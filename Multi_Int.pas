UNIT Multi_Int;

{$MODE DELPHI}

{$MODESWITCH NESTEDCOMMENTS+}

(*
Multi Int
---------
Multiple word integer types and basic math library.

v3.0
- new division algorithm (shift & subtract)

v3.4
- shift & subtract division algorithm working for
  Multi_Int_X2

v3.5 - v3.9
- many bug fixes for 64bit CPU
- many bug fixes for Multi_Int_X2

v3.10
- bug fixes for Multi_Int_X4 on 64bit CPU

v3.11a
- create missing
  implicit(Multi_Int_X4):int8u,
  implicit(Multi_Int_X4):INT_1W_S,
  implicit(all):int8,
  + others
- serious bug fixes - fixed in Multi_Int_X4

v3.11b
- serious bug fixes - fixed in Multi_Int_X2/3

v3.11c
- tidying-up

v3.11d
- bug fixes for 64bit

v3.11e
- bug fixes for 64bit

v3.11f
- added ODD and EVEN functions

v3.11g
- string_to_Multi_Int_X failed with zero length string

v3.11h
- string_to_Multi_Int_X failed on overflow

v3.12
- version no change only

v3.13
- string_to_Multi_Int_X9 should return zero for zero-length string

v3.14
- attempt to speedup

v3.15A
- make bit shift operations visible (Multi_Int_X2)
- bit rotate (Multi_Int_X2)
v3.15B
- serious overflow bug fixes
v3.15C
- make bit shift operations visible (Multi_Int_X3/4)
- bit rotate (Multi_Int_X3/4)
v3.15D
- more overflow fixes

v3.16
- to_hex functions

v4
- Multi_Int_X48
- Check div by zero
- fix Odd/Even
- ToHex defaults to trim
- really fix Odd/Even/ToHex
- from_hex
- tidy-up
- tidy-up unused/uninitialised vars
- more tidy-up unused/uninitialised vars
- overflow big fux in intdivide
- fixed visibility bug for Overflow & Defined
- inline all procs/funcs for ~50% speedup

v4.15
- Bug fix in Dec and Inc
- Bug fix - check X48_MAX value is > 0
- Bug fix - unary minus not defined
- Bug fix - raise exceptions done at too low level - causes misleading error mess
- Make Multi_Int_X_MAXINT constants the real typed vars instead of strings.

v4.16
- Serious bug fixes in subtract, divide with negative numbers!

v4.16
- Add power operator

v4.17
- Make all non-var params const

v4.18
- replicate v4.15/16 divide bug fix to Multi_Int_X4, Multi_Int_X3, Multi_Int_X2.
- replicate power operator to Multi_Int_X4, Multi_Int_X3, Multi_Int_X2.

v4.19
- type conversion between Multi_Int_X48, Multi_Int_X4, Multi_Int_X3, Multi_Int_X2
  probably finished
- square root function finished

v4.20
- fast power function

NB - UBool type gets broken when separated into it own unit!

*)

(* USER OPTIONAL DEFINES *)

// This should be changed to 32bit for 32 bit CPUs

{$define 64bit}

{$define RAISE_EXCEPTIONS_ENABLED}

(* END OF USER OPTIONAL DEFINES *)
	
INTERFACE

uses	sysutils
,		strutils
,		strings
,		math
;

{$INCLUDE Multi_Int_Interface.pas}

IMPLEMENTATION

{$INCLUDE Multi_Int_Implementation.pas}

begin
Multi_Init_Initialisation;
end.


