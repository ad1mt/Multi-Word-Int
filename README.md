# Multi-Word-Int v4.33
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Version 4.33 has:
- better exception handling if initialisation called incorrectly
- exception bug fixes
- overflow bug fixes
- some shift operations were failing if range-checking was enabled - range-checking disabled around shift operations
- Multi_Int_XV xor operation was not initialising result variable
