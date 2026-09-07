# Chapter 4: Case Study — Integrating Legacy COBOL into an ASP.NET Core API

In enterprise modernization, a "rip-and-replace" strategy to rewrite proven COBOL calculation engines in C# or Java often carries astronomical costs, immense regulatory risks, and calculation divergence.

The industry-standard best practice is the **Strangler Fig / Modernization Wrapper Pattern**: preserve the audited, high-speed COBOL calculation engine as a compiled shared library and wrap it in a modern **C# ASP.NET Core REST API**.

---

## 1. The Business Scenario

**Global Mortgage Corp** processes hundreds of thousands of residential mortgage applications. Their underwriting rules—governing Debt-to-Income (DTI) thresholds, credit score risk tiers, and compound amortization—have been codified and audited in COBOL over 25 years.

### The Objective
Expose the COBOL underwriting engine to modern web, React, and mobile loan applications by wrapping it in an ASP.NET Core REST API on Linux.

---

## 2. End-to-End System Architecture

```
[ Client (Web/Mobile/React) ]
              │ HTTP POST /api/loan/evaluate (JSON Payload)
              ▼
┌────────────────────────────────────────────────────────────────┐
│ ASP.NET Core 8 Web API (Linux / Kestrel)                       │
│                                                                │
│  1. Ingest JSON request body                                   │
│  2. Validate applicant input fields                            │
│  3. Initialize COBOL runtime (cob_init)                        │
│  4. P/Invoke LoanRiskEngine(ref score, ref income, ...)        │
└───────────────────────────────┬────────────────────────────────┘
                                │ Native Call (.so)
                                ▼
┌────────────────────────────────────────────────────────────────┐
│ libLoanRiskEngine.so (Native GnuCOBOL Shared Object)           │
│                                                                │
│  - Computes Debt-To-Income (DTI) ratio                         │
│  - Determines Risk Tier (PRIME, NEAR_PRIME, SUBPRIME)          │
│  - Calculates Monthly Installment via exact compound formula   │
│  - Returns decision status                                     │
└────────────────────────────────────────────────────────────────┘
```

---

## 3. The Backend: COBOL Calculation Engine (`LoanRiskEngine.cob`)

```cobol
       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LoanRiskEngine.
       AUTHOR. Enterprise Underwriting Team.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DTI-RATIO              USAGE COMP-2.
       01  WS-TOTAL-OBLIGATION       USAGE COMP-2.
       01  WS-MONTHS                 PIC S9(9) COMP-5 VALUE 360. *> 30 Years
       01  WS-MONTHLY-RATE           USAGE COMP-2 VALUE 0.00541666. *> 6.5% Annual
       01  WS-FACTOR                 USAGE COMP-2.
       01  WS-NUMERATOR              USAGE COMP-2.
       01  WS-DENOMINATOR            USAGE COMP-2.

       LINKAGE SECTION.
       01  LK-CREDIT-SCORE           PIC S9(9) COMP-5.
       01  LK-ANNUAL-INCOME          USAGE COMP-2.
       01  LK-EXISTING-DEBT          USAGE COMP-2.
       01  LK-REQUESTED-LOAN         USAGE COMP-2.
       01  LK-DECISION               PIC X(12).
       01  LK-RISK-TIER              PIC X(10).
       01  LK-MONTHLY-PAYMENT        USAGE COMP-2.
       01  LK-CALCULATED-DTI         USAGE COMP-2.

       PROCEDURE DIVISION USING LK-CREDIT-SCORE LK-ANNUAL-INCOME 
                                LK-EXISTING-DEBT LK-REQUESTED-LOAN 
                                LK-DECISION LK-RISK-TIER 
                                LK-MONTHLY-PAYMENT LK-CALCULATED-DTI.
       0000-MAIN.
      *> Step 1: Calculate Monthly Payment (Standard 30-Year Fixed Amortization)
           COMPUTE WS-FACTOR = (1.0 + WS-MONTHLY-RATE) ** WS-MONTHS
           COMPUTE WS-NUMERATOR = WS-MONTHLY-RATE * WS-FACTOR
           COMPUTE WS-DENOMINATOR = WS-FACTOR - 1.0
           COMPUTE LK-MONTHLY-PAYMENT = LK-REQUESTED-LOAN * (WS-NUMERATOR / WS-DENOMINATOR)

      *> Step 2: Compute Debt-To-Income (DTI) Ratio
           COMPUTE WS-TOTAL-OBLIGATION = (LK-EXISTING-DEBT / 12.0) + LK-MONTHLY-PAYMENT
           COMPUTE LK-CALCULATED-DTI = (WS-TOTAL-OBLIGATION / (LK-ANNUAL-INCOME / 12.0)) * 100.0

      *> Step 3: Determine Risk Tier & Approval Decision
           IF LK-CALCULATED-DTI > 43.0 OR LK-CREDIT-SCORE < 620
               MOVE "DECLINED    " TO LK-DECISION
               MOVE "HIGH_RISK " TO LK-RISK-TIER
           ELSE IF LK-CREDIT-SCORE >= 740
               MOVE "APPROVED    " TO LK-DECISION
               MOVE "PRIME     " TO LK-RISK-TIER
           ELSE IF LK-CREDIT-SCORE >= 680
               MOVE "APPROVED    " TO LK-DECISION
               MOVE "NEAR_PRIME" TO LK-RISK-TIER
           ELSE
               MOVE "CONDITIONAL " TO LK-DECISION
               MOVE "SUBPRIME  " TO LK-RISK-TIER
           END-IF

           EXIT PROGRAM.
```

---

## 4. The Frontend: ASP.NET Core Minimal API (`Program.cs`)

```csharp
using System.Runtime.InteropServices;
using System.Text;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Initialize COBOL runtime once at application launch
CobolBridge.InitializeRuntime();

app.MapPost("/api/loan/evaluate", (LoanApplicationRequest req) =>
{
    // Validate request inputs
    if (req.AnnualIncome <= 0 || req.RequestedLoan <= 0)
    {
        return Results.BadRequest(new { error = "AnnualIncome and RequestedLoan must be positive." });
    }

    // Call COBOL Engine via P/Invoke
    var result = CobolBridge.EvaluateLoan(req);
    return Results.Ok(result);
});

app.Run();

// Data Contracts
public record LoanApplicationRequest(
    string ApplicantName,
    int CreditScore,
    double AnnualIncome,
    double ExistingDebt,
    double RequestedLoan
);

public record LoanEvaluationResponse(
    string ApplicantName,
    string Decision,
    string RiskTier,
    double MonthlyPayment,
    double DtiRatio
);

// Native Bridge
public static class CobolBridge
{
    [DllImport("libcob.so", EntryPoint = "cob_init")]
    private static extern void cob_init(int argc, IntPtr argv);

    [DllImport("libLoanRiskEngine.so", EntryPoint = "LoanRiskEngine")]
    private static extern void LoanRiskEngine(
        ref int creditScore,
        ref double annualIncome,
        ref double existingDebt,
        ref double requestedLoan,
        [In, Out] byte[] decisionBuffer,
        [In, Out] byte[] riskTierBuffer,
        ref double monthlyPayment,
        ref double dtiRatio
    );

    public static void InitializeRuntime()
    {
        cob_init(0, IntPtr.Zero);
    }

    public static LoanEvaluationResponse EvaluateLoan(LoanApplicationRequest req)
    {
        int score = req.CreditScore;
        double income = req.AnnualIncome;
        double debt = req.ExistingDebt;
        double loan = req.RequestedLoan;
        byte[] decisionBytes = new byte[12];
        byte[] riskBytes = new byte[10];
        double payment = 0.0;
        double dti = 0.0;

        LoanRiskEngine(
            ref score,
            ref income,
            ref debt,
            ref loan,
            decisionBytes,
            riskBytes,
            ref payment,
            ref dti
        );

        string decision = Encoding.ASCII.GetString(decisionBytes).Trim();
        string riskTier = Encoding.ASCII.GetString(riskBytes).Trim();

        return new LoanEvaluationResponse(
            req.ApplicantName,
            decision,
            riskTier,
            Math.Round(payment, 2),
            Math.Round(dti, 2)
        );
    }
}
```

---

## 5. Performance and Architectural Benefits

1. **Zero Code Duplication**: 100% of calculation rules stay within the verified COBOL domain.
2. **Microsecond Latency**: P/Invoke executes in the same process memory as ASP.NET Core without HTTP or TCP overhead.
3. **Container Compatibility**: Both the ASP.NET Core service and the compiled COBOL `.so` library deploy cleanly into a standard Linux container (`mcr.microsoft.com/dotnet/aspnet:8.0`).

