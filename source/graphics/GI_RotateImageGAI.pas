unit GI_RotateImageGAI;
// Unit bracket (inferred): .text 0x00496F40..0x00498448; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheGAI, EC_CacheRotateBuf, GI_MessageLoop, GR_GraphBufPal, Types, Direct3D9, GR_DX;

type
  TRotateImageGaiGI = class(TObjectGI) // @size 0x1C4
  public
    ImageCache: TCGaiControlEC; // @offset $120
    RotationCache: TCRotateBufControlEC; // @offset $124
    RotatedImage: TGraphBufPalGR; // @offset $128
    RenderedAngle: Byte; // @offset $12C
    RenderedFrameIndex: Integer; // @offset $130
    FrameIndexTable: PInteger; // @offset $13C
    FrameDelayTable: PInteger; // @offset $140
    ImageSize: TPoint; // @offset $148
    Vertices: array[0..3] of TScreenVertexGR; // @offset $150
    FrameTexture: IDirect3DTexture9; // @offset $1C0
    destructor Destroy; override; // @addr $49716C
    procedure Clear; override; // @addr $497200
    procedure ClearFrameSequence; // @addr $497750
    function GetFrameSourceIndex(Index: Integer): Integer; // @addr $4977C8
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $497800
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $497834
    procedure LoadImageProperties(Block: TBlockParEC); // @addr $497884
    procedure Draw(ClipRect: TRect); override; // @addr $497BE4
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $498428
    Angle: Byte; // @offset $12D
    Alpha: Byte; // @offset $12E
    ImageDirty: Boolean; // @offset $12F
    FrameIndex: Integer; // @offset $134
    FrameCount: Integer; // @offset $138
    AnimationIndex: Integer; // @offset $144
    procedure SetAngle(Value: Byte); // @addr $497250
    procedure SetAlpha(Value: Byte); // @addr $497290
    procedure SetFrame(Value: Integer); // @addr $497710
    constructor Create(Owner: TObjectGI); // @addr $497078
    procedure SetImage(Path: WideString; ImageSize, Pivot: TPoint); // @addr 0x4972D0
    procedure UpdateAutoGeometry; override; // @addr 0x497A4C @note "Diagnostic retains TgaiGI.AfterLoad, but this is TRotateImageGaiGI's geometry-update override."
  end;

implementation

uses EC_Struct, SysUtils, Math, EC_Cache, EC_Mem, GI_GAI, GI_Main, GR_Main, GR_GraphBuf, GR_gi, aMyFunction;

{ @routine $497078 TRotateImageGaiGI_Create }
constructor TRotateImageGaiGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageCache := TCGaiControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
  RotationCache := TCRotateBufControlEC.Create;
  GlobalCache.ResetControl(RotationCache);
  RotatedImage := TGraphBufPalGR.Create;
  RenderedAngle := 0;
  Angle := 0;
  Alpha := 255;
  ImageDirty := True;
  AnimationIndex := -1;
  FrameTexture := nil;
end;
{ @end $497078 }

{ @routine $49716C TRotateImageGaiGI_Destroy }
destructor TRotateImageGaiGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  RotationCache.Free;
  RotationCache := nil;
  RotatedImage.Free;
  RotatedImage := nil;
  FrameTexture := nil;
  ClearFrameSequence;
  inherited Destroy;
end;
{ @end $49716C }

{ @routine $497200 TRotateImageGaiGI_Clear }
procedure TRotateImageGaiGI.Clear;
begin
  RenderedFrameIndex := 0;
  FrameIndex := 0;
  ImageDirty := True;
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited Clear;
end;
{ @end $497200 }

{ @routine $497250 TRotateImageGaiGI_SetAngle }
procedure TRotateImageGaiGI.SetAngle(Value: Byte);
begin
  if Value <> Angle then
  begin
    Angle := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $497250 }

{ @routine $497290 TRotateImageGaiGI_SetAlpha }
procedure TRotateImageGaiGI.SetAlpha(Value: Byte);
begin
  if Value <> Alpha then
  begin
    Alpha := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $497290 }

{ @routine $4972D0 TRotateImageGaiGI_SetImage }
procedure TRotateImageGaiGI.SetImage(Path: WideString; ImageSize, Pivot: TPoint);
var
  Data: TCGaiEC;
  Radius: Double;
begin
  RenderedFrameIndex := 0;
  ImageCache.SetCacheKey(Path);
  Data := AcquireCachedGai(ImageCache);
  try
    try
      RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' +
        IntToStr(Data.GetCanvasSize.X) + ',' + IntToStr(Data.GetCanvasSize.Y) + ',' + IntToStr(Pivot.X) + ',' + IntToStr(Pivot.Y));
    except
      raise Exception.Create('Error in TRotateImageGaiGI.SetImage');
    end;
    Self.ImageSize := ImageSize;
    Radius := SquaredDistanceToPoint(Pivot, 0, 0);
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, ImageSize.X, ImageSize.Y));
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, ImageSize.X, 0));
    Radius := Max(Radius, SquaredDistanceToPoint(Pivot, 0, ImageSize.Y));
    Radius := Floor(Sqrt(Radius) * 2.0 + 2.0);
    SetSize(Classes.Point(Trunc(Radius), Trunc(Radius)));
    SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
    if (RotatedImage.Width <> ClientSize.X) or (RotatedImage.Height <> ClientSize.Y) then
      RotatedImage.AllocateBuffer(ClientSize.X, ClientSize.Y, 256, ClientSize.X);
    ImageDirty := True;
  finally
    ImageCache.Release;
  end;
  Invalidate;
end;
{ @end $4972D0 }

{ @routine $497710 TRotateImageGaiGI_SetFrame }
procedure TRotateImageGaiGI.SetFrame(Value: Integer);
begin
  if Value <> FrameIndex then
  begin
    FrameIndex := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $497710 }

{ @routine $497750 TRotateImageGaiGI_ClearFrameSequence }
procedure TRotateImageGaiGI.ClearFrameSequence;
begin
  if FrameIndexTable <> nil then
  begin
    FreeFromHeapEC(GaiFrameHeap, FrameIndexTable);
    FrameIndexTable := nil;
  end;
  if FrameDelayTable <> nil then
  begin
    FreeFromHeapEC(GaiFrameHeap, FrameDelayTable);
    FrameDelayTable := nil;
  end;
  RenderedFrameIndex := 0;
  FrameCount := 0;
end;
{ @end $497750 }

{ @routine $4977C8 TRotateImageGaiGI_GetFrameSourceIndex }
function TRotateImageGaiGI.GetFrameSourceIndex(Index: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(FrameIndexTable, Index * SizeOf(Integer)));
end;
{ @end $4977C8 }

{ @routine $497800 TRotateImageGaiGI_LoadFromConfigPath }
procedure TRotateImageGaiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $497800 }

{ @routine $497834 TRotateImageGaiGI_LoadFromBlock }
procedure TRotateImageGaiGI.LoadFromBlock(Block: TBlockParEC);
begin
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
  ImageDirty := True;
end;
{ @end $497834 }

{ @routine $497884 TRotateImageGaiGI_LoadImageProperties }
procedure TRotateImageGaiGI.LoadImageProperties(Block: TBlockParEC);
begin
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) and (Block.CountParams('Sme') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')), GetPointGI(Block.GetParam('Sme')));
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
  if Block.CountParams('Trans') > 0 then SetAlpha(StrToInt(Block.GetParam('Trans')));
end;
{ @end $497884 }

{ @routine $497A4C TRotateImageGaiGI_UpdateAutoGeometry }
procedure TRotateImageGaiGI.UpdateAutoGeometry;
var
  Data: TCGaiEC;
begin
  if AnimationIndex >= 0 then
  begin
    ClearFrameSequence;
    if (ImageCache <> nil) and (ImageCache.CacheKey <> '') then
    begin
      Data := AcquireCachedGai(ImageCache);
      try
        if (AnimationIndex < 0) or (Data.GetSequenceCount <= AnimationIndex) then
          raise Exception.Create('TgaiGI.AfterLoad. Anim not found.');
        FrameCount := Data.GetSequenceFrameCount(AnimationIndex);
        FrameIndexTable := ReAllocFromHeapREC(GaiFrameHeap, FrameIndexTable, FrameCount * SizeOf(Integer));
        FrameDelayTable := ReAllocFromHeapREC(GaiFrameHeap, FrameDelayTable, FrameCount * SizeOf(Integer));
        Data.FillSequenceFrameIndexTable(AnimationIndex, FrameIndexTable, SizeOf(Integer));
        Data.FillSequenceFrameDelayTable(AnimationIndex, FrameDelayTable, SizeOf(Integer));
      finally
        ImageCache.Release;
      end;
    end;
  end;
end;
{ @end $497A4C }

{ @routine $497BE4 TRotateImageGaiGI_Draw }
procedure TRotateImageGaiGI.Draw(ClipRect: TRect);
var
  Data: TCGaiEC;
  Rotation: TCRotateBufEC;
  FrameGi: TgiGR;
  IndexPlane, PalettePlane: PgiPlaneGR;
  Degrees, C, S, LeftX, RightX, TopY, BottomY, CenterX, CenterY: Single;
  OldClip: TRect;
begin
  if (HitTestBounds.Left + ClientSize.X < 0) or (HitTestBounds.Left - ClientSize.X div 2 > GameScreenWidth) or
    (HitTestBounds.Top + ClientSize.Y < 0) or (HitTestBounds.Top - ClientSize.Y div 2 > GameScreenHeight) then Exit;
  if HardwareRenderingEnabled then
  begin
    if (RenderedAngle <> Angle) or (ImageDirty = True) or (FrameIndex <> RenderedFrameIndex) or (FrameTexture = nil) then
    begin
      ImageDirty := False;
      RenderedAngle := Angle;
      RenderedFrameIndex := FrameIndex;
      Data := nil;
      try
        Data := AcquireCachedGai(ImageCache);
        FrameTexture := Data.GetOrCreateFrameSurface(GetFrameSourceIndex(RenderedFrameIndex));
      finally
        if Data <> nil then ImageCache.Release;
      end;
    end;
    Vertices[0].Color := (Cardinal(Alpha) shl 24) or RgbWhite;
    Vertices[1].Color := Vertices[0].Color;
    Vertices[2].Color := Vertices[0].Color;
    Vertices[3].Color := Vertices[0].Color;
    Vertices[0].Z := 1.0; Vertices[1].Z := 1.0; Vertices[2].Z := 1.0; Vertices[3].Z := 1.0;
    Vertices[0].Rhw := 1.0; Vertices[1].Rhw := 1.0; Vertices[2].Rhw := 1.0; Vertices[3].Rhw := 1.0;
    Vertices[0].U := 0.0; Vertices[0].V := 0.0;
    Vertices[1].U := 1.0; Vertices[1].V := 0.0;
    Vertices[2].U := 1.0; Vertices[2].V := 1.0;
    Vertices[3].U := 0.0; Vertices[3].V := 1.0;
    LeftX := -ImageSize.X / 2;
    TopY := -ImageSize.Y / 2;
    RightX := ImageSize.X / 2;
    BottomY := ImageSize.Y / 2;
    CenterX := ClientSize.X / 2;
    CenterY := ClientSize.Y / 2;
    Degrees := Angle / 256 * 360;
    C := Cos((GamePi / 180) * Degrees);
    S := Sin((GamePi / 180) * Degrees);
    Vertices[0].X := LeftX * C - TopY * S + CenterX + HitTestBounds.Left;
    Vertices[0].Y := LeftX * S + TopY * C + CenterY + HitTestBounds.Top;
    Vertices[1].X := RightX * C - TopY * S + CenterX + HitTestBounds.Left;
    Vertices[1].Y := RightX * S + TopY * C + CenterY + HitTestBounds.Top;
    Vertices[2].X := RightX * C - BottomY * S + CenterX + HitTestBounds.Left;
    Vertices[2].Y := RightX * S + BottomY * C + CenterY + HitTestBounds.Top;
    Vertices[3].X := LeftX * C - BottomY * S + CenterX + HitTestBounds.Left;
    Vertices[3].Y := LeftX * S + BottomY * C + CenterY + HitTestBounds.Top;
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(@ClipRect);
    Direct3DDevice.SetTexture(0, FrameTexture);
    Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Vertices, SizeOf(TScreenVertexGR));
    Direct3DDevice.SetTexture(0, nil);
    Direct3DDevice.SetScissorRect(@OldClip);
  end
  else
  begin
    if (RenderedAngle <> Angle) or (ImageDirty = True) or (FrameIndex <> RenderedFrameIndex) then
    begin
      ImageDirty := False;
      RenderedAngle := Angle;
      RenderedFrameIndex := FrameIndex;
      Data := nil;
      Rotation := nil;
      try
        Data := AcquireCachedGai(ImageCache);
        Rotation := AcquireOrCreateRotateBuf(RotationCache);
        RotatedImage.ClearPixels;
        FrameGi := Data.LoadFrameGi(GetFrameSourceIndex(RenderedFrameIndex));
        if FrameGi.GetFormat <> 4 then RaiseWideMessage('rotate GAI 1');
        if (FrameGi.GetContentSize.X <> Data.GetCanvasSize.X) or (FrameGi.GetContentSize.Y <> Data.GetCanvasSize.Y) then
          RaiseWideMessage('rotate GAI 2');
        IndexPlane := FrameGi.GetPlane(0);
        PalettePlane := FrameGi.GetPlane(1);
        RotatedImage.SetPalette(PColorRGBA(PAnsiChar(FrameGi.Data) + PalettePlane.DataOffset), Cardinal(PalettePlane.DataSize) shr 2);
        Ex_OKGR_RotateBuf_Draw_BYTE(RotatedImage.Pixels, RotatedImage.PitchBytes,
          Pointer(PAnsiChar(FrameGi.Data) + IndexPlane.DataOffset), FrameGi.GetContentSize.X,
          OriginPoint.X, OriginPoint.Y, Angle, Rotation.Buffer);
        { Native software alpha adjustment uses Pixels with a four-byte stride. }
        if Alpha <> 255 then
          Ex_OKGR_Light_BYTE(AddPointerOffset(RotatedImage.Pixels, 3), 4,
            RotatedImage.PitchBytes - RotatedImage.Width * 4, RotatedImage.Width, RotatedImage.Height, Alpha);
      finally
        if Data <> nil then ImageCache.Release;
        if Rotation <> nil then RotationCache.Release;
      end;
    end;
    DrawPaletteAlphaBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      HitTestBounds.Left, HitTestBounds.Top, RotatedImage, ClipRect);
  end;
end;
{ @end $497BE4 }

{ @routine $498428 TRotateImageGaiGI_QueueImageLoad }
procedure TRotateImageGaiGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $498428 }

end.
