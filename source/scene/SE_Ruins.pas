unit SE_Ruins;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_MessageLoop, SE_Space, Types;

const
  rsInitial = 0;
  rsIdle = 1;
  rsDisappearing = 2;
  rsAppearing = 3;
  rsPlayingDisappearance = 4;

type
  TRuinsSE = class(TObjectSE) // @size $D8 @methodorder source
  public
    ImagePath: WideString; // @offset $4C
    StaticImagePath: WideString; // @offset $50
    MinimapImagePath: WideString; // @offset $54
    Animation: TgaiGI; // @offset $58
    StaticImage: TImageGI; // @offset $5C
    MinimapImage: TImageGI; // @offset $60
    FrameIndex: Integer; // @offset $64
    Alpha: Byte; // @offset $68
    AlphaLimit: Byte; // @offset $69
    WeaponPortCount: Cardinal; // @offset $6C
    WeaponPorts: array[1..10] of TPointF; // @offset $70
    HasTransitionImages: Boolean; // @offset $C0
    State: Integer; // @offset $C4
    FadeTimer: TCallbackTimerIdGI; // @offset $C8

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $699408
    procedure DetachFromSpace; override; // @addr $69987C
    procedure SetPosition(APosition: TPointF); override; // @addr $699B44
    procedure SetDepth(Value: Single); override; // @addr $699BEC
    function GetDepth: Single; override; // @addr $699C24
    function GetAlpha: Byte; override; // @addr $699C4C
    procedure SetAlpha(Value: Byte); override; // @addr $699C54
    function HitTestCursor: Boolean; override; // @addr $699D64
    procedure DrawMap; override; // @addr $699CB0
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $699FF4
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $69A2B0
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $69A2B8
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $69928C
    procedure SetState(Value: Integer); // @addr $6998FC
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $699998
    procedure AdvanceFade(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $699AA4
    function GetWeaponPortPoint(Seed: Cardinal): TPointF; // @addr $699D04

    KeepSize: Boolean; // @offset $CC
    PanelPartnerImage: WideString; // @offset $D0
    HideOnStarInfo: Boolean; // @offset $D4
  end;

implementation

uses Math, SysUtils, EC_Str, Globals, GlobalsV, GR_Main, SE_Process;

{ @routine $69928C TRuinsSE_Create }
constructor TRuinsSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  if CountDelimitedPartsW(GraphKey, ',') > 1 then
  begin
    inherited Create(ExtractDelimitedPartW(GraphKey, 0, ','), UnusedPosition);
    AlphaLimit := ExtractDigitsToIntW(ExtractDelimitedPartW(GraphKey, 1, ','));
  end
  else
  begin
    inherited Create(GraphKey, UnusedPosition);
    AlphaLimit := 255;
  end;
  HasTransitionImages := CacheDataRoot.FileExistsByPath(ImagePath + 'To') and CacheDataRoot.FileExistsByPath(ImagePath + 'From');
  State := rsInitial;
  Alpha := 255;
end;
{ @end $69928C }

{ @routine $699408 TRuinsSE_AttachToSpace }
procedure TRuinsSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Ruins.' + ExtractDelimitedPartW(ImagePath, CountDelimitedPartsW(ImagePath, '.') - 1, '.'));
  ConfigureRandomSound('Ruins.' + ExtractDelimitedPartW(ImagePath, CountDelimitedPartsW(ImagePath, '.') - 1, '.'));
  inherited AttachToSpace(ASpace);
  if AnimShipFull or (CurrentScreenId = screenArcadeBattle) then
  begin
    Animation := TgaiGI.Create(Space.MapPanel);
    if State = rsAppearing then
    begin
      Animation.SetImagePath(ImagePath + 'From');
      Animation.CycleCompleteCallback := AnimationCycleComplete;
      FrameIndex := 0;
    end
    else if State = rsDisappearing then
    begin
      Animation.SetImagePath(ImagePath + 'To');
      Animation.CycleCompleteCallback := AnimationCycleComplete;
      State := rsPlayingDisappearance;
      FrameIndex := 0;
    end
    else Animation.SetImagePath(ImagePath);
    Animation.ObjectSize := Animation.GetContentSize;
    Animation.Sme := HalfPoint(Animation.ClientSize);
    Animation.SetDepthByName(DepthExpression);
    Animation.Pos := TruncatePointF(Position);
    Animation.World := True;
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    if not (State in [rsDisappearing, rsAppearing]) then FrameIndex := Random(Animation.SequenceFrameCount - 1);
    Animation.SetSequenceFrame(FrameIndex);
    Animation.RestartPlayback;
    Animation.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
    if not KeepSize then Size := Animation.ClientSize;
  end
  else
  begin
    StaticImage := TImageGI.Create(Space.MapPanel);
    StaticImage.ImageSourcePath := StaticImagePath;
    StaticImage.ObjectSize := StaticImage.GetContentSize;
    StaticImage.Sme := HalfPoint(StaticImage.ClientSize);
    StaticImage.SetDepthByName(DepthExpression);
    StaticImage.Pos := TruncatePointF(Position);
    StaticImage.World := True;
    StaticImage.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
    if State = rsAppearing then
    begin
      FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade);
      SetAlpha(0);
    end
    else if State = rsDisappearing then
    begin
      FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade);
      SetAlpha(255);
    end;
    if not KeepSize then Size := StaticImage.ClientSize;
  end;
  MinimapImage := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
  MinimapImage.World := True;
  MinimapImage.SetDepthByName(DepthExpression);
  MinimapImage.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
  MinimapImage.ImageSourcePath := MinimapImagePath;
  MinimapImage.ObjectSize := MinimapImage.GetContentSize;
  MinimapImage.Sme := HalfPoint(MinimapImage.ClientSize);
end;
{ @end $699408 }

{ @routine $69987C TRuinsSE_DetachFromSpace }
procedure TRuinsSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if FadeTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(FadeTimer);
    FadeTimer := 0;
  end;
  if Animation <> nil then
  begin
    FrameIndex := Animation.SequenceFrame;
    Animation.Free;
    Animation := nil;
  end;
  if StaticImage <> nil then
  begin
    StaticImage.IsActive := False;
    StaticImage.Free;
    StaticImage := nil;
  end;
  if MinimapImage <> nil then
  begin
    MinimapImage.Free;
    MinimapImage := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $69987C }

{ @routine $6998FC TRuinsSE_SetState }
procedure TRuinsSE.SetState(Value: Integer);
begin
  if not IsAttachedToSpace then
  begin
    State := Value;
  end
  else
  begin
    if State = Value then Exit;
    State := Value;
    if Animation <> nil then
    begin
      if not (State in [rsInitial, rsIdle]) then Animation.CycleCompleteCallback := AnimationCycleComplete;
    end
    else if StaticImage <> nil then
    begin
      if State in [rsDisappearing, rsAppearing] then FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade)
      else if FadeTimer <> 0 then
      begin
        Space.Screen.CancelCallbackTimer(FadeTimer);
        FadeTimer := 0;
      end;
    end;
  end;
end;
{ @end $6998FC }

{ @routine $699998 TRuinsSE_AnimationCycleComplete }
procedure TRuinsSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if State = rsDisappearing then
  begin
    Animation.SetImagePath(ImagePath + 'To');
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetSequenceFrame(0);
    Animation.RestartPlayback;
    State := rsPlayingDisappearance;
  end
  else if (State = rsAppearing) or (State = rsIdle) then
  begin
    Animation.SetImagePath(ImagePath);
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetSequenceFrame(0);
    Animation.RestartPlayback;
    Animation.CycleCompleteCallback := nil;
    State := rsIdle;
  end
  else
  begin
    Animation.CycleCompleteCallback := nil;
    DetachFromSpace;
  end;
end;
{ @end $699998 }

{ @routine $699AA4 TRuinsSE_AdvanceFade }
procedure TRuinsSE.AdvanceFade(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if State = rsDisappearing then
  begin
    SetAlpha(Math.Max(0, GetAlpha - 5));
    if GetAlpha = 0 then
    begin
      State := rsIdle;
      DetachFromSpace;
    end;
  end
  else
  begin
    SetAlpha(Math.Min(255, GetAlpha + 5));
    if GetAlpha = 255 then
    begin
      State := rsIdle;
      if FadeTimer <> 0 then
      begin
        Space.Screen.CancelCallbackTimer(FadeTimer);
        FadeTimer := 0;
      end;
    end;
  end;
end;
{ @end $699AA4 }

{ @routine $699B44 TRuinsSE_SetPosition }
procedure TRuinsSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if not IsAttachedToSpace then Exit;
  if StaticImage <> nil then StaticImage.Pos := TruncatePointF(APosition);
  if Animation <> nil then Animation.Pos := TruncatePointF(APosition);
  MinimapImage.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
end;
{ @end $699B44 }

{ @routine $699BEC TRuinsSE_SetDepth }
procedure TRuinsSE.SetDepth(Value: Single);
begin
  if Animation <> nil then Animation.SetDepth(Value);
  if StaticImage <> nil then StaticImage.SetDepth(Value);
end;
{ @end $699BEC }

{ @routine $699C24 TRuinsSE_GetDepth }
function TRuinsSE.GetDepth: Single;
begin
  Result := 0;
  if Animation <> nil then Result := Animation.Depth;
  if StaticImage <> nil then Result := StaticImage.Depth;
end;
{ @end $699C24 }

{ @routine $699C4C TRuinsSE_GetAlpha }
function TRuinsSE.GetAlpha: Byte;
begin
  Result := Alpha;
end;
{ @end $699C4C }

{ @routine $699C54 TRuinsSE_SetAlpha }
procedure TRuinsSE.SetAlpha(Value: Byte);
begin
  Alpha := Value;
  if not IsAttachedToSpace then Exit;
  if Animation <> nil then Animation.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
  if StaticImage <> nil then StaticImage.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
end;
{ @end $699C54 }

{ @routine $699CB0 TRuinsSE_DrawMap }
procedure TRuinsSE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if CurrentProcess.RadarRange > 0 then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $699CB0 }

{ @routine $699D04 TRuinsSE_GetWeaponPortPoint }
function TRuinsSE.GetWeaponPortPoint(Seed: Cardinal): TPointF;
var
  Point: TPointF;
begin
  if WeaponPortCount < 1 then
  begin
    Result := Position;
    Exit;
  end;
  Point := WeaponPorts[1 + (Sqr(Seed) div 11) mod WeaponPortCount];
  Result.X := Position.X + Point.X;
  Result.Y := Position.Y + Point.Y;
end;
{ @end $699D04 }

{ @routine $699D64 TRuinsSE_HitTestCursor }
function TRuinsSE.HitTestCursor: Boolean;
begin
  Result := False;
  if IsAttachedToSpace then
  begin
    if Animation <> nil then Result := Animation.HitTestPixel(Animation.MessageLoop.GetCursorPoint)
    else if StaticImage <> nil then Result := StaticImage.HitTestPixel(StaticImage.MessageLoop.GetCursorPoint);
  end;
end;
{ @end $699D64 }





{ @routine $699FF4 TRuinsSE_LoadTemplate }
procedure TRuinsSE.LoadTemplate(Block: TBlockParEC);
var
  Index: Integer;
  // @nested $699DBC ParseRuinsPoint
  function ParseRuinsPoint(PointText: WideString): TPoint; // @addr $699DBC @calls "0x0069A190"
  begin
    if CountDelimitedPartsW(PointText, ',') < 2 then raise Exception.Create('GetPointGI. tstr=' + PointText);
    Result := Classes.Point(StrToInt(ExtractDelimitedPartW(PointText, 0, ',')), StrToInt(ExtractDelimitedPartW(PointText, 1, ',')));
  end;

  // @nested $699F00 ParseRuinsEnabled
  function ParseRuinsEnabled(Name: WideString): Boolean; // @addr $699F00 @calls "0x0069A11D"
  begin
    if (Name = 'Yes') or (Name = 'yes') or (Name = 'True') or (Name = 'true') or (Name = 'TRUE') or (Name = '1') then Result := True
    else Result := False;
  end;

begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  StaticImagePath := Block.GetParam('ImageI');
  MinimapImagePath := Block.GetParam('ImageMap');
  HasTransitionImages := CacheDataRoot.FileExistsByPath(ImagePath + 'To') and CacheDataRoot.FileExistsByPath(ImagePath + 'From');
  if Block.CountParams('PanelPartnerImage') > 0 then PanelPartnerImage := Block.GetParam('PanelPartnerImage')
  else PanelPartnerImage := '';
  if Block.CountParams('HideOnStarInfo') > 0 then HideOnStarInfo := ParseRuinsEnabled(Block.GetParam('HideOnStarInfo'))
  else HideOnStarInfo := False;
  WeaponPortCount := 0;
  for Index := Low(WeaponPorts) to High(WeaponPorts) do
  begin
    if Block.CountParams('WeaponPort' + IntToWideString(Index)) <= 0 then Break;
    WeaponPorts[Index] := PointToPointF(ParseRuinsPoint(Block.GetParam('WeaponPort' + IntToWideString(Index))));
    Inc(WeaponPortCount);
  end;
end;
{ @end $699FF4 }

{ @routine $69A2B0 TRuinsSE_ApplyConfig }
procedure TRuinsSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $69A2B0 }

{ @routine $69A2B8 TRuinsSE_QueueImageLoad }
procedure TRuinsSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Anim: TgaiGI;
  Image, MapImage: TImageGI;
begin
  if AnimShipFull or (CurrentScreenId = screenArcadeBattle) then
  begin
    Anim := TgaiGI.Create(Owner);
    Anim.SetImagePath(ImagePath);
    Anim.QueueImageLoad(PendingLoads);
    Anim.Free;
  end
  else
  begin
    Image := TImageGI.Create(Owner);
    Image.ImageSourcePath := StaticImagePath;
    Image.QueueImageLoad(PendingLoads);
    Image.Free;
  end;
  MapImage := TImageGI.Create(Owner);
  MapImage.ImageSourcePath := MinimapImagePath;
  MapImage.QueueImageLoad(PendingLoads);
  MapImage.Free;
end;
{ @end $69A2B8 }

end.
