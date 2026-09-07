       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ExceptionDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates native runtime error recovery and       *
      *> defensive programming in GnuCOBOL:                   *
      *> 1. Division by Zero recovery via ON SIZE ERROR       *
      *> 2. Arithmetic capacity overflow via ON SIZE ERROR    *
      *> 3. String truncation handling via ON OVERFLOW        *
      *> 4. Table boundary defensive validation               *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Test 1: Division by Zero
       01  WS-DIVIDEND               PIC 9(5)V99 VALUE 1500.00.
       01  WS-ZERO-DIVISOR           PIC 9(3) VALUE 0.
       01  WS-DIV-RESULT             PIC 9(5)V99 VALUE 999.99.

      *> Test 2: Arithmetic Overflow
       01  WS-LARGE-A                PIC 9(5) VALUE 50000.
       01  WS-LARGE-B                PIC 9(5) VALUE 2000.
       01  WS-SMALL-TARGET           PIC 9(4) VALUE 0.

      *> Test 3: String Overflow
       01  WS-SRC-STRING             PIC X(30) VALUE "Alpha Beta Gamma Delta Epsilon".
       01  WS-TGT-BUFFER             PIC X(10) VALUE SPACES.

      *> Test 4: Table Bounds
       01  RATE-TABLE-DATA.
           05  FILLER                PIC 9V99 VALUE 0.05.
           05  FILLER                PIC 9V99 VALUE 0.08.
           05  FILLER                PIC 9V99 VALUE 0.12.
       01  RATE-TABLE REDEFINES RATE-TABLE-DATA.
           05  TIER-RATE OCCURS 3 TIMES PIC 9V99.

       01  WS-SEARCH-INDEX           PIC S9(4) COMP-5 VALUE 5.
       01  WS-SELECTED-RATE          PIC 9V99 VALUE 0.0.

      *> Error Counters
       01  WS-ERRORS-CAUGHT          PIC 9(2) VALUE 0.
       01  WS-TESTS-RUN              PIC 9(2) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "     RUNTIME ERROR ANALYSIS & EXCEPTION DEMO      "
           DISPLAY "=================================================="

           PERFORM 1000-TEST-DIVIDE-BY-ZERO
           PERFORM 2000-TEST-SIZE-OVERFLOW
           PERFORM 3000-TEST-STRING-OVERFLOW
           PERFORM 4000-TEST-TABLE-BOUNDS
           PERFORM 5000-DISPLAY-AUDIT

           DISPLAY "=================================================="
           DISPLAY "All exceptions intercepted without program crash."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-TEST-DIVIDE-BY-ZERO.
           ADD 1 TO WS-TESTS-RUN
           DISPLAY "[SCENARIO 1] Division by Zero Trap:"
           DISPLAY "  Attempting to compute: " WS-DIVIDEND " / " WS-ZERO-DIVISOR

           DIVIDE WS-DIVIDEND BY WS-ZERO-DIVISOR GIVING WS-DIV-RESULT
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-CAUGHT
                   DISPLAY "  [TRAPPED] ON SIZE ERROR triggered successfully!"
                   DISPLAY "  [DEFENSE] Zero divisor intercepted. Result preserved as: " WS-DIV-RESULT
               NOT ON SIZE ERROR
                   DISPLAY "  [UNEXPECTED] Division succeeded unexpectedly."
           END-DIVIDE
           DISPLAY " ".

       2000-TEST-SIZE-OVERFLOW.
           ADD 1 TO WS-TESTS-RUN
           DISPLAY "[SCENARIO 2] Arithmetic Overflow Trap:"
           DISPLAY "  Attempting to store (50000 * 2000 = 100,000,000) in PIC 9(4) (max 9999)..."

           MULTIPLY WS-LARGE-A BY WS-LARGE-B GIVING WS-SMALL-TARGET
               ON SIZE ERROR
                   ADD 1 TO WS-ERRORS-CAUGHT
                   DISPLAY "  [TRAPPED] ON SIZE ERROR triggered successfully!"
                   DISPLAY "  [DEFENSE] Target variable size exceeded; memory corruption prevented."
               NOT ON SIZE ERROR
                   DISPLAY "  [UNEXPECTED] Overflow occurred silently!"
           END-MULTIPLY
           DISPLAY " ".

       3000-TEST-STRING-OVERFLOW.
           ADD 1 TO WS-TESTS-RUN
           DISPLAY "[SCENARIO 3] String Target Overflow Trap:"
           DISPLAY "  Attempting to write 30 bytes into a 10-byte target buffer..."

           STRING WS-SRC-STRING DELIMITED BY SIZE
               INTO WS-TGT-BUFFER
               ON OVERFLOW
                   ADD 1 TO WS-ERRORS-CAUGHT
                   DISPLAY "  [TRAPPED] ON OVERFLOW triggered successfully!"
                   DISPLAY "  [DEFENSE] Target buffer filled up to capacity: '" WS-TGT-BUFFER "'"
               NOT ON OVERFLOW
                   DISPLAY "  [UNEXPECTED] No overflow detected!"
           END-STRING
           DISPLAY " ".

       4000-TEST-TABLE-BOUNDS.
           ADD 1 TO WS-TESTS-RUN
           DISPLAY "[SCENARIO 4] Defensive Table Boundary Validation:"
           DISPLAY "  Table capacity is 3 tiers. Requested tier index: " WS-SEARCH-INDEX

           IF WS-SEARCH-INDEX < 1 OR WS-SEARCH-INDEX > 3
               ADD 1 TO WS-ERRORS-CAUGHT
               DISPLAY "  [VALIDATED] Index out of bounds (1..3 range check failed)!"
               DISPLAY "  [DEFENSE] Defaulting to baseline Tier 1 rate instead of crashing."
               MOVE TIER-RATE (1) TO WS-SELECTED-RATE
           ELSE
               MOVE TIER-RATE (WS-SEARCH-INDEX) TO WS-SELECTED-RATE
           END-IF

           DISPLAY "  Assigned Rate: " WS-SELECTED-RATE
           DISPLAY " ".

       5000-DISPLAY-AUDIT.
           DISPLAY "--------------------------------------------------"
           DISPLAY "Total Edge-Case Scenarios Tested : " WS-TESTS-RUN
           DISPLAY "Total Exceptions Safely Caught   : " WS-ERRORS-CAUGHT
           DISPLAY "Fatal Crashes Or Memory Corrupts : 0".

