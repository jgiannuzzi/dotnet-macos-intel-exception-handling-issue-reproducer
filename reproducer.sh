#!/bin/bash

case $(uname -sm) in
"Linux aarch64")
  os=linux
  osx_archs=()
  dotnet_archs=(arm64)
  ;;
"Linux x86_64")
  os=linux
  osx_archs=()
  dotnet_archs=(x64)
  ;;
"Darwin arm64")
  os=osx
  osx_archs=(arm64 x86_64)
  dotnet_archs=(arm64 x64)
  ;;
"Darwin x86_64")
  os=osx
  osx_archs=(x86_64)
  dotnet_archs=(x64)
  ;;
esac

if [ ! -d .dotnet ]; then
  for arch in "${dotnet_archs[@]}"; do
    echo "===== Installing .NET SDK 9.0 (${arch}) ====="
    mkdir -p ".dotnet/${arch}-9.0-sdk"
    curl -sSL "https://aka.ms/dotnet/9.0/dotnet-sdk-${os}-${arch}.tar.gz" | tar -C ".dotnet/${arch}-9.0-sdk" -xzf -
    echo "===== Installing .NET SDK 9.0 with .NET Runtime 10.0 (${arch}) ====="
    cp -a ".dotnet/${arch}-9.0-sdk" ".dotnet/${arch}-9.0-sdk+10.0-runtime"
    curl -sSL "https://aka.ms/dotnet/10.0/dotnet-runtime-${os}-${arch}.tar.gz" | tar -C ".dotnet/${arch}-9.0-sdk+10.0-runtime" -xzf -
    echo "===== Installing .NET SDK 9.0 with .NET Runtime 10.0 and .NET Runtime 9.0 command (${arch}) ====="
    cp -a ".dotnet/${arch}-9.0-sdk+10.0-runtime" ".dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command"
    curl -sSL "https://aka.ms/dotnet/9.0/dotnet-runtime-${os}-${arch}.tar.gz" | tar -C ".dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command" -xzf - dotnet
  done
fi

echo "===== Building native library ====="
cmake -B build -S . -D "CMAKE_OSX_ARCHITECTURES=$(
  IFS=";"
  echo "${osx_archs[*]}"
)"
cmake --build build

for arch in "${dotnet_archs[@]}"; do
  echo "===== Building managed projects (${arch}) ====="
  ".dotnet/${arch}-9.0-sdk/dotnet" build csharp
  ".dotnet/${arch}-9.0-sdk/dotnet" build csharp.test

  for config in ${arch}-9.0-sdk ${arch}-9.0-sdk+10.0-runtime ${arch}-9.0-sdk+10.0-runtime+9.0-command; do
    echo "===== Testing with ${config} ====="
    ".dotnet/${config}/dotnet" run --project csharp --no-build
    ".dotnet/${config}/dotnet" test csharp.test --no-build
  done
done
