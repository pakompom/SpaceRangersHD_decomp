unit GI_Cursor;
// Unit bracket (inferred): .text 0x004B9484..0x004BA422; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native dynamic-array RTTI names GI_Cursor at $4B9484, $4B94A8 and $4B94CC.

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
    AnimationTimer: PCallbackTimerGI; // @offset $138

    constructor Create(Owner: TObjectGI); // @addr $4B9634
    destructor Destroy; override; // @addr $4B969C
    procedure Clear; override; // @addr $4B979C @note "Clears cursor resources and the image child, retaining the child object."
    procedure SetImagePath(const Path: WideString); // @addr $4B9884
    procedure SetActive(Enabled: Boolean); override; // @addr $4B992C
    procedure SetOrigin(Origin: TPoint); override; // @addr $4B9A94
    procedure Draw(ClipRect: TRect); override; // @addr $4B9AEC
    procedure RebuildSystemCursor; // @addr $4B9B14 @note "Builds Windows cursor handles from GI/GAI resources and schedules animation when active."
    function CreateCursorBitmap(Buffer: TGraphBufGR): Cardinal; // @addr $4BA1AC @note "Copies a 32-bit image to a top-down Windows DIB; caller owns the bitmap."
    procedure AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $4BA348 @note "Timer and UserData are unused; replaces AnimationTimer after advancing the sequence."
  end;

implementation

uses Classes, EC_Cache, EC_CacheGAI, EC_CacheGI, EC_Str, GR_Main, SysUtils, Windows;

{ @routine $4B9634 TCursorGI_Create }
constructor TCursorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageControl := TImageGI.Create(Self);
  Active := False;
end;
{ @end $4B9634 }

{ @routine $4B969C TCursorGI_Destroy }
destructor TCursorGI.Destroy;
var Index: Integer;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
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
{ @end $4B969C }

{ @routine $4B979C TCursorGI_Clear }
procedure TCursorGI.Clear;
var Index: Integer;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
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
{ @end $4B979C }

{ @routine $4B9884 TCursorGI_SetImagePath }
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
    ImageControl.SetImagePath(Path);
    SetSize(ImageControl.GetContentSize);
    ImageControl.SetSize(ClientSize);
    ImageControl.RestartPlayback;
  end;
end;
{ @end $4B9884 }

{ @routine $4B992C TCursorGI_SetActive }
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
          if AnimationTimer <> nil then
          begin
            MessageLoop.CancelCallbackTimer(AnimationTimer);
            AnimationTimer := nil;
          end;
          AnimationTimer := MessageLoop.ScheduleCallbackTimer(
            FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
        end;
      end;
    end
    else
    begin
      if AnimationTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := nil;
      end;
      while ShowCursor(False) >= 0 do;
    end;
  end
  else
  begin
    ImageControl.SetActive(Enabled);
    ImageControl.RestartPlayback;
  end;
end;
{ @end $4B992C }

{ @routine $4B9A94 TCursorGI_SetOrigin }
procedure TCursorGI.SetOrigin(Origin: TPoint);
begin
  inherited SetOrigin(Origin);
  ImageControl.SetPosition(Classes.Point(-Origin.X, -Origin.Y));
  if ShowSystemMouse then RebuildSystemCursor;
end;
{ @end $4B9A94 }

{ @routine $4B9AEC TCursorGI_Draw }
procedure TCursorGI.Draw(ClipRect: TRect);
begin
  inherited Draw(ClipRect);
end;
{ @end $4B9AEC }

{ @routine $4B9B14 TCursorGI_RebuildSystemCursor }
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
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
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
      Gai.FillSequenceFrameIndexTable(0, Pointer(FrameIndices), 4);
      Gai.FillSequenceFrameDelayTable(0, Pointer(FrameDelays), 4);
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
  if (FrameIndex < 0) or (High(FrameIndices) < FrameIndex) then FrameIndex := 0;
  if Active then
  begin
    Windows.SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
    while ShowCursor(True) < 0 do;
    if High(FrameIndices) > 0 then
    begin
      if AnimationTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := nil;
      end;
      AnimationTimer := MessageLoop.ScheduleCallbackTimer(
        FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
    end;
  end;
end;
{ @end $4B9B14 }

// This local import has its own native thunk and IAT entry, separate from Windows.
function CreateDIBSection(DC: HDC; const BitmapInfo: TBitmapInfo; Usage: Cardinal;
  var Bits: Pointer; Section: THandle; Offset: Cardinal): HBITMAP; stdcall;
  external 'gdi32.dll' name 'CreateDIBSection'; // @addr $4BA1A4

{ @routine $4BA1AC TCursorGI_CreateCursorBitmap }
function TCursorGI.CreateCursorBitmap(Buffer: TGraphBufGR): Cardinal;
var
  DC: HDC;
  Bitmap: HBitmap;
  Bits: Pointer;
  X, Y: Cardinal;
  Pitch, SourceSkip, DestSkip: Integer;
  Dest, Source: Pointer;
  Info: TBitmapV4Header;
begin
  Pitch := (Buffer.Width * 4) and not 1;
  if (Buffer.Width * 4) and 1 <> 0 then Inc(Pitch, 2);
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
  SourceSkip := Buffer.PitchBytes - Buffer.Width * 4;
  DestSkip := Pitch - Buffer.Width * 4;
  Dest := Bits;
  Source := Buffer.GetPixels;
  for Y := 0 to Buffer.Height - 1 do
  begin
    for X := 0 to Buffer.Width - 1 do
    begin
      PCardinal(Dest)^ := PCardinal(Source)^;
      Source := Pointer(PAnsiChar(Source) + 4);
      Dest := Pointer(PAnsiChar(Dest) + 4);
    end;
    Source := Pointer(PAnsiChar(Source) + SourceSkip);
    Dest := Pointer(PAnsiChar(Dest) + DestSkip);
  end;
  ReleaseDC(0, DC);
  Result := Bitmap;
end;
{ @end $4BA1AC }

{ @routine $4BA348 TCursorGI_AdvanceAnimation }
procedure TCursorGI.AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Inc(FrameIndex);
  if High(FrameIndices) < FrameIndex then FrameIndex := 0;
  Windows.SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer := MessageLoop.ScheduleCallbackTimer(
    FrameDelays[FrameIndex], FrameDelays[FrameIndex], AdvanceAnimation);
end;
{ @end $4BA348 }

end.
