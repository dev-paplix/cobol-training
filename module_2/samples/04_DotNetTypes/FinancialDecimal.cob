>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : FinancialDecimal.cob                                 *
*> PURPOSE : Demonstrates financial precision with COMP-3 vs      *
*>           floating point binary inaccuracies                   *
*> COMPILE : cobc -x -free FinancialDecimal.cob                   *
*> RUN     : ./FinancialDecimal                                   *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. FinancialDecimal.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> 1. Hardware Floating Point (Demonstrating Roundoff Drift)
01 FLT-ACCUMULATOR            USAGE COMP-1 VALUE 0.0.
01 FLT-ADDEND                 USAGE COMP-1 VALUE 0.1.
01 LOOP-INDEX                 PIC 9(2).

*> 2. Exact Packed Decimal (COMP-3)
01 EXACT-ACCUMULATOR          PIC S9(7)V99 COMP-3 VALUE 0.00.
01 EXACT-ADDEND               PIC S9(1)V99 COMP-3 VALUE 0.10.

*> 3. High-Precision Banking Calculation
01 WS-PRINCIPAL               PIC S9(9)V99 COMP-3 VALUE 1250500.85.
01 WS-INTEREST-RATE           PIC V9999    COMP-3 VALUE 0.0525.
01 WS-INTEREST-EARNED         PIC S9(9)V99 COMP-3.
01 WS-TOTAL-MATURITY          PIC S9(9)V99 COMP-3.

01 DISP-EXACT                 PIC $ZZZ,ZZ9.99.
01 DISP-PRINCIPAL             PIC $Z,ZZZ,ZZ9.99.
01 DISP-INTEREST              PIC $ZZZ,ZZ9.99.
01 DISP-TOTAL                 PIC $Z,ZZZ,ZZ9.99.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       FINANCIAL DECIMAL VS FLOATING POINT PRECISION      ".
    DISPLAY "==========================================================".

    *> Adding 0.10 ten times: Expect exactly 1.00!
    PERFORM VARYING LOOP-INDEX FROM 1 BY 1 UNTIL LOOP-INDEX > 10
        ADD FLT-ADDEND TO FLT-ACCUMULATOR
        ADD EXACT-ADDEND TO EXACT-ACCUMULATOR
    END-PERFORM.

    DISPLAY "Adding 0.10 ten times:".
    DISPLAY "  Float (COMP-1) Result : " FLT-ACCUMULATOR 
            " (Shows IEEE base-2 drift!)".
    MOVE EXACT-ACCUMULATOR TO DISP-EXACT.
    DISPLAY "  COMP-3 Decimal Result : " DISP-EXACT 
            " (Exact 1.00 - Safe for Banking!)".
    DISPLAY "----------------------------------------------------------".

    *> High-Precision Interest Calculation
    COMPUTE WS-INTEREST-EARNED ROUNDED = WS-PRINCIPAL * WS-INTEREST-RATE.
    COMPUTE WS-TOTAL-MATURITY = WS-PRINCIPAL + WS-INTEREST-EARNED.

    MOVE WS-PRINCIPAL       TO DISP-PRINCIPAL.
    MOVE WS-INTEREST-EARNED TO DISP-INTEREST.
    MOVE WS-TOTAL-MATURITY  TO DISP-TOTAL.

    DISPLAY "Corporate Investment Calculation:".
    DISPLAY "  Principal Investment : " DISP-PRINCIPAL.
    DISPLAY "  Interest Rate        : 5.25%".
    DISPLAY "  Earned Interest      : " DISP-INTEREST.
    DISPLAY "  Total Maturity Value : " DISP-TOTAL.
    DISPLAY "==========================================================".
    GOBACK.
