unit EC_CacheGI;
// Unit bracket (inferred): .text 0x0047FC10..0x0048223A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, GR_gi, Types, Direct3D9;

type
  TCGiControlEC = class;
  TCGiEC = class;

  TCGiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47FD18
    function CreateData: TCacheDataEC; override; // @addr 0x47FD9C
    function AcquireData: TCacheDataEC; override; // @addr 0x47FDE8
  end;

  TCGiEC = class(TCacheDataEC) // @size 0x34
  public
    Image: TgiGR; // @offset 0x20
    SurfaceCache: TTextureGR; // @offset 0x24
    UsesTiledSurfaces: Boolean; // @offset 0x28
    TileOrigins: array of TPoint; // @offset 0x2C
    TileCount: Integer; // @offset 0x30
    // TileCount is zero for a single surface.

    constructor Create; // @addr 0x47FE04 @ida "TCGiEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47FE70 @ida "void __usercall $name(TCGiEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetTileOrigin(TileIndex: Integer): TPoint; // @addr 0x47FEF4 @ida "void __usercall $name(TCGiEC *Self@<eax>, int TileIndex@<edx>, TPoint *Result@<ecx>);"
    function GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9; // @addr 0x47FF48 @ida "void __usercall $name(TCGiEC *Self@<eax>, int SurfaceIndex@<edx>, IDirect3DTexture9 **Result@<ecx>);" @note "Caches the last requested surface at index zero; non-square tile grids use an incorrect stride."
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4802F0 @note "May modify SourceBuffer for resource-specific layout fixups. Ignores LoadOption."
    procedure ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x480568 @note "Modifies SourceBuffer in place."
  end;

function AcquireCachedGi(Control: TCacheControlEC): TCGiEC; // @addr 0x47FDBC

// Nested helpers of ApplyWideScreenLayoutFixups. ParentFrame is the compiler's
// hidden, caller-popped stack argument, not an ordinary Delphi source parameter.

implementation

uses EC_Mem, EC_Str, GR_Main, Windows, Math;

{ @routine $47FD18 TCGiControlEC_QueueLoadIfMissing }
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
{ @end $47FD18 }

{ @routine $47FD9C TCGiControlEC_CreateData }
function TCGiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGiEC.Create;
end;
{ @end $47FD9C }

{ @routine $47FDBC AcquireCachedGi }
function AcquireCachedGi(Control: TCacheControlEC): TCGiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGiEC) as TCGiEC;
end;
{ @end $47FDBC }

{ @routine $47FDE8 TCGiControlEC_AcquireData }
function TCGiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGi(Self);
end;
{ @end $47FDE8 }

{ @routine $47FE04 TCGiEC_Create }
constructor TCGiEC.Create;
begin
  inherited Create;
  Image := TgiGR.Create;
  SurfaceCache := nil; UsesTiledSurfaces := False; TileCount := 0;
end;
{ @end $47FE04 }

{ @routine $47FE70 TCGiEC_Destroy }
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
{ @end $47FE70 }

{ @routine $47FEF4 TCGiEC_GetTileOrigin }
function TCGiEC.GetTileOrigin(TileIndex: Integer): TPoint;
begin
  Result := TileOrigins[TileIndex];
end;
{ @end $47FEF4 }

{ @routine $47FF48 TCGiEC_GetOrCreateSurface }
function TCGiEC.GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9;
var Texture: IDirect3DTexture9; ImageSize: TPoint; Locked: TD3DLockedRect;
  TileIndex, Columns, Rows, TileWidth, TileHeight, Column, Row: Integer; Origin: TPoint;

  // @nested $47FF24 GiTileDivideRoundUp
  function GiTileDivideRoundUp(Value, Divisor: Integer): Integer; // @addr 0x47FF24 @ida "int __usercall $name@<eax>(int Value@<eax>, int Divisor@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x0048000B 0x00480021"
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
{ @end $47FF48 }

{ @routine $4802F0 TCGiEC_LoadFromConfigBuffer }
procedure TCGiEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  ApplyWideScreenLayoutFixups(SourceBuffer, CacheKey);
  Image.LoadRawGiFromBuffer(SourceBuffer);
  ResidentBytes := Image.DataSize;
end;
{ @end $4802F0 }

{ @routine $480568 TCGiEC_ApplyWideScreenLayoutFixups }
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

  // @nested $480334 RenderGiBufferToGraphBuf
  procedure RenderGiBufferToGraphBuf(SourceBuffer: TBufEC; DestGraphBuf: TGraphBufGR); // @addr 0x480334 @ida "void __usercall $name(TBufEC *SourceBuffer@<eax>, TGraphBufGR *DestGraphBuf@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x0048060C 0x0048072D 0x00480951 0x00480B4B 0x00480CC6 0x00480E48 0x0048112B 0x00481294 0x00481498 0x00481670 0x0048175F 0x004818B8 0x004819B0 0x00481BB8 0x00481DDF 0x00482163"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.LoadRawGiFromBuffer(SourceBuffer);
    DestGraphBuf.AllocateRgbaTight(WorkingImage.GetContentSize.X, WorkingImage.GetContentSize.Y);
    WorkingImage.DecodeToGraphBuf(DestGraphBuf, False);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $4803B8 StoreGraphBufAsRawGiBuffer
  procedure StoreGraphBufAsRawGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; StorageMode: Integer); // @addr 0x4803B8 @ida "void __usercall $name(TBufEC *DestBuffer@<eax>, TGraphBufGR *SourceGraphBuf@<edx>, int StorageMode@<ecx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x004816FD 0x00481864 0x00481948 0x004821E7"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFromGraphBuf(SourceGraphBuf, StorageMode);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $480428 StoreGraphBufAsGiBuffer
  procedure StoreGraphBufAsGiBuffer(DestBuffer: TBufEC; SourceGraphBuf: TGraphBufGR; TopLeft: TPoint); // @addr 0x480428 @ida "void __usercall $name(TBufEC *DestBuffer@<eax>, TGraphBufGR *SourceGraphBuf@<edx>, TPoint *TopLeft@<ecx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x004806C5 0x004808C7 0x00480AC1 0x00480C3C 0x00480DB4 0x0048106A 0x004811CF 0x0048140A 0x0048160D 0x00481AF2 0x00481CE9 0x00481E1F 0x004821D3"
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFormat2FromGraphBuf(SourceGraphBuf, TopLeft);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  // @nested $4804A0 LogWideScreenGiRescaleStart
  procedure LogWideScreenGiRescaleStart; // @addr 0x4804A0 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x004805EE 0x0048070F 0x00480933 0x00480B2D 0x00480CA8 0x00480E2A 0x0048110D 0x00481276 0x0048147A 0x00481652 0x00481741 0x0048189A 0x00481992 0x00481B9A 0x00481DC1 0x00482145"
  begin
    if not Quiet then AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $480544 LogWideScreenGiRescaleDone
  procedure LogWideScreenGiRescaleDone; // @addr 0x480544 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x004806DC 0x004808DE 0x00480AD8 0x00480C53 0x00480DCB 0x00481081 0x004811E6 0x00481421 0x00481624 0x00481714 0x0048187B 0x0048195F 0x00481B09 0x00481D00 0x00481E36 0x004821FE"
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
{ @end $480568 }

end.
