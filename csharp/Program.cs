using System.Runtime.InteropServices;

public static class Program
{
    public static void Main()
    {
        Console.WriteLine($"ThrowOutOfRangeCatchException: {ThrowOutOfRangeCatchException()}");
        Console.WriteLine($"ThrowOutOfRangeCatchOutOfRange: {ThrowOutOfRangeCatchOutOfRange()}");
        Console.WriteLine($"ThrowLengthErrorCatchException: {ThrowLengthErrorCatchException()}");
        Console.WriteLine($"ThrowLengthErrorCatchLengthError: {ThrowLengthErrorCatchLengthError()}");
        Console.WriteLine($"ThrowInvalidArgumentCatchException: {ThrowInvalidArgumentCatchException()}");
        Console.WriteLine($"ThrowRangeErrorCatchException: {ThrowRangeErrorCatchException()}");
        Console.WriteLine($"ThrowLogicErrorCatchException: {ThrowLogicErrorCatchException()}");
        Console.WriteLine($"ThrowRuntimeErrorCatchException: {ThrowRuntimeErrorCatchException()}");
    }

    [DllImport("Native")]
    private static extern int ThrowOutOfRangeCatchException();

    [DllImport("Native")]
    private static extern int ThrowOutOfRangeCatchOutOfRange();

    [DllImport("Native")]
    private static extern int ThrowLengthErrorCatchException();

    [DllImport("Native")]
    private static extern int ThrowLengthErrorCatchLengthError();

    [DllImport("Native")]
    private static extern int ThrowInvalidArgumentCatchException();

    [DllImport("Native")]
    private static extern int ThrowRangeErrorCatchException();

    [DllImport("Native")]
    private static extern int ThrowLogicErrorCatchException();

    [DllImport("Native")]
    private static extern int ThrowRuntimeErrorCatchException();
}
