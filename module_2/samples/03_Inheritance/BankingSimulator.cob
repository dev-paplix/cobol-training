>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : BankingSimulator.cob                                 *
*> PURPOSE : Test driver executing modular banking operations     *
*> COMPILE : cobc -x -free BankingSimulator.cob BankAccount.cob   *
*> RUN     : ./BankingSimulator                                   *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. BankingSimulator.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> Savings Account Record
01 WS-SAVINGS-ACCT.
   05 ACCT-NUM                PIC X(10) VALUE "SAV-1001".
   05 ACCT-TYPE               PIC X(10) VALUE "SAVINGS".
   05 ACCT-BALANCE            PIC S9(9)V99 COMP-3 VALUE 1000.00.
   05 ACCT-OVERDRAFT          PIC S9(9)V99 COMP-3 VALUE 0.00.
   05 ACCT-INTEREST-RATE      PIC V999 COMP-3     VALUE 0.045.

*> Checking Account Record (with $500 overdraft limit)
01 WS-CHECKING-ACCT.
   05 CHK-NUM                 PIC X(10) VALUE "CHK-2002".
   05 CHK-TYPE                PIC X(10) VALUE "CHECKING".
   05 CHK-BALANCE             PIC S9(9)V99 COMP-3 VALUE 300.00.
   05 CHK-OVERDRAFT           PIC S9(9)V99 COMP-3 VALUE 500.00.
   05 CHK-INTEREST-RATE       PIC V999 COMP-3     VALUE 0.000.

01 WS-OP                   PIC X(10).
01 WS-AMT                  PIC S9(9)V99 COMP-3.
01 WS-OK                   PIC 9.
01 WS-MSG                  PIC X(60).
01 DISP-BAL                PIC $ZZZ,ZZ9.99.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "           MODULAR GNUCOBOL BANKING SIMULATOR             ".
    DISPLAY "==========================================================".

    *> 1. Apply interest to Savings Account ($1000 * 4.5% = $45)
    MOVE "INTEREST" TO WS-OP.
    MOVE 0.00       TO WS-AMT.
    CALL "BankAccount" USING WS-SAVINGS-ACCT WS-OP WS-AMT WS-OK WS-MSG.
    MOVE ACCT-BALANCE TO DISP-BAL.
    DISPLAY "Savings Account Status: " FUNCTION TRIM(WS-MSG).
    DISPLAY "New Savings Balance   : " DISP-BAL.
    DISPLAY "----------------------------------------------------------".

    *> 2. Attempt Overdraft on Checking ($300 bal, withdraw $600 with $500 limit)
    MOVE "WITHDRAW" TO WS-OP.
    MOVE 600.00     TO WS-AMT.
    CALL "BankAccount" USING WS-CHECKING-ACCT WS-OP WS-AMT WS-OK WS-MSG.
    MOVE CHK-BALANCE TO DISP-BAL.
    DISPLAY "Checking Withdraw $600: " FUNCTION TRIM(WS-MSG).
    DISPLAY "New Checking Balance  : " DISP-BAL " (Negative / Overdraft)".
    DISPLAY "----------------------------------------------------------".

    *> 3. Attempt Excessive Overdraft on Checking ($1000 -> Exceeds remaining $200)
    MOVE "WITHDRAW" TO WS-OP.
    MOVE 1000.00    TO WS-AMT.
    CALL "BankAccount" USING WS-CHECKING-ACCT WS-OP WS-AMT WS-OK WS-MSG.
    DISPLAY "Checking Withdraw $1000: " FUNCTION TRIM(WS-MSG).

    DISPLAY "==========================================================".
    DISPLAY "Banking Simulation Finished Successfully!".
    GOBACK.
