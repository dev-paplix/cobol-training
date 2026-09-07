>>SOURCE FORMAT FREE
*>================================================================*
*> SUBPROGRAM : SavingsAccount.cob                                *
*> PURPOSE    : Dedicated Savings Account Specialist Subprogram   *
*> COMPILE    : cobc -c -free SavingsAccount.cob                  *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. SavingsAccount.

DATA DIVISION.
LINKAGE SECTION.
01 LS-BALANCE                 PIC S9(9)V99 COMP-3.
01 LS-INTEREST-RATE           PIC V999 COMP-3.
01 LS-INTEREST-EARNED         PIC S9(7)V99 COMP-3.

PROCEDURE DIVISION USING LS-BALANCE LS-INTEREST-RATE LS-INTEREST-EARNED.
    COMPUTE LS-INTEREST-EARNED ROUNDED = LS-BALANCE * LS-INTEREST-RATE.
    ADD LS-INTEREST-EARNED TO LS-BALANCE.
    GOBACK.
