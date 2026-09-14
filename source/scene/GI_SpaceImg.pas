unit GI_SpaceImg;
// Unit bracket (inferred): .text 0x00478F0C..0x00479DF4; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, EC_Struct, EC_BlockPar, Types;

type
  TSpaceImageGI = record // @size $88
    TemplateIndex: Integer; // @offset $00
    FrameIndex: Integer; // @offset $04
    FrameTicks: Integer; // @offset $08
    X: Single; // @offset $0C
    Y: Single; // @offset $10
    Depth: Single; // @offset $14
    InverseDepth: Single; // @offset $18
    OrbitCenter: TVector3D; // @offset $20
    Unknown38: TVector3D; // @offset $38 Zeroed on creation; use unresolved.
    ImageSize: TPoint; // @offset $50
    ImageOffset: TPoint; // @offset $58 Native positive half-size.
    PixelPosition: TPoint; // @offset $60
    OrbitStepDegrees: Double; // @offset $68 Per 10 ms callback.
    Unknown70: Integer; // @offset $70 Zeroed on creation; use unresolved.
    OrbitAngleRadians: Double; // @offset $78
    OrbitRadius: Double; // @offset $80
  end;
  PSpaceImageGI = ^TSpaceImageGI;

  TSpaceImgGI = class(TObjectGI) // @size 0x138
  public
    ImageCount: Integer; // @offset $120
    Images: PSpaceImageGI; // @offset $124
    ViewDirty: Boolean; // @offset $128
    ViewPosition: TPointF; // @offset $12C
    AnimationTimer: PCallbackTimerGI; // @offset $134

    constructor Create(Owner: TObjectGI); // @addr $47902C @ida "TSpaceImgGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $479080 @ida "void __usercall $name(TSpaceImgGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearImages; // @addr $4790E4
    function AllocateImage(Depth: Single): PSpaceImageGI; // @addr $479120 @ida "PSpaceImageGI __userpurge $name@<eax>(TSpaceImgGI *Self@<eax>, float Depth@<^0>);" @note "Inserts in descending depth order; reallocates and invalidates earlier pointers."
    function AddImage(TemplateIndex: Integer; X, Y, Depth: Single): PSpaceImageGI; // @addr $479228 @codeend $4793EB @ida "PSpaceImageGI __userpurge $name@<eax>(TSpaceImgGI *Self@<eax>, int TemplateIndex@<edx>, float X@<^8>, float Y@<^4>, float Depth@<^0>);"
    function NearestImageDistance(X, Y: Single): Single; // @addr $4793F4 @ida "float __userpurge $name@<st0>(TSpaceImgGI *Self@<eax>, float X@<^4>, float Y@<^0>);"
    procedure UpdateImageOrbitAndFrame(Image: PSpaceImageGI); // @addr $479498
    procedure ProjectImages; // @addr $479610
    function GetImage(Index: Integer): PSpaceImageGI; // @addr $4796C4
    procedure AnimateImages(Timer: PCallbackTimerGI; UserData: Integer); // @addr $4796F4
    procedure SetViewPosition(Position: TPointF); // @addr $4798AC @ida "void __usercall $name(TSpaceImgGI *Self@<eax>, TPointF *Position@<edx>);"
    procedure Invalidate; override; // @addr $479928
    procedure OnActivate; override; // @addr $4799BC
    procedure OnDeactivate; override; // @addr $479A24
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $479A64
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $479A98
    procedure LoadSpaceImageProperties(Block: TBlockParEC); // @addr $479AC0 @note "Empty in native code."
    procedure UpdateAutoGeometry; override; // @addr $479AD0 @note "Empty in native code."
    procedure Draw(ClipRect: TRect); override; // @addr $479ADC @ida "void __usercall $name(TSpaceImgGI *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

implementation

uses EC_Mem, EC_CacheGAI, GlobalsV, GR_Main, GR_Gi, GR_DX, Windows,
  Direct3D9, aMyFunction, Math;

{ @routine $47902C TSpaceImgGI_Create }
constructor TSpaceImgGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ViewDirty := True;
end;
{ @end $47902C }

{ @routine $479080 TSpaceImgGI_Destroy }
destructor TSpaceImgGI.Destroy;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  ClearImages;
  inherited Destroy;
end;
{ @end $479080 }

{ @routine $4790E4 TSpaceImgGI_ClearImages }
procedure TSpaceImgGI.ClearImages;
begin
  if Images <> nil then
  begin
    FreeEC(Images);
    Images := nil;
  end;
  ImageCount := 0;
end;
{ @end $4790E4 }

{ @routine $479120 TSpaceImgGI_AllocateImage }
function TSpaceImgGI.AllocateImage(Depth: Single): PSpaceImageGI;
var Image: PSpaceImageGI; I, J: Integer;
begin
  Inc(ImageCount);
  Images := ReAllocREC(Images, ImageCount * SizeOf(TSpaceImageGI));
  Image := Images;
  I := 0;
  while ImageCount - 1 > I do
  begin
    if Depth > Image.Depth then Break;
    Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
    Inc(I);
  end;
  J := ImageCount - 1;
  while J > I do
  begin
    CopyMemory(AddPointerOffset(Images, J * SizeOf(TSpaceImageGI)),
      AddPointerOffset(Images, (J - 1) * SizeOf(TSpaceImageGI)), SizeOf(TSpaceImageGI));
    Dec(J);
  end;
  Result := AddPointerOffset(Images, I * SizeOf(TSpaceImageGI));
end;
{ @end $479120 }

{ @routine $479228 TSpaceImgGI_AddImage }
function TSpaceImgGI.AddImage(TemplateIndex: Integer; X, Y, Depth: Single): PSpaceImageGI;
var Image: PSpaceImageGI; Data: TCGaiEC;
begin
  Image := AllocateImage(Depth);
  Image.TemplateIndex := TemplateIndex mod (High(SpaceImageTemplates) + 1);
  Image.X := X;
  Image.Y := Y;
  Image.Depth := Depth;
  Image.InverseDepth := 1.0 / Depth;
  Data := AcquireCachedGai(TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl));
  try
    Image.ImageSize := Data.GetCanvasSize;
    Image.ImageOffset := HalfPoint(Image.ImageSize);
    Image.FrameIndex := RandomIntRange(0, Data.GetSequenceFrameCount(0) - 1);
    Image.FrameTicks := Round(Data.GetSequenceFrameDelay(0, Image.FrameIndex) / 10.0);
  finally
    TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl).Release;
  end;
  Image.Unknown38 := MakeVector3D(0, 0, 0);
  Image.Unknown70 := 0;
  Image.OrbitAngleRadians := 0;
  Image.OrbitRadius := 0;
  Image.OrbitCenter := MakeVector3D(0, 0, 0);
  Image.OrbitStepDegrees := 0;
  ViewDirty := True;
  Result := Image;
end;
{ @end $479228 }

{ @routine $4793F4 TSpaceImgGI_NearestImageDistance }
function TSpaceImgGI.NearestImageDistance(X, Y: Single): Single;
var I: Integer; Image: PSpaceImageGI; DistanceSquared: Single;
begin
  Result := 1e10;
  Image := Images;
  for I := 0 to ImageCount - 1 do
  begin
    DistanceSquared := Sqr(X - Image.X) + Sqr(Y - Image.Y);
    if DistanceSquared < Result then Result := DistanceSquared;
    Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
  end;
  Result := Sqrt(Result);
end;
{ @end $4793F4 }

{ @routine $479498 TSpaceImgGI_UpdateImageOrbitAndFrame }
procedure TSpaceImgGI.UpdateImageOrbitAndFrame(Image: PSpaceImageGI);
var Data: TCGaiEC;
begin
  Image.OrbitRadius := Sqrt(Sqr(Image.X - Image.OrbitCenter.X) + Sqr(Image.Y - Image.OrbitCenter.Y));
  if Image.OrbitRadius = 0 then Image.OrbitAngleRadians := 0
  else Image.OrbitAngleRadians := ArcTan2(Image.X - Image.OrbitCenter.X, -(Image.Y - Image.OrbitCenter.Y));
  Data := AcquireCachedGai(TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl));
  try
    Image.ImageSize := Data.GetCanvasSize;
    Image.ImageOffset := HalfPoint(Image.ImageSize);
    Image.FrameIndex := Image.FrameIndex mod Data.GetSequenceFrameCount(0);
    Image.FrameTicks := Round(Data.GetSequenceFrameDelay(0, Image.FrameIndex) / 10.0);
  finally
    TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl).Release;
  end;
end;
{ @end $479498 }

{ @routine $479610 TSpaceImgGI_ProjectImages }
procedure TSpaceImgGI.ProjectImages;
var I: Integer; Image: PSpaceImageGI;
begin
  if ImageCount < 1 then Exit;
  Image := Images;
  for I := 0 to ImageCount - 1 do
  begin
    Image.PixelPosition.X := AbsolutePosition.X + Integer(Round((Image.X - ViewPosition.X) * Image.InverseDepth));
    Image.PixelPosition.Y := AbsolutePosition.Y + Integer(Round((Image.Y - ViewPosition.Y) * Image.InverseDepth));
    Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
  end;
  ViewDirty := False;
end;
{ @end $479610 }

{ @routine $4796C4 TSpaceImgGI_GetImage }
function TSpaceImgGI.GetImage(Index: Integer): PSpaceImageGI;
begin
  Result := AddPointerOffset(Images, Index * SizeOf(TSpaceImageGI));
end;
{ @end $4796C4 }

{ @routine $4796F4 TSpaceImgGI_AnimateImages }
procedure TSpaceImgGI.AnimateImages(Timer: PCallbackTimerGI; UserData: Integer);
var Image: PSpaceImageGI; I: Integer; Data: TCGaiEC;
begin
  Image := Images;
  for I := 0 to ImageCount - 1 do
  begin
    Dec(Image.FrameTicks);
    if Image.FrameTicks <= 0 then
    begin
      Data := AcquireCachedGai(TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl));
      try
        Inc(Image.FrameIndex);
        if Data.GetSequenceFrameCount(0) <= Image.FrameIndex then Image.FrameIndex := 0;
        Image.FrameTicks := Round(Data.GetSequenceFrameDelay(0, Image.FrameIndex) / 10.0);
      finally
        TCGaiControlEC(SpaceImageTemplates[Image.TemplateIndex].CacheControl).Release;
      end;
    end;
    if (Image.OrbitRadius <> 0) and (Image.OrbitStepDegrees <> 0) then
    begin
      Image.OrbitAngleRadians := (3.1415926 / 180) * Image.OrbitStepDegrees + Image.OrbitAngleRadians;
      Image.X := Sin(Image.OrbitAngleRadians) * Image.OrbitRadius + Image.OrbitCenter.X;
      Image.Y := Image.OrbitCenter.Y - Cos(Image.OrbitAngleRadians) * Image.OrbitRadius;
    end;
    Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
  end;
  ProjectImages;
end;
{ @end $4796F4 }

{ @routine $4798AC TSpaceImgGI_SetViewPosition }
procedure TSpaceImgGI.SetViewPosition(Position: TPointF);
begin
  if (ViewPosition.X <> Position.X) or (ViewPosition.Y <> Position.Y) then
  begin
    Invalidate;
    ViewPosition := Position;
    ViewDirty := True;
    ProjectImages;
    Invalidate;
  end;
end;
{ @end $4798AC }

{ @routine $479928 TSpaceImgGI_Invalidate }
procedure TSpaceImgGI.Invalidate;
var Image: PSpaceImageGI; I: Integer; Bounds: TRect;
begin
  Image := Images;
  for I := 0 to ImageCount - 1 do
  begin
    Bounds.Left := Image.PixelPosition.X + Image.ImageOffset.X;
    Bounds.Top := Image.PixelPosition.Y + Image.ImageOffset.Y;
    Bounds.Right := Bounds.Left + Image.ImageSize.X;
    Bounds.Bottom := Bounds.Top + Image.ImageSize.Y;
    MessageLoop.QueueUpdateRect(Bounds);
    Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
  end;
end;
{ @end $479928 }

{ @routine $4799BC TSpaceImgGI_OnActivate }
procedure TSpaceImgGI.OnActivate;
begin
  inherited OnActivate;
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(10, 10, AnimateImages);
end;
{ @end $4799BC }

{ @routine $479A24 TSpaceImgGI_OnDeactivate }
procedure TSpaceImgGI.OnDeactivate;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  inherited OnDeactivate;
end;
{ @end $479A24 }

{ @routine $479A64 TSpaceImgGI_LoadFromConfigPath }
procedure TSpaceImgGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadSpaceImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $479A64 }

{ @routine $479A98 TSpaceImgGI_LoadFromBlock }
procedure TSpaceImgGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadSpaceImageProperties(Block);
end;
{ @end $479A98 }

{ @routine $479AC0 TSpaceImgGI_LoadSpaceImageProperties }
procedure TSpaceImgGI.LoadSpaceImageProperties(Block: TBlockParEC);
begin
end;
{ @end $479AC0 }

{ @routine $479AD0 TSpaceImgGI_UpdateAutoGeometry }
procedure TSpaceImgGI.UpdateAutoGeometry;
begin
end;
{ @end $479AD0 }

{ @routine $479ADC TSpaceImgGI_Draw }
procedure TSpaceImgGI.Draw(ClipRect: TRect);
var Image: PSpaceImageGI; I: Integer; Data: TCGaiEC; Frame: TgiGR;
    Origin: TPoint; Bounds, Intersection: TRect;
begin
  for I := 0 to High(SpaceImageTemplates) do SpaceImageTemplates[I].CachedData := nil;
  try
    for I := 0 to High(SpaceImageTemplates) do
      SpaceImageTemplates[I].CachedData := AcquireCachedGai(TCGaiControlEC(SpaceImageTemplates[I].CacheControl));
    Image := Images;
    for I := 0 to ImageCount - 1 do
    begin
      Bounds.Left := Image.PixelPosition.X + Image.ImageOffset.X;
      Bounds.Top := Image.PixelPosition.Y + Image.ImageOffset.Y;
      Bounds.Right := Bounds.Left + Image.ImageSize.X;
      Bounds.Bottom := Bounds.Top + Image.ImageSize.Y;
      if IntersectRects(Intersection, Bounds, ClipRect) then
      begin
        Data := TCGaiEC(SpaceImageTemplates[Image.TemplateIndex].CachedData);
        Frame := Data.LoadFrameGi(Data.GetSequenceFrameIndex(0, Image.FrameIndex));
        if HardwareRenderingEnabled then
        begin
          Data.GetOrCreateFrameSurface(Data.GetSequenceFrameIndex(0, Image.FrameIndex));
          Origin := Data.GetFrameOrigin(Data.GetSequenceFrameIndex(0, Image.FrameIndex));
          DrawTexture(Data.GetOrCreateFrameSurface(Data.GetSequenceFrameIndex(0, Image.FrameIndex)),
            Bounds.Left + Origin.X, Bounds.Top + Origin.Y, 255, $FFFFFF, @ClipRect, False, False);
        end
        else
          Frame.DrawToGraphBuf(ScreenRenderBuffer,
            Bounds.Left + Frame.GetBoundsRect.Left - Data.GetBoundsRect.Left,
            Bounds.Top + Frame.GetBoundsRect.Top - Data.GetBoundsRect.Top, ClipRect, 0, 255);
      end;
      Image := AddPointerOffset(Image, SizeOf(TSpaceImageGI));
    end;
  finally
    for I := 0 to High(SpaceImageTemplates) do
      if TCGaiEC(SpaceImageTemplates[I].CachedData) <> nil then
      begin
        TCGaiControlEC(SpaceImageTemplates[I].CacheControl).Release;
        SpaceImageTemplates[I].CachedData := nil;
      end;
  end;
end;
{ @end $479ADC }

end.
