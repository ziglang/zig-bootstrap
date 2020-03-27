# bootstrap-zig

The purpose of this project is to start with minimum system dependencies and
end with a fully operational Zig compiler for any target.

## Status

None of this works yet, it's still an experiment.

## Host System Dependencies

 * C++ compiler capable of building LLVM, Clang, and LLD from source.
 * cmake 3.4.3 or later

## Build Instructions

```
make TARGET="$triple"
```

### Supported Triples

 * aarch64_be-linux-gnu
 * aarch64_be-linux-musl
 * aarch64_be-windows-gnu
 * aarch64-linux-gnu
 * aarch64-linux-musl
 * aarch64-windows-gnu
 * armeb-linux-gnueabi
 * armeb-linux-gnueabihf
 * armeb-linux-musleabi
 * armeb-linux-musleabihf
 * armeb-windows-gnu
 * arm-linux-gnueabi
 * arm-linux-gnueabihf
 * arm-linux-musleabi
 * arm-linux-musleabihf
 * arm-windows-gnu
 * i386-linux-gnu
 * i386-linux-musl
 * i386-windows-gnu
 * mips64el-linux-gnuabi64
 * mips64el-linux-gnuabin32
 * mips64el-linux-musl
 * mips64-linux-gnuabi64
 * mips64-linux-gnuabin32
 * mips64-linux-musl
 * mipsel-linux-gnu
 * mipsel-linux-musl
 * mips-linux-gnu
 * mips-linux-musl
 * powerpc64le-linux-gnu
 * powerpc64le-linux-musl
 * powerpc64-linux-gnu
 * powerpc64-linux-musl
 * powerpc-linux-gnu
 * powerpc-linux-musl
 * riscv64-linux-gnu
 * riscv64-linux-musl
 * s390x-linux-gnu
 * s390x-linux-musl
 * sparc-linux-gnu
 * sparcv9-linux-gnu
 * wasm32-freestanding-musl
 * x86_64-linux-gnu
 * x86_64-linux-gnux32
 * x86_64-linux-musl
 * x86_64-windows-gnu
