       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GeneralLedger.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> EXERCISE 2 (SOLUTION): SQLite Financial Ledger       *
      *> Full ACID transaction handling, balance calculation   *
      *> and overdraft protection via transaction ROLLBACK.   *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "SQLITE.CPY".

      *> Journal Record Fields
       01  WS-ENTRY-ID               PIC S9(9) COMP-5.
       01  WS-ACCOUNT                PIC X(15).
       01  WS-TX-TYPE                PIC X(10).
       01  WS-AMOUNT-DBL             USAGE COMP-2.
       01  WS-AMOUNT-DEC             PIC 9(7)V99 COMP-3.

      *> Account Balances
       01  WS-CHECKING-BAL           PIC S9(7)V99 COMP-3 VALUE 0.
       01  WS-SAVINGS-BAL            PIC S9(7)V99 COMP-3 VALUE 0.
       01  WS-TEST-WITHDRAWAL        PIC 9(7)V99 COMP-3 VALUE 1000.00.
       01  WS-PROJECTED-BAL          PIC S9(7)V99 COMP-3 VALUE 0.

      *> Display fields
       01  DISP-ENTRY-ID             PIC ZZZ9.
       01  DISP-AMOUNT               PIC $$$,$$9.99.
       01  DISP-CHK-BAL              PIC $$$,$$9.99.
       01  DISP-SAV-BAL              PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "      EXERCISE 2: SQLITE FINANCIAL LEDGER         "
           DISPLAY "=================================================="

           PERFORM 1000-OPEN-DB
           PERFORM 2000-SETUP-SCHEMA
           PERFORM 3000-RECORD-TRANSACTIONS
           PERFORM 4000-AUDIT-BALANCES
           PERFORM 5000-TEST-OVERDRAFT-ROLLBACK
           PERFORM 6000-CLEANUP

           DISPLAY "=================================================="
           DISPLAY "Exercise 2 completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-OPEN-DB.
           DISPLAY "[STEP 1] Opening ledger.db..."
           MOVE "ledger.db" TO SQL-STATEMENT
           CALL "cob_sqlite_open" USING BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQLITE-STATUS
           IF NOT SQL-OK
               DISPLAY "[ERROR] Could not open ledger.db: " SQLITE-STATUS
               STOP RUN
           END-IF.

       2000-SETUP-SCHEMA.
           DISPLAY "[STEP 2] Creating journal table..."
           MOVE "CREATE TABLE IF NOT EXISTS journal (entry_id INT, account TEXT, tx_type TEXT, amount REAL);" 
               TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE SQLITE-STATUS

           MOVE "DELETE FROM journal;" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
                                        BY REFERENCE SQL-STATEMENT 
                                        BY REFERENCE SQLITE-STATUS.

       3000-RECORD-TRANSACTIONS.
           DISPLAY "[STEP 3] Recording initial batch inside transaction..."
           MOVE "BEGIN TRANSACTION;" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

           MOVE "INSERT INTO journal VALUES (1, 'Checking', 'CREDIT', 1000.00);" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

           MOVE "INSERT INTO journal VALUES (2, 'Checking', 'DEBIT', 350.50);" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

           MOVE "INSERT INTO journal VALUES (3, 'Savings', 'CREDIT', 500.00);" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

           MOVE "COMMIT;" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS
           DISPLAY "[INFO] 3 journal transactions committed."
           DISPLAY " ".

       4000-AUDIT-BALANCES.
           DISPLAY "[STEP 4] Calculating account balances from journal..."
           DISPLAY "---------------------------------------------------------"
           DISPLAY "ID   | ACCOUNT         | TYPE       | AMOUNT             "
           DISPLAY "---------------------------------------------------------"

           MOVE 0 TO WS-CHECKING-BAL
           MOVE 0 TO WS-SAVINGS-BAL

           MOVE "SELECT entry_id, account, tx_type, amount FROM journal ORDER BY entry_id;" 
               TO SQL-STATEMENT
           CALL "cob_sqlite_prepare" USING BY REFERENCE DB-HANDLE 
                                           BY REFERENCE SQL-STATEMENT 
                                           BY REFERENCE STMT-HANDLE 
                                           BY REFERENCE SQLITE-STATUS

           PERFORM UNTIL 1 = 0
               CALL "cob_sqlite_step" USING BY REFERENCE STMT-HANDLE BY REFERENCE SQLITE-STATUS
               IF SQL-ROW
                   CALL "cob_sqlite_get_int" USING BY REFERENCE STMT-HANDLE BY VALUE 0 BY REFERENCE WS-ENTRY-ID
                   CALL "cob_sqlite_get_text" USING BY REFERENCE STMT-HANDLE BY VALUE 1 BY REFERENCE WS-ACCOUNT BY VALUE 15
                   CALL "cob_sqlite_get_text" USING BY REFERENCE STMT-HANDLE BY VALUE 2 BY REFERENCE WS-TX-TYPE BY VALUE 10
                   CALL "cob_sqlite_get_double" USING BY REFERENCE STMT-HANDLE BY VALUE 3 BY REFERENCE WS-AMOUNT-DBL

                   COMPUTE WS-AMOUNT-DEC ROUNDED = WS-AMOUNT-DBL
                   MOVE WS-ENTRY-ID TO DISP-ENTRY-ID
                   MOVE WS-AMOUNT-DEC TO DISP-AMOUNT
                   DISPLAY DISP-ENTRY-ID " | " WS-ACCOUNT " | " WS-TX-TYPE " | " DISP-AMOUNT

                   IF WS-ACCOUNT(1:8) = "Checking"
                       IF WS-TX-TYPE(1:6) = "CREDIT"
                           ADD WS-AMOUNT-DEC TO WS-CHECKING-BAL
                       ELSE
                           SUBTRACT WS-AMOUNT-DEC FROM WS-CHECKING-BAL
                       END-IF
                   ELSE
                       IF WS-TX-TYPE(1:6) = "CREDIT"
                           ADD WS-AMOUNT-DEC TO WS-SAVINGS-BAL
                       ELSE
                           SUBTRACT WS-AMOUNT-DEC FROM WS-SAVINGS-BAL
                       END-IF
                   END-IF
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM

           CALL "cob_sqlite_finalize" USING BY REFERENCE STMT-HANDLE BY REFERENCE SQLITE-STATUS

           MOVE WS-CHECKING-BAL TO DISP-CHK-BAL
           MOVE WS-SAVINGS-BAL TO DISP-SAV-BAL
           DISPLAY "---------------------------------------------------------"
           DISPLAY "Checking Account Balance : " DISP-CHK-BAL
           DISPLAY "Savings Account Balance  : " DISP-SAV-BAL
           DISPLAY " ".

       5000-TEST-OVERDRAFT-ROLLBACK.
           DISPLAY "[STEP 5] Testing overdraft withdrawal and ROLLBACK..."
           DISPLAY "Attempting to withdraw $1,000.00 from Checking..."
           MOVE "BEGIN TRANSACTION;" TO SQL-STATEMENT
           CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

           COMPUTE WS-PROJECTED-BAL = WS-CHECKING-BAL - WS-TEST-WITHDRAWAL
           IF WS-PROJECTED-BAL < 0
               DISPLAY "[OVERDRAFT] Withdrawal rejected: Projected balance would be negative!"
               DISPLAY "[INFO] Rolling back transaction..."
               MOVE "ROLLBACK;" TO SQL-STATEMENT
               CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS
               DISPLAY "[SUCCESS] Transaction rolled back cleanly. No funds deducted."
           ELSE
               MOVE "COMMIT;" TO SQL-STATEMENT
               CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS
           END-IF
           DISPLAY " ".

       6000-CLEANUP.
           CALL "cob_sqlite_close" USING BY REFERENCE DB-HANDLE BY REFERENCE SQLITE-STATUS
           DISPLAY "[INFO] Database closed cleanly.".

