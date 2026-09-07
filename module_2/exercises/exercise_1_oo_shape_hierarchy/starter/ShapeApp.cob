>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 1 (STARTER): ShapeApp.cob                             *
*> Main Driver calling geometry subprograms                       *
*> COMPILE : cobc -x -free ShapeApp.cob Rectangle.cob Circle.cob  *
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
    DISPLAY "       EXERCISE 1: MODULAR GNUCOBOL SHAPE APP             ".
    DISPLAY "==========================================================".

    *> TODO 1: Call "Rectangle" subprogram passing Width, Height, and Area
    CALL "Rectangle" USING WS-RECT-WIDTH 
                           WS-RECT-HEIGHT 
                           WS-RECT-AREA.
    DISPLAY "Rectangle (10 x 5) -> Area: " WS-RECT-AREA.

    *> TODO 2: Call "Circle" subprogram passing Radius and Area
    CALL "Circle" USING WS-CIRCLE-RADIUS 
                        WS-CIRCLE-AREA.
    DISPLAY "Circle (Radius 7)  -> Area: " WS-CIRCLE-AREA.

    DISPLAY "==========================================================".
    GOBACK.
