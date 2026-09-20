unit TypInfo;
// Unit bracket (inferred): .text 0x0041300C..0x0041385A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008761F0..0x008761F7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TTypeInfo = record;

  PTypeInfo = ^TTypeInfo;

  TPropInfo = record;

  PPropInfo = ^TPropInfo;

function GetEnumNameValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer; // @note "DCC32 MAP TypInfo.GetEnumNameValue. Source rtl/common/TypInfo.pas:797."

function GetEnumValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer; // @note "DCC32 MAP TypInfo.GetEnumValue. Source rtl/common/TypInfo.pas:862."

procedure GetPropInfo; // @nameonly @note "DCC32 MAP TypInfo.GetPropInfo. Prototype pending: no unique source declaration."

procedure GetOrdProp; // @nameonly @note "DCC32 MAP TypInfo.GetOrdProp. Prototype pending: no unique source declaration."

procedure SetOrdProp; // @nameonly @note "DCC32 MAP TypInfo.SetOrdProp. Prototype pending: no unique source declaration."

function GetSetElementValue(TypeInfo: PTypeInfo; const Name: AnsiString): Integer; // @note "DCC32 MAP TypInfo.GetSetElementValue. Source rtl/common/TypInfo.pas:1349."

procedure SetShortStrPropAsLongStr(Instance: TObject; PropInfo: PPropInfo; const Value: AnsiString); // @note "DCC32 MAP TypInfo.SetShortStrPropAsLongStr. Source rtl/common/TypInfo.pas:1607."

procedure SetWideStrPropAsLongStr(Instance: TObject; PropInfo: PPropInfo; const Value: AnsiString); // @note "DCC32 MAP TypInfo.SetWideStrPropAsLongStr. Source rtl/common/TypInfo.pas:1711."

procedure SetStrProp; // @nameonly @note "DCC32 MAP TypInfo.SetStrProp. Prototype pending: no unique source declaration."

procedure SetWideStrProp; // @nameonly @note "DCC32 MAP TypInfo.SetWideStrProp. Prototype pending: no unique source declaration."

procedure SetFloatProp; // @nameonly @note "DCC32 MAP TypInfo.SetFloatProp. Prototype pending: no unique source declaration."

procedure SetMethodProp; // @nameonly @note "DCC32 MAP TypInfo.SetMethodProp. Prototype pending: no unique source declaration."

procedure SetInt64Prop; // @nameonly @note "DCC32 MAP TypInfo.SetInt64Prop. Prototype pending: no unique source declaration."

procedure SetInterfaceProp; // @nameonly @note "DCC32 MAP TypInfo.SetInterfaceProp. Prototype pending: no unique source declaration."

procedure FinalizeTypInfo; // @nameonly @note "DCC32 MAP TypInfo.Finalization. Prototype pending: no unique source declaration."

implementation
end.
