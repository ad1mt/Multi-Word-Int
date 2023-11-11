{$MODE DELPHI}
{$MODESWITCH NESTEDCOMMENTS+}

program calc;
uses	sysutils
,		strutils
,		strings
,		math
,		Multi_Int
;

var
op		:string;
Mi,
Mj,
Mk		:Multi_Int_X48;
i,
start_time,
end_time		:int32;
delta			:double;

BEGIN
if (ParamCount = 0) then
	begin
	writeln('usage: calc  number  operator  number');
	writeln('where: operator can be one of:');
	writeln(' + - * xor rotu rotd shu shd div (/) mod (%) or pow (^ or **)');
	writeln('where shu/shd means shift bits and rotu/rotd means rotate bits');
	writeln('and number can be up to +/- ',Multi_Int_X48_MAXINT.tostr);
	end
else
	begin
	Mi:= ParamStr(1);
	Mj:= ParamStr(3);

	if	(not Mi.defined)
	or	(not Mj.defined) then
		begin
		writeln('input number error: maximum is');
		writeln(Multi_Int_X48_MAXINT.tostr);
		end
	else
		begin
		if	(ParamStr(2) = '/')
		or	(ParamStr(2) = 'div')
		then
			begin Mk:= Mi Div Mj; op:= '/'; end
	    else

		if	(ParamStr(2) = 'mod')
		or	(ParamStr(2) = '%')
		then
			begin MK:= Mi Mod Mj; op:= '%'; end

		else if	(ParamStr(2) = 'pow')
		or	(ParamStr(2) = '^')
		or	(ParamStr(2) = '**')
		then
			begin MK:= Mi ** Mj; op:= '^'; end

		else if	(ParamStr(2) = '*') then
			begin MK:= Mi * Mj; op:= '*'; end
	
		else if	(ParamStr(2) = '+') then
			begin MK:= Mi + Mj; op:= '+'; end
	
		else if	(ParamStr(2) = '-') then
			begin MK:= Mi - Mj; op:= '-'; end
	
		else if	(ParamStr(2) = 'xor') then
			begin MK:= Mi Xor Mj; op:= 'XOR'; end

		else if	(ParamStr(2) = 'rotu') then
			begin Mk:=Mi; Mk.RotateUp_MultiBits(Mk, INT_1W_U(Mj)); op:= 'ROTU'; end

		else if	(ParamStr(2) = 'rotd') then
			begin Mk:=Mi; Mk.RotateDown_MultiBits(Mk, INT_1W_U(Mj)); op:= 'ROTD'; end

		else if	(ParamStr(2) = 'shu') then
			begin Mk:=Mi; Mk.ShiftUp_MultiBits(Mk, INT_1W_U(Mj)); op:= 'SHU'; end

		else if	(ParamStr(2) = 'shd') then
			begin Mk:=Mi; Mk.ShiftDown_MultiBits(Mk, INT_1W_U(Mj)); op:= 'SHD'; end

		else if	(ParamStr(2) = 'sqr') then
			begin
			SqRoot(Mi,Mk,Mj);
			op:= 'SQR';
			end

		else
			begin
			writeln('Invalid operator');
			writeln('where: operator can be one of:');
			writeln(' + - * xor rotu rotd shu shd div (/) mod (%) or pow (^ or **)');
			halt(1);
			end
		;

		if (ParamStr(2) = 'sqr') then
			begin
			writeln;
			writeln(Mk.ToStr);
			writeln('Remainder ',Mj.tostr);
			end
		else
			begin
			writeln;
			write(Mk.ToStr);
			end;
		if	Mk.overflow
		then writeln(' Overflow!')
		else writeln;
		end;
	end;
END.

