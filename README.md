# Multi-Word-Int v4.32
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.32 has:
- major bug fixes in Real/Float type to Multi-Int conversion for 32bit environment
- created missing int64 to Multi-Int conversion for 32bit environment
- bug fixes in Overflow detection
- bug fix in Multi_Int_X3 hex conversion
- Multi_Init_Initialisation improvements to make it easier to build test suites
- exception bug fixes in division routines
