unit SE_SoundRnd;
// Unit bracket (inferred): .text 0x004D5B48..0x004D639B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class metadata and dynamic-array RTTI identify SE_SoundRnd.

interface

uses EC_Struct, EC_BlockPar;

type
  // Native record RTTI at $4D5B8C.
  TSoundRndUnitSE = record // @size $1C
    Weight: Integer; // @offset $00
    Group: Integer; // @offset $04 Native Group parameter.
    NextTimeMin: Integer; // @offset $08 Native NextTime pair.
    NextTimeMax: Integer; // @offset $0C
    SoundNames: array of WideString; // @offset $10
    SoundWeights: array of Integer; // @offset $14
    TotalSoundWeight: Integer; // @offset $18
  end;
  TSoundRndSE = class(TObjectEx) // @size $18
  public
    Prev: TSoundRndSE; // @offset $04
    Next: TSoundRndSE; // @offset $08
    Name: WideString; // @offset $0C
    Groups: array of TSoundRndUnitSE; // @offset $10
    TotalGroupWeight: Integer; // @offset $14
    constructor Create; // @addr $4D5E84
    destructor Destroy; override; // @addr $4D5EC8
    procedure Clear; // @addr $4D5F04
    procedure LoadFromBlock(Block: TBlockParEC); // @addr $4D5F84
    function SelectSound(GroupIndex: Integer): WideString; // @addr $4D62D0
  end;

var
  FirstRandomSound: TSoundRndSE = nil; // @addr $87AB30
  LastRandomSound: TSoundRndSE = nil; // @addr $87AB34

function CreateRandomSound: TSoundRndSE; // @addr $4D5C54
procedure FreeRandomSound(Sound: TSoundRndSE); // @addr $4D5CB8 @note "Unlinks and frees a nonnil registered sound."
procedure FreeAllRandomSounds; // @addr $4D5D24
function FindRandomSound(Name: WideString; var GroupIndex: Integer): TSoundRndSE; // @addr $4D5D3C @note "Creates and loads an uncached name, then selects a weighted group; -1 for zero total weight."

implementation

uses EC_Str, GR_Main, aMyFunction;

{ @routine $4D5C54 CreateRandomSound }
function CreateRandomSound: TSoundRndSE;
var Sound: TSoundRndSE;
begin
  Sound := TSoundRndSE.Create;
  if LastRandomSound <> nil then LastRandomSound.Next := Sound;
  Sound.Prev := LastRandomSound;
  Sound.Next := nil;
  LastRandomSound := Sound;
  if FirstRandomSound = nil then FirstRandomSound := Sound;
  Result := Sound;
end;
{ @end $4D5C54 }

{ @routine $4D5CB8 FreeRandomSound }
procedure FreeRandomSound(Sound: TSoundRndSE);
begin
  if Sound.Prev <> nil then Sound.Prev.Next := Sound.Next;
  if Sound.Next <> nil then Sound.Next.Prev := Sound.Prev;
  if LastRandomSound = Sound then LastRandomSound := Sound.Prev;
  if FirstRandomSound = Sound then FirstRandomSound := Sound.Next;
  Sound.Free;
end;
{ @end $4D5CB8 }

{ @routine $4D5D24 FreeAllRandomSounds }
procedure FreeAllRandomSounds;
begin
  while not (FirstRandomSound = nil) do FreeRandomSound(LastRandomSound);
end;
{ @end $4D5D24 }

{ @routine $4D5D3C FindRandomSound }
function FindRandomSound(Name: WideString; var GroupIndex: Integer): TSoundRndSE;
var Sound: TSoundRndSE; Index: Integer;
begin
  Sound := FirstRandomSound;
  while Sound <> nil do
  begin
    if Sound.Name = Name then Break;
    Sound := Sound.Next;
  end;
  if Sound = nil then
  begin
    Sound := CreateRandomSound;
    Sound.Name := Name;
    Sound.LoadFromBlock(GameDataConfig.GetBlockByPath('SE.Sound.Rnd.' + Name));
  end;
  if Sound.TotalGroupWeight < 1 then GroupIndex := -1
  else
  begin
    GroupIndex := RandomIntRange(0, Sound.TotalGroupWeight - 1);
    Index := 0;
    while True do
    begin
      Dec(GroupIndex, Sound.Groups[Index].Weight);
      if GroupIndex < 0 then
      begin
        GroupIndex := Index;
        Break;
      end;
      Inc(Index);
    end;
  end;
  Result := Sound;
end;
{ @end $4D5D3C }

{ @routine $4D5E84 TSoundRndSE_Create }
constructor TSoundRndSE.Create;
begin
  inherited Create;
end;
{ @end $4D5E84 }

{ @routine $4D5EC8 TSoundRndSE_Destroy }
destructor TSoundRndSE.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4D5EC8 }

{ @routine $4D5F04 TSoundRndSE_Clear }
procedure TSoundRndSE.Clear;
var Index: Integer;
begin
  for Index := 0 to High(Groups) do
  begin
    Groups[Index].SoundWeights := nil;
    Groups[Index].SoundNames := nil;
  end;
  Groups := nil;
end;
{ @end $4D5F04 }

{ @routine $4D5F84 TSoundRndSE_LoadFromBlock }
procedure TSoundRndSE.LoadFromBlock(Block: TBlockParEC);
var
  Index, Count, ParamIndex, ParamCount, SoundIndex, SoundCount: Integer;
  GroupBlock: TBlockParEC;
  Text: WideString;
begin
  TotalGroupWeight := 0;
  Count := Block.GetBlockCount;
  SetLength(Groups, Count);
  for Index := 0 to Count - 1 do
  begin
    GroupBlock := Block.GetBlockByIndex(Index);
    Groups[Index].Weight := ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index));
    Inc(TotalGroupWeight, Groups[Index].Weight);
    Groups[Index].Group := ExtractDigitsToIntW(GroupBlock.GetParam('Group'));
    Text := GroupBlock.GetParam('NextTime');
    Groups[Index].NextTimeMin := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, '-'));
    Groups[Index].NextTimeMax := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, '-'));
    SoundCount := 0;
    ParamCount := GroupBlock.GetParamCount;
    for ParamIndex := 0 to ParamCount - 1 do
      if IsIntegerTextW(GroupBlock.GetParamName(ParamIndex)) then Inc(SoundCount);
    Groups[Index].TotalSoundWeight := 0;
    SetLength(Groups[Index].SoundNames, SoundCount);
    SetLength(Groups[Index].SoundWeights, SoundCount);
    SoundIndex := 0;
    for ParamIndex := 0 to ParamCount - 1 do
    begin
      Text := GroupBlock.GetParamName(ParamIndex);
      if IsIntegerTextW(Text) then
      begin
        Groups[Index].SoundWeights[SoundIndex] := ExtractDigitsToIntW(Text);
        Groups[Index].SoundNames[SoundIndex] := GroupBlock.GetParamValue(ParamIndex);
        Inc(Groups[Index].TotalSoundWeight, Groups[Index].SoundWeights[SoundIndex]);
        Inc(SoundIndex);
      end;
    end;
  end;
end;
{ @end $4D5F84 }

{ @routine $4D62D0 TSoundRndSE_SelectSound }
function TSoundRndSE.SelectSound(GroupIndex: Integer): WideString;
var Index, Weight: Integer;
begin
  if Groups[GroupIndex].TotalSoundWeight >= 1 then
  begin
    Weight := RandomIntRange(0, Groups[GroupIndex].TotalSoundWeight - 1);
    for Index := 0 to High(Groups[GroupIndex].SoundNames) do
    begin
      Dec(Weight, Groups[GroupIndex].SoundWeights[Index]);
      if Weight < 0 then
      begin
        Result := Groups[GroupIndex].SoundNames[Index];
        Exit;
      end;
    end;
  end;
  Result := '';
end;
{ @end $4D62D0 }

end.
