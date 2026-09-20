unit EC_CacheGI;
// Unit bracket (inferred): .text 0x004787EC..0x0047AE16; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, GR_gi, Types, Direct3D9;

type
  TCGiControlEC = class;
  TCGiEC = class;

  TCGiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4788F4
    function CreateData: TCacheDataEC; override; // @addr 0x478978
    function AcquireData: TCacheDataEC; override; // @addr 0x4789C4
  end;

  TCGiEC = class(TCacheDataEC) // @size 0x34
  public
    Image: TgiGR; // @offset 0x20
    SurfaceCache: TTextureGR; // @offset 0x24
    UsesTiledSurfaces: Boolean; // @offset 0x28
    TileOrigins: array of TPoint; // @offset 0x2C
    TileCount: Integer; // @offset 0x30
    // TileCount is zero for a single surface.

    constructor Create; // @addr 0x4789E0
    destructor Destroy; override; // @addr 0x478A4C
    function GetTileOrigin(TileIndex: Integer): TPoint; // @addr 0x478AD0
    function GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9; // @addr 0x478B24 @note "Caches the last requested surface at index zero; non-square tile grids use an incorrect stride."
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x478ECC @note "May modify SourceBuffer for resource-specific layout fixups. Ignores LoadOption."
    procedure ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x479144 @note "Modifies SourceBuffer in place."
  end;

function AcquireCachedGi(Control: TCacheControlEC): TCGiEC; // @addr 0x478998

// Nested helpers of ApplyWideScreenLayoutFixups. ParentFrame is the compiler's
// hidden, caller-popped stack argument, not an ordinary Delphi source parameter.

implementation

uses EC_Mem, EC_Str, GR_Main, Windows, Math;

{ @routine $4788F4 TCGiControlEC_QueueLoadIfMissing }
procedure TCGiControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCGiControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCGiEC) = nil then
  begin
    Control := TCGiControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $4788F4 }

{ @routine $478978 TCGiControlEC_CreateData }
function TCGiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGiEC.Create;
end;
{ @end $478978 }

{ @routine $478998 AcquireCachedGi }
function AcquireCachedGi(Control: TCacheControlEC): TCGiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGiEC) as TCGiEC;
end;
{ @end $478998 }

{ @routine $4789C4 TCGiControlEC_AcquireData }
function TCGiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGi(Self);
end;
{ @end $4789C4 }

{ @routine $4789E0 TCGiEC_Create }
constructor TCGiEC.Create;
begin
  inherited Create;
  Image := TgiGR.Create;
  SurfaceCache := nil; UsesTiledSurfaces := False; TileCount := 0;
end;
{ @end $4789E0 }

{ @routine $478A4C TCGiEC_Destroy }
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
{ @end $478A4C }

{ @routine $478AD0 TCGiEC_GetTileOrigin }
function TCGiEC.GetTileOrigin(TileIndex: Integer): TPoint;
begin
  Result := TileOrigins[TileIndex];
end;
{ @end $478AD0 }

{ @routine $478B24 TCGiEC_GetOrCreateSurface }
function TCGiEC.GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9;
var Texture: IDirect3DTexture9; ImageSize: TPoint; Locked: TD3DLockedRect;
  TileIndex, Columns, Rows, TileWidth, TileHeight, Column, Row: Integer; Origin: TPoint;

  // @nested $478B00 GiTileDivideRoundUp
  function GiTileDivideRoundUp(Value, Divisor: Integer): Integer; // @addr 0x478B00 @calls "0x00478BE7 0x00478BFD"
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
{ @end $478B24 }

{ @routine $478ECC TCGiEC_LoadFromConfigBuffer }
procedure TCGiEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  ApplyWideScreenLayoutFixups(SourceBuffer, CacheKey);
  Image.LoadRawGiFromBuffer(SourceBuffer);
  ResidentBytes := Image.DataSize;
end;
{ @end $478ECC }

{ @routine $479144 TCGiEC_ApplyWideScreenLayoutFixups }
procedure TCGiEC.ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString);
var
  WorkingImage: TgiGR;
  Quiet: Boolean;
  SourceGraph, DestGraph: TGraphBufGR;
  VerticalAlign, ImageWidth, ImageHeight: Integer;
  Header: PgiHeaderGR;
  HeaderBytes: Pointer;
  Delta, Remainder, ExtraHeight: Integer;
  PreserveAlpha: Boolean;

  // @nested $478F10 RenderGiBufferToGraphBuf
  procedure RenderGiBufferToGraphBuf(SourceBuffer: TBufEC; DestGraphBuf: TGraphBufGR); // @addr 0x478F10 @calls "0x004791E8 0x00479309 0x0047952D 0x00479727 0x004798A2 0x00479A24 0x00479D07 0x00479E70 0x0047A074 0x0047A24C 0x0047A33B 0x0047A494 0x0047A58C 0x0047A794 0x0047A9BB 0x0047AD3F"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.LoadRawGiFromBuffer(SourceBuffer);
    DestGraphBuf.AllocateRgbaTight(WorkingImage.GetContentSize.X, WorkingImage.GetContentSize.Y);
    WorkingImage.DecodeToGraphBuf(DestGraphBuf, False);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $478F94 StoreGraphBufAsRawGiBuffer
  procedure StoreGraphBufAsRawGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; StorageMode: Integer); // @addr 0x478F94 @calls "0x0047A2D9 0x0047A440 0x0047A524 0x0047ADC3"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFromGraphBuf(SourceGraphBuf, StorageMode);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $479004 StoreGraphBufAsGiBuffer
  procedure StoreGraphBufAsGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; TopLeft: TPoint); // @addr 0x479004 @calls "0x004792A1 0x004794A3 0x0047969D 0x00479818 0x00479990 0x00479C46 0x00479DAB 0x00479FE6 0x0047A1E9 0x0047A6CE 0x0047A8C5 0x0047A9FB 0x0047ADAF"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFormat2FromGraphBuf(SourceGraphBuf, TopLeft);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $47907C LogWideScreenGiRescaleStart
  procedure LogWideScreenGiRescaleStart; // @addr 0x47907C @calls "0x004791CA 0x004792EB 0x0047950F 0x00479709 0x00479884 0x00479A06 0x00479CE9 0x00479E52 0x0047A056 0x0047A22E 0x0047A31D 0x0047A476 0x0047A56E 0x0047A776 0x0047A99D 0x0047AD21"
  begin
    if not Quiet then AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $479120 LogWideScreenGiRescaleDone
  procedure LogWideScreenGiRescaleDone; // @addr 0x479120 @calls "0x004792B8 0x004794BA 0x004796B4 0x0047982F 0x004799A7 0x00479C5D 0x00479DC2 0x00479FFD 0x0047A200 0x0047A2F0 0x0047A457 0x0047A53B 0x0047A6E5 0x0047A8DC 0x0047AA12 0x0047ADDA"
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
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, GameScreenHeight - DestGraph.Height - 1));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and (ResourceKey = 'Bm.FormMain2.2AnimMain') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, Max(Cardinal(GameScreenHeight), 768));
    Delta := (ExtraScreenWidth div 2 div 3) * 3;
    if Cardinal(GameScreenWidth) >= 1600 then Delta := Delta - 249;
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
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWin') then
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
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWinB') then
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
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormInfo3.' + GiResourceSuffix + 'BG') then
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
  end
  else if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormShop2.2bg') then
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
  end
  else if (ExtraScreenWidth > 0) and
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
  end
  else if (ExtraHeight > 0) and
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
  end
  else if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormGameSet2.' + GiResourceSuffix + 'Footer') then
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
  end
  else if (ResourceKey = 'Bm.FormIntro2.PanelTop') or (ResourceKey = 'Bm.FormEnd2.PanelTop') then
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
  end
  else if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormIntro2.PanelBottom') then
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
  end
  else if ResourceKey = 'Bm.FormEnd2.PanelBottom' then
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
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and (ResourceKey = 'Bm.FormPQuest2.2Panel') then
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
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0)) and
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
  end
  else if (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'WBbg') or
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
  end
  else
  begin
    VerticalAlign := 1;
    PreserveAlpha := FindTextOffsetW(ResourceKey, 'Alpha') > 0;
    repeat
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
           (FindTextOffsetW(ResourceKey, 'PirateBG') > 0))) then Break;
      if FindTextOffsetW(ResourceKey, 'Bm.FormRuins.') = 0 then
      begin
        if FindTextOffsetW(ResourceKey, 'BKbg') > 0 then
        begin
          VerticalAlign := 2;
          Break;
        end
        else if (FindTextOffsetW(ResourceKey, 'MCbg') > 0) or
           (FindTextOffsetW(ResourceKey, 'PBbg') > 0) or
           (FindTextOffsetW(ResourceKey, 'RCbg') > 0) or
           (FindTextOffsetW(ResourceKey, 'SBbg') > 0) or
           (FindTextOffsetW(ResourceKey, 'WBbg2') > 0) or
           ((FindTextOffsetW(ResourceKey, 'bg') > 0) and
            (FindTextOffsetW(ResourceKey, 'table') <= 0)) then Break;
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
        if (ImageWidth > 1024) or (ImageHeight > 768) then Break;
      end;
      if FindTextOffsetW(ResourceKey, 'Bm.FormLoad2.Shutter') <> 0 then Exit;
      PreserveAlpha := True;
      Quiet := True;
    until True;
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    Delta := SourceGraph.Width;
    Remainder := SourceGraph.Height;
    SourceGraph.RescaleRGBA_HW(GameScreenWidth, GameScreenHeight, True, 1, VerticalAlign);
    if (Delta <> SourceGraph.Width) or (Remainder <> SourceGraph.Height) then
    begin
      if PreserveAlpha then
        StoreGraphBufAsGiBuffer(SourceBuffer, SourceGraph, Classes.Point(0, 0))
      else StoreGraphBufAsRawGiBuffer(SourceBuffer, SourceGraph, 1);
    end;
    SourceGraph.Clear;
    SourceGraph.Free;
    LogWideScreenGiRescaleDone;
  end;
end;
{ @end $479144 }

end.
