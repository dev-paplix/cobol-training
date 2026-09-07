# Chapter 1: Traditional vs. Modern File Systems

File processing has been the cornerstone of COBOL applications since 1959. However, the operational environment has radically shifted. This chapter contrasts traditional mainframe file mechanisms with modern Linux/open-source file systems, detailing how to utilize Sequential and Indexed (ISAM) files in GnuCOBOL.

---

## 1. Mainframe JCL vs. Modern Environment Variables

In legacy IBM mainframe environments, file definitions in COBOL are decoupled from physical files using **Job Control Language (JCL)** Data Definition (`DD`) statements.

### Traditional Mainframe JCL Pattern
In COBOL:
```cobol
       SELECT CUST-FILE ASSIGN TO CUSTDD
           ORGANIZATION IS RECORD SEQUENTIAL
           FILE STATUS IS WS-FS.
```
In JCL:
```jcl
//MYJOB    JOB (ACCT),'RUN COBOL',CLASS=A
//STEP1    EXEC PGM=CUSTPROG
//CUSTDD   DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
```
The program references `CUSTDD`, which JCL dynamically resolves to the physical dataset `PROD.CUSTOMER.MASTER`.

### Modern Linux / GnuCOBOL Pattern
In modern Linux and microservice architectures, JCL is absent. Instead, GnuCOBOL provides two flexible mapping mechanisms:

#### Mechanism A: Environment Variable Override (`DD_` Prefix)
In COBOL:
```cobol
       SELECT CUST-FILE ASSIGN TO "CUSTDD"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS WS-CUST-STATUS.
```
In Linux Bash:
```bash
# Point CUSTDD to the actual physical path at runtime
export DD_CUSTDD="/var/data/customers_2026.dat"
./CustomerProgram
```
GnuCOBOL automatically checks for an environment variable named `DD_<assignment-name>`. If set, it directs I/O to that path without recompiling.

#### Mechanism B: Dynamic Path via Working-Storage
```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DATA-PATH      PIC X(128) VALUE "/var/data/customers.dat".

       FILE SECTION.
       FD  CUST-FILE.
       ...
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUST-FILE ASSIGN TO DYNAMIC WS-DATA-PATH
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CUST-STATUS.
```
This enables applications to compute paths dynamically (e.g., parsing configuration files or command-line arguments).

---

## 2. File Organizations in GnuCOBOL

COBOL supports three primary file organizations:

| Organization | Line Delimited | Record Format | Key Lookup | Typical Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`LINE SEQUENTIAL`** | Yes (`\n` or `\r\n`) | Variable / Text | Sequential only | CSV exports, logs, plain text reports |
| **`RECORD SEQUENTIAL`** | No (Byte streams) | Fixed length byte blocks | Sequential only | High-speed binary dumps, packed decimal records |
| **`INDEXED` (ISAM)** | No (B-Tree index) | Fixed or variable length | Direct by Key / Sequential | Fast primary key lookups, catalogs, ledgers |

### Understanding `LINE SEQUENTIAL`
`LINE SEQUENTIAL` files write human-readable lines terminated by standard operating system line breaks (`\n` on Linux). When COBOL reads a line sequential record, trailing spaces are automatically trimmed or handled, making it ideal for integration with non-COBOL tools (`grep`, `awk`, Python).

```cobol
       SELECT REPORT-FILE ASSIGN TO "report.txt"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS WS-STATUS.
```

### Understanding `INDEXED` (ISAM)
Indexed Sequential Access Method (ISAM) files store records accompanied by a B-Tree index structure. On Linux, GnuCOBOL uses **Berkeley DB** (BDB) or **VBIX** behind the scenes to maintain indexed access.

An indexed file allows:
- **Random Access**: Read any record instantly by specifying its primary key.
- **Sequential Access**: Traverse all records in ascending or descending key order.
- **Dynamic Access**: Switch between direct key lookups and sequential scrolling (`START`, `READ NEXT`).

```cobol
       SELECT PROD-FILE ASSIGN TO "products.dat"
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS PROD-ID
           FILE STATUS IS WS-PROD-STATUS.
```

---

## 3. Comprehensive `FILE STATUS` Code Reference

Every COBOL file operation (`OPEN`, `READ`, `WRITE`, `REWRITE`, `DELETE`, `CLOSE`) updates a 2-character `FILE STATUS` variable. Reliable COBOL programs **must check this code after every single I/O operation**.

| Code | Category | Meaning | Recommended Action |
| :--- | :--- | :--- | :--- |
| **`00`** | Success | Operation completed successfully. | Continue execution. |
| **`02`** | Warning | Duplicate key written (if `WITH DUPLICATES`). | Acceptable if duplicates allowed. |
| **`10`** | EOF | End of file reached on sequential read. | Set EOF flag, terminate read loop. |
| **`21`** | Key Error | Sequence error during sequential key write. | Ensure records are sorted by key. |
| **`22`** | Key Error | Duplicate key on `WRITE` (unique key violation). | Handle existing record or alert user. |
| **`23`** | Key Error | Record not found on random `READ`, `REWRITE`, or `DELETE`. | Return error / record missing notice. |
| **`24`** | Key Error | Boundary violation (file full or key exceeds maximum). | Check filesystem capacity. |
| **`30`** | System Error | Permanent I/O hardware/OS error. | Log critical failure and abort. |
| **`35`** | File Error | File not found during `OPEN INPUT` or `OPEN I-O`. | Verify file path / create initial file. |
| **`41`** | Logic Error | File already open. | Do not re-open an open file. |
| **`42`** | Logic Error | File already closed. | Do not close a closed file. |

---

## 4. ISAM Lifecycle: Create, Read, Update, Delete (CRUD)

### Step 1: Open Modes
- `OPEN OUTPUT`: Creates a new file (truncating any existing file). Used for initial data population.
- `OPEN INPUT`: Opens file for read-only access.
- `OPEN I-O`: Opens file for reading, inserting (`WRITE`), updating (`REWRITE`), and deleting (`DELETE`).

### Step 2: Random Read
To fetch a specific record:
```cobol
       MOVE "PRD1001" TO PROD-ID
       READ PROD-FILE
           INVALID KEY
               DISPLAY "Error: Product not found (Status: " WS-STATUS ")"
           NOT INVALID KEY
               DISPLAY "Found: " PROD-NAME " Price: " PROD-PRICE
       END-READ.
```

### Step 3: In-Place Update (`REWRITE`)
To modify an existing record:
```cobol
       MOVE "PRD1001" TO PROD-ID
       READ PROD-FILE
           NOT INVALID KEY
               MOVE 249.99 TO PROD-PRICE
               REWRITE PROD-RECORD
                   INVALID KEY
                       DISPLAY "Update failed!"
                   NOT INVALID KEY
                       DISPLAY "Product price updated successfully."
               END-REWRITE
       END-READ.
```

> [!IMPORTANT]
> A record must be successfully read before calling `REWRITE` in many access scenarios, and the `RECORD KEY` field itself must never be modified during a `REWRITE`.

### Step 4: Deleting a Record (`DELETE`)
```cobol
       MOVE "PRD1001" TO PROD-ID
       DELETE PROD-FILE RECORD
           INVALID KEY
               DISPLAY "Cannot delete: Record not found."
           NOT INVALID KEY
               DISPLAY "Record deleted."
       END-DELETE.
```

---

## 5. Summary Checklist for Modern File Systems

- [x] Use `ORGANIZATION IS LINE SEQUENTIAL` for human-readable text, CSV, and logs.
- [x] Use `ORGANIZATION IS INDEXED` with `ACCESS MODE IS DYNAMIC` when fast key retrieval and updates are required.
- [x] Always declare a 2-character `FILE STATUS IS WS-STATUS` and verify `WS-STATUS = "00"` after every operation.
- [x] Eliminate hardcoded file paths in enterprise code by leveraging runtime environment variables (`export DD_<name>=...`).
