using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace DotNetClient
{
    public static class CobolInterop
    {
        [DllImport("libcob.so", EntryPoint = "cob_init")]
        public static extern void cob_init(int argc, IntPtr argv);

        [DllImport("libCobolEngine.so", EntryPoint = "CobolEngine")]
        public static extern int CobolEngine(
            ref int creditScore,
            ref double monthlyIncome,
            ref double existingDebt,
            ref double approvedLimit,
            [In, Out] byte[] riskCode);

        static CobolInterop()
        {
            // Register custom library resolver for .NET 8
            NativeLibrary.SetDllImportResolver(typeof(CobolInterop).Assembly, (libraryName, assembly, searchPath) =>
            {
                if (libraryName == "libCobolEngine.so" || libraryName == "CobolEngine")
                {
                    string[] searchDirs = new[]
                    {
                        AppContext.BaseDirectory,
                        Path.Combine(AppContext.BaseDirectory, "..", "..", ".."),
                        Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."),
                        Directory.GetCurrentDirectory(),
                        Path.Combine(Directory.GetCurrentDirectory(), "..")
                    };

                    foreach (var dir in searchDirs)
                    {
                        string candidate = Path.GetFullPath(Path.Combine(dir, "libCobolEngine.so"));
                        if (File.Exists(candidate))
                        {
                            return NativeLibrary.Load(candidate);
                        }
                    }
                }
                return IntPtr.Zero;
            });

            // Initialize GnuCOBOL runtime
            cob_init(0, IntPtr.Zero);
        }

        public record AssessmentResult(int CreditScore, double Income, double Debt, double ApprovedLimit, string RiskCode);

        public static AssessmentResult Evaluate(int score, double income, double debt)
        {
            double limit = 0.0;
            byte[] riskBuffer = new byte[10];

            CobolEngine(ref score, ref income, ref debt, ref limit, riskBuffer);

            string riskCode = Encoding.ASCII.GetString(riskBuffer).Trim();
            return new AssessmentResult(score, income, debt, limit, riskCode);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("   C# .NET 8 CALLING COBOL SHARED LIBRARY (.SO)   ");
            Console.WriteLine("==================================================");

            var testCases = new (int Score, double Income, double Debt, string Scenario)[]
            {
                (520, 4500.00, 500.00,  "Subprime applicant (Low credit score)"),
                (640, 5000.00, 1200.00, "Fair credit applicant (High debt)"),
                (710, 6500.00, 1500.00, "Good credit applicant (Standard)"),
                (800, 10000.00, 2000.00, "Excellent credit applicant (Prime Tier)"),
                (750, 4000.00, 25000.00, "High credit score but over-leveraged debt")
            };

            foreach (var tc in testCases)
            {
                var result = CobolInterop.Evaluate(tc.Score, tc.Income, tc.Debt);
                Console.WriteLine($"\n[Scenario] {tc.Scenario}");
                Console.WriteLine($"  Input  : Score={result.CreditScore}, MonthlyIncome={result.Income:C0}, Debt={result.Debt:C0}");
                Console.WriteLine($"  COBOL  : Risk Tier = {result.RiskCode,-10} | Approved Limit = {result.ApprovedLimit:C2}");
            }

            Console.WriteLine("\n==================================================");
            Console.WriteLine("All COBOL engine evaluations completed successfully!");
        }
    }
}
