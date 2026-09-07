>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : TestCustomer.cob                                     *
*> PURPOSE : Main test harness calling the Customer subprogram    *
*> COMPILE : cobc -x -free TestCustomer.cob Customer.cob          *
*> RUN     : ./TestCustomer                                       *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. TestCustomer.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-CUSTOMER-REC.
   05 WS-CUST-ID              PIC X(8)  VALUE "CUST-101".
   05 WS-FIRST-NAME           PIC X(15) VALUE "SARAH".
   05 WS-LAST-NAME            PIC X(15) VALUE "CONNOR".
   05 WS-EMAIL                PIC X(30) VALUE "sconnor@resistance.org".
   05 WS-LOYALTY-POINTS       PIC 9(6)  VALUE 0.
   05 WS-MEMBERSHIP-TIER      PIC X(10) VALUE SPACES.

01 WS-ACTION                  PIC X(10).
01 WS-POINTS-INPUT            PIC 9(5).
01 WS-RESULT-MSG              PIC X(80).

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "==========================================================".
    DISPLAY "       TESTING MODULAR GNUCOBOL CUSTOMER SERVICE          ".
    DISPLAY "==========================================================".

    *> 1. Initialize Customer Record
    MOVE "INIT" TO WS-ACTION.
    MOVE 0      TO WS-POINTS-INPUT.
    CALL "Customer" USING WS-CUSTOMER-REC 
                          WS-ACTION 
                          WS-POINTS-INPUT 
                          WS-RESULT-MSG.
    DISPLAY "Action: " WS-ACTION " -> " FUNCTION TRIM(WS-RESULT-MSG).
    DISPLAY "Tier  : " WS-MEMBERSHIP-TIER.
    DISPLAY "----------------------------------------------------------".

    *> 2. Add 250 Points
    MOVE "ADD-POINTS" TO WS-ACTION.
    MOVE 250          TO WS-POINTS-INPUT.
    CALL "Customer" USING WS-CUSTOMER-REC 
                          WS-ACTION 
                          WS-POINTS-INPUT 
                          WS-RESULT-MSG.
    DISPLAY "Action: " WS-ACTION " -> " FUNCTION TRIM(WS-RESULT-MSG).
    DISPLAY "Points: " WS-LOYALTY-POINTS " | Tier: " WS-MEMBERSHIP-TIER.
    DISPLAY "----------------------------------------------------------".

    *> 3. Add 400 More Points (Total 650 -> Should promote to GOLD)
    MOVE "ADD-POINTS" TO WS-ACTION.
    MOVE 400          TO WS-POINTS-INPUT.
    CALL "Customer" USING WS-CUSTOMER-REC 
                          WS-ACTION 
                          WS-POINTS-INPUT 
                          WS-RESULT-MSG.
    DISPLAY "Action: " WS-ACTION " -> " FUNCTION TRIM(WS-RESULT-MSG).
    DISPLAY "Points: " WS-LOYALTY-POINTS " | Tier: " WS-MEMBERSHIP-TIER.

    DISPLAY "==========================================================".
    DISPLAY "Modular GnuCOBOL Test Passed Successfully!".
    GOBACK.
