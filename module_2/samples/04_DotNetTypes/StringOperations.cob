>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : StringOperations.cob                                 *
*> PURPOSE : Demonstrates modern string operations in GnuCOBOL    *
*>           (UNSTRING, STRING, Intrinsic Functions)              *
*> COMPILE : cobc -x -free StringOperations.cob                   *
*> RUN     : ./StringOperations                                   *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. StringOperations.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-RAW-TEXT                PIC X(40) VALUE "   Enterprise GnuCOBOL on Linux 2026   ".
01 WS-CLEAN-TEXT              PIC X(40).
01 WS-UPPER-TEXT              PIC X(40).
01 WS-LOWER-TEXT              PIC X(40).
01 WS-CONCAT-RESULT           PIC X(80).

*> Fields for UNSTRING demonstration
01 WS-CSV-LINE                PIC X(60) VALUE "USR-8821,John,Hopper,Admin".
01 WS-USER-ID                 PIC X(10).
01 WS-FIRST-NAME              PIC X(15).
01 WS-LAST-NAME               PIC X(15).
01 WS-ROLE                    PIC X(10).

01 WS-LEN                     PIC 9(3).

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       ADVANCED STRING OPERATIONS IN GNUCOBOL             ".
    DISPLAY "==========================================================".

    *> 1. Trimming Whitespace via FUNCTION TRIM
    MOVE FUNCTION TRIM(WS-RAW-TEXT) TO WS-CLEAN-TEXT.
    DISPLAY "Raw Text     : [" WS-RAW-TEXT "]".
    DISPLAY "Trimmed Text : [" FUNCTION TRIM(WS-CLEAN-TEXT) "]".

    *> 2. Case Conversion
    MOVE FUNCTION UPPER-CASE(WS-CLEAN-TEXT) TO WS-UPPER-TEXT.
    MOVE FUNCTION LOWER-CASE(WS-CLEAN-TEXT) TO WS-LOWER-TEXT.
    DISPLAY "Uppercase    : " FUNCTION TRIM(WS-UPPER-TEXT).
    DISPLAY "Lowercase    : " FUNCTION TRIM(WS-LOWER-TEXT).

    *> 3. Measuring String Length
    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-CLEAN-TEXT)).
    DISPLAY "Trimmed Len  : " WS-LEN " characters".
    DISPLAY "----------------------------------------------------------".

    *> 4. Parsing Delimited Data via UNSTRING
    DISPLAY "Parsing CSV: " WS-CSV-LINE.
    UNSTRING WS-CSV-LINE DELIMITED BY ","
        INTO WS-USER-ID
             WS-FIRST-NAME
             WS-LAST-NAME
             WS-ROLE.

    DISPLAY "  User ID   : " FUNCTION TRIM(WS-USER-ID).
    DISPLAY "  First Name: " FUNCTION TRIM(WS-FIRST-NAME).
    DISPLAY "  Last Name : " FUNCTION TRIM(WS-LAST-NAME).
    DISPLAY "  User Role : " FUNCTION TRIM(WS-ROLE).
    DISPLAY "----------------------------------------------------------".

    *> 5. Formatted Joining via STRING
    STRING "Greetings, " DELIMITED BY SIZE
           FUNCTION TRIM(WS-FIRST-NAME) DELIMITED BY SIZE
           " " DELIMITED BY SIZE
           FUNCTION TRIM(WS-LAST-NAME) DELIMITED BY SIZE
           "! Welcome to GnuCOBOL." DELIMITED BY SIZE
           INTO WS-CONCAT-RESULT.

    DISPLAY "Concatenated : " FUNCTION TRIM(WS-CONCAT-RESULT).
    DISPLAY "==========================================================".
    GOBACK.
