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
        // TODO 1: Declare P/Invoke for cob_init and InsuranceRatingEngine
        // [DllImport("libcob.so", EntryPoint = "cob_init")] ...
        // [DllImport("libInsuranceRatingEngine.so", EntryPoint = "InsuranceRatingEngine")] ...

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

            // TODO 2: Initialize COBOL runtime
            // cob_init(0, IntPtr.Zero);
        }

        public QuoteResponse CalculateQuote(QuoteRequest req)
        {
            // TODO 3: Prepare arguments, invoke InsuranceRatingEngine, format response
            return new QuoteResponse(req.DriverAge, req.PriorViolations, req.BasePremium, 0.0, "PENDING");
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddSingleton<IInsuranceRatingService, CobolInsuranceRatingService>();

            var app = builder.Build();

            app.MapGet("/health", () => Results.Ok(new { Status = "Healthy" }));
            app.MapPost("/api/insurance/quote", (QuoteRequest req, IInsuranceRatingService service) =>
            {
                var response = service.CalculateQuote(req);
                return Results.Ok(response);
            });

            app.Run();
        }
    }
}
