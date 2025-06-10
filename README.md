# zig-bootstrap

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Version Information

This repository copies sources from upstream. Patches listed below. Use git
to find and inspect the patch diffs.

 * LLVM, LLD, Clang 20.1.2
 * zlib 1.3.1
 * zstd 1.5.2
 * zig 0.15.0-dev.769+4d7980645

For other versions, check the git tags of this repository.

### Patches

 * all: Deleted unused files.
 * LLVM: Support .lib extension for static zstd.
 * LLVM: Portable handling of .def linker flag
 * LLVM: Don't pass -static when building executables.
 * LLVM: Fix `Triple::isTargetEHABICompatible()` for NetBSD
 * Clang: Ignore the examples directory
 * Clang: Disable building of libclang-cpp.so.
 * LLD: Added additional include directory to Zig's libunwind.
 * LLD: Respect `LLD_BUILD_TOOLS=OFF`
 * LLD: Skip building docs
 * zlib: Delete the ability to build a shared library.

## Host System Dependencies

 * C++ compiler capable of building LLVM, Clang, and LLD from source (GCC 5.1+
   or Clang)
     * On some systems, static libstdc++/libc++ may need to be installed
 * CMake 3.19 or later
 * make, ninja, or any other build system supported by CMake
 * POSIX system (bash, mkdir, cd)
 * Python 3

## Build Instructions

```
./build <arch>-<os>-<abi> <mcpu>
```

All parameters are required:

 * `<arch>-<os>-<abi>`: Replace with one of the Supported Targets below, or use
   `native` for the `<arch>` value (e.g. `native-linux-gnu`) to use the native
   architecture.
 * `<mcpu>`: Replace with a `-mcpu` parameter of Zig. `baseline` is recommended
   and means it will target a generic CPU for the target. `native` means it
   will target the native CPU. See the Zig documentation for more details.

Please be aware of the following two CMake environment variables that can
significantly affect how long it takes to build:

 * `CMAKE_GENERATOR` can be used to select a different generator instead of the
   default. For example, `CMAKE_GENERATOR=Ninja`.
 * `CMAKE_BUILD_PARALLEL_LEVEL` can be used to introduce parallelism to build
   systems (such as make) which do not default to parallel builds. This option
   is irrelevant when using Ninja.

When it succeeds, output can be found in `out/zig-<target>-<cpu>/`.

## Windows Build Instructions

Bootstrapping on Windows with MSVC is also possible via `build.bat`, which
takes the same arguments as `build` above.

This script requires that the "C++ CMake tools for Windows" component be
installed via the Visual Studio installer.

The script must be run within the `Developer Command Prompt for VS 2019` shell:

```
build.bat <arch>-<os>-<abi> <mcpu>
```

To build for x86 Windows, run the script within the `x86 Native Tools Command Prompt for VS 2019`.

### Supported Targets

If you try a "not tested" one and find a problem please file an issue,
and a pull request linking to the issue in the table.

If you try a "not tested" one and find that it works, please file a pull request
changing the status to "OK".

If you try an "OK" one and it does not work, please check if there is an existing
issue, and if not, file an issue.

Note: Generally, for Linux targets, we prefer the musl libc builds over the
glibc builds here, because musl builds end up producing a static binary, which
is more portable across Linux distributions.

#### FreeBSD

**Note:** You currently need to use `freebsd.14.0` or later, not just `freebsd`.

| Target                     | Status |
|----------------------------|--------|
| `aarch64-freebsd-none`     | OK     |
| `arm-freebsd-eabihf`       | [#235](https://github.com/ziglang/zig-bootstrap/issues/235) |
| `powerpc64-freebsd-none`   | OK     |
| `powerpc64le-freebsd-none` | OK     |
| `riscv64-freebsd-none`     | OK     |
| `x86_64-freebsd-none`      | OK     |

#### Linux

| Target                      | Status |
|-----------------------------|--------|
| `aarch64-linux-gnu`         | OK     |
| `aarch64-linux-musl`        | OK     |
| `aarch64_be-linux-gnu`      | OK     |
| `aarch64_be-linux-musl`     | OK     |
| `arm-linux-gnueabi`         | OK     |
| `arm-linux-gnueabihf`       | OK     |
| `arm-linux-musleabi`        | OK     |
| `arm-linux-musleabihf`      | OK     |
| `armeb-linux-gnueabi`       | OK     |
| `armeb-linux-gnueabihf`     | OK     |
| `armeb-linux-musleabi`      | OK     |
| `armeb-linux-musleabihf`    | OK     |
| `hexagon-linux-musl`        | [#215](https://github.com/ziglang/zig-bootstrap/issues/215) |
| `loongarch64-linux-gnu`     | OK     |
| `loongarch64-linux-gnusf`   | OK     |
| `loongarch64-linux-musl`    | OK     |
| `mips-linux-gnueabi`        | OK     |
| `mips-linux-gnueabihf`      | OK     |
| `mips-linux-musleabi`       | OK     |
| `mips-linux-musleabihf`     | OK     |
| `mips64-linux-gnuabi64`     | OK     |
| `mips64-linux-gnuabin32`    | OK     |
| `mips64-linux-muslabi64`    | OK     |
| `mips64-linux-muslabin32`   | OK     |
| `mips64el-linux-gnuabi64`   | OK     |
| `mips64el-linux-gnuabin32`  | [#214](https://github.com/ziglang/zig-bootstrap/issues/214) |
| `mips64el-linux-muslabi64`  | OK     |
| `mips64el-linux-muslabin32` | OK     |
| `mipsel-linux-gnueabi`      | OK     |
| `mipsel-linux-gnueabihf`    | OK     |
| `mipsel-linux-musleabi`     | OK     |
| `mipsel-linux-musleabihf`   | OK     |
| `powerpc-linux-gnueabi`     | OK     |
| `powerpc-linux-gnueabihf`   | OK     |
| `powerpc-linux-musleabi`    | OK     |
| `powerpc-linux-musleabihf`  | OK     |
| `powerpc64-linux-gnu`       | [#113](https://github.com/ziglang/zig-bootstrap/issues/113) |
| `powerpc64-linux-musl`      | OK     |
| `powerpc64le-linux-gnu`     | OK     |
| `powerpc64le-linux-musl`    | OK     |
| `riscv32-linux-gnu`         | OK     |
| `riscv32-linux-musl`        | OK     |
| `riscv64-linux-gnu`         | OK     |
| `riscv64-linux-musl`        | OK     |
| `s390x-linux-gnu`           | OK     |
| `s390x-linux-musl`          | OK     |
| `sparc-linux-gnu`           | [#117](https://github.com/ziglang/zig-bootstrap/issues/117) |
| `sparc64-linux-gnu`         | [#172](https://github.com/ziglang/zig-bootstrap/issues/172) |
| `thumb-linux-musleabi`      | OK     |
| `thumb-linux-musleabihf`    | OK     |
| `thumbeb-linux-musleabi`    | OK     |
| `thumbeb-linux-musleabihf`  | OK     |
| `x86-linux-gnu`             | OK     |
| `x86-linux-musl`            | OK     |
| `x86_64-linux-gnu`          | OK     |
| `x86_64-linux-gnux32`       | OK     |
| `x86_64-linux-musl`         | OK     |
| `x86_64-linux-muslx32`      | OK     |

#### macOS

| Target               | Status |
|----------------------|--------|
| `aarch64-macos-none` | OK     |
| `x86_64-macos-none`  | OK     |

#### NetBSD

**Note:** You currently need to use `netbsd.10.1` or later, not just `netbsd`.

| Target                   | Status |
|--------------------------|--------|
| `aarch64-netbsd-none`    | [#218](https://github.com/ziglang/zig-bootstrap/issues/218) |
| `aarch64_be-netbsd-none` | [#219](https://github.com/ziglang/zig-bootstrap/issues/219) |
| `arm-netbsd-eabi`        | [#220](https://github.com/ziglang/zig-bootstrap/issues/220) |
| `arm-netbsd-eabihf`      | [#221](https://github.com/ziglang/zig-bootstrap/issues/221) |
| `armeb-netbsd-eabi`      | [#222](https://github.com/ziglang/zig-bootstrap/issues/222) |
| `armeb-netbsd-eabihf`    | [#223](https://github.com/ziglang/zig-bootstrap/issues/223) |
| `mips-netbsd-eabi`       | [#224](https://github.com/ziglang/zig-bootstrap/issues/224) |
| `mips-netbsd-eabihf`     | [#225](https://github.com/ziglang/zig-bootstrap/issues/225) |
| `mipsel-netbsd-eabi`     | [#226](https://github.com/ziglang/zig-bootstrap/issues/226) |
| `mipsel-netbsd-eabihf`   | [#227](https://github.com/ziglang/zig-bootstrap/issues/227) |
| `powerpc-netbsd-eabi`    | [#228](https://github.com/ziglang/zig-bootstrap/issues/228) |
| `powerpc-netbsd-eabihf`  | [#229](https://github.com/ziglang/zig-bootstrap/issues/229) |
| `riscv32-netbsd-none`    | [#233](https://github.com/ziglang/zig-bootstrap/issues/233) |
| `riscv64-netbsd-none`    | [#234](https://github.com/ziglang/zig-bootstrap/issues/234) |
| `sparc-netbsd-none`      | [#230](https://github.com/ziglang/zig-bootstrap/issues/230) |
| `sparc64-netbsd-none`    | [#231](https://github.com/ziglang/zig-bootstrap/issues/231) |
| `x86-netbsd-none`        | [#232](https://github.com/ziglang/zig-bootstrap/issues/232) |
| `x86_64-netbsd-none`     | [#71](https://github.com/ziglang/zig-bootstrap/issues/71) |

#### Windows

| Target                | Status |
|-----------------------|--------|
| `aarch64-windows-gnu` | OK     |
| `thumb-windows-gnu`   | OK     |
| `x86-windows-gnu`     | OK     |
| `x86_64-windows-gnu`  | OK     |
