unit GI_RotateImage5;
// Unit bracket (inferred): .text 0x004AF430..0x004B0FA1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_CacheHSAI, EC_CacheRotateBuf, GI_MessageLoop, GR_GraphBufPal, Types, Direct3D9, GR_DX;

type
  TRotateImage5GI = class(TObjectGI) // @size 0x21D4
  public
    ImageCache: TCHSAIControlEC; // @offset 0x120
    RotationCache: TCRotateBufControlEC; // @offset 0x124
    RotatedImage: TGraphBufPalGR; // @offset 0x128
    RenderedAngle: Byte; // @offset 0x12C
    RenderedFrameIndex: Cardinal; // @offset 0x130
    FrameIndex: Cardinal; // @offset 0x134
    Angle: Byte; // @offset 0x138
    Alpha: Byte; // @offset 0x139
    ImageDirty: Boolean; // @offset 0x13A
    Unknown13C: TObject; // @offset $13C  Optional owned object; purpose unresolved.
    Vertices: array[0..3] of TScreenVertexGR; // @offset 0x140
    FrameTexture: IDirect3DTexture9; // @offset 0x1B0
    // Native table spacing is 257 Singles; only the 256 byte-angle entries are initialized.
    TopLeftX: array[0..256] of Single; // @offset 0x1B4
    TopLeftY: array[0..256] of Single; // @offset 0x5B8
    TopRightX: array[0..256] of Single; // @offset 0x9BC
    TopRightY: array[0..256] of Single; // @offset 0xDC0
    BottomRightX: array[0..256] of Single; // @offset 0x11C4
    BottomRightY: array[0..256] of Single; // @offset 0x15C8
    BottomLeftX: array[0..256] of Single; // @offset 0x19CC
    BottomLeftY: array[0..256] of Single; // @offset 0x1DD0

    constructor Create(Owner: TObjectGI); // @addr 0x4AF568 @ida "TRotateImage5GI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4AF934 @ida "void __usercall $name(TRotateImage5GI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4AF9E4 @note "Preserves cache keys, image storage and FrameTexture."
    procedure SetAngle(Value: Byte); // @addr 0x4AFA34 @note "A full turn has 256 steps."
    procedure SetFrameIndex(Value: Cardinal); // @addr 0x4AFA74 @note "Does not validate against the frame count."
    procedure SetAlpha(Value: Byte); // @addr 0x4AFAB4
    procedure SetImage(Path: WideString; ImageSize, Pivot: TPoint); // @addr 0x4AFAF4 @ida "void __userpurge $name(TRotateImage5GI *Self@<eax>, unsigned __int16 *Path@<edx>, TPoint *ImageSize@<ecx>, TPoint *Pivot@<^0>);" @note "Replaces size and origin with a centered square enclosing all rotations."
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x4B01EC @ida "bool __usercall $name@<al>(TRotateImage5GI *Self@<eax>, TPoint *Point@<edx>);" @note "Uses the last rendered image. Alpha must exceed 8 in software, or 0 in hardware."
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4B0628
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4B065C
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x4B06AC
    procedure Draw(ClipRect: TRect); override; // @addr 0x4B0874 @ida "void __usercall $name(TRotateImage5GI *Self@<eax>, TRect *ClipRect@<edx>);"
    function GetFrameCount: Cardinal; // @addr 0x4B0EB8
    procedure QueueImagePath(PendingLoads: TList; Path: WideString); // @addr 0x4B0F20 @note "Queues an arbitrary HSAI path; does not change this object's image."
  end;

var
  RotateImageConstructionStage: Integer = -1; // @addr $87A6D4

implementation

uses SysUtils, Math, EC_Cache, EC_Str, GR_Main, GI_Main, GR_GraphBuf, EC_Mem;

{ @routine $4AF568 TRotateImage5GI_Create }
constructor TRotateImage5GI.Create(Owner: TObjectGI);
begin
  RotateImageConstructionStage := 0;
  try
    inherited Create(Owner);
    ImageDirty := True;
    RotateImageConstructionStage := 1;
    ImageCache := TCHSAIControlEC.Create;
    RotateImageConstructionStage := 2;
    GlobalCache.ResetControl(ImageCache);
    RotateImageConstructionStage := 3;
    RotationCache := TCRotateBufControlEC.Create;
    RotateImageConstructionStage := 4;
    GlobalCache.ResetControl(RotationCache);
    RotateImageConstructionStage := 5;
    RotatedImage := TGraphBufPalGR.Create;
    RotateImageConstructionStage := 6;
    RenderedAngle := 0;
    RenderedFrameIndex := 0;
    Angle := 0;
    FrameIndex := 0;
    Alpha := 255;
    ImageDirty := True;
    Unknown13C := nil;
    FrameTexture := nil;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('self=' + IntToStr(Cardinal(Self)));
      AppendLogLineThreadSafe('FGBC=' + IntToStr(Cardinal(ImageCache)));
      AppendLogLineThreadSafe('FRBC=' + IntToStr(Cardinal(RotationCache)));
      AppendLogLineThreadSafe('FIR=' + IntToStr(Cardinal(RotatedImage)));
      raise Exception.Create('Error in procedure TRotateImage5GI.Create, label = ' + IntToStr(RotateImageConstructionStage));
    end;
  end;
  RotateImageConstructionStage := -1;
end;
{ @end $4AF568 }

{ @routine $4AF934 TRotateImage5GI_Destroy }
destructor TRotateImage5GI.Destroy;
begin
  if Unknown13C <> nil then
  begin
    Unknown13C.Free;
    Unknown13C := nil;
  end;
  FrameTexture := nil;
  ImageCache.Free;
  ImageCache := nil;
  RotationCache.Free;
  RotationCache := nil;
  RotatedImage.Free;
  RotatedImage := nil;
  inherited Destroy;
end;
{ @end $4AF934 }

{ @routine $4AF9E4 TRotateImage5GI_Clear }
procedure TRotateImage5GI.Clear;
begin
  ImageDirty := True;
  RenderedAngle := 255;
  Angle := 0;
  RenderedFrameIndex := 0;
  FrameIndex := 0;
  Alpha := 255;
  inherited Clear;
end;
{ @end $4AF9E4 }

{ @routine $4AFA34 TRotateImage5GI_SetAngle }
procedure TRotateImage5GI.SetAngle(Value: Byte);
begin
  if Value <> Angle then
  begin
    Angle := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $4AFA34 }

{ @routine $4AFA74 TRotateImage5GI_SetFrameIndex }
procedure TRotateImage5GI.SetFrameIndex(Value: Cardinal);
begin
  if Value <> FrameIndex then
  begin
    FrameIndex := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $4AFA74 }

{ @routine $4AFAB4 TRotateImage5GI_SetAlpha }
procedure TRotateImage5GI.SetAlpha(Value: Byte);
begin
  if Value <> Alpha then
  begin
    Alpha := Value;
    ImageDirty := True;
    Invalidate;
  end;
end;
{ @end $4AFAB4 }

{ @routine $4AFAF4 TRotateImage5GI_SetImage }
procedure TRotateImage5GI.SetImage(Path: WideString; ImageSize, Pivot: TPoint);
var
  Data: TCHSAIEC;
  Radius: Double;
  I: Integer;
  Radians, C, S, LeftX, TopY, RightX, BottomY, CenterX, CenterY: Single;
begin
  ImageCache.SetCacheKey(Path);
  Data := AcquireCachedHSAI(ImageCache);
  try
    try
      RotationCache.SetCacheKey(IntToStr(ImageSize.X) + ',' + IntToStr(ImageSize.Y) + ',' +
        IntToStr(Data.Width) + ',' + IntToStr(Data.Height) + ',' + IntToStr(Pivot.X) + ',' + IntToStr(Pivot.Y));
    except
      raise Exception.Create('Error in TRotateImage5GI.SetImage');
    end;
    Radius := Sqr(Pivot.X - 0) + Sqr(Pivot.Y - 0);
    Radius := Max(Radius, Sqr(Pivot.X - ImageSize.X) + Sqr(Pivot.Y - ImageSize.Y));
    Radius := Max(Radius, Sqr(Pivot.X - ImageSize.X) + Sqr(Pivot.Y - 0));
    Radius := Max(Radius, Sqr(Pivot.X - 0) + Sqr(Pivot.Y - ImageSize.Y));
    Radius := Floor(Sqrt(Radius) * 2.0 + 2.0);
    SetSize(Classes.Point(Trunc(Radius), Trunc(Radius)));
    SetOrigin(Classes.Point(ClientSize.X div 2, ClientSize.Y div 2));
    if (RotatedImage.Width <> ClientSize.X) or (RotatedImage.Height <> ClientSize.Y) then
      RotatedImage.AllocateBuffer(ClientSize.X, ClientSize.Y, 256, ClientSize.X);
    LeftX := -Pivot.X;
    TopY := -Pivot.Y;
    RightX := ImageSize.X - Pivot.X - 1;
    BottomY := ImageSize.Y - Pivot.Y - 1;
    CenterX := ClientSize.X / 2.0;
    CenterY := ClientSize.Y / 2.0;
    for I := 0 to 255 do
    begin
      Radians := I / 256.0 * 360.0 * 3.1415926 / 180.0;
      C := Cos(Radians);
      S := Sin(Radians);
      TopLeftX[I] := Trunc(LeftX * C - TopY * S) + CenterX;
      TopLeftY[I] := Trunc(LeftX * S + TopY * C) + CenterY;
      TopRightX[I] := Trunc(RightX * C - TopY * S) + CenterX;
      TopRightY[I] := Trunc(RightX * S + TopY * C) + CenterY;
      BottomRightX[I] := Trunc(RightX * C - BottomY * S) + CenterX;
      BottomRightY[I] := Trunc(RightX * S + BottomY * C) + CenterY;
      BottomLeftX[I] := Trunc(LeftX * C - BottomY * S) + CenterX;
      BottomLeftY[I] := Trunc(LeftX * S + BottomY * C) + CenterY;
    end;
    ImageDirty := True;
  finally
    ImageCache.Release;
  end;
  Invalidate;
end;
{ @end $4AFAF4 }

{ @routine $4B01EC TRotateImage5GI_HitTestPixel }
function TRotateImage5GI.HitTestPixel(Point: TPoint): Boolean;
var
  Surface, OldSurface: IDirect3DSurface9;
  Texture: IDirect3DTexture9;
  Locked: TD3DLockedRect;
  Buffer: TGraphBufGR;
  Quad: array[0..3] of TScreenVertexGR;
begin
  Result := False;
  if inherited ContainsPoint(Point) then
  begin
    if HardwareRenderingEnabled then
    begin
      if FrameTexture <> nil then
      begin
        Quad[0] := Vertices[0];
        Quad[1] := Vertices[1];
        Quad[2] := Vertices[2];
        Quad[3] := Vertices[3];
        Quad[0].X := TopLeftX[RenderedAngle];
        Quad[0].Y := TopLeftY[RenderedAngle];
        Quad[1].X := TopRightX[RenderedAngle];
        Quad[1].Y := TopRightY[RenderedAngle];
        Quad[2].X := BottomRightX[RenderedAngle];
        Quad[2].Y := BottomRightY[RenderedAngle];
        Quad[3].X := BottomLeftX[RenderedAngle];
        Quad[3].Y := BottomLeftY[RenderedAngle];
        Direct3DDevice.CreateRenderTarget(ClientSize.X, ClientSize.Y, D3DFMT_A8R8G8B8, D3DMULTISAMPLE_NONE, 0, False, Surface, nil);
        Direct3DDevice.CreateTexture(ClientSize.X, ClientSize.Y, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, Texture, nil);
        if Surface <> nil then
        begin
          if Texture = nil then Surface := nil
          else
          begin
            Direct3DDevice.GetRenderTarget(0, OldSurface);
            Direct3DDevice.SetRenderTarget(0, Surface);
            Direct3DDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
            Direct3DDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
            Direct3DDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
            Direct3DDevice.Clear(0, nil, D3DCLEAR_TARGET, 0, 1.0, 0);
            Direct3DDevice.SetTexture(0, FrameTexture);
            Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TScreenVertexGR));
            Direct3DDevice.SetTexture(0, nil);
            Direct3DDevice.SetRenderTarget(0, OldSurface);
            Texture.GetSurfaceLevel(0, OldSurface);
            if Direct3DDevice.GetRenderTargetData(Surface, OldSurface) <> 0 then
              AppendLogLineThreadSafe('GetRenderTargetData fail');
            OldSurface := nil;
            Surface := nil;
            Texture.LockRect(0, Locked, nil, 0);
            if Locked.Bits <> nil then
            begin
              Buffer := TGraphBufGR.Create(False);
              Buffer.AttachPixels(ClientSize.X, ClientSize.Y, Locked.Pitch, Locked.Bits);
              Result := Buffer.GetPixel32(Point.X - HitTestBounds.Left, Point.Y - HitTestBounds.Top) > $FFFFFF;
              Buffer.Free;
            end;
            Texture := nil;
          end;
        end;
      end;
    end
    else
      Result := Byte(RotatedImage.GetPaletteColor(RotatedImage.GetPixelIndex(Point.X - HitTestBounds.Left, Point.Y - HitTestBounds.Top)) shr 24) > 8;
  end;
end;
{ @end $4B01EC }

{ @routine $4B0628 TRotateImage5GI_LoadFromConfigPath }
procedure TRotateImage5GI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B0628 }

{ @routine $4B065C TRotateImage5GI_LoadFromBlock }
procedure TRotateImage5GI.LoadFromBlock(Block: TBlockParEC);
begin
  RenderedAngle := 255;
  Angle := 0;
  Alpha := 255;
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
  ImageDirty := True;
end;
{ @end $4B065C }

{ @routine $4B06AC TRotateImage5GI_LoadImageProperties }
procedure TRotateImage5GI.LoadImageProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then
    if Block.CountParams('Size') > 0 then
      if Block.CountParams('Sme') > 0 then
        SetImage(Block.GetParam('Image'), GetPointGI(Block.GetParam('Size')), GetPointGI(Block.GetParam('Sme')));
  if Block.CountParams('Angle') > 0 then SetAngle(StrToInt(Block.GetParam('Angle')));
  if Block.CountParams('Trans') > 0 then SetAlpha(StrToInt(Block.GetParam('Trans')));
end;
{ @end $4B06AC }

{ @routine $4B0874 TRotateImage5GI_Draw }
procedure TRotateImage5GI.Draw(ClipRect: TRect);
var
  Data: TCHSAIEC;
  Rotation: TCRotateBufEC;
  OldClip: TRect;
begin
  if (HitTestBounds.Right < 0) or (HitTestBounds.Left > GameScreenWidth) or
     (HitTestBounds.Bottom < 0) or (HitTestBounds.Top > GameScreenHeight) then Exit;
  if HardwareRenderingEnabled then
  begin
    if (RenderedAngle <> Angle) or (ImageDirty = True) or
       (FrameIndex <> RenderedFrameIndex) or (FrameTexture = nil) then
    begin
      ImageDirty := False;
      RenderedAngle := Angle;
      RenderedFrameIndex := FrameIndex;
      Data := nil;
      try
        Data := AcquireCachedHSAI(ImageCache);
        FrameTexture := Data.GetOrCreateFrameSurface(RenderedFrameIndex);
      finally
        if Data <> nil then ImageCache.Release;
      end;
    end;
    Vertices[0].Color := (Cardinal(Alpha) shl 24) or $FFFFFF;
    Vertices[1].Color := Vertices[0].Color;
    Vertices[2].Color := Vertices[0].Color;
    Vertices[3].Color := Vertices[0].Color;
    Vertices[0].Z := 1.0; Vertices[1].Z := 1.0; Vertices[2].Z := 1.0; Vertices[3].Z := 1.0;
    Vertices[0].Rhw := 1.0; Vertices[1].Rhw := 1.0; Vertices[2].Rhw := 1.0; Vertices[3].Rhw := 1.0;
    Vertices[0].U := 0.0; Vertices[0].V := 0.0;
    Vertices[1].U := 1.0; Vertices[1].V := 0.0;
    Vertices[2].U := 1.0; Vertices[2].V := 1.0;
    Vertices[3].U := 0.0; Vertices[3].V := 1.0;
    Vertices[0].X := HitTestBounds.Left + TopLeftX[Angle];
    Vertices[0].Y := HitTestBounds.Top + TopLeftY[Angle];
    Vertices[1].X := HitTestBounds.Left + TopRightX[Angle];
    Vertices[1].Y := HitTestBounds.Top + TopRightY[Angle];
    Vertices[2].X := HitTestBounds.Left + BottomRightX[Angle];
    Vertices[2].Y := HitTestBounds.Top + BottomRightY[Angle];
    Vertices[3].X := HitTestBounds.Left + BottomLeftX[Angle];
    Vertices[3].Y := HitTestBounds.Top + BottomLeftY[Angle];
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
        Data := AcquireCachedHSAI(ImageCache);
        Rotation := AcquireOrCreateRotateBuf(RotationCache);
        RotatedImage.FillPixels(ReadByteEC(Data.GetFrameIndexPlane(RenderedFrameIndex)));
        RotatedImage.SetPalette(Data.GetFramePalette(RenderedFrameIndex), 256);
        Ex_OKGR_RotateBuf_Draw_BYTE(RotatedImage.Pixels, RotatedImage.PitchBytes,
          Data.GetFrameIndexPlane(RenderedFrameIndex), Data.GetSourcePitchBytes,
          OriginPoint.X, OriginPoint.Y, Angle, Rotation.Buffer);
        if Alpha <> 255 then
          Ex_OKGR_Light_BYTE(AddPointerOffset(RotatedImage.Palette, 3), 4, 1024, 256, 1, Alpha);
      finally
        if Data <> nil then ImageCache.Release;
        if Rotation <> nil then RotationCache.Release;
      end;
    end;
    DrawPaletteAlphaBuffer16Clipped(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      HitTestBounds.Left, HitTestBounds.Top, RotatedImage, ClipRect);
  end;
end;
{ @end $4B0874 }

{ @routine $4B0EB8 TRotateImage5GI_GetFrameCount }
function TRotateImage5GI.GetFrameCount: Cardinal;
var Data: TCHSAIEC;
begin
  Data := nil;
  try
    Data := AcquireCachedHSAI(ImageCache);
    Result := Data.GetFrameCount;
  finally
    if Data <> nil then ImageCache.Release;
  end;
end;
{ @end $4B0EB8 }

{ @routine $4B0F20 TRotateImage5GI_QueueImagePath }
procedure TRotateImage5GI.QueueImagePath(PendingLoads: TList; Path: WideString);
var Control: TCHSAIControlEC;
begin
  Control := TCHSAIControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(Path);
  Control.QueueLoadIfMissing(PendingLoads);
  Control.Free;
end;
{ @end $4B0F20 }

end.
