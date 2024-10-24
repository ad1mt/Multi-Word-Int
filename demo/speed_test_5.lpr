// {$MODE DELPHI}
{$MODESWITCH NESTEDCOMMENTS+}

program speed_test_5;
uses	sysutils
,		strutils
,		strings
,		math
,		Multi_Int
;

const
MULTI_INT_XV_SIZE	= 512;

M2_DIV_ITERATIONS	= 200000;
M2_MUL_ITERATIONS	= 1000000;
M2_SUB_ITERATIONS	= 2000000;
M3_DIV_ITERATIONS	= 200000;
M3_MUL_ITERATIONS	= 1000000;
M3_SUB_ITERATIONS	= 2000000;
M4_DIV_ITERATIONS	= 200000;
M4_MUL_ITERATIONS	= 1000000;
M4_SUB_ITERATIONS	= 2000000;
MV_DIV_ITERATIONS	= 100;
MV_MUL_ITERATIONS	= 100000;
MV_SUB_ITERATIONS	= 100000;

var
i,
start_time,
end_time		:int32;
delta			:double;


(********************************)
procedure test_Multi_Int_X2;
var
M2_i,
M2_j,
M2_k	:Multi_Int_X2;

begin
start_time:= GetTickCount64;

M2_i:= Multi_Int_X2_MAXINT;
M2_j:= 4294967296;

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

(*----*)

start_time:= GetTickCount64;

M2_i:= (Multi_Int_X2_MAXINT >> (((Multi_X2_size * 1) div 4) * MULTI_INT_1W_SIZE));
M2_j:= (Multi_Int_X2_MAXINT >> (((Multi_X2_size * 3) div 4) * MULTI_INT_1W_SIZE));

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

(*----*)

start_time:= GetTickCount64;

M2_i:= (Multi_Int_X2_MAXINT shr 5);
// ShiftDown(M2_i, 5);
M2_i:= M2_i + 5;

M2_j:= (Multi_Int_X2_MAXINT >> 5);
// ShiftDown(M2_j, 11);
M2_j:= M2_j - 11;

i:=0;
while (i < (M2_SUB_ITERATIONS div 2)) do
	begin
	M2_k:= M2_i + M2_j;
	Dec(M2_i);
	Dec(M2_j);
	M2_k:= M2_i + M2_j;
	Inc(M2_i);
	Inc(M2_j);

	Inc(i)
	end;

if	M2_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of add with %d bit integers', [delta,M2_SUB_ITERATIONS,(((Multi_X2_size + 1) div 2) * 64)]));
(*----*)

start_time:= GetTickCount64;

M2_i:= (Multi_Int_X2_MAXINT shr 5);
// ShiftDown(M2_i, 5);
M2_i:= M2_i + 5;

M2_j:= (Multi_Int_X2_MAXINT >> 5);
// ShiftDown(M2_j, 11);
M2_j:= M2_j - 11;

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

(*----*)

writeln;
end;


(********************************)
procedure test_Multi_Int_X3;
var
M3_i,
M3_j,
M3_k	:Multi_Int_X3;

begin
start_time:= GetTickCount64;

M3_i:= Multi_Int_X3_MAXINT;
M3_j:= 4294967296;

i:=0;
while (i < (M3_DIV_ITERATIONS div 2)) do
	begin
	M3_k:= M3_i div M3_j;
	Dec(M3_i);
	Dec(M3_j);
	M3_k:= M3_i div M3_j;
	Inc(M3_i);
	Inc(M3_j);

	Inc(i)
	end;

if	M3_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,M3_DIV_ITERATIONS,(((Multi_X3_size + 1) div 2) * 64)]));

(*----*)

start_time:= GetTickCount64;

M3_i:= (Multi_Int_X3_MAXINT >> (((Multi_X3_size * 2) div 6) * 32));
M3_j:= (Multi_Int_X3_MAXINT >> (((Multi_X3_size * 4) div 6) * 32));

i:=0;
while (i < (M3_MUL_ITERATIONS div 2)) do
	begin
	M3_k:= M3_i * M3_j;
	Dec(M3_i);
	Dec(M3_j);
	M3_k:= M3_i * M3_j;
	Inc(M3_i);
	Inc(M3_j);

	Inc(i)
	end;

if	M3_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of multiply with %d bit integers', [delta,M3_MUL_ITERATIONS,(((Multi_X3_size + 1) div 2) * 64)]));

(*----*)

start_time:= GetTickCount64;

M3_i:= (Multi_Int_X3_MAXINT >> 5);
// ShiftDown(M3_i, 5);
M3_i:= M3_i + 5;

M3_j:= (Multi_Int_X3_MAXINT shr 5);
// ShiftDown(M3_j, 11);
M3_j:= M3_j - 11;

i:=0;
while (i < (M3_SUB_ITERATIONS div 2)) do
	begin
	M3_k:= M3_i + M3_j;
	Dec(M3_i);
	Dec(M3_j);
	M3_k:= M3_i + M3_j;
	Inc(M3_i);
	Inc(M3_j);

	Inc(i)
	end;

if	M3_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of add with %d bit integers', [delta,M3_SUB_ITERATIONS,(((Multi_X3_size + 1) div 2) * 64)]));

(*----*)

start_time:= GetTickCount64;

M3_i:= (Multi_Int_X3_MAXINT >> 5);
// ShiftDown(M3_i, 5);
M3_i:= M3_i + 5;

M3_j:= (Multi_Int_X3_MAXINT shr 5);
// ShiftDown(M3_j, 11);
M3_j:= M3_j - 11;

i:=0;
while (i < (M3_SUB_ITERATIONS div 2)) do
	begin
	M3_k:= M3_i - M3_j;
	Dec(M3_i);
	Dec(M3_j);
	M3_k:= M3_i - M3_j;
	Inc(M3_i);
	Inc(M3_j);

	Inc(i)
	end;

if	M3_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,M3_SUB_ITERATIONS,(((Multi_X3_size + 1) div 2) * 64)]));

(*----*)

writeln;
end;


(********************************)
procedure test_Multi_Int_X4;
var
M4_i,
M4_j,
M4_k	:Multi_Int_X4;

begin
start_time:= GetTickCount64;

M4_i:= Multi_Int_X4_MAXINT;
M4_j:= '4294967296';

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

(*----*)

start_time:= GetTickCount64;

M4_i:= (Multi_Int_X4_MAXINT >> (((Multi_X4_size * 1) div 4) * 32));
M4_j:= (Multi_Int_X4_MAXINT >> (((Multi_X4_size * 3) div 4) * 32));

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

(*----*)

start_time:= GetTickCount64;

M4_i:= Multi_Int_X4_MAXINT;
M4_i:= (M4_i >> 5);
M4_i:= M4_i + 5;

M4_j:= Multi_Int_X4_MAXINT;
M4_j:= (M4_j >> 11);
M4_j:= M4_j - 11;

i:=0;
while (i < (M4_SUB_ITERATIONS div 2)) do
	begin
	M4_k:= M4_i + M4_j;
	Dec(M4_i);
	Dec(M4_j);
	M4_k:= M4_i + M4_j;
	Inc(M4_i);
	Inc(M4_j);

	Inc(i)
	end;

if	M4_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of add with %d bit integers', [delta,M4_SUB_ITERATIONS,(((Multi_X4_size + 1) div 2) * 64)]));

(*----*)

start_time:= GetTickCount64;

M4_i:= Multi_Int_X4_MAXINT;
M4_i:= (M4_i >> 5);
M4_i:= M4_i + 5;

M4_j:= Multi_Int_X4_MAXINT;
M4_j:= (M4_j >> 11);
M4_j:= M4_j - 11;

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

(*----*)

writeln;
end;


(********************************)
procedure test_Multi_Int_XV;
var
MV_i,
MV_j,
MV_k	:Multi_Int_XV;

begin

start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
MV_j:= 4294967296;

i:=0;
while (i < (MV_DIV_ITERATIONS div 2)) do
	begin
	MV_k:= MV_i div MV_j;
	Multi_Int_Reset_XV_Last_Divisor;
	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of divide with %d bit integers', [delta,MV_DIV_ITERATIONS,((MULTI_INT_XV_SIZE div 2) * 64)]));

(*----*)

MV_i:= MV_k;
MV_j:= 4294967296;

start_time:= GetTickCount64;

i:=0;
while (i < MV_MUL_ITERATIONS) do
	begin
	MV_k:= MV_i * MV_j;
	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of multiply with %d bit integers', [delta,MV_MUL_ITERATIONS,((MULTI_INT_XV_SIZE div 2) * 64)]));

(*----*)
start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
MV_i:= (MV_i >> 1);
MV_i:= MV_i + 1;

MV_j:= Multi_Int_XV_MAXINT;
MV_j:= (MV_j >> 5);
MV_j:= MV_j - 5;

i:=0;
while (i < (MV_SUB_ITERATIONS div 2)) do
	begin
	MV_k:= MV_i + MV_j;
	Dec(MV_i);
	Dec(MV_j);
	MV_k:= MV_i + MV_j;
	Inc(MV_i);
	Inc(MV_j);

	Inc(i)
	end;

if	MV_k.overflow
then writeln(' Overflow!');

end_time:= GetTickCount64;
delta:= (end_time - start_time) / 1000;
writeln(Format('time elapsed is %f seconds for %d iterations of add with %d bit integers', [delta,MV_SUB_ITERATIONS,((MULTI_INT_XV_SIZE div 2) * 64)]));

(*----*)
start_time:= GetTickCount64;

MV_i:= Multi_Int_XV_MAXINT;
MV_i:= (MV_i >> 1);
MV_i:= MV_i + 1;

MV_j:= Multi_Int_XV_MAXINT;
MV_j:= (MV_j >> 5);
MV_j:= MV_j - 5;

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
writeln(Format('time elapsed is %f seconds for %d iterations of subtract with %d bit integers', [delta,MV_SUB_ITERATIONS,((MULTI_INT_XV_SIZE div 2) * 64)]));

(*----*)
writeln;
end;


begin
Multi_Int_Initialisation(MULTI_INT_XV_SIZE);

test_Multi_Int_X2;
test_Multi_Int_X3;
test_Multi_Int_X4;
test_Multi_Int_XV;

end.


