using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace WebApi
{
    // ==========================================
    // DTO Models
    // ==========================================
    public record LoanApplicationRequest(
        double PurchasePrice,
        double DownPayment,
        double AnnualIncome,
        double MonthlyDebt,
        short LoanTermYears,
        double InterestRate
    );

    public record LoanApplicationResponse(
        double PurchasePrice,
        double DownPayment,
        double LoanAmount,
        double LtvRatio,
        double MonthlyPayment,
        double DtiRatio,
        string Status,
        string ReasonCode
    );

    // ==========================================
    // COBOL Interoperability Service Interface
    // ==========================================
    public interface ILoanEngineService
    {
        LoanApplicationResponse EvaluateLoan(LoanApplicationRequest request);
    }

    public class CobolLoanEngineService : ILoanEngineService
    {
        [DllImport("libcob.so", EntryPoint = "cob_init")]
        private static extern void cob_init(int argc, IntPtr argv);

        [DllImport("libLoanRiskEngine.so", EntryPoint = "LoanRiskEngine")]
        private static extern int LoanRiskEngine(
            ref double purchasePrice,
            ref double downPayment,
            ref double annualIncome,
            ref double monthlyDebt,
            ref short loanTermYears,
            ref double interestRate,
            ref double loanAmount,
            ref double ltvRatio,
            ref double monthlyPayment,
            ref double dtiRatio,
            [In, Out] byte[] approvalStatus,
            [In, Out] byte[] reasonCode);

        static CobolLoanEngineService()
        {
            NativeLibrary.SetDllImportResolver(typeof(CobolLoanEngineService).Assembly, (libraryName, assembly, searchPath) =>
            {
                if (libraryName == "libLoanRiskEngine.so" || libraryName == "LoanRiskEngine")
                {
                    string[] candidates = new[]
                    {
                        AppContext.BaseDirectory,
                        Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "CobolBackend"),
                        Path.Combine(Directory.GetCurrentDirectory(), "CobolBackend"),
                        Path.Combine(Directory.GetCurrentDirectory(), "..", "CobolBackend"),
                        Directory.GetCurrentDirectory()
                    };

                    foreach (var dir in candidates)
                    {
                        string fullPath = Path.GetFullPath(Path.Combine(dir, "libLoanRiskEngine.so"));
                        if (File.Exists(fullPath))
                        {
                            return NativeLibrary.Load(fullPath);
                        }
                    }
                }
                return IntPtr.Zero;
            });

            // Initialize GnuCOBOL runtime
            cob_init(0, IntPtr.Zero);
        }

        public LoanApplicationResponse EvaluateLoan(LoanApplicationRequest req)
        {
            double purchasePrice = req.PurchasePrice;
            double downPayment = req.DownPayment;
            double annualIncome = req.AnnualIncome;
            double monthlyDebt = req.MonthlyDebt;
            short loanTerm = req.LoanTermYears;
            double rate = req.InterestRate;

            double loanAmount = 0.0;
            double ltvRatio = 0.0;
            double monthlyPayment = 0.0;
            double dtiRatio = 0.0;
            byte[] statusBytes = new byte[12];
            byte[] reasonBytes = new byte[20];

            LoanRiskEngine(
                ref purchasePrice,
                ref downPayment,
                ref annualIncome,
                ref monthlyDebt,
                ref loanTerm,
                ref rate,
                ref loanAmount,
                ref ltvRatio,
                ref monthlyPayment,
                ref dtiRatio,
                statusBytes,
                reasonBytes
            );

            string status = Encoding.ASCII.GetString(statusBytes).Trim();
            string reason = Encoding.ASCII.GetString(reasonBytes).Trim();

            return new LoanApplicationResponse(
                Math.Round(purchasePrice, 2),
                Math.Round(downPayment, 2),
                Math.Round(loanAmount, 2),
                Math.Round(ltvRatio, 2),
                Math.Round(monthlyPayment, 2),
                Math.Round(dtiRatio, 2),
                status,
                reason
            );
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddSingleton<ILoanEngineService, CobolLoanEngineService>();

            var app = builder.Build();

            // Minimal API Endpoints
            app.MapGet("/health", () => Results.Ok(new
            {
                Status = "Healthy",
                CobolBridge = "Active",
                Framework = ".NET 8 ASP.NET Core"
            }));

            app.MapPost("/api/loans/evaluate", (LoanApplicationRequest request, ILoanEngineService loanService) =>
            {
                if (request.PurchasePrice <= 0 || request.LoanTermYears <= 0)
                {
                    return Results.BadRequest(new { Error = "Invalid loan parameters" });
                }

                var response = loanService.EvaluateLoan(request);
                return Results.Ok(response);
            });

            // If --test flag provided, execute self-verification suite and exit cleanly
            if (args.Length > 0 && args[0] == "--test")
            {
                Console.WriteLine("==================================================");
                Console.WriteLine(" ASP.NET CORE LOAN API - COBOL INTEGRATION TEST  ");
                Console.WriteLine("==================================================");

                var service = app.Services.GetRequiredService<ILoanEngineService>();
                var testSuite = new[]
                {
                    new LoanApplicationRequest(400000.0, 80000.0, 120000.0, 500.0, 30, 0.065), // Standard Approval
                    new LoanApplicationRequest(500000.0, 25000.0, 100000.0, 800.0, 30, 0.070), // PMI Required (LTV 95%)
                    new LoanApplicationRequest(300000.0, 5000.0,  50000.0,  1000.0, 30, 0.065)  // High LTV & DTI (Denied)
                };

                foreach (var test in testSuite)
                {
                    var res = service.EvaluateLoan(test);
                    Console.WriteLine($"\n[Application] Price: {res.PurchasePrice:C0}, Down: {res.DownPayment:C0}");
                    Console.WriteLine($"  Loan: {res.LoanAmount:C0} | Monthly P&I: {res.MonthlyPayment:C2}");
                    Console.WriteLine($"  LTV: {res.LtvRatio:F1}% | DTI: {res.DtiRatio:F1}%");
                    Console.WriteLine($"  Decision: [{res.Status}] - {res.ReasonCode}");
                }

                Console.WriteLine("\n==================================================");
                Console.WriteLine("ASP.NET Core DI Service successfully invoked COBOL!");
                return;
            }

            app.Run();
        }
    }
}
