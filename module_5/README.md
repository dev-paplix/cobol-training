# Module 5: Seamless .NET Interoperability

Welcome to **Module 5** of the COBOL Training Series. In modern enterprise IT ecosystems, COBOL core processing systems do not live in a silo. Organizations frequently preserve decades of verified business and financial calculation logic in COBOL while connecting them directly to **modern C# and .NET backends, cloud microservices, and web/mobile front-ends**.

This module teaches you how to achieve **bidirectional, zero-overhead interoperability** between COBOL and Microsoft .NET 8 on modern Linux platforms, while also mastering the foundational assembly management and GAC concepts of legacy .NET Framework / NetCOBOL environments.

---

## 🎯 Learning Objectives

By completing this module, you will be able to:
1. **Call C# and VB.NET Libraries from COBOL**: Learn how modern .NET 8 C# methods can be exported using `[UnmanagedCallersOnly]` and Native AOT to be directly callable from COBOL via standard `CALL` statements.
2. **Expose COBOL Logic as Dynamic Shared Libraries (`.so` / `.dll`)**: Compile COBOL subprograms into dynamic shared objects using `cobc -m` and invoke them from C# via Platform Invoke (`[DllImport]`).
3. **Master the Runtime Initialization Bridge (`cob_init`)**: Understand why native COBOL runtimes (`libcob`) require explicit initialization when hosted inside a non-COBOL process (.NET CLR, Python, Node.js).
4. **Manage Assemblies, Strong Naming, and the GAC**: Understand the evolution of assembly distribution from legacy .NET Framework Global Assembly Cache (`gacutil`), `.snk` strong-naming keys, and `<bindingRedirect>` configuration to modern .NET 8 dynamic native library resolution (`NativeLibrary`, `LD_LIBRARY_PATH`).
5. **Architect an ASP.NET Core Microservice with a COBOL Backend**: Build an end-to-end REST API where an ASP.NET Core web service accepts JSON requests from clients, passes strongly-typed parameters into a compiled COBOL calculation engine, and returns calculated results.

---

## 📂 Module Directory Layout

```text
module_5/
├── README.md                                    # Module Syllabus, Architecture & Index
├── 01_calling_dotnet_from_cobol.md              # Guide 1: Calling C# from COBOL (Native AOT & C-ABI)
├── 02_exposing_cobol_as_shared_libraries.md     # Guide 2: Compiling COBOL to .so/DLL, P/Invoke & cob_init()
├── 03_assemblies_and_gac_management.md         # Guide 3: Strong Naming, GAC, Binding Redirects & .NET 8 Resolution
├── 04_case_study_aspnetcore_cobol_api.md       # Guide 4: Case Study: Wrapping COBOL in ASP.NET Core
├── 05_exercises_and_solutions.md               # Guide 5: Exercise Specs, Test Scenarios & Solution Keys
│
├── samples/                                     # Runnable Reference Implementations
│   ├── 01_CobolCallsCSharp/
│   │   ├── CSharpLib/                           # C# .NET 8 Native AOT library exporting functions
│   │   └── CobolClient.cob                      # COBOL program calling C# Native AOT library
│   ├── 02_CSharpCallsCobol/
│   │   ├── CobolEngine.cob                      # COBOL financial engine compiled to .so
│   │   └── DotNetClient/                        # C# Console App calling COBOL via [DllImport] & cob_init()
│   └── 03_CaseStudy_AspNetCore/
│       ├── CobolBackend/                        # LoanRiskEngine.cob (compiled to .so)
│       └── WebApi/                              # C# ASP.NET Core API calling COBOL engine
│
└── exercises/                                   # Practical Labs (Starter & Solution)
    ├── exercise_1_csharp_to_cobol_interop/      # C# client invoking COBOL tax engine
    │   ├── starter/
    │   └── solution/
    ├── exercise_2_cobol_calling_dotnet/         # COBOL batch calling C# checksum & validation
    │   ├── starter/
    │   └── solution/
    └── exercise_3_aspnet_cobol_microservice/    # ASP.NET Core API calling COBOL insurance rating engine
        ├── starter/
        └── solution/
```

---

## 🧭 Learning & Lab Progression

1. **Step 1: Read the Guides**:
   - [01. Calling .NET from COBOL](file:///home/wesi/codes/cobol-training/module_5/01_calling_dotnet_from_cobol.md)
   - [02. Exposing COBOL as Shared Libraries](file:///home/wesi/codes/cobol-training/module_5/02_exposing_cobol_as_shared_libraries.md)
   - [03. Assemblies & GAC Management](file:///home/wesi/codes/cobol-training/module_5/03_assemblies_and_gac_management.md)
   - [04. Case Study: Legacy COBOL in ASP.NET Core](file:///home/wesi/codes/cobol-training/module_5/04_case_study_aspnetcore_cobol_api.md)

2. **Step 2: Study and Run the Samples**:
   - Trace how COBOL calls C# in `samples/01_CobolCallsCSharp/`.
   - Trace how C# calls a COBOL `.so` using `cob_init()` in `samples/02_CSharpCallsCobol/`.
   - Explore the ASP.NET Core REST API case study in `samples/03_CaseStudy_AspNetCore/`.

3. **Step 3: Complete the Hands-on Exercises**:
   - Follow the instructions in [05. Exercises and Solutions Guide](file:///home/wesi/codes/cobol-training/module_5/05_exercises_and_solutions.md).
   - Test and verify your implementations against the provided solutions.

---

## ⚡ Quick Compilation & Execution Reference

### 1. Compile and Run C# Calling COBOL
```bash
# Compile COBOL to shared library (.so)
cd /home/wesi/codes/cobol-training/module_5/samples/02_CSharpCallsCobol
cobc -m -free CobolEngine.cob -o libCobolEngine.so

# Run C# client with LD_LIBRARY_PATH
cd DotNetClient
LD_LIBRARY_PATH=..:$LD_LIBRARY_PATH dotnet run
```

### 2. Compile and Run COBOL Calling C# (Native AOT)
```bash
# Publish C# library to native shared object (.so)
cd /home/wesi/codes/cobol-training/module_5/samples/01_CobolCallsCSharp/CSharpLib
dotnet publish -c Release -r linux-x64

# Compile COBOL with static call linking
cd ..
cobc -x -free -fstatic-call CobolClient.cob \
     -LCSharpLib/bin/Release/net8.0/linux-x64/publish \
     -l:CSharpLib.so -o CobolClient

LD_LIBRARY_PATH=CSharpLib/bin/Release/net8.0/linux-x64/publish:$LD_LIBRARY_PATH ./CobolClient
```

### 3. Run ASP.NET Core COBOL Case Study
```bash
# Build COBOL backend
cd /home/wesi/codes/cobol-training/module_5/samples/03_CaseStudy_AspNetCore/CobolBackend
cobc -m -free LoanRiskEngine.cob -o libLoanRiskEngine.so

# Run ASP.NET Core Web Service
cd ../WebApi
LD_LIBRARY_PATH=../CobolBackend:$LD_LIBRARY_PATH dotnet run
```

