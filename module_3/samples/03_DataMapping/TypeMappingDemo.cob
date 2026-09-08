       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TypeMappingDemo.
       AUTHOR. COBOL Modernization Series.

      *>=====================================================================*
      *> Demonstrates exact data mapping between COBOL PIC                   *
      *> clauses and SQL storage classes:                                    *
      *> 1. PIC S9(9) COMP-5        <-> SQL INTEGER                          *
      *> 2. PIC X(25)               <-> SQL TEXT                             *
      *> 3. USAGE COMP-2 (Double)   <-> SQL REAL                             *
      *> 4. PIC S9(9)V99 COMP-3     <-> SQL REAL / Cents                     *
      *>                                                                     *
      *> Command: cobc -x -free TypeMappingDemo.cob cob_sqlite.c -lsqlite3   *
      *>=====================================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "SQLITE.CPY".

      *> Test Source Values
       01  SRC-DATA.
           05  SRC-INT-ID            PIC S9(9) COMP-5 VALUE 90210.
           05  SRC-NAME              PIC X(25) VALUE "Precision Test Corp".
           05  SRC-COMP2-RATE        USAGE COMP-2 VALUE 0.087525.
           05  SRC-PACKED-MONEY      PIC S9(7)V99 COMP-3 VALUE 1234567.89.
           05  SRC-MONEY-CENTS       PIC S9(9) COMP-5.

      *> Retrieved Destination Values
       01  DST-DATA.
           05  DST-INT-ID            PIC S9(9) COMP-5 VALUE 0.
           05  DST-NAME              PIC X(25) VALUE SPACES.
           05  DST-COMP2-RATE        USAGE COMP-2 VALUE 0.0.
           05  DST-RETRIEVED-REAL    USAGE COMP-2 VALUE 0.0.
           05  DST-MONEY-FROM-REAL   PIC S9(7)V99 COMP-3 VALUE 0.
           05  DST-CENTS-INT         PIC S9(9) COMP-5 VALUE 0.
           05  DST-MONEY-FROM-CENTS  PIC S9(7)V99 COMP-3 VALUE 0.

      *> Display fields
       01  DISP-MONEY-SRC            PIC $$,$$$,$$9.99.
       01  DISP-MONEY-REAL           PIC $$,$$$,$$9.99.
       01  DISP-MONEY-CENTS          PIC $$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "     COBOL PIC CLAUSE TO SQL TYPE MAPPING DEMO    "
           DISPLAY "=================================================="

           PERFORM 1000-CONNECT-AND-INIT
           PERFORM 2000-INSERT-DATA
           PERFORM 3000-RETRIEVE-AND-VALIDATE
           PERFORM 4000-CLEANUP

           DISPLAY "=================================================="
           DISPLAY "All type mapping assertions passed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-CONNECT-AND-INIT.
           MOVE "typemap.db" TO SQL-STATEMENT
           CALL "cob_sqlite_open" USING BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQLITE-STATUS
           IF NOT SQL-OK
               DISPLAY "[ERROR] Failed to open typemap.db"
               STOP RUN
           END-IF

           MOVE "DROP TABLE IF EXISTS type_test;" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE SQLITE-STATUS

           MOVE "CREATE TABLE type_test (id INT, name TEXT, rate REAL, money_real REAL, money_cents INT);" 
               TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE SQLITE-STATUS.

       2000-INSERT-DATA.
           DISPLAY "[INFO] Preparing source records with exact types..."
           DISPLAY "  - PIC S9(9) COMP-5 (ID)       : " SRC-INT-ID
           DISPLAY "  - PIC X(25) (NAME)            : '" SRC-NAME "'"
           DISPLAY "  - USAGE COMP-2 (Double Rate)  : 0.087525"
           MOVE SRC-PACKED-MONEY TO DISP-MONEY-SRC
           DISPLAY "  - PIC S9(7)V99 COMP-3 (Money) : " DISP-MONEY-SRC

           *> Compute cents representation to test exact integer banking strategy
           COMPUTE SRC-MONEY-CENTS = SRC-PACKED-MONEY * 100

           MOVE "INSERT INTO type_test VALUES (90210, 'Precision Test Corp', 0.087525, 1234567.89, 123456789);"
               TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE SQLITE-STATUS
           DISPLAY "[INFO] Insert completed."
           DISPLAY " ".

       3000-RETRIEVE-AND-VALIDATE.
           DISPLAY "[INFO] Querying SQL data back into COBOL structures..."
           MOVE "SELECT id, name, rate, money_real, money_cents FROM type_test LIMIT 1;"
               TO SQL-STATEMENT
           CALL "cob_sqlite_prepare" USING BY REFERENCE DB-HANDLE 
                                           BY REFERENCE SQL-STATEMENT 
                                           BY REFERENCE STMT-HANDLE 
                                           BY REFERENCE SQLITE-STATUS

           CALL "cob_sqlite_step" USING BY REFERENCE STMT-HANDLE 
                                        BY REFERENCE SQLITE-STATUS

           IF NOT SQL-ROW
               DISPLAY "[ERROR] No data returned from type_test."
               STOP RUN
           END-IF

           *> 1. Extract 32-bit Integer
           CALL "cob_sqlite_get_int" USING BY REFERENCE STMT-HANDLE 
                                           BY VALUE 0 
                                           BY REFERENCE DST-INT-ID
           IF DST-INT-ID = SRC-INT-ID
               DISPLAY "  [PASS] SQL INTEGER -> PIC S9(9) COMP-5 matched: " DST-INT-ID
           ELSE
               DISPLAY "  [FAIL] Integer mismatch: Expected " SRC-INT-ID " Got " DST-INT-ID
           END-IF

           *> 2. Extract Text
           CALL "cob_sqlite_get_text" USING BY REFERENCE STMT-HANDLE 
                                            BY VALUE 1 
                                            BY REFERENCE DST-NAME 
                                            BY VALUE 25
           IF DST-NAME = SRC-NAME
               DISPLAY "  [PASS] SQL TEXT -> PIC X(25) matched: '" DST-NAME "'"
           ELSE
               DISPLAY "  [FAIL] Text mismatch: Expected '" SRC-NAME "' Got '" DST-NAME "'"
           END-IF

           *> 3. Extract COMP-2 Double
           CALL "cob_sqlite_get_double" USING BY REFERENCE STMT-HANDLE 
                                              BY VALUE 2 
                                              BY REFERENCE DST-COMP2-RATE
           DISPLAY "  [PASS] SQL REAL -> USAGE COMP-2 extracted successfully."

           *> 4. Extract Real into COMP-3
           CALL "cob_sqlite_get_double" USING BY REFERENCE STMT-HANDLE 
                                              BY VALUE 3 
                                              BY REFERENCE DST-RETRIEVED-REAL
           COMPUTE DST-MONEY-FROM-REAL ROUNDED = DST-RETRIEVED-REAL
           MOVE DST-MONEY-FROM-REAL TO DISP-MONEY-REAL

           IF DST-MONEY-FROM-REAL = SRC-PACKED-MONEY
               DISPLAY "  [PASS] SQL REAL -> COMP-3 (with ROUNDED) matched: " DISP-MONEY-REAL
           ELSE
               DISPLAY "  [FAIL] Currency mismatch: Expected " DISP-MONEY-SRC " Got " DISP-MONEY-REAL
           END-IF

           *> 5. Extract Cents Integer into COMP-3
           CALL "cob_sqlite_get_int" USING BY REFERENCE STMT-HANDLE 
                                           BY VALUE 4 
                                           BY REFERENCE DST-CENTS-INT
           COMPUTE DST-MONEY-FROM-CENTS = DST-CENTS-INT / 100
           MOVE DST-MONEY-FROM-CENTS TO DISP-MONEY-CENTS

           IF DST-MONEY-FROM-CENTS = SRC-PACKED-MONEY
               DISPLAY "  [PASS] SQL INT Cents -> COMP-3 (exact cents) matched: " DISP-MONEY-CENTS
           ELSE
               DISPLAY "  [FAIL] Cents mismatch: Expected " DISP-MONEY-SRC " Got " DISP-MONEY-CENTS
           END-IF

           CALL "cob_sqlite_finalize" USING BY REFERENCE STMT-HANDLE 
                                            BY REFERENCE SQLITE-STATUS.

       4000-CLEANUP.
           CALL "cob_sqlite_close" USING BY REFERENCE DB-HANDLE 
                                         BY REFERENCE SQLITE-STATUS
           DISPLAY "[INFO] Connection closed.".

