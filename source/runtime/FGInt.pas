{License, info, etc
 ------------------
This implementation is made by me, Walied Othman, to contact me
mail to rainwolf@submanifold.be or triade@submanifold.be ,
always mention wether it 's about the FGInt or about the 6xs,
preferably in the subject line.
This source code is free, but only to other free software,
it's a two-way street, if you use this code in an application from which
you won't make any money of (e.g. software for the good of mankind)
then go right ahead, I won't stop you, I do demand acknowledgement for
my work.  However, if you're using this code in a commercial application,
an application from which you'll make money, then yes, I charge a
license-fee, as described in the license agreement for commercial use, see
the textfile in this zip-file.
If you 're going to use these implementations, let me know, so I ca, put a link
on my page if desired, I 'm always curious as to see where the spawn of my
mind ends up in.  If any algorithm is patented in your country, you should
acquire a license before using this software.  Modified versions of this
software must contain an acknowledgement of the original author (=me).

This implementation is available at
http://www.submanifold.be

copyright 2000, Walied Othman
This header may not be removed.}

unit FGInt;
// Retained subset of Walied Othman's legacy source.

{$H+}
interface

uses SysUtils;

type
  TCompare = (compare_greater, compare_less, compare_equal, compare_error); // @size 1
  TSign = (negative, positive); // @size 1
  TFGInt = record // @size $08
    Sign: TSign; // @offset $00
    Number: array of LongWord; // @offset $04 Count followed by 31-bit limbs.
  end;

procedure zeronetochar8(var g : Char; const x : AnsiString); // @addr $69661C
procedure zeronetochar6(var g : Integer; const x : AnsiString); // @addr $6966B0
procedure initialize8(var trans : array of AnsiString); // @addr $6966F4 @ida "void __usercall $name(char **trans@<eax>, int trans_high@<edx>);"
procedure initialize6(var trans : array of AnsiString); // @addr $6968F4 @ida "void __usercall $name(char **trans@<eax>, int trans_high@<edx>);"
procedure FGIntDecodeBase64(const str64 : AnsiString; var str256 : AnsiString); // @addr $696A88
procedure ConvertBase256to2(const str256 : AnsiString; var str2 : AnsiString); // @addr $696BEC
procedure ConvertBase2to256(str2 : AnsiString; var str256 : AnsiString); // @addr $696CA4
procedure FGIntToBase2String(const FGInt : TFGInt; var S : AnsiString); // @addr $696DA4
procedure Base2StringToFGInt(S : AnsiString; var FGInt : TFGInt); // @addr $696E58
procedure FGIntFromBytes(str256 : AnsiString; var FGInt : TFGInt); // @addr $696FBC
procedure Base10StringToFGInt(Base10 : AnsiString; var FGInt : TFGInt); // @addr $69715C
procedure FGIntClear(var FGInt : TFGInt); // @addr $6973D8
function FGIntCompareAbs(const FGInt1, FGInt2 : TFGInt) : TCompare; // @addr $6973EC
procedure FGIntAdd(const FGInt1, FGInt2 : TFGInt; var Sum : TFGInt); // @addr $697458
procedure FGIntChangeSign(var FGInt : TFGInt); // @addr $69769C
procedure FGIntSub(var FGInt1, FGInt2, dif : TFGInt); // @addr $6976AC
procedure FGIntMulByIntbis(var FGInt : TFGInt; by : LongWord); // @addr $6976D4
procedure FGIntDivByIntBis(var FGInt : TFGInt; by : LongWord; var modres : LongWord); // @addr $6977BC
procedure FGIntAbs(var FGInt : TFGInt); // @addr $697898
procedure FGIntCopy(const FGInt1 : TFGInt; var FGInt2 : TFGInt); // @addr $69789C
procedure FGIntShiftRightBy31(var FGInt : TFGInt); // @addr $6978D4
procedure FGIntSubBis(var FGInt1 : TFGInt; const FGInt2 : TFGInt); // @addr $69792C
procedure FGIntMul(const FGInt1, FGInt2 : TFGInt; var Prod : TFGInt); // @addr $697A0C
procedure FGIntSquare(const FGInt : TFGInt; var Square : TFGInt); // @addr $697BBC
procedure FGIntShiftLeftBy31(var FGInt : TFGInt); // @addr $697DB0
procedure FGIntDivMod(var FGInt1, FGInt2, QFGInt, MFGInt : TFGInt); // @addr $697E0C
procedure FGIntMod(var FGInt1, FGInt2, MFGInt : TFGInt); // @addr $6981B8
procedure FGIntMulMod(var FGInt1, FGInt2, base, FGIntres : TFGInt); // @addr $698468
procedure FGIntModBis(const FGInt : TFGInt; var FGIntOut : TFGInt; b, head : LongWord); // @addr $6984E0
procedure FGIntMulModBis(const FGInt1, FGInt2 : TFGInt; var Prod : TFGInt; b, head : LongWord); // @addr $698588
procedure FGIntMontgomeryMod(const GInt, base, baseInv : TFGInt; var MGInt : TFGInt; b : LongWord; head : LongWord); // @addr $6987A4
procedure FGIntMontgomeryModExp(var FGInt, exp, modb, res : TFGInt); // @addr $6988F0
procedure FGIntGCD(const FGInt1, FGInt2 : TFGInt; var GCD : TFGInt); // @addr $698BD8
procedure FGIntModInv(const FGInt1, base : TFGInt; var Inverse : TFGInt); // @addr $698D10

procedure GIntDivByIntBis1(var GInt: TFGInt; by: LongWord; var modres: Word); // @addr $6970D0 @calls "0x00697330" @ida "void __usercall $name(TFGInt *GInt@<eax>, unsigned int by@<edx>, unsigned __int16 *modres@<ecx>, void *ParentFrame@<^0>);" @stackpop 0 Nested in Base10StringToFGInt.

var
  chr64: array[1..64] of Char = ('a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F',
    'g', 'G', 'h', 'H', 'i', 'I', 'j', 'J', 'k', 'K', 'l', 'L', 'm', 'M', 'n', 'N', 'o', 'O', 'p',
    'P', 'q', 'Q', 'r', 'R', 's', 'S', 't', 'T', 'u', 'U', 'v', 'V', 'w', 'W', 'x', 'X', 'y', 'Y',
    'z', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '='); // @addr $80F808

implementation

uses Math;

const
  // Each Number entry stores 31 payload bits; Number[0] stores the limb count.
  FGIntLimbBits = 31;
  FGIntLimbHighBit = 30;
  FGIntLimbMask = 2147483647;
  FGIntLimbBase = 2147483648;

{ @routine $69661C zeronetochar8 }
procedure zeronetochar8(var g : Char; const x : AnsiString);
var
  i : Integer;
  b : Byte;
begin
  b := 0;
  for i := 1 to 8 do
  begin
    if copy(x, i, 1) = '1' then
      b := b or (1 shl (8 - I));
  end;
  g := chr(b);
end;
{ @end $69661C }

{ @routine $6966B0 zeronetochar6 }
procedure zeronetochar6(var g : Integer; const x : AnsiString);
var
  I : Integer;
begin
  G := 0;
  for I := 1 to Length(X) do
  begin
    if I > 6 then
      break;
    if X[I] <> '0' then
      G := G or (1 shl (6 - I));
  end;
  Inc(G);
end;
{ @end $6966B0 }

{ @routine $6966F4 initialize8 }
procedure initialize8(var trans : array of AnsiString);
var
  c1, c2, c3, c4, c5, c6, c7, c8 : Integer;
  x : AnsiString;
  g : Char;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
              for c7 := 0 to 1 do
                for c8 := 0 to 1 do
                begin
                  x := chr(48+c1) + chr(48+c2) + chr(48+c3) + chr(48+c4) + chr(48+c5) + chr(48+c6) + chr(48+c7) + chr(48+c8);
                  zeronetochar8(g, x);
                  trans[ord(g)] := x;
                end;
end;
{ @end $6966F4 }

{ @routine $6968F4 initialize6 }
procedure initialize6(var trans : array of AnsiString);
var
  c1, c2, c3, c4, c5, c6 : Integer;
  x : AnsiString;
  g : Integer;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
            begin
              x := chr(48+c1) + chr(48+c2) + chr(48+c3) + chr(48+c4) + chr(48+c5) + chr(48+c6);
              zeronetochar6(g, x);
              trans[ord(chr64[g])] := x;
            end;
end;
{ @end $6968F4 }

{ @routine $696A88 FGIntDecodeBase64 }
procedure FGIntDecodeBase64(const str64 : AnsiString; var str256 : AnsiString);
var
  temp : AnsiString;
  trans : array[0..255] of AnsiString;
  i, len8 : LongInt;
  g : Char;
begin
  initialize6(trans);
  temp := '';
  for i := 1 to length(str64) do temp := temp + trans[ord(str64[i])];
  str256 := '';
  len8 := length(temp) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(temp, 1, 8));
    str256 := str256 + g;
    delete(temp, 1, 8);
  end;
end;
{ @end $696A88 }

{ @routine $696BEC ConvertBase256to2 }
procedure ConvertBase256to2(const str256 : AnsiString; var str2 : AnsiString);
var
  trans : array[0..255] of AnsiString;
  i : LongInt;
begin
  str2 := '';
  initialize8(trans);
  for i := 1 to length(str256) do str2 := str2 + trans[ord(str256[i])];
end;
{ @end $696BEC }

{ @routine $696CA4 ConvertBase2to256 }
procedure ConvertBase2to256(str2 : AnsiString; var str256 : AnsiString);
var
  i, len8 : LongInt;
  g : Char;
begin
  str256 := '';
  while (length(str2) mod 8) <> 0 do str2 := '0' + str2;
  len8 := length(str2) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(str2, 1, 8));
    str256 := str256 + g;
    delete(str2, 1, 8);
  end;
end;
{ @end $696CA4 }

{ @routine $696DA4 FGIntToBase2String }
procedure FGIntToBase2String(const FGInt : TFGInt; var S : AnsiString);
var
  i : LongWord;
  j : Integer;
begin
  S := '';
  for i := 1 to FGInt.Number[0] do
  begin
    for j := 0 to FGIntLimbHighBit do
      if (1 and (FGInt.Number[i] shr j)) = 1 then
        S := '1' + S
      else
        S := '0' + S;
  end;
  while (length(S) > 1) and (S[1] = '0') do
    delete(S, 1, 1);
  if S = '' then S := '0';
end;
{ @end $696DA4 }

{ @routine $696E58 Base2StringToFGInt }
procedure Base2StringToFGInt(S : AnsiString; var FGInt : TFGInt);
var
  i, j, size : LongWord;
begin
  while (S[1] = '0') and (length(S) > 1) do
    delete(S, 1, 1);
  size := length(S) div FGIntLimbBits;
  if (length(S) mod FGIntLimbBits) <> 0 then size := size + 1;
  SetLength(FGInt.Number, (size + 1));
  FGInt.Number[0] := size;
  j := 1;
  FGInt.Number[j] := 0;
  i := 0;
  while length(S) > 0 do
  begin
    if S[length(S)] = '1' then
      FGInt.Number[j] := FGInt.Number[j] or (1 shl i);
    i := i + 1;
    if i = FGIntLimbBits then
    begin
      i := 0;
      j := j + 1;
      if j <= size then FGInt.Number[j] := 0;
    end;
    delete(S, length(S), 1);
  end;
  FGInt.Sign := positive;
end;
{ @end $696E58 }

{ @routine $696FBC FGIntFromBytes }
procedure FGIntFromBytes(str256 : AnsiString; var FGInt : TFGInt);
var
  temp1 : AnsiString;
  i : LongInt;
  trans : array[0..255] of AnsiString;
begin
  temp1 := '';
  initialize8(trans);
  for i := 1 to length(str256) do temp1 := temp1 + trans[ord(str256[i])];
  while (temp1[1] = '0') and (temp1 <> '0') do delete(temp1, 1, 1);
  Base2StringToFGInt(temp1, FGInt);
end;
{ @end $696FBC }

{ @routine $69715C Base10StringToFGInt }
procedure Base10StringToFGInt(Base10 : AnsiString; var FGInt : TFGInt);
var
  i, size : LongWord;
  j : Word;
  S, x : AnsiString;
  sign : TSign;

  // @nested $6970D0 GIntDivByIntBis1
  procedure GIntDivByIntBis1(var GInt : TFGInt; by : LongWord; var modres : Word);
  var
    i, size, rest, temp : LongWord;
  begin
    size := GInt.Number[0];
    temp := 0;
    for i := size downto 1 do
    begin
      temp := temp * 10000;
      rest := temp + GInt.Number[i];
      GInt.Number[i] := rest div by;
      temp := rest mod by;
    end;
  modres := temp;
    while (GInt.Number[size] = 0) and (size > 1) do
      size := size - 1;
    if size <> GInt.Number[0] then
    begin
      SetLength(GInt.Number, size + 1);
      GInt.Number[0] := size;
    end;
  end;

begin
  while (not (Base10[1] In ['-', '0'..'9'])) and (length(Base10) > 1) do
    delete(Base10, 1, 1);
  if copy(Base10, 1, 1) = '-' then
  begin
    Sign := negative;
    delete(Base10, 1, 1);
  end
  else
    Sign := positive;
  while (length(Base10) > 1) and (copy(Base10, 1, 1) = '0') do
    delete(Base10, 1, 1);
  size := length(Base10) div 4;
  if (length(Base10) mod 4) <> 0 then size := size + 1;
  SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
  for i := 1 to (size - 1) do
  begin
    x := copy(Base10, length(Base10) - 3, 4);
    FGInt.Number[i] := StrToInt(x);
    delete(Base10, length(Base10) - 3, 4);
  end;
  FGInt.Number[size] := StrToInt(Base10);

  S := '';
  while (FGInt.Number[0] <> 1) or (FGInt.Number[1] <> 0) do
  begin
    GIntDivByIntBis1(FGInt, 2, j);
    S := inttostr(j) + S;
  end;
  if S = '' then S := '0';
  FGIntClear(FGInt);
  Base2StringToFGInt(S, FGInt);
  FGInt.Sign := sign;
end;
{ @end $69715C }

{ @routine $6973D8 FGIntClear }
procedure FGIntClear(var FGInt : TFGInt);
begin
  FGInt.Number := nil;
end;
{ @end $6973D8 }

{ @routine $6973EC FGIntCompareAbs }
function FGIntCompareAbs(const FGInt1, FGInt2 : TFGInt) : TCompare;
var
  size1, size2, i : LongWord;
begin
  FGIntCompareAbs := compare_error;
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 > size2 then FGIntCompareAbs := compare_greater
  else if size1 < size2 then FGIntCompareAbs := compare_less
  else
  begin
    i := size2;
    while (FGInt1.Number[i] = FGInt2.Number[i]) and (i > 1) do i := i - 1;
    if FGInt1.Number[i] = FGInt2.Number[i] then FGIntCompareAbs := compare_equal
    else if FGInt1.Number[i] < FGInt2.Number[i] then FGIntCompareAbs := compare_less
    else if FGInt1.Number[i] > FGInt2.Number[i] then FGIntCompareAbs := compare_greater;
  end;
end;
{ @end $6973EC }

{ @routine $697458 FGIntAdd }
procedure FGIntAdd(const FGInt1, FGInt2 : TFGInt; var Sum : TFGInt);
var
  i, size1, size2, size, rest, Trest : LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 < size2 then
    FGIntAdd(FGInt2, FGInt1, Sum)
  else
  begin
    if FGInt1.Sign = FGInt2.Sign then
    begin
      Sum.Sign := FGInt1.Sign;
      setlength(Sum.Number, (size1 + 2));
      rest := 0;
      for i := 1 to size2 do
      begin
        Trest := FGInt1.Number[i];
        Trest := Trest + FGInt2.Number[i];
        Trest := Trest + rest;
        Sum.Number[i] := Trest and FGIntLimbMask;
        rest := Trest shr FGIntLimbBits;
      end;
      for i := (size2 + 1) to size1 do
      begin
        Trest := FGInt1.Number[i] + rest;
        Sum.Number[i] := Trest and FGIntLimbMask;
        rest := Trest shr FGIntLimbBits;
      end;
      size := size1 + 1;
      Sum.Number[0] := size;
      Sum.Number[size] := rest;
      while (Sum.Number[size] = 0) and (size > 1) do
        size := size - 1;
      if Sum.Number[0] <> size then SetLength(Sum.Number, size + 1);
      Sum.Number[0] := size;
    end
    else
    begin
      if FGIntCompareAbs(FGInt2, FGInt1) = compare_greater then
        FGIntAdd(FGInt2, FGInt1, Sum)
      else
      begin
        SetLength(Sum.Number, (size1 + 1));
        rest := 0;
        for i := 1 to size2 do
        begin
          Trest := FGIntLimbBase;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - FGInt2.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and FGIntLimbMask;
          if (Trest > FGIntLimbMask) then
            rest := 0
          else
            rest := 1;
        end;
        for i := (size2 + 1) to size1 do
        begin
          Trest := FGIntLimbBase;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and FGIntLimbMask;
          if (Trest > FGIntLimbMask) then
            rest := 0
          else
            rest := 1;
        end;
        size := size1;
        while (Sum.Number[size] = 0) and (size > 1) do
          size := size - 1;
        if size <> size1 then SetLength(Sum.Number, size + 1);
        Sum.Number[0] := size;
        Sum.Sign := FGInt1.Sign;
      end;
    end;
  end;
end;
{ @end $697458 }

{ @routine $69769C FGIntChangeSign }
procedure FGIntChangeSign(var FGInt : TFGInt);
begin
  if FGInt.Sign = negative then FGInt.Sign := positive else FGInt.Sign := negative;
end;
{ @end $69769C }

{ @routine $6976AC FGIntSub }
procedure FGIntSub(var FGInt1, FGInt2, dif : TFGInt);
begin
  FGIntChangeSign(FGInt2);
  FGIntAdd(FGInt1, FGInt2, dif);
  FGIntChangeSign(FGInt2);
end;
{ @end $6976AC }

{ @routine $6976D4 FGIntMulByIntbis }
procedure FGIntMulByIntbis(var FGInt : TFGInt; by : LongWord);
var
  i, size, rest : LongWord;
  Trest : Int64;
begin
  size := FGInt.Number[0];
  Setlength(FGInt.Number, size + 2);
  rest := 0;
  for i := 1 to size do
  begin
    Trest := FGInt.Number[i];
    TRest := Trest * by;
    TRest := Trest + rest;
    FGInt.Number[i] := Trest and FGIntLimbMask;
    rest := Trest shr FGIntLimbBits;
  end;
  if rest <> 0 then
  begin
    size := size + 1;
    FGInt.Number[size] := rest;
  end
  else
    SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
end;
{ @end $6976D4 }

{ @routine $6977BC FGIntDivByIntBis }
procedure FGIntDivByIntBis(var FGInt : TFGInt; by : LongWord; var modres : LongWord);
var
  i, size : LongWord;
  temp, rest : Int64;
begin
  size := FGInt.Number[0];
  temp := 0;
  for i := size downto 1 do
  begin
    temp := temp shl FGIntLimbBits;
    rest := temp or FGInt.Number[i];
    FGInt.Number[i] := rest div by;
    temp := rest mod by;
  end;
  modres := temp;
  while (FGInt.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> FGInt.Number[0] then
  begin
    SetLength(FGInt.Number, size + 1);
    FGInt.Number[0] := size;
  end;
end;
{ @end $6977BC }

{ @routine $697898 FGIntAbs }
procedure FGIntAbs(var FGInt : TFGInt);
begin
  FGInt.Sign := positive;
end;
{ @end $697898 }

{ @routine $69789C FGIntCopy }
procedure FGIntCopy(const FGInt1 : TFGInt; var FGInt2 : TFGInt);
begin
  FGInt2.Sign := FGInt1.Sign;
  FGInt2.Number := nil;
  FGInt2.Number := Copy(FGInt1.Number, 0, FGInt1.Number[0] + 1);
end;
{ @end $69789C }

{ @routine $6978D4 FGIntShiftRightBy31 }
procedure FGIntShiftRightBy31(var FGInt : TFGInt);
var
  size, i : LongWord;
begin
  size := FGInt.Number[0];
  if size > 1 then
  begin
    for i := 1 to size - 1 do
    begin
      FGInt.Number[i] := FGInt.Number[i + 1];
    end;
    SetLength(FGInt.Number, Size);
    FGInt.Number[0] := size - 1;
  end
  else
    FGInt.Number[1] := 0;
end;
{ @end $6978D4 }

{ @routine $69792C FGIntSubBis }
procedure FGIntSubBis(var FGInt1 : TFGInt; const FGInt2 : TFGInt);
var
  i, size1, size2, rest, Trest : LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  rest := 0;
  for i := 1 to size2 do
  begin
    Trest := (FGIntLimbBase or FGInt1.Number[i]) - FGInt2.Number[i] - rest;
    if (Trest > FGIntLimbMask) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and FGIntLimbMask;
  end;
  for i := size2 + 1 to size1 do
  begin
    Trest := (FGIntLimbBase or FGInt1.Number[i]) - rest;
    if (Trest > FGIntLimbMask) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and FGIntLimbMask;
  end;
  i := size1;
  while (FGInt1.Number[i] = 0) and (i > 1) do
    i := i - 1;
  if i <> size1 then
  begin
    SetLength(FGInt1.Number, i + 1);
    FGInt1.Number[0] := i;
  end;
end;
{ @end $69792C }

{ @routine $697A0C FGIntMul }
procedure FGIntMul(const FGInt1, FGInt2 : TFGInt; var Prod : TFGInt);
var
  i, j, size, size1, size2, rest : LongWord;
  Trest : Int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := size1 + size2;
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    for j := 1 to size1 do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and FGIntLimbMask;
      rest := Trest shr FGIntLimbBits;
    end;
    Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;
{ @end $697A0C }

{ @routine $697BBC FGIntSquare }
procedure FGIntSquare(const FGInt : TFGInt; var Square : TFGInt);
var
  size, size1, i, j, rest : LongWord;
  Trest : Int64;
begin
  size1 := FGInt.Number[0];
  size := 2 * size1;
  SetLength(Square.Number, (size + 1));
  Square.Number[0] := size;
  for i := 1 to size do
    Square.Number[i] := 0;
  for i := 1 to size1 do
  begin
    Trest := FGInt.Number[i];
    Trest := Trest * FGInt.Number[i];
    Trest := Trest + Square.Number[2 * i - 1];
    Square.Number[2 * i - 1] := Trest and FGIntLimbMask;
    rest := Trest shr FGIntLimbBits;
    for j := i + 1 to size1 do
    begin
      Trest := FGInt.Number[i] shl 1;
      Trest := Trest * FGInt.Number[j];
      Trest := Trest + Square.Number[i + j - 1];
      Trest := Trest + rest;
      Square.Number[i + j - 1] := Trest and FGIntLimbMask;
      rest := Trest shr FGIntLimbBits;
    end;
    Square.Number[i + size1] := rest;
  end;
  Square.Sign := positive;
  while (Square.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> (2 * size1) then
  begin
    SetLength(Square.Number, size + 1);
    Square.Number[0] := size;
  end;
end;
{ @end $697BBC }

{ @routine $697DB0 FGIntShiftLeftBy31 }
procedure FGIntShiftLeftBy31(var FGInt : TFGInt);
var
  f1, f2 : LongWord;
  i, size : LongInt;
begin
  size := FGInt.Number[0];
  SetLength(FGInt.Number, size + 2);
  f1 := 0;
  for i := 1 to (size + 1) do
  begin
    f2 := FGInt.Number[i];
    FGInt.Number[i] := f1;
    f1 := f2;
  end;
  FGInt.Number[0] := size + 1;
end;
{ @end $697DB0 }

{ @routine $697E0C FGIntDivMod }
procedure FGIntDivMod(var FGInt1, FGInt2, QFGInt, MFGInt : TFGInt);
var
  one, zero, temp1, temp2 : TFGInt;
  s1, s2 : TSign;
  j, s, t : LongWord;
  i : Int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> compare_less then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    SetLength(QFGInt.Number, (s + 2));
    QFGInt.Number[0] := s + 1;
    for t := 1 to s do
    begin
      FGIntShiftLeftBy31(temp1);
      QFGInt.Number[t] := 0;
    end;
    j := s + 1;
    QFGInt.Number[j] := 0;
    while FGIntCompareAbs(MFGInt, FGInt2) <> compare_less do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> compare_less do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl FGIntLimbBits;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntbis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          QFGInt.Number[j] := QFGInt.Number[j] + i;
          if FGIntCompareAbs(MFGInt, temp2) <> compare_less then
          begin
            QFGInt.Number[j] := QFGInt.Number[j] + i;
            FGIntSubBis(MFGInt, temp2);
          end;
          FGIntClear(temp2);
        end
        else
        begin
          QFGInt.Number[j] := QFGInt.Number[j] + 1;
          FGIntSubBis(MFGInt, temp1);
        end;
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> compare_equal then
        begin
          FGIntShiftRightBy31(temp1);
          j := j - 1;
        end;
    end;
  end
  else
    Base10StringToFGInt('0', QFGInt);
  s := QFGInt.Number[0];
  while (s > 1) and (QFGInt.Number[s] = 0) do
    s := s - 1;
  if s < QFGInt.Number[0] then
  begin
    setlength(QFGInt.Number, s + 1);
    QFGInt.Number[0] := s;
  end;
  QFGInt.Sign := positive;

  FGIntClear(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> compare_equal then
    begin
      FGIntadd(QFGInt, one, temp1);
      FGIntClear(QFGInt);
      FGIntCopy(temp1, QFGInt);
      FGIntClear(temp1);
      FGIntsub(FGInt2, MFGInt, temp1);
      FGIntClear(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntClear(temp1);
    end;
    if s2 = positive then QFGInt.Sign := negative;
  end
  else
    QFGInt.Sign := s2;
  FGIntClear(one);
  FGIntClear(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;
{ @end $697E0C }

{ @routine $6981B8 FGIntMod }
procedure FGIntMod(var FGInt1, FGInt2, MFGInt : TFGInt);
var
  one, zero, temp1, temp2 : TFGInt;
  s1, s2 : TSign;
  s, t : LongWord;
  i : Int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> compare_less then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    for t := 1 to s do
      FGIntShiftLeftBy31(temp1);
    while FGIntCompareAbs(MFGInt, FGInt2) <> compare_less do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> compare_less do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl FGIntLimbBits;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntbis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          if FGIntCompareAbs(MFGInt, temp2) <> compare_less then
            FGIntSubBis(MFGInt, temp2);
          FGIntClear(temp2);
        end
        else
          FGIntSubBis(MFGInt, temp1);
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> compare_equal then FGIntShiftRightBy31(temp1);
    end;
  end;

  FGIntClear(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> compare_equal then
    begin
      FGIntSub(FGInt2, MFGInt, temp1);
      FGIntClear(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntClear(temp1);
    end;
  end;
  FGIntClear(one);
  FGIntClear(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;
{ @end $6981B8 }

{ @routine $698468 FGIntMulMod }
procedure FGIntMulMod(var FGInt1, FGInt2, base, FGIntres : TFGInt);
var
  temp : TFGInt;
begin
  FGIntMul(FGInt1, FGInt2, temp);
  FGIntMod(temp, base, FGIntres);
  FGIntClear(temp);
end;
{ @end $698468 }

{ @routine $6984E0 FGIntModBis }
procedure FGIntModBis(const FGInt : TFGInt; var FGIntOut : TFGInt; b, head : LongWord);
var
  i : LongWord;
begin
  if b <= FGInt.Number[0] then
  begin
    SetLength(FGIntOut.Number, (b + 1));
    for i := 0 to b do
      FGIntOut.Number[i] := FGInt.Number[i];
    FGIntOut.Number[b] := FGIntOut.Number[b] and head;
    i := b;
    while (FGIntOut.Number[i] = 0) and (i > 1) do
      i := i - 1;
    if i < b then SetLength(FGIntOut.Number, i + 1);
    FGIntOut.Number[0] := i;
    FGIntOut.Sign := positive;
  end
  else
    FGIntCopy(FGInt, FGIntOut);
end;
{ @end $6984E0 }

{ @routine $698588 FGIntMulModBis }
procedure FGIntMulModBis(const FGInt1, FGInt2 : TFGInt; var Prod : TFGInt; b, head : LongWord);
var
  i, j, size, size1, size2, t, rest : LongWord;
  Trest : Int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := min(b, size1 + size2);
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    t := min(size1, b - i + 1);
    for j := 1 to t do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and FGIntLimbMask;
      rest := Trest shr FGIntLimbBits;
    end;
    if (i + size1) <= b then Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  if size = b then Prod.Number[b] := Prod.Number[b] and head;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size < Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;
{ @end $698588 }

{ @routine $6987A4 FGIntMontgomeryMod }
procedure FGIntMontgomeryMod(const GInt, base, baseInv : TFGInt; var MGInt : TFGInt; b : LongWord; head : LongWord);
var
  m, temp, temp1 : TFGInt;
  r : LongWord;
begin
  FGIntModBis(GInt, temp, b, head);
  FGIntMulModBis(temp, baseInv, m, b, head);
  FGIntMul(m, base, temp1);
  FGIntClear(temp);
  FGIntAdd(temp1, GInt, temp);
  FGIntClear(temp1);
  MGInt.Number := copy(temp.Number, b - 1, temp.Number[0] - b + 2);
  MGInt.Sign := positive;
  MGInt.Number[0] := temp.Number[0] - b + 1;
  FGIntClear(temp);
  if (head shr FGIntLimbHighBit) = 0 then FGIntDivByIntBis(MGInt, head + 1, r)
  else FGIntShiftRightBy31(MGInt);
  if FGIntCompareAbs(MGInt, base) <> compare_less then FGIntSubBis(MGInt, base);
  FGIntClear(temp);
  FGIntClear(m);
end;
{ @end $6987A4 }

{ @routine $6988F0 FGIntMontgomeryModExp }
procedure FGIntMontgomeryModExp(var FGInt, exp, modb, res : TFGInt);
var
  temp2, temp3, baseInv, r, zero : TFGInt;
  i, j, t, b, head : LongWord;
  S: AnsiString;
begin
  Base2StringToFGInt('0', zero);
  FGIntMod(FGInt, modb, res);
  if FGIntCompareAbs(res, zero) = compare_equal then
  begin
    FGIntClear(zero);
    exit;
  end
  else FGIntClear(res);
  FGIntClear(zero);

  FGIntToBase2String(exp, S);
  t := modb.Number[0];
  b := t;

  if (modb.Number[t] shr FGIntLimbHighBit) = 1 then t := t + 1;
  SetLength(r.Number, (t + 1));
  r.Number[0] := t;
  r.Sign := positive;
  for i := 1 to t do
    r.Number[i] := 0;
  if t = modb.Number[0] then
  begin
    head := FGIntLimbMask;
    for j := 29 downto 0 do
    begin
      head := head shr 1;
      if (modb.Number[t] shr j) = 1 then
      begin
        r.Number[t] := 1 shl (j + 1);
        break;
      end;
    end;
  end
  else
  begin
    r.Number[t] := 1;
    head := FGIntLimbMask;
  end;

  FGIntModInv(modb, r, temp2);
  if temp2.Sign = negative then
    FGIntCopy(temp2, BaseInv)
  else
  begin
    FGIntCopy(r, BaseInv);
    FGIntSubBis(BaseInv, temp2);
  end;
//   FGIntBezoutBachet(r, modb, temp2, BaseInv);
  FGIntAbs(BaseInv);
  FGIntClear(temp2);
  FGIntMod(r, modb, res);
  FGIntMulMod(FGInt, res, modb, temp2);
  FGIntClear(r);

  for i := length(S) downto 1 do
  begin
    if S[i] = '1' then
    begin
      FGIntmul(res, temp2, temp3);
      FGIntClear(res);
      FGIntMontgomeryMod(temp3, modb, baseinv, res, b, head);
      FGIntClear(temp3);
    end;
    FGIntSquare(temp2, temp3);
    FGIntClear(temp2);
    FGIntMontgomeryMod(temp3, modb, baseinv, temp2, b, head);
    FGIntClear(temp3);
  end;
  FGIntClear(temp2);
  FGIntMontgomeryMod(res, modb, baseinv, temp3, b, head);
  FGIntCopy(temp3, res);
  FGIntClear(temp3);
  FGIntClear(baseinv);
end;
{ @end $6988F0 }

{ @routine $698BD8 FGIntGCD }
procedure FGIntGCD(const FGInt1, FGInt2 : TFGInt; var GCD : TFGInt);
var
  k : TCompare;
  zero, temp1, temp2, temp3 : TFGInt;
begin
  k := FGIntCompareAbs(FGInt1, FGInt2);
  if (k = compare_equal) then FGIntCopy(FGInt1, GCD)
  else if (k = compare_less) then FGIntGCD(FGInt2, FGInt1, GCD)
  else
  begin
    Base10StringToFGInt('0', zero);
    FGIntCopy(FGInt1, temp1);
    FGIntCopy(FGInt2, temp2);
    while (temp2.Number[0] <> 1) or (temp2.Number[1] <> 0) do
    begin
      FGIntMod(temp1, temp2, temp3);
      FGIntCopy(temp2, temp1);
      FGIntCopy(temp3, temp2);
      FGIntClear(temp3);
    end;
    FGIntCopy(temp1, GCD);
    FGIntClear(temp2);
    FGIntClear(zero);
  end;
end;
{ @end $698BD8 }

{ @routine $698D10 FGIntModInv }
procedure FGIntModInv(const FGInt1, base : TFGInt; var Inverse : TFGInt);
var
  zero, one, r1, r2, r3, tb, gcd, temp, temp1, temp2 : TFGInt;
begin
  Base10StringToFGInt('1', one);
  FGIntGCD(FGInt1, base, gcd);
  if FGIntCompareAbs(one, gcd) = compare_equal then
  begin
    FGIntcopy(base, r1);
    FGIntcopy(FGInt1, r2);
    Base10StringToFGInt('0', zero);
    Base10StringToFGInt('0', inverse);
    Base10StringToFGInt('1', tb);

    repeat
      FGIntClear(r3);
      FGIntdivmod(r1, r2, temp, r3);
      FGIntCopy(r2, r1);
      FGIntCopy(r3, r2);

      FGIntmul(tb, temp, temp1);
      FGIntsub(inverse, temp1, temp2);
      FGIntClear(inverse);
      FGIntClear(temp1);
      FGIntCopy(tb, inverse);
      FGIntCopy(temp2, tb);

      FGIntClear(temp);
    until FGIntCompareAbs(r3, zero) = compare_equal;

    if inverse.Sign = negative then
    begin
      FGIntadd(base, inverse, temp);
      FGIntCopy(temp, inverse);
    end;

    FGIntClear(tb);
    FGIntClear(r1);
    FGIntClear(r2);
  end;
  FGIntClear(gcd);
  FGIntClear(one);
end;
{ @end $698D10 }

end.
