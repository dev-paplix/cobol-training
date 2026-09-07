# Lesson 4: Hands-on — Creating Your First "Modern COBOL" Project in Visual Studio
# Lesson 4: Hands-on — Creating Your First Modern GnuCOBOL Application

## 1. Lab Overview & Objectives

In this hands-on tutorial, you will create, build, and debug a **Modern NetCOBOL Console Application** inside Visual Studio.
In this hands-on lab, you will write, compile, run, and inspect your first **Modern GnuCOBOL application**.

Unlike legacy procedural COBOL, your application will:
- Use modern **Free Format** syntax (`SOURCE(FREE)`).
- Declare and consume **.NET Base Class Libraries (BCL)** via the `REPOSITORY` section.
- Interrogate the operating system using `System.Environment`.
- Fetch and format system timestamps using `System.DateTime`.
- Accept interactive console input using `System.Console`.
- Use the Visual Studio interactive debugger to set breakpoints and inspect runtime data.
Your application will:
- Use modern **Free Format** layout (`>>SOURCE FORMAT FREE`).
- Leverage standard **Intrinsic Functions** (`FUNCTION CURRENT-DATE`, `FUNCTION TRIM`, `FUNCTION UPPER-CASE`).
- Capture interactive terminal input via `ACCEPT` and format terminal output via `DISPLAY`.
- Compile into a standalone native binary using `cobc`.
- Inspect the binary with Linux/Unix utilities.

---

## 2. Step 1: Create the Project in Visual Studio
## 2. Step 1: Create the Project Directory

1. Open **Microsoft Visual Studio**.
2. On the start window, click **Create a new project**.
3. In the search box at the top, type `NetCOBOL`, or configure the dropdown filters:
   - **Language**: `COBOL`
   - **Platform**: `Windows`
   - **Project Type**: `Console`
4. Select the template: **NetCOBOL Console Application** and click **Next**.
Open your terminal and navigate to your workspace:

```bash
mkdir -p ~/codes/cobol-training/module_1/samples/HelloModernCobol
cd ~/codes/cobol-training/module_1/samples/HelloModernCobol
```
+-------------------------------------------------------------------------------+
| Configure your new project                                                    |
+-------------------------------------------------------------------------------+
| Project name:       HelloModernCobol                                          |
| Location:           E:\training\cobol-training\module_1\samples               |
| Solution name:      HelloModernCobol                                          |
| Target Framework:   .NET Framework 4.8 (or default available)                 |
+-------------------------------------------------------------------------------+
```
5. Click **Create**. Visual Studio will generate the solution and project files.

---

## 3. Step 2: Configure Project Properties for Free Format
## 3. Step 2: Write the Source Code (`Program1.cob`)

By default, some NetCOBOL templates default to legacy Fixed Format (columns 1-72). Let's configure the project to use **Free Format**:
Create and edit `Program1.cob`:

1. In the **Solution Explorer**, right-click the `HelloModernCobol` project node and select **Properties**.
2. Select the **COBOL Compiler Options** tab.
3. Locate **Source Format** and select **Free Format** (`SOURCE(FREE)`).
4. Ensure **Arithmetic** is set to **Extended Precision** (`ARITH(EXTEND)`).
5. Press `Ctrl + S` to save your project property changes.

---

## 4. Step 3: Write the Modern COBOL Code

Double-click `Program1.cob` in the Solution Explorer. Replace the default template contents with the following code:

```cobol
@OPTIONS SOURCE(FREE), ARITH(EXTEND), CHECK(ALL)
>>SOURCE FORMAT FREE
*>================================================================*
*> PROGRAM : Program1.cob                                         *
*> PURPOSE : First modern GnuCOBOL console application            *
*>================================================================*
IDENTIFICATION DIVISION.
PROGRAM-ID. Program1.

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
REPOSITORY.
    CLASS SYS-CONSOLE     AS "System.Console"
    CLASS SYS-DATETIME    AS "System.DateTime"
    CLASS SYS-ENVIRONMENT AS "System.Environment"
    CLASS SYS-STRING      AS "System.String"
    CLASS SYS-CONVERT     AS "System.Convert".

DATA DIVISION.
WORKING-STORAGE SECTION.
01 USER-NAME              OBJECT REFERENCE SYS-STRING.
01 CURRENT-DATE-TIME      OBJECT REFERENCE SYS-DATETIME.
01 FORMATTED-TIME         OBJECT REFERENCE SYS-STRING.
01 OS-VERSION             OBJECT REFERENCE SYS-STRING.
01 MACHINE-NAME           OBJECT REFERENCE SYS-STRING.
01 RAW-INPUT              OBJECT REFERENCE SYS-STRING.
01 BIRTH-YEAR-STR         OBJECT REFERENCE SYS-STRING.
*> User Input Variables
01 WS-USER-NAME               PIC X(30).
01 WS-CLEAN-NAME              PIC X(30).
01 WS-BIRTH-YEAR-ALPHA        PIC X(4).
01 WS-BIRTH-YEAR              PIC 9(4).

01 WS-BIRTH-YEAR          PIC S9(4) COMP-5.
01 WS-CURRENT-YEAR        PIC S9(4) COMP-5.
01 WS-CALCULATED-AGE      PIC S9(4) COMP-5.
01 WS-DISPLAY-AGE         PIC Z,ZZ9.
*> Date and Time Extraction via FUNCTION CURRENT-DATE
01 WS-CURRENT-DATE-DATA.
   05 WS-CURRENT-YEAR         PIC 9(4).
   05 WS-CURRENT-MONTH        PIC 9(2).
   05 WS-CURRENT-DAY          PIC 9(2).
   05 WS-CURRENT-HOUR         PIC 9(2).
   05 WS-CURRENT-MINUTE       PIC 9(2).
   05 WS-CURRENT-SECOND       PIC 9(2).
   05 FILLER                  PIC X(9).

*> Numeric Calculation Variables
01 WS-CALCULATED-AGE          PIC S9(4) USAGE BINARY.
01 WS-DISPLAY-AGE             PIC Z,ZZ9.

PROCEDURE DIVISION.
MAIN-PARAGRAPH.
    *> -----------------------------------------------------------
    *> 1. Print Header & System Information
    *> -----------------------------------------------------------
    INVOKE SYS-CONSOLE "Clear".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "==========================================================".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "       WELCOME TO MODERN NETCOBOL FOR .NET (VISUAL STUDIO)".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "==========================================================".
    *> 1. Display Formatted Header
    DISPLAY "==========================================================".
    DISPLAY "             WELCOME TO MODERN GNUCOBOL".
    DISPLAY "==========================================================".

    *> Retrieve OS Version and Machine Name via System.Environment
    INVOKE SYS-ENVIRONMENT "get_OSVersion" RETURNING OS-VERSION.
    INVOKE SYS-ENVIRONMENT "get_MachineName" RETURNING MACHINE-NAME.
    *> 2. Fetch System Date and Time
    MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-DATA.
    DISPLAY "Current Date : " WS-CURRENT-YEAR "-" WS-CURRENT-MONTH "-" WS-CURRENT-DAY.
    DISPLAY "Current Time : " WS-CURRENT-HOUR ":" WS-CURRENT-MINUTE ":" WS-CURRENT-SECOND.
    DISPLAY "----------------------------------------------------------".

    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Host Machine : " & MACHINE-NAME.
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "OS Platform  : " & OS-VERSION.
    *> 3. Collect Interactive User Input
    DISPLAY "Enter your full name: " WITH NO ADVANCING.
    ACCEPT WS-USER-NAME.
    MOVE FUNCTION TRIM(WS-USER-NAME) TO WS-CLEAN-NAME.

    *> Retrieve and format current date/time via System.DateTime
    INVOKE SYS-DATETIME "get_Now" RETURNING CURRENT-DATE-TIME.
    INVOKE CURRENT-DATE-TIME "ToString" 
        USING "dddd, MMMM dd, yyyy - hh:mm:ss tt" 
        RETURNING FORMATTED-TIME.
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Current Time : " & FORMATTED-TIME.
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "----------------------------------------------------------".
    DISPLAY "Enter your birth year (e.g. 1990): " WITH NO ADVANCING.
    ACCEPT WS-BIRTH-YEAR-ALPHA.
    MOVE FUNCTION NUMVAL(WS-BIRTH-YEAR-ALPHA) TO WS-BIRTH-YEAR.

    *> -----------------------------------------------------------
    *> 2. User Interaction via System.Console
    *> -----------------------------------------------------------
    INVOKE SYS-CONSOLE "Write" USING "Enter your full name: ".
    INVOKE SYS-CONSOLE "ReadLine" RETURNING USER-NAME.
    *> 4. Perform Business Logic
    COMPUTE WS-CALCULATED-AGE = WS-CURRENT-YEAR - WS-BIRTH-YEAR.
    MOVE WS-CALCULATED-AGE TO WS-DISPLAY-AGE.

    INVOKE SYS-CONSOLE "Write" USING "Enter your birth year (e.g. 1985): ".
    INVOKE SYS-CONSOLE "ReadLine" RETURNING BIRTH-YEAR-STR.
    *> 5. Display Summary Card
    DISPLAY "----------------------------------------------------------".
    DISPLAY "Hello, " FUNCTION TRIM(WS-CLEAN-NAME) "!".
    DISPLAY "In " WS-CURRENT-YEAR ", you turn approximately " 
            FUNCTION TRIM(WS-DISPLAY-AGE) " years old.".
    DISPLAY "==========================================================".

    *> Convert String input to COBOL Binary Integer (COMP-5 / System.Int32)
    INVOKE SYS-CONVERT "ToInt32" USING BIRTH-YEAR-STR RETURNING WS-BIRTH-YEAR.
    GOBACK.
```

    *> Extract current year from DateTime object
    INVOKE CURRENT-DATE-TIME "get_Year" RETURNING WS-CURRENT-YEAR.
---

    *> Perform arithmetic calculation
    COMPUTE WS-CALCULATED-AGE = WS-CURRENT-YEAR - WS-BIRTH-YEAR.
    MOVE WS-CALCULATED-AGE TO WS-DISPLAY-AGE.
## 4. Step 3: Compile with `cobc`

    *> -----------------------------------------------------------
    *> 3. Display Results
    *> -----------------------------------------------------------
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "----------------------------------------------------------".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Hello, " & USER-NAME & "!".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "In " & WS-CURRENT-YEAR & ", you turn approximately " 
              & WS-DISPLAY-AGE & " years old.".
    INVOKE SYS-CONSOLE "WriteLine" 
        USING "==========================================================".
From your terminal inside the `HelloModernCobol` directory, run:

    INVOKE SYS-CONSOLE "WriteLine" 
        USING "Press [Enter] to exit the application...".
    INVOKE SYS-CONSOLE "ReadLine" RETURNING RAW-INPUT.

    GOBACK.
```bash
cobc -x -free -Wall Program1.cob -o HelloModernCobol
```

### Explaining the Flags:
* **`-x`**: Generates a standalone native executable.
* **`-free`**: Instructs the compiler to process free-format source (matching `>>SOURCE FORMAT FREE`).
* **`-Wall`**: Activates all compiler diagnostic warnings.
* **`-o HelloModernCobol`**: Specifies the name of the output binary.

If compilation succeeds, `cobc` finishes silently with exit code `0`.

---

## 5. Step 4: Build the Solution
## 5. Step 4: Run the Executable

1. From the top menu, select **Build -> Build Solution** (or press `Ctrl + Shift + B`).
2. Observe the **Output Window** (`Ctrl + Alt + O`):
   ```text
   1>------ Build started: Project: HelloModernCobol, Configuration: Debug Any CPU ------
   1>  Compiling Program1.cob ...
   1>  Generating Assembly: bin\Debug\HelloModernCobol.exe
   ========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
   ```
3. If any syntax errors occur, verify that:
   - Every period (`.`) ending a sentence is present.
   - The `@OPTIONS SOURCE(FREE)` directive is located on line 1.
   - Class names in `REPOSITORY` match the exact case in the `INVOKE` statements.
Execute the compiled binary:

```bash
./HelloModernCobol
```

Example interactive session:
```text
==========================================================
             WELCOME TO MODERN GNUCOBOL
==========================================================
Current Date : 2026-09-07
Current Time : 15:30:45
----------------------------------------------------------
Enter your full name: Grace Hopper
Enter your birth year (e.g. 1990): 1906
----------------------------------------------------------
Hello, Grace Hopper!
In 2026, you turn approximately 120 years old.
==========================================================
```

---

## 6. Step 5: Run and Debug
## 6. Step 5: Inspecting the Binary

1. **Set a Breakpoint**:
   - Scroll to line 57: `COMPUTE WS-CALCULATED-AGE = WS-CURRENT-YEAR - WS-BIRTH-YEAR.`
   - Click in the gray margin to the left of the line (or place your cursor on the line and press `F9`). A red dot will appear.
2. **Launch with Debugging**:
   - Press **`F5`** (or click the green **Start Debugging** arrow on the toolbar).
   - The console window will launch, clear the screen, print the header, and prompt for your name and birth year.
   - Type your name and a birth year (e.g. `1990`), then press `Enter`.
3. **Inspect Variables at the Breakpoint**:
   - The execution halts at the breakpoint with a yellow highlight arrow.
   - Open **Debug -> Windows -> Locals**.
   - Notice `WS-BIRTH-YEAR` shows `1990`, and `WS-CURRENT-YEAR` shows the current calendar year.
   - Hover your mouse over `USER-NAME` to see the string value via Visual Studio **DataTips**.
4. **Step Over**:
   - Press **`F10`** to step over the `COMPUTE` line.
   - Observe `WS-CALCULATED-AGE` immediately update with the calculated age in the Locals window.
5. **Continue Execution**:
   - Press **`F5`** to resume execution.
   - Switch to the console window to verify the final formatted output, then press `Enter` to terminate the program cleanly.
You can verify that GnuCOBOL compiled a true native binary using standard Linux tools:

Congratulations! You have successfully written, compiled, executed, and debugged your first modern COBOL program targeting the .NET runtime in Visual Studio.
```bash
# Check binary type
file HelloModernCobol
# Output: HelloModernCobol: ELF 64-bit LSB pie executable, x86-64, dynamically linked...

# Check dynamic library links
ldd HelloModernCobol
# Output shows libcob.so, libm.so, libc.so
```

Congratulations! You have successfully written, compiled, executed, and inspected your first native GnuCOBOL application.
