// {$MODE DELPHI}
{$MODESWITCH NESTEDCOMMENTS+}

program speed_test;
uses	sysutils
,		strutils
,		strings
,		math
,		Multi_Int
;
	
const
M48_DIV_ITERATIONS	= 100;
M48_SUB_ITERATIONS	= 100000;
M4_DIV_ITERATIONS	= 10000;
M4_SUB_ITERATIONS	= 1000000;
M2_DIV_ITERATIONS	= 100000;
M2_SUB_ITERATIONS	= 10000000;

var
op		:string;
M48_i,
M48_j,
M48_k		:Multi_Int_X48;
M4_i,
M4_j,
M4_k		:Multi_Int_X4;
M2_i,
M2_j,
M2_k		:Multi_Int_X2;
i,
start_time,
end_time		:int32;
delta			:double;

procedure test_Multi_Int_X48;
begin
start_time:= GetTickCount64;
M48_i:= Multi_Int_X48_MAXINT;
M48_j:= (To_Multi_Int_X48(Multi_Int_X2_MAXINT) * 7);

i:=0;
while (i < (M48_DIV_ITERATIONS div 2)) do
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
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M48_DIV_ITERATIONS,(((X48_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;
M48_i:= Multi_Int_X48_MAXINT;
M48_j:= (To_Multi_Int_X48(Multi_Int_X2_MAXINT) * 7);

i:=0;
while (i < (M48_SUB_ITERATIONS div 2)) do
	begin
	M48_k:= M48_i - M48_j;
	Dec(M48_i);
	Dec(M48_j);
	M48_k:= M48_i - M48_j;
	Inc(M48_i);
	Inc(M48_j);

	Inc(i)
	end;
end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M48_SUB_ITERATIONS,(((X48_size + 1) div 2) * 64)]));

if	M48_k.overflow
then writeln(' Overflow!')
else writeln;
end;

procedure test_Multi_Int_X4;
begin
start_time:= GetTickCount64;
M4_i:= Multi_Int_X4_MAXINT;
M4_j:= (To_Multi_Int_X4(Multi_Int_X2_MAXINT) * 7);

i:=0;
while (i < (M4_DIV_ITERATIONS div 2)) do
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
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M4_DIV_ITERATIONS,(((X4_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;
M4_i:= Multi_Int_X4_MAXINT;
M4_j:= (To_Multi_Int_X4(Multi_Int_X2_MAXINT) * 7);

i:=0;
while (i < (M4_SUB_ITERATIONS div 2)) do
	begin
	M4_k:= M4_i - M4_j;
	Dec(M4_i);
	Dec(M4_j);
	M4_k:= M4_i - M4_j;
	Inc(M4_i);
	Inc(M4_j);

	Inc(i)
	end;
end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M4_SUB_ITERATIONS,(((X4_size + 1) div 2) * 64)]));

if	M4_k.overflow
then writeln(' Overflow!')
else writeln;
end;

procedure test_Multi_Int_X2;
begin
start_time:= GetTickCount64;
M2_i:= Multi_Int_X2_MAXINT;
M2_j:= MAXINT;
M2_j:= (M2_j * M2_j * 7);

i:=0;
while (i < (M2_DIV_ITERATIONS div 2)) do
	begin
	M2_k:= M2_i div M2_j;
	Dec(M2_i);
	Dec(M2_j);
	M2_k:= M2_i div M2_j;
	Inc(M2_i);
	Inc(M2_j);

	Inc(i)
	end;
end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M2_DIV_ITERATIONS,(((X2_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;
M2_i:= Multi_Int_X2_MAXINT;
M2_j:= MAXINT;
M2_j:= (M2_j * M2_j * 7);

i:=0;
while (i < (M2_SUB_ITERATIONS div 2)) do
	begin
	M2_k:= M2_i - M2_j;
	Dec(M2_i);
	Dec(M2_j);
	M2_k:= M2_i - M2_j;
	Inc(M2_i);
	Inc(M2_j);

	Inc(i)
	end;
end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M2_SUB_ITERATIONS,(((X2_size + 1) div 2) * 64)]));

if	M2_k.overflow
then writeln(' Overflow!')
else writeln;
end;

begin
test_Multi_Int_X2;
test_Multi_Int_X4;
test_Multi_Int_X48;
end.

