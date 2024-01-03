# Multi-Word-Int v4.34
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.34 has:
- a significantly better division algorithm; around 10x-30x faster
- small speedups in multiplication routines
- minor bug fixes
- UBool type now merged in, no longer a separate unit/file
- testing bug fix
- minor bug fix in division algorithm
- major bug fix in division algorithm
- another bug fix in division algorithm
