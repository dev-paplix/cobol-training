# Guide 4: Module 2 Practical Exercises & Lab Instructions
# Guide 4: Module 2 Practical Exercises & Lab Instructions (GnuCOBOL)

This guide provides the specifications, requirements, and testing criteria for the three hands-on exercises in Module 2.
This guide provides the specifications and test criteria for the three hands-on exercises in Module 2.

All starter boilerplates and completed reference solutions are available in [`exercises/`](file:///e:/training/cobol-training/module_2/exercises/).
All starter boilerplates and completed reference solutions are located in [`exercises/`](file:///e:/training/cobol-training/module_2/exercises/).

---

## 🏗️ Exercise 1: Object-Oriented Shape Hierarchy
## 📐 Exercise 1: Modular Geometry Engine

### Location:
- Starter: [`exercises/exercise_1_oo_shape_hierarchy/starter/`](file:///e:/training/cobol-training/module_2/exercises/exercise_1_oo_shape_hierarchy/starter/)
- Solution: [`exercises/exercise_1_oo_shape_hierarchy/solution/`](file:///e:/training/cobol-training/module_2/exercises/exercise_1_oo_shape_hierarchy/solution/)
- Starter: [`exercises/exercise_1_modular_shapes/starter/`](file:///e:/training/cobol-training/module_2/exercises/exercise_1_modular_shapes/starter/)
- Solution: [`exercises/exercise_1_modular_shapes/solution/`](file:///e:/training/cobol-training/module_2/exercises/exercise_1_modular_shapes/solution/)

### Objective:
Practice OO-COBOL class creation, constructors, inheritance (`INHERITS`), method overriding (`OVERRIDE`), and polymorphic method dispatch.
Implement a modular geometry application consisting of a main driver (`ShapeApp.cob`) and callable subprograms (`CalcRectangle.cob` and `CalcCircle.cob`) with parameter validation.

### Architecture:
### Compilation Command:
```bash
cobc -x -free ShapeApp.cob CalcRectangle.cob CalcCircle.cob -o ShapeApp
./ShapeApp
```
           +---------------------------------------+
           |                 Shape                 |
           |---------------------------------------|
           | - Name: System.String                 |
           |---------------------------------------|
           | + GetArea(): System.Double            |
           | + PrintDetails(): void                |
           +---------------------------------------+
                              ^
                              |
              +---------------+---------------+
              |                               |
+---------------------------+   +---------------------------+
|         Rectangle         |   |          Circle           |
|---------------------------|   |---------------------------|
| - Width:  System.Double   |   | - Radius: System.Double   |
| - Height: System.Double   |   |---------------------------|
|---------------------------|   | + GetArea() OVERRIDE      |
| + GetArea() OVERRIDE      |   +---------------------------+
+---------------------------+
```

### Tasks:
1. Complete `Shape.cob`: Base class containing the `Name` attribute, a base constructor `NEW`, and a virtual/base `GetArea` returning 0.0.
2. Complete `Rectangle.cob`: Inherits from `Shape`, takes `Width` and `Height`, and overrides `GetArea` to return `Width * Height`.
3. Create `Circle.cob`: Inherits from `Shape`, takes `Radius`, and overrides `GetArea` using formula $\pi \times r^2$ via `System.Math::PI`.
4. Implement `ShapeApp.cob`: Instantiate both a `Rectangle` and a `Circle`, store them in polymorphic `Shape` object references, and execute their `PrintDetails` and `GetArea` methods.

---

## 🔤 Exercise 2: .NET String Parsing & Data Cleansing
## 🔤 Exercise 2: Delimited String Parser & Data Normalizer

### Location:
- Starter: [`exercises/exercise_2_dotnet_string_parser/starter/`](file:///e:/training/cobol-training/module_2/exercises/exercise_2_dotnet_string_parser/starter/)
- Solution: [`exercises/exercise_2_dotnet_string_parser/solution/`](file:///e:/training/cobol-training/module_2/exercises/exercise_2_dotnet_string_parser/solution/)
- Starter: [`exercises/exercise_2_string_parser/starter/`](file:///e:/training/cobol-training/module_2/exercises/exercise_2_string_parser/starter/)
- Solution: [`exercises/exercise_2_string_parser/solution/`](file:///e:/training/cobol-training/module_2/exercises/exercise_2_string_parser/solution/)

### Objective:
Process unstructured and messy legacy data strings into structured business entities using .NET `System.String` and `System.Convert`.

### Input Data Format:
You will receive raw CSV transaction records in this format:
Use `UNSTRING`, `STRING`, `FUNCTION TRIM`, and `FUNCTION UPPER-CASE` to parse a raw unformatted CSV record:
```text
  "  TXN-9021 ;  acct-8492 ; 1250.75 ;  deposit   "
"TXN-9021;acct-8492;1250.75;deposit"
```
Normalize the data, parse the amount into a numeric item, and display an invoice/receipt slip.

### Tasks:
1. Strip outer whitespace and leading/trailing quotes using `Trim`.
2. Extract the individual fields by splitting on `;` delimiter.
3. Normalize the data:
   - Account ID must be converted to uppercase (`ACCT-8492`).
   - Transaction type must be capitalized or validated (`DEPOSIT`).
   - Amount string must be converted to `System.Decimal` / `COMP-3`.
4. Output a formatted transaction confirmation receipt using `System.String::Format`.
### Compilation Command:
```bash
cobc -x -free TransactionParser.cob -o TransactionParser
./TransactionParser
```

---

## 💼 Exercise 3: Enterprise OO Payroll System
## 💼 Exercise 3: Enterprise Modular Payroll System

### Location:
- Starter: [`exercises/exercise_3_payroll_system/starter/`](file:///e:/training/cobol-training/module_2/exercises/exercise_3_payroll_system/starter/)
- Solution: [`exercises/exercise_3_payroll_system/solution/`](file:///e:/training/cobol-training/module_2/exercises/exercise_3_payroll_system/solution/)

### Objective:
Combine OO-COBOL, inheritance, and exact `System.Decimal` arithmetic to build a production-grade payroll calculation engine.
Build an enterprise payroll processor combining:
- A main payroll ledger controller (`PayrollApp.cob`).
- A salaried pay calculation subprogram (`CalcSalariedPay.cob`).
- An hourly overtime pay calculation subprogram (`CalcHourlyPay.cob`) with $1.5\times$ overtime for hours $> 40$.
- High-precision `COMP-3` decimal math with `ROUNDED` protection.

### Class Structure:
1. **`Employee.cob` (Base Class)**:
   - Fields: `EmployeeId`, `FullName`, `BasePayRate` (`System.Decimal`).
   - Methods: `NEW` constructor, `CalculateGrossPay` (returns `System.Decimal`), `GetSummary`.
2. **`SalariedEmployee.cob` (Derived)**:
   - Inherits `Employee`.
   - `CalculateGrossPay` overrides base: Salaried employees get a fixed bi-weekly rate (`BasePayRate / 26`).
3. **`HourlyEmployee.cob` (Derived)**:
   - Inherits `Employee`.
   - Fields: `HoursWorked` (e.g. 45 hours).
   - `CalculateGrossPay` overrides base: Regular pay for hours $\le 40$; $1.5\times$ overtime for hours $> 40$.
4. **`PayrollApp.cob` (Test Harness)**:
   - Instantiates a salaried executive and an hourly contractor.
   - Calculates their pay using polymorphism.
   - Displays a clean payroll ledger.

### Compilation Command:
```bash
cobc -x -free PayrollApp.cob CalcSalariedPay.cob CalcHourlyPay.cob -o PayrollApp
./PayrollApp
```
