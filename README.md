# Multi-Word-Int v4.27
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.27 has:
- an optimisation in the divide algorithm, taken from Knuth/Warren.
- bug fixes in Multi_Int_X2_to_Multi_Int_X48, Multi_Int_X3_to_Multi_Int_X48 and Multi_Int_X4_to_Multi_Int_X48 conversion routines.
- bug fix in division routine
- bug fix in unary minus routine
- note that Real/Float to Multi-Int conversion has unfixed bugs; I'm working on a fix
- single-digit bug fix in division routine
