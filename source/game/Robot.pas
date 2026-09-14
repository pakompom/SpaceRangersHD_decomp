unit Robot;
// Unit bracket (inferred): .text 0x007E7FAC..0x007E982F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876A58..0x00876A5F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows, Types, GR_Sound, GR_GraphBuf;

type
  TRobotTextImage = record // @size $14 Owned raster returned to the DLL.
    Buffer: TGraphBufGR; // @offset $00
    Pixels: Pointer; // @offset $04
    Pitch: Integer; // @offset $08
    Width: Integer; // @offset $0C
    Height: Integer; // @offset $10
  end;
  PRobotTextImage = ^TRobotTextImage;
  TRobotPlaySound = procedure(Name: PWideChar); stdcall;
  TRobotCreateSound = function(Name: PWideChar; Group, Looping: Integer): TSoundBufferControl; stdcall;
  TRobotSoundAction = procedure(Sound: TSoundBufferControl); stdcall;
  TRobotSoundQuery = function(Sound: TSoundBufferControl): Integer; stdcall;
  TRobotSoundSetValue = procedure(Sound: TSoundBufferControl; Value: Single); stdcall;
  TRobotSoundGetValue = function(Sound: TSoundBufferControl): Single; stdcall;
  TRobotRenderText = procedure(Text, FontName: PWideChar; Color: Cardinal;
    Width, Height, AlignX, AlignY, Wrap, OffsetX, OffsetY: Integer;
    Clip: PRect; Image: PRobotTextImage); stdcall;
  TRobotFreeText = procedure(Image: PRobotTextImage); stdcall;
  TRobotProgress = procedure(Fraction: Single); stdcall;
  TRobotAction = procedure; stdcall;
  TRobotGetVolume = function: Single; stdcall;
  TRobotSetVolume = procedure(Value: Single); stdcall;
  TRobotCallbacks = record // @size $40 Rangers callbacks passed to MatrixGame.dll.
    PlaySound: TRobotPlaySound; // @offset $00
    CreateSound: TRobotCreateSound; // @offset $04
    FreeSound: TRobotSoundAction; // @offset $08
    StartSound: TRobotSoundAction; // @offset $0C
    IsSoundPlaying: TRobotSoundQuery; // @offset $10
    SetSoundVolume: TRobotSoundSetValue; // @offset $14
    SetSoundPan: TRobotSoundSetValue; // @offset $18
    GetSoundVolume: TRobotSoundGetValue; // @offset $1C
    GetSoundPan: TRobotSoundGetValue; // @offset $20
    RenderText: TRobotRenderText; // @offset $24
    FreeText: TRobotFreeText; // @offset $28
    SetProgress: TRobotProgress; // @offset $2C
    PlayMusic: TRobotAction; // @offset $30
    ReleaseTextures: TRobotAction; // @offset $34
    GetMusicVolume: TRobotGetVolume; // @offset $38
    SetMusicVolume: TRobotSetVolume; // @offset $3C
  end;
  PRobotCallbacks = ^TRobotCallbacks;
  TRobotDisplaySettingsPrefix = packed record // @size $38 Native settings block.
    Direct3D: Pointer; // @offset $00 Borrowed, no interface reference counting.
    Device: Pointer; // @offset $04 Borrowed.
    ShowStencilShadows: Boolean; // @offset $08
    ShowProjShadows: Boolean; // @offset $09
    SelectEx: Boolean; // @offset $0A
    LandTexturesGloss: Boolean; // @offset $0B
    ObjTexturesGloss: Boolean; // @offset $0C
    SoftwareCursor: Boolean; // @offset $0D
    Sky: Byte; // @offset $0E
    RobotShadow: Byte; // @offset $0F
    ColorDepth: Integer; // @offset $10
    ScreenWidth: Integer; // @offset $14
    ScreenHeight: Integer; // @offset $18
    RefreshRate: Integer; // @offset $1C Zero in windowed mode.
    Brightness: Single; // @offset $20
    Contrast: Single; // @offset $24
    FSAASamples: Integer; // @offset $28
    Anisotropy: Integer; // @offset $2C
    MaxDistance: Single; // @offset $30
    VSync: Boolean; // @offset $34
  end;
  PRobotDisplaySettings = ^TRobotDisplaySettingsPrefix;
  TRobotInitialize = procedure(Callbacks: PRobotCallbacks); stdcall;
  TRobotSupportQuery = function: Integer; stdcall;
  TRobotRun = function(Instance, Window: Cardinal; MapName: PWideChar;
    Settings: PRobotDisplaySettings; Language, StartText, WinText, LossText,
    TerronName: PWideChar; Statistics: PInteger): Integer; stdcall;
  TRobotInterfacePrefix = record // @size $10 Dispatch table returned by GetRobotInterface.
    Initialize: TRobotInitialize; // @offset $00
    Finalize: TRobotAction; // @offset $04
    Support: TRobotSupportQuery; // @offset $08 Zero allows entry.
    Run: TRobotRun; // @offset $0C
  end;
  PRobotInterfacePrefix = ^TRobotInterfacePrefix;
  TGetRobotInterface = function: PRobotInterfacePrefix; stdcall;

var
  RobotInterface: PRobotInterfacePrefix = nil; // @addr $87EB90 Borrowed DLL dispatch table; nil until successful initialization.
  // Native compiler-generated initialization $876A58 decrements the unit counter
  // at $88AFBC; finalization $7E97F0 increments it and clears this array at zero.
  // The managed global below supplies that DCC32 lifetime code automatically.
var
  RobotCallbacks: TRobotCallbacks; // @addr $88AF60
  RobotBattleStatistics: array[0..5] of Integer; // @addr $88AFA0 Returned planetary-battle statistics; entry 0 is negative elapsed milliseconds.
  SupportedMultiSamples: array of Integer; // @addr $88AFB8
  RobotSettings: TRobotDisplaySettingsPrefix = (Direct3D: nil; Device: nil;
    ShowStencilShadows: True; ShowProjShadows: True; SelectEx: False;
    LandTexturesGloss: True; ObjTexturesGloss: True; SoftwareCursor: False;
    Sky: 2; RobotShadow: 1; ColorDepth: 32; ScreenWidth: 1024; ScreenHeight: 768;
    RefreshRate: 0; Brightness: 0.5; Contrast: 0.5; FSAASamples: 0;
    Anisotropy: 0; MaxDistance: 0; VSync: False); // @addr $87EB94
  RobotSound: Boolean = True; // @addr $87EBCC
  RobotMusic: Boolean = True; // @addr $87EBD0
  RobotVSync: Boolean = False; // @addr $87EBD4
  RobotFSAASamples: Integer = 0; // @addr $87EBD8
  RobotAnisotropy: Integer = 0; // @addr $87EBDC
  RobotMaxDistance: Integer = 0; // @addr $87EBE0
  SupportedMultiSampleCount: Integer = 0; // @addr $87EBE4
var
  MaximumAnisotropy: Cardinal = 0; // @addr $87EBE8
  RobotModule: Cardinal = 0; // @addr $87EBEC

function GetRobotMultiSampleIndex: Integer; // @addr $7E7FC8

procedure InitializeRobotRuntime; // @addr 0x7E8014
procedure FinalizeRobotRuntime; // @addr 0x7E82E8
function FRun(const MapName, StartText, WinText, LossText, TerronName: WideString): Integer; // @addr $7E8F4C Native diagnostic name: GIRobot.FRun.

procedure RobotPlaySound(Name: PWideChar); stdcall; // @addr $7E831C
function RobotCreateSound(Name: PWideChar; Group, Looping: Integer): TSoundBufferControl; stdcall; // @addr $7E836C
procedure RobotFreeSound(Sound: TSoundBufferControl); stdcall; // @addr $7E83EC
procedure RobotStartSound(Sound: TSoundBufferControl); stdcall; // @addr $7E8404
function RobotIsSoundPlaying(Sound: TSoundBufferControl): Integer; stdcall; // @addr $7E8424
procedure RobotSetSoundVolume(Sound: TSoundBufferControl; Value: Single); stdcall; // @addr $7E844C
procedure RobotSetSoundPan(Sound: TSoundBufferControl; Value: Single); stdcall; // @addr $7E8464
function RobotGetSoundVolume(Sound: TSoundBufferControl): Single; stdcall; // @addr $7E847C
function RobotGetSoundPan(Sound: TSoundBufferControl): Single; stdcall; // @addr $7E84A0
procedure RobotRenderText(Text, FontName: PWideChar; Color: Cardinal;
  Width, Height, AlignX, AlignY, Wrap, OffsetX, OffsetY: Integer;
  Clip: PRect; Image: PRobotTextImage); stdcall; // @addr $7E8740
procedure RobotFreeText(Image: PRobotTextImage); stdcall; // @addr $7E8D9C
procedure RobotSetProgress(Fraction: Single); stdcall; // @addr $7E8DC4
function RobotGetMusicVolume: Single; stdcall; // @addr $7E8E74
procedure RobotSetMusicVolume(Value: Single); stdcall; // @addr $7E8E88
procedure RobotPlayMusic; stdcall; // @addr $7E8EF0
procedure RobotReleaseTextures; stdcall; // @addr $7E8F44

implementation

uses GR_Main, GlobalsV, EC_Mem, EC_Str, GR_Music, GR_DX, fPanelLoad, SysUtils, Classes, EC_Cache, EC_CacheFont, GI_MessageLoop, EC_HsFile, aGalaxy;

{ @routine $7E7FC8 GetRobotMultiSampleIndex }
function GetRobotMultiSampleIndex: Integer;
var I: Integer;
begin
  for I := 0 to SupportedMultiSampleCount - 1 do
    if SupportedMultiSamples[I] = RobotFSAASamples then
    begin
      Result := I;
      Exit;
    end;
  Result := 0;
end;
{ @end $7E7FC8 }

{ @routine $7E8014 InitializeRobotRuntime }
procedure InitializeRobotRuntime;
var GetInterface: TGetRobotInterface;
    OverrideName: WideString;
    Callbacks: PRobotCallbacks;
begin
  FinalizeRobotRuntime;
  if IsInstallFeatureEnabled('Robot') then
  begin
    Callbacks := @RobotCallbacks;
    FillChar(Callbacks^, SizeOf(TRobotCallbacks), 0);
    RobotCallbacks.PlaySound := RobotPlaySound;
    RobotCallbacks.CreateSound := RobotCreateSound;
    RobotCallbacks.FreeSound := RobotFreeSound;
    RobotCallbacks.StartSound := RobotStartSound;
    RobotCallbacks.IsSoundPlaying := RobotIsSoundPlaying;
    RobotCallbacks.SetSoundVolume := RobotSetSoundVolume;
    RobotCallbacks.SetSoundPan := RobotSetSoundPan;
    RobotCallbacks.GetSoundVolume := RobotGetSoundVolume;
    RobotCallbacks.GetSoundPan := RobotGetSoundPan;
    RobotCallbacks.RenderText := RobotRenderText;
    RobotCallbacks.FreeText := RobotFreeText;
    RobotCallbacks.SetProgress := RobotSetProgress;
    RobotCallbacks.PlayMusic := RobotPlayMusic;
    RobotCallbacks.ReleaseTextures := RobotReleaseTextures;
    RobotCallbacks.GetMusicVolume := RobotGetMusicVolume;
    RobotCallbacks.SetMusicVolume := RobotSetMusicVolume;
    if DirectXVersion >= $90000 then
    begin
      if LanguageDataConfig.GetBlock('RobotsMap').CountParams('MatrixOverride') > 0 then
      begin
        OverrideName := LanguageDataConfig.GetBlock('RobotsMap').GetParam('MatrixOverride');
        RobotModule := LoadLibraryW(PWideChar(OverrideName));
      end
      else RobotModule := Windows.LoadLibrary('MatrixGame.dll');
      if RobotModule <> 0 then
      begin
        GetInterface := GetProcAddress(RobotModule, 'GetRobotInterface');
        if GetInterface() = nil then
        begin
          FreeLibrary(RobotModule);
          RobotModule := 0;
        end
        else
        begin
          RobotInterface := GetInterface();
          RobotInterface.Initialize(@RobotCallbacks);
          AppendLogLineThreadSafe('Load MatrixGame.dll .... ok');
          AppendLogLineThreadSafe(AnsiString('Robot.Support()=' + IntToWideString(RobotInterface.Support())));
        end;
      end;
    end;
  end;
end;
{ @end $7E8014 }

{ @routine $7E82E8 FinalizeRobotRuntime }
procedure FinalizeRobotRuntime;
begin
  if RobotInterface <> nil then
  begin
    RobotInterface.Finalize;
    RobotInterface := nil;
    if RobotModule <> 0 then
    begin
      FreeLibrary(RobotModule);
      RobotModule := 0;
    end;
  end;
end;
{ @end $7E82E8 }

{ @routine $7E831C RobotPlaySound }
procedure RobotPlaySound(Name: PWideChar); stdcall;
begin
  SoundManager.PlaySound(WideString(Name));
end;
{ @end $7E831C }

{ @routine $7E836C RobotCreateSound }
function RobotCreateSound(Name: PWideChar; Group, Looping: Integer): TSoundBufferControl; stdcall;
var Sound: TSoundBufferControl;
begin
  Sound := TSoundBufferControl.Create;
  if RobotSound then Sound.Configure(WideString(Name), Group, Looping <> 0);
  Result := Sound;
end;
{ @end $7E836C }

{ @routine $7E83EC RobotFreeSound }
procedure RobotFreeSound(Sound: TSoundBufferControl); stdcall;
begin
  if Sound <> nil then Sound.Free;
end;
{ @end $7E83EC }

{ @routine $7E8404 RobotStartSound }
procedure RobotStartSound(Sound: TSoundBufferControl); stdcall;
begin
  if Sound <> nil then if RobotSound then Sound.Play;
end;
{ @end $7E8404 }

{ @routine $7E8424 RobotIsSoundPlaying }
function RobotIsSoundPlaying(Sound: TSoundBufferControl): Integer; stdcall;
begin
  Result := 0;
  if Sound <> nil then Result := Integer(Sound.IsPlaying);
end;
{ @end $7E8424 }

{ @routine $7E844C RobotSetSoundVolume }
procedure RobotSetSoundVolume(Sound: TSoundBufferControl; Value: Single); stdcall;
begin
  if Sound <> nil then Sound.SetVolume(Value);
end;
{ @end $7E844C }

{ @routine $7E8464 RobotSetSoundPan }
procedure RobotSetSoundPan(Sound: TSoundBufferControl; Value: Single); stdcall;
begin
  if Sound <> nil then Sound.SetPan(Value);
end;
{ @end $7E8464 }

{ @routine $7E847C RobotGetSoundVolume }
function RobotGetSoundVolume(Sound: TSoundBufferControl): Single; stdcall;
begin
  if Sound = nil then Result := 0 else Result := Sound.Volume;
end;
{ @end $7E847C }

{ @routine $7E84A0 RobotGetSoundPan }
function RobotGetSoundPan(Sound: TSoundBufferControl): Single; stdcall;
begin
  if Sound = nil then Result := 0 else Result := Sound.Pan;
end;
{ @end $7E84A0 }

{ @routine $7E8740 RobotRenderText }
procedure RobotRenderText(Text, FontName: PWideChar; Color: Cardinal;
  Width, Height, AlignX, AlignY, Wrap, OffsetX, OffsetY: Integer;
  Clip: PRect; Image: PRobotTextImage); stdcall;
var
  TopAdjustment: Integer;
  Lines: TStringsEC;
  Font: TCFontEC;
  WrappedLines: TStringsEC;
  Buffer: TGraphBufGR;
  Control: TCFontControlEC;
  DrawX, DrawY, CurrentY: Integer;
  ImageSize: TPoint;
  DrawClip, Bounds, SourceClip: TRect;

  // @nested $7E84C4 MeasureRobotTextSize
  function MeasureRobotTextSize: TPoint; // @addr $7E84C4 @ida "void __usercall $name(TPoint *Result@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x7E882B"
  var
    Y: Integer;
    First: Boolean;
    MergedBounds, LineBounds: TRect;
  begin
    MergedBounds.Left := 0; MergedBounds.Right := 0;
    MergedBounds.Top := 0; MergedBounds.Bottom := 0;
    Y := 0;
    Lines.First;
    if Wrap = 0 then
    begin
      if not Lines.IsAtEnd then
      begin
        MergedBounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, @TopAdjustment);
        Inc(Y, Font.GetLineHeight);
        Lines.Next;
      end;
      while not Lines.IsAtEnd do
      begin
        LineBounds := Font.MeasureTaggedTextBounds(Lines.GetCurrentText, 0, Y, nil);
        Windows.UnionRect(MergedBounds, MergedBounds, LineBounds);
        Inc(Y, Font.GetLineHeight);
        Lines.Next;
      end;
    end
    else
    begin
      First := True;
      while not Lines.IsAtEnd do
      begin
        Font.WrapTaggedTextIntoLines(WrappedLines, Lines.GetCurrentText, Width - 4);
        if not WrappedLines.IsEmpty then
        begin
          WrappedLines.First;
          if First then
          begin
            MergedBounds := Font.MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, Y, @TopAdjustment);
            First := False;
            Inc(Y, Font.GetLineHeight);
            WrappedLines.Next;
          end;
          while not WrappedLines.IsAtEnd do
          begin
            LineBounds := Font.MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, Y, nil);
            Windows.UnionRect(MergedBounds, MergedBounds, LineBounds);
            Inc(Y, Font.GetLineHeight);
            WrappedLines.Next;
          end;
        end;
        Lines.Next;
      end;
    end;
    Result := Classes.Point(MergedBounds.Right - MergedBounds.Left, MergedBounds.Bottom - MergedBounds.Top);
  end;

begin
  Control := nil; Font := nil; Lines := nil; WrappedLines := nil;
  try
    Lines := TStringsEC.Create;
    Lines.SetText(WideString(Text));
    Control := TCFontControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(WideString(FontName));
    Font := AcquireCachedFont(Control);
    Font.ResetTextMeasureState;
    Font.UseARGBColors := True;
    Font.ColorTagsEnabled := False;
    if Wrap <> 0 then WrappedLines := TStringsEC.Create;
    if (Width = 0) and (Wrap <> 0) then RaiseWideMessage('robot text');
    ImageSize := MeasureRobotTextSize;
    SourceClip := Clip^;
    if Width = 0 then
    begin
      Width := ImageSize.X + 4;
      SourceClip.Right := Width;
    end;
    if Height = 0 then
    begin
      Height := ImageSize.Y + 4;
      SourceClip.Bottom := Height;
    end;
    Buffer := TGraphBufGR.Create(False);
    Buffer.AllocateRgbaTight(Width, Height);
    Buffer.ClearPixels;
    Image.Buffer := Buffer;
    Image.Pixels := Buffer.GetPixels;
    Image.Pitch := Buffer.PitchBytes;
    Image.Width := Buffer.Width;
    Image.Height := Buffer.Height;
    DrawClip := Classes.Rect(0, 0, Width, Height);
    if not Windows.IntersectRect(DrawClip, DrawClip, SourceClip) then Exit;
    DrawX := 0; DrawY := 0;
    if (AlignX = 0) or (Wrap <> 0) then DrawX := 2
    else if AlignX = 2 then DrawX := Width - ImageSize.X - 2
    else if AlignX = 1 then DrawX := Width div 2 - ImageSize.X div 2
    else if AlignX = 3 then DrawX := 2;
    if AlignY = 0 then DrawY := TopAdjustment + 2
    else if AlignY = 2 then DrawY := Height - ImageSize.Y - 2 + TopAdjustment
    else if AlignY = 1 then DrawY := Height div 2 - ImageSize.Y div 2 + TopAdjustment
    else if AlignY = 3 then DrawY := TopAdjustment + 2;
    Font.ColorTagsEnabled := True;
    Font.DefaultColor := Color;
    if Wrap = 0 then
    begin
      if AlignY = 1 then
        CurrentY := Height div 2 - (Font.GetLineHeight * (Lines.GetCount - 1) + Font.GetCenteringHeight) div 2 + Font.GetCenteringHeight
      else CurrentY := Font.AboveBaseline + DrawY - 2;
      Lines.First;
      while not Lines.IsAtEnd do
      begin
        Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, DrawX + OffsetX, CurrentY + OffsetY, Lines.GetCurrentText, DrawClip);
        Inc(CurrentY, Font.GetLineHeight);
        Lines.Next;
      end;
    end
    else
    begin
      CurrentY := Font.AboveBaseline + DrawY - 2;
      Lines.First;
      while not Lines.IsAtEnd do
      begin
        Font.WrapTaggedTextIntoLines(WrappedLines, Lines.GetCurrentText, Width - 4);
        WrappedLines.First;
        while not WrappedLines.IsAtEnd do
        begin
          if AlignX = 0 then
            Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, DrawX + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, DrawClip)
          else if AlignX = 2 then
          begin
            Bounds := Font.MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, 0, nil);
            Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, Width - (Bounds.Right - Bounds.Left) - 2 + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, DrawClip);
          end
          else if AlignX = 1 then
          begin
            Bounds := Font.MeasureTaggedTextBounds(WrappedLines.GetCurrentText, 0, 0, nil);
            Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, (Width - 0) div 2 - (Bounds.Right - Bounds.Left) div 2 + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, DrawClip);
          end
          else if (AlignX = 3) and not WrappedLines.IsAtLast then
            Font.DrawJustifiedTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, DrawX + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, Width - 4, DrawClip)
          else
            Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, DrawX + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, DrawClip);
          Inc(CurrentY, Font.GetLineHeight);
          WrappedLines.Next;
        end;
        Lines.Next;
      end;
    end;
  finally
    if Font <> nil then Control.Release;
    if Control <> nil then Control.Free;
    if Lines <> nil then Lines.Free;
    if WrappedLines <> nil then WrappedLines.Free;
  end;
end;
{ @end $7E8740 }

{ @routine $7E8D9C RobotFreeText }
procedure RobotFreeText(Image: PRobotTextImage); stdcall;
begin
  if Image.Buffer <> nil then Image.Buffer.Free;
  FillChar(Image^, SizeOf(TRobotTextImage), 0);
end;
{ @end $7E8D9C }

{ @routine $7E8DC4 RobotSetProgress }
procedure RobotSetProgress(Fraction: Single); stdcall;
var Panel: TfPanelLoad;
begin
  if Direct3DDevice <> nil then
    if ActiveLoadPanel <> nil then
    begin
      Panel := ActiveLoadPanel;
      Panel.SelectBackgroundStyle(3);
      Panel.RefreshBackgroundImages;
      Panel.SetShutterOpenFraction(0);
      Panel.SetProgress(Fraction);
      Panel.Show;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).SetCursorActive(False);
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).InvalidateViewport;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).Present;
      Panel.Hide;
    end;
end;
{ @end $7E8DC4 }

{ @routine $7E8E74 RobotGetMusicVolume }
function RobotGetMusicVolume: Single; stdcall;
begin
  Result := MusicVolumeScale;
end;
{ @end $7E8E74 }

{ @routine $7E8E88 RobotSetMusicVolume }
procedure RobotSetMusicVolume(Value: Single); stdcall;
var Buffer: TSoundBuffer;
begin
  MusicVolumeScale := Value;
  if SoundManager <> nil then
  begin
    Buffer := SoundManager.FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.Streaming then Buffer.SetVolume(MusicVolume * MusicVolumeScale);
      Buffer := Buffer.Next;
    end;
  end;
end;
{ @end $7E8E88 }

{ @routine $7E8EF0 RobotPlayMusic }
procedure RobotPlayMusic; stdcall;
begin
  if MusicEnabled and RobotMusic and not MusicManager.HasSelectedMusic then
  begin
    MusicManager.HasSelectedMusic;
    MusicManager.PlayCategory('Robot');
  end;
end;
{ @end $7E8EF0 }

{ @routine $7E8F44 RobotReleaseTextures }
procedure RobotReleaseTextures; stdcall;
begin
  ReleaseAllTextureSurfaces;
end;
{ @end $7E8F44 }

{ @routine $7E8F4C FRun }
function FRun(const MapName, StartText, WinText, LossText, TerronName: WideString): Integer;
var
  SavedDirectory, RobotDirectory: AnsiString;
  SavedSoundVolume, SavedMusicVolume: Single;
  Failed: Boolean;
  CursorState: TCursorStateGI;
  Memory: TMemoryStatusEx;
begin
  if MusicEnabled and MusicManager.HasSelectedMusic then MusicManager.RequestFadeOut;
  AppendLogLineThreadSafe('Preparing to start planetary battle');
  SavedDirectory := GetCurrentDir;
  LooseFileRoot := SavedDirectory + '\';
  try
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).CaptureCursorState(@CursorState);
    if InstallConfig.CountParams('RobotPath') > 0 then
    begin
      SetCurrentDir(AnsiString(InstallConfig.GetParam('RobotPath')));
      RobotDirectory := GetCurrentDir;
    end;
    RobotSetProgress(0);
    Memory.Length := SizeOf(Memory);
    GlobalMemoryStatusEx(Memory);
    if MemorySnapshotActive or (Galaxy <> nil) or ((Int64(Memory.AvailPhys) shr 30) <= 0) then GlobalCache.TrimToBudget(0);
    Result := 1;
    SavedSoundVolume := SoundVolume;
    SavedMusicVolume := MusicVolume;
    SoundVolume := RobotSoundVolume;
    MusicVolume := RobotMusicVolume;
    RobotSettings.Brightness := RobotBrightness / 2 + 0.5;
    RobotSettings.Contrast := RobotContrast / 2 + 0.5;
    RobotSettings.ColorDepth := 32;
    if Direct3DPresentParameters.Windowed then
    begin
      if AlternateViewportEnabled then
      begin
        RobotSettings.ScreenWidth := PresentationWidth;
        RobotSettings.ScreenHeight := PresentationHeight;
      end
      else
      begin
        RobotSettings.ScreenWidth := GameScreenWidth;
        RobotSettings.ScreenHeight := GameScreenHeight;
      end;
      RobotSettings.RefreshRate := 0;
    end
    else
    begin
      if RobotDisplayModes[SelectedRobotDisplayMode].Width = 0 then
      begin
        if AlternateViewportEnabled then
        begin
          RobotSettings.ScreenWidth := PresentationWidth;
          RobotSettings.ScreenHeight := PresentationHeight;
        end
        else
        begin
          RobotSettings.ScreenWidth := GameScreenWidth;
          RobotSettings.ScreenHeight := GameScreenHeight;
        end;
        RobotSettings.RefreshRate := GameDisplayModes[SelectedGameDisplayMode].RefreshRate;
      end
      else
      begin
        RobotSettings.ScreenWidth := RobotDisplayModes[SelectedRobotDisplayMode].Width;
        RobotSettings.ScreenHeight := RobotDisplayModes[SelectedRobotDisplayMode].Height;
        RobotSettings.RefreshRate := RobotDisplayModes[SelectedRobotDisplayMode].RefreshRate;
      end;
    end;
    RobotSettings.VSync := RobotVSync;
    RobotSettings.FSAASamples := RobotFSAASamples;
    RobotSettings.Anisotropy := RobotAnisotropy;
    RobotSettings.MaxDistance := RobotMaxDistance / 100;
    RobotBattleStatistics[0] := 0; RobotBattleStatistics[1] := 0;
    RobotBattleStatistics[2] := 0; RobotBattleStatistics[3] := 0;
    RobotBattleStatistics[4] := 0; RobotBattleStatistics[5] := 0;
    RobotSettings.Direct3D := Pointer(Direct3D);
    RobotSettings.Device := Pointer(Direct3DDevice);
    AppendLogLineThreadSafe('Starting planetary battle');
    RobotBattleActive := True;
    Failed := False;
    try
      if RobotInterface <> nil then
      begin
        if LanguageDataConfig.GetBlock('RobotsMap').CountParams('CfgOverride') > 0 then
          Result := RobotInterface.Run(HInstance, MainWindowHandle, PWideChar(MapName), @RobotSettings,
            PWideChar(LanguageDataConfig.GetBlock('RobotsMap').GetParam('CfgOverride')),
            PWideChar(StartText), PWideChar(WinText), PWideChar(LossText), PWideChar(TerronName), @RobotBattleStatistics[0])
        else
          Result := RobotInterface.Run(HInstance, MainWindowHandle, PWideChar(MapName), @RobotSettings,
            PWideChar(LanguageInstallConfig.GetParam('Lang')), PWideChar(StartText), PWideChar(WinText),
            PWideChar(LossText), PWideChar(TerronName), @RobotBattleStatistics[0]);
      end;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        Failed := True;
      end;
    end;
    if Result >= 100 then
    begin
      Dec(Result, 100);
      if Result >= 1 then AppendLogLineThreadSafe('Warning! There was an error on exit from planetary battle!');
      if Result = 0 then Failed := True;
    end;
    RobotBattleActive := False;
    AppendLogLineThreadSafe('Planetary battle finished');
    GR_DXReset;
    Windows.SetWindowTextA(MainWindowHandle, 'Rangers');
    ApplyGammaRamp(DisplayBrightness, DisplayContrast);
    SoundVolume := SavedSoundVolume;
    MusicVolume := SavedMusicVolume;
    MusicVolumeScale := 1;
    if (Result = 0) and not Failed then
    begin
      ExitScreenLoop := True;
      RequestedScreenId := screenNone;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
      Result := 0;
      Exit;
    end;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RestoreCursorState(@CursorState);
    if ShowSystemMouse then
      while ShowCursor(True) < 0 do
    else
      while ShowCursor(False) >= 0 do;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).InvalidateViewport;
  finally
    SetCurrentDir(SavedDirectory);
    LooseFileRoot := '';
  end;
  AppendLogLineThreadSafe('Cleanup after planetary battle finished');
  if MusicEnabled and MusicManager.HasSelectedMusic then MusicManager.RequestFadeOut;
  if Failed then raise Exception.Create('Error in GIRobot.FRun');
end;
{ @end $7E8F4C }

end.
