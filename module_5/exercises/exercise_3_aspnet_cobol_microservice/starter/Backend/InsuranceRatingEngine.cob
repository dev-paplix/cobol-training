       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. InsuranceRatingEngine.
       AUTHOR. Student.

      *>======================================================*
      *> EXERCISE 3 STARTER: Actuarial Insurance Rating Engine*
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

      *> TODO 1: Determine WS-AGE-FACTOR:
      *>         If age < 25 -> 1.40
      *>         Else if age > 65 -> 1.15
      *>         Else -> 1.00

      *> TODO 2: Compute violation surcharge:
      *>         WS-VIOLATION-SURCHARGE = LK-PRIOR-VIOLATIONS * 250.00

      *> TODO 3: Compute LK-ANNUAL-PREMIUM = (LK-BASE-PREMIUM * WS-AGE-FACTOR) + WS-VIOLATION-SURCHARGE

      *> TODO 4: Classify LK-RISK-RATING:
      *>         If LK-PRIOR-VIOLATIONS > 2 OR LK-ANNUAL-PREMIUM >= 2000.00 -> "HIGH_RISK"
      *>         Else if LK-PRIOR-VIOLATIONS = 0 AND LK-DRIVER-AGE >= 25 -> "LOW_RISK"
      *>         Else -> "STANDARD"

           GOBACK.
