       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BatchOptimizer.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 3 (STARTER): High-Throughput Batch Optimizer*
      *>                                                      *
      *> Instructions:                                        *
      *> 1. Refactor DISPLAY counters to COMP-5               *
      *> 2. Refactor table subscripting to INDEXED BY         *
      *> 3. Compile with -O3 optimization                     *
      *> 4. Measure the throughput gain                       *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Account Table (5,000 Accounts)
       01  ACCOUNT-PORTFOLIO.
           05  ACCT-RECORD OCCURS 5000 TIMES.
               10  ACCT-ID           PIC 9(8).
               10  ACCT-BALANCE      PIC 9(6)V99 COMP-3.
               10  ACCT-TIER         PIC X(4).

      *> Legacy DISPLAY Counters (Slow CPU conversions!)
      *> TODO 1: Refactor these to PIC S9(9) COMP-5
       01  WS-PASS-LIMIT             PIC 9(3) VALUE 20.
       01  WS-PASS-CTR               PIC 9(3) VALUE 0.
       01  WS-ACCT-CTR               PIC 9(5) VALUE 0.
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
           PERFORM VARYING WS-ACCT-CTR FROM 1 BY 1 UNTIL WS-ACCT-CTR > 5000
               COMPUTE ACCT-ID (WS-ACCT-CTR) = 10000000 + WS-ACCT-CTR
               MOVE 2500.00 TO ACCT-BALANCE (WS-ACCT-CTR)
               MOVE "CORP" TO ACCT-TIER (WS-ACCT-CTR)
           END-PERFORM
           DISPLAY "[INFO] Portfolio loaded."
           DISPLAY " ".

       2000-PROCESS-BATCH-SIMULATION.
           DISPLAY "[STEP 2] Running 20 simulation iterations (100,000 accounts)..."
           PERFORM 9000-GET-HUNDS
           MOVE 0 TO WS-TOTAL-INTEREST

      *> Batch Simulation Loop
           PERFORM VARYING WS-PASS-CTR FROM 1 BY 1 UNTIL WS-PASS-CTR > WS-PASS-LIMIT
               PERFORM VARYING WS-ACCT-CTR FROM 1 BY 1 UNTIL WS-ACCT-CTR > 5000
                   COMPUTE WS-TOTAL-INTEREST = WS-TOTAL-INTEREST + (ACCT-BALANCE (WS-ACCT-CTR) * 0.005)
               END-PERFORM
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-ELAPSED = WS-END-HUNDS - WS-START-HUNDS.

       3000-DISPLAY-PERFORMANCE.
           MOVE WS-ELAPSED TO DISP-ELAPSED
           MOVE WS-TOTAL-INTEREST TO DISP-INTEREST
           DISPLAY "  Total Interest Calculated : " DISP-INTEREST
           DISPLAY "  Elapsed Processing Time   : " DISP-ELAPSED " hundredths of a second."
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
