>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 2 (STARTER): TransactionParser.cob                    *
*> Cleans, unstrings, and normalizes raw delimited records        *
*> COMPILE : cobc -x -free TransactionParser.cob                  *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. TransactionParser.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-RAW-TRANSACTION         PIC X(60) 
   VALUE "TXN-9021;acct-8492;1250.75;deposit".

*> Extracted Raw Tokens
01 WS-TXN-ID                  PIC X(10).
01 WS-ACCT-ID                 PIC X(10).
01 WS-AMOUNT-STR              PIC X(12).
01 WS-TYPE                    PIC X(10).

*> Cleaned & Normalized Fields
01 WS-NORM-ACCT               PIC X(10).
01 WS-NORM-TYPE               PIC X(10).
01 WS-NUMERIC-AMOUNT          PIC 9(6)V99.
01 DISP-AMOUNT                PIC $ZZZ,ZZ9.99.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       EXERCISE 2 (STARTER): STRING PARSER & NORMALIZER   ".
    DISPLAY "==========================================================".
    DISPLAY "Raw Input: [" FUNCTION TRIM(WS-RAW-TRANSACTION) "]".

    *> TODO 1: Use UNSTRING to separate WS-RAW-TRANSACTION by ";" into:
    *>         WS-TXN-ID, WS-ACCT-ID, WS-AMOUNT-STR, WS-TYPE
    UNSTRING WS-RAW-TRANSACTION DELIMITED BY ";"
        INTO WS-TXN-ID
             WS-ACCT-ID
             WS-AMOUNT-STR
             WS-TYPE.

    *> TODO 2: Normalize WS-ACCT-ID to uppercase and trimmed
    MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-ACCT-ID)) TO WS-NORM-ACCT.

    *> TODO 3: Normalize WS-TYPE to uppercase
    MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TYPE)) TO WS-NORM-TYPE.

    *> TODO 4: Parse WS-AMOUNT-STR into numeric WS-NUMERIC-AMOUNT using FUNCTION NUMVAL
    COMPUTE WS-NUMERIC-AMOUNT = FUNCTION NUMVAL(WS-AMOUNT-STR).
    MOVE WS-NUMERIC-AMOUNT TO DISP-AMOUNT.

    *> TODO 5: Print formatted transaction confirmation receipt
    DISPLAY "----------------------------------------------------------".
    DISPLAY "Transaction Reference : " FUNCTION TRIM(WS-TXN-ID).
    DISPLAY "Target Account        : " FUNCTION TRIM(WS-NORM-ACCT).
    DISPLAY "Transaction Type      : " FUNCTION TRIM(WS-NORM-TYPE).
    DISPLAY "Processed Amount      : " DISP-AMOUNT.
    DISPLAY "==========================================================".
    GOBACK.
