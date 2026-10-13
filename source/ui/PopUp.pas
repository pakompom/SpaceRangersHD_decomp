unit PopUp;

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

    constructor Create; // @addr $4BF1E0
    destructor Destroy; override; // @addr $4BF250 @note "Frees queued cells without finalizing their strings; does not call inherited Destroy."
    function CreatePopup(Text, ImagePath: WideString): TObjectGI; // @addr $4BF300
    procedure QueueNotification(Text, ImagePath: WideString); // @addr $4BF8F8 Enqueues parallel managed-string cells under QueueLock.
    procedure AdvancePopups(Tick: Cardinal); // @addr $4BF514 @note "Drains queued notifications, advances their vertical animation, and retires off-screen controls."
  end;

var
  PopupController: TfPopUpController = nil; // @addr $80B70C
implementation

uses GI_Panel, GI_Image, GI_Label, GI_Main, GR_Main, GlobalsV, Math, Types;

{ @routine $4BF1E0 TfPopUpController_Create }
constructor TfPopUpController.Create;
begin
  inherited Create(nil);
  QueueLock := TCriticalSection.Create;
  TextQueue := TList.Create;
  ImageQueue := TList.Create;
end;
{ @end $4BF1E0 }

{ @routine $4BF250 TfPopUpController_Destroy }
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
{ @end $4BF250 }

{ @routine $4BF300 TfPopUpController_CreatePopup }
function TfPopUpController.CreatePopup(Text, ImagePath: WideString): TObjectGI;
var LabelControl: TLabelGI; Icon, Background: TImageGI; Panel: TPanelGI;
begin
  Panel := TPanelGI.Create(Self);
  Background := TImageGI.Create(Panel);
  Background.Pos := Classes.Point(0, 0);
  Background.ImageSourcePath := 'GI,Bm.FormAchievements.MessageBG';
  Background.ObjectSize := Background.GetContentSize;
  Background.IsActive := True;
  Panel.ObjectSize := Background.ClientSize;
  Icon := TImageGI.Create(Panel);
  Icon.ImageSourcePath := ImagePath;
  Icon.ObjectSize := Icon.GetContentSize;
  Icon.Pos := Classes.Point(27, 41);
  Icon.IsActive := True;
  LabelControl := TLabelGI.Create(Panel);
  LabelControl.Pos := Classes.Point(Icon.LocalPosition.X + Icon.ClientSize.X + 15, 54);
  LabelControl.ObjectSize := Classes.Point(Panel.ClientSize.X - Icon.ClientSize.X - Icon.LocalPosition.X - 30, 72);
  LabelControl.SetFontName(NormalBoldFontName);
  LabelControl.SetTextAlignX(taxCenter);
  LabelControl.SetTextAlignY(tayCenterEx);
  LabelControl.SetWordWrapEnabled(True);
  LabelControl.Text := Text;
  LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  LabelControl.IsActive := True;
  Result := Panel;
end;
{ @end $4BF300 }

{ @routine $4BF514 TfPopUpController_AdvancePopups }
procedure TfPopUpController.AdvancePopups(Tick: Cardinal);
var Popup, Previous: TObjectGI; Movement, BottomOffset: Integer; Text, ImagePath: WideString;
begin
  if TextQueue.Count > 0 then
  begin
    QueueLock.Enter;
    IsActive := True;
    Pos := Classes.Point(0, 0);
    SetDepth(-1000);
    ObjectSize := Classes.Point(GameScreenWidth, GameScreenHeight);
    World := True;
    MessageLoop := RegisteredScreens[CurrentScreenId] as TMessageLoopGI;
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
        Popup.Pos := Classes.Point(Integer(GameScreenWidth) - Popup.ClientSize.X - 10, Integer(GameScreenHeight) + 10);
        MotionRemainder := 0;
      end
      else Popup.Pos := Classes.Point(Integer(GameScreenWidth) - Popup.ClientSize.X - 10, Previous.LocalPosition.Y + Previous.ClientSize.Y + 10);
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
          BottomOffset := LastChild.LocalPosition.Y + LastChild.ClientSize.Y - Integer(GameScreenHeight);
          if BottomOffset - Movement <= -10 then
          begin
            Movement := BottomOffset + 10;
            PauseRemaining := 2000;
          end;
          Popup := FirstChild;
          while Popup <> nil do
          begin
            Popup.Pos := Classes.Point(Popup.LocalPosition.X, Popup.LocalPosition.Y - Movement);
            Popup := Popup.NextSibling;
          end;
        end
        else
        begin
          Popup := FirstChild;
          while Popup <> nil do
          begin
            Popup.Pos := Classes.Point(Popup.LocalPosition.X, Popup.LocalPosition.Y + Movement);
            Popup := Popup.NextSibling;
          end;
        end;
      end;
    end;
    LastTick := Tick;
    if not MovingUp then
      while (LastChild <> nil) and (LastChild.LocalPosition.Y > Integer(GameScreenHeight)) do FreeOwnedChild(LastChild);
    if FirstChild = nil then IsActive := False;
  end;
end;
{ @end $4BF514 }

{ @routine $4BF8F8 TfPopUpController_QueueNotification }
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
{ @end $4BF8F8 }

end.
