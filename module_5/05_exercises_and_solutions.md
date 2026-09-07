# Chapter 5: Practical Exercises & Solution Guide

This guide provides the specifications, requirements, sample test scenarios, and compilation instructions for the three practical exercises in **Module 5**.

---

## Exercise 1: C# to COBOL Calculation Interop
**Directory**: `exercises/exercise_1_csharp_to_cobol_interop/`

### Scenario
An e-commerce checkout engine in C# needs to calculate cart discounts and taxes using a legacy COBOL rating subprogram (`TaxEngine.cob`).

### Specifications
1. **COBOL Subprogram (`TaxEngine.cob`)**:
   - Accepts parameters:
     - `LK-SUBTOTAL`: `USAGE COMP-2` (Cart subtotal).
     - `LK-TIER`: `PIC X(8)` (`"GOLD"`, `"SILVER"`, or `"STANDARD"`).
     - `LK-DISCOUNT-AMT`: `USAGE COMP-2` (Output discount).
     - `LK-TAX-AMT`: `USAGE COMP-2` (Output 8.25% sales tax).
     - `LK-FINAL-TOTAL`: `USAGE COMP-2` (Output final total).
   - Rules:
     - `"GOLD"` customers receive 15% discount (`subtotal * 0.15`).
     - `"SILVER"` customers receive 10% discount (`subtotal * 0.10`).
     - Tax is 8.25% applied to the discounted subtotal.
     - Final Total is `(Subtotal - Discount) + Tax`.
2. **C# Consumer (`Program.cs`)**:
   - Initializes `libcob` runtime.
   - Declares P/Invoke signature for `TaxEngine`.
   - Tests all 3 customer tiers and prints formatted receipts.

### Compilation & Test
```bash
cd exercises/exercise_1_csharp_to_cobol_interop/solution
cobc -m -free TaxEngine.cob -o libTaxEngine.so
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH dotnet run
```

---

## Exercise 2: COBOL Batch Calling C# Native AOT
**Directory**: `exercises/exercise_2_cobol_calling_dotnet/`

### Scenario
An enterprise COBOL batch payroll reconciliation program needs to validate banking account numbers using modern C# utility methods.

### Specifications
1. **C# Library (`DotNetValidator.cs`)**:
   - Compiled with Native AOT to a shared object (`.so`).
   - Exports two entry points:
     - `ValidateAccountNumber(int acctNum)`: returns 1 if account passes modulo-7 checksum, else 0.
     - `CalculateProcessingFee(double amount)`: returns standard 1.75% transaction fee.
2. **COBOL Driver (`BatchDriver.cob`)**:
   - Invokes `ValidateAccountNumber` and `CalculateProcessingFee` via standard COBOL `CALL` statements.
   - Processes a batch of 3 accounts and generates an audit log.

### Compilation & Test
```bash
cd exercises/exercise_2_cobol_calling_dotnet/solution/DotNetLib
dotnet publish -c Release -r linux-x64
cd ..
cobc -x -free -fstatic-call BatchDriver.cob \
     -LDotNetLib/bin/Release/net8.0/linux-x64/publish \
     -l:DotNetLib.so -o BatchDriver
LD_LIBRARY_PATH=DotNetLib/bin/Release/net8.0/linux-x64/publish:$LD_LIBRARY_PATH ./BatchDriver
```

---

## Exercise 3: ASP.NET Core Microservice with COBOL Backend
**Directory**: `exercises/exercise_3_aspnet_cobol_microservice/`

### Scenario
An insurance corporation modernizes its underwriting frontend by building an ASP.NET Core Web Service that delegates actuarial risk assessment to a COBOL shared library (`InsuranceRatingEngine.cob`).

### Specifications
1. **COBOL Rating Engine (`InsuranceRatingEngine.cob`)**:
   - Evaluates:
     - Driver Age (`PIC S9(9) COMP-5`).
     - Prior Violations (`PIC S9(9) COMP-5`).
     - Base Premium (`USAGE COMP-2`).
     - Calculated Annual Premium (`USAGE COMP-2`).
     - Risk Rating (`PIC X(12)`: `"LOW_RISK"`, `"STANDARD"`, `"HIGH_RISK"`).
2. **ASP.NET Core Web Service**:
   - End-to-end integration exposing the calculation through a clean C# service wrapper.
   - Evaluates 3 test profiles and outputs formatted JSON results.

### Compilation & Test
```bash
cd exercises/exercise_3_aspnet_cobol_microservice/solution/Backend
cobc -m -free InsuranceRatingEngine.cob -o libInsuranceRatingEngine.so
cd ../WebApi
LD_LIBRARY_PATH=../Backend:$LD_LIBRARY_PATH dotnet run
```

