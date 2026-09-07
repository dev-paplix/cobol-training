       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DataTuningDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> High-Performance Benchmark comparing 1,000,000      *
      *> arithmetic operations across:                        *
      *> 1. USAGE DISPLAY  (ASCII text - slow)                *
      *> 2. USAGE COMP-3   (Packed Decimal - medium)          *
      *> 3. USAGE COMP-5   (Native 32-bit binary - fastest)   *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Test Variables
       01  WS-DISPLAY-ACC            PIC 9(8) VALUE 0.
       01  WS-COMP3-ACC              PIC S9(7)V99 COMP-3 VALUE 0.
       01  WS-COMP5-ACC              PIC S9(9) COMP-5 VALUE 0.

      *> Loop Controls
       01  WS-ITERATIONS             PIC S9(9) COMP-5 VALUE 1000000.
       01  WS-LOOP-IDX               PIC S9(9) COMP-5 VALUE 0.

      *> Timing Structures (Hundredths of a second)
       01  WS-TIME-RAW               PIC X(21).
       01  WS-START-HUNDS            PIC S9(9) COMP-5.
       01  WS-END-HUNDS              PIC S9(9) COMP-5.
       01  WS-ELAPSED-DISP           PIC S9(9) COMP-5.
       01  WS-ELAPSED-COMP3          PIC S9(9) COMP-5.
       01  WS-ELAPSED-COMP5          PIC S9(9) COMP-5.

       01  DISP-TIME                 PIC Z,ZZ9.
       01  DISP-ITERS                PIC Z,ZZZ,ZZ9.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "   COBOL DATA REPRESENTATION PERFORMANCE BENCH    "
           DISPLAY "=================================================="
           MOVE WS-ITERATIONS TO DISP-ITERS
           DISPLAY "Executing " DISP-ITERS " arithmetic increments per format..."
           DISPLAY " "

           PERFORM 1000-BENCHMARK-DISPLAY
           PERFORM 2000-BENCHMARK-COMP3
           PERFORM 3000-BENCHMARK-COMP5
           PERFORM 4000-DISPLAY-COMPARISON

           DISPLAY "=================================================="
           DISPLAY "Benchmark execution completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-BENCHMARK-DISPLAY.
           DISPLAY "[TEST 1] Running USAGE DISPLAY (ASCII Character Arithmetic)..."
           PERFORM 9000-GET-HUNDS
           MOVE WS-START-HUNDS TO WS-START-HUNDS

           MOVE 0 TO WS-DISPLAY-ACC
           PERFORM VARYING WS-LOOP-IDX FROM 1 BY 1 UNTIL WS-LOOP-IDX > WS-ITERATIONS
               ADD 1 TO WS-DISPLAY-ACC
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-ELAPSED-DISP = WS-END-HUNDS - WS-START-HUNDS
           MOVE WS-ELAPSED-DISP TO DISP-TIME
           DISPLAY "  Result : " WS-DISPLAY-ACC " | Elapsed: " DISP-TIME " hundredths of a sec."
           DISPLAY " ".

       2000-BENCHMARK-COMP3.
           DISPLAY "[TEST 2] Running USAGE COMP-3 (Packed Decimal / BCD)..."
           PERFORM 9000-GET-HUNDS

           MOVE 0 TO WS-COMP3-ACC
           PERFORM VARYING WS-LOOP-IDX FROM 1 BY 1 UNTIL WS-LOOP-IDX > WS-ITERATIONS
               ADD 1 TO WS-COMP3-ACC
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-ELAPSED-COMP3 = WS-END-HUNDS - WS-START-HUNDS
           MOVE WS-ELAPSED-COMP3 TO DISP-TIME
           DISPLAY "  Result : " WS-COMP3-ACC " | Elapsed: " DISP-TIME " hundredths of a sec."
           DISPLAY " ".

       3000-BENCHMARK-COMP5.
           DISPLAY "[TEST 3] Running USAGE COMP-5 (Native 32-bit Register Binary)..."
           PERFORM 9000-GET-HUNDS

           MOVE 0 TO WS-COMP5-ACC
           PERFORM VARYING WS-LOOP-IDX FROM 1 BY 1 UNTIL WS-LOOP-IDX > WS-ITERATIONS
               ADD 1 TO WS-COMP5-ACC
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-ELAPSED-COMP5 = WS-END-HUNDS - WS-START-HUNDS
           MOVE WS-ELAPSED-COMP5 TO DISP-TIME
           DISPLAY "  Result : " WS-COMP5-ACC " | Elapsed: " DISP-TIME " hundredths of a sec."
           DISPLAY " ".

       4000-DISPLAY-COMPARISON.
           DISPLAY "--------------------------------------------------"
           DISPLAY "PERFORMANCE SUMMARY (1,000,000 INCR OPERATIONS)  "
           DISPLAY "--------------------------------------------------"
           MOVE WS-ELAPSED-DISP TO DISP-TIME
           DISPLAY "1. USAGE DISPLAY (ASCII)   : " DISP-TIME " hundredths of a sec"
           MOVE WS-ELAPSED-COMP3 TO DISP-TIME
           DISPLAY "2. USAGE COMP-3 (Packed)   : " DISP-TIME " hundredths of a sec"
           MOVE WS-ELAPSED-COMP5 TO DISP-TIME
           DISPLAY "3. USAGE COMP-5 (Binary)   : " DISP-TIME " hundredths of a sec"
           DISPLAY " "
           DISPLAY "Conclusion: COMP-5 operates directly in CPU hardware registers,"
           DISPLAY "completely bypassing ASCII decimal conversions.".

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

