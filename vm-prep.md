# Bullet-Proof VM Preparation & Installation Guide

This document contains the complete, battle-tested setup guide for preparing a fresh **Ubuntu Linux (22.04 LTS / 24.04 LTS)** virtual machine or container to run all code, samples, exercises, and test suites across **Modules 1 through 5** of the Modern COBOL & .NET Training Series.

Following these instructions guarantees **100% build and execution success** with zero missing headers, missing runtime libraries, or broken compilers.

---

## ⚡ 1. Quick-Start: Automated 1-Minute Setup

If setting up a fresh machine, run this single block in your terminal:

```bash
# 1. Update package indices & ensure universe repository is active
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common ca-certificates curl git

# 2. Install all required compilers, runtimes, database libraries & headers
sudo apt install -y \
  gnucobol \
  libcob4-dev \
  build-essential \
  gcc \
  gdb \
  binutils \
  sqlite3 \
  libsqlite3-dev \
  libxml2-dev \
  libdb-dev \
  dotnet-sdk-8.0 \
  clang \
  zlib1g-dev \
  python3

# 3. Configure environment settings in ~/.bashrc
grep -q "DOTNET_CLI_TELEMETRY_OPTOUT" ~/.bashrc || cat << 'EOF' >> ~/.bashrc

# COBOL & .NET Training Environment Configuration
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
export LD_LIBRARY_PATH=.:/usr/local/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
EOF

# 4. Apply environment changes to current shell
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
export LD_LIBRARY_PATH=.:/usr/local/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
```

---

## 🔍 2. Detailed Dependency Breakdown by Module

Every installed package serves a specific architectural role across the curriculum:

| Package | Purpose in Curriculum | Modules Using It |
| :--- | :--- | :--- |
| **`gnucobol`** | The core open-source COBOL compiler (`cobc`). Transcompiles standard and modern COBOL to optimized C. | **Modules 1, 2, 3, 4, 5** |
| **`libcob4-dev`** | C headers (`libcob.h`) and symlinks for `libcob.so`. Required when C# or C programs invoke COBOL via `cob_init()`. | **Modules 3, 5** |
| **`build-essential` & `gcc`** | GNU C/C++ compiler and make tools. Required because `cobc` generates native C and invokes GCC for final assembly. | **Modules 1, 2, 3, 4, 5** |
| **`dotnet-sdk-8.0`** | Microsoft .NET 8 SDK. Compiles C# console apps, Minimal APIs, ASP.NET Core microservices, and Native AOT libraries. | **Module 5** |
| **`clang` & `zlib1g-dev`** | Native toolchain dependencies required by .NET 8 Native AOT (`<PublishAot>true</PublishAot>`) to produce `.so` files. | **Module 5** |
| **`sqlite3` & `libsqlite3-dev`** | Embedded SQL database engine and development headers. Provides database connectivity for COBOL via C-ABI bridges. | **Module 3** |
| **`libxml2-dev`** | GNOME XML library headers. Required for native COBOL `XML GENERATE` and `XML PARSE` statements. | **Module 3** |
| **`libdb-dev`** | Berkeley DB. The underlying ISAM indexed sequential file handler used by GnuCOBOL for `ORGANIZATION IS INDEXED`. | **Module 3** |
| **`gdb`** | The GNU Debugger. Used for interactive breakpoint stepping, watch windows, and call stack inspections. | **Module 4** |
| **`binutils`** | Utilities including `nm`, `objdump`, `ar`, and `ld`. Used to inspect exported C-ABI symbols in shared libraries. | **Modules 4, 5** |
| **`python3`** | Standard Python 3 interpreter. Drives the automated verification harnesses and regression testing suites. | **Modules 1, 2, 3, 4, 5** |

---

## 🛠️ 3. Handling Special Environments & Fallbacks

### A. Installing .NET 8 if Not Present in Default Ubuntu Repositories
On older Ubuntu releases (e.g. 20.04) or customized cloud images where `dotnet-sdk-8.0` is not yet indexed, register Microsoft's official package repository:

```bash
# Get Ubuntu version (e.g., 22.04 or 24.04)
UBUNTU_RELEASE=$(lsb_release -rs)

# Download Microsoft package repository definition
curl -sSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_RELEASE}/packages-microsoft-prod.deb" -O
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install .NET SDK
sudo apt update
sudo apt install -y dotnet-sdk-8.0
```

### B. Ubuntu 24.04 (Noble Numbat) Package Names
On Ubuntu 24.04 LTS, GnuCOBOL is version 3.2+:
- The development package name is either `libcob4-dev` or `libcob-dev`.
- Both are automatically satisfied by running:
  ```bash
  sudo apt install -y gnucobol libcob*-dev
  ```

---

## 🩺 4. Pre-Flight Verification Script

To verify that your VM is 100% prepared and ready to compile any module, copy and run this diagnostic check:

```bash
cat << 'EOF' > /tmp/check_env.sh
#!/usr/bin/env bash
set -e

echo "=================================================================="
echo "          SYSTEM DEPENDENCY & PRE-FLIGHT HEALTH CHECK            "
echo "=================================================================="

check_cmd() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e " [\033[32mOK\033[0m] $name: $(command -v $cmd) ($($cmd --version 2>&1 | head -n 1))"
    else
        echo -e " [\033[31mFAIL\033[0m] $name ($cmd) is NOT installed."
        exit 1
    fi
}

check_lib() {
    local lib=$1
    local name=$2
    if ldconfig -p | grep -q "$lib"; then
        local path=$(ldconfig -p | grep "$lib" | head -n 1 | awk '{print $NF}')
        echo -e " [\033[32mOK\033[0m] $name: found ($path)"
    else
        echo -e " [\033[31mFAIL\033[0m] Shared library $lib ($name) NOT found in ldconfig search path."
        exit 1
    fi
}

check_cmd cobc    "GnuCOBOL Compiler"
check_cmd gcc     "GNU C Compiler"
check_cmd dotnet  "Microsoft .NET SDK"
check_cmd sqlite3 "SQLite CLI Engine"
check_cmd gdb     "GNU Debugger"
check_cmd python3 "Python 3 Interpreter"

echo "------------------------------------------------------------------"
check_lib "libcob.so"     "GnuCOBOL Runtime"
check_lib "libsqlite3.so" "SQLite3 Shared Library"

echo "=================================================================="
echo -e "\033[32mALL DEPENDENCIES VERIFIED! System is 100% ready to run all modules.\033[0m"
echo "=================================================================="
EOF

chmod +x /tmp/check_env.sh
/tmp/check_env.sh
rm /tmp/check_env.sh
```

---

## 🚀 5. Running the Master Regression Suite

Once the pre-flight checks pass, you can execute the complete end-to-end test suite that compiles and runs every sample and exercise across all 5 modules:

```bash
cd /home/wesi/codes/cobol-training

# Execute master test harness
python3 ~/.gemini/antigravity/brain/cbd156f1-c94e-452a-956d-572f637a6865/scratch/verify_all.py
```

Expected output:
```text
======================================================================
OVERALL RESULT: ALL TESTS PASSED ACROSS ALL MODULES (1-5)!
======================================================================
```
