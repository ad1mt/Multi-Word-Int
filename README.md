# Multi-Word-Int v4.25
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.25 has:
- RAISE_EXCEPTIONS_ENABLED renamed to Multi_Int_RAISE_EXCEPTIONS_ENABLED
- Multi_Int_RAISE_EXCEPTIONS_ENABLED is now a variable (instead of a define) that can be set/changed at any point in the calling code
- several bug fixes and improvements
