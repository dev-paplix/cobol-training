# Lesson 3: Configuring the NetCOBOL Project Manager and Compiler Options
# Lesson 3: Mastering the GnuCOBOL Compiler (`cobc`) — Flags, Dialects, and Directives

## 1. Tooling Overview: Standalone Project Manager vs. Visual Studio
## 1. Overview of `cobc`

In the Fujitsu NetCOBOL ecosystem, you will encounter two primary ways to manage and compile projects:
The primary tool in the GnuCOBOL toolchain is the **`cobc`** compiler command.

1. **Visual Studio Project System (`.cobproj`)**:
   - The modern, integrated approach.
   - Uses MSBuild under the hood to invoke the NetCOBOL compiler (`cobol.exe`).
   - Seamlessly integrates with source control (Git), multi-language solutions, CI/CD pipelines (Azure DevOps, GitHub Actions), and the VS IDE.
2. **NetCOBOL Project Manager (`cobpm.exe`)**:
   - A standalone build utility provided with Fujitsu NetCOBOL.
   - Maintains `.prj` or `.cobpm` files.
   - Often used in legacy systems, automated batch build scripts, command-line build servers without full Visual Studio IDE installations, or when maintaining pure native Win32/x64 COBOL systems.
```bash
cobc [options] source-files...
```

> [!NOTE]
> For modern .NET development, you will primarily use **Visual Studio Project Properties**. However, understanding compiler directives (`@OPTIONS`) is universal and applies across both tools.
By default, `cobc` takes COBOL source code, expands copybooks, checks syntax and semantics, generates intermediate C code, and calls the host C compiler to produce an executable or dynamically loadable module.

---

## 2. The `@OPTIONS` Directive
## 2. Essential Compiler Flags Reference

The `@OPTIONS` statement is a special compiler directive that allows you to specify compiler settings directly inside the COBOL source file, overriding or augmenting project-level defaults.
| Option | Long Form | Purpose & Description |
| :--- | :--- | :--- |
| **`-x`** | `--executable` | Build an **executable** program (main entry point). Without `-x`, `cobc` produces a module or object file. |
| **`-m`** | `--module` | Build a **dynamically loadable module** (shared object `.so` or `.dll`) that can be loaded dynamically at runtime via `CALL "subprogram"`. |
| **`-free`** | `--free` | Treat source code as **Free Format** (lines up to 255 chars, no margin restrictions, comments with `*>`). |
| **`-fixed`** | `--fixed` | Enforce traditional **Fixed Format** (columns 1-6 sequence, 7 indicator, 8-72 code). *(Default if unspecified)* |
| **`-I <dir>`** | `--include-dir` | Add a directory to the copybook search path for `COPY` statements. |
| **`-Wall`** | `--all-warnings` | Enable all recommended compiler warnings (unreferenced variables, dialect violations, potential logic traps). |
| **`-Werror`** | `--error-warnings` | Treat all warnings as fatal errors. |
| **`-g`** | `--debug` | Generate debugging symbols in the output binary for source-level debugging with **GDB**. |
| **`-O` / `-O2`** | `--optimize` | Enable GCC optimization passes for maximum execution speed. |
| **`-C`** | `--translation-only`| Stop after generating intermediate C source code. Leaves `.c` and `.h` files for inspection. |
| **`-c`** | `--compile-only` | Compile to a native object file (`.o`), skipping the final link step. |
| **`-std=<dialect>`**| `--standard` | Enforce a specific COBOL dialect standard (see Dialects below). |

### Syntax Rules:
- Must be placed before the `IDENTIFICATION DIVISION` (typically on line 1 or 2).
- Preceded by the `@` symbol in the indicator area (or column 1 in free format).
- Multiple options can be separated by spaces or commas.
---

```cobol
      * Example of @OPTIONS directive in Fixed Format
000100 @OPTIONS ARITH(EXTEND), ALPHAL(WORD), CHECK(INDEX)
000200 IDENTIFICATION DIVISION.
000300 PROGRAM-ID. COMPILER-DEMO.
```
## 3. Dialect Support (`-std=`)

In modern **Free Format**:
```cobol
@OPTIONS SOURCE(FREE), ARITH(EXTEND), CHECK(ALL)
IDENTIFICATION DIVISION.
PROGRAM-ID. CompilerDemo.
One of GnuCOBOL's most powerful capabilities is its ability to emulate different historical and vendor-specific COBOL dialects:

```bash
cobc -std=ibm -x myprogram.cob
```

---
Common dialect options:
- **`-std=default`**: Standard GnuCOBOL (blends COBOL 85, 2002, 2014, and practical extensions).
- **`-std=ibm`**: IBM Mainframe z/OS Enterprise COBOL compatibility mode.
- **`-std=mf`**: Micro Focus COBOL dialect compatibility mode.
- **`-std=cobol85`**: Strict ANSI/ISO COBOL 85 standard.
- **`-std=cobol2002`**: ISO COBOL 2002 standard.
- **`-std=cobol2014`**: ISO COBOL 2014 standard.

## 3. Comprehensive Compiler Options Reference

Here are the most critical compiler options used in NetCOBOL for .NET:

| Option Keyword | Values / Syntax | Purpose & Description |
| :--- | :--- | :--- |
| **`SOURCE`** | `SOURCE(FIXED)`<br>`SOURCE(FREE)` | Controls source code formatting. `FIXED` enforces 80-column punch-card layout (columns 1-6 sequence, 7 indicator, 8-72 code). `FREE` allows unconstrained line lengths up to 255 characters without column restrictions. |
| **`ARITH`** | `ARITH(COMPAT)`<br>`ARITH(EXTEND)` | Governs arithmetic precision for decimal operations. `COMPAT` limits maximum precision to 18 digits (COBOL 85 standard). `EXTEND` expands precision up to 31 decimal digits, preventing overflow in large monetary calculations. |
| **`CHECK`** | `CHECK(INDEX)`<br>`CHECK(ALL)`<br>`NOCHECK` | Enables runtime validation checks. `CHECK(INDEX)` validates table/array subscript bounds. `CHECK(ALL)` enables subscript, reference modification, and overflow checking. *Recommended for Debug; disable in Release for maximum performance.* |
| **`ALPHAL`** | `ALPHAL(WORD)`<br>`ALPHAL(LOWER)` | Controls alphanumeric literal case sensitivity. `WORD` converts unquoted identifiers to uppercase while preserving string literal case. |
| **`QUOTE` / `APOST`** | `QUOTE`<br>`APOST` | Determines the delimiter for literal strings. `QUOTE` configures double quotes (`"HELLO"`). `APOST` configures single quotes (`'HELLO'`). |
| **`BINARY`** | `BINARY(NATIVE)`<br>`BINARY(BIG-ENDIAN)` | Determines byte ordering for binary data (`COMP-4`, `COMP-5`, `BINARY`). `NATIVE` uses Intel little-endian; `BIG-ENDIAN` emulates IBM mainframe byte order (essential when reading EBCDIC/mainframe sequential binary files). |
| **`RCS`** | `RCS(UNICODE)`<br>`RCS(ASCII)` | Configures national character representation (`PIC N`). `UNICODE` stores characters as UTF-16, matching .NET `System.String` internally. |
| **`MAIN`** | `MAIN(YES)`<br>`MAIN(NO)` | Declares that the compilation unit contains the entry point (`static void Main`) for an executable assembly. |
| **`LIST` / `NOLIST`**| `LIST`<br>`NOLIST` | Generates a formatted compiler listing file (`.LST`) containing line numbers, expanded copybooks, and compiler messages. |
| **`XREF`** | `XREF`<br>`NOXREF` | Emits a cross-reference table in the listing file showing where every variable and paragraph is declared and referenced. |

---

## 4. Configuring Copybook Search Paths (`LIB`)
## 4. Standard Preprocessor Directives

In enterprise COBOL, shared data structures and record layouts are stored in **Copybooks** and imported using the `COPY` statement:
Modern COBOL (and GnuCOBOL) provides standard preprocessor directives that start with **`>>`**:

### A. Source Format Directive
Instead of passing `-free` on the command line, you can place the standard directive on line 1 of your source file:
```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "CUSTOMER-RECORD.CPY".
>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. MyProg.
```
To return to fixed format:
```cobol
>>SOURCE FORMAT FIXED
```

When the compiler encounters `COPY "CUSTOMER-RECORD.CPY"`, it searches directories in the following order:
1. The directory containing the current source file.
2. Directories specified in the **Include Paths (`LIB`)** project setting.
3. The directory defined by the `COBCPY` environment variable.
### B. Conditional Compilation
You can compile code conditionally based on environment flags:
```cobol
>>DEFINE DEBUG-MODE AS 1

### Setting Include Paths in Visual Studio:
1. Right-click your `.cobproj` project -> **Properties**.
2. Navigate to **COBOL Compiler Options** (or **Build**).
3. Locate **Include Paths (`LIB`)**.
4. Add relative or absolute paths separated by semicolons:
   ```text
   .\Copybooks;..\SharedCopybooks;C:\EnterpriseData\Schema
   ```
>>IF DEBUG-MODE DEFINED
    DISPLAY "DEBUG: Reached checkpoint alpha."
>>END-IF
```

> [!TIP]
> Always use **relative paths** (e.g., `.\Copybooks`) in project properties so that your solution builds cleanly on any developer's machine or automated CI/CD build agent without hardcoded drive letters.

---

## 5. Compiler Listings and Diagnostic Levels
## 5. Copybook Resolution Hierarchy

When compilation fails or produces unexpected warnings, the **Compiler Listing (`.LST`)** and the **Visual Studio Error List** provide diagnostic feedback.

### Diagnostic Message Codes:
NetCOBOL error messages follow a standard format:
```text
JMNnnnnI-s "Message text" (Line: nn, Column: nn)
When GnuCOBOL encounters a statement like:
```cobol
       COPY "EMPLOYEE.CPY".
```
Where `s` represents the severity level:
- **`I` (Information)**: Informational message (e.g., option overrides).
- **`W` (Warning)**: Syntax irregularity or potential runtime issue; compilation succeeds.
- **`E` (Error)**: Syntax error; the compiler continues parsing, but code generation is suppressed.
- **`S` (Severe)**: Unrecoverable error; compilation is immediately terminated.
It searches for the file in the following order:
1. The **current working directory** where `cobc` was invoked.
2. The directory containing the current source file being compiled.
3. Any directories specified via the **`-I <dir>`** command-line flag.
4. Any directories specified in the **`COB_COPY_DIR`** environment variable.

### Example Compiler Listing (`Program1.lst`):
```text
Fujitsu NetCOBOL for .NET Version 11.0.0
Source File: Program1.cob
Options: SOURCE(FREE), ARITH(EXTEND), CHECK(INDEX)

Line  Col  Source Statement
   1       IDENTIFICATION DIVISION.
   2       PROGRAM-ID. Program1.
   3       DATA DIVISION.
   4       WORKING-STORAGE SECTION.
   5       01 WS-COUNT PIC 9(4).
   6       PROCEDURE DIVISION.
   7           MOVE "ABC" TO WS-COUNT.
*** JMN2114I-E Alphanumeric literal cannot be moved to numeric data item 'WS-COUNT'. (Line 7)
   8           GOBACK.

Statistics: 0 Severe, 1 Error, 0 Warnings, 1 Info.
Compilation Failed.
### Example: Setting environment variable in your shell
```bash
export COB_COPY_DIR="/opt/enterprise/copybooks:../copybooks"
cobc -x -free main.cob
```

In Visual Studio, these errors populate directly into the **Error List Window** (`Ctrl + \ , E`), allowing you to double-click an error to jump straight to the offending line in your source editor.

