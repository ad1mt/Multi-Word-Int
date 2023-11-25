UNIT UBool;

{$MODE DELPHI}

{$MODESWITCH NESTEDCOMMENTS+}

	
INTERFACE

uses	sysutils
,		strutils
,		strings
;


type

T_Multi_Leading_Zeros	=	(Multi_Keep_Leading_Zeros, Multi_Trim_Leading_Zeros);

(********************************************************)
// UBool type gets broken if separated into it own unit!
(********************************************************)

Multi_UBool_Values		= 	(Multi_UBool_UNDEF,Multi_UBool_FALSE,Multi_UBool_TRUE);
T_Multi_UBool	=	record
					private
						B_Value		:Multi_UBool_Values;
					public
						procedure	Init(v:Multi_UBool_Values); inline;
						function	ToStr:string; inline;
						class operator implicit(v:boolean):T_Multi_UBool; inline;
						class operator implicit(v:T_Multi_UBool):Boolean; inline;
						class operator implicit(v:Multi_UBool_Values):T_Multi_UBool; inline;
						class operator implicit(v:T_Multi_UBool):Multi_UBool_Values; inline;
						class operator equal(v1,v2:T_Multi_UBool):Boolean; inline;
						class operator notequal(v1,v2:T_Multi_UBool):Boolean; inline;
					end;


IMPLEMENTATION

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

class operator T_Multi_UBool.implicit(v:Multi_UBool_Values):T_Multi_UBool;
begin
Result.B_Value:= v;
end;

class operator T_Multi_UBool.implicit(v:T_Multi_UBool):Multi_UBool_Values;
begin
Result:= v.B_Value;
end;

class operator T_Multi_UBool.implicit(v:Boolean):T_Multi_UBool;
begin
if v then Result.B_Value:= Multi_UBool_TRUE
else Result.B_Value:= Multi_UBool_FALSE;
end;

class operator T_Multi_UBool.implicit(v:T_Multi_UBool):Boolean;
begin
if (v.B_Value = Multi_UBool_TRUE) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.equal(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value = v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

class operator T_Multi_UBool.notequal(v1,v2:T_Multi_UBool):Boolean;
begin
if (v1.B_Value <> v2.B_Value) then Result:= TRUE
else Result:= FALSE;
end;

begin
end.

