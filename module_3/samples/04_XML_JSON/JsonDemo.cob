       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. JsonDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates JSON serialization and parsing in       *
      *> standard GnuCOBOL using STRING and UNSTRING.         *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *>------------------------------------------------------*
      *> Part 1: Outbound Serialization Structures            *
      *>------------------------------------------------------*
       01  OUT-ORDER.
           05  OUT-ORD-ID            PIC 9(5) VALUE 77201.
           05  OUT-CUSTOMER          PIC X(20) VALUE "Cyberdyne Systems".
           05  OUT-ITEM-COUNT        PIC 9(3) VALUE 14.
           05  OUT-TOTAL-AMOUNT      PIC 9(5)V99 VALUE 1250.75.
           05  OUT-STATUS            PIC X(10) VALUE "CONFIRMED".

       01  FMT-AMOUNT                PIC ZZZZ9.99.
       01  WS-JSON-OUT               PIC X(512) VALUE SPACES.
       01  WS-OUT-PTR                PIC 9(4) VALUE 1.

      *>------------------------------------------------------*
      *> Part 2: Inbound Deserialization Structures           *
      *>------------------------------------------------------*
       01  IN-RAW-JSON               PIC X(256) VALUE
           '{"invoice_no": 99420, "vendor": "Stark Industries", "subtotal": 8450.00, "paid": "Y"}'.

       01  WS-TOKEN-1                PIC X(64).
       01  WS-TOKEN-2                PIC X(64).
       01  WS-TOKEN-3                PIC X(64).
       01  WS-TOKEN-4                PIC X(64).

       01  WS-KEY                    PIC X(32).
       01  WS-VAL                    PIC X(32).
       01  WS-PTR                    PIC 9(4) VALUE 2.

       01  WS-INV-NO                 PIC 9(5).
       01  WS-VENDOR                 PIC X(25).
       01  WS-SUBTOTAL               PIC 9(6)V99.
       01  WS-PAID-FLAG              PIC X.
       01  WS-DISCOUNT-AMT           PIC 9(5)V99.
       01  WS-NET-DUE                PIC 9(6)V99.

       01  DISP-SUBTOTAL             PIC $$$,$$9.99.
       01  DISP-DISCOUNT             PIC $$$,$$9.99.
       01  DISP-NET                  PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "         JSON SERIALIZATION & PARSING DEMO        "
           DISPLAY "=================================================="

           PERFORM 1000-JSON-SERIALIZE
           PERFORM 2000-JSON-DESERIALIZE

           DISPLAY "=================================================="
           DISPLAY "JSON processing completed successfully."
           STOP RUN.

       1000-JSON-SERIALIZE.
           DISPLAY "[PART 1] Serializing COBOL record into JSON..."
           MOVE OUT-TOTAL-AMOUNT TO FMT-AMOUNT
           MOVE 1 TO WS-OUT-PTR
           MOVE SPACES TO WS-JSON-OUT

           STRING
               '{"order_id": '
               FUNCTION TRIM(OUT-ORD-ID)
               ', "customer": "'
               FUNCTION TRIM(OUT-CUSTOMER)
               '", "items": '
               FUNCTION TRIM(OUT-ITEM-COUNT)
               ', "amount": '
               FUNCTION TRIM(FMT-AMOUNT)
               ', "status": "'
               FUNCTION TRIM(OUT-STATUS)
               '"}'
               DELIMITED BY SIZE
               INTO WS-JSON-OUT
               WITH POINTER WS-OUT-PTR
           END-STRING

           DISPLAY "Generated JSON string:"
           DISPLAY "--------------------------------------------------"
           DISPLAY FUNCTION TRIM(WS-JSON-OUT)
           DISPLAY "--------------------------------------------------"
           DISPLAY " ".

       2000-JSON-DESERIALIZE.
           DISPLAY "[PART 2] Deserializing incoming JSON payload..."
           DISPLAY "Raw Incoming Stream:"
           DISPLAY FUNCTION TRIM(IN-RAW-JSON)
           DISPLAY " "

           *> Step 1: Split JSON object properties delimited by comma or closing brace
           MOVE 2 TO WS-PTR
           UNSTRING IN-RAW-JSON
               DELIMITED BY "," OR "}"
               INTO WS-TOKEN-1
                    WS-TOKEN-2
                    WS-TOKEN-3
                    WS-TOKEN-4
               WITH POINTER WS-PTR
           END-UNSTRING

           *> Step 2: Extract invoice_no
           UNSTRING WS-TOKEN-1 DELIMITED BY ":" INTO WS-KEY WS-VAL
           MOVE FUNCTION NUMVAL(WS-VAL) TO WS-INV-NO

           *> Step 3: Extract vendor
           UNSTRING WS-TOKEN-2 DELIMITED BY ":" INTO WS-KEY WS-VAL
           INSPECT WS-VAL REPLACING ALL '"' BY ' '
           MOVE FUNCTION TRIM(WS-VAL) TO WS-VENDOR

           *> Step 4: Extract subtotal
           UNSTRING WS-TOKEN-3 DELIMITED BY ":" INTO WS-KEY WS-VAL
           MOVE FUNCTION NUMVAL(WS-VAL) TO WS-SUBTOTAL

           *> Step 5: Extract paid flag
           UNSTRING WS-TOKEN-4 DELIMITED BY ":" INTO WS-KEY WS-VAL
           INSPECT WS-VAL REPLACING ALL '"' BY ' '
           MOVE FUNCTION TRIM(WS-VAL) TO WS-PAID-FLAG

           DISPLAY "Successfully Parsed Fields:"
           DISPLAY "  Invoice Number : " WS-INV-NO
           DISPLAY "  Vendor Name    : " FUNCTION TRIM(WS-VENDOR)
           MOVE WS-SUBTOTAL TO DISP-SUBTOTAL
           DISPLAY "  Subtotal Amount: " DISP-SUBTOTAL
           DISPLAY "  Paid Flag      : " WS-PAID-FLAG

           *> Apply business logic: 5% early payment discount if paid
           IF WS-PAID-FLAG = "Y"
               COMPUTE WS-DISCOUNT-AMT ROUNDED = WS-SUBTOTAL * 0.05
               COMPUTE WS-NET-DUE = WS-SUBTOTAL - WS-DISCOUNT-AMT
               MOVE WS-DISCOUNT-AMT TO DISP-DISCOUNT
               MOVE WS-NET-DUE TO DISP-NET
               DISPLAY "  Early Disc(5%) : -" DISP-DISCOUNT
               DISPLAY "  Net Total Due  : " DISP-NET
           ELSE
               MOVE WS-SUBTOTAL TO DISP-NET
               DISPLAY "  Net Total Due  : " DISP-NET
           END-IF
           DISPLAY " ".

