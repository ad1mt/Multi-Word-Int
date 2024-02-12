UNIT Multi_Int;

(******************************************************************************)
// This code is public domain.
// No copyright.
// No license.
// No warranty.
// If you want to take this code and copyright it yourself, feel free.
(******************************************************************************)

// {$MODE DELPHI}
{$MODE OBJFPC}
{$MODESWITCH ADVANCEDRECORDS}

{$MODESWITCH NESTEDCOMMENTS+}

(* USER OPTIONAL DEFINES *)

// This should be changed to 32bit if you wish to override the default/detected setting
// E.g. if your compiler is 64bit but you want to generate code for 32bit integers,
// you would remove the "{$define 64bit}" and replace it with "{$define 32bit}"
// In 99.9% of cases, you should leave this to default, unless you have problems
// running the code in a 32bit environment.

{$IFDEF CPU64}
	{$define 64bit}
{$ELSE}
  	{$define 32bit}
{$ENDIF}

{$ifdef 32bit}
	{$SAFEFPUEXCEPTIONS ON}
{$endif}

// This makes procedure and functions inlined

// {$define inline_functions}

// This should be set if you have enabled overflow checking.
// Turning on overflow checking causes some shift operations to fail,
// so the code needs to turn off overflow checking for those operations.
// This define tells the code that it needs to turn overflow checking
// back on again after the shift operation.
// NB this option does not turn on overflow checking for you,
// if you wish to turn on overflow checking, you still need to do this
// in the usual way.

// {$define Overflow_Checks}

(******************************************************************************)
(*
v4.23B
-	bug fixes in divide
-	divide v4 working
-	sign bug fixes in power
-	sign bug fixes in sqroot

v4.23B
-	Negative functions
-	Abs functions
-	Additional init procs
-	Exception bug ifxes in Inc/Dec

v4.23C

v4.23D
-	?
-	sign bug fix in power v4.24
-	move UBool into separate unit.

v4.25
-	rename RAISE_EXCEPTIONS_ENABLED to Multi_Int_RAISE_EXCEPTIONS_ENABLED
-	make Multi_Int_RAISE_EXCEPTIONS_ENABLED a var instead of a define to allow
	better control of exceptions
-	Multi_Int_RAISE_EXCEPTIONS_ENABLED defaults to TRUE

v4.26
-	automagically detect and set {$define 64bit} or {$define 32bit}

v4.27
-	single word divisor optimisation from Warren/Knuth
-	inc(v1,increment), dec(v1, decrement)

v4.30
-	dynamic array inside Multi_Int_X48 record
-	Multi_Int_X48 size is now set at runtime
-	deal with Multi_Init_Initialisation not called or called more than once
-	Multi_Int to real overflow bug fixes (need replicating to all floats)
-	real-to-Multi-Int finished
-	single-to-Multi-Int finished
-	double-to-Multi-Int finished
-	bug fix in sqroot
-	bug fix in procedure ansistring_to_Multi_Int_X2
-	single-digit divisor bug fix in division routine
-	speed up Multi_Int_X48 multiply routine

v4.31
-	Rename Multi_Int_X48 to Multi_Int_XV
-	Rename assorted X48 stuff to XV
-	Make call Multi_Init_Initialisation optional with default value of 16
-	overflow bug fix in division routine
-	overflow bug in Multi_Int to single/double/real
-	overflow bug in 32bit Multi_Int to double/real
-	disable Multi_Int to single in 32bit environment
-	bug fix in hex to Multi_Int

v4.32.01
-	missing implicit conversion int64 to Multi_Int in 32bit environment
-	in all cases of overflow set Multi_Int_OVERFLOW_ERROR:=TRUE
-	set {$SAFEFPUEXCEPTIONS ON} in 32bit environments
-	re-instate Multi_int to single conversion in 32bit environment

v4.32.02
-	display compiler warning about lossy float to Multi_int conversion
-	add tests for hex conversion
-	Multi_Int_X3 hex conversion bug
-	Multi_Init_Initialisation improvements to make it easier to build test suites

v4.32.03
-	SINGLE_TYPE_PRECISION_DIGITS	= 7;
-	REAL_TYPE_PRECISION_DIGITS		= 15;
-	DOUBLE_TYPE_PRECISION_DIGITS	= 15;

v4.32.04
-	rename all INT_1W_S (etc) to MULTI_INT_1W_S (etc)
-	remove redundant Shift & Rotate procedures from record types

v4.32.05
-	exception not raised when div values same as last time
-	create method function FromHex(const v1:ansistring):Multi_Int;

v4.33.00
-	check and prevent Multi_Init_Initialisation if XV vars already exist
-	check invalidly resized XV vars
-	xor function was not checking overflow

v4.33.01
-	unary minus was not checking overflow
-	Multi_Int_XV xor function was not calling init
-	some shift operations did not have {$Q-} and {$R-}
-	To_Multi_Int_XV functions were not calling the Multi_Int_X_to_Multi_Int_XV proc

v4.34.00
-	new division algorithm - re-engineered knuth-warren  (Multi_Int_XV)

v4.34.01
-	new division algorithm for Multi_Int_X2 X3 X4
-	version const

v4.34.04
-	new division algorithm for Multi_Int_X4 required new Multi_Int_X5 for internal use only
-	new division algorithm for Multi_Int_XV required new Multi_Int_XW for internal use only

v4.34.05
-	bug fixes

v4.34.06
-	speed up multiplication routine - needed to get best out of new division algorithm

v4.34.07
-	small speed ups in new division algorithm

v4.34.08
-	UNFIXED Multi_Int_XV corruption bug in new division algorithm

v4.34.09
-	fix Multi_Int_XV corruption bug in new division algorithm

v4.34.10
-	reproduce fix for Multi_Int_XV corruption bug in new division algorithm to other types,
	even thought the other types did not manifest the bug. I did this to keep the code
	the same for the different data types.

v4.34.11
-	small speedups in multiplication routines.
-	bring UBool unit back inside from the cold.
-	testing bug fix in Multi_Int_X2 modulus functine
-	need extra initialisation routines reset_X2_Last_Divisor etc
-	bug fix in division algorithm

v4.34.12
-	major bug fix in division algorithm

v4.34.13
-	another bug fix in division algorithm
-	more reliable conversion from float types, by
	truncating the final digit instead of rounding.

v4.35.00
-	allow resizing of Multi_Int_XV type
-	allow different Multi_Int_XV vars to have different sizes
-	when a Multi_Int_XV operation value is larger than the operands,
	resize the result var to fit the value.

v4.35.01
-	impose limit on size of Multi_Int_XV vars

v4.35.02
-	lots of M_Value array indexing bugs fixed
-	result must not be set to 0 after failed call to Multi_Int_Reset_XV_Size
-	potential overflow bug in sqroot fixed
-	where internal M_Val array is used, result must be init := 0 in
	ansistring_to_Multi_Int_XV, hex_to_Multi_Int_XV, add_Multi_Int_XV,
	subtract_Multi_Int_XV and multiply_Multi_Int_XV
-	in Multi_Int_Set_XV_Limit check Multi_XV_Limit > Multi_Int_XV_size
-	exceptional case bug fix in division algorithm
-	lots undefined bug fixes in equals,less-than etc

v4.35.03
-	ToBin and FromBin functions
-	removed extended Inc operator (two-parameter version)
-	clean up hints, notes, warnings
-	exception overflow bug fix in add/subtract_Multi_Int_XV
-	more exception bug fixes

v4.35.04
-	re-instate function inlining with a switch
-	use function out parameters instead of var to eliminate warnings
-	define shr shl operators
-	serious bug fix in calling code for some operations var was being referenced
	instead of copied - for Multi_Int_XV only, others ok
-	implement shr and shl operators
-	hide ShiftDown & ShiftUp procedures
-	more var parameters changed to out

v4.36.00
-	now works in OBJFPC mode with ADVANCEDRECORDS switch
*)

(* END OF USER OPTIONAL DEFINES *)
	
INTERFACE

uses	sysutils
,		strutils
;

const
	version = '4.36.00';

const

(* Do not change these values *)

	Multi_X2_maxi = 3;
	Multi_X2_maxi_x2 = 7;
	Multi_X2_size = Multi_X2_maxi + 1;

	Multi_X3_maxi = 5;
	Multi_X3_maxi_x2 = 11;
	Multi_X3_size = Multi_X3_maxi + 1;

	Multi_X4_maxi = 7;
	Multi_X4_maxi_x2 = 15;
	Multi_X4_size = Multi_X4_maxi + 1;

const
	Multi_INT8_MAXINT = 127;
	Multi_INT8_MAXINT_1 = 128;
	Multi_INT8U_MAXINT = 255;
	Multi_INT8U_MAXINT_1 = 256;
	Multi_INT16_MAXINT = 32767;
	Multi_INT16_MAXINT_1 = 32768;
	Multi_INT16U_MAXINT = 65535;
	Multi_INT16U_MAXINT_1 = 65536;
	Multi_INT32_MAXINT = 2147483647;
	Multi_INT32_MAXINT_1 = 2147483648;
	Multi_INT32U_MAXINT = 4294967295;
	Multi_INT32U_MAXINT_1 = 4294967296;
	Multi_INT64_MAXINT = 9223372036854775807;
	Multi_INT64_MAXINT_1 = 9223372036854775808;
	Multi_INT64U_MAXINT = 18446744073709551615;
	Multi_INT64U_MAXINT_1 = 18446744073709551616;

	MULTI_SINGLE_TYPE_MAXVAL	= '9999999999999999999999999999';
	MULTI_REAL_TYPE_MAXVAL		= '99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
	MULTI_DOUBLE_TYPE_MAXVAL	= '99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';

	MULTI_SINGLE_TYPE_PRECISION_DIGITS	= 7;
	MULTI_REAL_TYPE_PRECISION_DIGITS	= 15;
	MULTI_DOUBLE_TYPE_PRECISION_DIGITS	= 15;

type
	Multi_int8u = byte;
	Multi_int8 = shortint;
	Multi_int16 = smallint;
	Multi_int16u = word;
	Multi_int32 = longint;
	Multi_int32u = longword;
	Multi_int64u = QWord;
	Multi_int64 = int64;

{$ifdef 32bit}
const
	MULTI_INT_1W_SIZE		= 16;
	MULTI_INT_2W_SIZE		= 32;
	MULTI_INT_4W_SIZE		= 64;

	MULTI_INT_1W_S_MAXINT	= Multi_INT16_MAXINT;
	MULTI_INT_1W_S_MAXINT_1	= Multi_INT16_MAXINT_1;
	MULTI_INT_1W_U_MAXINT	= Multi_INT16U_MAXINT;
	MULTI_INT_1W_U_MAXINT_1	= Multi_INT16U_MAXINT_1;

	MULTI_INT_2W_S_MAXINT	= Multi_INT32_MAXINT;
	MULTI_INT_2W_S_MAXINT_1	= Multi_INT32_MAXINT_1;
	MULTI_INT_2W_U_MAXINT	= Multi_INT32U_MAXINT;
	MULTI_INT_2W_U_MAXINT_1	= Multi_INT32U_MAXINT_1;

	MULTI_INT_4W_S_MAXINT	= Multi_INT64_MAXINT;
	MULTI_INT_4W_S_MAXINT_1	= Multi_INT64_MAXINT_1;
	MULTI_INT_4W_U_MAXINT	= Multi_INT64U_MAXINT;
	MULTI_INT_4W_U_MAXINT_1	= Multi_INT64U_MAXINT_1;

type

	MULTI_INT_1W_S		= Multi_int16;
	MULTI_INT_1W_U		= Multi_int16u;
	MULTI_INT_2W_S		= Multi_int32;
	MULTI_INT_2W_U		= Multi_int32u;
	MULTI_INT_4W_S		= Multi_int64;
	MULTI_INT_4W_U		= Multi_int64u;

{$endif} // 32-bit

{$ifdef 64bit}
const
	MULTI_INT_1W_SIZE		= 32;
	MULTI_INT_2W_SIZE		= 64;

	MULTI_INT_1W_S_MAXINT	= Multi_INT32_MAXINT;
	MULTI_INT_1W_S_MAXINT_1	= Multi_INT32_MAXINT_1;
	MULTI_INT_1W_U_MAXINT	= Multi_INT32U_MAXINT;
	MULTI_INT_1W_U_MAXINT_1	= Multi_INT32U_MAXINT_1;

	MULTI_INT_2W_S_MAXINT	= Multi_INT64_MAXINT;
	MULTI_INT_2W_S_MAXINT_1	= Multi_INT64_MAXINT_1;
	MULTI_INT_2W_U_MAXINT	= Multi_INT64U_MAXINT;
	MULTI_INT_2W_U_MAXINT_1	= Multi_INT64U_MAXINT_1;

type

	MULTI_INT_1W_S		= Multi_int32;
	MULTI_INT_1W_U		= Multi_int32u;
	MULTI_INT_2W_S		= Multi_int64;
	MULTI_INT_2W_U		= Multi_int64u;

{$endif} // 64-bit

type

T_Multi_Leading_Zeros	=	(Multi_Keep_Leading_Zeros, Multi_Trim_Leading_Zeros);

T_Multi_32bit_or_64bit	=	(Multi_undef, Multi_32bit, Multi_64bit);

Multi_UBool_Values		= 	(Multi_UBool_UNDEF,Multi_UBool_FALSE,Multi_UBool_TRUE);

T_Multi_UBool	=	record
					private
						B_Value		:Multi_UBool_Values;
					public
						procedure	Init(v:Multi_UBool_Values); inline;
						function	ToStr:string; inline;
						class operator :=(v:boolean):T_Multi_UBool; inline;
						class operator :=(v:T_Multi_UBool):Boolean; inline;
						class operator :=(v:Multi_UBool_Values):T_Multi_UBool; inline;
						class operator :=(v:T_Multi_UBool):Multi_UBool_Values; inline;
						class operator =(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator <>(v1,v2:T_Multi_UBool):Boolean; inline;
					end;

Multi_Int_X2	=	record
					private
						M_Value			:array[0..Multi_X2_maxi] of MULTI_INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function FromHex(const v1:ansistring):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						function FromBin(const v1:ansistring):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						function Overflow:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Negative:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Defined:boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_int8u;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_int8;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_1W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_1W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_2W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_2W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):ansistring;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Real):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Double):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Single;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Real;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Double;	{$ifdef inline_functions} inline; {$endif}
						class operator +(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator inc(const v1:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator dec(const v1:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator *(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator mod(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator xor(const v1,v2:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1:Multi_Int_X2):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X2):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator **(const v1:Multi_Int_X2; const P:MULTI_INT_2W_S):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator shr(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
						class operator shl(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;	{$ifdef inline_functions} inline; {$endif}
					end;


Multi_Int_X3	=	record
					private
						M_Value			:array[0..Multi_X3_maxi] of MULTI_INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function FromHex(const v1:ansistring):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						function FromBin(const v1:ansistring):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						function Overflow:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Negative:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Defined:boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_int8u;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_int8;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_1W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_1W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_2W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_2W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
					{$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:ansistring):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):ansistring;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Real):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Double):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Real;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Single;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Double;	{$ifdef inline_functions} inline; {$endif}
						class operator +(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator inc(const v1:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator dec(const v1:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator *(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator mod(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator xor(const v1,v2:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1:Multi_Int_X3):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X3):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator **(const v1:Multi_Int_X3; const P:MULTI_INT_2W_S):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator shr(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
						class operator shl(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;	{$ifdef inline_functions} inline; {$endif}
					end;


Multi_Int_X4	=	record
					private
						M_Value			:array[0..Multi_X4_maxi] of MULTI_INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function FromHex(const v1:ansistring):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						function FromBin(const v1:ansistring):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						function Overflow:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Negative:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Defined:boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Multi_int8u;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Multi_int8;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_1W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_1W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_2W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_2W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
					{$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:ansistring):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):ansistring;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Real):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Double):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Single;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Real;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Double;	{$ifdef inline_functions} inline; {$endif}
						class operator +(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator inc(const v1:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator dec(const v1:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator *(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator mod(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator xor(const v1,v2:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1:Multi_Int_X4):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X4):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator **(const v1:Multi_Int_X4; const P:MULTI_INT_2W_S):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator shr(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
						class operator shl(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;	{$ifdef inline_functions} inline; {$endif}
					end;


Multi_Int_XV	=	record
					private
						M_Value			:array of MULTI_INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
						M_Value_Size	:MULTI_INT_1W_S;
					public
						procedure init;	{$ifdef inline_functions} inline; {$endif}
						function ToStr:ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	{$ifdef inline_functions} inline; {$endif}
						function FromHex(const v1:ansistring):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						function FromBin(const v1:ansistring):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						function Overflow:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Negative:boolean;	{$ifdef inline_functions} inline; {$endif}
						function Defined:boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):Multi_int8u;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):Multi_int8;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_1W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_1W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_2W_U;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_2W_S;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):ansistring;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):Single;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Real):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):Real;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Double):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):Double;	{$ifdef inline_functions} inline; {$endif}
						class operator +(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator inc(const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator dec(const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator *(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator mod(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator -(const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions} inline; {$endif}
						class operator **(const v1:Multi_Int_XV; const P:MULTI_INT_2W_S):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator shr(const v1:Multi_Int_XV; const NBits:MULTI_INT_1W_U):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
						class operator shl(const v1:Multi_Int_XV; const NBits:MULTI_INT_1W_U):Multi_Int_XV;	{$ifdef inline_functions} inline; {$endif}
					end;

var
Multi_Int_RAISE_EXCEPTIONS_ENABLED			:boolean = TRUE;
Multi_Int_ERROR								:boolean = FALSE;
Multi_Int_X2_MAXINT							:Multi_Int_X2;
Multi_Int_X3_MAXINT							:Multi_Int_X3;
Multi_Int_X4_MAXINT							:Multi_Int_X4;
Multi_Int_XV_MAXINT							:Multi_Int_XV;

procedure Multi_Init_Initialisation(const P_Multi_XV_size:MULTI_INT_1W_U = 16);	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_1W_U);	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Set_XV_Limit(const S:MULTI_INT_1W_U);	{$ifdef inline_functions} inline; {$endif}
function Multi_Int_XV_Limit:MULTI_INT_1W_U;	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Reset_X2_Last_Divisor;	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Reset_X3_Last_Divisor;	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Reset_X4_Last_Divisor;	{$ifdef inline_functions} inline; {$endif}
procedure Multi_Int_Reset_XV_Last_Divisor;	{$ifdef inline_functions} inline; {$endif}

function Odd(const v1:Multi_Int_XV):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Odd(const v1:Multi_Int_X4):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Odd(const v1:Multi_Int_X3):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Odd(const v1:Multi_Int_X2):boolean; overload;	{$ifdef inline_functions} inline; {$endif}

function Even(const v1:Multi_Int_XV):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Even(const v1:Multi_Int_X4):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Even(const v1:Multi_Int_X3):boolean; overload;	{$ifdef inline_functions} inline; {$endif}
function Even(const v1:Multi_Int_X2):boolean; overload;	{$ifdef inline_functions} inline; {$endif}

function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}
function Abs(const v1:Multi_Int_XV):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}

procedure SqRoot(const v1:Multi_Int_XV; out VR,VREM:Multi_Int_XV); overload;	{$ifdef inline_functions} inline; {$endif}
procedure SqRoot(const v1:Multi_Int_X4; out VR,VREM:Multi_Int_X4); overload;	{$ifdef inline_functions} inline; {$endif}
procedure SqRoot(const v1:Multi_Int_X3; out VR,VREM:Multi_Int_X3); overload;	{$ifdef inline_functions} inline; {$endif}
procedure SqRoot(const v1:Multi_Int_X2; out VR,VREM:Multi_Int_X2); overload;	{$ifdef inline_functions} inline; {$endif}

(*
procedure ShiftUp(var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown(var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftUp(var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown(var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftUp(var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown(var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftUp(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;	{$ifdef inline_functions} inline; {$endif}
*)

procedure FromHex(const v1:ansistring; out v2:Multi_Int_X2); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X3); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X4); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromHex(const v1:ansistring; out v2:Multi_Int_XV); overload;	{$ifdef inline_functions} inline; {$endif}

procedure FromBin(const v1:ansistring; out mi:Multi_Int_X2); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X3); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X4); overload;	{$ifdef inline_functions} inline; {$endif}
procedure FromBin(const v1:ansistring; out mi:Multi_Int_XV); overload;	{$ifdef inline_functions} inline; {$endif}

function Hex_to_Multi_Int_X2(const v1:ansistring):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}
procedure Hex_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2); overload;	{$ifdef inline_functions} inline; {$endif}
function Hex_to_Multi_Int_X3(const v1:ansistring):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}
procedure Hex_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3); overload;	{$ifdef inline_functions} inline; {$endif}
function Hex_to_Multi_Int_X4(const v1:ansistring):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}
procedure Hex_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); overload;	{$ifdef inline_functions} inline; {$endif}
function Hex_to_Multi_Int_XV(const v1:ansistring):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}
procedure Hex_to_Multi_Int_XV(const v1:ansistring; out mi:Multi_Int_XV); overload;	{$ifdef inline_functions} inline; {$endif}

function bin_to_Multi_Int_X2(const v1:ansistring):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}
procedure bin_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2); overload;	{$ifdef inline_functions} inline; {$endif}
function bin_to_Multi_Int_X3(const v1:ansistring):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}
procedure bin_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3); overload;	{$ifdef inline_functions} inline; {$endif}
function bin_to_Multi_Int_X4(const v1:ansistring):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}
procedure bin_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); overload;	{$ifdef inline_functions} inline; {$endif}
function bin_to_Multi_Int_XV(const v1:ansistring):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}
procedure bin_to_Multi_Int_XV(const v1:ansistring; out mi:Multi_Int_XV); overload;	{$ifdef inline_functions} inline; {$endif}

function To_Multi_Int_XV(const v1:Multi_Int_X4):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_XV(const v1:Multi_Int_X3):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_XV(const v1:Multi_Int_X2):Multi_Int_XV; overload;	{$ifdef inline_functions} inline; {$endif}

function To_Multi_Int_X4(const v1:Multi_Int_XV):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X4(const v1:Multi_Int_X3):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X4(const v1:Multi_Int_X2):Multi_Int_X4; overload;	{$ifdef inline_functions} inline; {$endif}

function To_Multi_Int_X3(const v1:Multi_Int_XV):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X3(const v1:Multi_Int_X4):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X3(const v1:Multi_Int_X2):Multi_Int_X3; overload;	{$ifdef inline_functions} inline; {$endif}

function To_Multi_Int_X2(const v1:Multi_Int_XV):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X2(const v1:Multi_Int_X4):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X2(const v1:Multi_Int_X3):Multi_Int_X2; overload;	{$ifdef inline_functions} inline; {$endif}


IMPLEMENTATION

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

const
	Multi_X5_max = 8;
	Multi_X5_max_x2 = 16;
	Multi_X5_size = Multi_X4_maxi + 1;

type

(* Multi_Int_X5 FOR INTERNAL USE ONLY! *)

Multi_Int_X5	=	record
					private
						M_Value			:array[0..Multi_X5_max] of MULTI_INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function Negative:boolean;
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X5;
						class operator :=(const v1:Multi_Int_X4):Multi_Int_X5;
						class operator >=(const v1,v2:Multi_Int_X5):Boolean;
						class operator >(const v1,v2:Multi_Int_X5):Boolean;
						class operator *(const v1,v2:Multi_Int_X5):Multi_Int_X5;
						class operator -(const v1,v2:Multi_Int_X5):Multi_Int_X5;
					end;


(******************************************)
var

Multi_Init_Initialisation_count				:MULTI_INT_1W_S = 0;
Multi_XV_size								:MULTI_INT_1W_U = 0;
Multi_XV_maxi								:MULTI_INT_1W_U;
Multi_XV_limit								:MULTI_INT_1W_U;

X2_Last_Divisor,
X2_Last_Dividend,
X2_Last_Quotient,
X2_Last_Remainder	:Multi_Int_X2;

X3_Last_Divisor,
X3_Last_Dividend,
X3_Last_Quotient,
X3_Last_Remainder	:Multi_Int_X3;

X4_Last_Divisor,
X4_Last_Dividend,
X4_Last_Quotient,
X4_Last_Remainder	:Multi_Int_X4;

XV_Last_Divisor,
XV_Last_Dividend,
XV_Last_Quotient,
XV_Last_Remainder	:Multi_Int_XV;

(******************************************)

procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftUp_NBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
procedure ShiftDown_MultiBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U); forward;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X5(const v1:Multi_Int_X4):Multi_Int_X5; forward;	{$ifdef inline_functions} inline; {$endif}
function Multi_Int_X2_to_X3_multiply(const v1,v2:Multi_Int_X2):Multi_Int_X3; forward;	{$ifdef inline_functions} inline; {$endif}
function Multi_Int_X3_to_X4_multiply(const v1,v2:Multi_Int_X3):Multi_Int_X4; forward;	{$ifdef inline_functions} inline; {$endif}
function Multi_Int_X4_to_X5_multiply(const v1,v2:Multi_Int_X4):Multi_Int_X5; forward;	{$ifdef inline_functions} inline; {$endif}
function To_Multi_Int_X4(const v1:Multi_Int_X5):Multi_Int_X4; forward; overload;	{$ifdef inline_functions} inline; {$endif}

(******************************************)
procedure	T_Multi_UBool.Init(v:Multi_UBool_Values);
begin
if (v = Multi_UBool_TRUE) then B_Value:= Multi_UBool_TRUE
else if (v = Multi_UBool_FALSE) then B_Value:= Multi_UBool_FALSE
else B_Value:= Multi_UBool_UNDEF;
end;

function	T_Multi_UBool.ToStr:string;
begin
if (B_Value = Multi_UBool_TRUE) then Result:= 'TRUE'
else if (B_Value = Multi_UBool_FALSE) then Result:= 'FALSE'
else Result:= 'UNDEFINED';
end;

class operator T_Multi_UBool.:=(v:Multi_UBool_Values):T_Multi_UBool;
begin
Result.B_Value:= v;
end;

class operator T_Multi_UBool.:=(v:T_Multi_UBool):Multi_UBool_Values;
begin
Result:= v.B_Value;
end;

class operator T_Multi_UBool.:=(v:Boolean):T_Multi_UBool;
begin
if v then Result.B_Value:= Multi_UBool_TRUE
else Result.B_Value:= Multi_UBool_FALSE;
end;

class operator T_Multi_UBool.:=(v:T_Multi_UBool):Boolean;
begin
if (v.B_Value = Multi_UBool_TRUE) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.=(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value = v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.<>(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value <> v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;


{$ifdef 32bit}
(******************************************)
function nlz_bits(P_x:MULTI_INT_1W_U):MULTI_INT_1W_U;
var
n		:Multi_int32;
x,t		:MULTI_INT_1W_U;
begin
if (P_x = 0) then Result:= 16
else
	begin
	x:= P_x;
	n:= 0;
	t:=(x and MULTI_INT_1W_U(65280));
	if	(t = 0) then begin n:=(n + 8); x:=(x << 8); end;

	t:=(x and MULTI_INT_1W_U(61440));
	if	(t = 0) then begin n:=(n + 4); x:=(x << 4); end;

	t:=(x and MULTI_INT_1W_U(49152));
	if	(t = 0) then begin n:=(n + 2); x:=(x << 2); end;

	t:=(x and MULTI_INT_1W_U(32768));
	if	(t = 0) then begin n:=(n + 1); end;
	Result:= n;
	end;
end;

{$endif}


{$ifdef 64bit}
(******************************************)
function nlz_bits(x:MULTI_INT_1W_U):MULTI_INT_1W_U;
var	n	:Multi_int32;
begin
if (x = 0) then Result:= 32
else
	begin
	n:= 1;
	if	((x >> 16) = 0) then begin n:=(n + 16); x:=(x << 16); end;
	if	((x >> 24) = 0) then begin n:=(n + 8); x:=(x << 8); end;
	if	((x >> 28) = 0) then begin n:=(n + 4); x:=(x << 4); end;
	if	((x >> 30) = 0) then begin n:=(n + 2); x:=(x << 2); end;
	n:= (n - (x >> 31));
	Result:= n;
	end;
end;
{$endif}


{
******************************************
Multi_Int_X2
******************************************
}

function ABS_greaterthan_Multi_Int_X2(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(v1.M_Value[3] > v2.M_Value[3])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[3] < v2.M_Value[3])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[2] > v2.M_Value[2])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[2] < v2.M_Value[2])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[1] > v2.M_Value[1])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[1] < v2.M_Value[1])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[0] > v2.M_Value[0])
						then begin Result:=TRUE; exit; end
						else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_lessthan_Multi_Int_X2(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(v1.M_Value[3] < v2.M_Value[3])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[3] > v2.M_Value[3])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[2] < v2.M_Value[2])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[2] > v2.M_Value[2])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[1] < v2.M_Value[1])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[1] > v2.M_Value[1])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[0] < v2.M_Value[0])
						then begin Result:=TRUE; exit; end
						else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_equal_Multi_Int_X2(const v1,v2:Multi_Int_X2):Boolean;
begin
Result:=TRUE;
if	(v1.M_Value[3] <> v2.M_Value[3])
then Result:=FALSE
else
	if	(v1.M_Value[2] <> v2.M_Value[2])
	then Result:=FALSE
	else
		if	(v1.M_Value[1] <> v2.M_Value[1])
		then Result:=FALSE
		else
			if	(v1.M_Value[0] <> v2.M_Value[0])
			then Result:=FALSE;
end;


(******************************************)
function ABS_notequal_Multi_Int_X2(const v1,v2:Multi_Int_X2):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_X2(v1,v2));
end;


(******************************************)
function nlz_words_X2(m:Multi_Int_X2):MULTI_INT_1W_U;
var
i,n		:Multi_int32;
fini	:boolean;

begin
n:= 0;
i:= Multi_X2_maxi;
fini:= false;
repeat
	if	(i < 0) then fini:= true
	else if	(m.M_Value[i] <> 0) then fini:= true
	else
		begin
		INC(n);
		DEC(i);
		end;
until fini;
Result:= n;
end;


(******************************************)
function nlz_MultiBits_X2(const v1:Multi_Int_X2):MULTI_INT_1W_U;
var	w	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

w:= nlz_words_X2(v1);
if (w <= Multi_X2_maxi)
then Result:= nlz_bits(v1.M_Value[Multi_X2_maxi-w]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
function Multi_Int_X2.Defined:boolean;
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Multi_Int_X2.Overflow:boolean;
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X2):boolean; overload;
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Multi_Int_X2.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X2):boolean; overload;
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;
end;


(******************************************)
function Defined(const v1:Multi_Int_X2):boolean; overload;
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X2_Odd(const v1:Multi_Int_X2):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= TRUE
else Result:= FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Odd(const v1:Multi_Int_X2):boolean; overload;
begin
Result:= Multi_Int_X2_Odd(v1);
end;


(******************************************)
function Multi_Int_X2_Even(const v1:Multi_Int_X2):boolean; overload;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= FALSE
else Result:= TRUE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Even(const v1:Multi_Int_X2):boolean; overload;
begin
Result:= Multi_Int_X2_Even(v1);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);

{$Q-}
{$R-}
carry_bits_mask:= (carry_bits_mask << NBits_carry);
{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X2_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftUp_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X2(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X2(v1, NBits_count);
	end;
end;


{******************************************}
procedure ShiftUp(var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= (v1.M_Value[3] >> NBits);

carry_bits_2:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_2);

v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X2_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X2(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X2(v1, NBits_count);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X2(v1, NBits);
end;


{******************************************}
class operator Multi_Int_X2.shl(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X2(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X2.shr(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;
begin
Result:= v1;
ShiftDown_MultiBits_Multi_Int_X2(Result, NBits);
end;


(******************************************)
class operator Multi_Int_X2.<=(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=FALSE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=TRUE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_greaterthan_Multi_Int_X2(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_lessthan_Multi_Int_X2(v1,v2));
end;


(******************************************)
class operator Multi_Int_X2.>=(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_lessthan_Multi_Int_X2(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_X2(v1,v2) );
end;


(******************************************)
class operator Multi_Int_X2.>(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= ABS_greaterthan_Multi_Int_X2(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_X2(v1,v2);
end;


(******************************************)
class operator Multi_Int_X2.<(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
	then Result:= ABS_lessthan_Multi_Int_X2(v1,v2)
	else
		if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
		then Result:= ABS_greaterthan_Multi_Int_X2(v1,v2);
end;


(******************************************)
class operator Multi_Int_X2.=(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X2(v1,v2);
end;


(******************************************)
class operator Multi_Int_X2.<>(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_X2(v1,v2));
end;


(******************************************)
procedure ansistring_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X2_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

M_Val[0]:= 0;
M_Val[1]:= 0;
M_Val[2]:= 0;
M_Val[3]:= 0;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try	i:=strtoint(v1[c]);
			except
				on EConvertError do
					begin
					Multi_Int_ERROR:= TRUE;
					mi.Overflow_flag:=TRUE;
					mi.Defined_flag:= FALSE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
 		if mi.Defined_flag = FALSE then goto 999;
		M_Val[0]:=(M_Val[0] * 10) + i;
		M_Val[1]:=(M_Val[1] * 10);
		M_Val[2]:=(M_Val[2] * 10);
		M_Val[3]:=(M_Val[3] * 10);

		if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on ansistring conversion');
				end;
			goto 999;
			end;

		Inc(c);
		end;
	end;

mi.M_Value[0]:= M_Val[0];
mi.M_Value[1]:= M_Val[1];
mi.M_Value[2]:= M_Val[2];
mi.M_Value[3]:= M_Val[3];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function To_Multi_Int_X2(const v1:Multi_Int_X3):Multi_Int_X2;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
		Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X2_MAXINT)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
		Multi_Int_ERROR:= TRUE;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X2(const v1:Multi_Int_X4):Multi_Int_X2;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X2_MAXINT)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X2(const v1:Multi_Int_XV):Multi_Int_X2;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X2_MAXINT)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:ansistring):Multi_Int_X2;
begin
ansistring_to_Multi_Int_X2(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X2(const v1:MULTI_INT_4W_S; var mi:Multi_Int_X2);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
v:= Abs(v1);

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:MULTI_INT_4W_S):Multi_Int_X2;
begin
MULTI_INT_4W_S_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X2(const v1:MULTI_INT_4W_U; var mi:Multi_Int_X2);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:MULTI_INT_4W_U):Multi_Int_X2;
begin
MULTI_INT_4W_U_to_Multi_Int_X2(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X2(const v1:MULTI_INT_2W_S; out mi:Multi_Int_X2);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
	end;

end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:MULTI_INT_2W_S):Multi_Int_X2;
begin
MULTI_INT_2W_S_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X2(const v1:MULTI_INT_2W_U; out mi:Multi_Int_X2);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:MULTI_INT_2W_U):Multi_Int_X2;
begin
MULTI_INT_2W_U_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X2.:=(const v1:Single):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_SINGLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Single to Multi_Int conversion on ' + operation_str);
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X2.:=(const v1:Real):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
	operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_REAL_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Real to Multi_Int conversion on ' + operation_str);
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X2.:=(const v1:Double):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
	operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_DOUBLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double to Multi_Int conversion on ' + operation_str);
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X2_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):Real;
var
	R,V,M	:Real;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X2_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):Double;
var
	R,V,M	:Double;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X2_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_2W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_2W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_2W_S(-R)
else Result:= MULTI_INT_2W_S(R);
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_2W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[1]) << MULTI_INT_1W_SIZE);
R:= (R OR MULTI_INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;
Result:= R;
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_1W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_1W_S(-R)
else Result:= MULTI_INT_1W_S(R);
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_1W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (v1.M_Value[0] + (v1.M_Value[1] * MULTI_INT_1W_U_MAXINT_1));
if	(R > MULTI_INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= MULTI_INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):Multi_int8u;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8U_MAXINT)
or	(v1.M_Value[1] <> 0)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= Multi_int8u(v1.M_Value[0]);
end;


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):Multi_int8;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8_MAXINT)
or	(v1.M_Value[1] <> 0)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= Multi_int8(v1.M_Value[0]);
end;


(******************************************)
procedure bin_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2);
label 999;
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_U;
	M_Val		:array[0..Multi_X2_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X2_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		bit:= (ord(v1[c]) - ord('0'));
		if	(bit > 1)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			goto 999;
			end;

		M_Val[0]:=(M_Val[0] * 2) + bit;
		n:=1;
		while (n <= Multi_X2_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 2);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X2_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X2_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function Bin_to_Multi_Int_X2(const v1:ansistring):Multi_Int_X2;
begin
Bin_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X2); overload;
begin
Bin_to_Multi_Int_X2(v1,mi);
end;


(******************************************)
function Multi_Int_X2.FromBin(const v1:ansistring):Multi_Int_X2;
begin
bin_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_bin(const v1:Multi_Int_X2; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= MULTI_INT_1W_SIZE;
s:= '';

s:= s
	+   IntToBin(v1.M_Value[3],n)
	+   IntToBin(v1.M_Value[2],n)
	+   IntToBin(v1.M_Value[1],n)
	+   IntToBin(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X2.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X2_to_bin(self, Result, LZ);
end;


(******************************************)
procedure Multi_Int_X2_to_hex(const v1:Multi_Int_X2; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= (MULTI_INT_1W_SIZE div 4);
s:= '';

s:= s
	+   IntToHex(v1.M_Value[3],n)
	+   IntToHex(v1.M_Value[2],n)
	+   IntToHex(v1.M_Value[1],n)
	+   IntToHex(v1.M_Value[0],n)
	;

if	(LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X2.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X2_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X2_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X2_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try
			i:=Hex2Dec(v1[c]);
			except
				on EConvertError do
					begin
					Multi_Int_ERROR:= TRUE;
					mi.Defined_flag:= FALSE;
					mi.Overflow_flag:=TRUE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_X2_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X2_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X2_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X2); overload;
begin
hex_to_Multi_Int_X2(v1,v2);
end;


(******************************************)
function Multi_Int_X2.FromHex(const v1:ansistring):Multi_Int_X2;
begin
hex_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
function Hex_to_Multi_Int_X2(const v1:ansistring):Multi_Int_X2;
begin
hex_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_ansistring(const v1:Multi_Int_X2; out v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X2_maxi] of MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

M_Val[0]:= v1.M_Value[0];
M_Val[1]:= v1.M_Value[1];
M_Val[2]:= v1.M_Value[2];
M_Val[3]:= v1.M_Value[3];

repeat

	M_Val[2]:= M_Val[2] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
	M_Val[1]:= (M_Val[1] DIV 10);

	s:= inttostr(M_Val[0] MOD 10) + s;
	M_Val[0]:= (M_Val[0] DIV 10);

until	(0=0)
and		(M_Val[0] = 0)
and		(M_Val[1] = 0)
and		(M_Val[2] = 0)
and		(M_Val[3] = 0)
;

if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;

v2:=s;
end;


(******************************************)
function Multi_Int_X2.ToStr:ansistring;
begin
Multi_Int_X2_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):ansistring;
begin
Multi_Int_X2_to_ansistring(v1, Result);
end;


(******************************************)
class operator Multi_Int_X2.xor(const v1,v2:Multi_Int_X2):Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:=(v1.M_Value[0] xor v2.M_Value[0]);
Result.M_Value[1]:=(v1.M_Value[1] xor v2.M_Value[1]);
Result.M_Value[2]:=(v1.M_Value[2] xor v2.M_Value[2]);
Result.M_Value[3]:=(v1.M_Value[3] xor v2.M_Value[3]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:=FALSE;
if (v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
function add_Multi_Int_X2(const v1,v2:Multi_Int_X2):Multi_Int_X2;
var
	tv1,
	tv2		:MULTI_INT_2W_U;
	M_Val	:array[0..Multi_X2_maxi] of MULTI_INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_X2(const v1,v2:Multi_Int_X2):Multi_Int_X2;
var
	M_Val	:array[0..Multi_X2_maxi] of MULTI_INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;

(******************************************)
class operator Multi_Int_X2.inc(const v1:Multi_Int_X2):Multi_Int_X2;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	Result:=add_Multi_Int_X2(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_X2(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_X2(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X2(v2,v1);
		Neg:= Multi_UBool_FALSE;
		end;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.+(const v1,v2:Multi_Int_X2):Multi_Int_X2;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	Result:=add_Multi_Int_X2(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_X2(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X2(v2,v1);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X2(v1,v2);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_X2(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X2(v1,v2);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X2(v2,v1);
			Neg:= Multi_UBool_FALSE;
			end;
		end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.dec(const v1:Multi_Int_X2):Multi_Int_X2;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE) then
	begin
	if	ABS_greaterthan_Multi_Int_X2(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_X2(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X2(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_X2(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.-(const v1,v2:Multi_Int_X2):Multi_Int_X2;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	if	(v1.Negative_flag = TRUE) then
		begin
		if	ABS_greaterthan_Multi_Int_X2(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X2(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X2(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_X2(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X2(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X2(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_X2(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_X2(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.-(const v1:Multi_Int_X2):Multi_Int_X2;
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(********************v1********************)
procedure multiply_Multi_Int_X2(const v1,v2:Multi_Int_X2;out Result:Multi_Int_X2);
label	999;
var
M_Val		:array[0..Multi_X2_maxi_x2] of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,
jz,iz		:MULTI_INT_1W_S;
zf,
zero_mult	:boolean;
begin
Result:= 0;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_X2_maxi_x2);

zf:= FALSE;
i:= Multi_X2_maxi;
jz:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		jz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(jz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

zf:= FALSE;
i:= Multi_X2_maxi;
iz:= -1;
repeat
	if	(v1.M_Value[i] <> 0) then
		begin
		iz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(iz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

i:=0;
j:=0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		zero_mult:= TRUE;
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				zero_mult:= FALSE;
				tv1:=v1.M_Value[i];
				tv2:=v2.M_Value[j];
				M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
				M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
				end;
			INC(i);
		until (i > iz);
		if not zero_mult then
			begin
			k:=0;
			repeat
            	if (M_Val[k] <> 0) then
					begin
					M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
					M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
					end;
				INC(k);
			until (k > Multi_X2_maxi);
			end;
		i:=0;
        end;
	INC(j);
until (j > jz);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X2_maxi) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_X2_maxi_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:
end;


(******************************************)
class operator Multi_Int_X2.*(const v1,v2:Multi_Int_X2):Multi_Int_X2;
var	  R:Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X2(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if	R.Overflow_flag then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X2; out VR,VREM:Multi_Int_X2);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X2;
finished		:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Dec');
		end;
	exit;
	end;

if	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('SqRoot is Negative');
		end;
	exit;
	end;

D:= length(v1.ToStr);
D2:= D div 2;
if ((D mod 2)=0) then
	begin
	LS:= '1' + AddCharR('0','',D2-1);
	HS:= '1' + AddCharR('0','',D2);
	H:= HS;
	L:= LS;
	end
else
	begin
	LS:= '1' + AddCharR('0','',D2);
	HS:= '1' + AddCharR('0','',D2+1);
	H:= HS;
	L:= LS;
	end;

finished:= FALSE;
while not finished do
	begin
    T:= subtract_Multi_Int_X2(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X2(L,T);
    multiply_Multi_Int_X2(C,C, CC);

	if	(CC.Overflow)
	or	ABS_greaterthan_Multi_Int_X2(CC,v1)
	then
		begin
		if ABS_lessthan_Multi_Int_X2(C,H) then
			H:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			// multiply_Multi_Int_X2(C,C, T);
			// VREM:= subtract_Multi_Int_X2(v1,T);
			VREM:= 0;
			end
		end
	else if ABS_lessthan_Multi_Int_X2(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X2(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			multiply_Multi_Int_X2(C,C, T);
			VREM:= subtract_Multi_Int_X2(v1,T);
			end
		end
	else
		begin
		VREM:= 0;
		finished:= TRUE;
		end;
	end;

VR:= C;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;
end;


(********************v3********************)
{ Function exp_by_squaring_iterative(TV, P) }

class operator Multi_Int_X2.**(const v1:Multi_Int_X2; const P:MULTI_INT_2W_S):Multi_Int_X2;
var
Y,TV,T,R	:Multi_Int_X2;
PT			:MULTI_INT_2W_S;
begin
PT:= P;
TV:= v1;
if	(PT < 0) then R:= 0
else if	(PT = 0) then R:= 1
else
	begin
	Y := 1;
	while (PT > 1) do
		begin
		if	odd(PT) then
			begin
			multiply_Multi_Int_X2(TV,Y, T);
			if	(T.Overflow_flag)
			then
				begin
				Multi_Int_ERROR:= TRUE;
				Result:= 0;
				Result.Defined_flag:= FALSE;
				Result.Overflow_flag:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Power');
					end;
				exit;
				end;
			if	(T.Negative_flag = Multi_UBool_UNDEF) then
				if	(TV.Negative_flag = Y.Negative_flag)
				then T.Negative_flag:= Multi_UBool_FALSE
				else T.Negative_flag:= Multi_UBool_TRUE;

			Y:= T;
			PT := PT - 1;
			end;
		multiply_Multi_Int_X2(TV,TV, T);
		if	(T.Overflow_flag)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			Result:= 0;
			Result.Defined_flag:= FALSE;
			Result.Overflow_flag:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Power');
				end;
			exit;
			end;
		T.Negative_flag:= Multi_UBool_FALSE;

		TV:= T;
		PT := (PT div 2);
		end;
	multiply_Multi_Int_X2(TV,Y, R);
	if	(R.Overflow_flag)
	then
		begin
		Multi_Int_ERROR:= TRUE;
		Result:= 0;
		Result.Defined_flag:= FALSE;
		Result.Overflow_flag:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on Power');
			end;
		exit;
		end;
	if	(R.Negative_flag = Multi_UBool_UNDEF) then
		if	(TV.Negative_flag = Y.Negative_flag)
		then R.Negative_flag:= Multi_UBool_FALSE
		else R.Negative_flag:= Multi_UBool_TRUE;
	end;

Result:= R;
end;


(********************v1********************)
procedure intdivide_taylor_warruth_X2(const P_dividend,P_dividor:Multi_Int_X2;out P_quotient,P_remainder:Multi_Int_X2);
label	AGAIN,9000,9999;
var
dividor,
quotient,
dividend,
next_dividend	:Multi_Int_X3;

dividend_i,
dividend_i_1,
quotient_i,
dividor_i,
dividor_i_1,
dividor_non_zero_pos,
shiftup_bits_dividor,
i
				:MULTI_INT_1W_S;

adjacent_word_dividend,
adjacent_word_division,
word_division,
word_dividend,
word_carry,
next_word_carry
				:MULTI_INT_2W_U;

finished		:boolean;

begin
dividend:= 0;
next_dividend:= 0;
dividor:= 0;
quotient:= 0;
P_quotient:= 0;
P_remainder:= 0;

if	(P_dividor = 0) then
	begin
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_dividor = P_dividend) then
	begin
	P_quotient:= 1;
    end
else
	begin
	if	(Abs(P_dividor) > Abs(P_dividend)) then
		begin
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	dividor_non_zero_pos:= 0;
    i:= Multi_X2_maxi;
	while (i >= 0) do
		begin
		dividor.M_Value[i]:= P_dividor.M_Value[i];
		if	(dividor_non_zero_pos = 0) then
			if	(dividor.M_Value[i] <> 0) then
				dividor_non_zero_pos:= i;
		Dec(i);
		end;
	dividor.Negative_flag:= FALSE;

	// essential short-cut for single word dividor
	// the later code will fail if this case is not dealt with here

	if	(dividor_non_zero_pos = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		word_carry:= 0;
		i:= Multi_X2_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) div MULTI_INT_2W_U(P_dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(P_dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto 9000;
		end;

    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X3(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X3(dividor, shiftup_bits_dividor);
		end;

	next_word_carry:= 0;
	word_carry:= 0;
	dividor_i:= dividor_non_zero_pos;
	dividor_i_1:= (dividor_i - 1);
	dividend_i:= (Multi_X2_maxi + 1);
	finished:= FALSE;
	while (not finished) do
	    if (dividend_i >= 0) then
		    if (dividend.M_Value[dividend_i] = 0) then
				Dec(dividend_i)
			else finished:= TRUE
		else finished:= TRUE
		;
	quotient_i:= (dividend_i - dividor_non_zero_pos);

	while	(dividend >= 0)
	and		(quotient_i >= 0)
	do
		begin
		word_dividend:= ((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i]);
        word_division:= (word_dividend div dividor.M_Value[dividor_i]);
        next_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((next_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					next_word_carry:= next_word_carry + dividor.M_Value[dividor_i];
					if (next_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;
			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				end;
			P_quotient.M_Value[quotient_i]:= word_division;
            dividend:= next_dividend;
            word_carry:= dividend.M_Value[dividend_i];
			end
		else
			begin
            word_carry:= word_dividend;
			end;

		Dec(dividend_i);
		quotient_i:= (dividend_i - dividor_non_zero_pos);
		end; { while }

	ShiftDown_MultiBits_Multi_Int_X3(dividend, shiftup_bits_dividor);
	P_remainder:= To_Multi_Int_X2(dividend);

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;
9999:
end;


(******************************************)
class operator Multi_Int_X2.div(const v1,v2:Multi_Int_X2):Multi_Int_X2;
var
Remainder,
Quotient	:Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

// same values as last time

if	(X2_Last_Divisor = v2)
and	(X2_Last_Dividend = v1)
then
	Result:= X2_Last_Quotient
else	// different values than last time
	begin
	intdivide_taylor_warruth_X2(v1,v2,Quotient,Remainder);

	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

if	(X2_Last_Remainder.Overflow_flag)
or	(X2_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X2.mod(const v1,v2:Multi_Int_X2):Multi_Int_X2;
var
Remainder,
Quotient	:Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on modulus');
		end;
	exit;
	end;

// same values as last time

if	(X2_Last_Divisor = v2)
and	(X2_Last_Dividend = v1)
then
	Result:= X2_Last_Remainder
else	// different values than last time
	begin
	intdivide_taylor_warruth_X2(v1,v2,Quotient,Remainder);

	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;

if	(X2_Last_Remainder.Overflow_flag)
or	(X2_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


{
******************************************
Multi_Int_X3
******************************************
}

function ABS_greaterthan_Multi_Int_X3(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(v1.M_Value[5] > v2.M_Value[5])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[5] < v2.M_Value[5])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[4] > v2.M_Value[4])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[4] < v2.M_Value[4])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[3] > v2.M_Value[3])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[3] < v2.M_Value[3])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[2] > v2.M_Value[2])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[2] < v2.M_Value[2])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[1] > v2.M_Value[1])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[1] < v2.M_Value[1])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[0] > v2.M_Value[0])
										then begin Result:=TRUE; exit; end
										else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_lessthan_Multi_Int_X3(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(v1.M_Value[5] < v2.M_Value[5])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[5] > v2.M_Value[5])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[4] < v2.M_Value[4])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[4] > v2.M_Value[4])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[3] < v2.M_Value[3])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[3] > v2.M_Value[3])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[2] < v2.M_Value[2])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[2] > v2.M_Value[2])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[1] < v2.M_Value[1])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[1] > v2.M_Value[1])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[0] < v2.M_Value[0])
										then begin Result:=TRUE; exit; end
										else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_equal_Multi_Int_X3(const v1,v2:Multi_Int_X3):Boolean;
begin
Result:=TRUE;
if	(v1.M_Value[5] <> v2.M_Value[5])
then Result:=FALSE
else
	if	(v1.M_Value[4] <> v2.M_Value[4])
	then Result:=FALSE
	else
		if	(v1.M_Value[3] <> v2.M_Value[3])
		then Result:=FALSE
		else
			if	(v1.M_Value[2] <> v2.M_Value[2])
			then Result:=FALSE
			else
				if	(v1.M_Value[1] <> v2.M_Value[1])
				then Result:=FALSE
				else
					if	(v1.M_Value[0] <> v2.M_Value[0])
					then Result:=FALSE;
end;


(******************************************)
function ABS_notequal_Multi_Int_X3(const v1,v2:Multi_Int_X3):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_X3(v1,v2));
end;


(******************************************)
function Multi_Int_X3.Overflow:boolean;
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_X3.Defined:boolean;
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X3):boolean; overload;
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_X3):boolean; overload;
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X3.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X3):boolean; overload;
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;
end;


(******************************************)
function Multi_Int_X3_Odd(const v1:Multi_Int_X3):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= TRUE
else Result:= FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Odd(const v1:Multi_Int_X3):boolean; overload;
begin
Result:= Multi_Int_X3_Odd(v1);
end;


(******************************************)
function Multi_Int_X3_Even(const v1:Multi_Int_X3):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= FALSE
else Result:= TRUE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Even(const v1:Multi_Int_X3):boolean; overload;
begin
Result:= Multi_Int_X3_Even(v1);
end;


(******************************************)
function nlz_words_X3(m:Multi_Int_X3):MULTI_INT_1W_U;
var
i,n		:Multi_int32;
fini	:boolean;
begin
n:= 0;
i:= Multi_X3_maxi;
fini:= false;
repeat
	if	(i < 0) then fini:= true
	else if	(m.M_Value[i] <> 0) then fini:= true
	else
		begin
		INC(n);
		DEC(i);
		end;
until fini;
Result:= n;
end;


(******************************************)
function nlz_MultiBits_X3(v1:Multi_Int_X3):MULTI_INT_1W_U;
var	w	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

w:= nlz_words_X3(v1);
if (w <= Multi_X3_maxi)
then Result:= nlz_bits(v1.M_Value[Multi_X3_maxi-w]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;

NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] << NBits) OR carry_bits_2);

v1.M_Value[5]:= ((v1.M_Value[5] << NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X3_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[5]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= 0;
		DEC(n);
		end;
	end;
end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X3_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[5];
		v1.M_Value[5]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftUp_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X3(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X3(v1, NBits_count);
	end;
end;


{******************************************}
procedure ShiftUp(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;

NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[5] and carry_bits_mask) << NBits_carry);
v1.M_Value[5]:= (v1.M_Value[5] >> NBits);

carry_bits_2:= ((v1.M_Value[4] and carry_bits_mask) << NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_2);

v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X3(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X3(v1, NBits_count);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X3(v1, NBits);
end;


{******************************************}
class operator Multi_Int_X3.shl(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X3(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X3.shr(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;
begin
Result:= v1;
ShiftDown_MultiBits_Multi_Int_X3(Result, NBits);
end;


(******************************************)
class operator Multi_Int_X3.<=(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=FALSE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=TRUE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_greaterthan_Multi_Int_X3(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_lessthan_Multi_Int_X3(v1,v2));
end;


(******************************************)
class operator Multi_Int_X3.>=(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_lessthan_Multi_Int_X3(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_X3(v1,v2) );
end;


(******************************************)
class operator Multi_Int_X3.>(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= ABS_greaterthan_Multi_Int_X3(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_X3(v1,v2);
end;


(******************************************)
class operator Multi_Int_X3.<(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
	then Result:= ABS_lessthan_Multi_Int_X3(v1,v2)
	else
		if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
		then Result:= ABS_greaterthan_Multi_Int_X3(v1,v2);
end;


(******************************************)
class operator Multi_Int_X3.=(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X3(v1,v2);
end;


(******************************************)
class operator Multi_Int_X3.<>(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_X3(v1,v2));
end;


(******************************************)
procedure ansistring_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X3_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

M_Val[0]:= 0;
M_Val[1]:= 0;
M_Val[2]:= 0;
M_Val[3]:= 0;
M_Val[4]:= 0;
M_Val[5]:= 0;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try	i:=strtoint(v1[c]);
			except
				on EConvertError do
					begin
					Multi_Int_ERROR:= TRUE;
					mi.Defined_flag:= FALSE;
					mi.Overflow_flag:=TRUE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;
		M_Val[0]:=(M_Val[0] * 10) + i;
		M_Val[1]:=(M_Val[1] * 10);
		M_Val[2]:=(M_Val[2] * 10);
		M_Val[3]:=(M_Val[3] * 10);
		M_Val[4]:=(M_Val[4] * 10);
		M_Val[5]:=(M_Val[5] * 10);

		if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[4]:=M_Val[4] + (M_Val[3] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[3]:=(M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[4] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[5]:=M_Val[5] + (M_Val[4] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[4]:=(M_Val[4] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[5] > MULTI_INT_1W_U_MAXINT then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;

		Inc(c);
		end;
	end;

mi.M_Value[0]:= M_Val[0];
mi.M_Value[1]:= M_Val[1];
mi.M_Value[2]:= M_Val[2];
mi.M_Value[3]:= M_Val[3];
mi.M_Value[4]:= M_Val[4];
mi.M_Value[5]:= M_Val[5];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:ansistring):Multi_Int_X3;
begin
ansistring_to_Multi_Int_X3(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X3(const v1:MULTI_INT_4W_S; var mi:Multi_Int_X3);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
v:= Abs(v1);

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:MULTI_INT_4W_S):Multi_Int_X3;
begin
MULTI_INT_4W_S_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X3(const v1:MULTI_INT_4W_U; var mi:Multi_Int_X3);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;

end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:MULTI_INT_4W_U):Multi_Int_X3;
begin
MULTI_INT_4W_U_to_Multi_Int_X3(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X3(const v1:MULTI_INT_2W_S; out mi:Multi_Int_X3);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:MULTI_INT_2W_S):Multi_Int_X3;
begin
MULTI_INT_2W_S_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X3(const v1:MULTI_INT_2W_U; out mi:Multi_Int_X3);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:MULTI_INT_2W_U):Multi_Int_X3;
begin
MULTI_INT_2W_U_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_XV):Multi_Int_X3;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X3_MAXINT)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_X4):Multi_Int_X3;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X3_MAXINT)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_X2):Multi_Int_X3;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X3_maxi) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X3(const v1:Multi_Int_X2; out MI:Multi_Int_X3);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X3_maxi) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X2):Multi_Int_X3;
begin
Multi_Int_X2_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X3.:=(const v1:Single):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;
begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_SINGLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Single to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X3.:=(const v1:Real):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_REAL_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Real to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X3.:=(const v1:Double):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_DOUBLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X3_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):Real;
var
	R,V,M	:Real;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X3_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):Double;
var
	R,V,M	:Double;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X3_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_2W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_2W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_2W_S(-R)
else Result:= MULTI_INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_2W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[1]) << MULTI_INT_1W_SIZE);
R:= (R OR MULTI_INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_1W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_1W_S(-R)
else Result:= MULTI_INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_1W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (v1.M_Value[0] + (v1.M_Value[1] * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= MULTI_INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):Multi_int8u;
(* var	R	:Multi_int8u; *)
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8U_MAXINT)
or	(v1.M_Value[1] <> 0)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= Multi_int8u(v1.M_Value[0]);
end;


{******************************************}
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):Multi_int8;
(* var	R	:Multi_int8; *)
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= Multi_int8(v1.M_Value[0]);
end;


(******************************************)
procedure bin_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3);
label 999;
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_U;
	M_Val		:array[0..Multi_X3_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X3_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		bit:= (ord(v1[c]) - ord('0'));
		if	(bit > 1)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:= FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			goto 999;
			end;

		M_Val[0]:=(M_Val[0] * 2) + bit;
		n:=1;
		while (n <= Multi_X3_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 2);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X3_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X3_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function Bin_to_Multi_Int_X3(const v1:ansistring):Multi_Int_X3;
begin
Bin_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X3); overload;
begin
Bin_to_Multi_Int_X3(v1,mi);
end;


(******************************************)
function Multi_Int_X3.FromBin(const v1:ansistring):Multi_Int_X3;
begin
bin_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_bin(const v1:Multi_Int_X3; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= MULTI_INT_1W_SIZE;
s:= '';

s:= s
	+   IntToBin(v1.M_Value[5],n)
	+   IntToBin(v1.M_Value[4],n)
	+   IntToBin(v1.M_Value[3],n)
	+   IntToBin(v1.M_Value[2],n)
	+   IntToBin(v1.M_Value[1],n)
	+   IntToBin(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X3.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X3_to_bin(self, Result, LZ);
end;


(******************************************)
procedure Multi_Int_X3_to_hex(const v1:Multi_Int_X3; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

n:= (MULTI_INT_1W_SIZE div 4);
s:= '';

s:= s
	+   IntToHex(v1.M_Value[5],n)
	+   IntToHex(v1.M_Value[4],n)
	+   IntToHex(v1.M_Value[3],n)
	+   IntToHex(v1.M_Value[2],n)
	+   IntToHex(v1.M_Value[1],n)
	+   IntToHex(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X3.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X3_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X3_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X3_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try
			i:=Hex2Dec(v1[c]);
			except
				on EConvertError do
					begin
					Multi_Int_ERROR:= TRUE;
					mi.Defined_flag:= FALSE;
					mi.Overflow_flag:=TRUE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_X3_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X3_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on hex string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X3_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X3); overload;
begin
hex_to_Multi_Int_X3(v1,v2);
end;


(******************************************)
function Multi_Int_X3.FromHex(const v1:ansistring):Multi_Int_X3;
begin
hex_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
function Hex_to_Multi_Int_X3(const v1:ansistring):Multi_Int_X3;
begin
hex_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_ansistring(const v1:Multi_Int_X3; out v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X3_maxi] of MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

M_Val[0]:= v1.M_Value[0];
M_Val[1]:= v1.M_Value[1];
M_Val[2]:= v1.M_Value[2];
M_Val[3]:= v1.M_Value[3];
M_Val[4]:= v1.M_Value[4];
M_Val[5]:= v1.M_Value[5];

repeat

	M_Val[4]:= M_Val[4] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[5] MOD 10));
	M_Val[5]:= (M_Val[5] DIV 10);

	M_Val[3]:= M_Val[3] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[4] MOD 10));
	M_Val[4]:= (M_Val[4] DIV 10);

	M_Val[2]:= M_Val[2] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
	M_Val[1]:= (M_Val[1] DIV 10);

	s:= inttostr(M_Val[0] MOD 10) + s;
	M_Val[0]:= (M_Val[0] DIV 10);

until	(0=0)
and		(M_Val[0] = 0)
and		(M_Val[1] = 0)
and		(M_Val[2] = 0)
and		(M_Val[3] = 0)
and		(M_Val[4] = 0)
and		(M_Val[5] = 0)
;

if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;

v2:=s;
end;


(******************************************)
function Multi_Int_X3.ToStr:ansistring;
begin
Multi_Int_X3_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):ansistring;
begin
Multi_Int_X3_to_ansistring(v1, Result);
end;


(******************************************)
class operator Multi_Int_X3.xor(const v1,v2:Multi_Int_X3):Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:=(v1.M_Value[0] xor v2.M_Value[0]);
Result.M_Value[1]:=(v1.M_Value[1] xor v2.M_Value[1]);
Result.M_Value[2]:=(v1.M_Value[2] xor v2.M_Value[2]);
Result.M_Value[3]:=(v1.M_Value[3] xor v2.M_Value[3]);
Result.M_Value[4]:=(v1.M_Value[4] xor v2.M_Value[4]);
Result.M_Value[5]:=(v1.M_Value[5] xor v2.M_Value[5]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:=FALSE;
if (v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
function add_Multi_Int_X3(const v1,v2:Multi_Int_X3):Multi_Int_X3;
var
	tv1,
	tv2		:MULTI_INT_2W_U;
	M_Val	:array[0..Multi_X3_maxi] of MULTI_INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[4]:= (M_Val[3] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[3]:= (M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

tv1:= v1.M_Value[4];
tv2:= v2.M_Value[4];
M_Val[4]:=(M_Val[4] + tv1 + tv2);
if	M_Val[4] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[4] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[4]:= (M_Val[4] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

tv1:= v1.M_Value[5];
tv2:= v2.M_Value[5];
M_Val[5]:=(M_Val[5] + tv1 + tv2);
if	M_Val[5] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[5] MOD MULTI_INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_X3(const v1,v2:Multi_Int_X3):Multi_Int_X3;
var
	M_Val	:array[0..Multi_X3_maxi] of MULTI_INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	M_Val[4]:= -1;
	M_Val[3]:= (M_Val[3] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

M_Val[4]:=(v1.M_Value[4] - v2.M_Value[4] + M_Val[4]);
if	M_Val[4] < 0 then
	begin
	M_Val[5]:= -1;
	M_Val[4]:= (M_Val[4] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

M_Val[5]:=(v1.M_Value[5] - v2.M_Value[5] + M_Val[5]);
if	M_Val[5] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X3.inc(const v1:Multi_Int_X3):Multi_Int_X3;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	Result:=add_Multi_Int_X3(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_X3(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_X3(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X3(v2,v1);
		Neg:= Multi_UBool_FALSE;
		end;
	end;

if (Result.Overflow_flag = TRUE) then
		begin
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EIntOverflow.create('Overflow');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.+(const v1,v2:Multi_Int_X3):Multi_Int_X3;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	Result:=add_Multi_Int_X3(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_X3(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X3(v2,v1);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X3(v1,v2);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_X3(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X3(v1,v2);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X3(v2,v1);
			Neg:= Multi_UBool_FALSE;
			end;
		end;

if (Result.Overflow_flag = TRUE) then
		begin
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EIntOverflow.create('Overflow');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.dec(const v1:Multi_Int_X3):Multi_Int_X3;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE) then
	begin
	if	ABS_greaterthan_Multi_Int_X3(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_X3(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X3(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_X3(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.-(const v1,v2:Multi_Int_X3):Multi_Int_X3;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	if	(v1.Negative_flag = TRUE) then
		begin
		if	ABS_greaterthan_Multi_Int_X3(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X3(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X3(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_X3(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X3(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X3(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_X3(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_X3(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.-(const v1:Multi_Int_X3):Multi_Int_X3;
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(*******************v4*********************)
procedure multiply_Multi_Int_X3(const v1,v2:Multi_Int_X3;out Result:Multi_Int_X3); overload;
label	999;
var
M_Val		:array[0..Multi_X3_maxi_x2] of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,
jz,iz		:MULTI_INT_1W_S;
zf,
zero_mult	:boolean;
begin
Result:= 0;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_X3_maxi_x2);

zf:= FALSE;
i:= Multi_X3_maxi;
jz:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		jz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(jz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

zf:= FALSE;
i:= Multi_X3_maxi;
iz:= -1;
repeat
	if	(v1.M_Value[i] <> 0) then
		begin
		iz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(iz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

i:=0;
j:=0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		zero_mult:= TRUE;
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				zero_mult:= FALSE;
				tv1:=v1.M_Value[i];
				tv2:=v2.M_Value[j];
				M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
				M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
				end;
			INC(i);
		until (i > iz);
		if not zero_mult then
			begin
			k:=0;
			repeat
            	if (M_Val[k] <> 0) then
					begin
					M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
					M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
					end;
				INC(k);
			until (k > Multi_X3_maxi);
			end;
		i:=0;
        end;
	INC(j);
until (j > jz);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X3_maxi) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_X3_maxi_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_X3_maxi) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:
end;


(******************************************)
class operator Multi_Int_X3.*(const v1,v2:Multi_Int_X3):Multi_Int_X3;
var	  R:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X3(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;
end;


(******************************************)
function Multi_Int_X2_to_X3_multiply(const v1,v2:Multi_Int_X2):Multi_Int_X3;
var	  R:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X3(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X3; out VR,VREM:Multi_Int_X3);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X3;
finished		:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Dec');
		end;
	exit;
	end;

if	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('SqRoot is Negative_flag');
		end;
	exit;
	end;

D:= length(v1.ToStr);
D2:= D div 2;
if ((D mod 2)=0) then
	begin
	LS:= '1' + AddCharR('0','',D2-1);
	HS:= '1' + AddCharR('0','',D2);
	H:= HS;
	L:= LS;
	end
else
	begin
	LS:= '1' + AddCharR('0','',D2);
	HS:= '1' + AddCharR('0','',D2+1);
	H:= HS;
	L:= LS;
	end;

finished:= FALSE;
while not finished do
	begin
    T:= subtract_Multi_Int_X3(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X3(L,T);
    multiply_Multi_Int_X3(C,C, CC);

	if	(CC.Overflow)
	or	ABS_greaterthan_Multi_Int_X3(CC,v1)
	then
		begin
		if ABS_lessthan_Multi_Int_X3(C,H) then
			H:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			// multiply_Multi_Int_X3(C,C, T);
			// VREM:= subtract_Multi_Int_X3(v1,T);
			VREM:= 0;
			end
		end
	else if ABS_lessthan_Multi_Int_X3(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X3(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			multiply_Multi_Int_X3(C,C, T);
			VREM:= subtract_Multi_Int_X3(v1,T);
			end
		end
	else
		begin
		VREM:= 0;
		finished:= TRUE;
		end;
	end;

VR:= C;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;
end;


(********************v3********************)
{ Function exp_by_squaring_iterative(TV, P) }

class operator Multi_Int_X3.**(const v1:Multi_Int_X3; const P:MULTI_INT_2W_S):Multi_Int_X3;
var
Y,TV,T,R	:Multi_Int_X3;
PT			:MULTI_INT_2W_S;
begin
PT:= P;
TV:= v1;
if	(PT < 0) then R:= 0
else if	(PT = 0) then R:= 1
else
	begin
	Y := 1;
	while (PT > 1) do
		begin
		if	odd(PT) then
			begin
			multiply_Multi_Int_X3(TV,Y, T);
			if	(T.Overflow_flag)
			then
				begin
				Result:= 0;
				Result.Defined_flag:= FALSE;
				Result.Overflow_flag:= TRUE;
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Power');
					end;
				exit;
				end;
			if	(T.Negative_flag = Multi_UBool_UNDEF) then
				if	(TV.Negative_flag = Y.Negative_flag)
				then T.Negative_flag:= Multi_UBool_FALSE
				else T.Negative_flag:= Multi_UBool_TRUE;

			Y:= T;
			PT := PT - 1;
			end;
		multiply_Multi_Int_X3(TV,TV, T);
		if	(T.Overflow_flag)
		then
			begin
			Result:= 0;
			Result.Defined_flag:= FALSE;
			Result.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Power');
				end;
			exit;
			end;
		T.Negative_flag:= Multi_UBool_FALSE;

		TV:= T;
		PT := (PT div 2);
		end;
	multiply_Multi_Int_X3(TV,Y, R);
	if	(R.Overflow_flag)
	then
		begin
		Result:= 0;
		Result.Defined_flag:= FALSE;
		Result.Overflow_flag:= TRUE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on Power');
			end;
		exit;
		end;
	if	(R.Negative_flag = Multi_UBool_UNDEF) then
		if	(TV.Negative_flag = Y.Negative_flag)
		then R.Negative_flag:= Multi_UBool_FALSE
		else R.Negative_flag:= Multi_UBool_TRUE;
	end;

Result:= R;
end;


(********************v1********************)
procedure intdivide_taylor_warruth_X3(const P_dividend,P_dividor:Multi_Int_X3;out P_quotient,P_remainder:Multi_Int_X3);
label	AGAIN,9000,9999;
var
dividor,
quotient,
dividend,
next_dividend	:Multi_Int_X4;

dividend_i,
dividend_i_1,
quotient_i,
dividor_i,
dividor_i_1,
dividor_non_zero_pos,
shiftup_bits_dividor,
i				:MULTI_INT_1W_S;

adjacent_word_dividend,
adjacent_word_division,
word_division,
word_dividend,
word_carry,
next_word_carry
				:MULTI_INT_2W_U;

finished		:boolean;

begin
dividend:= 0;
next_dividend:= 0;
dividor:= 0;
quotient:= 0;
P_quotient:= 0;
P_remainder:= 0;

if	(P_dividor = 0) then
	begin
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_dividor = P_dividend) then
	begin
	P_quotient:= 1;
    end
else
	begin
	if	(Abs(P_dividor) > Abs(P_dividend)) then
		begin
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	dividor_non_zero_pos:= 0;
    i:= Multi_X3_maxi;
	while (i >= 0) do
		begin
		dividor.M_Value[i]:= P_dividor.M_Value[i];
		if	(dividor_non_zero_pos = 0) then
			if	(dividor.M_Value[i] <> 0) then
				dividor_non_zero_pos:= i;
		Dec(i);
		end;
	dividor.Negative_flag:= FALSE;

	// essential short-cut for single word dividor
	// the later code will fail if this case is not dealt with here

	if	(dividor_non_zero_pos = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		word_carry:= 0;
		i:= Multi_X3_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) div MULTI_INT_2W_U(dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto 9000;
		end;

    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X4(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X4(dividor, shiftup_bits_dividor);
		end;

	next_word_carry:= 0;
	word_carry:= 0;
	dividor_i:= dividor_non_zero_pos;
	dividor_i_1:= (dividor_i - 1);
	dividend_i:= (Multi_X3_maxi + 1);
	finished:= FALSE;
	while (not finished) do
	    if (dividend_i >= 0) then
		    if (dividend.M_Value[dividend_i] = 0) then
				Dec(dividend_i)
			else finished:= TRUE
		else finished:= TRUE
		;
	quotient_i:= (dividend_i - dividor_non_zero_pos);

	while	(dividend >= 0)
	and		(quotient_i >= 0)
	do
		begin
		word_dividend:= ((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i]);
        word_division:= (word_dividend div dividor.M_Value[dividor_i]);
        next_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((next_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					next_word_carry:= next_word_carry + dividor.M_Value[dividor_i];
					if (next_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;
			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				end;
			P_quotient.M_Value[quotient_i]:= word_division;
            dividend:= next_dividend;
            word_carry:= dividend.M_Value[dividend_i];
			end
		else
			begin
            word_carry:= word_dividend;
			end;

		Dec(dividend_i);
		quotient_i:= (dividend_i - dividor_non_zero_pos);
		end; { while }

	ShiftDown_MultiBits_Multi_Int_X4(dividend, shiftup_bits_dividor);
	P_remainder:= To_Multi_Int_X3(dividend);

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;
9999:
end;


(******************************************)
class operator Multi_Int_X3.div(const v1,v2:Multi_Int_X3):Multi_Int_X3;
var
Remainder,
Quotient	:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

// same values as last time

if	(X3_Last_Divisor = v2)
and	(X3_Last_Dividend = v1)
then
	Result:= X3_Last_Quotient
else	// different values than last time
	begin
	intdivide_taylor_warruth_X3(v1,v2,Quotient,Remainder);

	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

if	(X3_Last_Remainder.Overflow_flag)
or	(X3_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X3.mod(const v1,v2:Multi_Int_X3):Multi_Int_X3;
var
Remainder,
Quotient	:Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on modulus');
		end;
	exit;
	end;

// same values as last time

if	(X3_Last_Divisor = v2)
and	(X3_Last_Dividend = v1)
then
	Result:= X3_Last_Remainder
else	// different values than last time
	begin
	intdivide_taylor_warruth_X3(v1,v2,Quotient,Remainder);

	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;

if	(X3_Last_Remainder.Overflow_flag)
or	(X3_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


{
******************************************
Multi_Int_X4
******************************************
}


(******************************************)
function ABS_greaterthan_Multi_Int_X4(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(v1.M_Value[7] > v2.M_Value[7])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[7] < v2.M_Value[7])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[6] > v2.M_Value[6])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[6] < v2.M_Value[6])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[5] > v2.M_Value[5])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[5] < v2.M_Value[5])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[4] > v2.M_Value[4])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[4] < v2.M_Value[4])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[3] > v2.M_Value[3])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[3] < v2.M_Value[3])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[2] > v2.M_Value[2])
										then begin Result:=TRUE; exit; end
										else
											if	(v1.M_Value[2] < v2.M_Value[2])
											then begin Result:=FALSE; exit; end
											else
												if	(v1.M_Value[1] > v2.M_Value[1])
												then begin Result:=TRUE; exit; end
												else
													if	(v1.M_Value[1] < v2.M_Value[1])
													then begin Result:=FALSE; exit; end
													else
														if	(v1.M_Value[0] > v2.M_Value[0])
														then begin Result:=TRUE; exit; end
														else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_lessthan_Multi_Int_X4(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(v1.M_Value[7] < v2.M_Value[7])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[7] > v2.M_Value[7])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[6] < v2.M_Value[6])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[6] > v2.M_Value[6])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[5] < v2.M_Value[5])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[5] > v2.M_Value[5])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[4] < v2.M_Value[4])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[4] > v2.M_Value[4])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[3] < v2.M_Value[3])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[3] > v2.M_Value[3])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[2] < v2.M_Value[2])
										then begin Result:=TRUE; exit; end
										else
											if	(v1.M_Value[2] > v2.M_Value[2])
											then begin Result:=FALSE; exit; end
											else
												if	(v1.M_Value[1] < v2.M_Value[1])
												then begin Result:=TRUE; exit; end
												else
													if	(v1.M_Value[1] > v2.M_Value[1])
													then begin Result:=FALSE; exit; end
													else
														if	(v1.M_Value[0] < v2.M_Value[0])
														then begin Result:=TRUE; exit; end
														else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_equal_Multi_Int_X4(const v1,v2:Multi_Int_X4):Boolean;
begin
Result:=TRUE;
if	(v1.M_Value[0] <> v2.M_Value[0])
then Result:=FALSE
else
	if	(v1.M_Value[1] <> v2.M_Value[1])
	then Result:=FALSE
	else
		if	(v1.M_Value[2] <> v2.M_Value[2])
		then Result:=FALSE
		else
			if	(v1.M_Value[3] <> v2.M_Value[3])
			then Result:=FALSE
			else
				if	(v1.M_Value[4] <> v2.M_Value[4])
				then Result:=FALSE
				else
					if	(v1.M_Value[5] <> v2.M_Value[5])
					then Result:=FALSE
					else
						if	(v1.M_Value[6] <> v2.M_Value[6])
						then Result:=FALSE
						else
							if	(v1.M_Value[7] <> v2.M_Value[7])
							then Result:=FALSE;
end;


(******************************************)
function ABS_notequal_Multi_Int_X4(const v1,v2:Multi_Int_X4):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_X4(v1,v2));
end;


(******************************************)
function Multi_Int_X4.Overflow:boolean;
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_X4.Defined:boolean;
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X4):boolean; overload;
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_X4):boolean; overload;
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X4.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X4):boolean; overload;
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;
end;


(******************************************)
function Multi_Int_X4_Odd(const v1:Multi_Int_X4):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= TRUE
else Result:= FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Odd(const v1:Multi_Int_X4):boolean; overload;
begin
Result:= Multi_Int_X4_Odd(v1);
end;


(******************************************)
function Multi_Int_X4_Even(const v1:Multi_Int_X4):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= FALSE
else Result:= TRUE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Even(const v1:Multi_Int_X4):boolean; overload;
begin
Result:= Multi_Int_X4_Even(v1);
end;


(******************************************)
function nlz_words_X4(m:Multi_Int_X4):MULTI_INT_1W_U; // v2
var
i,n		:Multi_int32;
fini	:boolean;
begin
n:= 0;
i:= Multi_X4_maxi;
fini:= false;
repeat
	if	(i < 0) then fini:= true
	else if	(m.M_Value[i] <> 0) then fini:= true
	else
		begin
		INC(n);
		DEC(i);
		end;
until fini;
Result:= n;
end;


(******************************************)
function nlz_MultiBits_X4(v1:Multi_Int_X4):MULTI_INT_1W_U;
var	w	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

w:= nlz_words_X4(v1);
if (w <= Multi_X4_maxi)
then Result:= nlz_bits(v1.M_Value[Multi_X4_maxi-w]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);

{$Q-}
{$R-}
carry_bits_mask:= (carry_bits_mask << NBits_carry);
{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[6] and carry_bits_mask) >> NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] << NBits) OR carry_bits_2);

v1.M_Value[7]:= ((v1.M_Value[7] << NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X4_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[7]:= v1.M_Value[6];
		v1.M_Value[6]:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= 0;
		DEC(n);
		end;
	end;
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[7] and carry_bits_mask) << NBits_carry);
v1.M_Value[7]:= (v1.M_Value[7] >> NBits);

carry_bits_2:= ((v1.M_Value[6] and carry_bits_mask) << NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[5] and carry_bits_mask) << NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[4] and carry_bits_mask) << NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_2);

v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X4_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[6];
		v1.M_Value[6]:= v1.M_Value[7];
		v1.M_Value[7]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftUp_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X4(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X4(v1, NBits_count);
	end;
end;


{******************************************}
procedure ShiftUp(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X4(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X4(v1, NBits_count);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X4(v1, NBits);
end;


{******************************************}
class operator Multi_Int_X4.shl(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X4(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X4.shr(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;
begin
Result:= v1;
ShiftDown_MultiBits_Multi_Int_X4(Result, NBits);
end;


(******************************************)
class operator Multi_Int_X4.<=(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=FALSE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=TRUE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_greaterthan_Multi_Int_X4(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_lessthan_Multi_Int_X4(v1,v2));
end;


(******************************************)
class operator Multi_Int_X4.>=(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_lessthan_Multi_Int_X4(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_X4(v1,v2) );
end;


(******************************************)
class operator Multi_Int_X4.>(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= ABS_greaterthan_Multi_Int_X4(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_X4(v1,v2);
end;


(******************************************)
class operator Multi_Int_X4.<(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
	then Result:= ABS_lessthan_Multi_Int_X4(v1,v2)
	else
		if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
		then Result:= ABS_greaterthan_Multi_Int_X4(v1,v2);
end;


(******************************************)
class operator Multi_Int_X4.=(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X4(v1,v2);
end;


(******************************************)
class operator Multi_Int_X4.<>(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_X4(v1,v2));
end;


(******************************************)
function To_Multi_Int_X4(const v1:Multi_Int_XV):Multi_Int_X4;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X4_MAXINT)
then
	begin
	Result.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X4_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X4(const v1:Multi_Int_X3):Multi_Int_X4;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	Result.Overflow_flag:= TRUE;
	exit;
	end;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_maxi) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X4(const v1:Multi_Int_X2):Multi_Int_X4;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	Result.Overflow_flag:= TRUE;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_maxi) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X4(const v1:Multi_Int_X2; out MI:Multi_Int_X4);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_maxi) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X2):Multi_Int_X4;
begin
Multi_Int_X2_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_X4(const v1:Multi_Int_X3; out MI:Multi_Int_X4);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_maxi) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X3):Multi_Int_X4;
begin
Multi_Int_X3_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure ansistring_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X4_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

M_Val[0]:= 0;
M_Val[1]:= 0;
M_Val[2]:= 0;
M_Val[3]:= 0;
M_Val[4]:= 0;
M_Val[5]:= 0;
M_Val[6]:= 0;
M_Val[7]:= 0;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try	i:=strtoint(v1[c]);
			except
				on EConvertError do
					begin
					mi.Defined_flag:= FALSE;
					mi.Overflow_flag:=TRUE;
					Multi_Int_ERROR:= TRUE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;
		M_Val[0]:=(M_Val[0] * 10) + i;
		M_Val[1]:=(M_Val[1] * 10);
		M_Val[2]:=(M_Val[2] * 10);
		M_Val[3]:=(M_Val[3] * 10);
		M_Val[4]:=(M_Val[4] * 10);
		M_Val[5]:=(M_Val[5] * 10);
		M_Val[6]:=(M_Val[6] * 10);
		M_Val[7]:=(M_Val[7] * 10);

		if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[4]:=M_Val[4] + (M_Val[3] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[3]:=(M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[4] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[5]:=M_Val[5] + (M_Val[4] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[4]:=(M_Val[4] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[5] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[6]:=M_Val[6] + (M_Val[5] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[5]:=(M_Val[5] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[6] > MULTI_INT_1W_U_MAXINT then
			begin
			M_Val[7]:=M_Val[7] + (M_Val[6] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[6]:=(M_Val[6] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		if	M_Val[7] > MULTI_INT_1W_U_MAXINT then
			begin
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

mi.M_Value[0]:= M_Val[0];
mi.M_Value[1]:= M_Val[1];
mi.M_Value[2]:= M_Val[2];
mi.M_Value[3]:= M_Val[3];
mi.M_Value[4]:= M_Val[4];
mi.M_Value[5]:= M_Val[5];
mi.M_Value[6]:= M_Val[6];
mi.M_Value[7]:= M_Val[7];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
and	(M_Val[6] = 0)
and	(M_Val[7] = 0)
then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:ansistring):Multi_Int_X4;
begin
ansistring_to_Multi_Int_X4(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X4(const v1:MULTI_INT_4W_S; var mi:Multi_Int_X4);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
v:= Abs(v1);

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:MULTI_INT_4W_S):Multi_Int_X4;
begin
MULTI_INT_4W_S_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X4(const v1:MULTI_INT_4W_U; var mi:Multi_Int_X4);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:MULTI_INT_4W_U):Multi_Int_X4;
begin
MULTI_INT_4W_U_to_Multi_Int_X4(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X4(const v1:MULTI_INT_2W_S; out mi:Multi_Int_X4);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:MULTI_INT_2W_S):Multi_Int_X4;
begin
MULTI_INT_2W_S_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X4(const v1:MULTI_INT_2W_U; out mi:Multi_Int_X4);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:MULTI_INT_2W_U):Multi_Int_X4;
begin
MULTI_INT_2W_U_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X4.:=(const v1:Single):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;
begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_SINGLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Single to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X4.:=(const v1:Real):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_REAL_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Real to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X4.:=(const v1:Double):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_DOUBLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X4_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):Real;
var
	R,V,M	:Real;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X4_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):Double;
var
	R,V,M	:Double;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i <= Multi_X4_maxi)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_2W_S;
var	R	:MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if (R >= MULTI_INT_2W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_2W_S(-R)
else Result:= MULTI_INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_2W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[1]) << MULTI_INT_1W_SIZE);
R:= (R OR MULTI_INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_1W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_1W_S(-R)
else Result:= MULTI_INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_1W_U;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

if	(R > MULTI_INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= MULTI_INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):Multi_int8u;
(* var	R	:Multi_int8u; *)
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8U_MAXINT)
or	(v1.M_Value[1] <> 0)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= Multi_int8u(v1.M_Value[0]);
end;


{******************************************}
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):Multi_int8;
(* var	R	:Multi_int8u; *)
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (v1.M_Value[0] > Multi_INT8_MAXINT)
or	(v1.M_Value[1] <> 0)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= Multi_int8(v1.M_Value[0]);
end;


(******************************************)
procedure bin_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4);
label 999;
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_U;
	M_Val		:array[0..Multi_X4_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X4_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		bit:= (ord(v1[c]) - ord('0'));
		if	(bit > 1)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			goto 999;
			end;

		M_Val[0]:=(M_Val[0] * 2) + bit;
		n:=1;
		while (n <= Multi_X4_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 2);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X4_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X4_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function Bin_to_Multi_Int_X4(const v1:ansistring):Multi_Int_X4;
begin
Bin_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X4); overload;
begin
Bin_to_Multi_Int_X4(v1,mi);
end;


(******************************************)
function Multi_Int_X4.FromBin(const v1:ansistring):Multi_Int_X4;
begin
bin_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure Multi_Int_X4_to_bin(const v1:Multi_Int_X4; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= MULTI_INT_1W_SIZE;
s:= '';

s:= s
	+   IntToBin(v1.M_Value[7],n)
	+   IntToBin(v1.M_Value[6],n)
	+   IntToBin(v1.M_Value[5],n)
	+   IntToBin(v1.M_Value[4],n)
	+   IntToBin(v1.M_Value[3],n)
	+   IntToBin(v1.M_Value[2],n)
	+   IntToBin(v1.M_Value[1],n)
	+   IntToBin(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X4.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X4_to_bin(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X4_maxi] of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X4_maxi)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try
			i:=Hex2Dec(v1[c]);
			except
				on EConvertError do
					begin
					Multi_Int_ERROR:= TRUE;
					mi.Overflow_flag:=TRUE;
					mi.Defined_flag:= FALSE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_X4_maxi) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X4_maxi) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			mi.Defined_flag:=FALSE;
			mi.Overflow_flag:=TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on string conversion');
				end;
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X4_maxi) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X4); overload;
begin
hex_to_Multi_Int_X4(v1,v2);
end;


(******************************************)
function Multi_Int_X4.FromHex(const v1:ansistring):Multi_Int_X4;
begin
hex_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
function Hex_to_Multi_Int_X4(const v1:ansistring):Multi_Int_X4;
begin
hex_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure Multi_Int_X4_to_hex(const v1:Multi_Int_X4; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= (MULTI_INT_1W_SIZE div 4);
s:= '';

s:= s
	+   IntToHex(v1.M_Value[7],n)
	+   IntToHex(v1.M_Value[6],n)
	+   IntToHex(v1.M_Value[5],n)
	+   IntToHex(v1.M_Value[4],n)
	+   IntToHex(v1.M_Value[3],n)
	+   IntToHex(v1.M_Value[2],n)
	+   IntToHex(v1.M_Value[1],n)
	+   IntToHex(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_X4.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_X4_to_hex(self, Result, LZ);
end;


(******************************************)
procedure Multi_Int_X4_to_ansistring(const v1:Multi_Int_X4; out v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X4_maxi] of MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

M_Val[0]:= v1.M_Value[0];
M_Val[1]:= v1.M_Value[1];
M_Val[2]:= v1.M_Value[2];
M_Val[3]:= v1.M_Value[3];
M_Val[4]:= v1.M_Value[4];
M_Val[5]:= v1.M_Value[5];
M_Val[6]:= v1.M_Value[6];
M_Val[7]:= v1.M_Value[7];

repeat

	M_Val[6]:= M_Val[6] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[7] MOD 10));
	M_Val[7]:= (M_Val[7] DIV 10);

	M_Val[5]:= M_Val[5] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[6] MOD 10));
	M_Val[6]:= (M_Val[6] DIV 10);

	M_Val[4]:= M_Val[4] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[5] MOD 10));
	M_Val[5]:= (M_Val[5] DIV 10);

	M_Val[3]:= M_Val[3] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[4] MOD 10));
	M_Val[4]:= (M_Val[4] DIV 10);

	M_Val[2]:= M_Val[2] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
	M_Val[1]:= (M_Val[1] DIV 10);

	s:= inttostr(M_Val[0] MOD 10) + s;
	M_Val[0]:= (M_Val[0] DIV 10);

until	(0=0)
and		(M_Val[0] = 0)
and		(M_Val[1] = 0)
and		(M_Val[2] = 0)
and		(M_Val[3] = 0)
and		(M_Val[4] = 0)
and		(M_Val[5] = 0)
and		(M_Val[6] = 0)
and		(M_Val[7] = 0)
;

if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;

v2:=s;
end;


(******************************************)
function Multi_Int_X4.ToStr:ansistring;
begin
Multi_Int_X4_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):ansistring;
begin
Multi_Int_X4_to_ansistring(v1, Result);
end;


(******************************************)
class operator Multi_Int_X4.xor(const v1,v2:Multi_Int_X4):Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:=(v1.M_Value[0] xor v2.M_Value[0]);
Result.M_Value[1]:=(v1.M_Value[1] xor v2.M_Value[1]);
Result.M_Value[2]:=(v1.M_Value[2] xor v2.M_Value[2]);
Result.M_Value[3]:=(v1.M_Value[3] xor v2.M_Value[3]);
Result.M_Value[4]:=(v1.M_Value[4] xor v2.M_Value[4]);
Result.M_Value[5]:=(v1.M_Value[5] xor v2.M_Value[5]);
Result.M_Value[6]:=(v1.M_Value[6] xor v2.M_Value[6]);
Result.M_Value[7]:=(v1.M_Value[7] xor v2.M_Value[7]);

Result.Defined_flag:=TRUE;
Result.Overflow_flag:=FALSE;
if (v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
function add_Multi_Int_X4(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var
	tv1,
	tv2		:MULTI_INT_2W_U;
	M_Val	:array[0..Multi_X4_maxi] of MULTI_INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[4]:= (M_Val[3] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[3]:= (M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

tv1:= v1.M_Value[4];
tv2:= v2.M_Value[4];
M_Val[4]:=(M_Val[4] + tv1 + tv2);
if	M_Val[4] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[4] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[4]:= (M_Val[4] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

tv1:= v1.M_Value[5];
tv2:= v2.M_Value[5];
M_Val[5]:=(M_Val[5] + tv1 + tv2);
if	M_Val[5] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[6]:= (M_Val[5] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[5]:= (M_Val[5] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

tv1:= v1.M_Value[6];
tv2:= v2.M_Value[6];
M_Val[6]:=(M_Val[6] + tv1 + tv2);
if	M_Val[6] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[7]:= (M_Val[6] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[6]:= (M_Val[6] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

tv1:= v1.M_Value[7];
tv2:= v2.M_Value[7];
M_Val[7]:=(M_Val[7] + tv1 + tv2);
if	M_Val[7] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[7]:= (M_Val[7] MOD MULTI_INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
Result.M_Value[6]:= M_Val[6];
Result.M_Value[7]:= M_Val[7];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
and	(M_Val[6] = 0)
and	(M_Val[7] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_X4(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var
	M_Val	:array[0..Multi_X4_maxi] of MULTI_INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	M_Val[4]:= -1;
	M_Val[3]:= (M_Val[3] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

M_Val[4]:=(v1.M_Value[4] - v2.M_Value[4] + M_Val[4]);
if	M_Val[4] < 0 then
	begin
	M_Val[5]:= -1;
	M_Val[4]:= (M_Val[4] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

M_Val[5]:=(v1.M_Value[5] - v2.M_Value[5] + M_Val[5]);
if	M_Val[5] < 0 then
	begin
	M_Val[6]:= -1;
	M_Val[5]:= (M_Val[5] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

M_Val[6]:=(v1.M_Value[6] - v2.M_Value[6] + M_Val[6]);
if	M_Val[6] < 0 then
	begin
	M_Val[7]:= -1;
	M_Val[6]:= (M_Val[6] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

M_Val[7]:=(v1.M_Value[7] - v2.M_Value[7] + M_Val[7]);
if	M_Val[7] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
Result.M_Value[6]:= M_Val[6];
Result.M_Value[7]:= M_Val[7];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
and	(M_Val[6] = 0)
and	(M_Val[7] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X4.inc(const v1:Multi_Int_X4):Multi_Int_X4;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	Result:=add_Multi_Int_X4(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_X4(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_X4(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X4(v2,v1);
		Neg:= Multi_UBool_FALSE;
		end;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.+(const v1,v2:Multi_Int_X4):Multi_Int_X4;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	Result:=add_Multi_Int_X4(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_X4(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X4(v2,v1);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X4(v1,v2);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_X4(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X4(v1,v2);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X4(v2,v1);
			Neg:= Multi_UBool_FALSE;
			end;
		end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.-(const v1,v2:Multi_Int_X4):Multi_Int_X4;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	if	(v1.Negative_flag = TRUE) then
		begin
		if	ABS_greaterthan_Multi_Int_X4(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X4(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X4(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_X4(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X4(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X4(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_X4(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_X4(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.dec(const v1:Multi_Int_X4):Multi_Int_X4;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE) then
	begin
	if	ABS_greaterthan_Multi_Int_X4(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_X4(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X4(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_X4(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.-(const v1:Multi_Int_X4):Multi_Int_X4;
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(*******************v4*********************)
procedure multiply_Multi_Int_X4(const v1,v2:Multi_Int_X4;out Result:Multi_Int_X4); overload;
label	999;
var
M_Val		:array[0..Multi_X4_maxi_x2] of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,
jz,iz		:MULTI_INT_1W_S;
zf,
zero_mult	:boolean;
begin
Result:= 0;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_X4_maxi_x2);

zf:= FALSE;
i:= Multi_X4_maxi;
jz:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		jz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(jz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

zf:= FALSE;
i:= Multi_X4_maxi;
iz:= -1;
repeat
	if	(v1.M_Value[i] <> 0) then
		begin
		iz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(iz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

i:=0;
j:=0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		zero_mult:= TRUE;
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				zero_mult:= FALSE;
				tv1:=v1.M_Value[i];
				tv2:=v2.M_Value[j];
				M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
				M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
				end;
			INC(i);
		until (i > iz);
		if not zero_mult then
			begin
			k:=0;
			repeat
            	if (M_Val[k] <> 0) then
					begin
					M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
					M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
					end;
				INC(k);
			until (k > Multi_X4_maxi);
			end;
		i:=0;
        end;
	INC(j);
until (j > jz);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X4_maxi) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_X4_maxi_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_X4_maxi) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:
end;


(******************************************)
class operator Multi_Int_X4.*(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var	  R:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X4(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
function Multi_Int_X3_to_X4_multiply(const v1,v2:Multi_Int_X3):Multi_Int_X4;
var	  R:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X4(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;
end;


(****************************)
procedure SqRoot(const v1:Multi_Int_X4; out VR,VREM:Multi_Int_X4);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X4;
finished		:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Dec');
		end;
	exit;
	end;

if	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('SqRoot is Negative_flag');
		end;
	exit;
	end;

D:= length(v1.ToStr);
D2:= D div 2;
if ((D mod 2)=0) then
	begin
	LS:= '1' + AddCharR('0','',D2-1);
	HS:= '1' + AddCharR('0','',D2);
	H:= HS;
	L:= LS;
	end
else
	begin
	LS:= '1' + AddCharR('0','',D2);
	HS:= '1' + AddCharR('0','',D2+1);
	H:= HS;
	L:= LS;
	end;

finished:= FALSE;
while not finished do
	begin
    T:= subtract_Multi_Int_X4(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X4(L,T);
    multiply_Multi_Int_X4(C,C, CC);

	if	(CC.Overflow)
	or	ABS_greaterthan_Multi_Int_X4(CC,v1)
	then
		begin
		if ABS_lessthan_Multi_Int_X4(C,H) then
			H:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			// multiply_Multi_Int_X4(C,C, T);
			// VREM:= subtract_Multi_Int_X4(v1,T);
			VREM:= 0;
			end
		end
	else if ABS_lessthan_Multi_Int_X4(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X4(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			multiply_Multi_Int_X4(C,C, T);
			VREM:= subtract_Multi_Int_X4(v1,T);
			end
		end
	else
		begin
		VREM:= 0;
		finished:= TRUE;
		end;
	end;

VR:= C;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;
end;


(********************v3********************)
{ Function exp_by_squaring_iterative(TV, P) }

class operator Multi_Int_X4.**(const v1:Multi_Int_X4; const P:MULTI_INT_2W_S):Multi_Int_X4;
var
Y,TV,T,R	:Multi_Int_X4;
PT			:MULTI_INT_2W_S;
begin
PT:= P;
TV:= v1;
if	(PT < 0) then R:= 0
else if	(PT = 0) then R:= 1
else
	begin
	Y := 1;
	while (PT > 1) do
		begin
		if	odd(PT) then
			begin
			multiply_Multi_Int_X4(TV,Y, T);
			if	(T.Overflow_flag)
			then
				begin
				Result:= 0;
				Result.Defined_flag:= FALSE;
				Result.Overflow_flag:= TRUE;
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Power');
					end;
				exit;
				end;
			if	(T.Negative_flag = Multi_UBool_UNDEF) then
				if	(TV.Negative_flag = Y.Negative_flag)
				then T.Negative_flag:= Multi_UBool_FALSE
				else T.Negative_flag:= Multi_UBool_TRUE;

			Y:= T;
			PT := PT - 1;
			end;
		multiply_Multi_Int_X4(TV,TV, T);
		if	(T.Overflow_flag)
		then
			begin
			Result:= 0;
			Result.Defined_flag:= FALSE;
			Result.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Power');
				end;
			exit;
			end;
		T.Negative_flag:= Multi_UBool_FALSE;

		TV:= T;
		PT := (PT div 2);
		end;
{$WARNINGS OFF} {$HINTS OFF}
	multiply_Multi_Int_X4(TV,Y, R);

	if	(R.Overflow_flag)
	then
		begin
		Result:= 0;
		Result.Defined_flag:= FALSE;
		Result.Overflow_flag:= TRUE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on Power');
			end;
		exit;
		end;
	if	(R.Negative_flag = Multi_UBool_UNDEF) then
		if	(TV.Negative_flag = Y.Negative_flag)
		then R.Negative_flag:= Multi_UBool_FALSE
		else R.Negative_flag:= Multi_UBool_TRUE;
	end;

Result:= R;
end;


(********************v1********************)
procedure intdivide_taylor_warruth_X4(const P_dividend,P_dividor:Multi_Int_X4;out P_quotient,P_remainder:Multi_Int_X4);
label	AGAIN,9000,9999;
var
dividor,
quotient,
dividend,
next_dividend	:Multi_Int_X5;

dividend_i,
dividend_i_1,
quotient_i,
dividor_i,
dividor_i_1,
dividor_non_zero_pos,
shiftup_bits_dividor,
i				:MULTI_INT_1W_S;

t_word			:MULTI_INT_1W_U;

adjacent_word_dividend,
adjacent_word_division,
word_division,
word_dividend,
word_carry,
next_word_carry
				:MULTI_INT_2W_U;

finished		:boolean;

begin
dividend:= 0;
next_dividend:= 0;
dividor:= 0;
quotient:= 0;
P_quotient:= 0;
P_remainder:= 0;

if	(P_dividor = 0) then
	begin
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_dividor = P_dividend) then
	begin
	P_quotient:= 1;
    end
else
	begin
	if	(Abs(P_dividor) > Abs(P_dividend)) then
		begin
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	dividor_non_zero_pos:= 0;
    i:= Multi_X4_maxi;
	while (i >= 0) do
		begin
		t_word:= P_dividor.M_Value[i];
		dividor.M_Value[i]:= t_word;
		if	(dividor_non_zero_pos = 0) then
			if	(t_word <> 0) then
				dividor_non_zero_pos:= i;
		Dec(i);
		end;
	dividor.Negative_flag:= FALSE;
    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	// essential short-cut for single word dividor
	if	(dividor_non_zero_pos = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		word_carry:= 0;
		i:= Multi_X4_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto 9000;
		end;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X5(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X5(dividor, shiftup_bits_dividor);
		end;

	next_word_carry:= 0;
	word_carry:= 0;
	dividor_i:= dividor_non_zero_pos;
	dividor_i_1:= (dividor_i - 1);
	dividend_i:= (Multi_X4_maxi + 1);
	finished:= FALSE;
	while (not finished) do
	    if (dividend_i >= 0) then
		    if (dividend.M_Value[dividend_i] = 0) then
				Dec(dividend_i)
			else finished:= TRUE
		else finished:= TRUE
		;
	quotient_i:= (dividend_i - dividor_non_zero_pos);

	while	(dividend >= 0)
	and		(quotient_i >= 0)
	do
		begin
		word_dividend:= ((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i]);
        word_division:= (word_dividend div dividor.M_Value[dividor_i]);
        next_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((next_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					next_word_carry:= next_word_carry + dividor.M_Value[dividor_i];
					if (next_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;
			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				end;
			P_quotient.M_Value[quotient_i]:= word_division;
            dividend:= next_dividend;
            word_carry:= dividend.M_Value[dividend_i];
			end
		else
			begin
            word_carry:= word_dividend;
			end;

		Dec(dividend_i);
		quotient_i:= (dividend_i - dividor_non_zero_pos);
		end; { while }

	ShiftDown_MultiBits_Multi_Int_X5(dividend, shiftup_bits_dividor);
	P_remainder:= To_Multi_Int_X4(dividend);

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;
9999:
end;


(******************************************)
class operator Multi_Int_X4.div(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var
	Remainder,
	Quotient	:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

// same values as last time

if	(X4_Last_Divisor = v2)
and	(X4_Last_Dividend = v1)
then
	Result:= X4_Last_Quotient
else	// different values than last time
	begin
	intdivide_taylor_warruth_X4(v1,v2,Quotient,Remainder);

	X4_Last_Divisor:= v2;
	X4_Last_Dividend:= v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

if	(X4_Last_Remainder.Overflow_flag)
or	(X4_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X4.mod(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var
Remainder,
Quotient	:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on modulus');
		end;
	exit;
	end;

// same values as last time

if	(X4_Last_Divisor = v2)
and	(X4_Last_Dividend = v1)
then
	Result:= X4_Last_Remainder
else	// different values than last time
	begin
	intdivide_taylor_warruth_X4(v1,v2,Quotient,Remainder);

	X4_Last_Divisor:= v2;
	X4_Last_Dividend:= v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;

if	(X4_Last_Remainder.Overflow_flag)
or	(X4_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


{
******************************************
Multi_Int_X5  INTERNAL USE ONLY!
******************************************
}


(******************************************)
function ABS_greaterthan_Multi_Int_X5(const v1,v2:Multi_Int_X5):Boolean;
begin
if	(v1.M_Value[8] > v2.M_Value[8])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[8] < v2.M_Value[8])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[7] > v2.M_Value[7])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[7] < v2.M_Value[7])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[6] > v2.M_Value[6])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[6] < v2.M_Value[6])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[5] > v2.M_Value[5])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[5] < v2.M_Value[5])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[4] > v2.M_Value[4])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[4] < v2.M_Value[4])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[3] > v2.M_Value[3])
										then begin Result:=TRUE; exit; end
										else
											if	(v1.M_Value[3] < v2.M_Value[3])
											then begin Result:=FALSE; exit; end
											else
												if	(v1.M_Value[2] > v2.M_Value[2])
												then begin Result:=TRUE; exit; end
												else
													if	(v1.M_Value[2] < v2.M_Value[2])
													then begin Result:=FALSE; exit; end
													else
														if	(v1.M_Value[1] > v2.M_Value[1])
														then begin Result:=TRUE; exit; end
														else
															if	(v1.M_Value[1] < v2.M_Value[1])
															then begin Result:=FALSE; exit; end
															else
																if	(v1.M_Value[0] > v2.M_Value[0])
																then begin Result:=TRUE; exit; end
																else begin Result:=FALSE; exit; end;
end;


(******************************************)
function ABS_lessthan_Multi_Int_X5(const v1,v2:Multi_Int_X5):Boolean;
begin
if	(v1.M_Value[8] < v2.M_Value[8])
then begin Result:=TRUE; exit; end
else
	if	(v1.M_Value[8] > v2.M_Value[8])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[7] < v2.M_Value[7])
		then begin Result:=TRUE; exit; end
		else
			if	(v1.M_Value[7] > v2.M_Value[7])
			then begin Result:=FALSE; exit; end
			else
				if	(v1.M_Value[6] < v2.M_Value[6])
				then begin Result:=TRUE; exit; end
				else
					if	(v1.M_Value[6] > v2.M_Value[6])
					then begin Result:=FALSE; exit; end
					else
						if	(v1.M_Value[5] < v2.M_Value[5])
						then begin Result:=TRUE; exit; end
						else
							if	(v1.M_Value[5] > v2.M_Value[5])
							then begin Result:=FALSE; exit; end
							else
								if	(v1.M_Value[4] < v2.M_Value[4])
								then begin Result:=TRUE; exit; end
								else
									if	(v1.M_Value[4] > v2.M_Value[4])
									then begin Result:=FALSE; exit; end
									else
										if	(v1.M_Value[3] < v2.M_Value[3])
										then begin Result:=TRUE; exit; end
										else
											if	(v1.M_Value[3] > v2.M_Value[3])
											then begin Result:=FALSE; exit; end
											else
												if	(v1.M_Value[2] < v2.M_Value[2])
												then begin Result:=TRUE; exit; end
												else
													if	(v1.M_Value[2] > v2.M_Value[2])
													then begin Result:=FALSE; exit; end
													else
														if	(v1.M_Value[1] < v2.M_Value[1])
														then begin Result:=TRUE; exit; end
														else
															if	(v1.M_Value[1] > v2.M_Value[1])
															then begin Result:=FALSE; exit; end
															else
																if	(v1.M_Value[0] < v2.M_Value[0])
																then begin Result:=TRUE; exit; end
																else begin Result:=FALSE; exit; end;
end;


(******************************************)
function Multi_Int_X5.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
class operator Multi_Int_X5.>(const v1,v2:Multi_Int_X5):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= ABS_greaterthan_Multi_Int_X5(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_X5(v1,v2);
end;


(******************************************)
class operator Multi_Int_X5.>=(const v1,v2:Multi_Int_X5):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_lessthan_Multi_Int_X5(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_X5(v1,v2) );
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);

{$Q-}
{$R-}
carry_bits_mask:= (carry_bits_mask << NBits_carry);
{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] << NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[6] and carry_bits_mask) >> NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] << NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[7] and carry_bits_mask) >> NBits_carry);
v1.M_Value[7]:= ((v1.M_Value[7] << NBits) OR carry_bits_1);

v1.M_Value[8]:= ((v1.M_Value[8] << NBits) OR carry_bits_2);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_2:= ((v1.M_Value[8] and carry_bits_mask) << NBits_carry);
v1.M_Value[8]:= (v1.M_Value[8] >> NBits);

carry_bits_1:= ((v1.M_Value[7] and carry_bits_mask) << NBits_carry);
v1.M_Value[7]:= ((v1.M_Value[7] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[6] and carry_bits_mask) << NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[5] and carry_bits_mask) << NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[4] and carry_bits_mask) << NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] >> NBits) OR carry_bits_2);

carry_bits_2:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_1);

carry_bits_1:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_2);

v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_1);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X5(Var v1:Multi_Int_X5; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X5_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[6];
		v1.M_Value[6]:= v1.M_Value[7];
		v1.M_Value[7]:= v1.M_Value[8];
		v1.M_Value[8]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X5(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X5(v1, NBits_count);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X5(const v1:MULTI_INT_2W_U; out mi:Multi_Int_X5);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;
mi.M_Value[8]:= 0;
end;


(******************************************)
class operator Multi_Int_X5.:=(const v1:MULTI_INT_2W_U):Multi_Int_X5;
begin
MULTI_INT_2W_U_to_Multi_Int_X5(v1,Result);
end;


(******************************************)
procedure Multi_Int_X4_to_Multi_Int_X5(const v1:Multi_Int_X4; var MI:Multi_Int_X5);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X4_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X5_max) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X5.:=(const v1:Multi_Int_X4):Multi_Int_X5;
begin
Multi_Int_X4_to_Multi_Int_X5(v1,Result);
end;


(******************************************)
function To_Multi_Int_X5(const v1:Multi_Int_X4):Multi_Int_X5;
begin
Multi_Int_X4_to_Multi_Int_X5(v1,Result);
end;


(******************************************)
function To_Multi_Int_X4(const v1:Multi_Int_X5):Multi_Int_X4; overload;
var n :MULTI_INT_1W_U;
begin
Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	Result.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
or	(v1 > Multi_Int_X4_MAXINT)
then
	begin
	Result.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= 0;
while (n <= Multi_X4_maxi) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(*******************v4*********************)
procedure multiply_Multi_Int_X5(const v1,v2:Multi_Int_X5;out Result:Multi_Int_X5); overload;
label	999;
var
M_Val		:array[0..Multi_X5_max_x2] of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,
jz,iz		:MULTI_INT_1W_S;
zf,
zero_mult	:boolean;
begin
Result:= 0;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_X5_max_x2);

zf:= FALSE;
i:= Multi_X5_max;
jz:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		jz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(jz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

zf:= FALSE;
i:= Multi_X5_max;
iz:= -1;
repeat
	if	(v1.M_Value[i] <> 0) then
		begin
		iz:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(iz < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

i:=0;
j:=0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		zero_mult:= TRUE;
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				zero_mult:= FALSE;
				tv1:=v1.M_Value[i];
				tv2:=v2.M_Value[j];
				M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
				M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
				end;
			INC(i);
		until (i > iz);
		if not zero_mult then
			begin
			k:=0;
			repeat
            	if (M_Val[k] <> 0) then
					begin
					M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
					M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
					end;
				INC(k);
			until (k > Multi_X5_max);
			end;
		i:=0;
        end;
	INC(j);
until (j > jz);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X5_max) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_X5_max_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_X5_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:
end;


(******************************************)
class operator Multi_Int_X5.*(const v1,v2:Multi_Int_X5):Multi_Int_X5;
var	  R:Multi_Int_X5;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X5(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
function Multi_Int_X4_to_X5_multiply(const v1,v2:Multi_Int_X4):Multi_Int_X5;
var	  R:Multi_Int_X5;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

multiply_Multi_Int_X5(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;
end;


(******************************************)
function add_Multi_Int_X5(const v1,v2:Multi_Int_X5):Multi_Int_X5;
var
	tv1,
	tv2		:MULTI_INT_2W_U;
	M_Val	:array[0..Multi_X5_max] of MULTI_INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[4]:= (M_Val[3] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[3]:= (M_Val[3] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

tv1:= v1.M_Value[4];
tv2:= v2.M_Value[4];
M_Val[4]:=(M_Val[4] + tv1 + tv2);
if	M_Val[4] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[4] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[4]:= (M_Val[4] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

tv1:= v1.M_Value[5];
tv2:= v2.M_Value[5];
M_Val[5]:=(M_Val[5] + tv1 + tv2);
if	M_Val[5] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[6]:= (M_Val[5] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[5]:= (M_Val[5] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

tv1:= v1.M_Value[6];
tv2:= v2.M_Value[6];
M_Val[6]:=(M_Val[6] + tv1 + tv2);
if	M_Val[6] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[7]:= (M_Val[6] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[6]:= (M_Val[6] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

tv1:= v1.M_Value[7];
tv2:= v2.M_Value[7];
M_Val[7]:=(M_Val[7] + tv1 + tv2);
if	M_Val[7] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[8]:= (M_Val[7] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[7]:= (M_Val[7] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[8]:= 0;

tv1:= v1.M_Value[8];
tv2:= v2.M_Value[8];
M_Val[8]:=(M_Val[8] + tv1 + tv2);
if	M_Val[8] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[8]:= (M_Val[8] MOD MULTI_INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
Result.M_Value[6]:= M_Val[6];
Result.M_Value[7]:= M_Val[7];
Result.M_Value[8]:= M_Val[8];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
and	(M_Val[6] = 0)
and	(M_Val[7] = 0)
and	(M_Val[8] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_X5(const v1,v2:Multi_Int_X5):Multi_Int_X5;
var
	M_Val	:array[0..Multi_X5_max] of MULTI_INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	M_Val[4]:= -1;
	M_Val[3]:= (M_Val[3] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

M_Val[4]:=(v1.M_Value[4] - v2.M_Value[4] + M_Val[4]);
if	M_Val[4] < 0 then
	begin
	M_Val[5]:= -1;
	M_Val[4]:= (M_Val[4] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

M_Val[5]:=(v1.M_Value[5] - v2.M_Value[5] + M_Val[5]);
if	M_Val[5] < 0 then
	begin
	M_Val[6]:= -1;
	M_Val[5]:= (M_Val[5] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

M_Val[6]:=(v1.M_Value[6] - v2.M_Value[6] + M_Val[6]);
if	M_Val[6] < 0 then
	begin
	M_Val[7]:= -1;
	M_Val[6]:= (M_Val[6] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

M_Val[7]:=(v1.M_Value[7] - v2.M_Value[7] + M_Val[7]);
if	M_Val[7] < 0 then
	begin
	M_Val[8]:= -1;
	M_Val[7]:= (M_Val[7] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[8]:= 0;

M_Val[8]:=(v1.M_Value[8] - v2.M_Value[8] + M_Val[8]);
if	M_Val[8] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
Result.M_Value[6]:= M_Val[6];
Result.M_Value[7]:= M_Val[7];
Result.M_Value[8]:= M_Val[8];

if	(M_Val[0] = 0)
and	(M_Val[1] = 0)
and	(M_Val[2] = 0)
and	(M_Val[3] = 0)
and	(M_Val[4] = 0)
and	(M_Val[5] = 0)
and	(M_Val[6] = 0)
and	(M_Val[7] = 0)
and	(M_Val[8] = 0)
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_X5.-(const v1,v2:Multi_Int_X5):Multi_Int_X5;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	if	(v1.Negative_flag = TRUE) then
		begin
		if	ABS_greaterthan_Multi_Int_X5(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X5(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X5(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_X5(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X5(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X5(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_X5(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_X5(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


{
******************************************
Multi_Int_XV
******************************************
}

(******************************************)
procedure Multi_Int_XV.init;
begin
self.Defined_flag:= FALSE;
if	(Multi_Init_Initialisation_count = 0) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_Init_Initialisation has not been called');
	exit;
	end;
if (Multi_XV_size < 2) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_XV_size must be > 1');
	exit;
	end;
setlength(self.M_Value, Multi_XV_size);
self.M_Value_Size:= Multi_XV_size;
self.Negative_flag:= Multi_UBool_FALSE;
self.Overflow_flag:= FALSE;
self.Defined_flag:= FALSE;
end;


(******************************************)
procedure Multi_Int_XV_to_Multi_Int_XV(const v1:Multi_Int_XV; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
MI.init;
if (v1.M_Value_Size > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(MI, Multi_XV_size);
	if	(mi.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		mi.Defined_flag:=FALSE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

n:= 0;
while (n < v1.M_Value_Size) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n < MI.M_Value_Size) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
{
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Multi_Int_XV;
begin
Multi_Int_XV_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_XV):Multi_Int_XV;
begin
Multi_Int_XV_to_Multi_Int_XV(v1,Result);
end;
}


(******************************************)
procedure Multi_Int_Set_XV_Limit(const S:MULTI_INT_1W_U);
begin
if (S > Multi_XV_size) then Multi_XV_limit:= S
else
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_XV_limit must be > Multi_XV_size');
	exit;
	end;
end;


(******************************************)
function Multi_Int_XV_Limit:MULTI_INT_1W_U;
begin
Result:= Multi_XV_limit;
end;


(******************************************)
procedure Multi_Int_Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_1W_U);
begin
if	(S < 2) then
	begin
	v1.Defined_flag:= FALSE;
	v1.Overflow_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	{
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_XV_size must be > 1');
	}
	exit;
	end;
if	(S > Multi_XV_limit) then
	begin
	// v1.Defined_flag:= FALSE;
	v1.Overflow_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	{
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow on Multi_Int_Reset_XV_Size');
	}
	exit;
	end;
setlength(v1.M_Value, S);
v1.M_Value_Size:= S;
if	(S < v1.M_Value_Size) then
	begin
	v1.Negative_flag:= Multi_UBool_UNDEF;
	v1.Overflow_flag:= FALSE;
	v1.Defined_flag:= FALSE;
	end;
end;


(******************************************)
function ABS_greaterthan_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
i1,i2	:MULTI_INT_1W_S;

begin
i1:= (v1.M_Value_Size - 1);
i2:= (v2.M_Value_Size - 1);

while (i1 > i2) do
	begin
	if	(v1.M_Value[i1] > 0) then
		begin Result:=TRUE; exit; end;
	dec(i1);
	end;

while (i2 > i1) do
	begin
	if	(v2.M_Value[i2] > 0) then
		begin Result:=FALSE; exit; end;
	dec(i2);
	end;

while (i2 > 0) do
	begin
	if	(v1.M_Value[i2] > v2.M_Value[i2])
	then begin Result:=TRUE; exit; end
	else
		if	(v1.M_Value[i2] < v2.M_Value[i2])
		then begin Result:=FALSE; exit; end;
	dec(i2);
	end;

if	(v1.M_Value[0] > v2.M_Value[0])
then begin Result:=TRUE; exit; end
else begin Result:=FALSE; exit; end;

end;


(******************************************)
function ABS_lessthan_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
i1,i2	:MULTI_INT_1W_S;

begin
i1:= (v1.M_Value_Size - 1);
i2:= (v2.M_Value_Size - 1);

while (i1 > i2) do
	begin
	if	(v1.M_Value[i1] > 0) then
		begin Result:=FALSE; exit; end;
	dec(i1);
	end;

while (i2 > i1) do
	begin
	if	(v2.M_Value[i2] > 0) then
		begin Result:=TRUE; exit; end;
	dec(i2);
	end;

while (i2 > 0) do
	begin
	if	(v1.M_Value[i2] > v2.M_Value[i2])
	then begin Result:=FALSE; exit; end
	else
		if	(v1.M_Value[i2] < v2.M_Value[i2])
		then begin Result:=TRUE; exit; end;
	dec(i2);
	end;

if	(v1.M_Value[0] < v2.M_Value[0])
then begin Result:=TRUE; exit; end
else begin Result:=FALSE; exit; end;

end;


(******************************************)
function nlz_words_XV(const V:Multi_Int_XV):MULTI_INT_1W_U; // v2
var
i,n		:Multi_int32;
fini	:boolean;
begin
n:= 0;
i:= (V.M_Value_Size - 1);
fini:= false;
repeat
	if	(i < 0) then fini:= true
	else if	(V.M_Value[i] <> 0) then fini:= true
	else
		begin
		INC(n);
		DEC(i);
		end;
until fini;
Result:= n;
end;


(******************************************)
function nlz_MultiBits_XV(const v1:Multi_Int_XV):MULTI_INT_1W_U;
var	w	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

w:= nlz_words_XV(v1);
if (w < v1.M_Value_Size)
then Result:= nlz_bits(v1.M_Value[v1.M_Value_Size-w-1]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
function Multi_Int_XV.Overflow:boolean;
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_XV.Defined:boolean;
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_XV):boolean; overload;
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_XV):boolean; overload;
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_XV.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_XV):boolean; overload;
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_XV):Multi_Int_XV; overload;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;
end;


(******************************************)
function Multi_Int_XV_Odd(const v1:Multi_Int_XV):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= TRUE
else Result:= FALSE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Odd(const v1:Multi_Int_XV):boolean; overload;
begin
Result:= Multi_Int_XV_Odd(v1);
end;


(******************************************)
function Multi_Int_XV_Even(const v1:Multi_Int_XV):boolean;
var	bit1_mask	:MULTI_INT_1W_U;
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
bit1_mask:= $1;
{$endif}
{$ifdef 64bit}
bit1_mask:= $1;
{$endif}

if ((v1.M_Value[0] and bit1_mask) = bit1_mask)
then Result:= FALSE
else Result:= TRUE;

if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
function Even(const v1:Multi_Int_XV):boolean; overload;
begin
Result:= Multi_Int_XV_Even(v1);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
	n			:MULTI_INT_1W_U;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);

{$Q-}
{$R-}
carry_bits_mask:= (carry_bits_mask << NBits_carry);
{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[0]:= (v1.M_Value[0] << NBits);

	n:=1;
	while (n < (v1.M_Value_Size-1)) do
		begin
		carry_bits_2:= ((v1.M_Value[n] and carry_bits_mask) >> NBits_carry);
		v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);
		carry_bits_1:= carry_bits_2;
		inc(n);
		end;

	v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);

	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftUp_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_1W_U);
var	n,i	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_XV_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=(v1.M_Value_Size - 1);
		while (i > 0) do
			begin
			v1.M_Value[i]:= v1.M_Value[i-1];
			dec(i);
			end;
		v1.M_Value[i]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftUp_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_XV(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_XV(v1, NBits_count);
	end;
end;


{******************************************}
procedure ShiftUp(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_XV(v1, NBits);
end;


{******************************************}
class operator Multi_Int_XV.shl(const v1:Multi_Int_XV; const NBits:MULTI_INT_1W_U):Multi_Int_XV;
begin
// Result:= v1;								// this causes problems in calling code
Multi_Int_XV_to_Multi_Int_XV(v1, Result);	// if not done, causes problems in calling code
ShiftUp_MultiBits_Multi_Int_XV(Result, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
	n			:integer;
begin
if NBits > 0 then
begin

{$ifdef Overflow_Checks}
{$Q-}
{$R-}
{$endif}

{$ifdef 32bit}
carry_bits_mask:= $FFFF;
{$endif}
{$ifdef 64bit}
carry_bits_mask:= $FFFFFFFF;
{$endif}

NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
	begin
	n:= (v1.M_Value_Size - 1);
	carry_bits_1:= ((v1.M_Value[n] and carry_bits_mask) << NBits_carry);
	v1.M_Value[n]:= (v1.M_Value[n] >> NBits);

	dec(n);
	while (n > 0) do
		begin
		carry_bits_2:= ((v1.M_Value[n] and carry_bits_mask) << NBits_carry);
		v1.M_Value[n]:= ((v1.M_Value[n] >> NBits) OR carry_bits_1);
		carry_bits_1:= carry_bits_2;
		dec(n);
		end;

	v1.M_Value[n]:= ((v1.M_Value[n] >> NBits) OR carry_bits_1);
	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_1W_U);
var	n,i	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_XV_maxi) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=0;
		while (i < (v1.M_Value_Size - 1)) do
			begin
			v1.M_Value[i]:= v1.M_Value[i+1];
			inc(i);
			end;
		v1.M_Value[i]:= 0;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if	(Not v1.Defined_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_XV(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_XV(v1, NBits_count);
end;


{******************************************}
procedure ShiftDown(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_XV(v1, NBits);
end;


{******************************************}
class operator Multi_Int_XV.shr(const v1:Multi_Int_XV; const NBits:MULTI_INT_1W_U):Multi_Int_XV;
begin
// Result:= v1;								// this causes problems in calling code
Multi_Int_XV_to_Multi_Int_XV(v1, Result);	// if not done, causes problems in calling code
ShiftDown_MultiBits_Multi_Int_XV(Result, NBits);
end;


(******************************************)
class operator Multi_Int_XV.>(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= ABS_greaterthan_Multi_Int_XV(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_XV(v1,v2);
end;


(******************************************)
class operator Multi_Int_XV.<(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
	then Result:= ABS_lessthan_Multi_Int_XV(v1,v2)
	else
		if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
		then Result:= ABS_greaterthan_Multi_Int_XV(v1,v2);
end;


(******************************************)
function ABS_equal_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
i1,i2	:MULTI_INT_1W_S;

begin
Result:=TRUE;
i1:= (v1.M_Value_Size - 1);
i2:= (v2.M_Value_Size - 1);
while (i1 > i2) do
	begin
	if	(v1.M_Value[i1] > 0) then
		begin Result:=FALSE; exit; end;
	Dec(i1);
	end;
while (i2 > i1) do
	begin
	if	(v2.M_Value[i2] > 0) then
		begin Result:=FALSE; exit; end;
	Dec(i2);
	end;
while (i2 >= 0) do
	begin
	if	(v1.M_Value[i2] <> v2.M_Value[i2]) then
		begin Result:=FALSE; exit; end;
	Dec(i2);
	end;
end;


(******************************************)
function ABS_notequal_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.=(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_XV(v1,v2);
end;


(******************************************)
class operator Multi_Int_XV.<>(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.<=(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=FALSE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=TRUE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_greaterthan_Multi_Int_XV(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_lessthan_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.>=(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:=FALSE;
if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE) )
then Result:=TRUE
else
	if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = FALSE) )
	then Result:=FALSE
	else
		if ( (v1.Negative_flag = FALSE) and (v2.Negative_flag = FALSE) )
		then Result:= (Not ABS_lessthan_Multi_Int_XV(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_XV(v1,v2) );
end;


(******************************************)
procedure ansistring_to_Multi_Int_XV(const v1:ansistring; out mi:Multi_Int_XV);
label 999;
var
	n,i,b,c,e,s	:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;
s:= Multi_XV_size;
setlength(M_Val, s);
mi:= 0;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n < s)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try	i:=strtoint(v1[c]);
			except
				on EConvertError do
					begin
					mi.Defined_flag:= FALSE;
					mi.Overflow_flag:=TRUE;
					Multi_Int_ERROR:= TRUE;
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 10) + i;
		n:=1;
		while (n < s) do
			begin
			M_Val[n]:=(M_Val[n] * 10);
			inc(n);
			end;

		n:=0;
		while (n < (s-1)) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			Inc(s);
			setlength(M_Val, s);
			M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
			end;
		Inc(c);
		end;
	end;

if (s > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(mi,s);
	if (mi.Overflow) then
		begin
		mi.Defined_flag:= FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EInterror.create('Overflow');
			end;
		goto 999;
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n < s) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;

if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:ansistring):Multi_Int_XV;
begin
ansistring_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_XV_to_ansistring(const v1:Multi_Int_XV; var v2:ansistring);
var
	s			:ansistring = '';
	M_Val		:array of MULTI_INT_2W_U;
	n,t			:MULTI_INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

setlength(M_Val, v1.M_Value_Size);

n:=0;
while (n < v1.M_Value_Size) do
	begin
	t:= v1.M_Value[n];
	M_Val[n]:= t;
	inc(n);
	end;

repeat
	n:= (v1.M_Value_Size - 1);
	M_Val_All_Zero:= TRUE;
	repeat
		M_Val[n-1]:= M_Val[n-1] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[n] MOD 10));
		M_Val[n]:= (M_Val[n] DIV 10);
		if M_Val[n] <> 0 then M_Val_All_Zero:= FALSE;
		dec(n);
	until	(n = 0);

	s:= inttostr(M_Val[0] MOD 10) + s;
		M_Val[0]:= (M_Val[0] DIV 10);
	if M_Val[0] <> 0 then M_Val_All_Zero:= FALSE;

until M_Val_All_Zero;

if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
v2:=s;
end;


(******************************************)
function Multi_Int_XV.ToStr:ansistring;
begin
Multi_Int_XV_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):ansistring;
begin
Multi_Int_XV_to_ansistring(v1, Result);
end;


(******************************************)
procedure hex_to_Multi_Int_XV(const v1:ansistring; out mi:Multi_Int_XV);
label 999;
var
	n,i,b,c,e,s	:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;
s:= Multi_XV_size;
setlength(M_Val, s);
mi:= 0;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n < s)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		try
			i:=Hex2Dec(v1[c]);
			except
				Multi_Int_ERROR:= TRUE;
				mi.Overflow_flag:=TRUE;
				mi.Defined_flag:= FALSE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					Raise;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n < s) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < (s-1)) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			Inc(s);
			setlength(M_Val, s);
			M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		Inc(c);
		end;
	end;

if (s > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(mi,s);
	if (mi.Overflow) then
		begin
		mi.Defined_flag:= FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EInterror.create('Overflow');
			end;
		goto 999;
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n < s) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function Hex_to_Multi_Int_XV(const v1:ansistring):Multi_Int_XV;
begin
hex_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function Multi_Int_XV.FromHex(const v1:ansistring):Multi_Int_XV;
begin
hex_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_XV); overload;
begin
hex_to_Multi_Int_XV(v1,v2);
end;


(******************************************)
procedure Multi_Int_XV_to_hex(const v1:Multi_Int_XV; var v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	i,n		:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

// The "4" here looks suspicious, but it is not!
// It is the size in bits of a nibble (half-byte).

n:= (MULTI_INT_1W_SIZE div 4);
s:= '';

i:= (v1.M_Value_Size - 1);
while (i >= 0) do
	begin
	s:= s + IntToHex(v1.M_Value[i],n);
	dec(i);
	end;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_XV.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_XV_to_hex(self, Result, LZ);
end;


(******************************************)
procedure Bin_to_Multi_Int_XV(const v1:ansistring; out mi:Multi_Int_XV);
label 999;
var
	n,b,c,e,s	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;
s:= Multi_XV_size;
setlength(M_Val, s);
mi:= 0;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n < s)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(ansistring);
	e:=b + MULTI_INT_2W_U(length(v1)) - 1;
	if	(v1[b] = '-') then
		begin
		Signeg:= TRUE;
		INC(b);
		end;

	c:= b;
	while (c <= e) do
		begin
		bit:= (ord(v1[c]) - ord('0'));
		if	(bit > 1)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			goto 999;
			end;

		M_Val[0]:=(M_Val[0] * 2) + bit;
		n:=1;
		while (n < s) do
			begin
			M_Val[n]:=(M_Val[n] * 2);
			inc(n);
			end;

		n:=0;
		while (n < (s-1)) do
			begin
			if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
			begin
			Inc(s);
			setlength(M_Val, s);
			M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
			M_Val[n]:=(M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
			end;

		Inc(c);
		end;
	end;

if (s > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(mi,s);
	if (mi.Overflow) then
		begin
		mi.Defined_flag:= FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EInterror.create('Overflow');
			end;
		goto 999;
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n < s) do
	begin
	mi.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;
if M_Val_All_Zero then Zeroneg:= TRUE;

if Zeroneg then mi.Negative_flag:= Multi_UBool_FALSE
else if Signeg then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

999:
end;


(******************************************)
function Bin_to_Multi_Int_XV(const v1:ansistring):Multi_Int_XV;
begin
Bin_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_XV); overload;
begin
Bin_to_Multi_Int_XV(v1,mi);
end;


(******************************************)
function Multi_Int_XV.FromBin(const v1:ansistring):Multi_Int_XV;
begin
bin_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_XV_to_bin(const v1:Multi_Int_XV; var v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	i,n		:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	v2:='UNDEFINED';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	v2:='OVERFLOW';
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

n:= MULTI_INT_1W_SIZE;
s:= '';

i:= (v1.M_Value_Size - 1);
while (i >= 0) do
	begin
	s:= s + IntToBin(v1.M_Value[i],n);
	dec(i);
	end;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
if	(s = '') then s:= '0';
v2:=s;
end;


(******************************************)
function Multi_Int_XV.ToBin(const LZ:T_Multi_Leading_Zeros):ansistring;
begin
Multi_Int_XV_to_bin(self, Result, LZ);
end;


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_XV(const v1:MULTI_INT_2W_S; out mi:Multi_Int_XV);
var
	n				:MULTI_INT_2W_U;
begin
mi.init;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;

n:=2;
while (n <= Multi_XV_maxi) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_2W_S):Multi_Int_XV;
begin
MULTI_INT_2W_S_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_XV(const v1:MULTI_INT_2W_U; out mi:Multi_Int_XV);
var
	n				:MULTI_INT_2W_U;
begin
mi.init;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);

n:=2;
while (n <= Multi_XV_maxi) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_2W_U):Multi_Int_XV;
begin
MULTI_INT_2W_U_to_Multi_Int_XV(v1,Result);
end;


{$ifdef 32bit}
// The fact that thse routines only exist in 32bit mode looks suspicious.
// But it is not! These are dealing with 64bit integers in 32bit mode, which are 4 words in size)
// 4 word integers do not exist in 64bit mode

(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_XV(const v1:MULTI_INT_4W_S; var mi:Multi_Int_XV);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.init;
if (mi.M_Value_Size < 4) then
	begin
	Multi_Int_Reset_XV_Size(MI, 4);
	if	(mi.Overflow) then
		begin
		mi.Defined_flag:=FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;

v:= Abs(v1);
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

n:=4;
while (n <= Multi_XV_maxi) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_4W_S):Multi_Int_XV;
begin
MULTI_INT_4W_S_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_XV(const v1:MULTI_INT_4W_U; var mi:Multi_Int_XV);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.init;
if (mi.M_Value_Size < 4) then
	begin
	Multi_Int_Reset_XV_Size(MI, 4);
	if	(mi.Overflow) then
		begin
		mi.Defined_flag:=FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

v:= v1;
mi.M_Value[0]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[2]:= MULTI_INT_1W_U(v MOD MULTI_INT_1W_U_MAXINT_1);
v:= (v div MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[3]:= v;

n:=4;
while (n <= Multi_XV_maxi) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_4W_U):Multi_Int_XV;
begin
MULTI_INT_4W_U_to_Multi_Int_XV(v1,Result);
end;
{$endif}


(******************************************)
procedure Multi_Int_X4_to_Multi_Int_XV(const v1:Multi_Int_X4; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
MI.init;
if (Multi_X4_size > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(MI, Multi_X4_size);
	if	(mi.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		mi.Defined_flag:=FALSE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

n:= 0;
while (n <= Multi_X4_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n < MI.M_Value_Size) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X4):Multi_Int_XV;
begin
Multi_Int_X4_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X4):Multi_Int_XV;
begin
Multi_Int_X4_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_XV(const v1:Multi_Int_X3; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
MI.init;
if (Multi_X3_size > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(MI, Multi_X3_size);
	if	(mi.Overflow) then
		begin
		mi.Defined_flag:=FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n < MI.M_Value_Size) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X3):Multi_Int_XV;
begin
Multi_Int_X3_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X3):Multi_Int_XV;
begin
Multi_Int_X3_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_XV(const v1:Multi_Int_X2; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
MI.init;
if (Multi_X2_size > mi.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(MI, Multi_X2_size);
	if	(mi.Overflow) then
		begin
		mi.Defined_flag:=FALSE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EInterror.create('Overflow');
		exit;
		end;
	end;

if	(v1.Defined_flag = FALSE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	MI.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n < MI.M_Value_Size) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X2):Multi_Int_XV;
begin
Multi_Int_X2_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X2):Multi_Int_XV;
begin
Multi_Int_X2_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i < v1.M_Value_Size)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Single conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Real;
var
	R,V,M	:Real;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i < v1.M_Value_Size)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Real conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Double;
var
	R,V,M	:Double;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Multi_Int_ERROR:= FALSE;
finished:= FALSE;
M:= MULTI_INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];
i:= 1;
while	(i < v1.M_Value_Size)
and		(not Multi_Int_ERROR)
do
	begin
	if	(not finished)
	then
		begin
			V:= v1.M_Value[i];
			try
				begin
				V:= (V * M);
				R:= R + V;
				end
            except
				begin
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int to Double conversion');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
// WARNING Float type to Multi_Int type conversion loses some precision
class operator Multi_Int_XV.:=(const v1:Single):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;
begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_SINGLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on single to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float type to Multi_Int type conversion loses some precision
class operator Multi_Int_XV.:=(const v1:Real):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_REAL_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Real to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
// WARNING Float type to Multi_Int type conversion loses some precision
class operator Multi_Int_XV.:=(const v1:Double):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;

begin
Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',AnsiLeftStr(R_FLOATREC.digits,(MULTI_DOUBLE_TYPE_PRECISION_DIGITS-1)),R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double to Multi_Int conversion');
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):MULTI_INT_2W_S;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n < v1.M_Value_Size)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if (R >= MULTI_INT_2W_S_MAXINT)
or	(not M_Val_All_Zero)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_2W_S(-R)
else Result:= MULTI_INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):MULTI_INT_2W_U;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[1]) << MULTI_INT_1W_SIZE);
R:= (R OR MULTI_INT_2W_U(v1.M_Value[0]));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n < v1.M_Value_Size)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if (not M_Val_All_Zero)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= R;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):MULTI_INT_1W_S;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n < v1.M_Value_Size)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if	(R > MULTI_INT_1W_S_MAXINT)
or (not M_Val_All_Zero)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= MULTI_INT_1W_S(-R)
else Result:= MULTI_INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):MULTI_INT_1W_U;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

R:= (MULTI_INT_2W_U(v1.M_Value[0]) + (MULTI_INT_2W_U(v1.M_Value[1]) * MULTI_INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n < v1.M_Value_Size)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if	(R > MULTI_INT_1W_U_MAXINT)
or (not M_Val_All_Zero)
then
	begin
	Result:=0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= MULTI_INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Multi_int8u;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

if v1 > Multi_INT8U_MAXINT
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= Multi_int8u(v1.M_Value[0]);
end;


{******************************************}
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):Multi_int8;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Result:=0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

if v1 > Multi_INT8U_MAXINT
then
	begin
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result:= Multi_int8(v1.M_Value[0]);
end;


(******************************************)
function add_Multi_Int_XV(const v1,v2:Multi_Int_XV):Multi_Int_XV;
label 999;
var
	tv1,tv2			:MULTI_INT_2W_S;
//	tv1,tv2			:MULTI_INT_2W_U;
	i,s1,s2,s,ss	:MULTI_INT_1W_S;
	M_Val			:array of MULTI_INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;
ss:= (s+1);
setlength(M_Val, ss);

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

i:= 1;
while (i < (s-1)) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
	M_Val[i]:=(M_Val[i] + tv1 + tv2);
	if	M_Val[i] > MULTI_INT_1W_U_MAXINT then
		begin
		M_Val[i+1]:= (M_Val[i] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[i]:= (M_Val[i] MOD MULTI_INT_1W_U_MAXINT_1);
		end
	else M_Val[i+1]:= 0;
	inc(i);
	end;

if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
M_Val[i]:=(M_Val[i] + tv1 + tv2);

if	M_Val[i] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[i+1]:= (M_Val[i] DIV MULTI_INT_1W_U_MAXINT_1);
	M_Val[i]:= (M_Val[i] MOD MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	M_Val[i+1]:= 0;
	ss:= s;
	end;

Result:= 0;
if	(ss > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, ss);
	if (Result.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:= FALSE;
		goto 999;
		end;
	end;

Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

M_Val_All_Zero:= TRUE;
i:=0;
while (i < ss) do
	begin
	Result.M_Value[i]:= M_Val[i];
	if M_Val[i] <> 0 then M_Val_All_Zero:= FALSE;
	inc(i);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;

999:
end;


(******************************************)
function subtract_Multi_Int_XV(const v1,v2:Multi_Int_XV):Multi_Int_XV;
label 999;
var
	tv1,tv2			:MULTI_INT_2W_S;
	M_Val			:array of MULTI_INT_2W_S;
	i,s1,s2,s,ss	:MULTI_INT_1W_S;
	M_Val_All_Zero	:boolean;
begin
s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;
ss:= (s+1);
setlength(M_Val, ss);

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + MULTI_INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

i:=1;
while (i < (s-1)) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
	M_Val[i]:= (M_Val[i] + (tv1 - tv2));
	if	M_Val[i] < 0 then
		begin
		M_Val[i+1]:= -1;
		M_Val[i]:= (M_Val[i] + MULTI_INT_1W_U_MAXINT_1);
		end
	else M_Val[i+1]:= 0;
	inc(i);
	end;

if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
M_Val[i]:= (M_Val[i] + (tv1 - tv2));
if	M_Val[i] < 0 then
	begin
	M_Val[i+1]:= -1;
	M_Val[i]:= (M_Val[i] + MULTI_INT_1W_U_MAXINT_1);
	end
else
	begin
	M_Val[i+1]:= 0;
	ss:= s;
	end;

Result:= 0;
if	(ss > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, ss);
	if (Result.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:= FALSE;
		goto 999;
		end;
	end;

Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

M_Val_All_Zero:=TRUE;
i:=0;
while (i < ss) do
	begin
	Result.M_Value[i]:= M_Val[i];
	if M_Val[i] > 0 then M_Val_All_Zero:= FALSE;
	inc(i);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;

999:
end;


(******************************************)
class operator Multi_Int_XV.+(const v1,v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	Result:=add_Multi_Int_XV(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_XV(v2,v1);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_XV(v1,v2);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_XV(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_XV(v1,v2);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_XV(v2,v1);
			Neg:= Multi_UBool_FALSE;
			end;
		end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_XV.inc(const v1:Multi_Int_XV):Multi_Int_XV;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	Result:=add_Multi_Int_XV(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_XV(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_XV(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_XV(v2,v1);
		Neg:= Multi_UBool_FALSE;
		end;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_XV.-(const v1,v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	if	(v1.Negative_flag = TRUE) then
		begin
		if	ABS_greaterthan_Multi_Int_XV(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_XV(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_XV(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_XV(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_XV(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_XV(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_XV(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_XV.dec(const v1:Multi_Int_XV):Multi_Int_XV;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE) then
	begin
	if	ABS_greaterthan_Multi_Int_XV(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_XV(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_XV(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_XV(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_XV.-(const v1:Multi_Int_XV):Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on unary minus');
		end;
	exit;
	end;

Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_XV.xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;
label 999;
var
i,s1,s2,s	:MULTI_INT_1W_S;
tv1,tv2		:MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;

Result.init;
if (s > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, s);
	if (Result.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:=FALSE;
		goto 999;
		end;
	end;

i:=0;
while (i < s) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
	Result.M_Value[i]:=(tv1 xor tv2);
	Inc(i);
	end;

Result.Defined_flag:=TRUE;
Result.Overflow_flag:=FALSE;
if (v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:= Multi_UBool_TRUE;

999:
end;


(*******************v4*********************)
procedure multiply_Multi_Int_XV(const v1,v2:Multi_Int_XV;out Result:Multi_Int_XV); overload;
label	999;
var
i,j,k,
s1,s2,ss,
z2,z1		:MULTI_INT_1W_S;
zf,
zero_mult	:boolean;
tv1,tv2		:MULTI_INT_2W_U;
M_Val			:array of MULTI_INT_2W_U;

begin
s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
ss:= (s1 + s2);
setlength(M_Val, ss);

Result.init;
Result:= 0;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

// skip leading zeros in v2
zf:= FALSE;
i:= (s2-1);
z2:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		z2:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(z2 < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

// skip leading zeros in v1
zf:= FALSE;
i:= (s1-1);
z1:= -1;
repeat
	if	(v1.M_Value[i] <> 0) then
		begin
		z1:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(z1 < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

// main loopy
i:=0;
j:=0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		zero_mult:= TRUE;
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				zero_mult:= FALSE;
				tv1:=v1.M_Value[i];
				tv2:=v2.M_Value[j];
				M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
				M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
				end;
			INC(i);
		until (i > z1);
		if not zero_mult then
			begin
			k:=0;
			repeat
            	if (M_Val[k] <> 0) then
					begin
					M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
					M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
					end;
				INC(k);
			until (k >= ss);
			end;
		i:=0;
        end;
	INC(j);
until (j > z2);

// skip leading zeros to make result var just big enough, but no bigger
// check if result all zeros; if so, negative:= false, else negative:= undefined

Result.Negative_flag:=Multi_UBool_FALSE;
zf:= FALSE;
z1:= -1;
i:= (ss-1);
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (not zf) then
			begin
			zf:= TRUE;
			z1:= i;
			end;
		end;
	Dec(i);
until (i < 0);

if ((z1 + 1) > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result,(z1+1));
	if (Result.Overflow) then
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:= FALSE;
		goto 999;
		end;
	end;

// copy temp M_Val to Result
i:= 0;
while (i <= z1) do
	begin
	Result.M_Value[i]:= M_Val[i];
	Inc(i);
	end;

999:
end;


(******************************************)
class operator Multi_Int_XV.*(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var	  R:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	exit;
	end;

R.init;
multiply_Multi_Int_XV(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(*************************)
procedure SqRoot(const v1:Multi_Int_XV; out VR,VREM:Multi_Int_XV);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_XV;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Dec');
		end;
	exit;
	end;

if	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('SqRoot is Negative_flag');
		end;
	exit;
	end;

CC.init;

D:= length(v1.ToStr);
D2:= D div 2;
if ((D mod 2)=0) then
	begin
	LS:= '1' + AddCharR('0','',D2-1);
	HS:= '1' + AddCharR('0','',D2);
	H:= HS;
	L:= LS;
	end
else
	begin
	LS:= '1' + AddCharR('0','',D2);
	HS:= '1' + AddCharR('0','',D2+1);
	H:= HS;
	L:= LS;
	end;

finished:= FALSE;
while not finished do
	begin
    T:= subtract_Multi_Int_XV(H,L);
    // ShiftDown(T,1);
	ShiftDown_MultiBits_Multi_Int_XV(T, 1);
    C:= add_Multi_Int_XV(L,T);

    multiply_Multi_Int_XV(C,C, CC);

	if	(CC.Overflow)
	or	ABS_greaterthan_Multi_Int_XV(CC,v1)
	then
		begin
		if ABS_lessthan_Multi_Int_XV(C,H) then
			H:= C
		else
			begin
			finished:= TRUE;
			VREM:= 0;
			end
		end
	else if ABS_lessthan_Multi_Int_XV(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_XV(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			multiply_Multi_Int_XV(C,C, T);
			VREM:= subtract_Multi_Int_XV(v1,T);
			end
		end
	else
		begin
		VREM:= 0;
		finished:= TRUE;
		end;
	end;

VR:= C;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;
end;


(********************v3********************)
{ Function exp_by_squaring_iterative(TV, P) }

class operator Multi_Int_XV.**(const v1:Multi_Int_XV; const P:MULTI_INT_2W_S):Multi_Int_XV;
var
Y,TV,T,R	:Multi_Int_XV;
PT			:MULTI_INT_2W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on power');
		end;
	exit;
	end;

PT:= P;
TV:= v1;
if	(PT < 0) then R:= 0
else if	(PT = 0) then R:= 1
else
	begin
	Y := 1;
	while (PT > 1) do
		begin
		if	odd(PT) then
			begin
			multiply_Multi_Int_XV(TV,Y, T);
			if	(T.Overflow_flag)
			then
				begin
				Result:= 0;
				Result.Defined_flag:= FALSE;
				Result.Overflow_flag:= TRUE;
				Multi_Int_ERROR:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow on Power');
					end;
				exit;
				end;
			if	(T.Negative_flag = Multi_UBool_UNDEF) then
				if	(TV.Negative_flag = Y.Negative_flag)
				then T.Negative_flag:= Multi_UBool_FALSE
				else T.Negative_flag:= Multi_UBool_TRUE;

			Y:= T;
			PT := PT - 1;
			end;
		multiply_Multi_Int_XV(TV,TV, T);
		if	(T.Overflow_flag)
		then
			begin
			Result:= 0;
			Result.Defined_flag:= FALSE;
			Result.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Power');
				end;
			exit;
			end;
		T.Negative_flag:= Multi_UBool_FALSE;

		TV:= T;
		PT := (PT div 2);
		end;
	multiply_Multi_Int_XV(TV,Y, R);
	if	(R.Overflow_flag)
	then
		begin
		Result:= 0;
		Result.Defined_flag:= FALSE;
		Result.Overflow_flag:= TRUE;
		Multi_Int_ERROR:= TRUE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on Power');
			end;
		exit;
		end;
	if	(R.Negative_flag = Multi_UBool_UNDEF) then
		if	(TV.Negative_flag = Y.Negative_flag)
		then R.Negative_flag:= Multi_UBool_FALSE
		else R.Negative_flag:= Multi_UBool_TRUE;
	end;

Result:= R;
end;


(********************v0********************)
procedure intdivide_taylor_warruth_XV(const P_dividend,P_dividor:Multi_Int_XV;out P_quotient,P_remainder:Multi_Int_XV);
label	AGAIN,9000,9999;
var
dividor,
quotient,
dividend,
next_dividend
			:Multi_Int_XV;

dividend_i,
dividend_s,
dividend_i_1,
quotient_i,
dividor_i,
dividor_s,
div_s,
dividor_i_1,
dividor_non_zero_pos,
shiftup_bits_dividor,
i
				:MULTI_INT_1W_S;

adjacent_word_dividend,
adjacent_word_division,
word_division,
word_dividend,
word_carry,
next_word_carry
				:MULTI_INT_2W_U;

finished		:boolean;

begin
P_quotient:= 0;
P_remainder:= 0;

if	(P_dividor = 0) then
	begin
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_dividor = P_dividend) then
	begin
	P_quotient:= 1;
    end
else
	begin
	if	(Abs(P_dividor) > Abs(P_dividend)) then
		begin
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	dividor:= P_dividor;
	dividor_non_zero_pos:= 0;
    i:= (dividor.M_Value_Size - 1);
	while	(i >= 0) do
		begin
		if	(dividor_non_zero_pos = 0) then
			if	(dividor.M_Value[i] <> 0) then
				begin
				dividor_non_zero_pos:= i;
				break;
				end;
		Dec(i);
		end;
	dividor.Negative_flag:= FALSE;

	// essential short-cut for single word dividor
	// NB this is not just for speed, the later code
	// will break if this case is not processed in advance

	if	(dividor_non_zero_pos = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		word_carry:= 0;
		i:= (P_dividend.M_Value_Size - 1);
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) div MULTI_INT_2W_U(P_dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(P_dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto 9000;
		end;

    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	dividor_s:= (P_dividor.M_Value_Size + 1);
	dividend_s:= (P_dividend.M_Value_Size + 1);

	div_s:= dividend_s;
	if (dividor_s > dividend_s) then
		begin
		div_s:= dividor_s;
		dividend_s:= dividor_s;
		end
	else
		dividor_s:= div_s;

	Multi_Int_Reset_XV_Size(dividor, div_s);
	if (dividor.Overflow) then
		begin
		P_quotient.Defined_flag:= FALSE;
		P_quotient.Overflow_flag:= TRUE;
		P_remainder.Defined_flag:= FALSE;
		P_remainder.Overflow_flag:= TRUE;
		Multi_Int_ERROR:= TRUE;
		goto 9999;
		end;

	Multi_Int_Reset_XV_Size(dividend, div_s);
	if (dividend.Overflow) then
		begin
		P_quotient.Defined_flag:= FALSE;
		P_quotient.Overflow_flag:= TRUE;
		P_remainder.Defined_flag:= FALSE;
		P_remainder.Overflow_flag:= TRUE;
		Multi_Int_ERROR:= TRUE;
		goto 9999;
		end;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_XV(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_XV(dividor, shiftup_bits_dividor);
		end;

	next_word_carry:= 0;
	word_carry:= 0;
	dividor_i:= dividor_non_zero_pos;
	dividor_i_1:= (dividor_i - 1);
	dividend_i:= (Multi_XV_maxi + 1);
	finished:= FALSE;
	while (not finished) do
	    if (dividend_i >= 0) then
		    if (dividend.M_Value[dividend_i] = 0) then
				Dec(dividend_i)
			else finished:= TRUE
		else finished:= TRUE
		;
	quotient_i:= (dividend_i - dividor_non_zero_pos);

	while	(dividend >= 0)
	and		(quotient_i >= 0)
	do
		begin
		word_dividend:= ((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i]);
        word_division:= (word_dividend div dividor.M_Value[dividor_i]);
        next_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((next_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					next_word_carry:= next_word_carry + dividor.M_Value[dividor_i];
					if (next_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;

			quotient:= 0;
			if (quotient.M_Value_Size < div_s) then
				begin
				Multi_Int_Reset_XV_Size(quotient, div_s);
				if (quotient.Overflow) then
					begin
					P_quotient.Defined_flag:= FALSE;
					P_quotient.Overflow_flag:= TRUE;
					P_remainder.Defined_flag:= FALSE;
					P_remainder.Overflow_flag:= TRUE;
					Multi_Int_ERROR:= TRUE;
					goto 9999;
					end;
				end;

			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividor * quotient);
            next_dividend:= (dividend - next_dividend);
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				end;
			P_quotient.M_Value[quotient_i]:= word_division;
            dividend:= next_dividend;
            word_carry:= dividend.M_Value[dividend_i];
			end
		else
			begin
            word_carry:= word_dividend;
			end;

		Dec(dividend_i);
		quotient_i:= (dividend_i - dividor_non_zero_pos);
		end; { while }

	ShiftDown_MultiBits_Multi_Int_XV(dividend, shiftup_bits_dividor);
	P_remainder:= dividend;

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;

9999:
end;


(******************************************)
class operator Multi_Int_XV.div(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
Remainder,
Quotient	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

// same values as last time

if	(XV_Last_Divisor = v2)
and	(XV_Last_Dividend = v1)
then
	Result:= XV_Last_Quotient
else	// different values than last time
	begin
	intdivide_taylor_warruth_XV(v1,v2,Quotient,Remainder);

	XV_Last_Divisor:= v2;
	XV_Last_Dividend:= v1;
	XV_Last_Quotient:= Quotient;
	XV_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

if	(XV_Last_Remainder.Overflow_flag)
or	(XV_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


(******************************************)
class operator Multi_Int_XV.mod(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
Remainder,
Quotient	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result:= 0;
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on modulus');
		end;
	exit;
	end;

// same values as last time

if	(XV_Last_Divisor = v2)
and	(XV_Last_Dividend = v1)
then
	Result:= XV_Last_Remainder
else	// different values than last time
	begin
	intdivide_taylor_warruth_XV(v1,v2,Quotient,Remainder);

	XV_Last_Divisor:= v2;
	XV_Last_Dividend:= v1;
	XV_Last_Quotient:= Quotient;
	XV_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;


if	(XV_Last_Remainder.Overflow_flag)
or	(XV_Last_Quotient.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	end;
end;


{
******************************************
Multi_Init_Initialisation
******************************************
}

procedure Multi_Init_Initialisation(const P_Multi_XV_size:MULTI_INT_1W_U = 16);
var	i:MULTI_INT_1W_U;

begin
Inc(Multi_Init_Initialisation_count);

Multi_XV_size:=	P_Multi_XV_size;

if (Multi_XV_size < 1) then
	begin
	Raise EInterror.create('Multi_XV_size must be > 1');
	exit;
	end;

Multi_XV_limit:=	(Multi_XV_size * 2);
Multi_XV_maxi:=		(Multi_XV_size - 1);

X3_Last_Divisor:= 0;
X3_Last_Dividend:= 0;
X3_Last_Quotient:= 0;
X3_Last_Remainder:= 0;

X2_Last_Divisor:= 0;
X2_Last_Dividend:= 0;
X2_Last_Quotient:= 0;
X2_Last_Remainder:= 0;

X4_Last_Divisor:= 0;
X4_Last_Dividend:= 0;
X4_Last_Quotient:= 0;
X4_Last_Remainder:= 0;

XV_Last_Divisor:= 0;
XV_Last_Dividend:= 0;
XV_Last_Quotient:= 0;
XV_Last_Remainder:= 0;

Multi_Int_X2_MAXINT:= 0;
i:=0;
while (i <= Multi_X2_maxi) do
	begin
	Multi_Int_X2_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X3_MAXINT:= 0;
i:=0;
while (i <= Multi_X3_maxi) do
	begin
	Multi_Int_X3_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X4_MAXINT:= 0;
i:=0;
while (i <= Multi_X4_maxi) do
	begin
	Multi_Int_X4_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

if (Multi_XV_maxi < 1) then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Multi_XV_maxi value must be > 0');
		end;
	halt(1);
	end;

Multi_Int_XV_MAXINT:= 0;
i:=0;
while (i <= Multi_XV_maxi) do
	begin
	Multi_Int_XV_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;
end;

procedure Multi_Int_Reset_X2_Last_Divisor;
begin
X2_Last_Divisor:= 0;
X2_Last_Dividend:= 0;
X2_Last_Quotient:= 0;
X2_Last_Remainder:= 0;
end;

procedure Multi_Int_Reset_X3_Last_Divisor;
begin
X3_Last_Divisor:= 0;
X3_Last_Dividend:= 0;
X3_Last_Quotient:= 0;
X3_Last_Remainder:= 0;
end;

procedure Multi_Int_Reset_X4_Last_Divisor;
begin
X4_Last_Divisor:= 0;
X4_Last_Dividend:= 0;
X4_Last_Quotient:= 0;
X4_Last_Remainder:= 0;
end;

procedure Multi_Int_Reset_XV_Last_Divisor;
begin
XV_Last_Divisor:= 0;
XV_Last_Dividend:= 0;
XV_Last_Quotient:= 0;
XV_Last_Remainder:= 0;
end;


begin
Multi_Init_Initialisation;
end.

