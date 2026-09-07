       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CatalogManager.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 1 (STARTER): Indexed Product Catalog        *
      *>                                                      *
      *> Instructions:                                        *
      *> Complete the TODO sections to implement full CRUD    *
      *> operations on an INDEXED (ISAM) file:                *
      *> 1. WRITE initial product records                     *
      *> 2. Handle duplicate key error (Status 22)            *
      *> 3. READ random record by primary key (Status 23)     *
      *> 4. REWRITE updated quantity and price                *
      *> 5. DELETE a discontinued product                     *
      *> 6. Scan remaining records with START and READ NEXT   *
      *>======================================================*

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *> TODO 1: Declare the INDEXED file SELECT statement
      *> Assign to "catalog.idx", ORGANIZATION IS INDEXED,
      *> ACCESS MODE IS DYNAMIC, RECORD KEY IS FD-CAT-ID,
      *> FILE STATUS IS WS-CAT-STATUS.
           SELECT CAT-FILE ASSIGN TO "catalog.idx"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FD-CAT-ID
               FILE STATUS IS WS-CAT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CAT-FILE.
       01  CAT-RECORD.
           05  FD-CAT-ID         PIC X(6).
           05  FD-CAT-NAME       PIC X(25).
           05  FD-CAT-QTY        PIC 9(4).
           05  FD-CAT-PRICE      PIC 9(4)V99.

       WORKING-STORAGE SECTION.
       01  WS-CAT-STATUS         PIC X(2) VALUE "00".
           88  STATUS-OK         VALUE "00".
           88  STATUS-EOF        VALUE "10".
           88  STATUS-DUP-KEY    VALUE "22".
           88  STATUS-NOT-FOUND  VALUE "23".

       01  WS-EOF-FLAG           PIC X VALUE "N".
           88  END-OF-FILE       VALUE "Y".

       01  DISP-PRICE            PIC $$$,$$9.99.
       01  DISP-QTY              PIC Z,ZZ9.
       01  WS-TOTAL-ITEMS        PIC 9(4) VALUE 0.
       01  WS-CATALOG-VALUE      PIC 9(8)V99 VALUE 0.
       01  WS-ITEM-VALUE         PIC 9(8)V99 VALUE 0.
       01  DISP-CAT-VALUE        PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "      EXERCISE 1: INDEXED PRODUCT CATALOG         "
           DISPLAY "=================================================="

           PERFORM 1000-INITIALIZE-CATALOG
           PERFORM 2000-TEST-DUPLICATE
           PERFORM 3000-QUERY-PRODUCT
           PERFORM 4000-UPDATE-STOCK
           PERFORM 5000-DELETE-PRODUCT
           PERFORM 6000-CATALOG-AUDIT

           DISPLAY "=================================================="
           DISPLAY "Exercise 1 completed."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-INITIALIZE-CATALOG.
           DISPLAY "[STEP 1] Initializing catalog file..."
           OPEN OUTPUT CAT-FILE
           IF NOT STATUS-OK
               DISPLAY "[ERROR] Could not open catalog.idx for output."
               STOP RUN
           END-IF

           DISPLAY "[INFO] Writing catalog records..."
      *> TODO 2: Write 3 products into CAT-FILE:
      *> Item 1: ID="PRD001", Name="Ergonomic Chair", Qty=20, Price=199.50
      *> Item 2: ID="PRD002", Name="Standing Desk",    Qty=15, Price=349.00
      *> Item 3: ID="PRD003", Name="Desk Mat",         Qty=50, Price=19.99
           MOVE "PRD001" TO FD-CAT-ID
           MOVE "Ergonomic Chair" TO FD-CAT-NAME
           MOVE 20 TO FD-CAT-QTY
           MOVE 199.50 TO FD-CAT-PRICE
           WRITE CAT-RECORD

           MOVE "PRD002" TO FD-CAT-ID
           MOVE "Standing Desk" TO FD-CAT-NAME
           MOVE 15 TO FD-CAT-QTY
           MOVE 349.00 TO FD-CAT-PRICE
           WRITE CAT-RECORD

           MOVE "PRD003" TO FD-CAT-ID
           MOVE "Desk Mat" TO FD-CAT-NAME
           MOVE 50 TO FD-CAT-QTY
           MOVE 19.99 TO FD-CAT-PRICE
           WRITE CAT-RECORD

           CLOSE CAT-FILE
           DISPLAY "[INFO] 3 initial products written."
           DISPLAY " ".

       2000-TEST-DUPLICATE.
           DISPLAY "[STEP 2] Testing duplicate key protection..."
           OPEN I-O CAT-FILE
      *> TODO 3: Attempt to write PRD001 again with INVALID KEY handling
           MOVE "PRD001" TO FD-CAT-ID
           MOVE "Duplicate Chair" TO FD-CAT-NAME
           MOVE 5 TO FD-CAT-QTY
           MOVE 180.00 TO FD-CAT-PRICE
           WRITE CAT-RECORD
               INVALID KEY
                   DISPLAY "[EXPECTED] Duplicate key blocked! Status: " WS-CAT-STATUS
               NOT INVALID KEY
                   DISPLAY "[UNEXPECTED] Wrote duplicate product!"
           END-WRITE
           DISPLAY " ".

       3000-QUERY-PRODUCT.
           DISPLAY "[STEP 3] Querying product by primary key..."
      *> TODO 4: Look up PRD002 using READ ... INVALID KEY
           MOVE "PRD002" TO FD-CAT-ID
           READ CAT-FILE
               INVALID KEY
                   DISPLAY "[ERROR] Product PRD002 not found."
               NOT INVALID KEY
                   MOVE FD-CAT-PRICE TO DISP-PRICE
                   MOVE FD-CAT-QTY TO DISP-QTY
                   DISPLAY "Found: [" FD-CAT-ID "] " FD-CAT-NAME 
                           " | Stock: " DISP-QTY " | Price: " DISP-PRICE
           END-READ
           DISPLAY " ".

       4000-UPDATE-STOCK.
           DISPLAY "[STEP 4] Updating inventory quantity and price (REWRITE)..."
      *> TODO 5: Read PRD001, update Qty to 25 and Price to 189.99, then REWRITE
           MOVE "PRD001" TO FD-CAT-ID
           READ CAT-FILE
               NOT INVALID KEY
                   MOVE 25 TO FD-CAT-QTY
                   MOVE 189.99 TO FD-CAT-PRICE
                   REWRITE CAT-RECORD
                       INVALID KEY
                           DISPLAY "[ERROR] Failed to update PRD001."
                       NOT INVALID KEY
                           DISPLAY "[SUCCESS] PRD001 updated: Qty=25, Price=$189.99"
                   END-REWRITE
           END-READ
           DISPLAY " ".

       5000-DELETE-PRODUCT.
           DISPLAY "[STEP 5] Deleting discontinued product PRD003..."
      *> TODO 6: Delete PRD003 and verify Status 23 when trying to read it back
           MOVE "PRD003" TO FD-CAT-ID
           DELETE CAT-FILE RECORD
               INVALID KEY
                   DISPLAY "[ERROR] Delete failed."
               NOT INVALID KEY
                   DISPLAY "[SUCCESS] Deleted PRD003 from catalog."
           END-DELETE

           READ CAT-FILE
               INVALID KEY
                   DISPLAY "[EXPECTED] Verified PRD003 no longer exists (Status " WS-CAT-STATUS ")"
               NOT INVALID KEY
                   DISPLAY "[UNEXPECTED] PRD003 still exists!"
           END-READ
           DISPLAY " ".

       6000-CATALOG-AUDIT.
           DISPLAY "[STEP 6] Sequential audit of active inventory..."
           DISPLAY "----------------------------------------------------------------"
           DISPLAY "ID     | NAME                      | STOCK | PRICE    | TOTAL   "
           DISPLAY "----------------------------------------------------------------"

      *> TODO 7: Use START and READ NEXT to scan all active records
           MOVE LOW-VALUES TO FD-CAT-ID
           START CAT-FILE KEY >= FD-CAT-ID
               NOT INVALID KEY
                   MOVE "N" TO WS-EOF-FLAG
                   PERFORM UNTIL END-OF-FILE
                       READ CAT-FILE NEXT RECORD
                           AT END
                               MOVE "Y" TO WS-EOF-FLAG
                           NOT AT END
                               ADD 1 TO WS-TOTAL-ITEMS
                               COMPUTE WS-ITEM-VALUE = FD-CAT-QTY * FD-CAT-PRICE
                               ADD WS-ITEM-VALUE TO WS-CATALOG-VALUE

                               MOVE FD-CAT-PRICE TO DISP-PRICE
                               MOVE FD-CAT-QTY TO DISP-QTY
                               MOVE WS-ITEM-VALUE TO DISP-CAT-VALUE

                               DISPLAY FD-CAT-ID " | " FD-CAT-NAME " | "
                                       DISP-QTY " | " DISP-PRICE " | " DISP-CAT-VALUE
                       END-READ
                   END-PERFORM
           END-START

           CLOSE CAT-FILE
           MOVE WS-CATALOG-VALUE TO DISP-CAT-VALUE
           DISPLAY "----------------------------------------------------------------"
           DISPLAY "Active Unique Products : " WS-TOTAL-ITEMS
           DISPLAY "Total Catalog Value    : " DISP-CAT-VALUE.

