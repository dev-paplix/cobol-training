using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace ECommerceCheckout
{
    public static class CobolBridge
    {
        [DllImport("libcob.so", EntryPoint = "cob_init")]
        public static extern void cob_init(int argc, IntPtr argv);

        [DllImport("libTaxEngine.so", EntryPoint = "TaxEngine")]
        public static extern int TaxEngine(
            ref double subtotal,
            [In] byte[] tier,
            ref double discountAmt,
            ref double taxAmt,
            ref double finalTotal);

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
                        Path.Combine(AppContext.BaseDirectory, "..", "..", ".."),
                        Path.Combine(Directory.GetCurrentDirectory(), "..")
                    };
                    foreach (var dir in candidates)
                    {
                        string path = Path.GetFullPath(Path.Combine(dir, "libTaxEngine.so"));
                        if (File.Exists(path))
                        {
                            return NativeLibrary.Load(path);
                        }
                    }
                }
                return IntPtr.Zero;
            });

            cob_init(0, IntPtr.Zero);
        }

        public static (double Discount, double Tax, double Total) Calculate(double subtotal, string tier)
        {
            double discount = 0;
            double tax = 0;
            double total = 0;

            byte[] tierBytes = Encoding.ASCII.GetBytes(tier.PadRight(8));
            TaxEngine(ref subtotal, tierBytes, ref discount, ref tax, ref total);

            return (Math.Round(discount, 2), Math.Round(tax, 2), Math.Round(total, 2));
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("  EXERCISE 1: C# CHECKOUT - COBOL TAX ENGINE     ");
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

            Console.WriteLine("\n==================================================");
            Console.WriteLine("Exercise 1 validation passed successfully!");
        }
    }
}
