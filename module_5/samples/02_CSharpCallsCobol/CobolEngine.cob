       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CobolEngine.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Credit Assessment Engine shared library.            *
      *> Compiled with: cobc -m -free CobolEngine.cob        *
      *> Called from C# via P/Invoke [DllImport].            *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-MAX-ALLOWABLE          USAGE COMP-2 VALUE 0.0.
       01  WS-CALCULATED-LIMIT       USAGE COMP-2 VALUE 0.0.

       LINKAGE SECTION.
       01  LS-CREDIT-SCORE           PIC S9(9) COMP-5.
       01  LS-MONTHLY-INCOME         USAGE COMP-2.
       01  LS-EXISTING-DEBT          USAGE COMP-2.
       01  LS-APPROVED-LIMIT         USAGE COMP-2.
       01  LS-RISK-CODE              PIC X(10).

       PROCEDURE DIVISION USING LS-CREDIT-SCORE
                                LS-MONTHLY-INCOME
                                LS-EXISTING-DEBT
                                LS-APPROVED-LIMIT
                                LS-RISK-CODE.
       0000-EVALUATE-CREDIT.
           MOVE 0.0 TO LS-APPROVED-LIMIT
           MOVE SPACES TO LS-RISK-CODE

           EVALUATE TRUE
               WHEN LS-CREDIT-SCORE < 580
                   MOVE 0.0 TO LS-APPROVED-LIMIT
                   MOVE "SUBPRIME" TO LS-RISK-CODE

               WHEN LS-CREDIT-SCORE >= 580 AND LS-CREDIT-SCORE < 670
                   COMPUTE WS-MAX-ALLOWABLE = LS-MONTHLY-INCOME * 1.5
                   COMPUTE WS-CALCULATED-LIMIT = WS-MAX-ALLOWABLE - LS-EXISTING-DEBT
                   IF WS-CALCULATED-LIMIT > 0.0
                       MOVE WS-CALCULATED-LIMIT TO LS-APPROVED-LIMIT
                       MOVE "HIGH-RISK" TO LS-RISK-CODE
                   ELSE
                       MOVE 0.0 TO LS-APPROVED-LIMIT
                       MOVE "OVERLEVER" TO LS-RISK-CODE
                   END-IF

               WHEN LS-CREDIT-SCORE >= 670 AND LS-CREDIT-SCORE < 740
                   COMPUTE WS-MAX-ALLOWABLE = LS-MONTHLY-INCOME * 3.0
                   COMPUTE WS-CALCULATED-LIMIT = WS-MAX-ALLOWABLE - LS-EXISTING-DEBT
                   IF WS-CALCULATED-LIMIT > 0.0
                       MOVE WS-CALCULATED-LIMIT TO LS-APPROVED-LIMIT
                       MOVE "MODERATE" TO LS-RISK-CODE
                   ELSE
                       MOVE 0.0 TO LS-APPROVED-LIMIT
                       MOVE "OVERLEVER" TO LS-RISK-CODE
                   END-IF

               WHEN OTHER
                   COMPUTE WS-MAX-ALLOWABLE = LS-MONTHLY-INCOME * 5.0
                   COMPUTE WS-CALCULATED-LIMIT = WS-MAX-ALLOWABLE - LS-EXISTING-DEBT
                   IF WS-CALCULATED-LIMIT > 0.0
                       MOVE WS-CALCULATED-LIMIT TO LS-APPROVED-LIMIT
                       MOVE "PRIME" TO LS-RISK-CODE
                   ELSE
                       MOVE 0.0 TO LS-APPROVED-LIMIT
                       MOVE "OVERLEVER" TO LS-RISK-CODE
                   END-IF
           END-EVALUATE

           GOBACK.
