# Lesson 5: Exercises, Practical Labs, and Solutions
# Lesson 5: Exercises, Practical Labs, and Solutions (GnuCOBOL)

This document contains practical exercises designed to test and reinforce your understanding of **Module 1: The NetCOBOL Ecosystem and Visual Studio Integration**.
This document contains practical exercises designed to test and reinforce your understanding of **Module 1: The GnuCOBOL Ecosystem and Development Toolchain**.

---

## 📋 Exercise 1: Architectural Analysis & Runtime Diagnosis
## 📋 Exercise 1: Architectural Analysis & Intermediate C Inspection

### Question 1.1: The Legacy Migration Dilemma
A mainframe legacy COBOL system is being migrated to Fujitsu NetCOBOL for .NET. A senior developer claims:
> *"Because COBOL is an old procedural language, our migrated NetCOBOL programs will run as unmanaged native Win32 binaries, requiring us to manually manage pointers and free memory whenever we instantiate objects."*
### Task 1.1: The C Translation Mechanism
1. Run the GnuCOBOL compiler with the `-C` (capital C) flag on any simple program:
   ```bash
   cobc -C -free Program1.cob
   ```
2. Locate the generated `Program1.c` file in your directory.
3. Open `Program1.c` and inspect its contents:
   - Identify where your `WORKING-STORAGE` variables are defined in C.
   - Locate the function representing your `PROCEDURE DIVISION`.
   - Identify at least two calls to `libcob` functions (e.g., `cob_display`, `cob_accept`, `cob_add`).
4. **Question**: Why does GnuCOBOL's translation into C provide superior portability compared to compilers that generate proprietary object code directly?

**Task**:
Explain why this statement is technically incorrect. Cite at least **three** specific architectural components of the NetCOBOL for .NET runtime to justify your answer.

---

### Question 1.2: Type Mapping & Truncation Risk
Consider the following legacy COBOL data item:
```cobol
01 TRANSACTION-AMOUNT     PIC S9(18) COMP-3.
01 ACCOUNT-BALANCE        PIC S9(9)V99 COMP-3.
```
Your team needs to pass these fields into a C# Web API method defined as:
```csharp
public void ProcessTransaction(long transactionAmount, decimal accountBalance)
```
1. What happens if you map `TRANSACTION-AMOUNT` to a standard 32-bit `COMP-5` integer?
2. How does the NetCOBOL compiler bridge `PIC S9(p)V9(s) COMP-3` with the .NET CTS `System.Decimal`?
3. Which compiler option must be enabled to ensure precision up to 31 decimal digits?
## 🛠️ Exercise 2: Diagnosing `cobc` Build Failures

---

## 🛠️ Exercise 2: Compiler Options & Project Diagnostics

### Scenario: Diagnosing Build Failures
A newly hired developer attempted to compile the following program in Visual Studio, but the build failed with multiple severe errors.

#### Offending Source Code (`BrokenProgram.cob`):
```cobol
000100 IDENTIFICATION DIVISION.
000200 PROGRAM-ID. BrokenProgram.
000300 ENVIRONMENT DIVISION.
000400 CONFIGURATION SECTION.
000500 DATA DIVISION.
000600 WORKING-STORAGE SECTION.
000700 COPY "EMPLOYEE.CPY".
000800 01 WS-BONUS PIC 9(12)V99.
000900 PROCEDURE DIVISION.
001000     INVOKE SYS-CONSOLE "WriteLine" USING "Processing Employee...".
001100     COMPUTE WS-BONUS = EMP-SALARY * 0.155.
001200     GOBACK.
### Scenario:
A developer attempted to compile a newly written free-format COBOL program using:
```bash
cobc BrokenProg.cob
```

#### Compiler Diagnostics Log:
And received the following errors:
```text
1> Program1.cob(7): error JMN2401I-E Copybook 'EMPLOYEE.CPY' could not be found.
1> Program1.cob(10): error JMN2811I-E Class 'SYS-CONSOLE' is not defined in the REPOSITORY paragraph.
1> Program1.cob(11): error JMN2201I-E 'EMP-SALARY' is not defined.
BrokenProg.cob:1: error: invalid indicator 'O' at column 7
BrokenProg.cob:2: error: invalid indicator 'G' at column 7
BrokenProg.cob:8: error: copybook 'EMPLOYEE.CPY' not found
```

**Task**:
1. Identify the missing project configuration that caused error `JMN2401I-E`.
2. Identify the missing syntax section that caused error `JMN2811I-E`.
3. Provide the corrected, production-ready source code.
### Questions:
1. What caused the `invalid indicator at column 7` error on lines 1 and 2?
2. What compiler flag or source directive must be used to resolve the column 7 error?
3. How can the developer resolve the copybook resolution error if `EMPLOYEE.CPY` resides in `../copybooks/`?

---

## 💻 Exercise 3: Practical Hands-on Project — "Employee Onboarding System"
## 💻 Exercise 3: Hands-on Project — "Employee Onboarding System"

### Objective
Create a standalone Modern NetCOBOL Console Application named **`EmployeeOnboarding`** that simulates a corporate HR onboarding utility.
### Objective:
Build and run a complete, native GnuCOBOL application named **`EmployeeSystem`** that processes HR onboarding records.

### Requirements:
1. **Source Format**: Modern Free Format (`@OPTIONS SOURCE(FREE)`).
2. **Copybook Integration**:
   - Use the shared copybook `EMPLOYEE.CPY` (located in `module_1/samples/copybooks/`).
   - Configure the project's **Include Paths (`LIB`)** so the compiler locates `EMPLOYEE.CPY`.
3. **.NET Class Libraries**:
   - Declare `System.Console`, `System.DateTime`, `System.Environment`, and `System.Convert` in the `REPOSITORY`.
4. **Program Workflow**:
   - **Header Display**: Clear console, display corporate banner, hostname, and execution timestamp.
   - **User Input**:
     - Prompt for Employee ID (alphanumeric 6 chars).
     - Prompt for Full Name (alphanumeric 30 chars).
     - Prompt for Department Code (`IT`, `HR`, `FIN`, `OPS`).
     - Prompt for Base Monthly Salary (Numeric).
     - Prompt for Current Age (Numeric integer).
   - **Business Rules Calculation**:
     - Annual Salary = `Base Monthly Salary * 12`.
     - Department Bonus Rate:
       - `IT`: 15%
       - `FIN`: 12%
       - `OPS`: 10%
       - Any other: 8%
     - Annual Bonus = `Annual Salary * Bonus Rate`.
     - Years to Retirement = `65 - Current Age`. If current age >= 65, years to retirement is 0.
   - **Summary Output**:
     - Display a clean summary card with formatted monetary figures (`$ZZZ,ZZ9.99`) and retirement projections.
     - Wait for user confirmation before exiting.
1. **Source Format**: Free Format (`>>SOURCE FORMAT FREE`).
2. **Copybook Inclusion**: Use `COPY "EMPLOYEE.CPY"` located in `../copybooks/`.
3. **Data Input & Formatting**:
   - Collect Employee ID, Name, Department Code (`IT`, `FIN`, `OPS`, `HR`), Monthly Salary, and Age.
   - Clean strings using `FUNCTION UPPER-CASE` and `FUNCTION TRIM`.
4. **Calculations**:
   - Annual Salary = `Monthly Salary * 12`.
   - Department Bonus Rate: IT = 15%, FIN = 12%, OPS = 10%, Other = 8%.
   - Annual Bonus = `Annual Salary * Bonus Rate`.
   - Total Compensation = `Annual Salary + Annual Bonus`.
   - Years to Retirement = `65 - Age` (or 0 if age $\ge$ 65).
5. **Output**:
   - Display a formatted confirmation slip with currency masking (`$ZZZ,ZZ9.99`).
6. **Build Command**:
   - Compile using `cobc -x -free -I ../copybooks EmployeeSystem.cob -o EmployeeSystem`.

---

# 📖 Reference Solutions & Answer Keys

---

### Solution 1.1: Architectural Analysis
The developer's statement is false due to the following reasons:
1. **MSIL Generation**: NetCOBOL for .NET does not compile directly to native x86 machine instructions. It emits Microsoft Intermediate Language (MSIL/CIL) and CLI metadata packaged as a standard .NET PE assembly.
2. **Managed Execution via CLR**: At execution time, the .NET Common Language Runtime (CLR) JIT-compiles MSIL into native machine instructions on the fly. The program runs entirely under the supervision of the CLR, benefiting from type safety, execution isolation, and exception handling.
3. **Garbage Collection (GC)**: Managed object instances (`OBJECT REFERENCE`) are allocated on the CLR Managed Heap. The CLR Garbage Collector periodically reclaims memory for unreferenced objects automatically. Manual memory freeing (`free` / unmanaged `SET ADDRESS`) is not required for managed references.
### Solution 1.1:
1. In `Program1.c`, `WORKING-STORAGE` variables are encapsulated in a static byte array or structure managed by GnuCOBOL's runtime descriptor tables.
2. The `PROCEDURE DIVISION` becomes a standard C function (e.g., `static int Program1_ (const int entry);`).
3. Calls like `cob_display(0, 1, 1, ...)` and `cob_accept(...)` connect directly to `libcob`.
4. **Portability Justification**: Because C is the universal language of modern computing, any platform possessing an ANSI C compiler (GCC, Clang, MSVC) can immediately compile and run GnuCOBOL programs without needing custom machine-code backends for each new CPU architecture.

---

### Solution 1.2: Type Mapping & Truncation
1. **Truncation Hazard**: `PIC S9(18)` requires an 8-byte 64-bit integer (`System.Int64` / `long`). A 32-bit `COMP-5` integer (`System.Int32`) can only hold numbers up to $\pm 2,147,483,647$ (approx 9-10 digits). Mapping an 18-digit value to a 32-bit integer causes severe arithmetic overflow and data corruption. It must be declared as `PIC S9(18) COMP-5` or `BINARY`.
2. **`COMP-3` to `System.Decimal` Bridge**: The NetCOBOL runtime helper library (`Fujitsu.COBOL.dll`) provides internal converters that marshal packed decimal BCD (Binary Coded Decimal) fields to .NET's 128-bit `System.Decimal` representation without precision loss.
3. **Compiler Directive**: To support high precision up to 31 decimal digits without truncation during intermediate calculations, enable `@OPTIONS ARITH(EXTEND)`.
### Solution 2:
1. **Root Cause**: `cobc` defaults to Fixed Format (80-column punch-card layout), expecting column 7 to be an indicator (space, `*`, `/`, `-`). Because the program was written in free format without telling the compiler, arbitrary characters landed on column 7.
2. **Fix**: Pass the `-free` flag to `cobc`, or insert `>>SOURCE FORMAT FREE` as the very first line of the source code.
3. **Copybook Fix**: Pass `-I ../copybooks` to `cobc` during compilation, or set the `COB_COPY_DIR` environment variable:
   ```bash
   cobc -x -free -I ../copybooks BrokenProg.cob -o BrokenProg
   ```

---

### Solution 2: Diagnostics & Corrected Code
1. **Fix for `JMN2401I-E`**: The directory containing `EMPLOYEE.CPY` was not registered in the project's **Include Paths (`LIB`)**. In Visual Studio, go to **Project Properties -> COBOL Compiler Options -> Include Paths (LIB)** and add `.\Copybooks` or the relative directory of the copybook.
2. **Fix for `JMN2811I-E`**: The `REPOSITORY` paragraph was missing inside the `CONFIGURATION SECTION` of the `ENVIRONMENT DIVISION`.
3. **Corrected Source Code**:
### Solution 3:
The complete reference implementation is provided in:
📁 [`module_1/samples/EmployeeOnboarding/EmployeeSystem.cob`](file:///e:/training/cobol-training/module_1/samples/EmployeeOnboarding/EmployeeSystem.cob)

```cobol
@OPTIONS SOURCE(FREE), ARITH(EXTEND)
IDENTIFICATION DIVISION.
PROGRAM-ID. FixedProgram.

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
REPOSITORY.
    CLASS SYS-CONSOLE AS "System.Console".

DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "EMPLOYEE.CPY".
01 WS-BONUS           PIC 9(7)V99 COMP-3.
01 WS-BONUS-DISPLAY   PIC $ZZZ,ZZ9.99.

PROCEDURE DIVISION.
    INVOKE SYS-CONSOLE "WriteLine" USING "Processing Employee...".
    
    *> Assuming EMP-SALARY is defined in EMPLOYEE.CPY
    COMPUTE WS-BONUS = EMP-SALARY * 0.155.
    MOVE WS-BONUS TO WS-BONUS-DISPLAY.
    
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Calculated Bonus: " & WS-BONUS-DISPLAY.
    GOBACK.
Compile and execute it with:
```bash
cd module_1/samples/EmployeeOnboarding
cobc -x -free -I ../copybooks EmployeeSystem.cob -o EmployeeSystem
./EmployeeSystem
```

---

### Solution 3: Complete "Employee Onboarding System" Implementation

The complete working source code for Exercise 3 has been provided in the project workspace:
- Copybook: [`module_1/samples/copybooks/EMPLOYEE.CPY`](file:///e:/training/cobol-training/module_1/samples/copybooks/EMPLOYEE.CPY)
- Program Source: [`module_1/samples/EmployeeOnboarding/EmployeeSystem.cob`](file:///e:/training/cobol-training/module_1/samples/EmployeeOnboarding/EmployeeSystem.cob)

