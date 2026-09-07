using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace ECommerceCheckout
{
    public static class CobolBridge
    {
        // TODO 1: Import cob_init from libcob.so
        // [DllImport("libcob.so", EntryPoint = "cob_init")]
        // public static extern void cob_init(int argc, IntPtr argv);

        // TODO 2: Import TaxEngine from libTaxEngine.so
        // [DllImport("libTaxEngine.so", EntryPoint = "TaxEngine")]
        // public static extern int TaxEngine(...);

        static CobolBridge()
        {
            NativeLibrary.SetDllImportResolver(typeof(CobolBridge).Assembly, (libraryName, assembly, searchPath) =>
            {
                if (libraryName == "libTaxEngine.so" || libraryName == "TaxEngine")
                {
                    string[] candidates = new[]
                    {
                        AppContext.BaseDirectory,
                        Directory.GetCurrentDirectory(),
                        Path.Combine(AppContext.BaseDirectory, "..", "..", "..")
                    };
                    foreach (var dir in candidates)
                    {
                        string path = Path.GetFullPath(Path.Combine(dir, "libTaxEngine.so"));
                        if (File.Exists(path)) return NativeLibrary.Load(path);
                    }
                }
                return IntPtr.Zero;
            });

            // TODO 3: Call cob_init(0, IntPtr.Zero)
        }

        public static (double Discount, double Tax, double Total) Calculate(double subtotal, string tier)
        {
            double discount = 0;
            double tax = 0;
            double total = 0;

            // TODO 4: Convert tier to 8-byte ASCII array and invoke TaxEngine
            // byte[] tierBytes = Encoding.ASCII.GetBytes(tier.PadRight(8));
            // TaxEngine(...);

            return (Math.Round(discount, 2), Math.Round(tax, 2), Math.Round(total, 2));
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("  EXERCISE 1 STARTER: C# CHECKOUT - COBOL ENGINE ");
            Console.WriteLine("==================================================");

            var orders = new (double Subtotal, string Tier)[]
            {
                (250.00, "GOLD"),
                (120.00, "SILVER"),
                (85.50,  "STANDARD")
            };

            foreach (var ord in orders)
            {
                var (discount, tax, total) = CobolBridge.Calculate(ord.Subtotal, ord.Tier);
                Console.WriteLine($"\n[Order Checkout] Tier: {ord.Tier}");
                Console.WriteLine($"  Subtotal   : {ord.Subtotal:C2}");
                Console.WriteLine($"  Discount   : -{discount:C2}");
                Console.WriteLine($"  Sales Tax  : +{tax:C2}");
                Console.WriteLine($"  Final Paid : {total:C2}");
            }
        }
    }
}
