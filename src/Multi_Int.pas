UNIT Multi_Int;

{$MODE DELPHI}

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

{$MODESWITCH NESTEDCOMMENTS+}

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
*)

// {$define Overflow_Checks}
// {$define extended_inc_operator}

(* END OF USER OPTIONAL DEFINES *)
	
INTERFACE

uses	sysutils
,		strutils
,		strings
,		math
,		UBool
;

const

(* Do not change these values *)

	Multi_X2_max = 3;
	Multi_X2_max_x2 = 7;
	Multi_X2_size = Multi_X2_max + 1;

	Multi_X3_max = 5;
	Multi_X3_max_x2 = 11;
	Multi_X3_size = Multi_X3_max + 1;

	Multi_X4_max = 7;
	Multi_X4_max_x2 = 15;
	Multi_X4_size = Multi_X4_max + 1;

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

Multi_Int_X2	=	record
					private
						M_Value			:array[0..Multi_X2_max] of MULTI_INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X2;
						function Overflow:boolean;
						function Negative:boolean;
						function Defined:boolean;
						{
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
						}
						class operator implicit(const v1:Multi_Int_X2):Multi_int8u;
						class operator implicit(const v1:Multi_Int_X2):Multi_int8;
						class operator implicit(const v1:Multi_Int_X2):MULTI_INT_1W_U;
						class operator implicit(const v1:Multi_Int_X2):MULTI_INT_1W_S;
						class operator implicit(const v1:Multi_Int_X2):MULTI_INT_2W_U;
						class operator implicit(const v1:Multi_Int_X2):MULTI_INT_2W_S;
						class operator implicit(const v1:MULTI_INT_2W_S):Multi_Int_X2;
						class operator implicit(const v1:MULTI_INT_2W_U):Multi_Int_X2;
					{$ifdef 32bit}
						class operator implicit(const v1:MULTI_INT_4W_S):Multi_Int_X2;
						class operator implicit(const v1:MULTI_INT_4W_U):Multi_Int_X2;
					{$endif}
						class operator implicit(const v1:ansistring):Multi_Int_X2;
						class operator implicit(const v1:Multi_Int_X2):ansistring;
						class operator implicit(const v1:Single):Multi_Int_X2;
						class operator implicit(const v1:Real):Multi_Int_X2;
						class operator implicit(const v1:Double):Multi_Int_X2;
						class operator implicit(const v1:Multi_Int_X2):Single;
						class operator implicit(const v1:Multi_Int_X2):Real;
						class operator implicit(const v1:Multi_Int_X2):Double;
						class operator add(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator subtract(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator inc(const v1:Multi_Int_X2):Multi_Int_X2;
						class operator dec(const v1:Multi_Int_X2):Multi_Int_X2;
					{$ifdef extended_inc_operator}
						class operator inc(const v1,v2:Multi_Int_X2):Multi_Int_X2; overload;
						class operator dec(const v1,v2:Multi_Int_X2):Multi_Int_X2; overload;
					{$endif}
						class operator greaterthan(const v1,v2:Multi_Int_X2):Boolean;
						class operator lessthan(const v1,v2:Multi_Int_X2):Boolean;
						class operator equal(const v1,v2:Multi_Int_X2):Boolean;
						class operator notequal(const v1,v2:Multi_Int_X2):Boolean;
						class operator multiply(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator intdivide(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator modulus(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator xor(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator -(const v1:Multi_Int_X2):Multi_Int_X2;
						class operator >=(const v1,v2:Multi_Int_X2):Boolean;
						class operator <=(const v1,v2:Multi_Int_X2):Boolean;
						class operator **(const v1:Multi_Int_X2; const P:MULTI_INT_2W_S):Multi_Int_X2;
					end;


Multi_Int_X3	=	record
					private
						M_Value			:array[0..Multi_X3_max] of MULTI_INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X3;
						function Overflow:boolean;
						function Negative:boolean;
						function Defined:boolean;
						{
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
						}
						class operator implicit(const v1:Multi_Int_X3):Multi_int8u;
						class operator implicit(const v1:Multi_Int_X3):Multi_int8;
						class operator implicit(const v1:Multi_Int_X3):MULTI_INT_1W_U;
						class operator implicit(const v1:Multi_Int_X3):MULTI_INT_1W_S;
						class operator implicit(const v1:Multi_Int_X3):MULTI_INT_2W_U;
						class operator implicit(const v1:Multi_Int_X3):MULTI_INT_2W_S;
						class operator implicit(const v1:MULTI_INT_2W_S):Multi_Int_X3;
						class operator implicit(const v1:MULTI_INT_2W_U):Multi_Int_X3;
					{$ifdef 32bit}
						class operator implicit(const v1:MULTI_INT_4W_S):Multi_Int_X3;
						class operator implicit(const v1:MULTI_INT_4W_U):Multi_Int_X3;
					{$endif}
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_X3;
						class operator implicit(const v1:ansistring):Multi_Int_X3;
						class operator implicit(const v1:Multi_Int_X3):ansistring;
						class operator implicit(const v1:Single):Multi_Int_X3;
						class operator implicit(const v1:Real):Multi_Int_X3;
						class operator implicit(const v1:Double):Multi_Int_X3;
						class operator implicit(const v1:Multi_Int_X3):Real;
						class operator implicit(const v1:Multi_Int_X3):Single;
						class operator implicit(const v1:Multi_Int_X3):Double;
						class operator add(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator subtract(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator inc(const v1:Multi_Int_X3):Multi_Int_X3;
						class operator dec(const v1:Multi_Int_X3):Multi_Int_X3;
					{$ifdef extended_inc_operator}
						class operator inc(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator dec(const v1,v2:Multi_Int_X3):Multi_Int_X3;
					{$endif}
						class operator greaterthan(const v1,v2:Multi_Int_X3):Boolean;
						class operator lessthan(const v1,v2:Multi_Int_X3):Boolean;
						class operator equal(const v1,v2:Multi_Int_X3):Boolean;
						class operator notequal(const v1,v2:Multi_Int_X3):Boolean;
						class operator multiply(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator intdivide(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator modulus(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator xor(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator -(const v1:Multi_Int_X3):Multi_Int_X3;
						class operator >=(const v1,v2:Multi_Int_X3):Boolean;
						class operator <=(const v1,v2:Multi_Int_X3):Boolean;
						class operator **(const v1:Multi_Int_X3; const P:MULTI_INT_2W_S):Multi_Int_X3;
					end;


Multi_Int_X4	=	record
					private
						M_Value			:array[0..Multi_X4_max] of MULTI_INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X4;
						function Overflow:boolean;
						function Negative:boolean;
						function Defined:boolean;
						{
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
						}
						class operator implicit(const v1:Multi_Int_X4):Multi_int8u;
						class operator implicit(const v1:Multi_Int_X4):Multi_int8;
						class operator implicit(const v1:Multi_Int_X4):MULTI_INT_1W_U;
						class operator implicit(const v1:Multi_Int_X4):MULTI_INT_1W_S;
						class operator implicit(const v1:Multi_Int_X4):MULTI_INT_2W_U;
						class operator implicit(const v1:Multi_Int_X4):MULTI_INT_2W_S;
						class operator implicit(const v1:MULTI_INT_2W_S):Multi_Int_X4;
						class operator implicit(const v1:MULTI_INT_2W_U):Multi_Int_X4;
					{$ifdef 32bit}
						class operator implicit(const v1:MULTI_INT_4W_S):Multi_Int_X4;
						class operator implicit(const v1:MULTI_INT_4W_U):Multi_Int_X4;
					{$endif}
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_X4;
						class operator implicit(const v1:Multi_Int_X3):Multi_Int_X4;
						class operator implicit(const v1:ansistring):Multi_Int_X4;
						class operator implicit(const v1:Multi_Int_X4):ansistring;
						class operator implicit(const v1:Single):Multi_Int_X4;
						class operator implicit(const v1:Real):Multi_Int_X4;
						class operator implicit(const v1:Double):Multi_Int_X4;
						class operator implicit(const v1:Multi_Int_X4):Single;
						class operator implicit(const v1:Multi_Int_X4):Real;
						class operator implicit(const v1:Multi_Int_X4):Double;
						class operator add(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator subtract(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator inc(const v1:Multi_Int_X4):Multi_Int_X4;
						class operator dec(const v1:Multi_Int_X4):Multi_Int_X4;
					{$ifdef extended_inc_operator}
						class operator inc(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator dec(const v1,v2:Multi_Int_X4):Multi_Int_X4;
					{$endif}
						class operator greaterthan(const v1,v2:Multi_Int_X4):Boolean;
						class operator lessthan(const v1,v2:Multi_Int_X4):Boolean;
						class operator equal(const v1,v2:Multi_Int_X4):Boolean;
						class operator notequal(const v1,v2:Multi_Int_X4):Boolean;
						class operator multiply(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator intdivide(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator modulus(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator xor(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator -(const v1:Multi_Int_X4):Multi_Int_X4;
						class operator >=(const v1,v2:Multi_Int_X4):Boolean;
						class operator <=(const v1,v2:Multi_Int_X4):Boolean;
						class operator **(const v1:Multi_Int_X4; const P:MULTI_INT_2W_S):Multi_Int_X4;
					end;


Multi_Int_XV	=	record
					private
						M_Value			:array of MULTI_INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						procedure init;
						function ToStr:ansistring;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_XV;
						function Overflow:boolean;
						function Negative:boolean;
						function Defined:boolean;
						{
						procedure ShiftUp_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
						procedure ShiftDown_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
						procedure RotateUp_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
						procedure RotateDown_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
						}
						class operator implicit(const v1:Multi_Int_XV):Multi_int8u;
						class operator implicit(const v1:Multi_Int_XV):Multi_int8;
						class operator implicit(const v1:Multi_Int_XV):MULTI_INT_1W_U;
						class operator implicit(const v1:Multi_Int_XV):MULTI_INT_1W_S;
						class operator implicit(const v1:Multi_Int_XV):MULTI_INT_2W_U;
						class operator implicit(const v1:Multi_Int_XV):MULTI_INT_2W_S;
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_X3):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_X4):Multi_Int_XV;
						class operator implicit(const v1:MULTI_INT_2W_S):Multi_Int_XV;
						class operator implicit(const v1:MULTI_INT_2W_U):Multi_Int_XV;
					{$ifdef 32bit}
						class operator implicit(const v1:MULTI_INT_4W_S):Multi_Int_XV;
						class operator implicit(const v1:MULTI_INT_4W_U):Multi_Int_XV;
					{$endif}
						class operator implicit(const v1:ansistring):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_XV):ansistring;
						class operator implicit(const v1:Single):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_XV):Single;
						class operator implicit(const v1:Real):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_XV):Real;
						class operator implicit(const v1:Double):Multi_Int_XV;
						class operator implicit(const v1:Multi_Int_XV):Double;
						class operator add(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator greaterthan(const v1,v2:Multi_Int_XV):Boolean;
						class operator lessthan(const v1,v2:Multi_Int_XV):Boolean;
						class operator equal(const v1,v2:Multi_Int_XV):Boolean;
						class operator notequal(const v1,v2:Multi_Int_XV):Boolean;
						class operator subtract(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator inc(const v1:Multi_Int_XV):Multi_Int_XV;
						class operator dec(const v1:Multi_Int_XV):Multi_Int_XV;
					{$ifdef extended_inc_operator}
						class operator inc(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator dec(const v1,v2:Multi_Int_XV):Multi_Int_XV;
					{$endif}
						class operator xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator multiply(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator intdivide(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator modulus(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator -(const v1:Multi_Int_XV):Multi_Int_XV;
						class operator >=(const v1,v2:Multi_Int_XV):Boolean;
						class operator <=(const v1,v2:Multi_Int_XV):Boolean;
						class operator **(const v1:Multi_Int_XV; const P:MULTI_INT_2W_S):Multi_Int_XV;
					end;

var
Multi_Int_ALLOW_UNLIMITED_INITIALISATIONS	:boolean = FALSE;
Multi_Init_Initialisation_count				:MULTI_INT_1W_S = 0;
Multi_Int_RAISE_EXCEPTIONS_ENABLED			:boolean = TRUE;
Multi_Int_ERROR								:boolean = FALSE;
Multi_Int_XV_VARS_CREATED					:boolean = FALSE;

Multi_Int_X2_MAXINT			:Multi_Int_X2;
Multi_Int_X3_MAXINT			:Multi_Int_X3;
Multi_Int_X4_MAXINT			:Multi_Int_X4;
Multi_Int_XV_MAXINT			:Multi_Int_XV;
Multi_32bit_or_64bit		:T_Multi_32bit_or_64bit;

Multi_XV_size		:MULTI_INT_1W_U = 0;
Multi_XV_max		:MULTI_INT_1W_U;
Multi_XV_size_x2	:MULTI_INT_1W_U;
Multi_XV_max_x2		:MULTI_INT_1W_U;

procedure Multi_Init_Initialisation(const P_Multi_XV_size:Multi_int32u = 16);

function Odd(const v1:Multi_Int_XV):boolean; overload;
function Odd(const v1:Multi_Int_X4):boolean; overload;
function Odd(const v1:Multi_Int_X3):boolean; overload;
function Odd(const v1:Multi_Int_X2):boolean; overload;

function Even(const v1:Multi_Int_XV):boolean; overload;
function Even(const v1:Multi_Int_X4):boolean; overload;
function Even(const v1:Multi_Int_X3):boolean; overload;
function Even(const v1:Multi_Int_X2):boolean; overload;

function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;
function Abs(const v1:Multi_Int_XV):Multi_Int_XV; overload;

procedure SqRoot(const v1:Multi_Int_XV;var VR,VREM:Multi_Int_XV); overload;
procedure SqRoot(const v1:Multi_Int_X4;var VR,VREM:Multi_Int_X4); overload;
procedure SqRoot(const v1:Multi_Int_X3;var VR,VREM:Multi_Int_X3); overload;
procedure SqRoot(const v1:Multi_Int_X2;var VR,VREM:Multi_Int_X2); overload;

procedure ShiftUp(var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
procedure ShiftDown(var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
procedure ShiftUp(var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
procedure ShiftDown(var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
procedure ShiftUp(var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
procedure ShiftDown(var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
procedure ShiftUp(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
procedure ShiftDown(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;

procedure RotateUp(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
procedure RotateDown(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
procedure RotateUp(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
procedure RotateDown(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
procedure RotateUp(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
procedure RotateDown(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
procedure RotateUp(Var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
procedure RotateDown(Var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;

procedure FromHex(const v1:ansistring; var v2:Multi_Int_X2); overload;
procedure FromHex(const v1:ansistring; var v2:Multi_Int_X3); overload;
procedure FromHex(const v1:ansistring; var v2:Multi_Int_X4); overload;
procedure FromHex(const v1:ansistring; var v2:Multi_Int_XV); overload;

function Hex_to_Multi_Int_X2(const v1:ansistring):Multi_Int_X2; overload;
procedure Hex_to_Multi_Int_X2(const v1:ansistring; var mi:Multi_Int_X2); overload;

function Hex_to_Multi_Int_X3(const v1:ansistring):Multi_Int_X3; overload;
procedure Hex_to_Multi_Int_X3(const v1:ansistring; var mi:Multi_Int_X3); overload;

function Hex_to_Multi_Int_X4(const v1:ansistring):Multi_Int_X4; overload;
procedure Hex_to_Multi_Int_X4(const v1:ansistring; var mi:Multi_Int_X4); overload;

function Hex_to_Multi_Int_XV(const v1:ansistring):Multi_Int_XV; overload;
procedure Hex_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV); overload;

function To_Multi_Int_XV(const v1:Multi_Int_X4):Multi_Int_XV; overload;
function To_Multi_Int_XV(const v1:Multi_Int_X3):Multi_Int_XV; overload;
function To_Multi_Int_XV(const v1:Multi_Int_X2):Multi_Int_XV; overload;

function To_Multi_Int_X4(const v1:Multi_Int_XV):Multi_Int_X4; overload;
function To_Multi_Int_X4(const v1:Multi_Int_X3):Multi_Int_X4; overload;
function To_Multi_Int_X4(const v1:Multi_Int_X2):Multi_Int_X4; overload;

function To_Multi_Int_X3(const v1:Multi_Int_XV):Multi_Int_X3; overload;
function To_Multi_Int_X3(const v1:Multi_Int_X4):Multi_Int_X3; overload;
function To_Multi_Int_X3(const v1:Multi_Int_X2):Multi_Int_X3; overload;

function To_Multi_Int_X2(const v1:Multi_Int_XV):Multi_Int_X2; overload;
function To_Multi_Int_X2(const v1:Multi_Int_X4):Multi_Int_X2; overload;
function To_Multi_Int_X2(const v1:Multi_Int_X3):Multi_Int_X2; overload;


IMPLEMENTATION

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

(******************************************)
var

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
i:= Multi_X2_max;
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
function nlz_MultiBits_X2(m:Multi_Int_X2):MULTI_INT_1W_U;
var	w	:MULTI_INT_1W_U;
begin
w:= nlz_words_X2(m);
if (w <= Multi_X2_max)
then Result:= nlz_bits(m.M_Value[Multi_X2_max-w]) + (w * MULTI_INT_1W_SIZE)
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
procedure RotateUp_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
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

	carry_bits_3:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

	carry_bits_4:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_3);

	v1.M_Value[0]:= (v1.M_Value[0] OR carry_bits_4);
	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateUp_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X2_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateUp_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X2(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X2(v1, NBits_count);
	end;
end;


(******************************************)
{
procedure Multi_Int_X2.RotateUp_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X2(v1, NBits);
end;
}

(******************************************)
procedure RotateUp(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
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

	carry_bits_3:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
	v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_2);

	carry_bits_4:= ((v1.M_Value[0] and carry_bits_mask) << NBits_carry);
	v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_3);

	v1.M_Value[3]:= (v1.M_Value[3] OR carry_bits_4);
	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateDown_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X2_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[0];
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateDown_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X2(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X2(v1, NBits_count);
end;


(******************************************)
{
procedure Multi_Int_X2.RotateDown_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X2(v1, NBits);
end;
}


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X2(v1, NBits);
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
carry_bits_mask:= (carry_bits_mask << NBits_carry);

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
and		(NWords <= Multi_X2_max) then
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
{
procedure Multi_Int_X2.ShiftUp_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X2(v1, NBits);
end;
}


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
and		(NWords <= Multi_X2_max) then
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
{
procedure Multi_Int_X2.ShiftDown_MultiBits(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X2(v1, NBits);
end;
}


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X2(v1, NBits);
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
class operator Multi_Int_X2.greaterthan(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X2.lessthan(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X2.equal(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X2(v1,v2);
end;


(******************************************)
class operator Multi_Int_X2.notequal(const v1,v2:Multi_Int_X2):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_X2(v1,v2));
end;


(******************************************)
procedure ansistring_to_Multi_Int_X2(const v1:ansistring; var mi:Multi_Int_X2);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X2_max] of MULTI_INT_2W_U;
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
while (n <= Multi_X2_max) do
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
while (n <= Multi_X2_max) do
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
while (n <= Multi_X2_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;
end;


(******************************************)
{
procedure Multi_Int_X2.Init(const v1:ansistring);
begin
ansistring_to_Multi_Int_X2(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X2.implicit(const v1:ansistring):Multi_Int_X2;
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
class operator Multi_Int_X2.implicit(const v1:MULTI_INT_4W_S):Multi_Int_X2;
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
class operator Multi_Int_X2.implicit(const v1:MULTI_INT_4W_U):Multi_Int_X2;
begin
MULTI_INT_4W_U_to_Multi_Int_X2(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X2(const v1:MULTI_INT_2W_S; var mi:Multi_Int_X2);
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
class operator Multi_Int_X2.implicit(const v1:MULTI_INT_2W_S):Multi_Int_X2;
begin
MULTI_INT_2W_S_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X2(const v1:MULTI_INT_2W_U; var mi:Multi_Int_X2);
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
class operator Multi_Int_X2.implicit(const v1:MULTI_INT_2W_U):Multi_Int_X2;
begin
MULTI_INT_2W_U_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Single):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X2.implicit(const v1:Real):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
	operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X2.implicit(const v1:Double):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
	operation_str	:ansistring;
begin
operation_str:= 'Multi_Int_X2.implicit';
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X2(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Single;
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
while	(i <= Multi_X2_max)
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Real;
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
while	(i <= Multi_X2_max)
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Double;
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
while	(i <= Multi_X2_max)
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):MULTI_INT_2W_S;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):MULTI_INT_2W_U;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):MULTI_INT_1W_S;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):MULTI_INT_1W_U;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Multi_int8u;
var	R	:Multi_int8u;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Multi_int8;
var	R	:Multi_int8;
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
procedure Multi_Int_X2_to_hex(const v1:Multi_Int_X2; var v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
procedure hex_to_Multi_Int_X2(const v1:ansistring; var mi:Multi_Int_X2);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X2_max] of MULTI_INT_2W_U;
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
while (n <= Multi_X2_max)
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
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_X2_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X2_max) do
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
while (n <= Multi_X2_max) do
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
procedure FromHex(const v1:ansistring; var v2:Multi_Int_X2); overload;
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
procedure Multi_Int_X2_to_ansistring(const v1:Multi_Int_X2; var v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X2_max] of MULTI_INT_2W_U;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):ansistring;
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
	M_Val	:array[0..Multi_X2_max] of MULTI_INT_2W_U;
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
	M_Val	:array[0..Multi_X2_max] of MULTI_INT_2W_S;
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


{$ifdef extended_inc_operator}

(******************************************)
class operator Multi_Int_X2.inc(const v1,v2:Multi_Int_X2):Multi_Int_X2;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Inc');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.dec(const v1,v2:Multi_Int_X2):Multi_Int_X2;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Dec');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;

{$endif}


(******************************************)
class operator Multi_Int_X2.add(const v1,v2:Multi_Int_X2):Multi_Int_X2;
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
class operator Multi_Int_X2.subtract(const v1,v2:Multi_Int_X2):Multi_Int_X2;
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


(******************************************)
procedure multiply_Multi_Int_X2(const v1,v2:Multi_Int_X2;var Result:Multi_Int_X2);
var
	M_Val	:array[0..Multi_X2_max_x2] of MULTI_INT_2W_U;
	tv1,tv2	:MULTI_INT_2W_U;
	i,j,k	:MULTI_INT_1W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0;
repeat M_Val[i]:= 0; INC(i); until (i > Multi_X2_max_x2);

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X2_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_X2_max);
	INC(j);
	i:=0;
until (j > Multi_X2_max);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X2_max) then
			begin
			Result.Overflow_flag:=TRUE;
			// Result.Defined_flag:= FALSE;
			end;
		end;
	INC(i);
until (i > Multi_X2_max_x2)
or (Result.Overflow_flag);

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
end;


(******************************************)
class operator Multi_Int_X2.multiply(const v1,v2:Multi_Int_X2):Multi_Int_X2;
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
procedure SqRoot(const v1:Multi_Int_X2;var VR,VREM:Multi_Int_X2);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X2;
R_EXACT,
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

R_EXACT:= FALSE;
finished:= FALSE;
while not finished do
	begin
	// C:= (L + ((H - L) div 2));
    T:= subtract_Multi_Int_X2(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X2(L,T);

	// CC:= (C * C);
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
			multiply_Multi_Int_X2(C,C, T);
			VREM:= subtract_Multi_Int_X2(v1,T);
			end
		end
	// else if (CC < v1) then
	else if ABS_lessthan_Multi_Int_X2(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X2(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_X2(C,C, T);
			VREM:= subtract_Multi_Int_X2(v1,T);
			end
		end
	else
		begin
		R_EXACT:= TRUE;
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
			// Y := TV * Y;
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
		// TV := TV * TV;
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
	// R:= (TV * Y);
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


(******************************************)
procedure intdivide_Shift_And_Sub_X2(const P_dividend,P_divisor:Multi_Int_X2;var P_quotient,P_remainder:Multi_Int_X2);
label	1000,9000,9999;
var
dividend,
divisor,
quotient,
quotient_factor,
next_dividend,
ZERO				:Multi_Int_X2;
T					:MULTI_INT_1W_U;
z,k					:MULTI_INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:MULTI_INT_2W_S;

begin
ZERO:= 0;
if	(P_divisor = ZERO) then
	begin
	P_quotient:= ZERO;
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
 	P_remainder:= ZERO;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_divisor = P_dividend) then
	begin
	P_quotient:= 1;
 	P_remainder:= ZERO;
    end
else
	begin
    dividend:= 0;
	divisor:= 0;
	z:= 0;
    i:= Multi_X2_max;
	while (i >= 0) do
		begin
		dividend.M_Value[i]:= P_dividend.M_Value[i];
		T:= P_divisor.M_Value[i];
		divisor.M_Value[i]:= T;
		if	(T <> 0) then z:= (z + i);
		Dec(i);
		end;
	dividend.Negative_flag:= FALSE;
	divisor.Negative_flag:= FALSE;

	if	(divisor > dividend) then
		begin
		P_quotient:= ZERO;
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	// single digit divisor
	if	(z = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X2_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(divisor.M_Value[0]));
			k:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(divisor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= k;
		goto 9000;
		end;

	quotient:= ZERO;
	P_remainder:= ZERO;
	quotient_factor:= 1;

	{ Round 0 }
	nlz_bits_dividend:= nlz_MultiBits_X2(dividend);
	nlz_bits_divisor:= nlz_MultiBits_X2(divisor);
	nlz_bits_P_divisor:= nlz_bits_divisor;
	nlz_bits_diff:= (nlz_bits_divisor - nlz_bits_dividend - 1);

	if	(nlz_bits_diff > ZERO) then
		begin
		ShiftUp_MultiBits_Multi_Int_X2(divisor, nlz_bits_diff);
		ShiftUp_MultiBits_Multi_Int_X2(quotient_factor, nlz_bits_diff);
		end
	else nlz_bits_diff:= ZERO;

	{ Round X }
	repeat
	1000:
		next_dividend:= (dividend - divisor);
		if (next_dividend >= ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			goto 1000;
			end;
		if (next_dividend = ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			end;

		nlz_bits_divisor:= nlz_MultiBits_X2(divisor);
		if (nlz_bits_divisor < nlz_bits_P_divisor) then
			begin
			nlz_bits_dividend:= nlz_MultiBits_X2(dividend);
			nlz_bits_diff:= (nlz_bits_dividend - nlz_bits_divisor + 1);

			if ((nlz_bits_divisor + nlz_bits_diff) > nlz_bits_P_divisor) then
				nlz_bits_diff:= (nlz_bits_P_divisor - nlz_bits_divisor);

			ShiftDown_MultiBits_Multi_Int_X2(divisor, nlz_bits_diff);
			ShiftDown_MultiBits_Multi_Int_X2(quotient_factor, nlz_bits_diff);
			end;
	until	(dividend < P_divisor)
	or		(nlz_bits_divisor >= nlz_bits_P_divisor)
	or		(divisor = ZERO)
	;

	P_quotient:= quotient;
	P_remainder:= dividend;

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_divisor.Negative_flag)
	and	(P_quotient > ZERO)
	then
		P_quotient.Negative_flag:= TRUE;
	end;
9999:
end;


(******************************************)
class operator Multi_Int_X2.intdivide(const v1,v2:Multi_Int_X2):Multi_Int_X2;
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
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);

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

{
// same values as last time

if	(X2_Last_Divisor = v2)
and	(X2_Last_Dividend = v1)
then
	Result:= X2_Last_Quotient
else
	begin
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);

	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;
}
end;


(******************************************)
class operator Multi_Int_X2.modulus(const v1,v2:Multi_Int_X2):Multi_Int_X2;
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
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);

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

{
// same values as last time

if	(X2_Last_Divisor = v2)
and	(X2_Last_Dividend = v1)
then
	Result:= X2_Last_Remainder
else
	begin
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);

	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;
}
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
i:= Multi_X3_max;
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
function nlz_MultiBits_X3(m:Multi_Int_X3):MULTI_INT_1W_U;
var	w,b	:MULTI_INT_1W_U;
begin
w:= nlz_words_X3(m);
if (w <= Multi_X3_max)
then Result:= nlz_bits(m.M_Value[Multi_X3_max-w]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
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
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_3:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

carry_bits_4:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_3);

carry_bits_5:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] << NBits) OR carry_bits_4);

carry_bits_6:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] << NBits) OR carry_bits_5);

v1.M_Value[0]:= (v1.M_Value[0] OR carry_bits_6);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateUp_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X3_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateUp_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X3(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X3(v1, NBits_count);
	end;
end;


(******************************************)
{
procedure Multi_Int_X3.RotateUp_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X3(v1, NBits);
end;
}


(******************************************)
procedure RotateUp(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
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

carry_bits_1:= ((v1.M_Value[5] and carry_bits_mask) << NBits_carry);
v1.M_Value[5]:= (v1.M_Value[5] >> NBits);

carry_bits_2:= ((v1.M_Value[4] and carry_bits_mask) << NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] >> NBits) OR carry_bits_1);

carry_bits_3:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] >> NBits) OR carry_bits_2);

carry_bits_4:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_3);

carry_bits_5:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_4);

carry_bits_6:= ((v1.M_Value[0] and carry_bits_mask) << NBits_carry);
v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_5);

v1.M_Value[5]:= (v1.M_Value[5] OR carry_bits_6);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateDown_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X3_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[0];
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[5];
		v1.M_Value[5]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X3(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X3(v1, NBits_count);
end;


(******************************************)
{
procedure Multi_Int_X3.RotateDown_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X3(v1, NBits);
end;
}


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
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
and		(NWords <= Multi_X3_max) then
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
and		(NWords <= Multi_X3_max) then
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
{
procedure Multi_Int_X3.ShiftUp_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X3(v1, NBits);
end;
}


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
{
procedure Multi_Int_X3.ShiftDown_MultiBits(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X3(v1, NBits);
end;
}


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X3(v1, NBits);
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
class operator Multi_Int_X3.greaterthan(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X3.lessthan(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X3.equal(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X3(v1,v2);
end;


(******************************************)
class operator Multi_Int_X3.notequal(const v1,v2:Multi_Int_X3):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= FALSE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= TRUE
else Result:= (not ABS_equal_Multi_Int_X3(v1,v2));
end;


(******************************************)
procedure ansistring_to_Multi_Int_X3(const v1:ansistring; var mi:Multi_Int_X3);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X3_max] of MULTI_INT_2W_U;
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
{
procedure Multi_Int_X3.Init(const v1:ansistring);
begin
ansistring_to_Multi_Int_X3(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X3.implicit(const v1:ansistring):Multi_Int_X3;
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
class operator Multi_Int_X3.implicit(const v1:MULTI_INT_4W_S):Multi_Int_X3;
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
class operator Multi_Int_X3.implicit(const v1:MULTI_INT_4W_U):Multi_Int_X3;
begin
MULTI_INT_4W_U_to_Multi_Int_X3(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X3(const v1:MULTI_INT_2W_S; var mi:Multi_Int_X3);
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
class operator Multi_Int_X3.implicit(const v1:MULTI_INT_2W_S):Multi_Int_X3;
begin
MULTI_INT_2W_S_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X3(const v1:MULTI_INT_2W_U; var mi:Multi_Int_X3);
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
class operator Multi_Int_X3.implicit(const v1:MULTI_INT_2W_U):Multi_Int_X3;
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
while (n <= Multi_X3_max) do
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
while (n <= Multi_X3_max) do
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
while (n <= Multi_X2_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X3_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X3(const v1:Multi_Int_X2; var MI:Multi_Int_X3);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
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
while (n <= Multi_X2_max) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X3_max) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X2):Multi_Int_X3;
begin
Multi_Int_X2_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Single):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X3.implicit(const v1:Real):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X3.implicit(const v1:Double):Multi_Int_X3;
var
R			:Multi_Int_X3;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X3(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Single;
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
while	(i <= Multi_X3_max)
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Real;
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
while	(i <= Multi_X3_max)
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Double;
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
while	(i <= Multi_X3_max)
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):MULTI_INT_2W_S;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):MULTI_INT_2W_U;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):MULTI_INT_1W_S;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):MULTI_INT_1W_U;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Multi_int8u;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Multi_int8;
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
procedure Multi_Int_X3_to_hex(const v1:Multi_Int_X3; var v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X3_max] of MULTI_INT_2W_U;
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
procedure hex_to_Multi_Int_X3(const v1:ansistring; var mi:Multi_Int_X3);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X3_max] of MULTI_INT_2W_U;
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
while (n <= Multi_X3_max)
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
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_X3_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X3_max) do
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
while (n <= Multi_X3_max) do
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
procedure FromHex(const v1:ansistring; var v2:Multi_Int_X3); overload;
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
procedure Multi_Int_X3_to_ansistring(const v1:Multi_Int_X3; var v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X3_max] of MULTI_INT_2W_U;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):ansistring;
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
	M_Val	:array[0..Multi_X3_max] of MULTI_INT_2W_U;
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
	M_Val	:array[0..Multi_X3_max] of MULTI_INT_2W_S;
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



{$ifdef extended_inc_operator}

(******************************************)
class operator Multi_Int_X3.inc(const v1,v2:Multi_Int_X3):Multi_Int_X3;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Inc');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.dec(const v1,v2:Multi_Int_X3):Multi_Int_X3;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;
{$endif}


(******************************************)
class operator Multi_Int_X3.add(const v1,v2:Multi_Int_X3):Multi_Int_X3;
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
class operator Multi_Int_X3.subtract(const v1,v2:Multi_Int_X3):Multi_Int_X3;
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


(******************************************)
procedure multiply_Multi_Int_X3(const v1,v2:Multi_Int_X3;var Result:Multi_Int_X3);
var
	M_Val	:array[0..Multi_X3_max_x2] of MULTI_INT_2W_U;
	tv1,tv2	:MULTI_INT_2W_U;
	i,j,k	:MULTI_INT_1W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0;
repeat M_Val[i]:= 0; INC(i); until (i > Multi_X3_max_x2);

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X3_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_X3_max);
	INC(j);
	i:=0;
until (j > Multi_X3_max);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X3_max) then
			begin
			Result.Overflow_flag:=TRUE;
			// Result.Defined_flag:= FALSE;
			end;
		end;
	INC(i);
until (i > Multi_X3_max_x2)
or (Result.Overflow_flag);

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
end;


(******************************************)
class operator Multi_Int_X3.multiply(const v1,v2:Multi_Int_X3):Multi_Int_X3;
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
procedure SqRoot(const v1:Multi_Int_X3;var VR,VREM:Multi_Int_X3);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X3;
R_EXACT,
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

R_EXACT:= FALSE;
finished:= FALSE;
while not finished do
	begin
	// C:= (L + ((H - L) div 2));
    T:= subtract_Multi_Int_X3(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X3(L,T);

	// CC:= (C * C);
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
			multiply_Multi_Int_X3(C,C, T);
			VREM:= subtract_Multi_Int_X3(v1,T);
			end
		end
	// else if (CC < v1) then
	else if ABS_lessthan_Multi_Int_X3(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X3(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_X3(C,C, T);
			VREM:= subtract_Multi_Int_X3(v1,T);
			end
		end
	else
		begin
		R_EXACT:= TRUE;
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
			// Y := TV * Y;
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
		// TV := TV * TV;
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
	// R:= (TV * Y);
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


(******************************************)
procedure intdivide_Shift_And_Sub_X3(const P_dividend,P_divisor:Multi_Int_X3;var P_quotient,P_remainder:Multi_Int_X3);
label	1000,9000,9999;
var
dividend,
divisor,
quotient,
quotient_factor,
next_dividend,
ZERO				:Multi_Int_X3;
T					:MULTI_INT_1W_U;
z,k					:MULTI_INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:MULTI_INT_2W_S;

begin
ZERO:= 0;
if	(P_divisor = ZERO) then
	begin
	P_quotient:= ZERO;
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
 	P_remainder:= ZERO;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_divisor = P_dividend) then
	begin
	P_quotient:= 1;
 	P_remainder:= ZERO;
    end
else
	begin
    dividend:= 0;
	divisor:= 0;
	z:= 0;
    i:= Multi_X3_max;
	while (i >= 0) do
		begin
		dividend.M_Value[i]:= P_dividend.M_Value[i];
		T:= P_divisor.M_Value[i];
		divisor.M_Value[i]:= T;
		if	(T <> 0) then z:= (z + i);
		Dec(i);
		end;
	dividend.Negative_flag:= FALSE;
	divisor.Negative_flag:= FALSE;

	if	(divisor > dividend) then
		begin
		P_quotient:= ZERO;
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	// single digit divisor
	if	(z = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X3_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(divisor.M_Value[0]));
			k:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(divisor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= k;
		goto 9000;
		end;

	quotient:= ZERO;
	P_remainder:= ZERO;
	quotient_factor:= 1;

	{ Round 0 }
	nlz_bits_dividend:= nlz_MultiBits_X3(dividend);
	nlz_bits_divisor:= nlz_MultiBits_X3(divisor);
	nlz_bits_P_divisor:= nlz_bits_divisor;
	nlz_bits_diff:= (nlz_bits_divisor - nlz_bits_dividend - 1);

	if	(nlz_bits_diff > ZERO) then
		begin
		ShiftUp_MultiBits_Multi_Int_X3(divisor, nlz_bits_diff);
		ShiftUp_MultiBits_Multi_Int_X3(quotient_factor, nlz_bits_diff);
		end
	else nlz_bits_diff:= ZERO;

	{ Round X }
	repeat
	1000:
		next_dividend:= (dividend - divisor);
		if (next_dividend >= ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			goto 1000;
			end;
		if (next_dividend = ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			end;

		nlz_bits_divisor:= nlz_MultiBits_X3(divisor);
		if (nlz_bits_divisor < nlz_bits_P_divisor) then
			begin
			nlz_bits_dividend:= nlz_MultiBits_X3(dividend);
			nlz_bits_diff:= (nlz_bits_dividend - nlz_bits_divisor + 1);

			if ((nlz_bits_divisor + nlz_bits_diff) > nlz_bits_P_divisor) then
				nlz_bits_diff:= (nlz_bits_P_divisor - nlz_bits_divisor);

			ShiftDown_MultiBits_Multi_Int_X3(divisor, nlz_bits_diff);
			ShiftDown_MultiBits_Multi_Int_X3(quotient_factor, nlz_bits_diff);
			end;
	until	(dividend < P_divisor)
	or		(nlz_bits_divisor >= nlz_bits_P_divisor)
	or		(divisor = ZERO)
	;
	P_quotient:= quotient;
	P_remainder:= dividend;

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_divisor.Negative_flag)
	and	(P_quotient > ZERO)
	then
		P_quotient.Negative_flag:= TRUE;
	end;
9999:
end;


(******************************************)
class operator Multi_Int_X3.intdivide(const v1,v2:Multi_Int_X3):Multi_Int_X3;
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
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);

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

{
// same values as last time

if	(X3_Last_Divisor = v2)
and	(X3_Last_Dividend = v1)
then
	Result:= X3_Last_Quotient
else
	begin
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);

	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;
}
end;


(******************************************)
class operator Multi_Int_X3.modulus(const v1,v2:Multi_Int_X3):Multi_Int_X3;
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
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);

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
{
// same values as last time

if	(X3_Last_Divisor = v2)
and	(X3_Last_Dividend = v1)
then
	Result:= X3_Last_Remainder
else
	begin
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);

	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;
}
end;


{
******************************************
Multi_Int_X4
******************************************
}


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
i:= Multi_X4_max;
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
function nlz_MultiBits_X4(m:Multi_Int_X4):MULTI_INT_1W_U;
var	w,b	:MULTI_INT_1W_U;
begin
w:= nlz_words_X4(m);
if (w <= Multi_X4_max)
then Result:= nlz_bits(m.M_Value[Multi_X4_max-w]) + (w * MULTI_INT_1W_SIZE)
else Result:= (w * MULTI_INT_1W_SIZE);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
	carry_bits_7,
	carry_bits_8,
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
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
begin

carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
v1.M_Value[0]:= (v1.M_Value[0] << NBits);

carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] << NBits) OR carry_bits_1);

carry_bits_3:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] << NBits) OR carry_bits_2);

carry_bits_4:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] << NBits) OR carry_bits_3);

carry_bits_5:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] << NBits) OR carry_bits_4);

carry_bits_6:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] << NBits) OR carry_bits_5);

carry_bits_7:= ((v1.M_Value[6] and carry_bits_mask) >> NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] << NBits) OR carry_bits_6);

carry_bits_8:= ((v1.M_Value[7] and carry_bits_mask) >> NBits_carry);
v1.M_Value[7]:= ((v1.M_Value[7] << NBits) OR carry_bits_7);

v1.M_Value[0]:= (v1.M_Value[0] OR carry_bits_8);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateUp_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X4_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[7];
		v1.M_Value[7]:= v1.M_Value[6];
		v1.M_Value[6]:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[0];
		v1.M_Value[0]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateUp_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X4(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X4(v1, NBits_count);
	end;
end;


(******************************************)
{
procedure Multi_Int_X4.RotateUp_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X4(v1, NBits);
end;
}


(******************************************)
procedure RotateUp(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
	carry_bits_7,
	carry_bits_8,
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

carry_bits_1:= ((v1.M_Value[7] and carry_bits_mask) << NBits_carry);
v1.M_Value[7]:= (v1.M_Value[7] >> NBits);

carry_bits_2:= ((v1.M_Value[6] and carry_bits_mask) << NBits_carry);
v1.M_Value[6]:= ((v1.M_Value[6] >> NBits) OR carry_bits_1);

carry_bits_3:= ((v1.M_Value[5] and carry_bits_mask) << NBits_carry);
v1.M_Value[5]:= ((v1.M_Value[5] >> NBits) OR carry_bits_2);

carry_bits_4:= ((v1.M_Value[4] and carry_bits_mask) << NBits_carry);
v1.M_Value[4]:= ((v1.M_Value[4] >> NBits) OR carry_bits_3);

carry_bits_5:= ((v1.M_Value[3] and carry_bits_mask) << NBits_carry);
v1.M_Value[3]:= ((v1.M_Value[3] >> NBits) OR carry_bits_4);

carry_bits_6:= ((v1.M_Value[2] and carry_bits_mask) << NBits_carry);
v1.M_Value[2]:= ((v1.M_Value[2] >> NBits) OR carry_bits_5);

carry_bits_7:= ((v1.M_Value[1] and carry_bits_mask) << NBits_carry);
v1.M_Value[1]:= ((v1.M_Value[1] >> NBits) OR carry_bits_6);

carry_bits_8:= ((v1.M_Value[0] and carry_bits_mask) << NBits_carry);
v1.M_Value[0]:= ((v1.M_Value[0] >> NBits) OR carry_bits_7);

v1.M_Value[7]:= (v1.M_Value[7] OR carry_bits_8);

end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateDown_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X4_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		t:= v1.M_Value[0];
		v1.M_Value[0]:= v1.M_Value[1];
		v1.M_Value[1]:= v1.M_Value[2];
		v1.M_Value[2]:= v1.M_Value[3];
		v1.M_Value[3]:= v1.M_Value[4];
		v1.M_Value[4]:= v1.M_Value[5];
		v1.M_Value[5]:= v1.M_Value[6];
		v1.M_Value[6]:= v1.M_Value[7];
		v1.M_Value[7]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin

if (NBits >= MULTI_INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
	NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X4(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X4(v1, NBits_count);
end;


(******************************************)
{
procedure Multi_Int_X4.RotateDown_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X4(v1, NBits);
end;
}


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
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
and		(NWords <= Multi_X4_max) then
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
and		(NWords <= Multi_X4_max) then
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
{
procedure Multi_Int_X4.ShiftUp_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X4(v1, NBits);
end;
}


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
{
procedure Multi_Int_X4.ShiftDown_MultiBits(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X4(v1, NBits);
end;
}


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X4(v1, NBits);
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
class operator Multi_Int_X4.greaterthan(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X4.lessthan(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_X4.equal(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_X4(v1,v2);
end;


(******************************************)
class operator Multi_Int_X4.notequal(const v1,v2:Multi_Int_X4):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
then
	begin
	Result:=FALSE;
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
while (n <= Multi_X4_max) do
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
while (n <= Multi_X3_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_max) do
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
while (n <= Multi_X2_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X4(const v1:Multi_Int_X2; var MI:Multi_Int_X4);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	MI.Overflow_flag:= TRUE;
	exit;
	end;

n:= 0;
while (n <= Multi_X2_max) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_max) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X2):Multi_Int_X4;
begin
Multi_Int_X2_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_X4(const v1:Multi_Int_X3; var MI:Multi_Int_X4);
var
	n				:MULTI_INT_1W_U;
begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	MI.Overflow_flag:= TRUE;
	exit;
	end;

n:= 0;
while (n <= Multi_X3_max) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_X4_max) do
	begin
	MI.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X3):Multi_Int_X4;
begin
Multi_Int_X3_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure ansistring_to_Multi_Int_X4(const v1:ansistring; var mi:Multi_Int_X4);
label 999;
var
	i,b,c,e		:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
{
procedure Multi_Int_X4.Init(const v1:ansistring);
begin
ansistring_to_Multi_Int_X4(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X4.implicit(const v1:ansistring):Multi_Int_X4;
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
class operator Multi_Int_X4.implicit(const v1:MULTI_INT_4W_S):Multi_Int_X4;
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
class operator Multi_Int_X4.implicit(const v1:MULTI_INT_4W_U):Multi_Int_X4;
begin
MULTI_INT_4W_U_to_Multi_Int_X4(v1,Result);
end;
{$endif}


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_X4(const v1:MULTI_INT_2W_S; var mi:Multi_Int_X4);
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
class operator Multi_Int_X4.implicit(const v1:MULTI_INT_2W_S):Multi_Int_X4;
begin
MULTI_INT_2W_S_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_X4(const v1:MULTI_INT_2W_U; var mi:Multi_Int_X4);
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
class operator Multi_Int_X4.implicit(const v1:MULTI_INT_2W_U):Multi_Int_X4;
begin
MULTI_INT_2W_U_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Single):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X4.implicit(const v1:Real):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X4.implicit(const v1:Double):Multi_Int_X4;
var
R			:Multi_Int_X4;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_X4(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

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
while	(i <= Multi_X4_max)
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Real;
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
while	(i <= Multi_X4_max)
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Double;
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
while	(i <= Multi_X4_max)
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):MULTI_INT_2W_S;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):MULTI_INT_2W_U;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):MULTI_INT_1W_S;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):MULTI_INT_1W_U;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Multi_int8u;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Multi_int8;
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
procedure Multi_Int_X4_to_hex(const v1:Multi_Int_X4; var v2:ansistring; LZ:T_Multi_Leading_Zeros);
var
	s		:ansistring = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
procedure hex_to_Multi_Int_X4(const v1:ansistring; var mi:Multi_Int_X4);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
while (n <= Multi_X4_max)
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
		while (n <= Multi_X4_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X4_max) do
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
while (n <= Multi_X4_max) do
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
procedure FromHex(const v1:ansistring; var v2:Multi_Int_X4); overload;
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
procedure Multi_Int_X4_to_ansistring(const v1:Multi_Int_X4; var v2:ansistring);
var
	s		:ansistring = '';
	M_Val	:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):ansistring;
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
	M_Val	:array[0..Multi_X4_max] of MULTI_INT_2W_U;
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
	M_Val	:array[0..Multi_X4_max] of MULTI_INT_2W_S;
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



{$ifdef extended_inc_operator}

(******************************************)
class operator Multi_Int_X4.inc(const v1, v2:Multi_Int_X4):Multi_Int_X4;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Inc');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.dec(const v1, v2:Multi_Int_X4):Multi_Int_X4;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;
{$endif}


(******************************************)
class operator Multi_Int_X4.add(const v1,v2:Multi_Int_X4):Multi_Int_X4;
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
class operator Multi_Int_X4.subtract(const v1,v2:Multi_Int_X4):Multi_Int_X4;
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


(******************************************)
procedure multiply_Multi_Int_X4(const v1,v2:Multi_Int_X4;var Result:Multi_Int_X4);
var
	M_Val	:array[0..Multi_X4_max_x2] of MULTI_INT_2W_U;
	tv1,tv2	:MULTI_INT_2W_U;
	i,j,k	:MULTI_INT_1W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0;
repeat M_Val[i]:= 0; INC(i); until (i > Multi_X4_max_x2);

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X4_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_X4_max);
	INC(j);
	i:=0;
until (j > Multi_X4_max);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X4_max) then
			begin
			Result.Overflow_flag:=TRUE;
			// Result.Defined_flag:= FALSE;
			end;
		end;
	INC(i);
until (i > Multi_X4_max_x2)
or (Result.Overflow_flag);

Result.M_Value[0]:= M_Val[0];
Result.M_Value[1]:= M_Val[1];
Result.M_Value[2]:= M_Val[2];
Result.M_Value[3]:= M_Val[3];
Result.M_Value[4]:= M_Val[4];
Result.M_Value[5]:= M_Val[5];
Result.M_Value[6]:= M_Val[6];
Result.M_Value[7]:= M_Val[7];
end;


(******************************************)
class operator Multi_Int_X4.multiply(const v1,v2:Multi_Int_X4):Multi_Int_X4;
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


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X4;var VR,VREM:Multi_Int_X4);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_X4;
R_EXACT,
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

R_EXACT:= FALSE;
finished:= FALSE;
while not finished do
	begin
	// C:= (L + ((H - L) div 2));
    T:= subtract_Multi_Int_X4(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X4(L,T);

	// CC:= (C * C);
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
			multiply_Multi_Int_X4(C,C, T);
			VREM:= subtract_Multi_Int_X4(v1,T);
			end
		end
	// else if (CC < v1) then
	else if ABS_lessthan_Multi_Int_X4(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X4(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_X4(C,C, T);
			VREM:= subtract_Multi_Int_X4(v1,T);
			end
		end
	else
		begin
		R_EXACT:= TRUE;
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
			// Y := TV * Y;
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
		// TV := TV * TV;
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
	// R:= (TV * Y);
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


(******************************************)
procedure intdivide_Shift_And_Sub_X4(const P_dividend,P_divisor:Multi_Int_X4;var P_quotient,P_remainder:Multi_Int_X4);
label	1000,9000,9999;
var
dividend,
divisor,
quotient,
quotient_factor,
next_dividend,
ZERO				:Multi_Int_X4;
T					:MULTI_INT_1W_U;
z,k					:MULTI_INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:MULTI_INT_2W_S;

begin
ZERO:= 0;
if	(P_divisor = ZERO) then
	begin
	P_quotient:= ZERO;
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
 	P_remainder:= ZERO;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_divisor = P_dividend) then
	begin
	P_quotient:= 1;
 	P_remainder:= ZERO;
    end
else
	begin
    dividend:= 0;
	divisor:= 0;
	z:= 0;
    i:= Multi_X4_max;
	while (i >= 0) do
		begin
		dividend.M_Value[i]:= P_dividend.M_Value[i];
		T:= P_divisor.M_Value[i];
		divisor.M_Value[i]:= T;
		if	(T <> 0) then z:= (z + i);
		Dec(i);
		end;
	dividend.Negative_flag:= FALSE;
	divisor.Negative_flag:= FALSE;

	if	(divisor > dividend) then
		begin
		P_quotient:= ZERO;
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	// single digit divisor
	if	(z = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X4_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(divisor.M_Value[0]));
			k:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(divisor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= k;
		goto 9000;
		end;

	quotient:= ZERO;
	P_remainder:= ZERO;
	quotient_factor:= 1;

	{ Round 0 }
	nlz_bits_dividend:= nlz_MultiBits_X4(dividend);
	nlz_bits_divisor:= nlz_MultiBits_X4(divisor);
	nlz_bits_P_divisor:= nlz_bits_divisor;
	nlz_bits_diff:= (nlz_bits_divisor - nlz_bits_dividend - 1);

	if	(nlz_bits_diff > ZERO) then
		begin
		ShiftUp_MultiBits_Multi_Int_X4(divisor, nlz_bits_diff);
		ShiftUp_MultiBits_Multi_Int_X4(quotient_factor, nlz_bits_diff);
		end
	else nlz_bits_diff:= ZERO;

	{ Round X }
	repeat
	1000:
		next_dividend:= (dividend - divisor);
		if (next_dividend >= ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			goto 1000;
			end;
		if (next_dividend = ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			end;

		nlz_bits_divisor:= nlz_MultiBits_X4(divisor);
		if (nlz_bits_divisor < nlz_bits_P_divisor) then
			begin
			nlz_bits_dividend:= nlz_MultiBits_X4(dividend);
			nlz_bits_diff:= (nlz_bits_dividend - nlz_bits_divisor + 1);

			if ((nlz_bits_divisor + nlz_bits_diff) > nlz_bits_P_divisor) then
				nlz_bits_diff:= (nlz_bits_P_divisor - nlz_bits_divisor);

			ShiftDown_MultiBits_Multi_Int_X4(divisor, nlz_bits_diff);
			ShiftDown_MultiBits_Multi_Int_X4(quotient_factor, nlz_bits_diff);
			end;
	until	(dividend < P_divisor)
	or		(nlz_bits_divisor >= nlz_bits_P_divisor)
	or		(divisor = ZERO)
	;

	P_quotient:= quotient;
	P_remainder:= dividend;

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_divisor.Negative_flag)
	and	(P_quotient > ZERO)
	then
		P_quotient.Negative_flag:= TRUE;
	end;
9999:
end;


(******************************************)
class operator Multi_Int_X4.intdivide(const v1,v2:Multi_Int_X4):Multi_Int_X4;
var
	P_v1,
	P_v2,
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
	intdivide_Shift_And_Sub_X4(v1,v2,Quotient,Remainder);

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

{
// same values as last time

P_v1:= v1;
P_v2:= v2;

if	(X4_Last_Divisor = P_v2)
and	(X4_Last_Dividend = P_v1)
then
	Result:= X4_Last_Quotient
else
	begin
	intdivide_Shift_And_Sub_X4(P_v1,P_v2,Quotient,Remainder);

	X4_Last_Divisor:= P_v2;
	X4_Last_Dividend:= P_v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;
}
end;


(******************************************)
class operator Multi_Int_X4.modulus(const v1,v2:Multi_Int_X4):Multi_Int_X4;
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
	intdivide_Shift_And_Sub_X4(v1,v2,Quotient,Remainder);

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

{
// same values as last time

if	(X4_Last_Divisor = v2)
and	(X4_Last_Dividend = v1)
then
	Result:= X4_Last_Remainder
else
	begin
	intdivide_Shift_And_Sub_X4(v1,v2,Quotient,Remainder);

	X4_Last_Divisor:= v2;
	X4_Last_Dividend:= v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;
}
end;


{
******************************************
Multi_Int_XV
******************************************
}


(******************************************)
procedure Multi_Int_XV.init;
begin
if	(Multi_Init_Initialisation_count = 0) then
	begin
	Raise EInterror.create('Multi_Init_Initialisation has not been called');
	exit;
	end;
if (Multi_XV_size < 2) then
	begin
	Raise EInterror.create('Multi_XV_size must be > 1');
	exit;
	end;
setlength(self.M_Value, Multi_XV_size);
self.Negative_flag:= Multi_UBool_FALSE;
self.Overflow_flag:= FALSE;
self.Defined_flag:= FALSE;
Multi_Int_XV_VARS_CREATED:= TRUE;
end;


function ABS_greaterthan_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
	i	:MULTI_INT_2W_U;
begin
i:= Multi_XV_max;
while (i > 0) do
	begin
	if	(v1.M_Value[i] > v2.M_Value[i])
	then begin Result:=TRUE; exit; end
	else
		if	(v1.M_Value[i] < v2.M_Value[i])
		then begin Result:=FALSE; exit; end;
	dec(i);
	end;
if	(v1.M_Value[0] > v2.M_Value[0])
then begin Result:=TRUE; exit; end
else begin Result:=FALSE; exit; end;

end;


(******************************************)
function ABS_lessthan_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
	i	:MULTI_INT_2W_U;
begin
i:= Multi_XV_max;
while (i > 0) do
	begin
	if	(v1.M_Value[i] < v2.M_Value[i])
	then begin Result:=TRUE; exit; end
	else
		if	(v1.M_Value[i] > v2.M_Value[i])
		then begin Result:=FALSE; exit; end;
	dec(i);
	end;
if	(v1.M_Value[0] < v2.M_Value[0])
then begin Result:=TRUE; exit; end
else begin Result:=FALSE; exit; end;
end;


(******************************************)
function nlz_words_XV(const m:Multi_Int_XV):MULTI_INT_1W_U; // v2
var
i,n		:Multi_int32;
fini	:boolean;
begin
n:= 0;
i:= Multi_XV_max;
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
function nlz_MultiBits_XV(const m:Multi_Int_XV):MULTI_INT_1W_U;
var	w,b	:MULTI_INT_1W_U;
begin
w:= nlz_words_XV(m);
if (w <= Multi_XV_max)
then Result:= nlz_bits(m.M_Value[Multi_XV_max-w]) + (w * MULTI_INT_1W_SIZE)
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
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[0]:= (v1.M_Value[0] << NBits);

	n:=1;
	while (n < Multi_XV_max) do
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
and		(NWords <= Multi_XV_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=Multi_XV_max;
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
{
procedure Multi_Int_XV.ShiftUp_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_XV(v1, NBits);
end;
}


{******************************************}
procedure ShiftUp(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_XV(v1, NBits);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
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
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[0]:= (v1.M_Value[0] << NBits);

	n:=1;
	while (n <= Multi_XV_max) do
		begin
		carry_bits_2:= ((v1.M_Value[n] and carry_bits_mask) >> NBits_carry);
		v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);
		carry_bits_1:= carry_bits_2;
		inc(n);
		end;

	v1.M_Value[0]:= (v1.M_Value[0] OR carry_bits_1);
	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateUp_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_1W_U);
var	i,n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_XV_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=Multi_XV_max;
		t:= v1.M_Value[i];
		while (i > 0) do
			begin
			v1.M_Value[i]:= v1.M_Value[i-1];
			dec(i);
			end;
		v1.M_Value[i]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateUp_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_XV(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_XV(v1, NBits_count);
	end;
end;


(******************************************)
{
procedure Multi_Int_XV.RotateUp_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_XV(v1, NBits);
end;
}


(******************************************)
procedure RotateUp(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_XV(v1, NBits);
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
	n:=Multi_XV_max;
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
and		(NWords <= Multi_XV_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=0;
		while (i < Multi_XV_max) do
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
{
procedure Multi_Int_XV.ShiftDown_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_XV(v1, NBits);
end;
}


{******************************************}
procedure ShiftDown(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_XV(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
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
	n:=Multi_XV_max;
	carry_bits_1:= ((v1.M_Value[n] and carry_bits_mask) << NBits_carry);
	v1.M_Value[n]:= (v1.M_Value[n] >> NBits);

	dec(n);
	while (n >= 0) do
		begin
		carry_bits_2:= ((v1.M_Value[n] and carry_bits_mask) << NBits_carry);
		v1.M_Value[n]:= ((v1.M_Value[n] >> NBits) OR carry_bits_1);
		carry_bits_1:= carry_bits_2;
		dec(n);
		end;

	v1.M_Value[Multi_XV_max]:= (v1.M_Value[Multi_XV_max] OR carry_bits_1);

	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateDown_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_1W_U);
var	i,n,t	:MULTI_INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_XV_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=0;
		t:= v1.M_Value[i];
		while (i < Multi_XV_max) do
			begin
			v1.M_Value[i]:= v1.M_Value[i+1];
			inc(i);
			end;
		v1.M_Value[i]:= t;
		DEC(n);
		end;
	end;
end;


{******************************************}
procedure RotateDown_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
var
NWords_count,
NBits_count		:MULTI_INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= MULTI_INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV MULTI_INT_1W_SIZE);
		NBits_count:= (NBits MOD MULTI_INT_1W_SIZE);
		RotateDown_NWords_Multi_Int_XV(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateDown_NBits_Multi_Int_XV(v1, NBits_count);
	end;
end;


(******************************************)
{
procedure Multi_Int_XV.RotateDown_MultiBits(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_XV(v1, NBits);
end;
}


(******************************************)
procedure RotateDown(var v1:Multi_Int_XV; NBits:MULTI_INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_XV(v1, NBits);
end;


(******************************************)
class operator Multi_Int_XV.greaterthan(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
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
class operator Multi_Int_XV.lessthan(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
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
	i	:MULTI_INT_2W_U;
begin
Result:=TRUE;
i:=0;
while (i <= Multi_XV_max) do
	begin
	if	(v1.M_Value[i] <> v2.M_Value[i]) then
		begin
		Result:=FALSE;
		exit;
		end;
	inc(i);
	end;
end;


(******************************************)
function ABS_notequal_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.equal(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
	exit;
	end;

Result:= TRUE;
if ( v1.Negative_flag <> v2.Negative_flag )
then Result:= FALSE
else Result:= ABS_equal_Multi_Int_XV(v1,v2);
end;


(******************************************)
class operator Multi_Int_XV.notequal(const v1,v2:Multi_Int_XV):Boolean;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(v1.Overflow_flag)
or	(v2.Overflow_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
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
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
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
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
then
	begin
	Result:=FALSE;
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
procedure ansistring_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

setlength(M_Val, Multi_XV_size);
mi.init;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_XV_max)
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
					if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
						begin
						Raise;
						end;
					end;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 10) + i;
		n:=1;
		while (n <= Multi_XV_max) do
			begin
			M_Val[n]:=(M_Val[n] * 10);
			inc(n);
			end;

		n:=0;
		while (n < Multi_XV_max) do
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
while (n <= Multi_XV_max) do
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
class operator Multi_Int_XV.implicit(const v1:ansistring):Multi_Int_XV;
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
setlength(M_Val, Multi_XV_size);

if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

n:=0;
while (n <= Multi_XV_max) do
	begin
	t:= v1.M_Value[n];
	M_Val[n]:= t;
	inc(n);
	end;

repeat
	n:= Multi_XV_max;
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):ansistring;
begin
Multi_Int_XV_to_ansistring(v1, Result);
end;


(******************************************)
procedure hex_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV);
label 999;
var
	n,i,b,c,e
				:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

setlength(M_Val, Multi_XV_size);
mi.init;

mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_XV_max)
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
				mi.Defined_flag:= FALSE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					Raise;
			end;
		if mi.Defined_flag = FALSE then goto 999;

		M_Val[0]:=(M_Val[0] * 16) + i;
		n:=1;
		while (n <= Multi_XV_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_XV_max) do
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
				Raise EIntOverflow.create('Overflow on hex string conversion');
			goto 999;
			end;
		Inc(c);
		end;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_XV_max) do
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
procedure FromHex(const v1:ansistring; var v2:Multi_Int_XV); overload;
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
or	(length(v1.M_Value) <> Multi_XV_size)
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
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

n:= (MULTI_INT_1W_SIZE div 4);
s:= '';

i:=Multi_XV_max;
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
procedure MULTI_INT_2W_S_to_Multi_Int_XV(const v1:MULTI_INT_2W_S; var mi:Multi_Int_XV);
var
	n				:MULTI_INT_2W_U;
begin
mi.init;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;

n:=2;
while (n <= Multi_XV_max) do
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
class operator Multi_Int_XV.implicit(const v1:MULTI_INT_2W_S):Multi_Int_XV;
begin
MULTI_INT_2W_S_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_XV(const v1:MULTI_INT_2W_U; var mi:Multi_Int_XV);
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
while (n <= Multi_XV_max) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:MULTI_INT_2W_U):Multi_Int_XV;
begin
MULTI_INT_2W_U_to_Multi_Int_XV(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_XV(const v1:MULTI_INT_4W_S; var mi:Multi_Int_XV);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;
begin
mi.init;
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

n:=4;
while (n <= Multi_XV_max) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;

end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:MULTI_INT_4W_S):Multi_Int_XV;
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
while (n <= Multi_XV_max) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:MULTI_INT_4W_U):Multi_Int_XV;
begin
MULTI_INT_4W_U_to_Multi_Int_XV(v1,Result);
end;
{$endif}


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X4):Multi_Int_XV;
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
while (n <= Multi_X4_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X3):Multi_Int_XV;
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
while (n <= Multi_X3_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X2):Multi_Int_XV;
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
while (n <= Multi_X2_max) do
	begin
	Result.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X4_to_Multi_Int_XV(const v1:Multi_Int_X4; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
mi.init;
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	MI.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
	exit;
	end;

if	(Multi_XV_max < Multi_X4_max) then
	begin
	n:= 0;
	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while	(n <= Multi_X4_max)
	and		(not MI.Overflow_flag)
	do
		begin
		if	(v1.M_Value[n] > 0) then
			begin
			MI.Defined_flag:= FALSE;
			MI.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int_X4 conversion');
				end;
			break;
			end;
		inc(n);
		end;
	end
else
	begin
	n:= 0;
	while (n <= Multi_X4_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;

	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:Multi_Int_X4):Multi_Int_XV;
begin
Multi_Int_X4_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_XV(const v1:Multi_Int_X3; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
mi.init;
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	MI.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
	exit;
	end;

if	(Multi_XV_max < Multi_X3_max) then
	begin
	n:= 0;
	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while	(n <= Multi_X3_max)
	and		(not MI.Overflow_flag)
	do
		begin
		if	(v1.M_Value[n] > 0) then
			begin
			MI.Defined_flag:= FALSE;
			MI.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int_X3 conversion');
				end;
			break;
			end;
		inc(n);
		end;
	end
else
	begin
	n:= 0;
	while (n <= Multi_X3_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;

	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:Multi_Int_X3):Multi_Int_XV;
begin
Multi_Int_X3_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_XV(const v1:Multi_Int_X2; var MI:Multi_Int_XV);
var
	n				:MULTI_INT_1W_U;
begin
mi.init;
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

if	(v1.Defined_flag = FALSE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	MI.Defined_flag:= FALSE;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	MI.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
	exit;
	end;

if	(Multi_XV_max < Multi_X2_max) then
	begin
	n:= 0;
	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while	(n <= Multi_X2_max)
	and		(not MI.Overflow_flag)
	do
		begin
		if	(v1.M_Value[n] > 0) then
			begin
			MI.Defined_flag:= FALSE;
			MI.Overflow_flag:= TRUE;
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow on Multi_Int_X2 conversion');
				end;
			break;
			end;
		inc(n);
		end;
	end
else
	begin
	n:= 0;
	while (n <= Multi_X2_max) do
		begin
		MI.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;

	while (n <= Multi_XV_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:Multi_Int_X2):Multi_Int_XV;
begin
Multi_Int_X2_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):Single;
var
R,V,M		:Single;
i			:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(i <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):Real;
var
	R,V,M	:Real;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(i <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):Double;
var
	R,V,M	:Double;
	i		:MULTI_INT_1W_U;
finished	:boolean;
begin
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(i <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Single):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

Result.init;
FloatToDecimal(R_FLOATREC, v1, MULTI_SINGLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

if (R.Overflow) then
	begin
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on single to Multi_Int conversion on ' + operation_str);
		end;
	exit;
	end;

if (R_FLOATREC.Negative) then R.Negative_flag := TRUE;
Result:= R;
end;


(******************************************)
class operator Multi_Int_XV.implicit(const v1:Real):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

Result.init;
FloatToDecimal(R_FLOATREC, v1, MULTI_REAL_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_XV.implicit(const v1:Double):Multi_Int_XV;
var
R			:Multi_Int_XV;
R_FLOATREC	:TFloatRec;
var operation_str	:ansistring;
begin
{$WARNING Float to Multi_Int type conversion loses some precision }

Multi_Int_ERROR:= FALSE;

Result.init;
FloatToDecimal(R_FLOATREC, v1, MULTI_DOUBLE_TYPE_PRECISION_DIGITS, 0);
ansistring_to_Multi_Int_XV(AddCharR('0',R_FLOATREC.digits,R_FLOATREC.Exponent), R);

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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):MULTI_INT_2W_S;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;

begin
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(n <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):MULTI_INT_2W_U;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(n <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):MULTI_INT_1W_S;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(n <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):MULTI_INT_1W_U;
var
	R	:MULTI_INT_2W_U;
	n	:MULTI_INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
or	(length(v1.M_Value) <> Multi_XV_size)
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
while	(n <= Multi_XV_max)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):Multi_int8u;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
or	(length(v1.M_Value) <> Multi_XV_size)
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
class operator Multi_Int_XV.implicit(const v1:Multi_Int_XV):Multi_int8;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
or	(length(v1.M_Value) <> Multi_XV_size)
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
var
	tv1,
	tv2,
	n			:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
setlength(M_Val, Multi_XV_size);
Result.init;
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

n:=1;
while (n < Multi_XV_max) do
	begin
	tv1:= v1.M_Value[n];
	tv2:= v2.M_Value[n];
	M_Val[n]:=(M_Val[n] + tv1 + tv2);
	if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
		begin
		M_Val[n+1]:= (M_Val[n] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[n]:= (M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
		end
	else M_Val[n+1]:= 0;

	inc(n);
	end;

tv1:= v1.M_Value[n];
tv2:= v2.M_Value[n];
M_Val[n]:=(M_Val[n] + tv1 + tv2);
if	M_Val[n] > MULTI_INT_1W_U_MAXINT then
	begin
	M_Val[n]:= (M_Val[n] MOD MULTI_INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	if M_Val[n] <> 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_XV(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
//	M_Val	:array[0..Multi_XV_max] of MULTI_INT_2W_S;
	M_Val		:array of MULTI_INT_2W_S;
	n		:MULTI_INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
setlength(M_Val, Multi_XV_size);
Result.init;
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

n:=1;
while (n < Multi_XV_max) do
	begin
	M_Val[n]:=((v1.M_Value[n] - v2.M_Value[n]) + M_Val[n]);
	if	M_Val[n] < 0 then
		begin
		M_Val[n+1]:= -1;
		M_Val[n]:= (M_Val[n] + MULTI_INT_1W_U_MAXINT_1);
		end
	else M_Val[n+1]:= 0;

	inc(n);
	end;

M_Val[n]:=(v1.M_Value[n] - v2.M_Value[n] + M_Val[n]);
if	M_Val[n] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

M_Val_All_Zero:=TRUE;
n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;
end;


(******************************************)
class operator Multi_Int_XV.add(const v1,v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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
or	(length(v1.M_Value) <> Multi_XV_size)
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



{$ifdef extended_inc_operator}

(******************************************)
class operator Multi_Int_XV.inc(const v1, v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Inc');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_XV.dec(const v1, v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg	:Multi_UBool_Values;
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on inc');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;
{$endif}


(******************************************)
class operator Multi_Int_XV.subtract(const v1,v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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
or	(length(v1.M_Value) <> Multi_XV_size)
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
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_XV.xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
	n		:MULTI_INT_2W_U;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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

n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:=(v1.M_Value[n] xor v2.M_Value[n]);
	inc(n);
	end;

Result.Defined_flag:=TRUE;
Result.Overflow_flag:=FALSE;
if (v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:= Multi_UBool_TRUE;
end;


(*******************v3*********************)
procedure multiply_Multi_Int_XV(const v1,v2:Multi_Int_XV;var Result:Multi_Int_XV);
label	999;
var
M_Val		:array of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,
jz,iz		:MULTI_INT_1W_S;
zf			:boolean;
begin
setlength(M_Val, Multi_XV_size_x2);
Result.init;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_XV_max_x2);

zf:= FALSE;
i:= Multi_XV_max;
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
i:= Multi_XV_max;
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
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > iz);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_XV_max);
	i:=0;
	INC(j);
// until (j > Multi_XV_max);
until (j > jz);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_XV_max) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_XV_max_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:

end;


(*******************v2*********************)
procedure multiply_Multi_Int_XV_v2(const v1,v2:Multi_Int_XV;var Result:Multi_Int_XV);
label	999;
var
//	M_Val	:array[0..Multi_XV_max_x2] of MULTI_INT_2W_U;
M_Val		:array of MULTI_INT_2W_U;
tv1,tv2		:MULTI_INT_2W_U;
i,j,k,n,z	:MULTI_INT_1W_S;
zf			:boolean;
begin
setlength(M_Val, Multi_XV_size_x2);
Result.init;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0; repeat M_Val[i]:= 0; INC(i); until (i > Multi_XV_max_x2);

zf:= FALSE;
i:= Multi_XV_max;
z:= -1;
repeat
	if	(v2.M_Value[i] <> 0) then
		begin
		z:= i;
		zf:= TRUE;
		end;
	DEC(i);
until	(i < 0)
or		(zf)
;
if	(z < 0) then
	begin
	Result.Negative_flag:=Multi_UBool_FALSE;
	goto 999;
	end;

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_XV_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_XV_max);
	i:=0;
	INC(j);
// until (j > Multi_XV_max);
until (j > z);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_XV_max) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_XV_max_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

999:

end;


(******************v1**********************)
procedure multiply_Multi_Int_XV_v1(const v1,v2:Multi_Int_XV;var Result:Multi_Int_XV);
var
//	M_Val	:array[0..Multi_XV_max_x2] of MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	tv1,tv2	:MULTI_INT_2W_U;
	i,j,k,n	:MULTI_INT_1W_U;
begin
setlength(M_Val, Multi_XV_size_x2);
Result.init;
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0;
repeat M_Val[i]:= 0; INC(i); until (i > Multi_XV_max_x2);

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV MULTI_INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD MULTI_INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_XV_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV MULTI_INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD MULTI_INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_XV_max);
	INC(j);
	i:=0;
until (j > Multi_XV_max);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_XV_max) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_XV_max_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_XV_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

end;


(******************************************)
class operator Multi_Int_XV.multiply(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var	  R:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_XV;var VR,VREM:Multi_Int_XV);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,C,CC,T	:Multi_Int_XV;
R_EXACT,
finished		:boolean;
begin
if	(Not v1.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
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

R_EXACT:= FALSE;
finished:= FALSE;
while not finished do
	begin
	// C:= (L + ((H - L) div 2));
    T:= subtract_Multi_Int_XV(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_XV(L,T);

	// CC:= (C * C);
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
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_XV(C,C, T);
			VREM:= subtract_Multi_Int_XV(v1,T);
			end
		end
	// else if (CC < v1) then
	else if ABS_lessthan_Multi_Int_XV(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_XV(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_XV(C,C, T);
			VREM:= subtract_Multi_Int_XV(v1,T);
			end
		end
	else
		begin
		R_EXACT:= TRUE;
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
or	(length(v1.M_Value) <> Multi_XV_size)
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
			// Y := TV * Y;
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
		// TV := TV * TV;
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
	// R:= (TV * Y);
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


(********************v4********************)
procedure intdivide_Shift_And_Sub_XV(const P_dividend,P_divisor:Multi_Int_XV;var P_quotient,P_remainder:Multi_Int_XV);
label	1000,9000,9999;
var
dividend,
divisor,
quotient,
quotient_factor,
next_dividend,
ZERO				:Multi_Int_XV;
T					:MULTI_INT_1W_U;
z,k					:MULTI_INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:MULTI_INT_2W_S;

begin
ZERO:= 0;
if	(P_divisor = ZERO) then
	begin
	P_quotient:= ZERO;
	P_quotient.Defined_flag:= FALSE;
	P_quotient.Overflow_flag:= TRUE;
 	P_remainder:= ZERO;
	P_remainder.Defined_flag:= FALSE;
	P_remainder.Overflow_flag:= TRUE;
	Multi_Int_ERROR:= TRUE;
    end
else if	(P_divisor = P_dividend) then
	begin
	P_quotient:= 1;
 	P_remainder:= ZERO;
    end
else
	begin
    dividend:= 0;
	divisor:= 0;
	z:= 0;
    i:= Multi_XV_max;
	while (i >= 0) do
		begin
		dividend.M_Value[i]:= P_dividend.M_Value[i];
		T:= P_divisor.M_Value[i];
		divisor.M_Value[i]:= T;
		if	(T <> 0) then z:= (z + i);
		Dec(i);
		end;
	dividend.Negative_flag:= FALSE;
	divisor.Negative_flag:= FALSE;

	if	(divisor > dividend) then
		begin
		P_quotient:= ZERO;
	 	P_remainder:= P_dividend;
		goto 9000;
	    end;

	// single digit divisor
	if	(z = 0) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_XV_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(divisor.M_Value[0]));
			k:= (((k * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(divisor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= k;
		goto 9000;
		end;

	quotient:= ZERO;
	P_remainder:= ZERO;
	quotient_factor:= 1;

	{ Round 0 }
	nlz_bits_dividend:= nlz_MultiBits_XV(dividend);
	nlz_bits_divisor:= nlz_MultiBits_XV(divisor);
	nlz_bits_P_divisor:= nlz_bits_divisor;
	nlz_bits_diff:= (nlz_bits_divisor - nlz_bits_dividend - 1);

	if	(nlz_bits_diff > 0) then
		begin
		ShiftUp_MultiBits_Multi_Int_XV(divisor, nlz_bits_diff);
		ShiftUp_MultiBits_Multi_Int_XV(quotient_factor, nlz_bits_diff);
		end
	else nlz_bits_diff:= 0;

	{ Round X }
	repeat
	1000:
		next_dividend:= (dividend - divisor);
		if (next_dividend >= ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			goto 1000;
			end;
		if (next_dividend = ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			dividend:= next_dividend;
			end;

		nlz_bits_divisor:= nlz_MultiBits_XV(divisor);
		if (nlz_bits_divisor < nlz_bits_P_divisor) then
			begin
			nlz_bits_dividend:= nlz_MultiBits_XV(dividend);
			nlz_bits_diff:= (nlz_bits_dividend - nlz_bits_divisor + 1);

			if ((nlz_bits_divisor + nlz_bits_diff) > nlz_bits_P_divisor) then
				nlz_bits_diff:= (nlz_bits_P_divisor - nlz_bits_divisor);

			ShiftDown_MultiBits_Multi_Int_XV(divisor, nlz_bits_diff);
			ShiftDown_MultiBits_Multi_Int_XV(quotient_factor, nlz_bits_diff);
			end;
	until	(dividend < P_divisor)
	or		(nlz_bits_divisor >= nlz_bits_P_divisor)
	or		(divisor = ZERO)
	;

	P_quotient:= quotient;
	P_remainder:= dividend;

9000:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > ZERO)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_divisor.Negative_flag)
	and	(P_quotient > ZERO)
	then
		P_quotient.Negative_flag:= TRUE;
	end;
9999:
end;


(******************************************)
class operator Multi_Int_XV.intdivide(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
Remainder,
Quotient	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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
	intdivide_Shift_And_Sub_XV(v1,v2,Quotient,Remainder);

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
class operator Multi_Int_XV.modulus(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
Remainder,
Quotient	:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
or	(length(v1.M_Value) <> Multi_XV_size)
or	(length(v2.M_Value) <> Multi_XV_size)
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
	intdivide_Shift_And_Sub_XV(v1,v2,Quotient,Remainder);

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

procedure Multi_Init_Initialisation(const P_Multi_XV_size:Multi_int32u = 16);
var	i:Multi_int32u;

begin
if	(not Multi_Int_ALLOW_UNLIMITED_INITIALISATIONS) then
	begin
	if	(Multi_Init_Initialisation_count > 2)
	or	(	(Multi_Init_Initialisation_count > 1)
		and	(Multi_Int_XV_VARS_CREATED)
		)
	then
		begin
		Raise EInterror.create('Multi_Init_Initialisation has already been called and/or Multi_Int_XV variables already created');
		exit;
		end;
	end;

Inc(Multi_Init_Initialisation_count);

Multi_XV_size:=	P_Multi_XV_size;

if (Multi_XV_size < 1) then
	begin
	Raise EInterror.create('Multi_XV_size must be > 1');
	exit;
	end;

Multi_XV_max:=		(Multi_XV_size - 1);
Multi_XV_size_x2:=	(Multi_XV_size*2);
Multi_XV_max_x2:=	(((Multi_XV_max+1)*2)-1);

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
while (i <= Multi_X2_max) do
	begin
	Multi_Int_X2_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X3_MAXINT:= 0;
i:=0;
while (i <= Multi_X3_max) do
	begin
	Multi_Int_X3_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X4_MAXINT:= 0;
i:=0;
while (i <= Multi_X4_max) do
	begin
	Multi_Int_X4_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

if (Multi_XV_max < 1) then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Multi_XV_max value must be > 0');
		end;
	halt(1);
	end;

Multi_Int_XV_MAXINT:= 0;
i:=0;
while (i <= Multi_XV_max) do
	begin
	Multi_Int_XV_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_XV_VARS_CREATED:= FALSE;

Multi_32bit_or_64bit:= Multi_undef;
{$ifdef 64bit}
Multi_32bit_or_64bit:= Multi_64bit;
{$endif}
{$ifdef 32bit}
Multi_32bit_or_64bit:= Multi_32bit;
{$endif}

end;


begin
Multi_Init_Initialisation;
end.

