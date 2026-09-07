# Chapter 2: Managed Exceptions vs. Native Runtime Errors

Understanding how errors manifest at runtime is critical when modernizing COBOL applications. A crash in a legacy COBOL program may produce a raw operating system signal, whereas a managed COBOL program running under the Microsoft .NET CLR produces a structured exception object.

This chapter compares both error models and demonstrates how to write defensive, crash-proof COBOL code.

---

## 1. Comparing Error Models

| Feature | Managed .NET CLR (NetCOBOL) | Native Linux (GnuCOBOL) |
| :--- | :--- | :--- |
| **Error Type** | Strongly-typed class instances inheriting from `System.Exception` | OS Signals (`SIGFPE`, `SIGSEGV`) or runtime library messages (`libcob`) |
| **Null References** | Throws `System.NullReferenceException` | Segmentation fault (`SIGSEGV`) or null pointer dereference |
| **Array Out of Bounds**| Throws `System.IndexOutOfRangeException` | Detected by `libcob` with `-debug` / `-fcheck=all`; otherwise memory corruption |
| **Divide by Zero** | Throws `System.DivideByZeroException` | Triggers `ON SIZE ERROR` or sends `SIGFPE` (Floating Point Exception) |
| **Recovery Syntax** | `TRY ... CATCH (ex) ... FINALLY ... END-TRY` | `ON SIZE ERROR`, `ON OVERFLOW`, and `DECLARATIVES` (`USE AFTER EXCEPTION`) |

---

## 2. Runtime Error Detection in GnuCOBOL

By default in release builds, COBOL compilers prioritize raw execution speed and skip runtime boundary checks. If a program attempts to write past the end of a table, it silently corrupts adjacent working-storage memory.

### Enabling Runtime Safety Guards
During development and testing, always compile with:
```bash
cobc -x -free -debug MyProgram.cob -o MyProgram
# Or explicitly:
cobc -x -free -fcheck=all MyProgram.cob -o MyProgram
```

When compiled with `-debug`, GnuCOBOL injects automatic boundary checks. If an error occurs, it prints an explicit diagnostic message with the exact source file and line number before safely halting:

```text
libcob: MyProgram.cob:42: error: subscript of 'ACCOUNT-TABLE' out of bounds: 15
note: maximum subscript for 'ACCOUNT-TABLE': 10
Last statement of MyProgram was at line 42 of MyProgram.cob
```
Without `-debug`, the program would have silently overwritten memory, causing mysterious bugs hours later.

---

## 3. Handling Arithmetic Errors: `ON SIZE ERROR`

In enterprise banking and ledger processing, dividing by zero or exceeding the storage capacity of a `PIC` clause must never crash the job stream.

COBOL provides the `ON SIZE ERROR` clause for all mathematical verbs (`ADD`, `SUBTRACT`, `MULTIPLY`, `DIVIDE`, and `COMPUTE`).

### Syntax & Behavior
```cobol
       COMPUTE WS-UNIT-PRICE ROUNDED = WS-TOTAL-COST / WS-QUANTITY
           ON SIZE ERROR
               DISPLAY "[ERROR] Division by zero or decimal overflow detected!"
               MOVE 0 TO WS-UNIT-PRICE
               MOVE "ERROR_OVERFLOW" TO WS-ERROR-FLAG
           NOT ON SIZE ERROR
               MOVE "SUCCESS" TO WS-ERROR-FLAG
       END-COMPUTE.
```

### What Triggers `ON SIZE ERROR`?
1. **Division by Zero**: Any division where the denominator evaluates to zero.
2. **Decimal Truncation**: When the computed result has more integer digits than the target `PIC` clause allows (e.g., trying to store `1500.00` in `PIC 9(3)V99`).
3. **Invalid Exponentiation**: Negative numbers raised to fractional powers.

> [!IMPORTANT]
> If `ON SIZE ERROR` triggers, the target variable **retains its previous value** (it is NOT updated with a corrupted result), and execution immediately branches to the error handling block.

---

## 4. Handling String Overflows: `ON OVERFLOW`

When concatenating or splitting strings using `STRING` or `UNSTRING`, target buffer overflows are trapped using `ON OVERFLOW`:

```cobol
       STRING 
           WS-FIRST-NAME DELIMITED BY " "
           " " DELIMITED BY SIZE
           WS-LAST-NAME DELIMITED BY " "
           INTO WS-FULL-NAME
           ON OVERFLOW
               DISPLAY "[WARNING] Full name exceeded target buffer capacity!"
       END-STRING.
```

---

## 5. Structured File Error Handling: `DECLARATIVES`

In traditional procedural COBOL, checking `FILE STATUS` after every statement is required. However, for global, program-wide exception trapping, COBOL provides the `DECLARATIVES` section at the start of `PROCEDURE DIVISION`.

```cobol
       PROCEDURE DIVISION.
       DECLARATIVES.
       FILE-ERROR-HANDLER SECTION.
           USE AFTER STANDARD EXCEPTION PROCEDURE ON CUST-FILE.
       0100-HANDLE-FILE-ERROR.
           DISPLAY "[CRITICAL] File I/O failure on CUST-FILE! Status: " WS-CUST-STATUS
           EVALUATE WS-CUST-STATUS
               WHEN "35"
                   DISPLAY "Cause: Physical file not found on disk."
               WHEN "23"
                   DISPLAY "Cause: Record key not found in indexed file."
               WHEN OTHER
                   DISPLAY "Cause: Unhandled system I/O error."
           END-EVALUATE.
       END DECLARATIVES.

       0000-MAIN-LOGIC.
      *> Main program logic proceeds here...
```

---

## 6. Defensive Programming Best Practices

1. **Initialize All Numeric Fields**: Never leave `COMP-3` or `BINARY` fields uninitialized (`VALUE 0`). Reading uninitialized memory causes data exceptions (`libcob: numeric field is not numeric`).
2. **Always Wrap Divisions**: Never execute a `DIVIDE` or `COMPUTE` with variable divisors without an `ON SIZE ERROR` block.
3. **Test with `-debug` in CI/CD**: Run automated unit tests with `-debug` to catch off-by-one table boundaries before deploying to production.
4. **Log and Continue**: In batch processing, write malformed records to an error reject file and continue processing the rest of the batch rather than halting the entire pipeline.

