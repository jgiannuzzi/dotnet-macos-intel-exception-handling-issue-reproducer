## Reproducer for a .NET 10.0 exception handling issue on macOS Intel

There is an issue on macOS Intel with the .NET 10.0 Runtime when calling into a native library written in C++ that throws some exceptions inheriting from `std::exception` and catches them as their parent. This repository is a minimal reproducer of this issue.

### Conditions for the issue to happen

- Running on macOS _Intel_ architecture, regardless of the version (tested on macOS 12 through 26) - the issue appears natively and under Rosetta emulation too
- A native library that exposes a C interface and _internally_ throws `std::out_of_range` or `std::length_error` exceptions _and catches_ them as `std::exception`
- Either
  - A managed _test_ that calls this C interface and the .NET 10.0.0 `dotnet` _command_ used to run the tests, regardless of target framework (e.g. `net9.0`)
  - A managed _program_ that calls this C interface and the .NET 10.0.0 _Runtime_, regardless of `dotnet` command (e.g. 9.0.11)

### How this reproducer is structured

#### `cpp` directory

This directory contains the code for a native C++ library exposing a C interface.

It contains multiple functions that throw and catch exceptions inheriting from `std::exception`. They are caught either as `std::exception` or explicitly as their own type. They are thrown explictly or by calling a known `stdlib` function that throws them.

#### `csharp` directory

This directory contains the managed code for a C# program that consumes the native library.

It calls each entry point and prints out their result. `0` means the exception was caught as expected. `1` means that the catch-all `...` was used instead, which should _not_ happen.

#### `csharp.test` directory

This directory contains the managed code for a suite of C# tests that consume the the native library.

They call each entry point and assert that their result is `0`.

#### `reproducer.sh` shell script

This script demonstrates the issue by:
- downloading and manually setting up various configuration of the .NET SDK:
  - .NET 9.0 SDK
  - .NET 9.0 SDK with .NET 10.0 Runtime (and its `dotnet` command)
  - .NET 9.0 SDK with .NET 10.0 Runtime (but with the .NET 9.0 `dotnet` command)
  - .NET 10.0 SDK
  - .NET 10.0 SDK with .NET 9.0 `dotnet` command
- building the native library with `cmake`
- building the managed projects with the .NET SDK
- running the program and the tests with the various .NET configurations setup above

The script supports macOS and Linux (as a baseline), on both `arm64` and `x64` architectures.

On macOS Apple Silicon, the script will run for both the `arm64` and `x64` architectures. The latter runs via Rosetta 2.

### What are the symptoms?

On all combinations but one of OS, architecture, and .NET SDK/Runtime/command, the program outputs only `0`s and the tests all pass.

On macOS Intel, with the .NET 10.0 `dotnet` command and .NET 9.0 SDK, the tests that throw `std::out_of_range` or `std::length_error` and try to catch them as `std::exception` fail by having the native code go through the catch-all `...`. The program does not fail and only outputs `0`s.

On macOS Intel, with the .NET 10.0 Runtime, the program outputs `1` for the tests that throw `std::out_of_range` and `std::length_error`, whether with the .NET 10.0 or .NET 9.0 `dotnet` command. The tests also fail in the same way with the .NET 10.0 `dotnet` command, but succeed with the .NET 9.0 `dotnet` command.

### CI

There is [CI workflow](https://github.com/jgiannuzzi/dotnet-macos-intel-exception-handling-issue-reproducer/actions/workflows/ci.yml) that runs the reproducer script for all support Unix-based GitHub hosted runners. Checking the output of the script for any macOS runner demontstrates the issue. Search for `===== Testing with x64-9.0-sdk+10.0-runtime =====` and look at the test run. Also search for `===== Testing with x64-10.0` and look at the program outputs and the test runs.
