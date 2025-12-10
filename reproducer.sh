#!/bin/bash

# Global arrays to track failed tasks
TASK_FAIL_TITLES=()
TASK_FAIL_CODES=()

# Function to execute a task, tracking its status and grouping its output
with_task() {
  local continue_when_failed=0

  # Optional --continue_when_failed flag
  case "$1" in
  --continue_when_failed)
    continue_when_failed=1
    shift
    ;;
  esac

  local title="$1"
  shift

  local status=0

  # Start group / bold header
  if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "::group::$title"
  else
    echo -e "\033[1m$title\033[0m"
  fi

  # === Command execution ===
  if [[ "$1" == "--" ]]; then
    # Multi-command mode: everything after `--` is shell code
    shift
    local code="$*"
    if [[ -n "$code" ]]; then
      bash -o pipefail -e -c "$code" || status=$?
    fi
  else
    # Single command + args
    "$@" || status=$?
  fi

  # End group
  if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "::endgroup::"
  else
    echo
  fi

  # Track failure
  if ((status != 0)); then
    TASK_FAIL_TITLES+=("$title")
    TASK_FAIL_CODES+=("$status")

    if ((continue_when_failed == 0)); then
      echo "Task '$title' failed with status $status - aborting" >&2
      exit "$status"
    fi
  fi

  return "$status"
}

# Function to check whether any tasks failed
tasks_summary_and_exit() {
  if ((${#TASK_FAIL_TITLES[@]})); then
    echo "Summary of failed tasks:"
    local i
    for ((i = 0; i < ${#TASK_FAIL_TITLES[@]}; i++)); do
      echo "  - ${TASK_FAIL_TITLES[i]} (exit ${TASK_FAIL_CODES[i]})"
    done
    exit 1
  fi

  exit 0
}

# Configure .NET behaviour
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export DOTNET_NOLOGO=true

# Configure cURL behaviour - use a progress bar when running locally
curl_opts=-SL
if [ -n "${GITHUB_ACTIONS}" ]; then
  curl_opts+=s
else
  curl_opts+=#
fi

# Detect OS and architecture
case $(uname -sm) in
"Linux aarch64")
  os=linux
  osx_archs=""
  dotnet_archs=(arm64)
  ;;
"Linux x86_64")
  os=linux
  osx_archs=""
  dotnet_archs=(x64)
  ;;
"Darwin arm64")
  os=osx
  osx_archs="arm64;x86_64"
  dotnet_archs=(arm64 x64)
  ;;
"Darwin x86_64")
  os=osx
  osx_archs=x86_64
  dotnet_archs=(x64)
  ;;
esac

if [ ! -d .dotnet ]; then
  trap 'rm -rf .dotnet' EXIT
  for arch in "${dotnet_archs[@]}"; do
    with_task "Install .NET SDK 9.0 (${arch})" -- "
      mkdir -p .dotnet/${arch}-9.0-sdk
      curl ${curl_opts} https://aka.ms/dotnet/9.0/dotnet-sdk-${os}-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk -xzf -
    "
    with_task "Install .NET SDK 9.0 with .NET Runtime 10.0 (${arch})" -- "
      cp -a .dotnet/${arch}-9.0-sdk .dotnet/${arch}-9.0-sdk+10.0-runtime
      curl ${curl_opts} https://aka.ms/dotnet/10.0/dotnet-runtime-${os}-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk+10.0-runtime -xzf -
    "
    with_task "Install .NET SDK 9.0 with .NET Runtime 10.0 and .NET Runtime 9.0 command (${arch})" -- "
      cp -a .dotnet/${arch}-9.0-sdk+10.0-runtime .dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command
      curl ${curl_opts} https://aka.ms/dotnet/9.0/dotnet-runtime-${os}-${arch}.tar.gz | tar -C .dotnet/${arch}-9.0-sdk+10.0-runtime+9.0-command -xzf - ./dotnet
    "
    with_task "Install .NET SDK 10.0 (${arch})" -- "
      mkdir -p .dotnet/${arch}-10.0-sdk
      curl ${curl_opts} https://aka.ms/dotnet/10.0/dotnet-sdk-${os}-${arch}.tar.gz | tar -C .dotnet/${arch}-10.0-sdk -xzf -
    "
    with_task "Install .NET SDK 10.0 with .NET Runtime 9.0 command (${arch})" -- "
      cp -a .dotnet/${arch}-10.0-sdk .dotnet/${arch}-10.0-sdk+9.0-command
      curl ${curl_opts} https://aka.ms/dotnet/9.0/dotnet-runtime-${os}-${arch}.tar.gz | tar -C .dotnet/${arch}-10.0-sdk+9.0-command -xzf - ./dotnet
    "
  done
  trap - EXIT
fi

with_task "Build native library" -- "
  cmake -B build -S . -D CMAKE_OSX_ARCHITECTURES=\"${osx_archs}\"
  cmake --build build
"

for arch in "${dotnet_archs[@]}"; do
  for version in 9.0 10.0; do
    tfm=net${version}
    with_task "Build managed projects (${tfm}/${arch})" -- "
      .dotnet/${arch}-${version}-sdk/dotnet build csharp -p:TargetFrameworks=${tfm}
      .dotnet/${arch}-${version}-sdk/dotnet build csharp.test -p:TargetFrameworks=${tfm}
    "

    for config in ".dotnet/${arch}-${version}-sdk"*; do
      with_task --continue_when_failed "Run program with $(basename "${config}")" ${config}/dotnet run --project csharp --no-build -p:TargetFrameworks=${tfm} --framework ${tfm}
      with_task --continue_when_failed "Run tests with $(basename "${config}")" ${config}/dotnet test csharp.test --no-build -p:TargetFrameworks=${tfm} --framework ${tfm}
    done
  done
done

tasks_summary_and_exit
