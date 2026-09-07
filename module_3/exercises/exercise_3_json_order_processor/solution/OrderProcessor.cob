       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. OrderProcessor.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> EXERCISE 3 (SOLUTION): JSON Order Processor & XML Slip*
      *> Ingests raw JSON stream, performs financial tax and   *
      *> approval computations, and emits an XML slip.        *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Raw Input Stream
       01  RAW-JSON-STREAM           PIC X(256) VALUE
           '{"order_id": 88401, "customer": "Global Supplies Ltd", "subtotal": 1250.00}'.

      *> Parsing Token Buffers
       01  WS-TOKEN-1                PIC X(64).
       01  WS-TOKEN-2                PIC X(64).
       01  WS-TOKEN-3                PIC X(64).
       01  WS-KEY                    PIC X(32).
       01  WS-VAL                    PIC X(32).
       01  WS-PTR                    PIC 9(4) VALUE 2.

      *> Internal Calculation Variables
       01  WS-ORD-ID                 PIC 9(6).
       01  WS-CUST-NAME              PIC X(25).
       01  WS-SUBTOTAL               PIC 9(6)V99.
       01  WS-TAX                    PIC 9(5)V99.
       01  WS-TOTAL                  PIC 9(6)V99.
       01  WS-STATUS                 PIC X(12).

      *> Hierarchical Output Record for XML Generation
       01  ORDER-CONFIRMATION.
           05  CONFIRMATION-ID       PIC 9(6).
           05  CLIENT-NAME           PIC X(25).
           05  BILLING.
               10  SUB-TOTAL         PIC 9(6)V99.
               10  SALES-TAX         PIC 9(5)V99.
               10  FINAL-TOTAL       PIC 9(6)V99.
           05  APPROVAL-STATUS       PIC X(12).

      *> XML Output Buffers
       01  WS-XML-OUTPUT             PIC X(1024) VALUE SPACES.
       01  WS-XML-LEN                PIC 9(4) BINARY VALUE 0.

      *> Display formatting
       01  DISP-SUBTOTAL             PIC $$$,$$9.99.
       01  DISP-TAX                  PIC $$$,$$9.99.
       01  DISP-TOTAL                PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "   EXERCISE 3: JSON ORDER PROCESSOR & XML SLIP    "
           DISPLAY "=================================================="

           PERFORM 1000-PARSE-JSON
           PERFORM 2000-CALCULATE-FINANCIALS
           PERFORM 3000-GENERATE-XML-CONFIRMATION

           DISPLAY "=================================================="
           DISPLAY "Exercise 3 completed successfully."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-PARSE-JSON.
           DISPLAY "[STEP 1] Ingesting JSON order stream..."
           DISPLAY "Raw JSON: " FUNCTION TRIM(RAW-JSON-STREAM)
           DISPLAY " "

           MOVE 2 TO WS-PTR
           UNSTRING RAW-JSON-STREAM
               DELIMITED BY "," OR "}"
               INTO WS-TOKEN-1
                    WS-TOKEN-2
                    WS-TOKEN-3
               WITH POINTER WS-PTR
           END-UNSTRING

           UNSTRING WS-TOKEN-1 DELIMITED BY ":" INTO WS-KEY WS-VAL
           MOVE FUNCTION NUMVAL(WS-VAL) TO WS-ORD-ID

           UNSTRING WS-TOKEN-2 DELIMITED BY ":" INTO WS-KEY WS-VAL
           INSPECT WS-VAL REPLACING ALL '"' BY ' '
           MOVE FUNCTION TRIM(WS-VAL) TO WS-CUST-NAME

           UNSTRING WS-TOKEN-3 DELIMITED BY ":" INTO WS-KEY WS-VAL
           MOVE FUNCTION NUMVAL(WS-VAL) TO WS-SUBTOTAL

           DISPLAY "[INFO] JSON Successfully Parsed:"
           DISPLAY "  Order ID  : " WS-ORD-ID
           DISPLAY "  Customer  : " FUNCTION TRIM(WS-CUST-NAME)
           MOVE WS-SUBTOTAL TO DISP-SUBTOTAL
           DISPLAY "  Subtotal  : " DISP-SUBTOTAL
           DISPLAY " ".

       2000-CALCULATE-FINANCIALS.
           DISPLAY "[STEP 2] Executing financial business logic..."
           COMPUTE WS-TAX ROUNDED = WS-SUBTOTAL * 0.08
           COMPUTE WS-TOTAL = WS-SUBTOTAL + WS-TAX

           IF WS-TOTAL > 5000.00
               MOVE "REVIEW_REQ" TO WS-STATUS
           ELSE
               MOVE "APPROVED" TO WS-STATUS
           END-IF

           MOVE WS-TAX TO DISP-TAX
           MOVE WS-TOTAL TO DISP-TOTAL
           DISPLAY "  Sales Tax (8%) : " DISP-TAX
           DISPLAY "  Final Total    : " DISP-TOTAL
           DISPLAY "  Status Code    : " WS-STATUS
           DISPLAY " ".

       3000-GENERATE-XML-CONFIRMATION.
           DISPLAY "[STEP 3] Emitting XML confirmation slip..."
           MOVE WS-ORD-ID TO CONFIRMATION-ID
           MOVE WS-CUST-NAME TO CLIENT-NAME
           MOVE WS-SUBTOTAL TO SUB-TOTAL OF BILLING
           MOVE WS-TAX TO SALES-TAX OF BILLING
           MOVE WS-TOTAL TO FINAL-TOTAL OF BILLING
           MOVE WS-STATUS TO APPROVAL-STATUS

           XML GENERATE WS-XML-OUTPUT FROM ORDER-CONFIRMATION
               COUNT IN WS-XML-LEN
               ON EXCEPTION
                   DISPLAY "[ERROR] XML generation error: " XML-CODE
           END-XML

           IF XML-CODE = 0
               DISPLAY "Generated XML Confirmation (" WS-XML-LEN " bytes):"
               DISPLAY "--------------------------------------------------"
               DISPLAY WS-XML-OUTPUT(1:WS-XML-LEN)
               DISPLAY "--------------------------------------------------"
           END-IF.

