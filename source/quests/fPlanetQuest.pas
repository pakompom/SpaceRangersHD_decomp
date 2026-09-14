unit fPlanetQuest;
// Unit bracket (inferred): .text 0x00551E28..0x0055A72F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_CacheFont, GI_Label, GI_MessageLoop, TextQuest, TextQuestInterface, Types, aRanger, aScript;

type
  TQuestChoiceEvent = procedure(Value: Integer) of object;

  TfQuestA = class(TObject) // @size 0x14
  public
    // No recovered method uses +0x04.
    Callback: TQuestChoiceEvent; // @offset 0x08
    Value: Integer; // @offset 0x10
    constructor Create; // @addr 0x551FE4 @ida "TfQuestA *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x552028 @ida "void __usercall $name(TfQuestA *Self@<eax>, __int8 DestroyFlags@<dl>);"
  end;

  TfPlanetQuest = class(TMessageLoopGI) // @size 0x114
  public
    QuestName: WideString; // @offset 0xD0
    Quest: TTextQuest; // @offset 0xD4 // Owned until OnClose.
    CurrentDate: WideString; // @offset 0xD8
    DaysElapsed: Integer; // @offset 0xDC
    CurrentPicture: WideString; // @offset 0xE0
    MoneyLimitComplement: Cardinal; // @offset 0xE4
    CurrentText: WideString; // @offset 0xE8
    NextChoiceTop: Integer; // @offset 0xEC
    ParameterPanelWidth: Integer; // @offset 0xF0
    ParameterPanelHeight: Integer; // @offset 0xF4
    PageAnimationTimer: PCallbackTimerGI; // @offset 0xF8
    PreviousStyleIndex: Integer; // @offset 0xFC
    ChoiceCount: Integer; // @offset 0x100
    ParameterPanelOrigin: TPoint; // @offset 0x106 // Unaligned in the native layout.
    QuestId: Integer; // @offset 0x110 // -1 for a named quest.

    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr 0x553738
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr 0x553758
    procedure DisabledChoiceMouseEnter(Sender: TObjectGI); // @addr 0x5538AC
    procedure DisabledChoiceMouseLeave(Sender: TObjectGI); // @addr 0x5538CC
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x553778 @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5537F8 @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure DisabledChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x553948 @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    function CreateChoiceInlineObject(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr 0x5534C8
    procedure IgnoreChoice(Value: Integer); // @addr 0x5585F4 @note "Empty callback."
    procedure ContinueToLocation(LocationId: Integer); // @addr 0x558604
    procedure ContinueAlongPath(PathId: Integer); // @addr 0x558630
    procedure ContinueToOutcome(Value: Integer); // @addr 0x55865C @note "Value is unused."
    procedure AnimateTextPage(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x553E88
    procedure SetQuestText(const Text: WideString); // @addr 0x554A68 @note "<fix> sections use the fixed-width font."
    function GetTextColor(StyleIndex: Integer): Cardinal; // @addr 0x556970
    function GetDisabledTextColor(StyleIndex: Integer): Cardinal; // @addr 0x556B8C
    procedure ApplyStyle; // @addr 0x556DA0
    procedure SelectPageMode(Sender: TObjectGI); // @addr 0x557584
    procedure SelectStyle(Sender: TObjectGI); // @addr 0x5576F4
    procedure ShowControlHelp(Sender: TObjectGI; Visible: Boolean); // @addr 0x557810
    procedure SetQuestPicture(Name: WideString); // @addr 0x55793C @note "Suppresses repeated picture names."
    procedure RequestLoadGame(Sender: TObjectGI); // @addr 0x557AB0
    procedure QuestKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr 0x557BF4
    procedure SelectMusic; override; // @addr 0x557ED0
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x55A6B8
    procedure CompleteQuestSuccess(Value: Integer); // @addr 0x558684 @note "Queued script quests report status 2."
    procedure CompleteQuestFailure(Value: Integer); // @addr 0x558B48 @note "Queued script quests report status 3."
    procedure CompleteQuestDeath(Value: Integer); // @addr 0x558F9C
    procedure ClearChoices; // @addr 0x5527A0
    procedure AddChoice(Text: WideString; Value: Integer; Callback: TQuestChoiceEvent); // @addr 0x552890
    procedure AddDisabledChoice(Text: WideString; Value: Integer; Callback: TQuestChoiceEvent); // @addr 0x552E8C @note "Value and callback are ignored."
    procedure FinishChoiceLayout; // @addr 0x553BCC
    procedure ClearParameterPanel; // @addr 0x554080
    procedure AppendParameterText(Text: WideString); // @addr 0x5540F0
    procedure LayoutParameterPanel; // @addr 0x554480
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x5539CC @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);" @note "Only exact deltas of +120 and -120 are handled."
    procedure InitializeLayout; override; // @addr 0x554DB8
    procedure OnOpen; override; // @addr 0x555794
    procedure OnClose; override; // @addr 0x556500
    function GetTextBeforeDelimiter(const Text: WideString; Delimiter: WideChar): WideString; // @addr 0x55205C @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, unsigned __int16 *Text@<edx>, unsigned __int16 Delimiter@<cx>, unsigned __int16 **Result@<^0>);"
    function GetTextAfterComma(const Text: WideString; IgnoredDelimiter: WideChar): WideString; // @addr 0x552118 @ida "void __userpurge $name(TfPlanetQuest *Self@<eax>, unsigned __int16 *Text@<edx>, unsigned __int16 IgnoredDelimiter@<cx>, unsigned __int16 **Result@<^0>);" @note "A nonempty string without a comma is read past its end."
    function GetQuestContentHash(QuestId: Integer): WideString; // @addr 0x5521E0 @ida "void __usercall $name(TfPlanetQuest *Self@<eax>, int QuestId@<edx>, unsigned __int16 **Result@<ecx>);" @note "Hexadecimal complement of the quest buffer's CRC32."
    procedure LoadQuestById(QuestId: Integer); // @addr 0x552300
    procedure LoadQuestByName(const Name: WideString); // @addr 0x552550
    procedure ApplyLegacyPictureOverrides; // @addr 0x5590E4 @note "PQI keys are quest,L|P|PAR,indices; picture names lose the Bm.PQI. prefix."
    procedure ExportMoneyToPlayer; // @addr 0x5594E8 @note "Uses the first enabled money parameter; writes the player's clamped balance back."
    procedure ImportMoneyFromPlayer; // @addr 0x5595A0 @note "Uses the first enabled money parameter."
    // ext_name maps to GQuestVarExt_name; queued-script scope takes precedence over global scope.
    procedure ExportExternalParameters; // @addr 0x559630
    procedure ImportExternalParameters; // @addr 0x559798 @note "Writes clamped parameter values back to the script variables."
    function ExpandExternalText(Text: WideString): WideString; // @addr 0x559924 @ida "void __usercall $name(TfPlanetQuest *Self@<eax>, unsigned __int16 *Text@<edx>, unsigned __int16 **Result@<ecx>);" @note "<txt_name> uses global GQuestVarExt_name; queued-script scope is ignored."
    function ExpandTemplateText(Text: WideString): WideString; // @addr 0x557F14 @ida "void __usercall $name(TfPlanetQuest *Self@<eax>, unsigned __int16 *Text@<edx>, unsigned __int16 **Result@<ecx>);"
    function GetTextColorTag(StyleIndex: Integer): WideString; // @addr 0x556648 @ida "void __usercall $name(TfPlanetQuest *Self@<eax>, int StyleIndex@<edx>, unsigned __int16 **Result@<ecx>);" @note "StyleIndex is zero-based."
    procedure StartLoadedQuest; // @addr 0x552668 @note "Applies PQI overrides only through quest version 1111111124."
  end;

  // Methods use the active planet-quest screen; the interface has no instance state.
  TTextQuestPlayerInterface = class(TTextQuestInterface) // @size 0x04
  public
    procedure ShowText(Text: WideString); override; // @addr 0x559B08 @note "Suppresses repeated text after template expansion."
    procedure ShowPicture(Name: WideString); override; // @addr 0x559BAC
    procedure PlayMusic(Name: WideString); override; // @addr 0x559C00
    procedure PlaySound(Name: WideString); override; // @addr 0x559C68
    procedure ShowParameters(Text: WideString); override; // @addr 0x559CE8
    procedure AddContinueAction; override; // @addr 0x559D94
    procedure AddSuccessAction; override; // @addr 0x559E70
    procedure AddDeathAction; override; // @addr 0x55A05C
    procedure AddFailureAction; override; // @addr 0x55A134
    procedure AddPathAction(Text: WideString; PathId: Integer); override; // @addr 0x55A310
    procedure AddDisabledPath(Text: WideString); override; // @addr 0x55A3C0
    procedure AddPathContinueAction(PathId: Integer); override; // @addr 0x55A460
    procedure AddLocationContinueAction(LocationId: Integer); override; // @addr 0x55A544
    procedure AdvanceDays(Days: Integer); override; // @addr 0x55A628
  end;

// Nested helpers of TfPlanetQuest.SetQuestText; FontMode is zero for proportional text, one for fixed-width text.

var
  QuestStyleCount: Integer = 0; // @addr 0x87AA28
  ActiveGovernmentQuest: PQuest = nil; // @addr 0x87AA2C
  QuestPlayerInterface: TTextQuestPlayerInterface = nil; // @addr 0x87AA30
  ActiveQueuedTextQuest: PQueuedTextQuest = nil; // @addr 0x87AA34

implementation

uses Windows, Classes, Math, GI_GraphBuf, GI_GraphButton, GI_ScrollBar, GI_Window, EC_Cache, EC_CacheBuf, EC_Expression, EC_Str, GI_Image,
  GI_Main, GI_Panel, GI_PanelScrollBar, Globals, GlobalsV, GR_Main,
  SysUtils, ThreadCalc, aCalc, ParameterClass, aConst, aGalaxy, aPlayer, GI_MessageBox,
  fSaveManager, fScore, fLoadQuest, fHangar, aShip, aPlanet, aItem, Achievements, aGalaxyStruct, ValueListClass, EventClass, aMyFunction;

{ @routine $551FE4 TfQuestA_Create }
constructor TfQuestA.Create;
begin
  inherited Create;
end;
{ @end $551FE4 }

{ @routine $552028 TfQuestA_Destroy }
destructor TfQuestA.Destroy;
begin
  inherited Destroy;
end;
{ @end $552028 }

{ @routine $55205C TfPlanetQuest_GetTextBeforeDelimiter }
function TfPlanetQuest.GetTextBeforeDelimiter(const Text: WideString; Delimiter: WideChar): WideString;
var
  I, N: Integer;
  S: WideString;
begin
  S := '';
  N := Length(Text);
  for I := 1 to N do
  begin
    if Text[I] = Delimiter then Break;
    S := S + Text[I];
  end;
  Result := S;
end;
{ @end $55205C }

{ @routine $552118 TfPlanetQuest_GetTextAfterComma }
function TfPlanetQuest.GetTextAfterComma(const Text: WideString; IgnoredDelimiter: WideChar): WideString;
var
  I, N: Integer;
  S: WideString;
begin
  S := '';
  N := Length(Text);
  if N <> 0 then
  begin
    I := 1;
    while Text[I] <> ',' do Inc(I);
    Inc(I);
    while I <= N do
    begin
      S := S + Text[I];
      Inc(I);
    end;
  end;
  Result := S;
end;
{ @end $552118 }

{ @routine $5521E0 TfPlanetQuest_GetQuestContentHash }
function TfPlanetQuest.GetQuestContentHash(QuestId: Integer): WideString;
var
  Control: TCBufControlEC;
  Data: TCBufEC;
begin
  Control := nil;
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey('PlanetQuest.' + IntToStr(QuestId));
    Data := AcquireOrCreateBuffer(Control);
    Result := ScriptDwordToHex(Data.Buffer.ComputeCrc32 xor $FFFFFFFF);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $5521E0 }

{ @routine $552300 TfPlanetQuest_LoadQuestById }
procedure TfPlanetQuest.LoadQuestById(QuestId: Integer);
var
  Control: TCBufControlEC;
  Data: TCBufEC;
begin
  Self.QuestId := QuestId;
  Control := nil;
  QuestName := IntToStr(QuestId);
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey('PlanetQuest.' + IntToStr(QuestId));
    Data := AcquireOrCreateBuffer(Control);
    Quest.LoadFromReader(Data.Buffer, False);
    if not StandaloneQuestMode then
      if QuestId >= 10000 then
        if (LanguageDataConfig.GetBlock('PlanetQuest').CountBlocks('PlanetQuestLic') <= 0) or
          (LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuestLic').GetParamOrMarker(IntToStr(QuestId)) <>
            ScriptDwordToHex(Data.Buffer.ComputeCrc32 xor $FFFFFFFF)) then
          GR_Main.CCInterface.SetTamperDetected(True);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $552300 }

{ @routine $552550 TfPlanetQuest_LoadQuestByName }
procedure TfPlanetQuest.LoadQuestByName(const Name: WideString);
var
  Control: TCBufControlEC;
  Data: TCBufEC;
begin
  QuestId := -1;
  Control := nil;
  QuestName := Name;
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey('PlanetQuest.' + Name);
    Data := AcquireOrCreateBuffer(Control);
    Quest.LoadFromReader(Data.Buffer, False);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $552550 }

{ @routine $552668 TfPlanetQuest_StartLoadedQuest }
procedure TfPlanetQuest.StartLoadedQuest;
begin
  ClearChoices;
  DaysElapsed := 0;
  if Quest.FormatVersion <= 1111111124 then ApplyLegacyPictureOverrides;
  if GetPlayer = nil then CurrentDate := TrimWideString(Galaxy.FormatTurnDate(300))
  else CurrentDate := TrimWideString(Galaxy.FormatTurnDate(Galaxy.CurrentTurn));
  Quest.PlayerInterface := QuestPlayerInterface;
  ImportExternalParameters;
  if GetPlayer = nil then Quest.Start(-1, False)
  else Quest.Start(GetPlayer.Money, True);
  FinishChoiceLayout;
end;
{ @end $552668 }

{ @routine $5527A0 TfPlanetQuest_ClearChoices }
procedure TfPlanetQuest.ClearChoices;
var
  Panel: TPanelScrollBarGI;
  Spacer: TPanelGI;
begin
  Panel := GetByName('ActionListWindow') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  Panel.Invalidate;
  NextChoiceTop := 10;
  ParameterPanelWidth := 0;
  ParameterPanelHeight := 0;
  ChoiceCount := 0;
  Spacer := TPanelGI.Create(GetByName('ActionListWindow'));
  Spacer.SetPosition(Classes.Point(0, 0));
  Spacer.SetSize(Classes.Point(10, 10));
  Spacer.SetPositionModeW(True);
end;
{ @end $5527A0 }

{ @routine $552890 TfPlanetQuest_AddChoice }
procedure TfPlanetQuest.AddChoice(Text: WideString; Value: Integer; Callback: TQuestChoiceEvent);
var
  Owner: TPanelScrollBarGI;
  Skip: Integer;
  Panel: TPanelGI;
  Highlight: TImageGI;
  Choice: TfQuestA;
  Path: WideString;
  TextLabel: TLabelGI;
begin
  Skip := 0;
  while Skip < Length(Text) do
  begin
    if (Text[Skip + 1] <> '-') and (Text[Skip + 1] <> ' ') then Break;
    Inc(Skip);
  end;
  if Skip > 0 then Text := Copy(Text, Skip + 1, Length(Text) - Skip);
  Owner := GetByName('ActionListWindow') as TPanelScrollBarGI;
  Choice := TfQuestA.Create;
  Choice.Callback := Callback;
  Choice.Value := Value;
  Panel := TPanelGI.Create(Owner);
  Panel.UserValue := Integer(Choice);
  Panel.SetName(IntToStr(ChoiceCount));
  Panel.SetPosition(Classes.Point(0, NextChoiceTop));
  Panel.SetSize(Classes.Point(Owner.ClientSize.X, 20));
  Panel.SetPositionModeW(True);
  Panel.MouseEnterCallback := ChoiceMouseEnter;
  Panel.MouseLeaveCallback := ChoiceMouseLeave;
  Panel.LeftButtonDownCallback := ChoiceMouseDown;
  Panel.LeftButtonUpCallback := ChoiceMouseUp;
  Highlight := TImageGI.Create(Panel);
  Highlight.SetDepth(3);
  Highlight.SetPosition(Classes.Point(0, 0));
  Highlight.SetSize(Classes.Point(Owner.ClientSize.X, 20));
  Path := 'Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1) + 'Line';
  if CacheDataRoot.FileExistsByPath(Path) then Highlight.SetImagePath('GI,' + Path)
  else Highlight.SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1Line');
  Highlight.SetImageKindX(ikxLeftFill);
  Highlight.SetImageKindY(ikyTopFill);
  Highlight.SetActive(False);
  TextLabel := TLabelGI.Create(Panel);
  TextLabel.SetName(IntToStr(ChoiceCount));
  if FontQuest = 0 then TextLabel.SetFontName(NormalFontName)
  else if FontQuest = 1 then TextLabel.SetFontName(SmoothBigFontName)
  else if FontQuest = 2 then TextLabel.SetFontName(SmoothHugeFontName)
  else if FontQuest >= 3 then TextLabel.SetFontName(SmoothIntroFontName);
  TextLabel.SetSize(Classes.Point(Owner.ClientSize.X - 20, 20));
  TextLabel.SetPosition(Classes.Point(10, 0));
  TextLabel.SetDepth(2);
  TextLabel.SetWordWrapEnabled(True);
  TextLabel.SetTextAlignX(taxLeft);
  TextLabel.SetTextAlignY(tayAuto);
  TextLabel.SetText('<Object=0,20,14,0>' + Text);
  TextLabel.SetPositionModeW(True);
  TextLabel.SetActive(True);
  TextLabel.CreateEmbeddedControl := CreateChoiceInlineObject;
  TextLabel.SetTextAlignY(tayCenterEx);
  TextLabel.SetTextColor(GetTextColor(QuestStyleIndex));
  Panel.SetSize(Classes.Point(Panel.ClientSize.X, GiScalePixelsEx(2, 1) * 2 + TextLabel.ClientSize.Y));
  TextLabel.SetSize(Classes.Point(TextLabel.ClientSize.X, Panel.ClientSize.Y));
  Highlight.SetSize(Panel.ClientSize);
  Inc(NextChoiceTop, Panel.ClientSize.Y);
  Owner.VerticalScrollBar.SetSmallChange(TextLabel.GetLineHeight);
  Owner.UpdateScrollRanges;
  Inc(ChoiceCount);
end;
{ @end $552890 }

{ @routine $552E8C TfPlanetQuest_AddDisabledChoice }
procedure TfPlanetQuest.AddDisabledChoice(Text: WideString; Value: Integer; Callback: TQuestChoiceEvent);
var
  Owner: TPanelScrollBarGI;
  Skip: Integer;
  Panel: TPanelGI;
  Highlight: TImageGI;
  Path: WideString;
  TextLabel: TLabelGI;
begin
  Skip := 0;
  while Skip < Length(Text) do
  begin
    if (Text[Skip + 1] <> '-') and (Text[Skip + 1] <> ' ') then Break;
    Inc(Skip);
  end;
  if Skip > 0 then Text := Copy(Text, Skip + 1, Length(Text) - Skip);
  Text := RemoveMatchingTextTagsW(Text, 'color', 'COLOR');
  Text := RemoveMatchingTextTagsW(Text, '/color', '/COLOR');
  Owner := GetByName('ActionListWindow') as TPanelScrollBarGI;
  Panel := TPanelGI.Create(Owner);
  Panel.SetName(IntToStr(ChoiceCount));
  Panel.SetPosition(Classes.Point(0, NextChoiceTop));
  Panel.SetSize(Classes.Point(Owner.ClientSize.X, 20));
  Panel.SetPositionModeW(True);
  Panel.MouseEnterCallback := DisabledChoiceMouseEnter;
  Panel.MouseLeaveCallback := DisabledChoiceMouseLeave;
  Panel.LeftButtonDownCallback := ChoiceMouseDown;
  Panel.LeftButtonUpCallback := DisabledChoiceMouseUp;
  Highlight := TImageGI.Create(Panel);
  Highlight.SetDepth(3);
  Highlight.SetPosition(Classes.Point(0, 0));
  Highlight.SetSize(Classes.Point(Owner.ClientSize.X, 20));
  Path := 'Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1) + 'Line';
  if CacheDataRoot.FileExistsByPath(Path) then Highlight.SetImagePath('GI,' + Path)
  else Highlight.SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1Line');
  Highlight.SetImageKindX(ikxLeftFill);
  Highlight.SetImageKindY(ikyTopFill);
  Highlight.SetActive(False);
  TextLabel := TLabelGI.Create(Panel);
  TextLabel.SetName(IntToStr(ChoiceCount));
  if FontQuest = 0 then TextLabel.SetFontName(NormalFontName)
  else if FontQuest = 1 then TextLabel.SetFontName(SmoothBigFontName)
  else if FontQuest = 2 then TextLabel.SetFontName(SmoothHugeFontName)
  else if FontQuest >= 3 then TextLabel.SetFontName(SmoothIntroFontName);
  TextLabel.SetSize(Classes.Point(Owner.ClientSize.X - 20, 20));
  TextLabel.SetPosition(Classes.Point(10, 0));
  TextLabel.SetDepth(2);
  TextLabel.SetWordWrapEnabled(True);
  TextLabel.SetTextAlignX(taxLeft);
  TextLabel.SetTextAlignY(tayAuto);
  TextLabel.SetText('<Object=0,20,14,0>' + Text);
  TextLabel.SetPositionModeW(False);
  TextLabel.SetActive(True);
  TextLabel.UserState := 1;
  TextLabel.CreateEmbeddedControl := CreateChoiceInlineObject;
  TextLabel.SetTextAlignY(tayCenterEx);
  TextLabel.SetTextColor(GetDisabledTextColor(QuestStyleIndex));
  Panel.SetSize(Classes.Point(Panel.ClientSize.X, GiScalePixelsEx(2, 1) * 2 + TextLabel.ClientSize.Y));
  TextLabel.SetSize(Panel.ClientSize);
  Highlight.SetSize(Panel.ClientSize);
  Inc(NextChoiceTop, Panel.ClientSize.Y);
  Owner.UpdateScrollRanges;
  Inc(ChoiceCount);
end;
{ @end $552E8C }

{ @routine $5534C8 TfPlanetQuest_CreateChoiceInlineObject }
function TfPlanetQuest.CreateChoiceInlineObject(Sender: TLabelGI; Item: PFontObjectEC): TObjectGI;
var
  Path: WideString;
  Image: TImageGI;
begin
  Result := TPanelGI.Create(Sender);
  Image := TImageGI.Create(Result);
  Path := 'Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1) + 'Answer';
  if Sender.UserState = 1 then
  begin
    if CacheDataRoot.FileExistsByPath(Path + 'H') then Image.SetImagePath('GI,' + Path + 'H')
    else Image.SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1AnswerH');
  end
  else
  begin
    if CacheDataRoot.FileExistsByPath(Path) then Image.SetImagePath('GI,' + Path)
    else Image.SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1Answer');
  end;
  Image.SetImageKindX(ikxLeft);
  Image.SetSize(Image.GetContentSize);
end;
{ @end $5534C8 }

{ @routine $553738 TfPlanetQuest_ChoiceMouseEnter }
procedure TfPlanetQuest.ChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $553738 }

{ @routine $553758 TfPlanetQuest_ChoiceMouseLeave }
procedure TfPlanetQuest.ChoiceMouseLeave(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(False);
end;
{ @end $553758 }

{ @routine $553778 TfPlanetQuest_ChoiceMouseDown }
procedure TfPlanetQuest.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(2, 0));
end;
{ @end $553778 }

{ @routine $5537F8 TfPlanetQuest_ChoiceMouseUp }
procedure TfPlanetQuest.ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Choice: TfQuestA;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(163);
  Choice := TfQuestA(Sender.UserValue);
  Sender.UserValue := 0;
  ClearChoices;
  if Choice <> nil then
  begin
    if Assigned(Choice.Callback) then Choice.Callback(Choice.Value);
    Choice.Free;
  end;
  FinishChoiceLayout;
  if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(164);
  PostMouseMoveMessage;
  BreakUiMessage;
end;
{ @end $5537F8 }

{ @routine $5538AC TfPlanetQuest_DisabledChoiceMouseEnter }
procedure TfPlanetQuest.DisabledChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $5538AC }

{ @routine $5538CC TfPlanetQuest_DisabledChoiceMouseLeave }
procedure TfPlanetQuest.DisabledChoiceMouseLeave(Sender: TObjectGI);
begin
  if (Sender <> nil) and (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
  begin
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(0, 0));
    Sender.FirstChild.SetActive(False);
  end;
end;
{ @end $5538CC }

{ @routine $553948 TfPlanetQuest_DisabledChoiceMouseUp }
procedure TfPlanetQuest.DisabledChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(0, 0));
end;
{ @end $553948 }

{ @routine $5539CC TfPlanetQuest_ProcessMouseWheel }
procedure TfPlanetQuest.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel1, Panel2, Panel3, Panel4: TPanelScrollBarGI;
begin
  if Delta = WHEEL_DELTA then
  begin
    if GetByName('ActionListWindow').ContainsPoint(Point) then
    begin
      Panel1 := GetByName('ActionListWindow') as TPanelScrollBarGI;
      Panel1.SetScrollOffset(Classes.Point(0, Panel1.ScrollOffset.Y - Panel1.VerticalScrollBar.SmallChange));
      Panel1.PanelScrollChanged(nil);
    end
    else
    begin
      Panel2 := GetByName('MessageWindow') as TPanelScrollBarGI;
      Panel2.SetScrollOffset(Classes.Point(0, Panel2.ScrollOffset.Y - Panel2.VerticalScrollBar.SmallChange));
      Panel2.PanelScrollChanged(nil);
    end;
  end
  else if Delta = -WHEEL_DELTA then
  begin
    if GetByName('ActionListWindow').ContainsPoint(Point) then
    begin
      Panel3 := GetByName('ActionListWindow') as TPanelScrollBarGI;
      Panel3.SetScrollOffset(Classes.Point(0, Panel3.ScrollOffset.Y + Panel3.VerticalScrollBar.SmallChange));
      Panel3.PanelScrollChanged(nil);
    end
    else
    begin
      Panel4 := GetByName('MessageWindow') as TPanelScrollBarGI;
      Panel4.SetScrollOffset(Classes.Point(0, Panel4.ScrollOffset.Y + Panel4.VerticalScrollBar.SmallChange));
      Panel4.PanelScrollChanged(nil);
    end;
  end;
end;
{ @end $5539CC }

{ @routine $553BCC TfPlanetQuest_FinishChoiceLayout }
procedure TfPlanetQuest.FinishChoiceLayout;
var
  Panel: TPanelScrollBarGI;
  Control: TObjectGI;
  LineCount, Page, ExtraOffset: Integer;
  Spacer: TPanelGI;
begin
  Inc(NextChoiceTop, 10);
  Panel := GetByName('ActionListWindow') as TPanelScrollBarGI;
  Spacer := TPanelGI.Create(Panel);
  Spacer.SetPosition(Classes.Point(0, NextChoiceTop - 10));
  Spacer.SetSize(Classes.Point(10, 10));
  Spacer.SetPositionModeW(True);
  Panel.SetActive(True);
  Panel.SetVerticalScrollbarEnabled(NextChoiceTop > Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  Panel.SetScrollOffset(Classes.Point(0, 0));
  Panel.SetDragScrollingEnabled(Panel.IsVerticalScrollbarEnabled);
  Panel.UpdateScrollRanges;
  if QuestPageAnimationEnabled then
  begin
    GetByName('ActionListWindow').SetActive(False);
    Panel := GetByName('MessageWindow') as TPanelScrollBarGI;
    Panel.SetUnlimitedWorldEnabled(True);
    Panel.SetDragScrollingEnabled(False);
    Control := Panel.FirstChild;
    LineCount := 0;
    Page := 1;
    ExtraOffset := 0;
    while Control <> nil do
    begin
      Control.UserIndex := Control.LocalPosition.Y;
      if Control is TLabelGI then
        if Control.LocalPosition.Y < Panel.ClientSize.Y then
        begin
          Control.UserValue := Page;
          if Page > 1 then Control.SetPosition(Classes.Point(Control.LocalPosition.X, -Control.LocalPosition.Y - Control.ClientSize.Y - ExtraOffset));
          Inc(LineCount, (Control as TLabelGI).GetRenderedLineCount);
          if LineCount > 5 then
          begin
            LineCount := 0;
            Inc(Page);
          end;
        end;
      Control := Control.NextSibling;
    end;
    if PageAnimationTimer <> nil then
    begin
      CancelCallbackTimer(PageAnimationTimer);
      PageAnimationTimer := nil;
    end;
    PageAnimationTimer := ScheduleCallbackTimer(20, 20, AnimateTextPage);
  end;
end;
{ @end $553BCC }

{ @routine $553E88 TfPlanetQuest_AnimateTextPage }
procedure TfPlanetQuest.AnimateTextPage(Timer: PCallbackTimerGI; UserData: Integer);
var
  Panel: TPanelScrollBarGI;
  Control: TObjectGI;
  Moving: Boolean;
  Step: Integer;
begin
  Moving := False;
  Panel := GetByName('MessageWindow') as TPanelScrollBarGI;
  Control := Panel.FirstChild;
  while Control <> nil do
  begin
    if Control is TLabelGI then
      if Control.LocalPosition.Y < Control.UserIndex then
      begin
        Moving := True;
        Step := Round(Min(1.0, (Control.UserIndex - Control.LocalPosition.Y) / 100) * 30);
        if Step < 1 then Step := 1;
        Control.SetPosition(Classes.Point(Control.LocalPosition.X, Min(Control.UserIndex, Control.LocalPosition.Y + Step)));
      end;
    Control := Control.NextSibling;
  end;
  if not Moving then
  begin
    Panel.SetUnlimitedWorldEnabled(False);
    Panel.SetDragScrollingEnabled(True);
    if PageAnimationTimer <> nil then
    begin
      CancelCallbackTimer(PageAnimationTimer);
      PageAnimationTimer := nil;
    end;
    GetByName('ActionListWindow').SetActive(True);
    PostMouseMoveMessage;
  end;
end;
{ @end $553E88 }

{ @routine $554080 TfPlanetQuest_ClearParameterPanel }
procedure TfPlanetQuest.ClearParameterPanel;
var
  Panel: TPanelGI;
begin
  Panel := GetByName('ParamsShowWindow') as TPanelGI;
  Panel.FreeOwnedChildren;
  ParameterPanelWidth := 0;
  ParameterPanelHeight := 0;
end;
{ @end $554080 }

{ @routine $5540F0 TfPlanetQuest_AppendParameterText }
procedure TfPlanetQuest.AppendParameterText(Text: WideString);
var
  Panel: TPanelGI;
  FixedWidth: Boolean;
  Lines: TStringsEC;
  TextLabel: TLabelGI;
begin
  Panel := GetByName('ParamsShowWindow') as TPanelGI;
  FixedWidth := FindTextOffsetW(LowerCaseWideString(Text), '<fix>') >= 0;
  Text := RemoveMatchingTextTagsW(Text, 'fix', 'FIX');
  Text := RemoveMatchingTextTagsW(Text, '/fix', '/FIX');
  Text := ReplaceAllWideString(Text, GetTextColorTag(QuestStyleIndex), '<color=255,240,100>');
  Lines := TStringsEC.Create;
  Lines.SetText(Text);
  Lines.First;
  while not Lines.IsAtEnd do
  begin
    TextLabel := TLabelGI.Create(Panel);
    if FixedWidth then TextLabel.SetFontName('Font.' + GiResourceSuffix + 'Fix')
    else TextLabel.SetFontName(NormalFontName);
    TextLabel.SetSize(Classes.Point(1, 1));
    TextLabel.SetTextAlignX(taxAuto);
    TextLabel.SetTextAlignY(tayAuto);
    TextLabel.SetWordWrapEnabled(False);
    TextLabel.SetText(Lines.GetCurrentText);
    TextLabel.SetTextColor(GetTextColor(0));
    TextLabel.SetPosition(Classes.Point(0, ParameterPanelHeight));
    TextLabel.SetTextAlignY(tayCenterEx);
    if TextLabel.ClientSize.Y < 10 then TextLabel.SetSize(Classes.Point(TextLabel.ClientSize.X, TextLabel.ClientSize.Y + 10));
    Inc(ParameterPanelHeight, TextLabel.ClientSize.Y);
    TextLabel.UserData := Integer(FixedWidth);
    if FixedWidth then Inc(ParameterPanelHeight, 2);
    ParameterPanelWidth := Max(ParameterPanelWidth, TextLabel.ClientSize.X);
    Lines.Next;
  end;
  Lines.Free;
end;
{ @end $5540F0 }

{ @routine $554480 TfPlanetQuest_LayoutParameterPanel }
procedure TfPlanetQuest.LayoutParameterPanel;
var
  Window: TWindowGI;
  Panel: TPanelGI;
  Control: TObjectGI;
  Y: Integer;
begin
  Window := GetByName('ParamsShowWindowParent') as TWindowGI;
  Panel := GetByName('ParamsShowWindow') as TPanelGI;
  Window.SetPosition(ParameterPanelOrigin);
  Window.SetSize(Classes.Point(ParameterPanelWidth + Window.WorkSubRect.Left + Window.WorkSubRect.Right,
    ParameterPanelHeight + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
  Window.UpdateAutoGeometry;
  Panel.SetSize(Window.ClientSize);
  Y := 0;
  Control := Panel.FirstChild;
  while Control <> nil do
  begin
    Control.SetPosition(Classes.Point(Window.WorkSubRect.Left,
      (Window.ClientSize.Y - Window.WorkSubRect.Top - Window.WorkSubRect.Bottom - ParameterPanelHeight) div 2 + (Window.WorkSubRect.Top + Y)));
    Inc(Y, Control.ClientSize.Y);
    if Control.UserData <> 0 then Inc(Y, 2);
    Control := Control.NextSibling;
  end;
  if GameScreenHeight - GiScalePixels(30) < Window.LocalPosition.Y + Window.ClientSize.Y then
    Window.SetPosition(Classes.Point(Window.LocalPosition.X, GameScreenHeight - GiScalePixels(30) - Window.ClientSize.Y));
  if GameScreenWidth - GiScalePixels(10) < Window.LocalPosition.X + Window.ClientSize.X then
    Window.SetPosition(Classes.Point(GameScreenWidth - GiScalePixels(10) - Window.ClientSize.X, Window.LocalPosition.Y));
end;
{ @end $554480 }

{ @routine $554A68 TfPlanetQuest_SetQuestText }
procedure TfPlanetQuest.SetQuestText(const Text: WideString);
var
  Panel: TPanelScrollBarGI;
  NextTop: Integer;
  Lines: TStringsEC;
  LowerText: WideString;
  StartIndex, TagIndex, TextLength: Integer;

  // @nested $5546D4 AddQuestTextParagraph
  procedure AddQuestTextParagraph(const Text: WideString; FontMode: Integer); // @addr 0x5546D4 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, int FontMode@<edx>, void *ParentFrame@<^0>);"
  var
    Indent: Boolean;
    I: Integer;
    TextLabel: TLabelGI;
  begin
    if Text <> '' then
    begin
      Indent := False;
      if FontMode = 0 then
      begin
        Indent := True;
        I := 0;
        while I < Length(Text) do
        begin
          if PWideChar(Pointer(Text))[I] = '-' then
          begin
            Indent := False;
            Break;
          end
          else
          begin
            if (PWideChar(Pointer(Text))[I] <> ' ') and (PWideChar(Pointer(Text))[I] <> #9) then Break;
            Inc(I);
          end;
        end;
      end;
      TextLabel := TLabelGI.Create(Panel);
      if FontMode = 0 then
      begin
        if FontQuest = 0 then TextLabel.SetFontName(NormalFontName)
        else if FontQuest = 1 then TextLabel.SetFontName(SmoothBigFontName)
        else if FontQuest = 2 then TextLabel.SetFontName(SmoothHugeFontName)
        else if FontQuest >= 3 then TextLabel.SetFontName(SmoothIntroFontName);
      end
      else TextLabel.SetFontName('Font.' + GiResourceSuffix + 'Fix');
      TextLabel.SetPosition(Point(0, NextTop));
      TextLabel.SetSize(Point(Panel.ClientSize.X, 1));
      TextLabel.SetWordWrapEnabled(True);
      TextLabel.SetTextAlignX(taxAuto);
      TextLabel.SetTextAlignY(tayAuto);
      if Indent then TextLabel.SetText('     ' + Text)
      else TextLabel.SetText(Text);
      TextLabel.SetPositionModeW(True);
      TextLabel.SetTextColor(GetTextColor(QuestStyleIndex));
      TextLabel.SetTextAlignY(tayTop);
      { Preserve native getter order: rendered line count, then line height. }
      TextLabel.SetSize(Point(TextLabel.ClientSize.X,
        Max(1, TextLabel.GetRenderedLineCount) * TextLabel.GetLineHeight + 4));
      NextTop := TextLabel.LocalPosition.Y + TextLabel.ClientSize.Y - 2;
    end;
  end;

  // @nested $554988 AddQuestTextLines
  procedure AddQuestTextLines(const Text: WideString; FontMode: Integer); // @addr 0x554988 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, int FontMode@<edx>, void *ParentFrame@<^0>);"
  var
    N, StartIndex, EndIndex: Integer;
  begin
    N := Length(Text);
    StartIndex := 0;
    while StartIndex < N do
    begin
      EndIndex := FindTextOffsetW(Text, #10, StartIndex);
      if EndIndex < 0 then
      begin
        AddQuestTextParagraph(Copy(Text, StartIndex + 1, N - StartIndex), FontMode);
        Break;
      end;
      AddQuestTextParagraph(Copy(Text, StartIndex + 1, EndIndex - StartIndex + 1), FontMode);
      StartIndex := EndIndex + 1;
    end;
  end;

begin
  CurrentText := Text;
  Panel := GetByName('MessageWindow') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  if Text <> '' then
  begin
    NextTop := 0;
    // The native routine retains this allocation although the nested helpers do not use it.
    Lines := TStringsEC.Create;
    TextLength := Length(Text);
    LowerText := LowerCaseWideString(Text);
    StartIndex := 0;
    while StartIndex < TextLength do
    begin
      TagIndex := FindTextOffsetW(LowerText, '<fix>', StartIndex);
      if StartIndex < TagIndex then
        AddQuestTextLines(Copy(Text, StartIndex + 1, TagIndex - StartIndex), 0);
      if TagIndex >= 0 then
      begin
        Inc(TagIndex, 5);
        while (TagIndex < TextLength) and
          ((Text[TagIndex + 1] = ' ') or (Text[TagIndex + 1] = #9) or (Text[TagIndex + 1] = #13)) do Inc(TagIndex);
        if TagIndex < TextLength then
          if Text[TagIndex + 1] = #10 then Inc(TagIndex);
        StartIndex := TagIndex;
        TagIndex := FindTextOffsetW(LowerText, '</fix>', StartIndex);
        if StartIndex < TagIndex then
          AddQuestTextLines(Copy(Text, StartIndex + 1, TagIndex - StartIndex), 1);
        if TagIndex >= 0 then
        begin
          Inc(TagIndex, 6);
          while (TagIndex < TextLength) and
            ((Text[TagIndex + 1] = ' ') or (Text[TagIndex + 1] = #9) or (Text[TagIndex + 1] = #13)) do Inc(TagIndex);
          if TagIndex < TextLength then
            if Text[TagIndex + 1] = #10 then Inc(TagIndex);
          StartIndex := TagIndex;
        end
        else
        begin
          AddQuestTextLines(Copy(Text, StartIndex + 1, TextLength - StartIndex), 1);
          Break;
        end;
      end
      else
      begin
        AddQuestTextLines(Copy(Text, StartIndex + 1, TextLength - StartIndex), 0);
        Break;
      end;
    end;
    Lines.Free;
    Panel.SetScrollOffset(Point(0, 0));
    Panel.SetVerticalScrollbarEnabled(Panel.ClientSize.Y < NextTop);
    if Panel.FirstChild <> nil then
      Panel.VerticalScrollbar.SetSmallChange((Panel.FirstChild as TLabelGI).GetLineHeight);
    Panel.VerticalScrollbar.SetLargeChange(Panel.ClientSize.Y);
    Panel.VerticalScrollbar.SetPageSize(Panel.ClientSize.Y);
    Panel.UpdateScrollRanges;
    Panel.Invalidate;
  end;
end;
{ @end $554A68 }

{ @routine $554DB8 TfPlanetQuest_InitializeLayout }
procedure TfPlanetQuest.InitializeLayout;
var
  I, Shift: Integer;
  Control: TObjectGI;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fPlanetQuest... ');
  ViewportRect := Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('ImageFrame') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
    with FindByNameRecursive('PQI') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
    with FindByNameRecursive('AnimTextOn') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('AnimTextOff') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    for I := 1 to 4 do
      with FindByNameRecursive('Style' + IntToStr(I)) do
        SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ButtonExit') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    I := 0;
    Shift := 39;
    if ExtraScreenWidth < Shift then I := Shift - ExtraScreenWidth;
    Shift := Shift - I;
    with FindByNameRecursive('BGStyle') do
    begin
      SetPosition(Point(LocalPosition.X + Shift, LocalPosition.Y));
      SetSize(Point(ClientSize.X + (ExtraScreenWidth - Shift), ClientSize.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('BGImage') do
      SetPosition(Point(GameScreenWidth - ClientSize.X, LocalPosition.Y));
    with FindByNameRecursive('PanelImage') do
      if (ExtraScreenWidth > 0) or (ExtraScreenHeight > 0) then
      begin
        SetPosition(Point(0, LocalPosition.Y));
        SetSize(Point(GameScreenWidth, GameScreenHeight));
      end
      else SetSize(Point(ClientSize.X, GameScreenHeight));
    with FindByNameRecursive('QuestPanel') do
    begin
      SetSize(Point(GameScreenWidth, GameScreenHeight));
      with FindByNameRecursive('MessageWindow') as TPanelScrollBarGI do
      begin
        SetPosition(Point(LocalPosition.X + Shift, LocalPosition.Y));
        SetSize(Point(ClientSize.X + (ExtraScreenWidth - Shift), ClientSize.Y + ExtraScreenHeight div 2));
        TObjectGI(VerticalScrollbar).SetPosition(Point(VerticalScrollbar.LocalPosition.X + ExtraScreenWidth, VerticalScrollbar.LocalPosition.Y));
        VerticalScrollbar.SetSize(Point(VerticalScrollbar.ClientSize.X, VerticalScrollbar.ClientSize.Y + ExtraScreenHeight div 2));
      end;
      with FindByNameRecursive('ActionListWindow') as TPanelScrollBarGI do
      begin
        SetPosition(Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight div 2));
        SetSize(Point(ClientSize.X + (ExtraScreenWidth - Shift), ClientSize.Y + ExtraScreenHeight div 2));
        TObjectGI(VerticalScrollbar).SetPosition(Point(VerticalScrollbar.LocalPosition.X + ExtraScreenWidth, VerticalScrollbar.LocalPosition.Y));
        VerticalScrollbar.SetSize(Point(VerticalScrollbar.ClientSize.X, VerticalScrollbar.ClientSize.Y + ExtraScreenHeight div 2));
      end;
    end;
    with FindByNameRecursive('LabelHelp') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ParamsShowWindowParent') do
      SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
  end;
  AppendLogLineThreadSafe('ok');
  ParameterPanelOrigin := GetByName('ParamsShowWindowParent').LocalPosition;
  SetHelpCallback(ShowControlHelp);
  with GetByName('AnimTextOn') as TGraphButtonGI do
  begin
    UserValue := 0;
    UpCallback := SelectPageMode;
  end;
  with GetByName('AnimTextOff') as TGraphButtonGI do
  begin
    UserValue := 1;
    UpCallback := SelectPageMode;
  end;
  I := 1;
  while True do
  begin
    Control := FindControlByPath('Style' + IntToWideString(I));
    if Control = nil then Break;
    with Control as TGraphButtonGI do
    begin
      UserValue := I - 1;
      UpCallback := SelectStyle;
      DownCallback := SelectStyle;
    end;
    Inc(I);
  end;
  QuestStyleCount := I - 1;
  GetByName('MainPanel').KeyDownCallback := QuestKeyDown;
  (GetByName('ButtonExit') as TGraphButtonGI).UpCallback := RequestLoadGame;
  QuestPlayerInterface := TTextQuestPlayerInterface.Create;
end;
{ @end $554DB8 }

{ @routine $555794 TfPlanetQuest_OnOpen }
procedure TfPlanetQuest.OnOpen;
var
  I, J: Integer;
  GovernmentQuest: PQuest;
  Found: Boolean;
  Stage: Integer;
begin
  Stage := 0;
  try
    SelectMusic;
    ActiveQueuedTextQuest := nil;
    if Galaxy <> nil then EvictMainMenuShipCachesWhenAddressSpaceHigh;
    Stage := 1;
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
    Stage := 2;
    if (QuestStyleIndex < 0) or (QuestStyleIndex >= QuestStyleCount) then QuestStyleIndex := 0;
    GetByName('PQI').SetActive(False);
    CurrentPicture := '';
    (GetByName('QuestPanel') as TPanelGI).SetActive(True);
    Stage := 3;
    ClearChoices;
    SetQuestText('');
    ClearParameterPanel;
    LayoutParameterPanel;
    Stage := 4;
    if (QueuedTextQuests.Count = 0) and (GetPlayer <> nil) and
      (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.TextQuestId >= 10000) and
      ((LanguageDataConfig.GetBlock('PlanetQuest').CountBlocks('PlanetQuestLic') <= 0) or
       (LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuestLic').GetParamOrMarker(IntToStr(GetPlayer.CurrentPlanet.TextQuestId)) =
        PlanetQuestScreen.GetQuestContentHash(GetPlayer.CurrentPlanet.TextQuestId))) then
      MoneyLimitComplement := (Galaxy.ComputeScaledBigMoney(2) + GetPlayer.Money) xor $FFFFFFFF
    else if (GetPlayer <> nil) and (QueuedTextQuests.Count = 0) then
      MoneyLimitComplement := (GetPlayer.Money + 50000) xor $FFFFFFFF
    else MoneyLimitComplement := 1000000000 xor $FFFFFFFF;
    Stage := 5;
    if (GetPlayer <> nil) and (GetPlayer.CurrentPlanet <> nil) and GetPlayer.InPrison then
    begin
      Stage := 6;
      Quest := TTextQuest.Create;
      if GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate) then LoadQuestByName('Prison')
      else LoadQuestByName('PirateClanPrison');
      Stage := 7;
      Quest.ToStarText.Text := GetPlayer.CurrentStar.Name;
      Quest.ToPlanetText.Text := GetPlayer.CurrentPlanet.Name;
      Quest.DateText.Text := '';
      Quest.MoneyText.Text := '';
      Quest.FromPlanetText.Text := GetPlayer.CurrentPlanet.Name;
      Quest.FromStarText.Text := GetPlayer.CurrentStar.Name;
      Quest.RangerText.Text := GetPlayer.Name;
      Stage := 8;
      StartLoadedQuest;
      Stage := 9;
    end
    else if QueuedTextQuests.Count > 0 then
    begin
      Stage := 10;
      ActiveQueuedTextQuest := QueuedTextQuests[0];
      Quest := TTextQuest.Create;
      if IsIntegerTextW(ActiveQueuedTextQuest.Name) then LoadQuestById(StrToInt(ActiveQueuedTextQuest.Name))
      else LoadQuestByName(ActiveQueuedTextQuest.Name);
      Stage := 11;
      if GetPlayer.CurrentStar <> nil then
      begin
        Quest.ToStarText.Text := GetPlayer.CurrentStar.Name;
        Quest.FromStarText.Text := GetPlayer.CurrentStar.Name;
      end
      else
      begin
        Quest.ToStarText.Text := '';
        Quest.FromStarText.Text := '';
      end;
      if GetPlayer.CurrentPlanet <> nil then
      begin
        Quest.ToPlanetText.Text := GetPlayer.CurrentPlanet.Name;
        Quest.FromPlanetText.Text := GetPlayer.CurrentPlanet.Name;
      end
      else
      begin
        Quest.ToPlanetText.Text := '';
        Quest.FromPlanetText.Text := '';
      end;
      Quest.DateText.Text := '';
      Quest.MoneyText.Text := '';
      Quest.RangerText.Text := GetPlayer.Name;
      Stage := 12;
      StartLoadedQuest;
      Stage := 13;
    end
    else if (GetPlayer <> nil) and not StandaloneQuestMode then
    begin
      Stage := 14;
      Found := False;
      if GetPlayer.CurrentPlanet.TextQuestId > -1 then
        if GetPlayer.Quests.Count > 0 then
          for I := 0 to GetPlayer.Quests.Count - 1 do
          begin
            GovernmentQuest := GetPlayer.Quests[I];
            if (GovernmentQuest.QuestType = qtPlanetQuest) and
              (GovernmentQuest.ObjectiveTarget is TPlanet) and
              ((GovernmentQuest.ObjectiveTarget as TPlanet) = GetPlayer.CurrentPlanet) then
            begin
              Stage := 15;
              ActiveGovernmentQuest := GovernmentQuest;
              Quest := TTextQuest.Create;
              LoadQuestById(GetPlayer.CurrentPlanet.TextQuestId);
              Stage := 16;
              Quest.ToStarText.Text := GetPlayer.CurrentStar.Name;
              Quest.ToPlanetText.Text := GetPlayer.CurrentPlanet.Name;
              Quest.DateText.Text := Galaxy.FormatTurnDate(GovernmentQuest.DeadlineTurn);
              Quest.MoneyText.Text := IntToStr(GovernmentQuest.RewardMoney);
              Quest.FromPlanetText.Text := GovernmentQuest.Planet.Name;
              Quest.FromStarText.Text := GovernmentQuest.Planet.CurrentStar.Name;
              Quest.RangerText.Text := GetPlayer.Name;
              for J := 1 to Quest.GetParameterCount do
                if Quest.GetParameter(J).Enabled and (Quest.GetParameter(J).NameText.Text = 'GRewardMoney') then
                begin
                  Quest.GetParameter(J).Value := GovernmentQuest.RewardMoney;
                  Break;
                end;
              Stage := 17;
              StartLoadedQuest;
              Stage := 18;
              Found := True;
              Break;
            end;
          end;
      if not Found then
      begin
        RequestedScreenId := QuestReturnScreenId;
        RequestClose(1);
      end;
    end
    else
    begin
      Stage := 19;
      Quest := TTextQuest.Create;
      if IsIntegerTextW(PendingQuestName) then LoadQuestById(StrToInt(PendingQuestName))
      else LoadQuestByName(PendingQuestName);
      Stage := 20;
      Quest.ToStarText.Text := LocalizedText('FormLoadQuest.PToStar');
      Quest.ToPlanetText.Text := LocalizedText('FormLoadQuest.PToPlanet');
      Quest.DateText.Text := FormatGameTurnDate(1500);
      Quest.MoneyText.Text := '10000';
      Quest.FromPlanetText.Text := LocalizedText('FormLoadQuest.PFromPlanet');
      Quest.FromStarText.Text := LocalizedText('FormLoadQuest.PFromStar');
      Quest.RangerText.Text := LocalizedText('FormLoadQuest.PRanger');
      Stage := 21;
      StartLoadedQuest;
      Stage := 22;
    end;
    Stage := 23;
    ApplyStyle;
    Stage := 24;
    TGraphButtonGI(GetByName('Style' + IntToWideString(QuestStyleIndex + 1))).ExecuteOnPressCode;
    Stage := 25;
    if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(150);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfPlanetQuest.BeforeRun, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $555794 }

{ @routine $556500 TfPlanetQuest_OnClose }
procedure TfPlanetQuest.OnClose;
var
  Money, CappedMoney: Int64;
  Player: TPlayer;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(151);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  QuestId := -1;
  if PageAnimationTimer <> nil then
  begin
    CancelCallbackTimer(PageAnimationTimer);
    PageAnimationTimer := nil;
  end;
  ClearParameterPanel;
  ClearChoices;
  if GetPlayer <> nil then
  begin
    Player := GetPlayer;
    Money := GetPlayer.Money;
    // The native inlined Int64 minimum compares an unsigned limit with signed money.
    if Int64(MoneyLimitComplement xor $FFFFFFFF) < Money then
      CappedMoney := MoneyLimitComplement xor $FFFFFFFF
    else CappedMoney := Money;
    Player.SetMoney(Integer(CappedMoney));
  end;
  if Quest <> nil then
  begin
    Quest.Free;
    Quest := nil;
  end;
  if GetPlayer <> nil then GetPlayer.ProcessQuestTimersAndOutcomes;
  if (RequestedScreenId = screenMainMenu) or (RequestedScreenId = screenLoad) then
    ClearPendingScriptRequests;
end;
{ @end $556500 }

{ @routine $556648 TfPlanetQuest_GetTextColorTag }
function TfPlanetQuest.GetTextColorTag(StyleIndex: Integer): WideString;
var
  Block: TBlockParEC;
begin
  Block := UiStyleConfig.GetBlockByPath('Style');
  if Block.CountBlocks('QTextColor') > 0 then
  begin
    Block := Block.GetBlock('QTextColor');
    if Block.CountParams('Sel' + IntToWideString(StyleIndex + 1)) > 0 then
    begin
      Result := '<color=' + Block.GetParam('Sel' + IntToWideString(StyleIndex + 1)) + '>';
      Exit;
    end;
  end;
  if StyleIndex = 0 then Result := '<color=' + IntToStr(255) + ',' + IntToStr(240) + ',' + IntToStr(100) + '>'
  else if StyleIndex = 1 then Result := '<color=' + IntToStr(255) + ',' + IntToStr(240) + ',' + IntToStr(100) + '>'
  else if StyleIndex = 2 then Result := '<color=' + IntToStr(0) + ',' + IntToStr(4) + ',' + IntToStr(173) + '>'
  else if StyleIndex = 3 then Result := '<color=' + IntToStr(0) + ',' + IntToStr(4) + ',' + IntToStr(173) + '>'
  else Result := GetTextColorTag(0);
end;
{ @end $556648 }

{ @routine $556970 TfPlanetQuest_GetTextColor }
function TfPlanetQuest.GetTextColor(StyleIndex: Integer): Cardinal;
var
  Block: TBlockParEC;
  S: WideString;
begin
  Block := UiStyleConfig.GetBlockByPath('Style');
  if Block.CountBlocks('QTextColor') > 0 then
  begin
    Block := Block.GetBlock('QTextColor');
    if Block.CountParams('Text' + IntToWideString(StyleIndex + 1)) > 0 then
    begin
      S := Block.GetParam('Text' + IntToWideString(StyleIndex + 1));
      Result := CurrentPixelFormat.PackRgb(ExtractDigitsToIntW(ExtractDelimitedPartW(S, 0, ',')),
        ExtractDigitsToIntW(ExtractDelimitedPartW(S, 1, ',')), ExtractDigitsToIntW(ExtractDelimitedPartW(S, 2, ',')));
      Exit;
    end;
  end;
  if StyleIndex = 0 then Result := CurrentPixelFormat.PackRgbBytes(212, 208, 180)
  else if StyleIndex = 1 then Result := CurrentPixelFormat.PackRgbBytes(212, 208, 180)
  else if StyleIndex = 2 then Result := CurrentPixelFormat.PackRgbBytes(0, 0, 0)
  else if StyleIndex = 3 then Result := CurrentPixelFormat.PackRgbBytes(0, 0, 0)
  else Result := GetTextColor(0);
end;
{ @end $556970 }

{ @routine $556B8C TfPlanetQuest_GetDisabledTextColor }
function TfPlanetQuest.GetDisabledTextColor(StyleIndex: Integer): Cardinal;
var
  Block: TBlockParEC;
  S: WideString;
begin
  Block := UiStyleConfig.GetBlockByPath('Style');
  if Block.CountBlocks('QTextColor') > 0 then
  begin
    Block := Block.GetBlock('QTextColor');
    if Block.CountParams('Grey' + IntToWideString(StyleIndex + 1)) > 0 then
    begin
      S := Block.GetParam('Grey' + IntToWideString(StyleIndex + 1));
      Result := CurrentPixelFormat.PackRgb(ExtractDigitsToIntW(ExtractDelimitedPartW(S, 0, ',')),
        ExtractDigitsToIntW(ExtractDelimitedPartW(S, 1, ',')), ExtractDigitsToIntW(ExtractDelimitedPartW(S, 2, ',')));
      Exit;
    end;
  end;
  if StyleIndex = 0 then Result := CurrentPixelFormat.PackRgbBytes(120, 120, 120)
  else if StyleIndex = 1 then Result := CurrentPixelFormat.PackRgbBytes(120, 120, 120)
  else if StyleIndex = 2 then Result := CurrentPixelFormat.PackRgbBytes(120, 120, 120)
  else if StyleIndex = 3 then Result := CurrentPixelFormat.PackRgbBytes(120, 120, 120)
  else Result := GetDisabledTextColor(0);
end;
{ @end $556B8C }

{ @routine $556DA0 TfPlanetQuest_ApplyStyle }
procedure TfPlanetQuest.ApplyStyle;
var
  I: Integer;
  Control: TObjectGI;
  Path: WideString;
begin
  (GetByName('AnimTextOn') as TGraphButtonGI).SetActive(QuestPageAnimationEnabled);
  (GetByName('AnimTextOff') as TGraphButtonGI).SetActive(not QuestPageAnimationEnabled);
  for I := 1 to QuestStyleCount do
    (GetByName('Style' + IntToStr(I)) as TGraphButtonGI).SetDisabled(QuestStyleIndex = I - 1);
  (GetByName('BGStyle') as TImageGI).SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1));
  (GetByName('MessageWindow') as TPanelScrollBarGI).VerticalScrollbar.SetConfigPath('Style.ScrollBar.' + GiResourceSuffix + 'PQS' + IntToWideString(QuestStyleIndex + 1));
  (GetByName('ActionListWindow') as TPanelScrollBarGI).VerticalScrollbar.SetConfigPath('Style.ScrollBar.' + GiResourceSuffix + 'PQS' + IntToWideString(QuestStyleIndex + 1));
  Control := GetByName('MessageWindow').FirstChild;
  while Control <> nil do
  begin
    if Control is TLabelGI then
      with Control as TLabelGI do
      begin
        SetTextColor(GetTextColor(QuestStyleIndex));
        SetText(ReplaceAllWideString(GetText, GetTextColorTag(PreviousStyleIndex), GetTextColorTag(QuestStyleIndex)));
      end;
    Control := Control.NextSibling;
  end;
  Control := GetByName('ActionListWindow').FirstChild;
  while Control <> nil do
  begin
    if Control.FirstChild <> nil then
    begin
      with Control.FirstChild as TImageGI do
      begin
        Path := 'Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1) + 'Line';
        if CacheDataRoot.FileExistsByPath(Path) then SetImagePath('GI,' + Path)
        else SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1Line');
        SetImageKindX(ikxLeftFill);
        SetImageKindY(ikyTopFill);
      end;
      with Control.FirstChild.NextSibling as TLabelGI do
      begin
        if UserState = 1 then SetTextColor(GetDisabledTextColor(QuestStyleIndex))
        else SetTextColor(GetTextColor(QuestStyleIndex));
        SetText(ReplaceAllWideString(GetText, GetTextColorTag(PreviousStyleIndex), GetTextColorTag(QuestStyleIndex)));
      end;
      if Control.FirstChild.NextSibling.FirstChild <> nil then
        with Control.FirstChild.NextSibling.FirstChild.FirstChild as TImageGI do
        begin
          Path := 'Bm.FormPQuest2.' + GiResourceSuffix + 'S' + IntToWideString(QuestStyleIndex + 1) + 'Answer';
          if Control.FirstChild.NextSibling.UserState = 1 then
          begin
            if CacheDataRoot.FileExistsByPath(Path + 'H') then SetImagePath('GI,' + Path + 'H')
            else SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1AnswerH');
          end
          else if CacheDataRoot.FileExistsByPath(Path) then SetImagePath('GI,' + Path)
          else SetImagePath('GI,Bm.FormPQuest2.' + GiResourceSuffix + 'S1Answer');
        end;
    end;
    Control := Control.NextSibling;
  end;
end;
{ @end $556DA0 }

{ @routine $557584 TfPlanetQuest_SelectPageMode }
procedure TfPlanetQuest.SelectPageMode(Sender: TObjectGI);
var
  Filename: WideString;
begin
  if Boolean(Sender.UserValue) <> QuestPageAnimationEnabled then
  begin
    QuestPageAnimationEnabled := Boolean(Sender.UserValue);
    UserSettingsConfig.SetOrAddParam('PQuestAnim', BoolToWideString(QuestPageAnimationEnabled));
    Filename := GetGameUserDirectory + 'cfg.txt';
    UserSettingsConfig.SaveTextFile(PWideChar(Filename), True, False);
    if QuestPageAnimationEnabled then ShowControlHelp(GetByName('AnimTextOn'), True)
    else ShowControlHelp(GetByName('AnimTextOff'), True);
    ApplyStyle;
  end;
end;
{ @end $557584 }

{ @routine $5576F4 TfPlanetQuest_SelectStyle }
procedure TfPlanetQuest.SelectStyle(Sender: TObjectGI);
begin
  if QuestStyleIndex <> Sender.UserValue then
  begin
    PreviousStyleIndex := QuestStyleIndex;
    QuestStyleIndex := Sender.UserValue;
    UserSettingsConfig.SetOrAddParam('PQuestStyle', IntToStr(QuestStyleIndex));
    UserSettingsConfig.SaveTextFile(PWideChar(GetGameUserDirectory + 'cfg.txt'), True, False);
    ApplyStyle;
  end;
end;
{ @end $5576F4 }

{ @routine $557810 TfPlanetQuest_ShowControlHelp }
procedure TfPlanetQuest.ShowControlHelp(Sender: TObjectGI; Visible: Boolean);
var
  TextLabel: TLabelGI;
begin
  TextLabel := GetByName('LabelHelp') as TLabelGI;
  if Sender.HelpText = '' then Visible := False;
  TextLabel.SetActive(Visible);
  if (Sender.ControlName = 'ButtonExit') and (ActiveQueuedTextQuest <> nil) then
    TextLabel.SetText(LocalizedText('FormPQuest.HelpExitAlt'))
  else TextLabel.SetText(Sender.HelpText);
end;
{ @end $557810 }

{ @routine $55793C TfPlanetQuest_SetQuestPicture }
procedure TfPlanetQuest.SetQuestPicture(Name: WideString);
var
  Image: TGraphBufGI;
begin
  if CurrentPicture <> Name then
  begin
    CurrentPicture := Name;
    Image := GetByName('PQI') as TGraphBufGI;
    Image.SetActive(True);
    Image.LoadBitmapPathAsRgb('Bm.PQI.' + Name + '?RGB');
    if GiResourceVariant = 1 then
      Image.GraphBuf.RescaleRgb(Round(Cardinal(Image.GraphBuf.Width) * 800 / 1024), Round(Cardinal(Image.GraphBuf.Height) * 800 / 1024));
    Image.GraphBuf.ConvertRgbTo565;
    Image.Invalidate;
  end;
end;
{ @end $55793C }

{ @routine $557AB0 TfPlanetQuest_RequestLoadGame }
procedure TfPlanetQuest.RequestLoadGame(Sender: TObjectGI);
var
  Standalone: Boolean;
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormGameMenu.QExit'), mbgOK or mbgCancel) = mbgResultOK then
  begin
    Standalone := Galaxy = nil;
    ClearPendingScriptRequests;
    if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
    MemorySnapshotBuffer := nil;
    MemorySnapshotActive := False;
    if Galaxy <> nil then
      if not Galaxy.Destroying then Galaxy.Free;
    Galaxy := nil;
    ScreenLoadMode := 4;
    if Standalone then PostLoadScreenId := QuestReturnScreenId
    else PostLoadScreenId := screenMainMenu;
    RequestedScreenId := screenLoad;
    RequestClose(1);
  end;
end;
{ @end $557AB0 }

{ @routine $557BF4 TfPlanetQuest_QuestKeyDown }
procedure TfPlanetQuest.QuestKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
var
  Index: Integer;
  Panel: TPanelScrollBarGI;
  Choice, Control: TObjectGI;
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
    if VirtualKey = VK_ESCAPE then RequestLoadGame(nil);
    if (VirtualKey >= Ord('1')) and (VirtualKey <= Ord('9')) then
    begin
      Index := VirtualKey - Ord('1');
      Panel := GetByName('ActionListWindow') as TPanelScrollBarGI;
      Control := Panel.FirstChild;
      while (Control <> nil) and (not (Control is TPanelGI) or
        ((@Control.LeftButtonUpCallback <> @TfPlanetQuest.ChoiceMouseUp) and
         (@Control.LeftButtonUpCallback <> @TfPlanetQuest.DisabledChoiceMouseUp))) do
        Control := Control.NextSibling;
      Choice := Control;
      while (Choice <> nil) and (Index >= 0) do
      begin
        if Index = 0 then
        begin
          Choice.LeftButtonUpCallback(Choice, 0, Point(0, 0));
          Exit;
        end
        else
        begin
          Dec(Index);
          Control := Choice.NextSibling;
          while (Control <> nil) and (not (Control is TPanelGI) or
            ((@Control.LeftButtonUpCallback <> @TfPlanetQuest.ChoiceMouseUp) and
             (@Control.LeftButtonUpCallback <> @TfPlanetQuest.DisabledChoiceMouseUp))) do
            Control := Control.NextSibling;
          Choice := Control;
        end;
      end;
    end;
    if VirtualKey = Ord('R') then
      if ActiveQueuedTextQuest = nil then
        if SaveManagerScreen.AutoSaveExists then
          if ShowMessageBoxGI(Self, LocalizedText('Planet.NotCivil.QuestPlay.MsgLoad'), mbgOK or mbgCancel) = mbgResultOK then
            if GetPlayer <> nil then
            begin
              PendingLoadFileName := SaveManagerScreen.GetAutoSavePath;
              RequestedScreenId := screenGameLoad;
              RequestClose(1);
            end
            else
            begin
              StandaloneQuestMode := True;
              RequestedScreenId := screenPlanetQuest;
              CurrentScreenId := screenNone;
              RequestClose(1);
            end;
  end;
end;
{ @end $557BF4 }

{ @routine $557ED0 TfPlanetQuest_SelectMusic }
procedure TfPlanetQuest.SelectMusic;
begin
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
  else MusicManager.PlayCategory('Quest');
end;
{ @end $557ED0 }

{ @routine $557F14 TfPlanetQuest_ExpandTemplateText }
function TfPlanetQuest.ExpandTemplateText(Text: WideString): WideString;
var
  Expanded, SourceLineBreak, ReplacementLineBreak, IndentedLineBreak: WideString;
begin
  if GetPlayer = nil then CurrentDate := TrimWideString(Galaxy.FormatTurnDate(DaysElapsed + 300))
  else CurrentDate := TrimWideString(Galaxy.FormatTurnDate(Galaxy.CurrentTurn));
  Expanded := ExpandExternalText(Text);
  SourceLineBreak := #13#10;
  ReplacementLineBreak := #13#10;
  IndentedLineBreak := #13#10'          ';
  Expanded := ReplaceAllWideString(Expanded, '<ToStar>', WrapTextInColor(TrimWideString(Quest.ToStarText.Text), GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<ToPlanet>', WrapTextInColor(TrimWideString(Quest.ToPlanetText.Text), GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<Date>', WrapTextInColor(Quest.DateText.Text, GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<Money>', WrapTextInColor(Quest.MoneyText.Text, GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<FromPlanet>', WrapTextInColor(TrimWideString(Quest.FromPlanetText.Text), GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<FromStar>', WrapTextInColor(TrimWideString(Quest.FromStarText.Text), GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<Ranger>', WrapTextInColor(TrimWideString(Quest.RangerText.Text), GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, '<CurDate>', WrapTextInColor(CurrentDate, GetTextColorTag(QuestStyleIndex)));
  Expanded := ReplaceAllWideString(Expanded, SourceLineBreak, ReplacementLineBreak);
  Expanded := ReplaceAllWideString(Expanded, IndentedLineBreak, ReplacementLineBreak);
  if Pos('<', Expanded) > 0 then
  begin
    Expanded := ReplaceAllWideString(Expanded, '<br>', #13#10);
    Expanded := ReplaceAllWideString(Expanded, '<ll>', #13#10' '#13#10);
    // Native quirk: <Player> is expanded into Result, then overwritten below.
    if GetPlayer <> nil then
      Result := ReplaceAllWideString(Result, '<Player>', WrapTextInColor(GetPlayer.Name, GetTextColorTag(QuestStyleIndex)));
    Expanded := ReplaceAllWideString(Expanded, '<clr>', GetTextColorTag(QuestStyleIndex));
    Expanded := ReplaceAllWideString(Expanded, '<clrEnd>', '</color>');
  end;
  Result := Expanded;
end;
{ @end $557F14 }

{ @routine $5585F4 TfPlanetQuest_IgnoreChoice }
procedure TfPlanetQuest.IgnoreChoice(Value: Integer);
begin

end;
{ @end $5585F4 }

{ @routine $558604 TfPlanetQuest_ContinueToLocation }
procedure TfPlanetQuest.ContinueToLocation(LocationId: Integer);
begin
  ClearChoices;
  Quest.EnterLocation(LocationId);
end;
{ @end $558604 }

{ @routine $558630 TfPlanetQuest_ContinueAlongPath }
procedure TfPlanetQuest.ContinueAlongPath(PathId: Integer);
begin
  ClearChoices;
  Quest.FollowPath(PathId);
end;
{ @end $558630 }

{ @routine $55865C TfPlanetQuest_ContinueToOutcome }
procedure TfPlanetQuest.ContinueToOutcome(Value: Integer);
begin
  ClearChoices;
  Quest.ShowOutcome;
end;
{ @end $55865C }

{ @routine $558684 TfPlanetQuest_CompleteQuestSuccess }
procedure TfPlanetQuest.CompleteQuestSuccess(Value: Integer);
var
  News, ItemName: WideString;
  GovernmentQuest: PQuest;
  I: Integer;
  Item: TUselessItem;
begin
  ClearChoices;
  if ActiveQueuedTextQuest = nil then
    if GetPlayer <> nil then
      if not GetPlayer.InPrison then
        if GetPlayer.Quests.Count > 0 then
          for I := 0 to GetPlayer.Quests.Count - 1 do
          begin
            GovernmentQuest := GetPlayer.Quests[I];
            if (GovernmentQuest.QuestType = qtPlanetQuest) and
              (GovernmentQuest.ObjectiveTarget is TPlanet) and
              (GetPlayer.CurrentPlanet = (GovernmentQuest.ObjectiveTarget as TPlanet)) then
            begin
              if Quest.CompleteOnFinish then
              begin
                GovernmentQuest.Successful := True;
                News := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.PlanetaryQuest', (Galaxy.CurrentTurn div 10) * Integer(Galaxy.GenerationSeed));
                ReplaceTextToken(News, '<FromPlanet>', GovernmentQuest.Planet.Name, '<color=255,240,100>');
                ReplaceTextToken(News, '<ToPlanet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
                AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, News, '');
              end;
              ItemName := LookupLocalizedTextByKey('PlanetQuest.ItemForPlanetQuest.' + IntToStr(GovernmentQuest.QuestNumber));
              if ItemName <> 'none' then
              begin
                Item := TUselessItem.Create;
                Item.Init(ItemName, dsBlazer, 0, False);
                GetPlayer.Inventory.Add(Item);
              end;
              GetPlayer.CurrentPlanet.TextQuestId := -1;
              (GetByName('QuestPanel') as TPanelGI).SetActive(False);
              if GetPlayer.CurrentPlanet.IsCoalitionOwned or (GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate)) then
              begin
                GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, Quest.SuccessRelationDelta);
                if GetPlayer.CurrentPlanet.RelationToShip(GetPlayer) < 20 then
                  GetPlayer.CurrentPlanet.SetRelationLevelToRanger(GetPlayer, rlBad);
              end;
              Break;
            end;
          end;
  if QuestId >= 0 then
    if (ActiveQueuedTextQuest = nil) or (GetPlayer = nil) or not (GetPlayer.PirateRank in [4, 6]) then
    begin
      if GetPlayer <> nil then TryAddAchievementProgress('QUEST', 1);
      LoadQuestScreen.LoadCompletionData;
      LoadQuestScreen.RecordCompletion(QuestId, 0, 1);
      LoadQuestScreen.SaveCompletionData;
    end;
  RequestedScreenId := QuestReturnScreenId;
  RequestClose(1);
  if ActiveQueuedTextQuest <> nil then
  begin
    ActiveQueuedTextQuest := nil;
    CompleteQueuedTextQuest(sqsSuccess);
  end;
end;
{ @end $558684 }

{ @routine $558B48 TfPlanetQuest_CompleteQuestFailure }
procedure TfPlanetQuest.CompleteQuestFailure(Value: Integer);
var
  News: WideString;
  GovernmentQuest: PQuest;
  I: Integer;
begin
  if GetPlayer = nil then RequestedScreenId := QuestReturnScreenId
  else if GetPlayer.InPrison then
  begin
    GetPlayer.InPrison := False;
    if GetPlayer.CurrentPlanet <> nil then
      if (GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) then
        MainPiratePlanet.SetRelationLevelToRanger(GetPlayer, rlHostile)
      else GetPlayer.CurrentPlanet.SetRelationLevelToRanger(GetPlayer, rlHostile);
    if not HangarScreen.TryTakeOff then RequestedScreenId := screenHangar;
  end
  else
  begin
    if ActiveQueuedTextQuest = nil then
      if GetPlayer <> nil then
        if GetPlayer.Quests.Count > 0 then
          for I := GetPlayer.Quests.Count - 1 downto 0 do
          begin
            GovernmentQuest := GetPlayer.Quests[I];
            if (GovernmentQuest.QuestType = qtPlanetQuest) and
              (GovernmentQuest.ObjectiveTarget is TPlanet) and
              (GetPlayer.CurrentPlanet = (GovernmentQuest.ObjectiveTarget as TPlanet)) then
            begin
              GovernmentQuest.Successful := False;
              GetPlayer.PublishQuestStatus(GovernmentQuest, -1);
              News := PickLocalizedTextVariant('GalaxyNews.Quest.Failure.PlanetaryQuest', Integer(GetPlayer.Seed) * (Galaxy.CurrentTurn div 10));
              ReplaceTextToken(News, '<ToPlanet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
              ReplaceTextToken(News, '<FromPlanet>', GovernmentQuest.Planet.Name, '<color=255,240,100>');
              ReplaceTextToken(News, '<Relation>', GovernmentQuest.Planet.GetRelationLevelTextToShip(GetPlayer), '<color=255,240,100>');
              AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, News, '');
              GetPlayer.CurrentPlanet.TextQuestId := -1;
              GetPlayer.ArchiveQuest(I);
              Break;
            end;
          end;
    if (ActiveQueuedTextQuest = nil) and SaveManagerScreen.AutoSaveExists and
      (ShowMessageBoxGI(Self, LocalizedText('Planet.NotCivil.QuestPlay.MsgLoad'), mbgOK or mbgCancel) = mbgResultOK) then
    begin
      PendingLoadFileName := SaveManagerScreen.GetAutoSavePath;
      RequestedScreenId := screenGameLoad;
    end
    else RequestedScreenId := QuestReturnScreenId;
  end;
  RequestClose(1);
  if ActiveQueuedTextQuest <> nil then
  begin
    ActiveQueuedTextQuest := nil;
    CompleteQueuedTextQuest(sqsFailure);
  end;
end;
{ @end $558B48 }

{ @routine $558F9C TfPlanetQuest_CompleteQuestDeath }
procedure TfPlanetQuest.CompleteQuestDeath(Value: Integer);
begin
  if GetPlayer = nil then RequestedScreenId := QuestReturnScreenId
  else
  begin
    if SaveManagerScreen.AutoSaveExists and
      (ShowMessageBoxGI(Self, LocalizedText('Planet.NotCivil.QuestPlay.MsgLoad'), mbgOK or mbgCancel) = mbgResultOK) then
    begin
      PendingLoadFileName := SaveManagerScreen.GetAutoSavePath;
      RequestedScreenId := screenGameLoad;
    end
    else
    begin
      ScoreScreen.RecordPlayerResult(False);
      GetPlayer.Free;
      GameEndReason := 1;
      RequestedScreenId := screenGameEnd;
    end;
  end;
  ClearPendingScriptRequests;
  RequestClose(1);
end;
{ @end $558F9C }

{ @routine $5590E4 TfPlanetQuest_ApplyLegacyPictureOverrides }
procedure TfPlanetQuest.ApplyLegacyPictureOverrides;
var
  Found, Count, I, J, K: Integer;
  Kind, Indices, Name, Picture: WideString;
  Values: TValuesList;
  Config: TBlockParEC;
begin
  Values := TValuesList.Create;
  Config := GameDataConfig.GetBlock('PQI');
  Count := Config.GetParamCount;
  for I := 0 to Count - 1 do
  begin
    Name := Config.GetParamName(I);
    if GetTextBeforeDelimiter(Name, ',') = QuestName then
    begin
      Kind := GetTextAfterComma(Name, ',');
      Indices := GetTextAfterComma(Kind, ',');
      Kind := GetTextBeforeDelimiter(Kind, ',');
      Values.LoadFromSemicolonText(Indices);
      Picture := Config.GetParamValue(I);
      Picture := ReplaceAllWideString(Picture, 'Bm.PQI.', '');
      if Kind = 'L' then
        for J := 1 to Values.Count do
        begin
          Found := -1;
          for K := 1 to Quest.GetLocationCount do
            if Quest.GetLocation(K).Id = Values.Values[J] then
            begin
              Found := K;
              Break;
            end;
          if Found > 0 then
            for K := 1 to Quest.GetLocation(Found).EventCount do
              Quest.GetLocation(Found).Events[K].Picture.Text := Picture;
        end;
      if Kind = 'P' then
        for J := 1 to Values.Count do
        begin
          Found := -1;
          for K := 1 to Quest.GetPathCount do
            if Quest.GetPath(K).Id = Values.Values[J] then
            begin
              Found := K;
              Break;
            end;
          if Found > 0 then Quest.GetPath(Found).Event.Picture.Text := Picture;
        end;
      if Kind = 'PAR' then
        for J := 1 to Values.Count do
          if Quest.GetParameterCount >= Values.Values[J] then
            if Quest.GetParameter(Values.Values[J]).Enabled then
              if Quest.GetParameter(Values.Values[J]).CriticalOutcome <> qoNone then
                Quest.GetParameter(Values.Values[J]).CriticalEvent.Picture.Text := Picture;
    end;
  end;
  Values.Destroy;
end;
{ @end $5590E4 }

{ @routine $5594E8 TfPlanetQuest_ExportMoneyToPlayer }
procedure TfPlanetQuest.ExportMoneyToPlayer;
var
  I: Integer;
begin
  if GetPlayer <> nil then
    for I := 1 to Quest.GetParameterCount do
      if Quest.GetParameter(I).Enabled then
        if Quest.GetParameter(I).IsMoney then
        begin
          GetPlayer.SetMoney(Quest.GetParameter(I).Value);
          Quest.GetParameter(I).Value := GetPlayer.Money;
          Break;
        end;
end;
{ @end $5594E8 }

{ @routine $5595A0 TfPlanetQuest_ImportMoneyFromPlayer }
procedure TfPlanetQuest.ImportMoneyFromPlayer;
var
  I: Integer;
begin
  if GetPlayer <> nil then
    for I := 1 to Quest.GetParameterCount do
      if Quest.GetParameter(I).Enabled then
        if Quest.GetParameter(I).IsMoney then
        begin
          Quest.GetParameter(I).Value := GetPlayer.Money;
          Break;
        end;
end;
{ @end $5595A0 }

{ @routine $559630 TfPlanetQuest_ExportExternalParameters }
procedure TfPlanetQuest.ExportExternalParameters;
var
  I: Integer;
  Name: WideString;
  Variable: TVarEC;
begin
  for I := 1 to Quest.GetParameterCount do
    if FindTextPosW('ext_', Quest.GetParameter(I).NameText.Text) = 1 then
    begin
      Name := Quest.GetParameter(I).NameText.Text;
      Name[1] := 'E';
      Name := 'GQuestVar' + Name;
      Variable := nil;
      if ActiveQueuedTextQuest <> nil then
        if ActiveQueuedTextQuest.Script <> nil then Variable := ActiveQueuedTextQuest.Script.InitCode.LocalVar.GetVarNE(Name);
      if Variable = nil then Variable := SharedScriptVariables.GetVarNE(Name);
      if Variable <> nil then
        if Variable.RealVType = vkInt then
        begin
          Variable.SetInt(Quest.GetParameter(I).Value);
        end;
    end;
end;
{ @end $559630 }

{ @routine $559798 TfPlanetQuest_ImportExternalParameters }
procedure TfPlanetQuest.ImportExternalParameters;
var
  I: Integer;
  Name: WideString;
  Variable: TVarEC;
begin
  for I := 1 to Quest.GetParameterCount do
    if FindTextPosW('ext_', Quest.GetParameter(I).NameText.Text) = 1 then
    begin
      Name := Quest.GetParameter(I).NameText.Text;
      Name[1] := 'E';
      Name := 'GQuestVar' + Name;
      Variable := nil;
      if ActiveQueuedTextQuest <> nil then
        if ActiveQueuedTextQuest.Script <> nil then Variable := ActiveQueuedTextQuest.Script.InitCode.LocalVar.GetVarNE(Name);
      if Variable = nil then Variable := SharedScriptVariables.GetVarNE(Name);
      if Variable <> nil then
        if Variable.RealVType = vkInt then
        begin
          Quest.GetParameter(I).SetValue(Variable.GetInt);
          Variable.SetInt(Quest.GetParameter(I).Value);
        end;
    end;
end;
{ @end $559798 }

{ @routine $559924 TfPlanetQuest_ExpandExternalText }
function TfPlanetQuest.ExpandExternalText(Text: WideString): WideString;
var
  I: Integer;
  Name, Token, Expanded: WideString;
  Variable: TVarEC;
begin
  Expanded := Text;
  // +0 preserves the native argument-load order; see docs/development.md.
  for I := 1 to Quest.GetParameterCount do
    if FindTextPosW('ext_', Quest.GetParameter(I + 0).NameText.Text) = 1 then
    begin
      Name := Quest.GetParameter(I + 0).NameText.Text;
      Token := Name;
      Name[1] := 'E';
      Token[1] := 't';
      Token := '<' + Token + '>';
      Name := 'GQuestVar' + Name;
      Variable := SharedScriptVariables.GetVarNE(Name);
      if Variable <> nil then
        Expanded := ReplaceAllWideString(Expanded, Token, WrapTextInColor(TrimWideString(Variable.GetString), GetTextColorTag(QuestStyleIndex)));
    end;
  Result := Expanded;
end;
{ @end $559924 }

{ @routine $559B08 TTextQuestPlayerInterface_ShowText }
procedure TTextQuestPlayerInterface.ShowText(Text: WideString);
var
  ExpandedText: WideString;
begin
  ExpandedText := PlanetQuestScreen.ExpandTemplateText(Text);
  if ExpandedText <> TrimWideString(PlanetQuestScreen.CurrentText) then
    PlanetQuestScreen.SetQuestText(PlanetQuestScreen.ExpandTemplateText(Text));
end;
{ @end $559B08 }

{ @routine $559BAC TTextQuestPlayerInterface_ShowPicture }
procedure TTextQuestPlayerInterface.ShowPicture(Name: WideString);
begin
  PlanetQuestScreen.SetQuestPicture(Name);
end;
{ @end $559BAC }

{ @routine $559C00 TTextQuestPlayerInterface_PlayMusic }
procedure TTextQuestPlayerInterface.PlayMusic(Name: WideString);
begin
  MusicManager.RequestFadeOut;
  if MusicInPlanetEnabled then MusicManager.PlayCategory(Name);
end;
{ @end $559C00 }

{ @routine $559C68 TTextQuestPlayerInterface_PlaySound }
procedure TTextQuestPlayerInterface.PlaySound(Name: WideString);
begin
  SoundManager.PlaySound('Sound.' + Name);
end;
{ @end $559C68 }

{ @routine $559CE8 TTextQuestPlayerInterface_ShowParameters }
procedure TTextQuestPlayerInterface.ShowParameters(Text: WideString);
begin
  PlanetQuestScreen.ClearParameterPanel;
  PlanetQuestScreen.AppendParameterText(TrimWideString(PlanetQuestScreen.ExpandTemplateText(Text)));
  PlanetQuestScreen.LayoutParameterPanel;
  PlanetQuestScreen.ExportMoneyToPlayer;
  PlanetQuestScreen.ExportExternalParameters;
end;
{ @end $559CE8 }

{ @routine $559D94 TTextQuestPlayerInterface_AddContinueAction }
procedure TTextQuestPlayerInterface.AddContinueAction;
begin
  PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgContinue'), 0, PlanetQuestScreen.ContinueToOutcome);
end;
{ @end $559D94 }

{ @routine $559E70 TTextQuestPlayerInterface_AddSuccessAction }
procedure TTextQuestPlayerInterface.AddSuccessAction;
begin
  if (GetPlayer <> nil) and GetPlayer.InPrison then
    PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgSuccessPrison'), 0, PlanetQuestScreen.CompleteQuestSuccess)
  else if (ActiveQueuedTextQuest <> nil) and (ActiveQueuedTextQuest.SuccessCaption <> '') then
    PlanetQuestScreen.AddChoice(' - ' + ActiveQueuedTextQuest.SuccessCaption, 0, PlanetQuestScreen.CompleteQuestSuccess)
  else
    PlanetQuestScreen.AddChoice(' - ' + LocalizedColorText('Planet.NotCivil.QuestPlay.MsgSuccess'), 0, PlanetQuestScreen.CompleteQuestSuccess);
end;
{ @end $559E70 }

{ @routine $55A05C TTextQuestPlayerInterface_AddDeathAction }
procedure TTextQuestPlayerInterface.AddDeathAction;
begin
  PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgDeath'), 0, PlanetQuestScreen.CompleteQuestDeath);
end;
{ @end $55A05C }

{ @routine $55A134 TTextQuestPlayerInterface_AddFailureAction }
procedure TTextQuestPlayerInterface.AddFailureAction;
begin
  if (GetPlayer <> nil) and GetPlayer.InPrison then
    PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgFailPrison'), 0, PlanetQuestScreen.CompleteQuestFailure)
  else if (ActiveQueuedTextQuest <> nil) and (ActiveQueuedTextQuest.FailureCaption <> '') then
    PlanetQuestScreen.AddChoice(' - ' + ActiveQueuedTextQuest.FailureCaption, 0, PlanetQuestScreen.CompleteQuestFailure)
  else
    PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgFail'), 0, PlanetQuestScreen.CompleteQuestFailure);
end;
{ @end $55A134 }

{ @routine $55A310 TTextQuestPlayerInterface_AddPathAction }
procedure TTextQuestPlayerInterface.AddPathAction(Text: WideString; PathId: Integer);
begin
  PlanetQuestScreen.AddChoice('  - ' + PlanetQuestScreen.ExpandTemplateText(Text), PathId, PlanetQuestScreen.ContinueAlongPath);
end;
{ @end $55A310 }

{ @routine $55A3C0 TTextQuestPlayerInterface_AddDisabledPath }
procedure TTextQuestPlayerInterface.AddDisabledPath(Text: WideString);
begin
  PlanetQuestScreen.AddDisabledChoice('  - ' + PlanetQuestScreen.ExpandTemplateText(Text), 0, PlanetQuestScreen.IgnoreChoice);
end;
{ @end $55A3C0 }

{ @routine $55A460 TTextQuestPlayerInterface_AddPathContinueAction }
procedure TTextQuestPlayerInterface.AddPathContinueAction(PathId: Integer);
begin
  PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgContinue'), PathId, PlanetQuestScreen.ContinueAlongPath);
end;
{ @end $55A460 }

{ @routine $55A544 TTextQuestPlayerInterface_AddLocationContinueAction }
procedure TTextQuestPlayerInterface.AddLocationContinueAction(LocationId: Integer);
begin
  PlanetQuestScreen.AddChoice('  - ' + LocalizedText('Planet.NotCivil.QuestPlay.MsgContinue'), LocationId, PlanetQuestScreen.ContinueToLocation);
end;
{ @end $55A544 }

{ @routine $55A628 TTextQuestPlayerInterface_AdvanceDays }
procedure TTextQuestPlayerInterface.AdvanceDays(Days: Integer);
var
  I: Integer;
begin
  PlanetQuestScreen.ExportMoneyToPlayer;
  PlanetQuestScreen.ExportExternalParameters;
  for I := 1 to Days do
  begin
    Inc(PlanetQuestScreen.DaysElapsed);
    // The native standalone path stops after one increment, even when Days is greater than one.
    if StandaloneQuestMode then Break;
    WaitForTurnCalculation;
    PruneExpiredPersistentPlayerMessages;
    CalculatePlayerStarTurnAndWait;
    if ExitScreenLoop then Break;
    QueueGalaxyTurnCalculation;
    PlanetQuestScreen.ImportMoneyFromPlayer;
    PlanetQuestScreen.ImportExternalParameters;
  end;
end;
{ @end $55A628 }

{ @routine $55A6B8 TfPlanetQuest_ExecuteUiCode }
procedure TfPlanetQuest.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if ExitScreenLoop then Exit;
  if Integer(TurnCalculationPhase) in [0, 2, 4, 6] then
  begin
    if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(10109);
    ExecuteGameplayUiCode(Block, Key);
    if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(20109);
  end;
end;
{ @end $55A6B8 }

end.
