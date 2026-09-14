unit fAchievements;
// Unit bracket (inferred): .text 0x007FF614..0x008007C9; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, GI_Image, SimpleSteamApi, Types;

type
  // Native record RTTI at $7FF5E8.
  TfAchievementsSlot = record // @size $0C
    Key: WideString; // @offset $00
    Data: PAchievementData; // @offset $04
    Background: TImageGI; // @offset $08
  end;
  TAchievementRows = array of TfAchievementsSlot;

  TfAchievements = class(TMessageLoopGI) // @size 0xD4
  public
    Rows: array of TfAchievementsSlot; // @offset $D0
    procedure KeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $7FFA48
    function AppendRow(UnusedIndex: Integer): Integer; // @addr $7FFC28 @note "Ignores the argument and appends. The native insertion-shift loop is retained even though it has no iterations."
    procedure BuildRow(Owner: TObjectGI); // @addr $7FFFA4
    procedure RefreshRowBackground(Index: Integer); // @addr $8006B0
    procedure BuildProgressBars(Owner: TObjectGI; MinValue, MaxValue, StoredValue, CurrentValue: Integer); // @addr $8007CC

    constructor Create; // @addr 0x7FF6E8 @ida "TfAchievements *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7FF72C @ida "void __usercall $name(TfAchievements *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr 0x7FF914
    procedure OnClose; override; // @addr 0x7FF988
    procedure SelectMusic; override; // @addr 0x8007C0
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x7FFB48 @ida "void __userpurge $name(TfAchievements *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr 0x7FF760
    procedure RebuildAchievementList; // @addr 0x7FFCD8
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x7FFA10
  end;

implementation

uses Windows, Classes, SysUtils, Math, Achievements, EC_BlockPar, GI_GraphBuf, GI_GraphButton,
  GI_Label, GI_Panel, GI_PanelScrollBar, GI_ScrollBar, GI_CountBar,
  GR_Main, GR_GraphBuf, GlobalsV;

{ @routine $7FF6E8 TfAchievements_Create }
constructor TfAchievements.Create;
begin
  inherited Create;
end;
{ @end $7FF6E8 }

{ @routine $7FF72C TfAchievements_Destroy }
destructor TfAchievements.Destroy;
begin
  inherited Destroy;
end;
{ @end $7FF72C }

{ @routine $7FF760 TfAchievements_InitializeLayout }
procedure TfAchievements.InitializeLayout;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fAchievements... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('MainPanel') do
      SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, (GameScreenHeight - ClientSize.Y) div 2));
  end;
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := KeyDown;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := CloseClicked;
end;
{ @end $7FF760 }

{ @routine $7FF914 TfAchievements_OnOpen }
procedure TfAchievements.OnOpen;
begin
  inherited OnOpen;
  if (PreviousScreenId <> screenArcadeBattle) and (AuxRenderBuffer.GetPixels = nil) then
    CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  RebuildAchievementList;
end;
{ @end $7FF914 }

{ @routine $7FF988 TfAchievements_OnClose }
procedure TfAchievements.OnClose;
var
  I: Integer;
begin
  for I := 0 to High(Rows) do FreeAchievementData(Rows[I].Data);
  SetLength(Rows, 0);
  if RequestedScreenId <> screenArcadeBattle then AuxRenderBuffer.Clear;
  inherited OnClose;
end;
{ @end $7FF988 }

{ @routine $7FFA10 TfAchievements_CloseClicked }
procedure TfAchievements.CloseClicked(Sender: TObjectGI);
begin
  AuxRenderBuffer.Clear;
  RequestedScreenId := AchievementsReturnScreenId;
  RequestClose(1);
end;
{ @end $7FFA10 }

{ @routine $7FFA48 TfAchievements_KeyDown }
procedure TfAchievements.KeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_ESCAPE then CloseClicked(Sender)
  else if Key = VK_PRIOR then
  begin
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.LargeChange);
  end
  else if Key = VK_NEXT then
    with GetByName('PanelSlot') as TPanelScrollBarGI do
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.LargeChange);

end;
{ @end $7FFA48 }

{ @routine $7FFB48 TfAchievements_ProcessMouseWheel }
procedure TfAchievements.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  with GetByName('PanelSlot') as TPanelScrollBarGI do
  begin
    if Delta = WHEEL_DELTA then
    begin
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange);
      PostMouseMoveMessage;
    end
    else if Delta = -WHEEL_DELTA then
    begin
      if VerticalScrollBar.Active then
        VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange);
      PostMouseMoveMessage;
    end;
  end;
end;
{ @end $7FFB48 }

{ @routine $7FFC28 TfAchievements_AppendRow }
function TfAchievements.AppendRow(UnusedIndex: Integer): Integer;
var
  Index, I: Integer;
begin
  Index := High(Rows) + 1;
  SetLength(Rows, High(Rows) + 2);
  for I := High(Rows) downto Index + 1 do Rows[I] := Rows[I - 1];
  Result := Index;
end;
{ @end $7FFC28 }

{ @routine $7FFCD8 TfAchievements_RebuildAchievementList }
procedure TfAchievements.RebuildAchievementList;
var
  I, Y: Integer;
  Panel: TPanelScrollBarGI;
  Row: TPanelGI;
  Count, Index: Integer;
  Data: PAchievementData;
begin
  Panel := GetByName('PanelSlot') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  SetLength(Rows, 0);
  Count := GetAvailableAchievementCount;
  for I := 1 to Count do
  begin
    Index := AppendRow(0);
    Data := GetAchievementData(WideString(AchievementDefinitionTable[I].Key));
    Rows[Index].Key := WideString(AchievementDefinitionTable[I].Key);
    Rows[Index].Data := Data;
    if Data.HasProgress then Data.Achieved := Data.Achieved or (Data.Value >= Data.MaxValue);
  end;
  Y := 0;
  for I := 0 to High(Rows) do
  begin
    if (AchievementDefinitionTable[I + 1].Key <> 'HULL') or Rows[I].Data.Achieved then
    begin
      // The native row-spacing branch survives even though its spacing is zero.
      if I <> 0 then Inc(Y, 0);
      Row := TPanelGI.Create(Panel);
      Row.UserValue := I;
      Row.SetPosition(Classes.Point(0, Y));
      BuildRow(Row);
      Inc(Y, Row.ClientSize.Y);
      Row.SetPositionModeW(True);
      Panel.VerticalScrollBar.SetSmallChange(Row.ClientSize.Y);
      RefreshRowBackground(I);
    end;
  end;
  Panel.UpdateScrollRanges;
  Panel.VerticalScrollBar.SetActive(Y > Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  I := Panel.VerticalScrollBar.Position;
  Panel.VerticalScrollBar.SetPosition(I - 1);
  Panel.VerticalScrollBar.SetPosition(I);
  Panel.Invalidate;
end;
{ @end $7FFCD8 }

{ @routine $7FFFA4 TfAchievements_BuildRow }
procedure TfAchievements.BuildRow(Owner: TObjectGI);
var
  Index: Integer;
begin
  Index := Owner.UserValue;
  Rows[Index].Background := TImageGI.Create(Owner);
  with Rows[Index].Background do
  begin
    SetPosition(Classes.Point(0, 0));
    SetDepth(10);
    SetImagePath('GI,Bm.FormAchievements.Slot.Inactive');
    SetSize(GetContentSize);
    Owner.SetSize(ClientSize);
    SetActive(True);
  end;
  with TLabelGI.Create(Owner) do
  begin
    SetPosition(Classes.Point(122, 13));
    SetSize(Classes.Point(Owner.ClientSize.X - 38, Owner.ClientSize.Y));
    SetDepth(7);
    SetFontName(NormalBoldFontName);
    SetTextAlignX(taxLeft);
    SetTextAlignY(tayTop);
    SetText(Rows[Index].Data.Name^);
  end;
  with TLabelGI.Create(Owner) do
  begin
    SetPosition(Classes.Point(120, 40));
    SetSize(Classes.Point(440, 53));
    SetDepth(7);
    SetFontName(SmallFontName);
    SetTextAlignX(taxCenter);
    SetTextAlignY(tayCenterEx);
    SetText(Rows[Index].Data.Description^);
    SetWordWrapEnabled(True);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  end;
  if Rows[Index].Data.HasProgress and not Rows[Index].Data.Achieved then
  begin
    BuildProgressBars(Owner, 0, Rows[Index].Data.MaxValue, Rows[Index].Data.Value,
      GetCurrentAchievementProgress(Rows[Index].Key, Rows[Index].Data.Value));
    with TLabelGI.Create(Owner) do
    begin
      SetPosition(Classes.Point(600, 45));
      SetSize(Classes.Point(205, 20));
      SetDepth(7);
      SetFontName(SmallFontName);
      SetTextAlignX(taxCenter);
      SetTextAlignY(tayCenterEx);
      SetText(WideString(IntToStr(Rows[Index].Data.Value)) +
        LanguageDataConfig.GetParamByPathOrMarker('Achievements.Of') +
        WideString(IntToStr(Rows[Index].Data.MaxValue)));
      SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    end;
  end;
  if Rows[Index].Data.Achieved then
    with TLabelGI.Create(Owner) do
    begin
      SetPosition(Classes.Point(300, 102));
      SetSize(Classes.Point(505, 20));
      SetDepth(7);
      SetFontName(SmallFontName);
      SetTextAlignX(taxRight);
      SetTextAlignY(tayCenterEx);
      SetText(LanguageDataConfig.GetParamByPathOrMarker('Achievements.Achieved') +
        FormatUnixDateTime(Rows[Index].Data.Date));
      SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    end;
  with TImageGI.Create(Owner) do
  begin
    SetPosition(Classes.Point(30, 34));
    SetDepth(7);
    SetImagePath('GI,Bm.FormAchievements.Img.' + Rows[Index].Key);
    if not Rows[Index].Data.Achieved then SetImagePath(GetImagePath + 'D');
    SetSize(GetContentSize);
    SetActive(True);
  end;
end;
{ @end $7FFFA4 }

{ @routine $8006B0 TfAchievements_RefreshRowBackground }
procedure TfAchievements.RefreshRowBackground(Index: Integer);
begin
  if (Index >= 0) and (Index <= High(Rows)) then
    with Rows[Index].Background do
      if Rows[Index].Data.Achieved then SetImagePath('GI,Bm.FormAchievements.Slot.Active')
      else SetImagePath('GI,Bm.FormAchievements.Slot.Inactive');
end;
{ @end $8006B0 }

{ @routine $8007C0 TfAchievements_SelectMusic }
procedure TfAchievements.SelectMusic;
begin
end;
{ @end $8007C0 }

{ @routine $8007CC TfAchievements_BuildProgressBars }
procedure TfAchievements.BuildProgressBars(Owner: TObjectGI; MinValue, MaxValue, StoredValue, CurrentValue: Integer);
var
  Bar: TCountBarGI;
begin
  Bar := TCountBarGI.Create(Owner);
  TObjectGI(Bar).SetPosition(Classes.Point(630, 60));
  Bar.SetSize(Classes.Point(145, 20));
  Bar.SetPositionModeW(False);
  Bar.AfterThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeft');
  Bar.BeforeThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRight');
  Bar.ThumbButton.SetImageNormalPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.ThumbButton.SetImageNormalActivePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.ThumbButton.SetImageDownPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.SetRange(MinValue, MaxValue);
  Bar.SetPositionInternal(Min(StoredValue, MaxValue));
  Bar.SetHitTestDisabled(True);
  Bar.UpdateLayout;
  Bar.Invalidate;
  Bar := TCountBarGI.Create(Owner);
  TObjectGI(Bar).SetPosition(Classes.Point(630, 60));
  Bar.SetDepth(Bar.Depth - 1);
  Bar.SetSize(Classes.Point(145, 20));
  Bar.SetPositionModeW(False);
  Bar.AfterThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeftAlt');
  Bar.BeforeThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRightAlt');
  Bar.ThumbButton.SetImageNormalPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.ThumbButton.SetImageNormalActivePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.ThumbButton.SetImageDownPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Bar.SetRange(MinValue, MaxValue);
  Bar.SetPositionInternal(Min(CurrentValue, MaxValue));
  Bar.SetHitTestDisabled(True);
  Bar.UpdateLayout;
  Bar.Invalidate;
end;
{ @end $8007CC }

end.
