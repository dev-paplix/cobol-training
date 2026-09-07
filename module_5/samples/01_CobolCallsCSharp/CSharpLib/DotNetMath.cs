using System;
using System.Runtime.InteropServices;

namespace CSharpLib
{
    public static class DotNetMath
    {
        [UnmanagedCallersOnly(EntryPoint = "DotNetMultiply")]
        public static int DotNetMultiply(int a, int b)
        {
            return a * b;
        }

        [UnmanagedCallersOnly(EntryPoint = "DotNetCalculateTax")]
        public static unsafe void DotNetCalculateTax(double subtotal, double rate, double* taxAmount)
        {
            if (taxAmount != null)
            {
                *taxAmount = Math.Round(subtotal * rate, 2);
            }
        }

        [UnmanagedCallersOnly(EntryPoint = "DotNetApplyDiscount")]
        public static unsafe void DotNetApplyDiscount(double amount, double discountPercent, double* discountedAmount)
        {
            if (discountedAmount != null)
            {
                double discount = amount * (discountPercent / 100.0);
                *discountedAmount = Math.Round(amount - discount, 2);
            }
        }
    }
}
