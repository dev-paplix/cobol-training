# Chapter 2: Exposing COBOL Logic as Shared Libraries for .NET Front-Ends

One of the most valuable modernization strategies is encapsulating battle-tested COBOL calculations into reusable shared libraries (`.so` on Linux, `.dll` on Windows) that can be consumed directly by C# ASP.NET Core APIs, MAUI mobile backends, and desktop front-ends.

This chapter details how to compile COBOL modules into shared libraries, call them from C# via Platform Invoke (P/Invoke), and manage runtime initialization.

---

## 1. Architectural Architecture

```
┌────────────────────────────────────────────────────────┐
│ C# .NET 8 Host Application (ASP.NET Core / Console)   │
│                                                        │
│  1. DllImport("libcob.so") ──► cob_init(0, IntPtr.Zero)│
│                                                        │
│  2. DllImport("libCreditEngine.so")                    │
│     ──► CreditEngine(ref score, ref limit, ref status) │
└──────────────────────────┬─────────────────────────────┘
                           │ P/Invoke (Native Call)
                           ▼
┌────────────────────────────────────────────────────────┐
│ libCreditEngine.so (Compiled with cobc -m)             │
│                                                        │
│  PROCEDURE DIVISION USING LK-SCORE LK-LIMIT LK-STATUS  │
│  * Executes pure native business calculation rules     │
│  EXIT PROGRAM                                          │
└────────────────────────────────────────────────────────┘
```

---

## 2. Writing the Reusable COBOL Subprogram

The COBOL program accepts parameters in its `LINKAGE SECTION` and terminates with `EXIT PROGRAM` (instead of `STOP RUN`, which would terminate the entire host process!).

```cobol
       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CreditScoreEngine.
       AUTHOR. COBOL Modernization Series.

       DATA DIVISION.
       LINKAGE SECTION.
       01  LK-CREDIT-SCORE           PIC S9(9) COMP-5.
       01  LK-ANNUAL-INCOME          USAGE COMP-2.
       01  LK-CREDIT-LIMIT           USAGE COMP-2.
       01  LK-APPROVAL-STATUS        PIC X(10).

       PROCEDURE DIVISION USING LK-CREDIT-SCORE LK-ANNUAL-INCOME 
                                LK-CREDIT-LIMIT LK-APPROVAL-STATUS.
       0000-MAIN.
           IF LK-CREDIT-SCORE >= 720
               COMPUTE LK-CREDIT-LIMIT = LK-ANNUAL-INCOME * 0.35
               MOVE "APPROVED  " TO LK-APPROVAL-STATUS
           ELSE IF LK-CREDIT-SCORE >= 650
               COMPUTE LK-CREDIT-LIMIT = LK-ANNUAL-INCOME * 0.20
               MOVE "CONDITIONAL" TO LK-APPROVAL-STATUS
           ELSE
               MOVE 0.0 TO LK-CREDIT-LIMIT
               MOVE "REJECTED  " TO LK-APPROVAL-STATUS
           END-IF

           EXIT PROGRAM.
```

### Compiling to Shared Object (`.so`)
```bash
cobc -m -free CreditScoreEngine.cob -o libCreditScoreEngine.so
```
The `-m` flag instructs GnuCOBOL to generate a dynamically loadable C shared module.

---

## 3. The Mandatory Runtime Initialization: `cob_init()`

When a standalone COBOL executable runs, the COBOL startup code automatically initializes `libcob` (the GnuCOBOL runtime library). 

However, when C# loads a COBOL `.so` dynamically, `libcob` is uninitialized. Attempting to call the COBOL function directly will abort with:
```text
libcob: error: cob_init() has not been called
```

### The C# Initialization Solution
Import `cob_init` from `libcob.so` and call it once before invoking any COBOL functions:

```csharp
using System;
using System.Runtime.InteropServices;

public static class CobolRuntime
{
    [DllImport("libcob.so", EntryPoint = "cob_init")]
    private static extern void cob_init(int argc, IntPtr argv);

    private static bool _initialized = false;
    private static readonly object _lock = new object();

    public static void Initialize()
    {
        if (!_initialized)
        {
            lock (_lock)
            {
                if (!_initialized)
                {
                    cob_init(0, IntPtr.Zero);
                    _initialized = true;
                }
            }
        }
    }
}
```

---

## 4. C# P/Invoke Parameter Mapping

In COBOL, parameters in `PROCEDURE DIVISION USING` are passed **by reference** (pointers to memory).

| COBOL Type | Memory Size | C# P/Invoke Declaration | Passing Direction |
| :--- | :--- | :--- | :--- |
| `PIC S9(9) COMP-5` | 4 bytes (32-bit int) | `ref int` | In / Out |
| `PIC S9(18) COMP-5` | 8 bytes (64-bit int) | `ref long` | In / Out |
| `USAGE COMP-2` | 8 bytes (IEEE double)| `ref double` | In / Out |
| `PIC X(10)` | 10 ASCII bytes | `byte[]` (Length 10) | In / Out buffer |

### C# P/Invoke Declaration
```csharp
public static class CreditEngineBridge
{
    [DllImport("libCreditScoreEngine.so", EntryPoint = "CreditScoreEngine")]
    public static extern void CreditScoreEngine(
        ref int creditScore,
        ref double annualIncome,
        ref double creditLimit,
        [In, Out] byte[] statusBuffer
    );
}
```

### Complete C# Consumer
```csharp
class Program
{
    static void Main()
    {
        // 1. Initialize COBOL runtime
        CobolRuntime.Initialize();

        // 2. Prepare inputs
        int score = 740;
        double income = 85000.00;
        double approvedLimit = 0.0;
        byte[] statusBytes = new byte[10];

        // 3. Call native COBOL calculation engine
        CreditEngineBridge.CreditScoreEngine(
            ref score, 
            ref income, 
            ref approvedLimit, 
            statusBytes
        );

        string status = System.Text.Encoding.ASCII.GetString(statusBytes).Trim();
        Console.WriteLine($"Result from COBOL: Status={status}, Approved Limit=${approvedLimit:N2}");
    }
}
```

---

## 5. Thread Safety and Best Practices

1. **Use Reentrant Code**: Avoid modifying global `WORKING-STORAGE` variables across multiple simultaneous threads in the COBOL library. For multi-threaded ASP.NET Core web services, maintain all state in the `LINKAGE SECTION`.
2. **Use `EXIT PROGRAM`**: Always exit subprograms with `EXIT PROGRAM`. Never use `STOP RUN`, which would kill the hosting .NET process!
3. **Fixed Buffer Encoding**: Use `Encoding.ASCII.GetString()` and `Trim()` when converting COBOL `PIC X` space-padded character arrays to C# strings.

