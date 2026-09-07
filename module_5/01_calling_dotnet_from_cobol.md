# Chapter 1: Calling C# and VB.NET Class Libraries from COBOL

In modern enterprise architectures, organizations often leverage modern C# or VB.NET libraries to handle capabilities that are difficult or impractical in traditional COBOL—such as complex cryptographic hashing, REST API calls, cloud storage, or modern statistical mathematics.

This chapter explores both the legacy NetCOBOL approach and the modern, open-standards **.NET 8 Native AOT** approach to calling .NET code from COBOL.

---

## 1. The Architectural Evolution

```
[ LEGACY: NetCOBOL CLR Model (Windows Only) ]
  COBOL Source ──(NetCOBOL Compiler)──► MSIL Bytecode ──(Windows .NET CLR)──► Managed Execution
  * Requires proprietary compiler and Windows-only CLR runtime.

[ MODERN: Native AOT / C-ABI Model (Linux, macOS, Windows) ]
  C# Source ──(dotnet publish PublishAot)──► Native Shared Library (.so / .dll)
                                                       ▲
  COBOL Source ──(cobc -fstatic-call)─────────────────┘  (Direct C-ABI Call, 0 overhead!)
```

### The Legacy NetCOBOL Approach (Windows CLR)
In Fujitsu NetCOBOL, COBOL code was compiled directly into Microsoft Intermediate Language (MSIL). Calling .NET classes utilized OO-COBOL grammar:
```cobol
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       REPOSITORY.
           CLASS CSharpMath AS "Company.Utility.MathHelper".
       ...
       INVOKE CSharpMath "CalculateTax" USING WS-AMOUNT RETURNING WS-TAX.
```
While functional, this approach locked enterprises into proprietary runtimes and Windows-only hosting.

---

### The Modern Open Standards Approach (.NET 8 + Native AOT)
Starting with .NET 7 and perfected in **.NET 8**, C# supports **Native Ahead-Of-Time (AOT) Compilation**. 

Using Native AOT:
1. The C# code is compiled directly into native machine code (ELF `.so` on Linux, PE `.dll` on Windows).
2. Methods decorated with `[UnmanagedCallersOnly]` are exported with a standard C-compatible calling convention.
3. Any standard COBOL compiler (including GnuCOBOL) can invoke the C# function directly via standard `CALL` syntax!

---

## 2. Creating the C# Native AOT Library

### Step 1: Write the C# Code (`DotNetMath.cs`)
```csharp
using System;
using System.Runtime.InteropServices;

namespace UtilityLibrary
{
    public static class DotNetMath
    {
        [UnmanagedCallersOnly(EntryPoint = "DotNetMultiply")]
        public static int DotNetMultiply(int x, int y)
        {
            return x * y;
        }

        [UnmanagedCallersOnly(EntryPoint = "DotNetCalculateTax")]
        public static void DotNetCalculateTax(double subtotal, double taxRate, ref double taxAmount)
        {
            taxAmount = Math.Round(subtotal * taxRate, 2);
        }
    }
}
```

> [!NOTE]
> Methods marked with `[UnmanagedCallersOnly]` must be `static` and accept only primitive blittable types (`int`, `double`, `long`, `IntPtr`, pointers) that have identical memory representations in native code.

### Step 2: Configure the .NET 8 Project (`UtilityLibrary.csproj`)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <PublishAot>true</PublishAot>
    <NativeLib>Shared</NativeLib>
  </PropertyGroup>
</Project>
```

### Step 3: Publish the Native Shared Library
```bash
dotnet publish -c Release -r linux-x64
```
This produces `bin/Release/net8.0/linux-x64/publish/UtilityLibrary.so`. This shared object has no dependency on the .NET runtime—it is a true native binary!

---

## 3. Invoking the C# Library from COBOL

In COBOL, you declare the inputs as `COMP-5` (for integers) or `COMP-2` (for doubles), and invoke the entry point:

```cobol
       >>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CobolClient.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-SUBTOTAL               USAGE COMP-2 VALUE 1250.50.
       01  WS-TAX-RATE               USAGE COMP-2 VALUE 0.0825.
       01  WS-TAX-AMOUNT             USAGE COMP-2 VALUE 0.0.

       PROCEDURE DIVISION.
           DISPLAY "Calling C# .NET 8 CalculateTax method from COBOL..."
           CALL "DotNetCalculateTax" 
               USING BY VALUE WS-SUBTOTAL WS-TAX-RATE 
               RETURNING WS-TAX-AMOUNT

           DISPLAY "C# Calculated Tax: $" WS-TAX-AMOUNT
           STOP RUN.
```

---

## 4. Compiling and Linking

When compiling the COBOL application, link the published C# `.so` library:
```bash
# Compile COBOL with static linking to the C# library
cobc -x -free -fstatic-call CobolClient.cob \
     -L./bin/Release/net8.0/linux-x64/publish \
     -l:UtilityLibrary.so -o CobolClient

# Run with library path
LD_LIBRARY_PATH=./bin/Release/net8.0/linux-x64/publish:$LD_LIBRARY_PATH ./CobolClient
```

---

## 5. Summary Checklist for Calling .NET from COBOL

- [x] Decorate C# methods with `[UnmanagedCallersOnly(EntryPoint = "...")]`.
- [x] Set `<PublishAot>true</PublishAot>` and `<NativeLib>Shared</NativeLib>` in `.csproj`.
- [x] Use `COMP-5` for C# `int` (32-bit) and `USAGE COMP-2` for C# `double` (64-bit).
- [x] Pass primitive arguments `BY VALUE` from COBOL.
- [x] Compile COBOL with `-fstatic-call` and link the `.so` using `-L<path> -l:<file.so>`.
