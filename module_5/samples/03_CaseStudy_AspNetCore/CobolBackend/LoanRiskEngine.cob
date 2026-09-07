       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LoanRiskEngine.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Mortgage Underwriting & Risk Evaluation Shared Engine *
      *> Compiled with: cobc -m -free LoanRiskEngine.cob      *
      *> Invoked by ASP.NET Core Web API via C-ABI P/Invoke.  *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-MONTHLY-RATE           USAGE COMP-2 VALUE 0.0.
       01  WS-NUM-PAYMENTS           USAGE COMP-2 VALUE 0.0.
       01  WS-FACTOR                 USAGE COMP-2 VALUE 0.0.
       01  WS-MONTHLY-INCOME         USAGE COMP-2 VALUE 0.0.
       01  WS-TOTAL-DEBT             USAGE COMP-2 VALUE 0.0.

       LINKAGE SECTION.
       01  LS-PURCHASE-PRICE         USAGE COMP-2.
       01  LS-DOWN-PAYMENT           USAGE COMP-2.
       01  LS-ANNUAL-INCOME          USAGE COMP-2.
       01  LS-MONTHLY-DEBT           USAGE COMP-2.
       01  LS-LOAN-TERM-YEARS        PIC S9(4) COMP-5.
       01  LS-INTEREST-RATE          USAGE COMP-2.

       01  LS-LOAN-AMOUNT            USAGE COMP-2.
       01  LS-LTV-RATIO              USAGE COMP-2.
       01  LS-MONTHLY-PAYMENT        USAGE COMP-2.
       01  LS-DTI-RATIO              USAGE COMP-2.
       01  LS-APPROVAL-STATUS        PIC X(12).
       01  LS-REASON-CODE            PIC X(20).

       PROCEDURE DIVISION USING LS-PURCHASE-PRICE
                                LS-DOWN-PAYMENT
                                LS-ANNUAL-INCOME
                                LS-MONTHLY-DEBT
                                LS-LOAN-TERM-YEARS
                                LS-INTEREST-RATE
                                LS-LOAN-AMOUNT
                                LS-LTV-RATIO
                                LS-MONTHLY-PAYMENT
                                LS-DTI-RATIO
                                LS-APPROVAL-STATUS
                                LS-REASON-CODE.
       0000-PROCESS-LOAN.
           MOVE 0.0 TO LS-LOAN-AMOUNT
           MOVE 0.0 TO LS-LTV-RATIO
           MOVE 0.0 TO LS-MONTHLY-PAYMENT
           MOVE 0.0 TO LS-DTI-RATIO
           MOVE SPACES TO LS-APPROVAL-STATUS
           MOVE SPACES TO LS-REASON-CODE

      *> Step 1: Loan Amount and LTV Ratio
           COMPUTE LS-LOAN-AMOUNT = LS-PURCHASE-PRICE - LS-DOWN-PAYMENT
           IF LS-PURCHASE-PRICE > 0.0
               COMPUTE LS-LTV-RATIO = (LS-LOAN-AMOUNT / LS-PURCHASE-PRICE) * 100.0
           ELSE
               MOVE 100.0 TO LS-LTV-RATIO
           END-IF

      *> Step 2: Monthly Payment Amortization
           COMPUTE WS-MONTHLY-RATE = LS-INTEREST-RATE / 12.0
           COMPUTE WS-NUM-PAYMENTS = LS-LOAN-TERM-YEARS * 12.0

           IF WS-MONTHLY-RATE > 0.0 AND WS-NUM-PAYMENTS > 0.0
               COMPUTE WS-FACTOR = (1.0 + WS-MONTHLY-RATE) ** WS-NUM-PAYMENTS
               COMPUTE LS-MONTHLY-PAYMENT = 
                   LS-LOAN-AMOUNT * (WS-MONTHLY-RATE * WS-FACTOR) / (WS-FACTOR - 1.0)
           ELSE
               IF WS-NUM-PAYMENTS > 0.0
                   COMPUTE LS-MONTHLY-PAYMENT = LS-LOAN-AMOUNT / WS-NUM-PAYMENTS
               ELSE
                   MOVE 0.0 TO LS-MONTHLY-PAYMENT
               END-IF
           END-IF

      *> Step 3: Debt-to-Income (DTI) Ratio
           COMPUTE WS-MONTHLY-INCOME = LS-ANNUAL-INCOME / 12.0
           COMPUTE WS-TOTAL-DEBT = LS-MONTHLY-DEBT + LS-MONTHLY-PAYMENT

           IF WS-MONTHLY-INCOME > 0.0
               COMPUTE LS-DTI-RATIO = (WS-TOTAL-DEBT / WS-MONTHLY-INCOME) * 100.0
           ELSE
               MOVE 100.0 TO LS-DTI-RATIO
           END-IF

      *> Step 4: Underwriting Decision Logic
           EVALUATE TRUE
               WHEN LS-LTV-RATIO > 95.0
                   MOVE "DENIED" TO LS-APPROVAL-STATUS
                   MOVE "LTV EXCEEDS 95 PCT" TO LS-REASON-CODE

               WHEN LS-DTI-RATIO > 50.0
                   MOVE "DENIED" TO LS-APPROVAL-STATUS
                   MOVE "DTI EXCEEDS 50 PCT" TO LS-REASON-CODE

               WHEN LS-DTI-RATIO > 43.0
                   MOVE "CONDITIONAL" TO LS-APPROVAL-STATUS
                   MOVE "HIGH DTI APPR REQ" TO LS-REASON-CODE

               WHEN LS-LTV-RATIO > 80.0
                   MOVE "APPROVED" TO LS-APPROVAL-STATUS
                   MOVE "PMI REQUIRED" TO LS-REASON-CODE

               WHEN OTHER
                   MOVE "APPROVED" TO LS-APPROVAL-STATUS
                   MOVE "STANDARD APPROVAL" TO LS-REASON-CODE
           END-EVALUATE

           GOBACK.
