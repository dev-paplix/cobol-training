       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ResilientCalc.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 2 (STARTER): Crash-Proof Financial Calc     *
      *>                                                      *
      *> Instructions:                                        *
      *> Implement robust exception handling using ON SIZE    *
      *> ERROR to prevent runtime crashes when processing     *
      *> invalid transactions (zero divisor and overflow).    *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Transaction 1: Standard Division ($50,000 / 12)
       01  TX1-AMOUNT                PIC 9(6)V99 VALUE 50000.00.
       01  TX1-DIVISOR               PIC 9(3) VALUE 12.
       01  TX1-RESULT                PIC 9(6)V99 VALUE 0.

      *> Transaction 2: Zero Divisor ($25,000 / 0)
       01  TX2-AMOUNT                PIC 9(6)V99 VALUE 25000.00.
       01  TX2-DIVISOR               PIC 9(3) VALUE 0.
       01  TX2-RESULT                PIC 9(6)V99 VALUE 0.

      *> Transaction 3: Overflow ($999,999 * 50 into PIC 9(6)V99)
       01  TX3-AMOUNT                PIC 9(6)V99 VALUE 999999.00.
       01  TX3-MULT                  PIC 9(3) VALUE 50.
       01  TX3-RESULT                PIC 9(6)V99 VALUE 0.

      *> Transaction 4: Standard Multiplication ($10,000 * 0.05)
       01  TX4-AMOUNT                PIC 9(6)V99 VALUE 10000.00.
       01  TX4-RATE                  PIC 9V99 VALUE 0.05.
       01  TX4-RESULT                PIC 9(6)V99 VALUE 0.

      *> Audit Counters
       01  WS-TOTAL-PROCESSED        PIC 9(3) VALUE 0.
       01  WS-SUCCESS-COUNT          PIC 9(3) VALUE 0.
       01  WS-ERRORS-INTERCEPTED     PIC 9(3) VALUE 0.

       01  DISP-RESULT               PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "      EXERCISE 2: CRASH-PROOF CALCULATOR          "
           DISPLAY "=================================================="

           PERFORM 1000-PROCESS-TX1
           PERFORM 2000-PROCESS-TX2
           PERFORM 3000-PROCESS-TX3
           PERFORM 4000-PROCESS-TX4
           PERFORM 5000-DISPLAY-AUDIT

           DISPLAY "=================================================="
           DISPLAY "Calculator processed all transactions safely."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-PROCESS-TX1.
           ADD 1 TO WS-TOTAL-PROCESSED
           DISPLAY "[TX 1] Calculating $50,000.00 / 12..."
      *> TODO 1: Wrap in DIVIDE ... ON SIZE ERROR ... NOT ON SIZE ERROR
           DIVIDE TX1-AMOUNT BY TX1-DIVISOR GIVING TX1-RESULT
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-INTERCEPTED
                   DISPLAY "  [ERROR] TX1 failed calculation."
               NOT ON SIZE ERROR
                   ADD 1 TO WS-SUCCESS-COUNT
                   MOVE TX1-RESULT TO DISP-RESULT
                   DISPLAY "  [PASS] Monthly Payment: " DISP-RESULT
           END-DIVIDE
           DISPLAY " ".

       2000-PROCESS-TX2.
           ADD 1 TO WS-TOTAL-PROCESSED
           DISPLAY "[TX 2] Calculating $25,000.00 / 0 (Zero Divisor)..."
      *> TODO 2: Wrap in DIVIDE ... ON SIZE ERROR to trap division by zero
           DIVIDE TX2-AMOUNT BY TX2-DIVISOR GIVING TX2-RESULT
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-INTERCEPTED
                   DISPLAY "  [TRAPPED] Division by zero intercepted safely. Result set to $0.00."
                   MOVE 0 TO TX2-RESULT
               NOT ON SIZE ERROR
                   ADD 1 TO WS-SUCCESS-COUNT
                   MOVE TX2-RESULT TO DISP-RESULT
                   DISPLAY "  [UNEXPECTED] Result: " DISP-RESULT
           END-DIVIDE
           DISPLAY " ".

       3000-PROCESS-TX3.
           ADD 1 TO WS-TOTAL-PROCESSED
           DISPLAY "[TX 3] Calculating $999,999.00 * 50 (Arithmetic Overflow)..."
      *> TODO 3: Trap capacity overflow using ON SIZE ERROR
           MULTIPLY TX3-AMOUNT BY TX3-MULT GIVING TX3-RESULT
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-INTERCEPTED
                   DISPLAY "  [TRAPPED] Capacity overflow intercepted (target cannot fit 50M)."
                   MOVE 0 TO TX3-RESULT
               NOT ON SIZE ERROR
                   ADD 1 TO WS-SUCCESS-COUNT
                   MOVE TX3-RESULT TO DISP-RESULT
                   DISPLAY "  [UNEXPECTED] Result: " DISP-RESULT
           END-MULTIPLY
           DISPLAY " ".

       4000-PROCESS-TX4.
           ADD 1 TO WS-TOTAL-PROCESSED
           DISPLAY "[TX 4] Calculating $10,000.00 * 0.05..."
      *> TODO 4: Calculate safely with ON SIZE ERROR
           MULTIPLY TX4-AMOUNT BY TX4-RATE GIVING TX4-RESULT
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-INTERCEPTED
                   DISPLAY "  [ERROR] TX4 calculation failed."
               NOT ON SIZE ERROR
                   ADD 1 TO WS-SUCCESS-COUNT
                   MOVE TX4-RESULT TO DISP-RESULT
                   DISPLAY "  [PASS] Commission Fee: " DISP-RESULT
           END-MULTIPLY
           DISPLAY " ".

       5000-DISPLAY-AUDIT.
           DISPLAY "--------------------------------------------------"
           DISPLAY "TRANSACTION AUDIT SUMMARY                         "
           DISPLAY "--------------------------------------------------"
           DISPLAY "Total Transactions Evaluated : " WS-TOTAL-PROCESSED
           DISPLAY "Successful Calculations      : " WS-SUCCESS-COUNT
           DISPLAY "Degenerate Errors Trapped    : " WS-ERRORS-INTERCEPTED
           DISPLAY "Application Crashes          : 0".

