       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DebuggerDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates interactive debugging and conditional   *
      *> debugging directives (>>D) in GnuCOBOL.              *
      *>                                                      *
      *> Compile normally:                                    *
      *>   cobc -x -free DebuggerDemo.cob -o DebuggerDemo     *
      *>   (>>D lines are ignored as comments)                *
      *>                                                      *
      *> Compile with debug mode:                             *
      *>   cobc -x -free -fdebugging-line DebuggerDemo.cob -o DebuggerDemo *
      *>   (>>D lines are active and print diagnostics)       *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Loan Input Parameters
       01  WS-PRINCIPAL              PIC 9(7)V99 VALUE 250000.00.
       01  WS-ANNUAL-RATE            PIC 9V9999 VALUE 0.0650.
       01  WS-YEARS                  PIC 9(2) VALUE 15.

      *> Internal Calculation Variables
       01  WS-MONTHS                 PIC 9(4) COMP-5 VALUE 0.
       01  WS-MONTHLY-RATE           USAGE COMP-2 VALUE 0.0.
       01  WS-MONTHLY-PAYMENT        PIC 9(6)V99 VALUE 0.
       01  WS-TOTAL-PAYMENTS         PIC 9(8)V99 VALUE 0.
       01  WS-TOTAL-INTEREST         PIC 9(8)V99 VALUE 0.

      *> Temporary Power Calculation Fields
       01  WS-FACTOR                 USAGE COMP-2 VALUE 0.0.
       01  WS-NUMERATOR              USAGE COMP-2 VALUE 0.0.
       01  WS-DENOMINATOR            USAGE COMP-2 VALUE 0.0.
       01  WS-PAYMENT-CALC           USAGE COMP-2 VALUE 0.0.

      *> Formatted Display Fields
       01  DISP-PRINCIPAL            PIC $$$,$$$,$$9.99.
       01  DISP-PAYMENT              PIC $$$,$$9.99.
       01  DISP-TOTAL-PAID           PIC $$$,$$$,$$9.99.
       01  DISP-TOTAL-INT            PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "      INTERACTIVE DEBUGGER & >>D TRACE DEMO       "
           DISPLAY "=================================================="

           PERFORM 1000-INITIALIZE
           PERFORM 2000-CALCULATE-PAYMENT
           PERFORM 3000-CALCULATE-TOTALS
           PERFORM 4000-DISPLAY-SUMMARY

           DISPLAY "=================================================="
           DISPLAY "Debugger demo execution completed."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-INITIALIZE.
           MOVE WS-PRINCIPAL TO DISP-PRINCIPAL
           DISPLAY "[INFO] Evaluating Mortgage Loan:"
           DISPLAY "  Principal Amount : " DISP-PRINCIPAL
           DISPLAY "  Annual Interest  : 6.50%"
           DISPLAY "  Loan Term (Years): " WS-YEARS
           DISPLAY " "

           COMPUTE WS-MONTHS = WS-YEARS * 12
           COMPUTE WS-MONTHLY-RATE = WS-ANNUAL-RATE / 12.0.

      >>D  DISPLAY "[DEBUG >>D] 1000-INITIALIZE completed."
      >>D  DISPLAY "[DEBUG >>D] Months: " WS-MONTHS
      >>D  DISPLAY "[DEBUG >>D] Monthly Rate: " WS-MONTHLY-RATE.

       2000-CALCULATE-PAYMENT.
      *> Amortization formula: P * (r * (1+r)^n) / ((1+r)^n - 1)
           COMPUTE WS-FACTOR = (1.0 + WS-MONTHLY-RATE) ** WS-MONTHS
           COMPUTE WS-NUMERATOR = WS-MONTHLY-RATE * WS-FACTOR
           COMPUTE WS-DENOMINATOR = WS-FACTOR - 1.0
           COMPUTE WS-PAYMENT-CALC = WS-PRINCIPAL * (WS-NUMERATOR / WS-DENOMINATOR)

           COMPUTE WS-MONTHLY-PAYMENT ROUNDED = WS-PAYMENT-CALC.

      >>D  DISPLAY "[DEBUG >>D] 2000-CALCULATE-PAYMENT:"
      >>D  DISPLAY "[DEBUG >>D] Compounding Factor: " WS-FACTOR
      >>D  DISPLAY "[DEBUG >>D] Raw Monthly Payment: " WS-PAYMENT-CALC
      >>D  DISPLAY "[DEBUG >>D] Rounded Monthly Payment: " WS-MONTHLY-PAYMENT.

       3000-CALCULATE-TOTALS.
           COMPUTE WS-TOTAL-PAYMENTS = WS-MONTHLY-PAYMENT * WS-MONTHS
           COMPUTE WS-TOTAL-INTEREST = WS-TOTAL-PAYMENTS - WS-PRINCIPAL.

      >>D  DISPLAY "[DEBUG >>D] 3000-CALCULATE-TOTALS:"
      >>D  DISPLAY "[DEBUG >>D] Total Amount to Repay: " WS-TOTAL-PAYMENTS
      >>D  DISPLAY "[DEBUG >>D] Lifetime Interest Cost: " WS-TOTAL-INTEREST.

       4000-DISPLAY-SUMMARY.
           MOVE WS-MONTHLY-PAYMENT TO DISP-PAYMENT
           MOVE WS-TOTAL-PAYMENTS TO DISP-TOTAL-PAID
           MOVE WS-TOTAL-INTEREST TO DISP-TOTAL-INT

           DISPLAY "--------------------------------------------------"
           DISPLAY "MONTHLY PAYMENT SCHEDULE RESULT"
           DISPLAY "--------------------------------------------------"
           DISPLAY "Required Monthly Payment: " DISP-PAYMENT
           DISPLAY "Total Amount Paid (180m): " DISP-TOTAL-PAID
           DISPLAY "Total Interest Paid     : " DISP-TOTAL-INT.
