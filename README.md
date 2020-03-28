# bootstrap-zig

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Status

I've been testing with aarch64-linux-musl. It gets all the way to
successfully building zig0, and the next step is to improve build.zig
to support cross compiling instead of assuming native.

## Version Information

This repository copies sources from upstream.

 * LLVM 10
 * Clang 10
 * Zig 0.5.0+463b90b97 plus the branch that adds `zig c++` support.

## Host System Dependencies

 * C++ compiler capable of building LLVM, Clang, and LLD from source
 * cmake 3.4.3 or later
 * POSIX shell

## Build Instructions

```
build -j1 triple
```

Replace `-j1` with your jobs parameter to make, and `triple` with one of the
Supported Triples below.

If it succeeds, the output will be in `out/zig-triple/`.

### Supported Triples

If you try a "not tested" one and find a problem please file an issue,
and a pull request linking to the issue in the table.

If you try a "not tested" one and find that it works, please file a pull request
changing the status to "OK".

If you try an "OK" one and it does not work, please check if there is an existing
issue, and if not, file an issue.

| triple                     | support status |
|----------------------------|----------------|
| `aarch64_be-linux-gnu`     | not tested     |
| `aarch64_be-linux-musl`    | not tested     |
| `aarch64_be-windows-gnu`   | not tested     |
| `aarch64-linux-gnu`        | not tested     |
| `aarch64-linux-musl`       | working on it  |
| `aarch64-windows-gnu`      | not tested     |
| `armeb-linux-gnueabi`      | not tested     |
| `armeb-linux-gnueabihf`    | not tested     |
| `armeb-linux-musleabi`     | not tested     |
| `armeb-linux-musleabihf`   | not tested     |
| `armeb-windows-gnu`        | not tested     |
| `arm-linux-gnueabi`        | not tested     |
| `arm-linux-gnueabihf`      | not tested     |
| `arm-linux-musleabi`       | not tested     |
| `arm-linux-musleabihf`     | not tested     |
| `arm-windows-gnu`          | not tested     |
| `i386-linux-gnu`           | not tested     |
| `i386-linux-musl`          | not tested     |
| `i386-windows-gnu`         | not tested     |
| `mips64el-linux-gnuabi64`  | not tested     |
| `mips64el-linux-gnuabin32` | not tested     |
| `mips64el-linux-musl`      | not tested     |
| `mips64-linux-gnuabi64`    | not tested     |
| `mips64-linux-gnuabin32`   | not tested     |
| `mips64-linux-musl`        | not tested     |
| `mipsel-linux-gnu`         | not tested     |
| `mipsel-linux-musl`        | not tested     |
| `mips-linux-gnu`           | not tested     |
| `mips-linux-musl`          | not tested     |
| `powerpc64le-linux-gnu`    | not tested     |
| `powerpc64le-linux-musl`   | not tested     |
| `powerpc64-linux-gnu`      | not tested     |
| `powerpc64-linux-musl`     | not tested     |
| `powerpc-linux-gnu`        | not tested     |
| `powerpc-linux-musl`       | not tested     |
| `riscv64-linux-gnu`        | not tested     |
| `riscv64-linux-musl`       | not tested     |
| `s390x-linux-gnu`          | not tested     |
| `s390x-linux-musl`         | not tested     |
| `sparc-linux-gnu`          | not tested     |
| `sparcv9-linux-gnu`        | not tested     |
| `wasm32-freestanding-musl` | not tested     |
| `x86_64-linux-gnu`         | not tested     |
| `x86_64-linux-gnux32`      | not tested     |
| `x86_64-linux-musl`        | not tested     |
| `x86_64-windows-gnu`       | not tested     |
