# Multi-Word-Int v4.35
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).
This should be considered a beta development version.

Changes in version 4.35:
- Multi_Int_XV type is now variable in size and automatically resizes as necessary
- many minor bug fixes arising from above new feature
- some minor changes to the API, which might require minor changes in calling code
- exceptional case bug fix in division function
