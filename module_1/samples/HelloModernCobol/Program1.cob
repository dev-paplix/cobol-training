       >>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : Program1.cob                                         *
*> PURPOSE : First modern GnuCOBOL console application            *
*> COMPILE : cobc -x -free Program1.cob -o HelloModernCobol       *
*>           (or simply: cobc -x Program1.cob -o HelloModernCobol)*
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Program1.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> User Input Variables
01 WS-USER-NAME               PIC X(30).
01 WS-CLEAN-NAME              PIC X(30).
01 WS-BIRTH-YEAR-ALPHA        PIC X(4).
01 WS-BIRTH-YEAR              PIC 9(4).

*> Date and Time Extraction via FUNCTION CURRENT-DATE
01 WS-CURRENT-DATE-DATA.
   05 WS-CURRENT-YEAR         PIC 9(4).
   05 WS-CURRENT-MONTH        PIC 9(2).
   05 WS-CURRENT-DAY          PIC 9(2).
   05 WS-CURRENT-HOUR         PIC 9(2).
   05 WS-CURRENT-MINUTE       PIC 9(2).
   05 WS-CURRENT-SECOND       PIC 9(2).
   05 FILLER                  PIC X(9).

*> Numeric Calculation Variables
01 WS-CALCULATED-AGE          PIC S9(4) USAGE BINARY.
01 WS-DISPLAY-AGE             PIC Z,ZZ9.

PROCEDURE DIVISION.
MAIN-PARAGRAPH.
    *> 1. Display Formatted Header
    DISPLAY "==========================================================".
    DISPLAY "             WELCOME TO MODERN GNUCOBOL".
    DISPLAY "==========================================================".

    *> 2. Fetch System Date and Time
    MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-DATA.
    DISPLAY "Current Date : " WS-CURRENT-YEAR "-" WS-CURRENT-MONTH "-" WS-CURRENT-DAY.
    DISPLAY "Current Time : " WS-CURRENT-HOUR ":" WS-CURRENT-MINUTE ":" WS-CURRENT-SECOND.
    DISPLAY "----------------------------------------------------------".

    *> 3. Collect Interactive User Input
    DISPLAY "Enter your full name: " WITH NO ADVANCING.
    ACCEPT WS-USER-NAME.
    MOVE FUNCTION TRIM(WS-USER-NAME) TO WS-CLEAN-NAME.

    DISPLAY "Enter your birth year (e.g. 1990): " WITH NO ADVANCING.
    ACCEPT WS-BIRTH-YEAR-ALPHA.
    MOVE FUNCTION NUMVAL(WS-BIRTH-YEAR-ALPHA) TO WS-BIRTH-YEAR.

    *> 4. Perform Business Logic
    COMPUTE WS-CALCULATED-AGE = WS-CURRENT-YEAR - WS-BIRTH-YEAR.
    MOVE WS-CALCULATED-AGE TO WS-DISPLAY-AGE.

    *> 5. Display Summary Card
    DISPLAY "----------------------------------------------------------".
    DISPLAY "Hello, " FUNCTION TRIM(WS-CLEAN-NAME) "!".
    DISPLAY "In " WS-CURRENT-YEAR ", you turn approximately " 
            FUNCTION TRIM(WS-DISPLAY-AGE) " years old.".
    DISPLAY "==========================================================".

    GOBACK.
