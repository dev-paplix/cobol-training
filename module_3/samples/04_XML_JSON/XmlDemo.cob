       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. XmlDemo.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates XML generation in modern GnuCOBOL using *
      *> native XML GENERATE from hierarchical group items.   *
      *>                                                      *
      *> Command: cobc -x -free XmlDemo.cob                   *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Hierarchical COBOL Data Structure
       01  CUSTOMER-ORDER.
           05  ORDER-ID              PIC 9(6) VALUE 450123.
           05  CUSTOMER-DETAILS.
               10  CUST-CODE         PIC X(8) VALUE "CUST-99".
               10  COMPANY-NAME      PIC X(24) VALUE "Apex Industrial Supply".
               10  CONTACT-EMAIL     PIC X(25) VALUE "orders@apexsupply.com".
           05  FINANCIALS.
               10  SUB-TOTAL         PIC 9(5)V99 VALUE 2340.50.
               10  TAX-AMOUNT        PIC 9(4)V99 VALUE 187.24.
               10  GRAND-TOTAL       PIC 9(5)V99 VALUE 2527.74.
           05  ORDER-STATUS          PIC X(10) VALUE "APPROVED".

      *> Buffers for XML Output
       01  WS-XML-OUTPUT             PIC X(1024) VALUE SPACES.
       01  WS-XML-LENGTH             PIC 9(4) BINARY VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "       NATIVE XML GENERATE STREAMING DEMO         "
           DISPLAY "=================================================="

           DISPLAY "[INFO] Populating hierarchical data structure..."
           DISPLAY "  Order ID     : " ORDER-ID
           DISPLAY "  Company Name : " COMPANY-NAME
           DISPLAY "  Grand Total  : $" GRAND-TOTAL
           DISPLAY "  Status       : " ORDER-STATUS
           DISPLAY " "

           DISPLAY "[INFO] Executing XML GENERATE..."
           XML GENERATE WS-XML-OUTPUT FROM CUSTOMER-ORDER
               COUNT IN WS-XML-LENGTH
               ON EXCEPTION
                   DISPLAY "[ERROR] XML Generation failed with code: " XML-CODE
                   STOP RUN
               NOT ON EXCEPTION
                   DISPLAY "[SUCCESS] XML Document generated (" WS-XML-LENGTH " bytes):"
                   DISPLAY "--------------------------------------------------"
                   DISPLAY WS-XML-OUTPUT(1:WS-XML-LENGTH)
                   DISPLAY "--------------------------------------------------"
           END-XML.

           DISPLAY " "
           DISPLAY "XML generation completed successfully."
           DISPLAY "=================================================="
           STOP RUN.

