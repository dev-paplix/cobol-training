>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : NumericAndMath.cob                                   *
*> PURPOSE : Demonstrates binary data types and intrinsic math    *
*> COMPILE : cobc -x -free NumericAndMath.cob                     *
*> RUN     : ./NumericAndMath                                     *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. NumericAndMath.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> Native 32-bit and 64-bit binary machine integers
01 INT-VAL-A                  PIC S9(9) USAGE BINARY VALUE 450.
01 INT-VAL-B                  PIC S9(9) USAGE BINARY VALUE 890.
01 INT-RESULT                 PIC S9(9) USAGE BINARY.

*> Floating point for scientific formulas
01 FLT-INPUT                  USAGE COMP-2 VALUE 144.0.
01 FLT-SQRT-RESULT            USAGE COMP-2.
01 FLT-MOD-RESULT             PIC 9(4).

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       GNUCOBOL NUMERIC & INTRINSIC MATH DEMO             ".
    DISPLAY "==========================================================".

    *> 1. Comparison via FUNCTION MAX and MIN
    COMPUTE INT-RESULT = FUNCTION MAX(INT-VAL-A, INT-VAL-B).
    DISPLAY "Max of " INT-VAL-A " and " INT-VAL-B " = " INT-RESULT.

    COMPUTE INT-RESULT = FUNCTION MIN(INT-VAL-A, INT-VAL-B).
    DISPLAY "Min of " INT-VAL-A " and " INT-VAL-B " = " INT-RESULT.

    *> 2. Absolute Value
    MOVE -999 TO INT-VAL-A.
    COMPUTE INT-RESULT = FUNCTION ABS(INT-VAL-A).
    DISPLAY "Abs of -999 = " INT-RESULT.

    *> 3. Square Root via FUNCTION SQRT
    COMPUTE FLT-SQRT-RESULT = FUNCTION SQRT(FLT-INPUT).
    DISPLAY "Square Root of " FLT-INPUT " = " FLT-SQRT-RESULT.

    *> 4. Modulo Arithmetic via FUNCTION MOD
    COMPUTE FLT-MOD-RESULT = FUNCTION MOD(29, 5).
    DISPLAY "Modulo 29 mod 5 = " FLT-MOD-RESULT.

    DISPLAY "==========================================================".
    GOBACK.
