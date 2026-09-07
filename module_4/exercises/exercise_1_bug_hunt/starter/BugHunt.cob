       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BugHunt.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 1 (STARTER): The Enterprise Bug Hunt        *
      *>                                                      *
      *> Instructions:                                        *
      *> Compile this program with runtime checks enabled:    *
      *>   cobc -x -free -debug BugHunt.cob -o BugHunt        *
      *>                                                      *
      *> Run it to observe how the program terminates:        *
      *>   ./BugHunt                                          *
      *>                                                      *
      *> Locate and fix the 3 defects:                        *
      *> 1. Bug A: Off-by-one table subscript overrun (> 13)  *
      *> 2. Bug B: Uninitialized packed decimal field         *
      *> 3. Bug C: Unprotected division by zero               *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Monthly Commission Table (12 Months)
       01  COMMISSION-TABLE.
           05  MONTHLY-SALES OCCURS 12 TIMES PIC 9(6)V99.

       01  WS-MTH                    PIC S9(4) COMP-5 VALUE 1.
       01  WS-ANNUAL-SALES           PIC 9(8)V99 VALUE 0.

      *> Department Allocation Data
      *> [BUG B]: WS-BONUS-POOL is uninitialized packed decimal
       01  WS-BONUS-POOL             PIC S9(7)V99 COMP-3.
       01  WS-HEADCOUNT              PIC 9(3) VALUE 0.
       01  WS-AVG-BONUS              PIC 9(6)V99 VALUE 0.

       01  DISP-SALES                PIC $$$,$$$,$$9.99.
       01  DISP-BONUS                PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "         EXERCISE 1: ENTERPRISE BUG HUNT          "
           DISPLAY "=================================================="

           PERFORM 1000-POPULATE-SALES
           PERFORM 2000-CALCULATE-ANNUAL-SALES
           PERFORM 3000-ALLOCATE-BONUS

           DISPLAY "=================================================="
           DISPLAY "Bug hunt completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-POPULATE-SALES.
           DISPLAY "[STEP 1] Populating monthly commission data..."
      *> [BUG A]: Table has only 12 elements, but loop runs UNTIL WS-MTH > 13!
      *> Under -debug, this triggers 'subscript out of bounds: 13'
           PERFORM VARYING WS-MTH FROM 1 BY 1 UNTIL WS-MTH > 13
               MOVE 15000.00 TO MONTHLY-SALES (WS-MTH)
           END-PERFORM
           DISPLAY "[INFO] Monthly sales populated."
           DISPLAY " ".

       2000-CALCULATE-ANNUAL-SALES.
           DISPLAY "[STEP 2] Calculating annual sales and bonus pool..."
           MOVE 0 TO WS-ANNUAL-SALES
           PERFORM VARYING WS-MTH FROM 1 BY 1 UNTIL WS-MTH > 12
               ADD MONTHLY-SALES (WS-MTH) TO WS-ANNUAL-SALES
           END-PERFORM

           MOVE WS-ANNUAL-SALES TO DISP-SALES
           DISPLAY "  Total Annual Sales : " DISP-SALES

      *> [BUG B]: Reading uninitialized WS-BONUS-POOL adds garbage
           ADD WS-ANNUAL-SALES TO WS-BONUS-POOL
           DISPLAY "  Allocated Bonus Pool: $" WS-BONUS-POOL
           DISPLAY " ".

       3000-ALLOCATE-BONUS.
           DISPLAY "[STEP 3] Allocating bonuses to Research Department..."
           DISPLAY "  Department Headcount: " WS-HEADCOUNT

      *> [BUG C]: Unprotected division by zero when WS-HEADCOUNT is 0
           DIVIDE WS-BONUS-POOL BY WS-HEADCOUNT GIVING WS-AVG-BONUS

           MOVE WS-AVG-BONUS TO DISP-BONUS
           DISPLAY "  Bonus Per Employee  : " DISP-BONUS.

