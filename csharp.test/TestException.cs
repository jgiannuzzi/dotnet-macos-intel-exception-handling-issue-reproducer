using NUnit.Framework;
using System.Runtime.InteropServices;

namespace Tests
{
    [TestFixture]
    internal static class Tests
    {
        [Test]
        public static void TestThrowOutOfRangeCatchException()
        {
            Assert.That(ThrowOutOfRangeCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowOutOfRangeCatchOutOfRange()
        {
            Assert.That(ThrowOutOfRangeCatchOutOfRange(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowLengthErrorCatchException()
        {
            Assert.That(ThrowLengthErrorCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowLengthErrorCatchLengthError()
        {
            Assert.That(ThrowLengthErrorCatchLengthError(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowInvalidArgumentCatchException()
        {
            Assert.That(ThrowInvalidArgumentCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowRangeErrorCatchException()
        {
            Assert.That(ThrowRangeErrorCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowLogicErrorCatchException()
        {
            Assert.That(ThrowLogicErrorCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestThrowRuntimeErrorCatchException()
        {
            Assert.That(ThrowRuntimeErrorCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestTryOutOfRangeCatchException()
        {
            Assert.That(TryOutOfRangeCatchException(), Is.EqualTo(0));
        }

        [Test]
        public static void TestTryOutOfRangeCatchOutOfRange()
        {
            Assert.That(TryOutOfRangeCatchOutOfRange(), Is.EqualTo(0));
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
}
