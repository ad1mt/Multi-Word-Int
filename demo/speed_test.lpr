{$MODE DELPHI}
{$MODESWITCH NESTEDCOMMENTS+}

program speed_test;
uses	sysutils
,		strutils
,		strings
,		math
,		Multi_Int
;
	
const
M48_DEMO_ITERATIONS	= 100;
M4_DEMO_ITERATIONS	= 10000;

var
op		:string;
M48_i,
M48_j,
M48_k		:Multi_Int_X48;
M4_i,
M4_j,
M4_k		:Multi_Int_X4;
i,
start_time,
end_time		:int32;
delta			:double;

procedure test_Multi_Int_X48;
begin
start_time:= GetTickCount64;
M48_i:= Multi_Int_X48_MAXINT;
M48_j:= -1;

if	(not M48_i.defined)
or	(not M48_j.defined) then
	begin
	if	(not M48_i.defined) then writeln('M48_i number error');
	if	(not M48_j.defined) then writeln('M48_j number error');
	end
else
	begin
	i:=0;
	while (i < (M48_DEMO_ITERATIONS div 2)) do
		begin
		M48_k:= M48_i div M48_j;
		Dec(M48_i);
		Dec(M48_j);
		M48_k:= M48_i div M48_j;
		Inc(M48_i);
		Inc(M48_j);

		Inc(i)
		end;
	end_time:= GetTickCount64;
	delta:= (end_time - start_time) / 1000;
	writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M48_DEMO_ITERATIONS,(((X48_size + 1) div 2) * 64)]));

	if	M48_k.overflow
	then writeln(' Overflow!')
	else writeln;
	end;
end;

procedure test_Multi_Int_X4;
begin
start_time:= GetTickCount64;
M4_i:= Multi_Int_X4_MAXINT;
M4_j:= -1;

if	(not M4_i.defined)
or	(not M4_j.defined) then
	begin
	if	(not M4_i.defined) then writeln('M4_i number error');
	if	(not M4_j.defined) then writeln('M4_j number error');
	end
else
	begin
	i:=0;
	while (i < (M4_DEMO_ITERATIONS div 2)) do
		begin
		M4_k:= M4_i div M4_j;
		Dec(M4_i);
		Dec(M4_j);
		M4_k:= M4_i div M4_j;
		Inc(M4_i);
		Inc(M4_j);

		Inc(i)
		end;
	end_time:= GetTickCount64;
	delta:= (end_time - start_time) / 1000;
	writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M4_DEMO_ITERATIONS,(((X4_size + 1) div 2) * 64)]));

	if	M4_k.overflow
	then writeln(' Overflow!')
	else writeln;
	end;
end;

begin
test_Multi_Int_X4;
test_Multi_Int_X48;
end.

