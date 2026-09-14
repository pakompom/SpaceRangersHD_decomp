unit SE_Ruins;
// Unit bracket (inferred): .text 0x006C8DEC..0x006CA3B5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class and methods: $6C8DEC..$6CA3B6.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_MessageLoop, SE_Space, Types;

type
  TRuinsSE = class(TObjectSE) // @size $D8
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
    State: Integer; // @offset $C4  2 disappears, 3 appears, 4 finishes the To animation.
    FadeTimer: PCallbackTimerGI; // @offset $C8
    KeepSize: Boolean; // @offset $CC
    PanelPartnerImage: WideString; // @offset $D0
    HideOnStarInfo: Boolean; // @offset $D4
    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $6C8EC8 @ida "TRuinsSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $6C9064
    procedure DetachFromSpace; override; // @addr $6C9620
    procedure SetState(Value: Integer); // @addr $6C96E4
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $6C97DC
    procedure AdvanceFade(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6C9938
    procedure SetPosition(APosition: TPointF); override; // @addr $6C9A2C @ida "void __usercall $name(TRuinsSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure SetDepth(Value: Single); override; // @addr $6C9AEC @ida "void __userpurge $name(TRuinsSE *Self@<eax>, float Value@<^0>);"
    function GetDepth: Single; override; // @addr $6C9B34 @ida "float __usercall $name@<st0>(TRuinsSE *Self@<eax>);"
    function GetAlpha: Byte; override; // @addr $6C9B78
    procedure SetAlpha(Value: Byte); override; // @addr $6C9B94
    procedure DrawMap; override; // @addr $6C9C54
    function GetWeaponPortPoint(Seed: Cardinal): TPointF; // @addr $6C9CB4 @ida "void __usercall $name(TRuinsSE *Self@<eax>, unsigned int Seed@<edx>, TPointF *Result@<ecx>);"
    function HitTestCursor: Boolean; override; // @addr $6C9D2C
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $6C9FE0
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $6CA2D8
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $6CA2F4
  end;

implementation

uses Math, SysUtils, EC_Str, Globals, GlobalsV, GR_Main, SE_Process;

{ @routine $6C8EC8 TRuinsSE_Create }
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
  State := 0;
  Alpha := 255;
end;
{ @end $6C8EC8 }

{ @routine $6C9064 TRuinsSE_AttachToSpace }
procedure TRuinsSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not IsAttachedToSpace then
  begin
    ConfigureLoopSound('Ruins.' + ExtractDelimitedPartW(ImagePath, CountDelimitedPartsW(ImagePath, '.') - 1, '.'));
    ConfigureRandomSound('Ruins.' + ExtractDelimitedPartW(ImagePath, CountDelimitedPartsW(ImagePath, '.') - 1, '.'));
    inherited AttachToSpace(ASpace);
    if AnimShipFull or (CurrentScreenId = screenArcadeBattle) then
    begin
      Animation := TgaiGI.Create(Space.MapPanel);
      if State = 3 then
      begin
        Animation.SetImagePath(ImagePath + 'From');
        Animation.CycleCompleteCallback := AnimationCycleComplete;
        FrameIndex := 0;
      end
      else if State = 2 then
      begin
        Animation.SetImagePath(ImagePath + 'To');
        Animation.CycleCompleteCallback := AnimationCycleComplete;
        State := 4;
        FrameIndex := 0;
      end
      else Animation.SetImagePath(ImagePath);
      Animation.SetSize(Animation.GetContentSize);
      Animation.SetOrigin(HalfPoint(Animation.ClientSize));
      Animation.SetDepthByName(DepthExpression);
      Animation.SetPosition(TruncatePointF(Position));
      Animation.SetPositionModeW(True);
      Animation.SequenceIndex := 0;
      Animation.UpdateAutoGeometry;
      if not (State in [2, 3]) then FrameIndex := Random(Animation.SequenceFrameCount - 1);
      Animation.SetSequenceFrame(FrameIndex);
      Animation.RestartPlayback;
      Animation.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
      if not KeepSize then Size := Animation.ClientSize;
    end
    else
    begin
      StaticImage := TImageGI.Create(Space.MapPanel);
      StaticImage.SetImagePath(StaticImagePath);
      StaticImage.SetSize(StaticImage.GetContentSize);
      StaticImage.SetOrigin(HalfPoint(StaticImage.ClientSize));
      StaticImage.SetDepthByName(DepthExpression);
      StaticImage.SetPosition(TruncatePointF(Position));
      StaticImage.SetPositionModeW(True);
      StaticImage.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
      if State = 3 then
      begin
        FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade);
        SetAlpha(0);
      end
      else if State = 2 then
      begin
        FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade);
        SetAlpha(255);
      end;
      if not KeepSize then Size := StaticImage.ClientSize;
    end;
    MinimapImage := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    MinimapImage.SetPositionModeW(True);
    MinimapImage.SetDepthByName(DepthExpression);
    MinimapImage.SetPosition(TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale)));
    MinimapImage.SetImagePath(MinimapImagePath);
    MinimapImage.SetSize(MinimapImage.GetContentSize);
    MinimapImage.SetOrigin(HalfPoint(MinimapImage.ClientSize));
  end;
end;
{ @end $6C9064 }

{ @routine $6C9620 TRuinsSE_DetachFromSpace }
procedure TRuinsSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    if FadeTimer <> nil then
    begin
      Space.Screen.CancelCallbackTimer(FadeTimer);
      FadeTimer := nil;
    end;
    if Animation <> nil then
    begin
      FrameIndex := Animation.SequenceFrame;
      Animation.Free;
      Animation := nil;
    end;
    if StaticImage <> nil then
    begin
      StaticImage.SetActive(False);
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
end;
{ @end $6C9620 }

{ @routine $6C96E4 TRuinsSE_SetState }
procedure TRuinsSE.SetState(Value: Integer);
begin
  if not IsAttachedToSpace then
  begin
    State := Value;
    Exit;
  end;
  if State = Value then Exit;
  State := Value;
  if Animation <> nil then
  begin
    if not (State in [0, 1]) then Animation.CycleCompleteCallback := AnimationCycleComplete;
  end
  else if StaticImage <> nil then
  begin
    if State in [2, 3] then FadeTimer := Space.Screen.ScheduleCallbackTimer(20, 20, AdvanceFade)
    else if FadeTimer <> nil then
    begin
      Space.Screen.CancelCallbackTimer(FadeTimer);
      FadeTimer := nil;
    end;
  end;
end;
{ @end $6C96E4 }

{ @routine $6C97DC TRuinsSE_AnimationCycleComplete }
procedure TRuinsSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if State = 2 then
  begin
    Animation.SetImagePath(ImagePath + 'To');
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetSequenceFrame(0);
    Animation.RestartPlayback;
    State := 4;
  end
  else if (State = 3) or (State = 1) then
  begin
    Animation.SetImagePath(ImagePath);
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.SetSequenceFrame(0);
    Animation.RestartPlayback;
    Animation.CycleCompleteCallback := nil;
    State := 1;
  end
  else
  begin
    Animation.CycleCompleteCallback := nil;
    DetachFromSpace;
  end;
end;
{ @end $6C97DC }

{ @routine $6C9938 TRuinsSE_AdvanceFade }
procedure TRuinsSE.AdvanceFade(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if State = 2 then
  begin
    SetAlpha(Math.Max(0, GetAlpha - 5));
    if GetAlpha = 0 then
    begin
      State := 1;
      DetachFromSpace;
    end;
  end
  else
  begin
    SetAlpha(Math.Min(255, GetAlpha + 5));
    if GetAlpha = 255 then
    begin
      State := 1;
      if FadeTimer <> nil then
      begin
        Space.Screen.CancelCallbackTimer(FadeTimer);
        FadeTimer := nil;
      end;
    end;
  end;
end;
{ @end $6C9938 }

{ @routine $6C9A2C TRuinsSE_SetPosition }
procedure TRuinsSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    if StaticImage <> nil then StaticImage.SetPosition(TruncatePointF(APosition));
    if Animation <> nil then Animation.SetPosition(TruncatePointF(APosition));
    MinimapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $6C9A2C }

{ @routine $6C9AEC TRuinsSE_SetDepth }
procedure TRuinsSE.SetDepth(Value: Single);
begin
  if Animation <> nil then Animation.SetDepth(Value);
  if StaticImage <> nil then StaticImage.SetDepth(Value);
end;
{ @end $6C9AEC }

{ @routine $6C9B34 TRuinsSE_GetDepth }
function TRuinsSE.GetDepth: Single;
begin
  Result := 0;
  if Animation <> nil then Result := Animation.Depth;
  if StaticImage <> nil then Result := StaticImage.Depth;
end;
{ @end $6C9B34 }

{ @routine $6C9B78 TRuinsSE_GetAlpha }
function TRuinsSE.GetAlpha: Byte;
begin
  Result := Alpha;
end;
{ @end $6C9B78 }

{ @routine $6C9B94 TRuinsSE_SetAlpha }
procedure TRuinsSE.SetAlpha(Value: Byte);
begin
  Alpha := Value;
  if IsAttachedToSpace then
  begin
    if Animation <> nil then Animation.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
    if StaticImage <> nil then StaticImage.SetAlpha(Math.Min(Alpha, AlphaLimit) shr Space.AlphaShift);
  end;
end;
{ @end $6C9B94 }

{ @routine $6C9C54 TRuinsSE_DrawMap }
procedure TRuinsSE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if CurrentProcess.RadarRange > 0 then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $6C9C54 }

{ @routine $6C9CB4 TRuinsSE_GetWeaponPortPoint }
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
{ @end $6C9CB4 }

{ @routine $6C9D2C TRuinsSE_HitTestCursor }
function TRuinsSE.HitTestCursor: Boolean;
begin
  Result := False;
  if IsAttachedToSpace then
  begin
    if Animation <> nil then Result := Animation.HitTestPixel(Animation.MessageLoop.GetCursorPoint)
    else if StaticImage <> nil then Result := StaticImage.HitTestPixel(StaticImage.MessageLoop.GetCursorPoint);
  end;
end;
{ @end $6C9D2C }





{ @routine $6C9FE0 TRuinsSE_LoadTemplate }
procedure TRuinsSE.LoadTemplate(Block: TBlockParEC);
var
  Index: Integer;
  // @nested $6C9DA4 ParseRuinsPoint
  function ParseRuinsPoint(PointText: WideString): TPoint; // @addr $6C9DA4 @ida "void __usercall $name(unsigned __int16 *PointText@<eax>, TPoint *Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x6CA1AD"
  begin
    if CountDelimitedPartsW(PointText, ',') < 2 then raise Exception.Create('GetPointGI. tstr=' + PointText);
    Result := Classes.Point(StrToInt(ExtractDelimitedPartW(PointText, 0, ',')), StrToInt(ExtractDelimitedPartW(PointText, 1, ',')));
  end;

  // @nested $6C9EE8 ParseRuinsEnabled
  function ParseRuinsEnabled(Name: WideString): Boolean; // @addr $6C9EE8 @ida "bool __usercall $name@<al>(unsigned __int16 *Name@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x6CA129"
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
{ @end $6C9FE0 }

{ @routine $6CA2D8 TRuinsSE_ApplyConfig }
procedure TRuinsSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $6CA2D8 }

{ @routine $6CA2F4 TRuinsSE_QueueImageLoad }
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
    Image.SetImagePath(StaticImagePath);
    Image.QueueImageLoad(PendingLoads);
    Image.Free;
  end;
  MapImage := TImageGI.Create(Owner);
  MapImage.SetImagePath(MinimapImagePath);
  MapImage.QueueImageLoad(PendingLoads);
  MapImage.Free;
end;
{ @end $6CA2F4 }

end.
