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
  TCompare = (Lt, St, Eq, Er); // @size 1
  TSign = (negative, positive); // @size 1
  TFGInt = record // @size $08 Native record RTTI $6C5BA4.
    Sign: TSign; // @offset $00
    Number: array of LongWord; // @offset $04 Count followed by 31-bit limbs.
  end;

Procedure zeronetochar8(Var g : char; Const x : AnsiString); // @addr $6C5BBC
Procedure zeronetochar6(Var g : integer; Const x : AnsiString); // @addr $6C5C58
Procedure initialize8(Var trans : Array Of AnsiString); // @addr $6C5CCC @ida "void __usercall $name(char **trans@<eax>, int trans_high@<edx>);"
Procedure initialize6(Var trans : Array Of AnsiString); // @addr $6C5EE8 @ida "void __usercall $name(char **trans@<eax>, int trans_high@<edx>);"
Procedure FGIntDecodeBase64(Const str64 : AnsiString; Var str256 : AnsiString); // @addr $6C6094
Procedure ConvertBase256to2(Const str256 : AnsiString; Var str2 : AnsiString); // @addr $6C6224
Procedure ConvertBase2to256(str2 : AnsiString; Var str256 : AnsiString); // @addr $6C62EC
Procedure FGIntToBase2String(Const FGInt : TFGInt; Var S : AnsiString); // @addr $6C6410
Procedure Base2StringToFGInt(S : AnsiString; Var FGInt : TFGInt); // @addr $6C64EC
Procedure FGIntFromBytes(str256 : AnsiString; Var FGInt : TFGInt); // @addr $6C668C
Procedure Base10StringToFGInt(Base10 : AnsiString; Var FGInt : TFGInt); // @addr $6C687C
Procedure FGIntClear(Var FGInt : TFGInt); // @addr $6C6B48
Function FGIntCompareAbs(Const FGInt1, FGInt2 : TFGInt) : TCompare; // @addr $6C6B64
Procedure FGIntAdd(Const FGInt1, FGInt2 : TFGInt; Var Sum : TFGInt); // @addr $6C6C3C
Procedure FGIntChangeSign(Var FGInt : TFGInt); // @addr $6C6F48
Procedure FGIntSub(Var FGInt1, FGInt2, dif : TFGInt); // @addr $6C6F6C
Procedure FGIntMulByIntbis(Var FGInt : TFGInt; by : LongWord); // @addr $6C6FA0
Procedure FGIntDivByIntBis(Var FGInt : TFGInt; by : LongWord; Var modres : LongWord); // @addr $6C70A0
Procedure FGIntAbs(Var FGInt : TFGInt); // @addr $6C719C
Procedure FGIntCopy(Const FGInt1 : TFGInt; Var FGInt2 : TFGInt); // @addr $6C71AC
Procedure FGIntShiftRightBy31(Var FGInt : TFGInt); // @addr $6C71FC
Procedure FGIntSubBis(Var FGInt1 : TFGInt; Const FGInt2 : TFGInt); // @addr $6C7284
Procedure FGIntMul(Const FGInt1, FGInt2 : TFGInt; Var Prod : TFGInt); // @addr $6C73C4
Procedure FGIntSquare(Const FGInt : TFGInt; Var Square : TFGInt); // @addr $6C7598
Procedure FGIntShiftLeftBy31(Var FGInt : TFGInt); // @addr $6C77BC
Procedure FGIntDivMod(Var FGInt1, FGInt2, QFGInt, MFGInt : TFGInt); // @addr $6C7844
Procedure FGIntMod(Var FGInt1, FGInt2, MFGInt : TFGInt); // @addr $6C7C60
Procedure FGIntMulMod(Var FGInt1, FGInt2, base, FGIntres : TFGInt); // @addr $6C7F54
Procedure FGIntModBis(Const FGInt : TFGInt; Var FGIntOut : TFGInt; b, head : LongWord); // @addr $6C7FCC
Procedure FGIntMulModBis(Const FGInt1, FGInt2 : TFGInt; Var Prod : TFGInt; b, head : LongWord); // @addr $6C80B8
Procedure FGIntMontgomeryMod(Const GInt, base, baseInv : TFGInt; Var MGInt : TFGInt; b : Longword; head : LongWord); // @addr $6C8330
Procedure FGIntMontgomeryModExp(Var FGInt, exp, modb, res : TFGInt); // @addr $6C8488
Procedure FGIntGCD(Const FGInt1, FGInt2 : TFGInt; Var GCD : TFGInt); // @addr $6C87BC
Procedure FGIntModInv(Const FGInt1, base : TFGInt; Var Inverse : TFGInt); // @addr $6C8900

Procedure GIntDivByIntBis1(Var GInt: TFGInt; by: LongWord; Var modres: Word); // @addr $6C67B0 @ida "void __usercall $name(TFGInt *GInt@<eax>, unsigned int by@<edx>, unsigned __int16 *modres@<ecx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x6C6A8F" Nested in Base10StringToFGInt.

var
  chr64: array[1..64] of Char = ('a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F',
    'g', 'G', 'h', 'H', 'i', 'I', 'j', 'J', 'k', 'K', 'l', 'L', 'm', 'M', 'n', 'N', 'o', 'O', 'p',
    'P', 'q', 'Q', 'r', 'R', 's', 'S', 't', 'T', 'u', 'U', 'v', 'V', 'w', 'W', 'x', 'X', 'y', 'Y',
    'z', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '='); // @addr $87B8A8

implementation

uses Math;

{ @routine $6C5BBC zeronetochar8 }
Procedure zeronetochar8(Var g : char; Const x : AnsiString);
Var
   i : Integer;
   b : byte;
Begin
   b := 0;
   For i := 1 To 8 Do
   Begin
      If copy(x, i, 1) = '1' Then
         b := b Or (1 Shl (8 - I));
   End;
   g := chr(b);
End;
{ @end $6C5BBC }

{ @routine $6C5C58 zeronetochar6 }
Procedure zeronetochar6(Var g : integer; Const x : AnsiString);
Var
   I : Integer;
Begin
   G := 0;
   For I := 1 To Length(X) Do
   Begin
      If I > 6 Then
         Break;
      If X[I] <> '0' Then
         G := G Or (1 Shl (6 - I));
   End;
   Inc(G);
End;
{ @end $6C5C58 }

{ @routine $6C5CCC initialize8 }
Procedure initialize8(Var trans : Array Of AnsiString);
Var
   c1, c2, c3, c4, c5, c6, c7, c8 : integer;
   x : AnsiString;
   g : char;
Begin
   For c1 := 0 To 1 Do
      For c2 := 0 To 1 Do
         For c3 := 0 To 1 Do
            For c4 := 0 To 1 Do
               For c5 := 0 To 1 Do
                  For c6 := 0 To 1 Do
                     For c7 := 0 To 1 Do
                        For c8 := 0 To 1 Do
                        Begin
                           x := chr(48+c1) + chr(48+c2) + chr(48+c3) + chr(48+c4) + chr(48+c5) + chr(48+c6) + chr(48+c7) + chr(48+c8);
                           zeronetochar8(g, x);
                           trans[ord(g)] := x;
                        End;
End;
{ @end $6C5CCC }

{ @routine $6C5EE8 initialize6 }
Procedure initialize6(Var trans : Array Of AnsiString);
Var
   c1, c2, c3, c4, c5, c6 : integer;
   x : AnsiString;
   g : integer;
Begin
   For c1 := 0 To 1 Do
      For c2 := 0 To 1 Do
         For c3 := 0 To 1 Do
            For c4 := 0 To 1 Do
               For c5 := 0 To 1 Do
                  For c6 := 0 To 1 Do
                  Begin
                     x := chr(48+c1) + chr(48+c2) + chr(48+c3) + chr(48+c4) + chr(48+c5) + chr(48+c6);
                     zeronetochar6(g, x);
                     trans[ord(chr64[g])] := x;
                  End;
End;
{ @end $6C5EE8 }

{ @routine $6C6094 FGIntDecodeBase64 }
Procedure FGIntDecodeBase64(Const str64 : AnsiString; Var str256 : AnsiString);
Var
   temp : AnsiString;
   trans : Array[0..255] Of AnsiString;
   i, len8 : longint;
   g : char;
Begin
   initialize6(trans);
   temp := '';
   For i := 1 To length(str64) Do temp := temp + trans[ord(str64[i])];
   str256 := '';
   len8 := length(temp) Div 8;
   For i := 1 To len8 Do
   Begin
      zeronetochar8(g, copy(temp, 1, 8));
      str256 := str256 + g;
      delete(temp, 1, 8);
   End;
End;
{ @end $6C6094 }

{ @routine $6C6224 ConvertBase256to2 }
Procedure ConvertBase256to2(Const str256 : AnsiString; Var str2 : AnsiString);
Var
   trans : Array[0..255] Of AnsiString;
   i : longint;
Begin
   str2 := '';
   initialize8(trans);
   For i := 1 To length(str256) Do str2 := str2 + trans[ord(str256[i])];
End;
{ @end $6C6224 }

{ @routine $6C62EC ConvertBase2to256 }
Procedure ConvertBase2to256(str2 : AnsiString; Var str256 : AnsiString);
Var
   i, len8 : longint;
   g : char;
Begin
   str256 := '';
   While (length(str2) Mod 8) <> 0 Do str2 := '0' + str2;
   len8 := length(str2) Div 8;
   For i := 1 To len8 Do
   Begin
      zeronetochar8(g, copy(str2, 1, 8));
      str256 := str256 + g;
      delete(str2, 1, 8);
   End;
End;
{ @end $6C62EC }

{ @routine $6C6410 FGIntToBase2String }
Procedure FGIntToBase2String(Const FGInt : TFGInt; Var S : AnsiString);
Var
   i : LongWord;
   j : integer;
Begin
   S := '';
   For i := 1 To FGInt.Number[0] Do
   Begin
      For j := 0 To 30 Do
         If (1 And (FGInt.Number[i] Shr j)) = 1 Then
            S := '1' + S
         Else
            S := '0' + S;
   End;
   While (length(S) > 1) And (S[1] = '0') Do
      delete(S, 1, 1);
   If S = '' Then S := '0';
End;
{ @end $6C6410 }

{ @routine $6C64EC Base2StringToFGInt }
Procedure Base2StringToFGInt(S : AnsiString; Var FGInt : TFGInt);
Var
   i, j, size : LongWord;
Begin
   While (S[1] = '0') And (length(S) > 1) Do
      delete(S, 1, 1);
   size := length(S) Div 31;
   If (length(S) Mod 31) <> 0 Then size := size + 1;
   SetLength(FGInt.Number, (size + 1));
   FGInt.Number[0] := size;
   j := 1;
   FGInt.Number[j] := 0;
   i := 0;
   While length(S) > 0 Do
   Begin
      If S[length(S)] = '1' Then
         FGInt.Number[j] := FGInt.Number[j] Or (1 Shl i);
      i := i + 1;
      If i = 31 Then
      Begin
         i := 0;
         j := j + 1;
         If j <= size Then FGInt.Number[j] := 0;
      End;
      delete(S, length(S), 1);
   End;
   FGInt.Sign := positive;
End;
{ @end $6C64EC }

{ @routine $6C668C FGIntFromBytes }
Procedure FGIntFromBytes(str256 : AnsiString; Var FGInt : TFGInt);
Var
   temp1 : AnsiString;
   i : longint;
   trans : Array[0..255] Of AnsiString;
Begin
   temp1 := '';
   initialize8(trans);
   For i := 1 To length(str256) Do temp1 := temp1 + trans[ord(str256[i])];
   While (temp1[1] = '0') And (temp1 <> '0') Do delete(temp1, 1, 1);
   Base2StringToFGInt(temp1, FGInt);
End;
{ @end $6C668C }

{ @routine $6C687C Base10StringToFGInt }
Procedure Base10StringToFGInt(Base10 : AnsiString; Var FGInt : TFGInt);
Var
   i, size : LongWord;
   j : word;
   S, x : AnsiString;
   sign : TSign;

   // @nested $6C67B0 GIntDivByIntBis1
   Procedure GIntDivByIntBis1(Var GInt : TFGInt; by : LongWord; Var modres : word);
   Var
      i, size, rest, temp : LongWord;
   Begin
      size := GInt.Number[0];
      temp := 0;
      For i := size Downto 1 Do
      Begin
         temp := temp * 10000;
         rest := temp + GInt.Number[i];
         GInt.Number[i] := rest Div by;
         temp := rest Mod by;
      End;
	modres := temp;
      While (GInt.Number[size] = 0) And (size > 1) Do
         size := size - 1;
      If size <> GInt.Number[0] Then
      Begin
         SetLength(GInt.Number, size + 1);
         GInt.Number[0] := size;
      End;
   End;

Begin
   While (Not (Base10[1] In ['-', '0'..'9'])) And (length(Base10) > 1) Do
      delete(Base10, 1, 1);
   If copy(Base10, 1, 1) = '-' Then
   Begin
      Sign := negative;
      delete(Base10, 1, 1);
   End
   Else
      Sign := positive;
   While (length(Base10) > 1) And (copy(Base10, 1, 1) = '0') Do
      delete(Base10, 1, 1);
   size := length(Base10) Div 4;
   If (length(Base10) Mod 4) <> 0 Then size := size + 1;
   SetLength(FGInt.Number, size + 1);
   FGInt.Number[0] := size;
   For i := 1 To (size - 1) Do
   Begin
      x := copy(Base10, length(Base10) - 3, 4);
      FGInt.Number[i] := StrToInt(x);
      delete(Base10, length(Base10) - 3, 4);
   End;
   FGInt.Number[size] := StrToInt(Base10);

   S := '';
   While (FGInt.Number[0] <> 1) Or (FGInt.Number[1] <> 0) Do
   Begin
      GIntDivByIntBis1(FGInt, 2, j);
      S := inttostr(j) + S;
   End;
   If S = '' Then S := '0';
   FGIntClear(FGInt);
   Base2StringToFGInt(S, FGInt);
   FGInt.Sign := sign;
End;
{ @end $6C687C }

{ @routine $6C6B48 FGIntClear }
Procedure FGIntClear(Var FGInt : TFGInt);
Begin
   FGInt.Number := Nil;
End;
{ @end $6C6B48 }

{ @routine $6C6B64 FGIntCompareAbs }
Function FGIntCompareAbs(Const FGInt1, FGInt2 : TFGInt) : TCompare;
Var
   size1, size2, i : LongWord;
Begin
   FGIntCompareAbs := Er;
   size1 := FGInt1.Number[0];
   size2 := FGInt2.Number[0];
   If size1 > size2 Then FGIntCompareAbs := Lt Else
      If size1 < size2 Then FGIntCompareAbs := St Else
      Begin
         i := size2;
         While (FGInt1.Number[i] = FGInt2.Number[i]) And (i > 1) Do i := i - 1;
         If FGInt1.Number[i] = FGInt2.Number[i] Then FGIntCompareAbs := Eq Else
            If FGInt1.Number[i] < FGInt2.Number[i] Then FGIntCompareAbs := St Else
               If FGInt1.Number[i] > FGInt2.Number[i] Then FGIntCompareAbs := Lt;
      End;
End;
{ @end $6C6B64 }

{ @routine $6C6C3C FGIntAdd }
Procedure FGIntAdd(Const FGInt1, FGInt2 : TFGInt; Var Sum : TFGInt);
Var
   i, size1, size2, size, rest, Trest : LongWord;
Begin
   size1 := FGInt1.Number[0];
   size2 := FGInt2.Number[0];
   If size1 < size2 Then
      FGIntAdd(FGInt2, FGInt1, Sum)
   Else
   Begin
      If FGInt1.Sign = FGInt2.Sign Then
      Begin
         Sum.Sign := FGInt1.Sign;
         setlength(Sum.Number, (size1 + 2));
         rest := 0;
         For i := 1 To size2 Do
         Begin
            Trest := FGInt1.Number[i];
            Trest := Trest + FGInt2.Number[i];
            Trest := Trest + rest;
            Sum.Number[i] := Trest And 2147483647;
            rest := Trest Shr 31;
         End;
         For i := (size2 + 1) To size1 Do
         Begin
            Trest := FGInt1.Number[i] + rest;
            Sum.Number[i] := Trest And 2147483647;
            rest := Trest Shr 31;
         End;
         size := size1 + 1;
         Sum.Number[0] := size;
         Sum.Number[size] := rest;
         While (Sum.Number[size] = 0) And (size > 1) Do
            size := size - 1;
         If Sum.Number[0] <> size Then SetLength(Sum.Number, size + 1);
         Sum.Number[0] := size;
      End
      Else
      Begin
         If FGIntCompareAbs(FGInt2, FGInt1) = Lt Then
            FGIntAdd(FGInt2, FGInt1, Sum)
         Else
         Begin
            SetLength(Sum.Number, (size1 + 1));
            rest := 0;
            For i := 1 To size2 Do
            Begin
               Trest := 2147483648;
               TRest := Trest + FGInt1.Number[i];
               TRest := Trest - FGInt2.Number[i];
               TRest := Trest - rest;
               Sum.Number[i] := Trest And 2147483647;
               If (Trest > 2147483647) Then
                  rest := 0
               Else
                  rest := 1;
            End;
            For i := (size2 + 1) To size1 Do
            Begin
               Trest := 2147483648;
               TRest := Trest + FGInt1.Number[i];
               TRest := Trest - rest;
               Sum.Number[i] := Trest And 2147483647;
               If (Trest > 2147483647) Then
                  rest := 0
               Else
                  rest := 1;
            End;
            size := size1;
            While (Sum.Number[size] = 0) And (size > 1) Do
               size := size - 1;
            If size <> size1 Then SetLength(Sum.Number, size + 1);
            Sum.Number[0] := size;
            Sum.Sign := FGInt1.Sign;
         End;
      End;
   End;
End;
{ @end $6C6C3C }

{ @routine $6C6F48 FGIntChangeSign }
Procedure FGIntChangeSign(Var FGInt : TFGInt);
Begin
   If FGInt.Sign = negative Then FGInt.Sign := positive Else FGInt.Sign := negative;
End;
{ @end $6C6F48 }

{ @routine $6C6F6C FGIntSub }
Procedure FGIntSub(Var FGInt1, FGInt2, dif : TFGInt);
Begin
   FGIntChangeSign(FGInt2);
   FGIntAdd(FGInt1, FGInt2, dif);
   FGIntChangeSign(FGInt2);
End;
{ @end $6C6F6C }

{ @routine $6C6FA0 FGIntMulByIntbis }
Procedure FGIntMulByIntbis(Var FGInt : TFGInt; by : LongWord);
Var
   i, size, rest : LongWord;
   Trest : int64;
Begin
   size := FGInt.Number[0];
   Setlength(FGInt.Number, size + 2);
   rest := 0;
   For i := 1 To size Do
   Begin
      Trest := FGInt.Number[i];
      TRest := Trest * by;
      TRest := Trest + rest;
      FGInt.Number[i] := Trest And 2147483647;
      rest := Trest Shr 31;
   End;
   If rest <> 0 Then
   Begin
      size := size + 1;
      FGInt.Number[size] := rest;
   End
   Else
      SetLength(FGInt.Number, size + 1);
   FGInt.Number[0] := size;
End;
{ @end $6C6FA0 }

{ @routine $6C70A0 FGIntDivByIntBis }
Procedure FGIntDivByIntBis(Var FGInt : TFGInt; by : LongWord; Var modres : LongWord);
Var
   i, size : LongWord;
   temp, rest : int64;
Begin
   size := FGInt.Number[0];
   temp := 0;
   For i := size Downto 1 Do
   Begin
      temp := temp Shl 31;
      rest := temp Or FGInt.Number[i];
      FGInt.Number[i] := rest Div by;
      temp := rest Mod by;
   End;
   modres := temp;
   While (FGInt.Number[size] = 0) And (size > 1) Do
      size := size - 1;
   If size <> FGInt.Number[0] Then
   Begin
      SetLength(FGInt.Number, size + 1);
      FGInt.Number[0] := size;
   End;
End;
{ @end $6C70A0 }

{ @routine $6C719C FGIntAbs }
Procedure FGIntAbs(Var FGInt : TFGInt);
Begin
   FGInt.Sign := positive;
End;
{ @end $6C719C }

{ @routine $6C71AC FGIntCopy }
Procedure FGIntCopy(Const FGInt1 : TFGInt; Var FGInt2 : TFGInt);
Begin
   FGInt2.Sign := FGInt1.Sign;
   FGInt2.Number := Nil;
   FGInt2.Number := Copy(FGInt1.Number, 0, FGInt1.Number[0] + 1);
End;
{ @end $6C71AC }

{ @routine $6C71FC FGIntShiftRightBy31 }
Procedure FGIntShiftRightBy31(Var FGInt : TFGInt);
Var
   size, i : LongWord;
Begin
   size := FGInt.Number[0];
   If size > 1 Then
   Begin
      For i := 1 To size - 1 Do
      Begin
         FGInt.Number[i] := FGInt.Number[i + 1];
      End;
      SetLength(FGInt.Number, Size);
      FGInt.Number[0] := size - 1;
   End
   Else
      FGInt.Number[1] := 0;
End;
{ @end $6C71FC }

{ @routine $6C7284 FGIntSubBis }
Procedure FGIntSubBis(Var FGInt1 : TFGInt; Const FGInt2 : TFGInt);
Var
   i, size1, size2, rest, Trest : LongWord;
Begin
   size1 := FGInt1.Number[0];
   size2 := FGInt2.Number[0];
   rest := 0;
   For i := 1 To size2 Do
   Begin
      Trest := (2147483648 Or FGInt1.Number[i]) - FGInt2.Number[i] - rest;
      If (Trest > 2147483647) Then
         rest := 0
      Else
         rest := 1;
      FGInt1.Number[i] := Trest And 2147483647;
   End;
   For i := size2 + 1 To size1 Do
   Begin
      Trest := (2147483648 Or FGInt1.Number[i]) - rest;
      If (Trest > 2147483647) Then
         rest := 0
      Else
         rest := 1;
      FGInt1.Number[i] := Trest And 2147483647;
   End;
   i := size1;
   While (FGInt1.Number[i] = 0) And (i > 1) Do
      i := i - 1;
   If i <> size1 Then
   Begin
      SetLength(FGInt1.Number, i + 1);
      FGInt1.Number[0] := i;
   End;
End;
{ @end $6C7284 }

{ @routine $6C73C4 FGIntMul }
Procedure FGIntMul(Const FGInt1, FGInt2 : TFGInt; Var Prod : TFGInt);
Var
   i, j, size, size1, size2, rest : LongWord;
   Trest : int64;
Begin
   size1 := FGInt1.Number[0];
   size2 := FGInt2.Number[0];
   size := size1 + size2;
   SetLength(Prod.Number, (size + 1));
   For i := 1 To size Do
      Prod.Number[i] := 0;

   For i := 1 To size2 Do
   Begin
      rest := 0;
      For j := 1 To size1 Do
      Begin
         Trest := FGInt1.Number[j];
         Trest := Trest * FGInt2.Number[i];
         Trest := Trest + Prod.Number[j + i - 1];
         Trest := Trest + rest;
         Prod.Number[j + i - 1] := Trest And 2147483647;
         rest := Trest Shr 31;
      End;
      Prod.Number[i + size1] := rest;
   End;

   Prod.Number[0] := size;
   While (Prod.Number[size] = 0) And (size > 1) Do
      size := size - 1;
   If size <> Prod.Number[0] Then
   Begin
      SetLength(Prod.Number, size + 1);
      Prod.Number[0] := size;
   End;
   If FGInt1.Sign = FGInt2.Sign Then
      Prod.Sign := Positive
   Else
      prod.Sign := negative;
End;
{ @end $6C73C4 }

{ @routine $6C7598 FGIntSquare }
Procedure FGIntSquare(Const FGInt : TFGInt; Var Square : TFGInt);
Var
   size, size1, i, j, rest : LongWord;
   Trest : int64;
Begin
   size1 := FGInt.Number[0];
   size := 2 * size1;
   SetLength(Square.Number, (size + 1));
   Square.Number[0] := size;
   For i := 1 To size Do
      Square.Number[i] := 0;
   For i := 1 To size1 Do
   Begin
      Trest := FGInt.Number[i];
      Trest := Trest * FGInt.Number[i];
      Trest := Trest + Square.Number[2 * i - 1];
      Square.Number[2 * i - 1] := Trest And 2147483647;
      rest := Trest Shr 31;
      For j := i + 1 To size1 Do
      Begin
         Trest := FGInt.Number[i] Shl 1;
         Trest := Trest * FGInt.Number[j];
         Trest := Trest + Square.Number[i + j - 1];
         Trest := Trest + rest;
         Square.Number[i + j - 1] := Trest And 2147483647;
         rest := Trest Shr 31;
      End;
      Square.Number[i + size1] := rest;
   End;
   Square.Sign := positive;
   While (Square.Number[size] = 0) And (size > 1) Do
      size := size - 1;
   If size <> (2 * size1) Then
   Begin
      SetLength(Square.Number, size + 1);
      Square.Number[0] := size;
   End;
End;
{ @end $6C7598 }

{ @routine $6C77BC FGIntShiftLeftBy31 }
Procedure FGIntShiftLeftBy31(Var FGInt : TFGInt);
Var
   f1, f2 : LongWord;
   i, size : longint;
Begin
   size := FGInt.Number[0];
   SetLength(FGInt.Number, size + 2);
   f1 := 0;
   For i := 1 To (size + 1) Do
   Begin
      f2 := FGInt.Number[i];
      FGInt.Number[i] := f1;
      f1 := f2;
   End;
   FGInt.Number[0] := size + 1;
End;
{ @end $6C77BC }

{ @routine $6C7844 FGIntDivMod }
Procedure FGIntDivMod(Var FGInt1, FGInt2, QFGInt, MFGInt : TFGInt);
Var
   one, zero, temp1, temp2 : TFGInt;
   s1, s2 : TSign;
   j, s, t : LongWord;
   i : int64;
Begin
   s1 := FGInt1.Sign;
   s2 := FGInt2.Sign;
   FGIntAbs(FGInt1);
   FGIntAbs(FGInt2);
   FGIntCopy(FGInt1, MFGInt);
   FGIntCopy(FGInt2, temp1);

   If FGIntCompareAbs(FGInt1, FGInt2) <> St Then
   Begin
      s := FGInt1.Number[0] - FGInt2.Number[0];
      SetLength(QFGInt.Number, (s + 2));
      QFGInt.Number[0] := s + 1;
      For t := 1 To s Do
      Begin
         FGIntShiftLeftBy31(temp1);
         QFGInt.Number[t] := 0;
      End;
      j := s + 1;
      QFGInt.Number[j] := 0;
      While FGIntCompareAbs(MFGInt, FGInt2) <> St Do
      Begin
         While FGIntCompareAbs(MFGInt, temp1) <> St Do
         Begin
            If MFGInt.Number[0] > temp1.Number[0] Then
            Begin
               i := MFGInt.Number[MFGInt.Number[0]];
               i := i Shl 31;
               i := i + MFGInt.Number[MFGInt.Number[0] - 1];
               i := i Div (temp1.Number[temp1.Number[0]] + 1);
            End
            Else
               i := MFGInt.Number[MFGInt.Number[0]] Div (temp1.Number[temp1.Number[0]] + 1);
            If (i <> 0) Then
            Begin
               FGIntCopy(temp1, temp2);
               FGIntMulByIntbis(temp2, i);
               FGIntSubBis(MFGInt, temp2);
               QFGInt.Number[j] := QFGInt.Number[j] + i;
               If FGIntCompareAbs(MFGInt, temp2) <> St Then
               Begin
                  QFGInt.Number[j] := QFGInt.Number[j] + i;
                  FGIntSubBis(MFGInt, temp2);
               End;
               FGIntClear(temp2);
            End
            Else
            Begin
               QFGInt.Number[j] := QFGInt.Number[j] + 1;
               FGIntSubBis(MFGInt, temp1);
            End;
         End;
         If MFGInt.Number[0] <= temp1.Number[0] Then
            If FGIntCompareAbs(temp1, FGInt2) <> Eq Then
            Begin
               FGIntShiftRightBy31(temp1);
               j := j - 1;
            End;
      End;
   End
   Else
      Base10StringToFGInt('0', QFGInt);
   s := QFGInt.Number[0];
   While (s > 1) And (QFGInt.Number[s] = 0) Do
      s := s - 1;
   If s < QFGInt.Number[0] Then
   Begin
      setlength(QFGInt.Number, s + 1);
      QFGInt.Number[0] := s;
   End;
   QFGInt.Sign := positive;

   FGIntClear(temp1);
   Base10StringToFGInt('0', zero);
   Base10StringToFGInt('1', one);
   If s1 = negative Then
   Begin
      If FGIntCompareAbs(MFGInt, zero) <> Eq Then
      Begin
         FGIntadd(QFGInt, one, temp1);
         FGIntClear(QFGInt);
         FGIntCopy(temp1, QFGInt);
         FGIntClear(temp1);
         FGIntsub(FGInt2, MFGInt, temp1);
         FGIntClear(MFGInt);
         FGIntCopy(temp1, MFGInt);
         FGIntClear(temp1);
      End;
      If s2 = positive Then QFGInt.Sign := negative;
   End
   Else
      QFGInt.Sign := s2;
   FGIntClear(one);
   FGIntClear(zero);

   FGInt1.Sign := s1;
   FGInt2.Sign := s2;
End;
{ @end $6C7844 }

{ @routine $6C7C60 FGIntMod }
Procedure FGIntMod(Var FGInt1, FGInt2, MFGInt : TFGInt);
Var
   one, zero, temp1, temp2 : TFGInt;
   s1, s2 : TSign;
   s, t : LongWord;
   i : int64;
Begin
   s1 := FGInt1.Sign;
   s2 := FGInt2.Sign;
   FGIntAbs(FGInt1);
   FGIntAbs(FGInt2);
   FGIntCopy(FGInt1, MFGInt);
   FGIntCopy(FGInt2, temp1);

   If FGIntCompareAbs(FGInt1, FGInt2) <> St Then
   Begin
      s := FGInt1.Number[0] - FGInt2.Number[0];
      For t := 1 To s Do
         FGIntShiftLeftBy31(temp1);
      While FGIntCompareAbs(MFGInt, FGInt2) <> St Do
      Begin
         While FGIntCompareAbs(MFGInt, temp1) <> St Do
         Begin
            If MFGInt.Number[0] > temp1.Number[0] Then
            Begin
               i := MFGInt.Number[MFGInt.Number[0]];
               i := i Shl 31;
               i := i + MFGInt.Number[MFGInt.Number[0] - 1];
               i := i Div (temp1.Number[temp1.Number[0]] + 1);
            End
            Else
               i := MFGInt.Number[MFGInt.Number[0]] Div (temp1.Number[temp1.Number[0]] + 1);
            If (i <> 0) Then
            Begin
               FGIntCopy(temp1, temp2);
               FGIntMulByIntbis(temp2, i);
               FGIntSubBis(MFGInt, temp2);
               If FGIntCompareAbs(MFGInt, temp2) <> St Then
                  FGIntSubBis(MFGInt, temp2);
               FGIntClear(temp2);
            End
            Else
               FGIntSubBis(MFGInt, temp1);
         End;
         If MFGInt.Number[0] <= temp1.Number[0] Then
            If FGIntCompareAbs(temp1, FGInt2) <> Eq Then FGIntShiftRightBy31(temp1);
      End;
   End;

   FGIntClear(temp1);
   Base10StringToFGInt('0', zero);
   Base10StringToFGInt('1', one);
   If s1 = negative Then
   Begin
      If FGIntCompareAbs(MFGInt, zero) <> Eq Then
      Begin
         FGIntSub(FGInt2, MFGInt, temp1);
         FGIntClear(MFGInt);
         FGIntCopy(temp1, MFGInt);
         FGIntClear(temp1);
      End;
   End;
   FGIntClear(one);
   FGIntClear(zero);

   FGInt1.Sign := s1;
   FGInt2.Sign := s2;
End;
{ @end $6C7C60 }

{ @routine $6C7F54 FGIntMulMod }
Procedure FGIntMulMod(Var FGInt1, FGInt2, base, FGIntres : TFGInt);
Var
   temp : TFGInt;
Begin
   FGIntMul(FGInt1, FGInt2, temp);
   FGIntMod(temp, base, FGIntres);
   FGIntClear(temp);
End;
{ @end $6C7F54 }

{ @routine $6C7FCC FGIntModBis }
Procedure FGIntModBis(Const FGInt : TFGInt; Var FGIntOut : TFGInt; b, head : LongWord);
Var
   i : LongWord;
Begin
   If b <= FGInt.Number[0] Then
   Begin
      SetLength(FGIntOut.Number, (b + 1));
      For i := 0 To b Do
         FGIntOut.Number[i] := FGInt.Number[i];
      FGIntOut.Number[b] := FGIntOut.Number[b] And head;
      i := b;
      While (FGIntOut.Number[i] = 0) And (i > 1) Do
         i := i - 1;
      If i < b Then SetLength(FGIntOut.Number, i + 1);
      FGIntOut.Number[0] := i;
      FGIntOut.Sign := positive;
   End
   Else
      FGIntCopy(FGInt, FGIntOut);
End;
{ @end $6C7FCC }

{ @routine $6C80B8 FGIntMulModBis }
Procedure FGIntMulModBis(Const FGInt1, FGInt2 : TFGInt; Var Prod : TFGInt; b, head : LongWord);
Var
   i, j, size, size1, size2, t, rest : LongWord;
   Trest : int64;
Begin
   size1 := FGInt1.Number[0];
   size2 := FGInt2.Number[0];
   size := min(b, size1 + size2);
   SetLength(Prod.Number, (size + 1));
   For i := 1 To size Do
      Prod.Number[i] := 0;

   For i := 1 To size2 Do
   Begin
      rest := 0;
      t := min(size1, b - i + 1);
      For j := 1 To t Do
      Begin
         Trest := FGInt1.Number[j];
	   Trest := Trest * FGInt2.Number[i];
	   Trest := Trest + Prod.Number[j + i - 1];
	   Trest := Trest + rest;
         Prod.Number[j + i - 1] := Trest And 2147483647;
         rest := Trest Shr 31;
      End;
      If (i + size1) <= b Then Prod.Number[i + size1] := rest;
   End;

   Prod.Number[0] := size;
   If size = b Then Prod.Number[b] := Prod.Number[b] And head;
   While (Prod.Number[size] = 0) And (size > 1) Do
      size := size - 1;
   If size < Prod.Number[0] Then
   Begin
      SetLength(Prod.Number, size + 1);
      Prod.Number[0] := size;
   End;
   If FGInt1.Sign = FGInt2.Sign Then
      Prod.Sign := Positive
   Else
      prod.Sign := negative;
End;
{ @end $6C80B8 }

{ @routine $6C8330 FGIntMontgomeryMod }
Procedure FGIntMontgomeryMod(Const GInt, base, baseInv : TFGInt; Var MGInt : TFGInt; b : Longword; head : LongWord);
Var
   m, temp, temp1 : TFGInt;
   r : LongWord;
Begin
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
   If (head Shr 30) = 0 Then FGIntDivByIntBis(MGInt, head + 1, r)
   Else FGIntShiftRightBy31(MGInt);
   If FGIntCompareAbs(MGInt, base) <> St Then FGIntSubBis(MGInt, base);
   FGIntClear(temp);
   FGIntClear(m);
End;
{ @end $6C8330 }

{ @routine $6C8488 FGIntMontgomeryModExp }
Procedure FGIntMontgomeryModExp(Var FGInt, exp, modb, res : TFGInt);
Var
   temp2, temp3, baseInv, r, zero : TFGInt;
   i, j, t, b, head : LongWord;
   S: AnsiString;
Begin
   Base2StringToFGInt('0', zero);
   FGIntMod(FGInt, modb, res);
   If FGIntCompareAbs(res, zero)=Eq then
	 Begin
	   FGIntClear(zero);
	   Exit;
	 End else FGIntClear(res);
   FGIntClear(zero);

   FGIntToBase2String(exp, S);
   t := modb.Number[0];
   b := t;

   If (modb.Number[t] Shr 30) = 1 Then t := t + 1;
   SetLength(r.Number, (t + 1));
   r.Number[0] := t;
   r.Sign := positive;
   For i := 1 To t Do
      r.Number[i] := 0;
   If t = modb.Number[0] Then
   Begin
      head := 2147483647;
      For j := 29 Downto 0 Do
      Begin
         head := head Shr 1;
         If (modb.Number[t] Shr j) = 1 Then
         Begin
            r.Number[t] := 1 Shl (j + 1);
            break;
         End;
      End;
   End
   Else
   Begin
      r.Number[t] := 1;
      head := 2147483647;
   End;

   FGIntModInv(modb, r, temp2);
   If temp2.Sign = negative Then
      FGIntCopy(temp2, BaseInv)
   Else
   Begin
      FGIntCopy(r, BaseInv);
      FGIntSubBis(BaseInv, temp2);
   End;
//   FGIntBezoutBachet(r, modb, temp2, BaseInv);
   FGIntAbs(BaseInv);
   FGIntClear(temp2);
   FGIntMod(r, modb, res);
   FGIntMulMod(FGInt, res, modb, temp2);
   FGIntClear(r);

   For i := length(S) Downto 1 Do
   Begin
      If S[i] = '1' Then
      Begin
         FGIntmul(res, temp2, temp3);
         FGIntClear(res);
         FGIntMontgomeryMod(temp3, modb, baseinv, res, b, head);
         FGIntClear(temp3);
      End;
      FGIntSquare(temp2, temp3);
      FGIntClear(temp2);
      FGIntMontgomeryMod(temp3, modb, baseinv, temp2, b, head);
      FGIntClear(temp3);
   End;
   FGIntClear(temp2);
   FGIntMontgomeryMod(res, modb, baseinv, temp3, b, head);
   FGIntCopy(temp3, res);
   FGIntClear(temp3);
   FGIntClear(baseinv);
End;
{ @end $6C8488 }

{ @routine $6C87BC FGIntGCD }
Procedure FGIntGCD(Const FGInt1, FGInt2 : TFGInt; Var GCD : TFGInt);
Var
   k : TCompare;
   zero, temp1, temp2, temp3 : TFGInt;
Begin
   k := FGIntCompareAbs(FGInt1, FGInt2);
   If (k = Eq) Then FGIntCopy(FGInt1, GCD) Else
      If (k = St) Then FGIntGCD(FGInt2, FGInt1, GCD) Else
      Begin
         Base10StringToFGInt('0', zero);
         FGIntCopy(FGInt1, temp1);
         FGIntCopy(FGInt2, temp2);
         While (temp2.Number[0] <> 1) Or (temp2.Number[1] <> 0) Do
         Begin
            FGIntMod(temp1, temp2, temp3);
            FGIntCopy(temp2, temp1);
            FGIntCopy(temp3, temp2);
            FGIntClear(temp3);
         End;
         FGIntCopy(temp1, GCD);
         FGIntClear(temp2);
         FGIntClear(zero);
      End;
End;
{ @end $6C87BC }

{ @routine $6C8900 FGIntModInv }
Procedure FGIntModInv(Const FGInt1, base : TFGInt; Var Inverse : TFGInt);
Var
   zero, one, r1, r2, r3, tb, gcd, temp, temp1, temp2 : TFGInt;
Begin
   Base10StringToFGInt('1', one);
   FGIntGCD(FGInt1, base, gcd);
   If FGIntCompareAbs(one, gcd) = Eq Then
   Begin
      FGIntcopy(base, r1);
      FGIntcopy(FGInt1, r2);
      Base10StringToFGInt('0', zero);
      Base10StringToFGInt('0', inverse);
      Base10StringToFGInt('1', tb);

      Repeat
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
      Until FGIntCompareAbs(r3, zero) = Eq;

      If inverse.Sign = negative Then
      Begin
         FGIntadd(base, inverse, temp);
         FGIntCopy(temp, inverse);
      End;

      FGIntClear(tb);
      FGIntClear(r1);
      FGIntClear(r2);
   End;
   FGIntClear(gcd);
   FGIntClear(one);
End;
{ @end $6C8900 }

end.
