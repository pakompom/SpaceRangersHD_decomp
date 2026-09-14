unit fJournal;
// Unit bracket (inferred): .text 0x005F33B4..0x005F642F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_Main, EC_BlockPar, GI_MessageLoop, GI_PanelScrollBar, Types, fPanelMain;

type
  TfJournal = class(TMessageLoopGIWithMainPanel) // @size 0xE0
  public
    InfoPanel: TPanelScrollBarGI; // @offset 0xD4
    ContentHeight: Integer; // @offset $D8 Accumulated height while building entries.
    JournalSelected: Boolean; // @offset 0xDC

    constructor Create; // @addr 0x5F344C @ida "TfJournal *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x5F3498 @ida "void __usercall $name(TfJournal *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr 0x5F368C
    procedure OnClose; override; // @addr 0x5F3BE8
    procedure ProcessCallbackTimers; override; // @addr 0x5F5800
    procedure SelectMusic; override; // @addr 0x5F5834
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x5F5140 @ida "void __userpurge $name(TfJournal *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr 0x5F34CC
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x5F63CC
    procedure ToggleJournalNews(Sender: TObjectGI); // @addr 0x5F4D44
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x5F6184
    procedure ClearInputClicked(Sender: TObjectGI); // @addr 0x5F61A4
    procedure CopyInputClicked(Sender: TObjectGI); // @addr 0x5F61F8
    procedure PasteInputClicked(Sender: TObjectGI); // @addr 0x5F6250

    procedure ClearEntries; // @addr $5F3FD0
    procedure FinishEntries; // @addr $5F4028
    procedure AddEntrySpacing(Height: Integer); // @addr $5F415C
    procedure AddEntryHeading(Text, MessageText: WideString; Compact: Integer; RecordIndex: Integer); // @addr $5F4180
    procedure AddEntryText(Text: WideString; Align: TTextAlignXGI; FontName: WideString); // @addr $5F4B0C
    procedure MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5F4E98 @ida "void __userpurge $name(TfJournal *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5F4EEC
    procedure MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr $5F512C
    function HasTelevisionReception: Boolean; // @addr $5F51E8
    procedure PinEntryClicked(Sender: TObjectGI); // @addr $5F523C
    procedure DeleteEntryClicked(Sender: TObjectGI); // @addr $5F52C8
    procedure ClearEntriesConfirmed; // @addr $5F541C
    procedure ExportEntriesConfirmed; // @addr $5F5554
    procedure AddRecordClicked(Sender: TObjectGI); // @addr $5F605C

    procedure RebuildNewsEntries; // @addr 0x5F5B70
    procedure RebuildJournalEntries; // @addr 0x5F5D44
    procedure RefreshTelevisionAnimation(Sender: TObjectGI); // @addr 0x5F3CDC
  end;

function RunJournal(ParentLoop: TMessageLoopGI): Boolean; // @addr $5F62DC


implementation

// @unit-initialization $8758A8
// @unit-finalization $5F6430

uses Classes, Windows, Math, SysUtils, EC_Str, GR_GraphBuf, GR_Music, GR_Sound, GI_Panel, GI_Edit, GI_Image, GI_GraphBuf, GI_GraphButton, GI_Label, GI_GAI, GI_MessageBox, aPlayer, aShip, aPlanet, aGalaxy, aGalaxyStruct, aConst, aMyFunction, fStarMap, fGov, GlobalsV, Globals, GR_Main;

{ @routine $5F344C TfJournal_Create }
constructor TfJournal.Create;
begin
  inherited Create;
  JournalSelected := True;
end;
{ @end $5F344C }

{ @routine $5F3498 TfJournal_Destroy }
destructor TfJournal.Destroy;
begin
  inherited Destroy;
end;
{ @end $5F3498 }

{ @routine $5F34CC TfJournal_InitializeLayout }
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
{ @end $5F34CC }

{ @routine $5F368C TfJournal_OnOpen }
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
{ @end $5F368C }

{ @routine $5F3BE8 TfJournal_OnClose }
procedure TfJournal.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(202);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  InfoPanel.FreeOwnedChildren;
  MainPanel.OnClose;
end;
{ @end $5F3BE8 }

var
  // Native managed-string initialization pairs at $5F6514 down to $5F647C.
  TelevisionClipNames: array[0..19] of WideString = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v'); // @addr $87B614
var
  // The native sum loop tests index < 20; the selection loop stops before index 19.
  TelevisionClipWeights: array[0..19] of Integer = (9, 5, 9, 9, 7, 5, 7, 1, 3, 1, 0, 3, 3, 2, 3, 2, 3, 4, 5, 3); // @addr $87B664 Selection uses each weight plus one. @indexrefs "$5F3D0D,$5F3D3D"

{ @routine $5F3CDC TfJournal_RefreshTelevisionAnimation }
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
{ @end $5F3CDC }

{ @routine $5F3FD0 TfJournal_ClearEntries }
procedure TfJournal.ClearEntries;
begin
  ContentHeight := 0;
  InfoPanel.FreeOwnedChildren;
  InfoPanel.SetScrollOffset(Types.Point(0, 0));
  InfoPanel.Invalidate;
end;
{ @end $5F3FD0 }

{ @routine $5F4028 TfJournal_FinishEntries }
procedure TfJournal.FinishEntries;
begin
  InfoPanel.UpdateScrollRanges;
  InfoPanel.VerticalScrollBar.SetRange(0, InfoPanel.VerticalScrollBar.Maximum);
  InfoPanel.VerticalScrollBar.SetActive(InfoPanel.ClientSize.Y < ContentHeight);
  InfoPanel.VerticalScrollBar.SetSmallChange((GovernmentScreen.GetByName('TalkText') as TLabelGI).GetLineHeight);
  InfoPanel.VerticalScrollBar.SetLargeChange(InfoPanel.ClientSize.Y);
  InfoPanel.VerticalScrollBar.SetPageSize(InfoPanel.ClientSize.Y);
  InfoPanel.SetScrollOffset(Types.Point(0, 0));
  InfoPanel.Invalidate;
end;
{ @end $5F4028 }

{ @routine $5F415C TfJournal_AddEntrySpacing }
procedure TfJournal.AddEntrySpacing(Height: Integer);
begin
  Inc(ContentHeight, GiScalePixels(Height));
end;
{ @end $5F415C }

{ @routine $5F4180 TfJournal_AddEntryHeading }
procedure TfJournal.AddEntryHeading(Text, MessageText: WideString; Compact: Integer; RecordIndex: Integer);
var
  Image: TImageGI;
  ButtonPrefix: WideString;
  PinWidth: Integer;
begin
  Text := ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,0,0>');
  Text := ReplaceAllWideString(Text, '<color=0,255,0>', '<color=255,255,0>');
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
    SetText(Text);
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
      SetName(ButtonPrefix + IntToStr(RecordIndex));
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
          SetName('JrnDel' + IntToStr(RecordIndex));
          UserValue := RecordIndex;
          SetDown(False);
          SetHovered(True);
          Invalidate;
          SetHovered(False);
        end;
    end;
end;
{ @end $5F4180 }

{ @routine $5F4B0C TfJournal_AddEntryText }
procedure TfJournal.AddEntryText(Text: WideString; Align: TTextAlignXGI; FontName: WideString);
begin
  Text := ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,50,200>');
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
    SetText(Text);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    Inc(ContentHeight, ClientSize.Y);
  end;
end;
{ @end $5F4B0C }

{ @routine $5F4D44 TfJournal_ToggleJournalNews }
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
{ @end $5F4D44 }

{ @routine $5F4E98 TfJournal_MainPanelMouseDown }
procedure TfJournal.MainPanelMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SetFocusedControl(GetByName('TextRecord'));
end;
{ @end $5F4E98 }

{ @routine $5F4EEC TfJournal_MainPanelKeyDown }
procedure TfJournal.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var Position: Integer;
begin
  if IsVirtualKeyDown(VK_CONTROL) then
  begin
    if Key = Ord('C') then CopyInputClicked(nil)
    else if Key = Ord('V') then PasteInputClicked(nil)
    else if Key = VK_BACK then ClearInputClicked(nil);
  end;
  if not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
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
end;
{ @end $5F4EEC }

{ @routine $5F512C TfJournal_MainPanelKeyUp }
procedure TfJournal.MainPanelKeyUp(Sender: TObjectGI; Key: Cardinal);
begin

end;
{ @end $5F512C }

{ @routine $5F5140 TfJournal_ProcessMouseWheel }
procedure TfJournal.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position - InfoPanel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then InfoPanel.VerticalScrollBar.SetPosition(InfoPanel.VerticalScrollBar.Position + InfoPanel.VerticalScrollBar.SmallChange);
end;
{ @end $5F5140 }

{ @routine $5F51E8 TfJournal_HasTelevisionReception }
function TfJournal.HasTelevisionReception: Boolean;
begin
  Result := (GetPlayer <> nil) and (GetPlayer.IsDockedToShip or (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)])));
end;
{ @end $5F51E8 }

{ @routine $5F523C TfJournal_PinEntryClicked }
procedure TfJournal.PinEntryClicked(Sender: TObjectGI);
begin
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, Sender.HelpText, '');
  MainPanel.RebuildMessageButtons(False);
  (Sender as TGraphButtonGI).SetDisabled(True);
  BreakUiMessage;
end;
{ @end $5F523C }

{ @routine $5F52C8 TfJournal_DeleteEntryClicked }
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
{ @end $5F52C8 }

{ @routine $5F541C TfJournal_ClearEntriesConfirmed }
procedure TfJournal.ClearEntriesConfirmed;
begin
  if GetPlayer <> nil then
  begin
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
end;
{ @end $5F541C }

{ @routine $5F5554 TfJournal_ExportEntriesConfirmed }
procedure TfJournal.ExportEntriesConfirmed;
var FileName: WideString;
begin
  if GetPlayer <> nil then
  begin
    if JournalSelected then
    begin
      if GetPlayer.JournalRecords.Count > 0 then
        if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ExtractRecord'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          FileName := GetPlayer.ExportJournal;
          ShowMessageBoxGI(Self, ReplaceColoredToken(LocalizedText('FormInfo.ExtractRecordDone'), '<FileName>', FileName, '<color=255,240,100>'), mbgOK or mbgUnused04);
          RebuildJournalEntries;
          BreakUiMessage;
        end;
    end
    else if GetPlayer.NewsEntries.Count > 0 then
      if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormInfo.ExtractNews'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
      begin
        FileName := GetPlayer.ExportNews;
        ShowMessageBoxGI(Self, ReplaceColoredToken(LocalizedText('FormInfo.ExtractNewsDone'), '<FileName>', FileName, '<color=255,240,100>'), mbgOK or mbgUnused04);
        RebuildNewsEntries;
        BreakUiMessage;
      end;
  end;
end;
{ @end $5F5554 }

{ @routine $5F5800 TfJournal_ProcessCallbackTimers }
procedure TfJournal.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $5F5800 }

{ @routine $5F5834 TfJournal_SelectMusic }
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
        if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
        begin
          if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
            MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.CurrentPlanet.RaceId)) and $7F].InternalName + 'Pirate')
          else MusicManager.PlayCategory('Nation.PiratePlanetMain');
        end
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
      end
      else if GetPlayer.IsDockedToShip then
      begin
        if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
        else if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase), Ord(rstDominion)] then
          MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName);
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
{ @end $5F5834 }

{ @routine $5F5B70 TfJournal_RebuildNewsEntries }
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
    AddEntryHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn) + HeadingSuffix, '<color=255,240,100>'), WrapTextInColor(Galaxy.FormatTurnDate(Entry.Turn), '<color=255,240,100>') + #13#10 + ' ' + #13#10 + Entry.Text, 1, 0);
    AddEntryText(' .', taxCenter, '');
    AddEntryText(Entry.Text, taxAuto, '');
    AddEntryText(' .', taxCenter, '');
    AddEntrySpacing(10);
  end;
  FinishEntries;
end;
{ @end $5F5B70 }

{ @routine $5F5D44 TfJournal_RebuildJournalEntries }
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
    AddEntryHeading(WrapTextInColor(Galaxy.FormatTurnDate(Entry.DateTurn), '<color=255,240,100>'), WrapTextInColor(Galaxy.FormatTurnDate(Entry.DateTurn), '<color=255,240,100>') + #13#10 + ' ' + #13#10 + Entry.Text, 1, I);
    AddEntryText(' .', taxCenter, '');
    AddEntryText(Entry.Text, taxAuto, '');
    AddEntryText(' .', taxCenter, '');
    AddEntrySpacing(10);
    Inc(Displayed);
  end;
  if Displayed > 0 then AddEntryText(FormatText1(LocalizedColorText('FormInfo.RecordCount'), '<color=0,50,200>', '<Count>', IntToStr(Displayed)), taxCenter, SmallFontName);
  for I := 1 to 12 do AddEntryText(' .', taxCenter, '');
  FinishEntries;
end;
{ @end $5F5D44 }

{ @routine $5F605C TfJournal_AddRecordClicked }
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
{ @end $5F605C }

{ @routine $5F6184 TfJournal_CloseClicked }
procedure TfJournal.CloseClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $5F6184 }

{ @routine $5F61A4 TfJournal_ClearInputClicked }
procedure TfJournal.ClearInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetText('');
end;
{ @end $5F61A4 }

{ @routine $5F61F8 TfJournal_CopyInputClicked }
procedure TfJournal.CopyInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetClipboardWideText(Text);
end;
{ @end $5F61F8 }

{ @routine $5F6250 TfJournal_PasteInputClicked }
procedure TfJournal.PasteInputClicked(Sender: TObjectGI);
begin
  with GetByName('TextRecord') as TEditGI do SetText(GetClipboardWideText);
end;
{ @end $5F6250 }

{ @routine $5F62DC RunJournal }
function RunJournal(ParentLoop: TMessageLoopGI): Boolean;
var
  CursorAlignment: array[0..2] of Byte;
  State: TCursorStateGI;
begin
  ParentLoop.RootUiObject.NativeHook50;
  ParentLoop.CaptureCursorState(@State);
  ParentLoop.SetCursorActive(False);
  ParentLoop.DrawQueuedUpdateRects;
  JournalScreen.ParentLoop := ParentLoop;
  ParentLoop.ChildLoop := JournalScreen;
  if JournalScreen.Run = 1 then Result := True else Result := False;
  JournalScreen.ParentLoop := nil;
  ParentLoop.ChildLoop := nil;
  ParentLoop.InvalidateViewport;
  ParentLoop.RestoreCursorState(@State);
  ParentLoop.UpdateCursorPosition;
  ParentLoop.RootUiObject.NativeHook48;
  ParentLoop.Present;
  PostMouseMoveMessage;
end;
{ @end $5F62DC }

{ @routine $5F63CC TfJournal_ExecuteUiCode }
procedure TfJournal.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10001);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20001);
  end;
end;
{ @end $5F63CC }

end.
