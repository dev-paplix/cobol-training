      *================================================================*
      * PROGRAM : FixedFormatDemo.cob                                  *
      * PURPOSE : Demonstrates traditional 80-column fixed format       *
      * COMPILE : cobc -x FixedFormatDemo.cob                          *
      *================================================================*
000100 IDENTIFICATION DIVISION.
000200 PROGRAM-ID. FixedFormatDemo.
000300 DATA DIVISION.
000400 WORKING-STORAGE SECTION.
000500 01  WS-MESSAGE           PIC X(60) 
000600     VALUE "HELLO FROM TRADITIONAL FIXED-FORMAT COBOL".
000700 01  WS-LONG-SENTENCE     PIC X(120) VALUE 
000800-    "NOTICE HOW THIS SENTENCE HAD TO BE CONTINUED USING A HYPHEN
000900-    " IN COLUMN 7 ACROSS MULTIPLE PUNCH-CARD MARGINS.".
001000 PROCEDURE DIVISION.
001100 0000-MAIN.
001200     DISPLAY WS-MESSAGE.
001300     DISPLAY WS-LONG-SENTENCE.
001400     GOBACK.
