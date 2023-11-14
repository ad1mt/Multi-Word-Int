const

(*
Notes about X48_max
X48_max is the number of half-words (minus 1) in the Multi-word integer type named Multi_Int_X48,
using zero-base, therefore 1 means 2.
The value must be 1 or greater (i.e. 2 half-words minimum), but 
there is no point in having less than 7, because the type named Multi_Int_X4 uses 7.
The number is half-words, so if you specify 127 that is 128 half-words, which equals
64 words, which equals 512 bits.
*)
	X48_max		= 127;

(*
X48_max is the only thing you should change in here.
Do not change anything below.
*)

	X48_max_x2	= (((X48_max+1)*2)-1);
	X48_size	= X48_max + 1;

const
	INT8_MAXINT		= 127;
	INT8_MAXINT_1	= 128;
	INT8U_MAXINT	= 255;
	INT8U_MAXINT_1	= 256;
	INT16_MAXINT	= 32767;
	INT16_MAXINT_1	= 32768;
	INT16U_MAXINT	= 65535;
	INT16U_MAXINT_1 = 65536;
	INT32_MAXINT	= 2147483647;
	INT32_MAXINT_1	= 2147483648;
	INT32U_MAXINT	= 4294967295;
	INT32U_MAXINT_1	= 4294967296;
	INT64_MAXINT	= 9223372036854775807;
	INT64_MAXINT_1	= 9223372036854775808;
	INT64U_MAXINT	= 18446744073709551615;
	INT64U_MAXINT_1 = 18446744073709551616;

type
	int8u		= byte;
	int8		= shortint;
	int16		= smallint;
	int16u		= word;
	int32		= longint;
	int32u		= longword;
	int64u		= QWord;
(*	int64		= int64 *)

const

(* Do not change these values *)

	X2_max		= 3;
	X2_max_x2	= 7;
	X2_size		= X2_max + 1;

	X3_max		= 5;
	X3_max_x2	= 11;
	X3_size		= X3_max + 1;

	X4_max		= 7;
	X4_max_x2	= 15;
	X4_size		= X4_max + 1;

{$ifdef 32bit}
const
	INT_1W_SIZE		= 16;
	INT_2W_SIZE		= 32;

	INT_1W_S_MAXINT		= INT16_MAXINT;
	INT_1W_S_MAXINT_1	= INT16_MAXINT_1;
	INT_1W_U_MAXINT		= INT16U_MAXINT;
	INT_1W_U_MAXINT_1	= INT16U_MAXINT_1;

	INT_2W_S_MAXINT		= INT32_MAXINT;
	INT_2W_S_MAXINT_1	= INT32_MAXINT_1;
	INT_2W_U_MAXINT		= INT32U_MAXINT;
	INT_2W_U_MAXINT_1	= INT32U_MAXINT_1;

type

	INT_1W_S		= int16;
	INT_1W_U		= int16u;
	INT_2W_S		= int32;
	INT_2W_U		= int32u;

{$endif} // 32-bit

{$ifdef 64bit}
const
	INT_1W_SIZE		= 32;
	INT_2W_SIZE		= 64;

	INT_1W_S_MAXINT		= INT32_MAXINT;
	INT_1W_S_MAXINT_1	= INT32_MAXINT_1;
	INT_1W_U_MAXINT		= INT32U_MAXINT;
	INT_1W_U_MAXINT_1	= INT32U_MAXINT_1;

	INT_2W_S_MAXINT		= INT64_MAXINT;
	INT_2W_S_MAXINT_1	= INT64_MAXINT_1;
	INT_2W_U_MAXINT		= INT64U_MAXINT;
	INT_2W_U_MAXINT_1	= INT64U_MAXINT_1;

type

	INT_1W_S		= int32;
	INT_1W_U		= int32u;
	INT_2W_S		= int64;
	INT_2W_U		= int64u;

{$endif} // 64-bit

type

T_Leading_Zeros	=	(Keep_Leading_Zeros, Trim_Leading_Zeros);

(********************************************************)
// UBool type gets broken if separated into it own unit!
(********************************************************)

UBool			= 	(UBool_UNDEF,UBool_FALSE,UBool_TRUE);
T_UBool			=	record
					private
						B_Value		:UBool;
					public
						procedure	Init(v:UBool); inline;
						function	ToStr:string; inline;
						class operator implicit(v:boolean):T_UBool; inline;
						class operator implicit(v:T_UBool):Boolean; inline;
						class operator implicit(v:UBool):T_UBool; inline;
						class operator implicit(v:T_UBool):UBool; inline;
						class operator equal(v1,v2:T_UBool):Boolean; inline;
						class operator notequal(v1,v2:T_UBool):Boolean; inline;
					end;

Multi_Int_X2	=	record
					private
						M_Value			:array[0..X2_max] of INT_1W_U;
						Negative		:T_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Leading_Zeros=Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X2; inline;
                        function Odd:boolean; inline;
                        function Even:boolean; inline;
                        function Overflow:boolean; inline;
                        function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X2; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X2):int8u; inline;
						class operator implicit(const v1:Multi_Int_X2):int8; inline;
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
						M_Value			:array[0..X3_max] of INT_1W_U;
						Negative		:T_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Leading_Zeros=Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X3; inline;
                        function Odd:boolean; inline;
                        function Even:boolean; inline;
                        function Overflow:boolean; inline;
                        function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X3; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X3):int8u; inline;
						class operator implicit(const v1:Multi_Int_X3):int8; inline;
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
						M_Value			:array[0..X4_max] of INT_1W_U;
						Negative		:T_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Leading_Zeros=Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X4; inline;
                        function Odd:boolean; inline;
                        function Even:boolean; inline;
                        function Overflow:boolean; inline;
                        function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(Var v1:Multi_Int_X4; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X4):int8u; inline;
						class operator implicit(const v1:Multi_Int_X4):int8; inline;
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
						M_Value			:array[0..X48_max] of INT_1W_U;
						Negative		:T_UBool;
						Overflow_flag	:boolean;
						Defined_flag	:boolean;
					public
						procedure Init(const v1:string); inline;
						function ToStr:string; inline;
						function ToHex(const LZ:T_Leading_Zeros=Trim_Leading_Zeros):string; inline;
						function FromHex(const v1:string):Multi_Int_X48; inline;
                        function Odd:boolean; inline;
                        function Even:boolean; inline;
                        function Overflow:boolean; inline;
                        function Defined:boolean; inline;
						procedure ShiftUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure ShiftDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure RotateUp_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						procedure RotateDown_MultiBits(var v1:Multi_Int_X48; NBits:INT_1W_U); inline;
						class operator implicit(const v1:Multi_Int_X48):int8u; inline;
						class operator implicit(const v1:Multi_Int_X48):int8; inline;
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
						class operator xor(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator multiply(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator intdivide(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator modulus(const v1,v2:Multi_Int_X48):Multi_Int_X48; inline;
						class operator -(const v1:Multi_Int_X48):Multi_Int_X48; inline;
                        class operator >=(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator <=(const v1,v2:Multi_Int_X48):Boolean; inline;
						class operator **(const v1:Multi_Int_X48; const P:INT_2W_S):Multi_Int_X48; inline;
					end;

var
OVERFLOW_ERROR			:boolean;
Multi_Int_X2_MAXINT		:Multi_Int_X2;
Multi_Int_X3_MAXINT		:Multi_Int_X3;
Multi_Int_X4_MAXINT		:Multi_Int_X4;
Multi_Int_X48_MAXINT	:Multi_Int_X48;

function Odd(const v1:Multi_Int_X48):boolean; overload;
function Odd(const v1:Multi_Int_X4):boolean; overload;
function Odd(const v1:Multi_Int_X3):boolean; overload;
function Odd(const v1:Multi_Int_X2):boolean; overload;

function Even(const v1:Multi_Int_X48):boolean; overload;
function Even(const v1:Multi_Int_X4):boolean; overload;
function Even(const v1:Multi_Int_X3):boolean; overload;
function Even(const v1:Multi_Int_X2):boolean; overload;

procedure SqRoot(const v1:Multi_Int_X48;var VR,VREM:Multi_Int_X48); overload;
procedure SqRoot(const v1:Multi_Int_X4;var VR,VREM:Multi_Int_X4); overload;
procedure SqRoot(const v1:Multi_Int_X3;var VR,VREM:Multi_Int_X3); overload;
procedure SqRoot(const v1:Multi_Int_X2;var VR,VREM:Multi_Int_X2); overload;

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


