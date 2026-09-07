       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TableLookupDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates Table Access Performance Optimization:  *
      *> 1. Numeric Subscripting (dynamic address math)       *
      *> 2. Hardware Indexing (zero-overhead displacement)    *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> In-Memory Product Table (1,000 items)
       01  CATALOG-TABLE.
           05  CAT-ITEM OCCURS 1000 TIMES INDEXED BY TBL-IDX.
               10  ITEM-ID           PIC 9(6).
               10  ITEM-QTY          PIC 9(4) COMP-5.
               10  ITEM-PRICE        PIC 9(4)V99 COMP-3.

      *> Access Controls
       01  WS-SUB                    PIC 9(4) COMP-5 VALUE 1.
       01  WS-PASSES                 PIC 9(3) COMP-5 VALUE 50.
       01  WS-PASS-IDX               PIC 9(3) COMP-5 VALUE 0.
       01  WS-ACCUMULATOR            PIC 9(9)V99 COMP-3 VALUE 0.

      *> Timing structures
       01  WS-TIME-RAW               PIC X(21).
       01  WS-START-HUNDS            PIC S9(9) COMP-5.
       01  WS-END-HUNDS              PIC S9(9) COMP-5.
       01  WS-TIME-SUBSCRIPT         PIC S9(9) COMP-5.
       01  WS-TIME-INDEXED           PIC S9(9) COMP-5.

       01  DISP-TIME                 PIC Z,ZZ9.
       01  DISP-TOTAL                PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "   TABLE ACCESS: SUBSCRIPTS VS HARDWARE INDEXING  "
           DISPLAY "=================================================="

           PERFORM 1000-POPULATE-TABLE
           PERFORM 2000-TEST-SUBSCRIPTS
           PERFORM 3000-TEST-HARDWARE-INDEXING
           PERFORM 4000-DISPLAY-RESULTS

           DISPLAY "=================================================="
           DISPLAY "Table benchmark completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-POPULATE-TABLE.
           DISPLAY "[INFO] Populating 1,000 table elements in memory..."
           PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 1000
               COMPUTE ITEM-ID (WS-SUB) = 100000 + WS-SUB
               MOVE 5 TO ITEM-QTY (WS-SUB)
               MOVE 19.95 TO ITEM-PRICE (WS-SUB)
           END-PERFORM
           DISPLAY "[INFO] Table population completed."
           DISPLAY " ".

       2000-TEST-SUBSCRIPTS.
           DISPLAY "[TEST 1] Traversing table using Numeric Subscripts (50,000 lookups)..."
           PERFORM 9000-GET-HUNDS
           MOVE 0 TO WS-ACCUMULATOR

           PERFORM VARYING WS-PASS-IDX FROM 1 BY 1 UNTIL WS-PASS-IDX > WS-PASSES
               PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 1000
                   ADD ITEM-PRICE (WS-SUB) TO WS-ACCUMULATOR
               END-PERFORM
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-TIME-SUBSCRIPT = WS-END-HUNDS - WS-START-HUNDS
           MOVE WS-TIME-SUBSCRIPT TO DISP-TIME
           MOVE WS-ACCUMULATOR TO DISP-TOTAL
           DISPLAY "  Accumulated Value: " DISP-TOTAL " | Time: " DISP-TIME " hundredths of a sec."
           DISPLAY " ".

       3000-TEST-HARDWARE-INDEXING.
           DISPLAY "[TEST 2] Traversing table using INDEXED BY (50,000 lookups)..."
           PERFORM 9000-GET-HUNDS
           MOVE 0 TO WS-ACCUMULATOR

           PERFORM VARYING WS-PASS-IDX FROM 1 BY 1 UNTIL WS-PASS-IDX > WS-PASSES
               SET TBL-IDX TO 1
               PERFORM UNTIL TBL-IDX > 1000
                   ADD ITEM-PRICE (TBL-IDX) TO WS-ACCUMULATOR
                   SET TBL-IDX UP BY 1
               END-PERFORM
           END-PERFORM

           PERFORM 9100-GET-END-HUNDS
           COMPUTE WS-TIME-INDEXED = WS-END-HUNDS - WS-START-HUNDS
           MOVE WS-TIME-INDEXED TO DISP-TIME
           MOVE WS-ACCUMULATOR TO DISP-TOTAL
           DISPLAY "  Accumulated Value: " DISP-TOTAL " | Time: " DISP-TIME " hundredths of a sec."
           DISPLAY " ".

       4000-DISPLAY-RESULTS.
           DISPLAY "--------------------------------------------------"
           DISPLAY "TABLE TRAVERSAL PERFORMANCE COMPARISON            "
           DISPLAY "--------------------------------------------------"
           MOVE WS-TIME-SUBSCRIPT TO DISP-TIME
           DISPLAY "Subscripting (dynamic arithmetic): " DISP-TIME " hundredths of a sec"
           MOVE WS-TIME-INDEXED TO DISP-TIME
           DISPLAY "Hardware Indexing (INDEXED BY)  : " DISP-TIME " hundredths of a sec"
           DISPLAY " "
           DISPLAY "Hardware indexing avoids run-time multiplication because"
           DISPLAY "the index maintains the exact byte displacement in memory.".

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

