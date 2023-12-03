UNIT Multi_Int;

{$MODE DELPHI}

{$MODESWITCH NESTEDCOMMENTS+}

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

v4.27C
-	bug fixes in Multi_Int_X2_to_Multi_Int_X48,
	Multi_Int_X3_to_Multi_Int_X48 & Multi_Int_X4_to_Multi_Int_X48
*)

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

(* END OF USER OPTIONAL DEFINES *)
	
INTERFACE

uses	sysutils
,		strutils
,		strings
,		math
,		UBool
;

const

(*
Notes about Multi_X48_max
Multi_X48_max is the number of half-words (minus 1) in the Multi-word integer type named Multi_Int_X48,
using zero-base, therefore 1 means 2.
The value must be 1 or greater (i.e. 2 half-words minimum), but
there is no point in having less than 7, because the type named Multi_Int_X4 uses 8 (7).
The number is half-words, so if you specify 127 that is 128 half-words, which equals
64 words, which equals 512 bits (in 64bit environment).
*)
	Multi_X48_max		= 5;

(*
Multi_X48_max is the only thing you should change in here.
Do not change anything below.
*)

	Multi_X48_max_x2	= (((Multi_X48_max+1)*2)-1);
	Multi_X48_size		= Multi_X48_max + 1;

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

type
	Multi_int8u = byte;
	Multi_int8 = shortint;
	Multi_int16 = smallint;
	Multi_int16u = word;
	Multi_int32 = longint;
	Multi_int32u = longword;
	Multi_int64u = QWord;
	Multi_int64 = int64;

const

(* Do not change these values *)

	Multi_X2_size = 4;
	Multi_X2_max = Multi_X2_size - 1;
	Multi_X2_max_x2 = ((Multi_X2_size * 2) - 1);

	Multi_X3_size = 6;
	Multi_X3_max = (Multi_X3_size - 1);
	Multi_X3_max_x2 = ((Multi_X3_size * 2) - 1);

	Multi_X4_size = 8;
	Multi_X4_max = (Multi_X4_size - 1);
	Multi_X4_max_x2 = ((Multi_X4_size * 2) - 1);

{$ifdef 32bit}
const
	INT_1W_SIZE		= 16;
	INT_2W_SIZE		= 32;

	INT_1W_S_MAXINT		= Multi_INT16_MAXINT;
	INT_1W_S_MAXINT_1	= Multi_INT16_MAXINT_1;
	INT_1W_U_MAXINT		= Multi_INT16U_MAXINT;
	INT_1W_U_MAXINT_1	= Multi_INT16U_MAXINT_1;

	INT_2W_S_MAXINT		= Multi_INT32_MAXINT;
	INT_2W_S_MAXINT_1	= Multi_INT32_MAXINT_1;
	INT_2W_U_MAXINT		= Multi_INT32U_MAXINT;
	INT_2W_U_MAXINT_1	= Multi_INT32U_MAXINT_1;

type

	INT_1W_S		= Multi_int16;
	INT_1W_U		= Multi_int16u;
	INT_2W_S		= Multi_int32;
	INT_2W_U		= Multi_int32u;

{$endif} // 32-bit

{$ifdef 64bit}
const
	INT_1W_SIZE		= 32;
	INT_2W_SIZE		= 64;

	INT_1W_S_MAXINT		= Multi_INT32_MAXINT;
	INT_1W_S_MAXINT_1	= Multi_INT32_MAXINT_1;
	INT_1W_U_MAXINT		= Multi_INT32U_MAXINT;
	INT_1W_U_MAXINT_1	= Multi_INT32U_MAXINT_1;

	INT_2W_S_MAXINT		= Multi_INT64_MAXINT;
	INT_2W_S_MAXINT_1	= Multi_INT64_MAXINT_1;
	INT_2W_U_MAXINT		= Multi_INT64U_MAXINT;
	INT_2W_U_MAXINT_1	= Multi_INT64U_MAXINT_1;

type

	INT_1W_S		= Multi_int32;
	INT_1W_U		= Multi_int32u;
	INT_2W_S		= Multi_int64;
	INT_2W_U		= Multi_int64u;

{$endif} // 64-bit

type

T_Multi_Leading_Zeros	=	(Multi_Keep_Leading_Zeros, Multi_Trim_Leading_Zeros);

T_Multi_32bit_or_64bit	=	(Multi_undef, Multi_32bit, Multi_64bit);

Multi_Int_X2	=	record
					private
						M_Value			:array[0..Multi_X2_max] of INT_1W_U;
						Negative_flag	:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						// procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X2; inline;
						function Overflow:boolean; inline;
						function Negative:boolean; inline;
						function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X2):Multi_int8u; inline;
						class operator implicit(const v1:Multi_Int_X2):Multi_int8; inline;
						class operator implicit(const v1:Multi_Int_X2):INT_1W_U; inline;
						class operator implicit(const v1:Multi_Int_X2):INT_1W_S; inline;
						class operator implicit(const v1:Multi_Int_X2):INT_2W_U; inline;
						class operator implicit(const v1:Multi_Int_X2):INT_2W_S; inline;
						class operator implicit(const v1:INT_2W_S):Multi_Int_X2; inline;
						class operator implicit(const v1:INT_2W_U):Multi_Int_X2; inline;
						class operator implicit(const v1:string):Multi_Int_X2; inline;
						class operator implicit(const v1:Multi_Int_X2):string; inline;
						class operator implicit(const v1:Multi_Int_X2):Real; inline;
						class operator implicit(const v1:Real):Multi_Int_X2; inline;
						class operator implicit(const v1:Double):Multi_Int_X2; inline;
						class operator implicit(const v1:Multi_Int_X2):Double; inline;
						class operator add(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator subtract(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator inc(const v1:Multi_Int_X2):Multi_Int_X2; inline;
						class operator dec(const v1:Multi_Int_X2):Multi_Int_X2; inline;
						class operator inc(const v1:Multi_Int_X2; const v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator dec(const v1:Multi_Int_X2; const v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator greaterthan(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator lessthan(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator equal(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator notequal(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator multiply(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator intdivide(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator modulus(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator xor(const v1,v2:Multi_Int_X2):Multi_Int_X2; inline;
						class operator -(const v1:Multi_Int_X2):Multi_Int_X2; inline;
						class operator >=(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator <=(const v1,v2:Multi_Int_X2):Boolean; inline;
						class operator **(const v1:Multi_Int_X2; const P:INT_2W_S):Multi_Int_X2; inline;
					end;


Multi_Int_X3	=	record
					private
						M_Value			:array[0..Multi_X3_max] of INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						// procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X3; inline;
						function Overflow:boolean; inline;
						function Negative:boolean; inline;
						function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X3):Multi_int8u; inline;
						class operator implicit(const v1:Multi_Int_X3):Multi_int8; inline;
						class operator implicit(const v1:Multi_Int_X3):INT_1W_U; inline;
						class operator implicit(const v1:Multi_Int_X3):INT_1W_S; inline;
						class operator implicit(const v1:Multi_Int_X3):INT_2W_U; inline;
						class operator implicit(const v1:Multi_Int_X3):INT_2W_S; inline;
						class operator implicit(const v1:INT_2W_S):Multi_Int_X3; inline;
						class operator implicit(const v1:INT_2W_U):Multi_Int_X3; inline;
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_X3; inline;
						class operator implicit(const v1:string):Multi_Int_X3; inline;
						class operator implicit(const v1:Multi_Int_X3):string; inline;
						class operator implicit(const v1:Multi_Int_X3):Real; inline;
						class operator implicit(const v1:Real):Multi_Int_X3; inline;
						class operator implicit(const v1:Double):Multi_Int_X3; inline;
						class operator implicit(const v1:Multi_Int_X3):Double; inline;
						class operator add(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator subtract(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator inc(const v1:Multi_Int_X3):Multi_Int_X3; inline;
						class operator dec(const v1:Multi_Int_X3):Multi_Int_X3; inline;
						class operator inc(const v1:Multi_Int_X3; const v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator dec(const v1:Multi_Int_X3; const v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator greaterthan(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator lessthan(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator equal(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator notequal(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator multiply(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator intdivide(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator modulus(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator xor(const v1,v2:Multi_Int_X3):Multi_Int_X3; inline;
						class operator -(const v1:Multi_Int_X3):Multi_Int_X3; inline;
						class operator >=(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator <=(const v1,v2:Multi_Int_X3):Boolean; inline;
						class operator **(const v1:Multi_Int_X3; const P:INT_2W_S):Multi_Int_X3; inline;
					end;


Multi_Int_X4	=	record
					private
						M_Value			:array[0..Multi_X4_max] of INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						// procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X4; inline;
						function Overflow:boolean; inline;
						function Negative:boolean; inline;
						function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X4):Multi_int8u; inline;
						class operator implicit(const v1:Multi_Int_X4):Multi_int8; inline;
						class operator implicit(const v1:Multi_Int_X4):INT_1W_U; inline;
						class operator implicit(const v1:Multi_Int_X4):INT_1W_S; inline;
						class operator implicit(const v1:Multi_Int_X4):INT_2W_U; inline;
						class operator implicit(const v1:Multi_Int_X4):INT_2W_S; inline;
						class operator implicit(const v1:INT_2W_S):Multi_Int_X4; inline;
						class operator implicit(const v1:INT_2W_U):Multi_Int_X4; inline;
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_X4; inline;
						class operator implicit(const v1:Multi_Int_X3):Multi_Int_X4; inline;
						class operator implicit(const v1:string):Multi_Int_X4; inline;
						class operator implicit(const v1:Multi_Int_X4):string; inline;
						class operator implicit(const v1:Multi_Int_X4):Real; inline;
						class operator implicit(const v1:Real):Multi_Int_X4; inline;
						class operator implicit(const v1:Double):Multi_Int_X4; inline;
						class operator implicit(const v1:Multi_Int_X4):Double; inline;
						class operator add(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator subtract(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator inc(const v1:Multi_Int_X4):Multi_Int_X4; inline;
						class operator dec(const v1:Multi_Int_X4):Multi_Int_X4; inline;
						class operator inc(const v1:Multi_Int_X4; const v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator dec(const v1:Multi_Int_X4; const v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator greaterthan(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator lessthan(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator equal(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator notequal(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator multiply(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator intdivide(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator modulus(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator xor(const v1,v2:Multi_Int_X4):Multi_Int_X4; inline;
						class operator -(const v1:Multi_Int_X4):Multi_Int_X4; inline;
						class operator >=(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator <=(const v1,v2:Multi_Int_X4):Boolean; inline;
						class operator **(const v1:Multi_Int_X4; const P:INT_2W_S):Multi_Int_X4; inline;
					end;


Multi_Int_X48	=	record
					private
						M_Value			:array[0..Multi_X48_max] of INT_1W_U;
						Negative_flag		:T_Multi_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						// procedure Init(const v1:string); overload;
						// procedure Init(const v1:INT_2W_S); overload;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Multi_Leading_Zeros=Multi_Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X48; inline;
						function Overflow:boolean; inline;
						function Negative:boolean; inline;
						function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X48):Multi_int8u; inline;
						class operator implicit(const v1:Multi_Int_X48):Multi_int8; inline;
						class operator implicit(const v1:Multi_Int_X48):INT_1W_U; inline;
						class operator implicit(const v1:Multi_Int_X48):INT_1W_S; inline;
						class operator implicit(const v1:Multi_Int_X48):INT_2W_U; inline;
						class operator implicit(const v1:Multi_Int_X48):INT_2W_S; inline;
						class operator implicit(const v1:Multi_Int_X2):Multi_Int_X48; inline;
						class operator implicit(const v1:Multi_Int_X3):Multi_Int_X48; inline;
						class operator implicit(const v1:Multi_Int_X4):Multi_Int_X48; inline;
						class operator implicit(const v1:INT_2W_S):Multi_Int_X48; inline;
						class operator implicit(const v1:INT_2W_U):Multi_Int_X48; inline;
						class operator implicit(const v1:string):Multi_Int_X48; inline;
						class operator implicit(const v1:Multi_Int_X48):string; inline;
						class operator implicit(const v1:Real):Multi_Int_X48; inline;
						class operator implicit(const v1:Double):Multi_Int_X48; inline;
						class operator add(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator greaterthan(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator lessthan(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator equal(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator notequal(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator subtract(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator inc(const v1:Multi_Int_X48):Multi_Int_X48; inline;
						class operator dec(const v1:Multi_Int_X48):Multi_Int_X48; inline;
						class operator inc(const v1:Multi_Int_X48; const v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator dec(const v1:Multi_Int_X48; const v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator xor(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator multiply(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator intdivide(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator modulus(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator -(const v1:Multi_Int_X48):Multi_Int_X48;
						class operator >=(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator <=(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator **(const v1:Multi_Int_X48; const P:INT_2W_S):Multi_Int_X48; inline;
					end;

var
Multi_Int_RAISE_EXCEPTIONS_ENABLED,
Multi_Int_OVERFLOW_ERROR		:boolean;
Multi_Int_X2_MAXINT			:Multi_Int_X2;
Multi_Int_X3_MAXINT			:Multi_Int_X3;
Multi_Int_X4_MAXINT			:Multi_Int_X4;
Multi_Int_X48_MAXINT		:Multi_Int_X48;
Multi_32bit_or_64bit		:T_Multi_32bit_or_64bit;


function Odd(const v1:Multi_Int_X48):boolean; overload;
function Odd(const v1:Multi_Int_X4):boolean; overload;
function Odd(const v1:Multi_Int_X3):boolean; overload;
function Odd(const v1:Multi_Int_X2):boolean; overload;

function Even(const v1:Multi_Int_X48):boolean; overload;
function Even(const v1:Multi_Int_X4):boolean; overload;
function Even(const v1:Multi_Int_X3):boolean; overload;
function Even(const v1:Multi_Int_X2):boolean; overload;

function Abs(const v1:Multi_Int_X2):Multi_Int_X2; overload;
function Abs(const v1:Multi_Int_X3):Multi_Int_X3; overload;
function Abs(const v1:Multi_Int_X4):Multi_Int_X4; overload;
function Abs(const v1:Multi_Int_X48):Multi_Int_X48; overload;

procedure SqRoot(const v1:Multi_Int_X48;var VR,VREM:Multi_Int_X48); overload;
procedure SqRoot(const v1:Multi_Int_X4;var VR,VREM:Multi_Int_X4); overload;
procedure SqRoot(const v1:Multi_Int_X3;var VR,VREM:Multi_Int_X3); overload;
procedure SqRoot(const v1:Multi_Int_X2;var VR,VREM:Multi_Int_X2); overload;

procedure ShiftUp(var v1:Multi_Int_X2; NBits:INT_1W_U); overload; inline;
procedure ShiftDown(var v1:Multi_Int_X2; NBits:INT_1W_U); overload; inline;
procedure ShiftUp(var v1:Multi_Int_X3; NBits:INT_1W_U); overload; inline;
procedure ShiftDown(var v1:Multi_Int_X3; NBits:INT_1W_U); overload; inline;
procedure ShiftUp(var v1:Multi_Int_X4; NBits:INT_1W_U); overload; inline;
procedure ShiftDown(var v1:Multi_Int_X4; NBits:INT_1W_U); overload; inline;
procedure ShiftUp(var v1:Multi_Int_X48; NBits:INT_1W_U); overload; inline;
procedure ShiftDown(var v1:Multi_Int_X48; NBits:INT_1W_U); overload; inline;

procedure RotateUp(Var v1:Multi_Int_X2; NBits:INT_1W_U); overload; inline;
procedure RotateDown(Var v1:Multi_Int_X2; NBits:INT_1W_U); overload; inline;
procedure RotateUp(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload; inline;
procedure RotateDown(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload; inline;
procedure RotateUp(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload; inline;
procedure RotateDown(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload; inline;
procedure RotateUp(Var v1:Multi_Int_X48; NBits:INT_1W_U); overload; inline;
procedure RotateDown(Var v1:Multi_Int_X48; NBits:INT_1W_U); overload; inline;

function To_Multi_Int_X48(const v1:Multi_Int_X4):Multi_Int_X48; overload;
function To_Multi_Int_X48(const v1:Multi_Int_X3):Multi_Int_X48; overload;
function To_Multi_Int_X48(const v1:Multi_Int_X2):Multi_Int_X48; overload;

function To_Multi_Int_X4(const v1:Multi_Int_X48):Multi_Int_X4; overload;
function To_Multi_Int_X4(const v1:Multi_Int_X3):Multi_Int_X4; overload;
function To_Multi_Int_X4(const v1:Multi_Int_X2):Multi_Int_X4; overload;

function To_Multi_Int_X3(const v1:Multi_Int_X48):Multi_Int_X3; overload;
function To_Multi_Int_X3(const v1:Multi_Int_X4):Multi_Int_X3; overload;
function To_Multi_Int_X3(const v1:Multi_Int_X2):Multi_Int_X3; overload;

function To_Multi_Int_X2(const v1:Multi_Int_X48):Multi_Int_X2; overload;
function To_Multi_Int_X2(const v1:Multi_Int_X4):Multi_Int_X2; overload;
function To_Multi_Int_X2(const v1:Multi_Int_X3):Multi_Int_X2; overload;


IMPLEMENTATION


// {$define Overflow_Checks}

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

X48_Last_Divisor,
X48_Last_Dividend,
X48_Last_Quotient,
X48_Last_Remainder	:Multi_Int_X48;

{$ifdef 32bit}
(******************************************)
function nlz_bits(P_x:INT_1W_U):INT_1W_U;
var
n		:Multi_int32;
x,t		:INT_1W_U;
begin
if (P_x = 0) then Result:= 16
else
	begin
	x:= P_x;
	n:= 0;
	t:=(x and INT_1W_U(65280));
	if	(t = 0) then begin n:=(n + 8); x:=(x << 8); end;

	t:=(x and INT_1W_U(61440));
	if	(t = 0) then begin n:=(n + 4); x:=(x << 4); end;

	t:=(x and INT_1W_U(49152));
	if	(t = 0) then begin n:=(n + 2); x:=(x << 2); end;

	t:=(x and INT_1W_U(32768));
	if	(t = 0) then begin n:=(n + 1); end;
	Result:= n;
	end;
end;

{$endif}


{$ifdef 64bit}
(******************************************)
function nlz_bits(x:INT_1W_U):INT_1W_U;
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
function nlz_words_X2(m:Multi_Int_X2):INT_1W_U;
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
function nlz_MultiBits_X2(m:Multi_Int_X2):INT_1W_U;
var	w	:INT_1W_U;
begin
w:= nlz_words_X2(m);
if (w <= Multi_X2_max)
then Result:= nlz_bits(m.M_Value[Multi_X2_max-w]) + (w * INT_1W_SIZE)
else Result:= (w * INT_1W_SIZE);
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
var	bit1_mask	:INT_1W_U;
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
var	bit1_mask	:INT_1W_U;
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
procedure RotateUp_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure RotateUp_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateUp_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X2(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X2(v1, NBits_count);
	end;
end;


(******************************************)
procedure Multi_Int_X2.RotateUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure RotateUp(Var v1:Multi_Int_X2; NBits:INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure RotateDown_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateDown_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X2(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X2(v1, NBits_count);
end;


(******************************************)
procedure Multi_Int_X2.RotateDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X2; NBits:INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure ShiftUp_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftUp_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X2(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X2(v1, NBits_count);
	end;
end;


{******************************************}
procedure Multi_Int_X2.ShiftUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


{******************************************}
procedure ShiftUp(var v1:Multi_Int_X2; NBits:INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X2(v1, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure ShiftDown_NWords_Multi_Int_X2(Var v1:Multi_Int_X2; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftDown_MultiBits_Multi_Int_X2(Var v1:Multi_Int_X2; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X2(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X2(v1, NBits_count);
end;


{******************************************}
procedure Multi_Int_X2.ShiftDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X2(v1, NBits);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X2; NBits:INT_1W_U); overload;
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
procedure string_to_Multi_Int_X2(const v1:string; var mi:Multi_Int_X2);
label 999;
var
	i,b,c,e		:INT_2W_U;
	M_Val		:array[0..Multi_X2_max] of INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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

		if	M_Val[0] > INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > INT_1W_U_MAXINT then
			begin
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
var n :INT_1W_U;
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
or	(v1 > Multi_Int_X2_MAXINT)
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
end;


(******************************************)
function To_Multi_Int_X2(const v1:Multi_Int_X4):Multi_Int_X2;
var n :INT_1W_U;
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
or	(v1 > Multi_Int_X2_MAXINT)
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
end;


(******************************************)
function To_Multi_Int_X2(const v1:Multi_Int_X48):Multi_Int_X2;
var n :INT_1W_U;
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
or	(v1 > Multi_Int_X2_MAXINT)
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
end;


(******************************************)
{
procedure Multi_Int_X2.Init(const v1:string);
begin
string_to_Multi_Int_X2(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X2.implicit(const v1:string):Multi_Int_X2;
begin
string_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure INT_2W_S_to_Multi_Int_X2(const v1:INT_2W_S; var mi:Multi_Int_X2);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
	end;

end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:INT_2W_S):Multi_Int_X2;
begin
INT_2W_S_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure INT_2W_U_to_Multi_Int_X2(const v1:INT_2W_U; var mi:Multi_Int_X2);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:INT_2W_U):Multi_Int_X2;
begin
INT_2W_U_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Real):Multi_Int_X2;
var
R,RM,RT,RMAX	:Real;
M				:Multi_Int_X2;
begin
R:= Trunc(ABS(v1));
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on real conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Real;
var R,V,M:Real;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Double):Multi_Int_X2;
var
R,RM,RT,RMAX	:Double;
M				:Multi_Int_X2;
begin
R:= ABS(v1);
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Double;
var R,V,M:Double;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


{******************************************}
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):INT_2W_S;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_2W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_2W_S(-R)
else Result:= INT_2W_S(R);
end;


{******************************************}
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):INT_2W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[1]) << INT_1W_SIZE);
R:= (R OR INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;
Result:= R;
end;


{******************************************}
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):INT_1W_S;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_1W_S(-R)
else Result:= INT_1W_S(R);
end;


{******************************************}
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):INT_1W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (v1.M_Value[0] + (v1.M_Value[1] * INT_1W_U_MAXINT_1));
if	(R > INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Multi_int8u;
var	R	:Multi_int8u;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):Multi_int8;
var	R	:Multi_int8;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
procedure Multi_Int_X2_to_hex(const v1:Multi_Int_X2; var v2:string; LZ:T_Multi_Leading_Zeros);
var
	s		:string = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X4_max] of INT_2W_U;
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

n:= (INT_1W_SIZE div 4);
s:= '';

s:= s
	+   IntToHex(v1.M_Value[3],n)
	+   IntToHex(v1.M_Value[2],n)
	+   IntToHex(v1.M_Value[1],n)
	+   IntToHex(v1.M_Value[0],n)
	;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
v2:=s;
end;


(******************************************)
function Multi_Int_X2.ToHex(const LZ:T_Multi_Leading_Zeros):string;
begin
Multi_Int_X2_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X2(const v1:string; var mi:Multi_Int_X2);
label 999;
var
	n,i,b,c,e
				:INT_2W_U;
	M_Val		:array[0..Multi_X2_max] of INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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
		while (n <= Multi_X2_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X2_max) do
			begin
			if	M_Val[n] > INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > INT_1W_U_MAXINT then
			begin
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
function Multi_Int_X2.FromHex(const v1:string):Multi_Int_X2;
begin
hex_to_Multi_Int_X2(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_string(const v1:Multi_Int_X2; var v2:string);
var
	s		:string = '';
	M_Val	:array[0..Multi_X2_max] of INT_2W_U;
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

repeat

	M_Val[2]:= M_Val[2] + (INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
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
function Multi_Int_X2.ToStr:string;
begin
Multi_Int_X2_to_string(self, Result);
end;


(******************************************)
class operator Multi_Int_X2.implicit(const v1:Multi_Int_X2):string;
begin
Multi_Int_X2_to_string(v1, Result);
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
	tv2		:INT_2W_U;
	M_Val	:array[0..Multi_X2_max] of INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag.Init(Multi_UBool_UNDEF);

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[3] MOD INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
*)
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
	M_Val	:array[0..Multi_X2_max] of INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
*)
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Inc');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.inc(const v1:Multi_Int_X2; const v2:Multi_Int_X2):Multi_Int_X2;
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Add');
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Dec');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.dec(const v1:Multi_Int_X2; const v2:Multi_Int_X2):Multi_Int_X2;
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
	begin
	if (Result.Overflow_flag = TRUE) then
		Raise EIntOverflow.create('Overflow on Subtract');
	end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X2.-(const v1:Multi_Int_X2):Multi_Int_X2;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag) then
	Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
procedure multiply_Multi_Int_X2(const v1,v2:Multi_Int_X2;var Result:Multi_Int_X2);
var
	M_Val	:array[0..Multi_X2_max_x2] of INT_2W_U;
	tv1,tv2	:INT_2W_U;
	i,j,k	:INT_1W_U;
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
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X2_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD INT_1W_U_MAXINT_1);
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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X2;var VR,VREM:Multi_Int_X2);
var
D,D2		:INT_2W_S;
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
	VR:= 0;
	VR.Defined_flag:= FALSE;
	VREM:= 0;
	VREM.Defined_flag:= FALSE;
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
	L:= '1' + AddCharR('0','',D2-1);
	H:= '1' + AddCharR('0','',D2);
	end
else
	begin
	L:= '1' + AddCharR('0','',D2);
	H:= '1' + AddCharR('0','',D2+1);
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

class operator Multi_Int_X2.**(const v1:Multi_Int_X2; const P:INT_2W_S):Multi_Int_X2;
var
Y,TV,T,R	:Multi_Int_X2;
PT			:INT_2W_S;
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
prev_dividend,
ZERO				:Multi_Int_X2;
T					:INT_1W_U;
z,k					:INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:INT_2W_S;

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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
		if	(T <> 0) then Inc(z);
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
	if	(z = 1) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X4_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * INT_1W_U_MAXINT_1) + dividend.M_Value[i]) div divisor.M_Value[0]);
			k:= (((k * INT_1W_U_MAXINT_1) + dividend.M_Value[i]) - (P_quotient.M_Value[i] * divisor.M_Value[0]));
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
		prev_dividend:= dividend;
		dividend:= (dividend - divisor);
		if (dividend > ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			goto 1000;
			end;
		if (dividend = ZERO) then
			quotient:= (quotient + quotient_factor);
		if (dividend < ZERO) then
			dividend:= prev_dividend;

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
else
	begin
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

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
else
	begin
	intdivide_Shift_And_Sub_X2(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X2_Last_Divisor:= v2;
	X2_Last_Dividend:= v1;
	X2_Last_Quotient:= Quotient;
	X2_Last_Remainder:= Remainder;

	Result:= Remainder;
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
end;


(******************************************)
function Multi_Int_X3_Odd(const v1:Multi_Int_X3):boolean;
var	bit1_mask	:INT_1W_U;
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
var	bit1_mask	:INT_1W_U;
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
function nlz_words_X3(m:Multi_Int_X3):INT_1W_U;
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
function nlz_MultiBits_X3(m:Multi_Int_X3):INT_1W_U;
var	w,b	:INT_1W_U;
begin
w:= nlz_words_X3(m);
if (w <= Multi_X3_max)
then Result:= nlz_bits(m.M_Value[Multi_X3_max-w]) + (w * INT_1W_SIZE)
else Result:= (w * INT_1W_SIZE);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure RotateUp_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateUp_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X3(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X3(v1, NBits_count);
	end;
end;


(******************************************)
procedure Multi_Int_X3.RotateUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure RotateUp(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_3,
	carry_bits_4,
	carry_bits_5,
	carry_bits_6,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure RotateDown_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X3(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X3(v1, NBits_count);
end;


(******************************************)
procedure Multi_Int_X3.RotateDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure ShiftUp_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftDown_NWords_Multi_Int_X3(Var v1:Multi_Int_X3; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftUp_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X3(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X3(v1, NBits_count);
	end;
end;


{******************************************}
procedure Multi_Int_X3.ShiftUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


{******************************************}
procedure ShiftUp(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X3(v1, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;

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
procedure ShiftDown_MultiBits_Multi_Int_X3(Var v1:Multi_Int_X3; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X3(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X3(v1, NBits_count);
end;


{******************************************}
procedure Multi_Int_X3.ShiftDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X3(v1, NBits);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X3; NBits:INT_1W_U); overload;
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
procedure string_to_Multi_Int_X3(const v1:string; var mi:Multi_Int_X3);
label 999;
var
	i,b,c,e		:INT_2W_U;
	M_Val		:array[0..Multi_X3_max] of INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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

		if	M_Val[0] > INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > INT_1W_U_MAXINT then
			begin
			M_Val[4]:=M_Val[4] + (M_Val[3] DIV INT_1W_U_MAXINT_1);
			M_Val[3]:=(M_Val[3] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[4] > INT_1W_U_MAXINT then
			begin
			M_Val[5]:=M_Val[5] + (M_Val[4] DIV INT_1W_U_MAXINT_1);
			M_Val[4]:=(M_Val[4] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[5] > INT_1W_U_MAXINT then
			begin
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
procedure Multi_Int_X3.Init(const v1:string);
begin
string_to_Multi_Int_X3(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X3.implicit(const v1:string):Multi_Int_X3;
begin
string_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure INT_2W_S_to_Multi_Int_X3(const v1:INT_2W_S; var mi:Multi_Int_X3);
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
	mi.M_Value[0]:= (ABS(v1) MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:INT_2W_S):Multi_Int_X3;
begin
INT_2W_S_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure INT_2W_U_to_Multi_Int_X3(const v1:INT_2W_U; var mi:Multi_Int_X3);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:INT_2W_U):Multi_Int_X3;
begin
INT_2W_U_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_X48):Multi_Int_X3;
var n :INT_1W_U;
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
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_X4):Multi_Int_X3;
var n :INT_1W_U;
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
end;


(******************************************)
function To_Multi_Int_X3(const v1:Multi_Int_X2):Multi_Int_X3;
var n :INT_1W_U;
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

while (n <= Multi_X3_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X3(const v1:Multi_Int_X2; var MI:Multi_Int_X3);
var
	n				:INT_1W_U;
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
class operator Multi_Int_X3.implicit(const v1:Real):Multi_Int_X3;
var
R,RM,RT,RMAX	:Real;
M				:Multi_Int_X3;
begin
R:= Trunc(ABS(v1));
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[4]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[5]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on real conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Real;
var R,V,M:Real;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

V:= v1.M_Value[4];
V:= V * M * M * M * M;
R:= R + V;

V:= v1.M_Value[5];
V:= V * M * M * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Double):Multi_Int_X3;
var
R,RM,RT,RMAX	:Double;
M				:Multi_Int_X3;
begin
R:= ABS(v1);
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[4]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[5]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Double;
var R,V,M:Double;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

V:= v1.M_Value[4];
V:= V * M * M * M * M;
R:= R + V;

V:= v1.M_Value[5];
V:= V * M * M * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):INT_2W_S;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_2W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_2W_S(-R)
else Result:= INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):INT_2W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[1]) << INT_1W_SIZE);
R:= (R OR INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;
Result:= R;
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):INT_1W_S;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_1W_S(-R)
else Result:= INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):INT_1W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (v1.M_Value[0] + (v1.M_Value[1] * INT_1W_U_MAXINT_1));

if	(R > INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Multi_int8u;
(* var	R	:Multi_int8u; *)
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):Multi_int8;
(* var	R	:Multi_int8; *)
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
procedure Multi_Int_X3_to_hex(const v1:Multi_Int_X3; var v2:string; LZ:T_Multi_Leading_Zeros);
var
	s		:string = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X3_max] of INT_2W_U;
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

n:= (INT_1W_SIZE div 4);
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
v2:=s;
end;


(******************************************)
function Multi_Int_X3.ToHex(const LZ:T_Multi_Leading_Zeros):string;
begin
Multi_Int_X3_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X3(const v1:string; var mi:Multi_Int_X3);
label 999;
var
	n,i,b,c,e
				:INT_2W_U;
	M_Val		:array[0..Multi_X3_max] of INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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
		while (n <= Multi_X3_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X3_max) do
			begin
			if	M_Val[n] > INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > INT_1W_U_MAXINT then
			begin
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
function Multi_Int_X3.FromHex(const v1:string):Multi_Int_X3;
begin
hex_to_Multi_Int_X3(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_string(const v1:Multi_Int_X3; var v2:string);
var
	s		:string = '';
	M_Val	:array[0..Multi_X3_max] of INT_2W_U;
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

repeat

	M_Val[4]:= M_Val[4] + (INT_1W_U_MAXINT_1 * (M_Val[5] MOD 10));
	M_Val[5]:= (M_Val[5] DIV 10);

	M_Val[3]:= M_Val[3] + (INT_1W_U_MAXINT_1 * (M_Val[4] MOD 10));
	M_Val[4]:= (M_Val[4] DIV 10);

	M_Val[2]:= M_Val[2] + (INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
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
function Multi_Int_X3.ToStr:string;
begin
Multi_Int_X3_to_string(self, Result);
end;


(******************************************)
class operator Multi_Int_X3.implicit(const v1:Multi_Int_X3):string;
begin
Multi_Int_X3_to_string(v1, Result);
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
	tv2		:INT_2W_U;
	M_Val	:array[0..Multi_X3_max] of INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag.Init(Multi_UBool_UNDEF);

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > INT_1W_U_MAXINT then
	begin
	M_Val[4]:= (M_Val[3] DIV INT_1W_U_MAXINT_1);
	M_Val[3]:= (M_Val[3] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

tv1:= v1.M_Value[4];
tv2:= v2.M_Value[4];
M_Val[4]:=(M_Val[4] + tv1 + tv2);
if	M_Val[4] > INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[4] DIV INT_1W_U_MAXINT_1);
	M_Val[4]:= (M_Val[4] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

tv1:= v1.M_Value[5];
tv2:= v2.M_Value[5];
M_Val[5]:=(M_Val[5] + tv1 + tv2);
if	M_Val[5] > INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[5] MOD INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
*)
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
	M_Val	:array[0..Multi_X3_max] of INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	M_Val[4]:= -1;
	M_Val[3]:= (M_Val[3] + INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

M_Val[4]:=(v1.M_Value[4] - v2.M_Value[4] + M_Val[4]);
if	M_Val[4] < 0 then
	begin
	M_Val[5]:= -1;
	M_Val[4]:= (M_Val[4] + INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

M_Val[5]:=(v1.M_Value[5] - v2.M_Value[5] + M_Val[5]);
if	M_Val[5] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
*)
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Inc');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.inc(const v1:Multi_Int_X3; const v2:Multi_Int_X3):Multi_Int_X3;
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Add');
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.dec(const v1:Multi_Int_X3; const v2:Multi_Int_X3):Multi_Int_X3;
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Subtract');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X3.-(const v1:Multi_Int_X3):Multi_Int_X3;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag) then
	Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
procedure multiply_Multi_Int_X3(const v1,v2:Multi_Int_X3;var Result:Multi_Int_X3);
var
	M_Val	:array[0..Multi_X3_max_x2] of INT_2W_U;
	tv1,tv2	:INT_2W_U;
	i,j,k	:INT_1W_U;
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
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X3_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD INT_1W_U_MAXINT_1);
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

if	R.Overflow_flag then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X3;var VR,VREM:Multi_Int_X3);
var
D,D2		:INT_2W_S;
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
	L:= '1' + AddCharR('0','',D2-1);
	H:= '1' + AddCharR('0','',D2);
	end
else
	begin
	L:= '1' + AddCharR('0','',D2);
	H:= '1' + AddCharR('0','',D2+1);
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

class operator Multi_Int_X3.**(const v1:Multi_Int_X3; const P:INT_2W_S):Multi_Int_X3;
var
Y,TV,T,R	:Multi_Int_X3;
PT			:INT_2W_S;
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
prev_dividend,
ZERO				:Multi_Int_X3;
T					:INT_1W_U;
z,k					:INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:INT_2W_S;

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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
		if	(T <> 0) then Inc(z);
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
	if	(z = 1) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X4_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * INT_1W_U_MAXINT_1) + dividend.M_Value[i]) div divisor.M_Value[0]);
			k:= (((k * Multi_X4_max) + dividend.M_Value[i]) - (P_quotient.M_Value[i] * divisor.M_Value[0]));
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
		prev_dividend:= dividend;
		dividend:= (dividend - divisor);
		if (dividend > ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			goto 1000;
			end;
		if (dividend = ZERO) then
			quotient:= (quotient + quotient_factor);
		if (dividend < ZERO) then
			dividend:= prev_dividend;

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

9000:
	P_quotient:= quotient;
	P_remainder:= dividend;

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
else
	begin
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

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
else
	begin
	intdivide_Shift_And_Sub_X3(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X3_Last_Divisor:= v2;
	X3_Last_Dividend:= v1;
	X3_Last_Quotient:= Quotient;
	X3_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;

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
var	bit1_mask	:INT_1W_U;
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
var	bit1_mask	:INT_1W_U;
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
function nlz_words_X4(m:Multi_Int_X4):INT_1W_U; // v2
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
function nlz_MultiBits_X4(m:Multi_Int_X4):INT_1W_U;
var	w,b	:INT_1W_U;
begin
w:= nlz_words_X4(m);
if (w <= Multi_X4_max)
then Result:= nlz_bits(m.M_Value[Multi_X4_max-w]) + (w * INT_1W_SIZE)
else Result:= (w * INT_1W_SIZE);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
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
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure RotateUp_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateUp_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X4(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X4(v1, NBits_count);
	end;
end;


(******************************************)
procedure Multi_Int_X4.RotateUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure RotateUp(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
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
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure RotateDown_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:INT_1W_U);
var	n,t	:INT_1W_U;
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
procedure RotateDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	RotateDown_NWords_Multi_Int_X4(v1, NWords_count);
	end
else NBits_count:= NBits;

RotateDown_NBits_Multi_Int_X4(v1, NBits_count);
end;


(******************************************)
procedure Multi_Int_X4.RotateDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure RotateDown(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X4(v1, NBits);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure ShiftUp_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftDown_NBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
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
procedure ShiftDown_NWords_Multi_Int_X4(Var v1:Multi_Int_X4; NWords:INT_1W_U);
var	n	:INT_1W_U;
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
procedure ShiftUp_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X4(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X4(v1, NBits_count);
	end;
end;


{******************************************}
procedure Multi_Int_X4.ShiftUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


{******************************************}
procedure ShiftUp(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X4(v1, NBits);
end;


{******************************************}
procedure ShiftDown_MultiBits_Multi_Int_X4(Var v1:Multi_Int_X4; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X4(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X4(v1, NBits_count);
end;


{******************************************}
procedure Multi_Int_X4.ShiftDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X4(v1, NBits);
end;


{******************************************}
procedure ShiftDown(Var v1:Multi_Int_X4; NBits:INT_1W_U); overload;
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
function To_Multi_Int_X4(const v1:Multi_Int_X48):Multi_Int_X4;
var n :INT_1W_U;
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
end;


(******************************************)
function To_Multi_Int_X4(const v1:Multi_Int_X3):Multi_Int_X4;
var n :INT_1W_U;
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
var n :INT_1W_U;
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
	n				:INT_1W_U;
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
	n				:INT_1W_U;
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
procedure string_to_Multi_Int_X4(const v1:string; var mi:Multi_Int_X4);
label 999;
var
	i,b,c,e		:INT_2W_U;
	M_Val		:array[0..Multi_X4_max] of INT_2W_U;
	Signeg,
	Zeroneg		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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

		if	M_Val[0] > INT_1W_U_MAXINT then
			begin
			M_Val[1]:=M_Val[1] + (M_Val[0] DIV INT_1W_U_MAXINT_1);
			M_Val[0]:=(M_Val[0] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[1] > INT_1W_U_MAXINT then
			begin
			M_Val[2]:=M_Val[2] + (M_Val[1] DIV INT_1W_U_MAXINT_1);
			M_Val[1]:=(M_Val[1] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[2] > INT_1W_U_MAXINT then
			begin
			M_Val[3]:=M_Val[3] + (M_Val[2] DIV INT_1W_U_MAXINT_1);
			M_Val[2]:=(M_Val[2] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[3] > INT_1W_U_MAXINT then
			begin
			M_Val[4]:=M_Val[4] + (M_Val[3] DIV INT_1W_U_MAXINT_1);
			M_Val[3]:=(M_Val[3] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[4] > INT_1W_U_MAXINT then
			begin
			M_Val[5]:=M_Val[5] + (M_Val[4] DIV INT_1W_U_MAXINT_1);
			M_Val[4]:=(M_Val[4] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[5] > INT_1W_U_MAXINT then
			begin
			M_Val[6]:=M_Val[6] + (M_Val[5] DIV INT_1W_U_MAXINT_1);
			M_Val[5]:=(M_Val[5] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[6] > INT_1W_U_MAXINT then
			begin
			M_Val[7]:=M_Val[7] + (M_Val[6] DIV INT_1W_U_MAXINT_1);
			M_Val[6]:=(M_Val[6] MOD INT_1W_U_MAXINT_1);
			end;

		if	M_Val[7] > INT_1W_U_MAXINT then
			begin
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
procedure Multi_Int_X4.Init(const v1:string);
begin
string_to_Multi_Int_X4(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X4.implicit(const v1:string):Multi_Int_X4;
begin
string_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure INT_2W_S_to_Multi_Int_X4(const v1:INT_2W_S; var mi:Multi_Int_X4);
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
	mi.M_Value[0]:= (ABS(v1) MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:INT_2W_S):Multi_Int_X4;
begin
INT_2W_S_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure INT_2W_U_to_Multi_Int_X4(const v1:INT_2W_U; var mi:Multi_Int_X4);
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
mi.M_Value[2]:= 0;
mi.M_Value[3]:= 0;
mi.M_Value[4]:= 0;
mi.M_Value[5]:= 0;
mi.M_Value[6]:= 0;
mi.M_Value[7]:= 0;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:INT_2W_U):Multi_Int_X4;
begin
INT_2W_U_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Real):Multi_Int_X4;
var
R,RM,RT,RMAX	:Real;
M				:Multi_Int_X4;
begin
R:= Trunc(ABS(v1));
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[4]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[5]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[6]:= Trunc(RM);
R:= RT;

RT:= Trunc(R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[7]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on real conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Real;
var R,V,M:Real;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

V:= v1.M_Value[4];
V:= V * M * M * M * M;
R:= R + V;

V:= v1.M_Value[5];
V:= V * M * M * M * M * M;
R:= R + V;

V:= v1.M_Value[6];
V:= V * M * M * M * M * M * M;
R:= R + V;

V:= v1.M_Value[7];
V:= V * M * M * M * M * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Double):Multi_Int_X4;
var
R,RM,RT,RMAX	:Double;
M				:Multi_Int_X4;
begin
R:= ABS(v1);
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[0]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[1]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[2]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[3]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[4]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[5]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[6]:= Trunc(RM);
R:= RT;

RT:= (R / RMAX);
RM:= (R - (RT * RMAX));
M.M_Value[7]:= Trunc(RM);
R:= RT;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Double;
var R,V,M:Double;
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

M:= INT_1W_U_MAXINT_1;

R:=	v1.M_Value[0];

V:= v1.M_Value[1];
V:= V * M;
R:= R + V;

V:= v1.M_Value[2];
V:= V * M * M;
R:= R + V;

V:= v1.M_Value[3];
V:= V * M * M * M;
R:= R + V;

V:= v1.M_Value[4];
V:= V * M * M * M * M;
R:= R + V;

V:= v1.M_Value[5];
V:= V * M * M * M * M * M;
R:= R + V;

V:= v1.M_Value[6];
V:= V * M * M * M * M * M * M;
R:= R + V;

V:= v1.M_Value[7];
V:= V * M * M * M * M * M * M * M;
R:= R + V;

if v1.Negative_flag then R:= (- R);
Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):INT_2W_S;
var	R	:INT_2W_U;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if (R >= INT_2W_S_MAXINT)
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
then Result:= INT_2W_S(-R)
else Result:= INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):INT_2W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[1]) << INT_1W_SIZE);
R:= (R OR INT_2W_U(v1.M_Value[0]));

if	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= R;
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):INT_1W_S;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_1W_S_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_1W_S(-R)
else Result:= INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):INT_1W_U;
var	R	:INT_2W_U;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

if	(R > INT_1W_U_MAXINT)
or	(v1.M_Value[2] <> 0)
or	(v1.M_Value[3] <> 0)
or	(v1.M_Value[4] <> 0)
or	(v1.M_Value[5] <> 0)
or	(v1.M_Value[6] <> 0)
or	(v1.M_Value[7] <> 0)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):Multi_int8u;
(* var	R	:Multi_int8u; *)
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
Multi_Int_OVERFLOW_ERROR:= FALSE;
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
procedure Multi_Int_X4_to_hex(const v1:Multi_Int_X4; var v2:string; LZ:T_Multi_Leading_Zeros);
var
	s		:string = '';
	n		:Multi_int32u;
	M_Val	:array[0..Multi_X4_max] of INT_2W_U;
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

n:= (INT_1W_SIZE div 4);
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
v2:=s;
end;


(******************************************)
function Multi_Int_X4.ToHex(const LZ:T_Multi_Leading_Zeros):string;
begin
Multi_Int_X4_to_hex(self, Result, LZ);
end;


(******************************************)
procedure hex_to_Multi_Int_X4(const v1:string; var mi:Multi_Int_X4);
label 999;
var
	n,i,b,c,e
				:INT_2W_U;
	M_Val		:array[0..Multi_X4_max] of INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
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
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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
			if	M_Val[n] > INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > INT_1W_U_MAXINT then
			begin
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
function Multi_Int_X4.FromHex(const v1:string):Multi_Int_X4;
begin
hex_to_Multi_Int_X4(v1,Result);
end;


(******************************************)
procedure Multi_Int_X4_to_string(const v1:Multi_Int_X4; var v2:string);
var
	s		:string = '';
	M_Val	:array[0..Multi_X4_max] of INT_2W_U;
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

	M_Val[6]:= M_Val[6] + (INT_1W_U_MAXINT_1 * (M_Val[7] MOD 10));
	M_Val[7]:= (M_Val[7] DIV 10);

	M_Val[5]:= M_Val[5] + (INT_1W_U_MAXINT_1 * (M_Val[6] MOD 10));
	M_Val[6]:= (M_Val[6] DIV 10);

	M_Val[4]:= M_Val[4] + (INT_1W_U_MAXINT_1 * (M_Val[5] MOD 10));
	M_Val[5]:= (M_Val[5] DIV 10);

	M_Val[3]:= M_Val[3] + (INT_1W_U_MAXINT_1 * (M_Val[4] MOD 10));
	M_Val[4]:= (M_Val[4] DIV 10);

	M_Val[2]:= M_Val[2] + (INT_1W_U_MAXINT_1 * (M_Val[3] MOD 10));
	M_Val[3]:= (M_Val[3] DIV 10);

	M_Val[1]:= M_Val[1] + (INT_1W_U_MAXINT_1 * (M_Val[2] MOD 10));
	M_Val[2]:= (M_Val[2] DIV 10);

	M_Val[0]:= M_Val[0] + (INT_1W_U_MAXINT_1 * (M_Val[1] MOD 10));
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
function Multi_Int_X4.ToStr:string;
begin
Multi_Int_X4_to_string(self, Result);
end;


(******************************************)
class operator Multi_Int_X4.implicit(const v1:Multi_Int_X4):string;
begin
Multi_Int_X4_to_string(v1, Result);
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
	tv2		:INT_2W_U;
	M_Val	:array[0..Multi_X4_max] of INT_2W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag.Init(Multi_UBool_UNDEF);

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

tv1:= v1.M_Value[1];
tv2:= v2.M_Value[1];
M_Val[1]:=(M_Val[1] + tv1 + tv2);
if	M_Val[1] > INT_1W_U_MAXINT then
	begin
	M_Val[2]:= (M_Val[1] DIV INT_1W_U_MAXINT_1);
	M_Val[1]:= (M_Val[1] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

tv1:= v1.M_Value[2];
tv2:= v2.M_Value[2];
M_Val[2]:=(M_Val[2] + tv1 + tv2);
if	M_Val[2] > INT_1W_U_MAXINT then
	begin
	M_Val[3]:= (M_Val[2] DIV INT_1W_U_MAXINT_1);
	M_Val[2]:= (M_Val[2] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

tv1:= v1.M_Value[3];
tv2:= v2.M_Value[3];
M_Val[3]:=(M_Val[3] + tv1 + tv2);
if	M_Val[3] > INT_1W_U_MAXINT then
	begin
	M_Val[4]:= (M_Val[3] DIV INT_1W_U_MAXINT_1);
	M_Val[3]:= (M_Val[3] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

tv1:= v1.M_Value[4];
tv2:= v2.M_Value[4];
M_Val[4]:=(M_Val[4] + tv1 + tv2);
if	M_Val[4] > INT_1W_U_MAXINT then
	begin
	M_Val[5]:= (M_Val[4] DIV INT_1W_U_MAXINT_1);
	M_Val[4]:= (M_Val[4] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

tv1:= v1.M_Value[5];
tv2:= v2.M_Value[5];
M_Val[5]:=(M_Val[5] + tv1 + tv2);
if	M_Val[5] > INT_1W_U_MAXINT then
	begin
	M_Val[6]:= (M_Val[5] DIV INT_1W_U_MAXINT_1);
	M_Val[5]:= (M_Val[5] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

tv1:= v1.M_Value[6];
tv2:= v2.M_Value[6];
M_Val[6]:=(M_Val[6] + tv1 + tv2);
if	M_Val[6] > INT_1W_U_MAXINT then
	begin
	M_Val[7]:= (M_Val[6] DIV INT_1W_U_MAXINT_1);
	M_Val[6]:= (M_Val[6] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

tv1:= v1.M_Value[7];
tv2:= v2.M_Value[7];
M_Val[7]:=(M_Val[7] + tv1 + tv2);
if	M_Val[7] > INT_1W_U_MAXINT then
	begin
	M_Val[7]:= (M_Val[7] MOD INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on add');
		end;
*)
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
	M_Val	:array[0..Multi_X4_max] of INT_2W_S;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

M_Val[1]:=(v1.M_Value[1] - v2.M_Value[1] + M_Val[1]);
if	M_Val[1] < 0 then
	begin
	M_Val[2]:= -1;
	M_Val[1]:= (M_Val[1] + INT_1W_U_MAXINT_1);
	end
else M_Val[2]:= 0;

M_Val[2]:=(v1.M_Value[2] - v2.M_Value[2] + M_Val[2]);
if	M_Val[2] < 0 then
	begin
	M_Val[3]:= -1;
	M_Val[2]:= (M_Val[2] + INT_1W_U_MAXINT_1);
	end
else M_Val[3]:= 0;

M_Val[3]:=(v1.M_Value[3] - v2.M_Value[3] + M_Val[3]);
if	M_Val[3] < 0 then
	begin
	M_Val[4]:= -1;
	M_Val[3]:= (M_Val[3] + INT_1W_U_MAXINT_1);
	end
else M_Val[4]:= 0;

M_Val[4]:=(v1.M_Value[4] - v2.M_Value[4] + M_Val[4]);
if	M_Val[4] < 0 then
	begin
	M_Val[5]:= -1;
	M_Val[4]:= (M_Val[4] + INT_1W_U_MAXINT_1);
	end
else M_Val[5]:= 0;

M_Val[5]:=(v1.M_Value[5] - v2.M_Value[5] + M_Val[5]);
if	M_Val[5] < 0 then
	begin
	M_Val[6]:= -1;
	M_Val[5]:= (M_Val[5] + INT_1W_U_MAXINT_1);
	end
else M_Val[6]:= 0;

M_Val[6]:=(v1.M_Value[6] - v2.M_Value[6] + M_Val[6]);
if	M_Val[6] < 0 then
	begin
	M_Val[7]:= -1;
	M_Val[6]:= (M_Val[6] + INT_1W_U_MAXINT_1);
	end
else M_Val[7]:= 0;

M_Val[7]:=(v1.M_Value[7] - v2.M_Value[7] + M_Val[7]);
if	M_Val[7] < 0 then
	begin
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
(*
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on subtract');
		end;
*)
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Inc');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.inc(const v1:Multi_Int_X4; const v2:Multi_Int_X4):Multi_Int_X4;
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Add');
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Subtract');
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

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X4.dec(const v1:Multi_Int_X4; const v2:Multi_Int_X4):Multi_Int_X4;
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


(******************************************)
class operator Multi_Int_X4.-(const v1:Multi_Int_X4):Multi_Int_X4;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;
if	(v1.Negative_flag) then
	Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
procedure multiply_Multi_Int_X4(const v1,v2:Multi_Int_X4;var Result:Multi_Int_X4);
var
	M_Val	:array[0..Multi_X4_max_x2] of INT_2W_U;
	tv1,tv2	:INT_2W_U;
	i,j,k	:INT_1W_U;
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
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X4_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD INT_1W_U_MAXINT_1);
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

if	R.Overflow_flag then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X4;var VR,VREM:Multi_Int_X4);
var
D,D2		:INT_2W_S;
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
	L:= '1' + AddCharR('0','',D2-1);
	H:= '1' + AddCharR('0','',D2);
	end
else
	begin
	L:= '1' + AddCharR('0','',D2);
	H:= '1' + AddCharR('0','',D2+1);
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

class operator Multi_Int_X4.**(const v1:Multi_Int_X4; const P:INT_2W_S):Multi_Int_X4;
var
Y,TV,T,R	:Multi_Int_X4;
PT			:INT_2W_S;
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
prev_dividend,
ZERO				:Multi_Int_X4;
T					:INT_1W_U;
z,k					:INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:INT_2W_S;

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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
		if	(T <> 0) then Inc(z);
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
	if	(z = 1) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X4_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * INT_1W_U_MAXINT_1) + dividend.M_Value[i]) div divisor.M_Value[0]);
			k:= (((k * Multi_X4_max) + dividend.M_Value[i]) - (P_quotient.M_Value[i] * divisor.M_Value[0]));
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
		prev_dividend:= dividend;
		dividend:= (dividend - divisor);
		if (dividend > ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			goto 1000;
			end;
		if (dividend = ZERO) then
			quotient:= (quotient + quotient_factor);
		if (dividend < ZERO) then
			dividend:= prev_dividend;

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
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

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
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X4_Last_Divisor:= P_v2;
	X4_Last_Dividend:= P_v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Quotient;
	end;

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
else
	begin
	intdivide_Shift_And_Sub_X4(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X4_Last_Divisor:= v2;
	X4_Last_Dividend:= v1;
	X4_Last_Quotient:= Quotient;
	X4_Last_Remainder:= Remainder;

	Result:= Remainder;
	end;

end;


{
******************************************
Multi_Int_X48
******************************************
}


function ABS_greaterthan_Multi_Int_X48(const v1,v2:Multi_Int_X48):Boolean;
var
	i	:INT_2W_U;
begin
i:= Multi_X48_max;
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
function ABS_lessthan_Multi_Int_X48(const v1,v2:Multi_Int_X48):Boolean;
var
	i	:INT_2W_U;
begin
i:= Multi_X48_max;
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
function nlz_words_X48(const m:Multi_Int_X48):INT_1W_U; // v2
var
i,n		:Multi_int32;
fini	:boolean;
begin
n:= 0;
i:= Multi_X48_max;
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
function nlz_MultiBits_X48(const m:Multi_Int_X48):INT_1W_U;
var	w,b	:INT_1W_U;
begin
w:= nlz_words_X48(m);
if (w <= Multi_X48_max)
then Result:= nlz_bits(m.M_Value[Multi_X48_max-w]) + (w * INT_1W_SIZE)
else Result:= (w * INT_1W_SIZE);
end;


(******************************************)
function Multi_Int_X48.Overflow:boolean;
begin
Result:= self.Overflow_flag;
end;


(******************************************)
function Multi_Int_X48.Defined:boolean;
begin
Result:= self.Defined_flag;
end;


(******************************************)
function Overflow(const v1:Multi_Int_X48):boolean; overload;
begin
Result:= v1.Overflow_flag;
end;


(******************************************)
function Defined(const v1:Multi_Int_X48):boolean; overload;
begin
Result:= v1.Defined_flag;
end;


(******************************************)
function Multi_Int_X48.Negative:boolean;
begin
Result:= self.Negative_flag;
end;


(******************************************)
function Negative(const v1:Multi_Int_X48):boolean; overload;
begin
Result:= v1.Negative_flag;
end;


(******************************************)
function Abs(const v1:Multi_Int_X48):Multi_Int_X48; overload;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;
end;


(******************************************)
function Multi_Int_X48_Odd(const v1:Multi_Int_X48):boolean;
var	bit1_mask	:INT_1W_U;
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
function Odd(const v1:Multi_Int_X48):boolean; overload;
begin
Result:= Multi_Int_X48_Odd(v1);
end;


(******************************************)
function Multi_Int_X48_Even(const v1:Multi_Int_X48):boolean;
var	bit1_mask	:INT_1W_U;
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
function Even(const v1:Multi_Int_X48):boolean; overload;
begin
Result:= Multi_Int_X48_Even(v1);
end;


(******************************************)
procedure ShiftUp_NBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
	n			:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[0]:= (v1.M_Value[0] << NBits);

	n:=1;
	while (n < Multi_X48_max) do
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
procedure ShiftUp_NWords_Multi_Int_X48(var v1:Multi_Int_X48; NWords:INT_1W_U);
var	n,i	:INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X48_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=Multi_X48_max;
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
procedure ShiftUp_MultiBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		ShiftUp_NWords_Multi_Int_X48(v1, NWords_count);
		end
	else NBits_count:= NBits;
	ShiftUp_NBits_Multi_Int_X48(v1, NBits_count);
	end;
end;


{******************************************}
procedure Multi_Int_X48.ShiftUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U);
begin
ShiftUp_MultiBits_Multi_Int_X48(v1, NBits);
end;


{******************************************}
procedure ShiftUp(var v1:Multi_Int_X48; NBits:INT_1W_U); overload;
begin
ShiftUp_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
procedure RotateUp_NBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask << NBits_carry);

if NBits <= NBits_max then
	begin
	carry_bits_1:= ((v1.M_Value[0] and carry_bits_mask) >> NBits_carry);
	v1.M_Value[0]:= (v1.M_Value[0] << NBits);

	n:=1;
	while (n <= Multi_X48_max) do
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
procedure RotateUp_NWords_Multi_Int_X48(var v1:Multi_Int_X48; NWords:INT_1W_U);
var	i,n,t	:INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X48_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=Multi_X48_max;
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
procedure RotateUp_MultiBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		RotateUp_NWords_Multi_Int_X48(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateUp_NBits_Multi_Int_X48(v1, NBits_count);
	end;
end;


(******************************************)
procedure Multi_Int_X48.RotateUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U);
begin
RotateUp_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
procedure RotateUp(var v1:Multi_Int_X48; NBits:INT_1W_U); overload;
begin
RotateUp_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
procedure ShiftDown_NBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
	begin
	n:=Multi_X48_max;
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
procedure ShiftDown_NWords_Multi_Int_X48(var v1:Multi_Int_X48; NWords:INT_1W_U);
var	n,i	:INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X48_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=0;
		while (i < Multi_X48_max) do
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
procedure ShiftDown_MultiBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin

if (NBits >= INT_1W_SIZE) then
	begin
	NWords_count:= (NBits DIV INT_1W_SIZE);
	NBits_count:= (NBits MOD INT_1W_SIZE);
	ShiftDown_NWords_Multi_Int_X48(v1, NWords_count);
	end
else NBits_count:= NBits;

ShiftDown_NBits_Multi_Int_X48(v1, NBits_count);
end;


{******************************************}
procedure Multi_Int_X48.ShiftDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U);
begin
ShiftDown_MultiBits_Multi_Int_X48(v1, NBits);
end;


{******************************************}
procedure ShiftDown(var v1:Multi_Int_X48; NBits:INT_1W_U); overload;
begin
ShiftDown_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
procedure RotateDown_NBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var	carry_bits_1,
	carry_bits_2,
	carry_bits_mask,
	NBits_max,
	NBits_carry	:INT_1W_U;
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

NBits_max:= INT_1W_SIZE;
NBits_carry:= (NBits_max - NBits);
carry_bits_mask:= (carry_bits_mask >> NBits_carry);

if NBits <= NBits_max then
	begin
	n:=Multi_X48_max;
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

	v1.M_Value[Multi_X48_max]:= (v1.M_Value[Multi_X48_max] OR carry_bits_1);

	end;
end;

{$ifdef Overflow_Checks}
{$Q+}
{$R+}
{$endif}

end;


(******************************************)
procedure RotateDown_NWords_Multi_Int_X48(var v1:Multi_Int_X48; NWords:INT_1W_U);
var	i,n,t	:INT_1W_U;
begin
if		(NWords > 0)
and		(NWords <= Multi_X48_max) then
	begin
	n:= NWords;
	while (n > 0) do
		begin
		i:=0;
		t:= v1.M_Value[i];
		while (i < Multi_X48_max) do
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
procedure RotateDown_MultiBits_Multi_Int_X48(var v1:Multi_Int_X48; NBits:INT_1W_U);
var
NWords_count,
NBits_count		:INT_1W_U;

begin
if (NBits > 0) then
	begin
	if (NBits >= INT_1W_SIZE) then
		begin
		NWords_count:= (NBits DIV INT_1W_SIZE);
		NBits_count:= (NBits MOD INT_1W_SIZE);
		RotateDown_NWords_Multi_Int_X48(v1, NWords_count);
		end
	else NBits_count:= NBits;
	RotateDown_NBits_Multi_Int_X48(v1, NBits_count);
	end;
end;


(******************************************)
procedure Multi_Int_X48.RotateDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U);
begin
RotateDown_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
procedure RotateDown(var v1:Multi_Int_X48; NBits:INT_1W_U); overload;
begin
RotateDown_MultiBits_Multi_Int_X48(v1, NBits);
end;


(******************************************)
class operator Multi_Int_X48.greaterthan(const v1,v2:Multi_Int_X48):Boolean;
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
		then Result:= ABS_greaterthan_Multi_Int_X48(v1,v2)
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= ABS_lessthan_Multi_Int_X48(v1,v2);
end;


(******************************************)
class operator Multi_Int_X48.lessthan(const v1,v2:Multi_Int_X48):Boolean;
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
	then Result:= ABS_lessthan_Multi_Int_X48(v1,v2)
	else
		if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
		then Result:= ABS_greaterthan_Multi_Int_X48(v1,v2);
end;


(******************************************)
function ABS_equal_Multi_Int_X48(const v1,v2:Multi_Int_X48):Boolean;
var
	i	:INT_2W_U;
begin
Result:=TRUE;
i:=0;
while (i <= Multi_X48_max) do
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
function ABS_notequal_Multi_Int_X48(const v1,v2:Multi_Int_X48):Boolean;
begin
Result:= (not ABS_equal_Multi_Int_X48(v1,v2));
end;


(******************************************)
class operator Multi_Int_X48.equal(const v1,v2:Multi_Int_X48):Boolean;
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
else Result:= ABS_equal_Multi_Int_X48(v1,v2);
end;


(******************************************)
class operator Multi_Int_X48.notequal(const v1,v2:Multi_Int_X48):Boolean;
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
else Result:= (not ABS_equal_Multi_Int_X48(v1,v2));
end;


(******************************************)
class operator Multi_Int_X48.<=(const v1,v2:Multi_Int_X48):Boolean;
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
		then Result:= (Not ABS_greaterthan_Multi_Int_X48(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_lessthan_Multi_Int_X48(v1,v2));
end;


(******************************************)
class operator Multi_Int_X48.>=(const v1,v2:Multi_Int_X48):Boolean;
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
		then Result:= (Not ABS_lessthan_Multi_Int_X48(v1,v2) )
		else
			if ( (v1.Negative_flag = TRUE) and (v2.Negative_flag = TRUE) )
			then Result:= (Not ABS_greaterthan_Multi_Int_X48(v1,v2) );
end;


(******************************************)
procedure string_to_Multi_Int_X48(const v1:string; var mi:Multi_Int_X48);
label 999;
var
	n,i,b,c,e
				:INT_2W_U;
	M_Val		:array[0..Multi_X48_max] of INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X48_max)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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
		while (n <= Multi_X48_max) do
			begin
			M_Val[n]:=(M_Val[n] * 10);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X48_max) do
			begin
			if	M_Val[n] > INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > INT_1W_U_MAXINT then
			begin
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
while (n <= Multi_X48_max) do
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
{
procedure Multi_Int_X48.Init(const v1:string); overload;
begin
string_to_Multi_Int_X48(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X48.implicit(const v1:string):Multi_Int_X48;
begin
string_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
procedure Multi_Int_X48_to_string(const v1:Multi_Int_X48; var v2:string);
var
	s				:string = '';
	M_Val			:array[0..Multi_X48_max] of INT_2W_U;
	n				:INT_2W_U;
	M_Val_All_Zero	:boolean;
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

n:=0;
while (n <= Multi_X48_max) do
	begin
	M_Val[n]:= v1.M_Value[n];
	inc(n);
	end;

repeat
	n:= Multi_X48_max;
	M_Val_All_Zero:= TRUE;
	repeat
		M_Val[n-1]:= M_Val[n-1] + (INT_1W_U_MAXINT_1 * (M_Val[n] MOD 10));
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
function Multi_Int_X48.ToStr:string;
begin
Multi_Int_X48_to_string(self, Result);
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):string;
begin
Multi_Int_X48_to_string(v1, Result);
end;


(******************************************)
procedure hex_to_Multi_Int_X48(const v1:string; var mi:Multi_Int_X48);
label 999;
var
	n,i,b,c,e
				:INT_2W_U;
	M_Val		:array[0..Multi_X48_max] of INT_2W_U;
	Signeg,
	Zeroneg,
	M_Val_All_Zero		:boolean;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:= TRUE;
mi.Negative_flag:= FALSE;
Signeg:= FALSE;
Zeroneg:= FALSE;

n:=0;
while (n <= Multi_X48_max)
do begin M_Val[n]:= 0; inc(n); end;

if	(length(v1) > 0) then
	begin
	b:=low(string);
	e:=b + INT_2W_U(length(v1)) - 1;
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
		while (n <= Multi_X48_max) do
			begin
			M_Val[n]:=(M_Val[n] * 16);
			inc(n);
			end;

		n:=0;
		while (n < Multi_X48_max) do
			begin
			if	M_Val[n] > INT_1W_U_MAXINT then
				begin
				M_Val[n+1]:=M_Val[n+1] + (M_Val[n] DIV INT_1W_U_MAXINT_1);
				M_Val[n]:=(M_Val[n] MOD INT_1W_U_MAXINT_1);
				end;

			inc(n);
			end;

		if	M_Val[n] > INT_1W_U_MAXINT then
			begin
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
while (n <= Multi_X48_max) do
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
function Multi_Int_X48.FromHex(const v1:string):Multi_Int_X48;
begin
hex_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
procedure Multi_Int_X48_to_hex(const v1:Multi_Int_X48; var v2:string; LZ:T_Multi_Leading_Zeros);
var
	s		:string = '';
	i,n		:INT_1W_S;
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

n:= (INT_1W_SIZE div 4);
s:= '';

i:=Multi_X48_max;
while (i >= 0) do
	begin
	s:= s + IntToHex(v1.M_Value[i],n);
	dec(i);
	end;

if (LZ = Multi_Trim_Leading_Zeros) then Removeleadingchars(s,['0']);
if	(v1.Negative_flag = Multi_UBool_TRUE) then s:='-' + s;
v2:=s;
end;


(******************************************)
function Multi_Int_X48.ToHex(const LZ:T_Multi_Leading_Zeros):string;
begin
Multi_Int_X48_to_hex(self, Result, LZ);
end;


(******************************************)
procedure INT_2W_S_to_Multi_Int_X48(const v1:INT_2W_S; var mi:Multi_Int_X48);
var
	n				:INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;

n:=2;
while (n <= Multi_X48_max) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;

if (v1 < 0) then
	begin
	mi.Negative_flag:= Multi_UBool_TRUE;
	mi.M_Value[0]:= (ABS(v1) MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (ABS(v1) DIV INT_1W_U_MAXINT_1);
	end
else
	begin
	mi.Negative_flag:= Multi_UBool_FALSE;
	mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
	mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);
	end;
end;


(******************************************)
{
procedure Multi_Int_X48.Init(const v1:INT_2W_S); overload;
begin
INT_2W_S_to_Multi_Int_X48(v1,self);
end;
}


(******************************************)
class operator Multi_Int_X48.implicit(const v1:INT_2W_S):Multi_Int_X48;
begin
INT_2W_S_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
function To_Multi_Int_X48(const v1:Multi_Int_X4):Multi_Int_X48;
var n :INT_1W_U;
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

while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X48(const v1:Multi_Int_X3):Multi_Int_X48;
var n :INT_1W_U;
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

while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
function To_Multi_Int_X48(const v1:Multi_Int_X2):Multi_Int_X48;
var n :INT_1W_U;
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

while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
procedure Multi_Int_X4_to_Multi_Int_X48(const v1:Multi_Int_X4; var MI:Multi_Int_X48);
var
n				:INT_1W_U;

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

if	(Multi_X48_max < Multi_X4_max) then
	begin
	n:= 0;
	while (n <= Multi_X48_max) do
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
			Multi_Int_OVERFLOW_ERROR:= TRUE;
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

	while (n <= Multi_X48_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X4):Multi_Int_X48;
begin
Multi_Int_X4_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
procedure Multi_Int_X3_to_Multi_Int_X48(const v1:Multi_Int_X3; var MI:Multi_Int_X48);
var
n				:INT_1W_U;

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

if	(Multi_X48_max < Multi_X3_max) then
	begin
	n:= 0;
	while (n <= Multi_X48_max) do
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
			Multi_Int_OVERFLOW_ERROR:= TRUE;
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

	while (n <= Multi_X48_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X3):Multi_Int_X48;
begin
Multi_Int_X3_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
procedure Multi_Int_X2_to_Multi_Int_X48(const v1:Multi_Int_X2; var MI:Multi_Int_X48);
var
n				:INT_1W_U;

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

if	(Multi_X48_max < Multi_X2_max) then
	begin
	n:= 0;
	while (n <= Multi_X48_max) do
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
			Multi_Int_OVERFLOW_ERROR:= TRUE;
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

	while (n <= Multi_X48_max) do
		begin
		MI.M_Value[n]:= 0;
		inc(n);
		end;
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X2):Multi_Int_X48;
begin
Multi_Int_X2_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
procedure INT_2W_U_to_Multi_Int_X48(const v1:INT_2W_U; var mi:Multi_Int_X48);
var
	n				:INT_2W_U;
begin
mi.Overflow_flag:=FALSE;
mi.Defined_flag:=TRUE;
mi.Negative_flag:= Multi_UBool_FALSE;

mi.M_Value[0]:= (v1 MOD INT_1W_U_MAXINT_1);
mi.M_Value[1]:= (v1 DIV INT_1W_U_MAXINT_1);

n:=2;
while (n <= Multi_X48_max) do
	begin
	mi.M_Value[n]:= 0;
	inc(n);
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:INT_2W_U):Multi_Int_X48;
begin
INT_2W_U_to_Multi_Int_X48(v1,Result);
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Real):Multi_Int_X48;
var
R,RM,RT,RMAX	:Real;
n				:INT_2W_U;
M				:Multi_Int_X48;
begin
R:= Trunc(ABS(v1));
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

n:=0;
while (n <= Multi_X48_max) do
	begin
	RT:= Trunc(R / RMAX);
	RM:= (R - (RT * RMAX));
	M.M_Value[n]:= Trunc(RM);
	R:= RT;
	end;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on real conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Double):Multi_Int_X48;
var
R,RM,RT,RMAX	:Double;
n				:INT_2W_U;
M				:Multi_Int_X48;
begin
R:= ABS(v1);
M:= 0;
RMAX:= INT_1W_U_MAXINT_1;

n:=0;
while (n <= Multi_X48_max) do
	begin
	RT:= Trunc(R / RMAX);
	RM:= (R - (RT * RMAX));
	M.M_Value[n]:= Trunc(RM);
	R:= RT;
	end;

if (R > 0.0) then
	begin
	Result:= 0;
	Result.Defined_flag:= FALSE;
	Result.Negative_flag:= Multi_UBool_UNDEF;
	Result.Overflow_flag:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on Double conversion');
		end;
	end
else
	begin
	if (v1 < 0.0) then M.Negative_flag := TRUE;
	Result:= M;
	end;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):INT_2W_S;
var
	R	:INT_2W_U;
	n	:INT_1W_U;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n <= Multi_X48_max)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if (R >= INT_2W_S_MAXINT)
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
then Result:= INT_2W_S(-R)
else Result:= INT_2W_S(R);
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):INT_2W_U;
var
	R	:INT_2W_U;
	n	:INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[1]) << INT_1W_SIZE);
R:= (R OR INT_2W_U(v1.M_Value[0]));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n <= Multi_X48_max)
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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= R;
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):INT_1W_S;
var
	R	:INT_2W_U;
	n	:INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n <= Multi_X48_max)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if	(R > INT_1W_S_MAXINT)
or (not M_Val_All_Zero)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

if v1.Negative_flag
then Result:= INT_1W_S(-R)
else Result:= INT_1W_S(R);
end;


(******************************************)
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):INT_1W_U;
var
	R	:INT_2W_U;
	n	:INT_1W_U;
	M_Val_All_Zero	:boolean;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

R:= (INT_2W_U(v1.M_Value[0]) + (INT_2W_U(v1.M_Value[1]) * INT_1W_U_MAXINT_1));

M_Val_All_Zero:= TRUE;
n:=2;
while	(n <= Multi_X48_max)
and		M_Val_All_Zero
do
	begin
	if (v1.M_Value[n] <> 0)
	then M_Val_All_Zero:= FALSE;
	inc(n)
	end;

if	(R > INT_1W_U_MAXINT)
or (not M_Val_All_Zero)
then
	begin
	Result:=0;
	Multi_Int_OVERFLOW_ERROR:= TRUE;
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EInterror.create('Overflow');
		end;
	exit;
	end;

Result:= INT_1W_U(R);
end;


{******************************************}
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):Multi_int8u;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

if v1 > Multi_INT8U_MAXINT
then
	begin
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
class operator Multi_Int_X48.implicit(const v1:Multi_Int_X48):Multi_int8;
begin
Multi_Int_OVERFLOW_ERROR:= FALSE;
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

if v1 > Multi_INT8U_MAXINT
then
	begin
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
function add_Multi_Int_X48(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var
	tv1,
	tv2,
	n		:INT_2W_U;
	M_Val	:array[0..Multi_X48_max] of INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag.Init(Multi_UBool_UNDEF);

tv1:= v1.M_Value[0];
tv2:= v2.M_Value[0];
M_Val[0]:= (tv1 + tv2);
if	M_Val[0] > INT_1W_U_MAXINT then
	begin
	M_Val[1]:= (M_Val[0] DIV INT_1W_U_MAXINT_1);
	M_Val[0]:= (M_Val[0] MOD INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

n:=1;
while (n < Multi_X48_max) do
	begin
	tv1:= v1.M_Value[n];
	tv2:= v2.M_Value[n];
	M_Val[n]:=(M_Val[n] + tv1 + tv2);
	if	M_Val[n] > INT_1W_U_MAXINT then
		begin
		M_Val[n+1]:= (M_Val[n] DIV INT_1W_U_MAXINT_1);
		M_Val[n]:= (M_Val[n] MOD INT_1W_U_MAXINT_1);
		end
	else M_Val[n+1]:= 0;

	inc(n);
	end;

tv1:= v1.M_Value[n];
tv2:= v2.M_Value[n];
M_Val[n]:=(M_Val[n] + tv1 + tv2);
if	M_Val[n] > INT_1W_U_MAXINT then
	begin
	M_Val[n]:= (M_Val[n] MOD INT_1W_U_MAXINT_1);
	Result.Defined_flag:= FALSE;
	Result.Overflow_flag:=TRUE;
	end;

M_Val_All_Zero:= TRUE;
n:=0;
while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	if M_Val[n] <> 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;

end;


(******************************************)
function subtract_Multi_Int_X48(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var
	M_Val	:array[0..Multi_X48_max] of INT_2W_S;
	n		:INT_2W_U;
	M_Val_All_Zero	:boolean;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

M_Val[0]:=(v1.M_Value[0] - v2.M_Value[0]);
if	M_Val[0] < 0 then
	begin
	M_Val[1]:= -1;
	M_Val[0]:= (M_Val[0] + INT_1W_U_MAXINT_1);
	end
else M_Val[1]:= 0;

n:=1;
while (n < Multi_X48_max) do
	begin
	M_Val[n]:=((v1.M_Value[n] - v2.M_Value[n]) + M_Val[n]);
	if	M_Val[n] < 0 then
		begin
		M_Val[n+1]:= -1;
		M_Val[n]:= (M_Val[n] + INT_1W_U_MAXINT_1);
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
while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	if M_Val[n] > 0 then M_Val_All_Zero:= FALSE;
	inc(n);
	end;

if M_Val_All_Zero
then Result.Negative_flag:=Multi_UBool_FALSE;
end;


(******************************************)
class operator Multi_Int_X48.add(const v1,v2:Multi_Int_X48):Multi_Int_X48;
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
	Result:=add_Multi_Int_X48(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	if	((v1.Negative_flag = FALSE) and (v2.Negative_flag = TRUE))
	then
		begin
		if	ABS_greaterthan_Multi_Int_X48(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X48(v2,v1);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X48(v1,v2);
			Neg:= Multi_UBool_FALSE;
			end;
		end
	else
		begin
		if	ABS_greaterthan_Multi_Int_X48(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X48(v1,v2);
			Neg:= Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X48(v2,v1);
			Neg:= Multi_UBool_FALSE;
			end;
		end;

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on add');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X48.inc(const v1:Multi_Int_X48):Multi_Int_X48;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X48;
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
v2:= 1;

if	(v1.Negative_flag = FALSE)
then
	begin
	Result:=add_Multi_Int_X48(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_X48(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_X48(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X48(v2,v1);
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
class operator Multi_Int_X48.inc(const v1:Multi_Int_X48; const v2:Multi_Int_X48):Multi_Int_X48;
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
	Result:=add_Multi_Int_X48(v1,v2);
	Neg:= v1.Negative_flag;
	end
else
	begin
	if	ABS_greaterthan_Multi_Int_X48(v1,v2)
	then
		begin
		Result:=subtract_Multi_Int_X48(v1,v2);
		Neg:= Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X48(v2,v1);
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
class operator Multi_Int_X48.subtract(const v1,v2:Multi_Int_X48):Multi_Int_X48;
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
		if	ABS_greaterthan_Multi_Int_X48(v1,v2)
		then
			begin
			Result:=subtract_Multi_Int_X48(v1,v2);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X48(v2,v1);
			Neg:=Multi_UBool_FALSE;
			end
		end
	else	(* if	not Negative_flag then	*)
		begin
		if	ABS_greaterthan_Multi_Int_X48(v2,v1)
		then
			begin
			Result:=subtract_Multi_Int_X48(v2,v1);
			Neg:=Multi_UBool_TRUE;
			end
		else
			begin
			Result:=subtract_Multi_Int_X48(v1,v2);
			Neg:=Multi_UBool_FALSE;
			end
		end
	end
else (* v1.Negative_flag <> v2.Negative_flag *)
	begin
	if	(v2.Negative_flag = TRUE) then
		begin
		Result:=add_Multi_Int_X48(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	else
		begin
		Result:=add_Multi_Int_X48(v1,v2);
		Neg:=Multi_UBool_TRUE;
		end
	end;

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on subtract');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X48.dec(const v1:Multi_Int_X48):Multi_Int_X48;
Var	Neg	:Multi_UBool_Values;
	v2	:Multi_Int_X48;
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
v2:= 1;

if	(v1.Negative_flag = FALSE) then
	begin
	if	ABS_greaterthan_Multi_Int_X48(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_X48(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X48(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_X48(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X48.dec(const v1:Multi_Int_X48; const v2:Multi_Int_X48):Multi_Int_X48;
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
	if	ABS_greaterthan_Multi_Int_X48(v2,v1)
	then
		begin
		Result:=subtract_Multi_Int_X48(v2,v1);
		Neg:=Multi_UBool_TRUE;
		end
	else
		begin
		Result:=subtract_Multi_Int_X48(v1,v2);
		Neg:=Multi_UBool_FALSE;
		end
	end
else (* v1 is Negative_flag *)
	begin
	Result:=add_Multi_Int_X48(v1,v2);
	Neg:=Multi_UBool_TRUE;
	end;

if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		if (Result.Overflow_flag = TRUE) then
			Raise EIntOverflow.create('Overflow on Dec');
		end;

if	(Result.Negative_flag = Multi_UBool_UNDEF) then Result.Negative_flag:= Neg;
end;


(******************************************)
class operator Multi_Int_X48.-(const v1:Multi_Int_X48):Multi_Int_X48;
begin
Result:= v1;
Result.Negative_flag:= Multi_UBool_FALSE;
if	(not v1.Negative) then
	Result.Negative_flag:= Multi_UBool_TRUE;
end;


(******************************************)
class operator Multi_Int_X48.xor(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var
	n		:INT_2W_U;
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

n:=0;
while (n <= Multi_X48_max) do
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


(******************************************)
procedure multiply_Multi_Int_X48(const v1,v2:Multi_Int_X48;var Result:Multi_Int_X48);
var
	M_Val	:array[0..Multi_X48_max_x2] of INT_2W_U;
	tv1,tv2	:INT_2W_U;
	i,j,k,n	:INT_1W_U;
begin
Result.Overflow_flag:=FALSE;
Result.Defined_flag:=TRUE;
Result.Negative_flag:=Multi_UBool_UNDEF;

i:=0;
repeat M_Val[i]:= 0; INC(i); until (i > Multi_X48_max_x2);

i:=0;
j:=0;
repeat
	repeat
		tv1:=v1.M_Value[i];
		tv2:=v2.M_Value[j];
		M_Val[i+j+1]:= (M_Val[i+j+1] + ((tv1 * tv2) DIV INT_1W_U_MAXINT_1));
		M_Val[i+j]:= (M_Val[i+j] + ((tv1 * tv2) MOD INT_1W_U_MAXINT_1));
		INC(i);
	until (i > Multi_X48_max);
	k:=0;
	repeat
		M_Val[k+1]:= M_Val[k+1] + (M_Val[k] DIV INT_1W_U_MAXINT_1);
		M_Val[k]:= (M_Val[k] MOD INT_1W_U_MAXINT_1);
		INC(k);
	until (k > Multi_X48_max);
	INC(j);
	i:=0;
until (j > Multi_X48_max);

Result.Negative_flag:=Multi_UBool_FALSE;
i:=0;
repeat
	if (M_Val[i] <> 0) then
		begin
		Result.Negative_flag:= Multi_UBool_UNDEF;
		if (i > Multi_X48_max) then
			begin
			Result.Overflow_flag:=TRUE;
			end;
		end;
	INC(i);
until (i > Multi_X48_max_x2)
or (Result.Overflow_flag);

n:=0;
while (n <= Multi_X48_max) do
	begin
	Result.M_Value[n]:= M_Val[n];
	inc(n);
	end;

end;


(******************************************)
class operator Multi_Int_X48.multiply(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var	  R:Multi_Int_X48;
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

multiply_Multi_Int_X48(v1,v2,R);

if	(R.Negative_flag = Multi_UBool_UNDEF) then
	if	(v1.Negative_flag = v2.Negative_flag)
	then R.Negative_flag:= Multi_UBool_FALSE
	else R.Negative_flag:=Multi_UBool_TRUE;

Result:= R;

if	R.Overflow_flag then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Overflow on multiply');
		end;
	end;
end;


(*-----------------------*)
procedure SqRoot(const v1:Multi_Int_X48;var VR,VREM:Multi_Int_X48);
var
D,D2		:INT_2W_S;
H,L,C,CC,T	:Multi_Int_X48;
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
	L:= '1' + AddCharR('0','',D2-1);
	H:= '1' + AddCharR('0','',D2);
	end
else
	begin
	L:= '1' + AddCharR('0','',D2);
	H:= '1' + AddCharR('0','',D2+1);
	end;

R_EXACT:= FALSE;
finished:= FALSE;
while not finished do
	begin
	// C:= (L + ((H - L) div 2));
    T:= subtract_Multi_Int_X48(H,L);
    ShiftDown(T,1);
    C:= add_Multi_Int_X48(L,T);

	// CC:= (C * C);
    multiply_Multi_Int_X48(C,C, CC);

	if	(CC.Overflow)
	or	ABS_greaterthan_Multi_Int_X48(CC,v1)
	then
		begin
		if ABS_lessthan_Multi_Int_X48(C,H) then
			H:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_X48(C,C, T);
			VREM:= subtract_Multi_Int_X48(v1,T);
			end
		end
	// else if (CC < v1) then
	else if ABS_lessthan_Multi_Int_X48(CC,v1) then
		begin
		if ABS_greaterthan_Multi_Int_X48(C,L) then
			L:= C
		else
			begin
			finished:= TRUE;
			// VREM:= (v1 - (C * C));
			multiply_Multi_Int_X48(C,C, T);
			VREM:= subtract_Multi_Int_X48(v1,T);
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

class operator Multi_Int_X48.**(const v1:Multi_Int_X48; const P:INT_2W_S):Multi_Int_X48;
var
Y,TV,T,R	:Multi_Int_X48;
PT			:INT_2W_S;
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
			multiply_Multi_Int_X48(TV,Y, T);
			if	(T.Overflow_flag)
			then
				begin
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
		multiply_Multi_Int_X48(TV,TV, T);
		if	(T.Overflow_flag)
		then
			begin
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
	multiply_Multi_Int_X48(TV,Y, R);
	if	(R.Overflow_flag)
	then
		begin
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


(********************v4********************)
procedure intdivide_Shift_And_Sub_X48(const P_dividend,P_divisor:Multi_Int_X48;var P_quotient,P_remainder:Multi_Int_X48);
label	1000,9000,9999;
var
dividend,
divisor,
quotient,
quotient_factor,
prev_dividend,
ZERO				:Multi_Int_X48;
T					:INT_1W_U;
z,k					:INT_2W_U;
i,
nlz_bits_dividend,
nlz_bits_divisor,
nlz_bits_P_divisor,
nlz_bits_diff		:INT_2W_S;

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
	Multi_Int_OVERFLOW_ERROR:= TRUE;
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
    i:= Multi_X48_max;
	while (i >= 0) do
		begin
		dividend.M_Value[i]:= P_dividend.M_Value[i];
		T:= P_divisor.M_Value[i];
		divisor.M_Value[i]:= T;
		if	(T <> 0) then Inc(z);
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
	if	(z = 1) then
		begin
		P_remainder:= 0;
		P_quotient:= 0;
		k:= 0;
		i:= Multi_X4_max;
		while (i >= 0) do
			begin
			P_quotient.M_Value[i]:= (((k * INT_1W_U_MAXINT_1) + dividend.M_Value[i]) div divisor.M_Value[0]);
			k:= (((k * Multi_X4_max) + dividend.M_Value[i]) - (P_quotient.M_Value[i] * divisor.M_Value[0]));
			Dec(i);
			end;
		P_remainder.M_Value[0]:= k;
		goto 9000;
		end;

	quotient:= ZERO;
	P_remainder:= ZERO;
	quotient_factor:= 1;

	{ Round 0 }
	nlz_bits_dividend:= nlz_MultiBits_X48(dividend);
	nlz_bits_divisor:= nlz_MultiBits_X48(divisor);
	nlz_bits_P_divisor:= nlz_bits_divisor;
	nlz_bits_diff:= (nlz_bits_divisor - nlz_bits_dividend - 1);

	if	(nlz_bits_diff > 0) then
		begin
		ShiftUp_MultiBits_Multi_Int_X48(divisor, nlz_bits_diff);
		ShiftUp_MultiBits_Multi_Int_X48(quotient_factor, nlz_bits_diff);
		end
	else nlz_bits_diff:= 0;

	{ Round X }
	repeat
	1000:
		prev_dividend:= dividend;
		dividend:= (dividend - divisor);
		if (dividend > ZERO) then
			begin
			quotient:= (quotient + quotient_factor);
			goto 1000;
			end;
		if (dividend = ZERO) then
			quotient:= (quotient + quotient_factor);
		if (dividend < ZERO) then
			dividend:= prev_dividend;

		nlz_bits_divisor:= nlz_MultiBits_X48(divisor);
		if (nlz_bits_divisor < nlz_bits_P_divisor) then
			begin
			nlz_bits_dividend:= nlz_MultiBits_X48(dividend);
			nlz_bits_diff:= (nlz_bits_dividend - nlz_bits_divisor + 1);

			if ((nlz_bits_divisor + nlz_bits_diff) > nlz_bits_P_divisor) then
				nlz_bits_diff:= (nlz_bits_P_divisor - nlz_bits_divisor);

			ShiftDown_MultiBits_Multi_Int_X48(divisor, nlz_bits_diff);
			ShiftDown_MultiBits_Multi_Int_X48(quotient_factor, nlz_bits_diff);
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
class operator Multi_Int_X48.intdivide(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var
Remainder,
Quotient	:Multi_Int_X48;
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
		Raise EIntOverflow.create('Overflow on divide');
		end;
	exit;
	end;

// same values as last time

if	(X48_Last_Divisor = v2)
and	(X48_Last_Dividend = v1)
then
	Result:= X48_Last_Quotient
else	// different values than last time
	begin
	intdivide_Shift_And_Sub_X48(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X48_Last_Divisor:= v2;
	X48_Last_Dividend:= v1;
	X48_Last_Quotient:= Quotient;
	X48_Last_Remainder:= Remainder;

	Result:= Quotient;

	if	(Remainder.Overflow_flag or Quotient.Overflow_flag)
	then
		begin
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on divide');
			end;
		end;
	end;

end;


(******************************************)
class operator Multi_Int_X48.modulus(const v1,v2:Multi_Int_X48):Multi_Int_X48;
var
Remainder,
Quotient	:Multi_Int_X48;
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
		Raise EIntOverflow.create('Overflow on modulus');
		end;
	exit;
	end;

// same values as last time

if	(X48_Last_Divisor = v2)
and	(X48_Last_Dividend = v1)
then
	Result:= X48_Last_Remainder
else	// different values than last time
	begin
	intdivide_Shift_And_Sub_X48(v1,v2,Quotient,Remainder);
{
	if	(v1.Negative_flag <> v2.Negative_flag)
	then Quotient.Negative_flag:= TRUE
	else if	(v2.Negative_flag)
	then Remainder.Negative_flag:= TRUE;
}
	X48_Last_Divisor:= v2;
	X48_Last_Dividend:= v1;
	X48_Last_Quotient:= Quotient;
	X48_Last_Remainder:= Remainder;

	Result:= Remainder;

	if	(Remainder.Overflow_flag or Quotient.Overflow_flag)
	then
		begin
		if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
			begin
			Raise EIntOverflow.create('Overflow on divide');
			end;
		end;
	end;
end;


{
******************************************
Multi_Init_Initialisation
******************************************
}

procedure Multi_Init_Initialisation;
var	i:Multi_int32u;
begin
Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
Multi_Int_OVERFLOW_ERROR:= FALSE;

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

X48_Last_Divisor:= 0;
X48_Last_Dividend:= 0;
X48_Last_Quotient:= 0;
X48_Last_Remainder:= 0;

Multi_Int_X2_MAXINT:= 0;
i:=0;
while (i <= Multi_X2_max) do
	begin
	Multi_Int_X2_MAXINT.M_Value[i]:= INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X3_MAXINT:= 0;
i:=0;
while (i <= Multi_X3_max) do
	begin
	Multi_Int_X3_MAXINT.M_Value[i]:= INT_1W_U_MAXINT;
	Inc(i);
	end;

Multi_Int_X4_MAXINT:= 0;
i:=0;
while (i <= Multi_X4_max) do
	begin
	Multi_Int_X4_MAXINT.M_Value[i]:= INT_1W_U_MAXINT;
	Inc(i);
	end;

if (Multi_X48_max < 1) then
	begin
	if Multi_Int_RAISE_EXCEPTIONS_ENABLED then
		begin
		Raise EIntOverflow.create('Multi_X48_max value must be > 0');
		end;
	writeln('Multi_Int Unit: Multi_X48_max defined value must be > 0');
	halt(1);
	end;

Multi_Int_X48_MAXINT:= 0;
i:=0;
while (i <= Multi_X48_max) do
	begin
	Multi_Int_X48_MAXINT.M_Value[i]:= INT_1W_U_MAXINT;
	Inc(i);
	end;

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


