using System;
using System.Runtime.InteropServices;

namespace DotNetLib
{
    public static class DotNetValidator
    {
        [UnmanagedCallersOnly(EntryPoint = "ValidateAccountNumber")]
        public static int ValidateAccountNumber(int acctNum)
        {
            // Modulo-7 validation rule
            return (acctNum % 7 == 0) ? 1 : 0;
        }

        [UnmanagedCallersOnly(EntryPoint = "CalculateProcessingFee")]
        public static unsafe void CalculateProcessingFee(double amount, double* fee)
        {
            if (fee != null)
            {
                // 1.75% processing fee rounded to 2 decimals
                *fee = Math.Round(amount * 0.0175, 2);
            }
        }
    }
}
