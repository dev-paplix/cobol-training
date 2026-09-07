# Chapter 3: Data Provider Integration & Type Mapping

In enterprise development, data corruption most frequently occurs at the boundary between different data models: **COBOL's fixed-layout record structures** vs. **SQL's dynamic, typed relational schemas**.

This chapter details exact type mappings, precision guarantees, and conversion patterns when exchanging data between COBOL and SQL databases.

---

## 1. COBOL vs. SQL Data Models

| Feature | COBOL Representation | SQL (Relational / SQLite) |
| :--- | :--- | :--- |
| **String Storage** | Fixed length (`PIC X(n)`), padded with spaces (`0x20`) | Variable length (`TEXT` / `VARCHAR`), null-terminated (`\0`) |
| **Integers** | Binary words (`PIC S9(9) BINARY` / `COMP-5`) | 1, 2, 3, 4, 6, or 8-byte variable integers (`INTEGER`) |
| **Financial Decimals** | Packed Decimal (`PIC S9(m)V9(n) COMP-3`), fixed-point BCD | `NUMERIC`, `REAL` (IEEE 754 Float), or scaled `INTEGER` |
| **Floating Point** | `USAGE COMP-1` (32-bit), `USAGE COMP-2` (64-bit) | `REAL` (64-bit IEEE 754 double precision) |
| **Null Values** | No native NULL concept (uses blanks, low-values, or zeros) | First-class `NULL` state |

---

## 2. Comprehensive Type Mapping Reference Table

| COBOL Declaration | Storage Bytes | SQL Type (SQLite) | C Type in Bridge | Mapping Strategy & Notes |
| :--- | :--- | :--- | :--- | :--- |
| `PIC X(n)` | $n$ bytes | `TEXT` | `char*` | Space-padded in COBOL; bridge strips trailing spaces or pads to size. |
| `PIC S9(4) BINARY` | 2 bytes | `INTEGER` | `int16_t` | Fits inside SQLite 16-bit integer range (-32,768 to 32,767). |
| `PIC S9(9) BINARY` / `COMP-5` | 4 bytes | `INTEGER` | `int32_t` | Standard 32-bit integer (-2,147,483,648 to 2,147,483,647). |
| `PIC S9(18) BINARY` / `COMP-5`| 8 bytes | `INTEGER` | `int64_t` | Large 64-bit integer IDs or microsecond timestamps. |
| `USAGE COMP-2` | 8 bytes | `REAL` | `double` | Direct 64-bit IEEE double. Ideal for scientific / statistical values. |
| `PIC S9(7)V99 COMP-3` | 5 bytes | `REAL` or `INTEGER` | `double` or `int64_t` | **Financial values**: Can be mapped directly to `REAL` or stored as integer cents. |

---

## 3. Financial Decimals: Avoiding Floating-Point Inaccuracy

A major pitfall in legacy migrations is converting COBOL `COMP-3` (Packed Decimal) into standard SQL floating-point `REAL` / `FLOAT`. In IEEE 754 floating-point arithmetic, fractions like `0.10` or `0.01` cannot be represented precisely in binary, causing fractional penny roundoff errors (e.g., `0.10000000000000000555`).

COBOL eliminates this via decimal fixed-point arithmetic (`COMP-3`). When interfacing with SQL, enterprise developers use one of two robust strategies:

### Strategy 1: Storing Monetary Values as Integer Cents
Convert monetary amounts to cents by multiplying by 100 before writing to SQL, and dividing by 100 upon retrieval:

```cobol
      *> In COBOL:
       01  WS-BALANCE-DOLLARS       PIC S9(7)V99 VALUE 12450.75.
       01  WS-BALANCE-CENTS         PIC S9(9) BINARY.

      *> Convert to cents before SQL INSERT
       COMPUTE WS-BALANCE-CENTS = WS-BALANCE-DOLLARS * 100.
      *> Stored in SQLite as INTEGER: 1245075

      *> On retrieval from SQL:
       COMPUTE WS-BALANCE-DOLLARS = WS-BALANCE-CENTS / 100.
```
**Advantage**: 100% immune to floating-point rounding errors across all databases and platforms.

### Strategy 2: Bridge Floating-Point with Scaled Transfer
When SQLite's `REAL` column is used, the C-bridge retrieves the value via `sqlite3_column_double` directly into a COBOL `USAGE COMP-2` (double-precision float). COBOL then computes the assignment into `COMP-3` using `ROUNDED`:

```cobol
       01  WS-SQL-DOUBLE            USAGE COMP-2.
       01  WS-ACCT-BALANCE          PIC S9(9)V99 COMP-3.

       CALL "cob_sqlite_get_double" USING
           BY REFERENCE STMT-HANDLE
           BY VALUE 2
           BY REFERENCE WS-SQL-DOUBLE

       COMPUTE WS-ACCT-BALANCE ROUNDED = WS-SQL-DOUBLE.
```

---

## 4. String Handling & Buffer Padding

In COBOL, fixed-width fields retain trailing spaces. If a `PIC X(30)` field contains the name `"JOHN DOE"`, it is stored in memory as 8 characters followed by 22 spaces.

When interfacing with SQL:
1. **Inserting into SQL**: Trailing spaces should ideally be trimmed or passed to SQL as a standard string.
2. **Retrieving from SQL**: If the database returns `"ACME CORP"` (9 characters), the bridge must pad the remaining 21 bytes with spaces (`0x20`) so COBOL string operations (`IF`, `EVALUATE`, `DISPLAY`) behave consistently.

### The C-Bridge Implementation Pattern
```c
void cob_sqlite_get_text(sqlite3_stmt *stmt, int col_idx, char *dest, int dest_len) {
    const unsigned char *text = sqlite3_column_text(stmt, col_idx);
    int len = 0;
    if (text != NULL) {
        len = strlen((const char *)text);
        if (len > dest_len) len = dest_len;
        memcpy(dest, text, len);
    }
    /* Pad remaining bytes with spaces to satisfy COBOL fixed-width semantics */
    if (len < dest_len) {
        memset(dest + len, ' ', dest_len - len);
    }
}
```

---

## 5. Handling `NULL` Values

In SQL, a column can be `NULL` (unknown or absent). COBOL variables, however, always have a byte value (e.g., all spaces or zeros).

When reading nullable columns:
1. The C bridge can test `sqlite3_column_type(stmt, col_idx) == SQLITE_NULL`.
2. If `SQLITE_NULL`, the bridge populates the COBOL field with a predefined sentinel value (such as spaces for `PIC X` or zero for numeric).

---

## 6. Summary Checklist for SQL Data Mapping

- [x] Use `PIC S9(9) BINARY` / `COMP-5` for 32-bit SQL `INTEGER` primary keys.
- [x] Use `USAGE COMP-2` as an intermediary for 64-bit SQL `REAL` fields.
- [x] Use `PIC S9(m)V9(n) COMP-3` for final business calculations, using `ROUNDED` on incoming data.
- [x] For critical financial systems, consider storing monetary amounts in SQL as integer cents.
- [x] Ensure string extraction functions pad target buffers with spaces to adhere to COBOL fixed-length field semantics.

