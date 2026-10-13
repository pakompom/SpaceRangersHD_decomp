unit GI_RotateImageGAI;

interface

uses Classes, EC_BlockPar, EC_CacheGAI, EC_CacheRotateBuf, GI_MessageLoop, GR_GraphBufPal, Types, Direct3D9, GR_DX;

type
  TRotateImageGaiGI = class(TObjectGI) // @size 0x1C4 @methodorder source
  public
    ImageCache: TCGaiControlEC; // @offset $120
    RotationCache: TCRotateBufControlEC; // @offset $124
    RotatedImage: TGraphBufPalGR; // @offset $128
    RenderedAngle: Byte; // @offset $12C
    Angle: Byte; // @offset $12D
    Alpha: Byte; // @offset $12E
    ImageDirty: Boolean; // @offset $12F
    RenderedFrameIndex: Integer; // @offset $130
    FrameIndex: Integer; // @offset $134
    FrameCount: Integer; // @offset $138
    FrameIndexTable: PInteger; // @offset $13C
    FrameDelayTable: PInteger; // @offset $140
    AnimationIndex: Integer; // @offset $144
    ImageSize: TPoint; // @offset $148
    Vertices: array[0..3] of TScreenVertexGR; // @offset $150
    FrameTexture: IDirect3DTexture9; // @offset $1C0

    destructor Destroy; override; // @addr $4B7400
    procedure Clear; override; // @addr $4B7470
    procedure ClearFrameSequence; // @addr $4B7914
    function GetFrameSourceIndex(Index: Integer): Integer; // @addr $4B796C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4B7994
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4B79C0
    procedure LoadImageProperties(Block: TBlockParEC); // @addr $4B79F8
    procedure Draw(ClipRect: TRect); override; // @addr $4B7D30
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $4B8520
    procedure SetAngle(Value: Byte); // @addr $4B74A4
    procedure SetAlpha(Value: Byte); // @addr $4B74C8
    procedure SetFrame(Value: Integer); // @addr $4B78F0
    constructor Create(Owner: TObjectGI); // @addr $4B7338
    procedure SetImage(Path: WideString; ImageSize, Pivot: TPoint); // @addr 0x004B74EC
    procedure UpdateAutoGeometry; override; // @addr 0x004B7BB4 @note "Diagnostic retains TgaiGI.AfterLoad, but this is TRotateImageGaiGI's geometry-update override."
  end;

implementation

uses EC_Struct, SysUtils, Math, EC_Cache, EC_Mem, GI_GAI, GI_Main, GR_Main, GR_GraphBuf, GR_gi, aMyFunction;

{ @routine $4B7338 TRotateImageGaiGI_Create }
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
{ @end $4B7338 }

{ @routine $4B7400 TRotateImageGaiGI_Destroy }
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
{ @end $4B7400 }

{ @routine $4B7470 TRotateImageGaiGI_Clear }
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
{ @end $4B7470 }

{ @routine $4B74A4 TRotateImageGaiGI_SetAngle }
procedure TRotateImageGaiGI.SetAngle(Value: Byte);
begin
  if Value = Angle then Exit;
  Angle := Value;
  ImageDirty := True;
  Invalidate;
end;
{ @end $4B74A4 }

{ @routine $4B74C8 TRotateImageGaiGI_SetAlpha }
procedure TRotateImageGaiGI.SetAlpha(Value: Byte);
begin
  if Value = Alpha then Exit;
  Alpha := Value;
  ImageDirty := True;
  Invalidate;
end;
{ @end $4B74C8 }

{ @routine $4B74EC TRotateImageGaiGI_SetImage }
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
{ @end $4B74EC }

{ @routine $4B78F0 TRotateImageGaiGI_SetFrame }
procedure TRotateImageGaiGI.SetFrame(Value: Integer);
begin
  if Value = FrameIndex then Exit;
  FrameIndex := Value;
  ImageDirty := True;
  Invalidate;
end;
{ @end $4B78F0 }

{ @routine $4B7914 TRotateImageGaiGI_ClearFrameSequence }
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
{ @end $4B7914 }

{ @routine $4B796C TRotateImageGaiGI_GetFrameSourceIndex }
function TRotateImageGaiGI.GetFrameSourceIndex(Index: Integer): Integer;
begin
  Result := ReadIntegerEC(AddPointerOffset(FrameIndexTable, Index * SizeOf(Integer)));
end;
{ @end $4B796C }

{ @routine $4B7994 TRotateImageGaiGI_LoadFromConfigPath }
procedure TRotateImageGaiGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B7994 }

{ @routine $4B79C0 TRotateImageGaiGI_LoadFromBlock }
procedure TRotateImageGaiGI.LoadFromBlock(Block: TBlockParEC);
begin
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
  ImageDirty := True;
end;
{ @end $4B79C0 }

{ @routine $4B79F8 TRotateImageGaiGI_LoadImageProperties }
procedure TRotateImageGaiGI.LoadImageProperties(Block: TBlockParEC);
begin
  if (Block.CountParams('Image') > 0) and (Block.CountParams('Size') > 0) and (Block.CountParams('Sme') > 0) then
    SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')), GetPointGI(Block.GetParam('Sme')));
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
  if Block.CountParams('Trans') > 0 then SetAlpha(StrToInt(Block.GetParam('Trans')));
end;
{ @end $4B79F8 }

{ @routine $4B7BB4 TRotateImageGaiGI_UpdateAutoGeometry }
procedure TRotateImageGaiGI.UpdateAutoGeometry;
var
  Data: TCGaiEC;
begin
  if AnimationIndex < 0 then Exit;
  ClearFrameSequence;
  if (ImageCache <> nil) and (ImageCache.CacheKey <> '') then
  begin
    Data := AcquireCachedGai(ImageCache);
    try
      if (AnimationIndex < 0) or (AnimationIndex >= Data.GetSequenceCount) then
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
{ @end $4B7BB4 }

{ @routine $4B7D30 TRotateImageGaiGI_Draw }
procedure TRotateImageGaiGI.Draw(ClipRect: TRect);
var
  Data: TCGaiEC;
  Rotation: TCRotateBufEC;
  FrameGi: TgiGR;
  IndexPlane, PalettePlane: PgiPlaneGR;
  Degrees, C, S, LeftX, RightX, TopY, BottomY, CenterX, CenterY: Single;
  OldClip: TRect;
begin
  if (HitTestBounds.Left + ClientSize.X < 0) or (HitTestBounds.Left - ClientSize.X div 2 > Integer(GameScreenWidth)) then Exit;
  if (HitTestBounds.Top + ClientSize.Y < 0) or (HitTestBounds.Top - ClientSize.Y div 2 > Integer(GameScreenHeight)) then Exit;
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
    Vertices[0].Color := (Alpha shl 24) or RgbWhite;
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
        RotatedImage.SetPalette(PColorRGBA(PAnsiChar(FrameGi.Data) + PalettePlane.DataOffset), PalettePlane.DataSize shr 2);
        Ex_OKGR_RotateBuf_Draw_BYTE(RotatedImage.Pixels, RotatedImage.PitchBytes,
          PAnsiChar(FrameGi.Data) + IndexPlane.DataOffset, FrameGi.GetContentSize.X,
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
{ @end $4B7D30 }

{ @routine $4B8520 TRotateImageGaiGI_QueueImageLoad }
procedure TRotateImageGaiGI.QueueImageLoad(PendingLoads: TList);
begin
  ImageCache.QueueLoadIfMissing(PendingLoads);
end;
{ @end $4B8520 }

end.
