       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. InsuranceRatingEngine.
       AUTHOR. COBOL Modernization Series.

      *>======================================================*
      *> Actuarial Risk & Insurance Rating Engine.            *
      *> Compiled with: cobc -m -free InsuranceRatingEngine.cob*
      *>======================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-AGE-FACTOR             USAGE COMP-2 VALUE 1.0.
       01  WS-VIOLATION-SURCHARGE    USAGE COMP-2 VALUE 0.0.

       LINKAGE SECTION.
       01  LK-DRIVER-AGE             PIC S9(9) COMP-5.
       01  LK-PRIOR-VIOLATIONS       PIC S9(9) COMP-5.
       01  LK-BASE-PREMIUM           USAGE COMP-2.
       01  LK-ANNUAL-PREMIUM         USAGE COMP-2.
       01  LK-RISK-RATING            PIC X(12).

       PROCEDURE DIVISION USING LK-DRIVER-AGE
                                LK-PRIOR-VIOLATIONS
                                LK-BASE-PREMIUM
                                LK-ANNUAL-PREMIUM
                                LK-RISK-RATING.
       0000-CALCULATE-PREMIUM.
           MOVE 0.0 TO LK-ANNUAL-PREMIUM
           MOVE SPACES TO LK-RISK-RATING

      *> Step 1: Age multiplier
           IF LK-DRIVER-AGE < 25
               MOVE 1.40 TO WS-AGE-FACTOR
           ELSE
               IF LK-DRIVER-AGE > 65
                   MOVE 1.15 TO WS-AGE-FACTOR
               ELSE
                   MOVE 1.00 TO WS-AGE-FACTOR
               END-IF
           END-IF

      *> Step 2: Violation surcharge ($250 per violation)
           COMPUTE WS-VIOLATION-SURCHARGE = LK-PRIOR-VIOLATIONS * 250.00

      *> Step 3: Compute final annual premium
           COMPUTE LK-ANNUAL-PREMIUM = (LK-BASE-PREMIUM * WS-AGE-FACTOR) + WS-VIOLATION-SURCHARGE

      *> Step 4: Classify risk rating
           IF LK-PRIOR-VIOLATIONS > 2 OR LK-ANNUAL-PREMIUM >= 2000.00
               MOVE "HIGH_RISK" TO LK-RISK-RATING
           ELSE
               IF LK-PRIOR-VIOLATIONS = 0 AND LK-DRIVER-AGE >= 25
                   MOVE "LOW_RISK" TO LK-RISK-RATING
               ELSE
                   MOVE "STANDARD" TO LK-RISK-RATING
               END-IF
           END-IF

           GOBACK.
