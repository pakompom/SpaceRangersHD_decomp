{License, info, etc
 ------------------

This implementation is made by me, Walied Othman, to contact me
mail to Walied.Othman@belgacom.net or Triade@ulyssis.org,
always mention wether it 's about the FGInt for Delphi or for
FreePascal, or wether it 's about the 6xs, preferably in the subject line.
If you 're going to use these implementations, at least mention my
name or something and notify me so I may even put a link on my page.
This implementation is freeware and according to the coderpunks'
manifesto it should remain so, so don 't use these implementations
in commercial software.  Encryption, as a tool to ensure privacy
should be free and accessible for anyone.  If you plan to use these
implementations in a commercial application, contact me before
doing so, that way you can license the software to use it in commercial
Software.  If any algorithm is patented in your country, you should
acquire a license before using this software.  Modified versions of this
software must contain an acknowledgement of the original author (=me).
This implementation is available at
http://triade.studentenweb.org

copyright 2000, Walied Othman
This header may not be removed.
}

unit FGIntRSA;
// Retained subset of Walied Othman's legacy source.

{$H+}
interface

uses FGInt;


Procedure FGIntEncodeBlocks(P : AnsiString; Var exp, modb : TFGInt; Var E : AnsiString); // @addr $6C8B30

implementation

{ @routine $6C8B30 FGIntEncodeBlocks }
Procedure FGIntEncodeBlocks(P : AnsiString; Var exp, modb : TFGInt; Var E : AnsiString);
Var
   i, j, modbits : longint;
   PGInt, temp, zero : TFGInt;
   tempstr1, tempstr2, tempstr3 : AnsiString;
Begin
   Base2StringToFGInt('0', zero);
   FGIntToBase2String(modb, tempstr1);
   modbits := length(tempstr1);
   convertBase256to2(P, tempstr1);
   tempstr1 := '111' + tempstr1;
   j := modbits - 1;
   While (length(tempstr1) Mod j) <> 0 Do tempstr1 := '0' + tempstr1;

   j := length(tempstr1) Div (modbits - 1);
   tempstr2 := '';
   For i := 1 To j Do
   Begin
      tempstr3 := copy(tempstr1, 1, modbits - 1);
      While (copy(tempstr3, 1, 1) = '0') And (length(tempstr3) > 1) Do delete(tempstr3, 1, 1);
      Base2StringToFGInt(tempstr3, PGInt);
      delete(tempstr1, 1, modbits - 1);
      If tempstr3 = '0' Then FGIntCopy(zero, temp) Else FGIntMontgomeryModExp(PGInt, exp, modb, temp);
      FGIntClear(PGInt);
      tempstr3 := '';
      FGIntToBase2String(temp, tempstr3);
      While (length(tempstr3) Mod modbits) <> 0 Do tempstr3 := '0' + tempstr3;
      tempstr2 := tempstr2 + tempstr3;
      FGIntClear(temp);
   End;

   While (tempstr2[1] = '0') And (length(tempstr2) > 1) Do delete(tempstr2, 1, 1);
   ConvertBase2To256(tempstr2, E);
   FGIntClear(zero);
End;
{ @end $6C8B30 }

end.
