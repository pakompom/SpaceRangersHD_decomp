unit fSelectFace;
// Unit bracket (inferred): .text 0x00564144..0x005655EE; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, Types;

type
  TfSelectFace = class(TMessageLoopGI) // @size $110
  public
    PlayerRace: Byte; // @offset $D0
    CaptainPortraitIndex: Integer; // @offset $D4
    LastPortraitByRace: array[0..4] of Integer; // @offset $D8
    PlayerName: WideString; // @offset $EC Bound to the player-name edit control in OnOpen.

    PlayerNameEdited: Boolean; // @offset $F0
    NationalityCosts: array[0..4] of Integer; // @offset $F4
    AvailableMoney: Integer; // @offset $108
    AcceptedCost: Integer; // @offset $10C

    procedure OnOpen; override; // @addr $5646DC
    procedure OnClose; override; // @addr $564804
    procedure ProcessCallbackTimers; override; // @addr $5654C0
    procedure SelectMusic; override; // @addr $565494
    procedure PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $564810 @ida "void __userpurge $name(TfSelectFace *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure RefreshPortrait; // @addr $564864
    procedure PreviousPortraitClicked(Sender: TObjectGI); // @addr $564B60
    procedure NextPortraitClicked(Sender: TObjectGI); // @addr $564B84
    procedure SelectRace(Sender: TObjectGI); // @addr $564BA8
    procedure RaceClicked(Sender: TObjectGI); // @addr $564D18
    procedure ApplyClicked(Sender: TObjectGI); // @addr $564DB8
    procedure CancelClicked(Sender: TObjectGI); // @addr $565074
    procedure RefreshPact; // @addr $565094
    procedure PlayerNameChanged(Sender: TObjectGI); // @addr $5651C4
    function ValidatePlayerName(Name: WideString): Boolean; // @addr $565288
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $565408
    procedure InitializeLayout; override; // @addr $5641F0
  end;

function RunSelectFaceDialog(Parent: TMessageLoopGI): Boolean; // @addr $565500 @note "Borrows the initialized SelectFaceScreen; returns True only for Run result 1. Caller supplies and reads its selection fields."

implementation

uses Classes, Windows, GR_Main, GR_Music, Globals, GlobalsV, EC_Str, SysUtils,
  aConst, aMyFunction, GI_Main, GI_Edit, GI_GraphButton, GI_GraphBuf, GI_Image,
  GI_Label, GI_gai;

{ @routine $5641F0 TfSelectFace_InitializeLayout }
procedure TfSelectFace.InitializeLayout;
var I: Integer; Face: WideString; Race: Byte; Control: TObjectGI;
begin
  inherited;
  for Race := 0 to 4 do
  begin
    I := -1;
    repeat
      Inc(I);
      Face := IntToStr(I);
      if I < 10 then Face := '0' + Face;
    until GameDataConfig.GetBlockByPath('StyleFace' + OwnerInfo[RaceToOwner(Race)].InternalName).CountParams(Face) <= 0;
    LastPortraitByRace[Race] := I - 1;
  end;
  AppendLogTextThreadSafe('fSelectFace... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('PlayerName').Parent do SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
  end;
  AppendLogLineThreadSafe('ok');
  Control := FindControlByPath('SubPanel');
  if (Control <> nil) and (ExtraScreenHeight < 0) then
  begin
    Control.SetPosition(Classes.Point(0,ExtraScreenHeight));
    Control.SetSize(Classes.Point(GameScreenWidth,GameScreenHeight - ExtraScreenHeight));
  end;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  GetByName('MainPanel').LeftButtonDownCallback := PlayerNameMouseDown;
  (GetByName('FaceLeft') as TGraphButtonGI).DownCallback := PreviousPortraitClicked;
  (GetByName('FaceRight') as TGraphButtonGI).DownCallback := NextPortraitClicked;
  for I := 0 to 4 do
  begin
    Face := OwnerToSys(RaceToOwner(NumberToRace(I)));
    with GetByName('Race' + Face) as TGraphButtonGI do
    begin
      DownCallback := RaceClicked;
      UpCallback := RaceClicked;
      UserValue := I;
    end;
  end;
  (GetByName('Ok') as TGraphButtonGI).UpCallback := ApplyClicked;
  (GetByName('Cancel') as TGraphButtonGI).UpCallback := CancelClicked;
  with GetByName('PlayerName') as TEditGI do
  begin
    ChangedCallback := PlayerNameChanged;
    MaxLength := 13;
  end;
end;
{ @end $5641F0 }

{ @routine $5646DC TfSelectFace_OnOpen }
procedure TfSelectFace.OnOpen;
begin
  CaptureScreenBackground(True,0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  SelectRace(GetByName('Race' + OwnerToSys(RaceToOwner(PlayerRace))));
  (GetByName('PlayerName') as TEditGI).SetText(PlayerName);
  RefreshPact;
  PlayerNameEdited := False;
  RefreshPortrait;
end;
{ @end $5646DC }

{ @routine $564804 TfSelectFace_OnClose }
procedure TfSelectFace.OnClose;
begin
end;
{ @end $564804 }

{ @routine $564810 TfSelectFace_PlayerNameMouseDown }
procedure TfSelectFace.PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SetFocusedControl(GetByName('PlayerName'));
end;
{ @end $564810 }

{ @routine $564864 TfSelectFace_RefreshPortrait }
procedure TfSelectFace.RefreshPortrait;
begin
  if CaptainPortraitIndex < 0 then CaptainPortraitIndex := LastPortraitByRace[PlayerRace]
  else if CaptainPortraitIndex > LastPortraitByRace[PlayerRace] then CaptainPortraitIndex := 0;
  with GetByName('CaptainI') as TImageGI do
    if LastPortraitByRace[PlayerRace] >= 0 then
    begin
      SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + OwnerInfo[RaceToOwner(PlayerRace)].InternalName + IntToStr(CaptainPortraitIndex) + 'i');
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end
    else SetActive(False);
  with GetByName('CaptainA') as TgaiGI do
  begin
    FirstFrameOnly := not AnimCaptain;
    if LastPortraitByRace[PlayerRace] >= 0 then
    begin
      SetImagePath('Bm.Captain.' + GiResourceSuffix + OwnerInfo[RaceToOwner(PlayerRace)].InternalName + IntToStr(CaptainPortraitIndex) + 'a');
      SequenceIndex := 0;
      UpdateAutoGeometry;
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
      RestartPlayback;
    end
    else SetActive(False);
  end;
end;
{ @end $564864 }

{ @routine $564B60 TfSelectFace_PreviousPortraitClicked }
procedure TfSelectFace.PreviousPortraitClicked(Sender: TObjectGI);
begin
  Dec(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $564B60 }

{ @routine $564B84 TfSelectFace_NextPortraitClicked }
procedure TfSelectFace.NextPortraitClicked(Sender: TObjectGI);
begin
  Inc(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $564B84 }

{ @routine $564BA8 TfSelectFace_SelectRace }
procedure TfSelectFace.SelectRace(Sender: TObjectGI);
begin
  PlayerRace := Sender.UserValue;
  (GetByName('RaceMaloc') as TGraphButtonGI).SetDown(PlayerRace = 0);
  (GetByName('RacePeleng') as TGraphButtonGI).SetDown(PlayerRace = 1);
  (GetByName('RacePeople') as TGraphButtonGI).SetDown(PlayerRace = 2);
  (GetByName('RaceFei') as TGraphButtonGI).SetDown(PlayerRace = 3);
  (GetByName('RaceGaal') as TGraphButtonGI).SetDown(PlayerRace = 4);

end;
{ @end $564BA8 }

{ @routine $564D18 TfSelectFace_RaceClicked }
procedure TfSelectFace.RaceClicked(Sender: TObjectGI);
begin
  SelectRace(Sender);
  CaptainPortraitIndex := 0;
  RefreshPortrait;
  SetFocusedControl(GetByName('PlayerName'));
  with GetByName('PlayerName') as TEditGI do SetCaretPosition(Length(Text));
  PlayerNameChanged(nil);
end;
{ @end $564D18 }

{ @routine $564DB8 TfSelectFace_ApplyClicked }
procedure TfSelectFace.ApplyClicked(Sender: TObjectGI);
var Cost: Integer; Text: WideString;
begin
  Cost := 0;
  case PlayerRace of
    0: Cost := NationalityCosts[0];
    1: Cost := NationalityCosts[1];
    2: Cost := NationalityCosts[2];
    3: Cost := NationalityCosts[3];
    4: Cost := NationalityCosts[4];
  end;
  if Cost <= AvailableMoney then
  begin
    AcceptedCost := Cost;
    Text := FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormRuins.PB.ChangeNationality.Confirm'),'<color=255,240,100>','<Money>',IntToStr(Cost));
    if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then RequestClose(1);
  end
  else
  begin
    AcceptedCost := 0;
    Text := FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormRuins.PB.ChangeNationality.NoMoney'),'<color=255,240,100>','<Money>',IntToStr(Cost));
    ShowMessageBoxGI(Self,Text,mbgOK or mbgWarning);
  end;
end;
{ @end $564DB8 }

{ @routine $565074 TfSelectFace_CancelClicked }
procedure TfSelectFace.CancelClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $565074 }

{ @routine $565094 TfSelectFace_RefreshPact }
procedure TfSelectFace.RefreshPact;
var Text: WideString;
begin
  Text := LocalizedColorText('FormRuins.PB.ChangeNationality.PactText');
  ReplaceTextToken(Text,'<CurName>',PlayerName,'<color=247,148,29>');
  (GetByName('Pact') as TLabelGI).SetText(Text);
end;
{ @end $565094 }

{ @routine $5651C4 TfSelectFace_PlayerNameChanged }
procedure TfSelectFace.PlayerNameChanged(Sender: TObjectGI);
begin
  if Sender <> nil then PlayerNameEdited := True;
  (GetByName('Ok') as TGraphButtonGI).SetDisabled(not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text));
  PlayerName := (GetByName('PlayerName') as TEditGI).Text;
  RefreshPact;
end;
{ @end $5651C4 }

{ @routine $565288 TfSelectFace_ValidatePlayerName }
function TfSelectFace.ValidatePlayerName(Name: WideString): Boolean;
var I: Integer;
begin
  Result := False;
  Name := RemoveWideStringChars(Name,'<>{}');
  with GetByName('PlayerName') as TEditGI do
    if Text <> Name then
    begin
      I := CaretPosition;
      SetText(Name);
      if I > 0 then SetCaretPosition(I - 1) else SetCaretPosition(0);
    end;
  Name := TrimWideString(Name);
  if Length(Name) < 1 then Exit;
  with GetByName('PlayerName') as TEditGI do
    for I := 0 to Length(Name) - 1 do
      if not HasGlyph(Name[I + 1]) then Exit;
  Result := True;
end;
{ @end $565288 }

{ @routine $565408 TfSelectFace_MainPanelKeyDown }
procedure TfSelectFace.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
    if Key = VK_RETURN then
    begin
      if not (GetByName('Ok') as TGraphButtonGI).Disabled then ApplyClicked(nil);
    end
    else if Key = VK_ESCAPE then CancelClicked(nil);
end;
{ @end $565408 }

{ @routine $565494 TfSelectFace_SelectMusic }
procedure TfSelectFace.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $565494 }

{ @routine $5654C0 TfSelectFace_ProcessCallbackTimers }
procedure TfSelectFace.ProcessCallbackTimers;
begin
  inherited;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $5654C0 }

{ @routine $565500 RunSelectFaceDialog }
function RunSelectFaceDialog(Parent: TMessageLoopGI): Boolean;
var
  CursorAlignment: array[0..2] of Byte; // Native gap between the Boolean result and packed cursor record at EBP-$20.
  State: TCursorStateGI;
begin
  Result := False;
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  SelectFaceScreen.ParentLoop := Parent;
  Parent.ChildLoop := SelectFaceScreen;
  if SelectFaceScreen.Run = 1 then Result := True;
  SelectFaceScreen.ParentLoop := nil;
  Parent.ChildLoop := nil;
  Parent.InvalidateViewport;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
  Parent.Present;
  PostMouseMoveMessage;
end;
{ @end $565500 }

end.
