# Chapter 4: Practical Exercises & Solution Guide

This guide provides the specifications, requirements, sample test scenarios, and compilation instructions for the three practical exercises in **Module 4**.

---

## Exercise 1: The Enterprise Bug Hunt
**Directory**: `exercises/exercise_1_bug_hunt/`

### Scenario
An enterprise payroll batch job (`BugHunt.cob`) has been crashing intermittently in production. The operations team reported a fatal termination, but the stack trace is unclear.

### Defects to Locate & Fix
1. **Bug 1: Array Boundary Violation**: A monthly sales commission table with 12 elements is accessed with an index of 13 during quarter-end processing.
2. **Bug 2: Uninitialized Computational Field**: A packed decimal accumulator is read without an initial `VALUE 0`, leading to corrupted data.
3. **Bug 3: Unprotected Division by Zero**: Departmental bonus distribution divides the total bonus pool by the department headcount. When a newly created department with 0 employees is evaluated, the program halts.

### Diagnostic Instructions
Compile the starter code with `-debug`:
```bash
cobc -x -free -debug BugHunt.cob -o BugHunt
./BugHunt
```
Observe the explicit `libcob` diagnostics, fix each defect, and verify clean execution with code 0.

---

## Exercise 2: Crash-Proof Financial Calculator
**Directory**: `exercises/exercise_2_resilient_calculator/`

### Scenario
A web-facing transaction processing service accepts financial calculations from external clients. External payloads frequently contain malformed numbers, zero divisors, or astronomical sums designed to crash the system.

### Specifications
1. **Input Payload Processing**:
   - The program evaluates 4 test cases:
     - Case 1: Valid calculation (`$50,000 / 12 months`).
     - Case 2: Division by zero (`$25,000 / 0 months`).
     - Case 3: Decimal capacity overflow (Attempting to compute `$999,999 * 50` into a `PIC 9(6)V99` target).
     - Case 4: Valid calculation (`$10,000 * 1.05`).
2. **Resilience Requirements**:
   - All computations must use `ON SIZE ERROR` and `NOT ON SIZE ERROR`.
   - On error, the program must log the specific error condition (`DIVIDE_BY_ZERO` or `SIZE_OVERFLOW`), retain data integrity, and proceed to the next transaction.
   - The program must complete with exit code 0 and an audit summary.

### Compilation & Test
```bash
cd exercises/exercise_2_resilient_calculator/solution
cobc -x -free ResilientCalc.cob -o ResilientCalc
./ResilientCalc
```

---

## Exercise 3: High-Throughput Batch Optimizer
**Directory**: `exercises/exercise_3_performance_optimizer/`

### Scenario
A nightly batch interest calculation program processes a portfolio table of 10,000 accounts over 20 simulation iterations (200,000 total record evaluations). The legacy program is written with `USAGE DISPLAY` counters and numeric subscripts, causing excessive CPU consumption.

### Optimization Requirements
1. **Data Model Refactoring**:
   - Change loop counters, iteration variables, and accumulator variables from `PIC 9(8) DISPLAY` to `PIC S9(9) COMP-5`.
2. **Table Navigation Optimization**:
   - Replace numeric subscripts (`ACCT-TABLE (WS-SUB)`) with hardware-indexed access (`ACCT-TABLE (ACCT-IDX)` using `INDEXED BY ACCT-IDX` and `SET ACCT-IDX UP BY 1`).
3. **Compiler Optimization**:
   - Compile using `-O3` to enable GCC loop unrolling and register optimization.
4. **Verification**:
   - Measure and output elapsed time or throughput, proving a dramatic reduction in CPU cycle time.

### Compilation & Test
```bash
cd exercises/exercise_3_performance_optimizer/solution
cobc -x -free -O3 BatchOptimizer.cob -o BatchOptimizer
./BatchOptimizer
```

