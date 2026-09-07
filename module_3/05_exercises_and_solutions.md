# Chapter 5: Practical Exercises & Solution Guide

This guide provides the specifications, requirements, sample test cases, and compilation commands for the three practical exercises in **Module 3**.

---

## Exercise 1: Indexed (ISAM) Product Catalog
**Directory**: `exercises/exercise_1_indexed_catalog/`

### Scenario
An inventory warehouse needs a reliable, high-speed product catalog. Rather than reading an entire file sequentially, the program must look up, modify, and delete product records instantly using an indexed file with primary key indexing.

### Specifications
1. **Record Layout**:
   - `PROD-ID`: `PIC X(6)` (Primary Record Key, e.g., `"PRD101"`)
   - `PROD-NAME`: `PIC X(25)`
   - `PROD-QTY`: `PIC 9(4)`
   - `PROD-PRICE`: `PIC 9(4)V99`
2. **Operations Required**:
   - **Initial Load**: Insert 3 sample products (`PRD001`, `PRD002`, `PRD003`). Handle duplicate key errors (`FILE STATUS = "22"`).
   - **Direct Query**: Look up `PRD002` by key and display details. Handle not found (`FILE STATUS = "23"`).
   - **Inventory Update**: Modify quantity for `PRD001` using `REWRITE`.
   - **Record Deletion**: Delete `PRD003` using `DELETE`.
   - **Audit Scan**: Sequentially read all remaining active records and print an inventory valuation summary.

### Compilation & Test
```bash
cd exercises/exercise_1_indexed_catalog/solution
cobc -x -free CatalogManager.cob -o CatalogManager
./CatalogManager
```

---

## Exercise 2: SQLite Financial Ledger
**Directory**: `exercises/exercise_2_sqlite_ledger/`

### Scenario
A financial institution is modernizing its transaction journal from flat files to SQLite. All transactions must be recorded with strict ACID transaction guarantees.

### Specifications
1. **Database Setup**:
   - Database name: `ledger.db`.
   - Table: `journal (entry_id INT, account_name TEXT, tx_type TEXT, amount REAL)`.
2. **Operations Required**:
   - Open database and initialize table.
   - Begin transaction.
   - Insert entries:
     - Entry 1: Account `"Checking"`, Type `"CREDIT"`, Amount `$1000.00`
     - Entry 2: Account `"Checking"`, Type `"DEBIT"`, Amount `$350.50`
     - Entry 3: Account `"Savings"`, Type `"CREDIT"`, Amount `$500.00`
   - Execute query `SELECT account_name, tx_type, amount FROM journal ORDER BY entry_id;`.
   - Step through the cursor using `cob_sqlite_step` and sum up the net balance for `"Checking"`.
   - Commit transaction and safely close database.

### Compilation & Test
```bash
cd exercises/exercise_2_sqlite_ledger/solution
cobc -x -free GeneralLedger.cob cob_sqlite.c -lsqlite3 -o GeneralLedger
./GeneralLedger
```

---

## Exercise 3: JSON E-Commerce Order Processor
**Directory**: `exercises/exercise_3_json_order_processor/`

### Scenario
An e-commerce gateway receives order payloads in JSON. The COBOL backend must ingest the JSON stream, validate business rules, calculate tax, and emit an XML receipt document for fulfillment.

### Specifications
1. **Input JSON Payload**:
   ```json
   {"order_id": 88401, "customer": "Global Supplies Ltd", "subtotal": 1250.00}
   ```
2. **Business Rules**:
   - Extract `order_id`, `customer`, and `subtotal` from the JSON string.
   - Calculate Sales Tax at 8.0% (`subtotal * 0.08`).
   - Compute Total Order Cost (`subtotal + tax`).
   - If Total exceeds `$5000.00`, set status to `"REVIEW_REQUIRED"`; otherwise, set status to `"APPROVED"`.
3. **XML Output**:
   - Populate a COBOL group structure `ORDER-CONFIRMATION`.
   - Use `XML GENERATE` to emit the final XML confirmation string.

### Compilation & Test
```bash
cd exercises/exercise_3_json_order_processor/solution
cobc -x -free OrderProcessor.cob -o OrderProcessor
./OrderProcessor
```

