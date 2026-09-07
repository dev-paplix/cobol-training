>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 1 (STARTER): Circle.cob                               *
*> Subprogram calculating area of a circle (PI * r * r)           *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Circle.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-PI                      USAGE COMP-2 VALUE 3.141592653589793.

LINKAGE SECTION.
01 LS-RADIUS                  USAGE COMP-2.
01 LS-AREA                    USAGE COMP-2.

PROCEDURE DIVISION USING LS-RADIUS LS-AREA.
    *> TODO: Compute circle area using formula: PI * Radius * Radius
    COMPUTE LS-AREA = WS-PI * LS-RADIUS * LS-RADIUS.
    GOBACK.
