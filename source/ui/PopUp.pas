unit PopUp;
// Unit bracket (inferred): .text 0x004BA424..0x004BAD9F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Placement follows the reviewed PopUp association in reference/unit_ownership.json.
// Native TfPopUpController VMT: $4BA470.

interface

uses GI_MessageLoop, Classes, SyncObjs;

type
  TfPopUpController = class(TObjectGI) // @size $13C
  public
    LastTick: Cardinal; // @offset $120
    PauseRemaining: Cardinal; // @offset $124
    MovingUp: Boolean; // @offset $128
    MotionRemainder: Single; // @offset $12C
    QueueLock: TCriticalSection; // @offset $130
    TextQueue: TList; // @offset $134  Entries point to WideString cells.
    ImageQueue: TList; // @offset $138  Parallel WideString cells for image paths.

    constructor Create; // @addr $4BA54C
    destructor Destroy; override; // @addr $4BA5D0 @note "Frees queued cells without finalizing their strings; does not call inherited Destroy."
    function CreatePopup(Text, ImagePath: WideString): TObjectGI; // @addr $4BA6B4
    procedure QueueNotification(Text, ImagePath: WideString); // @addr $4BADB0 Enqueues parallel managed-string cells under QueueLock.
    procedure AdvancePopups(Tick: Cardinal); // @addr $4BA8F0 @note "Drains queued notifications, advances their vertical animation, and retires off-screen controls."
  end;

var
  PopupController: TfPopUpController = nil; // @addr $87AA04  Created at $529098..$5290AA.
implementation

uses GI_Panel, GI_Image, GI_Label, GI_Main, GR_Main, GlobalsV, Math, Types;

{ @routine $4BA54C TfPopUpController_Create }
constructor TfPopUpController.Create;
begin
  inherited Create(nil);
  QueueLock := TCriticalSection.Create;
  TextQueue := TList.Create;
  ImageQueue := TList.Create;
end;
{ @end $4BA54C }

{ @routine $4BA5D0 TfPopUpController_Destroy }
destructor TfPopUpController.Destroy;
begin
  QueueLock.Enter;
  while TextQueue.Count > 0 do
  begin
    Dispose(TextQueue[0]);
    TextQueue.Delete(0);
  end;
  while ImageQueue.Count > 0 do
  begin
    Dispose(ImageQueue[0]);
    ImageQueue.Delete(0);
  end;
  TextQueue.Free;
  ImageQueue.Free;
  FreeOwnedChildren;
  QueueLock.Leave;
  QueueLock.Free;
end;
{ @end $4BA5D0 }

{ @routine $4BA6B4 TfPopUpController_CreatePopup }
function TfPopUpController.CreatePopup(Text, ImagePath: WideString): TObjectGI;
var LabelControl: TLabelGI; Icon, Background: TImageGI; Panel: TPanelGI;
begin
  Panel := TPanelGI.Create(Self);
  Background := TImageGI.Create(Panel);
  Background.SetPosition(Classes.Point(0, 0));
  Background.SetImagePath('GI,Bm.FormAchievements.MessageBG');
  Background.SetSize(Background.GetContentSize);
  Background.SetActive(True);
  Panel.SetSize(Background.ClientSize);
  Icon := TImageGI.Create(Panel);
  Icon.SetImagePath(ImagePath);
  Icon.SetSize(Icon.GetContentSize);
  Icon.SetPosition(Classes.Point(27, 41));
  Icon.SetActive(True);
  LabelControl := TLabelGI.Create(Panel);
  LabelControl.SetPosition(Classes.Point(Icon.LocalPosition.X + Icon.ClientSize.X + 15, 54));
  LabelControl.SetSize(Classes.Point(Panel.ClientSize.X - Icon.ClientSize.X - Icon.LocalPosition.X - 30, 72));
  LabelControl.SetFontName(NormalBoldFontName);
  LabelControl.SetTextAlignX(taxCenter);
  LabelControl.SetTextAlignY(tayCenterEx);
  LabelControl.SetWordWrapEnabled(True);
  LabelControl.SetText(Text);
  LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  LabelControl.SetActive(True);
  Result := Panel;
end;
{ @end $4BA6B4 }

{ @routine $4BA8F0 TfPopUpController_AdvancePopups }
procedure TfPopUpController.AdvancePopups(Tick: Cardinal);
var Popup, Previous: TObjectGI; Movement, BottomOffset: Integer; Text, ImagePath: WideString;
begin
  if TextQueue.Count > 0 then
  begin
    QueueLock.Enter;
    SetActive(True);
    SetPosition(Classes.Point(0, 0));
    SetDepth(-1000);
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    SetPositionModeW(True);
    MessageLoop := TObject(RegisteredScreens[Ord(CurrentScreenId)]) as TMessageLoopGI;
    while TextQueue.Count > 0 do
    begin
      Text := PWideString(TextQueue[0])^;
      Dispose(TextQueue[0]);
      TextQueue.Delete(0);
      ImagePath := PWideString(ImageQueue[0])^;
      Dispose(ImageQueue[0]);
      ImageQueue.Delete(0);
      Previous := LastChild;
      Popup := CreatePopup(Text, ImagePath);
      if Previous = nil then
      begin
        Popup.SetPosition(Classes.Point(GameScreenWidth - Popup.ClientSize.X - 10, GameScreenHeight + 10));
        MotionRemainder := 0;
      end
      else Popup.SetPosition(Classes.Point(GameScreenWidth - Popup.ClientSize.X - 10, Previous.LocalPosition.Y + Previous.ClientSize.Y + 10));
      MovingUp := True;
      PauseRemaining := 0;
    end;
    QueueLock.Leave;
  end;
  if FirstChild = nil then LastTick := Tick
  else
  begin
    if PauseRemaining > 0 then
    begin
      PauseRemaining := Max(Tick - LastTick, PauseRemaining) - (Tick - LastTick);
      if PauseRemaining = 0 then MovingUp := False;
    end
    else
    begin
      MotionRemainder := MotionRemainder + Max(0, Tick - LastTick) * 0.07;
      if MotionRemainder >= 1 then
      begin
        Movement := Trunc(MotionRemainder);
        MotionRemainder := MotionRemainder - Movement;
        if MovingUp then
        begin
          BottomOffset := LastChild.LocalPosition.Y + LastChild.ClientSize.Y - GameScreenHeight;
          if BottomOffset - Movement <= -10 then
          begin
            Movement := BottomOffset + 10;
            PauseRemaining := 2000;
          end;
          Popup := FirstChild;
          while Popup <> nil do
          begin
            Popup.SetPosition(Classes.Point(Popup.LocalPosition.X, Popup.LocalPosition.Y - Movement));
            Popup := Popup.NextSibling;
          end;
        end
        else
        begin
          Popup := FirstChild;
          while Popup <> nil do
          begin
            Popup.SetPosition(Classes.Point(Popup.LocalPosition.X, Popup.LocalPosition.Y + Movement));
            Popup := Popup.NextSibling;
          end;
        end;
      end;
    end;
    LastTick := Tick;
    if not MovingUp then
      while (LastChild <> nil) and (LastChild.LocalPosition.Y > GameScreenHeight) do FreeOwnedChild(LastChild);
    if FirstChild = nil then SetActive(False);
  end;
end;
{ @end $4BA8F0 }

{ @routine $4BADB0 TfPopUpController_QueueNotification }
procedure TfPopUpController.QueueNotification(Text, ImagePath: WideString);
var Cell: PWideString;
begin
  QueueLock.Enter;
  New(Cell);
  Cell^ := Text;
  TextQueue.Add(Cell);
  New(Cell);
  Cell^ := ImagePath;
  ImageQueue.Add(Cell);
  QueueLock.Leave;
end;
{ @end $4BADB0 }

end.
