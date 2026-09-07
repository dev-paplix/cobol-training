       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CobolClient.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Demonstrates calling C# .NET 8 class library         *
      *> compiled via Native AOT from modern GnuCOBOL.        *
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Test 1: Integer multiplication
       01  WS-INT-A                  PIC S9(9) COMP-5 VALUE 25.
       01  WS-INT-B                  PIC S9(9) COMP-5 VALUE 16.
       01  WS-INT-RES                PIC S9(9) COMP-5 VALUE 0.

      *> Test 2: Financial calculation
       01  WS-SUBTOTAL               USAGE COMP-2 VALUE 1500.00.
       01  WS-DISCOUNT-PCT           USAGE COMP-2 VALUE 15.0.
       01  WS-DISCOUNTED-AMT         USAGE COMP-2 VALUE 0.0.
       01  WS-TAX-RATE               USAGE COMP-2 VALUE 0.0825.
       01  WS-TAX-AMT                USAGE COMP-2 VALUE 0.0.
       01  WS-FINAL-TOTAL            USAGE COMP-2 VALUE 0.0.

      *> Formatted Display
       01  DISP-SUBTOTAL             PIC $$$,$$9.99.
       01  DISP-DISCOUNTED           PIC $$$,$$9.99.
       01  DISP-TAX                  PIC $$$,$$9.99.
       01  DISP-FINAL                PIC $$$,$$9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "=================================================="
           DISPLAY "     COBOL CALLING C# .NET 8 NATIVE AOT DEMO      "
           DISPLAY "=================================================="

           PERFORM 1000-TEST-INTEGER-CALL
           PERFORM 2000-TEST-FINANCIAL-CALL

           DISPLAY "=================================================="
           DISPLAY "All C# methods invoked successfully from COBOL."
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       1000-TEST-INTEGER-CALL.
           DISPLAY "[TEST 1] Calling C# DotNetMultiply method..."
           CALL "DotNetMultiply" 
               USING BY VALUE WS-INT-A WS-INT-B 
               RETURNING WS-INT-RES

           DISPLAY "  Inputs : " WS-INT-A " * " WS-INT-B
           DISPLAY "  Result : " WS-INT-RES " (Expected: 400)"
           DISPLAY " ".

       2000-TEST-FINANCIAL-CALL.
           DISPLAY "[TEST 2] Calling C# Discount & Tax methods..."
           MOVE WS-SUBTOTAL TO DISP-SUBTOTAL
           DISPLAY "  Gross Cart Subtotal : " DISP-SUBTOTAL

      *> Step A: Apply 15% discount
           CALL "DotNetApplyDiscount"
               USING BY VALUE WS-SUBTOTAL WS-DISCOUNT-PCT
                     BY REFERENCE WS-DISCOUNTED-AMT

           MOVE WS-DISCOUNTED-AMT TO DISP-DISCOUNTED
           DISPLAY "  After 15% Discount  : " DISP-DISCOUNTED

      *> Step B: Calculate 8.25% tax
           CALL "DotNetCalculateTax"
               USING BY VALUE WS-DISCOUNTED-AMT WS-TAX-RATE
                     BY REFERENCE WS-TAX-AMT

           MOVE WS-TAX-AMT TO DISP-TAX
           DISPLAY "  Sales Tax (8.25%)   : " DISP-TAX

      *> Step C: Compute Final Total
           COMPUTE WS-FINAL-TOTAL = WS-DISCOUNTED-AMT + WS-TAX-AMT
           MOVE WS-FINAL-TOTAL TO DISP-FINAL
           DISPLAY "  Net Order Total     : " DISP-FINAL.

