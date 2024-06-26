# Multi-Word-Int v4.37
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Changes in version 4.37:
- Bitwise NOT AND OR functions
- Bug fixes in XOR function
- Tidy-up/simplify overflow exception messages
- Re-instate "lost" Negative function
- bitwise operations no longer generates an exception for negative values
- Fix for a problem with exceptions when range-checking is enabled on the 32-bit compiler
- Bug fixes in bitshift functions
- bug fixes: overflow flag was not set in several functions
