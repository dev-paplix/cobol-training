       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BatchOptimizer.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> EXERCISE 3 (SOLUTION): High-Throughput Batch Optimizer*
      *> Fully optimized implementation using:                *
      *> 1. Native COMP-5 register-level binary integers      *
      *> 2. Hardware INDEXED BY table displacement indexing   *
      *> 3. Compiled with -O3 aggressive optimizations        *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Account Table (5,000 Accounts) with INDEXED BY
       01  ACCOUNT-PORTFOLIO.
           05  ACCT-RECORD OCCURS 5000 TIMES INDEXED BY ACCT-IDX.
               10  ACCT-ID           PIC 9(8).
               10  ACCT-BALANCE      PIC 9(6)V99 COMP-3.
               10  ACCT-TIER         PIC X(4).

      *> Optimized COMP-5 Hardware Register Counters
       01  WS-PASS-LIMIT             PIC S9(9) COMP-5 VALUE 20.
       01  WS-PASS-CTR               PIC S9(9) COMP-5 VALUE 0.
       01  WS-INIT-CTR               PIC S9(9) COMP-5 VALUE 0.
       01  WS-TOTAL-INTEREST         PIC 9(9)V99 COMP-3 VALUE 0.

      *> Timing structures
       01  WS-TIME-RAW               PIC X(21).
       01  WS-START-HUNDS            PIC S9(9) COMP-5.
       01  WS-END-HUNDS              PIC S9(9) COMP-5.
       01  WS-ELAPSED                PIC S9(9) COMP-5.

       01  DISP-ELAPSED              PIC Z,ZZ9.
       01  DISP-INTEREST             PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "   EXERCISE 3: HIGH-THROUGHPUT BATCH OPTIMIZER    "
           DISPLAY "=================================================="

           PERFORM 1000-LOAD-PORTFOLIO
           PERFORM 2000-PROCESS-BATCH-SIMULATION
           PERFORM 3000-DISPLAY-PERFORMANCE

           DISPLAY "=================================================="
           DISPLAY "Batch processing completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-LOAD-PORTFOLIO.
           DISPLAY "[STEP 1] Loading 5,000 customer accounts..."
           PERFORM VARYING WS-INIT-CTR FROM 1 BY 1 UNTIL WS-INIT-CTR > 5000
               COMPUTE ACCT-ID (WS-INIT-CTR) = 10000000 + WS-INIT-CTR
               MOVE 2500.00 TO ACCT-BALANCE (WS-INIT-CTR)
               MOVE "CORP" TO ACCT-TIER (WS-INIT-CTR)
           END-PERFORM
           DISPLAY "[INFO] Portfolio loaded."
           DISPLAY " ".

       2000-PROCESS-BATCH-SIMULATION.
           DISPLAY "[STEP 2] Running 20 simulation iterations (100,000 accounts)..."
           PERFORM 9000-GET-HUNDS
           MOVE 0 TO WS-TOTAL-INTEREST

      *> Optimized Loop using COMP-5 and INDEXED BY
           PERFORM VARYING WS-PASS-CTR FROM 1 BY 1 UNTIL WS-PASS-CTR > WS-PASS-LIMIT
               SET ACCT-IDX TO 1
               PERFORM UNTIL ACCT-IDX > 5000
                   COMPUTE WS-TOTAL-INTEREST = WS-TOTAL-INTEREST + (ACCT-BALANCE (ACCT-IDX) * 0.005)
                   SET ACCT-IDX UP BY 1
               END-PERFORM
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-ELAPSED = WS-END-HUNDS - WS-START-HUNDS.

       3000-DISPLAY-PERFORMANCE.
           MOVE WS-ELAPSED TO DISP-ELAPSED
           MOVE WS-TOTAL-INTEREST TO DISP-INTEREST
           DISPLAY "  Total Interest Calculated : " DISP-INTEREST
           DISPLAY "  Elapsed Processing Time   : " DISP-ELAPSED " hundredths of a second."
           DISPLAY "  [OPTIMIZATION] COMP-5 and INDEXED BY eliminated ASCII conversions and address math."
           DISPLAY " ".

       9000-GET-HUNDS.
           MOVE FUNCTION CURRENT-DATE TO WS-TIME-RAW
           COMPUTE WS-START-HUNDS = 
               (FUNCTION NUMVAL(WS-TIME-RAW(9:2)) * 360000) +
               (FUNCTION NUMVAL(WS-TIME-RAW(11:2)) * 6000)  +
               (FUNCTION NUMVAL(WS-TIME-RAW(13:2)) * 100)   +
               FUNCTION NUMVAL(WS-TIME-RAW(15:2)).

       9100-GET-END-HUNDS.
           MOVE FUNCTION CURRENT-DATE TO WS-TIME-RAW
           COMPUTE WS-END-HUNDS = 
               (FUNCTION NUMVAL(WS-TIME-RAW(9:2)) * 360000) +
               (FUNCTION NUMVAL(WS-TIME-RAW(11:2)) * 6000)  +
               (FUNCTION NUMVAL(WS-TIME-RAW(13:2)) * 100)   +
               FUNCTION NUMVAL(WS-TIME-RAW(15:2)).

