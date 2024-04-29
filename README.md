# bootstrap-zig

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Version Information

This repository copies sources from upstream. Patches listed below. Use git
to find and inspect the patch diffs.

 * LLVM, LLD, Clang release/18.x (commit 78b99c73ee4b96fe9ce0e294d4632326afb2db42)
 * zlib 1.3.1
 * zstd 1.5.2
 * zig 0.13.0-dev.69+c8b808826 (llvm18 branch)

For other versions, check the git tags of this repository.

### Patches

 * all: Deleted unused files.
 * LLVM: Support .lib extension for static zstd.
 * LLVM: Portable handling of .def linker flag
 * Clang: Disable building of libclang-cpp.so.
 * LLD: Added additional include directory to Zig's libunwind.
 * LLD: Respect `LLD_BUILD_TOOLS=OFF`
 * zlib: Delete the ability to build a shared library.

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

| triple                     | support status |
|----------------------------|----------------|
| `aarch64_be-linux-gnu`     | [#90](https://github.com/ziglang/zig-bootstrap/issues/90) |
| `aarch64_be-linux-musl`    | [#92](https://github.com/ziglang/zig-bootstrap/issues/92) |
| `aarch64_be-windows-gnu`   | [#94](https://github.com/ziglang/zig-bootstrap/issues/94) |
| `aarch64-linux-gnu`        | OK             |
| `aarch64-linux-musl`       | OK             |
| `aarch64-windows-gnu`      | OK             |
| `aarch64-macos-none`       | OK             |
| `armeb-linux-gnueabi`      | [#96](https://github.com/ziglang/zig-bootstrap/issues/96) |
| `armeb-linux-gnueabihf`    | [#97](https://github.com/ziglang/zig-bootstrap/issues/97) |
| `armeb-linux-musleabi`     | [#98](https://github.com/ziglang/zig-bootstrap/issues/98) |
| `armeb-linux-musleabihf`   | [#99](https://github.com/ziglang/zig-bootstrap/issues/99) |
| `armeb-windows-gnu`        | [#100](https://github.com/ziglang/zig-bootstrap/issues/100) |
| `arm-linux-gnueabi`        | [#101](https://github.com/ziglang/zig-bootstrap/issues/101) |
| `arm-linux-gnueabihf`      | [#102](https://github.com/ziglang/zig-bootstrap/issues/102) |
| `arm-linux-musleabi`       | [#103](https://github.com/ziglang/zig-bootstrap/issues/103) |
| `arm-linux-musleabihf`     | OK |
| `arm-windows-gnu`          | [#105](https://github.com/ziglang/zig-bootstrap/issues/105) |
| `i386-linux-gnu`           | not tested     |
| `i386-linux-musl`          | OK             |
| `i386-windows-gnu`         | OK             |
| `mips64el-linux-gnuabi64`  | [#106](https://github.com/ziglang/zig-bootstrap/issues/106) |
| `mips64el-linux-gnuabin32` | [#107](https://github.com/ziglang/zig-bootstrap/issues/107) |
| `mips64el-linux-musl`      | [#3](https://github.com/ziglang/bootstrap/issues/3) |
| `mips64-linux-gnuabi64`    | [#108](https://github.com/ziglang/zig-bootstrap/issues/108) |
| `mips64-linux-gnuabin32`   | [#109](https://github.com/ziglang/zig-bootstrap/issues/109) |
| `mips64-linux-musl`        | [#110](https://github.com/ziglang/zig-bootstrap/issues/110) |
| `mipsel-linux-gnu`         | [#111](https://github.com/ziglang/zig-bootstrap/issues/111) |
| `mipsel-linux-musl`        | [#12](https://github.com/ziglang/bootstrap/issues/12) |
| `mips-linux-gnu`           | [#112](https://github.com/ziglang/zig-bootstrap/issues/112) |
| `mips-linux-musl`          | not tested     |
| `powerpc64le-linux-gnu`    | [#24](https://github.com/ziglang/zig-bootstrap/issues/24) |
| `powerpc64le-linux-musl`   | OK             |
| `powerpc64-linux-gnu`      | [#113](https://github.com/ziglang/zig-bootstrap/issues/113) |
| `powerpc64-linux-musl`     | OK             |
| `powerpc-linux-gnu`        | [#114](https://github.com/ziglang/zig-bootstrap/issues/114) |
| `powerpc-linux-musl`       | OK             |
| `riscv64-linux-gnu`        | [#115](https://github.com/ziglang/zig-bootstrap/issues/115) |
| `riscv64-linux-musl`       | OK             |
| `s390x-linux-gnu`          | [#116](https://github.com/ziglang/zig-bootstrap/issues/116) |
| `s390x-linux-musl`         | [#52](https://github.com/ziglang/bootstrap/issues/52) |
| `sparc-linux-gnu`          | [#117](https://github.com/ziglang/zig-bootstrap/issues/117) |
| `sparcv9-linux-gnu`        | [ziglang/zig#4931](https://github.com/ziglang/zig/issues/4931) |
| `x86_64-freebsd-gnu`       | [#45](https://github.com/ziglang/bootstrap/issues/45) |
| `x86_64-linux-gnu`         | OK             |
| `x86_64-linux-gnux32`      | [#20](https://github.com/ziglang/bootstrap/issues/20) |
| `x86_64-linux-musl`        | OK             |
| `x86_64-windows-gnu`       | OK             |
| `x86_64-macos-none`        | OK             |
| `loongarch64-linux-musl`   | [#164](https://github.com/ziglang/zig-bootstrap/issues/164) |
| `loongarch64-linux-gnu`    | [#166](https://github.com/ziglang/zig-bootstrap/issues/166) |

#### Other Notable Targets Known to Work

 * `arm-linux-musleabi` with mcpu value of `generic+v6kz`. This produces a
   build of Zig that runs on the RPi 1 and RPi Zero.
   - If you want to produce a build for this CPU exactly, use `arm1176jzf_s`.
