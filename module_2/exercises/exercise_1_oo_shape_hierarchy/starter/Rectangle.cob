>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 1 (STARTER): Rectangle.cob                            *
*> Subprogram calculating area of a rectangle                     *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Rectangle.

DATA DIVISION.
LINKAGE SECTION.
01 LS-WIDTH                   USAGE COMP-2.
01 LS-HEIGHT                  USAGE COMP-2.
01 LS-AREA                    USAGE COMP-2.

PROCEDURE DIVISION USING LS-WIDTH LS-HEIGHT LS-AREA.
    *> TODO: Compute LS-AREA = LS-WIDTH * LS-HEIGHT
    COMPUTE LS-AREA = LS-WIDTH * LS-HEIGHT.
    GOBACK.
