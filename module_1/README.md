# Module 1: The NetCOBOL Ecosystem and Visual Studio Integration
# Module 1: The GnuCOBOL Ecosystem and Development Toolchain

Welcome to **Module 1** of the NetCOBOL Training Series. This module establishes foundational knowledge for working with Fujitsu NetCOBOL for .NET within the modern Microsoft Visual Studio integrated development environment (IDE).
Welcome to **Module 1** of the GnuCOBOL Training Series. This module establishes the foundational knowledge for compiling, executing, and debugging COBOL applications using **GnuCOBOL (`cobc`)** on modern operating systems (Linux, macOS, and Windows with WSL/MinGW).

---

## 🎯 Module Objectives

By the end of this module, you will be able to:
1. **Analyze the architectural transition** from traditional Native COBOL to Managed .NET COBOL (MSIL, CLR execution, Garbage Collection, and CTS data typing).
2. **Navigate and configure Visual Studio** for COBOL development, including Solution Explorer, NetCOBOL project templates, and project configuration properties.
3. **Control compilation behavior** using the NetCOBOL Project Manager, compiler directives (`@OPTIONS`), build settings, and copybook resolution paths.
4. **Develop, compile, execute, and debug** your first "Modern COBOL" application consuming .NET Base Class Libraries (BCL).
1. **Understand the GnuCOBOL Architecture**: Master the two-stage compilation pipeline where `cobc` translates COBOL into intermediate C and compiles it to native machine code via GCC/Clang linked with `libcob`.
2. **Set Up a Modern Development Environment**: Configure code editors (such as VS Code), directory layouts, build tasks, and environment variables (`COB_COPY_DIR`, `COB_LIBRARY_PATH`).
3. **Master `cobc` Compiler Options**: Effectively use compiler flags (`-x`, `-free`, `-m`, `-Wall`, `-std=`, `-I`, `-g`, `-O2`) and preprocessor directives (`>>SOURCE FORMAT FREE`).
4. **Develop, Compile, and Debug**: Write your first modern GnuCOBOL application, build it with `cobc`, execute the native binary, and debug logic issues.

---

## 📚 Module Curriculum Structure

This module is organized into structured lessons and hands-on laboratory exercises:

| Lesson / Document | Description | Key Focus Topics |
| :--- | :--- | :--- |
| **[01. Architecture: Native to Managed](file:///e:/training/cobol-training/module_1/01_architecture_native_to_managed.md)** | Conceptual & architectural deep dive | Native vs. Managed runtime, MSIL/CIL, CLR, GC, CTS Type Mapping |
| **[02. Visual Studio IDE Setup](file:///e:/training/cobol-training/module_1/02_visual_studio_setup_and_properties.md)** | IDE workflow and configuration | Templates, `.cobproj` structure, Assembly references, Solution Explorer |
| **[03. Compiler Options & Project Manager](file:///e:/training/cobol-training/module_1/03_project_manager_and_compiler_options.md)** | Build control and directives | `@OPTIONS`, Project Manager, `ALPHAL`, `ARITH`, `CHECK`, Copybook `LIB` paths |
| **[04. Hands-on: First Modern COBOL Project](file:///e:/training/cobol-training/module_1/04_hands_on_first_modern_cobol_project.md)** | Step-by-step interactive lab | Creating solution, invoking .NET Framework APIs, building, debugging |
| **[05. Exercises and Solutions](file:///e:/training/cobol-training/module_1/05_exercises_and_solutions.md)** | Practical challenges & assessments | Architectural analysis, compiler diagnostics, Employee Onboarding project |
| **[01. Architecture: The GnuCOBOL Engine](file:///e:/training/cobol-training/module_1/01_architecture_native_to_managed.md)** | Technical deep dive into GnuCOBOL | Translation pipeline (COBOL $\rightarrow$ C $\rightarrow$ Native Binary), `libcob` runtime, memory model |
| **[02. Development Environment Setup](file:///e:/training/cobol-training/module_1/02_visual_studio_setup_and_properties.md)** | Toolchain & IDE integration | VS Code, GnuCOBOL extensions, Terminal, Directory structure, `Makefile` automation |
| **[03. Compiler Options & Preprocessor Directives](file:///e:/training/cobol-training/module_1/03_project_manager_and_compiler_options.md)** | Build control and `cobc` flags | `-x`, `-free`, `-std=`, `-I`, Copybook paths, `>>SOURCE FORMAT FREE`, compiler diagnostics |
| **[04. Hands-on: First GnuCOBOL Project](file:///e:/training/cobol-training/module_1/04_hands_on_first_modern_cobol_project.md)** | Step-by-step interactive lab | Writing free-format code, intrinsic functions, compiling with `cobc`, running and inspecting binaries |
| **[05. Exercises and Solutions](file:///e:/training/cobol-training/module_1/05_exercises_and_solutions.md)** | Practical challenges & assessments | Diagnostic troubleshooting, intermediate C inspection (`-C`), Employee Onboarding project |

---

## 📂 Directory Layout

```text
module_1/
├── README.md                                    # This overview document
├── 01_architecture_native_to_managed.md         # Lesson 1: Architectural Foundation
├── 02_visual_studio_setup_and_properties.md     # Lesson 2: VS Integration & Project Setup
├── 03_project_manager_and_compiler_options.md   # Lesson 3: Compiler Directives & Options
├── 01_architecture_native_to_managed.md         # Lesson 1: GnuCOBOL Translation Pipeline & libcob
├── 02_visual_studio_setup_and_properties.md     # Lesson 2: Dev Environment, Editor & Makefiles
├── 03_project_manager_and_compiler_options.md   # Lesson 3: cobc Compiler Flags & Directives
├── 04_hands_on_first_modern_cobol_project.md    # Lesson 4: Step-by-Step Hands-on Tutorial
├── 05_exercises_and_solutions.md                # Lesson 5: Exercises, Quizzes & Solutions
├── 05_exercises_and_solutions.md                # Lesson 5: Exercises, Quizzes & Reference Solutions
└── samples/                                     # Sample source code and copybooks
    ├── copybooks/
    │   └── EMPLOYEE.CPY                         # Standard copybook for exercises
    ├── HelloModernCobol/
    │   └── Program1.cob                         # Complete code from Hands-on Lab
    └── EmployeeOnboarding/
        └── EmployeeSystem.cob                   # Exercise 3 reference implementation
        └── EmployeeSystem.cob                   # GnuCOBOL reference implementation
```

---

## 🛠️ Prerequisites & System Requirements
## 🛠️ Prerequisites & Verification

Before starting this module, ensure your environment meets the following specifications:
- **Operating System**: Windows 10 / Windows 11 / Windows Server 2016+ (64-bit).
- **IDE**: Microsoft Visual Studio (Community, Professional, or Enterprise) 2019 or 2022 with *.NET Desktop Development* workload installed.
- **COBOL Compiler**: Fujitsu NetCOBOL for .NET (v11 or higher) installed with Visual Studio Integration enabled.
- **Runtime**: Microsoft .NET Framework 4.8 or .NET Core/.NET 6+ (depending on your NetCOBOL distribution release).
Ensure you have GnuCOBOL installed on your machine. In your terminal, run:

---
```bash
cobc --version
```
Expected output:
```text
cobc (GnuCOBOL) 3.1.2 (or higher)
Copyright (C) 2020 Free Software Foundation, Inc.
Built with: gcc ...
C-compiler: gcc ...
```

## 🚀 Recommended Learning Path

1. **Read Lesson 1**: Understand how COBOL runs under the Common Language Runtime (CLR) and how data structures map to .NET objects.
2. **Study Lesson 2**: Familiarize yourself with Visual Studio project templates and project properties.
3. **Review Lesson 3**: Learn the critical compiler flags (`@OPTIONS`) that govern source format, decimal arithmetic, and copybook resolution.
4. **Complete Lesson 4**: Follow the hands-on guide to create, build, and step through `HelloModernCobol`.
5. **Tackle Lesson 5**: Complete the 3 exercises to validate your mastery of the NetCOBOL ecosystem.

If `cobc` is not installed:
* **Ubuntu/Debian**: `sudo apt update && sudo apt install gnucobol`
* **Fedora/RHEL**: `sudo dnf install gnucobol`
* **macOS**: `brew install gnu-cobol`
* **Windows**: Install via WSL (`wsl --install`) or MSYS2 / MinGW.
