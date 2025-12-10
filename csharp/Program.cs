using System.Reflection;
using System.Runtime.InteropServices;

public static class Program
{
    public static void Main()
    {
        bool anyFailed = false;

        var methods = typeof(Program)
            .GetMethods(BindingFlags.NonPublic | BindingFlags.Static)
            .Where(m => m.GetCustomAttribute<DllImportAttribute>() != null)
            .OrderBy(m => m.Name);

        foreach (var method in methods)
        {
            int result = (int)method.Invoke(null, null)!;

            Console.WriteLine($"{method.Name}: {result}");

            if (result != 0)
            {
                anyFailed = true;
            }
        }

        Environment.Exit(anyFailed ? 1 : 0);
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

    [DllImport("Native")]
    private static extern int TryOutOfRangeCatchException();

    [DllImport("Native")]
    private static extern int TryOutOfRangeCatchOutOfRange();
}
