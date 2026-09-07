>>SOURCE FORMAT FREE
*>================================================================*
*> EXERCISE 3 (STARTER): HourlyEmployee.cob                       *
*> Subprogram calculating hourly wages with 1.5x overtime         *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. HourlyEmployee.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-REGULAR-PAY             PIC S9(7)V99 COMP-3.
01 WS-OVERTIME-HOURS          PIC 9(3)V9   COMP-3.
01 WS-OVERTIME-RATE           PIC S9(5)V99 COMP-3.
01 WS-OVERTIME-PAY            PIC S9(7)V99 COMP-3.

LINKAGE SECTION.
01 LS-HOURLY-RATE             PIC S9(5)V99 COMP-3.
01 LS-HOURS-WORKED            PIC 9(3)V9   COMP-3.
01 LS-GROSS-PAY               PIC S9(7)V99 COMP-3.

PROCEDURE DIVISION USING LS-HOURLY-RATE LS-HOURS-WORKED LS-GROSS-PAY.
    *> TODO 1: If hours <= 40, pay = hours * rate
    IF LS-HOURS-WORKED <= 40.0
        COMPUTE LS-GROSS-PAY ROUNDED = LS-HOURLY-RATE * LS-HOURS-WORKED
    ELSE
    *> TODO 2: If hours > 40:
    *>         Regular Pay  = 40 * rate
    *>         Overtime Pay = (hours - 40) * (rate * 1.5)
    *>         Total Pay    = Regular Pay + Overtime Pay
        COMPUTE WS-REGULAR-PAY = LS-HOURLY-RATE * 40.0
        COMPUTE WS-OVERTIME-HOURS = LS-HOURS-WORKED - 40.0
        COMPUTE WS-OVERTIME-RATE = LS-HOURLY-RATE * 1.5
        COMPUTE WS-OVERTIME-PAY ROUNDED = WS-OVERTIME-HOURS * WS-OVERTIME-RATE
        COMPUTE LS-GROSS-PAY = WS-REGULAR-PAY + WS-OVERTIME-PAY
    END-IF.
    GOBACK.
