       >>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : EmployeeSystem.cob                                   *
*> PURPOSE : Standard Native GnuCOBOL implementation             *
*> COMPILE : cobc -x -free EmployeeSystem.cob -o EmployeeSystem   *
*>           (or simply: cobc -x EmployeeSystem.cob)              *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. EmployeeSystem.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> Include copybook with search path or local directory
COPY "EMPLOYEE.CPY".

*> Current System Date & Time
01 WS-CURRENT-DATE-DATA.
   05 WS-CURRENT-YEAR           PIC 9(4).
   05 WS-CURRENT-MONTH          PIC 9(2).
   05 WS-CURRENT-DAY            PIC 9(2).
   05 WS-CURRENT-HOUR           PIC 9(2).
   05 WS-CURRENT-MINUTE         PIC 9(2).
   05 WS-CURRENT-SECOND         PIC 9(2).
   05 FILLER                    PIC X(9).

*> Formatted Display Variables (COBOL Edited Picture Clauses)
01 DISP-MONTHLY-SALARY          PIC $ZZZ,ZZ9.99.
01 DISP-ANNUAL-SALARY           PIC $Z,ZZZ,ZZ9.99.
01 DISP-BONUS-RATE              PIC ZZ9.9.
01 DISP-BONUS-PERCENT-CALC      PIC 9(3)V9.
01 DISP-ANNUAL-BONUS            PIC $ZZZ,ZZ9.99.
01 DISP-TOTAL-COMP              PIC $Z,ZZZ,ZZ9.99.
01 DISP-YEARS-TO-RETIRE         PIC Z9.
01 WS-TEMP-INPUT                PIC X(30).

PROCEDURE DIVISION.
MAIN-LOGIC.
    PERFORM 1000-DISPLAY-HEADER.
    PERFORM 2000-COLLECT-INPUT.
    PERFORM 3000-CALCULATE-BENEFITS.
    PERFORM 4000-DISPLAY-SUMMARY.
    PERFORM 5000-TERMINATE-RUN.
    GOBACK.

1000-DISPLAY-HEADER.
    DISPLAY "================================================================".
    DISPLAY "           ACME CORP - EMPLOYEE ONBOARDING SYSTEM (GNUCOBOL)".
    DISPLAY "================================================================".

    MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-DATA.
    DISPLAY "System Timestamp: " 
            WS-CURRENT-YEAR "-" WS-CURRENT-MONTH "-" WS-CURRENT-DAY 
            " " WS-CURRENT-HOUR ":" WS-CURRENT-MINUTE ":" WS-CURRENT-SECOND.
    DISPLAY "----------------------------------------------------------------".
    EXIT PARAGRAPH.

2000-COLLECT-INPUT.
    DISPLAY "Enter Employee ID (6 chars)       : " WITH NO ADVANCING.
    ACCEPT EMP-ID.

    DISPLAY "Enter Full Name (Max 30 chars)    : " WITH NO ADVANCING.
    ACCEPT EMP-NAME.

    DISPLAY "Enter Dept (IT / FIN / OPS / HR)  : " WITH NO ADVANCING.
    ACCEPT WS-TEMP-INPUT.
    MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TEMP-INPUT)) TO EMP-DEPT.

    DISPLAY "Enter Current Age (e.g. 32)       : " WITH NO ADVANCING.
    ACCEPT EMP-AGE.

    DISPLAY "Enter Monthly Salary ($)          : " WITH NO ADVANCING.
    ACCEPT EMP-MONTHLY-SALARY.
    EXIT PARAGRAPH.

3000-CALCULATE-BENEFITS.
    COMPUTE EMP-ANNUAL-SALARY = EMP-MONTHLY-SALARY * 12.

    EVALUATE EMP-DEPT
        WHEN "IT"
            MOVE 0.150 TO EMP-BONUS-RATE
        WHEN "FIN"
            MOVE 0.120 TO EMP-BONUS-RATE
        WHEN "OPS"
            MOVE 0.100 TO EMP-BONUS-RATE
        WHEN OTHER
            MOVE 0.080 TO EMP-BONUS-RATE
    END-EVALUATE.

    COMPUTE EMP-ANNUAL-BONUS = EMP-ANNUAL-SALARY * EMP-BONUS-RATE.
    COMPUTE EMP-TOTAL-COMPENSATION = EMP-ANNUAL-SALARY + EMP-ANNUAL-BONUS.

    IF EMP-AGE < 65
        COMPUTE EMP-YEARS-TO-RETIRE = 65 - EMP-AGE
    ELSE
        MOVE 0 TO EMP-YEARS-TO-RETIRE
    END-IF.
    EXIT PARAGRAPH.

4000-DISPLAY-SUMMARY.
    MOVE EMP-MONTHLY-SALARY      TO DISP-MONTHLY-SALARY.
    MOVE EMP-ANNUAL-SALARY       TO DISP-ANNUAL-SALARY.
    COMPUTE DISP-BONUS-PERCENT-CALC = EMP-BONUS-RATE * 100.
    MOVE DISP-BONUS-PERCENT-CALC TO DISP-BONUS-RATE.
    MOVE EMP-ANNUAL-BONUS        TO DISP-ANNUAL-BONUS.
    MOVE EMP-TOTAL-COMPENSATION  TO DISP-TOTAL-COMP.
    MOVE EMP-YEARS-TO-RETIRE     TO DISP-YEARS-TO-RETIRE.

    DISPLAY " ".
    DISPLAY "================================================================".
    DISPLAY "                EMPLOYEE ONBOARDING CONFIRMATION                ".
    DISPLAY "================================================================".
    DISPLAY "Employee ID        : " EMP-ID.
    DISPLAY "Employee Name      : " EMP-NAME.
    DISPLAY "Department Code    : " EMP-DEPT.
    DISPLAY "Current Age        : " EMP-AGE.
    DISPLAY "Years to Retire    : " DISP-YEARS-TO-RETIRE " year(s)".
    DISPLAY "----------------------------------------------------------------".
    DISPLAY "Monthly Base Pay   : " DISP-MONTHLY-SALARY.
    DISPLAY "Annualized Base Pay: " DISP-ANNUAL-SALARY.
    DISPLAY "Department Bonus   : " DISP-BONUS-RATE "% (" DISP-ANNUAL-BONUS ")".
    DISPLAY "Total Compensation : " DISP-TOTAL-COMP.
    DISPLAY "================================================================".
    EXIT PARAGRAPH.

5000-TERMINATE-RUN.
    DISPLAY "Record successfully processed.".
    EXIT PARAGRAPH.
