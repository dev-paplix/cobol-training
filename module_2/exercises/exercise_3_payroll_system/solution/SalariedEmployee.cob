>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 3 (SOLUTION): SalariedEmployee.cob                    *
*> Subprogram calculating bi-weekly pay for salaried employees    *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. SalariedEmployee.

DATA DIVISION.
LINKAGE SECTION.
01 LS-ANNUAL-SALARY           PIC S9(9)V99 COMP-3.
01 LS-BIWEEKLY-GROSS          PIC S9(7)V99 COMP-3.

PROCEDURE DIVISION USING LS-ANNUAL-SALARY LS-BIWEEKLY-GROSS.
    COMPUTE LS-BIWEEKLY-GROSS ROUNDED = LS-ANNUAL-SALARY / 26.
    GOBACK.
