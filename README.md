# bootstrap-zig

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Version Information

This repository copies sources from upstream.

 * LLVM 10
 * Clang 10
 * Zig 0.5.0+7beea4717
   - When 0.6.0 is released, this repository will gain a git tag with that version.

## Host System Dependencies

 * C++ compiler capable of building LLVM, Clang, and LLD from source
 * cmake 3.4.3 or later
 * make
 * POSIX shell

## Build Instructions

```
build -j1 triple [options]
```

Replace `-j1` with your jobs parameter to make, and `triple` with one of the
Supported Triples below.

If it succeeds, the output will be in `out/zig-triple/`.

`[options]` could be, for example: `-mcpu=generic+v6kz`.

Note that the `triple` parameter is not optional. For the native target, you
still have to pass the triple explicitly. To make it native, additionally
pass `-mcpu=native` for `[options]`.

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
| `aarch64_be-linux-gnu`     | not tested     |
| `aarch64_be-linux-musl`    | not tested     |
| `aarch64_be-windows-gnu`   | not tested     |
| `aarch64-linux-gnu`        | not tested     |
| `aarch64-linux-musl`       | OK             |
| `aarch64-windows-gnu`      | not tested     |
| `armeb-linux-gnueabi`      | not tested     |
| `armeb-linux-gnueabihf`    | not tested     |
| `armeb-linux-musleabi`     | not tested     |
| `armeb-linux-musleabihf`   | not tested     |
| `armeb-windows-gnu`        | not tested     |
| `arm-linux-gnueabi`        | not tested     |
| `arm-linux-gnueabihf`      | not tested     |
| `arm-linux-musleabi`       | OK             |
| `arm-linux-musleabihf`     | OK             |
| `arm-windows-gnu`          | not tested     |
| `i386-linux-gnu`           | not tested     |
| `i386-linux-musl`          | OK             |
| `i386-windows-gnu`         | not tested     |
| `mips64el-linux-gnuabi64`  | not tested     |
| `mips64el-linux-gnuabin32` | not tested     |
| `mips64el-linux-musl`      | [#3](https://github.com/ziglang/bootstrap/issues/3) |
| `mips64-linux-gnuabi64`    | not tested     |
| `mips64-linux-gnuabin32`   | not tested     |
| `mips64-linux-musl`        | not tested     |
| `mipsel-linux-gnu`         | not tested     |
| `mipsel-linux-musl`        | [#12](https://github.com/ziglang/bootstrap/issues/12) |
| `mips-linux-gnu`           | not tested     |
| `mips-linux-musl`          | not tested     |
| `powerpc64le-linux-gnu`    | not tested     |
| `powerpc64le-linux-musl`   | [#5](https://github.com/ziglang/bootstrap/issues/5) |
| `powerpc64-linux-gnu`      | not tested     |
| `powerpc64-linux-musl`     | not tested     |
| `powerpc-linux-gnu`        | not tested     |
| `powerpc-linux-musl`       | not tested     |
| `riscv64-linux-gnu`        | not tested     |
| `riscv64-linux-musl`       | [#4](https://github.com/ziglang/bootstrap/issues/4) |
| `s390x-linux-gnu`          | not tested     |
| `s390x-linux-musl`         | not tested     |
| `sparc-linux-gnu`          | not tested     |
| `sparcv9-linux-gnu`        | not tested     |
| `wasm32-freestanding-musl` | not tested     |
| `x86_64-linux-gnu`         | OK             |
| `x86_64-linux-gnux32`      | not tested     |
| `x86_64-linux-musl`        | OK             |
| `x86_64-windows-gnu`       | [#1](https://github.com/ziglang/bootstrap/pull/1) [#8](https://github.com/ziglang/bootstrap/issues/8) |

#### Other Notable Targets Known to Work

 * `arm-linux-musleabi` with `-mcpu=generic+v6kz`. This produces a build of Zig
   that runs on the RPi 1 and RPi Zero.
   - If you want to produce a build for this CPU exactly, use `-mcpu=arm1176jzf_s`.
