>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 3 (SOLUTION): PayrollApp.cob                          *
*> Main Payroll Application Driver                                *
*> COMPILE : cobc -x -free PayrollApp.cob Employee.cob            *
*>           SalariedEmployee.cob HourlyEmployee.cob              *
*> RUN     : ./PayrollApp                                         *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. PayrollApp.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> Salaried Employee Record ($104,000 / year)
01 WS-SAL-TYPE                PIC X(10) VALUE "SALARIED".
01 WS-SAL-ANNUAL              PIC S9(9)V99 COMP-3 VALUE 104000.00.
01 WS-SAL-HOURS               PIC 9(3)V9   COMP-3 VALUE 0.0.
01 WS-SAL-GROSS               PIC S9(7)V99 COMP-3.
01 DISP-SAL-GROSS             PIC $ZZZ,ZZ9.99.

*> Hourly Employee Record ($35.00 / hr for 46.0 hrs)
01 WS-HRY-TYPE                PIC X(10) VALUE "HOURLY".
01 WS-HRY-RATE                PIC S9(9)V99 COMP-3 VALUE 35.00.
01 WS-HRY-HOURS               PIC 9(3)V9   COMP-3 VALUE 46.0.
01 WS-HRY-GROSS               PIC S9(7)V99 COMP-3.
01 DISP-HRY-GROSS             PIC $ZZZ,ZZ9.99.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       EXERCISE 3 SOLUTION: MODULAR PAYROLL APP           ".
    DISPLAY "==========================================================".

    *> 1. Calculate Salaried Pay (Biweekly: $104,000 / 26 = $4,000.00)
    CALL "Employee" USING WS-SAL-TYPE 
                          WS-SAL-ANNUAL 
                          WS-SAL-HOURS 
                          WS-SAL-GROSS.
    MOVE WS-SAL-GROSS TO DISP-SAL-GROSS.
    DISPLAY "Director  (Salaried $104K/yr) -> Bi-weekly Gross: " DISP-SAL-GROSS.

    *> 2. Calculate Hourly Pay ($35/hr x 46h = 40h @ $35 + 6h @ $52.50 = $1,715.00)
    CALL "Employee" USING WS-HRY-TYPE 
                          WS-HRY-RATE 
                          WS-HRY-HOURS 
                          WS-HRY-GROSS.
    MOVE WS-HRY-GROSS TO DISP-HRY-GROSS.
    DISPLAY "Tech Lead (Hourly $35/46h)   -> Bi-weekly Gross: " DISP-HRY-GROSS.

    DISPLAY "==========================================================".
    GOBACK.
