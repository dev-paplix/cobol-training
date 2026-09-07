# Guide 3: Working with .NET Data Types — System.String, Int32, and Decimal
# Guide 3: GnuCOBOL Data Types, String Manipulation, and Exact Arithmetic

## 1. Bridging COBOL and the .NET Common Type System (CTS)
## 1. The GnuCOBOL Data Type Landscape

When writing Modern COBOL, you will constantly interact with .NET Base Class Libraries. The three most essential types are:
1. **`System.String`**: For dynamic text manipulation, formatting, and internationalization.
2. **`System.Int32`**: For fast, native 32-bit machine binary calculations, loops, and indexing.
3. **`System.Decimal`**: For exact, high-precision financial and monetary calculations without floating-point rounding errors.
GnuCOBOL offers rich support for both traditional business data items and low-level machine types:

```
+--------------------------------------------------------------------------------+
|                            GNUCOBOL DATA TAXONOMY                              |
+--------------------------------------------------------------------------------+
| 1. Alphanumeric & Strings                                                      |
|    - PIC X(n)          : Fixed-length character buffer                         |
|    - Intrinsic Funcs   : FUNCTION TRIM, UPPER-CASE, LOWER-CASE, SUBSTITUTE    |
|    - Structured Verbs  : STRING ... DELIMITED BY, UNSTRING ... DELIMITED BY   |
+--------------------------------------------------------------------------------+
| 2. Machine Binary Integers                                                     |
|    - USAGE BINARY / COMP-4 / COMP-5 (Maps to C short, int, long long)         |
|    - Fast looping, table indexes, and C interoperability                       |
+--------------------------------------------------------------------------------+
| 3. High-Precision Packed Decimal (Currency & Banking)                         |
|    - USAGE COMP-3 / PACKED-DECIMAL                                             |
|    - BCD encoding, 0% binary floating-point roundoff error                     |
+--------------------------------------------------------------------------------+
| 4. Hardware Floating Point                                                     |
|    - USAGE COMP-1 (32-bit float), USAGE COMP-2 (64-bit double)                |
|    - Scientific calculations, geometry, trigonometric formulas                |
+--------------------------------------------------------------------------------+
```

---

## 2. Working with `System.String`
## 2. Advanced String Processing: `UNSTRING` and `STRING`

In traditional COBOL, strings are fixed-length byte buffers (`PIC X(n)`) padded with trailing spaces. In contrast, `System.String` is an immutable, dynamic UTF-16 reference type.
### A. Parsing Delimited Data with `UNSTRING`
COBOL provides the built-in `UNSTRING` verb, which splits a single source string across delimiters into target fields:

### Declaring and Invocations:
```cobol
CONFIGURATION SECTION.
REPOSITORY.
    CLASS SYS-STRING  AS "System.String"
    CLASS SYS-CONSOLE AS "System.Console".
01 WS-RAW-RECORD     PIC X(80) VALUE "TXN-101,ACCT-900,1450.50,DEPOSIT".
01 WS-TXN-ID         PIC X(10).
01 WS-ACCT-NUM       PIC X(10).
01 WS-AMOUNT-STR     PIC X(10).
01 WS-TYPE           PIC X(10).

DATA DIVISION.
WORKING-STORAGE SECTION.
01 FullText           OBJECT REFERENCE SYS-STRING.
01 SubText            OBJECT REFERENCE SYS-STRING.
01 UpperText          OBJECT REFERENCE SYS-STRING.
01 TextLen            PIC S9(9) COMP-5.

PROCEDURE DIVISION.
    *> Direct string assignment
    MOVE "   NetCOBOL for .NET Enterprise   " TO FullText.
    UNSTRING WS-RAW-RECORD DELIMITED BY ","
        INTO WS-TXN-ID
             WS-ACCT-NUM
             WS-AMOUNT-STR
             WS-TYPE.
```

    *> Trim whitespace
    INVOKE FullText "Trim" RETURNING FullText.
### B. Concatenating with `STRING`
The `STRING` statement joins multiple fields into a target buffer with explicit delimiter rules:

    *> Convert to Uppercase
    INVOKE FullText "ToUpper" RETURNING UpperText.
```cobol
01 WS-FIRST-NAME     PIC X(15) VALUE "GRACE".
01 WS-LAST-NAME      PIC X(15) VALUE "HOPPER".
01 WS-FULL-MESSAGE   PIC X(80).

    *> Substring (StartIndex 0, Length 8) -> "NETCOBOL"
    INVOKE UpperText "Substring" USING 0 8 RETURNING SubText.

    *> Get String Length
    INVOKE SubText "get_Length" RETURNING TextLen.

    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Extracted: [" & SubText & "] Length: " & TextLen.
PROCEDURE DIVISION.
    STRING "Dr. " DELIMITED BY SIZE
           FUNCTION TRIM(WS-FIRST-NAME) DELIMITED BY SIZE
           " " DELIMITED BY SIZE
           FUNCTION TRIM(WS-LAST-NAME) DELIMITED BY SIZE
           " - Computer Pioneer" DELIMITED BY SIZE
           INTO WS-FULL-MESSAGE.
```

### Essential `System.String` Methods:
| Method | Description | Example Usage |
| :--- | :--- | :--- |
| `Trim()` | Removes leading and trailing whitespace | `INVOKE Str "Trim" RETURNING CleanStr` |
| `ToUpper()` / `ToLower()` | Case conversion | `INVOKE Str "ToUpper" RETURNING UpperStr` |
| `Substring(start, len)` | Extracts slice | `INVOKE Str "Substring" USING 0 5 RETURNING Slice` |
| `Contains(value)` | Checks substring presence | `INVOKE Str "Contains" USING "NET" RETURNING FoundFlag` |
| `Replace(old, new)` | Replaces character sequences | `INVOKE Str "Replace" USING "-" "/" RETURNING NewStr` |
| `get_Length` | Property getter for length | `INVOKE Str "get_Length" RETURNING Len` |

---

## 3. Working with `System.Int32` (`PIC S9(9) COMP-5`)
## 3. Essential Modern Intrinsic Functions

To achieve maximum performance and seamless interop with .NET loop counters, array indices, and integer parameters, map directly to `PIC S9(9) COMP-5` or `BINARY`:
GnuCOBOL includes standard ISO COBOL intrinsic functions:

- `COMP-5` specifies native machine binary format (little-endian on x86/x64).
- Matches the memory layout of C#'s `int` and .NET's `System.Int32` exactly—requiring **zero marshaling overhead**.
| Function | Purpose | Example |
| :--- | :--- | :--- |
| **`FUNCTION TRIM(str)`** | Strips leading and trailing spaces | `MOVE FUNCTION TRIM(WS-NAME) TO WS-CLEAN` |
| **`FUNCTION UPPER-CASE(str)`** | Converts to uppercase | `MOVE FUNCTION UPPER-CASE(WS-CODE) TO WS-UPPER` |
| **`FUNCTION LOWER-CASE(str)`** | Converts to lowercase | `MOVE FUNCTION LOWER-CASE(WS-EMAIL) TO WS-LOWER` |
| **`FUNCTION LENGTH(str)`** | Returns character length | `COMPUTE WS-LEN = FUNCTION LENGTH(WS-STR)` |
| **`FUNCTION NUMVAL(str)`** | Parses number from text string | `COMPUTE WS-NUM = FUNCTION NUMVAL(WS-STR)` |
| **`FUNCTION NUMVAL-C(str)`**| Parses monetary string (`"$1,250.50"`) | `COMPUTE WS-AMT = FUNCTION NUMVAL-C(WS-STR)` |
| **`FUNCTION CURRENT-DATE`** | Returns 21-character date/timestamp | `MOVE FUNCTION CURRENT-DATE TO WS-DATE-BLOCK` |
| **`FUNCTION SQRT(n)`** | Calculates square root | `COMPUTE WS-ROOT = FUNCTION SQRT(144)` |

### Performing Calculations with `System.Math`:
```cobol
CONFIGURATION SECTION.
REPOSITORY.
    CLASS SYS-MATH    AS "System.Math"
    CLASS SYS-CONVERT AS "System.Convert".

DATA DIVISION.
WORKING-STORAGE SECTION.
01 NumA      PIC S9(9) COMP-5 VALUE 150.
01 NumB      PIC S9(9) COMP-5 VALUE 320.
01 MaxResult PIC S9(9) COMP-5.
01 AbsResult PIC S9(9) COMP-5.
01 StrVal    OBJECT REFERENCE SYS-STRING VALUE "4500".

PROCEDURE DIVISION.
    *> Call System.Math static methods
    INVOKE SYS-MATH "Max" USING NumA NumB RETURNING MaxResult.
    INVOKE SYS-MATH "Abs" USING -75 RETURNING AbsResult.

    *> Convert String to Int32
    INVOKE SYS-CONVERT "ToInt32" USING StrVal RETURNING NumA.
```

---

## 4. Working with `System.Decimal` for Financial Calculations
## 4. Financial Precision: Why `COMP-3` is Mandatory for Banking

Binary floating-point types (`float` / `double` / `COMP-1` / `COMP-2`) cannot accurately represent fractions like `0.1` or `0.01` due to base-2 representation limits.
In binary floating point (`COMP-1` / `COMP-2` / C `double`), fractions like `0.1` cannot be expressed exactly in binary (base-2), resulting in repeating approximations like `0.10000000000000000555...`.

For banking and financial systems, you have two primary options in NetCOBOL:
1. **COBOL Packed Decimal (`PIC S9(p)V9(s) COMP-3`)**:
   - The native COBOL decimal format with automatic scaling.
2. **.NET `System.Decimal` (`OBJECT REFERENCE SYS-DECIMAL`)**:
   - A 128-bit high-precision fixed-point number supported by .NET BCL.
Over millions of financial transactions, this accumulates into significant auditing discrepancies.

### Seamless Conversion Pattern:
### The Solution: Packed Decimal (`COMP-3`)
```cobol
CONFIGURATION SECTION.
REPOSITORY.
    CLASS SYS-DECIMAL AS "System.Decimal"
    CLASS SYS-CONVERT AS "System.Convert"
    CLASS SYS-CONSOLE AS "System.Console".
01 WS-EXACT-BALANCE     PIC S9(9)V99 COMP-3.
01 WS-INTEREST-RATE     PIC V9999    COMP-3 VALUE 0.0525.
01 WS-ACCRUED-INTEREST  PIC S9(7)V99 COMP-3.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 COBOL-SALARY       PIC S9(7)V99 COMP-3 VALUE 85450.75.
01 COBOL-BONUS        PIC S9(7)V99 COMP-3 VALUE 12817.61.
01 COBOL-TOTAL        PIC S9(8)V99 COMP-3.

01 DOTNET-DEC-1       OBJECT REFERENCE SYS-DECIMAL.
01 DOTNET-DEC-2       OBJECT REFERENCE SYS-DECIMAL.
01 DOTNET-SUM         OBJECT REFERENCE SYS-DECIMAL.
01 FORMATTED-CURR     OBJECT REFERENCE SYS-STRING.

PROCEDURE DIVISION.
    *> Convert COBOL Packed Decimal to System.Decimal
    INVOKE SYS-CONVERT "ToDecimal" USING COBOL-SALARY RETURNING DOTNET-DEC-1.
    INVOKE SYS-CONVERT "ToDecimal" USING COBOL-BONUS RETURNING DOTNET-DEC-2.

    *> Perform high-precision static Decimal calculation
    INVOKE SYS-DECIMAL "Add" USING DOTNET-DEC-1 DOTNET-DEC-2 RETURNING DOTNET-SUM.

    *> Format directly as localized currency using .NET format string "{0:C}"
    INVOKE SYS-STRING "Format" 
        USING "{0:C}" DOTNET-SUM 
        RETURNING FORMATTED-CURR.

    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Total Compensation: " & FORMATTED-CURR.
    COMPUTE WS-ACCRUED-INTEREST ROUNDED = WS-EXACT-BALANCE * WS-INTEREST-RATE
        ON SIZE ERROR
            DISPLAY "ERROR: Balance overflow detected!"
    END-COMPUTE.
```

`COMP-3` stores digits as Binary-Coded Decimal (BCD), guaranteeing **100% exact decimal accuracy** with zero floating-point drift.
