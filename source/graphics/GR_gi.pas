unit GR_gi;
// Unit bracket (inferred): .text 0x00476918..0x004787AC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct, GR_GraphBuf, Types;

type

  // Shared GI/GAI disk structures; ownership inferred from both readers and unit order.
  TGaiHeader = packed record // @size 0x30
    // +0x00..+0x07 and +0x24..+0x2F metadata remain unresolved.
    Bounds: TRect; // @offset 0x08
    FrameCount: Integer; // @offset 0x18
    Flags: Cardinal; // @offset 0x1C
    SequenceTableOffset: Integer; // @offset 0x20
  end;
  PGaiHeader = ^TGaiHeader;
  TGaiFrameEntry = packed record // @size 0x08
    DataOffset: Integer; // @offset 0x00
    DataSize: Integer; // @offset 0x04
  end;
  PGaiFrameEntry = ^TGaiFrameEntry;
  TGaiSequenceTableHeader = packed record // @size 0x08
    SequenceCount: Integer; // @offset 0x00
  end;
  PGaiSequenceTableHeader = ^TGaiSequenceTableHeader;
  TGaiSequenceDirectoryEntry = packed record // @size 0x08
    SequenceDataOffset: Integer; // @offset 0x00
  end;
  PGaiSequenceDirectoryEntry = ^TGaiSequenceDirectoryEntry;
  TGaiSequenceFrameEntry = packed record // @size 0x08
    SourceFrameIndex: Integer; // @offset 0x00
    FrameDelay: Integer; // @offset 0x04
  end;
  PGaiSequenceFrameEntry = ^TGaiSequenceFrameEntry;
  TGaiSequenceDataBlock = packed record // @size 0x04
    FrameCount: Integer; // @offset 0x00
    // Followed by FrameCount TGaiSequenceFrameEntry records.
  end;
  PGaiSequenceDataBlock = ^TGaiSequenceDataBlock;

  TgiHeaderGR = packed record // @size 0x40
    Magic: array[0..3] of AnsiChar; // @offset 0x00
    Version: Integer; // @offset 0x04
    Bounds: TRect; // @offset 0x08
    RedMask: Cardinal; // @offset 0x18
    GreenMask: Cardinal; // @offset 0x1C
    BlueMask: Cardinal; // @offset 0x20
    AlphaMask: Cardinal; // @offset 0x24
    Format: Integer; // @offset 0x28
    PlaneCount: Integer; // @offset 0x2C
    ClipRectCount: Integer; // @offset 0x30
    ClipRectTableOffset: Integer; // @offset 0x34
    // +0x38..+0x3F are not interpreted by the recovered reader/writer.
  end;
  PgiHeaderGR = ^TgiHeaderGR;
  TgiPlaneGR = packed record // @size 0x20
    DataOffset: Integer; // @offset 0x00
    DataSize: Integer; // @offset 0x04
    Bounds: TRect; // @offset 0x08
    // The last two dwords remain unresolved.
  end;
  PgiPlaneGR = ^TgiPlaneGR;
  TgiClipRectDiskGR = packed record // @size 0x08
    Left: Word; // @offset 0x00
    Top: Word; // @offset 0x02
    Bottom: Word; // @offset 0x04
    Right: Word; // @offset 0x06
  end;
  PgiClipRectDiskGR = ^TgiClipRectDiskGR;

  TgiGR = class(TObjectEx) // @size 0x14
  public
    Data: Pointer; // @offset 0x04
    DataSize: Integer; // @offset 0x08
    UsesExternalData: Boolean; // @offset 0x0C
    Header: PgiHeaderGR; // @offset 0x10

    constructor Create; // @addr 0x47696C
    destructor Destroy; override; // @addr 0x4769B0
    procedure ClearData; // @addr 0x4769EC @note "Borrowed data is detached without freeing it."
    function IsEmpty: Boolean; // @addr 0x476A34
    procedure LoadRawGiBytes(BufferPtr: Pointer; ByteCount: Integer); // @addr 0x476A50 @note "BufferPtr is borrowed; its header and length are not validated."
    procedure LoadRawGiFromBuffer(SourceBuffer: TBufEC); // @addr 0x476A90 @note "Owns its copy; ignores SourceBuffer.Position."
    procedure LoadCompressedGiBytes(BufferPtr: Pointer; ByteCount: Integer); // @addr 0x476AF0 @note "Owns decompressed storage; empty on decompression failure."
    function GetBoundsRect: TRect; // @addr 0x476B98
    function GetContentSize: TPoint; // @addr 0x476BC0
    function GetTopLeft: TPoint; // @addr 0x476C00
    function GetFormat: Integer; // @addr 0x476C30
    function GetPlane(PlaneIndex: Integer): PgiPlaneGR; // @addr 0x476C4C @note "Does not validate PlaneIndex."
    function GetClipRectCount: Integer; // @addr 0x476C74
    function GetClipRect(RectIndex: Integer): TRect; // @addr 0x476C90 @note "Does not validate RectIndex."
    procedure BuildPalettedFormat4ColorCache; // @addr 0x476CF0 @note "Modifies Data even when borrowed."
    procedure DrawToGraphBuf(GraphBuf: TGraphBufGR; X, Y: Integer; DrawRect: TRect; BlendMode, Alpha: Byte); // @addr 0x476DEC
    procedure DecodeToGraphBuf(GraphBuf: TGraphBufGR; Keep16BitPixels: Boolean); // @addr 0x47743C @note "Formats 0..4 create a 32-bit destination; formats 5/6 decode into an existing sufficiently large buffer. Keep16BitPixels affects format 0 without an alpha mask."
    procedure DecodeRawRegion(Destination: Pointer; PitchBytes, SourceX, SourceY, Width, Height: Integer; Keep16BitPixels: Boolean); // @addr 0x477B9C @note "Only format 0 is supported; other formats report an error."
    procedure DecodeToPixels(Destination: Pointer; PitchBytes, Width, Height: Integer; Keep16BitPixels: Boolean); // @addr 0x477DFC
    procedure CreateFromGraphBuf(GraphBuf: TGraphBufGR; StorageMode: Integer); // @addr 0x478314 @note "Mode 1 uses RGB565; mode 0 uses ARGB masks. Native allocation reserves two bytes per pixel except for mode 2, whose payload is left uninitialized."
    procedure CreateFormat2FromGraphBuf(GraphBuf: TGraphBufGR; TopLeft: TPoint); // @addr 0x478508 @note "Uses RGB565 masks."
  end;

procedure PrepareRawGiColorCache(Data: Pointer); // @addr $4787B0

implementation

uses EC_Mem, EC_OKGF, Windows, GR_Main, GlobalsV, EC_Str;

{ @routine $47696C TgiGR_Create }
constructor TgiGR.Create;
begin
  inherited Create;
end;
{ @end $47696C }

{ @routine $4769B0 TgiGR_Destroy }
destructor TgiGR.Destroy;
begin
  ClearData;
  inherited Destroy;
end;
{ @end $4769B0 }

{ @routine $4769EC TgiGR_ClearData }
procedure TgiGR.ClearData;
begin
  if (Data <> nil) and not UsesExternalData then FreeEC(Data);
  Data := nil; DataSize := 0; UsesExternalData := False; Header := nil;
end;
{ @end $4769EC }

{ @routine $476A34 TgiGR_IsEmpty }
function TgiGR.IsEmpty: Boolean;
begin
  Result := Header = nil;
end;
{ @end $476A34 }

{ @routine $476A50 TgiGR_LoadRawGiBytes }
procedure TgiGR.LoadRawGiBytes(BufferPtr: Pointer; ByteCount: Integer);
begin
  ClearData;
  Data := BufferPtr; DataSize := ByteCount; UsesExternalData := True; Header := Data;
end;
{ @end $476A50 }

{ @routine $476A90 TgiGR_LoadRawGiFromBuffer }
procedure TgiGR.LoadRawGiFromBuffer(SourceBuffer: TBufEC);
begin
  ClearData;
  DataSize := SourceBuffer.DataSize;
  Data := AllocEC(DataSize);
  CopyMemory(Data, SourceBuffer.Data, DataSize);
  UsesExternalData := False;
  Header := Data;
end;
{ @end $476A90 }

{ @routine $476AF0 TgiGR_LoadCompressedGiBytes }
procedure TgiGR.LoadCompressedGiBytes(BufferPtr: Pointer; ByteCount: Integer);
begin
  ClearData;
  if ByteCount < 8 then Exit;
  DataSize := OKGF_ZLib_UnCompress(nil, 0, BufferPtr, ByteCount);
  if DataSize = 0 then Exit;
  Data := AllocEC(DataSize);
  DataSize := OKGF_ZLib_UnCompress(Data, DataSize, BufferPtr, ByteCount);
  if DataSize = 0 then
  begin
    FreeEC(Data);
    Data := nil;
  end
  else
  begin
    Header := Data;
    UsesExternalData := False;
  end;
end;
{ @end $476AF0 }

{ @routine $476B98 TgiGR_GetBoundsRect }
function TgiGR.GetBoundsRect: TRect;
begin
  Result := Header.Bounds;
end;
{ @end $476B98 }

{ @routine $476BC0 TgiGR_GetContentSize }
function TgiGR.GetContentSize: TPoint;
begin
  Result.X := Header.Bounds.Right - Header.Bounds.Left;
  Result.Y := Header.Bounds.Bottom - Header.Bounds.Top;
end;
{ @end $476BC0 }

{ @routine $476C00 TgiGR_GetTopLeft }
function TgiGR.GetTopLeft: TPoint;
begin
  Result.X := Header.Bounds.Left; Result.Y := Header.Bounds.Top;
end;
{ @end $476C00 }

{ @routine $476C30 TgiGR_GetFormat }
function TgiGR.GetFormat: Integer;
begin
  Result := Header.Format;
end;
{ @end $476C30 }

{ @routine $476C4C TgiGR_GetPlane }
function TgiGR.GetPlane(PlaneIndex: Integer): PgiPlaneGR;
begin
  Result := Pointer(PlaneIndex * SizeOf(TgiPlaneGR) + SizeOf(TgiHeaderGR) + PAnsiChar(Data));
end;
{ @end $476C4C }

{ @routine $476C74 TgiGR_GetClipRectCount }
function TgiGR.GetClipRectCount: Integer;
begin
  Result := Header.ClipRectCount;
end;
{ @end $476C74 }

{ @routine $476C90 TgiGR_GetClipRect }
function TgiGR.GetClipRect(RectIndex: Integer): TRect;
var Rect: PgiClipRectDiskGR;
begin
  Rect := Pointer(PAnsiChar(Data) + Header.ClipRectTableOffset + 1 + RectIndex * SizeOf(TgiClipRectDiskGR));
  Result.Left := Rect.Left; Result.Top := Rect.Top;
  Result.Right := Rect.Right; Result.Bottom := Rect.Bottom;
end;
{ @end $476C90 }

{ @routine $476CF0 TgiGR_BuildPalettedFormat4ColorCache }
procedure TgiGR.BuildPalettedFormat4ColorCache;
var Plane: PgiPlaneGR; Source, Dest: Pointer; Index, Count: Integer; Color: Cardinal;
begin
  if HardwareRenderingEnabled or (Header = nil) or (Header.Format <> 4) then Exit;
  Plane := GetPlane(1);
  Source := AddPointerOffset(Data, Plane.DataOffset);
  Dest := Source;
  Count := Plane.DataSize div SizeOf(TColorRGBA);
  for Index := 0 to Count - 1 do
  begin
    Color := ReadDWordEC(Source);
    Color := CurrentPixelFormat.PackRgbBytes(Color and $FF, (Color shr 8) and $FF, (Color shr 16) and $FF);
    WriteWordEC(Dest, Color);
    Source := AddPointerOffset(Source, SizeOf(TColorRGBA));
    Dest := AddPointerOffset(Dest, SizeOf(Word));
  end;
end;
{ @end $476CF0 }

{ @routine $476DEC TgiGR_DrawToGraphBuf }
procedure TgiGR.DrawToGraphBuf(GraphBuf: TGraphBufGR; X, Y: Integer; DrawRect: TRect; BlendMode, Alpha: Byte);
var Plane, PalettePlane: PgiPlaneGR; InclusiveClip: TRect;
begin
  case Header.Format of
    0:
      begin
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        if Plane.DataOffset <> 0 then
        begin
          if (Header.RedMask = $FF0000) and (Header.GreenMask = $FF00) and (Header.BlueMask = $FF) and (Header.AlphaMask = $FF000000) then
            DrawAlphaBuffer16Clipped(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(Word),
              Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, DrawRect)
          else CopyBuffer16Clipped(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(Word),
              Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, DrawRect, Boolean(BlendMode));
        end;
      end;
    1:
      begin
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        if Plane.DataOffset <> 0 then
          DrawTransparentBuffer16(GraphBuf.GetPixels, GraphBuf.PitchBytes,
            X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
            Pointer(PAnsiChar(Data) + Plane.DataOffset), DrawRect, False);
      end;
    2:
      begin
        InclusiveClip.Left := DrawRect.Left; InclusiveClip.Top := DrawRect.Top;
        InclusiveClip.Right := DrawRect.Right - 1; InclusiveClip.Bottom := DrawRect.Bottom - 1;
        Plane := Pointer(PAnsiChar(Data) + (SizeOf(TgiHeaderGR) + 2 * SizeOf(TgiPlaneGR)));
        if Plane.DataOffset <> 0 then
          Ex_OKGR_AlphaBuf_DrawClip_16(GraphBuf.GetPixels, GraphBuf.PitchBytes,
            X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
            Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip);
        Plane := Pointer(PAnsiChar(Data) + (SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR)));
        if Plane.DataOffset <> 0 then
          Ex_OKGR_TransAlphaBuf_DrawClip_WORD(GraphBuf.GetPixels, GraphBuf.PitchBytes,
            X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
            Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip);
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        if Plane.DataOffset <> 0 then
          Ex_OKGR_TransBuf_DrawClip_WORD(GraphBuf.GetPixels, GraphBuf.PitchBytes,
            X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
            Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip);
      end;
    3:
      begin
        InclusiveClip.Left := DrawRect.Left; InclusiveClip.Top := DrawRect.Top;
        InclusiveClip.Right := DrawRect.Right - 1; InclusiveClip.Bottom := DrawRect.Bottom - 1;
        if Alpha = 255 then
        begin
          Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
          if Plane.DataOffset <> 0 then
            Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip);
          Plane := Pointer(PAnsiChar(Data) + (SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR)));
          if Plane.DataOffset <> 0 then
            Ex_OKGR_AlphaIndexed_AlphaDrawClip_16(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip);
        end
        else if Alpha >= 4 then
        begin
          Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
          if Plane.DataOffset <> 0 then
            Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip, Alpha);
          Plane := Pointer(PAnsiChar(Data) + (SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR)));
          if Plane.DataOffset <> 0 then
            Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(GraphBuf.GetPixels, GraphBuf.PitchBytes,
              X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
              Pointer(PAnsiChar(Data) + Plane.DataOffset), InclusiveClip, Alpha);
        end;
      end;
    4:
      begin
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        PalettePlane := Pointer(PAnsiChar(Data) + (SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR)));
        CopyPalettedBuffer16Clipped(GraphBuf.GetPixels, GraphBuf.PitchBytes,
          X + Plane.Bounds.Left - Header.Bounds.Left, Y + Plane.Bounds.Top - Header.Bounds.Top,
          Pointer(PAnsiChar(Data) + Plane.DataOffset), Pointer(PalettePlane.DataOffset + PAnsiChar(Data)),
          Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Right - Header.Bounds.Left,
          Header.Bounds.Bottom - Header.Bounds.Top, DrawRect);
      end;
    5:
      begin
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        Ex_OKGR_F5_DrawRGBA(Pointer(PAnsiChar(GraphBuf.GetPixels) + (X * SizeOf(TColorRGBA) + GraphBuf.PitchBytes * Y)), GraphBuf.PitchBytes, Pointer(PAnsiChar(Data) + Plane.DataOffset));
      end;
    6:
      begin
        Plane := Pointer(PAnsiChar(Data) + SizeOf(TgiHeaderGR));
        Ex_OKGR_F6_DrawRGBA(Pointer(PAnsiChar(GraphBuf.GetPixels) + (X * SizeOf(TColorRGBA) + GraphBuf.PitchBytes * Y)), GraphBuf.PitchBytes, Pointer(PAnsiChar(Data) + Plane.DataOffset));
      end;
  end;
end;
{ @end $476DEC }

{ @routine $47743C TgiGR_DecodeToGraphBuf }
procedure TgiGR.DecodeToGraphBuf(GraphBuf: TGraphBufGR; Keep16BitPixels: Boolean);
var Plane, PalettePlane: PgiPlaneGR; Y: Cardinal;
begin
  if Header.Format = 0 then
  begin
    GraphBuf.AllocateRgba(Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA));
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
    begin
      if Header.AlphaMask = 0 then
      begin
        if Keep16BitPixels then
          for Y := 0 to Cardinal(GraphBuf.Height) - 1 do
            CopyMemory(AddPointerOffset(GraphBuf.GetPixels, GraphBuf.PitchBytes * Y), AddPointerOffset(Data, Plane.DataOffset + Y * GraphBuf.Width * SizeOf(Word)), GraphBuf.Width * SizeOf(Word))
        else Ex_OKGF_Convert565toBGRA(AddPointerOffset(Data, Plane.DataOffset), GraphBuf.Width * SizeOf(Word), GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height);
      end
      else CopyMemory(GraphBuf.GetPixels, AddPointerOffset(Data, Plane.DataOffset), GraphBuf.Width * SizeOf(TColorRGBA) * GraphBuf.Height);
    end;
  end
  else if Header.Format = 1 then
  begin
    GraphBuf.AllocateRgba(Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA));
    GraphBuf.ClearPixels;
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransBuf_Draw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 2 then
  begin
    GraphBuf.AllocateRgba(Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA));
    GraphBuf.ClearPixels;
    Plane := GetPlane(2);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaBuf_Draw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(1);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransAlphaBuf_Draw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransBuf_Draw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 3 then
  begin
    GraphBuf.AllocateRgba(Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA));
    GraphBuf.ClearPixels;
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaIndexed_Draw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(1);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(AddPointerOffset(GraphBuf.GetPixels, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * GraphBuf.Width * SizeOf(TColorRGBA)), GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 4 then
  begin
    GraphBuf.AllocateRgba(Header.Bounds.Right - Header.Bounds.Left, Header.Bounds.Bottom - Header.Bounds.Top, (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA));
    GraphBuf.ClearPixels;
    Plane := GetPlane(0); PalettePlane := GetPlane(1);
    ExpandPaletteToBgra(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, AddPointerOffset(Data, Plane.DataOffset), GraphBuf.Width, AddPointerOffset(Data, PalettePlane.DataOffset));
  end
  else if Header.Format = 5 then
  begin
    if (GraphBuf <> nil) and (Header.Bounds.Right - Header.Bounds.Left <= GraphBuf.Width) and (Header.Bounds.Bottom - Header.Bounds.Top <= GraphBuf.Height) then
    begin
      Plane := GetPlane(0);
      Ex_OKGR_F5_DrawRGBA(GraphBuf.GetPixels, GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    end;
  end
  else if Header.Format = 6 then
  begin
    if (GraphBuf <> nil) and (Header.Bounds.Right - Header.Bounds.Left <= GraphBuf.Width) and (Header.Bounds.Bottom - Header.Bounds.Top <= GraphBuf.Height) then
    begin
      Plane := GetPlane(0);
      Ex_OKGR_F6_DrawRGBA(GraphBuf.GetPixels, GraphBuf.PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    end;
  end;
end;
{ @end $47743C }

{ @routine $477B9C TgiGR_DecodeRawRegion }
procedure TgiGR.DecodeRawRegion(Destination: Pointer; PitchBytes, SourceX, SourceY, Width, Height: Integer; Keep16BitPixels: Boolean);
var Plane: PgiPlaneGR; Y, SourcePitch: Integer;
begin
  if Header.Format = 0 then
  begin
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
    begin
      if Header.AlphaMask = 0 then
      begin
        SourcePitch := (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(Word);
        if Keep16BitPixels then
          for Y := 0 to Height - 1 do
            CopyMemory(AddPointerOffset(Destination, PitchBytes * Y),
              AddPointerOffset(Data, (SourceY + Y) * SourcePitch + SourceX * SizeOf(Word) + Plane.DataOffset), Width * SizeOf(Word))
        else Ex_OKGF_Convert565toBGRA(AddPointerOffset(Data, SourceY * SourcePitch + SourceX * SizeOf(Word) + Plane.DataOffset), SourcePitch, Destination, PitchBytes, Width, Height);
      end
      else
      begin
        SourcePitch := (Header.Bounds.Right - Header.Bounds.Left) * SizeOf(TColorRGBA);
        for Y := 0 to Height - 1 do
          CopyMemory(AddPointerOffset(Destination, PitchBytes * Y),
            AddPointerOffset(Data, (Y + SourceY) * SourcePitch + SourceX * SizeOf(TColorRGBA) + Plane.DataOffset), Width * SizeOf(TColorRGBA));
      end;
    end;
  end
  else AppendLogLineThreadSafe('Error in TgiGR.DrawRGBA()::FZag.format=' + IntToWideString(Header.Format));
end;
{ @end $477B9C }

{ @routine $477DFC TgiGR_DecodeToPixels }
procedure TgiGR.DecodeToPixels(Destination: Pointer; PitchBytes, Width, Height: Integer; Keep16BitPixels: Boolean);
var Plane, PalettePlane: PgiPlaneGR; Y: Integer;
begin
  if Header.Format = 0 then
  begin
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
    begin
      if Header.AlphaMask = 0 then
      begin
        if Keep16BitPixels then
          for Y := 0 to Height - 1 do
            CopyMemory(AddPointerOffset(Destination, PitchBytes * Y), AddPointerOffset(Data, Y * Width * SizeOf(Word) + Plane.DataOffset), Width * SizeOf(Word))
        else Ex_OKGF_Convert565toBGRA(AddPointerOffset(Data, Plane.DataOffset), Width * SizeOf(Word), Destination, PitchBytes, Width, Height);
      end
      else CopyMemory(Destination, AddPointerOffset(Data, Plane.DataOffset), PitchBytes * Height);
    end;
  end
  else if Header.Format = 1 then
  begin
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransBuf_Draw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 2 then
  begin
    Plane := GetPlane(2);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaBuf_Draw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(1);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransAlphaBuf_Draw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_TransBuf_Draw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 3 then
  begin
    Plane := GetPlane(0);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaIndexed_Draw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
    Plane := GetPlane(1);
    if Plane.DataOffset <> 0 then
      Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(AddPointerOffset(Destination, (Plane.Bounds.Left - Header.Bounds.Left) * SizeOf(TColorRGBA) + (Plane.Bounds.Top - Header.Bounds.Top) * PitchBytes), PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 4 then
  begin
    Plane := GetPlane(0); PalettePlane := GetPlane(1);
    ExpandPaletteToBgra(Destination, PitchBytes, Width, Height, AddPointerOffset(Data, Plane.DataOffset), Width, AddPointerOffset(Data, PalettePlane.DataOffset));
  end
  else if Header.Format = 5 then
  begin
    Plane := GetPlane(0);
    Ex_OKGR_F5_DrawRGBA(Destination, PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end
  else if Header.Format = 6 then
  begin
    Plane := GetPlane(0);
    Ex_OKGR_F6_DrawRGBA(Destination, PitchBytes, AddPointerOffset(Data, Plane.DataOffset));
  end;
end;
{ @end $477DFC }

{ @routine $478314 TgiGR_CreateFromGraphBuf }
procedure TgiGR.CreateFromGraphBuf(GraphBuf: TGraphBufGR; StorageMode: Integer);
var Plane: PgiPlaneGR; ByteCount: Cardinal;

  // @nested $4782CC SwapGiSourceRedBlue
  procedure SwapGiSourceRedBlue; // @addr $4782CC @calls "0x00478486 0x004784FC"
  var Pixels: Pointer; Count: Integer;
  begin
    Pixels := GraphBuf.GetPixels;
    Count := GraphBuf.Width * GraphBuf.Height;
    asm
      PUSH EDI
      PUSH EAX
      PUSH ECX
      MOV EDI, Pixels
      MOV ECX, Count
    @@Pixel:
      MOV AL, [EDI]
      XCHG AL, [EDI + 2]
      MOV [EDI], AL
      ADD EDI, 4
      DEC ECX
      JNZ @@Pixel
      POP ECX
      POP EAX
      POP EDI
    end;
  end;

begin
  ClearData;
  ByteCount := GraphBuf.Width * GraphBuf.Height;
  if StorageMode = 2 then ByteCount := ByteCount * SizeOf(TColorRGBA) else ByteCount := ByteCount * SizeOf(Word);
  DataSize := ByteCount + (SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR));
  Data := AllocEC(DataSize);
  Header := Data;
  FillChar(Header^, SizeOf(TgiHeaderGR), 0);
  Header.Magic[0] := 'g'; Header.Magic[1] := 'i'; Header.Version := 1;
  Header.Bounds := Classes.Rect(0, 0, GraphBuf.Width, GraphBuf.Height);
  Header.PlaneCount := 1;
  Plane := GetPlane(0);
  Plane.DataOffset := SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR);
  Plane.DataSize := ByteCount;
  Plane.Bounds := Header.Bounds;
  case StorageMode of
    0:
      begin
        Header.RedMask := $FF0000; Header.GreenMask := $FF00; Header.BlueMask := $FF; Header.AlphaMask := $FF000000;
        CopyMemory(AddPointerOffset(Data, Plane.DataOffset), GraphBuf.GetPixels, ByteCount);
      end;
    1:
      begin
        SwapGiSourceRedBlue;
        Header.RedMask := $F800; Header.GreenMask := $7E0; Header.BlueMask := $1F;
        Ex_OKGF_Convert_8888to565(AddPointerOffset(Data, Plane.DataOffset), GraphBuf.Width * SizeOf(Word), 0, 0, GraphBuf.GetPixels, GraphBuf.PitchBytes, 0, 0, GraphBuf.Width, GraphBuf.Height);
        SwapGiSourceRedBlue;
      end;
  end;
end;
{ @end $478314 }

{ @routine $478508 TgiGR_CreateFormat2FromGraphBuf }
procedure TgiGR.CreateFormat2FromGraphBuf(GraphBuf: TGraphBufGR; TopLeft: TPoint);
var Plane: PgiPlaneGR; ByteCount, Offset: Integer;
begin
  ClearData;
  ByteCount := Ex_OKGR_TransBuf_BuildFromRGBA_16(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, nil);
  Inc(ByteCount, Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, nil));
  Inc(ByteCount, Ex_OKGR_AlphaBuf_BuildFromRGBA(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, nil));
  Offset := SizeOf(TgiHeaderGR) + 3 * SizeOf(TgiPlaneGR);
  DataSize := Offset + ByteCount;
  Data := AllocEC(DataSize); Header := Data;
  FillChar(Header^, SizeOf(TgiHeaderGR), 0);
  Header.Magic[0] := 'g'; Header.Magic[1] := 'i'; Header.Version := 1;
  Header.Bounds := Classes.Rect(TopLeft.X, TopLeft.Y, TopLeft.X + GraphBuf.Width, TopLeft.Y + GraphBuf.Height);
  Header.Format := 2; Header.PlaneCount := 3;
  Header.RedMask := $F800; Header.GreenMask := $7E0; Header.BlueMask := $1F;
  Plane := GetPlane(0); Plane.DataOffset := Offset;
  Plane.DataSize := Ex_OKGR_TransBuf_BuildFromRGBA_16(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, AddPointerOffset(Data, Offset));
  Plane.Bounds := Header.Bounds;
  Inc(Offset, Plane.DataSize);
  Plane := GetPlane(1); Plane.DataOffset := Offset;
  Plane.DataSize := Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, AddPointerOffset(Data, Offset));
  Plane.Bounds := Header.Bounds;
  Inc(Offset, Plane.DataSize);
  Plane := GetPlane(2); Plane.DataOffset := Offset;
  Plane.DataSize := Ex_OKGR_AlphaBuf_BuildFromRGBA(GraphBuf.GetPixels, GraphBuf.PitchBytes, GraphBuf.Width, GraphBuf.Height, AddPointerOffset(Data, Offset));
  Plane.Bounds := Header.Bounds;
end;
{ @end $478508 }

{ @routine $4787B0 PrepareRawGiColorCache }
procedure PrepareRawGiColorCache(Data: Pointer);
var Image: TgiGR;
begin
  Image := TgiGR.Create;
  Image.LoadRawGiBytes(Data, 1);
  Image.BuildPalettedFormat4ColorCache;
  Image.Free;
end;
{ @end $4787B0 }

end.
