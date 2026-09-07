      *>======================================================*
      *> SQLITE.CPY - GnuCOBOL Copybook for SQLite3 Interface  *
      *>======================================================*
       01  SQLITE-STATUS             PIC S9(9) COMP-5 VALUE 0.
           88  SQL-OK                VALUE 0.
           88  SQL-ROW               VALUE 100.
           88  SQL-DONE              VALUE 101.

       01  DB-HANDLE                 USAGE POINTER VALUE NULL.
       01  STMT-HANDLE               USAGE POINTER VALUE NULL.
       01  SQL-STATEMENT             PIC X(512) VALUE SPACES.

