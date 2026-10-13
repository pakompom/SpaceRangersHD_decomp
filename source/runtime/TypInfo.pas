unit TypInfo;

interface

type
  TTypeInfo = record;

  PTypeInfo = ^TTypeInfo;

  TPropInfo = record;

  PPropInfo = ^TPropInfo;

function GetEnumNameValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer;

function GetEnumValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer;

procedure GetPropInfo; // @nameonly

procedure GetOrdProp; // @nameonly

procedure SetOrdProp; // @nameonly

function GetSetElementValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer;

procedure SetShortStrPropAsLongStr(Instance: TObject; PropInfo: PPropInfo; const Value: AnsiString);

procedure SetWideStrPropAsLongStr(Instance: TObject; PropInfo: PPropInfo; const Value: AnsiString);

procedure SetStrProp; // @nameonly

procedure SetWideStrProp; // @nameonly

procedure SetFloatProp; // @nameonly

procedure SetMethodProp; // @nameonly

procedure SetInt64Prop; // @nameonly

procedure SetInterfaceProp; // @nameonly

procedure FinalizeTypInfo; // @nameonly

implementation
end.
