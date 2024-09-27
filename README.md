# Multi-Word-Int v4.39
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
The library has now been thoroughly tested I no longer considered it to be beta development code.

Changes in version 4.39:
- major bug fix in DIV with Multi_Int_XV type.
