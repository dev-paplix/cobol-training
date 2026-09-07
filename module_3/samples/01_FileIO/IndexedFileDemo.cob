       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IndexedFileDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates INDEXED (ISAM) file processing using     *
      *> GnuCOBOL B-Tree indexing. Covers:                    *
      *> 1. Writing records and handling duplicate key errors *
      *> 2. Random record retrieval by PRIMARY RECORD KEY     *
      *> 3. In-place record update with REWRITE               *
      *> 4. Record deletion with DELETE                       *
      *> 5. Key-not-found error handling (Status 23)          *
      *> 6. Sequential traversal using START and READ NEXT    *
      *>======================================================*

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PROD-FILE ASSIGN TO "products.idx"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FD-PROD-ID
               FILE STATUS IS WS-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  PROD-FILE.
       01  PROD-RECORD.
           05  FD-PROD-ID        PIC X(6).
           05  FD-PROD-NAME      PIC X(25).
           05  FD-PROD-QTY       PIC 9(4).
           05  FD-PROD-PRICE     PIC 9(4)V99.

       WORKING-STORAGE SECTION.
       01  WS-STATUS             PIC X(2) VALUE "00".
           88  STATUS-OK         VALUE "00".
           88  STATUS-EOF        VALUE "10".
           88  STATUS-DUP-KEY    VALUE "22".
           88  STATUS-NOT-FOUND  VALUE "23".

       01  WS-EOF-FLAG           PIC X VALUE "N".
           88  END-OF-FILE       VALUE "Y".

       01  DISP-PRICE            PIC $$$,$$9.99.
       01  DISP-QTY              PIC Z,ZZ9.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "        INDEXED (ISAM) FILE OPERATIONS DEMO       "
           DISPLAY "=================================================="

           PERFORM 1000-INITIALIZE-FILE
           PERFORM 2000-TEST-DUPLICATE-KEY
           PERFORM 3000-RANDOM-READ
           PERFORM 4000-UPDATE-RECORD
           PERFORM 5000-DELETE-RECORD
           PERFORM 6000-SEQUENTIAL-AUDIT

           DISPLAY "=================================================="
           DISPLAY "Indexed file operations completed successfully."
           STOP RUN.

       1000-INITIALIZE-FILE.
           DISPLAY "[STEP 1] Creating new indexed file: products.idx..."
           OPEN OUTPUT PROD-FILE
           IF NOT STATUS-OK
               DISPLAY "[ERROR] Could not create indexed file. Status: " WS-STATUS
               STOP RUN
           END-IF

           DISPLAY "[INFO] Populating initial inventory items..."
           
           MOVE "PRD101" TO FD-PROD-ID
           MOVE "Mechanical Keyboard" TO FD-PROD-NAME
           MOVE 45 TO FD-PROD-QTY
           MOVE 89.99 TO FD-PROD-PRICE
           WRITE PROD-RECORD

           MOVE "PRD102" TO FD-PROD-ID
           MOVE "Wireless Mouse" TO FD-PROD-NAME
           MOVE 120 TO FD-PROD-QTY
           MOVE 29.50 TO FD-PROD-PRICE
           WRITE PROD-RECORD

           MOVE "PRD103" TO FD-PROD-ID
           MOVE "4K Monitor 27in" TO FD-PROD-NAME
           MOVE 18 TO FD-PROD-QTY
           MOVE 349.00 TO FD-PROD-PRICE
           WRITE PROD-RECORD

           CLOSE PROD-FILE
           DISPLAY "[INFO] Initial records successfully written."
           DISPLAY " ".

       2000-TEST-DUPLICATE-KEY.
           DISPLAY "[STEP 2] Testing Duplicate Key Validation..."
           OPEN I-O PROD-FILE
           
           MOVE "PRD102" TO FD-PROD-ID
           MOVE "Duplicate Wireless Mouse" TO FD-PROD-NAME
           MOVE 10 TO FD-PROD-QTY
           MOVE 15.00 TO FD-PROD-PRICE
           WRITE PROD-RECORD
               INVALID KEY
                   DISPLAY "[EXPECTED] Duplicate key caught! Status: " WS-STATUS
                           " (22 = Duplicate Key)"
               NOT INVALID KEY
                   DISPLAY "[UNEXPECTED] Wrote duplicate record!"
           END-WRITE
           DISPLAY " ".

       3000-RANDOM-READ.
           DISPLAY "[STEP 3] Random Direct Read by Primary Key..."
           MOVE "PRD102" TO FD-PROD-ID
           READ PROD-FILE
               INVALID KEY
                   DISPLAY "[ERROR] Record not found. Status: " WS-STATUS
               NOT INVALID KEY
                   MOVE FD-PROD-PRICE TO DISP-PRICE
                   MOVE FD-PROD-QTY TO DISP-QTY
                   DISPLAY "Found Record: [" FD-PROD-ID "] " FD-PROD-NAME
                           " | Qty: " DISP-QTY " | Price: " DISP-PRICE
           END-READ
           DISPLAY " ".

       4000-UPDATE-RECORD.
           DISPLAY "[STEP 4] In-Place Record Update (REWRITE)..."
           MOVE "PRD101" TO FD-PROD-ID
           READ PROD-FILE
               NOT INVALID KEY
                   MOVE 24.99 TO FD-PROD-PRICE
                   MOVE 55 TO FD-PROD-QTY
                   REWRITE PROD-RECORD
                       INVALID KEY
                           DISPLAY "[ERROR] Rewrite failed: " WS-STATUS
                       NOT INVALID KEY
                           DISPLAY "[SUCCESS] Updated PRD101: New Price: $24.99, New Qty: 55"
                   END-REWRITE
           END-READ
           DISPLAY " ".

       5000-DELETE-RECORD.
           DISPLAY "[STEP 5] Record Deletion (DELETE) & Status 23 Test..."
           MOVE "PRD103" TO FD-PROD-ID
           DELETE PROD-FILE RECORD
               INVALID KEY
                   DISPLAY "[ERROR] Could not delete PRD103: " WS-STATUS
               NOT INVALID KEY
                   DISPLAY "[SUCCESS] Deleted PRD103 from indexed file."
           END-DELETE

           *> Verify PRD103 is no longer readable
           READ PROD-FILE
               INVALID KEY
                   DISPLAY "[EXPECTED] Verified PRD103 absent. Status: " WS-STATUS 
                           " (23 = Record Not Found)"
               NOT INVALID KEY
                   DISPLAY "[UNEXPECTED] PRD103 was still found!"
           END-READ
           DISPLAY " ".

       6000-SEQUENTIAL-AUDIT.
           DISPLAY "[STEP 6] Sequential Full-Scan Audit..."
           DISPLAY "--------------------------------------------------"
           DISPLAY "ID     | NAME                      | QTY  | PRICE "
           DISPLAY "--------------------------------------------------"
           
           MOVE LOW-VALUES TO FD-PROD-ID
           START PROD-FILE KEY >= FD-PROD-ID
               INVALID KEY
                   DISPLAY "[ERROR] Could not position cursor."
               NOT INVALID KEY
                   MOVE "N" TO WS-EOF-FLAG
                   PERFORM UNTIL END-OF-FILE
                       READ PROD-FILE NEXT RECORD
                           AT END
                               MOVE "Y" TO WS-EOF-FLAG
                           NOT AT END
                               MOVE FD-PROD-PRICE TO DISP-PRICE
                               MOVE FD-PROD-QTY TO DISP-QTY
                               DISPLAY FD-PROD-ID " | " FD-PROD-NAME " | " 
                                       DISP-QTY " | " DISP-PRICE
                       END-READ
                   END-PERFORM
           END-START

           CLOSE PROD-FILE.

