unit fSaveManager;
// Unit bracket (inferred): .text 0x0079B794..0x007A0F89; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, GI_MessageLoop, GI_Panel, GR_Sound, Types, Windows;

var
  AutoSaveFileName: WideString = 'AutoSave.sav'; // @addr 0x87C200
  QuickSaveFileNames: array[1..3] of WideString = ('QuickSave.sav', 'QuickSave2.sav', 'QuickSave3.sav'); // @addr $87C204
  TurnSaveFileName: WideString = 'TurnSave.sav'; // @addr 0x87C210

type
  PSMSlot = ^TSMSlot;
  TSMSlot = packed record // @size 0x20
    FileName: WideString; // @offset 0x00
    DisplayName: WideString; // @offset 0x04
    Turn: Integer; // @offset 0x08
    Money: Integer; // @offset 0x0C
    PilotName: WideString; // @offset 0x10
    RaceName: WideString; // @offset 0x14
    LocalWriteTime: TFileTime; // @offset 0x18
  end;

  TSaveManagerMode = (smmLoad=0, smmSave=1); // @size 0x01

  TfSaveManager = class(TMessageLoopGI) // @size 0xE4
  public
    SelectedSlot: Integer; // @offset 0xD0
    Slots: TList; // @offset 0xD4  Owns PSMSlot records; an empty FileName marks the new-save slot.
    PreviewTimer: PCallbackTimerGI; // @offset 0xD8
    PreviewSound: TSoundBufferControl; // @offset 0xDC
    Closing: Boolean; // @offset 0xE0

    constructor Create; // @addr 0x79B830 @ida "TfSaveManager *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x79B8EC @ida "void __usercall $name(TfSaveManager *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr 0x79B93C
    procedure OnOpen; override; // @addr 0x79BBE0 @note "Waits for the save writer before scanning slots."
    procedure OnClose; override; // @addr 0x79C018
    procedure SelectMusic; override; // @addr 0x7A0F80
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x79EB90 @ida "void __userpurge $name(TfSaveManager *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"

    procedure RebuildSlotControls; // @addr 0x79C1B0
    procedure InitializeSlotPanel(Panel: TPanelGI); // @addr 0x79C5C0
    procedure RefreshSlot(SlotIndex: Integer; UnusedEditingFlag: Boolean); // @addr 0x79D228
    procedure CloseClicked(Sender: TObjectGI); // @addr 0x79DF5C
    procedure LoadClicked(Sender: TObjectGI); // @addr 0x79DF94
    procedure SaveClicked(Sender: TObjectGI); // @addr 0x79E218
    procedure DeleteClicked(Sender: TObjectGI); // @addr 0x79E604
    procedure SlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x79E818 @ida "void __userpurge $name(TfSaveManager *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure SlotDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x79E8AC @ida "void __userpurge $name(TfSaveManager *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure SlotKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x79E8F0
    function AcceptSaveNameCharacter(Sender: TObjectGI; Character: WideChar): Boolean; // @addr 0x79EBDC
    procedure SelectSlot(SlotIndex: Integer); // @addr 0x79EC3C
    procedure ClearSlotSelection; // @addr 0x79F2F8
    function AutoSaveExists: Boolean; // @addr 0x79F468
    function GetAutoSavePath: WideString; // @addr 0x79F4D4 @ida "void __usercall $name(TfSaveManager *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function FindAutoSaveSlot: Integer; // @addr 0x79F548 @note "Checks only the last list entry; returns -1 when absent."
    function BuildCurrentSaveDescription: WideString; // @addr 0x79F5E4 @ida "void __usercall $name(TfSaveManager *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Requires the current player and star; station-control mode uses the player's saved docking location."
    function BuildUniqueSavePath(const FileName: WideString; out SuffixIndex: Integer): WideString; // @addr 0x79FA08 @ida "void __userpurge $name(TfSaveManager *Self@<eax>, unsigned __int16 *FileName@<edx>, int *SuffixIndex@<ecx>, unsigned __int16 **Result@<^0>);" @note "Uses the current Slots list, without rescanning disk. SuffixIndex is zero when no numbered suffix is needed."
    function GetSaveConfigPath(const FileName: WideString): WideString; // @addr 0x79FE24 @ida "void __usercall $name(TfSaveManager *Self@<eax>, unsigned __int16 *FileName@<edx>, unsigned __int16 **Result@<ecx>);"
    function QuickSaveExists(SlotIndex: Integer): Boolean; // @addr 0x79FEEC
    function GetQuickSavePath(SlotIndex: Integer): WideString; // @addr 0x79FF60 @ida "void __usercall $name(TfSaveManager *Self@<eax>, int SlotIndex@<edx>, unsigned __int16 **Result@<ecx>);" @note "One-based quick-save index (1..3); unchecked."
    function GetTurnSavePath: WideString; // @addr 0x79FFDC @ida "void __usercall $name(TfSaveManager *Self@<eax>, unsigned __int16 **Result@<edx>);"
    procedure SlotMouseEnter(Sender: TObjectGI); // @addr 0x7A0050
    procedure SlotMouseLeave(Sender: TObjectGI); // @addr 0x7A0164
    procedure ScanSaveFiles; // @addr 0x7A03F4 @note "Owns TSMSlot records, newest first; optional new-save entry comes first and autosave last. Rejects malformed headers and versions outside 13..CurrentSaveVersion."
    function IsSlotEmpty(SlotIndex: Integer): Boolean; // @addr 0x7A09AC @note "True for an out-of-range index or empty FileName."
    function FindNewestSlot: Integer; // @addr 0x7A09FC @note "Returns -1 when no timestamp is greater than zero; ties retain the first match."
    function ReadSaveVersion(FileName: WideString): Integer; // @addr 0x7A0A88 @note "Reads the first two strings without checking the RSG magic."
    procedure LoadSavePreviews(FileName: WideString); // @addr 0x7A0B44
    procedure FinishPreviewDelay(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7A0E84
  end;

implementation

// @unit-initialization $876A30
// @unit-finalization $7A0F8C

uses aGalaxyStruct, GR_Main, SysUtils, Math, EC_Str, EC_File, EC_Buf, EC_BlockPar,
  GI_Main, GI_GAI, GI_Image, GI_Edit, GI_Label, GI_GraphBuf, GI_PanelScrollBar, GI_GraphButton,
  Globals, GlobalsV, aConst, aMyFunction, aPlayer, aGalaxy, aSaveLoad, fMainForm, fShip2;

var
  NewSaveNormalColor: Cardinal; // @addr $889D18
  NewSaveSelectedColor: Cardinal; // @addr $889D1C
  SaveSlotNormalColor: Cardinal; // @addr $889D20
  SaveSlotSelectedColor: Cardinal; // @addr $889D24


{ @routine $79B830 TfSaveManager_Create }
constructor TfSaveManager.Create;
begin
  inherited;
  Slots := TList.Create;
  SelectedSlot := -1;
  PreviewSound := TSoundBufferControl.Create;
  PreviewSound.Configure('Sound.SaveLoadLoop',0,True);
end;
{ @end $79B830 }

{ @routine $79B8EC TfSaveManager_Destroy }
destructor TfSaveManager.Destroy;
begin
  Slots.Free;
  PreviewSound.Free;
  inherited;
end;
{ @end $79B8EC }

{ @routine $79B93C TfSaveManager_InitializeLayout }
procedure TfSaveManager.InitializeLayout;
begin
  inherited;
  AppendLogTextThreadSafe('fSaveManager... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  GetByName('').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
  GetByName('BGBuf').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
  with GetByName('ButClose').Parent do
    SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
  NewSaveNormalColor := GetStyleColorGI('SaveManager.NewSaveNormal',0,41,65);
  NewSaveSelectedColor := GetStyleColorGI('SaveManager.NewSaveSelected',87,149,175);
  SaveSlotNormalColor := GetStyleColorGI('SaveManager.SlotNormal',97,129,143);
  SaveSlotSelectedColor := GetStyleColorGI('SaveManager.SlotSelected',65,121,145);
  AppendLogLineThreadSafe('ok');
end;
{ @end $79B93C }

{ @routine $79BBE0 TfSaveManager_OnOpen }
procedure TfSaveManager.OnOpen;
var
  Directory: AnsiString;
begin
  inherited;
  Directory := GetGameUserDirectory + 'Save';
  if not DirectoryExists(Directory) then CreateDir(Directory);
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True,0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('Anim') as TgaiGI do RestartPlayback;
  SelectedSlot := -1;
  if SaveManagerMode = smmSave then SelectedSlot := 0;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := CloseClicked;
  (GetByName('ButCancel') as TGraphButtonGI).UpCallback := CloseClicked;
  with GetByName('ButLoad') as TGraphButtonGI do
  begin
    SetActive(SaveManagerMode = smmLoad);
    UpCallback := LoadClicked;
  end;
  with GetByName('ButSave') as TGraphButtonGI do
  begin
    SetActive(SaveManagerMode = smmSave);
    UpCallback := SaveClicked;
  end;
  with GetByName('ButDelete') as TGraphButtonGI do
  begin
    UpCallback := DeleteClicked;
    SetDisabled(True);
    SetActive(True);
  end;
  with GetByName('GameImage') as TGraphBufGI do
  begin
    GraphBuf.Clear;
    Invalidate;
  end;
  with GetByName('GameImage2') as TGraphBufGI do
  begin
    GraphBuf.Clear;
    Invalidate;
  end;
  GetByName('CaptionLoad').SetActive(SaveManagerMode = smmLoad);
  GetByName('CaptionSave').SetActive(SaveManagerMode = smmSave);
  if (SaveWriter <> nil) and SaveWriter.IsRunning then SaveWriter.WaitForIdle($FFFFFFFF);
  RebuildSlotControls;
  if Slots.Count <= 0 then PreviewSound.SetVolume(1);
  Closing := False;
end;
{ @end $79BBE0 }

{ @routine $79C018 TfSaveManager_OnClose }
procedure TfSaveManager.OnClose;
var
  I: Integer;
  Slot: PSMSlot;
  ScrollPanel: TPanelScrollBarGI;
begin
  for I := 0 to Slots.Count - 1 do
  begin
    Slot := PSMSlot(Slots[I]);
    Slot.FileName := '';
    Dispose(Slot);
  end;
  Slots.Clear;
  PreviewSound.SetVolume(0);
  if Galaxy <> nil then Galaxy.CampaignFlag183 := 0;
  if PreviewTimer <> nil then
  begin
    CancelCallbackTimer(PreviewTimer);
    PreviewTimer := nil;
  end;
  ScrollPanel := GetByName('PanelSlot') as TPanelScrollBarGI;
  ScrollPanel.FreeOwnedChildren;
  with GetByName('GameImage') as TGraphBufGI do GraphBuf.Clear;
  with GetByName('GameImage2') as TGraphBufGI do GraphBuf.Clear;
  AuxRenderBuffer.Clear;
  inherited;
  Closing := False;
end;
{ @end $79C018 }

{ @routine $79C1B0 TfSaveManager_RebuildSlotControls }
procedure TfSaveManager.RebuildSlotControls;
var
  Panel: TPanelGI;
  ScrollPanel: TPanelScrollBarGI;
  I, Y: Integer;
begin
  ScanSaveFiles;
  if SelectedSlot < 0 then SelectedSlot := FindNewestSlot;
  if (FindAutoSaveSlot = SelectedSlot) and (SaveManagerMode <> smmLoad) then SelectedSlot := 0;
  if Slots.Count <= SelectedSlot then SelectedSlot := Slots.Count - 1;
  ScrollPanel := GetByName('PanelSlot') as TPanelScrollBarGI;
  ScrollPanel.KeyDownCallback := SlotKeyDown;
  ScrollPanel.FreeOwnedChildren;
  GetByName('PanelAutoSave').FreeOwnedChildren;
  Y := 0;
  for I := 0 to Slots.Count - 1 do
  begin
    if FindAutoSaveSlot <> I then
    begin
      Panel := TPanelGI.Create(ScrollPanel);
      Panel.UserValue := I;
      Panel.SetPosition(Classes.Point(0,Y));
      InitializeSlotPanel(Panel);
      Inc(Y,Panel.ClientSize.Y);
      Panel.SetName('Slot' + IntToStr(I));
      Panel.SetPositionModeW(True);
      RefreshSlot(I,False);
      ScrollPanel.VerticalScrollBar.SetSmallChange(Panel.ClientSize.Y);
    end;
  end;
  if FindAutoSaveSlot >= 0 then
  begin
    Panel := TPanelGI.Create(GetByName('PanelAutoSave'));
    Panel.UserValue := FindAutoSaveSlot;
    Panel.SetPosition(Classes.Point(0,0));
    InitializeSlotPanel(Panel);
    Panel.SetName('Slot' + IntToStr(FindAutoSaveSlot));
    Panel.SetPositionModeW(False);
    RefreshSlot(FindAutoSaveSlot,False);
    GetByName('PanelAutoSave').SetSize(Panel.ClientSize);
    ScrollPanel.VerticalScrollBar.SetSmallChange(Panel.ClientSize.Y);
  end;
  ScrollPanel.UpdateScrollRanges;
  ScrollPanel.VerticalScrollBar.SetActive(ScrollPanel.ClientSize.Y < Y);
  ScrollPanel.VerticalScrollBar.SetLargeChange(ScrollPanel.ClientSize.Y);
  ScrollPanel.VerticalScrollBar.SetPageSize(ScrollPanel.ClientSize.Y);
  I := ScrollPanel.VerticalScrollBar.Position;
  ScrollPanel.VerticalScrollBar.SetPosition(I - 1);
  ScrollPanel.VerticalScrollBar.SetPosition(I);
  if (SelectedSlot < 0) or (Slots.Count <= SelectedSlot) then SelectedSlot := -1;
  SelectSlot(SelectedSlot);
  FinishPreviewDelay(nil,0);
end;
{ @end $79C1B0 }

{ @routine $79C5C0 TfSaveManager_InitializeSlotPanel }
procedure TfSaveManager.InitializeSlotPanel(Panel: TPanelGI);
begin
  Panel.SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)));
  Panel.MouseEnterCallback := SlotMouseEnter;
  Panel.MouseLeaveCallback := SlotMouseLeave;
  Panel.LeftButtonDownCallback := SlotMouseDown;
  if (SaveManagerMode = smmLoad) or (FindAutoSaveSlot <> Panel.UserValue) then
    Panel.LeftButtonDoubleClickCallback := SlotDoubleClick;
  with TImageGI.Create(Panel) do
  begin
    SetPosition(Classes.Point(0,0));
    SetDepth(10);
    SetImagePath('GI,Bm.FormSave2.' + GiResourceSuffix + 'Glow');
    SetSize(GetContentSize);
    Panel.SetSize(ClientSize);
    SetActive(False);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'onmouse');
  end;
  with TImageGI.Create(Panel) do
  begin
    if GiResourceVariant = 1 then SetPosition(Classes.Point(51,2))
    else SetPosition(Classes.Point(64,3));
    SetDepth(9);
    SetImagePath('GI,Bm.FormSave2.' + GiResourceSuffix + 'SlotN');
    SetSize(GetContentSize);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'BG');
  end;
  with TImageGI.Create(Panel) do
  begin
    if GiResourceVariant = 1 then
    begin
      SetPosition(Classes.Point(2,2));
      SetSize(Classes.Point(49,49));
    end
    else
    begin
      SetPosition(Classes.Point(3,3));
      SetSize(Classes.Point(61,61));
    end;
    SetDepth(9);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Emblem');
  end;
  if (SaveManagerMode = smmLoad) or (FindAutoSaveSlot = Panel.UserValue) then
  begin
    with TLabelGI.Create(Panel) do
    begin
      SetPosition(Classes.Point(81,14));
      SetSize(Classes.Point(409,20));
      SetDepth(7);
      if FontDialog = 0 then SetFontName(NormalFontName)
      else if FontDialog = 1 then SetFontName(SmoothBigFontName)
      else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
      else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
      SetTextAlignX(taxLeft);
      SetTextAlignY(tayCenterEx);
      SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Edit');
      if Self.IsSlotEmpty(Panel.UserValue) then SetText('')
      else SetText(PSMSlot(Self.Slots[Panel.UserValue]).DisplayName);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    end;
  end
  else
  begin
    with TEditGI.Create(Panel) do
    begin
      SetPosition(Classes.Point(81,14));
      SetSize(Classes.Point(409,20));
      SetDepth(7);
      if FontDialog = 0 then SetFontName(NormalFontName)
      else if FontDialog = 1 then SetFontName(SmoothBigFontName)
      else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
      else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
      SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Edit');
      MaxLength := 55;
      if Self.IsSlotEmpty(Panel.UserValue) then SetText('')
      else SetText(PSMSlot(Self.Slots[Panel.UserValue]).DisplayName);
      SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
      AcceptCharCallback := AcceptSaveNameCharacter;
    end;
  end;
  with TLabelGI.Create(Panel) do
  begin
    SetPosition(Classes.Point(72,37));
    SetSize(Classes.Point(130,17));
    SetDepth(8);
    SetFontName(RangerFontName);
    SetTextAlignX(taxCenter);
    SetTextAlignY(tayCenterEx);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Captain');
  end;
  with TLabelGI.Create(Panel) do
  begin
    SetPosition(Classes.Point(207,37));
    SetSize(Classes.Point(165,17));
    SetDepth(8);
    SetFontName(RangerFontName);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(227,227,227));
    SetTextAlignX(taxCenter);
    SetTextAlignY(tayCenterEx);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Turn');
  end;
  with TLabelGI.Create(Panel) do
  begin
    SetPosition(Classes.Point(387,37));
    SetSize(Classes.Point(108,17));
    SetDepth(8);
    SetFontName(RangerFontName);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(227,227,227));
    SetTextAlignX(taxCenter);
    SetTextAlignY(tayCenterEx);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Money');
  end;
  with TLabelGI.Create(Panel) do
  begin
    SetPosition(Classes.Point(297,7));
    SetSize(Classes.Point(200,15));
    SetDepth(8);
    SetFontName(MiniFontName);
    SetTextColor(CurrentPixelFormat.PackRgbBytes(227,227,227));
    SetTextAlignX(taxRight);
    SetTextAlignY(tayCenterEx);
    SetName('Slot' + IntToStr(Cardinal(Panel.UserValue)) + 'Date');
  end;

end;
{ @end $79C5C0 }

{ @routine $79D228 TfSaveManager_RefreshSlot }
procedure TfSaveManager.RefreshSlot(SlotIndex: Integer; UnusedEditingFlag: Boolean);
var
  State: WideString;
  Color: Cardinal;
  Time: TSystemTime;
begin
  try
    if SelectedSlot = SlotIndex then State := 'D' else State := 'N';
    with GetByName('Slot' + IntToStr(SlotIndex) + 'BG') as TImageGI do
      SetImagePath('GI,Bm.FormSave2.2Slot' + State);
    with GetByName('Slot' + IntToStr(SlotIndex) + 'Emblem') as TImageGI do
    begin
      SetImagePath('GI,Bm.FormSave2.2' + PSMSlot(Slots[SlotIndex]).RaceName + State);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end;
    with GetByName('Slot' + IntToStr(SlotIndex) + 'Date') as TLabelGI do
    begin
      if IsSlotEmpty(SlotIndex) then SetText(LocalizedText('FormSaveManager.New'))
      else
      begin
        FileTimeToSystemTime(PSMSlot(Slots[SlotIndex]).LocalWriteTime,Time);
        SetText(FormatDateTime(AnsiString(LocalizedText('FormSaveManager.DateFormatStr')),SystemTimeToDateTime(Time)));
      end;
      if (SaveManagerMode = smmSave) and (SlotIndex = 0) then
      begin
        if SelectedSlot = SlotIndex then SetTextColor(NewSaveSelectedColor)
        else SetTextColor(NewSaveNormalColor);
      end
      else
      begin
        if SelectedSlot = SlotIndex then SetTextColor(SaveSlotSelectedColor)
        else SetTextColor(SaveSlotNormalColor);
      end;
    end;
    if SelectedSlot = SlotIndex then Color := CurrentPixelFormat.PackRgbBytes(255,255,255)
    else Color := CurrentPixelFormat.PackRgbBytes(0,0,0);
    if GetByName('Slot' + IntToStr(SlotIndex) + 'Edit') is TEditGI then
    begin
      with GetByName('Slot' + IntToStr(SlotIndex) + 'Edit') as TEditGI do
      begin
        SetText(PSMSlot(Slots[SlotIndex]).DisplayName);
        SetTextColor(Color);
      end;
    end
    else
    begin
      with GetByName('Slot' + IntToStr(SlotIndex) + 'Edit') as TLabelGI do
      begin
        SetText(PSMSlot(Slots[SlotIndex]).DisplayName);
        SetTextColor(Color);
      end;
    end;
    if IsSlotEmpty(SlotIndex) then
    begin
      if SelectedSlot = SlotIndex then
      begin
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Captain') as TLabelGI).SetText(GetPlayer.Name);
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Turn') as TLabelGI).SetText(FormatGameTurnDate(Galaxy.CurrentTurn));
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Money') as TLabelGI).SetText(IntToStr(GetPlayer.Money));
      end
      else
      begin
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Captain') as TLabelGI).SetText('');
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Turn') as TLabelGI).SetText('');
        (GetByName('Slot' + IntToStr(SlotIndex) + 'Money') as TLabelGI).SetText('');
      end;
    end
    else
    begin
      (GetByName('Slot' + IntToStr(SlotIndex) + 'Captain') as TLabelGI).SetText(PSMSlot(Slots[SlotIndex]).PilotName);
      (GetByName('Slot' + IntToStr(SlotIndex) + 'Turn') as TLabelGI).SetText(FormatGameTurnDate(PSMSlot(Slots[SlotIndex]).Turn));
      (GetByName('Slot' + IntToStr(SlotIndex) + 'Money') as TLabelGI).SetText(IntToStr(PSMSlot(Slots[SlotIndex]).Money));
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe(AnsiString(WideString('Error when loading info from save file ') + PSMSlot(Slots[SlotIndex]).FileName));
    end;
  end;
end;
{ @end $79D228 }

{ @routine $79DF5C TfSaveManager_CloseClicked }
procedure TfSaveManager.CloseClicked(Sender: TObjectGI);
begin
  RequestedScreenId := SaveManagerReturnScreenId;
  Closing := True;
  RequestClose(1);
end;
{ @end $79DF5C }

{ @routine $79DF94 TfSaveManager_LoadClicked }
procedure TfSaveManager.LoadClicked(Sender: TObjectGI);
begin
  ReleaseAllTextureSurfaces;
  MainMenuScreen.LoadPanel.SelectBackgroundStyle(0);
  if SelectedSlot >= 0 then
  begin
    if not IsSlotEmpty(SelectedSlot) and (ReadSaveVersion(PSMSlot(Slots[SelectedSlot]).FileName) < MinimumLoadableSaveVersion) then
      ShowMessageBoxGI(TMessageLoopGI(GetRegisteredScreenLoop(CurrentScreenId)),LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.LoadError'),mbgCancel or mbgError)
    else if not IsSlotEmpty(SelectedSlot) then
    begin
      PendingLoadFileName := PSMSlot(Slots[SelectedSlot]).FileName;
      EditableSaveFileName := GetSaveConfigPath(PendingLoadFileName);
      if SysUtils.FileExists(EditableSaveFileName) then
        if ShowMessageBoxGI(Self,LocalizedColorText('FormSaveManager.LoadDumpConfirm'),mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        begin
          EditableSaveBlock.Clear;
          EditableSaveBlock.LoadFromTextFileWithEncodingProbe(PWideChar(EditableSaveFileName),True);
          ApplyEditableSaveOnLoad := True;
        end;
      ShipScreen.SelectedHoldKind := phkEmpty;
      ShipScreen.SelectedHoldItem := nil;
      RequestedScreenId := screenGameLoad;
      RequestClose(1);
    end;
  end;
end;
{ @end $79DF94 }

{ @routine $79E218 TfSaveManager_SaveClicked }
procedure TfSaveManager.SaveClicked(Sender: TObjectGI);
var
  Saved: Boolean;
  FileName, Description: WideString;
  SuffixIndex: Integer;
begin
  if SelectedSlot >= 0 then
  begin
    if not IsSlotEmpty(SelectedSlot) then
    begin
      SysUtils.DeleteFile(AnsiString(PSMSlot(Slots[SelectedSlot]).FileName));
      PSMSlot(Slots[SelectedSlot]).FileName := '';
    end;
    FileName := TrimWideString((GetByName('Slot' + IntToStr(SelectedSlot) + 'Edit') as TEditGI).Text);
    if FileName = '' then SetFocusedControl(GetByName('Slot' + IntToStr(SelectedSlot) + 'Edit'))
    else
    begin
      Description := FileName;
      FileName := RemoveWideStringChars(FileName,'<>"/\:');
      if RunningUnderWine or ((UserSettingsConfig.CountParams('TransliterateSaveNames') > 0) and
        ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('TransliterateSaveNames')))) then
        FileName := TransliterateCyrillicToLatin(FileName);
      FileName := BuildUniqueSavePath(GetGameUserDirectory + 'save\' + FileName + '.sav',SuffixIndex);
      if SuffixIndex > 0 then Description := Description + ' (' + IntToStr(SuffixIndex) + ')';
      Saved := SaveGameToFile(FileName,Description);
      if not Saved then
        ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.SaveError'),mbgOK or mbgError);
      CloseClicked(Sender);
    end;
  end;
end;
{ @end $79E218 }

{ @routine $79E604 TfSaveManager_DeleteClicked }
procedure TfSaveManager.DeleteClicked(Sender: TObjectGI);
var
  WasAutoSave: Boolean;
begin
  if (SelectedSlot >= 0) and not IsSlotEmpty(SelectedSlot) then
    if ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.QueryDelete'),mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      if (FindAutoSaveSlot = SelectedSlot) and (SaveManagerMode = smmLoad) then WasAutoSave := True else WasAutoSave := False;
      SysUtils.DeleteFile(AnsiString(PSMSlot(Slots[SelectedSlot]).FileName));
      if SysUtils.FileExists(GetSaveConfigPath(PSMSlot(Slots[SelectedSlot]).FileName)) then
        SysUtils.DeleteFile(AnsiString(GetSaveConfigPath(PSMSlot(Slots[SelectedSlot]).FileName)));
      if WasAutoSave then SelectedSlot := 0;
      RebuildSlotControls;
    end;
end;
{ @end $79E604 }

{ @routine $79E818 TfSaveManager_SlotMouseDown }
procedure TfSaveManager.SlotMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not Closing and ((SaveManagerMode = smmLoad) or (FindAutoSaveSlot <> Sender.UserValue)) then
  begin
    SoundManager.PlaySound('Sound.ButtonClick');
    SelectSlot(Sender.UserValue);
  end;
end;
{ @end $79E818 }

{ @routine $79E8AC TfSaveManager_SlotDoubleClick }
procedure TfSaveManager.SlotDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if SaveManagerMode = smmSave then SaveClicked(Sender) else LoadClicked(Sender);
end;
{ @end $79E8AC }

{ @routine $79E8F0 TfSaveManager_SlotKeyDown }
procedure TfSaveManager.SlotKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_DOWN then
  begin
    if SelectedSlot < 0 then SelectSlot(0)
    else if ((SaveManagerMode = smmLoad) or (FindAutoSaveSlot < 0)) and (Slots.Count - 1 <= SelectedSlot) then SelectSlot(0)
    else if (SaveManagerMode <> smmLoad) and (FindAutoSaveSlot >= 0) and (Slots.Count - 2 <= SelectedSlot) then SelectSlot(0)
    else SelectSlot(SelectedSlot + 1);
  end
  else if Key = VK_UP then
  begin
    if SelectedSlot < 0 then SelectSlot(Slots.Count - 1)
    else if SelectedSlot = 0 then
    begin
      if (SaveManagerMode = smmLoad) or (FindAutoSaveSlot < 0) then
      begin
        if Slots.Count - 1 <> SelectedSlot then SelectSlot(Slots.Count - 1);
      end
      else if Slots.Count - 2 <> SelectedSlot then SelectSlot(Slots.Count - 2);
    end
    else SelectSlot(SelectedSlot - 1);
  end
  else if Key = VK_PRIOR then
  begin
    if SelectedSlot <> 0 then SelectSlot(0);
  end
  else if Key = VK_NEXT then
  begin
    if (SaveManagerMode = smmLoad) or (FindAutoSaveSlot < 0) then
    begin
      if Slots.Count - 1 <> SelectedSlot then SelectSlot(Slots.Count - 1);
    end
    else if Slots.Count - 2 <> SelectedSlot then SelectSlot(Slots.Count - 2);
  end
  else if Key = VK_DELETE then DeleteClicked(nil)
  else if Key = VK_ESCAPE then CloseClicked(Sender)
  else if Key = VK_RETURN then
  begin
    if SaveManagerMode = smmSave then SaveClicked(Sender) else LoadClicked(Sender);
  end;
end;
{ @end $79E8F0 }

{ @routine $79EB90 TfSaveManager_ProcessMouseWheel }
procedure TfSaveManager.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then SlotKeyDown(nil,VK_UP)
  else if Delta = -WHEEL_DELTA then SlotKeyDown(nil,VK_DOWN);
end;
{ @end $79EB90 }

{ @routine $79EBDC TfSaveManager_AcceptSaveNameCharacter }
function TfSaveManager.AcceptSaveNameCharacter(Sender: TObjectGI; Character: WideChar): Boolean;
begin
  Result := (Character <> '\') and (Character <> '/') and (Character <> ':') and
    (Character <> '*') and (Character <> '?') and (Character <> '"') and
    (Character <> '<') and (Character <> '>') and (Character <> '|');
end;
{ @end $79EBDC }

{ @routine $79EC3C TfSaveManager_SelectSlot }
procedure TfSaveManager.SelectSlot(SlotIndex: Integer);
var
  ScrollPanel: TPanelScrollBarGI;
begin
  ClearSlotSelection;
  SelectedSlot := SlotIndex;
  if Slots.Count <= SelectedSlot then SelectedSlot := -1;
  (GetByName('ButDelete') as TGraphButtonGI).SetDisabled(IsSlotEmpty(SlotIndex));
  (GetByName('ButLoad') as TGraphButtonGI).SetDisabled(IsSlotEmpty(SlotIndex));
  (GetByName('ButSave') as TGraphButtonGI).SetDisabled((SlotIndex < 0) or (Slots.Count <= SlotIndex));
  if (SelectedSlot >= 0) and (Slots.Count > SelectedSlot) then
  begin
    ScrollPanel := GetByName('PanelSlot') as TPanelScrollBarGI;
    if FindAutoSaveSlot <> SlotIndex then
      with GetByName('Slot' + IntToStr(SlotIndex)) as TPanelGI do
        ScrollPanel.ScrollRectIntoView(GetLocalBounds);
    RefreshSlot(SlotIndex,SaveManagerMode = smmSave);
    if GetByName('Slot' + IntToStr(SlotIndex) + 'Edit') is TEditGI then
    begin
      if IsSlotEmpty(SlotIndex) then
        with GetByName('Slot' + IntToStr(SlotIndex) + 'Edit') as TEditGI do SetText(BuildCurrentSaveDescription);
      SetFocusedControl(GetByName('Slot' + IntToStr(SlotIndex) + 'Edit'));
    end;
    if not IsSlotEmpty(SlotIndex) then
    begin
      if PreviewTimer <> nil then
      begin
        CancelCallbackTimer(PreviewTimer);
        PreviewTimer := nil;
      end;
      LoadSavePreviews(PSMSlot(Slots[SlotIndex]).FileName);
    end
    else if (SelectedSlot = 0) and (SaveManagerMode = smmSave) then
    begin
      with GetByName('GameImage') as TGraphBufGI do
      begin
        GraphBuf.Clear;
        GraphBuf.AllocateRgb(SavePreviewGraph.Width,SavePreviewGraph.Height,SavePreviewGraph.PitchBytes);
        Windows.CopyMemory(GraphBuf.GetPixels,SavePreviewGraph.GetPixels,GraphBuf.Height * GraphBuf.PitchBytes);
        GraphBuf.RescaleRgb(ClientSize.X,ClientSize.Y);
        GraphBuf.ConvertRgbTo565;
        Invalidate;
        SetActive(False);
      end;
      with GetByName('GameImage2') as TGraphBufGI do
      begin
        GraphBuf.Clear;
        GraphBuf.AllocateRgb(SecondarySavePreviewGraph.Width,SecondarySavePreviewGraph.Height,SecondarySavePreviewGraph.PitchBytes);
        Windows.CopyMemory(GraphBuf.GetPixels,SecondarySavePreviewGraph.GetPixels,GraphBuf.Height * GraphBuf.PitchBytes);
        GraphBuf.RescaleRgb(ClientSize.X,ClientSize.Y);
        GraphBuf.ConvertRgbTo565;
        Invalidate;
        SetActive(False);
      end;
      if PreviewTimer <> nil then
      begin
        CancelCallbackTimer(PreviewTimer);
        PreviewTimer := nil;
      end;
      PreviewTimer := ScheduleCallbackTimer(250,250,FinishPreviewDelay);
      PreviewSound.SetVolume(1);
    end
    else
    begin
      with GetByName('GameImage') as TGraphBufGI do
      begin
        GraphBuf.Clear;
        Invalidate;
        SetActive(False);
      end;
      with GetByName('GameImage2') as TGraphBufGI do
      begin
        GraphBuf.Clear;
        Invalidate;
        SetActive(False);
      end;
    end;
    PostMouseMoveMessage;
  end;
end;
{ @end $79EC3C }

{ @routine $79F2F8 TfSaveManager_ClearSlotSelection }
procedure TfSaveManager.ClearSlotSelection;
var
  PreviousSlot: Integer;
begin
  if PreviewTimer <> nil then
  begin
    CancelCallbackTimer(PreviewTimer);
    PreviewTimer := nil;
  end;
  GetByName('GameImage').SetActive(False);
  GetByName('GameImage2').SetActive(False);
  PreviousSlot := SelectedSlot;
  SelectedSlot := -1;
  if PreviousSlot >= 0 then
  begin
    if GetByName('Slot' + IntToStr(PreviousSlot) + 'Edit') is TEditGI then SetFocusedControl(nil);
    RefreshSlot(PreviousSlot,False);
  end;
end;
{ @end $79F2F8 }

{ @routine $79F468 TfSaveManager_AutoSaveExists }
function TfSaveManager.AutoSaveExists: Boolean;
begin
  Result := SysUtils.FileExists(GetAutoSavePath);
end;
{ @end $79F468 }

{ @routine $79F4D4 TfSaveManager_GetAutoSavePath }
function TfSaveManager.GetAutoSavePath: WideString;
begin
  Result := GetGameUserDirectory + 'save\' + AutoSaveFileName;
end;
{ @end $79F4D4 }

{ @routine $79F548 TfSaveManager_FindAutoSaveSlot }
function TfSaveManager.FindAutoSaveSlot: Integer;
begin
  Result := -1;
  if Slots.Count > 0 then
    if PSMSlot(Slots[Slots.Count - 1]).FileName = GetAutoSavePath then Result := Slots.Count - 1;
end;
{ @end $79F548 }

{ @routine $79F5E4 TfSaveManager_BuildCurrentSaveDescription }
function TfSaveManager.BuildCurrentSaveDescription: WideString;
begin
  if GetPlayer.RuinsMode = 0 then
  begin
    if GetPlayer.CurrentPlanet <> nil then
    begin
      if GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      begin
        Result := LocalizedText('FormSaveManager.SaveInShip');
        Result := ReplaceAllWideString(Result,'<ShipName>',GetPlayer.CurrentPlanet.Name);
      end
      else
      begin
        Result := LocalizedText('FormSaveManager.SaveInPlanet');
        Result := ReplaceAllWideString(Result,'<Planet>',GetPlayer.CurrentPlanet.Name);
      end;
    end
    else if GetPlayer.DockedTo <> nil then
    begin
      Result := LocalizedText('FormSaveManager.SaveInShip');
      Result := ReplaceAllWideString(Result,'<ShipName>',GetPlayer.DockedTo.GetFullName(' '));
    end
    else Result := LocalizedText('FormSaveManager.SaveInSpace');
  end
  else
  begin
    if GetPlayer.RuinsSavedPlanet <> nil then
    begin
      if GetPlayer.RuinsSavedPlanet.IsMainPiratePlanet then
      begin
        Result := LocalizedText('FormSaveManager.SaveInShip');
        Result := ReplaceAllWideString(Result,'<ShipName>',GetPlayer.RuinsSavedPlanet.Name);
      end
      else
      begin
        Result := LocalizedText('FormSaveManager.SaveInPlanet');
        Result := ReplaceAllWideString(Result,'<Planet>',GetPlayer.RuinsSavedPlanet.Name);
      end;
    end
    else if GetPlayer.RuinsSavedDockedTo <> nil then
    begin
      Result := LocalizedText('FormSaveManager.SaveInShip');
      Result := ReplaceAllWideString(Result,'<ShipName>',GetPlayer.RuinsSavedDockedTo.GetFullName(' '));
    end
    else Result := LocalizedText('FormSaveManager.SaveInSpace');
  end;
  Result := ReplaceAllWideString(Result,'<Star>',GetPlayer.CurrentStar.Name);
  Result := ReplaceAllWideString(Result,'<Constellation>',GetPlayer.CurrentStar.Constellation.GetName);
  Result := ReplaceAllWideString(Result,'<Player>',GetPlayer.Name);
end;
{ @end $79F5E4 }

{ @routine $79FA08 TfSaveManager_BuildUniqueSavePath }
function TfSaveManager.BuildUniqueSavePath(const FileName: WideString; out SuffixIndex: Integer): WideString;
var
  I, ExistingSuffix, Parts: Integer;
  Directory, BaseName, Extension, ExistingName, Suffix: WideString;
begin
  Directory := TrimWideString(ExtractFileDirW(FileName));
  if Directory = '' then Directory := GetGameUserDirectory + 'save';
  BaseName := TrimWideString(ExtractFileNameNoExtW(FileName));
  Extension := TrimWideString(ExtractFileExtNoDotW(FileName));
  if Extension = '' then Extension := 'sav';
  Parts := CountDelimitedPartsW(BaseName,'()');
  if Parts >= 3 then
  begin
    Suffix := ExtractDelimitedPartW(BaseName,Parts - 2,'()');
    if IsIntegerTextW(Suffix) then BaseName := TrimWideString(ExtractDelimitedRangeW(BaseName,0,Parts - 3,'()'));
  end;
  SuffixIndex := 0;
  I := 0;
  while I < Slots.Count do
  begin
    ExistingName := TrimWideString(LowerCaseWideString(ExtractFileNameNoExtW(PSMSlot(Slots[I]).FileName)));
    Parts := CountDelimitedPartsW(ExistingName,'()');
    ExistingSuffix := 0;
    if Parts >= 3 then
    begin
      Suffix := ExtractDelimitedPartW(ExistingName,Parts - 2,'()');
      if IsIntegerTextW(Suffix) then
      begin
        ExistingName := TrimWideString(ExtractDelimitedRangeW(ExistingName,0,Parts - 3,'()'));
        ExistingSuffix := ExtractDigitsToIntW(Suffix);
      end;
    end;
    if ExistingName = LowerCaseWideString(BaseName) then SuffixIndex := Max(SuffixIndex,ExistingSuffix + 1);
    Inc(I);
  end;
  if SuffixIndex = 0 then Result := Directory + '\' + BaseName + '.' + Extension
  else
  begin
    Parts := CountDelimitedPartsW(BaseName,'()');
    if Parts >= 3 then
    begin
      Suffix := ExtractDelimitedPartW(BaseName,Parts - 2,'()');
      if IsIntegerTextW(Suffix) then Result := Directory + '\' + ExtractDelimitedRangeW(BaseName,0,Parts - 3,'()') + ' (' + IntToStr(SuffixIndex) + ').' + Extension
      else Result := Directory + '\' + BaseName + ' (' + IntToStr(SuffixIndex) + ').' + Extension;
    end
    else Result := Directory + '\' + BaseName + ' (' + IntToStr(SuffixIndex) + ').' + Extension;
  end;
end;
{ @end $79FA08 }

{ @routine $79FE24 TfSaveManager_GetSaveConfigPath }
function TfSaveManager.GetSaveConfigPath(const FileName: WideString): WideString;
var
  Directory, BaseName, Extension: WideString;
begin
  Directory := TrimWideString(ExtractFileDirW(FileName));
  BaseName := TrimWideString(ExtractFileNameNoExtW(FileName));
  Extension := 'txt';
  Result := Directory + '\' + BaseName + '.' + Extension;
end;
{ @end $79FE24 }

{ @routine $79FEEC TfSaveManager_QuickSaveExists }
function TfSaveManager.QuickSaveExists(SlotIndex: Integer): Boolean;
begin
  Result := SysUtils.FileExists(GetQuickSavePath(SlotIndex));
end;
{ @end $79FEEC }

{ @routine $79FF60 TfSaveManager_GetQuickSavePath }
function TfSaveManager.GetQuickSavePath(SlotIndex: Integer): WideString;
begin
  Result := GetGameUserDirectory + 'save\' + QuickSaveFileNames[SlotIndex];
end;
{ @end $79FF60 }

{ @routine $79FFDC TfSaveManager_GetTurnSavePath }
function TfSaveManager.GetTurnSavePath: WideString;
begin
  Result := GetGameUserDirectory + 'save\' + TurnSaveFileName;
end;
{ @end $79FFDC }

{ @routine $7A0050 TfSaveManager_SlotMouseEnter }
procedure TfSaveManager.SlotMouseEnter(Sender: TObjectGI);
begin
  GetByName('Slot' + IntToStr(Cardinal(Sender.UserValue)) + 'onmouse').SetActive((FindAutoSaveSlot <> Sender.UserValue) or (SaveManagerMode <> smmSave));
  SoundManager.PlaySound('Sound.ButtonEnter');
end;
{ @end $7A0050 }

{ @routine $7A0164 TfSaveManager_SlotMouseLeave }
procedure TfSaveManager.SlotMouseLeave(Sender: TObjectGI);
begin
  GetByName('Slot' + IntToStr(Cardinal(Sender.UserValue)) + 'onmouse').SetActive(False);
  SoundManager.PlaySound('Sound.ButtonLeave');
end;
{ @end $7A0164 }

{ @routine $7A03F4 TfSaveManager_ScanSaveFiles }
procedure TfSaveManager.ScanSaveFiles;
var
  Slot: PSMSlot;
  PreviousDirectory: AnsiString;
  Search: THandle;
  I: Integer;
  AutoSlot, NewSlot: PSMSlot;
  FileObject: TFileEC;
  AutoPath: WideString;
  FindData: TWin32FindData;

  // @nested $7A0258 InsertScannedSaveSlotByTime
  procedure InsertScannedSaveSlotByTime; // @addr 0x7A0258 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x7A0872" @note "Nested helper of TfSaveManager.ScanSaveFiles; requires its parent stack frame."
  var
    Low, High, Middle, Comparison: Integer;
    OtherSlot: PSMSlot;
    Time: TFileTime;
  begin
    if Slots.Count < 1 then
    begin
      Slots.Add(Slot);
      Exit;
    end;
    Time := Slot.LocalWriteTime;
    Low := 0;
    OtherSlot := PSMSlot(Slots[0]);
    Comparison := CompareFileTime(OtherSlot.LocalWriteTime,Time);
    if Comparison <= 0 then
    begin
      Slots.Insert(0,Slot);
      Exit;
    end;
    High := Slots.Count - 1;
    OtherSlot := PSMSlot(Slots[High]);
    Comparison := CompareFileTime(OtherSlot.LocalWriteTime,Time);
    if Comparison >= 0 then
    begin
      Slots.Add(Slot);
      Exit;
    end;
    while True do
    begin
      if High - Low < 2 then
      begin
        Slots.Insert(High,Slot);
        Exit;
      end;
      Middle := (Low + High) div 2;
      OtherSlot := PSMSlot(Slots[Middle]);
      Comparison := CompareFileTime(OtherSlot.LocalWriteTime,Time);
      if Comparison = 0 then
      begin
        Slots.Insert(Middle,Slot);
        Exit;
      end
      else if Comparison < 0 then High := Middle
      else Low := Middle;
    end;
  end;
begin
  FileObject := TFileEC.Create;
  AutoPath := GetAutoSavePath;
  PreviousDirectory := GetCurrentDir;
  SetCurrentDir(GetGameUserDirectory + 'Save');
  AutoSlot := nil;
  NewSlot := nil;
  for I := 0 to Slots.Count - 1 do
  begin
    Slot := PSMSlot(Slots[I]);
    Slot.FileName := '';
    Dispose(Slot);
  end;
  Slots.Clear;
  if SaveManagerMode = smmSave then
  begin
    New(NewSlot);
    if GetPlayer.OwnerId = Byte(oiPirate) then
      NewSlot.RaceName := OwnerInfo[Ord(oiPirate)].InternalName + OwnerInfo[RaceToOwner(GetPlayer.PilotRace)].InternalName
    else NewSlot.RaceName := OwnerInfo[GetPlayer.OwnerId].InternalName;
  end;
  try
    FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
    Search := Windows.FindFirstFile('*.sav',FindData);
    if Search <> INVALID_HANDLE_VALUE then
    begin
      repeat
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
        begin
          New(Slot);
          Slot.FileName := GetGameUserDirectory + 'save\' + TrimWideString(WideString(FindData.cFileName));
          if LowerCaseWideString(Slot.FileName) = LowerCaseWideString(GetAutoSavePath) then Slot.FileName := AutoPath;
          Slot.DisplayName := ExtractFileNameNoExtW(Slot.FileName);
          FileTimeToLocalFileTime(FindData.ftLastWriteTime,Slot.LocalWriteTime);
          try
            FileObject.SetFileName(Slot.FileName);
            if not FileObject.TryAcquireReadHandle(True) then
            begin
              SuppressExceptionLogCopy := True;
              raise EAbort.Create('Err');
            end;
            if FileObject.ReadWideString <> 'RSG' then
            begin
              SuppressExceptionLogCopy := True;
              raise EAbort.Create('Err');
            end;
            I := ExtractDigitsToIntW(FileObject.ReadWideString);
            if (I < 13) or (I > CurrentSaveVersion) then
            begin
              SuppressExceptionLogCopy := True;
              raise EAbort.Create('Err');
            end;
            if (Slot.FileName = AutoPath) or RunningUnderWine then Slot.DisplayName := FileObject.ReadWideString
            else FileObject.ReadWideString;
            Slot.Turn := ExtractDigitsToIntW(FileObject.ReadWideString);
            Slot.Money := ExtractDigitsToIntW(FileObject.ReadWideString);
            Slot.PilotName := FileObject.ReadWideString;
            Slot.RaceName := FileObject.ReadWideString;
            if FileObject.ReadWideString <> 'EZ' then
            begin
              SuppressExceptionLogCopy := True;
              raise EAbort.Create('Err');
            end;
            FileObject.ReleaseHandle;
            if Slot.FileName = AutoPath then AutoSlot := Slot else InsertScannedSaveSlotByTime;
          except
            Dispose(Slot);
          end;
        end;
      until not Boolean(Windows.FindNextFile(Search,FindData));
      Windows.FindClose(Search);
    end;
  finally
    FileObject.Free;
    SetCurrentDir(PreviousDirectory);
  end;
  if NewSlot <> nil then Slots.Insert(0,NewSlot);
  if AutoSlot <> nil then Slots.Add(AutoSlot);
end;
{ @end $7A03F4 }

{ @routine $7A09AC TfSaveManager_IsSlotEmpty }
function TfSaveManager.IsSlotEmpty(SlotIndex: Integer): Boolean;
begin
  if (SlotIndex < 0) or (Slots.Count <= SlotIndex) then Result := True
  else Result := PSMSlot(Slots[SlotIndex]).FileName = '';
end;
{ @end $7A09AC }

{ @routine $7A09FC TfSaveManager_FindNewestSlot }
function TfSaveManager.FindNewestSlot: Integer;
var
  I: Integer;
  Latest: TFileTime;
begin
  Result := -1;
  Latest.dwLowDateTime := 0;
  Latest.dwHighDateTime := 0;
  for I := 0 to Slots.Count - 1 do
    if CompareFileTime(PSMSlot(Slots[I]).LocalWriteTime,Latest) > 0 then
    begin
      Latest := PSMSlot(Slots[I]).LocalWriteTime;
      Result := I;
    end;
end;
{ @end $7A09FC }

{ @routine $7A0A88 TfSaveManager_ReadSaveVersion }
function TfSaveManager.ReadSaveVersion(FileName: WideString): Integer;
var
  FileObject: TFileEC;
begin
  FileObject := TFileEC.Create;
  FileObject.SetFileName(FileName);
  FileObject.AcquireReadHandle(False);
  FileObject.TryAcquireReadHandle(False);
  FileObject.ReadWideString;
  Result := ExtractDigitsToIntW(FileObject.ReadWideString);
  FileObject.ReleaseHandle;
  FileObject.Free;
end;
{ @end $7A0A88 }

{ @routine $7A0B44 TfSaveManager_LoadSavePreviews }
procedure TfSaveManager.LoadSavePreviews(FileName: WideString);
var
  FileObject: TFileEC;
  ByteCount: Integer;
  Buffer: TBufEC;
  FirstImage, SecondImage: TGraphBufGI;
begin
  FirstImage := GetByName('GameImage') as TGraphBufGI;
  FirstImage.SetActive(False);
  FirstImage.GraphBuf.Clear;
  FirstImage.Invalidate;
  SecondImage := GetByName('GameImage2') as TGraphBufGI;
  SecondImage.SetActive(False);
  SecondImage.GraphBuf.Clear;
  SecondImage.Invalidate;
  FileObject := TFileEC.Create;
  Buffer := TBufEC.Create;
  try
    FileObject.SetFileName(FileName);
    FileObject.AcquireReadHandle(False);
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadWideString;
    FileObject.ReadBuffer(@ByteCount,4);
    if ByteCount > 0 then
    begin
      Buffer.SetSize(ByteCount);
      FileObject.ReadBuffer(Buffer.Data,ByteCount);
    end;
    if ByteCount > 0 then
    begin
      FirstImage.GraphBuf.LoadFromBuffer(Buffer);
      FirstImage.GraphBuf.RescaleRgb(FirstImage.ClientSize.X,FirstImage.ClientSize.Y);
      FirstImage.GraphBuf.ConvertRgbTo565;
    end;
    FileObject.ReadBuffer(@ByteCount,4);
    if ByteCount > 0 then
    begin
      Buffer.SetSize(ByteCount);
      FileObject.ReadBuffer(Buffer.Data,ByteCount);
    end;
    if ByteCount > 0 then
    begin
      Buffer.SetPosition(0);
      SecondImage.GraphBuf.LoadFromBuffer(Buffer);
      // Native deliberately uses the first control's dimensions for both previews.
      SecondImage.GraphBuf.RescaleRgb(FirstImage.ClientSize.X,FirstImage.ClientSize.Y);
      SecondImage.GraphBuf.ConvertRgbTo565;
    end;
    FileObject.ReleaseHandle;
  except
    FirstImage.GraphBuf.Clear;
    SecondImage.GraphBuf.Clear;
  end;
  FileObject.Free;
  Buffer.Free;
  if PreviewTimer <> nil then
  begin
    CancelCallbackTimer(PreviewTimer);
    PreviewTimer := nil;
  end;
  PreviewTimer := ScheduleCallbackTimer(250,250,FinishPreviewDelay);
  PreviewSound.SetVolume(1);
end;
{ @end $7A0B44 }

{ @routine $7A0E84 TfSaveManager_FinishPreviewDelay }
procedure TfSaveManager.FinishPreviewDelay(Timer: PCallbackTimerGI; UserData: Integer);
begin
  PreviewSound.SetVolume(0);
  if PreviewTimer <> nil then
  begin
    CancelCallbackTimer(PreviewTimer);
    PreviewTimer := nil;
  end;
  if not IsSlotEmpty(SelectedSlot) or ((SelectedSlot = 0) and (SaveManagerMode = smmSave)) then
  begin
    GetByName('GameImage').SetActive(True);
    GetByName('GameImage2').SetActive(True);
  end
  else
  begin
    GetByName('GameImage').SetActive(False);
    GetByName('GameImage2').SetActive(False);
  end;
end;
{ @end $7A0E84 }

{ @routine $7A0F80 TfSaveManager_SelectMusic }
procedure TfSaveManager.SelectMusic;
begin

end;
{ @end $7A0F80 }

end.
