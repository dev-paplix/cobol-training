>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 2 (SOLUTION): TransactionParser.cob                  *
*> Full data parsing, cleansing, and normalization                *
*> COMPILE : cobc -x -free TransactionParser.cob                  *
*> RUN     : ./TransactionParser                                  *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. TransactionParser.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-RAW-TRANSACTION         PIC X(80) 
   VALUE '  "TXN-9021;acct-8492;1250.75;deposit"  '.
01 WS-CLEAN-LINE              PIC X(80).

*> Extracted Raw Tokens
01 WS-TXN-ID                  PIC X(15).
01 WS-ACCT-ID                 PIC X(15).
01 WS-AMOUNT-STR              PIC X(15).
01 WS-TYPE                    PIC X(15).

*> Cleaned & Normalized Business Fields
01 WS-NORM-ACCT               PIC X(15).
01 WS-NORM-TYPE               PIC X(15).
01 WS-NUMERIC-AMOUNT          PIC 9(7)V99.
01 DISP-AMOUNT                PIC $ZZZ,ZZ9.99.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "     EXERCISE 2 SOLUTION: STRING PARSING & NORMALIZATION  ".
    DISPLAY "==========================================================".
    DISPLAY "Raw Input: [" FUNCTION TRIM(WS-RAW-TRANSACTION) "]".

    *> 1. Strip whitespace and quotes
    MOVE FUNCTION SUBSTITUTE(FUNCTION TRIM(WS-RAW-TRANSACTION), '"', '') 
        TO WS-CLEAN-LINE.

    *> 2. Split fields using UNSTRING
    UNSTRING WS-CLEAN-LINE DELIMITED BY ";"
        INTO WS-TXN-ID
             WS-ACCT-ID
             WS-AMOUNT-STR
             WS-TYPE.

    *> 3. Normalize Account ID to Uppercase
    MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-ACCT-ID)) TO WS-NORM-ACCT.

    *> 4. Normalize Transaction Type to Uppercase
    MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TYPE)) TO WS-NORM-TYPE.

    *> 5. Parse Amount into numeric value via FUNCTION NUMVAL
    COMPUTE WS-NUMERIC-AMOUNT = FUNCTION NUMVAL(WS-AMOUNT-STR).
    MOVE WS-NUMERIC-AMOUNT TO DISP-AMOUNT.

    *> 6. Format and Display Clean Receipt
    DISPLAY "----------------------------------------------------------".
    DISPLAY "              CLEANED TRANSACTION RECEIPT                 ".
    DISPLAY "----------------------------------------------------------".
    DISPLAY "Transaction Reference : " FUNCTION TRIM(WS-TXN-ID).
    DISPLAY "Target Account        : " FUNCTION TRIM(WS-NORM-ACCT).
    DISPLAY "Transaction Type      : " FUNCTION TRIM(WS-NORM-TYPE).
    DISPLAY "Processed Amount      : " DISP-AMOUNT.
    DISPLAY "==========================================================".
    GOBACK.
