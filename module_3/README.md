# Module 3: Advanced Data Handling and File Systems

Welcome to **Module 3** of the COBOL Training Series. This module focuses on the heart of enterprise computing: **persisting, querying, transforming, and streaming data**. 

In traditional enterprise architectures, COBOL programs interacted with flat files managed by JCL (Job Control Language) on mainframes. In modern Linux, cloud, and microservice architectures, COBOL programs must handle:
1. **Modern File Systems**: Line Sequential (text/CSV), Record Sequential, and high-performance **Indexed (ISAM)** files with B-Tree keys.
2. **Relational Database Connectivity**: Embedding SQL databases (**SQLite3**) into COBOL using an ultra-fast, native C bridge without proprietary middleware or bulky runtimes.
3. **Exact Data Provider Mapping**: Safely mapping COBOL `PIC` clauses (`PIC X`, `COMP-3` Packed Decimal, `BINARY`, `COMP-2`) to SQL storage classes (`TEXT`, `INTEGER`, `REAL`) with zero precision loss.
4. **Modern Web Data Streams**: Ingesting and producing modern web data formats—streaming **XML** via native `XML GENERATE` and processing **JSON** payloads via COBOL's built-in `STRING` and `UNSTRING` facilities.

All samples and exercises in this module are **100% native GnuCOBOL** (`cobc` on Linux) with zero Fujitsu NetCOBOL dependencies.

---

## 🎯 Learning Objectives

By completing this module, you will be able to:
1. **Transition from Mainframe JCL to Modern File Systems**: Replace `//DD` statements with environment variables (`export DD_...`) and implement robust `FILE STATUS` error handling (`00`, `10`, `23`, etc.).
2. **Master Indexed (ISAM) Files**: Implement fast indexed record storage, primary `RECORD KEY` lookups, record additions, and in-place `REWRITE` updates.
3. **Execute SQL from COBOL**: Integrate SQLite3 to create tables, execute parameterized DDL/DML, and iterate over query result sets using cursor step logic.
4. **Preserve Computational Precision**: Accurately map COBOL fixed-point packed decimals (`COMP-3`) and binary integers to database column types without floating-point roundoff errors.
5. **Serialize and Deserialize Web Streams**: Output structured XML documents from COBOL hierarchical records using `XML GENERATE`, and build/parse JSON data streams.

---

## 📂 Module Directory Layout

```text
module_3/
├── README.md                                    # Module Syllabus, Overview & Index
├── 01_traditional_vs_modern_file_systems.md     # Guide 1: Line/Record Sequential, ISAM & Env Vars
├── 02_sqlite_database_connectivity.md          # Guide 2: SQLite3 Integration, C-Bridge & Transactions
├── 03_sql_data_type_mapping.md                 # Guide 3: Mapping COBOL PIC clauses to SQL types
├── 04_xml_and_json_processing.md               # Guide 4: XML GENERATE, JSON Serialization/UNSTRING
├── 05_exercises_and_solutions.md               # Guide 5: Exercise Specs, Test Scenarios & Solution Keys
│
├── samples/                                     # Runnable Reference Implementations
│   ├── 01_FileIO/
│   │   ├── SequentialFileDemo.cob               # Line Sequential reader/writer with FILE STATUS
│   │   └── IndexedFileDemo.cob                  # Indexed ISAM with RECORD KEY & random access
│   ├── 02_DatabaseSQLite/
│   │   ├── cob_sqlite.c                         # Safe, high-performance C bridge for SQLite3
│   │   ├── SQLITE.CPY                           # Copybook with status codes & function prototypes
│   │   └── DatabaseDemo.cob                     # DDL, INSERT, and SELECT cursor traversal
│   ├── 03_DataMapping/
│   │   └── TypeMappingDemo.cob                  # Numeric & string fidelity: COMP-3/BINARY vs SQL
│   └── 04_XML_JSON/
│       ├── XmlDemo.cob                          # XML GENERATE and hierarchical group items
│       └── JsonDemo.cob                         # JSON payload construction and UNSTRING parsing
│
└── exercises/                                   # Practical Labs (Starter & Solution)
    ├── exercise_1_indexed_catalog/              # ISAM Product Catalog (Add, Query, Update, Delete)
    │   ├── starter/
    │   └── solution/
    ├── exercise_2_sqlite_ledger/                # SQLite Financial Ledger with Transaction Audit
    │   ├── starter/
    │   └── solution/
    └── exercise_3_json_order_processor/         # Ingest JSON Order, Calculate Tax, Emit XML Slip
        ├── starter/
        └── solution/
```

---

## 🧭 Learning & Lab Progression

1. **Step 1: Read the Guides**:
   - [01. Traditional vs. Modern File Systems](file:///home/wesi/codes/cobol-training/module_3/01_traditional_vs_modern_file_systems.md)
   - [02. SQLite Database Connectivity](file:///home/wesi/codes/cobol-training/module_3/02_sqlite_database_connectivity.md)
   - [03. SQL Data Type Mapping](file:///home/wesi/codes/cobol-training/module_3/03_sql_data_type_mapping.md)
   - [04. XML and JSON Processing](file:///home/wesi/codes/cobol-training/module_3/04_xml_and_json_processing.md)

2. **Step 2: Study and Run the Samples**:
   - Check file operations in `samples/01_FileIO/`.
   - Run the SQLite database demo in `samples/02_DatabaseSQLite/`.
   - Inspect data type fidelity in `samples/03_DataMapping/`.
   - Explore XML and JSON processing in `samples/04_XML_JSON/`.

3. **Step 3: Complete the Hands-on Exercises**:
   - Follow the detailed steps in [05. Exercises and Solutions Guide](file:///home/wesi/codes/cobol-training/module_3/05_exercises_and_solutions.md).
   - Complete the starter code in each exercise directory and test against the reference solution.

---

## ⚡ Quick Compilation & Execution Reference

### File I/O Samples
```bash
# Compile and run Sequential File Demo
cd /home/wesi/codes/cobol-training/module_3/samples/01_FileIO
cobc -x -free SequentialFileDemo.cob -o SequentialFileDemo
./SequentialFileDemo

# Compile and run Indexed (ISAM) File Demo
cobc -x -free IndexedFileDemo.cob -o IndexedFileDemo
./IndexedFileDemo
```

### SQLite Database Samples
```bash
# Compile COBOL with C-Bridge and link sqlite3
cd /home/wesi/codes/cobol-training/module_3/samples/02_DatabaseSQLite
cobc -x -free DatabaseDemo.cob cob_sqlite.c -lsqlite3 -o DatabaseDemo
./DatabaseDemo
```

### XML & JSON Samples
```bash
# Compile and run XML Demo
cd /home/wesi/codes/cobol-training/module_3/samples/04_XML_JSON
cobc -x -free XmlDemo.cob -o XmlDemo
./XmlDemo

# Compile and run JSON Demo
cobc -x -free JsonDemo.cob -o JsonDemo
./JsonDemo
```
