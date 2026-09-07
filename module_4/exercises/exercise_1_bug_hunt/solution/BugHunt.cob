       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BugHunt.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> EXERCISE 1 (SOLUTION): The Enterprise Bug Hunt       *
      *> Fixed all 3 defects:                                 *
      *> 1. Corrected loop boundary from > 13 to > 12         *
      *> 2. Initialized WS-BONUS-POOL with VALUE 0            *
      *> 3. Added ON SIZE ERROR block to handle 0 headcount   *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Monthly Commission Table (12 Months)
       01  COMMISSION-TABLE.
           05  MONTHLY-SALES OCCURS 12 TIMES PIC 9(6)V99.

       01  WS-MTH                    PIC S9(4) COMP-5 VALUE 1.
       01  WS-ANNUAL-SALES           PIC 9(8)V99 VALUE 0.

      *> Department Allocation Data
      *> FIX B: Initialized with VALUE 0
       01  WS-BONUS-POOL             PIC S9(7)V99 COMP-3 VALUE 0.
       01  WS-HEADCOUNT              PIC 9(3) VALUE 0.
       01  WS-AVG-BONUS              PIC 9(6)V99 VALUE 0.

       01  DISP-SALES                PIC $$$,$$$,$$9.99.
       01  DISP-BONUS                PIC $$$,$$9.99.
       01  DISP-POOL                 PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "         EXERCISE 1: ENTERPRISE BUG HUNT          "
           DISPLAY "=================================================="

           PERFORM 1000-POPULATE-SALES
           PERFORM 2000-CALCULATE-ANNUAL-SALES
           PERFORM 3000-ALLOCATE-BONUS

           DISPLAY "=================================================="
           DISPLAY "Bug hunt completed successfully. All defects resolved."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-POPULATE-SALES.
           DISPLAY "[STEP 1] Populating monthly commission data..."
      *> FIX A: Loop condition corrected to UNTIL WS-MTH > 12
           PERFORM VARYING WS-MTH FROM 1 BY 1 UNTIL WS-MTH > 12
               MOVE 15000.00 TO MONTHLY-SALES (WS-MTH)
           END-PERFORM
           DISPLAY "[INFO] Monthly sales populated cleanly within bounds (1..12)."
           DISPLAY " ".

       2000-CALCULATE-ANNUAL-SALES.
           DISPLAY "[STEP 2] Calculating annual sales and bonus pool..."
           MOVE 0 TO WS-ANNUAL-SALES
           PERFORM VARYING WS-MTH FROM 1 BY 1 UNTIL WS-MTH > 12
               ADD MONTHLY-SALES (WS-MTH) TO WS-ANNUAL-SALES
           END-PERFORM

           MOVE WS-ANNUAL-SALES TO DISP-SALES
           DISPLAY "  Total Annual Sales : " DISP-SALES

      *> FIX B: WS-BONUS-POOL initialized to 0 and calculated cleanly
           MOVE 0 TO WS-BONUS-POOL
           COMPUTE WS-BONUS-POOL = WS-ANNUAL-SALES * 0.05
           MOVE WS-BONUS-POOL TO DISP-POOL
           DISPLAY "  Allocated Bonus Pool: " DISP-POOL
           DISPLAY " ".

       3000-ALLOCATE-BONUS.
           DISPLAY "[STEP 3] Allocating bonuses to Research Department..."
           DISPLAY "  Department Headcount: " WS-HEADCOUNT

      *> FIX C: Protected against division by zero using ON SIZE ERROR
           DIVIDE WS-BONUS-POOL BY WS-HEADCOUNT GIVING WS-AVG-BONUS
               ON SIZE ERROR
                   DISPLAY "  [DEFENSE] Zero headcount handled safely: Average bonus set to $0.00."
                   MOVE 0 TO WS-AVG-BONUS
               NOT ON SIZE ERROR
                   DISPLAY "  [SUCCESS] Average bonus allocated successfully."
           END-DIVIDE

           MOVE WS-AVG-BONUS TO DISP-BONUS
           DISPLAY "  Bonus Per Employee  : " DISP-BONUS.

