{$MODE OBJFPC}
{$MODESWITCH ADVANCEDRECORDS}
{$LONGSTRINGS ON}
{$MODESWITCH NESTEDCOMMENTS+}
{$warn 6058 off}
{$warn 5025 off}

program unit_test_1_v27_X;
uses	sysutils
,		strutils
,		strings
,		math
,		Multi_Int
;

{$IFDEF CPU64}
	{$DEFINE 64BIT}
{$ELSE}
	{$IFDEF CPU32}
  		{$DEFINE 32BIT}
	{$ENDIF}
{$ENDIF}

const

// You need to comment/uncomment the following lines to specify
// which multi int type you wish to test.
// Only one type can be tested in one instance, but you can
// create multiple executables, one for each type.

// {$define Multi_Int_X2}
// {$define Multi_Int_X3}
// {$define Multi_Int_X4}
{$define Multi_Int_XV}

// You should not need to change anything below this line.

TEST_FAIL_EXPECTED = TRUE;

MULTI_SINGLE_TYPE_MAXVAL	= '340000000000000000000000000000000000000';
// MULTI_REAL_TYPE_MAXVAL		= '99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
MULTI_DOUBLE_TYPE_MAXVAL	= '17000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

type

{$ifdef Multi_Int_X2}
	big_int	= Multi_Int_X2;

{$else}
{$ifdef Multi_Int_X3}
	big_int	= Multi_Int_X3;

{$else}
{$ifdef Multi_Int_X4}
	big_int	= Multi_Int_X4;

{$else}
{$ifdef Multi_Int_XV}
	big_int	= Multi_Int_XV;

{$else}
	{$fatal One of Multi_Int_XV Multi_Int_X2 Multi_Int_X3, or Multi_Int_X4 must be defined}

{$endif} {$endif} {$endif} {$endif}

hex_or_dec	= (bin_str,hex_str,dec_str);

var
T,N,P,R,
MULTI_MAXINT		:big_int;
XV_SIZE,
Multi_Int_NBITS		:int32;
got_exception		:boolean;
MULTI_MAXINT_STR,
MULTI_MAXINT_HEX,
MULTI_MAXINT_BIN,
MAXINT_OVER_STR,
MAXINT_OVER_HEX,
MAXINT_OVER_BIN,
NS,RS
					:ansistring;

procedure reset_Last_Divisor;
begin
{$ifdef Multi_Int_X2}
	Multi_Int_Reset_X2_Last_Divisor;
{$else}
{$ifdef Multi_Int_X3}
	Multi_Int_Reset_X3_Last_Divisor;
{$else}
{$ifdef Multi_Int_X4}
	Multi_Int_Reset_X4_Last_Divisor;
{$else}
{$ifdef Multi_Int_XV}
	Multi_Int_Reset_XV_Last_Divisor;
{$else}
	{$fatal One of Multi_Int_XV Multi_Int_X2 Multi_Int_X3, or Multi_Int_X4 must be defined}
{$endif} {$endif} {$endif} {$endif}
end;

(*---------------------------------*)
// test_signed_operators
(*---------------------------------*)
procedure test_signed_operators(const v1,v2:big_int);
var
Ub,Vb,Wb,Rb		:big_int;
Ui,Vi,Wi		:MULTI_INT_2W_S;
Us,Vs,op		:ansistring;
got_exception	:boolean;
FAILED			:T_Multi_UBool;

begin
writeln('--------------------------------');
writeln('test_signed_operators starting ',V1.tostr,' ',V2.tostr);
writeln('--------------------------------');

Ub:= v1;
Vb:= v2;

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
FAILED:= FALSE;

if	(v1 <= MULTI_INT_2W_S_MAXINT)
and	(v2 <= MULTI_INT_2W_S_MAXINT)
and	(v1 >= (-MULTI_INT_2W_S_MAXINT))
and	(v2 >= (-MULTI_INT_2W_S_MAXINT))
then
	begin

	Ui:= v1;
	Vi:= v2;

	Wi:= (Ui + Vi);
	Wb:= (Ub + Vb);
	op:= '+';
	if (Wb <> Wi)
	or Multi_Int_ERROR
	then
		begin
		writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
		FAILED:= TRUE;
		end
	else
		writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);

	Multi_Int_ERROR:= FALSE;

	Wi:= (Ui - Vi);
	Wb:= (Ub - Vb);
	op:= '-';
	if (Wb <> Wi)
	or Multi_Int_ERROR
	then
		begin
		writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
		FAILED:= TRUE;
		end
	else
		writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);

	Multi_Int_ERROR:= FALSE;

	Wb:= (Ub * Vb);
	op:= '*';
	if	(Abs(Wb) < MULTI_INT_2W_S_MAXINT)
	or Multi_Int_ERROR
	then
		begin
		Wi:= (Ui * Vi);
		if (Wb <> Wi) then
			begin
			FAILED:= TRUE;
			writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
		end;

	Multi_Int_ERROR:= FALSE;

	if	(Vb <> 0) then
		begin
		reset_Last_Divisor;
		Wi:= (Ui div Vi);
		Wb:= (Ub div Vb);
		op:= 'div';
		if (Wb <> Wi)
		or Multi_Int_ERROR
		then
			begin
			FAILED:= TRUE;
			writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
		end
	else
		begin
		reset_Last_Divisor;
		Wb:= (Ub div Vb);
		op:= 'div';
		if	(not Wb.overflow) then
			begin
			FAILED:= TRUE;
			writeln('FAILED! Expected Multi_Int_OVERFLOW_ERROR ',Ub.tostr,' ',op,' ',Vb.tostr);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr);
		got_exception:= FALSE;
		Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
		try	Wb:= (Ub div Vb)
			except got_exception:= TRUE;
			end;
		Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
		if	(not got_exception) then
			begin
			FAILED:= TRUE;
	    	writeln('FAILED! Expected Multi_Int OVERFLOW exception ',Ub.tostr,' ',op,' ',Vb.tostr);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr);
		Multi_Int_ERROR:= FALSE;
		end;

	Multi_Int_ERROR:= FALSE;

	if	(Vb <> 0) then
		begin
		reset_Last_Divisor;
		Wi:= (Ui mod Vi);
		Wb:= (Ub mod Vb);
		op:= 'mod';
		if (Wb <> Wi)
		or Multi_Int_ERROR
		then
			begin
			FAILED:= TRUE;
			writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
		end
	else
		begin
		reset_Last_Divisor;
		Wb:= (Ub mod Vb);
		op:= 'mod';
		if	(not Wb.overflow) then
			begin
			FAILED:= TRUE;
			writeln('FAILED! Expected Multi_Int_OVERFLOW_ERROR ',Ub.tostr,' ',op,' ',Vb.tostr);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr);
		got_exception:= FALSE;
		Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
		try	Wb:= (Ub mod Vb)
			except got_exception:= TRUE;
			end;
		Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
		if	(not got_exception) then
			begin
			FAILED:= TRUE;
	    	writeln('FAILED! Expected Multi_Int OVERFLOW exception ',Ub.tostr,' ',op,' ',Vb.tostr);
			end
		else
			writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr);
		Multi_Int_ERROR:= FALSE;
		end;

	Multi_Int_ERROR:= FALSE;

	if	(Vb >= 0) then
		begin
		op:= '**';
		got_exception:= FALSE;
		try Wi:= (Ui ** Vi)
			except got_exception:= TRUE;
			end;
        if	(not got_exception) then
			begin
			Wb:= (Ub ** Vb);
			if	(Wb <> Wi)
			or Multi_Int_ERROR
			then
				begin
				FAILED:= TRUE;
				writeln('FAILED! (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
				end
			else
				writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr,') = ',Wb.tostr,'   (',Ui,' ',op,' ',Vi,') = ',Wi);
			Multi_Int_ERROR:= FALSE;
			end
		else
			begin
			op:= '**';
			Wb:= (Ub ** Vb);
			if	(Wb.overflow) then
				begin
				got_exception:= FALSE;
				Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
				try
					Wb:= (Ub ** Vb);
					except got_exception:= TRUE;
					end;
				Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
				if	(not got_exception) then
					begin
					FAILED:= TRUE;
			    	writeln('FAILED! Expected Multi_Int OVERFLOW exception ',Ub.tostr,' ',op,' ',Vb.tostr);
					end
				else
					writeln('Ok (',Ub.tostr,' ',op,' ',Vb.tostr);
            {	// what is this doing?
				end
			else if	(Wb <> Rb) then
				begin
				FAILED:= TRUE;
				writeln('FAILED! ',Ub.tostr,' ',op,' ',Vb.tostr,' = ',Wb.tostr);
			}
				Multi_Int_ERROR:= FALSE;
				end;
			end;
		end;

	end;

Multi_Int_ERROR:= FALSE;

if	(Ub > 0) then
	begin
	op:= 'sqroot';
	sqroot(Ub,Wb,Rb);
	if	(Wb.overflow)
	or Multi_Int_ERROR
	then
		writeln('FAILED! ',op,'(',Wb.tostr,') overflow = ',Wb.overflow)
	else
		if	(Ub <> ((Wb * Wb) + Rb))
		or	Multi_Int_ERROR
		then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr,' rem ',Vb.tostr);
			end
		else
			writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr,' rem ',Vb.tostr);
    end;

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
Multi_Int_ERROR:= FALSE;

Wb:= Ub;
Inc(Wb);
op:= 'Inc';
if	(Wb.overflow) then
	begin
	if	(Ub = MULTI_MAXINT) then
		writeln('Expected & got overflow ',op,'(',Ub.tostr,')')
	else
		writeln('DUBIOUS! ',op,'(',Ub.tostr,') overflow = ',Ub.overflow);
	end
else
	begin
	Rb:= (Wb - Ub);
	if (Rb <> 1)
	or Multi_Int_ERROR
	then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end
	else
		if	(Ub.overflow) then
			writeln('DUBIOUS! ',op,'(',Wb.tostr,') overflow = ',Ub.overflow)
		else
			writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end;

Multi_Int_ERROR:= FALSE;

Wb:= Vb;
Inc(Wb);
op:= 'Inc';
if	(Wb.overflow) then
	begin
	if	(Vb = MULTI_MAXINT) then
		writeln('Expected & got overflow ',op,'(',Vb.tostr,')')
	else
		writeln('DUBIOUS! ',op,'(',Vb.tostr,') overflow = ',Vb.overflow);
	end
else
	begin
	if ((Wb - Vb) <> 1)
	or Multi_Int_ERROR
	then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Vb.tostr,') = ',Wb.tostr);
		end
	else
		if	(Ub.overflow) then
			writeln('DUBIOUS! ',op,'(',Wb.tostr,') overflow = ',Ub.overflow)
		else
			writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end;

Multi_Int_ERROR:= FALSE;

Wb:= Ub;
Dec(Wb);
op:= 'Dec';
if	(Ub.overflow) then
	begin
	if	(Ub = MULTI_MAXINT) then
		writeln('Expected & got overflow ',op,'(',Ub.tostr,')')
	else
		writeln('DUBIOUS! ',op,'(',Ub.tostr,') overflow = ',Ub.overflow);
	end
else
	begin
	if ((Ub - Wb) <> 1)
	or Multi_Int_ERROR
	then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end
	else
		if	(Ub.overflow) then
			writeln('DUBIOUS! ',op,'(',Wb.tostr,') overflow = ',Ub.overflow)
		else
			writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end;

Multi_Int_ERROR:= FALSE;

Wb:= Vb;
Dec(Wb);
op:= 'Dec';
if	(Vb.overflow) then
	begin
	if	(Vb = MULTI_MAXINT) then
		writeln('Expected & got overflow ',op,'(',Vb.tostr,')')
	else
		writeln('DUBIOUS! ',op,'(',Vb.tostr,') overflow = ',Vb.overflow);
	end
else
	begin
	if ((Vb - Wb) <> 1)
	or Multi_Int_ERROR
	then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Vb.tostr,') = ',Wb.tostr);
		end
	else
		if	(Ub.overflow) then
			writeln('DUBIOUS! ',op,'(',Wb.tostr,') overflow = ',Ub.overflow)
		else
			writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);
		end;

Multi_Int_ERROR:= FALSE;

Vb:= (-Ub);
Wb:= (-Vb);
op:= 'u-minus';
if	(Wb <> Ub)
or Multi_Int_ERROR
then
	begin
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

op:= 'Abs';
if	(Abs(Vb) <> Abs(Ub))
or Multi_Int_ERROR
then
	begin
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,'(',Ub.tostr,') = ',Vb.tostr);
	end;
if	(Abs(Wb) <> Abs(Vb))
or Multi_Int_ERROR
then
	begin
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,'(',Wb.tostr,') = ',Vb.tostr);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;

Multi_Int_ERROR:= FALSE;

Ub:= v1;
Vb:= v2;

op:= 'tostr';
Us:= Ub.tostr;
Wb:= Us;
if	(Multi_Int_ERROR) then
	writeln('Multi_Int_ERROR ',op,' ',Ub.tostr);
if	(Ub <> Wb)
or Multi_Int_ERROR
then
	begin
	op:= 'tostr';
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,' Ub=',Ub.tostr,' Us=',Us,' Wb=',Wb.tostr);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

Multi_Int_ERROR:= FALSE;

op:= 'tostr';
Vs:= Vb.tostr;
Wb:= Vs;
if	(Multi_Int_ERROR) then
	writeln('Multi_Int_ERROR ',op,' ',Vb.tostr);
if	(Vb <> Wb)
or Multi_Int_ERROR
then
	begin
	op:= 'tostr';
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,' Vb=',Vb.tostr,' Vs=',Vs,' Wb=',Wb.tostr);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;

Multi_Int_ERROR:= FALSE;

Ub:= v1;
Vb:= v2;

op:= 'tohex';
Us:= Ub.tohex;
FromHex(Us,Wb);
if	(Multi_Int_ERROR) then
	writeln('Multi_Int_ERROR ',op,' ',Ub.tostr);
if	(Ub <> Wb)
or Multi_Int_ERROR
then
	begin
	op:= 'tohex';
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,' Ub=',Ub.tohex,' Us=',Us,' Wb=',Wb.tohex);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

Multi_Int_ERROR:= FALSE;

op:= 'tohex';
Vs:= Vb.tohex;
fromHex(Vs,Wb);
if	(Multi_Int_ERROR) then
	writeln('Multi_Int_ERROR ',op,' ',Vb.tostr);
if	(Vb <> Wb)
or Multi_Int_ERROR
then
	begin
	op:= 'tohex';
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',op,' Vb=',Vb.tohex,' Vs=',Vs,' Wb=',Wb.tohex);
	end
else
	writeln('Ok ',op,'(',Ub.tostr,') = ',Wb.tostr);

if	FAILED then
	writeln('FAILED one or more tests!')
else if (FAILED = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;
end;


(*---------------------------------*)
// test_floats
(*---------------------------------*)
procedure test_floats(const v1:big_int);
var
Ub,Wb,Tb		:big_int;
n				:MULTI_INT_2W_S;
Ur				:real;
Ud				:double;
Uq				:single;
Us,Ws,Ts,op		:ansistring;
FAILED			:T_Multi_UBool;

begin
writeln('--------------------------------');
writeln('Test_floats starting ',V1.tostr);
writeln('--------------------------------');

Multi_Int_ERROR:= FALSE;

failed:= Multi_UBool_FALSE;

Ub:= v1;
if	(Abs(Ub) <= (MULTI_SINGLE_TYPE_MAXVAL)) then
	begin
	Tb:= MULTI_SINGLE_TYPE_MAXVAL;
	op:= 'to single';
	Uq:= Ub;
	if	(Multi_Int_ERROR) then
		begin
		Tb:= MULTI_SINGLE_TYPE_MAXVAL;
		if	(Abs(Ub) < Abs(Tb)) then
			begin
			failed:= Multi_UBool_UNDEF;
			writeln('FAILED! Unexpected Multi_Int_ERROR ',op,' ',Ub.tostr);
			end
		end
	else
		begin
		Wb:= Uq;
		if	(Multi_Int_ERROR) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! Multi_Int_ERROR ',Ub.tostr,' ',op,' ',Wb.tostr);
			end;
		Us:= Ub.tostr;
		Ws:= Wb.tostr;
		if	(length(Us) <> length(Ws))
		or	(AnsiLeftStr(Us, (MULTI_SINGLE_TYPE_PRECISION_DIGITS - 1)) <> AnsiLeftStr(Ws, (MULTI_SINGLE_TYPE_PRECISION_DIGITS - 1)))
		then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,' ',Us,' = ',Ws);
			end;
		end;
	end;

Ub:= v1;
if	(Abs(Ub) <= (MULTI_SINGLE_TYPE_MAXVAL)) then
	begin
	Tb:= MULTI_DOUBLE_TYPE_MAXVAL;
	op:= 'to double';
	Ud:= Ub;
	if	(Multi_Int_ERROR) then
		begin
		Tb:= MULTI_SINGLE_TYPE_MAXVAL;
		if	(Abs(Ub) < Abs(Tb)) then
			begin
			failed:= Multi_UBool_UNDEF;
			writeln('FAILED! Unexpected Multi_Int_ERROR ',op,' ',Ub.tostr);
			end
		end
	else
		begin
		Wb:= Ud;
		if	(Multi_Int_ERROR) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! Multi_Int_ERROR ',Ub.tostr,' ',op,' ',Wb.tostr);
			end;
		Us:= Ub.tostr;
		Ws:= Wb.tostr;
		if	(length(Us) <> length(Ws))
		or	(AnsiLeftStr(Us, (MULTI_DOUBLE_TYPE_PRECISION_DIGITS - 1)) <> AnsiLeftStr(Ws, (MULTI_DOUBLE_TYPE_PRECISION_DIGITS - 1)))
		then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,' ',Us,' = ',Ws);
			end;
		end;
	end;


if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test_strings
(*---------------------------------*)
procedure test_strings(const v1:ansistring; const str_type:hex_or_dec; const fail_expected:boolean=FALSE);
var
Ub,Vb,Wb		:big_int;
Vs,Ws,Es,
op				:ansistring;
got_exception	:boolean;
FAILED			:T_Multi_UBool;

begin
writeln('--------------------------------');
writeln('Test_strings starting "',V1,'"');
writeln('--------------------------------');
if	(str_type = bin_str) then write('Binary String Test');
if	(str_type = hex_str) then write('Heximal String Test');
if	(str_type = dec_str) then write('Decimal String Test');
writeln;

writeln('--------------------------------');

got_exception:= FALSE;
Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
failed:= Multi_UBool_UNDEF;

Vs:= v1;
if	(str_type = dec_str) then
	begin
	op:= 'fromstr';
	Ub:= Vs;

	if	(fail_expected) then
		if (not Multi_Int_ERROR) then
			begin
			failed:= Multi_UBool_UNDEF;
			end
		else
			begin
			failed:= Multi_UBool_FALSE;
			end
	else
		if	(Multi_Int_ERROR) then
			writeln('FAILED! Multi_Int_ERROR ',op)
		else
			begin
			Ws:= Ub.tostr;
			if	(Vs <> Ws)
			and	(big_int(Vs) <> big_int(Ws))
			then
				begin
				failed:= Multi_UBool_TRUE;
				writeln('FAILED! ',op,' Vs=',Vs,' Ws=',Ws);
				end
			else failed:= Multi_UBool_FALSE;
			end;
	end;

Multi_Int_ERROR:= FALSE;

(* test exception *)
if	(str_type = dec_str)
and	(fail_expected)
then
	begin
	got_exception:= FALSE;
	op:= 'fromstr';
	got_exception:= FALSE;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
	try	Ub:= Vs
		except
		on E:Exception do
        	begin
			got_exception:= TRUE;
            Es:= E.message;
			end;
		end;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
	if	(not got_exception) then
		begin
		failed:= Multi_UBool_UNDEF;
    	writeln('DUBIOUS! Expected Multi_Int ',Es,' exception ',op,' ',Vs);
		end
	else
		begin
		failed:= Multi_UBool_FALSE;
		end;
	end;

Multi_Int_ERROR:= FALSE;

if	(str_type = hex_str) then
	begin
	op:= 'fromhex';
	fromhex(Vs,Ub);

	if	(fail_expected) then
		if (not Multi_Int_ERROR) then
			begin
			failed:= Multi_UBool_UNDEF;
			writeln('DUBIOUS! Expected Multi_Int_ERROR ',op);
			end
		else failed:= Multi_UBool_FALSE
	else
		if	(Multi_Int_ERROR) then
			writeln('FAILED! Multi_Int_ERROR ',op)
		else
			begin
			Ws:= Ub.ToHex;
			if	(Vs <> Ws)
			and	(Vb.FromHex(Vs) <> Wb.FromHex(Ws))
			then
				begin
				failed:= Multi_UBool_TRUE;
				writeln('FAILED! ',op,' Vs=',Vs,' Ws=',Ws);
				end
			else failed:= Multi_UBool_FALSE;
			end;
	end;

Multi_Int_ERROR:= FALSE;

(* test exception *)
if	(str_type = hex_str)
and	(fail_expected)
then
	begin
	got_exception:= FALSE;
	op:= 'fromhex';
	got_exception:= FALSE;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
	try fromhex(Vs,Ub)
		except
		on E:Exception do
        	begin
			got_exception:= TRUE;
            Es:= E.message;
			end;
		end;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
	if	(not got_exception) then
		begin
		failed:= Multi_UBool_UNDEF;
    	writeln('DUBIOUS! Expected Multi_Int ',Es,' exception ',op,' ',Vs);
		end
	else
		begin
		failed:= Multi_UBool_FALSE;
		end;
	end;

Multi_Int_ERROR:= FALSE;

if	(str_type = bin_str) then
	begin
	op:= 'frombin';

	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
	frombin(Vs,Ub);
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;

	if	(fail_expected) then
		if (not Multi_Int_ERROR) then
			begin
			failed:= Multi_UBool_UNDEF;
			writeln('DUBIOUS! Expected Multi_Int_ERROR ',op);
			end
		else failed:= Multi_UBool_FALSE
	else
		if	(Multi_Int_ERROR) then
			writeln('FAILED! Multi_Int_ERROR ',op)
		else
			begin
			Ws:= Ub.Tobin;
			if	(Vs <> Ws)
			and	(Vb.Frombin(Vs) <> Wb.Frombin(Ws))
			then
				begin
				failed:= Multi_UBool_TRUE;
				writeln('FAILED! ',op,' Vs=',Vs,' Ws=',Ws);
				end
			else failed:= Multi_UBool_FALSE;
			end;
	end;

Multi_Int_ERROR:= FALSE;

(* test exception *)
if	(str_type = bin_str)
and	(fail_expected)
then
	begin
	got_exception:= FALSE;
	op:= 'frombin';
	got_exception:= FALSE;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
	try frombin(Vs,Ub)
		except
		on E:Exception do
        	begin
			got_exception:= TRUE;
            Es:= E.message;
			end;
		end;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
	if	(not got_exception) then
		begin
		failed:= Multi_UBool_UNDEF;
    	writeln('DUBIOUS! Expected Multi_Int ',Es,' exception ',op,' ',Vs);
		end
	else
		begin
		failed:= Multi_UBool_FALSE;
		end;
	end;

Multi_Int_ERROR:= FALSE;

if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test_power
(*---------------------------------*)
procedure test_power(const v1,v2,v3:big_int);
var
Ub,Vb,Wb,Rb		:big_int;
failed			:T_Multi_UBool;
op				:ansistring;

begin
writeln('--------------------------------');
writeln('Test_power starting ',V1.tostr,' ',V2.tostr,' ',V3.tostr);
writeln('--------------------------------');

Ub:= v1;
Vb:= v2;
Rb:= v3;

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
failed:= Multi_UBool_UNDEF;

op:= '**';
got_exception:= FALSE;
op:= 'power';
Wb:= (Ub ** Vb);
if	(Wb.overflow) then
	begin
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
	try	Wb:= (Ub ** Vb)
		except got_exception:= TRUE;
		end;
	Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
	if	(not got_exception) then
		begin
		failed:= Multi_UBool_TRUE;
    	writeln('FAILED! Expected Multi_Int OVERFLOW exception ',Ub.tostr,' ',op,' ',Vb.tostr);
		end;
	end
else if	(Wb <> Rb) then
	begin
	failed:= Multi_UBool_TRUE;
	writeln('FAILED! ',Ub.tostr,' ',op,' ',Vb.tostr,' = ',Wb.tostr);
	end
else failed:= Multi_UBool_FALSE;

if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test_dec
(*---------------------------------*)
procedure test_dec(const v1,v2:big_int);
var
Ub,Wb,Rb		:big_int;
failed			:T_Multi_UBool;
op				:ansistring;

begin
writeln('--------------------------------');
writeln('Test_dec starting ',V1.tostr,' ',V2.tostr);
writeln('--------------------------------');

Ub:= v1;
Rb:= v2;

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
failed:= Multi_UBool_UNDEF;

if	(Rb = 0) then
	begin
	Wb:= Ub;
	Dec(Wb);
	op:= 'Dec';
	if	(Wb.overflow) then
		begin
		if	(Ub = MULTI_MAXINT) then
			begin
			failed:= Multi_UBool_FALSE;
			writeln('Expected & got overflow ',op,'(',Ub.tostr,')');
			end
		else
			begin
			failed:= Multi_UBool_TRUE;
			writeln(op,'(',Ub.tostr,') overflow = ',Ub.overflow);
			end
		end
	else
		begin
		if ((Ub - Wb) <> 1) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
			end
		else if	(Ub.overflow) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln(op,'(',Wb.tostr,') overflow = ',Ub.overflow);
			end
		else failed:= Multi_UBool_FALSE;
		end;
	end;

if	(Rb <> 0) then
	begin
	Wb:= Ub;
	Dec(Wb);
	op:= 'Dec';
	if	(Wb.overflow) then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Ub.tostr,') overflow = ',Ub.overflow);
		end
	else
		begin
		if	(Wb <> Rb)
		or	((Ub - Wb) <> 1)
		then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
			end
		else failed:= Multi_UBool_FALSE;
		end;
	end;

if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test_inc
(*---------------------------------*)
procedure test_inc(const v1,v2:big_int);
var
Ub,Wb,Rb		:big_int;
failed			:T_Multi_UBool;
op				:ansistring;

begin
writeln('--------------------------------');
writeln('Test_inc starting ',V1.tostr,' ',V2.tostr);
writeln('--------------------------------');

Ub:= v1;
Rb:= v2;

Multi_Int_RAISE_EXCEPTIONS_ENABLED:= FALSE;
failed:= Multi_UBool_UNDEF;

if	(Rb = 0) then
	begin
	Wb:= Ub;
	Inc(Wb);
	op:= 'Inc';
	if	(Wb.overflow) then
		begin
		if	(Ub = MULTI_MAXINT) then
			begin
			failed:= Multi_UBool_FALSE;
			end
		else
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! Expected overflow on ',op,'(',Ub.tostr,') overflow = ',Ub.overflow);
			end
		end
	else
		begin
		if ((Wb - Ub) <> 1) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
			end
		else if	(Ub.overflow) then
			begin
			failed:= Multi_UBool_TRUE;
			writeln(op,'(',Wb.tostr,') overflow = ',Ub.overflow);
			end
		else failed:= Multi_UBool_FALSE;
		end;
	end;

if	(Rb <> 0) then
	begin
	Wb:= Ub;
	Inc(Wb);
	op:= 'Inc';
	if	(Wb.overflow) then
		begin
		failed:= Multi_UBool_TRUE;
		writeln('FAILED! ',op,'(',Ub.tostr,') overflow = ',Ub.overflow);
		end
	else
		begin
		if	(Wb <> Rb)
		or	((Wb - Ub) <> 1)
		then
			begin
			failed:= Multi_UBool_TRUE;
			writeln('FAILED! ',op,'(',Ub.tostr,') = ',Wb.tostr);
            end
		else failed:= Multi_UBool_FALSE;
		end;
	end;

if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// shift/mult/and/add/or test
(*---------------------------------*)
procedure shift_and_or_test;
var
Mb,Ab,Sb,Tb,Xb	:big_int;
N,C				:MULTI_INT_2W_S;
failed			:T_Multi_UBool;

begin
writeln('--------------------------------');
writeln('shift_and_or_test starting');
writeln('--------------------------------');

Multi_Int_ERROR:= FALSE;
failed:= FALSE;

Mb:= 1;
Sb:= 1;
Ab:= 1;

N:= (Multi_Int_NBITS - 1);

C:= 0;
repeat
	Sb:= (Sb << 1);
	Mb:= (Mb * 2);
	Ab:= (Ab + Ab);

	if	(Sb <> Mb) then
		begin
		writeln('FAILED A (Sb <> Mb) [',C,'] !');
		failed:= TRUE;
		end;

	if	(Sb <> Ab) then
		begin
		writeln('FAILED A (Sb <> Ab) [',C,'] !');
		failed:= TRUE;
		end;

	if	(Multi_Int_ERROR) then
		begin
		writeln('FAILED A (Multi_Int_ERROR) [',C,'] !');
		failed:= TRUE;
		end;

	if	(Mb.overflow) then
		begin
		writeln('FAILED A (Mb.overflow) [',C,'] !');
		failed:= TRUE;
		end;

	if	(Ab.overflow) then
		begin
		writeln('FAILED A (Ab.overflow) [',C,'] !');
		failed:= TRUE;
		end;

	Sb:= (Sb or 1);
	Mb:= (Mb + 1);
	Ab:= (Ab + 1);

	if	(Sb <> Mb) then
		begin
		writeln('FAILED B (Sb <> Mb) [',C,'] !');
		failed:= TRUE;
		end;
	if	(Sb <> Ab) then
		begin
		writeln('FAILED B (Sb <> Ab) [',C,'] !');
		failed:= TRUE;
		end;
	if	(Multi_Int_ERROR) then
		begin
		writeln('FAILED B (Multi_Int_ERROR) [',C,'] !');
		failed:= TRUE;
		end;
	if	(Mb.overflow) then
		begin
		writeln('FAILED B (Mb.overflow) [',C,'] !');
		failed:= TRUE;
		end;
	if	(Ab.overflow) then
		begin
		writeln('FAILED B (Ab.overflow) [',C,'] !');
		failed:= TRUE;
		end;

	Inc(C);
until	(C >= N)
or		(failed);

if	(Sb <> MULTI_MAXINT) then
	begin
	writeln('FAILED C1 !');
		failed:= TRUE;
	end;

if	(Ab <> Multi_MAXINT)
then begin writeln('FAILED C2 !'); failed:= TRUE; end;

if	(Mb <> Multi_MAXINT)
then begin writeln('FAILED C3 !'); failed:= TRUE; end;

Tb:= 1;
Tb:= (Tb << N);

C:= 0;
repeat
	Sb:= (Sb >> 1);
	Mb:= (Mb div 2);
	Xb:= (not Tb);
	Ab:= (Ab and Xb);
	Tb:= (Tb >> 1);
	if	(Sb <> Mb)
	or	(Sb <> Ab)
	or	(Multi_Int_ERROR)
	or	(Mb.overflow)
	or	(Ab.overflow)
	then begin writeln('FAILED D [',C,'] !'); failed:= TRUE; end;

	Inc(C);
until	(C >= N)
or		(failed = Multi_UBool_TRUE);

if	(Sb <> 1)
or	(Ab <> 1)
or	(Mb <> 1)
then begin writeln('FAILED E !'); failed:= TRUE; end;

if	(failed = Multi_UBool_TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!')
else
	writeln('Ok');

writeln;

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test X4 to XV
(*---------------------------------*)
procedure test_X4_to_XV;
var
failed	:T_Multi_UBool;
v2,w2	:Multi_Int_X2;
v3,w3	:Multi_Int_X3;
v4,w4	:Multi_Int_X4;
vx		:Multi_Int_XV;

begin
writeln('--------------------------------');
writeln('test_X4_to_XV starting');
writeln('--------------------------------');

failed:= FALSE;

v2:= Multi_Int_X2_MAXINT;
v3:= Multi_Int_X3_MAXINT;
v4:= Multi_Int_X4_MAXINT;

write('Test x2 to xv: ');

vx:= Multi_Int_Xv_MAXINT;
vx:= v2;
if (vx <> v2) then
	begin
	writeln('FAILED! x2 to xv');
	failed:= TRUE;
	end
else writeln('Ok x2 to xv');

w2:= To_Multi_Int_X2(vx);
if (vx <> w2)
or (v2 <> w2)
then
	begin
	writeln('FAILED! xv to x2');
	failed:= TRUE;
	end
else writeln('Ok xv to x2');

write('Test x3 to xv: ');

vx:= Multi_Int_XV_MAXINT;
vx:= v3;
if (vx <> v3) then
	begin
	writeln('FAILED! x3 to xv');
	failed:= TRUE;
	end
else writeln('Ok x3 to xv');

w3:= To_Multi_Int_X3(vx);
if (vx <> w3)
or (v3 <> w3)
then
	begin
	writeln('FAILED! xv to x3');
	failed:= TRUE;
	end
else writeln('Ok xv to x3');

write('Test x4 to xv: ');

vx:= Multi_Int_XV_MAXINT;
vx:= v4;
if (vx <> v4) then
	begin
	writeln('FAILED! x4 to xv');
	failed:= TRUE;
	end
else writeln('Ok x4 to xv');

w4:= To_Multi_Int_X4(vx);
if (vx <> w4)
or (v4 <> w4)
then
	begin
	writeln('FAILED! xv to x4');
	failed:= TRUE;
	end
else writeln('Ok xv to x4');


if	(failed = TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!');

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
// test X
(*---------------------------------*)
procedure test_x;
var
failed			:T_Multi_UBool;
s				:ansistring;
P1,P2,T,
F,FS,FSC		:big_int;
i				:int32;

begin
writeln('--------------------------------');
writeln('test_x starting');
writeln('--------------------------------');

failed:= FALSE;

write('Test 1: ');
S:= MULTI_MAXINT.tostr;
N:= S;
T:= sqroot(N);
S:= T.tostr;
P:= S;
T:= (P ** 2);
S:= T.tostr;
N:= S;
R:= N div P;
if (P <> R) then
	begin
	writeln('FAILED!');
	failed:= TRUE;
	writeln('P=',P.tostr);
	writeln('R=',R.tostr);
	end
else writeln('Ok');

if	(failed = TRUE) then
	writeln('FAILED one or more tests!')
else if (failed = Multi_UBool_UNDEF) then
	writeln('DUBIOUS one or more tests!');

Multi_Int_ERROR:= FALSE;

end;


(*---------------------------------*)
BEGIN

{$IFDEF 32BIT}
	XV_SIZE:= 36;
{$ELSE}
{$IFDEF 64BIT}
	XV_SIZE:= 18;
{$ENDIF}
{$ENDIF}

Multi_Int_Initialisation(XV_SIZE);
// Multi_Int_Set_XV_Limit(XV_SIZE + 2);	// the 32bit maximum size must be 36 otherwise large constants later must be changed

{$ifdef Multi_Int_X2}
	MULTI_MAXINT:= Multi_Int_X2_MAXINT;
	Multi_Int_NBITS:= (Multi_X2_size * MULTI_INT_1W_SIZE);
{$else}
{$ifdef Multi_Int_X3}
	MULTI_MAXINT:= Multi_Int_X3_MAXINT;
	Multi_Int_NBITS:= (Multi_X3_size * MULTI_INT_1W_SIZE);
{$else}
{$ifdef Multi_Int_X4}
	MULTI_MAXINT:= Multi_Int_X4_MAXINT;
	Multi_Int_NBITS:= (Multi_X4_size * MULTI_INT_1W_SIZE);
{$else}
{$ifdef Multi_Int_XV}
	MULTI_MAXINT:= Multi_Int_XV_MAXINT;
	Multi_Int_NBITS:= (XV_SIZE * MULTI_INT_1W_SIZE);
{$endif} {$endif} {$endif} {$endif}

test_signed_operators(0,1);
test_signed_operators(2,1);
test_signed_operators(2,2);
test_signed_operators(2,3);
test_signed_operators(3,3);
test_signed_operators(3,2);
test_signed_operators(1,-2);
test_signed_operators(-1,2);
test_signed_operators(-1,-2);
test_signed_operators(1,2);
test_signed_operators(-2,1);
test_signed_operators(-2,2);
test_signed_operators(2,-1);
test_signed_operators(-2,-1);
test_signed_operators(1000,3);
test_signed_operators(1234567,1234567);
test_signed_operators(1234567,-1234567);
test_signed_operators(-1234567,1234567);
test_signed_operators(MULTI_MAXINT,1);
test_signed_operators(MULTI_MAXINT,65535);
test_signed_operators(MULTI_MAXINT,65536);
test_signed_operators(MULTI_MAXINT,4294967295);
test_signed_operators(MULTI_MAXINT,4294967296);

test_signed_operators(MULTI_MAXINT,0);
T:= -MULTI_MAXINT;
T:= T + 1;
test_signed_operators(T,0);

{$ifdef 32bit}
{$ifdef Multi_Int_X4}
// these are special numbers that trigger an unusual case inside the division algorithm
test_signed_operators('340282366841710300949110269838224261120','39614081275578912870481526783');
{$endif}
{$ifdef Multi_Int_XV}
// these are special numbers that trigger an unusual case inside the division algorithm
test_signed_operators('340282366841710300949110269838224261120','39614081275578912870481526783');
{$endif}
{$endif}

test_floats(0);
test_floats(1);
test_floats(2);
test_floats(-1);
test_floats(-2);
test_floats(1234567);
test_floats(-1234567);

{$ifdef Multi_Int_XV}
Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
Multi_Int_Set_XV_Limit(64);

N:= MULTI_SINGLE_TYPE_MAXVAL;
if not Multi_Int_ERROR then
	begin
	test_floats(N);
	N:= -N;
	test_floats(N);
	end
else
	Multi_Int_ERROR:= FALSE;

N:= MULTI_DOUBLE_TYPE_MAXVAL;
if not Multi_Int_ERROR then
	begin
	test_floats(N);
	N:= -N;
	test_floats(N);
	end
else
	Multi_Int_ERROR:= FALSE;

N:= MULTI_MAXINT;
test_floats(N);
N:= -MULTI_MAXINT;
test_floats(N);

Multi_Int_Set_XV_Limit(XV_SIZE);
Multi_Int_RAISE_EXCEPTIONS_ENABLED:= TRUE;
N:= 0;
{$endif}

{$ifdef Multi_Int_X4}
	{$ifdef 32bit}
	MULTI_MAXINT_STR:= '340282366920938463463374607431768211455';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '340282366920938463463374607431768211456';
	MAXINT_OVER_HEX:= '100000000000000000000000000000000';
	MAXINT_OVER_BIN:= '100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

	{$endif}
	{$ifdef 64bit}
	MULTI_MAXINT_STR:= '115792089237316195423570985008687907853269984665640564039457584007913129639935';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '115792089237316195423570985008687907853269984665640564039457584007913129639936';
	MAXINT_OVER_HEX:= '10000000000000000000000000000000000000000000000000000000000000000';
	MAXINT_OVER_BIN:= '10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
	{$endif}
{$endif}

{$ifdef Multi_Int_X3}

	{$ifdef 32bit}
	MULTI_MAXINT_STR:= '79228162514264337593543950335';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '79228162514264337593543950336';
	MAXINT_OVER_HEX:= '1000000000000000000000000';
	MAXINT_OVER_BIN:= '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

	{$endif}

	{$ifdef 64bit}
	MULTI_MAXINT_STR:= '6277101735386680763835789423207666416102355444464034512895';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '6277101735386680763835789423207666416102355444464034512896';
	MAXINT_OVER_HEX:= '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
	MAXINT_OVER_BIN:= '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
	{$endif}
{$endif}

{$ifdef Multi_Int_X2}

	{$ifdef 32bit}
	MULTI_MAXINT_STR:= '18446744073709551615';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '1111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '18446744073709551616';
	MAXINT_OVER_HEX:= '10000000000000000';
	MAXINT_OVER_BIN:= '10000000000000000000000000000000000000000000000000000000000000000';
	{$endif}

	{$ifdef 64bit}
	MULTI_MAXINT_STR:= '340282366920938463463374607431768211455';
	MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
	MULTI_MAXINT_BIN:= '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';

	MAXINT_OVER_STR:= '340282366920938463463374607431768211456';
	MAXINT_OVER_HEX:= '100000000000000000000000000000000';
	MAXINT_OVER_BIN:= '100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
	{$endif}
{$endif}

{$ifdef Multi_Int_XV}
// MULTI_MAXINT_STR:= '247330401473104534060502521019647190035131349101211839914063056092897225106531867170316401061243044989597671426016139339351365034306751209967546155101893167916606772148699135';
// MAXINT_OVER_STR:= '247330401473104534060502521019647190035131349101211839914063056092897225106531867170316401061243044989597671426016139339351365034306751209967546155101893167916606772148699136';

MULTI_MAXINT_STR:= MULTI_MAXINT.ToStr;
MAXINT_OVER_STR:= ansileftstr(MULTI_MAXINT_STR,(length(MULTI_MAXINT_STR) - 1)) + '9';

// MULTI_MAXINT_HEX:= 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
// MAXINT_OVER_HEX:= '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

MULTI_MAXINT_HEX:= MULTI_MAXINT.ToHex;
MAXINT_OVER_HEX:= '1';
MAXINT_OVER_HEX:= AddcharR('0',MAXINT_OVER_HEX,(length(MULTI_MAXINT_HEX) + 1));

// MULTI_MAXINT_BIN:= '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
// MAXINT_OVER_BIN:= '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

MULTI_MAXINT_BIN:= MULTI_MAXINT.ToBin;
MAXINT_OVER_BIN:= '1';
MAXINT_OVER_BIN:= AddcharR('0',MAXINT_OVER_BIN,(length(MULTI_MAXINT_BIN) + 1));

{$endif}

test_strings(MULTI_MAXINT_STR, dec_str);
test_strings(MAXINT_OVER_STR, dec_str,TEST_FAIL_EXPECTED);
test_strings(MULTI_MAXINT_HEX, hex_str);
test_strings(MAXINT_OVER_HEX, hex_str,TEST_FAIL_EXPECTED);
test_strings(MULTI_MAXINT_BIN, bin_str);
test_strings(MAXINT_OVER_BIN, bin_str,TEST_FAIL_EXPECTED);
test_strings('-'+MULTI_MAXINT_STR, dec_str);
test_strings('-'+MAXINT_OVER_STR, dec_str,TEST_FAIL_EXPECTED);
test_strings('-'+MULTI_MAXINT_HEX, hex_str);
test_strings('-'+MAXINT_OVER_HEX, hex_str,TEST_FAIL_EXPECTED);
test_strings('-'+MULTI_MAXINT_BIN, bin_str);
test_strings('-'+MAXINT_OVER_BIN, bin_str,TEST_FAIL_EXPECTED);
test_strings('0', dec_str);
test_strings('0', hex_str);
test_strings('0', bin_str);
test_strings('-1', dec_str);
test_strings('-1', hex_str);
test_strings('-1', bin_str);
test_strings('', dec_str);
test_strings('', hex_str);
test_strings('', bin_str);
test_strings('/', dec_str,TEST_FAIL_EXPECTED);
test_strings(':', dec_str,TEST_FAIL_EXPECTED);
test_strings('/', hex_str,TEST_FAIL_EXPECTED);
test_strings('G', hex_str,TEST_FAIL_EXPECTED);
test_strings('/', bin_str,TEST_FAIL_EXPECTED);
test_strings('2', bin_str,TEST_FAIL_EXPECTED);

{$ifdef Multi_Int_X2}
	{$ifdef 32bit}
		N:= 4294967295;
		P:= 2;
	    R:= '18446744065119617025';
		test_power(N,P,R);
	{$endif}
	{$ifdef 64bit}
		N:= 18446744073709551615;
		P:= 2;
	    R:= '340282366920938463426481119284349108225';
		test_power(N,P,R);
	{$endif}
{$else}
{$ifdef Multi_Int_X3}
	{$ifdef 32bit}
		N:= 4294967295;
		P:= 3;
	    R:= '79228162458924105385300197375';
		test_power(N,P,R);
	{$endif}
	{$ifdef 64bit}
		N:= 4294967295;
		P:= 4;
	    R:= '340282366604025813516997721482669850625';
		test_power(N,P,R);
	{$endif}
{$else}
{$ifdef Multi_Int_X4}
	{$ifdef 32bit}
		N:= 4294967295;
		P:= 4;
	    R:= '340282366604025813516997721482669850625';
		test_power(N,P,R);
	{$endif}
	{$ifdef 64bit}
		N:= 18446744073709551615;
		P:= 4;
	    R:= '115792089237316195398462578067141184799968521174335529155754622898352762650625';
		test_power(N,P,R);
	{$endif}

{$else}
{$ifdef Multi_Int_XV}
	{$ifdef 32bit}
		N:= 4294967295;
		P:= 8;
		R:= '115792089021636622262124715160334756877804245386980633020041035952359812890625';
	{$endif}
	{$ifdef 64bit}
		N:= 18446744073709551615;
		P:= 8;
		R:= '13407807929942597093759315203840991004188031530987402520718628407015669769757842313630909715223819254400837606388228716074377856895316039510175975812890625';
	{$endif}
		test_power(N,P,R);
{$endif} {$endif} {$endif} {$endif}

N:= 4294967295;
R:= 4294967296;
test_inc(N,R);
T:= R; R:= N; N:= T;
test_dec(N,R);

{$ifdef Multi_Int_X2}
	{$ifdef 32bit}
		N:= '18446744073709551614';
		R:= '18446744073709551615';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

	{$endif}
	{$ifdef 64bit}
		N:= '79228162514264337593543950335';
		R:= '79228162514264337593543950336';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);
	{$endif}
{$endif}

{$ifdef Multi_Int_X3}
	{$ifdef 32bit}
		N:= '1208925819614629174706175';
		R:= '1208925819614629174706176';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '79228162514264337593543950334';
		R:= '79228162514264337593543950335';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

	{$endif}
	{$ifdef 64bit}
		N:= '340282366920938463463374607431768211455';
		R:= '340282366920938463463374607431768211456';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '1461501637330902918203684832716283019655932542975';
		R:= '1461501637330902918203684832716283019655932542976';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '6277101735386680763835789423207666416102355444464034512894';
		R:= '6277101735386680763835789423207666416102355444464034512895';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);
	{$endif}
{$endif}

{$ifdef Multi_Int_X4}
	{$ifdef 32bit}
		N:= '5192296858534827628530496329220095';
		R:= '5192296858534827628530496329220096';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '79228162514264337593543950335';
		R:= '79228162514264337593543950336';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '1208925819614629174706175';
		R:= '1208925819614629174706176';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '18446744073709551615';
		R:= '18446744073709551616';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);
	{$endif}
	{$ifdef 64bit}
		N:= '340282366920938463463374607431768211455';
		R:= '340282366920938463463374607431768211456';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '1461501637330902918203684832716283019655932542975';
		R:= '1461501637330902918203684832716283019655932542976';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '6277101735386680763835789423207666416102355444464034512895';
		R:= '6277101735386680763835789423207666416102355444464034512896';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '26959946667150639794667015087019630673637144422540572481103610249215';
		R:= '26959946667150639794667015087019630673637144422540572481103610249216';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);

		N:= '115792089237316195423570985008687907853269984665640564039457584007913129639934';
		R:= '115792089237316195423570985008687907853269984665640564039457584007913129639935';
		test_inc(N,R);
		T:= R; R:= N; N:= T;
		test_dec(N,R);
	{$endif}

{$endif}

{$ifdef Multi_Int_XV}

NS:= '340282366920938463463374607431768211455';
RS:= '340282366920938463463374607431768211456';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '1461501637330902918203684832716283019655932542975';
RS:= '1461501637330902918203684832716283019655932542976';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '6277101735386680763835789423207666416102355444464034512895';
RS:= '6277101735386680763835789423207666416102355444464034512896';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '26959946667150639794667015087019630673637144422540572481103610249215';
RS:= '26959946667150639794667015087019630673637144422540572481103610249216';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

// if (Multi_Int_XV_Limit > 16) then
// begin

NS:= '115792089237316195423570985008687907853269984665640564039457584007913129639935';
RS:= '115792089237316195423570985008687907853269984665640564039457584007913129639936';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '497323236409786642155382248146820840100456150797347717440463976893159497012533375533055';
RS:= '497323236409786642155382248146820840100456150797347717440463976893159497012533375533056';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '2135987035920910082395021706169552114602704522356652769947041607822219725780640550022962086936574';
RS:= '2135987035920910082395021706169552114602704522356652769947041607822219725780640550022962086936575';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

N:= big_int('497323236409786642155382248146820840100456150797347717440463976893159497012533375533056')
  + big_int('115792089237316195423570985008687907853269984665640564039457584007913129639936')
  + big_int('26959946667150639794667015087019630673637144422540572481103610249216')
  + big_int('6277101735386680763835789423207666416102355444464034512896')
  + big_int('1461501637330902918203684832716283019655932542976')
  + big_int('340282366920938463463374607431768211456')
  + big_int('79228162514264337593543950336')
  + big_int('18446744073709551616')
  + 4294967296
 ;
NS:= N.tostr;
RS:= '497323236525578731419658390243819566640659256139144307488153203229972377654773399158785';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);

NS:= '497323236525578731419658390243819566640659256139144307488153203229972377654773399158775';
RS:= '497323236525578731419658390243819566640659256139144307488153203229972377654773399158776';
test_inc(NS,RS);
T:= RS; RS:= NS; NS:= T;
test_dec(NS,RS);
// end

{$endif}

shift_and_or_test;
test_X4_to_XV;
test_x;

END.

