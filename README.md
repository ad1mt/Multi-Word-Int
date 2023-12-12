# Multi-Word-Int v4.31
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.31 has:
- the Multi_Int_X48 type has been renamed to Multi_Int_XV
- the size of the Multi_Int_XV type can be set at runtime during initialisation
- the multiplication routine has been speeded-up
- bug fixes to Real/Float to Multi-Int conversion
- many other bug fixes

Unfortunately, the current version of the library can not be reliably used with the 32bit version of the Free Pascal compiler. Multi_Int to float type conversion does not work reliably. I am working on a fix.
