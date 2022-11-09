@echo off

SETLOCAL EnableDelayedExpansion
if NOT DEFINED VSCMD_VER (
   echo error: this script must be run within the visual studio developer command prompt
   exit /b 1
)

if "%1" == "" (set TARGET=x86_64-windows-gnu) ELSE (set TARGET=%1)
if "%2" == "" (set MCPU=native) ELSE (set MCPU=%2)

set TARGET_OS_CMAKE=""
FOR /F "tokens=2 delims=-" %%i IN (%TARGET%) DO (
  IF "%%i"=="macos" set TARGET_OS_CMAKE="Darwin"
  IF "%%i"=="freebsd" set TARGET_OS_CMAKE="FreeBSD"
  IF "%%i"=="windows" set TARGET_OS_CMAKE="Windows"
  IF "%%i"=="linux" set TARGET_OS_CMAKE="Linux"
)

set OUTDIR=out-win
set ROOTDIR=%~dp0
set "ROOTDIR_CMAKE=%ROOTDIR:\=/%"
set ZIG_VERSION="0.11.0-dev.78+28288dcbb"

set JOBS_ARG=
set BUILD_SYSTEM_ARGS=

pushd %ROOTDIR%

rem Build zlib for the host
mkdir "%ROOTDIR%%OUTDIR%\build-zlib-host"
cd "%ROOTDIR%%OUTDIR%\build-zlib-host"
cmake "%ROOTDIR%/zlib" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

type CMakeCache.txt | findstr /C:"CMAKE_GENERATOR:INTERNAL=Visual Studio" >nul
if %ERRORLEVEL% EQU 0 (
   rem The cmake -j argument with visual studio will start multiple MSBuild instances, but only one cl.exe instance
   set JOBS_ARG=""
   set BUILD_SYSTEM_ARGS=-- /p:CL_MPcount=%NUMBER_OF_PROCESSORS%
)

cmake --build . %JOBS_ARG% --target install %BUILD_SYSTEM_ARGS%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Build the libraries for Zig to link against, as well as native `llvm-tblgen` using msvc
mkdir "%ROOTDIR%%OUTDIR%\build-llvm-host"
cd "%ROOTDIR%%OUTDIR%\build-llvm-host"
cmake "%ROOTDIR%/llvm" ^
  -DLLVM_ENABLE_PROJECTS="lld;clang" ^
  -DLLVM_ENABLE_LIBXML2=OFF ^
  -DLLVM_ENABLE_ZSTD=OFF ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR%/%OUTDIR%/host" ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DLLVM_INCLUDE_GO_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DLLVM_ENABLE_BINDINGS=OFF ^
  -DLLVM_ENABLE_OCAMLDOC=OFF ^
  -DLLVM_ENABLE_Z3_SOLVER=OFF ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DCLANG_INCLUDE_DOCS=OFF ^
  -DLLVM_INCLUDE_DOCS=OFF ^
  -DLLVM_USE_CRT_RELEASE=MT ^
  -DCMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install %BUILD_SYSTEM_ARGS%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Build an x86_64-windows-msvc zig using msvc, linking against LLVM/Clang/LLD built by msvc
mkdir "%ROOTDIR%%OUTDIR%\build-zig-host"
cd "%ROOTDIR%%OUTDIR%\build-zig-host"
cmake "%ROOTDIR%/zig" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR%/%OUTDIR%/host" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DZIG_STATIC=ON ^
  -DZIG_ENABLE_ZSTD=OFF ^
  -DZIG_TARGET_TRIPLE=x86_64-windows-msvc ^
  -DZIG_VERSION="%ZIG_VERSION%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install %BUILD_SYSTEM_ARGS%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set ZIG=%ROOTDIR%%OUTDIR%\host\bin\zig.exe
set "ZIG=%ZIG:\=/%"

rem Cross compile zlib for the target
mkdir "%ROOTDIR%%OUTDIR%\build-zlib-%TARGET%-%MCPU%"
cd "%ROOTDIR%%OUTDIR%\build-zlib-%TARGET%-%MCPU%"
cmake "%ROOTDIR%/zlib" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DCMAKE_SYSTEM_NAME="%TARGET_OS_CMAKE%" ^
  -DCMAKE_C_COMPILER="%ZIG%;cc;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_CXX_COMPILER="%ZIG%;c++;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_ASM_COMPILER="%ZIG%;cc;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_RC_COMPILER="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-rc" ^
  -DCMAKE_AR="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ar" ^
  -DCMAKE_RANLIB="%ROOTDIR_CMAKE%%OUTDIR%/host/bin/llvm-ranlib"
cmake --build . %JOBS_ARG% --target install %BUILD_SYSTEM_ARGS%
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

rem Cross compile LLVM for the target
mkdir "%ROOTDIR%%OUTDIR%\build-llvm-%TARGET%-%MCPU%"
cd "%ROOTDIR%%OUTDIR%\build-llvm-%TARGET%-%MCPU%"
cmake "%ROOTDIR%/llvm" ^
  -DCMAKE_INSTALL_PREFIX="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_PREFIX_PATH="%ROOTDIR_CMAKE%%OUTDIR%/%TARGET%-%MCPU%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_CROSSCOMPILING=True ^
  -DCMAKE_SYSTEM_NAME="%TARGET_OS_CMAKE%" ^
  -DCMAKE_C_COMPILER="%ZIG%;cc;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_CXX_COMPILER="%ZIG%;c++;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
  -DCMAKE_ASM_COMPILER="%ZIG%;cc;-fno-sanitize=all;-s;-target;%TARGET%;-mcpu=%MCPU%" ^
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
  -DLLVM_INCLUDE_GO_TESTS=OFF ^
  -DLLVM_INCLUDE_EXAMPLES=OFF ^
  -DLLVM_INCLUDE_BENCHMARKS=OFF ^
  -DLLVM_INCLUDE_DOCS=OFF ^
  -DLLVM_DEFAULT_TARGET_TRIPLE="%TARGET%" ^
  -DCLANG_TABLEGEN="%ROOTDIR_CMAKE%%OUTDIR%/build-llvm-host/bin/clang-tblgen.exe" ^
  -DCLANG_BUILD_TOOLS=OFF ^
  -DCLANG_INCLUDE_DOCS=OFF ^
  -DCLANG_ENABLE_ARCMT=ON ^
  -DLIBCLANG_BUILD_STATIC=ON
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cmake --build . %JOBS_ARG% --target install %BUILD_SYSTEM_ARGS%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

rem Finally, we can cross compile Zig itself, with Zig.
cd "%ROOTDIR%\zig"
%ZIG% build ^
  --prefix "%ROOTDIR%%OUTDIR%\zig-%TARGET%-%MCPU%" ^
  --search-prefix "%ROOTDIR%%OUTDIR%\%TARGET%-%MCPU%" ^
  -Dstatic-llvm ^
  -Drelease ^
  -Dstrip ^
  -Dtarget="%TARGET%" ^
  -Dcpu="%MCPU%" ^
  -Dversion-string=%ZIG_VERSION% ^
  -Denable-stage1
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

popd
