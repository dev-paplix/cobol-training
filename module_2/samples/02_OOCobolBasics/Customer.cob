>>SOURCE FORMAT FREE
*>================================================================*
*> SUBPROGRAM : Customer.cob                                      *
*> PURPOSE    : Modular Customer Service handling customer logic  *
*> COMPILE    : cobc -c -free Customer.cob                        *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Customer.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-TIER-LABEL              PIC X(10).

LINKAGE SECTION.
*> Passed-in Customer Parameter Block
01 LS-CUSTOMER-DATA.
   05 LS-CUST-ID              PIC X(8).
   05 LS-FIRST-NAME           PIC X(15).
   05 LS-LAST-NAME            PIC X(15).
   05 LS-EMAIL                PIC X(30).
   05 LS-LOYALTY-POINTS       PIC 9(6).
   05 LS-MEMBERSHIP-TIER      PIC X(10).
01 LS-ACTION-CODE             PIC X(10). *> 'INIT', 'ADD-POINTS', 'EVAL-TIER'
01 LS-POINTS-TO-ADD           PIC 9(5).
01 LS-STATUS-MSG              PIC X(80).

PROCEDURE DIVISION USING LS-CUSTOMER-DATA 
                         LS-ACTION-CODE 
                         LS-POINTS-TO-ADD 
                         LS-STATUS-MSG.
MAIN-LOGIC.
    EVALUATE LS-ACTION-CODE
        WHEN "INIT"
            MOVE 0 TO LS-LOYALTY-POINTS
            MOVE "BRONZE" TO LS-MEMBERSHIP-TIER
            MOVE "Customer initialized with Bronze tier." TO LS-STATUS-MSG

        WHEN "ADD-POINTS"
            ADD LS-POINTS-TO-ADD TO LS-LOYALTY-POINTS
            PERFORM 1000-EVALUATE-TIER
            STRING "Added " DELIMITED BY SIZE
                   LS-POINTS-TO-ADD DELIMITED BY SIZE
                   " points. Current Tier: " DELIMITED BY SIZE
                   LS-MEMBERSHIP-TIER DELIMITED BY SIZE
                   INTO LS-STATUS-MSG

        WHEN "EVAL-TIER"
            PERFORM 1000-EVALUATE-TIER
            MOVE "Membership tier refreshed." TO LS-STATUS-MSG

        WHEN OTHER
            MOVE "ERROR: Invalid action code." TO LS-STATUS-MSG
    END-EVALUATE.

    GOBACK.

1000-EVALUATE-TIER.
    IF LS-LOYALTY-POINTS >= 1000
        MOVE "PLATINUM" TO LS-MEMBERSHIP-TIER
    ELSE IF LS-LOYALTY-POINTS >= 500
        MOVE "GOLD"     TO LS-MEMBERSHIP-TIER
    ELSE IF LS-LOYALTY-POINTS >= 200
        MOVE "SILVER"   TO LS-MEMBERSHIP-TIER
    ELSE
        MOVE "BRONZE"   TO LS-MEMBERSHIP-TIER
    END-IF.
    EXIT PARAGRAPH.
