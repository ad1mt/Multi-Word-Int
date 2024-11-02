UNIT Multi_Int;

(******************************************************************************)
// This code is public domain.
// No copyright.
// No license.
// No warranty.
// If you want to take this code and copyright it yourself, feel free.
(******************************************************************************)

{$MODE OBJFPC}
{$MODESWITCH ADVANCEDRECORDS}
{$LONGSTRINGS ON}
{$MODESWITCH NESTEDCOMMENTS+}

(* USER OPTIONAL DEFINES *)

// This should be changed to 32bit if you wish to override the default/detected setting
// E.g. if your compiler is 64bit but you want to generate code for 32bit integers,
// you would remove the "{$define 64bit}" and replace it with "{$define 32bit}"
// In 99.9% of cases, you should leave this to default, unless you have problems
// running the code in a 32bit or ARM environment.
// E.g:
// {$DEFINE 32BIT}
// or
// {$DEFINE 64BIT}


// This makes procedures and functions inlined
{$define inline_functions_level_1}


// This enables assertion-type code that is
// designed to be enabled only while unit testing
{$define assertion_code_enabled}


(* END OF USER OPTIONAL DEFINES *)

// Do not remove these defines

{$IFDEF 32BIT}
	{$WARNING 32BIT OVERRIDE}
{$ELSE}
	{$IFDEF 64BIT}
		{$WARNING 64BIT OVERRIDE}
	{$ELSE}
		{$IFDEF CPU64}
			{$DEFINE 64BIT}
			{$NOTE 64BIT ENVIRONMENT DETECTED}
		{$ELSE} {$IFDEF CPU32}
		  	{$DEFINE 32BIT}
			{$NOTE 32BIT ENVIRONMENT DETECTED}
		{$ELSE}
			{$FATAL Could not detect 32bit vs 64bit CPU}
		{$ENDIF}
		{$ENDIF}
	{$ENDIF}
{$ENDIF}


// This define is essential to make exceptions work correctly
// for floating-point operations on Intel 32 bit CPU's.

{$IFDEF 64BIT}
	{$IFDEF CPU32}
		{$SAFEFPUEXCEPTIONS ON}
		{$WARNING 64BIT OVERRIDE IN 32BIT ENVIRONMENT DETECTED}
		{$WARNING SETTING SAFEFPUEXCEPTIONS ON}
	{$ENDIF}
{$ELSE}
	{$IFDEF 32BIT}
		{$SAFEFPUEXCEPTIONS ON}
	{$ENDIF}
{$ENDIF}


(******************************************************************************)
(*
v4.70
-	1.	minor code tidy-ups in division functions
-	2.	major bug fixes in XV type division function
-	3.	more major bug fixes in XV type division function

v4.71
-	1.	speed improvements in XV type multiply
-	2.	bug in sqroot

v4.72
-	1.	bug fixes in speed improvements
-	2.	more speed improvements in XV type multiply
-	3.	bug fix in XV type init
-	4.	bug fix in XV type multiply
-	5.	bug fixes near calls to Multi_Int_Reset_XV_Size
-	6.	bug fixes near calls to init_Multi_Int_XV
-	7.	removed lots of redundant Result:=0 and other tidy-ups

v4.73
-	1.	recoded subtract_Multi_Int_XV with added speed
-	2.	lots of bug fixes.

v4.74
-	1.	continue with subtract_Multi_Int_XV speedup
-	2.	fix visibility of init_Multi_Int_XV

v4.75
-	1.	bug fix: Multi_Int_X_MAXINT definitions did not
		set the flags.
-	2.	Multi_Int_Initialisation bug: X2, X3 & X4 initialisation
		moved to unit initialisation.
-	3.	Multi_Int_RAISE_EXCEPTIONS_ENABLED defaults now to FALSE

v4.76
-	1.	Yet more bugs in Multi_Int_XV division.
-	2.	fixed many bugs where Multi_Int_ERROR should be set TRUE

v4.77
-	1.	Rename T to Force_recompile to make it self-documenting :)
-	2.	more bug fixes in sqroot
-	3.	replicate recent Multi_Int_XV division bug fixes to
		other division functions

v4.78
-	1.	replicate subtract_Multi_Int_XV speedups to add_Multi_Int_XV
-	2.	bug fixes in subtract_Multi_Int_XV & add_Multi_Int_XV
-	3.	Yet another bug fix in Multi_Int_XV division.
-	4.	bug fixes in init_Multi_Int_XV

v4.80	Abandoned.
-	1.	redesign initialisation logic

v4.81a
-	1.	make all internal flags T_Multi_UBool
-	2.	function Multi_Int_XV_is_Initialised
-	3.	new operators for T_Multi_UBool: < <= > >=

v4.81b
-	1.	new internal add_Multi_Int_XV subtract_Multi_Int_XV
-	2.	use internal subtract_Multi_Int_XV in Multi_Int_XV divide

v4.81c
-	1.	solved the weird bugs, and started to fix them

v4.81d
-	1.	started to fix the weird bugs

v4.81e
-	1.	started to fix the weird bugs

v4.81f
-	1.	get rid of Multi_XV_size
-	2.	Major bug fix in multiply_Multi_Int_XV

v4.81g
-	1.	?

v4.81h
-	1.	Major bug fix in multiply_Multi_Int_XV
-	2a.	create INTERNAL_multiply_Multi_Int_XV
-	2b.	create INTERNAL_add/aubtract_Multi_Int_XV
-	3.	create INTERNAL_Reset_XV_Size and use it in lots of places
-	4.	size limit in INTERNAL_Reset_XV_Size
-	5.	call zero_multi_XV at start of INTERNAL_add/aubtract/multiply_Multi_Int_XV
-	6.	bug fix in ShiftUp_MultiBits_Multi_Int_XV
-	7.	other bug fixes?
-	8.	finally passes unit tests again

v4.82a
-	1.	clean up code.
-	2.	bug fixes in multiply_Multi_Int_XV; result not initialised

v4.82b
-	1.	more bug fixes in multiply_Multi_Int_XV; setting result size
-	2.	more bug fixes in add_Multi_Int_XV; setting result size

*)

INTERFACE

uses	sysutils
,		strutils
;

const
	version = '4.82.00';

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

Multi_UBool_Values		= 	(Multi_UBool_TRUE,Multi_UBool_FALSE,Multi_UBool_UNDEF);

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
						class operator <=(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator <(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator >=(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator >(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator or(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator or(v1:T_Multi_UBool;v2:Boolean):Boolean; inline;
						class operator or(v1:Boolean; v2:T_Multi_UBool):Boolean; inline;
						class operator and(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator and(v1:T_Multi_UBool;v2:Boolean):Boolean; inline;
						class operator and(v1:Boolean; v2:T_Multi_UBool):Boolean; inline;
						class operator not(v1:T_Multi_UBool):Boolean; inline;
					end;

Multi_Int_X2	=	record
					private
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
						Negative_flag	:T_Multi_UBool;
						M_Value			:array[0..Multi_X2_maxi] of MULTI_INT_1W_U;
					public
						function ToStr:ansistring;										{$ifdef inline_functions_level_1} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X2;
						function FromBin(const v1:ansistring):Multi_Int_X2;
						function Overflow:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Negative:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Defined:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):Multi_int8u;
						class operator :=(const v1:Multi_Int_X2):Multi_int8;
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_1W_U;
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_1W_S;
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_2W_U;
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_2W_S;
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X2;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X2;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X2;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X2;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_4W_S;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):MULTI_INT_4W_U;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_X2;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X2):ansistring;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X2;
						class operator :=(const v1:Real):Multi_Int_X2;
						class operator :=(const v1:Double):Multi_Int_X2;
						class operator :=(const v1:Multi_Int_X2):Single;
						class operator :=(const v1:Multi_Int_X2):Real;
						class operator :=(const v1:Multi_Int_X2):Double;
						class operator +(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator -(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator inc(const v1:Multi_Int_X2):Multi_Int_X2;
						class operator dec(const v1:Multi_Int_X2):Multi_Int_X2;
						class operator *(const v1,v2:Multi_Int_X2):Multi_Int_X2;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator mod(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator xor(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator or(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator and(const v1,v2:Multi_Int_X2):Multi_Int_X2;
						class operator not(const v1:Multi_Int_X2):Multi_Int_X2;
						class operator -(const v1:Multi_Int_X2):Multi_Int_X2;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X2):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X2):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X2):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X2):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X2):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X2):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator **(const v1:Multi_Int_X2; const P:MULTI_INT_2W_S):Multi_Int_X2;
						class operator shr(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;
						class operator shl(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;
					end;


Multi_Int_X3	=	record
					private
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
						Negative_flag	:T_Multi_UBool;
						M_Value			:array[0..Multi_X3_maxi] of MULTI_INT_1W_U;
					public
						function ToStr:ansistring;										{$ifdef inline_functions_level_1} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X3;
						function FromBin(const v1:ansistring):Multi_Int_X3;
						function Overflow:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Negative:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Defined:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_int8u;
						class operator :=(const v1:Multi_Int_X3):Multi_int8;
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_1W_U;
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_1W_S;
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_2W_U;
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_2W_S;
						class operator :=(const v1:Multi_Int_X2):Multi_Int_X3;
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X3;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X3;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X3;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X3;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_4W_S;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):MULTI_INT_4W_U;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_X3;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):ansistring;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X3;
						class operator :=(const v1:Real):Multi_Int_X3;
						class operator :=(const v1:Double):Multi_Int_X3;
						class operator :=(const v1:Multi_Int_X3):Real;
						class operator :=(const v1:Multi_Int_X3):Single;
						class operator :=(const v1:Multi_Int_X3):Double;
						class operator +(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator -(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator inc(const v1:Multi_Int_X3):Multi_Int_X3;
						class operator dec(const v1:Multi_Int_X3):Multi_Int_X3;
						class operator *(const v1,v2:Multi_Int_X3):Multi_Int_X3;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator mod(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator xor(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator or(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator and(const v1,v2:Multi_Int_X3):Multi_Int_X3;
						class operator not(const v1:Multi_Int_X3):Multi_Int_X3;
						class operator -(const v1:Multi_Int_X3):Multi_Int_X3;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X3):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X3):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X3):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X3):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X3):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X3):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator **(const v1:Multi_Int_X3; const P:MULTI_INT_2W_S):Multi_Int_X3;
						class operator shr(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;
						class operator shl(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;
					end;


Multi_Int_X4	=	record
					private
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
						Negative_flag	:T_Multi_UBool;
						M_Value			:array[0..Multi_X4_maxi] of MULTI_INT_1W_U;
					public
						function ToStr:ansistring;										{$ifdef inline_functions_level_1} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;
						function FromHex(const v1:ansistring):Multi_Int_X4;
						function FromBin(const v1:ansistring):Multi_Int_X4;
						function Overflow:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Negative:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Defined:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):Multi_int8u;
						class operator :=(const v1:Multi_Int_X4):Multi_int8;
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_1W_U;
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_1W_S;
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_2W_U;
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_2W_S;
						class operator :=(const v1:Multi_Int_X2):Multi_Int_X4;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X3):Multi_Int_X4;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_4W_S;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):MULTI_INT_4W_U;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_X4;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_X4):ansistring;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_X4;
						class operator :=(const v1:Real):Multi_Int_X4;
						class operator :=(const v1:Double):Multi_Int_X4;
						class operator :=(const v1:Multi_Int_X4):Single;
						class operator :=(const v1:Multi_Int_X4):Real;
						class operator :=(const v1:Multi_Int_X4):Double;
						class operator +(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator -(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator inc(const v1:Multi_Int_X4):Multi_Int_X4;
						class operator dec(const v1:Multi_Int_X4):Multi_Int_X4;
						class operator *(const v1,v2:Multi_Int_X4):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator div(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator mod(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator xor(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator or(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator and(const v1,v2:Multi_Int_X4):Multi_Int_X4;
						class operator not(const v1:Multi_Int_X4):Multi_Int_X4;
						class operator -(const v1:Multi_Int_X4):Multi_Int_X4;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_X4):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_X4):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_X4):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_X4):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_X4):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <=(const v1,v2:Multi_Int_X4):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator **(const v1:Multi_Int_X4; const P:MULTI_INT_2W_S):Multi_Int_X4;
						class operator shr(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;
						class operator shl(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;
					end;


Multi_Int_XV	=	record
					private
						M_Value_Size	:MULTI_INT_2W_U;
						Negative_flag	:T_Multi_UBool;
						M_Value			:array of MULTI_INT_1W_U;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						function ToStr:ansistring;										{$ifdef inline_functions_level_1} inline; {$endif}
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	
						function ToBin(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):ansistring;	
						function FromHex(const v1:ansistring):Multi_Int_XV;	
						function FromBin(const v1:ansistring):Multi_Int_XV;	
						function Overflow:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Negative:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
						function Defined:boolean;										{$ifdef inline_functions_level_1} inline; {$endif}
                        class operator Initialize(var MI:Multi_Int_XV);
                        class operator copy(constref v1:Multi_Int_XV; var MI:Multi_Int_XV);
						class operator :=(const v1:Multi_Int_XV):Multi_int8u;
						class operator :=(const v1:Multi_Int_XV):Multi_int8;	
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_1W_U;	
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_1W_S;	
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_2W_U;	
						class operator :=(const v1:Multi_Int_XV):MULTI_INT_2W_S;	
						class operator :=(const v1:Multi_Int_X2):Multi_Int_XV;
						class operator :=(const v1:Multi_Int_X3):Multi_Int_XV;	
						class operator :=(const v1:Multi_Int_X4):Multi_Int_XV;
						class operator :=(const v1:MULTI_INT_2W_S):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_2W_U):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$ifdef 32bit}
						class operator :=(const v1:MULTI_INT_4W_S):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:MULTI_INT_4W_U):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
					{$endif}
						class operator :=(const v1:ansistring):Multi_Int_XV;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Multi_Int_XV):ansistring;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator :=(const v1:Single):Multi_Int_XV;	
						class operator :=(const v1:Real):Multi_Int_XV;	
						class operator :=(const v1:Double):Multi_Int_XV;	
						class operator :=(const v1:Multi_Int_XV):Single;	
						class operator :=(const v1:Multi_Int_XV):Real;	
						class operator :=(const v1:Multi_Int_XV):Double;	
						class operator +(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator -(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator inc(const v1:Multi_Int_XV):Multi_Int_XV;	
						class operator dec(const v1:Multi_Int_XV):Multi_Int_XV;	
						class operator *(const v1,v2:Multi_Int_XV):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_U):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_S):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v2:MULTI_INT_1W_U; const v1:Multi_Int_XV):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v2:MULTI_INT_1W_S; const v1:Multi_Int_XV):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}

						class operator *(const v1:Multi_Int_XV; const v2:MULTI_INT_2W_U):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v1:Multi_Int_XV; const v2:MULTI_INT_2W_S):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v2:MULTI_INT_2W_U; const v1:Multi_Int_XV):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
						class operator *(const v2:MULTI_INT_2W_S; const v1:Multi_Int_XV):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}

						class operator div(const v1,v2:Multi_Int_XV):Multi_Int_XV;
						class operator mod(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator or(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator and(const v1,v2:Multi_Int_XV):Multi_Int_XV;	
						class operator not(const v1:Multi_Int_XV):Multi_Int_XV;	
						class operator -(const v1:Multi_Int_XV):Multi_Int_XV;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >(const v1,v2:Multi_Int_XV):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <(const v1,v2:Multi_Int_XV):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator =(const v1,v2:Multi_Int_XV):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
						class operator <>(const v1,v2:Multi_Int_XV):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator >=(const v1,v2:Multi_Int_XV):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
 						class operator <=(const v1,v2:Multi_Int_XV):Boolean;			{$ifdef inline_functions_level_1} inline; {$endif}
						class operator **(const v1:Multi_Int_XV; const P:MULTI_INT_2W_S):Multi_Int_XV;	
						class operator shr(const v1:Multi_Int_XV; const NBits:MULTI_INT_2W_U):Multi_Int_XV;	
						class operator shl(const v1:Multi_Int_XV; const NBits:MULTI_INT_2W_U):Multi_Int_XV;	
					end;

var
Multi_Int_RAISE_EXCEPTIONS_ENABLED	:boolean = TRUE;
Multi_Int_ERROR						:boolean = FALSE;
Multi_Int_X2_MAXINT					:Multi_Int_X2;
Multi_Int_X3_MAXINT					:Multi_Int_X3;
Multi_Int_X4_MAXINT					:Multi_Int_X4;
Multi_Int_XV_MAXINT					:Multi_Int_XV;

procedure Multi_Int_Initialisation(const P_Multi_XV_size:MULTI_INT_2W_U = 16);	
procedure Multi_Int_Set_XV_Limit(const S:MULTI_INT_2W_U);							{$ifdef inline_functions_level_1} inline; {$endif}
// procedure INTERNAL_Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_2W_U);	{$ifdef inline_functions_level_1} inline; {$endif}
procedure Multi_Int_Reset_X2_Last_Divisor;
procedure Multi_Int_Reset_X3_Last_Divisor;	
procedure Multi_Int_Reset_X4_Last_Divisor;	
procedure Multi_Int_Reset_XV_Last_Divisor;	

function Odd(const v1:Multi_Int_XV):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Odd(const v1:Multi_Int_X4):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Odd(const v1:Multi_Int_X3):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Odd(const v1:Multi_Int_X2):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}

function Even(const v1:Multi_Int_XV):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Even(const v1:Multi_Int_X4):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Even(const v1:Multi_Int_X3):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Even(const v1:Multi_Int_X2):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}

function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Abs(const v1:Multi_Int_XV):Multi_Int_XV; overload;					{$ifdef inline_functions_level_1} inline; {$endif}

function Negative(const v1:Multi_Int_X2):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Negative(const v1:Multi_Int_X3):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Negative(const v1:Multi_Int_X4):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
function Negative(const v1:Multi_Int_XV):boolean; overload; 				{$ifdef inline_functions_level_1} inline; {$endif}

procedure SqRoot(const v1:Multi_Int_XV; out VR,VREM:Multi_Int_XV); overload;	
procedure SqRoot(const v1:Multi_Int_X4; out VR,VREM:Multi_Int_X4); overload;	
procedure SqRoot(const v1:Multi_Int_X3; out VR,VREM:Multi_Int_X3); overload;	
procedure SqRoot(const v1:Multi_Int_X2; out VR,VREM:Multi_Int_X2); overload;	

procedure SqRoot(const v1:Multi_Int_XV; out VR:Multi_Int_XV); overload;	
procedure SqRoot(const v1:Multi_Int_X4; out VR:Multi_Int_X4); overload;	
procedure SqRoot(const v1:Multi_Int_X3; out VR:Multi_Int_X3); overload;	
procedure SqRoot(const v1:Multi_Int_X2; out VR:Multi_Int_X2); overload;	

function SqRoot(const v1:Multi_Int_XV):Multi_Int_XV; overload;	
function SqRoot(const v1:Multi_Int_X4):Multi_Int_X4; overload;	
function SqRoot(const v1:Multi_Int_X3):Multi_Int_X3; overload;	
function SqRoot(const v1:Multi_Int_X2):Multi_Int_X2; overload;	

procedure FromHex(const v1:ansistring; out v2:Multi_Int_X2); overload;	
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X3); overload;	
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X4); overload;	
procedure FromHex(const v1:ansistring; out v2:Multi_Int_XV); overload;	

procedure FromBin(const v1:ansistring; out mi:Multi_Int_X2); overload;	
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X3); overload;	
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X4); overload;	
procedure FromBin(const v1:ansistring; out mi:Multi_Int_XV); overload;	

procedure Hex_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2); overload;	
procedure Hex_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3); overload;	
procedure Hex_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); overload;	
procedure Hex_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV); overload;

procedure bin_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2); overload;	
procedure bin_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3); overload;	
procedure bin_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); overload;	
procedure bin_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV); overload;

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

const
	Multi_X5_max = 8;
	Multi_X5_maxi = 7;
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
i, Force_recompile				:MULTI_INT_1W_U;
Multi_Int_Initialisation_done	:boolean = FALSE;
// Multi_XV_size				:MULTI_INT_2W_U = 0;
Multi_XV_min_size 				:MULTI_INT_2W_U = 2;
Multi_XV_limit					:MULTI_INT_2W_U = 0;

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

procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); forward;	
procedure ShiftDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U); forward;	
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); forward;	
procedure ShiftDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U); forward;	
procedure ShiftUp_NBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U); forward;	
procedure ShiftDown_MultiBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U); forward;	
function To_Multi_Int_X5(const v1:Multi_Int_X4):Multi_Int_X5; forward;	
function Multi_Int_X2_to_X3_multiply(const v1,v2:Multi_Int_X2):Multi_Int_X3; forward;	
function Multi_Int_X3_to_X4_multiply(const v1,v2:Multi_Int_X3):Multi_Int_X4; forward;	
function Multi_Int_X4_to_X5_multiply(const v1,v2:Multi_Int_X4):Multi_Int_X5; forward;	
function To_Multi_Int_X4(const v1:Multi_Int_X5):Multi_Int_X4; forward; overload;

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

class operator T_Multi_UBool.<=(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value <= v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.<(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value < v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.>=(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value >= v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.>(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value > v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.or(v1,v2:T_Multi_UBool):Boolean;
begin
if	(v1.B_Value = Multi_UBool_TRUE)
or	(v2.B_Value = Multi_UBool_TRUE)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.or(v1:T_Multi_UBool;v2:Boolean):Boolean;
begin
if	(v1.B_Value = Multi_UBool_TRUE)
or	(v2)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.or(v1:Boolean;v2:T_Multi_UBool):Boolean;
begin
if	(v1)
or	(v2.B_Value = Multi_UBool_TRUE)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.and(v1,v2:T_Multi_UBool):Boolean;
begin
if	(v1.B_Value = Multi_UBool_TRUE)
and	(v2.B_Value = Multi_UBool_TRUE)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.and(v1:T_Multi_UBool;v2:Boolean):Boolean;
begin
if	(v1.B_Value = Multi_UBool_TRUE)
and	(v2)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.and(v1:Boolean; v2:T_Multi_UBool):Boolean;
begin
if	(v1)
and	(v2.B_Value = Multi_UBool_TRUE)
then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.not(v1:T_Multi_UBool):Boolean;
begin
if	(v1.B_Value = Multi_UBool_TRUE) then Result:= FALSE
else if (v1.B_Value = Multi_UBool_FALSE) then Result:= TRUE
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
			then Result:=FALSE;
end;


(******************************************)
function ABS_notequal_Multi_Int_X2(const v1,v2:Multi_Int_X2):Boolean;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X2.Defined:boolean;									{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Multi_Int_X2.Overflow:boolean;									{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X2):boolean; overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Multi_Int_X2.Negative:boolean;									{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X2):boolean; overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Defined(const v1:Multi_Int_X2):boolean; overload; 				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X2_Odd(const v1:Multi_Int_X2):boolean; 
var	bit1_mask	:MULTI_INT_1W_U;

begin
bit1_mask:= $1;

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

end;


(******************************************)
function Odd(const v1:Multi_Int_X2):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_X2_Odd(v1);
end;


(******************************************)
function Multi_Int_X2_Even(const v1:Multi_Int_X2):boolean; 
var	bit1_mask	:MULTI_INT_1W_U;
begin

bit1_mask:= $1;

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

end;


(******************************************)
function Even(const v1:Multi_Int_X2):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_X2_Even(v1);
end;


{$ifdef 32bit}
(******************************************)
procedure ShiftUp_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;

	procedure INT_1W_U_shl(var v1:MULTI_INT_1W_U; const nbits:MULTI_INT_1W_U); 
	var carry_bits_mask_2w	:MULTI_INT_2W_U;
	begin
	carry_bits_mask_2w:= v1;
	carry_bits_mask_2w:= (carry_bits_mask_2w << NBits);
	v1:= MULTI_INT_1W_U(carry_bits_mask_2w and MULTI_INT_1W_U_MAXINT);
	end;

begin
if NBits > 0 then
begin

carry_bits_mask:= $FFFF;
NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
INT_1W_U_shl(carry_bits_mask, NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[0], NBits);

	carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[1], NBits);
	v1.M_Value[1]:= (v1.M_Value[1] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[2], NBits);
	v1.M_Value[2]:= (v1.M_Value[2] OR carry_bits_2);

	INT_1W_U_shl(v1.M_Value[3], NBits);
	v1.M_Value[3]:= (v1.M_Value[3] OR carry_bits_1);
	end;
end;

end;
{$endif}

{$ifdef 64bit}
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

	carry_bits_mask:= $FFFFFFFF;
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

end;
{$endif}


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X2_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
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

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X2_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
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
class operator Multi_Int_X2.shl(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X2(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X2.shr(const v1:Multi_Int_X2; const NBits:MULTI_INT_1W_U):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
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
 		if mi.Defined_flag = FALSE then exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= FALSE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
		Multi_Int_ERROR:= TRUE;
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
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_2W_U;

begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

n:= 0;
if	(v1.M_Value_Size > Multi_X2_size) then
	begin
	while (n <= Multi_X2_maxi) do
		begin
		Result.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while (n < v1.M_Value_Size) do
		begin
		if (v1.M_Value[n] <> 0) then
			goto OVERFLOW_BRANCH;
		inc(n);
		end;
	end
else
	begin
	while (n < v1.M_Value_Size) do
		begin
		Result.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while (n <= Multi_X2_maxi) do
		begin
		Result.M_Value[n]:= 0;
		inc(n);
		end;
	end;

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
Result.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:

end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:ansistring):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
ansistring_to_Multi_Int_X2(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X2(const v1:MULTI_INT_4W_S; out mi:Multi_Int_X2); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X2.:=(const v1:MULTI_INT_4W_S):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_4W_S_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X2(const v1:MULTI_INT_4W_U; out mi:Multi_Int_X2); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X2.:=(const v1:MULTI_INT_2W_S):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X2.:=(const v1:MULTI_INT_2W_U):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_2W_U_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
// WARNING Float to Multi_Int type conversion loses some precision
class operator Multi_Int_X2.:=(const v1:Single):Multi_Int_X2;
var
R			:Multi_Int_X2;
R_FLOATREC	:TFloatRec;
begin
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
		Raise EIntOverflow.create('Overflow');
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
begin
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
		Raise EIntOverflow.create('Overflow');
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

begin
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if V.IsInfinity
			or single.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if single.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			{
			if single.IsInfinity(V)
			or single.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;
			}

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			{
			if single.IsInfinity(M) then 
				finished:= TRUE;
			}
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if double.IsInfinity(V)
			or double.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if double.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


{$ifdef 32bit}

(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_4W_S;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1 < (-MULTI_INT_4W_U_MAXINT_1))
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

if v1.Negative_flag
then Result:= MULTI_INT_4W_S(-R)
else Result:= MULTI_INT_4W_S(R);
end;



(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_4W_U;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1.Negative_flag)
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

Result:= (R);
end;

{$endif}


{******************************************}
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):MULTI_INT_2W_S;
var	R	:MULTI_INT_2W_U;
begin
Multi_Int_ERROR:= FALSE;
if	(Not v1.Defined_flag)
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_S;
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
		or	(bit < 0)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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
end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X2); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Bin_to_Multi_Int_X2(v1,mi);
end;


(******************************************)
function Multi_Int_X2.FromBin(const v1:ansistring):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X2.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X2.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X2_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X2(const v1:ansistring; out mi:Multi_Int_X2); 
var
	n,i,b,c,e	:MULTI_INT_2W_U;
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
		if mi.Defined_flag = FALSE then exit;

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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X2); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
hex_to_Multi_Int_X2(v1,v2);
end;


(******************************************)
function Multi_Int_X2.FromHex(const v1:ansistring):Multi_Int_X2;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X2.ToStr:ansistring;								{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X2_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X2.:=(const v1:Multi_Int_X2):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
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
	Multi_Int_ERROR:= TRUE;
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
	Result.Defined_flag:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] xor v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] xor v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] xor v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] xor v2.M_Value[3]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative <> v2.Negative)
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X2.or(const v1,v2:Multi_Int_X2):Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] or v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] or v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] or v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] or v2.M_Value[3]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag := FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X2.and(const v1,v2:Multi_Int_X2):Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] and v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] and v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] and v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] and v2.M_Value[3]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag := FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X2.not(const v1:Multi_Int_X2):Multi_Int_X2;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (not v1.M_Value[0]);
Result.M_Value[1]:= (not v1.M_Value[1]);
Result.M_Value[2]:= (not v1.M_Value[2]);
Result.M_Value[3]:= (not v1.M_Value[3]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag := FALSE;

Result.Negative_flag:=  Multi_UBool_TRUE;
if v1.Negative
then Result.Negative_flag:= Multi_UBool_FALSE;
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
	Result:= 0;
	Multi_Int_ERROR:= TRUE;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
class operator Multi_Int_X2.-(const v1:Multi_Int_X2):Multi_Int_X2; 				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(********************v1********************)
procedure multiply_Multi_Int_X2(const v1,v2:Multi_Int_X2;out Result:Multi_Int_X2);
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
	exit;
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
	exit;
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	end;
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
					Raise EIntOverflow.create('Overflow');
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
				Raise EIntOverflow.create('Overflow');
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
			Raise EIntOverflow.create('Overflow');
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
label	AGAIN,FINISH;
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
adjacent_word_carry
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
		goto FINISH;
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
		word_carry:= 0;
		i:= Multi_X2_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) div MULTI_INT_2W_U(P_dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(P_dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto FINISH;
		end;

    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X3(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X3(dividor, shiftup_bits_dividor);
		end;

	adjacent_word_carry:= 0;
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
        adjacent_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((adjacent_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					adjacent_word_carry:= adjacent_word_carry + dividor.M_Value[dividor_i];
					if (adjacent_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;
			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if Multi_Int_ERROR then
				begin
				P_quotient.Defined_flag:= FALSE;
				P_quotient.Overflow_flag:= TRUE;
				P_remainder.Defined_flag:= FALSE;
				P_remainder.Overflow_flag:= TRUE;
				exit;
				end;
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				if Multi_Int_ERROR then
					begin
					P_quotient.Defined_flag:= FALSE;
					P_quotient.Overflow_flag:= TRUE;
					P_remainder.Defined_flag:= FALSE;
					P_remainder.Overflow_flag:= TRUE;
					exit;
					end;
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

FINISH:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	end;
end;


(***********v2************)
procedure SqRoot(const v1:Multi_Int_X2; out VR,VREM:Multi_Int_X2);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,
C,CC,LPC,
Q,R,T		:Multi_Int_X2;
finished	:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
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
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

VR.Defined_flag:= FALSE;
VREM.Defined_flag:= FALSE;

if	(v1 >= 100) then
	begin
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

	T:= (H-L);
	ShiftDown_MultiBits_Multi_Int_X2(T, 1);
	C:= (L+T);
	end
else
	begin
	C:= (v1 div 2);
	if	(C = 0) then C:= 1;
	end;

finished:= FALSE;
LPC:= v1;
repeat
	begin
	// CC:= ((C + (v1 div C)) div 2);
    intdivide_taylor_warruth_X2(v1,C,Q,R);
	if (Multi_Int_ERROR) then exit;
	CC:= (C+Q);
    ShiftDown_MultiBits_Multi_Int_X2(CC, 1);
	if	(ABS(C-CC) < 2) then
		begin
		if	(CC < LPC) then
			LPC:= CC
		else if (CC >= LPC) then
			finished:= TRUE
		end;
	C:= CC;
	end
until finished;

VREM:= (v1 - (LPC * LPC));
VR:= LPC;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;

end;


(*************************)
procedure SqRoot(const v1:Multi_Int_X2; out VR:Multi_Int_X2);				{$ifdef inline_functions_level_1} inline; {$endif}
var	VREM:Multi_Int_X2;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
end;


(*************************)
function SqRoot(const v1:Multi_Int_X2):Multi_Int_X2;						{$ifdef inline_functions_level_1} inline; {$endif}
var	VR,VREM:Multi_Int_X2;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
Result:= VR;
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
					then Result:=FALSE;
end;


(******************************************)
function ABS_notequal_Multi_Int_X3(const v1,v2:Multi_Int_X3):Boolean; 			{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= (not ABS_equal_Multi_Int_X3(v1,v2));
end;


(******************************************)
function Multi_Int_X3.Overflow:boolean; 										{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_X3.Defined:boolean; 											{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X3):boolean; overload; 					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_X3):boolean; overload; 						{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X3.Negative:boolean; 										{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X3):boolean; overload; 					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;						{$ifdef inline_functions_level_1} inline; {$endif}
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

bit1_mask:= $1;

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

end;


(******************************************)
function Odd(const v1:Multi_Int_X3):boolean; overload;						{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_X3_Odd(v1);
end;


(******************************************)
function Multi_Int_X3_Even(const v1:Multi_Int_X3):boolean; 
var	bit1_mask	:MULTI_INT_1W_U;
begin

bit1_mask:= $1;

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

end;


(******************************************)
function Even(const v1:Multi_Int_X3):boolean; overload;							{$ifdef inline_functions_level_1} inline; {$endif}
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


{$ifdef 32bit}
(******************************************)
procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;

	procedure INT_1W_U_shl(var v1:MULTI_INT_1W_U; const nbits:MULTI_INT_1W_U); 
	var carry_bits_mask_2w	:MULTI_INT_2W_U;
	begin
	carry_bits_mask_2w:= v1;
	carry_bits_mask_2w:= (carry_bits_mask_2w << NBits);
	v1:= MULTI_INT_1W_U(carry_bits_mask_2w and MULTI_INT_1W_U_MAXINT);
	end;

begin
if NBits > 0 then
begin

carry_bits_mask:= $FFFF;
NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
INT_1W_U_shl(carry_bits_mask, NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[0], NBits);

	carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[1], NBits);
	v1.M_Value[1]:= (v1.M_Value[1] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[2], NBits);
	v1.M_Value[2]:= (v1.M_Value[2] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[3], NBits);
	v1.M_Value[3]:= (v1.M_Value[3] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[4], NBits);
	v1.M_Value[4]:= (v1.M_Value[4] OR carry_bits_2);

	INT_1W_U_shl(v1.M_Value[5], NBits);
	v1.M_Value[5]:= (v1.M_Value[5] OR carry_bits_1);
	end;
end;

end;
{$endif}

{$ifdef 64bit}
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

carry_bits_mask:= $FFFFFFFF;
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

end;
{$endif}


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X3_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
		v1.M_Value[4]:= 0;
		v1.M_Value[5]:= 0;
		end;
end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X3_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
		v1.M_Value[4]:= 0;
		v1.M_Value[5]:= 0;
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
class operator Multi_Int_X3.shl(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X3(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X3.shr(const v1:Multi_Int_X3; const NBits:MULTI_INT_1W_U):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
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
		if mi.Defined_flag = FALSE then exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:ansistring):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
ansistring_to_Multi_Int_X3(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X3(const v1:MULTI_INT_4W_S; out mi:Multi_Int_X3); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X3.:=(const v1:MULTI_INT_4W_S):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_4W_S_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X3(const v1:MULTI_INT_4W_U; out mi:Multi_Int_X3); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X3.:=(const v1:MULTI_INT_4W_U):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X3.:=(const v1:MULTI_INT_2W_S):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X3.:=(const v1:MULTI_INT_2W_U):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_2W_U_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_XV):Multi_Int_X3;
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_2W_U;

begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

n:= 0;
if	(v1.M_Value_Size > Multi_X3_size) then
	begin
	while (n < v1.M_Value_Size) do
		begin
		Result.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while (n < v1.M_Value_Size) do
		begin
		if (v1.M_Value[n] <> 0) then
			goto OVERFLOW_BRANCH;
		inc(n);
		end;
	end
else
	begin
	while (n < v1.M_Value_Size) do
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

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
Result.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:
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
	Multi_Int_ERROR:= TRUE;
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if single.IsInfinity(V)
			or single.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if single.IsInfinity(M) then 
				finished:= TRUE;
		end
		{
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
					Raise EIntOverflow.create('Overflow');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
		}
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			{
			if real.IsInfinity(V)
			or real.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;
			}

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			{
			if real.IsInfinity(M) then 
				finished:= TRUE;
			}
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if double.IsInfinity(V)
			or double.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if double.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


{$ifdef 32bit}

(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_4W_S;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1 < (-MULTI_INT_4W_U_MAXINT_1))
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

if v1.Negative_flag
then Result:= (-R)
else Result:= (R);
end;



(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_4W_U;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1.Negative_flag)
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

Result:= (R);
end;

{$endif}


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):MULTI_INT_2W_S;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_S;
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
		or	(bit < 0)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Defined_flag:= FALSE;
			mi.Overflow_flag:=TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X3); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Bin_to_Multi_Int_X3(v1,mi);
end;


(******************************************)
function Multi_Int_X3.FromBin(const v1:ansistring):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X3.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X3.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X3_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X3(const v1:ansistring; out mi:Multi_Int_X3); 
var
	n,i,b,c,e	:MULTI_INT_2W_U;
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
		if mi.Defined_flag = FALSE then exit;

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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X3); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
hex_to_Multi_Int_X3(v1,v2);
end;


(******************************************)
function Multi_Int_X3.FromHex(const v1:ansistring):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X3.ToStr:ansistring;											{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X3_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X3.:=(const v1:Multi_Int_X3):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
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
	Multi_Int_ERROR:= TRUE;
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
	Result.Defined_flag:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] xor v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] xor v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] xor v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] xor v2.M_Value[3]);
Result.M_Value[4]:= (v1.M_Value[4] xor v2.M_Value[4]);
Result.M_Value[5]:= (v1.M_Value[5] xor v2.M_Value[5]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative <> v2.Negative)
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X3.or(const v1,v2:Multi_Int_X3):Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] or v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] or v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] or v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] or v2.M_Value[3]);
Result.M_Value[4]:= (v1.M_Value[4] or v2.M_Value[4]);
Result.M_Value[5]:= (v1.M_Value[5] or v2.M_Value[5]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X3.and(const v1,v2:Multi_Int_X3):Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] and v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] and v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] and v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] and v2.M_Value[3]);
Result.M_Value[4]:= (v1.M_Value[4] and v2.M_Value[4]);
Result.M_Value[5]:= (v1.M_Value[5] and v2.M_Value[5]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X3.not(const v1:Multi_Int_X3):Multi_Int_X3;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (not v1.M_Value[0]);
Result.M_Value[1]:= (not v1.M_Value[1]);
Result.M_Value[2]:= (not v1.M_Value[2]);
Result.M_Value[3]:= (not v1.M_Value[3]);
Result.M_Value[4]:= (not v1.M_Value[4]);
Result.M_Value[5]:= (not v1.M_Value[5]);
Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:=  Multi_UBool_TRUE;
if v1.Negative
then Result.Negative_flag:= Multi_UBool_FALSE;
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
	Multi_Int_ERROR:= TRUE;
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
class operator Multi_Int_X3.-(const v1:Multi_Int_X3):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(*******************v4*********************)
procedure multiply_Multi_Int_X3(const v1,v2:Multi_Int_X3;out Result:Multi_Int_X3); overload;
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
	exit;
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
	exit;
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
					Raise EIntOverflow.create('Overflow');
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
				Raise EIntOverflow.create('Overflow');
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
			Raise EIntOverflow.create('Overflow');
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
label	AGAIN,FINISH;
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
adjacent_word_carry
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
		goto FINISH;
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
		word_carry:= 0;
		i:= Multi_X3_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) div MULTI_INT_2W_U(dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(P_dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto FINISH;
		end;

    dividend:= P_dividend;
	dividend.Negative_flag:= FALSE;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X4(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X4(dividor, shiftup_bits_dividor);
		end;

	adjacent_word_carry:= 0;
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
        adjacent_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((adjacent_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					adjacent_word_carry:= adjacent_word_carry + dividor.M_Value[dividor_i];
					if (adjacent_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;
			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if Multi_Int_ERROR then
				begin
				P_quotient.Defined_flag:= FALSE;
				P_quotient.Overflow_flag:= TRUE;
				P_remainder.Defined_flag:= FALSE;
				P_remainder.Overflow_flag:= TRUE;
				exit;
				end;
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				if Multi_Int_ERROR then
					begin
					P_quotient.Defined_flag:= FALSE;
					P_quotient.Overflow_flag:= TRUE;
					P_remainder.Defined_flag:= FALSE;
					P_remainder.Overflow_flag:= TRUE;
					exit;
					end;
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

FINISH:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;

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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	end;
end;


(***********v2************)
procedure SqRoot(const v1:Multi_Int_X3; out VR,VREM:Multi_Int_X3);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,
C,CC,LPC,
Q,R,T		:Multi_Int_X3;
finished	:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
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
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

VR.Defined_flag:= FALSE;
VREM.Defined_flag:= FALSE;

if	(v1 >= 100) then
	begin
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

	T:= (H-L);
	ShiftDown_MultiBits_Multi_Int_X3(T, 1);
	C:= (L+T);
	end
else
	begin
	C:= (v1 div 2);
	if	(C = 0) then C:= 1;
	end;

finished:= FALSE;
LPC:= v1;
repeat
	begin
	// CC:= ((C + (v1 div C)) div 2);
    intdivide_taylor_warruth_X3(v1,C,Q,R);
	CC:= (C+Q);
    ShiftDown_MultiBits_Multi_Int_X3(CC, 1);
	if (Multi_Int_ERROR) then exit;
	if	(ABS(C-CC) < 2) then
		begin
		if	(CC < LPC) then
			LPC:= CC
		else if (CC >= LPC) then
			finished:= TRUE
		end;
	C:= CC;
	end
until finished;

VREM:= (v1 - (LPC * LPC));
VR:= LPC;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;

end;


(*************************)
procedure SqRoot(const v1:Multi_Int_X3; out VR:Multi_Int_X3);				{$ifdef inline_functions_level_1} inline; {$endif}
var	VREM:Multi_Int_X3;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
end;


(*************************)
function SqRoot(const v1:Multi_Int_X3):Multi_Int_X3;				{$ifdef inline_functions_level_1} inline; {$endif}
var	VR,VREM:Multi_Int_X3;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
Result:= VR;
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
function ABS_notequal_Multi_Int_X4(const v1,v2:Multi_Int_X4):Boolean; 				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= (not ABS_equal_Multi_Int_X4(v1,v2));
end;


(******************************************)
function Multi_Int_X4.Overflow:boolean; 											{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_X4.Defined:boolean; 												{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X4):boolean; overload; 						{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_X4):boolean; overload; 							{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X4.Negative:boolean; 											{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X4):boolean; overload; 						{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;							{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X4_Odd(const v1:Multi_Int_X4):boolean; 							{$ifdef inline_functions_level_1} inline; {$endif}
var	bit1_mask	:MULTI_INT_1W_U;
begin

bit1_mask:= $1;

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

end;


(******************************************)
function Odd(const v1:Multi_Int_X4):boolean; overload;							{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_X4_Odd(v1);
end;


(******************************************)
function Multi_Int_X4_Even(const v1:Multi_Int_X4):boolean; 						{$ifdef inline_functions_level_1} inline; {$endif}
var	bit1_mask	:MULTI_INT_1W_U;
begin

bit1_mask:= $1;

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

end;


(******************************************)
function Even(const v1:Multi_Int_X4):boolean; overload;							{$ifdef inline_functions_level_1} inline; {$endif}
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


{$ifdef 32bit}
(******************************************)
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;

	procedure INT_1W_U_shl(var v1:MULTI_INT_1W_U; const nbits:MULTI_INT_1W_U); 
	var carry_bits_mask_2w	:MULTI_INT_2W_U;
	begin
	carry_bits_mask_2w:= v1;
	carry_bits_mask_2w:= (carry_bits_mask_2w << NBits);
	v1:= MULTI_INT_1W_U(carry_bits_mask_2w and MULTI_INT_1W_U_MAXINT);
	end;

begin
if NBits > 0 then
begin

carry_bits_mask:= $FFFF;
NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
INT_1W_U_shl(carry_bits_mask, NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[0], NBits);

	carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[1], NBits);
	v1.M_Value[1]:= (v1.M_Value[1] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[2], NBits);
	v1.M_Value[2]:= (v1.M_Value[2] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[3], NBits);
	v1.M_Value[3]:= (v1.M_Value[3] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[4], NBits);
	v1.M_Value[4]:= (v1.M_Value[4] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[5], NBits);
	v1.M_Value[5]:= (v1.M_Value[5] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[6] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[6], NBits);
	v1.M_Value[6]:= (v1.M_Value[6] OR carry_bits_2);

	INT_1W_U_shl(v1.M_Value[7], NBits);
	v1.M_Value[7]:= (v1.M_Value[7] OR carry_bits_1);
	end;
end;

end;
{$endif}


{$ifdef 64bit}

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

carry_bits_mask:= $FFFFFFFF;
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

end;

{$endif}


(******************************************)
procedure ShiftUp_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X4_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
		v1.M_Value[4]:= 0;
		v1.M_Value[5]:= 0;
		v1.M_Value[6]:= 0;
		v1.M_Value[7]:= 0;
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

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X4_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
		v1.M_Value[4]:= 0;
		v1.M_Value[5]:= 0;
		v1.M_Value[6]:= 0;
		v1.M_Value[7]:= 0;
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
class operator Multi_Int_X4.shl(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_X4(Result, NBits);
end;


{******************************************}
class operator Multi_Int_X4.shr(const v1:Multi_Int_X4; const NBits:MULTI_INT_1W_U):Multi_Int_X4;		{$ifdef inline_functions_level_1} inline; {$endif}
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
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_2W_U;

begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

Result.Overflow_flag:= v1.Overflow_flag;
Result.Defined_flag:= v1.Defined_flag;
Result.Negative_flag:= v1.Negative_flag;

n:= 0;
if	(v1.M_Value_Size > Multi_X4_size) then
	begin
	while (n <= Multi_X4_maxi) do
		begin
		Result.M_Value[n]:= v1.M_Value[n];
		inc(n);
		end;
	while (n < v1.M_Value_Size) do
		begin
		if (v1.M_Value[n] <> 0) then
			goto OVERFLOW_BRANCH;
		inc(n);
		end;
	end
else
	begin
	while (n < v1.M_Value_Size) do
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

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
Result.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

if	(v1.Overflow_flag = TRUE)
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
class operator Multi_Int_X4.:=(const v1:Multi_Int_X2):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X4.:=(const v1:Multi_Int_X3):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X3_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure ansistring_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); 
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
		if mi.Defined_flag = FALSE then exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:ansistring):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
ansistring_to_Multi_Int_X4(v1,Result);
end;


{$ifdef 32bit}
(******************************************)
procedure MULTI_INT_4W_S_to_Multi_Int_X4(const v1:MULTI_INT_4W_S; out mi:Multi_Int_X4); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X4.:=(const v1:MULTI_INT_4W_S):Multi_Int_X4;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_4W_S_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_X4(const v1:MULTI_INT_4W_U; out mi:Multi_Int_X4); 
var
v	:MULTI_INT_4W_U;
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
class operator Multi_Int_X4.:=(const v1:MULTI_INT_4W_U):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X4.:=(const v1:MULTI_INT_2W_S):Multi_Int_X4;				{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_X4.:=(const v1:MULTI_INT_2W_U):Multi_Int_X4;				{$ifdef inline_functions_level_1} inline; {$endif}
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if single.IsInfinity(V)
			or single.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if single.IsInfinity(M) then 
				finished:= TRUE;
		end
		{
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
					Raise EIntOverflow.create('Overflow');
					end;
				end;
			end;
			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end;
		end
		}
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			{
			if real.IsInfinity(V)
			or real.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;
			}

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			{
			if real.IsInfinity(M) then 
				finished:= TRUE;
			}
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if double.IsInfinity(V)
			or double.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if double.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
				end;
			end;
		end;
	Inc(i);
	end;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


{$ifdef 32bit}

(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_4W_S;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1 < (-MULTI_INT_4W_U_MAXINT_1))
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

if v1.Negative_flag
then Result:= MULTI_INT_4W_S(-R)
else Result:= MULTI_INT_4W_S(R);
end;



(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_4W_U;
var		R	:MULTI_INT_4W_U;
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

if	(v1 > MULTI_INT_4W_U_MAXINT)
or	(v1.Negative_flag)
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

R:=	MULTI_INT_4W_U(v1.M_Value[3]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[2]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[1]);
R:=	(R * MULTI_INT_1W_U_MAXINT_1) + MULTI_INT_4W_U(v1.M_Value[0]);

Result:= (R);
end;

{$endif}


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):MULTI_INT_2W_S;
var	R	:MULTI_INT_2W_U;
begin
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
	Multi_Int_ERROR:= TRUE;
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
var
	n,b,c,e	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_S;
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
		or	(bit < 0)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			exit;
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_X4); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X4.Tobin(const LZ:T_Multi_Leading_Zeros):ansistring;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X4_to_bin(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X4(const v1:ansistring; out mi:Multi_Int_X4); 
var
	n,i,b,c,e	:MULTI_INT_2W_U;
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
		if mi.Defined_flag = FALSE then exit;

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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
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

end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_X4); overload;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
hex_to_Multi_Int_X4(v1,v2);
end;


(******************************************)
function Multi_Int_X4.FromHex(const v1:ansistring):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X4.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;					{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_X4.ToStr:ansistring;									{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X4_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_X4.:=(const v1:Multi_Int_X4):ansistring;		{$ifdef inline_functions_level_1} inline; {$endif}
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
	Multi_Int_ERROR:= TRUE;
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
	Result.Defined_flag:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative <> v2.Negative)
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X4.or(const v1,v2:Multi_Int_X4):Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] or v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] or v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] or v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] or v2.M_Value[3]);
Result.M_Value[4]:= (v1.M_Value[4] or v2.M_Value[4]);
Result.M_Value[5]:= (v1.M_Value[5] or v2.M_Value[5]);
Result.M_Value[6]:= (v1.M_Value[6] or v2.M_Value[6]);
Result.M_Value[7]:= (v1.M_Value[7] or v2.M_Value[7]);

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X4.and(const v1,v2:Multi_Int_X4):Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (v1.M_Value[0] and v2.M_Value[0]);
Result.M_Value[1]:= (v1.M_Value[1] and v2.M_Value[1]);
Result.M_Value[2]:= (v1.M_Value[2] and v2.M_Value[2]);
Result.M_Value[3]:= (v1.M_Value[3] and v2.M_Value[3]);
Result.M_Value[4]:= (v1.M_Value[4] and v2.M_Value[4]);
Result.M_Value[5]:= (v1.M_Value[5] and v2.M_Value[5]);
Result.M_Value[6]:= (v1.M_Value[6] and v2.M_Value[6]);
Result.M_Value[7]:= (v1.M_Value[7] and v2.M_Value[7]);

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X4.not(const v1:Multi_Int_X4):Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;

Result.M_Value[0]:= (not v1.M_Value[0]);
Result.M_Value[1]:= (not v1.M_Value[1]);
Result.M_Value[2]:= (not v1.M_Value[2]);
Result.M_Value[3]:= (not v1.M_Value[3]);
Result.M_Value[4]:= (not v1.M_Value[4]);
Result.M_Value[5]:= (not v1.M_Value[5]);
Result.M_Value[6]:= (not v1.M_Value[6]);
Result.M_Value[7]:= (not v1.M_Value[7]);

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:=  Multi_UBool_TRUE;
if v1.Negative
then Result.Negative_flag:= Multi_UBool_FALSE;
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
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Result:= 0;
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
class operator Multi_Int_X4.-(const v1:Multi_Int_X4):Multi_Int_X4;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(*******************v4*********************)
procedure multiply_Multi_Int_X4(const v1,v2:Multi_Int_X4;out Result:Multi_Int_X4); overload;
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
	exit;
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
	exit;
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

end;


(******************************************)
class operator Multi_Int_X4.*(const v1,v2:Multi_Int_X4):Multi_Int_X4;			{$ifdef inline_functions_level_1} inline; {$endif}
var	  R:Multi_Int_X4;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result:=0;
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
					Raise EIntOverflow.create('Overflow');
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
				Raise EIntOverflow.create('Overflow');
				end;
			exit;
			end;
		T.Negative_flag:= Multi_UBool_FALSE;

		TV:= T;
		PT := (PT div 2);
		end;
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
			Raise EIntOverflow.create('Overflow');
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
label	AGAIN,FINISH;
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
adjacent_word_carry
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
		goto FINISH;
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
	// NB this is not just for speed, the later code
	// will break if this case is not processed in advance

	if	(dividor_non_zero_pos = 0) then
		begin
		word_carry:= 0;
		i:= Multi_X4_maxi;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(P_quotient.M_Value[i]) * MULTI_INT_2W_U(dividor.M_Value[0])));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= word_carry;
		goto FINISH;
		end;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_X5(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_X5(dividor, shiftup_bits_dividor);
		end;

	adjacent_word_carry:= 0;
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
        adjacent_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((adjacent_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					adjacent_word_carry:= adjacent_word_carry + dividor.M_Value[dividor_i];
					if (adjacent_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;

			quotient:= 0;
			quotient.M_Value[quotient_i]:= word_division;
            next_dividend:= (dividend - (dividor * quotient));
			if Multi_Int_ERROR then
				begin
				P_quotient.Defined_flag:= FALSE;
				P_quotient.Overflow_flag:= TRUE;
				P_remainder.Defined_flag:= FALSE;
				P_remainder.Overflow_flag:= TRUE;
				exit;
				end;
			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;
	            next_dividend:= (dividend - (dividor * quotient));
				if Multi_Int_ERROR then
					begin
					P_quotient.Defined_flag:= FALSE;
					P_quotient.Overflow_flag:= TRUE;
					P_remainder.Defined_flag:= FALSE;
					P_remainder.Overflow_flag:= TRUE;
					exit;
					end;
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

FINISH:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;

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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	end;
end;


(***********v2************)
procedure SqRoot(const v1:Multi_Int_X4; out VR,VREM:Multi_Int_X4);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,
C,CC,LPC,
Q,R,T		:Multi_Int_X4;
finished	:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
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
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

VR.Defined_flag:= FALSE;
VREM.Defined_flag:= FALSE;

if	(v1 >= 100) then
	begin
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

	T:= (H-L);
	ShiftDown_MultiBits_Multi_Int_X4(T, 1);
	C:= (L+T);
	end
else
	begin
	C:= (v1 div 2);
	if	(C = 0) then C:= 1;
	end;

finished:= FALSE;
LPC:= v1;
repeat
	begin
	// CC:= ((C + (v1 div C)) div 2);
    intdivide_taylor_warruth_X4(v1,C,Q,R);
	CC:= (C+Q);
    ShiftDown_MultiBits_Multi_Int_X4(CC, 1);
	if (Multi_Int_ERROR) then exit;
	if	(ABS(C-CC) < 2) then
		begin
		if	(CC < LPC) then
			LPC:= CC
		else if (CC >= LPC) then
			finished:= TRUE
		end;
	C:= CC;
	end
until finished;

VREM:= (v1 - (LPC * LPC));
VR:= LPC;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;

end;


(*************************)
procedure SqRoot(const v1:Multi_Int_X4; out VR:Multi_Int_X4);				{$ifdef inline_functions_level_1} inline; {$endif}
var	VREM:Multi_Int_X4;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
end;


(*************************)
function SqRoot(const v1:Multi_Int_X4):Multi_Int_X4;						{$ifdef inline_functions_level_1} inline; {$endif}
var	VR,VREM:Multi_Int_X4;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
Result:= VR;
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


{$ifdef 32bit}
(******************************************)
procedure ShiftUp_NBits_Multi_Int_X5(Var v1:Multi_Int_X5; NBits:MULTI_INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;

	procedure INT_1W_U_shl(var v1:MULTI_INT_1W_U; const nbits:MULTI_INT_1W_U); 
	var carry_bits_mask_2w	:MULTI_INT_2W_U;
	begin
	carry_bits_mask_2w:= v1;
	carry_bits_mask_2w:= (carry_bits_mask_2w << NBits);
	v1:= MULTI_INT_1W_U(carry_bits_mask_2w and MULTI_INT_1W_U_MAXINT);
	end;

begin
if NBits > 0 then
begin

carry_bits_mask:= $FFFF;
NBits_max:= MULTI_INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
INT_1W_U_shl(carry_bits_mask, NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[0], NBits);

	carry_bits_2:= ((v1.M_Value[1] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[1], NBits);
	v1.M_Value[1]:= (v1.M_Value[1] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[2] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[2], NBits);
	v1.M_Value[2]:= (v1.M_Value[2] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[3] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[3], NBits);
	v1.M_Value[3]:= (v1.M_Value[3] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[4] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[4], NBits);
	v1.M_Value[4]:= (v1.M_Value[4] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[5] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[5], NBits);
	v1.M_Value[5]:= (v1.M_Value[5] OR carry_bits_1);

	carry_bits_1:= ((v1.M_Value[6] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[6], NBits);
	v1.M_Value[6]:= (v1.M_Value[6] OR carry_bits_2);

	carry_bits_2:= ((v1.M_Value[7] and carry_bits_mask) >> NBits_carry);
	INT_1W_U_shl(v1.M_Value[7], NBits);
	v1.M_Value[7]:= (v1.M_Value[7] OR carry_bits_1);

	INT_1W_U_shl(v1.M_Value[8], NBits);
	v1.M_Value[8]:= (v1.M_Value[8] OR carry_bits_2);
	end;
end;

end;

{$endif}


{$ifdef 64bit}
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

carry_bits_mask:= $FFFFFFFF;
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

	carry_bits_2:= ((v1.M_Value[7] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[7]:= ((v1.M_Value[7] << NBits) OR carry_bits_1);

	v1.M_Value[8]:= ((v1.M_Value[8] << NBits) OR carry_bits_2);
	end;
end;

end;

{$endif}


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

end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_X5(Var v1:Multi_Int_X5; NWords:MULTI_INT_1W_U);
var	n	:MULTI_INT_1W_U;
begin
if	(NWords > 0) then
	if	(NWords <= Multi_X5_maxi) then
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
		end
	else
		begin
		v1.M_Value[0]:= 0;
		v1.M_Value[1]:= 0;
		v1.M_Value[2]:= 0;
		v1.M_Value[3]:= 0;
		v1.M_Value[4]:= 0;
		v1.M_Value[5]:= 0;
		v1.M_Value[6]:= 0;
		v1.M_Value[7]:= 0;
		v1.M_Value[8]:= 0;
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
procedure Multi_Int_X4_to_Multi_Int_X5(const v1:Multi_Int_X4; out MI:Multi_Int_X5);
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
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
	exit;
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
	exit;
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
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
		Raise EIntOverflow.create('Overflow');
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
procedure Zero_Multi_Int_XV_M_Value(var MI:Multi_Int_XV);					{$ifdef inline_functions_level_1} inline; {$endif}
var	n	:MULTI_INT_1W_U;
begin
n:= MI.M_Value_Size;
setlength(MI.M_Value,0);
setlength(MI.M_Value,n);
end;


(******************************************)
class operator Multi_Int_XV.Initialize(var MI:Multi_Int_XV);					{$ifdef inline_functions_level_1} inline; {$endif}
begin
setlength(mi.M_Value, 0);
setlength(mi.M_Value, 2);
MI.M_Value_Size:= 2;
MI.Negative_flag:= Multi_UBool_FALSE;
MI.Overflow_flag:= FALSE;
MI.Defined_flag:= TRUE;
end;


(********************v3********************)
procedure Multi_Int_Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_2W_U);		{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(S < Multi_XV_min_size) then
	begin
	Multi_Int_ERROR:= TRUE;
	v1.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_Int_XV Size must be >= Multi_XV_min_size');
	exit;
	end;
if	(S > Multi_XV_limit) then
	begin
	Multi_Int_ERROR:= TRUE;
	v1.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Overflow (Multi_Int_XV Size > limit)');
	exit;
	end;

setlength(v1.M_Value, S);
v1.M_Value_Size:= S;

end;


(********************v3********************)
procedure INTERNAL_Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_2W_U);	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(S < Multi_XV_min_size) then
	begin
	Multi_Int_ERROR:= TRUE;
	v1.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_Int_XV Size must be >= Multi_XV_min_size');
	exit;
	end;
if	(S > (Multi_XV_limit + 3)) then
	begin
	Multi_Int_ERROR:= TRUE;
	v1.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_Int_XV Size exceeded limit');
	exit;
	end;

setlength(v1.M_Value, S);
v1.M_Value_Size:= S;

end;


(********************v2********************)
class operator Multi_Int_XV.copy(constref v1:Multi_Int_XV; var MI:Multi_Int_XV);	{$ifdef inline_functions_level_1} inline; {$endif}
var	N,Z,V,S	:MULTI_INT_2W_S;

begin
MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;
MI.M_Value:= v1.M_Value;
MI.M_Value_Size:= v1.M_Value_Size;
end;


(******************************************)
procedure Multi_Int_Set_XV_Limit(const S:MULTI_INT_2W_U);	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if (S >= Multi_XV_min_size) then Multi_XV_limit:= S
else
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EInterror.create('Multi_XV_limit must be >= Multi_XV_min_size');
	exit;
	end;

i:=0;
while (i < Multi_Int_XV_MAXINT.M_Value_Size ) do
	begin
	Multi_Int_XV_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;
Multi_Int_XV_MAXINT.Defined_flag:= TRUE;
Multi_Int_XV_MAXINT.Negative_flag:= FALSE;
Multi_Int_XV_MAXINT.Overflow_flag:= FALSE;
end;


(******************************************)
function ABS_greaterthan_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;
var
i1,i2	:MULTI_INT_2W_S;

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
i1,i2	:MULTI_INT_2W_S;

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
function nlz_MultiBits_XV(const v1:Multi_Int_XV):MULTI_INT_2W_U;
var
w,R	:MULTI_INT_2W_U;
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
if (w < v1.M_Value_Size) then
	begin
	R:= nlz_bits(v1.M_Value[v1.M_Value_Size-w-1]);
	R:= R + (w * MULTI_INT_1W_SIZE);
	Result:= R;
	end
else
	begin
	Result:= (w * MULTI_INT_1W_SIZE);
	end
end;


(******************************************)
function Multi_Int_XV.Overflow:boolean;							{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_XV.Defined:boolean;							{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_XV):boolean; overload;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_XV):boolean; overload; 		{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_XV.Negative:boolean; 						{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_XV):boolean; overload;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_XV):Multi_Int_XV; overload;		{$ifdef inline_functions_level_1} inline; {$endif}
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
function Multi_Int_XV_Odd(const v1:Multi_Int_XV):boolean; 				{$ifdef inline_functions_level_1} inline; {$endif}
var	bit1_mask	:MULTI_INT_1W_U;
begin

bit1_mask:= $1;

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

end;


(******************************************)
function Odd(const v1:Multi_Int_XV):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_XV_Odd(v1);
end;


(******************************************)
function Multi_Int_XV_Even(const v1:Multi_Int_XV):boolean; 				{$ifdef inline_functions_level_1} inline; {$endif}
begin

if ((v1.M_Value[0] and $1) = $1)
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

end;


(******************************************)
function Even(const v1:Multi_Int_XV):boolean; overload;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= Multi_Int_XV_Even(v1);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_2W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
	n			:MULTI_INT_1W_U;
{$ifdef 32bit}
	procedure INT_1W_U_shl(var v1:MULTI_INT_1W_U; const nbits:MULTI_INT_2W_U); 				{$ifdef inline_functions_level_1} inline; {$endif}
	var carry_bits_mask_2w	:MULTI_INT_2W_U;
	begin
	carry_bits_mask_2w:= v1;
	carry_bits_mask_2w:= (carry_bits_mask_2w << NBits);
	v1:= MULTI_INT_1W_U(carry_bits_mask_2w and MULTI_INT_1W_U_MAXINT);
	end;
{$endif}

begin
if NBits > 0 then
	begin

	{$ifdef 32bit}
	carry_bits_mask:= $FFFF;
	{$else}
	carry_bits_mask:= $FFFFFFFF;
	{$endif}

	NBits_max:= MULTI_INT_1W_SIZE;
	NBits_carry:= (NBits_max - NBits);

	{$ifdef 32bit}
	INT_1W_U_shl(carry_bits_mask, NBits_carry);
	{$else}
	carry_bits_mask:= (carry_bits_mask << NBits_carry);
	{$endif}

	if NBits <= NBits_max then
		begin
		carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
		{$ifdef 32bit}
		// v1.M_Value[0]:= (v1.M_Value[0] << NBits);
	    INT_1W_U_shl(v1.M_Value[0], NBits);
		{$else}
		v1.M_Value[0]:= (v1.M_Value[0] << NBits);
		{$endif}

		n:=1;
		while (n < (v1.M_Value_Size-1)) do
			begin
			carry_bits_2:= ((v1.M_Value[n] and carry_bits_mask) >> NBits_carry);

			{$ifdef 32bit}
			// v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);
	        INT_1W_U_shl(v1.M_Value[n], NBits);
	        v1.M_Value[n]:= (v1.M_Value[n] OR carry_bits_1);
			{$else}
			v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);
			{$endif}

			carry_bits_1:= carry_bits_2;
			inc(n);
			end;

		v1.M_Value[n]:= ((v1.M_Value[n] << NBits) OR carry_bits_1);

		end;
	end;
end;


(******************************************)
procedure ShiftUp_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_2W_U);
var	n,i	:MULTI_INT_1W_U;
begin
if (NWords > 0) then
	if (NWords < v1.M_Value_Size) then
		begin
		n:= NWords;
		while (n > 0) do
			begin
			i:= (v1.M_Value_Size - 1);
			while (i > 0) do
				begin
				v1.M_Value[i]:= v1.M_Value[i-1];
				dec(i);
				end;
			v1.M_Value[i]:= 0;
			DEC(n);
			end;
		end
	else
		begin
		n:=  (v1.M_Value_Size - 1);
		while (n > 0) do
			begin
			v1.M_Value[n]:= 0;
			DEC(n);
			end;
		end;
end;


{******************************************}
procedure ShiftUp_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_2W_U);
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
       	INTERNAL_Reset_XV_Size(v1, (NWords_count + 1));
		if Multi_Int_ERROR then exit;
		ShiftUp_NWords_Multi_Int_XV(v1, NWords_count);
		end
	else NBits_count:= NBits;
	if (NBits_count > nlz_bits( v1.M_Value[ (v1.M_Value_Size - 1) ] )) then
    	INTERNAL_Reset_XV_Size(v1, (v1.M_Value_Size + 1));
	ShiftUp_NBits_Multi_Int_XV(v1, NBits_count);
	end;
end;


{******************************************}
class operator Multi_Int_XV.shl(const v1:Multi_Int_XV; const NBits:MULTI_INT_2W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
ShiftUp_MultiBits_Multi_Int_XV(Result, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_2W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:MULTI_INT_1W_U;
	n			:integer;
begin
if NBits > 0 then
	begin

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
end;


(******************************************)
procedure ShiftDown_NWords_Multi_Int_XV(var v1:Multi_Int_XV; NWords:MULTI_INT_2W_U);
var	n,i	:MULTI_INT_1W_U;
begin

if (NWords > 0) then
	if (NWords < v1.M_Value_Size ) then
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
		end
	else
		begin
		n:= (v1.M_Value_Size - 1);
		while (n > 0) do
			begin
			v1.M_Value[n]:= 0;
			DEC(n);
			end;
		end;

end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_XV(var v1:Multi_Int_XV; NBits:MULTI_INT_2W_U);
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
class operator Multi_Int_XV.shr(const v1:Multi_Int_XV; const NBits:MULTI_INT_2W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= v1;
ShiftDown_MultiBits_Multi_Int_XV(Result, NBits);
end;


(******************************************)
class operator Multi_Int_XV.>(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_XV.<(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions_level_1} inline; {$endif}
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
function ABS_equal_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean;	{$ifdef inline_functions_level_1} inline; {$endif}
var
i1,i2	:MULTI_INT_2W_S;

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
function ABS_notequal_Multi_Int_XV(const v1,v2:Multi_Int_XV):Boolean; 	{$ifdef inline_functions_level_1} inline; {$endif}
begin
Result:= (not ABS_equal_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.=(const v1,v2:Multi_Int_XV):Boolean;		{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_XV.<>(const v1,v2:Multi_Int_XV):Boolean;		{$ifdef inline_functions_level_1} inline; {$endif}
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
if ( v1.Negative_flag <> v2.Negative_flag ) then
	Result:= TRUE
else
	Result:= (not ABS_equal_Multi_Int_XV(v1,v2));
end;


(******************************************)
class operator Multi_Int_XV.<=(const v1,v2:Multi_Int_XV):Boolean;		{$ifdef inline_functions_level_1} inline; {$endif}
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
class operator Multi_Int_XV.>=(const v1,v2:Multi_Int_XV):Boolean;		{$ifdef inline_functions_level_1} inline; {$endif}
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
procedure ansistring_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV);
var
	n,i,b,c,e,s	:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

s:= (length(v1) div 10);
if (s <= Multi_XV_min_size) then s:= Multi_XV_min_size;
setlength(M_Val, s);

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
		if mi.Defined_flag = FALSE then exit;

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

Multi_Int_Reset_XV_Size(MI, s);
if Multi_Int_ERROR then
	begin
	mi.Defined_flag:= FALSE;
	exit;
	end;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;

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

end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:ansistring):Multi_Int_XV;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
ansistring_to_Multi_Int_XV(v1,Result);
end;


(*********************v2*******************)
procedure Multi_Int_XV_to_ansistring(const v1:Multi_Int_XV; out v2:ansistring);
var
s				:ansistring = '';
M_Val			:array of MULTI_INT_2W_U;
n,t,z			:MULTI_INT_2W_S;
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
z:= -1;
n:= (v1.M_Value_Size - 1);
while (n >= 0) do
	begin
	t:= v1.M_Value[n];
	M_Val[n]:= t;
	if (z = -1) then
	if (t <> 0) then
		z:= n;
	Dec(n);
	end;
if (z = -1) then z:= 0;

repeat
	n:= z;
	z:= -1;
	M_Val_All_Zero:= TRUE;
	while (n > 0) do
		begin
		M_Val[n-1]:= M_Val[n-1] + (MULTI_INT_1W_U_MAXINT_1 * (M_Val[n] MOD 10));
		M_Val[n]:= (M_Val[n] DIV 10);
		if M_Val[n] <> 0 then
			begin
			M_Val_All_Zero:= FALSE;
			if (z = -1) then z:= n;
			end;
		dec(n);
		end;

	if (z = -1) then z:= 0;
	s:= inttostr(M_Val[0] MOD 10) + s;
	M_Val[0]:= (M_Val[0] DIV 10);
	if M_Val[0] <> 0 then M_Val_All_Zero:= FALSE;

until M_Val_All_Zero;

if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
v2:=s;
end;


(******************************************)
function Multi_Int_XV.ToStr:ansistring;									{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_XV_to_ansistring(self, Result);
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_XV):ansistring;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_XV_to_ansistring(v1, Result);
end;


(******************************************)
procedure hex_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV);
var
	n,i,b,c,e,s	:MULTI_INT_2W_U;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;
mi.Defined_flag:= TRUE;

s:= ( length(v1) div 8);
if (s < Multi_XV_min_size) then s:= Multi_XV_min_size;
setlength(M_Val, s);
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
		if mi.Defined_flag = FALSE then exit;

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

Multi_Int_Reset_XV_Size(MI, s);
if Multi_Int_ERROR then
	begin
	mi.Defined_flag:= FALSE;
	exit;
	end;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;

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

end;


(******************************************)
function Multi_Int_XV.FromHex(const v1:ansistring):Multi_Int_XV;			{$ifdef inline_functions_level_1} inline; {$endif}
begin
hex_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure FromHex(const v1:ansistring; out v2:Multi_Int_XV); overload;		{$ifdef inline_functions_level_1} inline; {$endif}
begin
hex_to_Multi_Int_XV(v1,v2);
end;


(******************************************)
procedure Multi_Int_XV_to_hex(const v1:Multi_Int_XV; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
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
function Multi_Int_XV.ToHex(const LZ:T_Multi_Leading_Zeros):ansistring;			{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_XV_to_hex(self, Result, LZ);
end;


(******************************************)
procedure Bin_to_Multi_Int_XV(const v1:ansistring; var mi:Multi_Int_XV);
var
	n,b,c,e,s	:MULTI_INT_2W_U;
	bit			:MULTI_INT_1W_S;
	M_Val		:array of MULTI_INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
Multi_Int_ERROR:= FALSE;

//s:= Multi_XV_size;
s:= (length(v1) div 32);
if (s <= Multi_XV_min_size) then s:= Multi_XV_min_size;

setlength(M_Val, s);
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
		or	(bit < 0)
		then
			begin
			Multi_Int_ERROR:= TRUE;
			mi.Overflow_flag:=TRUE;
			mi.Defined_flag:= FALSE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				Raise EInterror.create('Invalid binary digit');
			exit;
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

Multi_Int_Reset_XV_Size(MI, s);
if Multi_Int_ERROR then
	begin
	mi.Defined_flag:= FALSE;
	exit;
	end;
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;

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

end;


(******************************************)
procedure FromBin(const v1:ansistring; out mi:Multi_Int_XV); overload;			{$ifdef inline_functions_level_1} inline; {$endif}
begin
Bin_to_Multi_Int_XV(v1,mi);
end;


(******************************************)
function Multi_Int_XV.FromBin(const v1:ansistring):Multi_Int_XV;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
bin_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_XV_to_bin(const v1:Multi_Int_XV; out v2:ansistring; LZ:T_Multi_Leading_Zeros);
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
function Multi_Int_XV.ToBin(const LZ:T_Multi_Leading_Zeros):ansistring;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_XV_to_bin(self, Result, LZ);
end;


(******************************************)
procedure MULTI_INT_2W_S_to_Multi_Int_XV(const v1:MULTI_INT_2W_S; var mi:Multi_Int_XV);		{$ifdef inline_functions_level_1} inline; {$endif}
var	n	:MULTI_INT_2W_U;

begin
setlength(mi.M_Value, 0);
setlength(mi.M_Value, 2);
mi.M_Value_Size:= 2;

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
class operator Multi_Int_XV.:=(const v1:MULTI_INT_2W_S):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_2W_S_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure MULTI_INT_2W_U_to_Multi_Int_XV(const v1:MULTI_INT_2W_U; var mi:Multi_Int_XV);			{$ifdef inline_functions_level_1} inline; {$endif}
var	n	:MULTI_INT_2W_U;
begin
setlength(mi.M_Value, 0);
setlength(mi.M_Value, 2);
mi.M_Value_Size:= 2;

mi.M_Value[0]:= (v1 MOD MULTI_INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV MULTI_INT_1W_U_MAXINT_1);

end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_2W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
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
// Zero_Multi_Int_XV_M_Value(mi);
setlength(mi.M_Value, 0);
Multi_Int_Reset_XV_Size(MI, 4);
if Multi_Int_ERROR then
	begin
	mi.Defined_flag:=FALSE;
	exit;
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

if (v1 < 0) then mi.Negative_flag:= Multi_UBool_TRUE
else mi.Negative_flag:= Multi_UBool_FALSE;
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_4W_S):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_4W_S_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure MULTI_INT_4W_U_to_Multi_Int_XV(const v1:MULTI_INT_4W_U; var mi:Multi_Int_XV);
var
v	:MULTI_INT_4W_U;
n	:MULTI_INT_2W_U;

begin
setlength(mi.M_Value, 0);
Multi_Int_Reset_XV_Size(MI, 4);
if Multi_Int_ERROR then
	begin
	mi.Defined_flag:=FALSE;
	exit;
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

{
n:=4;
while (n < m1.M_Value_Size) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
}
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:MULTI_INT_4W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
MULTI_INT_4W_U_to_Multi_Int_XV(v1,Result);
end;
{$endif}


(******************************************)
procedure Multi_Int_X4_to_Multi_Int_XV(const v1:Multi_Int_X4; var MI:Multi_Int_XV);
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_1W_U;

begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

setlength(mi.M_Value, 0);
Multi_Int_Reset_XV_Size(MI, Multi_X4_size);
if Multi_Int_ERROR then
	goto OVERFLOW_BRANCH;

n:= 0;
while (n <= Multi_X4_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
MI.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X4):Multi_Int_XV;			{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X4_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X4):Multi_Int_XV;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X4_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_XV(const v1:Multi_Int_X3; var MI:Multi_Int_XV);
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_1W_U;

begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

setlength(mi.M_Value, 0);
Multi_Int_Reset_XV_Size(MI, Multi_X3_size);
if Multi_Int_ERROR then
	goto OVERFLOW_BRANCH;

n:= 0;
while (n <= Multi_X3_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
MI.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:

end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X3):Multi_Int_XV;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X3_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X3):Multi_Int_XV;					{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X3_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_XV(const v1:Multi_Int_X2; var MI:Multi_Int_XV);
label OVERFLOW_BRANCH, CLEAN_EXIT;
var	n	:MULTI_INT_1W_U;
begin
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

if	(v1.Overflow_flag = TRUE) then
	goto OVERFLOW_BRANCH;

MI.Overflow_flag:= v1.Overflow_flag;
MI.Defined_flag:= v1.Defined_flag;
MI.Negative_flag:= v1.Negative_flag;

setlength(mi.M_Value, 0);
Multi_Int_Reset_XV_Size(MI, Multi_X2_size);
if Multi_Int_ERROR then
	goto OVERFLOW_BRANCH;

n:= 0;
while (n <= Multi_X2_maxi) do
	begin
	MI.M_Value[n]:= v1.M_Value[n];
	inc(n);
	end;

goto CLEAN_EXIT;

OVERFLOW_BRANCH:

Multi_Int_ERROR:= TRUE;
MI.Overflow_flag:= TRUE;
if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	Raise EInterror.create('Overflow');
	end;
exit;

CLEAN_EXIT:
end;


(******************************************)
class operator Multi_Int_XV.:=(const v1:Multi_Int_X2):Multi_Int_XV;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
Multi_Int_X2_to_Multi_Int_XV(v1,Result);
end;


(******************************************)
function To_Multi_Int_XV(const v1:Multi_Int_X2):Multi_Int_XV;					{$ifdef inline_functions_level_1} inline; {$endif}
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if single.IsInfinity(V)
			or single.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if single.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			{
			if real.IsInfinity(V)
			or real.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;
			}

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			{
			if real.IsInfinity(M) then 
				finished:= TRUE;
			}
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
			try begin
				V:= (V * M);
				R:= R + V;
				end
			except Multi_Int_ERROR:= TRUE;
			end; // except
			if double.IsInfinity(V)
			or double.IsInfinity(R) then
				Multi_Int_ERROR:= TRUE;

			if (Multi_Int_ERROR) then
				begin
				finished:= TRUE;
				if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
					begin
					Raise EIntOverflow.create('Overflow');
					end;
				end;

			V:= MULTI_INT_1W_U_MAXINT_1;
			try M:= (M * V);
			except finished:= TRUE;
			end; // except
			if double.IsInfinity(M) then 
				finished:= TRUE;
		end
	else
		begin
		if	(v1.M_Value[i] > 0) then
			begin
			Multi_Int_ERROR:= TRUE;
			if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
				begin
				Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
Multi_Int_ERROR:= FALSE;
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
if	(v1.Overflow_flag)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
or	(v1.Negative_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
or	(v1.Negative_flag = TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag)
or	(v1.Negative_flag = Multi_UBool_TRUE)
then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
then
	begin
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
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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


(*******************v4B*********************)
procedure INTERNAL_add_Multi_Int_XV(const v1,v2:Multi_Int_XV; var Result:Multi_Int_XV);
var
i,cv,
vz1,vz2,
rs,rz,ro,
z1,z2,
tv,tv1,tv2		:MULTI_INT_2W_S;
M_Val_All_Zero	:boolean;
zf				:boolean;

begin
Zero_Multi_Int_XV_M_Value(Result);

// skip leading zeros in v2
zf:= FALSE;
i:= (v2.M_Value_Size - 1);
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
if (z2 < 0) then z2:= 0;

// skip leading zeros in v1
zf:= FALSE;
i:= (v1.M_Value_Size - 1);
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
if (z1 < 0) then z1:= 0;

if	(z2 > z1) then
	begin
	vz1:= z1;
	vz2:= z2;
	end
else
	begin
	vz2:= z1;
	vz1:= z2;
	end;

if	(v2.M_Value_Size > v1.M_Value_Size) then
	rs:= (v2.M_Value_Size + 1)
else
	rs:= (v1.M_Value_Size + 1);

ro:= Result.M_Value_Size;
if	(rs > Result.M_Value_Size) then
	begin
	INTERNAL_Reset_XV_Size(Result,rs);
	if Multi_Int_ERROR then exit;
	end;

Result.Overflow_flag:= FALSE;
Result.Defined_flag:= FALSE;
Result.Negative_flag:= Multi_UBool_UNDEF;

// main loopy

M_Val_All_Zero:=TRUE;
rz:= 0;
cv:= 0;
i:= 0;

while (i <= vz1) do
	begin
	tv:= cv + (v1.M_Value[i] + v2.M_Value[i]);
	if	tv > MULTI_INT_1W_U_MAXINT then
		begin
		Result.M_Value[i]:= (tv - MULTI_INT_1W_U_MAXINT_1);
		cv:= 1;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else if tv > 0 then
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		end;
	inc(i);
	end;

while (i <= vz2) do
	begin
	if (i < v1.M_Value_Size) then tv1:= v1.M_Value[i] else tv1:=0;
	if (i < v2.M_Value_Size) then tv2:= v2.M_Value[i] else tv2:=0;
	tv:= cv + (tv1 + tv2);
	if	tv > MULTI_INT_1W_U_MAXINT then
		begin
		Result.M_Value[i]:= (tv - MULTI_INT_1W_U_MAXINT_1);
		cv:= 1;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else if tv > 0 then
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		end;
	inc(i);
	end;

if (cv <> 0) then
	begin
	if (i < rs) then
		begin
		if (i < v1.M_Value_Size) then tv1:= v1.M_Value[i] else tv1:=0;
		if (i < v2.M_Value_Size) then tv2:= v2.M_Value[i] else tv2:=0;
		tv:= cv + (tv1 + tv2);
		Result.M_Value[i]:= tv;
		if tv <> 0 then
			begin
			rz:= i;
			M_Val_All_Zero:= FALSE;
			end;
		end
	else
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:= FALSE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EIntOverflow.create('Internal error in Multi_Int_XV Add');
		exit;
		end;
	end;

Inc(rz);
if (rz < rs)
then
	begin
	if (rz < ro) then rz:= ro;
	INTERNAL_Reset_XV_Size(Result,rz);
	if Multi_Int_ERROR then exit;
	end;

Result.Overflow_flag:= FALSE;
Result.Defined_flag:= TRUE;
if M_Val_All_Zero then
	Result.Negative_flag:= FALSE
else
	Result.Negative_flag:= Multi_UBool_UNDEF;
end;


(*******************v4B*********************)
procedure INTERNAL_subtract_Multi_Int_XV(const v1,v2:Multi_Int_XV; var Result:Multi_Int_XV);
var
i,cv,
vz1,vz2,
rs,rz,ro,
z1,z2,
tv,tv1,tv2		:MULTI_INT_2W_S;
M_Val_All_Zero	:boolean;
zf				:boolean;

begin
Zero_Multi_Int_XV_M_Value(Result);

// skip leading zeros in v2
zf:= FALSE;
i:= (v2.M_Value_Size - 1);
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
if (z2 < 0) then z2:= 0;

// skip leading zeros in v1
zf:= FALSE;
i:= (v1.M_Value_Size - 1);
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
if (z1 < 0) then z1:= 0;

if	(z2 > z1) then
	begin
	vz1:= z1;
	vz2:= z2;
	end
else
	begin
	vz2:= z1;
	vz1:= z2;
	end;

if	(v2.M_Value_Size > v1.M_Value_Size) then
	rs:= (v2.M_Value_Size + 1)
else
	rs:= (v1.M_Value_Size + 1);

ro:= Result.M_Value_Size;
if	(rs > Result.M_Value_Size) then
	begin
	INTERNAL_Reset_XV_Size(Result,rs);
	if Multi_Int_ERROR then exit;
	end;

Result.Overflow_flag:= FALSE;
Result.Defined_flag:= FALSE;
Result.Negative_flag:= Multi_UBool_UNDEF;

// main loopy

M_Val_All_Zero:=TRUE;
rz:= 0;
cv:= 0;
i:= 0;

while (i <= vz1) do
	begin
	tv:= cv + (v1.M_Value[i] - v2.M_Value[i]);
	if	tv < 0 then
		begin
		Result.M_Value[i]:= (tv + MULTI_INT_1W_U_MAXINT_1);
		cv:= -1;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else if tv > 0 then
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		end;
	inc(i);
	end;

while (i <= vz2) do
	begin
	if (i < v1.M_Value_Size) then tv1:= v1.M_Value[i] else tv1:=0;
	if (i < v2.M_Value_Size) then tv2:= v2.M_Value[i] else tv2:=0;
	tv:= cv + (tv1 - tv2);
	if	tv < 0 then
		begin
		Result.M_Value[i]:= (tv + MULTI_INT_1W_U_MAXINT_1);
		cv:= -1;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else if tv > 0 then
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		rz:= i;
		M_Val_All_Zero:= FALSE;
		end
	else
		begin
		Result.M_Value[i]:= tv;
		cv:= 0;
		end;
	inc(i);
	end;

if (cv <> 0) then
	if (i < rs) then
		begin
		if (i < v1.M_Value_Size) then tv1:= v1.M_Value[i] else tv1:=0;
		if (i < v2.M_Value_Size) then tv2:= v2.M_Value[i] else tv2:=0;
		tv:= cv + (tv1 - tv2);
		Result.M_Value[i]:= tv;
		if tv <> 0 then
			begin
			rz:= i;
			M_Val_All_Zero:= FALSE;
			end;
		end
	else
		begin
		Multi_Int_ERROR:= TRUE;
		Result.Defined_flag:= FALSE;
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			Raise EIntOverflow.create('Internal error in Multi_Int_XV Subtract');
		exit;
		end;

Inc(rz);
if (rz < rs)
then
	begin
	if (rz < ro) then rz:= ro;
	INTERNAL_Reset_XV_Size(Result,rz);
	if Multi_Int_ERROR then exit;
	end;

Result.Overflow_flag:= FALSE;
Result.Defined_flag:= TRUE;
if M_Val_All_Zero then
	Result.Negative_flag:= FALSE
else
	Result.Negative_flag:= Multi_UBool_UNDEF;
end;


(******************************************)
procedure add_Multi_Int_XV(const v1,v2:Multi_Int_XV; var Result:Multi_Int_XV);
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	INTERNAL_add_Multi_Int_XV(v1,v2,Result);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_XV(v1,v2)
		then
			begin
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
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
procedure subtract_Multi_Int_XV(const v1,v2:Multi_Int_XV; var Result:Multi_Int_XV);
Var	Neg:Multi_UBool_Values;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		INTERNAL_add_Multi_Int_XV(v1,v2,Result);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		INTERNAL_add_Multi_Int_XV(v1,v2,Result);
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
class operator Multi_Int_XV.+(const v1,v2:Multi_Int_XV):Multi_Int_XV;
Var	Neg:T_Multi_UBool;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;

if	(v1.Negative_flag = v2.Negative_flag)
then
	begin
	// Result:= INTERNAL_add_Multi_Int_XV(v1,v2);
	INTERNAL_add_Multi_Int_XV(v1,v2,Result);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_XV(v1,v2)
		then
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
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
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
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
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Neg:=Multi_UBool_UNDEF;
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	// Result:= INTERNAL_add_Multi_Int_XV(v1,v2);
	INTERNAL_add_Multi_Int_XV(v1,v2,Result);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_XV(v1,v2)
	then
		begin
		// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
		INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
		INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
			// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_XV(v2,v1)
		then
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
			INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
			INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		// Result:= INTERNAL_add_Multi_Int_XV(v1,v2);
		INTERNAL_add_Multi_Int_XV(v1,v2,Result);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		// Result:= INTERNAL_add_Multi_Int_XV(v1,v2);
		INTERNAL_add_Multi_Int_XV(v1,v2,Result);
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
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
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
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		// Result:= INTERNAL_subtract_Multi_Int_XV(v2,v1);
		INTERNAL_subtract_Multi_Int_XV(v2,v1,Result);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		// Result:= INTERNAL_subtract_Multi_Int_XV(v1,v2);
		INTERNAL_subtract_Multi_Int_XV(v1,v2,Result);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	// Result:= INTERNAL_add_Multi_Int_XV(v1,v2);
	INTERNAL_add_Multi_Int_XV(v1,v2,Result);
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
class operator Multi_Int_XV.-(const v1:Multi_Int_XV):Multi_Int_XV;				{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
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
	Result.Defined_flag:= v1.Defined_flag;
	Result.Overflow_flag:= v1.Overflow_flag;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Result:= v1;
if	(v1.Negative_flag = Multi_UBool_TRUE) then Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag = Multi_UBool_FALSE) then Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_XV.xor(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
i,s1,s2,s	:MULTI_INT_1W_S;
tv1,tv2		:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;

if (s > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, s);
	if Multi_Int_ERROR then
		begin
		Result.Defined_flag:= FALSE;
		exit;
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
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative <> v2.Negative)
then Result.Negative_flag:= Multi_UBool_TRUE;

end;


(******************************************)
class operator Multi_Int_XV.or(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
i,s1,s2,s	:MULTI_INT_1W_S;
tv1,tv2		:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;

if (s > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, s);
	if Multi_Int_ERROR then
		begin
		Result.Defined_flag:= FALSE;
		exit;
		end;
	end;

i:=0;
while (i < s) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
	Result.M_Value[i]:=(tv1 or tv2);
	Inc(i);
	end;

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;

end;


(******************************************)
class operator Multi_Int_XV.and(const v1,v2:Multi_Int_XV):Multi_Int_XV;
var
i,s1,s2,s	:MULTI_INT_1W_S;
tv1,tv2		:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

s1:= v1.M_Value_Size;
s2:= v2.M_Value_Size;
s:= s1;
if (s1 < s2) then s:= s2;

if (s > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, s);
	if Multi_Int_ERROR then
		begin
		Result.Defined_flag:= FALSE;
		exit;
		end;
	end;

i:=0;
while (i < s) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	if	(i < s2) then tv2:= v2.M_Value[i] else tv2:= 0;
	Result.M_Value[i]:=(tv1 and tv2);
	Inc(i);
	end;

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:= Multi_UBool_FALSE;
if v1.Negative and v2.Negative
then Result.Negative_flag:= Multi_UBool_TRUE;

end;


(******************************************)
class operator Multi_Int_XV.not(const v1:Multi_Int_XV):Multi_Int_XV;
var
i,s1,s	:MULTI_INT_1W_S;
tv1		:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

s:= v1.M_Value_Size;

if (s > Result.M_Value_Size) then
	begin
	Multi_Int_Reset_XV_Size(Result, s);
	if Multi_Int_ERROR then
		begin
		Result.Defined_flag:= FALSE;
		exit;
		end;
	end;

i:=0;
while (i < s) do
	begin
	if	(i < s1) then tv1:= v1.M_Value[i] else tv1:= 0;
	Result.M_Value[i]:= (not tv1);
	Inc(i);
	end;

Result.Defined_flag:=TRUE;
Result.Overflow_flag:= FALSE;

Result.Negative_flag:=  Multi_UBool_TRUE;
if v1.Negative
then Result.Negative_flag:= Multi_UBool_FALSE;

end;


(*******************v6*********************)
procedure multiply_Multi_Int_XV(const v1,v2:Multi_Int_XV; var Result:Multi_Int_XV); overload;
var
zf		:boolean;
rs,vs,ro,
tv		:MULTI_INT_2W_U;
i,j,h,
z1,z2	:MULTI_INT_2W_S;

begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

Zero_Multi_Int_XV_M_Value(Result);

// skip leading zeros in v2
zf:= FALSE;
i:= (v2.M_Value_Size - 1);
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
if	(z2 < 0) then exit;

// skip leading zeros in v1
zf:= FALSE;
i:= (v1.M_Value_Size - 1);
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
if	(z1 < 0) then exit;

rs:= (z1 + z2 + 3);

ro:= Result.M_Value_Size;
INTERNAL_Reset_XV_Size(Result,rs);
if Multi_Int_ERROR then	exit;

Result.Overflow_flag:= FALSE;
Result.Defined_flag:= TRUE;
Result.Negative_flag:= Multi_UBool_UNDEF;

if	(v2.M_Value_Size > v1.M_Value_Size) then
	vs:= v2.M_Value_Size
else
	vs:= v1.M_Value_Size;

// main loopy
h:= 0;
i:= 0;
j:= 0;
repeat
	if (v2.M_Value[j] <> 0) then
    	begin
		repeat
			if	(v1.M_Value[i] <> 0)
			then
				begin
				h:= (i+j);
                tv:= Result.M_Value[h] + (v1.M_Value[i] * v2.M_Value[j]);
				Result.M_Value[h]:= (tv MOD MULTI_INT_1W_U_MAXINT_1);
                tv:= (tv DIV MULTI_INT_1W_U_MAXINT_1);
				while (tv > 0) and (h < rs) do
					begin
					Inc(h);
	                tv:= (tv + Result.M_Value[h]);
					Result.M_Value[h]:= (tv MOD MULTI_INT_1W_U_MAXINT_1);
					tv:= (tv DIV MULTI_INT_1W_U_MAXINT_1);
					end;
                if (tv > 0) and (h < rs) then
					begin
                    Raise EInterror.create('Internal error in INTERNAL_multiply_Multi_Int_XV');
					end;
				end;
			INC(i);
		until (i > z1);
		i:=0;
        end;
	INC(j);
until (j > z2);

Inc(h);
if (h < rs)
then
	begin
	if (h < ro) then h:= ro;
	INTERNAL_Reset_XV_Size(Result,h);
	if Multi_Int_ERROR then exit;
	end;

if	(v1.Negative_flag = v2.Negative_flag)
then Result.Negative_flag:= Multi_UBool_FALSE
else Result.Negative_flag:=Multi_UBool_TRUE;

end;


(******************************************)
procedure multiply_Multi_Int_XV(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_S; var Result:Multi_Int_XV); overload;
var
i,h,rs,
z1	:MULTI_INT_2W_S;
zf	:boolean;
tv	:MULTI_INT_2W_S;

begin
Zero_Multi_Int_XV_M_Value(Result);
if (v2 = 0) then
	exit;

// skip leading zeros in v1
zf:= FALSE;
i:= (v1.M_Value_Size - 1);
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
	exit;
	end;

rs:= (z1 + 3);
INTERNAL_Reset_XV_Size(Result,rs);
if Multi_Int_ERROR then	exit;

// main loopy
i:= 0;
h:= 0;
repeat
	if	(v1.M_Value[i] <> 0)
	then
		begin
		h:= i+1;
		tv:= (v1.M_Value[i] * v2) + Result.M_Value[i];
		Result.M_Value[i]:= (tv MOD MULTI_INT_1W_U_MAXINT_1);
		Result.M_Value[h]:= (tv DIV MULTI_INT_1W_U_MAXINT_1);
		end;
	INC(i);
until (i > z1);

if (Result.M_Value[h] <> 0) then
	z1:= h;

Inc(z1);

if (z1 < rs)
then
	begin
	if (z1 < Multi_XV_min_size) then z1:= Multi_XV_min_size;
	INTERNAL_Reset_XV_Size(Result,z1);
	if Multi_Int_ERROR then exit;
	end;

Result.Negative_flag:= v1.Negative_flag;
end;


(******************************************)
procedure multiply_Multi_Int_XV(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_U; var Result:Multi_Int_XV); overload;
var
i,h,rs,
z1	:MULTI_INT_2W_S;
zf	:boolean;
tv	:MULTI_INT_2W_U;

begin
Zero_Multi_Int_XV_M_Value(Result);
if (v2 = 0) then
	exit;

// skip leading zeros in v1
zf:= FALSE;
i:= (v1.M_Value_Size - 1);
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
	exit;
	end;

rs:= (z1 + 3);
INTERNAL_Reset_XV_Size(Result,rs);
if Multi_Int_ERROR then	exit;

// main loopy
i:= 0;
h:= 0;
repeat
	if	(v1.M_Value[i] <> 0)
	then
		begin
		h:= i+1;
		tv:= (v1.M_Value[i] * v2) + Result.M_Value[i];
		Result.M_Value[i]:= (tv MOD MULTI_INT_1W_U_MAXINT_1);
		Result.M_Value[h]:= (tv DIV MULTI_INT_1W_U_MAXINT_1);
		end;
	INC(i);
until (i > z1);

if (Result.M_Value[h] <> 0) then
	z1:= h;

Inc(z1);

if (z1 < rs)
then
	begin
	if (z1 < Multi_XV_min_size) then z1:= Multi_XV_min_size;
	INTERNAL_Reset_XV_Size(Result,z1);
	if Multi_Int_ERROR then exit;
	end;

Result.Negative_flag:= v1.Negative_flag;
end;


(******************************************)
class operator Multi_Int_XV.*(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_S):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

multiply_Multi_Int_XV(v1,v2,Result);

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v2:MULTI_INT_1W_S; const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

multiply_Multi_Int_XV(v1,v2,Result);

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v1:Multi_Int_XV; const v2:MULTI_INT_1W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

multiply_Multi_Int_XV(v1,v2,Result);

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v2:MULTI_INT_1W_U; const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

multiply_Multi_Int_XV(v1,v2,Result);

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v1:Multi_Int_XV; const v2:MULTI_INT_2W_U):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var
m2	:Multi_Int_XV;
i2	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

if	(v2 < MULTI_INT_1W_U_MAXINT_1)
then
	begin
    i2:= v2;
	multiply_Multi_Int_XV(v1,i2,Result);
	end
else
	begin
    m2:= v2;
	multiply_Multi_Int_XV(v1,m2,Result);
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v2:MULTI_INT_2W_U; const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var
m2	:Multi_Int_XV;
i2	:MULTI_INT_1W_U;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

if	(v2 < MULTI_INT_1W_U_MAXINT_1)
then
	begin
    i2:= v2;
	multiply_Multi_Int_XV(v1,i2,Result);
	end
else
	begin
    m2:= v2;
	multiply_Multi_Int_XV(v1,m2,Result)
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v1:Multi_Int_XV; const v2:MULTI_INT_2W_S):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var
m2	:Multi_Int_XV;
i2	:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

if	(v2 < MULTI_INT_1W_S_MAXINT_1)
and	(v2 >= -MULTI_INT_1W_S_MAXINT_1)
then
	begin
    i2:= v2;
	multiply_Multi_Int_XV(v1,i2,Result);
	end
else
	begin
    m2:= v2;
	multiply_Multi_Int_XV(v1,m2,Result)
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v2:MULTI_INT_2W_S; const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var
m2	:Multi_Int_XV;
i2	:MULTI_INT_1W_S;
begin
if	(Not v1.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

if	(v2 < MULTI_INT_1W_S_MAXINT_1)
and	(v2 >= -MULTI_INT_1W_S_MAXINT_1)
then
	begin
    i2:= v2;
	multiply_Multi_Int_XV(v1,i2,Result);
	end
else
	begin
    m2:= v2;
	multiply_Multi_Int_XV(v1,m2,Result)
	end;

if (Result.Overflow_flag = TRUE) then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		Raise EIntOverflow.create('Overflow');
	end;

end;


(******************************************)
class operator Multi_Int_XV.*(const v1,v2:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var	  R:Multi_Int_XV;
begin
if	(Not v1.Defined_flag)
or	(Not v2.Defined_flag)
then
	begin
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

multiply_Multi_Int_XV(v1,v2,R);

if Multi_Int_ERROR then exit;

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

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
	Result.Defined_flag:= FALSE;
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
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
					Raise EIntOverflow.create('Overflow');
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
				Raise EIntOverflow.create('Overflow');
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
			Raise EIntOverflow.create('Overflow');
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
label	AGAIN,FINISH;

var
dividor,
quotient,
dividend,
next_dividend,
temp_dividend
			:Multi_Int_XV;

dividend_i,
dividend_i_1,
quotient_i,
dividor_i,
div_size,
rem_size,
dividor_i_1,
dividor_non_zero_pos,
shiftup_bits_dividor,
i
				:MULTI_INT_2W_S;

adjacent_word_dividend,
adjacent_word_division,
word_division,
word_dividend,
word_carry,
adjacent_word_carry
				:MULTI_INT_2W_U;

finished		:boolean;

	procedure Reset_XV_Size(var v1:Multi_Int_XV ;const S:MULTI_INT_2W_U);
	begin
	setlength(v1.M_Value, S);
	v1.M_Value_Size:= S;
	end;

(****)
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
		goto FINISH;
	    end;

	dividor_non_zero_pos:= 0;
    i:= (P_dividor.M_Value_Size - 1);
	while	(i >= 0) do
		begin
		if	(dividor_non_zero_pos = 0) then
			if	(P_dividor.M_Value[i] <> 0) then
				begin
				dividor_non_zero_pos:= i;
				break;
				end;
		Dec(i);
		end;

	Multi_Int_Reset_XV_Size(P_quotient, P_dividend.M_Value_Size);
	Multi_Int_Reset_XV_Size(P_remainder, P_dividend.M_Value_Size);

	if Multi_Int_ERROR then
		begin
		P_quotient.Defined_flag:= FALSE;
		P_quotient.Overflow_flag:= TRUE;
		P_remainder.Defined_flag:= FALSE;
		P_remainder.Overflow_flag:= TRUE;
		exit;
		end;

	div_size:= (P_dividend.M_Value_Size + 1);

	dividor:= P_dividor;
    dividend:= P_dividend;
	Zero_Multi_Int_XV_M_Value(quotient);
	Zero_Multi_Int_XV_M_Value(next_dividend);
	Zero_Multi_Int_XV_M_Value(temp_dividend);

	INTERNAL_Reset_XV_Size(dividor, div_size);
	INTERNAL_Reset_XV_Size(dividend, div_size);
	INTERNAL_Reset_XV_Size(quotient, div_size);
	INTERNAL_Reset_XV_Size(next_dividend, div_size);
	INTERNAL_Reset_XV_Size(temp_dividend, div_size);

	if Multi_Int_ERROR then
		begin
		P_quotient.Defined_flag:= FALSE;
		P_quotient.Overflow_flag:= TRUE;
		P_remainder.Defined_flag:= FALSE;
		P_remainder.Overflow_flag:= TRUE;
		exit;
		end;

	dividor.Negative_flag:= FALSE;
	dividend.Negative_flag:= FALSE;

	// essential short-cut for single word dividor
	// NB this is not just for speed, the later code
	// will break if this case is not processed in advance

	if	(dividor_non_zero_pos = 0) then
		begin
		word_carry:= 0;
		i:= (dividor.M_Value_Size - 1);
		while (i >= 0) do
			begin
			quotient.M_Value[i]:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) div MULTI_INT_2W_U(dividor.M_Value[0]));
			word_carry:= (((word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + MULTI_INT_2W_U(dividend.M_Value[i])) - (MULTI_INT_2W_U(quotient.M_Value[i]) * MULTI_INT_2W_U(dividor.M_Value[0])));
			Dec(i);
			end;
		P_quotient:= quotient;
		P_remainder.M_Value[0]:= word_carry;

		Multi_Int_Reset_XV_Size(P_quotient, P_dividend.M_Value_Size);
		Multi_Int_Reset_XV_Size(P_remainder, P_dividend.M_Value_Size);

		if Multi_Int_ERROR then
			begin
			P_quotient.Defined_flag:= FALSE;
			P_quotient.Overflow_flag:= TRUE;
			P_remainder.Defined_flag:= FALSE;
			P_remainder.Overflow_flag:= TRUE;
			exit;
			end;
		goto FINISH;
		end;

	shiftup_bits_dividor:= nlz_bits(dividor.M_Value[dividor_non_zero_pos]);
	if	(shiftup_bits_dividor > 0) then
		begin
		ShiftUp_NBits_Multi_Int_XV(dividend, shiftup_bits_dividor);
		ShiftUp_NBits_Multi_Int_XV(dividor, shiftup_bits_dividor);
		end;

	adjacent_word_carry:= 0;
	word_carry:= 0;
	dividor_i:= dividor_non_zero_pos;
	dividor_i_1:= (dividor_i - 1);
	dividend_i:= (dividend.M_Value_Size - 1);
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
        adjacent_word_carry:= (word_dividend mod dividor.M_Value[dividor_i]);

		if	(word_division > 0) then
			begin
			dividend_i_1:= (dividend_i - 1);
			if	(dividend_i_1 >= 0) then
				begin
				AGAIN:
				adjacent_word_dividend:= ((adjacent_word_carry * MULTI_INT_2W_U(MULTI_INT_1W_U_MAXINT_1)) + dividend.M_Value[dividend_i_1]);
                adjacent_word_division:= (dividor.M_Value[dividor_i_1] * word_division);
				if	(adjacent_word_division > adjacent_word_dividend)
				or	(word_division >= MULTI_INT_1W_U_MAXINT_1)
				then
					begin
					Dec(word_division);
					adjacent_word_carry:= adjacent_word_carry + dividor.M_Value[dividor_i];
					if (adjacent_word_carry < MULTI_INT_1W_U_MAXINT_1) then
						goto AGAIN;
					end;
				end;

			// quotient:= 0;
			Zero_Multi_Int_XV_M_Value(quotient);

			quotient.M_Value[quotient_i]:= word_division;

            multiply_Multi_Int_XV(dividor, quotient, temp_dividend);
			subtract_Multi_Int_XV(dividend,temp_dividend,next_dividend);
			if Multi_Int_ERROR then
				begin
				P_quotient.Defined_flag:= FALSE;
				P_quotient.Overflow_flag:= TRUE;
				P_remainder.Defined_flag:= FALSE;
				P_remainder.Overflow_flag:= TRUE;
				exit;
				end;

			if (next_dividend.Negative) then
				begin
				Dec(word_division);
				quotient.M_Value[quotient_i]:= word_division;

	            multiply_Multi_Int_XV(dividor, quotient, temp_dividend);
				subtract_Multi_Int_XV(dividend,temp_dividend,next_dividend);

				if Multi_Int_ERROR then
					begin
					P_quotient.Defined_flag:= FALSE;
					P_quotient.Overflow_flag:= TRUE;
					P_remainder.Defined_flag:= FALSE;
					P_remainder.Overflow_flag:= TRUE;
					exit;
					end;
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

	if	(P_remainder.M_Value_Size < dividend.M_Value_Size) then
		begin
		rem_size:= P_remainder.M_Value_Size;
		P_remainder:= dividend;
        Multi_Int_Reset_XV_Size(quotient, rem_size);
		if Multi_Int_ERROR then
			begin
			P_quotient.Defined_flag:= FALSE;
			P_quotient.Overflow_flag:= TRUE;
			P_remainder.Defined_flag:= FALSE;
			P_remainder.Overflow_flag:= TRUE;
			exit;
			end;
		end
	else
		P_remainder:= dividend;

FINISH:
	if	(P_dividend.Negative_flag = TRUE) and (P_remainder > 0)
	then
		P_remainder.Negative_flag:= TRUE;

	if	(P_dividend.Negative_flag <> P_dividor.Negative_flag)
	and	(P_quotient > 0)
	then
		P_quotient.Negative_flag:= TRUE;

	end;

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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
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
	Result.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Uninitialised variable');
		end;
	exit;
	end;
if	(v1.Overflow_flag or v2.Overflow_flag)
then
	begin
	Result.Overflow_flag:=TRUE;
	Result.Defined_flag:=TRUE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;
end;


(***********v2************)
procedure SqRoot(const v1:Multi_Int_XV; out VR,VREM:Multi_Int_XV);
var
D,D2		:MULTI_INT_2W_S;
HS,LS		:ansistring;
H,L,
C,CC,LPC,
Q,R,T		:Multi_Int_XV;
finished	:boolean;

begin
if	(Not v1.Defined_flag)
then
	begin
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
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
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow');
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
		Raise EIntOverflow.create('Overflow');
		end;
	exit;
	end;

VR.Defined_flag:= FALSE;
VREM.Defined_flag:= FALSE;

if	(v1 >= 100) then
	begin
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

	T:= (H-L);
	ShiftDown_MultiBits_Multi_Int_XV(T, 1);
	C:= (L+T);
	end
else
	begin
	C:= (v1 div 2);
	if	(C = 0) then C:= 1;
	end;

finished:= FALSE;
LPC:= v1;
repeat
	begin
	// CC:= ((C + (v1 div C)) div 2);
    intdivide_taylor_warruth_XV(v1,C,Q,R);
	if (Multi_Int_ERROR) then
		begin
		exit;
		end;
	CC:= (C+Q);
    ShiftDown_MultiBits_Multi_Int_XV(CC, 1);
	if	(ABS(C-CC) < 2) then
		begin
		if	(CC < LPC) then
			LPC:= CC
		else if (CC >= LPC) then
			finished:= TRUE
		end;
	C:= CC;
	end
until finished;

VREM:= (v1 - (LPC * LPC));
VR:= LPC;
VR.Negative_flag:= Multi_UBool_FALSE;
VREM.Negative_flag:= Multi_UBool_FALSE;

end;


(*************************)
procedure SqRoot(const v1:Multi_Int_XV; out VR:Multi_Int_XV);	{$ifdef inline_functions_level_1} inline; {$endif}
var	VREM:Multi_Int_XV;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
end;


(*************************)
function SqRoot(const v1:Multi_Int_XV):Multi_Int_XV;	{$ifdef inline_functions_level_1} inline; {$endif}
var	VR,VREM:Multi_Int_XV;
begin
VREM:= 0;
sqroot(v1,VR,VREM);
Result:= VR;
end;


{
******************************************
Multi_Int_Initialisation
******************************************
}

procedure Multi_Int_Initialisation(const P_Multi_XV_size:MULTI_INT_2W_U = 16);
var	i:MULTI_INT_2W_S;

begin

if Multi_Int_Initialisation_done then
	begin
	Multi_Int_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Multi_Int_Initialisation already called');
		end;
	exit;
	end
else
	begin
	Multi_Int_Initialisation_done:= TRUE;

	if (P_Multi_XV_size < Multi_XV_min_size) then
		begin
		Multi_Int_ERROR:= TRUE;
		Raise EInterror.create('Multi_XV_size must be >= minimum size');
		exit;
		end;
	Multi_XV_limit:= P_Multi_XV_size;
	Multi_XV_min_size:= 2;

	XV_Last_Divisor:= 0;
	XV_Last_Dividend:= 0;
	XV_Last_Quotient:= 0;
	XV_Last_Remainder:= 0;

	Multi_Int_XV_MAXINT:= 0;
	Multi_Int_Reset_XV_Size(Multi_Int_XV_MAXINT, Multi_XV_limit);
	i:=0;
	while (i < Multi_Int_XV_MAXINT.M_Value_Size ) do
		begin
		Multi_Int_XV_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
		Inc(i);
		end;
	end;
	Multi_Int_XV_MAXINT.Defined_flag:= TRUE;
	Multi_Int_XV_MAXINT.Negative_flag:= FALSE;
	Multi_Int_XV_MAXINT.Overflow_flag:= FALSE;

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

X2_Last_Divisor:= 0;
X2_Last_Dividend:= 0;
X2_Last_Quotient:= 0;
X2_Last_Remainder:= 0;

X3_Last_Divisor:= 0;
X3_Last_Dividend:= 0;
X3_Last_Quotient:= 0;
X3_Last_Remainder:= 0;

X4_Last_Divisor:= 0;
X4_Last_Dividend:= 0;
X4_Last_Quotient:= 0;
X4_Last_Remainder:= 0;

Multi_Int_X2_MAXINT:= 0;
i:=0;
while (i <= Multi_X2_maxi) do
	begin
	Multi_Int_X2_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;
Multi_Int_X2_MAXINT.Defined_flag:= TRUE;
Multi_Int_X2_MAXINT.Negative_flag:= FALSE;
Multi_Int_X2_MAXINT.Overflow_flag:= FALSE;

Multi_Int_X3_MAXINT:= 0;
i:=0;
while (i <= Multi_X3_maxi) do
	begin
	Multi_Int_X3_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;
Multi_Int_X3_MAXINT.Defined_flag:= TRUE;
Multi_Int_X3_MAXINT.Negative_flag:= FALSE;
Multi_Int_X3_MAXINT.Overflow_flag:= FALSE;

Multi_Int_X4_MAXINT:= 0;
i:=0;
while (i <= Multi_X4_maxi) do
	begin
	Multi_Int_X4_MAXINT.M_Value[i]:= MULTI_INT_1W_U_MAXINT;
	Inc(i);
	end;
Multi_Int_X4_MAXINT.Defined_flag:= TRUE;
Multi_Int_X4_MAXINT.Negative_flag:= FALSE;
Multi_Int_X4_MAXINT.Overflow_flag:= FALSE;

{
What is the point of Force_recompile ?
I have been getting problems where disabling/enabling the
{$define inline_functions_level_1} has not been picked-up
by the compiler. So whenever I change the define, I also
change the value assigned to T, which forces a re-compile.
}

Force_recompile:= 1;
end.

