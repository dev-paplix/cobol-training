       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TaxEngine.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 1 STARTER: Tax and Discount Calculation     *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DISCOUNT-RATE          USAGE COMP-2 VALUE 0.0.
       01  WS-NET-SUBTOTAL           USAGE COMP-2 VALUE 0.0.
       01  WS-TAX-RATE               USAGE COMP-2 VALUE 0.0825.

       LINKAGE SECTION.
       01  LK-SUBTOTAL               USAGE COMP-2.
       01  LK-TIER                   PIC X(8).
       01  LK-DISCOUNT-AMT           USAGE COMP-2.
       01  LK-TAX-AMT                USAGE COMP-2.
       01  LK-FINAL-TOTAL            USAGE COMP-2.

       PROCEDURE DIVISION USING LK-SUBTOTAL
                                LK-TIER
                                LK-DISCOUNT-AMT
                                LK-TAX-AMT
                                LK-FINAL-TOTAL.
       0000-CALCULATE-TAX.
      *> TODO 1: Initialize output parameters to 0.0
      *> ...

      *> TODO 2: Evaluate LK-TIER:
      *>         If "GOLD", set WS-DISCOUNT-RATE to 0.15 (15%)
      *>         If "SILVER", set WS-DISCOUNT-RATE to 0.10 (10%)
      *>         Otherwise, set WS-DISCOUNT-RATE to 0.00
      *> ...

      *> TODO 3: Compute LK-DISCOUNT-AMT = LK-SUBTOTAL * WS-DISCOUNT-RATE
      *>         Compute WS-NET-SUBTOTAL = LK-SUBTOTAL - LK-DISCOUNT-AMT
      *>         Compute LK-TAX-AMT = WS-NET-SUBTOTAL * WS-TAX-RATE
      *>         Compute LK-FINAL-TOTAL = WS-NET-SUBTOTAL + LK-TAX-AMT
      *> ...

           GOBACK.
