>>SOURCE FORMAT FREE
*>================================================================*
*> SUBPROGRAM : BankAccount.cob                                   *
*> PURPOSE    : Modular Bank Account Service supporting standard  *
*>              Savings and Checking with Overdraft               *
*> COMPILE    : cobc -c -free BankAccount.cob                     *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. BankAccount.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-TEMP-CALC               PIC S9(9)V99 COMP-3.

LINKAGE SECTION.
01 LS-ACCOUNT-RECORD.
   05 LS-ACCT-NUMBER          PIC X(10).
   05 LS-ACCT-TYPE            PIC X(10). *> 'SAVINGS' or 'CHECKING'
   05 LS-BALANCE              PIC S9(9)V99 COMP-3.
   05 LS-OVERDRAFT-LIMIT      PIC S9(9)V99 COMP-3.
   05 LS-INTEREST-RATE        PIC V999 COMP-3.

01 LS-OPERATION               PIC X(10). *> 'DEPOSIT', 'WITHDRAW', 'INTEREST'
01 LS-AMOUNT                  PIC S9(9)V99 COMP-3.
01 LS-SUCCESS-FLAG            PIC 9.     *> 1 = Success, 0 = Denied
01 LS-MESSAGE                 PIC X(60).

PROCEDURE DIVISION USING LS-ACCOUNT-RECORD 
                         LS-OPERATION 
                         LS-AMOUNT 
                         LS-SUCCESS-FLAG 
                         LS-MESSAGE.
MAIN-LOGIC.
    MOVE 0 TO LS-SUCCESS-FLAG
    MOVE SPACES TO LS-MESSAGE

    EVALUATE LS-OPERATION
        WHEN "DEPOSIT"
            ADD LS-AMOUNT TO LS-BALANCE
            MOVE 1 TO LS-SUCCESS-FLAG
            MOVE "Deposit completed successfully." TO LS-MESSAGE

        WHEN "WITHDRAW"
            IF LS-ACCT-TYPE = "CHECKING"
                *> Checking account permits overdraft up to limit
                COMPUTE WS-TEMP-CALC = LS-BALANCE + LS-OVERDRAFT-LIMIT
                IF WS-TEMP-CALC >= LS-AMOUNT
                    SUBTRACT LS-AMOUNT FROM LS-BALANCE
                    MOVE 1 TO LS-SUCCESS-FLAG
                    MOVE "Withdrawal approved (Overdraft protected)." 
                        TO LS-MESSAGE
                ELSE
                    MOVE 0 TO LS-SUCCESS-FLAG
                    MOVE "DENIED: Exceeds balance and overdraft limit." 
                        TO LS-MESSAGE
                END-IF
            ELSE
                *> Standard / Savings: Cannot go below 0
                IF LS-BALANCE >= LS-AMOUNT
                    SUBTRACT LS-AMOUNT FROM LS-BALANCE
                    MOVE 1 TO LS-SUCCESS-FLAG
                    MOVE "Withdrawal approved." TO LS-MESSAGE
                ELSE
                    MOVE 0 TO LS-SUCCESS-FLAG
                    MOVE "DENIED: Insufficient funds." TO LS-MESSAGE
                END-IF
            END-IF

        WHEN "INTEREST"
            IF LS-ACCT-TYPE = "SAVINGS"
                COMPUTE WS-TEMP-CALC ROUNDED = LS-BALANCE * LS-INTEREST-RATE
                ADD WS-TEMP-CALC TO LS-BALANCE
                MOVE 1 TO LS-SUCCESS-FLAG
                MOVE "Interest applied successfully." TO LS-MESSAGE
            ELSE
                MOVE 0 TO LS-SUCCESS-FLAG
                MOVE "Interest does not apply to checking accounts." 
                    TO LS-MESSAGE
            END-IF

        WHEN OTHER
            MOVE 0 TO LS-SUCCESS-FLAG
            MOVE "ERROR: Unknown operation code." TO LS-MESSAGE
    END-EVALUATE.

    GOBACK.
