       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BatchDriver.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 2 STARTER: COBOL Batch Calling C# Native AOT*
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-INDEX                  PIC 9(2) VALUE 1.

       01  WS-ACCOUNT-TABLE.
           05  WS-ACCOUNT-ENTRY OCCURS 3 TIMES.
               10  WS-ACCT-ID        PIC S9(9) COMP-5.
               10  WS-AMOUNT         USAGE COMP-2.
               10  WS-IS-VALID       PIC S9(9) COMP-5.
               10  WS-FEE            USAGE COMP-2.
               10  WS-NET-PAYMENT    USAGE COMP-2.

       01  DISP-AMOUNT               PIC $$$,$$9.99.
       01  DISP-FEE                  PIC $$$,$$9.99.
       01  DISP-NET                  PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-LOAD-ACCOUNTS
           PERFORM 2000-PROCESS-BATCH
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-LOAD-ACCOUNTS.
           MOVE 10017 TO WS-ACCT-ID(1)
           MOVE 2500.00 TO WS-AMOUNT(1)
           MOVE 10020 TO WS-ACCT-ID(2)
           MOVE 1800.00 TO WS-AMOUNT(2)
           MOVE 10031 TO WS-ACCT-ID(3)
           MOVE 8400.00 TO WS-AMOUNT(3).

       2000-PROCESS-BATCH.
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 3
      *> TODO 1: CALL "ValidateAccountNumber" USING BY VALUE WS-ACCT-ID(WS-INDEX)
      *>                                      RETURNING WS-IS-VALID(WS-INDEX)

      *> TODO 2: If WS-IS-VALID(WS-INDEX) = 1:
      *>         CALL "CalculateProcessingFee" USING BY VALUE WS-AMOUNT(WS-INDEX)
      *>                                             BY REFERENCE WS-FEE(WS-INDEX)
      *>         COMPUTE WS-NET-PAYMENT(WS-INDEX) = WS-AMOUNT(WS-INDEX) - WS-FEE(WS-INDEX)
      *>         Display formatted amounts
      *>         Else:
      *>         Display account rejected
               CONTINUE
           END-PERFORM.
