#!/bin/sh

if [ ! -d .dotnet ]; then
  for arch in arm64 x64; do
    echo "===== Installing .NET SDK 9.0 (${arch}) ====="
    mkdir -p .dotnet/${arch}-9.0-sdk
    curl -sSL https://aka.ms/dotnet/9.0/dotnet-sdk-osx-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk -xzf -
    echo "===== Installing .NET SDK 9.0 with .NET Runtime 10.0 (${arch}) ====="
    cp -a .dotnet/${arch}-9.0-sdk .dotnet/${arch}-9.0-sdk+10.0-runtime
    curl -sSL https://aka.ms/dotnet/10.0/dotnet-runtime-osx-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk+10.0-runtime -xzf -
    echo "===== Installing .NET SDK 9.0 with .NET Runtime 10.0 and .NET Runtime 9.0 command (${arch}) ====="
    cp -a .dotnet/${arch}-9.0-sdk+10.0-runtime .dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command
    curl -sSL https://aka.ms/dotnet/9.0/dotnet-runtime-osx-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command -xzf - dotnet
  done
fi

echo "===== Building native library ====="
cmake -B build -S . -D 'CMAKE_OSX_ARCHITECTURES=arm64;x86_64'
cmake --build build

echo "===== Building managed projects ====="
.dotnet/arm64-9.0-sdk/dotnet build csharp
.dotnet/arm64-9.0-sdk/dotnet build csharp.test

for arch in arm64 x64; do
  for config in ${arch}-9.0-sdk ${arch}-9.0-sdk+10.0-runtime ${arch}-9.0-sdk+10.0-runtime+9.0-command; do
    echo "===== Testing with ${config} ====="
    .dotnet/${config}/dotnet run --project csharp --no-build
    .dotnet/${config}/dotnet test csharp.test --no-build
  done
done
