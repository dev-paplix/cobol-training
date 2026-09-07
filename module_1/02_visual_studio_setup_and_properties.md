# Lesson 2: Visual Studio IDE Setup — Solution Explorer, Project Templates, and Properties
# Lesson 2: GnuCOBOL Development Environment Setup

## 1. Overview of Visual Studio Integration
## 1. Modern Tooling for GnuCOBOL

Fujitsu NetCOBOL for .NET integrates directly into the Microsoft Visual Studio IDE (supporting VS 2017, VS 2019, and VS 2022 depending on NetCOBOL version). This integration transforms Visual Studio into a modern COBOL development environment equipped with:
While GnuCOBOL is driven via the command line (`cobc`), modern developers pair it with lightweight, powerful IDEs such as **Visual Studio Code (VS Code)**, **VSCodium**, or **Neovim** across Linux, macOS, and Windows (via WSL2 or MSYS2).

- **MSBuild Support**: COBOL projects use standard MSBuild-compliant `.cobproj` XML project files.
- **IntelliSense & Syntax Highlighting**: Color-coded keywords, sections, and division identifiers.
- **Solution Explorer Integration**: Native representation of COBOL source files, copybooks, and .NET assembly references.
- **Unified Debugging**: Full integration with the Visual Studio debugger, allowing you to set breakpoints, step through COBOL code, inspect variables in the Watch/Locals windows, and even step across languages into C# or VB.NET code.

---

## 2. NetCOBOL Project Templates

When creating a new project in Visual Studio (`File -> New -> Project`), filter by language by choosing **COBOL**. NetCOBOL provides several primary project templates:

```
+--------------------------------------------------------------------------------+
|                          NETCOBOL PROJECT TEMPLATES                            |
|                   GNUCOBOL DEVELOPER WORKSPACE ARCHITECTURE                    |
+--------------------------------------------------------------------------------+
| 1. NetCOBOL Console Application                                                |
|    - Target: Command-line applications (Batch processing, CLI utilities)      |
|    - Emits: .exe executable containing a standard PROGRAM-ID or CLASS-ID      |
| Code Editor: Visual Studio Code                                                |
|   ├── Extension: bitlang.cobol (COBOL language support & syntax highlighting)  |
|   ├── Tasks: .vscode/tasks.json (Automated cobc build shortcuts via Ctrl+Shift+B)
|   └── Linter / Diagnostics: Automated error squiggles from cobc -fsyntax-only   |
|                                                                                |
| Terminal / CLI Toolchain:                                                      |
|   ├── Compiler: cobc (Translates COBOL to C and executes GCC/Clang)            |
|   ├── Debugger: GDB (GNU Debugger) with COBOL-aware source line mapping        |
|   └── Automation: Makefile / CMake / bash scripts                              |
+--------------------------------------------------------------------------------+
| 2. NetCOBOL Class Library                                                      |
|    - Target: Business logic tiers, reusable calculation engines               |
|    - Emits: .dll assembly consumed by C#, ASP.NET, or other COBOL projects   |
+--------------------------------------------------------------------------------+
| 3. NetCOBOL Windows Application                                                |
|    - Target: Desktop graphical applications using Windows Forms (WinForms)     |
|    - Emits: .exe with graphical message loop and event handlers               |
+--------------------------------------------------------------------------------+
| 4. NetCOBOL ASP.NET Web Application / Service                                  |
|    - Target: Legacy web services, Web Forms, or HTTP handlers                 |
|    - Emits: Managed assemblies hosted in IIS                                   |
+--------------------------------------------------------------------------------+
```

### Choosing the Right Template
- Use **Console Application** for batch processing, utility scripts, data migration routines, and testing.
- Use **Class Library** when modernizing enterprise systems into a multi-tier architecture where modern UI/Web layers (e.g., ASP.NET Core or WPF written in C#) invoke COBOL business rules.
---

## 2. Recommended VS Code Extensions

Install the following extensions from the VS Code Marketplace or Open-VSX:
1. **COBOL** by *BitLang*: Provides syntax highlighting, code completion, snippets, and margin navigation for both Free and Fixed format COBOL.
2. **GnuCOBOL** by *Ocedo*: Integrates `cobc -fsyntax-only` for real-time background error reporting.
3. **Native Debug** by *webfreak*: Enables interactive step-debugging via `gdb`.

---

## 3. Solution Explorer Anatomy
## 3. Recommended Project Structure

A NetCOBOL project within the Visual Studio **Solution Explorer** consists of several key elements:
A clean, standard project layout for GnuCOBOL systems:

```text
Solution 'CobolModernization' (2 Projects)
│
├── 📁 CobolCoreLib (.cobproj)                 <-- NetCOBOL Class Library
│   ├── 📁 Properties
│   │   └── AssemblyInfo.cob                  <-- Assembly metadata (Version, Title, GUID)
│   ├── 📁 References
│   │   ├── Fujitsu.COBOL                      <-- NetCOBOL runtime helper library
│   │   ├── System                             <-- Core .NET BCL
│   │   └── System.Data                        <-- ADO.NET database library
│   ├── 📁 Copybooks
│   │   ├── ACCTREC.CPY                        <-- Shared record layout
│   │   └── COMMCODES.CPY                      <-- Return codes copybook
│   ├── AccountProcessor.cob                   <-- Core business logic class
│   └── CalculationService.cob                 <-- Calculation routines
│
└── 📁 WebFrontEnd (C# ASP.NET Core)           <-- Multi-language integration
    ├── 📁 Controllers
    └── Program.cs                             <-- Directly invokes CobolCoreLib.dll!
my-cobol-project/
├── .vscode/
│   ├── tasks.json             # Build automation definitions
│   └── settings.json          # Editor formatting & copybook paths
├── bin/                       # Compiled executable binaries
├── copybooks/                 # Reusable .cpy copybooks
│   └── COMMON-DEFS.CPY
├── src/                       # COBOL source files (.cob or .cbl)
│   ├── main.cob
│   └── subroutines/
│       └── logger.cob
├── tests/                     # Automated test suites
└── Makefile                   # Build automation script
```

### Key Elements:
1. **`.cobproj` File**: An XML file adhering to the MSBuild schema. It defines targets, compiler paths, flags, dependencies, and included source files.
2. **References Node**: Managed assemblies referenced by your project. By default, `Fujitsu.COBOL` and `System` are included. You can right-click **References -> Add Reference...** to reference standard .NET DLLs, NuGet packages, or other C#/VB projects in the solution.
3. **Source Files (`.cob` or `.cbl`)**: The actual COBOL source files.
4. **Copybooks (`.cpy`, `.cbl`, or `.cop`)**: Files referenced via the COBOL `COPY` statement.
5. **`AssemblyInfo.cob`**: COBOL equivalent of C#'s `AssemblyInfo.cs`, declaring assembly attributes such as `AssemblyVersion`, `AssemblyTitle`, and `AssemblyCompany`.

---

## 4. Project Properties Deep Dive
## 4. Configuring VS Code Build Tasks (`.vscode/tasks.json`)

To access project properties, right-click the project node in **Solution Explorer** and select **Properties** (or press `Alt + Enter`).
To compile the active COBOL file in VS Code simply by pressing `Ctrl + Shift + B`, create `.vscode/tasks.json`:

### A. Application Page
- **Assembly Name**: The name of the output `.dll` or `.exe` file (e.g., `FinancialEngine`).
- **Default Namespace**: The default root namespace for classes generated in the project.
- **Target Framework**: Specifies the .NET runtime version (e.g., `.NET Framework 4.8`).
- **Output Type**: 
  - `Console Application` (has a command window)
  - `Windows Application` (GUI window, no console)
  - `Class Library` (non-executable assembly `.dll`)
- **Startup Object**: The designated `PROGRAM-ID` or `CLASS-ID` that contains the application entry point.
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Active GnuCOBOL Program",
            "type": "shell",
            "command": "cobc",
            "args": [
                "-x",
                "-free",
                "-Wall",
                "-I", "${workspaceFolder}/copybooks",
                "${file}",
                "-o", "${workspaceFolder}/bin/${fileBasenameNoExtension}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": {
                "owner": "cobol",
                "fileLocation": ["relative", "${workspaceFolder}"],
                "pattern": {
                    "regexp": "^(.*):(\\d+):\\s+(warning|error):\\s+(.*)$",
                    "file": 1,
                    "line": 2,
                    "severity": 3,
                    "message": 4
                }
            }
        }
    ]
}
```

### B. Build Page
- **Configuration**: Toggle between `Debug` (includes full symbol files `.pdb`, enables diagnostics) and `Release` (code optimization enabled, debug symbols minimized).
- **Platform**: `Any CPU`, `x86`, or `x64`.
- **Output Path**: Defaults to `bin\Debug\` or `bin\Release\`.
- **Generate XML Documentation**: Generates XML metadata for exposed COBOL classes.
---

### C. COBOL Compiler Options Page
This is the most critical configuration page in NetCOBOL projects:
## 5. Build Automation with `Makefile`

```
+-----------------------------------------------------------------------+
| NetCOBOL Project Properties - Compiler Settings                       |
+-----------------------------------------------------------------------+
| Source Format:             ( ) Fixed Format       (*) Free Format     |
| Character Set:             (*) ASCII              ( ) Unicode (RCS)   |
| Diagnostic Message Level:  [ Information (Level 0)            v ]     |
| Arithmetic Support:        [ Extended Precision (ARITH(EXTEND)) v ]  |
| Include Paths (LIB):       [ .\Copybooks;..\Shared\Copybooks     ]    |
| Additional Directives:     [ ALPHAL(WORD) ENDIAN(LITTLE)        ]    |
+-----------------------------------------------------------------------+
```
For multi-file projects, create a `Makefile` in the root of your project:

- **Source Format**:
  - **Fixed Format**: Traditional 80-column punch-card layout (Columns 1-6 Sequence, Column 7 Indicator, Area A 8-11, Area B 12-72, Columns 73-80 Identification).
  - **Free Format**: Modern format where code can begin in any column and extend up to 255 characters per line without margin restrictions.
- **Include Paths (`LIB` or `COPYPATH`)**: Semicolon-delimited directory list where the compiler searches for files referenced in `COPY "NAME"` statements.
- **Compiler Directives**: Pass specific flags to the compiler engine (see Lesson 3 for details).
```makefile
# Makefile for GnuCOBOL Application
COBC = cobc
COBFLAGS = -free -Wall -O2 -I ./copybooks
BIN_DIR = bin
SRC_DIR = src

### D. Debug Page
- **Start Action**:
  - *Start Project*: Launches the output assembly directly.
  - *Start External Program*: Launches an external host application (e.g., launching a C# test harness or `iisexpress.exe` to debug a COBOL Class Library).
- **Command Line Arguments**: Parameters passed into the `PROGRAM-ID` through linkage or `System.Environment::GetCommandLineArgs()`.
- **Working Directory**: Directory from which relative file paths (`ASSIGN TO "DATAFILE.DAT"`) are resolved during debug execution.
# Targets
all: $(BIN_DIR)/app

---
$(BIN_DIR)/app: $(SRC_DIR)/main.cob
	@mkdir -p $(BIN_DIR)
	$(COBC) -x $(COBFLAGS) $< -o $@

## 5. Solution Best Practices: Multi-Language Projects
clean:
	rm -rf $(BIN_DIR)

A primary benefit of NetCOBOL for .NET is the ability to maintain COBOL business engines alongside modern C# user interfaces or APIs within the same Visual Studio solution:
.PHONY: all clean
```

### Setting Up a Multi-Language Solution:
1. Create a blank solution: `File -> New -> Project -> Blank Solution`.
2. Add the COBOL project: Right-click Solution -> `Add -> New Project -> NetCOBOL Class Library`.
3. Add the Modern Frontend: Right-click Solution -> `Add -> New Project -> C# ASP.NET Core Web API` (or WPF/Console).
4. Establish Reference: In the C# project, right-click **Dependencies / References -> Add Project Reference -> Select the NetCOBOL Class Library**.
5. Build Order: Visual Studio automatically builds the NetCOBOL library first, produces the `.dll`, and passes it as a reference to the C# compiler.

Simply typing `make` will build your binaries efficiently and cleanly.
