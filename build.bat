setlocal
set JOBS=%1
set TARGET=%2

set ROOTDIR=%cd%

:: First build the libraries for Zig to link against, as well as native `llvm-tblgen`.
mkdir %ROOTDIR%\out\build-llvm-host
cd %ROOTDIR%\out\build-llvm-host
cmake -GNinja %ROOTDIR%\llvm ^
  -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DLLVM_USE_CRT_RELEASE=MT ^
  -DLLVM_ENABLE_PROJECTS="lld;clang" ^
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="AVR" ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DCMAKE_INSTALL_PREFIX=%ROOTDIR%\out\host ^
  -DCMAKE_PREFIX_PATH=%ROOTDIR%\out\host ^
  -DLLVM_BUILD_TOOLS=OFF ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DCMAKE_BUILD_TYPE=Release
ninja -j %JOBS% install
ninja -j %JOBS% llvm-config
copy bin\llvm-config.exe %ROOTDIR%\out\host\bin\llvm-config.exe

:: Now we build Zig, still with system C\C++ compiler, linking against LLVM,
:: Clang, LLD we just built from source.
mkdir %ROOTDIR%\out\build-zig-host
cd %ROOTDIR%\out\build-zig-host
cmake ..\..\zig -GNinja -DCMAKE_INSTALL_PREFIX=..\host -DCMAKE_PREFIX_PATH=..\host -DCMAKE_BUILD_TYPE=Release
ninja -j %JOBS% install

:: Now we have Zig as a cross compiler
set CC="%ROOTDIR%\out\host\bin\zig.exe"
set CXX="%ROOTDIR%\out\host\bin\zig.exe"

:: Replace backslashes (also coming from %ROOTDIR%) as cmake will choke on them
:: They will have to be passed as command line arguments to cmake in order to
:: keep them as forward slashes ...
set CC=%CC:\=/%
set CXX=%CXX:\=/%

:: Split zig arguments from compiler path otherwise cmake complains
set CFLAGS=cc -target %TARGET%
set CXXFLAGS=c++ -target %TARGET%

:: Rebuild LLVM with Zig.
mkdir %ROOTDIR%\out\build-llvm-%TARGET%
cd %ROOTDIR%\out\build-llvm-%TARGET%
cmake -GNinja %ROOTDIR%\llvm ^
  -DCMAKE_C_COMPILER=%CC% ^
  -DCMAKE_CXX_COMPILER=%CXX% ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DLLVM_USE_CRT_RELEASE=MT ^
  -DLLVM_ENABLE_PROJECTS="lld;clang" ^
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="AVR" ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DCMAKE_INSTALL_PREFIX=%ROOTDIR%\out\%TARGET% ^
  -DCMAKE_PREFIX_PATH=%ROOTDIR%\out\%TARGET% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DLLVM_TABLEGEN=%ROOTDIR%\out\host\bin\llvm-tblgen ^
  -DCLANG_TABLEGEN=%ROOTDIR%\out\build-llvm-host\bin\clang-tblgen ^
  -DLLVM_BUILD_TOOLS=OFF ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DLLVM_BUILD_STATIC=ON ^
  -DLIBCLANG_BUILD_STATIC=ON ^
  -DLLVM_DEFAULT_TARGET_TRIPLE=%TARGET%
ninja -j %JOBS% install

:: Finally, we can cross compile Zig itself, with Zig.
mkdir %ROOTDIR%\out\build-zig-%TARGET%
cd %ROOTDIR%\out\build-zig-%TARGET%
cmake -GNinja %ROOTDIR%\zig ^
  -DCMAKE_C_COMPILER=%CC% ^
  -DCMAKE_CXX_COMPILER=%CXX% ^
  -DCMAKE_INSTALL_PREFIX=%ROOTDIR%\out\zig-%TARGET% ^
  -DCMAKE_PREFIX_PATH=%ROOTDIR%\out\%TARGET% ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DZIG_TARGET_TRIPLE=%TARGET% ^
  -DZIG_EXECUTABLE=%ZIG%
ninja -j %JOBS% install

endlocal
