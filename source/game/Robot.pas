unit Robot;
// Unit bracket (inferred): .text 0x0083C12C..0x0083D9AF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008779D4..0x008779DB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows, Types, GR_Sound, GR_GraphBuf, aGalaxyStruct;

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
  TRobotDisplaySettingsPrefix = record // @size $38 Native settings block.
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
    TerronName: PWideChar; Statistics: PPlanetBattleStatistics): Integer; stdcall;
  TRobotInterfacePrefix = record // @size $10 Dispatch table returned by GetRobotInterface.
    Initialize: TRobotInitialize; // @offset $00
    Finalize: TRobotAction; // @offset $04
    Support: TRobotSupportQuery; // @offset $08 Zero allows entry.
    Run: TRobotRun; // @offset $0C
  end;
  PRobotInterfacePrefix = ^TRobotInterfacePrefix;
  TGetRobotInterface = function: PRobotInterfacePrefix; stdcall;

var
  RobotInterface: PRobotInterfacePrefix = nil; // @addr $87F6B0 Borrowed DLL dispatch table; nil until successful initialization.
  // Native compiler-generated initialization $8779D4 decrements the unit counter
  // at $88C3A8; finalization $83D970 increments it and clears this array at zero.
  // The managed global below supplies that DCC32 lifetime code automatically.
var
  RobotCallbacks: TRobotCallbacks; // @addr $88C34C
  RobotBattleStatistics: TPlanetBattleStatistics; // @addr $88C38C Player-side SRobotGameState returned by MatrixGame.Run.
  SupportedMultiSamples: array of Integer; // @addr $88C3A4
  RobotSettings: TRobotDisplaySettingsPrefix = (Direct3D: nil; Device: nil;
    ShowStencilShadows: True; ShowProjShadows: True; SelectEx: False;
    LandTexturesGloss: True; ObjTexturesGloss: True; SoftwareCursor: False;
    Sky: 2; RobotShadow: 1; ColorDepth: 32; ScreenWidth: 1024; ScreenHeight: 768;
    RefreshRate: 0; Brightness: 0.5; Contrast: 0.5; FSAASamples: 0;
    Anisotropy: 0; MaxDistance: 0; VSync: False); // @addr $87F6B4
  RobotSound: Boolean = True; // @addr $87F6EC
  RobotMusic: Boolean = True; // @addr $87F6F0
  RobotVSync: Boolean = False; // @addr $87F6F4
  RobotFSAASamples: Integer = 0; // @addr $87F6F8
  RobotAnisotropy: Integer = 0; // @addr $87F6FC
  RobotMaxDistance: Integer = 0; // @addr $87F700
  SupportedMultiSampleCount: Integer = 0; // @addr $87F704
var
  MaximumAnisotropy: Cardinal = 0; // @addr $87F708
  RobotModule: Cardinal = 0; // @addr $87F70C

function GetRobotMultiSampleIndex: Integer; // @addr $83C148

procedure InitializeRobotRuntime; // @addr 0x83C194
procedure FinalizeRobotRuntime; // @addr 0x83C468
function FRun(const MapName, StartText, WinText, LossText, TerronName: WideString): Integer; // @addr $83D0CC Native diagnostic name: GIRobot.FRun.

procedure RobotPlaySound(Name: PWideChar); stdcall; // @addr $83C49C
function RobotCreateSound(Name: PWideChar; Group, Looping: Integer): TSoundBufferControl; stdcall; // @addr $83C4EC
procedure RobotFreeSound(Sound: TSoundBufferControl); stdcall; // @addr $83C56C
procedure RobotStartSound(Sound: TSoundBufferControl); stdcall; // @addr $83C584
function RobotIsSoundPlaying(Sound: TSoundBufferControl): Integer; stdcall; // @addr $83C5A4
procedure RobotSetSoundVolume(Sound: TSoundBufferControl; Value: Single); stdcall; // @addr $83C5CC
procedure RobotSetSoundPan(Sound: TSoundBufferControl; Value: Single); stdcall; // @addr $83C5E4
function RobotGetSoundVolume(Sound: TSoundBufferControl): Single; stdcall; // @addr $83C5FC
function RobotGetSoundPan(Sound: TSoundBufferControl): Single; stdcall; // @addr $83C620
procedure RobotRenderText(Text, FontName: PWideChar; Color: Cardinal;
  Width, Height, AlignX, AlignY, Wrap, OffsetX, OffsetY: Integer;
  Clip: PRect; Image: PRobotTextImage); stdcall; // @addr $83C8C0
procedure RobotFreeText(Image: PRobotTextImage); stdcall; // @addr $83CF1C
procedure RobotSetProgress(Fraction: Single); stdcall; // @addr $83CF44
function RobotGetMusicVolume: Single; stdcall; // @addr $83CFF4
procedure RobotSetMusicVolume(Value: Single); stdcall; // @addr $83D008
procedure RobotPlayMusic; stdcall; // @addr $83D070
procedure RobotReleaseTextures; stdcall; // @addr $83D0C4

implementation

uses GR_Main, GlobalsV, EC_Mem, EC_Str, GR_Music, GR_DX, fPanelLoad, SysUtils, Classes, EC_Cache, EC_CacheFont, GI_MessageLoop, EC_HsFile, aGalaxy;

{ @routine $83C148 GetRobotMultiSampleIndex }
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
{ @end $83C148 }

{ @routine $83C194 InitializeRobotRuntime }
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
{ @end $83C194 }

{ @routine $83C468 FinalizeRobotRuntime }
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
{ @end $83C468 }

{ @routine $83C49C RobotPlaySound }
procedure RobotPlaySound(Name: PWideChar); stdcall;
begin
  SoundManager.PlaySound(WideString(Name));
end;
{ @end $83C49C }

{ @routine $83C4EC RobotCreateSound }
function RobotCreateSound(Name: PWideChar; Group, Looping: Integer): TSoundBufferControl; stdcall;
var Sound: TSoundBufferControl;
begin
  Sound := TSoundBufferControl.Create;
  if RobotSound then Sound.Configure(WideString(Name), Group, Looping <> 0);
  Result := Sound;
end;
{ @end $83C4EC }

{ @routine $83C56C RobotFreeSound }
procedure RobotFreeSound(Sound: TSoundBufferControl); stdcall;
begin
  if Sound <> nil then Sound.Free;
end;
{ @end $83C56C }

{ @routine $83C584 RobotStartSound }
procedure RobotStartSound(Sound: TSoundBufferControl); stdcall;
begin
  if Sound <> nil then if RobotSound then Sound.Play;
end;
{ @end $83C584 }

{ @routine $83C5A4 RobotIsSoundPlaying }
function RobotIsSoundPlaying(Sound: TSoundBufferControl): Integer; stdcall;
begin
  Result := 0;
  if Sound <> nil then Result := Integer(Sound.IsPlaying);
end;
{ @end $83C5A4 }

{ @routine $83C5CC RobotSetSoundVolume }
procedure RobotSetSoundVolume(Sound: TSoundBufferControl; Value: Single); stdcall;
begin
  if Sound <> nil then Sound.SetVolume(Value);
end;
{ @end $83C5CC }

{ @routine $83C5E4 RobotSetSoundPan }
procedure RobotSetSoundPan(Sound: TSoundBufferControl; Value: Single); stdcall;
begin
  if Sound <> nil then Sound.SetPan(Value);
end;
{ @end $83C5E4 }

{ @routine $83C5FC RobotGetSoundVolume }
function RobotGetSoundVolume(Sound: TSoundBufferControl): Single; stdcall;
begin
  if Sound = nil then Result := 0 else Result := Sound.Volume;
end;
{ @end $83C5FC }

{ @routine $83C620 RobotGetSoundPan }
function RobotGetSoundPan(Sound: TSoundBufferControl): Single; stdcall;
begin
  if Sound = nil then Result := 0 else Result := Sound.Pan;
end;
{ @end $83C620 }

function CenterSpan(SpanStart, SpanEnd, ContentStart, ContentEnd: Integer): Integer; inline;
begin
  Result := SpanStart + (SpanEnd - SpanStart) div 2 - (ContentEnd - ContentStart) div 2;
end;

{ @routine $83C8C0 RobotRenderText }
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

  // @nested $83C644 MeasureRobotTextSize
  function MeasureRobotTextSize: TPoint; // @addr $83C644 @calls "0x83C9AB"
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
            Font.DrawTaggedText32(Buffer.GetPixels, Buffer.PitchBytes, CenterSpan(0, Width, Bounds.Left, Bounds.Right) + OffsetX, CurrentY + OffsetY, WrappedLines.GetCurrentText, DrawClip);
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
{ @end $83C8C0 }

{ @routine $83CF1C RobotFreeText }
procedure RobotFreeText(Image: PRobotTextImage); stdcall;
begin
  if Image.Buffer <> nil then Image.Buffer.Free;
  FillChar(Image^, SizeOf(TRobotTextImage), 0);
end;
{ @end $83CF1C }

{ @routine $83CF44 RobotSetProgress }
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
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).SetCursorActive(False);
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).InvalidateViewport;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).Present;
      Panel.Hide;
    end;
end;
{ @end $83CF44 }

{ @routine $83CFF4 RobotGetMusicVolume }
function RobotGetMusicVolume: Single; stdcall;
begin
  Result := MusicVolumeScale;
end;
{ @end $83CFF4 }

{ @routine $83D008 RobotSetMusicVolume }
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
{ @end $83D008 }

{ @routine $83D070 RobotPlayMusic }
procedure RobotPlayMusic; stdcall;
begin
  if MusicEnabled and RobotMusic and not MusicManager.HasSelectedMusic then
  begin
    MusicManager.HasSelectedMusic;
    MusicManager.PlayCategory('Robot');
  end;
end;
{ @end $83D070 }

{ @routine $83D0C4 RobotReleaseTextures }
procedure RobotReleaseTextures; stdcall;
begin
  ReleaseAllTextureSurfaces;
end;
{ @end $83D0C4 }

{ @routine $83D0CC FRun }
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
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).CaptureCursorState(@CursorState);
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
    RobotBattleStatistics.SignedTimeMs := 0; RobotBattleStatistics.RobotsBuilt := 0;
    RobotBattleStatistics.RobotsDestroyed := 0; RobotBattleStatistics.TurretsBuilt := 0;
    RobotBattleStatistics.TurretsDestroyed := 0; RobotBattleStatistics.BuildingsDestroyed := 0;
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
            PWideChar(StartText), PWideChar(WinText), PWideChar(LossText), PWideChar(TerronName), @RobotBattleStatistics)
        else
          Result := RobotInterface.Run(HInstance, MainWindowHandle, PWideChar(MapName), @RobotSettings,
            PWideChar(LanguageInstallConfig.GetParam('Lang')), PWideChar(StartText), PWideChar(WinText),
            PWideChar(LossText), PWideChar(TerronName), @RobotBattleStatistics);
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
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
      Result := 0;
      Exit;
    end;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RestoreCursorState(@CursorState);
    if ShowSystemMouse then
      while ShowCursor(True) < 0 do
    else
      while ShowCursor(False) >= 0 do;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).InvalidateViewport;
  finally
    SetCurrentDir(SavedDirectory);
    LooseFileRoot := '';
  end;
  AppendLogLineThreadSafe('Cleanup after planetary battle finished');
  if MusicEnabled and MusicManager.HasSelectedMusic then MusicManager.RequestFadeOut;
  if Failed then raise Exception.Create('Error in GIRobot.FRun');
end;
{ @end $83D0CC }

end.
