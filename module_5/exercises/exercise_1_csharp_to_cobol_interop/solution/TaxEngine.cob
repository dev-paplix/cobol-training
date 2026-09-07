       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TaxEngine.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> E-Commerce Tax and Discount Calculation Engine.      *
      *> Compiled with: cobc -m -free TaxEngine.cob           *
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
           MOVE 0.0 TO LK-DISCOUNT-AMT
           MOVE 0.0 TO LK-TAX-AMT
           MOVE 0.0 TO LK-FINAL-TOTAL

           EVALUATE FUNCTION UPPER-CASE(LK-TIER)
               WHEN "GOLD"
                   MOVE 0.15 TO WS-DISCOUNT-RATE
               WHEN "SILVER"
                   MOVE 0.10 TO WS-DISCOUNT-RATE
               WHEN OTHER
                   MOVE 0.00 TO WS-DISCOUNT-RATE
           END-EVALUATE

           COMPUTE LK-DISCOUNT-AMT = LK-SUBTOTAL * WS-DISCOUNT-RATE
           COMPUTE WS-NET-SUBTOTAL = LK-SUBTOTAL - LK-DISCOUNT-AMT
           COMPUTE LK-TAX-AMT = WS-NET-SUBTOTAL * WS-TAX-RATE
           COMPUTE LK-FINAL-TOTAL = WS-NET-SUBTOTAL + LK-TAX-AMT

           GOBACK.
