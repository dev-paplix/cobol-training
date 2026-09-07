>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 3 (SOLUTION): Employee.cob                            *
*> Unified payroll dispatcher subprogram                          *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Employee.

DATA DIVISION.
LINKAGE SECTION.
01 LS-EMP-TYPE                PIC X(10).
01 LS-RATE-OR-SALARY          PIC S9(9)V99 COMP-3.
01 LS-HOURS                   PIC 9(3)V9   COMP-3.
01 LS-CALCULATED-GROSS        PIC S9(7)V99 COMP-3.

PROCEDURE DIVISION USING LS-EMP-TYPE 
                          LS-RATE-OR-SALARY 
                          LS-HOURS 
                          LS-CALCULATED-GROSS.
    EVALUATE FUNCTION UPPER-CASE(FUNCTION TRIM(LS-EMP-TYPE))
        WHEN "SALARIED"
            CALL "SalariedEmployee" USING LS-RATE-OR-SALARY 
                                          LS-CALCULATED-GROSS
        WHEN "HOURLY"
            CALL "HourlyEmployee" USING LS-RATE-OR-SALARY 
                                        LS-HOURS 
                                        LS-CALCULATED-GROSS
        WHEN OTHER
            MOVE 0.00 TO LS-CALCULATED-GROSS
    END-EVALUATE.
    GOBACK.
