# Multi-Word-Int v4.92
Library to provide multi-word (large) integers for the Free Pascal compiler.
Designed to be reasonably fast, and requiring minimal changes to existing code.
Provides basic arithmetic operations add, subtract, multiply, divide, exclusive-or, power, odd, even, bit shift.
Provides implicit/automatic conversions to other types wherever possible.
Will compile and run on 32bit and 64bit environments.
Written purely in Pascal to be portable and reliable (no assembly or C language code).

Changes in this version:
-	slightly faster multiply_Multi_Int_X2/3/4/5 routines
-	several bug fixes in Multi_Int_X5 definition
-	slightly faster subtract_Multi_Int_X2/3/4/5 routines
-	slightly faster add_Multi_Int_X2/3/4/5 routines
-	overflow bug fixes in add_Multi_Int_X2/3/4/5 routines
