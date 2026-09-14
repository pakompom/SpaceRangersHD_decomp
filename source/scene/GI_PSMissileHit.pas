unit GI_PSMissileHit;
// Unit bracket (inferred): .text 0x004ED678..0x004ED897; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008757F8..0x008757FF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native animation palette resources; this effect uses the shared GAI control.

interface

type
  TGAISet = array[0..0] of WideString;
  TMissileHitAnimationPaths = array of TGAISet;

procedure LoadMissileHitAnimationPaths; // @addr $4ED69C

var
  MissileHitAnimationPaths: array of TGAISet; // @addr $889590

implementation

// @unit-initialization $8757F8
// @unit-finalization $4ED858

uses SysUtils, Math, EC_BlockPar, EC_Str, Globals;

{ @routine $4ED69C LoadMissileHitAnimationPaths }
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
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      if PaletteBlock.CountParams('GAI') > 0 then
        MissileHitAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;
{ @end $4ED69C }

end.
