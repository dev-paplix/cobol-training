>>SOURCE FORMAT FREE
*>================================================================*
*> SUBPROGRAM : CheckingAccount.cob                               *
*> PURPOSE    : Dedicated Checking Account Overdraft Handler      *
*> COMPILE    : cobc -c -free CheckingAccount.cob                 *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. CheckingAccount.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-AVAILABLE               PIC S9(9)V99 COMP-3.

LINKAGE SECTION.
01 LS-BALANCE                 PIC S9(9)V99 COMP-3.
01 LS-OVERDRAFT-LIMIT         PIC S9(9)V99 COMP-3.
01 LS-WITHDRAW-AMOUNT         PIC S9(9)V99 COMP-3.
01 LS-APPROVED-FLAG           PIC 9.

PROCEDURE DIVISION USING LS-BALANCE 
                         LS-OVERDRAFT-LIMIT 
                         LS-WITHDRAW-AMOUNT 
                         LS-APPROVED-FLAG.
    COMPUTE WS-AVAILABLE = LS-BALANCE + LS-OVERDRAFT-LIMIT.
    IF WS-AVAILABLE >= LS-WITHDRAW-AMOUNT
        SUBTRACT LS-WITHDRAW-AMOUNT FROM LS-BALANCE
        MOVE 1 TO LS-APPROVED-FLAG
    ELSE
        MOVE 0 TO LS-APPROVED-FLAG
    END-IF.
    GOBACK.
