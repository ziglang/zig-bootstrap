# bootstrap-zig

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Version Information

This repository copies sources from upstream. Patches listed below. Use git
to find and inspect the patch diffs.

 * LLVM, LLD, Clang 19.1.0
 * zlib 1.3.1
 * zstd 1.5.2
 * zig 0.14.0-dev.2257+e6d2e1641

For other versions, check the git tags of this repository.

### Patches

 * all: Deleted unused files.
 * LLVM: Support .lib extension for static zstd.
 * LLVM: Portable handling of .def linker flag
 * Clang: Disable building of libclang-cpp.so.
 * LLD: Added additional include directory to Zig's libunwind.
 * LLD: Respect `LLD_BUILD_TOOLS=OFF`
 * zlib: Delete the ability to build a shared library.
 * [LLVM: Fix crash when FREEZE a half(f16) type on loongarch](https://github.com/llvm/llvm-project/pull/107791)

## Host System Dependencies

 * C++ compiler capable of building LLVM, Clang, and LLD from source (GCC 5.1+
   or Clang)
 * CMake 3.19 or later
 * make, ninja, or any other build system supported by CMake
 * POSIX system (bash, mkdir, cd)
 * Python 3

## Build Instructions

```
./build <arch>-<os>-<abi> <mcpu>
```

All parameters are required:

 * `<arch>-<os>-<abi>`: Replace with one of the Supported Triples below, or use
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

When it succeeds, output can be found in `out/zig-<triple>-<cpu>/`.

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

### Supported Triples

If you try a "not tested" one and find a problem please file an issue,
and a pull request linking to the issue in the table.

If you try a "not tested" one and find that it works, please file a pull request
changing the status to "OK".

If you try an "OK" one and it does not work, please check if there is an existing
issue, and if not, file an issue.

Note: Generally, for Linux targets, we prefer the musl libc builds over the
glibc builds here, because musl builds end up producing a static binary, which
is more portable across Linux distributions.

| triple                      | support status |
|-----------------------------|----------------|
| `aarch64-linux-gnu`         | OK             |
| `aarch64-linux-musl`        | OK             |
| `aarch64-macos-none`        | OK             |
| `aarch64-windows-gnu`       | OK             |
| `aarch64_be-linux-gnu`      | OK             |
| `aarch64_be-linux-musl`     | OK             |
| `arm-linux-gnueabi`         | OK             |
| `arm-linux-gnueabihf`       | OK             |
| `arm-linux-musleabi`        | OK             |
| `arm-linux-musleabihf`      | OK             |
| `armeb-linux-gnueabi`       | OK             |
| `armeb-linux-gnueabihf`     | OK             |
| `armeb-linux-musleabi`      | OK             |
| `armeb-linux-musleabihf`    | OK             |
| `loongarch64-linux-gnu`     | OK             |
| `loongarch64-linux-gnusf`   | OK             |
| `loongarch64-linux-musl`    | OK             |
| `mips-linux-gnueabi`        | OK             |
| `mips-linux-gnueabihf`      | OK             |
| `mips-linux-musleabi`       | OK             |
| `mips-linux-musleabihf`     | OK             |
| `mips64-linux-gnuabi64`     | OK             |
| `mips64-linux-gnuabin32`    | OK             |
| `mips64-linux-muslabi64`    | OK             |
| `mips64-linux-muslabin32`   | OK             |
| `mips64el-linux-gnuabi64`   | OK             |
| `mips64el-linux-gnuabin32`  | OK             |
| `mips64el-linux-muslabi64`  | OK             |
| `mips64el-linux-muslabin32` | OK             |
| `mipsel-linux-gnueabi`      | OK             |
| `mipsel-linux-gnueabihf`    | OK             |
| `mipsel-linux-musleabi`     | OK             |
| `mipsel-linux-musleabihf`   | OK             |
| `powerpc-linux-gnueabi`     | OK             |
| `powerpc-linux-gnueabihf`   | OK             |
| `powerpc-linux-musleabi`    | OK             |
| `powerpc-linux-musleabihf`  | OK             |
| `powerpc64-linux-gnu`       | [#113](https://github.com/ziglang/zig-bootstrap/issues/113) |
| `powerpc64-linux-musl`      | OK             |
| `powerpc64le-linux-gnu`     | OK             |
| `powerpc64le-linux-musl`    | OK             |
| `riscv32-linux-gnu`         | OK             |
| `riscv32-linux-musl`        | OK             |
| `riscv64-linux-gnu`         | OK             |
| `riscv64-linux-musl`        | OK             |
| `s390x-linux-gnu`           | OK             |
| `s390x-linux-musl`          | OK             |
| `sparc-linux-gnu`           | [#117](https://github.com/ziglang/zig-bootstrap/issues/117) |
| `sparc64-linux-gnu`         | [#172](https://github.com/ziglang/zig-bootstrap/issues/172) |
| `thumb-linux-musleabi`      | OK             |
| `thumb-linux-musleabihf`    | OK             |
| `thumb-windows-gnu`         | OK             |
| `thumbeb-linux-musleabi`    | OK             |
| `thumbeb-linux-musleabihf`  | OK             |
| `x86-linux-gnu`             | OK             |
| `x86-linux-musl`            | OK             |
| `x86-windows-gnu`           | OK             |
| `x86_64-freebsd-none`       | [#45](https://github.com/ziglang/bootstrap/issues/45) |
| `x86_64-linux-gnu`          | OK             |
| `x86_64-linux-gnux32`       | OK             |
| `x86_64-linux-musl`         | OK             |
| `x86_64-linux-muslx32`      | OK             |
| `x86_64-macos-none`         | OK             |
| `x86_64-netbsd-none`        | [#71](https://github.com/ziglang/zig-bootstrap/issues/71) |
| `x86_64-windows-gnu`        | OK             |

#### Other Notable Targets Known to Work

 * `arm-linux-musleabi` with mcpu value of `generic+v6kz`. This produces a
   build of Zig that runs on the RPi 1 and RPi Zero.
   - If you want to produce a build for this CPU exactly, use `arm1176jzf_s`.
