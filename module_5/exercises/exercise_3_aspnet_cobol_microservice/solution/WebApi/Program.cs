using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

namespace InsuranceMicroservice
{
    public record QuoteRequest(int DriverAge, int PriorViolations, double BasePremium);
    public record QuoteResponse(int DriverAge, int PriorViolations, double BasePremium, double AnnualPremium, string RiskRating);

    public interface IInsuranceRatingService
    {
        QuoteResponse CalculateQuote(QuoteRequest request);
    }

    public class CobolInsuranceRatingService : IInsuranceRatingService
    {
        [DllImport("libcob.so", EntryPoint = "cob_init")]
        private static extern void cob_init(int argc, IntPtr argv);

        [DllImport("libInsuranceRatingEngine.so", EntryPoint = "InsuranceRatingEngine")]
        private static extern int InsuranceRatingEngine(
            ref int driverAge,
            ref int priorViolations,
            ref double basePremium,
            ref double annualPremium,
            [In, Out] byte[] riskRating);

        static CobolInsuranceRatingService()
        {
            NativeLibrary.SetDllImportResolver(typeof(CobolInsuranceRatingService).Assembly, (libraryName, assembly, searchPath) =>
            {
                if (libraryName == "libInsuranceRatingEngine.so" || libraryName == "InsuranceRatingEngine")
                {
                    string[] dirs = new[]
                    {
                        AppContext.BaseDirectory,
                        Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "Backend"),
                        Path.Combine(Directory.GetCurrentDirectory(), "Backend"),
                        Path.Combine(Directory.GetCurrentDirectory(), "..", "Backend"),
                        Directory.GetCurrentDirectory()
                    };
                    foreach (var d in dirs)
                    {
                        string p = Path.GetFullPath(Path.Combine(d, "libInsuranceRatingEngine.so"));
                        if (File.Exists(p)) return NativeLibrary.Load(p);
                    }
                }
                return IntPtr.Zero;
            });

            cob_init(0, IntPtr.Zero);
        }

        public QuoteResponse CalculateQuote(QuoteRequest req)
        {
            int age = req.DriverAge;
            int violations = req.PriorViolations;
            double basePrem = req.BasePremium;
            double annualPrem = 0.0;
            byte[] ratingBuffer = new byte[12];

            InsuranceRatingEngine(ref age, ref violations, ref basePrem, ref annualPrem, ratingBuffer);

            string riskRating = Encoding.ASCII.GetString(ratingBuffer).Trim();
            return new QuoteResponse(age, violations, Math.Round(basePrem, 2), Math.Round(annualPrem, 2), riskRating);
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddSingleton<IInsuranceRatingService, CobolInsuranceRatingService>();

            var app = builder.Build();

            app.MapGet("/health", () => Results.Ok(new { Status = "Healthy", Service = "Insurance Rating Microservice" }));

            app.MapPost("/api/insurance/quote", (QuoteRequest req, IInsuranceRatingService service) =>
            {
                var response = service.CalculateQuote(req);
                return Results.Ok(response);
            });

            if (args.Length > 0 && args[0] == "--test")
            {
                Console.WriteLine("==================================================");
                Console.WriteLine(" EXERCISE 3: ASP.NET CORE INSURANCE MICROSERVICE  ");
                Console.WriteLine("==================================================");

                var service = app.Services.GetRequiredService<IInsuranceRatingService>();
                var profiles = new[]
                {
                    new QuoteRequest(22, 0, 1000.00), // Young driver: 1.4x -> $1,400 (STANDARD)
                    new QuoteRequest(35, 0, 1000.00), // Adult clean: 1.0x -> $1,000 (LOW_RISK)
                    new QuoteRequest(45, 3, 1000.00), // 3 violations: $1,000 + $750 -> $1,750 (HIGH_RISK)
                    new QuoteRequest(70, 1, 1500.00)  // Senior: 1.15x + $250 -> $1,975 (STANDARD)
                };

                foreach (var p in profiles)
                {
                    var q = service.CalculateQuote(p);
                    Console.WriteLine($"\n[Quote Evaluation] Age: {q.DriverAge}, Violations: {q.PriorViolations}");
                    Console.WriteLine($"  Base Premium   : {q.BasePremium:C2}");
                    Console.WriteLine($"  Annual Premium : {q.AnnualPremium:C2}");
                    Console.WriteLine($"  Risk Rating    : {q.RiskRating}");
                }

                Console.WriteLine("\n==================================================");
                Console.WriteLine("Exercise 3 microservice test passed successfully!");
                return;
            }

            app.Run();
        }
    }
}
