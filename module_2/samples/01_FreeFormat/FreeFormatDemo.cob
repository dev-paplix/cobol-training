>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : FreeFormatDemo.cob                                   *
*> PURPOSE : Demonstrates modern free-format GnuCOBOL features    *
*> COMPILE : cobc -x -free FreeFormatDemo.cob                     *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. FreeFormatDemo.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> Clean indentation and modern comments
    01 WS-MODERN-TITLE     PIC X(60) VALUE 
       "Welcome to Modern Free-Format GnuCOBOL!".
    
    01 WS-EXPLANATION      PIC X(180) VALUE 
       "In free-format mode, statements start in any column, " &
       "lines extend up to 255 characters, and inline comments " &
       "use '*>' anywhere on the line.".

    01 WS-COUNT            PIC 9(2) VALUE 1.

PROCEDURE DIVISION.
MainLogic.
    DISPLAY "==========================================================".
    DISPLAY WS-MODERN-TITLE.
    DISPLAY "==========================================================".
    DISPLAY WS-EXPLANATION.
    DISPLAY "----------------------------------------------------------".

    *> Performing inline logic with comments
    PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > 3
        DISPLAY "  -> Iteration Counter: " WS-COUNT *> Modern inline comment!
    END-PERFORM.

    DISPLAY "==========================================================".
    DISPLAY "Execution complete.".
    GOBACK.
