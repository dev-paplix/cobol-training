# Module 4: Debugging and Performance Profiling

Welcome to **Module 4** of the COBOL Training Series. In mission-critical enterprise environments, writing working COBOL code is only the first half of the engineering lifecycle. The second half is ensuring that programs are **robust, diagnosable, crash-proof, and optimized for maximum throughput**.

This module bridges the debugging and performance concepts of both **Visual Studio / Microsoft .NET CLR (NetCOBOL)** and modern **Linux / open-source environments (GnuCOBOL, GDB, VS Code)**.

---

## 🎯 Learning Objectives

By completing this module, you will be able to:
1. **Master Interactive Debugging**: Set line and conditional breakpoints, inspect local and working-storage variables in watch windows, step through paragraphs (`Step Into`, `Step Over`, `Step Out`), and inspect call stacks using both Visual Studio and GDB / VS Code.
2. **Utilize Compiler Debug Directives**: Use conditional compilation directives (`>>D`, `WITH DEBUGGING MODE`) and compiler debug flags (`cobc -g`, `cobc -debug`) to output diagnostic telemetry without impacting production release binaries.
3. **Contrast Managed Exceptions with Native Runtime Errors**: Understand how the .NET CLR managed exception hierarchy (`System.Exception`, `NullReferenceException`, structured `try/catch`) compares with native COBOL runtime signals (SIGFPE, SIGSEGV), `libcob` bounds checks (`-fcheck=all`), and structured COBOL error handling (`DECLARATIVES`, `ON SIZE ERROR`).
4. **Eliminate Performance Bottlenecks**: Understand the severe CPU overhead of character-based `USAGE DISPLAY` arithmetic versus packed decimal (`COMP-3`) and register-level native binary (`COMP-5`).
5. **Optimize Tables and Data Structures**: Replace runtime-multiplied numeric subscripts (`PIC 9(4)`) with zero-overhead hardware indexing (`INDEXED BY` / `SET ... UP BY`).
6. **Leverage Compiler Optimization**: Harness GCC backend optimizations (`-O2`, `-O3`) and profile application hotspots using `gprof` (`cobc -pg`).

---

## 📂 Module Directory Layout

```text
module_4/
├── README.md                                    # Module Syllabus, Overview & Index
├── 01_interactive_debugging_and_breakpoints.md  # Guide 1: Debugging Concepts, Breakpoints, Watches & GDB
├── 02_managed_exceptions_vs_runtime_errors.md  # Guide 2: CLR Exceptions vs Native COBOL libcob Errors
├── 03_performance_profiling_and_tuning.md      # Guide 3: COMP-5, Indexing, Compiler Flags & gprof
├── 04_exercises_and_solutions.md               # Guide 4: Exercise Specs, Test Scenarios & Solution Keys
│
├── samples/                                     # Runnable Reference Implementations
│   ├── 01_Debugger/
│   │   └── DebuggerDemo.cob                     # Step-into, watch variables, and >>D debugging lines
│   ├── 02_Exceptions/
│   │   └── ExceptionDemo.cob                    # Runtime bounds checks, ON SIZE ERROR & DECLARATIVES
│   └── 03_Performance/
│       ├── DataTuningDemo.cob                   # High-speed benchmark: DISPLAY vs COMP-3 vs COMP-5
│       └── TableLookupDemo.cob                  # Benchmark: Subscripts (PIC 9) vs Indexing (INDEXED BY)
│
└── exercises/                                   # Practical Labs (Starter & Solution)
    ├── exercise_1_bug_hunt/                     # Enterprise Bug Hunt: diagnose 3 hidden runtime bugs
    │   ├── starter/
    │   └── solution/
    ├── exercise_2_resilient_calculator/         # Crash-Proof Calculator with ON SIZE ERROR recovery
    │   ├── starter/
    │   └── solution/
    └── exercise_3_performance_optimizer/        # 10x Batch Refactor (DISPLAY -> COMP-5 & Indexing)
        ├── starter/
        └── solution/
```

---

## 🧭 Learning & Lab Progression

1. **Step 1: Read the Guides**:
   - [01. Interactive Debugging & Breakpoints](file:///home/wesi/codes/cobol-training/module_4/01_interactive_debugging_and_breakpoints.md)
   - [02. Managed Exceptions vs. Runtime Errors](file:///home/wesi/codes/cobol-training/module_4/02_managed_exceptions_vs_runtime_errors.md)
   - [03. Performance Profiling & Tuning](file:///home/wesi/codes/cobol-training/module_4/03_performance_profiling_and_tuning.md)

2. **Step 2: Study and Run the Samples**:
   - Test stepping and conditional debugging in `samples/01_Debugger/`.
   - Observe exception recovery and bounds enforcement in `samples/02_Exceptions/`.
   - Run benchmarks to measure hardware-level speedups in `samples/03_Performance/`.

3. **Step 3: Complete the Practical Exercises**:
   - Follow the detailed steps in [04. Exercises and Solutions Guide](file:///home/wesi/codes/cobol-training/module_4/04_exercises_and_solutions.md).
   - Test each starter program, diagnose the bottlenecks or defects, and compare with the verified solution.

---

## ⚡ Quick Compilation & Execution Reference

### Debugging Samples
```bash
# Compile with DWARF debug info for GDB / VS Code
cd /home/wesi/codes/cobol-training/module_4/samples/01_Debugger
cobc -x -free -g DebuggerDemo.cob -o DebuggerDemo
./DebuggerDemo

# Compile with conditional debugging lines enabled
cobc -x -free -debug DebuggerDemo.cob -o DebuggerDemo_Debug
./DebuggerDemo_Debug
```

### Exception Handling Samples
```bash
# Compile and run runtime exception demo
cd /home/wesi/codes/cobol-training/module_4/samples/02_Exceptions
cobc -x -free ExceptionDemo.cob -o ExceptionDemo
./ExceptionDemo
```

### Performance Benchmarks
```bash
# Compile with maximum optimization (-O3)
cd /home/wesi/codes/cobol-training/module_4/samples/03_Performance
cobc -x -free -O3 DataTuningDemo.cob -o DataTuningDemo
./DataTuningDemo

cobc -x -free -O3 TableLookupDemo.cob -o TableLookupDemo
./TableLookupDemo
```

