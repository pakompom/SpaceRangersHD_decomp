unit GI_PSMissileHit;
// Native animation palette resources; this effect uses the shared GAI control.

interface

type
  TGAISet = array[0..0] of WideString;
  TMissileHitAnimationPaths = array of TGAISet;

procedure LoadMissileHitAnimationPaths; // @addr $4EB550

var
  MissileHitAnimationPaths: array of TGAISet; // @addr $81B178

implementation

// @unit-initialization $80680C
// @unit-finalization $4EB6D0

uses SysUtils, Math, EC_BlockPar, EC_Str, Globals;

{ @routine $4EB550 LoadMissileHitAnimationPaths }
procedure LoadMissileHitAnimationPaths;
var
  Block, PaletteBlock: TBlockParEC;
  Index, BlockCount, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.MissileHit.Palettes');
  BlockCount := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to BlockCount - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(MissileHitAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) = 0 then Continue;
    PaletteBlock := Block.GetBlockByPath(Text);
    if PaletteBlock.CountParams('GAI') > 0 then
      MissileHitAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
  end;
end;
{ @end $4EB550 }

end.
