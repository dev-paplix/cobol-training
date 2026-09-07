# Module 2: Modern COBOL Features and Object-Oriented Extensions
# Module 2: Modern GnuCOBOL Features, Modular Architecture, and Data Types

Welcome to **Module 2** of the NetCOBOL Training Series. This module transitions you from traditional procedural COBOL into **Modern, Object-Oriented COBOL (OO-COBOL)** targeting the Microsoft .NET ecosystem.
Welcome to **Module 2** of the GnuCOBOL Training Series. This module focuses on modern COBOL programming patterns within the GnuCOBOL (`cobc`) ecosystem: **Free-Format layout**, **Modular Subprogram Architecture**, **User-Defined Functions**, and **Advanced Data Representation**.

While Module 1 covered the architectural bridge and IDE integration, Module 2 focuses heavily on **practical source code, design patterns, and hands-on exercises**.
All samples and exercises in this module are **100% native GnuCOBOL** and ready to compile using `cobc` on Linux, macOS, and Windows.

---

## 🎯 Module Objectives

1. **Break Free from the 72-Column Limitation**: Master modern free-format source layout, inline comments (`*>`), and flexible line lengths.
2. **Understand OO-COBOL Architecture**: Learn `CLASS-ID`, `FACTORY` (class/static scope), `OBJECT` (instance scope), constructors (`NEW`), and methods (`METHOD-ID`).
3. **Implement Inheritance & Polymorphism**: Build extensible class hierarchies using `INHERITS`, method overriding (`OVERRIDE`), and `INVOKE SUPER`.
4. **Harness .NET Core Types**: Seamlessly manipulate `System.String`, `System.Int32`, and `System.Decimal` with maximum precision and zero truncation.
1. **Break Free from the 72-Column Limitation**: Master modern free-format source layout (`>>SOURCE FORMAT FREE`), inline comments (`*>`), and lines up to 255 characters.
2. **Master Modular COBOL Architecture**: Learn subprogram encapsulation, call-by-reference/content/value, dynamic module compilation (`cobc -m`), and user-defined functions.
3. **Advanced String Processing**: Utilize COBOL's powerful `STRING`, `UNSTRING`, and modern intrinsic string functions (`FUNCTION TRIM`, `FUNCTION SUBSTITUTE`, `FUNCTION UPPER-CASE`).
4. **Exact Financial Mathematics**: Leverage `USAGE COMP-3` (Packed Decimal) with `ROUNDED` and `ON SIZE ERROR` to eliminate binary floating-point roundoff errors.

---

## 📂 Module Directory Layout

```text
module_2/
├── README.md                                    # This guide & index
├── 01_modern_features_and_free_format.md        # Technical Guide: Free-Format syntax rules
├── 02_oo_cobol_classes_methods_inheritance.md   # Technical Guide: OO-COBOL grammar & inheritance
├── 03_dotnet_data_types_interop.md              # Technical Guide: System.String, Int32 & Decimal
├── 04_exercises_guide.md                        # Instructions & specifications for all 3 exercises
├── README.md                                    # This guide & syllabus
├── 01_modern_features_and_free_format.md        # Guide 1: Free-Format syntax & compiler directives
├── 02_oo_cobol_classes_methods_inheritance.md   # Guide 2: Modular Architecture, Subprograms & Functions
├── 03_dotnet_data_types_interop.md              # Guide 3: Data Types, String Manipulation & Financial Math
├── 04_exercises_guide.md                        # Guide 4: Specifications for all 3 exercises
│
├── samples/                                     # Full, runnable code examples
├── samples/                                     # Complete, Runnable Code Examples
│   ├── 01_FreeFormat/
│   │   ├── FixedFormatDemo.cob                  # Traditional punch-card format for comparison
│   │   └── FreeFormatDemo.cob                   # Modern free-format counterpart
│   ├── 02_OOCobolBasics/
│   │   ├── Customer.cob                         # Complete OO-COBOL class (Factory & Object)
│   │   └── TestCustomer.cob                     # Driver program instantiating Customer objects
│   ├── 03_Inheritance/
│   │   ├── BankAccount.cob                      # Base class
│   │   ├── SavingsAccount.cob                   # Derived class (adds interest calculations)
│   │   ├── CheckingAccount.cob                  # Derived class (overrides Withdraw with overdraft)
│   │   └── BankingSimulator.cob                 # Polymorphic test harness
│   └── 04_DotNetTypes/
│       ├── StringOperations.cob                 # System.String manipulation & methods
│       ├── NumericAndMath.cob                   # Int32, COMP-5, and System.Math
│       └── FinancialDecimal.cob                 # System.Decimal vs COMP-3 financial calculations
│   ├── 02_ModularArchitecture/
│   │   ├── CustomerService.cob                  # Modular subprogram with LINKAGE SECTION
│   │   └── MainCustomerApp.cob                  # Main program calling CustomerService
│   ├── 03_SubprogramsAndDispatch/
│   │   ├── BankService.cob                      # Account business rules & dispatch engine
│   │   └── BankingSimulator.cob                 # Multi-account test harness
│   └── 04_DataTypesAndStrings/
│       ├── StringOperations.cob                 # UNSTRING, STRING, and Intrinsic string functions
│       ├── NumericAndMath.cob                   # COMP-5 binary, Intrinsic math (SQRT, MOD, MAX, MIN)
│       └── FinancialDecimal.cob                 # Exact COMP-3 banking math vs Float roundoff
│
└── exercises/                                   # Practical labs with Starters & Solutions
    ├── exercise_1_oo_shape_hierarchy/           # OO hierarchy (Shape -> Rectangle, Circle)
    │   ├── starter/                             # Boilerplates for you to complete
    │   └── solution/                            # Verified reference implementation
    ├── exercise_2_dotnet_string_parser/         # CSV/string sanitization using System.String
└── exercises/                                   # Practical Labs with Starters & Solutions
    ├── exercise_1_modular_shapes/               # Modular geometry calculation engine
    │   ├── starter/
    │   └── solution/
    └── exercise_3_payroll_system/               # Full OO Payroll system with System.Decimal
    ├── exercise_2_string_parser/                # Raw transaction string cleansing & UNSTRING
    │   ├── starter/
    │   └── solution/
    └── exercise_3_payroll_system/               # Enterprise modular payroll with exact COMP-3
        ├── starter/
        └── solution/
```

---

## 🧭 Learning & Lab Progression

1. **Step 1: Read the Guides**:
   - Skim [01. Free-Format Features](file:///e:/training/cobol-training/module_2/01_modern_features_and_free_format.md)
   - Read [02. OO-COBOL Classes & Inheritance](file:///e:/training/cobol-training/module_2/02_oo_cobol_classes_methods_inheritance.md)
   - Read [03. .NET Data Types Interop](file:///e:/training/cobol-training/module_2/03_dotnet_data_types_interop.md)
2. **Step 2: Study the Samples in `samples/`**:
   - Compare `FixedFormatDemo.cob` vs `FreeFormatDemo.cob`.
   - Trace how `Customer.cob` encapsulates state and exposes methods.
   - Observe how `SavingsAccount` and `CheckingAccount` inherit from `BankAccount`.
   - Run `FinancialDecimal.cob` to see high-precision financial arithmetic.
3. **Step 3: Complete the Exercises in `exercises/`**:
   - Follow the detailed steps in [04. Exercises Guide](file:///e:/training/cobol-training/module_2/04_exercises_guide.md).
   - Work through the `starter/` code first, then verify your work against the `solution/`.

1. **Read Guide 1**: Learn how to format modern COBOL files cleanly using `>>SOURCE FORMAT FREE`.
2. **Read Guide 2**: Learn how GnuCOBOL structures modular systems using `CALL ... USING` and `LINKAGE SECTION`.
3. **Read Guide 3**: Master data types: strings, binary numbers (`COMP-5`), and currency (`COMP-3`).
4. **Compile & Run Samples**:
   ```bash
   cd module_2/samples/01_FreeFormat && cobc -x -free FreeFormatDemo.cob && ./FreeFormatDemo
   cd ../04_DataTypesAndStrings && cobc -x -free FinancialDecimal.cob && ./FinancialDecimal
   ```
5. **Complete the Exercises**: Work through `exercises/` starting from `starter/` and verify with `solution/`.
