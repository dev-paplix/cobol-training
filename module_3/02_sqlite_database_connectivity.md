# Chapter 2: SQLite Database Connectivity & C-Bridge Architecture

In legacy mainframe and proprietary Windows environments, COBOL systems utilized DB2 (via embedded SQL precompilers like `EXEC SQL`) or Microsoft ADO.NET / ODBC drivers (via Fujitsu NetCOBOL COM/CLR wrappers). 

In modern cloud, containerized, and Linux architectures, **SQLite3** offers an embedded, serverless, zero-configuration SQL database engine. This chapter details how to seamlessly integrate SQLite3 with GnuCOBOL using a high-performance C bridge.

---

## 1. Why SQLite for Modern COBOL?

1. **Zero External Daemon**: SQLite runs inside the same process memory as the COBOL executable, eliminating network latency and database connection pool overhead.
2. **ACID Compliant**: Full transactional safety with `BEGIN TRANSACTION`, `COMMIT`, and `ROLLBACK`.
3. **Cross-Platform Single-File Storage**: Databases are self-contained `.db` files that can be easily backed up, versioned, or transferred.
4. **Standard SQL Grammar**: Full support for standard SQL DDL (`CREATE TABLE`, `INDEX`), DML (`INSERT`, `UPDATE`, `DELETE`), aggregations (`COUNT`, `SUM`), joins, and subqueries.

---

## 2. Bridging C and COBOL: The C-Bridge Pattern

COBOL and C manage memory differently:
- **Strings**: C uses null-terminated strings (`char*` ending with `\0`). COBOL uses fixed-width character buffers (`PIC X(n)`) padded with trailing spaces.
- **Pointers**: C manages handles (`sqlite3*`, `sqlite3_stmt*`) as raw memory addresses. COBOL stores these as `USAGE POINTER`.
- **Return Codes**: SQLite functions return integers like `SQLITE_OK` (0), `SQLITE_ROW` (100), and `SQLITE_DONE` (101).

While GnuCOBOL can directly invoke C functions via `CALL "c_func" USING BY REFERENCE ...`, directly handling C string pointers (`sqlite3_column_text`) from COBOL causes memory over-reads and segmentation faults because COBOL strings lack null terminators and expect fixed-length buffers.

### The Solution: `cob_sqlite.c`
We create a lightweight, type-safe C bridge (`cob_sqlite.c`) that:
1. Accepts COBOL space-padded strings and null-terminates them for SQLite.
2. Extracts column values from SQLite and safely copies them into COBOL buffers with space-padding.
3. Provides intuitive COBOL-friendly subroutines.

---

## 3. C-Bridge Function Reference

| Function Name | Parameters | Purpose |
| :--- | :--- | :--- |
| `cob_sqlite_open` | `(filename, db_handle, status)` | Opens or creates an SQLite `.db` file. |
| `cob_sqlite_exec` | `(db_handle, sql, status)` | Executes immediate DDL/DML statements (CREATE, INSERT, UPDATE). |
| `cob_sqlite_prepare` | `(db_handle, sql, stmt_handle, status)` | Compiles a SQL query into a prepared statement cursor. |
| `cob_sqlite_step` | `(stmt_handle, status)` | Advances cursor: returns `100` (`SQLITE_ROW`) or `101` (`SQLITE_DONE`). |
| `cob_sqlite_get_int` | `(stmt_handle, col_idx, int_out)` | Retrieves an integer column into a `BINARY` / `COMP-5` variable. |
| `cob_sqlite_get_text`| `(stmt_handle, col_idx, buffer, max_len)` | Retrieves a text column into a space-padded `PIC X(n)` buffer. |
| `cob_sqlite_get_double`| `(stmt_handle, col_idx, dbl_out)` | Retrieves a floating/decimal column into `COMP-2` or scaled numeric. |
| `cob_sqlite_finalize`| `(stmt_handle, status)` | Frees prepared statement memory. |
| `cob_sqlite_close` | `(db_handle, status)` | Closes database connection. |

---

## 4. COBOL Linkage & Working-Storage Setup

To use SQLite in COBOL, declare the handles and return codes in `WORKING-STORAGE SECTION`:

```cobol
       WORKING-STORAGE SECTION.
      *> Database & Statement Pointers
       01  DB-HANDLE                 USAGE POINTER VALUE NULL.
       01  STMT-HANDLE               USAGE POINTER VALUE NULL.

      *> Status and Control Variables
       01  SQLITE-STATUS             PIC S9(9) BINARY VALUE 0.
           88  SQL-OK                VALUE 0.
           88  SQL-ROW               VALUE 100.
           88  SQL-DONE              VALUE 101.

      *> Query Buffer
       01  SQL-STATEMENT             PIC X(256).
```

---

## 5. End-to-End Workflow

### Step 1: Open Database & Create Table
```cobol
       MOVE "company.db" TO SQL-STATEMENT
       CALL "cob_sqlite_open" USING
           BY REFERENCE SQL-STATEMENT
           BY REFERENCE DB-HANDLE
           BY REFERENCE SQLITE-STATUS

       IF NOT SQL-OK
           DISPLAY "Error opening database: " SQLITE-STATUS
           STOP RUN
       END-IF

      *> Create table
       MOVE "CREATE TABLE IF NOT EXISTS accounts (id INT, name TEXT, balance REAL);" 
           TO SQL-STATEMENT
       CALL "cob_sqlite_exec" USING
           BY REFERENCE DB-HANDLE
           BY REFERENCE SQL-STATEMENT
           BY REFERENCE SQLITE-STATUS
```

### Step 2: Insert Records
```cobol
       MOVE "INSERT INTO accounts VALUES (101, 'Engineering Dept', 250000.00);" 
           TO SQL-STATEMENT
       CALL "cob_sqlite_exec" USING
           BY REFERENCE DB-HANDLE
           BY REFERENCE SQL-STATEMENT
           BY REFERENCE SQLITE-STATUS
```

### Step 3: Query Records Using Cursor Step
```cobol
       MOVE "SELECT id, name, balance FROM accounts ORDER BY id;" 
           TO SQL-STATEMENT
       CALL "cob_sqlite_prepare" USING
           BY REFERENCE DB-HANDLE
           BY REFERENCE SQL-STATEMENT
           BY REFERENCE STMT-HANDLE
           BY REFERENCE SQLITE-STATUS

       IF SQL-OK
           PERFORM UNTIL 1 = 0
               CALL "cob_sqlite_step" USING
                   BY REFERENCE STMT-HANDLE
                   BY REFERENCE SQLITE-STATUS

               IF SQL-ROW
                   *> Column 0: id (Integer)
                   CALL "cob_sqlite_get_int" USING
                       BY REFERENCE STMT-HANDLE
                       BY VALUE 0
                       BY REFERENCE WS-ACCT-ID

                   *> Column 1: name (Text)
                   CALL "cob_sqlite_get_text" USING
                       BY REFERENCE STMT-HANDLE
                       BY VALUE 1
                       BY REFERENCE WS-ACCT-NAME
                       BY VALUE 30

                   *> Column 2: balance (Double / Real)
                   CALL "cob_sqlite_get_double" USING
                       BY REFERENCE STMT-HANDLE
                       BY VALUE 2
                       BY REFERENCE WS-ACCT-BALANCE

                   DISPLAY "Account: " WS-ACCT-ID " | Name: " WS-ACCT-NAME 
                           " | Balance: $" WS-ACCT-BALANCE
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM

           *> Finalize the statement cursor
           CALL "cob_sqlite_finalize" USING
               BY REFERENCE STMT-HANDLE
               BY REFERENCE SQLITE-STATUS
       END-IF
```

### Step 4: Transaction Management
To maintain ACID integrity across multiple operations:
```cobol
      *> Start atomic transaction
       MOVE "BEGIN TRANSACTION;" TO SQL-STATEMENT
       CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
           BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

      *> Execute operations...
      *> If successful:
       MOVE "COMMIT;" TO SQL-STATEMENT
       CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
           BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS

      *> If any error occurs:
       MOVE "ROLLBACK;" TO SQL-STATEMENT
       CALL "cob_sqlite_exec" USING BY REFERENCE DB-HANDLE 
           BY REFERENCE SQL-STATEMENT BY REFERENCE SQLITE-STATUS
```

---

## 6. Compilation & Linkage

Compiling COBOL with the C-Bridge is straightforward with `cobc`:
```bash
# -x: Build executable
# -free: Free-format COBOL source
# -lsqlite3: Link the system SQLite library
cobc -x -free DatabaseDemo.cob cob_sqlite.c -lsqlite3 -o DatabaseDemo
```
This produces a single, native Linux binary with no runtime dependencies other than standard `libsqlite3.so` and `libcob.so`.

