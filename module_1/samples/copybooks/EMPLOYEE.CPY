*>================================================================*
*> COPYBOOK: EMPLOYEE.CPY                                         *
*> PURPOSE : Standard Enterprise Employee Record Definition       *
*> FORMAT  : Free / Fixed Compatible                              *
*>================================================================*
       01 EMP-RECORD.
          05 EMP-ID                     PIC X(6).
          05 EMP-NAME                   PIC X(30).
          05 EMP-DEPT                   PIC X(4).
          05 EMP-AGE                    PIC 9(2).
          05 EMP-MONTHLY-SALARY         PIC 9(7)V99 COMP-3.
          05 EMP-ANNUAL-SALARY          PIC 9(8)V99 COMP-3.
          05 EMP-BONUS-RATE             PIC V999    COMP-3.
          05 EMP-ANNUAL-BONUS           PIC 9(7)V99 COMP-3.
          05 EMP-TOTAL-COMPENSATION     PIC 9(8)V99 COMP-3.
          05 EMP-YEARS-TO-RETIRE        PIC 9(2)    COMP-5.

