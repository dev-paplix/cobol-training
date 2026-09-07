# Guide 1: Moving Beyond the 72-Column Limit — Free-Format Source Code
# Guide 1: Moving Beyond the 72-Column Limit — Free-Format in GnuCOBOL

## 1. The Legacy Punch-Card Constraint
## 1. The Legacy 80-Column Punch-Card Constraint

Standard ANSI COBOL 85 enforced a rigid 80-column card format designed for 1960s punched cards:
- **Columns 1–6 (Sequence Area)**: Line numbers or sequence numbers (originally physically ordered card numbers).
- **Column 7 (Indicator Area)**: Comments (`*`), form-feed (`/`), debug code (`D`), or line continuation (`-`).
- **Columns 8–11 (Area A)**: Division headers, section headers, paragraph names, level indicators (`FD`, `01`, `77`).
- **Columns 12–72 (Area B)**: Entries, sentences, statements, and continuation lines.
- **Columns 73–80 (Identification Area)**: Ignored by compiler; used for program IDs or punch-card deck tracking.
Historical COBOL 85 enforced a strict 80-column punch-card layout:
- **Columns 1–6**: Sequence numbers.
- **Column 7**: Indicator area (`*` for comments, `/` for page eject, `-` for line continuation).
- **Columns 8–11 (Area A)**: Division, Section, Paragraph headers, and level numbers `01` and `77`.
- **Columns 12–72 (Area B)**: Standard statements and data descriptions.
- **Columns 73–80**: Program ID / identification (ignored by compiler).

If code accidentally spilled into column 73, it was silently discarded, causing subtle, baffling syntax or logic errors!
If code accidentally spilled into column 73, compilers silently discarded it, causing baffling bugs.

---

## 2. Modern Free-Format Syntax (`SOURCE(FREE)`)
## 2. Modern Free Format in GnuCOBOL

With the COBOL 2002 standard and Fujitsu NetCOBOL for .NET, you can eliminate this constraint entirely using **Free Format**.
Modern COBOL standards (COBOL 2002/2014) and **GnuCOBOL** eliminate this restriction completely.

### Activating Free Format:
1. **Via Source Directive**:
   Add `@OPTIONS SOURCE(FREE)` at the very beginning of the source file.
2. **Via Visual Studio Project Properties**:
   In the project properties under **COBOL Compiler Options**, toggle **Source Format** to **Free Format**.
You can activate free format in GnuCOBOL in two ways:

### Rules of Free Format:
- **No Column Margins**: Statements, headers, and division identifiers can start in any column (column 1 through 255).
- **Line Length**: Lines can extend up to **255 characters** (rather than 72).
1. **Via Source Directive** (Standard ISO COBOL):
   Place this directive on **Line 1** of your file:
   ```cobol
   >>SOURCE FORMAT FREE
   ```
2. **Via `cobc` Compiler Flag**:
   Pass `-free` when invoking the compiler:
   ```bash
   cobc -x -free MyProgram.cob
   ```

### Free-Format Rules in GnuCOBOL:
- **No Column Margins**: Division headers, paragraph names, variables, and statements can start in any column.
- **Extended Line Length**: Lines can extend up to **255 characters** per line.
- **Modern Inline Comments**:
  - Use `*>` for comments. Everything from `*>` to the end of the line is treated as a comment.
  - You can place comments at the start of a line or inline after code.
  - Traditional `*` in column 7 is no longer required.
- **String Continuation & Literal Concatenation**:
  - Instead of awkward column 7 `-` continuation, strings can be cleanly joined across lines using the `&` concatenation operator.
  - Use **`*>`** for comments. Everything from `*>` to the end of the line is a comment.
  - Can be placed at the start of a line or inline after executable statements.
- **String Continuation**: You can break strings naturally or concatenate them using the `&` operator.

---

## 3. Side-by-Side Comparison

### Legacy Fixed Format:
```cobol
      *================================================================*
      * COLUMNS: 1-6 Sequence | 7 Ind | 8-11 Area A | 12-72 Area B     *
      *================================================================*
000100 IDENTIFICATION DIVISION.
000200 PROGRAM-ID. FIXEDDEMO.
000300 DATA DIVISION.
000400 WORKING-STORAGE SECTION.
000500 01  WS-LONG-STRING              PIC X(100) VALUE "THIS IS A VER
000600-    "Y LONG STRING THAT HAD TO BE CONTINUED USING HYPHEN".
000500 01  WS-LONG-TEXT               PIC X(90) VALUE "THIS IS A VER
000600-    "Y LONG STRING THAT REQUIRES HYPHEN CONTINUATION IN COL 7.".
000700 PROCEDURE DIVISION.
000800 0000-MAIN.
000900     DISPLAY "HELLO WORLD FROM FIXED FORMAT".
000900     DISPLAY WS-LONG-TEXT.
001000     GOBACK.
```

### Modern Free Format:
### Modern GnuCOBOL Free Format:
```cobol
@OPTIONS SOURCE(FREE)
>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. FreeDemo.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> Clean indentation and modern comments
    01 WS-LONG-STRING PIC X(100) VALUE 
       "This is a clean, modern string that spans lines naturally " &
       "without ugly hyphen continuation rules.".
    *> Indent cleanly to any column
    01 WS-LONG-TEXT PIC X(120) VALUE 
       "This is a modern string written cleanly without punch-card " &
       "margin limitations or awkward hyphen continuations.".

PROCEDURE DIVISION.
MainMethod.
    DISPLAY "Hello World from Modern Free-Format COBOL!" *> Inline comment!
MainLogic.
    DISPLAY "Hello from Modern Free-Format GnuCOBOL!" *> Inline comment
    DISPLAY WS-LONG-TEXT
    GOBACK.
```

---

## 4. Best Practices for Modern COBOL Code Layout

1. **Consistent 4-Space Indentation**: Use 4 spaces for structural blocks (Divisions $\rightarrow$ Sections $\rightarrow$ Paragraphs/Methods $\rightarrow$ Logic statements).
2. **Logical Variable Grouping**: Indent level numbers (`01`, `05`, `10`) to reflect record hierarchy clearly.
3. **Use `*>` for All Comments**: It avoids confusion when migrating or re-formatting files.
4. **Descriptive Mixed-Case Identifiers**: NetCOBOL supports mixed-case and hyphens (e.g., `Customer-Account-Number` or `CustomerAccountNumber` when using `ALPHAL(WORD)`).

