>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 1 (STARTER): Shape.cob                                *
*> Generic shape dispatcher or record descriptor                  *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Shape.

DATA DIVISION.
LINKAGE SECTION.
01 LS-SHAPE-TYPE              PIC X(10).
01 LS-DIM-1                   USAGE COMP-2.
01 LS-DIM-2                   USAGE COMP-2.
01 LS-CALCULATED-AREA         USAGE COMP-2.

PROCEDURE DIVISION USING LS-SHAPE-TYPE LS-DIM-1 LS-DIM-2 LS-CALCULATED-AREA.
    EVALUATE FUNCTION UPPER-CASE(FUNCTION TRIM(LS-SHAPE-TYPE))
        WHEN "RECTANGLE"
            CALL "Rectangle" USING LS-DIM-1 LS-DIM-2 LS-CALCULATED-AREA
        WHEN "CIRCLE"
            CALL "Circle" USING LS-DIM-1 LS-CALCULATED-AREA
        WHEN OTHER
            MOVE 0.0 TO LS-CALCULATED-AREA
    END-EVALUATE.
    GOBACK.
