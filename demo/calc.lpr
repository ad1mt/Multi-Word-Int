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
Mk		:Multi_Int_XV;
i,
big_size,
start_time,
end_time		:int32;
delta			:double;

BEGIN
big_size:= 16;
Multi_Init_Initialisation(big_size);
Multi_Int_Set_XV_Limit(big_size + 1);

if (ParamCount = 0) then
	begin
	writeln('calc v',version,' ',big_size,' words (',(big_size * MULTI_INT_1W_SIZE),' bits)');
	writeln('usage: calc  number  operator  number');
	writeln('where: operator can be one of:');
	writeln(' + - * div (/) mod (%) xor shu shd sqr hex dec pow (^ or **) ');
	writeln('where shu/shd means shift bits and sqr means square root');
	writeln('and number can be up to +/- ',Multi_Int_XV_MAXINT.tostr);
	writeln('or approx ',trunc(((big_size * MULTI_INT_1W_SIZE)/128000)*38532),' digits long');
	end
else
	begin
	if	(ParamStr(2) = 'dec')
	then FromHex(ParamStr(1),Mi)
    else Mi:= ParamStr(1);
	Mj:= ParamStr(3);

	if	(not Mi.defined)
	or	(not Mj.defined) then
		begin
		writeln('input number error: maximum is');
		writeln(Multi_Int_XV_MAXINT.tostr);
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

		else if	(ParamStr(2) = 'shu') then
			begin Mk:= (Mi << MULTI_INT_1W_U(Mj)); op:= 'SHU'; end

		else if	(ParamStr(2) = 'shd') then
			begin Mk:= (Mi >> MULTI_INT_1W_U(Mj)); op:= 'SHD'; end

		else if	(ParamStr(2) = 'sqr') then
			begin
			SqRoot(Mi,Mk,Mj);
			op:= 'SQR';
			end

		else if	(ParamStr(2) = 'hex') then
			begin
			Mk:= Mi;
			op:= 'HEX';
			end

		else if	(ParamStr(2) = 'dec') then
			begin
			Mk:= Mi;
			op:= 'DEC';
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
		else if (ParamStr(2) = 'hex') then
			begin
			writeln;
			writeln(Mk.ToHex);
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

