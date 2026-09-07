>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 1 (SOLUTION): ShapeApp.cob                            *
*> Main Driver calling geometry subprograms                       *
*> COMPILE : cobc -x -free ShapeApp.cob Rectangle.cob Circle.cob  *
*> RUN     : ./ShapeApp                                           *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. ShapeApp.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-RECT-WIDTH              USAGE COMP-2 VALUE 10.0.
01 WS-RECT-HEIGHT             USAGE COMP-2 VALUE 5.0.
01 WS-RECT-AREA               USAGE COMP-2.

01 WS-CIRCLE-RADIUS           USAGE COMP-2 VALUE 7.0.
01 WS-CIRCLE-AREA             USAGE COMP-2.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       EXERCISE 1 SOLUTION: MODULAR GEOMETRY APP          ".
    DISPLAY "==========================================================".

    *> 1. Invoke Rectangle Subprogram
    CALL "Rectangle" USING WS-RECT-WIDTH 
                           WS-RECT-HEIGHT 
                           WS-RECT-AREA.
    DISPLAY "Rectangle (Width: 10.0, Height: 5.0) -> Area: " WS-RECT-AREA.

    *> 2. Invoke Circle Subprogram
    CALL "Circle" USING WS-CIRCLE-RADIUS 
                        WS-CIRCLE-AREA.
    DISPLAY "Circle    (Radius: 7.0)              -> Area: " WS-CIRCLE-AREA.

    DISPLAY "==========================================================".
    GOBACK.
