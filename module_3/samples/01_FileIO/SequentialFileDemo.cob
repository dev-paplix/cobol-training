       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SequentialFileDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> This program demonstrates LINE SEQUENTIAL file I/O   *
      *> in modern GnuCOBOL. It writes sample customer data,  *
      *> closes the file, and reads it back sequentially with *
      *> rigorous FILE STATUS validation.                     *
      *>                                                      *
      *> Command: cobc -x -free SequentialFileDemo.cob        *
      *>======================================================*

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUST-FILE ASSIGN TO "customers.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CUST-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUST-FILE.
       01  CUST-FILE-RECORD.
           05  FD-CUST-ID        PIC 9(5).
           05  FILLER            PIC X VALUE "|".
           05  FD-CUST-NAME      PIC X(20).
           05  FILLER            PIC X VALUE "|".
           05  FD-CUST-TIER      PIC X(8).
           05  FILLER            PIC X VALUE "|".
           05  FD-CUST-BALANCE   PIC 9(6)V99.

       WORKING-STORAGE SECTION.
       01  WS-CUST-STATUS        PIC X(2) VALUE "00".
           88  STATUS-OK         VALUE "00".
           88  STATUS-EOF        VALUE "10".

       01  WS-EOF-FLAG           PIC X VALUE "N".
           88  END-OF-FILE       VALUE "Y".

       01  WS-RECORD-COUNT       PIC 9(4) VALUE 0.
       01  WS-TOTAL-BALANCE      PIC 9(8)V99 VALUE 0.

      *> Display formatting fields
       01  DISP-COUNT            PIC Z,ZZ9.
       01  DISP-BALANCE          PIC $$$,$$$,$$9.99.
       01  DISP-RECORD-BAL       PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "      LINE SEQUENTIAL FILE PROCESSING DEMO        "
           DISPLAY "=================================================="

           PERFORM 1000-WRITE-RECORDS
           PERFORM 2000-READ-RECORDS
           PERFORM 3000-DISPLAY-SUMMARY

           DISPLAY "Sequential file processing completed successfully."
           STOP RUN.

       1000-WRITE-RECORDS.
           DISPLAY "[INFO] Opening customers.txt for OUTPUT..."
           OPEN OUTPUT CUST-FILE
           IF NOT STATUS-OK
               DISPLAY "[ERROR] Failed to open file for output. Status: " WS-CUST-STATUS
               STOP RUN
           END-IF

           DISPLAY "[INFO] Writing sample records..."
           
           *> Record 1
           MOVE 10001 TO FD-CUST-ID
           MOVE "Alpha Corporation" TO FD-CUST-NAME
           MOVE "PLATINUM" TO FD-CUST-TIER
           MOVE 12500.50 TO FD-CUST-BALANCE
           WRITE CUST-FILE-RECORD

           *> Record 2
           MOVE 10002 TO FD-CUST-ID
           MOVE "Beta Logistics" TO FD-CUST-NAME
           MOVE "GOLD" TO FD-CUST-TIER
           MOVE 4800.75 TO FD-CUST-BALANCE
           WRITE CUST-FILE-RECORD

           *> Record 3
           MOVE 10003 TO FD-CUST-ID
           MOVE "Gamma Systems" TO FD-CUST-NAME
           MOVE "SILVER" TO FD-CUST-TIER
           MOVE 1200.00 TO FD-CUST-BALANCE
           WRITE CUST-FILE-RECORD

           *> Record 4
           MOVE 10004 TO FD-CUST-ID
           MOVE "Delta Holdings" TO FD-CUST-NAME
           MOVE "PLATINUM" TO FD-CUST-TIER
           MOVE 35000.25 TO FD-CUST-BALANCE
           WRITE CUST-FILE-RECORD

           CLOSE CUST-FILE
           DISPLAY "[INFO] 4 records written and file closed."
           DISPLAY " ".

       2000-READ-RECORDS.
           DISPLAY "[INFO] Opening customers.txt for INPUT..."
           OPEN INPUT CUST-FILE
           IF NOT STATUS-OK
               DISPLAY "[ERROR] Failed to open file for input. Status: " WS-CUST-STATUS
               STOP RUN
           END-IF

           DISPLAY "--------------------------------------------------"
           DISPLAY "ID    | NAME                 | TIER     | BALANCE "
           DISPLAY "--------------------------------------------------"

           MOVE "N" TO WS-EOF-FLAG
           PERFORM UNTIL END-OF-FILE
               READ CUST-FILE
                   AT END
                       MOVE "Y" TO WS-EOF-FLAG
                   NOT AT END
                       ADD 1 TO WS-RECORD-COUNT
                       ADD FD-CUST-BALANCE TO WS-TOTAL-BALANCE
                       MOVE FD-CUST-BALANCE TO DISP-RECORD-BAL
                       DISPLAY FD-CUST-ID " | " FD-CUST-NAME " | " 
                               FD-CUST-TIER " | " DISP-RECORD-BAL
               END-READ
           END-PERFORM

           CLOSE CUST-FILE.

       3000-DISPLAY-SUMMARY.
           MOVE WS-RECORD-COUNT TO DISP-COUNT
           MOVE WS-TOTAL-BALANCE TO DISP-BALANCE
           DISPLAY "--------------------------------------------------"
           DISPLAY "Total Records Read : " DISP-COUNT
           DISPLAY "Combined Balances  : " DISP-BALANCE
           DISPLAY "==================================================".

