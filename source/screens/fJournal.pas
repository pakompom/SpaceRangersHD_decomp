unit fJournal;

interface

uses GI_Main, EC_BlockPar, GI_MessageLoop, GI_PanelScrollBar, Types, fPanelMain;

type
  TfJournal = class(TMessageLoopGIWithMainPanel) // @size 0xE0
  public
    InfoPanel: TPanelScrollBarGI; // @offset 0xD4
    ContentHeight: Integer; // @offset $D8 Accumulated height while building entries.
    JournalSelected: Boolean; // @offset 0xDC

    constructor Create; // @addr 0x005D9B50
    destructor Destroy; override; // @addr 0x005D9B8C
    procedure OnOpen; override; // @addr 0x005D9D60
    procedure OnClose; override; // @addr 0x005DA248
    procedure ProcessCallbackTimers; override; // @addr 0x005DBB04
    procedure SelectMusic; override; // @addr 0x005DBB2C
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x005DB528
    procedure InitializeLayout; override; // @addr 0x005D9BB4
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x005DC618
    procedure ToggleJournalNews(Sender: TObjectGI); // @addr 0x005DB234
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x005DC430
    procedure ClearInputClicked(Sender: TObjectGI); // @addr 0x005DC43C
    procedure CopyInputClicked(Sender: TObjectGI); // @addr 0x005DC47C
    procedure PasteInputClicked(Sender: TObjectGI); // @addr 0x005DC4C0

    procedure ClearEntries; // @addr $5DA5F0
    procedure FinishEntries; // @addr $5DA638
    procedure AddEntrySpacing(Height: Integer); // @addr $5DA720
    procedure AddEntryHeading(CaptionText, MessageText: WideString; Compact: Integer; RecordIndex: Integer); // @addr $5DA738
    procedure AddEntryText(CaptionText: WideString; Align: TTextAlignXGI; FontName: WideString); // @addr $5DB01C
    procedure MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5DB360
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5DB3B0
    procedure MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr $5DB524
    function HasTelevisionReception: Boolean; // @addr $5DB580
    procedure PinEntryClicked(Sender: TObjectGI); // @addr $5DB5C0
    procedure DeleteEntryClicked(Sender: TObjectGI); // @addr $5DB640
    procedure ClearEntriesConfirmed; // @addr $5DB730
    procedure ExportEntriesConfirmed; // @addr $5DB860
    procedure AddRecordClicked(Sender: TObjectGI); // @addr $5DC31C

    procedure RebuildNewsEntries; // @addr 0x005DBE6C
    procedure RebuildJournalEntries; // @addr 0x005DC030
    procedure RefreshTelevisionAnimation(Sender: TObjectGI); // @addr 0x005DA330
  end;

function RunJournal(ParentLoop: TMessageLoopGI): Boolean; // @addr $5DC540


implementation

// @unit-initialization $8068C4
// @unit-finalization $5DC670

uses Classes, Windows, Math, SysUtils, EC_Str, GR_GraphBuf, GR_Music, GR_Sound, GI_Panel, GI_Edit, GI_Image, GI_GraphBuf, GI_GraphButton, GI_Label, GI_GAI, GI_MessageBox, aPlayer, aShip, aPlanet, aGalaxy, aGalaxyStruct, aConst, aMyFunction, fStarMap, fGov, GlobalsV, Globals, GR_Main;

{ @routine $5D9B50 TfJournal_Create }
constructor TfJournal.Create;
begin
  inherited Create;
  JournalSelected := True;
end;
{ @end $5D9B50 }

{ @routine $5D9B8C TfJournal_Destroy }
destructor TfJournal.Destroy;
begin
  inherited Destroy;
end;
{ @end $5D9B8C }

{ @routine $5D9BB4 TfJournal_InitializeLayout }
procedure TfJournal.InitializeLayout;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fJournal... ');
  ViewportRect := Types.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Types.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Types.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('ButFormClose').Parent do
      SetPosition(Types.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  InfoPanel := GetByName('PanelInfo') as TPanelScrollBarGI;
end;
{ @end $5D9BB4 }

{ @routine $5D9D60 TfJournal_OnOpen }
procedure TfJournal.OnOpen;
var Reception: Boolean;
begin
  CaptureScreenBackground(True, 0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
  MainPanel.OnOpen;
  (GetByName('PM_Ship') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Gal') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Quest') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_EndTurn') as TGraphButtonGI).SetHitTestDisabled(True);
  (GetByName('PM_Logo') as TGraphButtonGI).SetHitTestDisabled(True);
  if GetPlayer <> nil then GetPlayer.RefreshNewsAtLocation;
  with GetByName('MainPanel') do
  begin
    KeyDownCallback := MainPanelKeyDown;
    KeyUpCallback := MainPanelKeyUp;
    LeftButtonDownCallback := MainPanelMouseDown;
  end;
  (GetByName('AddRecord') as TGraphButtonGI).UpCallback := AddRecordClicked;
  (GetByName('ButFormClose') as TGraphButtonGI).UpCallback := CloseClicked;
  (GetByName('ButClear') as TGraphButtonGI).UpCallback := ClearInputClicked;
  (GetByName('ButCopy') as TGraphButtonGI).UpCallback := CopyInputClicked;
  (GetByName('ButPaste') as TGraphButtonGI).UpCallback := PasteInputClicked;
  MainPanel.RebuildMessageButtons(False);
  with GetByName('ButJournal') as TGraphButtonGI do
  begin
    UpCallback := ToggleJournalNews;
    SetDisabled(JournalSelected);
  end;
  with GetByName('ButNews') as TGraphButtonGI do
  begin
    UpCallback := ToggleJournalNews;
    SetDisabled(not JournalSelected);
  end;
  GetByName('PanelJournal').SetActive(JournalSelected);
  Reception := HasTelevisionReception;
  (GetByName('TVNone') as TImageGI).SetActive(not Reception);
  (GetByName('TV') as TgaiGI).SetActive(Reception);
  RefreshTelevisionAnimation(nil);
  with GetByName('TextRecord') as TEditGI do
  begin
    AutoScrollText := True;
    ClearFocusOnEnter := False;
  end;
  JournalSelected := not JournalSelected;
  ToggleJournalNews(nil);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
  Galaxy.PrimeIntegrityChecksum(201);
end;
{ @end $5D9D60 }

{ @routine $5DA248 TfJournal_OnClose }
procedure TfJournal.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(202);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  InfoPanel.FreeOwnedChildren;
  MainPanel.OnClose;
end;
{ @end $5DA248 }

var
  TelevisionClipNames: array[0..19] of WideString = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v'); // @addr $80F574
var
  // The native sum loop tests index < 20; the selection loop stops before index 19.
  TelevisionClipWeights: array[0..19] of Integer = (9, 5, 9, 9, 7, 5, 7, 1, 3, 1, 0, 3, 3, 2, 3, 2, 3, 4, 5, 3); // @addr $80F5C4 @indexrefs "0x005DA376" Selection uses each weight plus one.

{ @routine $5DA330 TfJournal_RefreshTelevisionAnimation }
procedure TfJournal.RefreshTelevisionAnimation(Sender: TObjectGI);
var I, Choice: Integer;
begin
  Choice := 0;
  for I := 0 to 19 do Inc(Choice, TelevisionClipWeights[I] + 1);
  Choice := RandomIntRange(0, Choice - 1);
  I := 0;
  while I < 19 do
  begin
    Dec(Choice, TelevisionClipWeights[I] + 1);
    if Choice < 0 then Break;
    Inc(I);
  end;
  with GetByName('TV') as TgaiGI do
  begin
    if JournalSelected then
    begin
      SetFirstFrameImagePath('Bm.News.' + GiResourceSuffix + 'FindI');
      SetImagePath('Bm.News.' + GiResourceSuffix + 'FindA');
      LoadFrameSequenceFromText('[75,0-' + IntToStr(GetMainImageFrameCount - 1) + ']');
    end
    else
    begin
      SetFirstFrameImagePath('Bm.News.' + GiResourceSuffix + TelevisionClipNames[I] + 'i');
      SetImagePath('Bm.News.' + GiResourceSuffix + TelevisionClipNames[I] + 'a');
      LoadFrameSequenceFromText('[75,0-' + IntToStr(GetMainImageFrameCount - 1) + ']');
    end;
    UpdateAutoGeometry;
    CycleCompleteCallback := RefreshTelevisionAnimation;
    if HasTelevisionReception then RestartPlayback else StopAutoPlayback;
  end;
end;
{ @end $5DA330 }

{ @routine $5DA5F0 TfJournal_ClearEntries }
procedure TfJournal.ClearEntries;
begin
  ContentHeight := 0;
  InfoPanel.FreeOwnedChildren;
  InfoPanel.SetScrollOffset(Types.Point(0, 0));
  InfoPanel.Invalidate;
end;
{ @end $5DA5F0 }

{ @routine $5DA638 TfJournal_FinishEntries }
procedure TfJournal.FinishEntries;
begin
  InfoPanel.UpdateScrollRanges;
  InfoPanel.VerticalScrollBar.SetRange(0, InfoPanel.VerticalScrollBar.Maximum);
  InfoPanel.VerticalScrollBar.IsActive := InfoPanel.ClientSize.Y < ContentHeight;
  InfoPanel.VerticalScrollBar.SetSmallChange((GovernmentScreen.GetByName('TalkText') as TLabelGI).GetLineHeight);
  InfoPanel.VerticalScrollBar.SetLargeChange(InfoPanel.ClientSize.Y);
  InfoPanel.VerticalScrollBar.SetPageSize(InfoPanel.ClientSize.Y);
  InfoPanel.SetScrollOffset(Types.Point(0, 0));
  InfoPanel.Invalidate;
end;
{ @end $5DA638 }

{ @routine $5DA720 TfJournal_AddEntrySpacing }
procedure TfJournal.AddEntrySpacing(Height: Integer);
begin
  Inc(ContentHeight, GiScalePixels(Height));
end;
{ @end $5DA720 }

{ @routine $5DA738 TfJournal_AddEntryHeading }
procedure TfJournal.AddEntryHeading(CaptionText, MessageText: WideString; Compact: Integer; RecordIndex: Integer);
var
  Image: TImageGI;
  ButtonPrefix: WideString;
  PinWidth: Integer;
begin
  CaptionText := ReplaceAllWideString(CaptionText, TextHighlightColorTag, BlackColorTag);
  CaptionText := ReplaceAllWideString(CaptionText, GreenColorTag, YellowColorTag);
  Image := TImageGI.Create(InfoPanel);
  if Compact = 0 then Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'CaptionL')
  else Image.SetImagePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'Caption');
  Image.SetSize(Image.GetContentSize);
  if Compact = 0 then Image.SetPosition(Types.Point(InfoPanel.ClientSize.X div 2 - Image.ClientSize.X div 2, ContentHeight))
  else Image.SetPosition(Types.Point(InfoPanel.ClientSize.X - Image.ClientSize.X, ContentHeight));
  Image.SetDepth(1);
  Image.SetImageKindX(ikxLeftFill);
  Image.SetImageKindY(ikyCenter);
  Inc(ContentHeight, Image.ClientSize.Y);
  Image.SetPositionModeW(True);
  with TLabelGI.Create(InfoPanel) do
  begin
    if FontDialog = 0 then SetFontName(NormalFontName)
    else if FontDialog = 1 then SetFontName(SmoothBigFontName)
    else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
    else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
    SetDepth(-1);
    SetSize(Image.ClientSize);
    if Compact <> 0 then SetSize(Types.Point(ClientSize.X - GiScalePixels(20), ClientSize.Y));
    SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - ClientSize.X, Image.LocalPosition.Y));
    SetWordWrapEnabled(False);
    SetPositionModeW(True);
    SetTextAlignX(taxCenter);
    SetTextAlignY(tayCenterEx);
    Text := CaptionText;
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  end;
  if MessageText <> '' then
    with TGraphButtonGI.Create(InfoPanel) do
    begin
      SetImageNormalPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemN');
      SetImageNormalActivePath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemA');
      SetImageDownPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemD');
      SetImageDisabledPath('GI,Bm.FormInfo2.' + GiResourceSuffix + 'MemH');
      SetSize(GetMaxStateImageSize);
      PinWidth := ClientSize.X;
      if Compact = 0 then SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - ClientSize.X - GiScalePixels(10), Image.LocalPosition.Y))
      else SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - ClientSize.X - GiScalePixels(10), Image.LocalPosition.Y - GiScalePixels(5)));
      SetKind(gbkDisable);
      SetPositionModeW(True);
      HelpText := MessageText;
      UpCallback := PinEntryClicked;
      if JournalSelected then ButtonPrefix := 'JrnBtn' else ButtonPrefix := 'News';
      Name := ButtonPrefix + IntToStr(RecordIndex);
      SetDown(False);
      SetDisabled(FindPlayerBubbleByText(MessageText, False) <> nil);
      SetHovered(True);
      Invalidate;
      SetHovered(False);
      if JournalSelected then
        with TGraphButtonGI.Create(InfoPanel) do
        begin
          SetImageNormalPath('GI,Bm.FormCount2.' + GiResourceSuffix + 'SubN');
          SetImageNormalActivePath('GI,Bm.FormCount2.' + GiResourceSuffix + 'SubA');
          SetImageDownPath('GI,Bm.FormCount2.' + GiResourceSuffix + 'SubD');
          SetImageDisabledPath('GI,Bm.FormCount2.' + GiResourceSuffix + 'SubH');
          SetSize(GetMaxStateImageSize);
          SetPosition(Types.Point(Image.LocalPosition.X + Image.ClientSize.X - ClientSize.X - GiScalePixels(15) - PinWidth, Image.LocalPosition.Y - GiScalePixels(3)));
          SetKind(gbkDisable);
          SetPositionModeW(True);
          UpCallback := DeleteEntryClicked;
          Name := 'JrnDel' + IntToStr(RecordIndex);
          UserValue := RecordIndex;
          SetDown(False);
          SetHovered(True);
          Invalidate;
          SetHovered(False);
        end;
    end;
end;
{ @end $5DA738 }

{ @routine $5DB01C TfJournal_AddEntryText }
procedure TfJournal.AddEntryText(CaptionText: WideString; Align: TTextAlignXGI; FontName: WideString);
begin
  CaptionText := ReplaceAllWideString(CaptionText, TextHighlightColorTag, DialogHighlightColorTag);
  with TLabelGI.Create(InfoPanel) do
  begin
    if FontName = '' then
    begin
      if FontDialog = 0 then SetFontName(NormalFontName)
      else if FontDialog = 1 then SetFontName(SmoothBigFontName)
      else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
      else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
    end
    else SetFontName(FontName);
    SetPosition(Types.Point(0, ContentHeight));
    SetSize(Types.Point(InfoPanel.ClientSize.X, 1));
    SetWordWrapEnabled(True);
    SetPositionModeW(True);
    if JournalSelected then SetAutoHeightPadding(8);
    SetTextAlignX(Align);
    SetTextAlignY(tayAuto);
    Text := CaptionText;
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    Inc(ContentHeight, ClientSize.Y);
  end;
end;
{ @end $5DB01C }

{ @routine $5DB234 TfJournal_ToggleJournalNews }
procedure TfJournal.ToggleJournalNews(Sender: TObjectGI);
begin
  JournalSelected := not JournalSelected;
  RefreshTelevisionAnimation(nil);
  (GetByName('ButJournal') as TGraphButtonGI).SetDisabled(JournalSelected);
  (GetByName('ButNews') as TGraphButtonGI).SetDisabled(not JournalSelected);
  GetByName('PanelJournal').SetActive(JournalSelected);
  if JournalSelected then SetFocusedControl(GetByName('TextRecord')) else SetFocusedControl(nil);
  if not JournalSelected then RebuildNewsEntries else RebuildJournalEntries;
end;
{ @end $5DB234 }

{ @routine $5DB360 TfJournal_MainPanelMouseDown }
procedure TfJournal.MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SetFocusedControl(GetByName('TextRecord'));
end;
{ @end $5DB360 }

{ @routine $5DB3B0 TfJournal_MainPanelKeyDown }
procedure TfJournal.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var Position: Integer;
begin
  if IsVirtualKeyDown(VK_CONTROL) then
  begin
    if Key = Ord('C') then CopyInputClicked(nil)
    else if Key = Ord('V') then PasteInputClicked(nil)
    else if Key = VK_BACK then ClearInputClicked(nil);
  end;
  if IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if IsVirtualKeyDown(VK_CONTROL) and (Key = VK_DELETE) then ClearEntriesConfirmed
  else if IsVirtualKeyDown(VK_CONTROL) and (Key = VK_INSERT) then ExportEntriesConfirmed
  else if not IsVirtualKeyDown(VK_CONTROL) then
  begin
    Position := InfoPanel.VerticalScrollBar.Position;
    if Key = VK_PRIOR then Dec(Position, InfoPanel.VerticalScrollBar.LargeChange);
    if Key = VK_NEXT then Inc(Position, InfoPanel.VerticalScrollBar.LargeChange);
    if Key = VK_UP then Dec(Position, InfoPanel.VerticalScrollBar.SmallChange);
    if Key = VK_DOWN then Inc(Position, InfoPanel.VerticalScrollBar.SmallChange);
    if Position < InfoPanel.VerticalScrollBar.Minimum then Position := InfoPanel.VerticalScrollBar.Minimum;
    if Position > InfoPanel.VerticalScrollBar.Maximum then Position := InfoPanel.VerticalScrollBar.Maximum;
    InfoPanel.VerticalScrollBar.SetPosition(Position);
    if Key = VK_HOME then
    begin
      if not JournalSelected then InfoPanel.SetScrollOffset(Types.Point(0, 0));
    end
    else if (Key = VK_RETURN) and JournalSelected then AddRecordClicked(nil)
    else if (Key = VK_ESCAPE) or (Key = VK_F1) then CloseClicked(nil);
  end;
end;
{ @end $5DB3B0 }

{ @routine $5DB524 TfJournal_MainPanelKeyUp }
procedure TfJournal.MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal);
begin

end;
{ @end $5DB524 }

{ @routine $5DB528 TfJournal_ProcessMouseWheel }
procedure TfJournal.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position - InfoPanel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position + InfoPanel.VerticalScrollBar.SmallChange);
end;
{ @end $5DB528 }

{ @routine $5DB580 TfJournal_HasTelevisionReception }
function TfJournal.HasTelevisionReception: Boolean;
begin
  Result := (GetPlayer <> nil) and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate])));
end;
{ @end $5DB580 }

{ @routine $5DB5C0 TfJournal_PinEntryClicked }
procedure TfJournal.PinEntryClicked(Sender: TObjectGI);
begin
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(pmUserNote, Galaxy.CurrentTurn, Sender.HelpText, '');
  MainPanel.RebuildMessageButtons(False);
  (Sender as TGraphButtonGI).SetDisabled(True);
  BreakUiMessage;
end;
{ @end $5DB5C0 }

{ @routine $5DB640 TfJournal_DeleteEntryClicked }
procedure TfJournal.DeleteEntryClicked(Sender: TObjectGI);
var Position: Integer;
begin
  if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.DelRecord'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
  begin
    if GetPlayer <> nil then GetPlayer.DeleteJournalRecord(Sender.UserValue);
    Position := InfoPanel.VerticalScrollBar.Position;
    RebuildJournalEntries;
    if Position < InfoPanel.VerticalScrollBar.Minimum then Position := InfoPanel.VerticalScrollBar.Minimum;
    if Position > InfoPanel.VerticalScrollBar.Maximum then Position := InfoPanel.VerticalScrollBar.Maximum;
    InfoPanel.VerticalScrollBar.SetPosition(Position);
    BreakUiMessage;
  end;
end;
{ @end $5DB640 }

{ @routine $5DB730 TfJournal_ClearEntriesConfirmed }
procedure TfJournal.ClearEntriesConfirmed;
begin
  if GetPlayer = nil then Exit;
  if JournalSelected then
  begin
    if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ClearRecord'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      GetPlayer.ClearJournal;
      RebuildJournalEntries;
      BreakUiMessage;
    end;
  end
  else
  begin
    if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ClearNews'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      GetPlayer.TrimNewsEntries(0);
      RebuildNewsEntries;
      BreakUiMessage;
    end;
  end;
end;
{ @end $5DB730 }

{ @routine $5DB860 TfJournal_ExportEntriesConfirmed }
procedure TfJournal.ExportEntriesConfirmed;
var FileName: WideString;
begin
  if GetPlayer = nil then Exit;
  if JournalSelected then
  begin
    if GetPlayer.JournalRecords.Count > 0 then
      if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ExtractRecord'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
      begin
        FileName := GetPlayer.ExportJournal;
        ShowMessageBoxGI(Self, ReplaceColoredToken(LocalizedText('FormInfo.ExtractRecordDone'), '<FileName>', FileName, TextHighlightColorTag), mbgOK or mbgUnused04);
        RebuildJournalEntries;
        BreakUiMessage;
      end;
  end
  else if GetPlayer.NewsEntries.Count > 0 then
    if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ExtractNews'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      FileName := GetPlayer.ExportNews;
      ShowMessageBoxGI(Self, ReplaceColoredToken(LocalizedText('FormInfo.ExtractNewsDone'), '<FileName>', FileName, TextHighlightColorTag), mbgOK or mbgUnused04);
      RebuildNewsEntries;
      BreakUiMessage;
    end;
end;
{ @end $5DB860 }

{ @routine $5DBB04 TfJournal_ProcessCallbackTimers }
procedure TfJournal.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $5DBB04 }

{ @routine $5DBB2C TfJournal_SelectMusic }
procedure TfJournal.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.RequestFadeOut
  else
  begin
    if GetPlayer.IsOnPlanet or GetPlayer.IsDockedToShip then
    begin
      if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
      else if GetPlayer.IsOnPlanet then
      begin
        if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
        begin
          if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
            MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
          else MusicManager.PlayCategory('Nation.PiratePlanetMain');
        end
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
      end
      else if GetPlayer.IsDockedToShip then
      begin
        if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
        else if GetPlayer.DockedTo.TypeId in [rstPirateBase, rstDominion] then
          MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
      end;
    end
    else if MusicInSpaceEnabled then
    begin
      if (GetPlayer <> nil) and (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
      begin
        StarMapScreen.BattleMusicSelected := True;
        MusicManager.PlayCategory('Destroyer');
      end
      else
      begin
        StarMapScreen.BattleMusicSelected := False;
        MusicManager.PlayCategory('StarMap');
      end;
    end
    else MusicManager.RequestFadeOut;
  end;
end;
{ @end $5DBB2C }

{ @routine $5DBE6C TfJournal_RebuildNewsEntries }
procedure TfJournal.RebuildNewsEntries;
var
  I, Count: Integer;
  Entry: PPlanetNewsEntry;
  HeadingSuffix: WideString; { Native appends this zero-initialized, otherwise unassigned local. }
begin
  ClearEntries;
  AddEntrySpacing(10);
  Count := 0;
  for I := GetPlayer.NewsEntries.Count - 1 downto 0 do
  begin
    Inc(Count);
    if Count > MaxPlayerNews then Break;
    Entry := GetPlayer.NewsEntries[I];
    AddEntryHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn) + HeadingSuffix, TextHighlightColorTag), WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn), TextHighlightColorTag) + #13#10 + ' ' + #13#10 + Entry.Text, 1, 0);
    AddEntryText(' .', taxCenter, '');
    AddEntryText(Entry.Text, taxAuto, '');
    AddEntryText(' .', taxCenter, '');
    AddEntrySpacing(10);
  end;
  FinishEntries;
end;
{ @end $5DBE6C }

{ @routine $5DC030 TfJournal_RebuildJournalEntries }
procedure TfJournal.RebuildJournalEntries;
var
  I, Count, Displayed: Integer;
  Entry: TJournalRecord;
begin
  ClearEntries;
  AddEntrySpacing(10);
  AddEntryText(LocalizedColorText('FormInfo.RecordTitle'), taxCenter, NormalBoldFontName);
  AddEntrySpacing(10);
  Displayed := 0;
  Count := GetPlayer.JournalRecords.Count;
  for I := Count - 1 downto 0 do
  begin
    Entry := GetPlayer.JournalRecords[I];
    AddEntryHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.DateTurn), TextHighlightColorTag), WrapTextInColor(Galaxy.FormatTurnDate(Entry.DateTurn), TextHighlightColorTag) + #13#10 + ' ' + #13#10 + Entry.Text, 1, I);
    AddEntryText(' .', taxCenter, '');
    AddEntryText(Entry.Text, taxAuto, '');
    AddEntryText(' .', taxCenter, '');
    AddEntrySpacing(10);
    Inc(Displayed);
  end;
  if Displayed > 0 then AddEntryText(FormatText1(LocalizedColorText('FormInfo.RecordCount'), DialogHighlightColorTag, '<Count>', IntToStr(Displayed)), taxCenter, SmallFontName);
  for I := 1 to 12 do AddEntryText(' .', taxCenter, '');
  FinishEntries;
end;
{ @end $5DC030 }

{ @routine $5DC31C TfJournal_AddRecordClicked }
procedure TfJournal.AddRecordClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do
  begin
    if Length(SysUtils.Trim(Text)) > 0 then
    begin
      GetPlayer.AddJournalRecord(Text);
      SoundManager.PlaySound('Sound.UserMsgAdd');
      SetText('');
      RebuildJournalEntries;
    end
    else SoundManager.PlaySound('Sound.NoMoney');
  end;
end;
{ @end $5DC31C }

{ @routine $5DC430 TfJournal_CloseClicked }
procedure TfJournal.CloseClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $5DC430 }

{ @routine $5DC43C TfJournal_ClearInputClicked }
procedure TfJournal.ClearInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetText('');
end;
{ @end $5DC43C }

{ @routine $5DC47C TfJournal_CopyInputClicked }
procedure TfJournal.CopyInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $5DC47C }

{ @routine $5DC4C0 TfJournal_PasteInputClicked }
procedure TfJournal.PasteInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5DC4C0 }

{ @routine $5DC540 RunJournal }
function RunJournal(ParentLoop: TMessageLoopGI): Boolean;
var
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.OnModalSuspend;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.ShowCursor := False;
  ParentLoop.DrawQueuedUpdateRects;
  JournalScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := JournalScreen;
  if JournalScreen.Run = 1 then Result := True else Result := False;
  JournalScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.OnModalResume;
  ParentLoop.Present;
  PostMouseMoveMessage;
end;
{ @end $5DC540 }

{ @routine $5DC618 TfJournal_ExecuteUiCode }
procedure TfJournal.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10001);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20001);
  end;
end;
{ @end $5DC618 }

end.
