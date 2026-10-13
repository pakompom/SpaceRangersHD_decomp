unit GI_Cursor;

interface

uses GI_Image, GI_MessageLoop, GR_GraphBuf, Types;

type
  TCursorGI = class(TObjectGI) // @size $13C
  public
    ImageControl: TImageGI; // @offset $120
    ImagePath: WideString; // @offset $124
    CursorHandles: array of Cardinal; // @offset $128
    FrameIndices: array of Integer; // @offset $12C
    FrameDelays: array of Integer; // @offset $130
    FrameIndex: Integer; // @offset $134
    AnimationTimer: TCallbackTimerIdGI; // @offset $138

    constructor Create(Owner: TObjectGI); // @addr $4BFB6C
    destructor Destroy; override; // @addr $4BFBBC
    procedure Clear; override; // @addr $4BFC78 @note "Clears cursor resources and the image child, retaining the child object."
    procedure SetImagePath(const Path: WideString); // @addr $4BFD1C
    procedure SetActive(Enabled: Boolean); override; // @addr $4BFDA4
    procedure SetOrigin(Origin: TPoint); override; // @addr $4BFEA8
    procedure Draw(ClipRect: TRect); override; // @addr $4BFEFC
    procedure RebuildSystemCursor; // @addr $4BFF18 @note "Builds Windows cursor handles from GI/GAI resources and schedules animation when active."
    function CreateCursorBitmap(Buffer: TGraphBufGR): Cardinal; // @addr $4C054C @note "Copies a 32-bit image to a top-down Windows DIB; caller owns the bitmap."
    procedure AdvanceAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $4C0664 @note "Timer and UserData are unused; replaces AnimationTimer after advancing the sequence."
  end;

implementation

uses Classes, EC_Cache, EC_CacheGAI, EC_CacheGI, EC_Str, GR_Main, SysUtils, Windows;

{ @routine $4BFB6C TCursorGI_Create }
constructor TCursorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageControl := TImageGI.Create(Self);
  Active := False;
end;
{ @end $4BFB6C }

{ @routine $4BFBBC TCursorGI_Destroy }
destructor TCursorGI.Destroy;
var Index: Integer;
begin
  if AnimationTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> 0 then
    begin
      DestroyIcon(CursorHandles[Index]);
      CursorHandles[Index] := 0;
    end;
  ImagePath := '';
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  inherited Destroy;
end;
{ @end $4BFBBC }

{ @routine $4BFC78 TCursorGI_Clear }
procedure TCursorGI.Clear;
var Index: Integer;
begin
  if AnimationTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> 0 then
    begin
      DestroyIcon(CursorHandles[Index]);
      CursorHandles[Index] := 0;
    end;
  ImagePath := '';
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  ImageControl.Clear;
end;
{ @end $4BFC78 }

{ @routine $4BFD1C TCursorGI_SetImagePath }
procedure TCursorGI.SetImagePath(const Path: WideString);
begin
  Clear;
  if ShowSystemMouse then
  begin
    if ImagePath <> Path then FrameIndex := 0;
    ImagePath := Path;
    RebuildSystemCursor;
  end
  else
  begin
    ImageControl.ImageSourcePath := Path;
    ObjectSize := ImageControl.GetContentSize;
    ImageControl.ObjectSize := ClientSize;
    ImageControl.RestartPlayback;
  end;
end;
{ @end $4BFD1C }

{ @routine $4BFDA4 TCursorGI_SetActive }
procedure TCursorGI.SetActive(Enabled: Boolean);
begin
  Invalidate;
  inherited SetActive(Enabled);
  if ShowSystemMouse then
  begin
    if Enabled then
    begin
      if High(CursorHandles) >= 0 then
      begin
        FrameIndex := 0;
        Windows.SetCursor(CursorHandles[FrameIndex]);
        while ShowCursor(True) < 0 do;
        if High(FrameIndices) > 0 then
        begin
          if AnimationTimer <> 0 then
          begin
            MessageLoop.CancelCallbackTimer(AnimationTimer);
            AnimationTimer := 0;
          end;
          AnimationTimer := MessageLoop.ScheduleCallbackTimer(
            FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
        end;
      end;
    end
    else
    begin
      if AnimationTimer <> 0 then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := 0;
      end;
      while ShowCursor(False) >= 0 do;
    end;
  end
  else
  begin
    ImageControl.IsActive := Enabled;
    ImageControl.RestartPlayback;
  end;
end;
{ @end $4BFDA4 }

{ @routine $4BFEA8 TCursorGI_SetOrigin }
procedure TCursorGI.SetOrigin(Origin: TPoint);
begin
  inherited SetOrigin(Origin);
  ImageControl.Pos := Classes.Point(-Origin.X, -Origin.Y);
  if ShowSystemMouse then RebuildSystemCursor;
end;
{ @end $4BFEA8 }

{ @routine $4BFEFC TCursorGI_Draw }
procedure TCursorGI.Draw(ClipRect: TRect);
begin
  inherited Draw(ClipRect);
end;
{ @end $4BFEFC }

{ @routine $4BFF18 TCursorGI_RebuildSystemCursor }
procedure TCursorGI.RebuildSystemCursor;
var
  GaiControl: TCGaiControlEC;
  GiControl: TCGiControlEC;
  Gai: TCGaiEC;
  Gi: TCGiEC;
  Index: Integer;
  Kind, Path: WideString;
  Buffer: TGraphBufGR;
  Info: TIconInfo;
begin
  if AnimationTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> 0 then
    begin
      DestroyIcon(CursorHandles[Index]);
      CursorHandles[Index] := 0;
    end;
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  Path := ImagePath;
  Kind := ExtractNextDelimitedPartW(Path, ',');
  if Kind = 'GAI' then
  begin
    GaiControl := TCGaiControlEC.Create;
    GlobalCache.ResetControl(GaiControl);
    GaiControl.SetCacheKey(Path);
    Buffer := TGraphBufGR.Create(False);
    Gai := AcquireCachedGai(GaiControl);
    try
      SetLength(CursorHandles, Gai.GetFrameCount);
      SetLength(FrameIndices, Gai.GetSequenceFrameCount(0));
      SetLength(FrameDelays, Gai.GetSequenceFrameCount(0));
      Gai.FillSequenceFrameIndexTable(0, @FrameIndices[0], SizeOf(Integer));
      Gai.FillSequenceFrameDelayTable(0, @FrameDelays[0], SizeOf(Integer));
      for Index := 0 to High(CursorHandles) do
      begin
        Gai.LoadFrameGi(Index).DecodeToGraphBuf(Buffer, False);
        Info.fIcon := False;
        Info.xHotspot := OriginPoint.X - (Gai.LoadFrameGi(Index).GetBoundsRect.Left - Gai.GetBoundsRect.Left);
        Info.yHotspot := OriginPoint.Y - (Gai.LoadFrameGi(Index).GetBoundsRect.Top - Gai.GetBoundsRect.Top);
        Info.hbmMask := CreateCursorBitmap(Buffer);
        Info.hbmColor := Info.hbmMask;
        CursorHandles[Index] := CreateIconIndirect(Info);
        if CursorHandles[Index] = 0 then
          RaiseWideMessage('CreateIconIndirect GetLastError=' + IntToStr(GetLastError));
        DeleteObject(Info.hbmMask);
      end;
    finally
      GaiControl.Release;
    end;
    Buffer.Free;
    GaiControl.Free;
  end
  else if Kind = 'GI' then
  begin
    GiControl := TCGiControlEC.Create;
    GlobalCache.ResetControl(GiControl);
    GiControl.SetCacheKey(Path);
    Buffer := TGraphBufGR.Create(False);
    Gi := AcquireCachedGi(GiControl);
    try
      SetLength(CursorHandles, 1);
      SetLength(FrameIndices, 1);
      SetLength(FrameDelays, 1);
      FrameIndices[0] := 0;
      FrameDelays[0] := 0;
      Gi.Image.DecodeToGraphBuf(Buffer, False);
      Info.fIcon := False;
      Info.xHotspot := OriginPoint.X;
      Info.yHotspot := OriginPoint.Y;
      Info.hbmMask := CreateCursorBitmap(Buffer);
      Info.hbmColor := Info.hbmMask;
      CursorHandles[0] := CreateIconIndirect(Info);
      if CursorHandles[0] = 0 then
        RaiseWideMessage('CreateIconIndirect GetLastError=' + IntToStr(GetLastError));
      DeleteObject(Info.hbmMask);
    finally
      GiControl.Release;
    end;
    Buffer.Free;
    GiControl.Free;
  end;
  if (FrameIndex < 0) or (FrameIndex > High(FrameIndices)) then FrameIndex := 0;
  if Active then
  begin
    Windows.SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
    while ShowCursor(True) < 0 do;
    if High(FrameIndices) > 0 then
    begin
      if AnimationTimer <> 0 then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := 0;
      end;
      AnimationTimer := MessageLoop.ScheduleCallbackTimer(
        FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
    end;
  end;
end;
{ @end $4BFF18 }

// This local import has its own native thunk and IAT entry, separate from Windows.
function CreateDIBSection(DC: HDC; const BitmapInfo: TBitmapInfo; Usage: Cardinal;
  var Bits: Pointer; Section: THandle; Offset: Cardinal): HBITMAP; stdcall;
  external 'gdi32.dll' name 'CreateDIBSection'; // @addr $4C0544

{ @routine $4C054C TCursorGI_CreateCursorBitmap }
function TCursorGI.CreateCursorBitmap(Buffer: TGraphBufGR): Cardinal;
var
  DC: HDC;
  Bitmap: HBitmap;
  Bits: Pointer;
  X, Y: Cardinal;
  Pitch, SourceSkip, DestSkip: Integer;
  Dest, Source: PCardinal;
  Info: TBitmapV4Header;
begin
  Pitch := (Buffer.Width * SizeOf(Cardinal)) and not 1;
  if (Buffer.Width * SizeOf(Cardinal)) and 1 <> 0 then Inc(Pitch, 2);
  FillChar(Info, SizeOf(Info), 0);
  Info.bV4Size := SizeOf(Info);
  Info.bV4Width := Buffer.Width;
  Info.bV4Height := -Buffer.Height;
  Info.bV4Planes := 1;
  Info.bV4BitCount := 32;
  Info.bV4V4Compression := BI_RGB;
  Info.bV4SizeImage := Buffer.Height * Pitch;
  DC := GetDC(0);
  Bitmap := CreateDIBSection(DC, PBitmapInfo(@Info)^, DIB_RGB_COLORS, Bits, 0, 0);
  if Bitmap = 0 then RaiseWideMessage('DIB section');
  SourceSkip := Buffer.PitchBytes - Buffer.Width * SizeOf(Cardinal);
  DestSkip := Pitch - Buffer.Width * SizeOf(Cardinal);
  Dest := Bits;
  Source := Buffer.GetPixels;
  for Y := 0 to Buffer.Height - 1 do
  begin
    for X := 0 to Buffer.Width - 1 do
    begin
      Dest^ := Source^;
      Inc(Source);
      Inc(Dest);
    end;
    Source := PCardinal(PAnsiChar(Source) + SourceSkip);
    Dest := PCardinal(PAnsiChar(Dest) + DestSkip);
  end;
  ReleaseDC(0, DC);
  Result := Bitmap;
end;
{ @end $4C054C }

{ @routine $4C0664 TCursorGI_AdvanceAnimation }
procedure TCursorGI.AdvanceAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  Inc(FrameIndex);
  if High(FrameIndices) < FrameIndex then FrameIndex := 0;
  Windows.SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
  if AnimationTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(
    FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
end;
{ @end $4C0664 }

end.
