rem This file is licensed under the public domain.

@echo off

SETLOCAL EnableDelayedExpansion
if NOT DEFINED VSCMD_VER (
   echo error: this script must be run within the visual studio developer command prompt
   exit /b 1
)

where ninja >nul 2>nul
if %ERRORLEVEL% neq 0 (
   echo error: this script requires ninja to be installed, as the Visual Studio cmake generator doesn't support alternate compilers
   exit /b %ERRORLEVEL%
)

if "%1" == "" (set "TARGET=x86_64-windows-gnu") ELSE (set TARGET=%~1)
if "%2" == "" (set "MCPU=native") ELSE (set MCPU=%~2)
if "%VSCMD_ARG_HOST_ARCH%"=="x86" set HOST_TARGET=x86-windows-msvc
if "%VSCMD_ARG_HOST_ARCH%"=="x64" set HOST_TARGET=x86_64-windows-msvc
echo Boostrapping targeting %TARGET% (%MCPU%), using %HOST_TARGET% as the host compiler

set TARGET_ABI=
set TARGET_OS_CMAKE=
FOR /F "tokens=2,3 delims=-" %%i IN ("%TARGET%") DO (
  IF "%%i"=="macos" set "TARGET_OS_CMAKE=Darwin"
  IF "%%i"=="freebsd" set "TARGET_OS_CMAKE=FreeBSD"
  IF "%%i"=="windows" set "TARGET_OS_CMAKE=Windows"
  IF "%%i"=="linux" set "TARGET_OS_CMAKE=Linux"
  set TARGET_ABI=%%j
)

set OUTDIR=out-win
if "%VSCMD_ARG_HOST_ARCH%"=="x86" set OUTDIR=out-win-x86

set ROOTDIR=%~dp0
set "ROOTDIR_CMAKE=%ROOTDIR:\=/%"
set ZIG_VERSION=0.12.0

set JOBS_ARG=

pushd %ROOTDIR%

rem Build zlib for the host
mkdir "%ROOTDIR%%OUTDIR%\build-zlib-host"
cd "%ROOTDIR%%OUTDIR%\build-zlib-host"
cmake "%ROOTDIR%/zlib" ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_USER_MAKE_RULES_OVERRIDE="%ROOTDIR%/zig/cmake/c_flag_overrides.cmake"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

cmake --build . %JOBS_ARG% --target install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Build the libraries for Zig to link against, as well as native `llvm-tblgen` using msvc
mkdir "%ROOTDIR%%OUTDIR%\build-llvm-host"
cd "%ROOTDIR%%OUTDIR%\build-llvm-host"
cmake "%ROOTDIR%/llvm" ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DLLVM_ENABLE_PROJECTS="lld;clang" ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DLLVM_ENABLE_ZSTD=OFF ^
  -DLLVM_INCLUDE_UTILS=OFF ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DLLVM_INCLUDE_DOCS=OFF ^
  -DLLVM_ENABLE_BINDINGS=OFF ^
  -DLLVM_ENABLE_OCAMLDOC=OFF ^
  -DLLVM_ENABLE_Z3_SOLVER=OFF ^
  -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF ^
  -DLLVM_TOOL_LLVM_LTO_BUILD=OFF ^
  -DLLVM_TOOL_LTO_BUILD=OFF ^
  -DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DCLANG_INCLUDE_DOCS=OFF ^
  -DLLVM_INCLUDE_DOCS=OFF ^
  -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF ^
  -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF ^
  -DCLANG_TOOL_ARCMT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_C_ARCMT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_LIBCLANG_BUILD=OFF ^
  -DLLVM_USE_CRT_RELEASE=MT ^
  -DLLVM_BUILD_LLVM_C_DYLIB=NO
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Build an x86_64-windows-msvc zig using msvc, linking against LLVM/Clang/LLD/zlib built by msvc
mkdir "%ROOTDIR%%OUTDIR%\build-zig-host"
cd "%ROOTDIR%%OUTDIR%\build-zig-host"
cmake "%ROOTDIR%/zig" ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR_CMAKE%%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR_CMAKE%%OUTDIR%/host" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DZIG_STATIC=ON ^
  -DZIG_STATIC_ZSTD=OFF ^
  -DZIG_TARGET_TRIPLE="%HOST_TARGET%" ^
  -DZIG_TARGET_MCPU=baseline

if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

IF "%TARGET_ABI%"=="msvc" (
   echo Building a target with the msvc ABI isn't supported yet
   exit /b
)

set ZIG=%ROOTDIR%%OUTDIR%\host\bin\zig.exe
set "ZIG=%ZIG:\=/%"
set "ZIG_LIB_DIR=%ROOTDIR%/zig/lib"

rem CMP0091=NEW is required in order for the CMAKE_MSVC_RUNTIME_LIBRARY value to be respected,
rem which we need to be set to MultiThreaded when building msvc ABI targets

rem Cross compile zlib for the target
mkdir "%ROOTDIR%%OUTDIR%\build-zlib-%TARGET%-%MCPU%"
cd "%ROOTDIR%%OUTDIR%\build-zlib-%TARGET%-%MCPU%"
cmake "%ROOTDIR%/zlib" ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DCMAKE_SYSTEM_NAME="%TARGET_OS_CMAKE%" ^
  -DCMAKE_C_COMPILER="%ZIG%;cc;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_CXX_COMPILER="%ZIG%;c++;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_ASM_COMPILER="%ZIG%;cc;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_RC_COMPILER="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-rc.exe" ^
  -DCMAKE_AR="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ar.exe" ^
  -DCMAKE_RANLIB="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ranlib.exe" ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW
cmake --build . %JOBS_ARG% --target install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Cross compile zstd for the target
mkdir "%ROOTDIR%%OUTDIR%\%TARGET%-%MCPU%\lib"
copy "%ROOTDIR%\zstd\lib\zstd.h" "%ROOTDIR%%OUTDIR%\%TARGET%-%MCPU%\include\zstd.h"
cd "%ROOTDIR%%OUTDIR%\%TARGET%-%MCPU%\lib"
%ZIG% build-lib ^
  --name zstd ^
  -target %TARGET% ^
  -mcpu=%MCPU% ^
  -fstrip ^
  -OReleaseFast ^
  -lc ^
  "%ROOTDIR%\zstd\lib\decompress\zstd_ddict.c" ^
  "%ROOTDIR%\zstd\lib\decompress\zstd_decompress.c" ^
  "%ROOTDIR%\zstd\lib\decompress\huf_decompress.c" ^
  "%ROOTDIR%\zstd\lib\decompress\huf_decompress_amd64.S" ^
  "%ROOTDIR%\zstd\lib\decompress\zstd_decompress_block.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstdmt_compress.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_opt.c" ^
  "%ROOTDIR%\zstd\lib\compress\hist.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_ldm.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_fast.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_compress_literals.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_double_fast.c" ^
  "%ROOTDIR%\zstd\lib\compress\huf_compress.c" ^
  "%ROOTDIR%\zstd\lib\compress\fse_compress.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_lazy.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_compress.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_compress_sequences.c" ^
  "%ROOTDIR%\zstd\lib\compress\zstd_compress_superblock.c" ^
  "%ROOTDIR%\zstd\lib\deprecated\zbuff_compress.c" ^
  "%ROOTDIR%\zstd\lib\deprecated\zbuff_decompress.c" ^
  "%ROOTDIR%\zstd\lib\deprecated\zbuff_common.c" ^
  "%ROOTDIR%\zstd\lib\common\entropy_common.c" ^
  "%ROOTDIR%\zstd\lib\common\pool.c" ^
  "%ROOTDIR%\zstd\lib\common\threading.c" ^
  "%ROOTDIR%\zstd\lib\common\zstd_common.c" ^
  "%ROOTDIR%\zstd\lib\common\xxhash.c" ^
  "%ROOTDIR%\zstd\lib\common\debug.c" ^
  "%ROOTDIR%\zstd\lib\common\fse_decompress.c" ^
  "%ROOTDIR%\zstd\lib\common\error_private.c" ^
  "%ROOTDIR%\zstd\lib\dictBuilder\zdict.c" ^
  "%ROOTDIR%\zstd\lib\dictBuilder\divsufsort.c" ^
  "%ROOTDIR%\zstd\lib\dictBuilder\fastcover.c" ^
  "%ROOTDIR%\zstd\lib\dictBuilder\cover.c"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Ideally we could use ZLIB_USE_STATIC_LIBS here (which would detect zlib correctly),
rem but this was added in 3.24 and the MSVC-bundled CMake is 3.20. Instead, for the msvc
rem ABI the zlib path is specified explicitly.

IF "%TARGET_ABI%"=="msvc" (
  set ZLIB_LIBRARY=-DZLIB_LIBRARY="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%/lib/z.lib"
) else (
  set ZLIB_LIBRARY=
)
rem Cross compile LLVM for the target
mkdir "%ROOTDIR%%OUTDIR%\build-llvm-%TARGET%-%MCPU%"
cd "%ROOTDIR%%OUTDIR%\build-llvm-%TARGET%-%MCPU%"
cmake "%ROOTDIR%/llvm" ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DCMAKE_SYSTEM_NAME="%TARGET_OS_CMAKE%" ^
  -DCMAKE_C_COMPILER="%ZIG%;cc;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_CXX_COMPILER="%ZIG%;c++;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_ASM_COMPILER="%ZIG%;cc;-fno-sanitize=all;-fno-stack-protector;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_RC_COMPILER="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-rc.exe" ^
  -DCMAKE_AR="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ar.exe" ^
  -DCMAKE_RANLIB="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ranlib.exe" ^
  -DLLVM_ENABLE_BACKTRACES=OFF ^
  -DLLVM_ENABLE_BINDINGS=OFF ^
  -DLLVM_ENABLE_CRASH_OVERRIDES=OFF ^
  -DLLVM_ENABLE_LIBEDIT=OFF ^
  -DLLVM_ENABLE_LIBPFM=OFF ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DLLVM_ENABLE_OCAMLDOC=OFF ^
  -DLLVM_ENABLE_PLUGINS=OFF ^
  -DLLVM_ENABLE_PROJECTS="lld;clang" ^
  -DLLVM_ENABLE_TERMINFO=OFF ^
  -DLLVM_ENABLE_Z3_SOLVER=OFF ^
  -DLLVM_ENABLE_ZLIB=FORCE_ON ^
  -DLLVM_ENABLE_ZSTD=FORCE_ON ^
  -DLLVM_USE_STATIC_ZSTD=ON ^
  -DLLVM_TABLEGEN="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-tblgen.exe" ^
  -DLLVM_BUILD_TOOLS=OFF ^
  -DLLVM_BUILD_STATIC=ON ^
  -DLLVM_INCLUDE_UTILS=OFF ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DLLVM_INCLUDE_DOCS=OFF ^
  -DLLVM_DEFAULT_TARGET_TRIPLE=%TARGET% ^
  -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF ^
  -DLLVM_TOOL_LLVM_LTO_BUILD=OFF ^
  -DLLVM_TOOL_LTO_BUILD=OFF ^
  -DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF ^
  -DCLANG_TABLEGEN="%ROOTDIR_CMAKE%%OUTDIR%/build-llvm-host/bin/clang-tblgen.exe" ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DCLANG_INCLUDE_DOCS=OFF ^
  -DCLANG_INCLUDE_TESTS=OFF ^
  -DCLANG_ENABLE_ARCMT=ON ^
  -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF ^
  -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF ^
  -DCLANG_TOOL_ARCMT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_C_ARCMT_TEST_BUILD=OFF ^
  -DCLANG_TOOL_LIBCLANG_BUILD=OFF ^
  %ZLIB_LIBRARY% ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Finally, we can cross compile Zig itself, with Zig.
cd "%ROOTDIR%\zig"
%ZIG% build ^
  --prefix "%ROOTDIR%%OUTDIR%\zig-%TARGET%-%MCPU%" ^
  --search-prefix "%ROOTDIR%%OUTDIR%\%TARGET%-%MCPU%" ^
  -Dflat ^
  -Dstatic-llvm ^
  -Doptimize=ReleaseFast ^
  -Dstrip ^
  -Dtarget="%TARGET%" ^
  -Dcpu="%MCPU%" ^
  -Dversion-string="%ZIG_VERSION%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

popd
