unit fSelectFace;

interface

uses GI_MessageLoop, Types;

type
  TfSelectFace = class(TMessageLoopGI) // @size $110
  public
    PlayerRace: TOwnerId; // @offset $D0
    CaptainPortraitIndex: Integer; // @offset $D4
    LastPortraitByRace: array[oiMaloc..oiGaal] of Integer; // @offset $D8
    PlayerName: WideString; // @offset $EC Bound to the player-name edit control in OnOpen.

    PlayerNameEdited: Boolean; // @offset $F0
    NationalityCosts: array[oiMaloc..oiGaal] of Integer; // @offset $F4
    AvailableMoney: Integer; // @offset $108
    AcceptedCost: Integer; // @offset $10C

    procedure OnOpen; override; // @addr $5D8D48
    procedure OnClose; override; // @addr $5D8E60
    procedure ProcessCallbackTimers; override; // @addr $5D99B4
    procedure SelectMusic; override; // @addr $5D9990
    procedure PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5D8E64
    procedure RefreshPortrait; // @addr $5D8EB4
    procedure PreviousPortraitClicked(Sender: TObjectGI); // @addr $5D916C
    procedure NextPortraitClicked(Sender: TObjectGI); // @addr $5D9178
    procedure SelectRace(Sender: TObjectGI); // @addr $5D9184
    procedure RaceClicked(Sender: TObjectGI); // @addr $5D92D0
    procedure ApplyClicked(Sender: TObjectGI); // @addr $5D9354
    procedure CancelClicked(Sender: TObjectGI); // @addr $5D95D0
    procedure RefreshPact; // @addr $5D95DC
    procedure PlayerNameChanged(Sender: TObjectGI); // @addr $5D9700
    function ValidatePlayerName(ProposedName: WideString): Boolean; // @addr $5D97AC
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5D9910
    procedure InitializeLayout; override; // @addr $5D88C8
  end;

function RunSelectFaceDialog(Parent: TMessageLoopGI): Boolean; // @addr $5D99E0 @note "Borrows the initialized SelectFaceScreen; returns True only for Run result 1. Caller supplies and reads its selection fields."

implementation

uses Classes, Windows, GR_Main, GR_Music, Globals, GlobalsV, EC_Str, SysUtils,
  aConst, aMyFunction, GI_Main, GI_Edit, GI_GraphButton, GI_GraphBuf, GI_Image,
  GI_Label, GI_gai;

{ @routine $5D88C8 TfSelectFace_InitializeLayout }
procedure TfSelectFace.InitializeLayout;
var I: Integer; Face: WideString; Race: TOwnerId; Control: TObjectGI;
begin
  inherited;
  for Race := oiMaloc to oiGaal do
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
{ @end $5D88C8 }

{ @routine $5D8D48 TfSelectFace_OnOpen }
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
{ @end $5D8D48 }

{ @routine $5D8E60 TfSelectFace_OnClose }
procedure TfSelectFace.OnClose;
begin
end;
{ @end $5D8E60 }

{ @routine $5D8E64 TfSelectFace_PlayerNameMouseDown }
procedure TfSelectFace.PlayerNameMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  SetFocusedControl(GetByName('PlayerName'));
end;
{ @end $5D8E64 }

{ @routine $5D8EB4 TfSelectFace_RefreshPortrait }
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
{ @end $5D8EB4 }

{ @routine $5D916C TfSelectFace_PreviousPortraitClicked }
procedure TfSelectFace.PreviousPortraitClicked(Sender: TObjectGI);
begin
  Dec(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $5D916C }

{ @routine $5D9178 TfSelectFace_NextPortraitClicked }
procedure TfSelectFace.NextPortraitClicked(Sender: TObjectGI);
begin
  Inc(CaptainPortraitIndex);
  RefreshPortrait;
end;
{ @end $5D9178 }

{ @routine $5D9184 TfSelectFace_SelectRace }
procedure TfSelectFace.SelectRace(Sender: TObjectGI);
begin
  PlayerRace := TOwnerId(Sender.UserValue);
  (GetByName('RaceMaloc') as TGraphButtonGI).SetDown(PlayerRace = oiMaloc);
  (GetByName('RacePeleng') as TGraphButtonGI).SetDown(PlayerRace = oiPeleng);
  (GetByName('RacePeople') as TGraphButtonGI).SetDown(PlayerRace = oiHuman);
  (GetByName('RaceFei') as TGraphButtonGI).SetDown(PlayerRace = oiFeyan);
  (GetByName('RaceGaal') as TGraphButtonGI).SetDown(PlayerRace = oiGaal);

end;
{ @end $5D9184 }

{ @routine $5D92D0 TfSelectFace_RaceClicked }
procedure TfSelectFace.RaceClicked(Sender: TObjectGI);
begin
  SelectRace(Sender);
  CaptainPortraitIndex := 0;
  RefreshPortrait;
  SetFocusedControl(GetByName('PlayerName'));
  with GetByName('PlayerName') as TEditGI do SetCaretPosition(Length(Text));
  PlayerNameChanged(nil);
end;
{ @end $5D92D0 }

{ @routine $5D9354 TfSelectFace_ApplyClicked }
procedure TfSelectFace.ApplyClicked(Sender: TObjectGI);
var Cost: Integer; Text: WideString;
begin
  Cost := 0;
  case PlayerRace of
    oiMaloc: Cost := NationalityCosts[oiMaloc];
    oiPeleng: Cost := NationalityCosts[oiPeleng];
    oiHuman: Cost := NationalityCosts[oiHuman];
    oiFeyan: Cost := NationalityCosts[oiFeyan];
    oiGaal: Cost := NationalityCosts[oiGaal];
  end;
  if Cost <= AvailableMoney then
  begin
    AcceptedCost := Cost;
    Text := FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormRuins.PB.ChangeNationality.Confirm'),TextHighlightColorTag,'<Money>',IntToStr(Cost));
    if ShowMessageBoxGI(Self,Text,mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then RequestClose(1);
  end
  else
  begin
    AcceptedCost := 0;
    Text := FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormRuins.PB.ChangeNationality.NoMoney'),TextHighlightColorTag,'<Money>',IntToStr(Cost));
    ShowMessageBoxGI(Self,Text,mbgOK or mbgWarning);
  end;
end;
{ @end $5D9354 }

{ @routine $5D95D0 TfSelectFace_CancelClicked }
procedure TfSelectFace.CancelClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $5D95D0 }

{ @routine $5D95DC TfSelectFace_RefreshPact }
procedure TfSelectFace.RefreshPact;
var Text: WideString;
begin
  Text := LocalizedColorText('FormRuins.PB.ChangeNationality.PactText');
  ReplaceTextToken(Text,'<CurName>',PlayerName,'<color=247,148,29>');
  (GetByName('Pact') as TLabelGI).Text := Text;
end;
{ @end $5D95DC }

{ @routine $5D9700 TfSelectFace_PlayerNameChanged }
procedure TfSelectFace.PlayerNameChanged(Sender: TObjectGI);
begin
  if Sender <> nil then PlayerNameEdited := True;
  (GetByName('Ok') as TGraphButtonGI).SetDisabled(not ValidatePlayerName((GetByName('PlayerName') as TEditGI).Text));
  PlayerName := (GetByName('PlayerName') as TEditGI).Text;
  RefreshPact;
end;
{ @end $5D9700 }

{ @routine $5D97AC TfSelectFace_ValidatePlayerName }
function TfSelectFace.ValidatePlayerName(ProposedName: WideString): Boolean;
var I: Integer;
begin
  Result := False;
  ProposedName := RemoveWideStringChars(ProposedName,'<>{}');
  with GetByName('PlayerName') as TEditGI do
    if Text <> ProposedName then
    begin
      I := CaretPosition;
      SetText(ProposedName);
      if I > 0 then SetCaretPosition(I - 1) else SetCaretPosition(0);
    end;
  ProposedName := TrimWideString(ProposedName);
  if Length(ProposedName) < 1 then Exit;
  with GetByName('PlayerName') as TEditGI do
    for I := 0 to Length(ProposedName) - 1 do
      if not HasGlyph(ProposedName[I + 1]) then Exit;
  Result := True;
end;
{ @end $5D97AC }

{ @routine $5D9910 TfSelectFace_MainPanelKeyDown }
procedure TfSelectFace.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
    if Key = VK_RETURN then
    begin
      if not (GetByName('Ok') as TGraphButtonGI).Disabled then ApplyClicked(nil);
    end
    else if Key = VK_ESCAPE then CancelClicked(nil);
  end;
end;
{ @end $5D9910 }

{ @routine $5D9990 TfSelectFace_SelectMusic }
procedure TfSelectFace.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $5D9990 }

{ @routine $5D99B4 TfSelectFace_ProcessCallbackTimers }
procedure TfSelectFace.ProcessCallbackTimers;
begin
  inherited;
  if (ParentLoop <> nil) and (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(2);
end;
{ @end $5D99B4 }

{ @routine $5D99E0 RunSelectFaceDialog }
function RunSelectFaceDialog(Parent: TMessageLoopGI): Boolean;
var
  State: TCursorStateGI;
begin
  Result := False;
  Parent.RootUiObject.OnModalSuspend;
  Parent.CaptureCursorState(@State);
  Parent.ShowCursor := False;
  Parent.DrawQueuedUpdateRects;
  SelectFaceScreen.ParentLoop := Parent;
  Parent.ChildLoop := SelectFaceScreen;
  if SelectFaceScreen.Run = 1 then Result := True;
  SelectFaceScreen.ParentLoop := nil;
  Parent.ChildLoop := nil;
  Parent.InvalidateViewport;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.OnModalResume;
  Parent.Present;
  PostMouseMoveMessage;
end;
{ @end $5D99E0 }

end.
