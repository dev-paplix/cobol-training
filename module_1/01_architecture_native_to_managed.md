# Lesson 1: Architecture of NetCOBOL for .NET — From Native to Managed Code
# Lesson 1: Architecture of GnuCOBOL — The C Translation Pipeline & Runtime

## 1. Executive Summary & Paradigm Shift
## 1. Executive Summary: What is GnuCOBOL?

For decades, traditional COBOL systems operated exclusively as **native code**. Whether running on IBM z/OS mainframes, Unix/Linux environments, or Windows with Win32/x64 compilers, COBOL programs compiled directly into platform-specific machine code (or native object decks) bound to static memory addresses and operating-system-specific C/runtime libraries.
**GnuCOBOL** (formerly *OpenCOBOL*) is a modern, free, and open-source COBOL compiler. Unlike legacy proprietary compilers that compile directly to proprietary assembly formats or virtual machine bytecodes, GnuCOBOL employs a highly portable, two-stage native compilation pipeline:

With the release of **Fujitsu NetCOBOL for .NET**, the paradigm shifted dramatically:
- Instead of compiling down to native machine instructions (`x86`/`x64`), NetCOBOL compiles directly to **Microsoft Intermediate Language (MSIL)**, also called **Common Intermediate Language (CIL)**.
- Instead of relying on a proprietary OS loader and static memory model, NetCOBOL applications execute inside the **Common Language Runtime (CLR)**.
- Instead of isolated COBOL data structures, NetCOBOL bridges traditional `PICTURE` clauses with the **Common Type System (CTS)**, enabling seamless, bi-directional interoperability with modern .NET languages such as C#, VB.NET, and F#.
1. It translates COBOL source code into **portable C code**.
2. It compiles the generated C code into **native machine binary** (`ELF`, `Mach-O`, or `PE`) using your system's C compiler (such as `gcc`, `clang`, or `clang-cl`).
3. It links the binary against **`libcob`**, the GnuCOBOL runtime support library.

```
+-------------------------------------------------------------------------------+
|                       NATIVE COBOL EXECUTION MODEL                            |
|                       GNUCOBOL COMPILATION PIPELINE                           |
|                                                                               |
|   COBOL Source (.cob)  --->  Native Compiler  --->  Object Code / Native DLL  |
|                                                            |                  |
|                                                            v                  |
|                                                    Operating System (Win32)   |
|                                                    Direct Native Execution    |
|   COBOL Source (.cob)                                                         |
|           |                                                                   |
|           v                                                                   |
|      [ cobc -S ]  (Lexical parsing, semantic checks, preprocessor expansion) |
|           |                                                                   |
|           v                                                                   |
|   Intermediate C Source (.c) & Headers (.h)                                  |
|           |                                                                   |
|           v                                                                   |
|      [ System C Compiler: gcc / clang ]                                      |
|           |                                                                   |
|           v                                                                   |
|   Object File (.o)  +  GnuCOBOL Runtime Library (libcob.so / .dll / .dylib)   |
|           |                                                                   |
|           v                                                                   |
|   Native Executable Binary (or Shared Module .so / .dll)                      |
+-------------------------------------------------------------------------------+

+-------------------------------------------------------------------------------+
|                    NETCOBOL FOR .NET MANAGED MODEL                            |
|                                                                               |
|   COBOL Source (.cob)  ---> NetCOBOL Compiler ---> .NET Assembly (MSIL + Meta)|
|                                                            |                  |
|                                                            v                  |
|                                                    CLR Execution Engine       |
|                                                    (JIT Compiler & GC)        |
|                                                            |                  |
|                                                            v                  |
|                                                    Underlying Hardware / OS   |
+-------------------------------------------------------------------------------+
```

---

## 2. The NetCOBOL for .NET Compilation Pipeline
## 2. Why the C Translation Model Matters

When you build a NetCOBOL project in Visual Studio, the build system (`MSBuild`) invokes the NetCOBOL compiler driver. The compilation stages are:
This translation pipeline gives GnuCOBOL distinct superpowers:
1. **Unrivaled Portability**: GnuCOBOL runs anywhere GCC or Clang runs—x86_64, ARM64 (Apple Silicon, Raspberry Pi), POWER, IBM s390x, RISC-V, and Windows.
2. **Aggressive Optimization**: GnuCOBOL benefits directly from GCC's industry-leading optimization flags (`-O2`, `-O3`, `-march=native`, vectorization, and LTO).
3. **Frictionless C Interoperability**: Because the intermediate representation is standard ANSI C, COBOL programs can effortlessly call C functions (such as POSIX sockets, OpenSSL, or SQLite) and C programs can call COBOL modules directly.

1. **Lexical Analysis and Macro Expansion**:
   - The compiler scans the source code, processing compiler directives (such as `@OPTIONS`), replacing text via `COPY` statements and `REPLACE` directives.
2. **Syntax and Semantic Parsing**:
   - Validates ANSI/ISO COBOL 85 and 2002 standards, checking statements against standard COBOL grammar and object-oriented extensions.
3. **Symbol Table & CTS Type Resolution**:
   - Resolves external references declared in the `REPOSITORY` paragraph.
   - Inspects referenced .NET assemblies (e.g., `mscorlib.dll`, `System.dll`, or custom C# assemblies) to resolve classes, interfaces, value types, and method signatures.
4. **Intermediate Language & Metadata Generation**:
   - Produces standard .NET **MSIL instructions** (e.g., `ldstr`, `callvirt`, `stloc`, `add`).
   - Generates the **CLI Metadata Table**, describing all classes, fields, properties, methods, and parameters exposed by the COBOL program.
5. **Assembly Packaging**:
   - Emits a Portable Executable (PE) file (`.exe` or `.dll`) containing the MSIL payload and CLI manifest.

At runtime, the Windows loader hands execution to the CLR. The **Just-In-Time (JIT) Compiler** translates the MSIL instructions into native host processor instructions on demand.

---

## 3. Native NetCOBOL vs. NetCOBOL for .NET
## 3. The Anatomy of `libcob` (The Runtime Engine)

Understanding the boundary between Native NetCOBOL (Win32/x64) and NetCOBOL for .NET is essential when modernizing legacy applications:
When your compiled GnuCOBOL executable runs, it relies on **`libcob`** (the runtime library). `libcob` provides:
- **COBOL Decimal Arithmetic Engine**: Emulates standard COBOL decimal math (`COMP-3`, `PACKED-DECIMAL`) and handles `ROUNDED` and `ON SIZE ERROR` conditions.
- **Screen I/O & Terminal Emulation**: Powers formatted `DISPLAY ... AT LINE ... COL` and `ACCEPT` via `ncurses` or `curses`.
- **Indexed & Sequential File I/O**: Implements COBOL file operations (`READ`, `WRITE`, `START`, `DELETE`) backed by engines such as **BDB (Berkeley DB)**, **VBISAM**, or **NODB**.
- **Dynamic Program Loader**: Manages dynamic module loading when executing `CALL "subprogram"` statements at runtime.
- **Intrinsic Functions Engine**: Provides mathematical, string, and date calculations (`FUNCTION CURRENT-DATE`, `FUNCTION TRIM`, etc.).

| Feature / Dimension | Native NetCOBOL (Win32/x64) | NetCOBOL for .NET (Managed) |
| :--- | :--- | :--- |
| **Output Target** | Native Machine Code (x86/x64 PE) | MSIL (CIL) + CLI Metadata |
| **Execution Environment** | Direct Windows OS execution | Common Language Runtime (CLR) |
| **Runtime Dependencies** | Fujitsu Native Runtime (`F3BICM64.DLL`, etc.) | CLR + Fujitsu Managed Runtime (`Fujitsu.COBOL.dll`) |
| **Memory Management** | Static Working-Storage; explicit pointer allocation (`SET ADDRESS OF`) | CLR Managed Heap with automatic Garbage Collection (GC) |
| **Object Orientation** | Procedural; optional ANSI 2002 OO | Full .NET Object Model: classes, interfaces, events, generics |
| **Data Types** | Traditional COBOL `PIC` representations | Standard `PIC` mapped to .NET Common Type System (CTS) |
| **Interoperability** | Standard C calling conventions (`stdcall`/`cdecl`), Win32 DLL exports | Seamless assembly references: call C# classes directly, or expose COBOL classes to C# |
| **Multithreading** | OS Threads via Win32 API calls | Full integration with `System.Threading` and Tasks (`async`/`await`) |
| **Exception Handling** | Declaratives (`USE AFTER ERROR PROCEDURE`), status codes | Structured Exception Handling: `TRY ... CATCH ... FINALLY` |

---

## 4. Managed Memory Model and Garbage Collection
## 4. Memory Architecture in GnuCOBOL

In traditional COBOL:
- The `WORKING-STORAGE SECTION` allocates a contiguous, fixed block of memory when the program is loaded.
- Memory remains resident throughout the program run-unit life cycle.
- Dynamic memory required complex API calls or pointer arithmetic (`USAGE POINTER`).
In GnuCOBOL, memory layout depends on how variables are declared:

In NetCOBOL for .NET:
1. **Procedural Programs**:
   - A traditional procedural program (`PROGRAM-ID`) compiled under NetCOBOL is internally packaged into a managed class with static fields representing the `WORKING-STORAGE` items.
   - The CLR initializes these static fields when the class is first loaded.
2. **Object-Oriented Classes (`CLASS-ID`)**:
   - Variables declared in `WORKING-STORAGE` within a `FACTORY` (class level) become static members.
   - Variables declared in `OBJECT` sections become instance fields allocated on the **CLR Managed Heap**.
   - When an instance is no longer referenced, the **CLR Garbage Collector (GC)** automatically claims the memory, preventing memory leaks and dangling pointer bugs.
### A. `WORKING-STORAGE SECTION` (Static Allocation)
- Allocated statically in the process data segment when the program or module is first loaded.
- State is preserved across multiple `CALL` executions unless the program has the `IS INITIAL` attribute.
- Accessible globally within that program unit.

> [!NOTE]
> NetCOBOL handles the cleanup of managed objects automatically. However, when working with unmanaged resources (e.g., native file handles or database connections), you must ensure deterministic cleanup using .NET's `IDisposable` pattern.
### B. `LOCAL-STORAGE SECTION` (Stack Allocation)
- Introduced in modern COBOL standards (COBOL 2002) and fully supported in GnuCOBOL.
- Each time the program is called, variables in `LOCAL-STORAGE` are allocated fresh on the call stack.
- Essential for writing **recursive subprograms** (`PROGRAM-ID. RecurProg RECURSIVE`) and thread-safe routines.

### C. `LINKAGE SECTION` (Pointer Mapping)
- Does not allocate storage.
- Maps addresses passed by calling programs (`CALL ... USING BY REFERENCE / BY CONTENT / BY VALUE`) onto COBOL record definitions.

---

## 5. Mapping COBOL Data Types to the .NET Common Type System (CTS)
## 5. Data Representation in GnuCOBOL

Because NetCOBOL generates standard .NET assemblies, data types must harmonize with .NET CTS types. The following table provides the canonical mapping:
| COBOL Usage Clause | Internal C Representation | Description |
| :--- | :--- | :--- |
| `DISPLAY` (`PIC X(n)`, `PIC 9(n)`) | `char[]` / ASCII string | Standard human-readable characters |
| `USAGE BINARY` / `COMP-4` / `COMP-5` | `int16_t`, `int32_t`, `int64_t` | Native CPU machine binary integers (Little-endian on x86/ARM) |
| `USAGE COMP-3` / `PACKED-DECIMAL` | `unsigned char[]` (BCD) | 2 digits per byte + half-byte sign nibble (`C`/`D`/`F`) |
| `USAGE COMP-1` | `float` (32-bit) | IEEE single-precision floating point |
| `USAGE COMP-2` | `double` (64-bit) | IEEE double-precision floating point |
| `USAGE POINTER` | `void*` | Raw memory address pointer for C interop |

| COBOL Data Definition | Storage Representation | Equivalent .NET CTS Type | C# Equivalent |
| :--- | :--- | :--- | :--- |
| `PIC X(n)` | Fixed-length alphanumeric character string | `System.String` or fixed-length byte buffer | `string` / `byte[]` |
| `PIC N(n) USAGE NATIONAL` | UTF-16 Unicode character string | `System.String` | `string` |
| `PIC S9(4) USAGE COMP-5 / BINARY` | 16-bit signed binary integer | `System.Int16` | `short` |
| `PIC 9(4) USAGE COMP-5 / BINARY` | 16-bit unsigned binary integer | `System.UInt16` | `ushort` |
| `PIC S9(9) USAGE COMP-5 / BINARY` | 32-bit signed binary integer | `System.Int32` | `int` |
| `PIC 9(9) USAGE COMP-5 / BINARY` | 32-bit unsigned binary integer | `System.UInt32` | `uint` |
| `PIC S9(18) USAGE COMP-5 / BINARY` | 64-bit signed binary integer | `System.Int64` | `long` |
| `PIC 9(18) USAGE COMP-5 / BINARY` | 64-bit unsigned binary integer | `System.UInt64` | `ulong` |
| `USAGE COMP-1` | 32-bit single-precision floating point | `System.Single` | `float` |
| `USAGE COMP-2` | 64-bit double-precision floating point | `System.Double` | `double` |
| `PIC S9(p)V9(s) COMP-3` (Packed) | BCD packed decimal | `Fujitsu.COBOL.PackedDecimal` / `System.Decimal` | `decimal` |
| `OBJECT REFERENCE ClassName` | Managed Object Pointer | Instance of `ClassName` | Object instance |

> [!TIP]
> When calling .NET APIs (such as `System.Console::WriteLine` or `System.Convert::ToInt32`), make sure your parameters align with CTS types. Using `COMP-5` (machine binary) is strongly recommended for numerical interop rather than standard display numeric (`PIC 9`).

---

## 6. Modern Syntax: The `REPOSITORY` Paragraph
## 6. Inspecting the Generated C Code (`cobc -C`)

To consume .NET classes in NetCOBOL, you must declare them in the `REPOSITORY` paragraph located in the `CONFIGURATION SECTION` of the `ENVIRONMENT DIVISION`.
One of the best educational features of GnuCOBOL is that you can inspect the intermediate C code generated by the compiler using the **`-C`** flag:

### Syntax Example:
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ArchitectureDemo.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       REPOSITORY.
           CLASS SYS-CONSOLE  AS "System.Console"
           CLASS SYS-DATETIME AS "System.DateTime"
           CLASS SYS-STRING   AS "System.String".

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 CURRENT-TIME         OBJECT REFERENCE SYS-DATETIME.
       01 FORMATTED-MSG        OBJECT REFERENCE SYS-STRING.

       PROCEDURE DIVISION.
           INVOKE SYS-DATETIME "get_Now" RETURNING CURRENT-TIME.
           INVOKE CURRENT-TIME "ToString" USING "yyyy-MM-dd HH:mm:ss"
                                          RETURNING FORMATTED-MSG.
           INVOKE SYS-CONSOLE "WriteLine" USING FORMATTED-MSG.
           GOBACK.
```bash
cobc -C -free myprogram.cob
```

### Key Takeaways:
1. **`CLASS Alias AS "Namespace.ClassName"`** maps a friendly COBOL name (which cannot have periods) to the fully qualified .NET type.
2. Property getters are accessed via standard CLI conventions (e.g., `get_Now` for `DateTime.Now`).
3. Methods are executed using the `INVOKE` statement or modern inline method invocation syntax.

This leaves a `myprogram.c` file in your directory. Opening it reveals how the GnuCOBOL compiler translates your divisions, working-storage items, and procedure statements into clean C structs and function calls into `libcob`.
