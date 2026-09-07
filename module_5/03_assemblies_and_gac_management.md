# Chapter 3: Managing Assemblies, Strong Naming, and the Global Assembly Cache (GAC)

Managing dependencies is a core discipline in enterprise software engineering. In the Microsoft .NET ecosystem, the mechanism for sharing, versioning, and deploying code libraries has undergone a major paradigm shift.

This chapter explores both the legacy **.NET Framework / NetCOBOL** model (Strong Naming, GAC, and Binding Redirects) and the modern **.NET 8** model (Container-first, NuGet cache, and dynamic native library resolution).

---

## 1. The Legacy .NET Framework Model (NetCOBOL Era)

In traditional enterprise Windows environments, multiple applications on the same server needed to share common COBOL and C# libraries without duplicating DLLs on disk.

```
┌───────────────────────────────────────────────────────────┐
│ Windows Server (NetCOBOL / .NET Framework 4.8)            │
│                                                           │
│  App A (v1.0.0.0) ───────┐                                │
│                          ▼                                │
│  App B (v2.0.0.0) ──► [ Global Assembly Cache (GAC) ]     │
│                          C:\Windows\Microsoft.NET\assembly│
│                          ├── Company.CobolEngine (v1.0.0) │
│                          └── Company.CobolEngine (v2.0.0) │
└───────────────────────────────────────────────────────────┘
```

### What is an Assembly?
An assembly is the fundamental unit of deployment in .NET:
- Contains compiled MSIL code, resources, and an **Assembly Manifest**.
- The manifest describes the identity: Name, Version (`Major.Minor.Build.Revision`), Culture, and Public Key Token.

### Strong-Name Signing (`sn.exe`)
To install an assembly into the GAC, it **must be strongly named**. A strong name consists of the assembly's identity combined with a cryptographic public/private key pair:

```bash
# 1. Generate a cryptographic key pair
sn -k EnterpriseKey.snk

# 2. Sign the assembly during compilation
# In C# AssemblyInfo.cs:
# [assembly: AssemblyKeyFile("EnterpriseKey.snk")]
# [assembly: AssemblyVersion("2.1.0.0")]
```
**Benefits**:
- **Tamper Prevention**: Any unauthorized modification invalidates the cryptographic hash.
- **Uniqueness**: Prevents name collisions across third-party libraries.

---

### The Global Assembly Cache (GAC) and `gacutil`
The GAC was the centralized, machine-wide store for shared .NET assemblies:

```cmd
:: Install an assembly into the GAC
gacutil /i Company.CobolEngine.dll

:: Verify installation and view registered version
gacutil /l Company.CobolEngine

:: Remove an assembly from the GAC
gacutil /u Company.CobolEngine
```

### Version Binding Redirection (`app.config` / `web.config`)
When a patched library (`v2.1.0.1`) was deployed to the GAC, legacy applications built against `v2.1.0.0` could be redirected without recompilation using **Binding Redirects**:

```xml
<configuration>
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <dependentAssembly>
        <assemblyIdentity name="Company.CobolEngine"
                          publicKeyToken="32ab4ba45e0a69a1"
                          culture="neutral" />
        <!-- Redirect any caller requesting v2.1.0.0 through v2.1.0.4 to v2.1.0.5 -->
        <bindingRedirect oldVersion="2.1.0.0-2.1.0.4"
                         newVersion="2.1.0.5" />
      </dependentAssembly>
    </assemblyBinding>
  </runtime>
</configuration>
```

---

## 2. The Modern .NET 8 Model: Why the GAC Was Retired

Starting with .NET Core and continued through **.NET 8**, Microsoft completely retired the GAC.

### Why Was the GAC Retired?
1. **Containerization (Docker / Kubernetes)**: Modern cloud apps run in lightweight Linux containers. Installing libraries into a shared machine-wide cache violates container immutability.
2. **Side-by-Side Isolation**: Machine-wide state caused deployment conflicts ("DLL Hell").
3. **NuGet Package Cache**: All dependency resolution is now handled per-project via NuGet (`~/.nuget/packages`).

### Modern Assembly Resolution in .NET 8
In .NET 8, assemblies are resolved in this order:
1. **Application Base Directory**: The folder containing the executable.
2. **`.deps.json` Manifest**: Describes the exact transitive dependencies resolved by NuGet during build.
3. **Runtime Framework Directory**: The shared .NET runtime installed on the host.

---

## 3. Managing Native Shared Libraries (`.so` / `.dll`) in .NET 8

When integrating native COBOL shared libraries (`libCobolEngine.so`) with .NET 8 applications on Linux, P/Invoke must locate the `.so` file at runtime.

### Mechanism A: System Search Path (`LD_LIBRARY_PATH`)
The standard Linux dynamic loader searches directories specified in `LD_LIBRARY_PATH`:
```bash
export LD_LIBRARY_PATH=/opt/company/cobol/lib:$LD_LIBRARY_PATH
dotnet run
```

### Mechanism B: Programmatic Resolution via `NativeLibrary`
Modern .NET provides the `NativeLibrary` class to dynamically locate and load native shared objects at runtime:

```csharp
using System.Reflection;
using System.Runtime.InteropServices;

public static class NativeResolver
{
    public static void ConfigureCobolLibraryPath(string customDir)
    {
        NativeLibrary.SetDllImportResolver(Assembly.GetExecutingAssembly(), (libraryName, assembly, searchPath) =>
        {
            if (libraryName == "libCreditScoreEngine.so")
            {
                string fullPath = System.IO.Path.Combine(customDir, "libCreditScoreEngine.so");
                if (System.IO.File.Exists(fullPath))
                {
                    return NativeLibrary.Load(fullPath);
                }
            }
            return IntPtr.Zero; // Fall back to default OS resolution
        });
    }
}
```

This ensures that your .NET 8 microservice can automatically resolve COBOL shared libraries regardless of whether it is deployed on a developer laptop, a CI/CD server, or a Docker container!

---

## 4. Summary Checklist for Assembly & Library Management

- [x] In legacy NetCOBOL systems, shared assemblies required strong naming (`.snk`) and registration via `gacutil /i`.
- [x] Use `<bindingRedirect>` in `app.config` to update legacy dependencies without recompilation.
- [x] In modern .NET 8, deploy applications with local dependencies or packaged inside containers.
- [x] Use `LD_LIBRARY_PATH` or `NativeLibrary.SetDllImportResolver` to load COBOL native `.so` files cleanly in .NET 8.

