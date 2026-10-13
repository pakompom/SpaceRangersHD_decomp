unit EC_CacheGI;

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, GR_gi, Types, Direct3D9;

type
  TCGiControlEC = class;
  TCGiEC = class;

  TCGiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048DBD8
    function CreateData: TCacheDataEC; override; // @addr 0x0048DC44
    function AcquireData: TCacheDataEC; override; // @addr 0x0048DC74
  end;

  TCGiEC = class(TCacheDataEC) // @size 0x34
  public
    Image: TgiGR; // @offset 0x20
    SurfaceCache: TTextureGR; // @offset 0x24
    UsesTiledSurfaces: Boolean; // @offset 0x28
    TileOrigins: array of TPoint; // @offset 0x2C
    TileCount: Integer; // @offset 0x30
    // TileCount is zero for a single surface.

    constructor Create; // @addr 0x0048DC7C
    destructor Destroy; override; // @addr 0x0048DCD0
    function GetTileOrigin(TileIndex: Integer): TPoint; // @addr 0x0048DD30
    function GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9; // @addr 0x0048DD54 @note "Caches the last requested surface at index zero; non-square tile grids use an incorrect stride."
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x0048E0A4 @note "May modify SourceBuffer for resource-specific layout fixups. Ignores LoadOption."
    procedure ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x0048E2D0 @note "Modifies SourceBuffer in place."
  end;

function AcquireCachedGi(Control: TCacheControlEC): TCGiEC; // @addr 0x0048DC54

implementation

uses EC_Mem, EC_Str, GR_Main, Windows, Math;

{ @routine $48DBD8 TCGiControlEC_QueueLoadIfMissing }
procedure TCGiControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCGiControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCGiEC) <> nil then Exit;
  Control := TCGiControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48DBD8 }

{ @routine $48DC44 TCGiControlEC_CreateData }
function TCGiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGiEC.Create;
end;
{ @end $48DC44 }

{ @routine $48DC54 AcquireCachedGi }
function AcquireCachedGi(Control: TCacheControlEC): TCGiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGiEC) as TCGiEC;
end;
{ @end $48DC54 }

{ @routine $48DC74 TCGiControlEC_AcquireData }
function TCGiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGi(Self);
end;
{ @end $48DC74 }

{ @routine $48DC7C TCGiEC_Create }
constructor TCGiEC.Create;
begin
  inherited Create;
  Image := TgiGR.Create;
  SurfaceCache := nil; UsesTiledSurfaces := False; TileCount := 0;
end;
{ @end $48DC7C }

{ @routine $48DCD0 TCGiEC_Destroy }
destructor TCGiEC.Destroy;
begin
  Image.Free;
  if SurfaceCache <> nil then
  begin
    FreeTextureCache(SurfaceCache); SurfaceCache := nil; UsesTiledSurfaces := False;
    SetLength(TileOrigins, 0); TileCount := 0;
  end;
  inherited Destroy;
end;
{ @end $48DCD0 }

{ @routine $48DD30 TCGiEC_GetTileOrigin }
function TCGiEC.GetTileOrigin(TileIndex: Integer): TPoint;
begin
  Result := TileOrigins[TileIndex];
end;
{ @end $48DD30 }

{ @routine $48DD54 TCGiEC_GetOrCreateSurface }
function TCGiEC.GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9;
var Texture: IDirect3DTexture9; ImageSize: TPoint; Locked: TD3DLockedRect;
  TileIndex, Columns, Rows, TileWidth, TileHeight, Column, Row: Integer; Origin: TPoint;

  // @nested $48DD44 GiTileDivideRoundUp
  function GiTileDivideRoundUp(Value, Divisor: Integer): Integer; // @addr 0x0048DD44 @calls "0x0048DE03,0x0048DE17"
  begin
    Result := (Divisor - 1 + Value) div Divisor;
  end;
begin
  if SurfaceCache = nil then SurfaceCache := CreateTextureCache;
  Texture := SurfaceCache.GetSurface(SurfaceIndex);
  if (Texture = nil) and (Image <> nil) and not UsesTiledSurfaces then
  begin
    ImageSize := Image.GetContentSize;
    if (ImageSize.X = 0) or (ImageSize.Y = 0) then
    begin
      Result := nil;
      Exit;
    end;
    if (MaxTextureSize.X < ImageSize.X) or (MaxTextureSize.Y < ImageSize.Y) then
    begin
      UsesTiledSurfaces := True;
      Columns := GiTileDivideRoundUp(ImageSize.X, MaxTextureSize.X);
      Rows := GiTileDivideRoundUp(ImageSize.Y, MaxTextureSize.Y);
      TileCount := Columns * Rows;
      SetLength(TileOrigins, TileCount);
      Row := 0;
      while Row < Rows do
      begin
        Column := 0;
        if MaxTextureSize.Y >= ImageSize.Y then TileHeight := ImageSize.Y
        else if (Row + 1) * MaxTextureSize.Y > ImageSize.Y then TileHeight := ImageSize.Y - MaxTextureSize.Y * Row
        else TileHeight := MaxTextureSize.Y;
        while Column < Columns do
        begin
          TileIndex := Row * Rows + Column;
          if MaxTextureSize.X >= ImageSize.X then TileWidth := ImageSize.X
          else if (Column + 1) * MaxTextureSize.X > ImageSize.X then TileWidth := ImageSize.X - MaxTextureSize.X * Column
          else TileWidth := MaxTextureSize.X;
          if (Image.Header.Format = 0) and (Image.Header.AlphaMask = 0) then
            Texture := GR_CreateTexture(TileWidth, TileHeight, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
          else Texture := GR_CreateTexture(TileWidth, TileHeight, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
          Origin := Classes.Point(MaxTextureSize.X * Column, MaxTextureSize.Y * Row);
          if Texture <> nil then
          begin
            Texture.LockRect(0, Locked, nil, 0);
            if Locked.Bits <> nil then
            begin
              Image.DecodeRawRegion(Locked.Bits, Locked.Pitch, Origin.X, Origin.Y, TileWidth, TileHeight, True);
              Texture.UnlockRect(0);
            end;
          end;
          SurfaceCache.SetSurface(Texture, TileIndex);
          TileOrigins[TileIndex] := Origin;
          Inc(Column);
        end;
        Inc(Row);
      end;
      Texture := SurfaceCache.GetSurface(SurfaceIndex);
    end
    else
    begin
      if (Image.Header.Format = 0) and (Image.Header.AlphaMask = 0) then
        Texture := GR_CreateTexture(ImageSize.X, ImageSize.Y, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
      else Texture := GR_CreateTexture(ImageSize.X, ImageSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
      if Texture <> nil then
      begin
        Texture.LockRect(0, Locked, nil, 0);
        if Locked.Bits <> nil then
        begin
          Image.DecodeToPixels(Locked.Bits, Locked.Pitch, ImageSize.X, ImageSize.Y, True);
          Texture.UnlockRect(0);
        end;
      end;
    end;
    SurfaceCache.SetSurface(Texture, 0);
  end;
  Result := Texture;
end;
{ @end $48DD54 }

{ @routine $48E0A4 TCGiEC_LoadFromConfigBuffer }
procedure TCGiEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  ApplyWideScreenLayoutFixups(SourceBuffer, CacheKey);
  Image.LoadRawGiFromBuffer(SourceBuffer);
  ResidentBytes := Image.DataSize;
end;
{ @end $48E0A4 }

{ @routine $48E2D0 TCGiEC_ApplyWideScreenLayoutFixups }
procedure TCGiEC.ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString);
label RescaleMatchedImage;
var
  WorkingImage: TgiGR;
  Quiet: Boolean;
  SourceGraph, DestGraph: TGraphBufGR;
  VerticalAlign, ImageWidth, ImageHeight: Integer;
  Header: PgiHeaderGR;
  HeaderBytes: Pointer;
  Delta, Remainder, ExtraHeight: Integer;
  PreserveAlpha: Boolean;

  // @nested $48E0CC RenderGiBufferToGraphBuf
  procedure RenderGiBufferToGraphBuf(SourceBuffer: TBufEC; DestGraphBuf: TGraphBufGR); // @addr 0x0048E0CC @calls "0x0048E374,0x0048E46A,0x0048E64A,0x0048E7E2,0x0048E915,0x0048EA47,0x0048ECCA,0x0048EE11,0x0048EFCA,0x0048F15A,0x0048F22D,0x0048F35A,0x0048F436,0x0048F602,0x0048F7E0,0x0048FB24"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.LoadRawGiFromBuffer(SourceBuffer);
    DestGraphBuf.AllocateRgbaTight(WorkingImage.GetContentSize.X, WorkingImage.GetContentSize.Y);
    WorkingImage.DecodeToGraphBuf(DestGraphBuf, False);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $48E13C StoreGraphBufAsRawGiBuffer
  procedure StoreGraphBufAsRawGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; StorageMode: Integer); // @addr 0x0048E13C @calls "0x0048F1D5,0x0048F30B,0x0048F3D8,0x0048FB8A"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFromGraphBuf(SourceGraphBuf, StorageMode);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $48E1A4 StoreGraphBufAsGiBuffer
  procedure StoreGraphBufAsGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; TopLeft: TPoint); // @addr 0x0048E1A4 @calls "0x0048E40C,0x0048E5D1,0x0048E769,0x0048E89C,0x0048E9C8,0x0048EC21,0x0048ED52,0x0048EF46,0x0048F0FD,0x0048F54A,0x0048F6F5,0x0048F818,0x0048FB77"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFormat2FromGraphBuf(SourceGraphBuf, TopLeft);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $48E208 LogWideScreenGiRescaleStart
  procedure LogWideScreenGiRescaleStart; // @addr 0x0048E208 @calls "0x0048E358,0x0048E44E,0x0048E62E,0x0048E7C6,0x0048E8F9,0x0048EA2B,0x0048ECAE,0x0048EDF5,0x0048EFAE,0x0048F13E,0x0048F211,0x0048F33E,0x0048F41A,0x0048F5E6,0x0048F7C4,0x0048FB08"
  begin
    if not Quiet then AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $48E2AC LogWideScreenGiRescaleDone
  procedure LogWideScreenGiRescaleDone; // @addr 0x0048E2AC @calls "0x0048E421,0x0048E5E6,0x0048E77E,0x0048E8B1,0x0048E9DD,0x0048EC36,0x0048ED67,0x0048EF5B,0x0048F112,0x0048F1EA,0x0048F320,0x0048F3ED,0x0048F55F,0x0048F70A,0x0048F82D,0x0048FB9F"
  begin
    if not Quiet then AppendLogLineThreadSafe('ok');
  end;
begin
  ExtraHeight := ExtraScreenHeight;
  if ExtraHeight < 0 then ExtraHeight := 0;
  Quiet := False;
  if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.PanelMain2.' + GiResourceSuffix + 'BG') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, 0, 0, SourceGraph,
      Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height), Classes.Rect(430, 0, 593, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, GameScreenHeight - Integer(DestGraph.Height) - 1));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and (ResourceKey = 'Bm.FormMain2.2AnimMain') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, Max(GameScreenHeight, 768));
    Delta := (ExtraScreenWidth div 2 div 3) * 3;
    if GameScreenWidth >= 1600 then Delta := Delta - 249;
    Remainder := ExtraHeight mod 3;
    if Remainder <> 0 then Remainder := 3 - Remainder;
    DestGraph.DrawNinePatch(0, 0, Delta, 0, SourceGraph,
      Classes.Rect(0, Remainder, 3, SourceGraph.Height), Classes.Rect(0, 0, 0, 765 - Remainder));
    DestGraph.DrawNinePatch(Delta, 0, 0, 0, SourceGraph,
      Classes.Rect(3, Remainder, SourceGraph.Width - 4, SourceGraph.Height), Classes.Rect(1005, 0, 0, 765 - Remainder));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWin') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := 3;
    Delta := (Min(ExtraScreenHeight, 250) div Delta) * Delta;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    Remainder := (Delta div 3 div 4) * 3;
    Delta := Delta - Remainder;
    DestGraph.DrawNinePatch(0, 0, DestGraph.Width, Delta + 530, SourceGraph,
      Classes.Rect(0, 0, SourceGraph.Width, 530), Classes.Rect(0, 380, 0, 147));
    DestGraph.DrawNinePatch(0, Delta + 530, DestGraph.Width, Remainder + 90, SourceGraph,
      Classes.Rect(0, 530, SourceGraph.Width, SourceGraph.Height), Classes.Rect(0, 0, 0, 87));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWinB') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := (Min(ExtraScreenHeight, 250) div 3 div 4) * 3;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    DestGraph.DrawNinePatch(0, 0, DestGraph.Width, DestGraph.Height, SourceGraph,
      Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height), Classes.Rect(0, 97, 0, 53));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormInfo3.' + GiResourceSuffix + 'BG') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := 3;
    Delta := (Min(ExtraScreenHeight, 432) div Delta) * Delta;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    DestGraph.DrawNinePatch(0, 0, DestGraph.Width, DestGraph.Height, SourceGraph,
      Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height), Classes.Rect(0, 449, 0, 148));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormShop2.2bg') then
  begin
    Delta := (ExtraScreenWidth div 198) * 198;
    if Delta > 198 then Delta := 198;
    if Delta <> 0 then
    begin
      LogWideScreenGiRescaleStart;
      SourceGraph := TGraphBufGR.Create(False);
      RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
      DestGraph := TGraphBufGR.Create(False);
      DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height);
      DestGraph.DrawNinePatch(0, 0, Delta div 2 + 226, 34, SourceGraph,
        Classes.Rect(0, 0, 226, 34), Classes.Rect(225, 0, 0, 0));
      DestGraph.DrawNinePatch(Delta div 2 + 226, 0, 0, 34, SourceGraph,
        Classes.Rect(226, 0, 0, 34), Classes.Rect(326, 0, 213, 0));
      DestGraph.DrawNinePatch(0, 34, 0, 354, SourceGraph,
        Classes.Rect(0, 34, 0, 388), Classes.Rect(218, 0, 548, 0));
      DestGraph.DrawNinePatch(0, 388, Delta div 2 + 226, 0, SourceGraph,
        Classes.Rect(0, 388, 226, 0), Classes.Rect(225, 0, 0, 0));
      DestGraph.DrawNinePatch(Delta div 2 + 226, 388, 0, 0, SourceGraph,
        Classes.Rect(226, 388, 0, 0), Classes.Rect(326, 0, 213, 0));
      SourceGraph.Clear;
      SourceGraph.Free;
      StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
      DestGraph.Clear;
      DestGraph.Free;
      LogWideScreenGiRescaleDone;
    end;
    Exit;
  end;
  if (ExtraScreenWidth > 0) and
    ((ResourceKey = 'Bm.FormShop2.2Fei') or (ResourceKey = 'Bm.FormShop2.2Gaal') or
     (ResourceKey = 'Bm.FormShop2.2Peleng') or (ResourceKey = 'Bm.FormShop2.2People')) then
  begin
    Delta := (ExtraScreenWidth div 198) * 198;
    if Delta > 198 then Delta := 198;
    if Delta <> 0 then
    begin
      LogWideScreenGiRescaleStart;
      SourceGraph := TGraphBufGR.Create(False);
      RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
      DestGraph := TGraphBufGR.Create(False);
      DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height);
      DestGraph.DrawNinePatch(0, 0, 0, 0, SourceGraph,
        Classes.Rect(0, 0, 0, 0), Classes.Rect(121, 0, 483, 0));
      SourceGraph.Clear;
      SourceGraph.Free;
      StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
      DestGraph.Clear;
      DestGraph.Free;
      LogWideScreenGiRescaleDone;
    end;
    Exit;
  end;
  if (ExtraHeight > 0) and
    ((ResourceKey = 'Bm.FormOptions2.' + GiResourceSuffix + 'Left') or
     (ResourceKey = 'Bm.FormOptions2.' + GiResourceSuffix + 'Right')) then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(SourceGraph.Width, ExtraScreenHeight + SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, 37, DestGraph.Height, SourceGraph,
      Classes.Rect(0, 0, 37, SourceGraph.Height), Classes.Rect(0, 324, 0, 338));
    DestGraph.DrawNinePatch(37, 0, 193, DestGraph.Height, SourceGraph,
      Classes.Rect(37, 0, 230, SourceGraph.Height), Classes.Rect(0, 280, 0, 375));
    DestGraph.DrawNinePatch(230, 0, 513, DestGraph.Height, SourceGraph,
      Classes.Rect(230, 0, 743, SourceGraph.Height), Classes.Rect(0, 325, 0, 337));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormGameSet2.' + GiResourceSuffix + 'Footer') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, ExtraScreenWidth div 2 + 342, 0, SourceGraph,
      Classes.Rect(0, 0, 342, 0), Classes.Rect(341, 0, 0, 0));
    DestGraph.CopyRect32(Classes.Point(ExtraScreenWidth div 2 + 342, 0), SourceGraph,
      Classes.Rect(342, 0, 682, SourceGraph.Height));
    DestGraph.DrawNinePatch(ExtraScreenWidth div 2 + 682, 0, ExtraScreenWidth div 2 + 342, 0, SourceGraph,
      Classes.Rect(682, 0, 0, 0), Classes.Rect(0, 0, 341, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ResourceKey = 'Bm.FormIntro2.PanelTop') or (ResourceKey = 'Bm.FormEnd2.PanelTop') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, 0, 0, SourceGraph,
      Classes.Rect(0, 0, 0, 0), Classes.Rect(0, 0, 0, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormIntro2.PanelBottom') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, ExtraScreenWidth div 2 + 302, 0, SourceGraph,
      Classes.Rect(0, 0, 302, 0), Classes.Rect(301, 0, 0, 0));
    DestGraph.DrawNinePatch(ExtraScreenWidth div 2 + 302, 0, 0, 0, SourceGraph,
      Classes.Rect(302, 0, 0, 0), Classes.Rect(420, 0, 301, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if ResourceKey = 'Bm.FormEnd2.PanelBottom' then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(0, 0, 0, 0, SourceGraph,
      Classes.Rect(0, 0, 0, 0), Classes.Rect(0, 0, 154, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and (ResourceKey = 'Bm.FormPQuest2.2Panel') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, GameScreenHeight);
    Delta := 39 - ExtraScreenWidth;
    if Delta < 0 then Delta := 0;
    DestGraph.DrawNinePatch(0, ExtraScreenHeight div 2 + 492, 0, 0, SourceGraph,
      Classes.Rect(Delta, 492, 0, 0), Classes.Rect(302 - Delta, 0, 760, 275));
    DestGraph.DrawNinePatch(0, 0, 0, ExtraScreenHeight div 2 + 492, SourceGraph,
      Classes.Rect(Delta, 0, 0, 492), Classes.Rect(345 - Delta, 410, 717, 81));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and
    (((FindTextOffsetW(ResourceKey, 'Bm.FormPQuest2.2S') = 0) and
      IsIntegerTextW(CopyWideStringUnchecked(ResourceKey, 18, Length(ResourceKey) - 17))) or
     ((FindTextOffsetW(ResourceKey, 'Bm.FormPQuest2.') = 0) and
      (FindTextOffsetW(ResourceKey, 'rescale') > 0))) then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := ExtraScreenWidth - 39;
    if Delta < 0 then Delta := 0;
    DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height + ExtraHeight);
    DestGraph.DrawNinePatch(0, 0, 0, ExtraHeight div 2 + 500, SourceGraph,
      Classes.Rect(0, 0, 0, 500), Classes.Rect(289, 385, 289, 114));
    DestGraph.DrawNinePatch(0, ExtraHeight div 2 + 500, 0, 0, SourceGraph,
      Classes.Rect(0, 500, 0, 0), Classes.Rect(289, 0, 289, 206));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  if (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'WBbg') or
    (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'CBbg') or
    (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'DestroyerBridgebg') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    SourceGraph.RescaleRGBA_HW(GameScreenWidth, GameScreenHeight, True, 1, 1);
    StoreGraphBufAsGiBuffer(SourceBuffer, SourceGraph, Classes.Point(0, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    LogWideScreenGiRescaleDone;
    Exit;
  end;
  VerticalAlign := 1;
  PreserveAlpha := FindTextOffsetW(ResourceKey, 'Alpha') > 0;
  if (ResourceKey = 'Bm.FormAbout2.Bg') or (ResourceKey = 'Bm.FormGameSet2.2bg') or
     (ResourceKey = 'Bm.FormOptions2.2Bg') or (ResourceKey = 'Bm.FormScore2.2bg') or
     (FindTextOffsetW(ResourceKey, 'Bm.City.') = 0) or
     ((FindTextOffsetW(ResourceKey, 'Bm.Gov.') = 0) and
      ((FindTextOffsetW(ResourceKey, 'MalocBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'MalocPirateBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'PelengBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'PelengPirateBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'PeopleBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'PeoplePirateBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'FeiBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'FeiPirateBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'GaalBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'GaalPirateBG') > 0) or
       (FindTextOffsetW(ResourceKey, 'PirateBG') > 0))) then goto RescaleMatchedImage;
  if FindTextOffsetW(ResourceKey, 'Bm.FormRuins.') = 0 then
  begin
    if FindTextOffsetW(ResourceKey, 'BKbg') > 0 then
    begin
      VerticalAlign := 2;
      goto RescaleMatchedImage;
    end
    else if (FindTextOffsetW(ResourceKey, 'MCbg') > 0) or
       (FindTextOffsetW(ResourceKey, 'PBbg') > 0) or
       (FindTextOffsetW(ResourceKey, 'RCbg') > 0) or
       (FindTextOffsetW(ResourceKey, 'SBbg') > 0) or
       (FindTextOffsetW(ResourceKey, 'WBbg2') > 0) or
       ((FindTextOffsetW(ResourceKey, 'bg') > 0) and
        (FindTextOffsetW(ResourceKey, 'table') <= 0)) then goto RescaleMatchedImage;
  end;
  if FindTextOffsetW(ResourceKey, 'Bm.PlanetBG') = 0 then
  begin
    if SourceBuffer.DataSize < SizeOf(TgiHeaderGR) then Exit;
    HeaderBytes := AllocEC(SizeOf(TgiHeaderGR));
    CopyMemory(HeaderBytes, SourceBuffer.Data, SizeOf(TgiHeaderGR));
    Header := HeaderBytes;
    ImageWidth := Header.Bounds.Right - Header.Bounds.Left;
    ImageHeight := Header.Bounds.Bottom - Header.Bounds.Top;
    FreeEC(HeaderBytes);
    if (ImageWidth > 1024) or (ImageHeight > 768) then goto RescaleMatchedImage;
  end;
  if FindTextOffsetW(ResourceKey, 'Bm.FormLoad2.Shutter') <> 0 then Exit;
  PreserveAlpha := True;
  Quiet := True;
RescaleMatchedImage:
  LogWideScreenGiRescaleStart;
  SourceGraph := TGraphBufGR.Create(False);
  RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
  // Reuse the layout temporaries for the width and height before rescaling.
  Delta := SourceGraph.Width;
  Remainder := SourceGraph.Height;
  SourceGraph.RescaleRGBA_HW(GameScreenWidth, GameScreenHeight, True, 1, VerticalAlign);
  if (Delta <> Integer(SourceGraph.Width)) or (Remainder <> Integer(SourceGraph.Height)) then
  begin
    if PreserveAlpha then
      StoreGraphBufAsGiBuffer(SourceBuffer, SourceGraph, Classes.Point(0, 0))
    else StoreGraphBufAsRawGiBuffer(SourceBuffer, SourceGraph, 1);
  end;
  SourceGraph.Clear;
  SourceGraph.Free;
  LogWideScreenGiRescaleDone;
end;
{ @end $48E2D0 }

end.
