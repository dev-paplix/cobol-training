# Guide 2: Object-Oriented COBOL (OO-COBOL) — Classes, Methods, and Inheritance
# Guide 2: Modular Architecture in GnuCOBOL — Subprograms, Functions & Linkage

## 1. The Anatomy of an OO-COBOL Class
## 1. Modularity and Encapsulation in Standard COBOL

In Fujitsu NetCOBOL for .NET, object-oriented concepts map directly to the .NET Common Language Infrastructure (CLI). An OO-COBOL source file defines a **`CLASS-ID`** which compiles into a standard .NET class inside a `.dll` or `.exe`.
In the GnuCOBOL ecosystem, modularity, encapsulation, and code reuse are achieved through:
1. **Separately Compiled Subprograms** (`PROGRAM-ID` invoked via `CALL`).
2. **The `LINKAGE SECTION`** (Mapping caller memory into callee parameters).
3. **Parameter Passing Conventions** (`BY REFERENCE`, `BY CONTENT`, `BY VALUE`).
4. **User-Defined Functions** (`FUNCTION-ID`), supported under modern COBOL 2002/2014 standards in GnuCOBOL.
5. **Dynamic Modules (`cobc -m`)**: Compiling reusable subprograms into shared libraries loaded on-demand.

A complete OO-COBOL class is divided into two distinct conceptual scopes:
1. **`FACTORY` (Static / Class Scope)**:
   - Data and methods associated with the **class itself** (equivalent to C# `static` members or class factory methods).
2. **`OBJECT` (Instance Scope)**:
   - Data and methods associated with **individual object instances** (equivalent to non-static fields and methods in C#).
---

## 2. Anatomy of a Subprogram

A subprogram is a standalone COBOL compilation unit designed to perform a dedicated business operation.

```cobol
>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. TaxCalculator.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-TAX-RATE          PIC V999 VALUE 0.0825.

LINKAGE SECTION.
*> Parameters passed from the calling program
01 LS-GROSS-AMOUNT      PIC 9(7)V99.
01 LS-TAX-DUE           PIC 9(7)V99.

PROCEDURE DIVISION USING LS-GROSS-AMOUNT LS-TAX-DUE.
    COMPUTE LS-TAX-DUE ROUNDED = LS-GROSS-AMOUNT * WS-TAX-RATE.
    GOBACK.
```
+-------------------------------------------------------------+
| CLASS-ID. MyClass [INHERITS BaseClass]                     |
|                                                             |
|   +-- FACTORY. (Static / Class Scope) --------------------+ |
|   |   DATA DIVISION. (Static Variables)                   | |
|   |   PROCEDURE DIVISION.                                 | |
|   |       METHOD-ID. StaticMethod. ... END METHOD.        | |
|   +-------------------------------------------------------+ |
|                                                             |
|   +-- OBJECT. (Instance Scope) ---------------------------+ |
|   |   DATA DIVISION. (Instance Fields)                    | |
|   |   PROCEDURE DIVISION.                                 | |
|   |       METHOD-ID. NEW. (Constructor) ... END METHOD.   | |
|   |       METHOD-ID. InstanceMethod. ... END METHOD.      | |
|   +-------------------------------------------------------+ |
|                                                             |
| END CLASS MyClass.                                          |
+-------------------------------------------------------------+
```

---

## 2. Declaring Methods and Parameters
## 3. Parameter Passing Semantics: Reference, Content, Value

Methods are declared with `METHOD-ID. MethodName.` and closed with `END METHOD MethodName.`.
When invoking a subprogram via `CALL`, you have full control over parameter mechanics:

Parameters and return values are declared in the **`LINKAGE SECTION`** of the method:
- **Input Parameters**: Listed in `PROCEDURE DIVISION USING param1, param2...`
- **Return Value**: Declared with `RETURNING retVal`

### Example Method Definition:
```cobol
       METHOD-ID. CalculateInterest.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-INTEREST-CALC     PIC S9(7)V99 COMP-3.
       LINKAGE SECTION.
       01 Rate                 PIC V999 COMP-3.       *> Input parameter
       01 CalculatedAmount     PIC S9(7)V99 COMP-3.   *> Return value
       PROCEDURE DIVISION USING Rate RETURNING CalculatedAmount.
           COMPUTE WS-INTEREST-CALC = Balance * Rate.
           MOVE WS-INTEREST-CALC TO CalculatedAmount.
       END METHOD CalculateInterest.
    CALL "TaxCalculator" USING 
        BY REFERENCE WS-ORIGINAL-DATA
        BY CONTENT   WS-READONLY-DATA
        BY VALUE     WS-INTEGER-VAL
```

| Convention | Behavior | C Equivalent |
| :--- | :--- | :--- |
| **`BY REFERENCE`** | Passes the memory pointer to the original variable. Any change inside the subprogram modifies the caller's data directly. *(Default)* | `void func(int *ptr)` |
| **`BY CONTENT`** | Copies the caller's value to a temporary memory buffer and passes the buffer's pointer. The caller's variable cannot be overwritten. | Pass temporary copy pointer |
| **`BY VALUE`** | Passes the raw value directly on the call stack. Used heavily when interfacing directly with C libraries. | `void func(int val)` |

---

## 3. Constructors (`METHOD-ID. NEW`)
## 4. Compiling and Linking Subprograms with GnuCOBOL

In NetCOBOL for .NET, object initialization is performed by the **`NEW`** method inside the `OBJECT` scope.
You have two primary architectural choices when building multi-program systems with `cobc`:

```cobol
       METHOD-ID. NEW.
       DATA DIVISION.
       LINKAGE SECTION.
       01 InitialBalance       PIC S9(9)V99 COMP-3.
       PROCEDURE DIVISION USING InitialBalance.
           *> Always invoke super constructor first
           INVOKE SUPER "NEW".
           MOVE InitialBalance TO Balance.
       END METHOD NEW.
### Approach A: Static Compilation (Single Monolithic Binary)
Compile all source files together into a single executable:
```bash
cobc -x -free MainApp.cob TaxCalculator.cob -o MainApp
./MainApp
```

### Instantiating an Object from Another Program:
```cobol
       WORKING-STORAGE SECTION.
       01 MyAccount   OBJECT REFERENCE BankAccount.
### Approach B: Dynamic Modular Compilation (`cobc -m`)
Compile the main program as an executable, and compile subprograms as dynamically loadable shared objects (`.so` on Linux, `.dll` on Windows):
```bash
# 1. Compile subprogram into a dynamically loadable module (.so)
cobc -m -free TaxCalculator.cob

       PROCEDURE DIVISION.
           INVOKE BankAccount "NEW" USING 1500.00 RETURNING MyAccount.
           INVOKE MyAccount "Deposit" USING 250.00.
# 2. Compile main program
cobc -x -free MainApp.cob -o MainApp

# 3. Run! GnuCOBOL will automatically load TaxCalculator.so when CALL is reached
./MainApp
```

> [!TIP]
> Use the **`COB_LIBRARY_PATH`** environment variable if your `.so` modules reside in a separate directory (e.g. `export COB_LIBRARY_PATH=./modules`).

---

## 4. Inheritance & Method Overriding
## 5. User-Defined Functions (`FUNCTION-ID`)

NetCOBOL supports single inheritance using the **`INHERITS`** clause:
GnuCOBOL supports **User-Defined Functions** (introduced in COBOL 2002). Functions return a value directly and can be used inside inline expressions!

### Defining the Function:
```cobol
CLASS-ID. SavingsAccount INHERITS BankAccount.
```
>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
FUNCTION-ID. CalcBonus.

### Key Rules for Inheritance:
1. **Declaration**: In `REPOSITORY`, you must declare both the base class and any referenced types.
2. **Calling Superclass Constructor**: In the derived class constructor (`NEW`), call:
   ```cobol
   INVOKE SUPER "NEW" [USING arguments].
   ```
3. **Overriding Methods**: Use the `OVERRIDE` keyword on the `METHOD-ID`:
   ```cobol
   METHOD-ID. Withdraw OVERRIDE.
   ```
4. **Calling Base Implementation**: To call the superclass's version of a method from inside the overridden method:
   ```cobol
   INVOKE SUPER "Withdraw" USING Amount RETURNING SuccessFlag.
   ```
DATA DIVISION.
LINKAGE SECTION.
01 LS-SALARY       PIC 9(7)V99.
01 LS-BONUS        PIC 9(7)V99.

---
PROCEDURE DIVISION USING LS-SALARY RETURNING LS-BONUS.
    COMPUTE LS-BONUS = LS-SALARY * 0.15.
    GOBACK.
END FUNCTION CalcBonus.
```

## 5. Polymorphism in Action
### Using the Function:
```cobol
>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. MainCaller.

Because NetCOBOL emits .NET CLI metadata, polymorphic assignments work identically to C#:
CONFIGURATION SECTION.
REPOSITORY.
    FUNCTION CalcBonus.

```cobol
DATA DIVISION.
WORKING-STORAGE SECTION.
*> Base class reference holding a derived class instance
01 AcctRef    OBJECT REFERENCE BankAccount.
01 SavingsRef OBJECT REFERENCE SavingsAccount.
01 WS-SALARY   PIC 9(7)V99 VALUE 50000.00.
01 WS-RESULT   PIC 9(7)V99.

PROCEDURE DIVISION.
    INVOKE SavingsAccount "NEW" USING "SA-901" 1000.00 RETURNING SavingsRef.
    
    *> Polymorphic assignment: SavingsAccount IS A BankAccount
    SET AcctRef TO SavingsRef.
    
    *> Dynamically invokes SavingsAccount's overridden method!
    INVOKE AcctRef "DisplaySummary".
    *> Invoke directly in an arithmetic expression!
    COMPUTE WS-RESULT = CalcBonus(WS-SALARY).
    DISPLAY "Calculated Bonus: " WS-RESULT.
    GOBACK.
```

