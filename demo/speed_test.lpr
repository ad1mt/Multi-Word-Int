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
M2_DIV_ITERATIONS	= 1000000;
M2_MUL_ITERATIONS	= 1000000;
M2_SUB_ITERATIONS	= 10000000;
M4_DIV_ITERATIONS	= 1000000;
M4_MUL_ITERATIONS	= 1000000;
M4_SUB_ITERATIONS	= 1000000;
MV_DIV_ITERATIONS	= 10000;
MV_MUL_ITERATIONS	= 100000;
MV_SUB_ITERATIONS	= 100000;

var
op		:string;
i,
big_int_size,
start_time,
end_time		:int32;
delta			:double;

(********************************)
procedure test_Multi_Int_X2;
var
M2_i,
M2_j,
M2_k		:Multi_Int_X2;

begin
start_time:= GetTickCount64;

// M2_i:= Multi_Int_X2_MAXINT;
// ShiftDown(M2_i, 1);

// M2_j:= Multi_Int_X2_MAXINT;
// ShiftDown(M2_j, 47);

M2_i:= 1000000000000000003;
M2_j:= 1000000000000037;

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

if	M2_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M2_DIV_ITERATIONS,(((Multi_X2_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;

M2_i:= 1000000000000000003;
M2_j:= 1000000000000037;

i:=0;
while (i < (M2_MUL_ITERATIONS div 2)) do
	begin
	M2_k:= M2_i * M2_j;
	Dec(M2_i);
	Dec(M2_j);
	M2_k:= M2_i * M2_j;
	Inc(M2_i);
	Inc(M2_j);

	Inc(i)
	end;

if	M2_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of multiply with %d bit integers', [delta,M2_MUL_ITERATIONS,(((Multi_X2_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;

M2_i:= 1000000000000000003;
M2_j:= 1000000000000037;

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

if	M2_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M2_SUB_ITERATIONS,(((Multi_X2_size + 1) div 2) * 64)]));

writeln;
end;


(********************************)
procedure test_Multi_Int_X4;
var
M4_i,
M4_j,
M4_k		:Multi_Int_X4;

begin
start_time:= GetTickCount64;

// M2_i:= Multi_Int_X2_MAXINT;
// ShiftDown(M2_i, 1);

// M2_j:= Multi_Int_X2_MAXINT;
// ShiftDown(M2_j, 47);

M4_i:= 1000000000000000003;
M4_j:= 1000000000000037;

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

if	M4_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M4_DIV_ITERATIONS,(((Multi_X4_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;

M4_i:= 1000000000000000003;
M4_j:= 1000000000000037;

i:=0;
while (i < (M4_MUL_ITERATIONS div 2)) do
	begin
	M4_k:= M4_i * M4_j;
	Dec(M4_i);
	Dec(M4_j);
	M4_k:= M4_i * M4_j;
	Inc(M4_i);
	Inc(M4_j);

	Inc(i)
	end;

if	M4_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of multiply with %d bit integers', [delta,M4_MUL_ITERATIONS,(((Multi_X4_size + 1) div 2) * 64)]));

start_time:= GetTickCount64;

M4_i:= 1000000000000000003;
M4_j:= 1000000000000037;

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

if	M4_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M4_SUB_ITERATIONS,(((Multi_X4_size + 1) div 2) * 64)]));

writeln;
end;


(********************************)
procedure test_Multi_Int_XV;
var
MV_i,
MV_j,
MV_k		:Multi_Int_XV;

begin

start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
ShiftDown(MV_i, 7);

MV_j:= '1000000000011100000000041070000000050653';

i:=0;
while (i < (MV_DIV_ITERATIONS div 2)) do
	begin
	MV_k:= MV_i div MV_j;
	Dec(MV_i);
	Dec(MV_j);
	MV_k:= MV_i div MV_j;
	Inc(MV_i);
	Inc(MV_j);

	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,MV_DIV_ITERATIONS,((big_int_size div 2) * 64)]));

(*----*)
start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
ShiftDown(MV_i, 131);

MV_j:= Multi_Int_X4_MAXINT;
ShiftDown(MV_j, 131);

i:=0;
while (i < (MV_MUL_ITERATIONS div 2)) do
	begin
	MV_k:= MV_i * MV_j;
	Dec(MV_i);
	Dec(MV_j);
	MV_k:= MV_i * MV_j;
	Inc(MV_i);
	Inc(MV_j);

	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of multiply with %d bit integers', [delta, MV_MUL_ITERATIONS, ((big_int_size div 2) * 64)]));

(*----*)
start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
ShiftDown(MV_i, 7);

MV_j:= Multi_Int_XV_MAXINT;
ShiftDown(MV_j, 11);

i:=0;
while (i < (MV_SUB_ITERATIONS div 2)) do
	begin
	MV_k:= MV_i - MV_j;
	Dec(MV_i);
	Dec(MV_j);
	MV_k:= MV_i - MV_j;
	Inc(MV_i);
	Inc(MV_j);

	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta, MV_SUB_ITERATIONS,((big_int_size div 2) * 64)]));
writeln;
end;


begin
big_int_size:= 16;
Multi_Init_Initialisation(big_int_size);

test_Multi_Int_X2;
test_Multi_Int_X4;
test_Multi_Int_XV;
end.

