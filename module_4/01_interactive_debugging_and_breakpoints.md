# Chapter 1: Interactive Debugging, Breakpoints, and Trace Logic

Diagnosing software defects in production batch jobs or transaction processors requires deep mastery of interactive debugging tools. 

Whether you are working in **Microsoft Visual Studio** (targeting NetCOBOL) or **Visual Studio Code / GDB** (targeting GnuCOBOL on Linux), the fundamental debugging paradigms—**Breakpoints, Watch Windows, Stepping, and Call Stacks**—are universal.

---

## 1. The Core Debugger Workflow

Interactive debugging pauses a running program at designated points in time, allowing you to examine the state of memory and verify that business logic executes exactly as intended.

```
       [ Edit Source ]
              │
              ▼
   [ Compile with Debug Flags ]  (e.g., cobc -g or VS Debug Profile)
              │
              ▼
       [ Set Breakpoint ]       (On critical PERFORM, IF, or COMPUTE)
              │
              ▼
       [ Launch Debugger ]      (Execution halts at breakpoint)
              │
    ┌─────────┴─────────┐
    ▼                   ▼
[ Inspect Variables ]  [ Control Execution Flow ]
(Watch / Locals)       (Step Into / Step Over / Step Out)
```

---

## 2. Stepping Logic: Step Into vs. Step Over vs. Step Out

When execution is paused at a line of code, you have three primary ways to advance:

| Action | Visual Studio Shortcut | GDB Command | VS Code Shortcut | What It Does in COBOL |
| :--- | :--- | :--- | :--- | :--- |
| **Step Into** | **F11** | `step` (`s`) | **F11** | If the line is a `PERFORM paragraph` or `CALL subprogram`, execution enters inside the target paragraph or subprogram. |
| **Step Over** | **F10** | `next` (`n`) | **F10** | Executes the line (including the entire `PERFORM` or `CALL`) as a single atomic step without stepping into its internal lines. |
| **Step Out** | **Shift+F11** | `finish` (`fin`) | **Shift+F11** | Continues execution until the current paragraph or subprogram finishes and control returns to the caller. |
| **Continue** | **F5** | `continue` (`c`) | **F5** | Resumes normal execution until the next breakpoint is hit or the program exits. |

---

## 3. Inspection Windows: Locals, Watches, and Call Stack

### The Watch Window
In both Visual Studio and VS Code, the **Watch Window** lets you specify exact variable names to monitor.
- In COBOL, watching a group item (e.g., `01 CUSTOMER-RECORD`) automatically expands to reveal all nested elementary items (`05 CUST-NAME`, `05 CUST-BALANCE`).
- Watching array items with indices (e.g., `MONTHLY-TOTAL (3)`) displays the exact element value.

### The Call Stack Window
When deeply nested `PERFORM` or `CALL` hierarchies are executed:
- The **Call Stack** lists the exact sequence of callers:
  1. `4100-CALCULATE-TAX` (Current location)
  2. `4000-PROCESS-INVOICE`
  3. `1000-MAIN-LOOP`
  4. `0000-MAIN`
- Clicking any frame in the call stack switches the editor and watch window to that scope's execution context.

---

## 4. Debugging on Linux with GDB (`cobc -g`)

GnuCOBOL compiles COBOL source code into native C, which is then compiled by GCC into machine code. By passing the `-g` flag, `cobc` generates full **DWARF debug symbols**, mapping machine instructions directly back to your COBOL source lines!

### Step 1: Compile with Debug Information
```bash
cobc -x -free -g DebuggerDemo.cob -o DebuggerDemo
```

### Step 2: Launch in GDB
```bash
gdb ./DebuggerDemo
```

### Step 3: Essential GDB Commands for COBOL
```text
(gdb) list                          # View surrounding COBOL source code
(gdb) break 1000-CALCULATE-LOAN     # Set breakpoint on a COBOL paragraph
(gdb) break DebuggerDemo.cob:45     # Set breakpoint on line 45
(gdb) run                           # Start program execution
(gdb) next                          # Step Over (F10)
(gdb) step                          # Step Into (F11)
(gdb) print WS_PRINCIPAL            # Print value of COBOL variable
(gdb) display WS_INTEREST_RATE      # Automatically display variable at every step
(gdb) backtrace                     # View Call Stack
(gdb) quit                          # Exit GDB
```

---

## 5. Source-Level Conditional Debugging Directives (`>>D`)

In enterprise COBOL, you often need diagnostic displays during testing that must automatically disappear in production without having to manually add or delete code.

COBOL standardizes **Conditional Debugging Lines**:

### In Free Format: `>>D`
```cobol
       COMPUTE WS-MONTHLY-PAYMENT ROUNDED = 
           WS-PRINCIPAL * (WS-RATE / (1 - (1 + WS-RATE) ** -WS-MONTHS))

      >>D DISPLAY "[DEBUG] Principal: " WS-PRINCIPAL " Rate: " WS-RATE
      >>D DISPLAY "[DEBUG] Calculated Payment: " WS-MONTHLY-PAYMENT
```

### How the Compiler Treats `>>D`:
- **Normal Compilation** (`cobc -x -free MyProg.cob`):
  Lines beginning with `>>D` are treated as comments and **completely ignored**! Zero CPU cycle or memory overhead.
- **Debug Compilation** (`cobc -x -free -debug MyProg.cob`):
  The compiler treats `>>D` lines as active, executable COBOL statements!

This provides a clean, zero-risk method for leaving diagnostic probes embedded in enterprise codebases.

---

## 6. Summary Checklist for Interactive Debugging

- [x] Use `F11` (Step Into) to dive into complex business paragraphs; use `F10` (Step Over) to skip known utility routines.
- [x] Always inspect the **Call Stack** when diagnosing unexpected program terminations to trace the path of invocation.
- [x] Always compile with `-g` when building development and test binaries.
- [x] Use `>>D` debugging lines for lightweight diagnostic telemetry that compiles away in release mode.

