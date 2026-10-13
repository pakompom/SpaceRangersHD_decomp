unit GR_Main;

interface

uses GR_Music, DirectSound, EC_Thread, GR_Sound, EC_Data, EC_OKGF, EC_Buf, GR_GraphBufPal, Direct3D9, EC_Cache, EC_BlockPar, EC_Str, GR_GraphBuf, SyncObjs, Classes, Types;

const
  // Shared by version display, configuration migration and data compatibility checks.
  GameVersionText = '2.1.2500';
  ModSelectionConfigPath = 'Mods\ModCFG.txt';

type
  TWindowMessageCallbackGR = procedure(Message, WParam: Cardinal; LParam: Integer) of object;
  TRuntimeCallbackGR = procedure;
  TDebugKeyCallbackGR = procedure(Key: Word);
  TTriangleRasterizer16 = procedure(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Clip: PRect); cdecl;
  TLineRasterizer16 = procedure(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal); cdecl;
  TBlendPixel16 = procedure(Pixel: Pointer; Color: Word; Alpha: Byte); cdecl;

  TMemoryStatusEx = record // @size 64
    Length: Cardinal; // @offset 0
    MemoryLoad: Cardinal; // @offset 4
    TotalPhys: UInt64; // @offset 8
    AvailPhys: UInt64; // @offset 16
    TotalPageFile: UInt64; // @offset 24
    AvailPageFile: UInt64; // @offset 32
    TotalVirtual: UInt64; // @offset 40
    AvailVirtual: UInt64; // @offset 48
    AvailExtendedVirtual: UInt64; // @offset 56
  end;

  TCursorUnit = class(TObject) // @size 0x1C
  public
    Prev: TCursorUnit; // @offset 0x04
    Next: TCursorUnit; // @offset 0x08
    Name: WideString; // @offset 0x0C
    ImagePath: WideString; // @offset 0x10
    HotSpot: TPoint; // @offset 0x14
  end;

  PCCSnapshot = ^TCCSnapshot;
  // Links hide the live snapshot among randomized decoys. Unidentified payload
  // slots remain explicit alongside the recovered status/checksum channels.
  TCCSnapshot = record // @size $30
    Prev: PCCSnapshot; // @offset $00
    Next: PCCSnapshot; // @offset $04
    ResourceChecksumFailed: Boolean; // @offset $08
    TamperDetected: Boolean; // @offset $09
    Flag0A: Boolean; // @offset $0A
    ProtectedStateXorSeed: Integer; // @offset $0C Nonzero while galaxy state is XOR-obfuscated ($7DAA3C/$7DAA84).
    Value10: Integer; // @offset $10
    IntegrityStatus: Integer; // @offset $14
    IntegrityError: Integer; // @offset $18
    IntegrityChecksum: Cardinal; // @offset $1C
    IntegrityChecksum1: Cardinal; // @offset $20
    IntegrityChecksum2: Cardinal; // @offset $24
    EncodedCheatPoints: Integer; // @offset $28
    EditableStateApplied: Boolean; // @offset $2C Set by ApplyEditableState ($7D5418); saved and checked for score eligibility and cheat warnings.
  end;
  TCCInterface = class(TObject) // @size 0x10
  public
    Buffer: TBufEC; // @offset $04
    SnapshotHead: PCCSnapshot; // @offset $08
    Lock: TCriticalSection; // @offset 0x0C
    constructor Create; // @addr $7C06C8
    destructor Destroy; override; // @addr $7C0730
    procedure Reset; // @addr $7C076C
    function CreateEmptySnapshot: PCCSnapshot; // @addr $7C0898
    function GetSnapshot: PCCSnapshot; // @addr $7C07A0
    function CreateDecoy: PCCSnapshot; // @addr $7C07B8
    function CopySnapshot(Source: PCCSnapshot): PCCSnapshot; // @addr $7C08DC
    procedure CommitSnapshot(Snapshot: PCCSnapshot); // @addr $7C0938
    procedure ClearSnapshots; // @addr $7C0A10
    function GetResourceChecksumFailed: Boolean; // @addr $7C0A5C
    procedure SetResourceChecksumFailed(Value: Boolean); // @addr $7C0A80
    procedure SetFlag0A(Value: Boolean); // @addr $7C0B38
    function GetValue10: Integer; // @addr $7C0C28 Protected payload with unresolved purpose.
    procedure SetValue10(Value: Integer); // @addr $7C0C4C
    function GetFlag0A: Boolean; // @addr $7C0B14 Protected flag consumed by the dormant galaxy checksum; purpose unresolved.
    procedure SetEditableStateApplied(Value: Boolean); // @addr $7C0B94 Replaces the protected score-mod warning flag.
    function GetEditableStateApplied: Boolean; // @addr $7C0B70 Read under Lock; used for the score-mod cheat warning.
    procedure SetProtectedStateXorSeed(Value: Integer); // @addr $7C0BF0 Protected-state XOR seed; zero denotes restored state.
    function GetProtectedStateXorSeed: Integer; // @addr $7C0BCC @note "Protected-state XOR seed; zero denotes restored state. Rangers reads it after the screen loop."
    function GetTamperDetected: Boolean; // @addr 0x007C0AB8 @note "Reads the protected tamper flag under Lock. SetMoney checks its encoded mirror and rereads after Sleep(1); NextDay similarly checks ammunition."
    procedure SetTamperDetected(Value: Boolean); // @addr 0x007C0ADC @note "Copies the current snapshot, replaces byte 9 and commits it under Lock."
    function GetIntegrityStatus: Integer; // @addr $7C0C84
    procedure SetIntegrityStatus(Value: Integer); // @addr $7C0CA8
    function GetIntegrityError: Integer; // @addr $7C0CE0
    procedure SetIntegrityError(Value: Integer); // @addr $7C0D04
    function GetIntegrityChecksum: Cardinal; // @addr $7C0D3C
    procedure SetIntegrityChecksum(Value: Cardinal); // @addr $7C0D60
    function GetIntegrityChecksum1: Cardinal; // @addr $7C0D98
    procedure SetIntegrityChecksum1(Value: Cardinal); // @addr $7C0DBC
    function GetIntegrityChecksum2: Cardinal; // @addr $7C0DF4
    procedure SetIntegrityChecksum2(Value: Cardinal); // @addr $7C0E18
    function GetEncodedCheatPoints: Integer; // @addr $7C0E50
    procedure SetEncodedCheatPoints(Value: Integer); // @addr $7C0E74
  end;

function AddCursorUnit: TCursorUnit; // @addr 0x007CC5C0
procedure RemoveCursorUnit(Cursor: TCursorUnit); // @addr 0x007CC600
function FindCursorByName(const Name: WideString): TCursorUnit; // @addr 0x007CC644 @note "Case-sensitive lookup; raises when absent."
procedure PostMouseMoveMessage; // @addr 0x007CC6A0 @note "Uses a zero key/button state."

procedure CheckRuntimeWatchdog; // @addr $7C3D80 @note "Native uses an explicit indirect jump into a generated fault sequence if the watchdog stops."
function MainWindowProc(Window, Message, WParam: Cardinal; LParam: Integer): Integer; stdcall; // @addr $7CAB90
procedure CaptureSavePreview; // @addr $7CB258 Creates a 300x225 RGB preview and equally sized scratch buffer.
procedure FreeSavePreviewBuffers; // @addr $7CB304
function GetGameUserDirectory: WideString; // @addr 0x007CD4E4 @note "Returns a trailing directory separator."
procedure CreateStartupLogFile; // @addr 0x007C3DB8
function MeasureCpuClockMHz: Double; // @addr $7CC6DC @note "Samples the low 32 bits of RDTSC over 200ms; returns 1500 on an exception."
function ReadRegistryText(Root: Cardinal; KeyPath, ValueName, DefaultValue: WideString): WideString; // @addr $7CC7B8 @note "ANSI registry API, fixed 2048-byte buffer, REG_SZ only."
function ReadRegistryInteger(Root: Cardinal; KeyPath, ValueName: WideString; DefaultValue: Integer): Integer; // @addr $7CC8F4
procedure ApplyProcessAffinity; // @addr $7C3D48
procedure CheckPlatformModules; // @addr $7BFDA0 @note "Native entry exits before the retained module/process checks; the entire dormant body is preserved."
procedure InitializePlatformRuntimeAndMainWindow; // @addr 0x007C3E7C
procedure LoadLanguageAndPackages; // @addr 0x007C44F8 @note "Falls back to Russian when the selected language is unavailable; raises on package-open failure."
procedure LoadSelectedModInstallBlocks; // @addr 0x007C4890
procedure ResetInstalledPackageState; // @addr 0x007C4C6C
procedure FinalizePlatformRuntime; // @addr 0x007C4CD8
function HasWow64Support: Boolean; // @addr 0x007C4D30 @note "Requires a WOW64 process and the filesystem-redirection and extended registry APIs."
procedure ApplyMainWindowGeometry; // @addr 0x007C4E68
procedure ShowAndFocusMainWindow; // @addr 0x007C508C
procedure LoadDatConfigAndModOverrides; // @addr 0x007C5288
procedure FreeDatConfigRoots; // @addr 0x007C58D8
function IsInstallFeatureEnabled(const Path: WideString): Boolean; // @addr $7CC558
procedure LoadInformationColorTags; // @addr $7CD074
procedure InitializeRuntimeAndSettings; // @addr 0x007C59B0
procedure FinalizeRuntimeAndSettings; // @addr 0x007C84A8

procedure EnumerateAndSelectDisplayModes; // @addr 0x007C859C @note "Keeps the highest refresh rate for each size. A zero-width entry means automatic resolution; a custom size may be appended."
procedure ConfigureDefaultRenderState; // @addr $7C8FD8
procedure PreparePresentationParameters; // @addr $7C9074
procedure FreeScreenRenderBuffers; // @addr $7CA554
procedure LogPresentationParameters; // @addr $7CDA80
function Direct3DErrorText(Code: Integer): AnsiString; // @addr $7CCA3C
procedure GR_DXInit; // @addr 0x007C91B4
procedure ApplyGammaRamp(Brightness, Contrast: Single); // @addr $7CA5AC @note "Linear RGB ramp with brightness/contrast endpoints; returns when no device is present."
procedure GR_DXReset; // @addr 0x007CA3DC
function BeginFramePresentation: Boolean; // @addr $7CAE98 @note "Increments the nesting count and always returns true."
procedure EndFramePresentation; // @addr $7CAEA4 @note "Presents at the outermost level, subject to the frame-rate limit."
procedure PresentScreenBuffer; // @addr $7CAEF8 @note "Hardware mode ends/presents/restarts the scene; software mode draws the buffer texture unless OffscreenTexture is assigned."
function GR_WinMessage(Callback: TWindowMessageCallbackGR): Integer; // @addr $7CA854 @note "Method callback receives Context/EAX, Message/EDX, WParam/ECX and LParam on stack. Returns zero when exiting."
procedure DrawOffscreenTexture; // @addr $7CB05C @note "Presents OffscreenTexture, fitting or cropping it to the viewport."
procedure CaptureScreenBackground(ApplyEffects: Boolean; UnusedOption: Byte); // @addr $7CB218
procedure CopyBgraToRgb24(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); // @addr $7CB33C
procedure CaptureRecordingFrame; // @addr $7CB414 @note "Copies a due software frame into the recording ring and flushes it when full."
procedure FlushRecordingFrames; // @addr $7CB494 @note "Writes pending RGB565 frames as sequential Film\\NNNNNN.bmp files."
function IsVirtualKeyDown(Key: Integer): Boolean; // @addr $7CC234 @note "Tests bit 15 of GetAsyncKeyState."

function LookupLocalizedTextByKey(const Path: WideString): WideString; // @addr 0x007CC250 @note "Returns one raw value, or a marker containing Path on lookup failure."
function LookupLocalizedTextOrEmpty(const Path: WideString): WideString; // @addr 0x007CC268 @note "Returns one raw value; missing paths return empty and may create intermediate blocks."
function FormatUnixDateTime(Value: Cardinal): WideString; // @addr $7CD008

function GiResourceSuffix: WideString; // @addr 0x007CC2A4 @note "Always returns 2 in this binary."
function GiResourceVariant: Integer; // @addr $7CC29C @note "Always returns 2; variant 1 retains the legacy quest-picture downscaling branch."
procedure AppendLogLineThreadSafe(const Text: AnsiString); // @addr 0x007CC2C8 @note "Appends a line to the session log and closes the file. The lock is not released if a write raises."
procedure AppendDebugLogLine(const Text: AnsiString); // @addr $7CC378 Creates #####add.log when absent; native unchecked TextFile I/O.
procedure AppendOptionalDebugLogLine(const Text: AnsiString); // @addr $7CC410 @note "Appends only when #####add.log already exists; shares SessionLogLock and native unchecked TextFile I/O."
procedure AppendLogTextThreadSafe(const Text: AnsiString); // @addr 0x007CC320 @note "Appends without a newline, flushes and closes the file."
procedure LogMemoryUsage; // @addr 0x007C03C0

// Delphi wrappers translate DLL exceptions into Exception objects.
function BeginImageRead(Source: Pointer; SourceSize: Integer; out Width, Height: Cardinal): POkgfReadContext; // @addr 0x007C0F8C @note "Borrows Source until ReadImagePixels consumes the context. Returns nil for unsupported input. Detection requires at least 34 bytes and accepts BMP, JFIF JPEG, PNG and supported PSD modes."
function ReadImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer; // @addr 0x007C1008 @note "Consumes Context on success; returns nonzero on success."
function BeginIndexedImageRead(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext; // @addr 0x007C108C @note "Borrows Source; accepts indexed PNG and indexed or grayscale PSD. Returns nil on failure. BytesPerPixel is one or two."
function ReadIndexedImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer; // @addr 0x007C1114 @note "Consumes Context on success. Palette requires the count returned by BeginIndexedImageRead."
function WritePngFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer; // @addr 0x007C118C
function WriteBmpFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer; // @addr 0x007C1218

// Delphi exception wrappers around the named OKGF/OKGR DLL exports.
// Ex_ distinguishes wrappers from DLL import symbols; full parameter types remain unresolved.
function Ex_OKGF_MulTable256x256: Pointer; // @addr 0x007C0EAC
function Ex_OKGF_DXVersion: Cardinal; // @addr 0x007C0F20
procedure Ex_OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C12B0
procedure Ex_OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C132C
procedure Ex_OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C13AC
procedure Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C142C
procedure Ex_OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C14B0
procedure Ex_OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C152C
procedure Ex_OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C15B8
function Ex_OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer; // @addr $7C1644
function Ex_OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $7C16D0
procedure Ex_OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C175C
procedure Ex_OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C17EC
function Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $7C1874
function Ex_OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $7C1908
procedure Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $7C1994
procedure Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA); // @addr $7C1A30
procedure Ex_OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect); // @addr $7C1AD8
procedure Ex_OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect); // @addr $7C1B68
procedure Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal); // @addr $7C1BF8
procedure Ex_OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word); // @addr $7C1C8C
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C1D20
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); // @addr $7C1DB4
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $7C1E54
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); // @addr $7C1EE4
function Ex_OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer; // @addr $7C1F84
procedure Ex_OKGR_RotateBuf_Free(Buffer: Pointer); // @addr $7C200C
procedure Ex_OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect); // @addr $7C2080
procedure Ex_OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer); // @addr $7C2100
procedure Ex_OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer); // @addr $7C2194
procedure Ex_OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect); // @addr $7C2228
function Ex_OKGR_LightBuf_Create(Width, Height: Integer): Pointer; // @addr $7C22C8
procedure Ex_OKGR_LightBuf_Destroy(Buffer: Pointer); // @addr $7C2340
procedure Ex_OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer); // @addr $7C23B4
procedure Ex_OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte); // @addr $7C242C
procedure Ex_OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA); // @addr $7C24A0
procedure Ex_OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte); // @addr $7C252C
function Ex_OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer; // @addr $7C25AC
function Ex_OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer; // @addr $7C2638
procedure Ex_OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $7C26AC
procedure Ex_OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $7C274C
procedure Ex_OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $7C27F4
procedure Ex_OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $7C2894
procedure Ex_OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $7C293C
procedure Ex_OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $7C29DC
procedure Ex_OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $7C2A84
procedure Ex_OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer); // @addr $7C2B18
procedure Ex_OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word); // @addr $7C2BB4
procedure Ex_OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer); // @addr $7C2C54
procedure Ex_OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $7C2CE8
procedure Ex_OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal); // @addr 0x007C2D7C
procedure Ex_OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word); // @addr 0x007C2E00
procedure Ex_OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer); // @addr 0x007C2E7C
procedure Ex_OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr 0x007C2EFC
procedure Ex_OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr $7C2F80
procedure Ex_OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr $7C3004
procedure Ex_OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $7C3088
procedure Ex_OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer); // @addr 0x007C311C
procedure Ex_OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); // @addr $7C3198
procedure Ex_OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte); // @addr $7C321C
procedure Ex_OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); // @addr 0x007C32A0
procedure Ex_OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); // @addr 0x007C3330
procedure Ex_OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); // @addr 0x007C33C0
procedure Ex_OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); // @addr 0x007C3454
function Ex_OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer; // @addr $7C34E8 @ida "int __userpurge $name@<eax>(int *X1@<eax>, int *Y1@<edx>, int *X2@<ecx>, int *Y2@<^4>, const TRect *Clip@<^0>);"
procedure DrawGradientLine16Clipped(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; Clip: TRect); // @addr $7CC1C0 @note "Native implementation ignores Pixels/Pitch and draws into ScreenRenderBuffer."
function Ex_OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer; // @addr $7C3564 @ida "int __userpurge $name@<eax>(int *X1@<eax>, int *Y1@<edx>, unsigned int *Color1@<ecx>, int *X2@<^12>, int *Y2@<^8>, unsigned int *Color2@<^4>, const TRect *Clip@<^0>);"
procedure Ex_OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word); // @addr 0x007C35F0
procedure Ex_OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect); // @addr 0x007C367C
function Ex_OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; // @addr $7C3710
function Ex_OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; // @addr $7C37A0 @note "Restores one saved 16-bit pixel per rasterized line point; returns the pixel count."
procedure Ex_OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect); // @addr 0x007C3830
procedure Ex_OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect); // @addr 0x007C38CC
procedure Ex_OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer); // @addr 0x007C3960
procedure Ex_OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); // @addr 0x007C3A04
procedure Ex_OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); // @addr 0x007C3AA0
procedure Ex_OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect); // @addr 0x007C3B3C
procedure Ex_OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer); // @addr 0x007C3BD4
procedure Ex_OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C3C60
procedure Ex_OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $7C3CD4

function GiScalePixels(Value: Integer): Integer; // @addr 0x007CC2C0 @note "Identity function in this binary."
function GiScalePixelsEx(Value, AlternateValue: Integer): Integer; // @addr 0x007CC2C4 @note "Returns Value; AlternateValue is unused in this binary."

procedure RaiseWideMessage(const Message: WideString); // @addr 0x007CC9E4 @note "Converts the borrowed UTF-16 message to AnsiString and raises Exception."

procedure DrawTransparentBuffer16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Clip: TRect; HalfAlpha: Boolean); // @addr $7CB6FC @ida "void __userpurge $name(void *Dest@<eax>, int Pitch@<edx>, int X@<ecx>, int Y@<^12>, void *Source@<^8>, TRect *Clip@<^4>, unsigned __int8 HalfAlpha@<^0>);"
procedure CopyPalettedBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source, Palette: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect); // @addr $7CB758
procedure CopyBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect; UnusedOption: Boolean); // @addr $7CB960 @ida "void __userpurge $name(void *Dest@<eax>, unsigned int DestPitch@<edx>, int X@<ecx>, int Y@<^24>, void *Source@<^20>, unsigned int SourcePitch@<^16>, unsigned int Width@<^12>, unsigned int Height@<^8>, TRect *Clip@<^4>, unsigned __int8 UnusedOption@<^0>);"
procedure DrawAlphaBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect); // @addr $7CBC28
procedure ExpandPaletteToBgra(Dest: Pointer; DestPitch: Integer; Width, Height: Cardinal; Source: Pointer; SourcePitch: Integer; Palette: Pointer); // @addr $7CBDE8

function GetStyleColorGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): Cardinal; // @addr 0x007CD24C @note "Uses Data.StyleColor from Main.dat and the current pixel format. Missing entries use the defaults; malformed configured RGB text may raise."
function GetStyleColorTagGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): WideString; // @addr 0x007CD38C @note "Returns a complete opening <color=...> tag. Configured Data.StyleColor text is inserted verbatim; missing entries use the default RGB values."

procedure CopyGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; HalfAlpha, UnusedOption: Boolean); // @addr $7CB834

procedure DrawAlphaGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect); // @addr $7CBB30

procedure CopyTransparentGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; TransparentColor: Word); // @addr $7CBA34

procedure DrawPaletteAlphaBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect); // @addr $7CBCFC

procedure BlendPaletteBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect); // @addr $7CBEB0

function GetClipboardWideText: WideString; // @addr $7CD804
procedure SetClipboardWideText(Text: WideString); // @addr $7CD880
procedure WriteTextFileThreadSafe(FileName, Text: AnsiString); // @addr $7CC4A0

function ComputeMachineFingerprintCRC: Cardinal; // @addr $7CD688 CRC32 of the C: volume serial and ANSI processor name. Native code ignores volume-query failure.

var
  RuntimeActive: Boolean; // @addr $81CF38 @note "Message pump returns without sleeping when active; cleared during device loss."
  VSyncEnabled: Boolean; // @addr $81CF39
  PathGrowEnabled: Boolean; // @addr $81CF3A @note "User setting PathGrow; permits extending the shared path-node pool."
  ShowSystemMouse: Boolean; // @addr $81CF3B @note "User setting ShowSystemMouse; uses Windows cursor handles instead of drawing the image child."
  ScreenRenderBuffer: TGraphBufGR; // @addr 0x0081CF3C
  RenderScratchBuffer: TGraphBufGR; // @addr $81CF40
  AuxRenderBuffer: TGraphBufGR; // @addr $81CF44  Second shared scratch buffer, also used for captured screen backgrounds.
  SelectedLanguage: WideString; // @addr $81CF48
  RequestedLanguage: WideString; // @addr $81CF4C
  AvailableLanguageCodes: WideString; // @addr $81CF50
  OverrideGameUserDirectory: WideString; // @addr $81CF54
var
  CurrentPixelFormat: TPixelFormatGR; // @addr $81CF58
  GameScreenWidth: Cardinal; // @addr $81CF5C
  GameScreenHeight: Cardinal; // @addr $81CF60
  PresentationWidth: Integer; // @addr $81CF64
  PresentationHeight: Integer; // @addr $81CF68
  ViewportOffset: TPoint; // @addr $81CF6C
  AlternateViewportEnabled: Boolean; // @addr $81CF74  Enables scaled or panned software presentation and mouse-coordinate conversion.
  GameScreenRect: TRect; // @addr $81CF78
  PresentationRect: TRect; // @addr $81CF88
  ScrollInteriorRect: TRect; // @addr $81CF98
  MainWindowHandle: Cardinal; // @addr 0x0081CFA8
  WideCaseTable: array of TWideCasePair; // @addr 0x0081CFAC

function OKGF_ZLib_Compress(Dest, Source: Pointer; SourceSize, Mode: Integer): Integer; stdcall;
  external 'ZLib.dll' name 'OKGF_ZLib_Compress'; // @addr 0x007BF8DC
function OKGF_ZLib_UnCompress(Dest: Pointer; DestCapacity: Integer; Source: Pointer; SourceSize: Integer): Integer; stdcall;
  external 'ZLib.dll' name 'OKGF_ZLib_UnCompress'; // @addr 0x007BF8E4

function GlobalMemoryStatusEx(var Status: TMemoryStatusEx): LongBool; stdcall;
  external 'kernel32' name 'GlobalMemoryStatusEx'; // @addr 0x007BF8EC

function OKGF_MulTable256x256: Pointer; cdecl;
  external 'okgf.dll' name 'OKGF_MulTable256x256'; // @addr $7BF8F4

function OKGF_DXVersion: Cardinal; cdecl;
  external 'okgf.dll' name 'DXVersion'; // @addr $7BF8FC

function OKGF_ReadStart_Buf(Source: Pointer; SourceSize: Integer; out Width, Height: Cardinal): POkgfReadContext; cdecl;
  external 'okgf.dll' name 'OKGF_ReadStart_Buf'; // @addr $7BF904

function OKGF_Read(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Read'; // @addr $7BF90C

function OKGF_ReadStartPal_Buf(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext; cdecl;
  external 'okgf.dll' name 'OKGF_ReadStartPal_Buf'; // @addr $7BF914

function OKGF_ReadPal(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_ReadPal'; // @addr $7BF91C

function OKGF_Write_PNG_File(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Write_PNG_File'; // @addr $7BF924

function OKGF_Write_BMP_File(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Write_BMP_File'; // @addr $7BF92C

procedure OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_Draw_RGBA'; // @addr $7BF934

procedure OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_Draw_RGBA'; // @addr $7BF93C

procedure OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_Draw_RGBA'; // @addr $7BF944

procedure OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDraw_RGBA'; // @addr $7BF94C

procedure OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_Draw_RGBA'; // @addr $7BF954

procedure OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_DrawClip_WORD'; // @addr $7BF95C

procedure OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_HADrawClip_16'; // @addr $7BF964

function OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_Build_WORD'; // @addr $7BF96C

function OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_BuildFromRGBA_16'; // @addr $7BF974

procedure OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_DrawClip_WORD'; // @addr $7BF97C

procedure OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_DrawClip_16'; // @addr $7BF984

function OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_BuildFromRGBA_16'; // @addr $7BF98C

function OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_BuildFromRGBA'; // @addr $7BF994

procedure OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaSimpleBuf_Draw_16'; // @addr $7BF99C

procedure OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaSimpleBufPalAlpha_Draw_16'; // @addr $7BF9A4

procedure OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_MaskBuf_DrawClip_DWORD'; // @addr $7BF9AC

procedure OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_MaskBuf_DrawClip_WORD'; // @addr $7BF9B4

procedure OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_FillAlphaClip_RGBA'; // @addr $7BF9BC

procedure OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_FillAlphaClip_16'; // @addr $7BF9C4

procedure OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_CopyDrawClip_WORD'; // @addr $7BF9CC

procedure OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_CopyDrawClip_Alpha_16'; // @addr $7BF9D4

procedure OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDrawClip_16'; // @addr $7BF9DC

procedure OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16'; // @addr $7BF9E4

function OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Build'; // @addr $7BF9EC

procedure OKGR_RotateBuf_Free(Buffer: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Free'; // @addr $7BF9F4

procedure OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Size'; // @addr $7BF9FC

procedure OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Draw_DWORD'; // @addr $7BFA04

procedure OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Draw_BYTE'; // @addr $7BFA0C

procedure OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_DrawTransClip_WORD'; // @addr $7BFA14

function OKGR_LightBuf_Create(Width, Height: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Create'; // @addr $7BFA1C

procedure OKGR_LightBuf_Destroy(Buffer: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Destroy'; // @addr $7BFA24

procedure OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_SetSme'; // @addr $7BFA2C

procedure OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Init'; // @addr $7BFA34

procedure OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_LoadFromPalBuf'; // @addr $7BFA3C

procedure OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Rotate'; // @addr $7BFA44

function OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_TemplBuild'; // @addr $7BFA4C

// The native Delphi binding preserves EAX, but the DLL defines no result contract.
function OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_TemplDel'; // @addr $7BFA54

procedure OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_DrawAndLight_32'; // @addr $7BFA5C

procedure OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_DrawAndLightClip_16'; // @addr $7BFA64

procedure OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet3_DrawAndLight_32'; // @addr $7BFA6C

procedure OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet3_DrawAndLightClip_16'; // @addr $7BFA74

procedure OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet4_DrawAndLight_32'; // @addr $7BFA7C

procedure OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet4_DrawAndLightClip_16'; // @addr $7BFA84

procedure OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Copy_XY_XY_WORD'; // @addr $7BFA8C

procedure OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_PalCopy_XY_XY_WORD'; // @addr $7BFA94

procedure OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word); cdecl;
  external 'okgf.dll' name 'OKGR_CopyTrans_XY_XY_WORD'; // @addr $7BFA9C

procedure OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_CopySingleBuf_XY_XY_WORD'; // @addr $7BFAA4

procedure OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_HACopy_XY_XY_16'; // @addr $7BFAAC

procedure OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGR_StretchGdi_WORD'; // @addr $7BFAB4

procedure OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_Fill_WORD'; // @addr $7BFABC

procedure OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_ConvertRGBto565'; // @addr $7BFAC4

procedure OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toRGB'; // @addr $7BFACC

procedure OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toBGR'; // @addr $7BFAD4

procedure OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toBGRA'; // @addr $7BFADC

procedure OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert_8888to565'; // @addr $7BFAE4

procedure OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_ShrLight_16'; // @addr $7BFAEC

procedure OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_ShrLightMask_16'; // @addr $7BFAF4

procedure OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_Light_BYTE'; // @addr $7BFAFC

procedure OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawClip_WORD'; // @addr $7BFB04

procedure OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawClip_BYTE'; // @addr $7BFB0C

procedure OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawFillClip_WORD'; // @addr $7BFB14

procedure OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawFillClip_BYTE'; // @addr $7BFB1C

procedure OKGR_PixelAlpha_16(Pixel: Pointer; Color: Word; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_PixelAlpha_16'; // @addr $7BFB24

function OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_Clip'; // @addr $7BFB2C

function OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_LineColor_Clip'; // @addr $7BFB34

procedure OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_Line_Draw_WORD'; // @addr $7BFB3C

procedure OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Line_DrawClip_WORD'; // @addr $7BFB44

function OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_CopyToBuf_WORD'; // @addr $7BFB4C

function OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_CopyFromBuf_WORD'; // @addr $7BFB54

procedure OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Line_DrawClip_Alpha_16'; // @addr $7BFB5C

procedure OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AnimLine_Draw_16'; // @addr $7BFB64

procedure OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_AnimShadowLine_Draw_16'; // @addr $7BFB6C

procedure OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Alpha64Trapezium_16'; // @addr $7BFB74

procedure OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Alpha128Trapezium_16'; // @addr $7BFB7C

procedure OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_FillTrapezium_DWORD'; // @addr $7BFB84

procedure OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Rescale'; // @addr $7BFB8C

procedure OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_F5_DrawRGBA'; // @addr $7BFB94

procedure OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_F6_DrawRGBA'; // @addr $7BFB9C

procedure OKGF_Triangle_16(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Clip: PRect); cdecl;
  external 'okgf.dll' name 'OKGF_Triangle_16'; // @addr $7BFBA4 @note "Cdecl triangle ABI verified at native caller $5E820C."

procedure OKGF_LineIp_16(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGF_LineIp_16'; // @addr $7BFBAC @note "Cdecl gradient-line ABI verified at native caller $7CC1C0."

var
  InstallConfig: TBlockParEC; // @addr 0x0081CFB0
  LanguageInstallConfig: TBlockParEC; // @addr 0x0081CFB4
  UserSettingsConfig: TBlockParEC; // @addr 0x0081CFB8
  MainDataConfig: TBlockParEC; // @addr 0x0081CFBC
  LanguageDataConfig: TBlockParEC; // @addr 0x0081CFC0
  UiStyleConfig: TBlockParEC; // @addr $81CFC4
  SelectedMods: WideString; // @addr $81CFC8
  SelectedModsDisplaySuffix: WideString; // @addr $81CFCC
  LoadedSaveModSet: WideString; // @addr 0x0081CFD0
var
  SuppressModRetryPrompt: Boolean = False; // @addr $812F70 @note "Startup failure guard; other writers remain to be recovered."
  SkipModsOnReload: Boolean = False; // @addr $812F74
  WindowedModeRequested: Boolean = False; // @addr $812F78
  ExitScreenLoop: Boolean = False; // @addr 0x00812F7C
  FullFrameRedrawRequested: Boolean = True; // @addr $812F80
  DisplayBrightness: Single = 0; // @addr $812F84
  DisplayContrast: Single = 0; // @addr $812F88
  RobotBrightness: Single = 0; // @addr $812F8C
  RobotContrast: Single = 0; // @addr $812F90
  OffscreenFrameUpdated: Boolean = False; // @addr $812F94
  OffscreenLastPresentationTick: Cardinal = 0; // @addr $812F98
  InterfaceBlendPalette: Pointer = nil; // @addr $812F9C @note "256 RGB565 colors blended between (8,32,255) and (200,128,128)."
  RequestedRefreshRate: Integer = 0; // @addr $812FA0
  PresentWithoutLimit: Boolean = False; // @addr $812FA4
  DisableHardwareVertexProcessing: Boolean = False; // @addr $812FA8
  DisableMultithreadFlag: Boolean = False; // @addr $812FAC
  DisableTripleBuffer: Boolean = False; // @addr $812FB0
  ModInstallConfigs: TList = nil; // @addr $812FB4 @note "Owns TBlockParEC entries loaded from selected mods' Install.txt files."
  ModLanguageInstallConfigs: TList = nil; // @addr $812FB8 @note "Owns the selected mods' language-specific install blocks."
  ApplyEditableSaveOnLoad: Boolean = False; // @addr $812FBC
  EditableSaveFileName: WideString = ''; // @addr $812FC0
var
  // CheckPlatformModules reaches ModShipNameConfig by adding four bytes to this address.
  // Keep both initialized globals adjacent; these checks are disabled in this build.
  PlatformCheckAnchor: Integer = -35753766; // @addr $812FC4 @note "Dormant checks write a random integer at byte offset 4 from this address, overlapping ModShipNameConfig. Original anchor meaning unresolved."
  ModShipNameConfig: TBlockParEC = nil; // @addr $812FC8
  ModRuinNameConfig: TBlockParEC = nil; // @addr $812FCC
  NewGameSeedText: WideString = ''; // @addr $812FD0 User-supplied galaxy seed, edited by CheatSeed.
var
  CacheLoadLoggingEnabled: Boolean = False; // @addr $812FD4
  SoundManager: TSoundControl = nil; // @addr $812FD8
  MusicManager: TMusicControl = nil; // @addr $812FDC
  ShowFrameRate: Boolean = False; // @addr $812FE0
  RecordingFrames: Boolean = False; // @addr $812FE4
  RecordingFrameBuffers: TList = nil; // @addr $812FE8
  FirstRegisteredCursor: TCursorUnit = nil; // @addr 0x00812FEC
  LastRegisteredCursor: TCursorUnit = nil; // @addr 0x00812FF0
  BuildVersionMismatch: Boolean = False; // @addr $812FF4
  SessionLogLock: TCriticalSection = nil; // @addr 0x00812FF8
  DebugKeyCallback: TDebugKeyCallbackGR = nil; // @addr $812FFC  Receives Ctrl+Shift keys when Alt is not held.
  CustomCursorEnabled: Boolean = True; // @addr $813000 @note "Gates message-loop cursor selection and restoration."
  DirectXVersion: Cardinal = 0; // @addr $813004
  RecordingFrameCount: Integer = 0; // @addr $813008
  RecordingFrameInterval: Integer = 50; // @addr $81300C @note "1000 div FilmFPS; native does not check for zero."
  LastRecordingFrameTick: Cardinal = 0; // @addr $813010
  // VerifyStartupModuleChecksum reaches StartupIntegrityMarker eight bytes before
  // StartupChecksumAnchor. Keep these initialized globals consecutive and in order.
  StartupIntegrityMarker: Integer = 0; // @addr $813014 Signed integrity marker: positive after a failed startup module checksum, negative after a clean check; reset by TMessageLoopGI.Present.
  LastMouseMessageTick: Cardinal = 0; // @addr $813018
  StartupChecksumAnchor: Integer = 0; // @addr $81301C @note "Checksum helper accesses StartupIntegrityMarker at byte offset -8; original anchor meaning unresolved."
  RobotBattleActive: Boolean = False; // @addr $813020 Set across MatrixGame Run, including its exception handler.
  ProcessorCoreCount: Integer = 1; // @addr $813024 @note "Counts CentralProcessor registry subkeys, with a minimum of one."
  Direct3D: IDirect3D9 = nil; // @addr $813028
  Direct3DDevice: IDirect3DDevice9 = nil; // @addr 0x0081302C
  OffscreenTexture: IDirect3DTexture9 = nil; // @addr $813030
var
  OffscreenFillViewport: Boolean = False; // @addr $813034  Fill/crop instead of fitting the entire video frame.
  UseDesktopDisplayMode: Boolean = False; // @addr $813038
  GameDisplayModeCount: Integer = 0; // @addr 0x0081303C
  SelectedGameDisplayMode: Integer = -1; // @addr 0x00813040
  SmallestGameDisplayMode: Integer = -1; // @addr $813044
  UseAutomaticRobotDisplayMode: Boolean = False; // @addr $813048
  RobotDisplayModeCount: Integer = 0; // @addr 0x0081304C
  SelectedRobotDisplayMode: Integer = -1; // @addr 0x00813050
  AltResolutionSwitch: Boolean = False; // @addr $813054
  LastPresentationTick: Cardinal = 0; // @addr $813058
  PresentationFrameRate: Cardinal = 0; // @addr $81305C
  RuntimeWatchdog: TThreadEC = nil; // @addr $813060
  PresentationDepth: Integer = 0; // @addr $813064

var
  EditableSaveBlock: TBlockParEC; // @addr $81CFD4
  GameDataConfig: TBlockParEC; // @addr 0x0081CFD8 @note "Borrowed MainDataConfig.Data block; contains StyleColor."
  NewGameSettingsConfig: TBlockParEC; // @addr $81CFDC @note "Optional user-directory newgame.txt."
  UiDepthConfig: TBlockParEC; // @addr $81CFE0  Borrowed MainDataConfig.ZPos depth-name table.
  CacheDataRoot: TDataEC; // @addr $81CFE4
  GlobalCache: TCacheEC; // @addr 0x0081CFE8
  SessionLog: TextFile; // @addr 0x0081CFEC
  SavePreviewGraph: TGraphBufGR; // @addr $81D1B8
  SecondarySavePreviewGraph: TGraphBufGR; // @addr $81D1BC
  PerformanceCounterFrequency: Int64; // @addr $81D1C0
  DebugCommandMessage: Cardinal; // @addr $81D1C8
  SuppressExceptionLogCopy: Boolean; // @addr $81D1CC  Consumed by $5E7574 to skip the separate exception-log copy.
  BlendPixel16: TBlendPixel16; // @addr $81D1D0
  TriangleRasterizer16: TTriangleRasterizer16; // @addr $81D1D4 @note "OKGF_Triangle_16 callback; cdecl pixel, pitch, vertex/color arguments."
  LineRasterizer16: TLineRasterizer16; // @addr $81D1D8 @note "OKGF_LineIp_16 callback; cdecl pixel, pitch, vertex/color arguments."
  RuntimeExitCheckCallback1: procedure; // @addr $81D1DC Assigned by Rangers.start; no native reads indexed.
  RuntimeExitCheckCallback2: procedure; // @addr $81D1E0 Assigned by Rangers.start; no native reads indexed.
  OnMessageIdle: TRuntimeCallbackGR; // @addr $81D1E4
  OnMessageResume: TRuntimeCallbackGR; // @addr $81D1E8
  CCInterface: TCCInterface; // @addr $81D1EC @note "Owned here; shared with startup helpers and other units."
  RuntimeStartupTick: Cardinal; // @addr $81D1F0
  MainRuntimeThreadId: Cardinal; // @addr $81D1F4
type
  PDisplayModeGR = ^TDisplayModeGR;
  TDisplayModeGR = object // @size 0x10
    Width: Cardinal; // @offset 0x00
    Height: Cardinal; // @offset 0x04
    RefreshRate: Cardinal; // @offset 0x08
    Format: Cardinal; // @offset 0x0C
  end;

  TDisplayModeArrayGR = array of TDisplayModeGR;

var
  DesktopDisplayMode: TDisplayModeGR; // @addr $81D1F8
  Direct3DPresentParameters: TD3DPresentParameters; // @addr $81D208
  PreviousPresentParameters: TD3DPresentParameters; // @addr $81D240
  GameDisplayModes: array of TDisplayModeGR; // @addr 0x0081D278
  RobotDisplayModes: array of TDisplayModeGR; // @addr 0x0081D27C
var
  // Differences from the 1024x768 UI baseline; may be negative.
  ExtraScreenWidth: Integer; // @addr 0x0081D280
  ExtraScreenHeight: Integer; // @addr 0x0081D284
  EncodedPlatformModuleNames: array[0..8] of AnsiString = (
    'loinbaosgaga-10a', 'loinbavrokrablius-->0', 'loinbaveohrablissufainlae', // 'libogg-0', 'libvorbis-0', 'libvorbisfile'
    'mhastorhinxagrakmae', 'ookogifa', 'sotoenalm^_^aucah', 'sotoenalm^_^aupki', // 'matrixgame', 'okgf', 'steam_ach', 'steam_api'
    'xavriadeccomrie', 'zoloimba'); // @addr $813068 @note "Alternating-character DLL basenames consumed by dormant CheckPlatformModules." 'xvidcore', 'zlib'
  CachedGameUserDirectory: WideString = ''; // @addr $81308C

implementation

// @unit-initialization $8079EC
// @unit-finalization $7CDE98

uses GI_Main, DirectXRenderException, TlHelp32, aPacket, DateUtils, Robot, GI_MessageLoop, MMSystem, EC_Mem, GR_DX, Globals, aMyFunction, MessageText, GlobalsV, ShlObj, Math, Forms, Clipbrd, SysUtils, Messages, ActiveX, Windows, Registry;

var
  StartupState: Cardinal; // @addr $81D28C @note "Cleared by settings initialization; no retained reader found, original meaning unresolved."
  ScreenCenterX: Cardinal; // @addr $81D290
  ScreenCenterY: Cardinal; // @addr $81D294
  LastWindowMessageTick: Cardinal; // @addr $81D298
  MessageIdle: Boolean; // @addr $81D29C

{$I-}

{ @routine $7BFDA0 CheckPlatformModules }
procedure CheckPlatformModules;
var
  GameDirectory, ModulePath: AnsiString;
  Snapshot, SteamProcessId: Cardinal;
  Index, FailureOffset: Integer;
  Found: Boolean;
  DllSuffix: WideString;
  SteamClientPath: AnsiString;
  Entry: TModuleEntry32;

  // @nested $7BFCE8 MatchesModuleDirectoryPrefix
  function MatchesModuleDirectoryPrefix(Prefix, Path: AnsiString): Boolean; // @addr $7BFCE8 @calls "0x007BFE8F" @note "Nested helper. Requires Prefix no longer than Path, but compares only characters 1 through Length(Prefix)-1."
  var
    CharacterIndex, CharacterCount: Integer;
  begin
    Result := False;
    if Length(Prefix) > Length(Path) then Exit;
    CharacterIndex := 1;
    CharacterCount := Min(Length(Prefix), Length(Path));
    while CharacterIndex < CharacterCount do
    begin
      if Prefix[CharacterIndex] <> Path[CharacterIndex] then Exit;
      Inc(CharacterIndex);
    end;
    Result := True;
  end;

begin
  // Startup integrity checks are disabled in this build.
  Exit;
  DllSuffix := 'll';
  DllSuffix := '.d' + DllSuffix;
  Snapshot := CreateToolhelp32Snapshot(8, GetCurrentProcessId);
  if Snapshot <> INVALID_HANDLE_VALUE then
  begin
    GameDirectory := AnsiLowerCase(ExtractFilePath(Application.ExeName));
    Entry.dwSize := SizeOf(Entry);
    if Module32First(Snapshot, Entry) then
    begin
      while True do
      begin
        if MatchesModuleDirectoryPrefix(GameDirectory,
          AnsiLowerCase(ExtractFilePath(AnsiString(Entry.szExePath)))) then
        begin
          Found := False;
          ModulePath := AnsiLowerCase(AnsiString(Entry.szModule));
          for Index := 0 to 8 do
          begin
            // 'libogg-0.dll', 'libvorbis-0.dll', 'libvorbisfile.dll',
            // 'matrixgame.dll', 'okgf.dll', 'steam_ach.dll', 'steam_api.dll',
            // 'xvidcore.dll', 'zlib.dll'.
            if WideString(ModulePath) = DecodeTextW(
              WideString(EncodedPlatformModuleNames[Index])) + DllSuffix then
            begin
              Found := True;
              Break;
            end;
          end;
          if not Found then
          begin
            FailureOffset := 4;
            PInteger(PAnsiChar(@PlatformCheckAnchor) + FailureOffset)^ :=
              RandomIntRange(1000000000, 2000000000);
            CloseHandle(Snapshot);
            Exit;
          end;
        end;
        if not Module32Next(Snapshot, Entry) then Break;
      end;
    end;
    CloseHandle(Snapshot);
  end;
  SteamClientPath := AnsiLowerCase(AnsiString(ReadRegistryText(HKEY_CURRENT_USER,
    DecodeTextW('Sdonf6t4wdabrden\7Vga4l-v7ef\3Sdt6e8a,mu\gAcczt1i2v3e2Pvrnohcyetsrs'), // 'Software\Valve\Steam\ActiveProcess'
    DecodeTextW('S4tgefadm.ClliitevnvteDtlfls'), ''))); // 'SteamClientDll'
  SteamProcessId := ReadRegistryInteger(HKEY_CURRENT_USER,
    DecodeTextW('Sdonf6t4wdabrden\7Vga4l-v7ef\3Sdt6e8a,mu\gAcczt1i2v3e2Pvrnohcyetsrs'), 'pid', 0); // 'Software\Valve\Steam\ActiveProcess'
  Snapshot := CreateToolhelp32Snapshot(8, GetCurrentProcessId);
  if Snapshot <> INVALID_HANDLE_VALUE then
  begin
    Entry.dwSize := SizeOf(Entry);
    if Module32First(Snapshot, Entry) then
    begin
      Found := False;
      // Native deliberately advances before inspecting the first path here.
      while Module32Next(Snapshot, Entry) do
      begin
        ModulePath := AnsiLowerCase(AnsiString(Entry.szExePath));
        if ModulePath = SteamClientPath then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        FailureOffset := 4;
        PInteger(PAnsiChar(@PlatformCheckAnchor) + FailureOffset)^ :=
          RandomIntRange(1000000000, 2000000000);
        CloseHandle(Snapshot);
        Exit;
      end;
    end;
    CloseHandle(Snapshot);
  end;
  Found := False;
  Snapshot := CreateToolhelp32Snapshot(8, SteamProcessId);
  if Snapshot <> INVALID_HANDLE_VALUE then
  begin
    Entry.dwSize := SizeOf(Entry);
    if Module32First(Snapshot, Entry) then
      if AnsiLowerCase(AnsiString(Entry.szExePath)) =
        AnsiLowerCase(AnsiString(WideString(ExtractFilePath(SteamClientPath)) +
          DecodeTextW('s1t2eda5mg.he7xie'))) then // 'steam.exe'
      begin
        while Module32Next(Snapshot, Entry) do
        begin
          ModulePath := AnsiLowerCase(AnsiString(Entry.szExePath));
          if ModulePath = SteamClientPath then
          begin
            Found := True;
            Break;
          end;
        end;
      end;
    CloseHandle(Snapshot);
  end;
  if not Found then
  begin
    FailureOffset := 4;
    PInteger(PAnsiChar(@PlatformCheckAnchor) + FailureOffset)^ :=
      RandomIntRange(1000000000, 2000000000);
  end;
end;
{ @end $7BFDA0 }

{ @routine $7C03C0 LogMemoryUsage }
procedure LogMemoryUsage;
var
  Status: TMemoryStatusEx;
begin
  Status.Length := SizeOf(Status);
  GlobalMemoryStatusEx(Status);
  AppendLogLineThreadSafe('Memory Info');
  AppendLogLineThreadSafe('Physical Memory:');
  AppendLogLineThreadSafe('Used=' + SysUtils.IntToStr((Status.TotalPhys - Status.AvailPhys) shr 10) + ' KB');
  AppendLogLineThreadSafe('Available=' + SysUtils.IntToStr(Status.AvailPhys shr 10) + ' KB');
  AppendLogLineThreadSafe('Total=' + SysUtils.IntToStr(Status.TotalPhys shr 10) + ' KB');
  AppendLogLineThreadSafe('Virtual Memory:');
  AppendLogLineThreadSafe('Used=' + SysUtils.IntToStr((Status.TotalVirtual - Status.AvailVirtual) shr 10) + ' KB');
  AppendLogLineThreadSafe('Available=' + SysUtils.IntToStr(Status.AvailVirtual shr 10) + ' KB');
  AppendLogLineThreadSafe('Total=' + SysUtils.IntToStr(Status.TotalVirtual shr 10) + ' KB');
  if GlobalCache <> nil then AppendLogLineThreadSafe('Cache Size=' + SysUtils.IntToStr(GlobalCache.ResidentBytes shr 10) + ' KB');
  AppendLogLineThreadSafe('Textures Cache Size=' + SysUtils.IntToStr(Int64(ResidentTextureBytes shr 10)) + ' KB');
end;
{ @end $7C03C0 }

{ @routine $7C06C8 TCCInterface_Create }
constructor TCCInterface.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  Randomize;
  Buffer := TBufEC.Create;
  CommitSnapshot(CreateEmptySnapshot);
end;
{ @end $7C06C8 }

{ @routine $7C0730 TCCInterface_Destroy }
destructor TCCInterface.Destroy;
begin
  Lock.Free;
  Buffer.Free;
  ClearSnapshots;
  inherited Destroy;
end;
{ @end $7C0730 }

{ @routine $7C076C TCCInterface_Reset }
procedure TCCInterface.Reset;
begin
  Lock.Enter;
  Buffer.Clear;
  ClearSnapshots;
  CommitSnapshot(CreateEmptySnapshot);
  Lock.Leave;
end;
{ @end $7C076C }

{ @routine $7C07A0 TCCInterface_GetSnapshot }
function TCCInterface.GetSnapshot: PCCSnapshot;
var Entry: PCCSnapshot;
begin
  Entry := SnapshotHead;
  while (Entry.Prev = nil) or (Entry.Next.Prev = Entry) do Entry := Entry.Next;
  Result := Entry.Next;
end;
{ @end $7C07A0 }

{ @routine $7C07B8 TCCInterface_CreateDecoy }
function TCCInterface.CreateDecoy: PCCSnapshot;
begin
  New(Result);
  Result.ResourceChecksumFailed := Random(11) > 9;
  Result.TamperDetected := Random(11) > 8;
  Result.Flag0A := Random(11) > 9;
  Result.ProtectedStateXorSeed := Random(2000000000);
  Result.Value10 := Random(1000);
  Result.IntegrityStatus := Random(1000);
  Result.IntegrityError := Ord(Random(11) > 8) * Random(1000);
  Result.IntegrityChecksum := Random(2000000000);
  Result.IntegrityChecksum1 := Random(2000000000);
  Result.IntegrityChecksum2 := Random(2000000000);
  Result.EncodedCheatPoints := Random(2000000000);
  Result.EditableStateApplied := Random(11) > 9;
end;
{ @end $7C07B8 }

{ @routine $7C0898 TCCInterface_CreateEmptySnapshot }
function TCCInterface.CreateEmptySnapshot: PCCSnapshot;
begin
  New(Result);
  Result.ResourceChecksumFailed := False;
  Result.TamperDetected := False;
  Result.Flag0A := False;
  Result.ProtectedStateXorSeed := 0;
  Result.Value10 := 0;
  Result.IntegrityStatus := 0;
  Result.IntegrityError := 0;
  Result.IntegrityChecksum := 0;
  Result.IntegrityChecksum1 := 0;
  Result.IntegrityChecksum2 := 0;
  Result.EncodedCheatPoints := 0;
  Result.EditableStateApplied := False;
end;
{ @end $7C0898 }

{ @routine $7C08DC TCCInterface_CopySnapshot }
function TCCInterface.CopySnapshot(Source: PCCSnapshot): PCCSnapshot;
begin
  New(Result);
  Result.ResourceChecksumFailed := Source.ResourceChecksumFailed;
  Result.TamperDetected := Source.TamperDetected;
  Result.Flag0A := Source.Flag0A;
  Result.ProtectedStateXorSeed := Source.ProtectedStateXorSeed;
  Result.Value10 := Source.Value10;
  Result.IntegrityStatus := Source.IntegrityStatus;
  Result.IntegrityError := Source.IntegrityError;
  Result.IntegrityChecksum := Source.IntegrityChecksum;
  Result.IntegrityChecksum1 := Source.IntegrityChecksum1;
  Result.IntegrityChecksum2 := Source.IntegrityChecksum2;
  Result.EncodedCheatPoints := Source.EncodedCheatPoints;
  Result.EditableStateApplied := Source.EditableStateApplied;
end;
{ @end $7C08DC }

{ @routine $7C0938 TCCInterface_CommitSnapshot }
procedure TCCInterface.CommitSnapshot(Snapshot: PCCSnapshot);
var RingCount, PrefixCount, OldPrefixCount: Integer;
    Entry, Added: PCCSnapshot;
begin
  OldPrefixCount := 0;
  if SnapshotHead <> nil then
  begin
    Entry := GetSnapshot;
    Added := SnapshotHead;
    while Entry <> Added do
    begin
      Inc(OldPrefixCount);
      Added := Added.Next;
    end;
  end;
  RingCount := Random(3) + 3;
  PrefixCount := Random(3) + 3;
  while PrefixCount = OldPrefixCount do PrefixCount := Random(3) + 3;
  Entry := Snapshot;
  Added := nil;
  while RingCount > 0 do
  begin
    Dec(RingCount);
    Added := CreateDecoy;
    Added.Next := Entry;
    Entry.Prev := Added;
    Entry := Added;
  end;
  Added.Prev := Snapshot;
  Snapshot.Next := Added;
  Entry := Snapshot;
  while PrefixCount > 0 do
  begin
    Dec(PrefixCount);
    Added := CreateDecoy;
    Added.Next := Entry;
    Entry.Prev := Added;
    Entry := Added;
  end;
  Added.Prev := nil;
  if SnapshotHead <> nil then ClearSnapshots;
  SnapshotHead := Added;
end;
{ @end $7C0938 }

{ @routine $7C0A10 TCCInterface_ClearSnapshots }
procedure TCCInterface.ClearSnapshots;
var Snapshot, Entry, Next: PCCSnapshot;
begin
  Snapshot := GetSnapshot;
  SnapshotHead := nil;
  Entry := Snapshot.Next;
  while Entry <> Snapshot do
  begin
    Next := Entry.Next;
    Dispose(Entry);
    Entry := Next;
  end;
  while Entry <> nil do
  begin
    Next := Entry.Prev;
    Dispose(Entry);
    Entry := Next;
  end;
end;
{ @end $7C0A10 }

{ @routine $7C0A5C TCCInterface_GetResourceChecksumFailed }
function TCCInterface.GetResourceChecksumFailed: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.ResourceChecksumFailed;
  Lock.Leave;
end;
{ @end $7C0A5C }

{ @routine $7C0A80 TCCInterface_SetResourceChecksumFailed }
procedure TCCInterface.SetResourceChecksumFailed(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.ResourceChecksumFailed := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0A80 }

{ @routine $7C0AB8 TCCInterface_GetTamperDetected }
function TCCInterface.GetTamperDetected: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.TamperDetected;
  Lock.Leave;
end;
{ @end $7C0AB8 }

{ @routine $7C0ADC TCCInterface_SetTamperDetected }
procedure TCCInterface.SetTamperDetected(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.TamperDetected := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0ADC }

{ @routine $7C0B14 TCCInterface_GetFlag0A }
function TCCInterface.GetFlag0A: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.Flag0A;
  Lock.Leave;
end;
{ @end $7C0B14 }

{ @routine $7C0B38 TCCInterface_SetFlag0A }
procedure TCCInterface.SetFlag0A(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.Flag0A := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0B38 }

{ @routine $7C0B70 TCCInterface_GetEditableStateApplied }
function TCCInterface.GetEditableStateApplied: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.EditableStateApplied;
  Lock.Leave;
end;
{ @end $7C0B70 }

{ @routine $7C0B94 TCCInterface_SetEditableStateApplied }
procedure TCCInterface.SetEditableStateApplied(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.EditableStateApplied := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0B94 }

{ @routine $7C0BCC TCCInterface_GetProtectedStateXorSeed }
function TCCInterface.GetProtectedStateXorSeed: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.ProtectedStateXorSeed;
  Lock.Leave;
end;
{ @end $7C0BCC }

{ @routine $7C0BF0 TCCInterface_SetProtectedStateXorSeed }
procedure TCCInterface.SetProtectedStateXorSeed(Value: Integer);
var
  Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.ProtectedStateXorSeed := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0BF0 }

{ @routine $7C0C28 TCCInterface_GetValue10 }
function TCCInterface.GetValue10: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.Value10;
  Lock.Leave;
end;
{ @end $7C0C28 }

{ @routine $7C0C4C TCCInterface_SetValue10 }
procedure TCCInterface.SetValue10(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.Value10 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0C4C }

{ @routine $7C0C84 TCCInterface_GetIntegrityStatus }
function TCCInterface.GetIntegrityStatus: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityStatus;
  Lock.Leave;
end;
{ @end $7C0C84 }

{ @routine $7C0CA8 TCCInterface_SetIntegrityStatus }
procedure TCCInterface.SetIntegrityStatus(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityStatus := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0CA8 }

{ @routine $7C0CE0 TCCInterface_GetIntegrityError }
function TCCInterface.GetIntegrityError: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityError;
  Lock.Leave;
end;
{ @end $7C0CE0 }

{ @routine $7C0D04 TCCInterface_SetIntegrityError }
procedure TCCInterface.SetIntegrityError(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityError := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0D04 }

{ @routine $7C0D3C TCCInterface_GetIntegrityChecksum }
function TCCInterface.GetIntegrityChecksum: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum;
  Lock.Leave;
end;
{ @end $7C0D3C }

{ @routine $7C0D60 TCCInterface_SetIntegrityChecksum }
procedure TCCInterface.SetIntegrityChecksum(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0D60 }

{ @routine $7C0D98 TCCInterface_GetIntegrityChecksum1 }
function TCCInterface.GetIntegrityChecksum1: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum1;
  Lock.Leave;
end;
{ @end $7C0D98 }

{ @routine $7C0DBC TCCInterface_SetIntegrityChecksum1 }
procedure TCCInterface.SetIntegrityChecksum1(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum1 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0DBC }

{ @routine $7C0DF4 TCCInterface_GetIntegrityChecksum2 }
function TCCInterface.GetIntegrityChecksum2: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum2;
  Lock.Leave;
end;
{ @end $7C0DF4 }

{ @routine $7C0E18 TCCInterface_SetIntegrityChecksum2 }
procedure TCCInterface.SetIntegrityChecksum2(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum2 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0E18 }

{ @routine $7C0E50 TCCInterface_GetEncodedCheatPoints }
function TCCInterface.GetEncodedCheatPoints: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.EncodedCheatPoints;
  Lock.Leave;
end;
{ @end $7C0E50 }

{ @routine $7C0E74 TCCInterface_SetEncodedCheatPoints }
procedure TCCInterface.SetEncodedCheatPoints(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.EncodedCheatPoints := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $7C0E74 }

{ @routine $7C0EAC Ex_OKGF_MulTable256x256 }
function Ex_OKGF_MulTable256x256: Pointer;
begin
  try
    Result := OKGF_MulTable256x256;
  except
    raise Exception.Create('Error in OKGF_MulTable256x256');
  end;
end;
{ @end $7C0EAC }

{ @routine $7C0F20 Ex_OKGF_DXVersion }
function Ex_OKGF_DXVersion: Cardinal;
begin
  try
    Result := OKGF_DXVersion;
  except
    raise Exception.Create('Error in OKGF_DXVersion');
  end;
end;
{ @end $7C0F20 }

{ @routine $7C0F8C BeginImageRead }
function BeginImageRead(Source: Pointer; SourceSize: Integer; out Width, Height: Cardinal): POkgfReadContext;
begin
  try
    Result := OKGF_ReadStart_Buf(Source, SourceSize, Width, Height);
  except
    raise Exception.Create('Error in OKGF_ReadStart_Buf');
  end;
end;
{ @end $7C0F8C }

{ @routine $7C1008 ReadImagePixels }
function ReadImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer;
begin
  try
    Result := OKGF_Read(Context, Pixels, PitchBytes, RedMask, GreenMask, BlueMask, AlphaMask, BytesPerPixel);
  except
    raise Exception.Create('Error in OKGF_Read');
  end;
end;
{ @end $7C1008 }

{ @routine $7C108C BeginIndexedImageRead }
function BeginIndexedImageRead(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext;
begin
  try
    Result := OKGF_ReadStartPal_Buf(Source, SourceSize, Width, Height, PaletteCount, BytesPerPixel);
  except
    raise Exception.Create('Error in OKGF_ReadStartPal_Buf');
  end;
end;
{ @end $7C108C }

{ @routine $7C1114 ReadIndexedImagePixels }
function ReadIndexedImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer;
begin
  try
    Result := OKGF_ReadPal(Context, Pixels, PitchBytes, Palette);
  except
    raise Exception.Create('Error in OKGF_ReadPal');
  end;
end;
{ @end $7C1114 }

{ @routine $7C118C WritePngFile }
function WritePngFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer;
begin
  try
    Result := OKGF_Write_PNG_File(FileName, Pixels, PitchBytes, Width, Height, HasAlpha, SwapRedBlue);
  except
    raise Exception.Create('Error in OKGF_Write_PNG_File');
  end;
end;
{ @end $7C118C }

{ @routine $7C1218 WriteBmpFile }
function WriteBmpFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer;
begin
  try
    Result := OKGF_Write_BMP_File(FileName, Pixels, PitchBytes, BitsPerPixel, RedMask, GreenMask, BlueMask, AlphaMask, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Write_BMP_File');
  end;
end;
{ @end $7C1218 }

{ @routine $7C12B0 Ex_OKGR_AlphaBuf_Draw_RGBA }
procedure Ex_OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_Draw_RGBA');
  end;
end;
{ @end $7C12B0 }

{ @routine $7C132C Ex_OKGR_TransAlphaBuf_Draw_RGBA }
procedure Ex_OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_TransAlphaBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_Draw_RGBA');
  end;
end;
{ @end $7C132C }

{ @routine $7C13AC Ex_OKGR_AlphaIndexed_Draw_RGBA }
procedure Ex_OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaIndexed_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_Draw_RGBA');
  end;
end;
{ @end $7C13AC }

{ @routine $7C142C Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA }
procedure Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDraw_RGBA');
  end;
end;
{ @end $7C142C }

{ @routine $7C14B0 Ex_OKGR_TransBuf_Draw_RGBA }
procedure Ex_OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_TransBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_TransBuf_Draw_RGBA');
  end;
end;
{ @end $7C14B0 }

{ @routine $7C152C Ex_OKGR_TransBuf_DrawClip_WORD }
procedure Ex_OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransBuf_DrawClip_WORD');
  end;
end;
{ @end $7C152C }

{ @routine $7C15B8 Ex_OKGR_TransBuf_HADrawClip_16 }
procedure Ex_OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransBuf_HADrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransBuf_HADrawClip_16');
  end;
end;
{ @end $7C15B8 }

{ @routine $7C1644 Ex_OKGR_TransBuf_Build_WORD }
function Ex_OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer;
begin
  try
    Result := OKGR_TransBuf_Build_WORD(Source, Pitch, Width, Height, Dest, TransparentColor);
  except
    raise Exception.Create('Error in OKGR_TransBuf_Build_WORD');
  end;
end;
{ @end $7C1644 }

{ @routine $7C16D0 Ex_OKGR_TransBuf_BuildFromRGBA_16 }
function Ex_OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_TransBuf_BuildFromRGBA_16(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_TransBuf_BuildFromRGBA_16');
  end;
end;
{ @end $7C16D0 }

{ @routine $7C175C Ex_OKGR_TransAlphaBuf_DrawClip_WORD }
procedure Ex_OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransAlphaBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_DrawClip_WORD');
  end;
end;
{ @end $7C175C }

{ @routine $7C17EC Ex_OKGR_AlphaBuf_DrawClip_16 }
procedure Ex_OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaBuf_DrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_DrawClip_16');
  end;
end;
{ @end $7C17EC }

{ @routine $7C1874 Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16 }
function Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_TransAlphaBuf_BuildFromRGBA_16(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_BuildFromRGBA_16');
  end;
end;
{ @end $7C1874 }

{ @routine $7C1908 Ex_OKGR_AlphaBuf_BuildFromRGBA }
function Ex_OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_AlphaBuf_BuildFromRGBA(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_BuildFromRGBA');
  end;
end;
{ @end $7C1908 }

{ @routine $7C1994 Ex_OKGR_AlphaSimpleBuf_Draw_16 }
procedure Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_AlphaSimpleBuf_Draw_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_AlphaSimpleBuf_Draw_16');
  end;
end;
{ @end $7C1994 }

{ @routine $7C1A30 Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16 }
procedure Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA);
begin
  try
    OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height, Palette);
  except
    raise Exception.Create('Error in OKGR_AlphaSimpleBufPalAlpha_Draw_16');
  end;
end;
{ @end $7C1A30 }

{ @routine $7C1AD8 Ex_OKGR_MaskBuf_DrawClip_DWORD }
procedure Ex_OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect);
begin
  try
    OKGR_MaskBuf_DrawClip_DWORD(Dest, Pitch, X, Y, Source, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_MaskBuf_DrawClip_DWORD');
  end;
end;
{ @end $7C1AD8 }

{ @routine $7C1B68 Ex_OKGR_MaskBuf_DrawClip_WORD }
procedure Ex_OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_MaskBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_MaskBuf_DrawClip_WORD');
  end;
end;
{ @end $7C1B68 }

{ @routine $7C1BF8 Ex_OKGR_TransBuf_FillAlphaClip_RGBA }
procedure Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal);
begin
  try
    OKGR_TransBuf_FillAlphaClip_RGBA(Dest, Pitch, X, Y, Source, Clip, Color);
  except
    raise Exception.Create('Error in OKGR_TransBuf_FillAlphaClip_RGBA');
  end;
end;
{ @end $7C1BF8 }

{ @routine $7C1C8C Ex_OKGR_TransBuf_FillAlphaClip_16 }
procedure Ex_OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word);
begin
  try
    OKGR_TransBuf_FillAlphaClip_16(Dest, Pitch, X, Y, Source, Clip, Color);
  except
    raise Exception.Create('Error in OKGR_TransBuf_FillAlphaClip_16');
  end;
end;
{ @end $7C1C8C }

{ @routine $7C1D20 Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD }
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_CopyDrawClip_WORD');
  end;
end;
{ @end $7C1D20 }

{ @routine $7C1DB4 Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16 }
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte);
begin
  try
    OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest, Pitch, X, Y, Source, Clip, Alpha);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_CopyDrawClip_Alpha_16');
  end;
end;
{ @end $7C1DB4 }

{ @routine $7C1E54 Ex_OKGR_AlphaIndexed_AlphaDrawClip_16 }
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaIndexed_AlphaDrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDrawClip_16');
  end;
end;
{ @end $7C1E54 }

{ @routine $7C1EE4 Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16 }
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte);
begin
  try
    OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest, Pitch, X, Y, Source, Clip, Alpha);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16');
  end;
end;
{ @end $7C1EE4 }

{ @routine $7C1F84 Ex_OKGR_RotateBuf_Build }
function Ex_OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer;
begin
  try
    Result := OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Build');
  end;
end;
{ @end $7C1F84 }

{ @routine $7C200C Ex_OKGR_RotateBuf_Free }
procedure Ex_OKGR_RotateBuf_Free(Buffer: Pointer);
begin
  try
    OKGR_RotateBuf_Free(Buffer);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Free');
  end;
end;
{ @end $7C200C }

{ @routine $7C2080 Ex_OKGR_RotateBuf_Size }
procedure Ex_OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect);
begin
  try OKGR_RotateBuf_Size(X, Y, Angle, RotationMap, Bounds);
  except raise Exception.Create('Error in OKGR_RotateBuf_Size'); end;
end;
{ @end $7C2080 }

{ @routine $7C2100 Ex_OKGR_RotateBuf_Draw_DWORD }
procedure Ex_OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer);
begin
  try
    OKGR_RotateBuf_Draw_DWORD(Dest, DestPitch, Source, SourcePitch, CenterX, CenterY, Angle, RotationMap);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Draw_DWORD');
  end;
end;
{ @end $7C2100 }

{ @routine $7C2194 Ex_OKGR_RotateBuf_Draw_BYTE }
procedure Ex_OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer);
begin
  try
    OKGR_RotateBuf_Draw_BYTE(Dest, DestPitch, Source, SourcePitch, Width, Height, Angle, RotationMap);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Draw_BYTE');
  end;
end;
{ @end $7C2194 }

{ @routine $7C2228 Ex_OKGR_RotateBuf_DrawTransClip_WORD }
procedure Ex_OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect);
begin
  try OKGR_RotateBuf_DrawTransClip_WORD(Dest, DestPitch, Source, SourcePitch, CenterX, CenterY, Angle, RotationMap, Clip);
  except raise Exception.Create('Error in OKGR_RotateBuf_DrawTransClip_WORD'); end;
end;
{ @end $7C2228 }

{ @routine $7C22C8 Ex_OKGR_LightBuf_Create }
function Ex_OKGR_LightBuf_Create(Width, Height: Integer): Pointer;
begin
  try
    Result := OKGR_LightBuf_Create(Width, Height);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Create');
  end;
end;
{ @end $7C22C8 }

{ @routine $7C2340 Ex_OKGR_LightBuf_Destroy }
procedure Ex_OKGR_LightBuf_Destroy(Buffer: Pointer);
begin
  try
    OKGR_LightBuf_Destroy(Buffer);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Destroy');
  end;
end;
{ @end $7C2340 }

{ @routine $7C23B4 Ex_OKGR_LightBuf_SetSme }
procedure Ex_OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer);
begin
  try
    OKGR_LightBuf_SetSme(Buffer, X, Y);
  except
    raise Exception.Create('Error in OKGR_LightBuf_SetSme');
  end;
end;
{ @end $7C23B4 }

{ @routine $7C242C Ex_OKGR_LightBuf_Init }
procedure Ex_OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte);
begin
  try
    OKGR_LightBuf_Init(Buffer, Value);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Init');
  end;
end;
{ @end $7C242C }

{ @routine $7C24A0 Ex_OKGR_LightBuf_LoadFromPalBuf }
procedure Ex_OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA);
begin
  try
    OKGR_LightBuf_LoadFromPalBuf(Buffer, Source, Width, Height, Pitch, Palette);
  except
    raise Exception.Create('Error in OKGR_LightBuf_LoadFromPalBuf');
  end;
end;
{ @end $7C24A0 }

{ @routine $7C252C Ex_OKGR_LightBuf_Rotate }
procedure Ex_OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte);
begin
  try
    OKGR_LightBuf_Rotate(Dest, Source, RotationMap, Angle);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Rotate');
  end;
end;
{ @end $7C252C }

{ @routine $7C25AC Ex_OKGR_Planet2_TemplBuild }
function Ex_OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer;
begin
  try
    Result := OKGR_Planet2_TemplBuild(Source, Pitch, Height, TextureWidth, TextureHeight, ByteCount);
  except
    raise Exception.Create('Error in OKGR_Planet2_TemplBuild');
  end;
end;
{ @end $7C25AC }

{ @routine $7C2638 Ex_OKGR_Planet2_TemplDel }
function Ex_OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer;
begin
  try
    Result := OKGR_Planet2_TemplDel(TemplateData);
  except
    raise Exception.Create('Error in OKGR_Planet2_TemplDel');
  end;
end;
{ @end $7C2638 }

{ @routine $7C26AC Ex_OKGR_Planet2_DrawAndLight_32 }
procedure Ex_OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet2_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet2_DrawAndLight_32');
  end;
end;
{ @end $7C26AC }

{ @routine $7C274C Ex_OKGR_Planet2_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet2_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet2_DrawAndLightClip_16');
  end;
end;
{ @end $7C274C }

{ @routine $7C27F4 Ex_OKGR_Planet3_DrawAndLight_32 }
procedure Ex_OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet3_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet3_DrawAndLight_32');
  end;
end;
{ @end $7C27F4 }

{ @routine $7C2894 Ex_OKGR_Planet3_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet3_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet3_DrawAndLightClip_16');
  end;
end;
{ @end $7C2894 }

{ @routine $7C293C Ex_OKGR_Planet4_DrawAndLight_32 }
procedure Ex_OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet4_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet4_DrawAndLight_32');
  end;
end;
{ @end $7C293C }

{ @routine $7C29DC Ex_OKGR_Planet4_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet4_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet4_DrawAndLightClip_16');
  end;
end;
{ @end $7C29DC }

{ @routine $7C2A84 Ex_OKGR_Copy_XY_XY_WORD }
procedure Ex_OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_Copy_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_Copy_XY_XY_WORD');
  end;
end;
{ @end $7C2A84 }

{ @routine $7C2B18 Ex_OKGR_PalCopy_XY_XY_WORD }
procedure Ex_OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer);
begin
  try
    OKGR_PalCopy_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Palette, Width, Height);
  except
    raise Exception.Create('Error in OKGR_PalCopy_XY_XY_WORD');
  end;
end;
{ @end $7C2B18 }

{ @routine $7C2BB4 Ex_OKGR_CopyTrans_XY_XY_WORD }
procedure Ex_OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word);
begin
  try
    OKGR_CopyTrans_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height, TransparentColor);
  except
    raise Exception.Create('Error in OKGR_CopyTrans_XY_XY_WORD');
  end;
end;
{ @end $7C2BB4 }

{ @routine $7C2C54 Ex_OKGR_CopySingleBuf_XY_XY_WORD }
procedure Ex_OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_CopySingleBuf_XY_XY_WORD(Pixels, Pitch, DestX, DestY, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_CopySingleBuf_XY_XY_WORD');
  end;
end;
{ @end $7C2C54 }

{ @routine $7C2CE8 Ex_OKGR_HACopy_XY_XY_16 }
procedure Ex_OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_HACopy_XY_XY_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_HACopy_XY_XY_16');
  end;
end;
{ @end $7C2CE8 }

{ @routine $7C2D7C Ex_OKGR_StretchGdi_WORD }
procedure Ex_OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal);
begin
  try
    OKGR_StretchGdi_WORD(Dest, Width, Height, Source, SourceWidth, SourceHeight);
  except
    raise Exception.Create('Error in OKGR_StretchGdi_WORD');
  end;
end;
{ @end $7C2D7C }

{ @routine $7C2E00 Ex_OKGR_Fill_WORD }
procedure Ex_OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word);
begin
  try
    OKGR_Fill_WORD(Pixels, Pitch, Width, Height, Color);
  except
    raise Exception.Create('Error in OKGR_Fill_WORD');
  end;
end;
{ @end $7C2E00 }

{ @routine $7C2E7C Ex_OKGF_ConvertRGBto565 }
procedure Ex_OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer);
begin
  try
    OKGF_ConvertRGBto565(Source, Dest, Pitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_ConvertRGBto565');
  end;
end;
{ @end $7C2E7C }

{ @routine $7C2EFC Ex_OKGF_Convert565toRGB }
procedure Ex_OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toRGB(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toRGB');
  end;
end;
{ @end $7C2EFC }

{ @routine $7C2F80 Ex_OKGF_Convert565toBGR }
procedure Ex_OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toBGR(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toBGR');
  end;
end;
{ @end $7C2F80 }

{ @routine $7C3004 Ex_OKGF_Convert565toBGRA }
procedure Ex_OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toBGRA(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toBGRA');
  end;
end;
{ @end $7C3004 }

{ @routine $7C3088 Ex_OKGF_Convert_8888to565 }
procedure Ex_OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGF_Convert_8888to565(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert_8888to565');
  end;
end;
{ @end $7C3088 }

{ @routine $7C311C Ex_OKGR_ShrLight_16 }
procedure Ex_OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer);
begin
  try
    OKGR_ShrLight_16(Pixels, Pitch, Width, Height, Shift);
  except
    raise Exception.Create('Error in OKGR_ShrLight_16');
  end;
end;
{ @end $7C311C }

{ @routine $7C3198 Ex_OKGR_ShrLightMask_16 }
procedure Ex_OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer);
begin
  try
    OKGR_ShrLightMask_16(Dest, DestPitch, Source, SourcePitch, Width, Height);
  except
    raise Exception.Create('Error in OKGR_ShrLightMask_16');
  end;
end;
{ @end $7C3198 }

{ @routine $7C321C Ex_OKGR_Light_BYTE }
procedure Ex_OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte);
begin
  try
    OKGR_Light_BYTE(Pixels, PixelStride, Pitch, Width, Height, Alpha);
  except
    raise Exception.Create('Error in OKGR_Light_BYTE');
  end;
end;
{ @end $7C321C }

{ @routine $7C32A0 Ex_OKGR_Circle_DrawClip_WORD }
procedure Ex_OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawClip_WORD(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawClip_WORD');
  end;
end;
{ @end $7C32A0 }

{ @routine $7C3330 Ex_OKGR_Circle_DrawClip_BYTE }
procedure Ex_OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawClip_BYTE(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawClip_BYTE');
  end;
end;
{ @end $7C3330 }

{ @routine $7C33C0 Ex_OKGR_Circle_DrawFillClip_WORD }
procedure Ex_OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawFillClip_WORD(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawFillClip_WORD');
  end;
end;
{ @end $7C33C0 }

{ @routine $7C3454 Ex_OKGR_Circle_DrawFillClip_BYTE }
procedure Ex_OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawFillClip_BYTE(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawFillClip_BYTE');
  end;
end;
{ @end $7C3454 }

{ @routine $7C34E8 Ex_OKGR_Line_Clip }
function Ex_OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer;
begin
  try
    Result := OKGR_Line_Clip(X1, Y1, X2, Y2, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_Clip');
  end;
end;
{ @end $7C34E8 }

{ @routine $7C3564 Ex_OKGR_LineColor_Clip }
function Ex_OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer;
begin
  try
    Result := OKGR_LineColor_Clip(X1, Y1, Color1, X2, Y2, Color2, Clip);
  except
    raise Exception.Create('Error in Ex_OKGR_LineColor_Clip');
  end;
end;
{ @end $7C3564 }

{ @routine $7C35F0 Ex_OKGR_Line_Draw_WORD }
procedure Ex_OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word);
begin
  try
    OKGR_Line_Draw_WORD(Pixels, Pitch, X1, Y1, X2, Y2, Color);
  except
    raise Exception.Create('Error in OKGR_Line_Draw_WORD');
  end;
end;
{ @end $7C35F0 }

{ @routine $7C367C Ex_OKGR_Line_DrawClip_WORD }
procedure Ex_OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Line_DrawClip_WORD(Pixels, Pitch, X1, Y1, X2, Y2, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_DrawClip_WORD');
  end;
end;
{ @end $7C367C }

{ @routine $7C3710 Ex_OKGR_Line_CopyToBuf_WORD }
function Ex_OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer;
begin
  try
    Result := OKGR_Line_CopyToBuf_WORD(Dest, Source, Pitch, X1, Y1, X2, Y2);
  except
    raise Exception.Create('Error in OKGR_Line_CopyToBuf_WORD');
  end;
end;
{ @end $7C3710 }

{ @routine $7C37A0 Ex_OKGR_Line_CopyFromBuf_WORD }
function Ex_OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer;
begin
  try
    Result := OKGR_Line_CopyFromBuf_WORD(Source, Dest, Pitch, X1, Y1, X2, Y2);
  except
    raise Exception.Create('Error in OKGR_Line_CopyFromBuf_WORD');
  end;
end;
{ @end $7C37A0 }

{ @routine $7C3830 Ex_OKGR_Line_DrawClip_Alpha_16 }
procedure Ex_OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect);
begin
  try
    OKGR_Line_DrawClip_Alpha_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Alpha, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_DrawClip_Alpha_16');
  end;
end;
{ @end $7C3830 }

{ @routine $7C38CC Ex_OKGR_AnimLine_Draw_16 }
procedure Ex_OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect);
begin
  try
    OKGR_AnimLine_Draw_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Phase, Clip);
  except
    raise Exception.Create('Error in OKGR_AnimLine_Draw_16');
  end;
end;
{ @end $7C38CC }

{ @routine $7C3960 Ex_OKGR_AnimShadowLine_Draw_16 }
procedure Ex_OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer);
begin
  try
    OKGR_AnimShadowLine_Draw_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Phase, Clip, ShadowPixels, ShadowPitch);
  except
    raise Exception.Create('Error in OKGR_AnimShadowLine_Draw_16');
  end;
end;
{ @end $7C3960 }

{ @routine $7C3A04 Ex_OKGR_Alpha64Trapezium_16 }
procedure Ex_OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Alpha64Trapezium_16(Pixels, Pitch, X1, Y1, X2, Y2, X3, X4, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Alpha64Trapezium_16');
  end;
end;
{ @end $7C3A04 }

{ @routine $7C3AA0 Ex_OKGR_Alpha128Trapezium_16 }
procedure Ex_OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Alpha128Trapezium_16(Pixels, Pitch, X1, Y1, X2, Y2, X3, X4, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Alpha128Trapezium_16');
  end;
end;
{ @end $7C3AA0 }

{ @routine $7C3B3C Ex_OKGR_FillTrapezium_DWORD }
procedure Ex_OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect);
begin
  try
    OKGR_FillTrapezium_DWORD(Pixels, Pitch, X1, X2, Y1, X3, X4, Y2, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_FillTrapezium_DWORD');
  end;
end;
{ @end $7C3B3C }

{ @routine $7C3BD4 Ex_OKGF_Rescale }
procedure Ex_OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer);
begin
  try
    OKGF_Rescale(Dest, Width, Height, DestPitch, Source, SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter);
  except
    raise Exception.Create('Error in OKGF_Rescale');
  end;
end;
{ @end $7C3BD4 }

{ @routine $7C3C60 Ex_OKGR_F5_DrawRGBA }
procedure Ex_OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_F5_DrawRGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_F5_DrawRGBA');
  end;
end;
{ @end $7C3C60 }

{ @routine $7C3CD4 Ex_OKGR_F6_DrawRGBA }
procedure Ex_OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_F6_DrawRGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_F6_DrawRGBA');
  end;
end;
{ @end $7C3CD4 }

{ @routine $7C3D48 ApplyProcessAffinity }
procedure ApplyProcessAffinity;
var Mask: Cardinal;
begin
  Mask := 1;
  if MultiThreadEnabled then
  begin
    while SetProcessAffinityMask(GetCurrentProcess, Mask) do Mask := (Mask shl 1) or 1;
    Exit;
  end;
  SetProcessAffinityMask(GetCurrentProcess, Mask);
end;
{ @end $7C3D48 }

{ @routine $7C3D80 CheckRuntimeWatchdog }
procedure CheckRuntimeWatchdog;
var FaultCode: Pointer;
begin
  if RuntimeWatchdog <> nil then
    if not RuntimeWatchdog.IsRunning then
    begin
      FaultCode := AllocEC(5);
      PCardinal(FaultCode)^ := $89C033;
      asm
        jmp FaultCode
      end;
    end;
end;
{ @end $7C3D80 }

{ @routine $7C3DB8 CreateStartupLogFile }
procedure CreateStartupLogFile;
begin
  AssignFile(SessionLog, GetGameUserDirectory + '########.log');
  Rewrite(SessionLog);
  Writeln(SessionLog, 'Start');
  CloseFile(SessionLog);
end;
{ @end $7C3DB8 }

{ @routine $7C3E7C InitializePlatformRuntimeAndMainWindow }
procedure InitializePlatformRuntimeAndMainWindow;
var SystemDirectory: WideString; Module: HModule; WindowClass: TWndClassW;
  UnusedLocal: array[0..7] of Byte; // Native reserves eight unreferenced local bytes here; original type and purpose unknown.
begin
  SetLength(SystemDirectory, 256);
  SetLength(SystemDirectory, GetSystemDirectoryW(PWideChar(SystemDirectory), 256));
  Module := LoadLibraryW(PWideChar(SystemDirectory + DecodeTextW('\/di34da9..idalal'))); // '\d3d9.dll'
  Direct3DCreate9 := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('Drinroekcata33DICAroevaltaen9')))); // 'Direct3DCreate9'
  Module := LoadLibraryW(PWideChar(SystemDirectory + DecodeTextW('\/dosdosusnuds.idalal'))); // '\dsound.dll'
  DirectSoundCreate := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('DrinroekcataSnowusnud.Carvenaltie')))); // 'DirectSoundCreate'
  DirectSoundEnumerate := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('DrinroekcataSnowusnud.ElnourmieArtastaenAi')))); // 'DirectSoundEnumerateA'
  CheckPlatformModules;
  CoInitialize(nil);
  DirectXVersion := Ex_OKGF_DXVersion;
  DebugCommandMessage := RegisterWindowMessage('DebugMsgCommand');
  CopyFile('#ship_c.dbf', '#ship.dbf', False);
  AppendLogLineThreadSafe('Build=2.1.2500 (6 October 2026)');
  AppendLogLineThreadSafe('DXVersion=' + SysUtils.IntToStr(Int64(DirectXVersion shr 16)) + '.' +
    SysUtils.IntToStr(Int64((DirectXVersion shr 8) and $FF)) + '.' + SysUtils.IntToStr(Int64(DirectXVersion and $FF)));
  PerformanceCounterFrequency := 0;
  QueryPerformanceFrequency(PerformanceCounterFrequency);
  WindowClass.style := $2B;
  WindowClass.cbClsExtra := 0;
  WindowClass.cbWndExtra := 0;
  WindowClass.hInstance := HInstance;
  WindowClass.hIcon := LoadIcon(HInstance, 'MAINICON');
  WindowClass.hCursor := LoadCursor(0, IDC_ARROW);
  WindowClass.hbrBackground := GetStockObject(BLACK_BRUSH);
  WindowClass.lpszMenuName := nil;
  WindowClass.lpszClassName := 'Rangers MainClassName';
  WindowClass.lpfnWndProc := @MainWindowProc;
  if RegisterClassW(WindowClass) = 0 then
    raise Exception.Create('RegisterClass GetLastError()=' + SysUtils.IntToStr(Int64(GetLastError)));
  if not InitializePackageCollection then raise Exception.Create('Error while initializing package files');
  MainWindowHandle := Windows.CreateWindowExW(0, 'Rangers MainClassName', 'Rangers', 0, 0, 0, 4096, 2048, 0, 0, HInstance, nil);
  if MainWindowHandle = 0 then
    raise Exception.Create('CreateWindowEx GetLastError()=' + SysUtils.IntToStr(Int64(GetLastError)));
  SetTimer(MainWindowHandle, 1, 100, nil);
  Application.Handle := MainWindowHandle;
  InstallConfig := TBlockParEC.Create;
  InstallConfig.LoadFromTextFileWithEncodingProbe('install.txt', False);
  QuestMessages := TQuestMessages.Create;
end;
{ @end $7C3E7C }

{ @routine $7C44F8 LoadLanguageAndPackages }
procedure LoadLanguageAndPackages;
begin
  if RequestedLanguage <> '' then
  begin
    if not FileExists('install_' + RequestedLanguage + '.txt') then
    begin
      AppendLogLineThreadSafe('Not installed - ' + RequestedLanguage);
      RequestedLanguage := '';
    end
    else SelectedLanguage := RequestedLanguage;
  end;
  if (SelectedLanguage <> '') and (not FileExists('install_' + SelectedLanguage + '.txt')) then
    begin
      AppendLogLineThreadSafe('Not installed - ' + SelectedLanguage + ', try to switch to russian');
      SelectedLanguage := 'russian';
    end;
  if SelectedLanguage = '' then SelectedLanguage := 'russian';
  if not FileExists('install_' + SelectedLanguage + '.txt') then
    raise Exception.Create('Not installed language: ' + SelectedLanguage)
  else
  begin
    LanguageInstallConfig := TBlockParEC.Create;
    LanguageInstallConfig.LoadFromTextFileWithEncodingProbe(PWideChar('install_' + SelectedLanguage + '.txt'), False);
  end;
  ModInstallConfigs := TList.Create;
  ModLanguageInstallConfigs := TList.Create;
  LoadSelectedModInstallBlocks;
  if not LoadConfiguredPackages then raise Exception.Create('Error while openning package files');
end;
{ @end $7C44F8 }

{ @routine $7C4890 LoadSelectedModInstallBlocks }
procedure LoadSelectedModInstallBlocks;
var Index: Integer; ModNames, ModPath: WideString; Block: TBlockParEC;
begin
  ModNames := '';
  if FileExists(ModSelectionConfigPath) then
  begin
    Block := TBlockParEC.Create;
    Block.LoadFromTextFileWithEncodingProbe(ModSelectionConfigPath, False);
    if Block.CountParams('CurrentMod') > 0 then
      ModNames := TrimWideString(Block.GetParam('CurrentMod'));
    SelectedMods := ModNames;
    SelectedModsDisplaySuffix := ', ' + SelectedMods + ',';
    if ModNames <> '' then
    begin
      if SkipModsOnReload then AppendLogLineThreadSafe('Trying to reload without mods')
      else AppendLogLineThreadSafe('CurrentMod=' + ModNames);
    end;
    Block.Free;
  end
  else
  begin
    SelectedMods := '';
    SelectedModsDisplaySuffix := '';
  end;
  if SkipModsOnReload then Exit;
    Index := 0;
    repeat
      ModPath := TrimWideString(ExtractDelimitedPartW(ModNames, Index, ','));
      if ModPath <> '' then ModPath := ModPath + '\';
      if FileExists('Mods\' + ModPath + 'Install.txt') then
      begin
        Block := TBlockParEC.Create;
        ModInstallConfigs.Add(Block);
        Block.LoadFromTextFileWithEncodingProbe(PWideChar('Mods\' + ModPath + 'Install.txt'), False);
      end;
      if FileExists('Mods\' + ModPath + 'Install_' + SelectedLanguage + '.txt') then
      begin
        Block := TBlockParEC.Create;
        ModLanguageInstallConfigs.Add(Block);
        Block.LoadFromTextFileWithEncodingProbe(PWideChar('Mods\' + ModPath + 'Install_' + SelectedLanguage + '.txt'), False);
      end;
      Inc(Index);
    until Index >= CountDelimitedPartsW(ModNames, ',');
end;
{ @end $7C4890 }

{ @routine $7C4C6C ResetInstalledPackageState }
procedure ResetInstalledPackageState;
var I: Integer;
begin
  FinalizePackageCollection;
  InitializePackageCollection;
  for I := 0 to ModInstallConfigs.Count - 1 do TObject(ModInstallConfigs[I]).Free;
  ModInstallConfigs.Clear;
  for I := 0 to ModLanguageInstallConfigs.Count - 1 do TObject(ModLanguageInstallConfigs[I]).Free;
  ModLanguageInstallConfigs.Clear;
end;
{ @end $7C4C6C }

{ @routine $7C4CD8 FinalizePlatformRuntime }
procedure FinalizePlatformRuntime;
begin
  FreeSavePreviewBuffers;
  if InstallConfig <> nil then
  begin
    InstallConfig.Free;
    InstallConfig := nil;
  end;
  if LanguageInstallConfig <> nil then
  begin
    LanguageInstallConfig.Free;
    LanguageInstallConfig := nil;
  end;
  FinalizePackageCollection;
  DestroyWindow(MainWindowHandle);
  MainWindowHandle := 0;
  CoUninitialize;
end;
{ @end $7C4CD8 }

{ @routine $7C4D30 HasWow64Support }
function HasWow64Support: Boolean;
type
  TGetNativeSystemInfo = procedure(var Info: TSystemInfo); stdcall;
  TIsWow64Process = function(Process: THandle; var IsWow64: LongBool): LongBool; stdcall;
var Module: HModule; NativeSystemInfo: TGetNativeSystemInfo;
  IsWow64Process: TIsWow64Process; Wow64: LongBool; Supported: Boolean; Info: TSystemInfo;
begin
  Supported := False;
  Module := GetModuleHandle('kernel32.dll');
  NativeSystemInfo := GetProcAddress(Module, 'GetNativeSystemInfo');
  if Assigned(NativeSystemInfo) then
  begin
    NativeSystemInfo(Info);
    IsWow64Process := GetProcAddress(Module, 'IsWow64Process');
    if Assigned(IsWow64Process) then
      if IsWow64Process(GetCurrentProcess, Wow64) then
        if Wow64 then
          if GetProcAddress(GetModuleHandle('kernel32.dll'), 'Wow64DisableWow64FsRedirection') <> nil then
            if GetProcAddress(Module, 'GetSystemWow64DirectoryA') <> nil then
              if GetProcAddress(GetModuleHandle('advapi32.dll'), 'RegDeleteKeyExA') <> nil then
                Supported := True;
  end
  else GetSystemInfo(Info);
  Result := Supported;
end;
{ @end $7C4D30 }

{ @routine $7C4E68 ApplyMainWindowGeometry }
procedure ApplyMainWindowGeometry;
var
  Style: Cardinal;
  Width, Height: Cardinal;
  Bounds: TRect;
begin
  if AlternateViewportEnabled then
  begin
    Width := PresentationWidth;
    Height := PresentationHeight;
  end
  else
  begin
    Width := GameScreenWidth;
    Height := GameScreenHeight;
  end;
  if Direct3DPresentParameters.Windowed then
  begin
    if (UserSettingsConfig.CountParams('ShowCaption') > 0) and
       not ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('ShowCaption'))) then
      Style := $10000000
    else Style := $10CA0000;
    if UserSettingsConfig.CountParams('OverrideWindowPosition') > 0 then
    begin
      Bounds.Left := ExtractSignedDigitsToIntW(ExtractDelimitedPartW(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('OverrideWindowPosition')), 0, ','));
      Bounds.Top := ExtractSignedDigitsToIntW(ExtractDelimitedPartW(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('OverrideWindowPosition')), 1, ','));
    end
    else
    begin
      Bounds.Left := (DesktopDisplayMode.Width - Width) div 2;
      Bounds.Top := (DesktopDisplayMode.Height - Height) div 2;
    end;
    Bounds.Right := Bounds.Left + Integer(Width);
    Bounds.Bottom := Bounds.Top + Integer(Height);
  end
  else
  begin
    Style := $90080000;
    Bounds.Left := 0;
    Bounds.Top := 0;
    Bounds.Right := Width;
    Bounds.Bottom := Height;
  end;
  AdjustWindowRect(Bounds, Style, False);
  SetWindowLong(MainWindowHandle, GWL_STYLE, Style);
  SetWindowPos(MainWindowHandle, HWND_NOTOPMOST, Bounds.Left, Bounds.Top,
    Bounds.Right - Bounds.Left, Bounds.Bottom - Bounds.Top, SWP_SHOWWINDOW);
end;
{ @end $7C4E68 }

{ @routine $7C508C ShowAndFocusMainWindow }
procedure ShowAndFocusMainWindow;
begin
  if not Direct3DPresentParameters.Windowed then ShowWindow(MainWindowHandle, SW_SHOWMAXIMIZED)
  else ShowWindow(MainWindowHandle, SW_SHOWNORMAL);
  UpdateWindow(MainWindowHandle);
  SetFocus(MainWindowHandle);
  RedrawWindow(0, nil, 0, $787);
end;
{ @end $7C508C }

{ @routine $7C5288 LoadDatConfigAndModOverrides }
procedure LoadDatConfigAndModOverrides;
var ModNames, ModPath: WideString; HasOverrides: Boolean; Block: TBlockParEC;
  Data: TDataEC; Index: Integer;
  // @nested $7C50D8 LoadBlockDatConfig
  procedure LoadBlockDatConfig(Root: TBlockParEC; FileName: WideString); // @addr 0x007C50D8 @calls "0x007C5332,0x007C53DD,0x007C5474,0x007C5553" @note "An empty tree produces a log warning, not an exception from this wrapper."
  begin
    Root.LoadFromEncryptedDatFile(FileName);
    if (Root.GetBlockCount <= 0) and (Root.GetParamCount <= 0) then
      AppendLogLineThreadSafe('Warning! <' + FileName + '> is empty!');
  end;

  // @nested $7C51B4 LoadCacheDatConfig
  procedure LoadCacheDatConfig(Root: TDataEC; FileName: WideString); // @addr 0x007C51B4 @calls "0x007C55C0,0x007C566B"
  begin
    Root.LoadFromEncryptedDatFile(FileName);
    if Root.IsEmpty then AppendLogLineThreadSafe('Warning! <' + FileName + '> is empty!');
  end;

begin
  MainDataConfig := TBlockParEC.Create;
  ModNames := '';
  if not SkipModsOnReload and FileExists(ModSelectionConfigPath) then
  begin
    Block := TBlockParEC.Create;
    Block.LoadFromTextFileWithEncodingProbe(ModSelectionConfigPath, False);
    if Block.CountParams('CurrentMod') > 0 then
      ModNames := TrimWideString(Block.GetParamByPath('CurrentMod'));
    Block.Free;
  end;
  HasOverrides := False;
  LoadBlockDatConfig(MainDataConfig, 'CFG\Main.dat');
  Index := 0;
  if not SkipModsOnReload then
  begin
    repeat
      ModPath := TrimWideString(ExtractDelimitedPartW(ModNames, Index, ','));
      if ModPath <> '' then ModPath := ModPath + '\';
      if FileExists('Mods\' + ModPath + 'CFG\Main.dat') then
      begin
        HasOverrides := True;
        Block := TBlockParEC.Create;
        LoadBlockDatConfig(Block, 'Mods\' + ModPath + 'CFG\Main.dat');
        MainDataConfig.MergeFrom(Block);
        Block.Clear;
        Block.Free;
      end;
      Inc(Index);
    until Index >= CountDelimitedPartsW(ModNames, ',');
  end;
  if DumpLoadedConfig then MainDataConfig.SaveTextFile('Main.txt', False, True);
  LanguageDataConfig := TBlockParEC.Create;
  LoadBlockDatConfig(LanguageDataConfig, 'CFG\' + LanguageInstallConfig.GetParam('Lang') + '\Lang.dat');
  Index := 0;
  if not SkipModsOnReload then
  begin
    repeat
      ModPath := TrimWideString(ExtractDelimitedPartW(ModNames, Index, ','));
      if ModPath <> '' then ModPath := ModPath + '\';
      if FileExists('Mods\' + ModPath + 'CFG\' + LanguageInstallConfig.GetParam('Lang') + '\Lang.dat') then
      begin
        HasOverrides := True;
        Block := TBlockParEC.Create;
        LoadBlockDatConfig(Block, 'Mods\' + ModPath + 'CFG\' + LanguageInstallConfig.GetParam('Lang') + '\Lang.dat');
        LanguageDataConfig.MergeFrom(Block);
        Block.Clear;
        Block.Free;
      end;
      Inc(Index);
    until Index >= CountDelimitedPartsW(ModNames, ',');
  end;
  if DumpLoadedConfig then LanguageDataConfig.SaveTextFile('Lang.txt', False, True);
  CacheDataRoot := TDataEC.Create;
  LoadCacheDatConfig(CacheDataRoot, 'CFG\CacheData.dat');
  Index := 0;
  if not SkipModsOnReload then
  begin
    repeat
      ModPath := TrimWideString(ExtractDelimitedPartW(ModNames, Index, ','));
      if ModPath <> '' then ModPath := ModPath + '\';
      if FileExists('Mods\' + ModPath + 'CFG\CacheData.dat') then
      begin
        HasOverrides := True;
        Data := TDataEC.Create;
        LoadCacheDatConfig(Data, 'Mods\' + ModPath + 'CFG\CacheData.dat');
        CacheDataRoot.MergeFrom(Data);
        Data.Free;
      end;
      Inc(Index);
    until Index >= CountDelimitedPartsW(ModNames, ',');
  end;
  if DumpLoadedConfig then
  begin
    Block := TBlockParEC.Create;
    CacheDataRoot.WriteToBlock(Block);
    Block.SaveTextFile('CacheData.txt', False, True);
    Block.Free;
  end;
  if HasOverrides and (ModNames = '') then
  begin
    SelectedMods := 'Custom mod';
    SelectedModsDisplaySuffix := '';
    AppendLogLineThreadSafe('Custom mod');
  end;
end;
{ @end $7C5288 }

{ @routine $7C58D8 FreeDatConfigRoots }
procedure FreeDatConfigRoots;
begin
  if CacheDataRoot <> nil then
  begin
    CacheDataRoot.Free;
    CacheDataRoot := nil;
  end;
  if LanguageDataConfig <> nil then
  begin
    LanguageDataConfig.Free;
    LanguageDataConfig := nil;
  end;
  GameDataConfig := nil;
  if MainDataConfig <> nil then
  begin
    MainDataConfig.Free;
    MainDataConfig := nil;
  end;
end;
{ @end $7C58D8 }

{ @routine $7C59B0 InitializeRuntimeAndSettings }
procedure InitializeRuntimeAndSettings;
var
  ModuleName, Text, ExtraText: WideString;
  Block: TBlockParEC;
  Index, Count, BufferSize: Integer;
  Frame: Pointer;
  Cursor: TCursorUnit;
  SavedChecksumFailed: Boolean;
  Reg: TRegistry;
  MemoryStatus: TMemoryStatusEx;

  // @nested $7C5930 VerifyStartupModuleChecksum
  procedure VerifyStartupModuleChecksum; // @addr $7C5930 @calls "0x007C738F,0x007C73C9,0x007C73F1,0x007C7419,0x007C7441,0x007C7469,0x007C74B6,0x007C74E6,0x007C7516" @note "Nested startup helper; checks the module path at parent-frame -4 and writes the signed integrity marker."
  var
    MarkerOffset: Cardinal;
  begin
    CCInterface.SetResourceChecksumFailed(False);
    VerifyResourceFileChecksum(ModuleName);
    MarkerOffset := 8;
    if CCInterface.GetResourceChecksumFailed then
      PInteger(PAnsiChar(@StartupChecksumAnchor) - Integer(MarkerOffset))^ :=
        RandomIntRange(1000000000, 2000000000)
    else if PInteger(PAnsiChar(@StartupChecksumAnchor) - Integer(MarkerOffset))^ <= 0 then
      PInteger(PAnsiChar(@StartupChecksumAnchor) - Integer(MarkerOffset))^ :=
        RandomIntRange(-2000000000, -1000000000);
    CCInterface.SetResourceChecksumFailed(False);
  end;

begin
  StartupState := 0;
  FinalizeRuntimeAndSettings;
  Text := TrimWideString(ReadRegistryText(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'ProductName', ''));
  if HasWow64Support then ExtraText := ' [x64] build '
  else ExtraText := ' [x86] build ';
  ModuleName := TrimWideString(ReadRegistryText(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'CurrentBuild', ''));
  if ExtractDigitsToIntW(ModuleName) >= 22000 then
    Text := ReplaceAllWideString(Text, 'Windows 10', 'Windows 11');
  if RunningUnderWine then
    AppendLogLineThreadSafe('Wine compatibility mode is set to ''' + Text + ExtraText + ModuleName + '''')
  else
    AppendLogLineThreadSafe('Operating System=' + Text + ExtraText + ModuleName);
  Index := 0;
  Count := 0;
  while True do
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.KeyExists('HARDWARE\DESCRIPTION\System\CentralProcessor\' + IntToStr(Index)) then
        Inc(Count)
      else
        Break;
      Inc(Index);
    finally
      Reg.Free;
    end;
  end;
  Index := 0;
  Text := TrimWideString(ReadRegistryText(HKEY_LOCAL_MACHINE,
    WideString('HARDWARE\DESCRIPTION\System\CentralProcessor\' + IntToStr(Index)), 'Identifier', ''));
  ExtraText := TrimWideString(ReadRegistryText(HKEY_LOCAL_MACHINE,
    WideString('HARDWARE\DESCRIPTION\System\CentralProcessor\' + IntToStr(Index)), 'ProcessorNameString', ''));
  if Count <= 1 then ModuleName := ' (1 core)'
  else ModuleName := WideString(' (' + IntToStr(Count) + ' cores)');
  ProcessorCoreCount := Max(Count, 1);
  AppendLogLineThreadSafe('Processor=' + ExtraText + ModuleName);
  AppendLogLineThreadSafe('CPU Clock=' + IntToStr(Round(Min(Min(MeasureCpuClockMHz, MeasureCpuClockMHz), MeasureCpuClockMHz))) + ' MHz');
  MemoryStatus.Length := SizeOf(MemoryStatus);
  GlobalMemoryStatusEx(MemoryStatus);
  AppendLogLineThreadSafe('Physical Memory Total=' + IntToStr(Integer(MemoryStatus.TotalPhys div $100000)) + ' MB');
  AppendLogLineThreadSafe('Physical Memory Available=' + IntToStr(Integer(MemoryStatus.AvailPhys div $100000)) + ' MB');
  AppendLogLineThreadSafe('Page File Total=' + IntToStr(Integer(MemoryStatus.TotalPageFile div $100000)) + ' MB');
  AppendLogLineThreadSafe('Page File Available=' + IntToStr(Integer(MemoryStatus.AvailPageFile div $100000)) + ' MB');
  AppendLogLineThreadSafe('Virtual Memory Total=' + IntToStr(Integer(MemoryStatus.TotalVirtual div $100000)) + ' MB');
  AppendLogLineThreadSafe('Virtual Memory Available=' + IntToStr(Integer(MemoryStatus.AvailVirtual div $100000)) + ' MB');
  UserSettingsConfig := TBlockParEC.Create;
  Text := GetGameUserDirectory + 'CFG.TXT';
  if not FileExists(Text) then
  begin
    AppendLogTextThreadSafe('Creating cfg.txt ... ');
    CopyFileW('cfg.txt', PWideChar(Text), False);
    UserSettingsConfig.LoadFromTextFileWithEncodingProbe(PWideChar(Text), True);
    UserSettingsConfig.AddParam('CurrentVersion', GameVersionText);
    UserSettingsConfig.AddParam('VideoMemSizeLimit', '256');
    if RunningUnderWine then
    begin
      UserSettingsConfig.AddParam('RunOnWineWithoutWarning', 'True');
      ShowWineWarning := True;
    end;
    UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
    AppendLogLineThreadSafe('ok!');
  end
  else
  begin
    UserSettingsConfig.LoadFromTextFileWithEncodingProbe(PWideChar(Text), True);
    if UserSettingsConfig.CountParamsByPath('CurrentVersion') = 0 then
    begin
      AppendLogTextThreadSafe('Updating cfg.txt content ... ');
      UserSettingsConfig.AddParam('CurrentVersion', GameVersionText);
      UserSettingsConfig.SetOrAddParam('HardwareRender', 'True');
      UserSettingsConfig.SetOrAddParam('MultiThread', 'False');
      UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
      AppendLogLineThreadSafe('ok!');
    end
    else if UserSettingsConfig.GetParamByPathOrMarker('CurrentVersion') <> GameVersionText then
    begin
      AppendLogTextThreadSafe('Updating cfg.txt version ... ');
      if (UserSettingsConfig.GetParam('CurrentVersion') = '2.1.1800') and
        (UserSettingsConfig.CountParamsByPath('CountFilmSave') > 0) and
        (UserSettingsConfig.GetParamByPathOrMarker('CountFilmSave') = '30') then
        UserSettingsConfig.SetOrAddParam('CountFilmSave', '7');
      UserSettingsConfig.SetOrAddParam('CurrentVersion', GameVersionText);
      UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
      AppendLogLineThreadSafe('ok!');
    end;
    if UserSettingsConfig.CountParamsByPath('VideoMemSizeLimit') = 0 then
    begin
      AppendLogTextThreadSafe('Updating cfg.txt content ... ');
      UserSettingsConfig.AddParam('VideoMemSizeLimit', '256');
      UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
      AppendLogLineThreadSafe('ok!');
    end;
    if RunningUnderWine then
      if (UserSettingsConfig.CountParams('RunOnWineWithoutWarning') = 0) or
        not ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('RunOnWineWithoutWarning'))) then
      begin
        if UserSettingsConfig.CountParams('RunOnWineWithoutWarning') = 0 then
          UserSettingsConfig.AddParam('RunOnWineWithoutWarning', 'True')
        else
          UserSettingsConfig.SetOrAddParam('RunOnWineWithoutWarning', 'True');
        UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
        ShowWineWarning := True;
      end;
  end;
  EditableSaveBlock := TBlockParEC.Create;
  NewGameSettingsConfig := TBlockParEC.Create;
  Text := GetGameUserDirectory + 'newgame.txt';
  if FileExists(PWideChar(Text)) then
    NewGameSettingsConfig.LoadFromTextFileWithEncodingProbe(PWideChar(Text), True);
  if UserSettingsConfig.CountParamsByPath('MultiThread') > 0 then
    MultiThreadEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('MultiThread'));
  ApplyProcessAffinity;
  PathGrowEnabled := True;
  if UserSettingsConfig.CountParams('PathGrow') > 0 then
    PathGrowEnabled := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('PathGrow')));
  ShowSystemMouse := False;
  if UserSettingsConfig.CountParams('ShowSystemMouse') > 0 then
    ShowSystemMouse := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('ShowSystemMouse')));
  if FileExists('Mods\ShipName.txt') then
  begin
    ModShipNameConfig := TBlockParEC.Create;
    ModShipNameConfig.LoadFromTextFileWithEncodingProbe('Mods\ShipName.txt', False);
  end;
  if FileExists('Mods\RuinName.txt') then
  begin
    ModRuinNameConfig := TBlockParEC.Create;
    ModRuinNameConfig.LoadFromTextFileWithEncodingProbe('Mods\RuinName.txt', False);
  end;
  if FileExists('MusicChange.txt') then
  begin
    MainDataConfig.GetBlock('Music').Clear;
    MainDataConfig.GetBlock('Music').LoadFromTextFileWithEncodingProbe('MusicChange.txt', False);
  end;
  CacheDataRoot.AddMissingFromBlock(LanguageDataConfig.GetBlockByPath('PlanetQuest'));
  GlobalCache := TCacheEC.Create;
  GlobalCache.SetDataRoot(CacheDataRoot);
  GlobalCache.ResidentByteLimit := 0;
  if UserSettingsConfig.CountParams('CacheSize') > 0 then
    GlobalCache.ResidentByteLimit := (ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('CacheSize')) shl 10) shl 10;
  if GlobalCache.ResidentByteLimit <= $1000000 then
    if MemoryStatus.AvailVirtual > $48000000 then
      GlobalCache.ResidentByteLimit := $18000000
    else
      GlobalCache.ResidentByteLimit := Min(Int64(Cardinal(MemoryStatus.AvailVirtual) div 3), Int64($18000000));
  AppendLogLineThreadSafe('Cache Size=' + IntToStr(GlobalCache.ResidentByteLimit div 1024) + ' KB');
  if UserSettingsConfig.CountParams('Brightness') > 0 then
    DisplayBrightness := ParseDecimalToSingleW(UserSettingsConfig.GetParamByPathOrMarker('Brightness'));
  if UserSettingsConfig.CountParams('Contrast') > 0 then
    DisplayContrast := ParseDecimalToSingleW(UserSettingsConfig.GetParamByPathOrMarker('Contrast'));
  if UserSettingsConfig.CountParams('RobotBrightness') > 0 then
    RobotBrightness := ParseDecimalToSingleW(UserSettingsConfig.GetParamByPathOrMarker('RobotBrightness'));
  if UserSettingsConfig.CountParams('RobotContrast') > 0 then
    RobotContrast := ParseDecimalToSingleW(UserSettingsConfig.GetParamByPathOrMarker('RobotContrast'));
  if UserSettingsConfig.CountParams('3D') > 0 then
    ThreeDimensionalModeEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('3D'));
  UiStyleConfig := MainDataConfig.GetBlockByPath('ML');
  GameDataConfig := MainDataConfig.GetBlockByPath('Data');
  LoadInformationColorTags;
  UiDepthConfig := MainDataConfig.GetBlockByPath('ZPos');
  PlanetDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('Planet'));
  ShipPathDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('UnitPathShip'));
  ShipPathEndDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('UnitPathEndShip'));
  UnitPathDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('UnitPath'));
  UnitPathEndDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('UnitPathEnd'));
  ActionButtonDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('ButtonAction'));
  GalaxyStarDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('GalaxyStar'));
  GalaxyStarNameDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('GalaxyStarName'));
  GalaxyWarDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('GalaxyWar'));
  ConstellationLineDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('ConstellationLine'));
  ConstellationColorDepth := ExtractDecimalToSingleW(UiDepthConfig.GetParam('ConstellationColor'));
  if UserSettingsConfig.CountParamsByPath('Sound') > 0 then
    SoundEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('Sound'));
  if UserSettingsConfig.CountParamsByPath('SoundInSpace') > 0 then
    SoundInSpaceEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SoundInSpace'));
  if UserSettingsConfig.CountParamsByPath('SoundVolume') > 0 then
    SoundVolume := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('SoundVolume')) / 100;
  if SoundVolume > 1 then SoundVolume := 1;
  if SoundVolume < 0 then SoundVolume := 0;
  if UserSettingsConfig.CountParamsByPath('RobotSoundVolume') > 0 then
    RobotSoundVolume := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('RobotSoundVolume')) / 100;
  if RobotSoundVolume > 1 then RobotSoundVolume := 1;
  if RobotSoundVolume < 0 then RobotSoundVolume := 0;
  if not IsInstallFeatureEnabled('Sound') then SoundEnabled := False;
  if not IsInstallFeatureEnabled('SoundInSpace') then SoundInSpaceEnabled := False;
  if UserSettingsConfig.CountParamsByPath('Music') > 0 then
    MusicEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('Music'));
  if UserSettingsConfig.CountParamsByPath('MusicInSpace') > 0 then
    MusicInSpaceEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('MusicInSpace'));
  if UserSettingsConfig.CountParamsByPath('MusicInHyper') > 0 then
    MusicInHyperEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('MusicInHyper'));
  if UserSettingsConfig.CountParamsByPath('MusicInPlanet') > 0 then
    MusicInPlanetEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('MusicInPlanet'));
  if UserSettingsConfig.CountParamsByPath('MusicVolume') > 0 then
    MusicVolume := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('MusicVolume')) / 100;
  if MusicVolume > 1 then MusicVolume := 1;
  if MusicVolume < 0 then MusicVolume := 0;
  if UserSettingsConfig.CountParamsByPath('RobotMusicVolume') > 0 then
    RobotMusicVolume := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('RobotMusicVolume')) / 100;
  if RobotMusicVolume > 1 then RobotMusicVolume := 1;
  if RobotMusicVolume < 0 then RobotMusicVolume := 0;
  if not IsInstallFeatureEnabled('Music') then MusicEnabled := False;
  if not IsInstallFeatureEnabled('MusicInSpace') then MusicInSpaceEnabled := False;
  Block := LanguageDataConfig.GetBlock('CaseConv');
  Count := Block.GetParamCount;
  SetLength(WideCaseTable, Count);
  for Index := 0 to Count - 1 do
  begin
    WideCaseTable[Index].LowerChar := Block.GetParamName(Index)[1];
    WideCaseTable[Index].UpperChar := Block.GetParamValue(Index)[1];
  end;
  AppendLogLineThreadSafe('Loading configuration files.... ok!');
  AppendLogLineThreadSafe('Creating window.... ok!');
  if SoundEnabled then AppendLogLineThreadSafe('Sound interfaces are:')
  else AppendLogLineThreadSafe('Sound is disabled...');
  SoundManager := TSoundControl.Create;
  MusicManager := TMusicControl.Create;
  if XonarSoundDevice then
    if (UserSettingsConfig.CountParams('RunWithXonarWithoutWarning') = 0) or
      not ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('RunWithXonarWithoutWarning'))) then
    begin
      if UserSettingsConfig.CountParams('RunWithXonarWithoutWarning') = 0 then
        UserSettingsConfig.AddParam('RunWithXonarWithoutWarning', 'True')
      else
        UserSettingsConfig.SetOrAddParam('RunWithXonarWithoutWarning', 'True');
      Text := GetGameUserDirectory + 'CFG.TXT';
      UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
      ShowXonarWarning := True;
    end;
  GR_DXInit;
  ScreenCenterX := GameScreenWidth shr 1;
  ScreenCenterY := GameScreenHeight shr 1;
  ShowAndFocusMainWindow;
  if not ShowSystemMouse then ShowCursor(False);
  AppendLogLineThreadSafe('Sound=' + BoolToWideString(SoundEnabled));
  AppendLogLineThreadSafe('Music=' + BoolToWideString(MusicEnabled));
  InterfaceBlendPalette := AllocEC(512);
  for Index := 0 to 255 do
  begin
    WriteWordEC(AddPointerOffset(InterfaceBlendPalette, 2 * Index), CurrentPixelFormat.PackRgbBytes(8, 32, 255));
    BlendPixel16(AddPointerOffset(InterfaceBlendPalette, 2 * Index), CurrentPixelFormat.PackRgbBytes(200, 128, 128), Index);
  end;
  if RecordingFrameBuffers <> nil then
  begin
    for Index := 0 to RecordingFrameBuffers.Count - 1 do FreeEC(RecordingFrameBuffers[Index]);
    RecordingFrameBuffers.Clear;
    RecordingFrameBuffers.Free;
    RecordingFrameBuffers := nil;
  end;
  if UserSettingsConfig.CountParamsByPath('FilmBufSize') > 0 then
  begin
    BufferSize := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('FilmBufSize'));
    if BufferSize > 0 then
    begin
      RecordingFrameBuffers := TList.Create;
      Count := ((BufferSize shl 10) shl 10) div Integer(GameScreenWidth * GameScreenHeight * 2) + 1;
      AppendLogLineThreadSafe('FilmFrame=' + IntToStr(Count));
      for Index := 0 to Count - 1 do
      begin
        Frame := AllocEC(GameScreenWidth * GameScreenHeight * 2);
        RecordingFrameBuffers.Add(Frame);
      end;
    end;
  end;
  if UserSettingsConfig.CountParamsByPath('FilmFPS') > 0 then
    RecordingFrameInterval := 1000 div ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('FilmFPS'));
  Block := MainDataConfig.GetBlockByPath('Graph.Cursor');
  for Index := 0 to Block.GetBlockCount - 1 do
  begin
    Cursor := AddCursorUnit;
    Cursor.Name := Block.GetBlockNameByIndex(Index);
    Cursor.ImagePath := Block.GetBlockByIndex(Index).GetParam('Image');
    Cursor.HotSpot := GetPointGI(Block.GetBlockByIndex(Index).GetParam('Sme'));
  end;
  if LanguageDataConfig.GetParamByPathOrMarker('BV.BV') <> GameVersionText then
  begin
    AppendLogLineThreadSafe('Build version mismatch with Lang.dat!');
    BuildVersionMismatch := True;
  end;
  if MainDataConfig.GetParamByPathOrMarker('BV.BV') <> GameVersionText then
  begin
    AppendLogLineThreadSafe('Build version mismatch with Main.dat!');
    BuildVersionMismatch := True;
  end;
  if CacheDataRoot.FindEntry('BV').ChildData.FindEntry('BV').SharedFileRef.FileRef.FileName <> GameVersionText then
  begin
    AppendLogLineThreadSafe('Build version mismatch with CacheData.dat!');
    BuildVersionMismatch := True;
  end;
  SavedChecksumFailed := CCInterface.GetResourceChecksumFailed;
  Text := 'll';
  Text := '.d' + Text;
  ModuleName := DecodeTextW('sotoenalm^_^aucah') + Text; // 'steam_ach'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('sotoenalm^_^aupki') + Text; // 'steam_api'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('zoloimba') + Text; // 'zlib'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('MhastorhinxaGrakmae') + Text; // 'MatrixGame'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('ookogifa') + Text; // 'okgf'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('xavriadeccomrie') + Text; // 'xvidcore'
  VerifyStartupModuleChecksum;
  ExtraText := 'ib';
  ExtraText := 'l' + ExtraText;
  ModuleName := ExtraText + DecodeTextW('osgaga-10a') + Text; // 'ogg-0'
  VerifyStartupModuleChecksum;
  ModuleName := ExtraText + DecodeTextW('vrokrablius-->0') + Text; // 'vorbis-0'
  VerifyStartupModuleChecksum;
  ModuleName := ExtraText + DecodeTextW('veohrablissufainlae') + Text; // 'vorbisfile'
  VerifyStartupModuleChecksum;
  CCInterface.SetResourceChecksumFailed(SavedChecksumFailed);
end;
{ @end $7C59B0 }

{ @routine $7C84A8 FinalizeRuntimeAndSettings }
procedure FinalizeRuntimeAndSettings;
begin
  while FirstRegisteredCursor <> nil do RemoveCursorUnit(LastRegisteredCursor);
  if InterfaceBlendPalette <> nil then
  begin
    FreeEC(InterfaceBlendPalette);
    InterfaceBlendPalette := nil;
  end;
  if SoundManager <> nil then SoundManager.SignalStop;
  if MusicManager <> nil then
  begin
    MusicManager.Free;
    MusicManager := nil;
  end;
  if SoundManager <> nil then
  begin
    SoundManager.Free;
    SoundManager := nil;
  end;
  if GlobalCache <> nil then
  begin
    GlobalCache.Free;
    GlobalCache := nil;
  end;
  if ModShipNameConfig <> nil then
  begin
    ModShipNameConfig.Free;
    ModShipNameConfig := nil;
  end;
  if ModRuinNameConfig <> nil then
  begin
    ModRuinNameConfig.Free;
    ModRuinNameConfig := nil;
  end;
  if UserSettingsConfig <> nil then
  begin
    UserSettingsConfig.Free;
    UserSettingsConfig := nil;
  end;
  FreeScreenRenderBuffers;
  WideCaseTable := nil;
end;
{ @end $7C84A8 }

{ @routine $7C859C EnumerateAndSelectDisplayModes }
procedure EnumerateAndSelectDisplayModes;
var
  Index, ModeCount: Integer;
  Resolution, ModeKey: WideString;
  SmallestArea: Integer;
  Modes: TBlockParEC;
  Mode: TDisplayModeGR;
  // Native reserves 16 unused local bytes here; original type is unresolved.
  UnusedLocal: array[0..15] of Byte;
begin
  if GameDisplayModeCount = 0 then Direct3D.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, DesktopDisplayMode);
  FillChar(Mode, SizeOf(Mode), 0);
  GameDisplayModeCount := 0;
  SelectedGameDisplayMode := -1;
  SmallestGameDisplayMode := -1;
  SmallestArea := -1;
  RobotDisplayModeCount := 0;
  SelectedRobotDisplayMode := -1;
  Resolution := '';
  if UserSettingsConfig.CountParams('VideoMode') > 0 then
    Resolution := TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('VideoMode'));
  if CountDelimitedPartsW(Resolution, ',') > 1 then
  begin
    GameScreenWidth := ExtractDigitsToIntW(ExtractDelimitedPartW(Resolution, 0, ','));
    GameScreenHeight := ExtractDigitsToIntW(ExtractDelimitedPartW(Resolution, 1, ','));
    RequestedRefreshRate := 0;
    if CountDelimitedPartsW(Resolution, ',') > 2 then
      RequestedRefreshRate := ExtractDigitsToIntW(ExtractDelimitedPartW(Resolution, 2, ','));
  end
  else
  begin
    GameScreenWidth := 0;
    GameScreenHeight := 0;
    RequestedRefreshRate := 0;
  end;
  // Native keeps the VideoMode text when RobotResolution is absent.
  if UserSettingsConfig.CountParams('RobotResolution') > 0 then
    Resolution := TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('RobotResolution'));
  if CountDelimitedPartsW(Resolution, ',') > 1 then
  begin
    RobotSettings.ScreenWidth := ExtractDigitsToIntW(ExtractDelimitedPartW(Resolution, 0, ','));
    RobotSettings.ScreenHeight := ExtractDigitsToIntW(ExtractDelimitedPartW(Resolution, 1, ','));
  end
  else
  begin
    RobotSettings.ScreenWidth := 0;
    RobotSettings.ScreenHeight := 0;
  end;
  UseDesktopDisplayMode := False;
  if (GameScreenWidth < 1024) or (GameScreenHeight < 720) then
  begin
    GameScreenWidth := DesktopDisplayMode.Width;
    GameScreenHeight := DesktopDisplayMode.Height;
    UseDesktopDisplayMode := True;
  end;
  UseAutomaticRobotDisplayMode := False;
  if (RobotSettings.ScreenWidth < 1024) or (RobotSettings.ScreenHeight < 720) then
    UseAutomaticRobotDisplayMode := True;
  ModeCount := Direct3D.GetAdapterModeCount(D3DADAPTER_DEFAULT, DesktopDisplayMode.Format);
  if (DesktopDisplayMode.Format <> D3DFMT_X8R8G8B8) and (DesktopDisplayMode.Format <> D3DFMT_A8R8G8B8) then
    DesktopDisplayMode.Format := D3DFMT_X8R8G8B8;
  Modes := TBlockParEC.Create;
  for Index := 0 to ModeCount - 1 do
  begin
    Direct3D.EnumAdapterModes(D3DADAPTER_DEFAULT, DesktopDisplayMode.Format, Index, Mode);
    if Mode.Height < 720 then Continue;
    ModeKey := SysUtils.IntToHex(Int64(Mode.Width), 6) + SysUtils.IntToHex(Int64(Mode.Height), 6);
    if (Modes.CountParams(ModeKey) > 0) and
       (SysUtils.StrToInt(ExtractDelimitedPartW(Modes.GetParam(ModeKey), 0, ',')) >= Integer(Mode.RefreshRate)) then Continue;
    Modes.SetOrAddParam(ModeKey, SysUtils.IntToStr(Int64(Mode.RefreshRate)) + ',' + SysUtils.IntToStr(Index));
  end;
  GameDisplayModeCount := Modes.GetParamCount;
  RobotDisplayModeCount := Modes.GetParamCount;
  SetLength(GameDisplayModes, GameDisplayModeCount + 2);
  SetLength(RobotDisplayModes, RobotDisplayModeCount + 2);
  AppendLogLineThreadSafe('Desktop Resolution=' + SysUtils.IntToStr(Int64(DesktopDisplayMode.Width)) + 'x' + SysUtils.IntToStr(Int64(DesktopDisplayMode.Height)));
  AppendLogTextThreadSafe('Available Resolutions=');
  for Index := 0 to Modes.GetParamCount - 1 do
  begin
    ModeKey := Modes.GetParamValue(Index);
    Direct3D.EnumAdapterModes(D3DADAPTER_DEFAULT, DesktopDisplayMode.Format,
      SysUtils.StrToInt(ExtractDelimitedPartW(ModeKey, 1, ',')), Mode);
    GameDisplayModes[Index] := Mode;
    RobotDisplayModes[Index] := Mode;
    if (SmallestArea < 0) or (Integer(Mode.Width * Mode.Height) < SmallestArea) then
    begin
      SmallestArea := Mode.Width * Mode.Height;
      SmallestGameDisplayMode := Index;
    end;
    if (Mode.Width = GameScreenWidth) and (Mode.Height = GameScreenHeight) then SelectedGameDisplayMode := Index;
    if (Cardinal(RobotSettings.ScreenWidth) = Mode.Width) and (Cardinal(RobotSettings.ScreenHeight) = Mode.Height) then SelectedRobotDisplayMode := Index;
    if Index > 0 then AppendLogTextThreadSafe(', ');
    AppendLogTextThreadSafe(SysUtils.IntToStr(Int64(Mode.Width)) + 'x' + SysUtils.IntToStr(Int64(Mode.Height)));
  end;
  Modes.Free;
  if GameDisplayModeCount = 0 then
  begin
    AppendLogTextThreadSafe('No supported resolutions found!');
    if (GameScreenWidth < 1024) or (GameScreenHeight < 720) then
    begin
      AlternateViewportEnabled := True;
      ViewportOffset := Classes.Point(0, 0);
      PresentationWidth := GameScreenWidth;
      PresentationHeight := GameScreenHeight;
      RobotSettings.ScreenWidth := GameScreenWidth;
      RobotSettings.ScreenHeight := GameScreenHeight;
      if ScaleViewportToWindow then
      begin
        if GameScreenWidth > GameScreenHeight then
        begin
          GameScreenHeight := 720;
          GameScreenWidth := Cardinal(Integer(GameScreenHeight) * PresentationWidth) div Cardinal(PresentationHeight);
        end
        else
        begin
          GameScreenWidth := 1024;
          GameScreenHeight := Cardinal(Integer(GameScreenWidth) * PresentationHeight) div Cardinal(PresentationWidth);
        end;
      end
      else
      begin
        GameScreenWidth := Math.Max(1024, Int64(GameScreenWidth));
        GameScreenHeight := Math.Max(720, Int64(GameScreenHeight));
      end;
      HardwareRenderingEnabled := False;
    end;
  end;
  GameDisplayModes[GameDisplayModeCount].Width := 0;
  GameDisplayModes[GameDisplayModeCount].Height := 0;
  GameDisplayModes[GameDisplayModeCount].RefreshRate := DesktopDisplayMode.RefreshRate;
  RobotDisplayModes[RobotDisplayModeCount].Width := 0;
  RobotDisplayModes[RobotDisplayModeCount].Height := 0;
  if UseDesktopDisplayMode then SelectedGameDisplayMode := GameDisplayModeCount;
  if UseAutomaticRobotDisplayMode then SelectedRobotDisplayMode := RobotDisplayModeCount;
  Inc(GameDisplayModeCount);
  Inc(RobotDisplayModeCount);
  if SelectedGameDisplayMode = -1 then
  begin
    SelectedGameDisplayMode := GameDisplayModeCount;
    GameDisplayModes[SelectedGameDisplayMode].Width := GameScreenWidth;
    GameDisplayModes[SelectedGameDisplayMode].Height := GameScreenHeight;
    Inc(GameDisplayModeCount);
  end;
  if SelectedRobotDisplayMode = -1 then
  begin
    SelectedRobotDisplayMode := RobotDisplayModeCount;
    RobotDisplayModes[SelectedRobotDisplayMode].Width := RobotSettings.ScreenWidth;
    RobotDisplayModes[SelectedRobotDisplayMode].Height := RobotSettings.ScreenHeight;
    Inc(RobotDisplayModeCount);
  end;
  AppendLogLineThreadSafe('');
  ExtraScreenWidth := Integer(GameScreenWidth) - 1024;
  ExtraScreenHeight := Integer(GameScreenHeight) - 768;
  GameScreenRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  PresentationRect := Classes.Rect(0, 0, PresentationWidth, PresentationHeight);
end;
{ @end $7C859C }

{ @routine $7C8FD8 ConfigureDefaultRenderState }
procedure ConfigureDefaultRenderState;
begin
  Direct3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, 1);
  Direct3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
  Direct3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
  Direct3DDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
  Direct3DDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  Direct3DDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  Direct3DDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  Direct3DDevice.SetRenderState(D3DRS_SCISSORTESTENABLE, 1);
  Direct3DDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
end;
{ @end $7C8FD8 }

{ @routine $7C9074 PreparePresentationParameters }
procedure PreparePresentationParameters;
begin
  PreviousPresentParameters := Direct3DPresentParameters;
  with Direct3DPresentParameters do
  begin
    ZeroMemory(@Direct3DPresentParameters, SizeOf(Direct3DPresentParameters));
    Windowed := WindowedModeRequested and (GameScreenHeight < DesktopDisplayMode.Height);
    DeviceWindow := MainWindowHandle;
    if DisableTripleBuffer then BackBufferCount := 1 else BackBufferCount := 2;
    BackBufferFormat := DesktopDisplayMode.Format;
    PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
    if Windowed then
    begin
      if VSyncEnabled then PresentationInterval := D3DPRESENT_INTERVAL_DEFAULT;
      SwapEffect := D3DSWAPEFFECT_DISCARD;
    end
    else
    begin
      if VSyncEnabled then PresentationInterval := D3DPRESENT_INTERVAL_ONE;
      SwapEffect := D3DSWAPEFFECT_FLIP;
      if UseDesktopDisplayMode then
      begin
        BackBufferWidth := DesktopDisplayMode.Width;
        BackBufferHeight := DesktopDisplayMode.Height;
        FullScreenRefreshRateInHz := DesktopDisplayMode.RefreshRate;
      end
      else
      begin
        BackBufferWidth := GameDisplayModes[SelectedGameDisplayMode].Width;
        BackBufferHeight := GameDisplayModes[SelectedGameDisplayMode].Height;
        if RequestedRefreshRate > 0 then FullScreenRefreshRateInHz := RequestedRefreshRate
        else FullScreenRefreshRateInHz := GameDisplayModes[SelectedGameDisplayMode].RefreshRate;
      end;
    end;
    PresentationFrameRate := FullScreenRefreshRateInHz;
    if PresentationFrameRate = 0 then PresentationFrameRate := DesktopDisplayMode.RefreshRate;
    if PresentationFrameRate = 0 then PresentationFrameRate := 50;
  end;
end;
{ @end $7C9074 }

{ @routine $7C91B4 GR_DXInit }
procedure GR_DXInit;
var
  ControlWord: Word;
  Code: Integer;
  Surface: IDirect3DSurface9;
  Index, MiniMapSize: Integer;
  Angle: Single;
  DeviceFlags: Cardinal;
  Identifier: TD3DAdapterIdentifier9;
  Caps: TD3DCaps9;
begin
  FreeScreenRenderBuffers;
  WindowedModeRequested := False;
  if UserSettingsConfig.CountParams('Window') > 0 then
    WindowedModeRequested := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('Window')));
  VSyncEnabled := False;
  if UserSettingsConfig.CountParams('VSync') > 0 then
    VSyncEnabled := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('VSync')));
  HardwareRenderingRequested := False;
  if UserSettingsConfig.CountParams('HardwareRender') > 0 then
    HardwareRenderingRequested := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('HardwareRender')));
  HardwareRenderingEnabled := HardwareRenderingRequested and
    (not RunningUnderWine or ((UserSettingsConfig.CountParams('AllowHardwareRenderUnderWine') <> 0) and
      ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('AllowHardwareRenderUnderWine')))));
  ScaleViewportToWindow := True;
  if UserSettingsConfig.CountParams('RenderModeScale') > 0 then
    ScaleViewportToWindow := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('RenderModeScale')));
  TextureManagerDisabled := False;
  if UserSettingsConfig.CountParams('DisableTextureManager') > 0 then
    TextureManagerDisabled := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('DisableTextureManager')));
  PresentWithoutLimit := False;
  if UserSettingsConfig.CountParams('DisableFrameLimit') > 0 then
    PresentWithoutLimit := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('DisableFrameLimit')));
  DisableHardwareVertexProcessing := False;
  if UserSettingsConfig.CountParams('DisableHWVertexProcessing') > 0 then
    DisableHardwareVertexProcessing := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('DisableHWVertexProcessing')));
  DisableMultithreadFlag := False;
  if UserSettingsConfig.CountParams('DisableMultithreadFlag') > 0 then
    DisableMultithreadFlag := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('DisableMultithreadFlag')));
  DisableTripleBuffer := False;
  if UserSettingsConfig.CountParams('DisableTripleBuffer') > 0 then
    DisableTripleBuffer := ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('DisableTripleBuffer')));
  ScreenRenderBuffer := TGraphBufGR.Create(True);
  RenderScratchBuffer := TGraphBufGR.Create(True);
  AuxRenderBuffer := TGraphBufGR.Create(True);
  ControlWord := $133F;
  asm
    fclex
    and ControlWord, $FCFF
    fldcw ControlWord
  end;
  try
    if Direct3D = nil then
    begin
      Direct3D := CreateDirect3D9($80000020);
      // Native constructs this exception without raising it.
      if Direct3D = nil then EDirectXRender.Create('GR_DXInit()::Direct3DCreate9(...)');
      AppendLogLineThreadSafe('Initializing DX9.... ok!');
      Direct3D.GetAdapterIdentifier(D3DADAPTER_DEFAULT, 0, Identifier);
      AppendLogLineThreadSafe('Videocard=' + AnsiString(Identifier.Description));
      AppendLogLineThreadSafe('Driver=' + AnsiString(Identifier.Driver));
    end;
    SupportedMultiSamples := nil;
    SupportedMultiSampleCount := 0;
    for Index := 0 to 16 do
      if Direct3D.CheckDeviceMultiSampleType(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_A8R8G8B8, False, Index, nil) = 0 then
      begin
        SetLength(SupportedMultiSamples, SupportedMultiSampleCount + 1);
        SupportedMultiSamples[SupportedMultiSampleCount] := Index;
        Inc(SupportedMultiSampleCount);
      end;
    if Direct3D.GetDeviceCaps(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Caps) = 0 then
      MaximumAnisotropy := Caps.MaxAnisotropy;
    MaxTextureSize.X := Caps.MaxTextureWidth;
    MaxTextureSize.Y := Caps.MaxTextureHeight;
    AppendLogLineThreadSafe('Max Texture Size=' + IntToStr(Int64(Caps.MaxTextureWidth)) + 'x' + IntToStr(Int64(Caps.MaxTextureHeight)));
    EnumerateAndSelectDisplayModes;
    PreparePresentationParameters;
    ApplyMainWindowGeometry;
    if Direct3DDevice = nil then
    begin
      DeviceFlags := 0;
      if not DisableMultithreadFlag then DeviceFlags := D3DCREATE_MULTITHREADED;
      if not DisableHardwareVertexProcessing then
        Code := Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, MainWindowHandle,
          DeviceFlags or D3DCREATE_HARDWARE_VERTEXPROCESSING, Direct3DPresentParameters, Direct3DDevice)
      else
        Code := -1;
      if Code <> 0 then
        Code := Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, MainWindowHandle,
          DeviceFlags or D3DCREATE_SOFTWARE_VERTEXPROCESSING, Direct3DPresentParameters, Direct3DDevice);
      if (Code <> 0) or (Direct3DDevice = nil) then
      begin
        AppendLogLineThreadSafe('Error: GR_DXInit()::GR_Direct3D.CreateDevice, failed to create device, trying to switch to minimal resolution...');
        SelectedGameDisplayMode := SmallestGameDisplayMode;
        GameScreenWidth := GameDisplayModes[SelectedGameDisplayMode].Width;
        GameScreenHeight := GameDisplayModes[SelectedGameDisplayMode].Height;
        PresentationWidth := GameScreenWidth;
        PresentationHeight := GameScreenHeight;
        ExtraScreenWidth := Integer(GameScreenWidth) - 1024;
        ExtraScreenHeight := Integer(GameScreenHeight) - 768;
        GameScreenRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
        PresentationRect := Classes.Rect(0, 0, PresentationWidth, PresentationHeight);
        WindowedModeRequested := True;
        AlternateViewportEnabled := False;
        PreparePresentationParameters;
        ApplyMainWindowGeometry;
        Code := Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, MainWindowHandle,
          DeviceFlags or D3DCREATE_SOFTWARE_VERTEXPROCESSING, Direct3DPresentParameters, Direct3DDevice);
        if (Code <> 0) or (Direct3DDevice = nil) then
        begin
          LogPresentationParameters;
          raise EDirectXRender.CreateCode('GR_DXInit()::GR_Direct3D.CreateDevice', Code);
        end;
      end;
      Direct3DDevice.GetRenderTarget(0, Surface);
      Direct3DDevice.ColorFill(Surface, nil, 0);
      Direct3DDevice.GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, Surface);
      Direct3DDevice.ColorFill(Surface, nil, 0);
      Direct3DDevice.GetBackBuffer(0, 1, D3DBACKBUFFER_TYPE_MONO, Surface);
      Direct3DDevice.ColorFill(Surface, nil, 0);
      AppendLogLineThreadSafe('Initializing Direct3D device... ok!');
    end
    else
    begin
      Code := Direct3DDevice.Reset(Direct3DPresentParameters);
      if Code <> 0 then
      begin
        LogPresentationParameters;
        raise EDirectXRender.CreateCode('GR_DXInit()::GR_D3DDevice.Reset', Code);
      end;
      AppendLogLineThreadSafe('Re-initializing Direct3D device... ok!');
    end;
    AvailableTextureBytes := Direct3DDevice.GetAvailableTextureMem;
    ReservedTextureBytes := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('VideoMemSizeLimit'));
    AppendLogLineThreadSafe('Available Video Memory=' + IntToStr(Int64(AvailableTextureBytes shr 10)) + ' KB');
    if Integer(ReservedTextureBytes) > 0 then
    begin
      AppendLogLineThreadSafe('Available Video Memory Override=' + IntToStr(Integer(ReservedTextureBytes shl 10)) + ' KB');
      ReservedTextureBytes := AvailableTextureBytes - ((ReservedTextureBytes shl 10) shl 10);
    end;
    UserSettingsConfig.GetParam('VideoMemSizeLimit');
    for Index := Low(DrawVertices) to High(DrawVertices) do
    begin
      DrawVertices[Index].Z := 1;
      DrawVertices[Index].RHW := 1;
    end;
    Direct3DDevice.SetVertexShader(nil);
    Direct3DDevice.SetFVF(D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
    ConfigureDefaultRenderState;
    AppendLogTextThreadSafe('Display Mode=');
    if not Direct3DPresentParameters.Windowed then
    begin
      AppendLogTextThreadSafe(IntToStr(Int64(Direct3DPresentParameters.BackBufferWidth)) + 'x' +
        IntToStr(Int64(Direct3DPresentParameters.BackBufferHeight)) + ' ' +
        IntToStr(Int64(Direct3DPresentParameters.FullScreenRefreshRateInHz)) + 'Hz');
      if AlternateViewportEnabled then
        AppendLogLineThreadSafe(' [' + IntToStr(Int64(GameScreenWidth)) + 'x' +
          IntToStr(Int64(GameScreenHeight)) + ']');
    end
    else
    begin
      if AlternateViewportEnabled then
        AppendLogTextThreadSafe(IntToStr(Int64(Cardinal(PresentationWidth))) + 'x' +
          IntToStr(Int64(Cardinal(PresentationHeight))) + ' [');
      AppendLogTextThreadSafe(IntToStr(Int64(GameScreenWidth)) + 'x' + IntToStr(Int64(GameScreenHeight)));
      if AlternateViewportEnabled then AppendLogTextThreadSafe(']');
    end;
    AppendLogLineThreadSafe('');
  except
    on E: EDirectXRender do
    begin
      ThreeDimensionalModeEnabled := False;
      Direct3DDevice := nil;
      Direct3D := nil;
    end;
  end;
  CurrentPixelFormat := TPixelFormatGR.Create;
  CurrentPixelFormat.RedMask := $F800;
  CurrentPixelFormat.GreenMask := $7E0;
  CurrentPixelFormat.BlueMask := $1F;
  CurrentPixelFormat.AlphaMask := 0;
  CurrentPixelFormat.BytesPerPixel := 2;
  CurrentPixelFormat.RebuildChannelMetrics;
  BlendPixel16 := @OKGR_PixelAlpha_16;
  TriangleRasterizer16 := @OKGF_Triangle_16;
  LineRasterizer16 := @OKGF_LineIp_16;
  ScreenRenderBuffer.AllocateNativePitch(GameScreenWidth, GameScreenHeight, 2 * GameScreenWidth);
  if GameDataConfig.CountParams('MiniMapBufSize') > 0 then
    MiniMapSize := ExtractDigitsToIntW(GameDataConfig.GetParam('MiniMapBufSize'))
  else
    MiniMapSize := 156;
  RenderScratchBuffer.AllocateNative(MiniMapSize, MiniMapSize);
  ApplyGammaRamp(DisplayBrightness, DisplayContrast);
  // Native uses two different approximations of pi for these tables.
  for Index := Low(CircleCos) to High(CircleCos) do
  begin
    Angle := Index * (GamePi / 180);
    CircleCos[Index] := Cos(Angle);
    CircleSin[Index] := Sin(Angle);
  end;
  for Index := Low(LineAlphaTable) to High(LineAlphaTable) do
    LineAlphaTable[Index] := Trunc(Cos(Index / 180 * 3.14159265354) * 127 + 128);
  PendingPointCapacity := 1024;
  SetLength(PendingPoints, PendingPointCapacity);
end;
{ @end $7C91B4 }

{ @routine $7CA3DC GR_DXReset }
procedure GR_DXReset;
var ErrorCode: Integer;
begin
  PreparePresentationParameters;
  if not Direct3DPresentParameters.Windowed then ApplyMainWindowGeometry;
  if Direct3DDevice = nil then
  begin
    ErrorCode := Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, MainWindowHandle,
      D3DCREATE_MULTITHREADED or D3DCREATE_HARDWARE_VERTEXPROCESSING, Direct3DPresentParameters, Direct3DDevice);
    if ErrorCode <> 0 then
      ErrorCode := Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, MainWindowHandle,
        D3DCREATE_MULTITHREADED or D3DCREATE_SOFTWARE_VERTEXPROCESSING, Direct3DPresentParameters, Direct3DDevice);
    if (ErrorCode <> 0) or (Direct3DDevice = nil) then
    begin
      LogPresentationParameters;
      raise EDirectXRender.CreateCode('GR_DXReset()::GR_Direct3D.CreateDevice(...)', ErrorCode);
    end;
  end
  else
  begin
    ErrorCode := Direct3DDevice.Reset(Direct3DPresentParameters);
    if ErrorCode <> 0 then
    begin
      LogPresentationParameters;
      raise EDirectXRender.CreateCode('GR_DXReset()::GR_D3DDevice.Reset(...)', ErrorCode);
    end;
  end;
  Direct3DDevice.SetVertexShader(nil);
  Direct3DDevice.SetFVF(D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
  ConfigureDefaultRenderState;
  if Direct3DPresentParameters.Windowed then ApplyMainWindowGeometry;
  ShowAndFocusMainWindow;
end;
{ @end $7CA3DC }

{ @routine $7CA554 FreeScreenRenderBuffers }
procedure FreeScreenRenderBuffers;
begin
  if RenderScratchBuffer <> nil then
  begin
    RenderScratchBuffer.Free;
    RenderScratchBuffer := nil;
  end;
  if AuxRenderBuffer <> nil then
  begin
    AuxRenderBuffer.Free;
    AuxRenderBuffer := nil;
  end;
  if ScreenRenderBuffer <> nil then
  begin
    ScreenRenderBuffer.Free;
    ScreenRenderBuffer := nil;
  end;
  PresentationDepth := 0;
end;
{ @end $7CA554 }

{ @routine $7CA5AC ApplyGammaRamp }
procedure ApplyGammaRamp(Brightness, Contrast: Single);
var
  Index, Value: Integer;
  LowInput, LowOutput, HighInput, HighOutput: Single;
  LowIndex, HighIndex: Integer;
  Level, Step: Single;
  Ramp: TD3DGammaRamp;
begin
  if Direct3DDevice = nil then Exit;
  if Brightness >= 0 then
  begin
    LowInput := 0;
    LowOutput := Brightness * 0.5;
    HighInput := 1 - Brightness * 0.5;
    HighOutput := 1;
  end
  else
  begin
    LowInput := -Brightness * 0.5;
    LowOutput := 0;
    HighInput := 1;
    HighOutput := 1 - -Brightness * 0.5;
  end;
  Step := (HighOutput - LowOutput) / (HighInput - LowInput);
  Level := (0.5 - LowInput) * Step + LowOutput;
  LowInput := LowInput + 0.4 * Contrast * Level;
  HighInput := HighInput - (1 - Level) * (0.4 * Contrast);
  LowIndex := Round(LowInput * 255);
  HighIndex := Round(HighInput * 255);
  Value := Round(Max(0, LowOutput) * 65535);
  for Index := 0 to LowIndex - 1 do
  begin
    Ramp.Red[Index] := Value;
    Ramp.Green[Index] := Value;
    Ramp.Blue[Index] := Value;
  end;
  Level := LowOutput;
  Step := (HighOutput - LowOutput) / (HighIndex - LowIndex);
  for Index := LowIndex to HighIndex - 1 do
  begin
    if (Index >= 0) and (Index <= 255) then
    begin
      Value := Round(Max(0, Level) * 65535);
      if Value < 0 then Value := 0
      else if Value > 65535 then Value := 65535;
      Ramp.Red[Index] := Value;
      Ramp.Green[Index] := Value;
      Ramp.Blue[Index] := Value;
    end;
    Level := Level + Step;
  end;
  Value := Round(Min(1.0, HighOutput) * 65535);
  for Index := HighIndex to 255 do
  begin
    Ramp.Red[Index] := Value;
    Ramp.Green[Index] := Value;
    Ramp.Blue[Index] := Value;
  end;
  Direct3DDevice.SetGammaRamp(0, 0, Ramp);
end;
{ @end $7CA5AC }

{ @routine $7CA854 GR_WinMessage }
function GR_WinMessage(Callback: TWindowMessageCallbackGR): Integer;
var
  ContinueLoop, Stage: Integer;
  Msg: TMsg;
  EventTrack: TTrackMouseEvent;
begin
  Stage := 0;
  try
    if SoundManager <> nil then SoundManager.UpdateFades;
    Stage := 1;
    ContinueLoop := 1;
    while True do
    begin
      if ExitScreenLoop then
      begin
        Result := 0;
        Exit;
      end;
      Stage := 2;
      if (timeGetTime - LastWindowMessageTick > 5000) and not MessageIdle then
      begin
        MessageIdle := True;
        if Assigned(OnMessageIdle) then OnMessageIdle;
      end;
      Stage := 3;
      if LastMouseMessageTick <> 0 then
        if (timeGetTime - LastMouseMessageTick > 100) and RuntimeActive then
        begin
          LastMouseMessageTick := timeGetTime;
          PostMouseMoveMessage;
        end;
      Stage := 4;
      while Boolean(PeekMessageW(Msg, 0, 0, 0, PM_REMOVE)) = True do
      begin
        Stage := 5;
        if MessageIdle and Assigned(OnMessageResume) then OnMessageResume;
        MessageIdle := False;
        LastWindowMessageTick := timeGetTime;
        Stage := 6;
        TranslateMessage(Msg);
        Stage := 7;
        if Msg.message <> DebugCommandMessage then
          if Msg.message = WM_QUIT then ContinueLoop := 0;
        Stage := 8;
        if Msg.message = WM_MOUSEMOVE then
        begin
          FillChar(EventTrack, SizeOf(EventTrack), 0);
          EventTrack.cbSize := SizeOf(EventTrack);
          EventTrack.dwFlags := TME_LEAVE;
          EventTrack.hwndTrack := MainWindowHandle;
          TrackMouseEvent(EventTrack);
          LastMouseMessageTick := 0;
        end;
        Stage := 9;
        DispatchMessageW(Msg);
        Stage := 10;
        if (Msg.hwnd = MainWindowHandle) and Assigned(Callback) and Application.Active then
          Callback(Msg.message, Msg.wParam, Msg.lParam);
      end;
      Stage := 11;
      if (ContinueLoop = 0) or RuntimeActive then Break;
      SysUtils.Sleep(1);
    end;
    Result := ContinueLoop;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure GR_WinMessage, label = ' + SysUtils.IntToStr(Stage));
    end;
  end;
end;
{ @end $7CA854 }

{ @routine $7CAB90 MainWindowProc }
function MainWindowProc(Window, Message, WParam: Cardinal; LParam: Integer): Integer; stdcall;
var Origin: TPoint; Bounds: TRect;
begin
  if Message = WM_ACTIVATEAPP then
  begin
    if WParam <> 0 then
    begin
      if Direct3DDevice <> nil then
        if Direct3DDevice.TestCooperativeLevel = D3DERR_DEVICENOTRESET then GR_DXReset;
      if not Direct3DPresentParameters.Windowed then
      begin
        Origin := Classes.Point(GameScreenRect.Left, GameScreenRect.Top);
        ClientToScreen(MainWindowHandle, Origin);
        Bounds := Classes.Rect(Origin.X + GameScreenRect.Left, Origin.Y + GameScreenRect.Top,
          Origin.X + GameScreenRect.Right, Origin.Y + GameScreenRect.Bottom);
        ClipCursor(@Bounds);
      end;
      Application.OnActivate(nil);
    end
    else
    begin
      if Direct3DDevice <> nil then Direct3DDevice.TestCooperativeLevel;
      if not Direct3DPresentParameters.Windowed then ClipCursor(nil);
      Application.OnDeactivate(nil);
    end;
    if WParam <> 0 then
    begin
      if CurrentScreenId = screenPlanetNO then
        TMessageLoopGI(RegisteredScreens[CurrentScreenId]).UpdateActionCursor(False)
      else if (CurrentScreenId = screenShip) or (CurrentScreenId = screenStarMap) then
        TMessageLoopGI(RegisteredScreens[CurrentScreenId]).UpdateActionCursor(True);
      if (TMessageLoopGI(RegisteredScreens[screenShip]) <> nil) and
         (TMessageLoopGI(RegisteredScreens[screenShip]).GetActionParentLoop <> nil) and
         (TMessageLoopGI(RegisteredScreens[screenShip]).GetActionParentLoop = TMessageLoopGI(RegisteredScreens[CurrentScreenId])) then
        TMessageLoopGI(RegisteredScreens[screenShip]).UpdateActionCursor(True);
    end;
  end
  else if Message = WM_DESTROY then
  begin
    if ExitScreenLoop then PostQuitMessage(0);
  end
  else if Message = WM_ERASEBKGND then
  begin
    Result := 1;
    Exit;
  end
  else if Message = WM_PAINT then
  begin
    if Direct3DPresentParameters.Windowed then PresentScreenBuffer;
  end
  else if Message = WM_MOUSEMOVE then begin end
  else if Message = WM_LBUTTONDOWN then begin end
  else if Message = WM_LBUTTONUP then begin end
  else if Message = WM_RBUTTONDOWN then begin end
  else if Message = WM_RBUTTONUP then begin end
  else if (Message = WM_SYSKEYDOWN) and (WParam in [VK_MENU, VK_LEFT..VK_DOWN]) then
  begin
    Result := 1;
    Exit;
  end
  else if (Message = WM_SYSKEYUP) and (WParam in [VK_MENU, VK_LEFT..VK_DOWN]) then
  begin
    Result := 1;
    Exit;
  end
  else if Message = WM_KEYDOWN then
  begin
    if (WParam = Ord('R')) and IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and
      IsVirtualKeyDown(VK_MENU) and (CurrentScreenId <> screenNone) then begin end;
  end
  else if Message = WM_CLOSE then ExitScreenLoop := True
  else if Message = WM_CANCELMODE then RuntimeActive := False
  else if Message = WM_SETCURSOR then
  begin
    Result := 1;
    Exit;
  end
  else if Message = WM_TIMER then
  begin
    CheckRuntimeWatchdog;
    Result := 1;
    Exit;
  end;
  Result := DefWindowProcW(Window, Message, WParam, LParam);
end;
{ @end $7CAB90 }

{ @routine $7CAE98 BeginFramePresentation }
function BeginFramePresentation: Boolean;
begin
  Inc(PresentationDepth);
  Result := True;
end;
{ @end $7CAE98 }

{ @routine $7CAEA4 EndFramePresentation }
procedure EndFramePresentation;
var Tick: Cardinal;
begin
  if PresentationDepth <= 0 then Exit;
  Dec(PresentationDepth);
  if PresentationDepth = 0 then
  begin
    if PresentWithoutLimit then PresentScreenBuffer
    else
    begin
      Tick := timeGetTime;
      if 1000 div PresentationFrameRate < Tick - LastPresentationTick then
      begin
        LastPresentationTick := Tick;
        PresentScreenBuffer;
      end;
    end;
  end;
end;
{ @end $7CAEA4 }

{ @routine $7CAEF8 PresentScreenBuffer }
procedure PresentScreenBuffer;
begin
  if HardwareRenderingEnabled then
  begin
    Direct3DDevice.EndScene;
    Direct3DDevice.Present(nil, nil, 0, nil);
    Direct3DDevice.BeginScene;
  end
  else if OffscreenTexture = nil then
  begin
    Direct3DDevice.BeginScene;
    if not AlternateViewportEnabled then
      DrawTexture(ScreenRenderBuffer.GetTexture, 0, 0, 255, RgbWhite, nil, False, False)
    else if ScaleViewportToWindow then
      DrawTextureSized(ScreenRenderBuffer.GetTexture, 0, 0, PresentationWidth, PresentationHeight, 255, RgbWhite, nil, False, False)
    else
      DrawTexture(ScreenRenderBuffer.GetTexture, ViewportOffset.X, ViewportOffset.Y, 255, RgbWhite, nil, False, False);
    Direct3DDevice.EndScene;
    Direct3DDevice.Present(nil, nil, 0, nil);
  end;
end;
{ @end $7CAEF8 }

{ @routine $7CB05C DrawOffscreenTexture }
procedure DrawOffscreenTexture;
var
  X, Y: Integer;
  Width, Height, ViewWidth, ViewHeight: Cardinal;
  Desc: TD3DSurfaceDesc;
begin
  if OffscreenTexture <> nil then
  begin
    if not OffscreenFrameUpdated then
      if timeGetTime - OffscreenLastPresentationTick < 100 then Exit;
    OffscreenLastPresentationTick := timeGetTime;
    OffscreenTexture.GetLevelDesc(0, Desc);
    if AlternateViewportEnabled then
    begin
      ViewWidth := PresentationWidth;
      ViewHeight := PresentationHeight;
    end
    else
    begin
      ViewWidth := GameScreenWidth;
      ViewHeight := GameScreenHeight;
    end;
    Width := ViewWidth;
    Height := Round((Desc.Height / Desc.Width) * ViewWidth);
    if ((Height > ViewHeight) and not OffscreenFillViewport) or
       ((Height < ViewHeight) and OffscreenFillViewport) then
    begin
      Width := Round((Desc.Width / Desc.Height) * ViewHeight);
      Height := ViewHeight;
    end;
    X := Integer(ViewWidth - Width) div 2;
    Y := Integer(ViewHeight - Height) div 2;
    Direct3DDevice.Clear(0, nil, D3DCLEAR_TARGET, 0, 1, 0);
    if HardwareRenderingEnabled then
      DrawTextureSized(OffscreenTexture, X, Y, Width, Height, 255, RgbWhite, @GameScreenRect, False, False)
    else
    begin
      Direct3DDevice.BeginScene;
      DrawTextureSized(OffscreenTexture, X, Y, Width, Height, 255, RgbWhite, @GameScreenRect, False, False);
      Direct3DDevice.EndScene;
      Direct3DDevice.Present(nil, nil, 0, nil);
    end;
  end;
end;
{ @end $7CB05C }

{ @routine $7CB218 CaptureScreenBackground }
procedure CaptureScreenBackground(ApplyEffects: Boolean; UnusedOption: Byte);
begin
  AuxRenderBuffer.LoadFromScreen(UnusedOption);
  if not ApplyEffects then Exit;
  if BackgroundShade then AuxRenderBuffer.AdjustBrightness(-50);
  if BackgroundGrayscale then AuxRenderBuffer.ConvertToGrayscale;
end;
{ @end $7CB218 }

{ @routine $7CB258 CaptureSavePreview }
procedure CaptureSavePreview;
begin
  FreeSavePreviewBuffers;
  SavePreviewGraph := TGraphBufGR.Create(False);
  SavePreviewGraph.LoadFromScreen(0);
  if HardwareRenderingEnabled then
  begin
    SavePreviewGraph.RescaleWithAspect(300, 225, True, 1, 1, 5);
    SavePreviewGraph.ConvertBgraToRgb24;
  end
  else
  begin
    SavePreviewGraph.Convert565ToRgb;
    SavePreviewGraph.RescaleWithAspect(300, 225, True, 1, 1, 5);
  end;
  SecondarySavePreviewGraph := TGraphBufGR.Create(False);
  SecondarySavePreviewGraph.AllocateNativePitch(300, 225, 900);
end;
{ @end $7CB258 }

{ @routine $7CB304 FreeSavePreviewBuffers }
procedure FreeSavePreviewBuffers;
begin
  if SavePreviewGraph <> nil then
  begin
    SavePreviewGraph.Free;
    SavePreviewGraph := nil;
  end;
  if SecondarySavePreviewGraph <> nil then
  begin
    SecondarySavePreviewGraph.Free;
    SecondarySavePreviewGraph := nil;
  end;
end;
{ @end $7CB304 }

{ @routine $7CB33C CopyBgraToRgb24 }
procedure CopyBgraToRgb24(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer);
var X, Y: Integer;
begin
  Y := 0;
  while Y < Height do
  begin
    X := 0;
    while X < Width do
    begin
      PColorRGB(AddPointerOffset(Dest, X * SizeOf(TColorRGB))).R :=
        PByte(AddPointerOffset(Source, X * SizeOf(TColorBGRA) + 2))^;
      PByte(AddPointerOffset(Dest, X * SizeOf(TColorRGB) + 1))^ :=
        PByte(AddPointerOffset(Source, X * SizeOf(TColorBGRA) + 1))^;
      PByte(AddPointerOffset(Dest, X * SizeOf(TColorRGB) + 2))^ :=
        PColorBGRA(AddPointerOffset(Source, X * SizeOf(TColorBGRA))).B;
      Inc(X);
    end;
    Dest := AddPointerOffset(Dest, DestPitch);
    Source := AddPointerOffset(Source, SourcePitch);
    Inc(Y);
  end;
end;
{ @end $7CB33C }

{ @routine $7CB414 CaptureRecordingFrame }
procedure CaptureRecordingFrame;
begin
  if timeGetTime - LastRecordingFrameTick >= Cardinal(RecordingFrameInterval) then
  begin
    Ex_OKGR_Copy_XY_XY_WORD(RecordingFrameBuffers[RecordingFrameCount], GameScreenWidth * 2,
      0, 0, ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      0, 0, GameScreenWidth, GameScreenHeight);
    Inc(RecordingFrameCount);
    if RecordingFrameCount >= RecordingFrameBuffers.Count then FlushRecordingFrames;
    LastRecordingFrameTick := timeGetTime;
  end;
end;
{ @end $7CB414 }

{ @routine $7CB494 FlushRecordingFrames }
procedure FlushRecordingFrames;
var
  SearchHandle: THandle;
  FirstFrameNumber, Index: Integer;
  Directory: AnsiString;
  Frame: TGraphBufGR;
  FileName: AnsiString;
  FindData: TWin32FindDataA;
begin
  if RecordingFrameCount < 1 then Exit;
  Directory := GetCurrentDir;
  SetCurrentDir('Film');
  FirstFrameNumber := -1;
  SearchHandle := Windows.FindFirstFile('*.*', FindData);
  // Native code scans without testing for INVALID_HANDLE_VALUE.
  while True do
  begin
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> FILE_ATTRIBUTE_DIRECTORY then
      FirstFrameNumber := Max(FirstFrameNumber, ExtractDigitsToIntW(WideString(AnsiString(FindData.cFileName))));
    if not Boolean(Windows.FindNextFile(SearchHandle, FindData)) then Break;
  end;
  Windows.FindClose(SearchHandle);
  SetCurrentDir(Directory);
  Inc(FirstFrameNumber);
  Frame := TGraphBufGR.Create(False);
  Frame.AllocateNativePitch(ScreenRenderBuffer.Width, ScreenRenderBuffer.Height, ScreenRenderBuffer.Width * 3);
  for Index := 0 to RecordingFrameCount - 1 do
  begin
    Ex_OKGF_Convert565toBGR(RecordingFrameBuffers[Index], GameScreenWidth * 2,
      Frame.GetPixels, Frame.PitchBytes, Frame.Width, Frame.Height);
    FileName := AnsiString('Film\' + IntToFixedWidthWideString(FirstFrameNumber + Index, 6) + '.bmp');
    WriteBmpFile(PAnsiChar(FileName), Frame.GetPixels, Frame.PitchBytes,
      24, $FF, $FF00, $FF0000, 0, Frame.Width, Frame.Height);
  end;
  Frame.Free;
  RecordingFrameCount := 0;
end;
{ @end $7CB494 }

{ @routine $7CB6FC DrawTransparentBuffer16 }
procedure DrawTransparentBuffer16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Clip: TRect; HalfAlpha: Boolean);
var InclusiveClip: TRect;
begin
  InclusiveClip.Left := Clip.Left; InclusiveClip.Top := Clip.Top;
  InclusiveClip.Right := Clip.Right - 1; InclusiveClip.Bottom := Clip.Bottom - 1;
  if HalfAlpha then Ex_OKGR_TransBuf_HADrawClip_16(Dest, Pitch, X, Y, Source, InclusiveClip)
  else Ex_OKGR_TransBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, InclusiveClip);
end;
{ @end $7CB6FC }

{ @routine $7CB758 CopyPalettedBuffer16Clipped }
procedure CopyPalettedBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source, Palette: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect);
var SourceX, SourceY: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Integer(Width) - 1 < Clip.Left) or (Y + Integer(Height) - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, X + Integer(Width) - 1 - (Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Y + Integer(Height) - 1 - (Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X; Dec(Width, SourceX); X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y; Dec(Height, SourceY); Y := Clip.Top;
  end;
  Ex_OKGR_PalCopy_XY_XY_WORD(Dest, DestPitch, X, Y, Source, SourcePitch, SourceX, SourceY, Palette, Width, Height);
end;
{ @end $7CB758 }

{ @routine $7CB834 CopyGraphBuffer16Clipped }
procedure CopyGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; HalfAlpha, UnusedOption: Boolean);
var SourceX, SourceY, Width, Height: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Integer(Source.Width) + X - 1 < Clip.Left) or (Integer(Source.Height) + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, Cardinal(X) + Width - 1 - Cardinal(Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Cardinal(Y) + Height - 1 - Cardinal(Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X;
    Dec(Width, SourceX);
    X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y;
    Dec(Height, SourceY);
    Y := Clip.Top;
  end;
  if HalfAlpha then Ex_OKGR_HACopy_XY_XY_16(Dest, DestPitch, X, Y, Source.GetPixels, Source.PitchBytes, SourceX, SourceY, Width, Height)
  else Ex_OKGR_Copy_XY_XY_WORD(Dest, DestPitch, X, Y, Source.GetPixels, Source.PitchBytes, SourceX, SourceY, Width, Height);
end;
{ @end $7CB834 }

{ @routine $7CB960 CopyBuffer16Clipped }
procedure CopyBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect; UnusedOption: Boolean);
var SourceX, SourceY: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Integer(Width) - 1 < Clip.Left) or (Y + Integer(Height) - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, X + Integer(Width) - 1 - (Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Y + Integer(Height) - 1 - (Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X; Dec(Width, SourceX); X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y; Dec(Height, SourceY); Y := Clip.Top;
  end;
  Ex_OKGR_Copy_XY_XY_WORD(Dest, DestPitch, X, Y, Source, SourcePitch, SourceX, SourceY, Width, Height);
end;
{ @end $7CB960 }

{ @routine $7CBA34 CopyTransparentGraphBuffer16Clipped }
procedure CopyTransparentGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; TransparentColor: Word);
var SourceX, SourceY, Width, Height: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Integer(Source.Width) + X - 1 < Clip.Left) or (Integer(Source.Height) + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, Cardinal(X) + Width - 1 - Cardinal(Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Cardinal(Y) + Height - 1 - Cardinal(Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X;
    Dec(Width, SourceX);
    X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y;
    Dec(Height, SourceY);
    Y := Clip.Top;
  end;
  Ex_OKGR_CopyTrans_XY_XY_WORD(Dest, DestPitch, X, Y, Source.GetPixels, Source.PitchBytes, SourceX, SourceY, Width, Height, TransparentColor);
end;
{ @end $7CBA34 }

{ @routine $7CBB30 DrawAlphaGraphBuffer16Clipped }
procedure DrawAlphaGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect);
var SourceX, SourceY, Width, Height: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Integer(Source.Width) + X - 1 < Clip.Left) or (Integer(Source.Height) + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, Cardinal(X) + Width - 1 - Cardinal(Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Cardinal(Y) + Height - 1 - Cardinal(Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X;
    Dec(Width, SourceX);
    X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y;
    Dec(Height, SourceY);
    Y := Clip.Top;
  end;
  Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest, DestPitch, X, Y, Source.GetPixels, Source.PitchBytes, SourceX, SourceY, Width, Height);
end;
{ @end $7CBB30 }

{ @routine $7CBC28 DrawAlphaBuffer16Clipped }
procedure DrawAlphaBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Cardinal; Clip: TRect);
var SourceX, SourceY: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Integer(Width) - 1 < Clip.Left) or (Y + Integer(Height) - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, X + Integer(Width) - 1 - (Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Y + Integer(Height) - 1 - (Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X; Dec(Width, SourceX); X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y; Dec(Height, SourceY); Y := Clip.Top;
  end;
  Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest, DestPitch, X, Y, Source, SourcePitch, SourceX, SourceY, Width, Height);
end;
{ @end $7CBC28 }

{ @routine $7CBCFC DrawPaletteAlphaBuffer16Clipped }
procedure DrawPaletteAlphaBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect);
var SourceX, SourceY, Width, Height: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (X + Source.Width - 1 < Clip.Left) or (Y + Source.Height - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, X + Integer(Width) - 1 - (Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Y + Integer(Height) - 1 - (Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X;
    Dec(Width, SourceX);
    X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y;
    Dec(Height, SourceY);
    Y := Clip.Top;
  end;
  Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest, DestPitch, X, Y, Source.Pixels, Source.PitchBytes, SourceX, SourceY, Width, Height, Source.Palette);
end;
{ @end $7CBCFC }

{ @routine $7CBDE8 ExpandPaletteToBgra }
procedure ExpandPaletteToBgra(Dest: Pointer; DestPitch: Integer; Width, Height: Cardinal; Source: Pointer; SourcePitch: Integer; Palette: Pointer);
var X, Y: Cardinal; Offset: Cardinal;
begin
  for Y := 0 to Height - 1 do
  begin
    for X := 0 to Width - 1 do
    begin
      Offset := PByte(PAnsiChar(Source) + X)^ shl 2;
      PColorBGRA(PAnsiChar(Dest) + X * SizeOf(TColorBGRA)).B := PByte(@PColorRGBA(PAnsiChar(Palette) + Offset).B)^;
      PByte(@PColorBGRA(PAnsiChar(Dest) + X * SizeOf(TColorBGRA)).G)^ := PByte(@PColorRGBA(PAnsiChar(Palette) + Offset).G)^;
      PByte(@PColorBGRA(PAnsiChar(Dest) + X * SizeOf(TColorBGRA)).R)^ := PColorRGBA(PAnsiChar(Palette) + Offset).R;
      PByte(@PColorBGRA(PAnsiChar(Dest) + X * SizeOf(TColorBGRA)).A)^ := PByte(@PColorRGBA(PAnsiChar(Palette) + Offset).A)^;
    end;
    Source := AddPointerOffset(Source, SourcePitch);
    Dest := AddPointerOffset(Dest, DestPitch);
  end;
end;
{ @end $7CBDE8 }

{ @routine $7CBEB0 BlendPaletteBuffer16Clipped }
procedure BlendPaletteBuffer16Clipped(Dest: Pointer; DestPitch: Cardinal; X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect);
var
  SourcePixels: Pointer;
  Width: Cardinal;
  Palette, MulTable: Pointer;
  ColumnCount, SourceSkip, DestSkip: Integer;
  Height: Cardinal;
  SourceX, SourceY: Cardinal;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
     (X + Source.Width - 1 < Clip.Left) or (Y + Source.Height - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Integer(Width) - 1 >= Clip.Right then Dec(Width, X + Integer(Width) - 1 - (Clip.Right - 1));
  if Y + Integer(Height) - 1 >= Clip.Bottom then Dec(Height, Y + Integer(Height) - 1 - (Clip.Bottom - 1));
  if X < Clip.Left then
  begin
    SourceX := Clip.Left - X;
    Dec(Width, SourceX);
    X := Clip.Left;
  end;
  if Y < Clip.Top then
  begin
    SourceY := Clip.Top - Y;
    Dec(Height, SourceY);
    Y := Clip.Top;
  end;
  SourcePixels := Integer(SourceY) * Source.PitchBytes + PAnsiChar(Source.Pixels) + SourceX;
  Dest := Y * Integer(DestPitch) + PAnsiChar(Dest) + X * 2;
  SourceSkip := Source.PitchBytes - Integer(Width);
  DestSkip := DestPitch - Width * 2;
  MulTable := Ex_OKGF_MulTable256x256;
  Palette := Source.Palette;
  ColumnCount := Width;
  if CurrentPixelFormat.TotalChannelBits = 16 then
  begin
    asm
      push    esi
      push    edi
      push    edx
      push    ebx
      push    ecx
      mov     esi, SourcePixels
      mov     edi, Dest
      mov     ecx, Width
    @@L4C6630:
      xor     edx, edx
      mov     dl, [esi]
      shl     edx, 2
      add     edx, Palette
      mov     edx, [edx]
      mov     ebx, edx
      shr     ebx, 18h
      jz      @@L4C66F0
      shl     ebx, 8
      add     ebx, MulTable
      mov     eax, edx
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 8
      and     eax, 0F800h
      mov     ecx, eax
      mov     eax, edx
      shr     eax, 8
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 3
      and     eax, 7E0h
      or      ecx, eax
      mov     eax, edx
      shr     eax, 10h
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shr     eax, 3
      and     eax, 1Fh
      or      ecx, eax
      mov     eax, edx
      shr     eax, 18h
      mov     ebx, 0FFh
      sub     ebx, eax
      shl     ebx, 8
      add     ebx, MulTable
      xor     edx, edx
      mov     dx, [edi]
      mov     eax, edx
      shr     eax, 8
      and     eax, 0F8h
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 8
      and     eax, 0F800h
      add     ecx, eax
      mov     eax, edx
      shr     eax, 3
      and     eax, 0FCh
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 3
      and     eax, 7E0h
      add     ecx, eax
      mov     eax, edx
      shl     eax, 3
      and     eax, 0F8h
      add     eax, ebx
      mov     al, [eax]
      shr     eax, 3
      and     eax, 1Fh
      add     ecx, eax
      mov     [edi], cx
    @@L4C66F0:
      add     esi, 1
      add     edi, 2
      dec     ColumnCount
      jnz     @@L4C6630
      mov     eax, Width
      mov     ColumnCount, eax
      add     esi, SourceSkip
      add     edi, DestSkip
      dec     Height
      jnz     @@L4C6630
      pop     ecx
      pop     ebx
      pop     edx
      pop     edi
      pop     esi
    end;
  end
  else
  begin
    asm
      push    esi
      push    edi
      push    edx
      push    ebx
      push    ecx
      mov     esi, SourcePixels
      mov     edi, Dest
      mov     ecx, Width
    @@L4C672C:
      xor     edx, edx
      mov     dl, [esi]
      shl     edx, 2
      add     edx, Palette
      mov     edx, [edx]
      mov     ebx, edx
      shr     ebx, 18h
      jz      @@L4C67EC
      shl     ebx, 8
      add     ebx, MulTable
      mov     eax, edx
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 7
      and     eax, 7C00h
      mov     ecx, eax
      mov     eax, edx
      shr     eax, 8
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 2
      and     eax, 3E0h
      or      ecx, eax
      mov     eax, edx
      shr     eax, 10h
      and     eax, 0FFh
      add     eax, ebx
      mov     al, [eax]
      shr     eax, 3
      and     eax, 1Fh
      or      ecx, eax
      mov     eax, edx
      shr     eax, 18h
      mov     ebx, 0FFh
      sub     ebx, eax
      shl     ebx, 8
      add     ebx, MulTable
      xor     edx, edx
      mov     dx, [edi]
      mov     eax, edx
      shr     eax, 7
      and     eax, 0F8h
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 7
      and     eax, 7C00h
      add     ecx, eax
      mov     eax, edx
      shr     eax, 2
      and     eax, 0F8h
      add     eax, ebx
      mov     al, [eax]
      shl     eax, 2
      and     eax, 3E0h
      add     ecx, eax
      mov     eax, edx
      shl     eax, 3
      and     eax, 0F8h
      add     eax, ebx
      mov     al, [eax]
      shr     eax, 3
      and     eax, 1Fh
      add     ecx, eax
      mov     [edi], cx
    @@L4C67EC:
      add     esi, 1
      add     edi, 2
      dec     ColumnCount
      jnz     @@L4C672C
      mov     eax, Width
      mov     ColumnCount, eax
      add     esi, SourceSkip
      add     edi, DestSkip
      dec     Height
      jnz     @@L4C672C
      pop     ecx
      pop     ebx
      pop     edx
      pop     edi
      pop     esi
    end;
  end;
end;
{ @end $7CBEB0 }

{ @routine $7CC1C0 DrawGradientLine16Clipped }
procedure DrawGradientLine16Clipped(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; Clip: TRect);
begin
  if Ex_OKGR_LineColor_Clip(X1, Y1, Color1, X2, Y2, Color2, Clip) <> 0 then
    LineRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      X1, Y1, Color1, X2, Y2, Color2);
end;
{ @end $7CC1C0 }

{ @routine $7CC234 IsVirtualKeyDown }
function IsVirtualKeyDown(Key: Integer): Boolean;
begin
  Result := GetAsyncKeyState(Key) and $8000 = $8000;
end;
{ @end $7CC234 }

{ @routine $7CC250 LookupLocalizedTextByKey }
function LookupLocalizedTextByKey(const Path: WideString): WideString;
begin
  Result := LanguageDataConfig.GetParamByPathOrMarker(Path);
end;
{ @end $7CC250 }

{ @routine $7CC268 LookupLocalizedTextOrEmpty }
function LookupLocalizedTextOrEmpty(const Path: WideString): WideString;
begin
  if LanguageDataConfig.CountParamsByPath(Path) > 0 then
    Result := LanguageDataConfig.GetParamByPathOrMarker(Path)
  else Result := '';
end;
{ @end $7CC268 }

{ @routine $7CC29C GiResourceVariant }
function GiResourceVariant: Integer;
begin
  Result := 2;
end;
{ @end $7CC29C }

{ @routine $7CC2A4 GiResourceSuffix }
function GiResourceSuffix: WideString;
begin
  Result := '2';
end;
{ @end $7CC2A4 }

{ @routine $7CC2C0 GiScalePixels }
function GiScalePixels(Value: Integer): Integer;
begin
  Result := Value;
end;
{ @end $7CC2C0 }

{ @routine $7CC2C4 GiScalePixelsEx }
function GiScalePixelsEx(Value, AlternateValue: Integer): Integer;
begin
  Result := Value;
end;
{ @end $7CC2C4 }

{ @routine $7CC2C8 AppendLogLineThreadSafe }
procedure AppendLogLineThreadSafe(const Text: AnsiString);
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  Append(SessionLog);
  Writeln(SessionLog, Text);
  CloseFile(SessionLog);
  SessionLogLock.Leave;
end;
{ @end $7CC2C8 }

{ @routine $7CC320 AppendLogTextThreadSafe }
procedure AppendLogTextThreadSafe(const Text: AnsiString);
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  Append(SessionLog);
  Write(SessionLog, Text);
  CloseFile(SessionLog);
  SessionLogLock.Leave;
end;
{ @end $7CC320 }

{ @routine $7CC378 AppendDebugLogLine }
procedure AppendDebugLogLine(const Text: AnsiString);
var
  Log: TextFile;
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  AssignFile(Log, '#####add.log');
  if not FileExists('#####add.log') then Rewrite(Log)
  else Append(Log);
  Writeln(Log, Text);
  CloseFile(Log);
  SessionLogLock.Leave;
end;
{ @end $7CC378 }

{ @routine $7CC410 AppendOptionalDebugLogLine }
procedure AppendOptionalDebugLogLine(const Text: AnsiString);
var Log: TextFile;
begin
  if not FileExists('#####add.log') then Exit;
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  AssignFile(Log, '#####add.log');
  Append(Log);
  Writeln(Log, Text);
  CloseFile(Log);
  SessionLogLock.Leave;
end;
{ @end $7CC410 }

{ @routine $7CC4A0 WriteTextFileThreadSafe }
procedure WriteTextFileThreadSafe(FileName, Text: AnsiString);
var F: TextFile;
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  AssignFile(F, FileName);
  Rewrite(F);
  Writeln(F, Text);
  CloseFile(F);
  SessionLogLock.Leave;
end;
{ @end $7CC4A0 }

{ @routine $7CC558 IsInstallFeatureEnabled }
function IsInstallFeatureEnabled(const Path: WideString): Boolean;
begin
  if InstallConfig.CountParamsByPath(Path) < 1 then Result := False
  else Result := ParseEnabledNameGI(InstallConfig.GetParamByPathOrMarker(Path));
end;
{ @end $7CC558 }

{ @routine $7CC5C0 AddCursorUnit }
function AddCursorUnit: TCursorUnit;
var Cursor: TCursorUnit;
begin
  Cursor := TCursorUnit.Create;
  if LastRegisteredCursor <> nil then LastRegisteredCursor.Next := Cursor;
  Cursor.Prev := LastRegisteredCursor;
  Cursor.Next := nil;
  LastRegisteredCursor := Cursor;
  if FirstRegisteredCursor = nil then FirstRegisteredCursor := Cursor;
  Result := Cursor;
end;
{ @end $7CC5C0 }

{ @routine $7CC600 RemoveCursorUnit }
procedure RemoveCursorUnit(Cursor: TCursorUnit);
begin
  if Cursor.Prev <> nil then Cursor.Prev.Next := Cursor.Next;
  if Cursor.Next <> nil then Cursor.Next.Prev := Cursor.Prev;
  if LastRegisteredCursor = Cursor then LastRegisteredCursor := Cursor.Prev;
  if FirstRegisteredCursor = Cursor then FirstRegisteredCursor := Cursor.Next;
  Cursor.Free;
end;
{ @end $7CC600 }

{ @routine $7CC644 FindCursorByName }
function FindCursorByName(const Name: WideString): TCursorUnit;
var Cursor: TCursorUnit;
begin
  Cursor := FirstRegisteredCursor;
  while Cursor <> nil do
  begin
    if Cursor.Name = Name then
    begin
      Result := Cursor;
      Exit;
    end;
    Cursor := Cursor.Next;
  end;
  raise Exception.Create('GR_CursorFind');
end;
{ @end $7CC644 }

{ @routine $7CC6A0 PostMouseMoveMessage }
procedure PostMouseMoveMessage;
var
  Point: TPoint;
begin
  GetCursorPos(Point);
  ScreenToClient(MainWindowHandle, Point);
  PostMessage(MainWindowHandle, WM_MOUSEMOVE, 0, Word(Point.X) or (Word(Point.Y) shl 16));
end;
{ @end $7CC6A0 }

{ @routine $7CC6DC MeasureCpuClockMHz }
function MeasureCpuClockMHz: Double;
var TickLow, TickHigh: Cardinal; ProcessPriority: Cardinal; ThreadPriority: Integer;
begin
  ProcessPriority := GetPriorityClass(GetCurrentProcess);
  ThreadPriority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  try
    SysUtils.Sleep(10);
    asm
      rdtsc
      mov TickLow, eax
      mov TickHigh, edx
    end;
    SysUtils.Sleep(200);
    asm
      rdtsc
      sub eax, TickLow
      sbb edx, TickHigh
      mov TickLow, eax
      mov TickHigh, edx
    end;
    Result := TickLow / 200000;
  except
    Result := 1500;
  end;
  SetThreadPriority(GetCurrentThread, ThreadPriority);
  SetPriorityClass(GetCurrentProcess, ProcessPriority);
end;
{ @end $7CC6DC }

{ @routine $7CC7B8 ReadRegistryText }
function ReadRegistryText(Root: Cardinal; KeyPath, ValueName, DefaultValue: WideString): WideString;
var Key: HKey; ValueType: Cardinal; Data: Pointer; ByteCount: Cardinal;
begin
  if RegOpenKeyExA(Root, PAnsiChar(AnsiString(KeyPath)), 0, KEY_READ, Key) <> ERROR_SUCCESS then
  begin
    Result := DefaultValue;
    Exit;
  end;

  ByteCount := 2048;
  Data := AllocEC(ByteCount);
  if RegQueryValueExA(Key, PAnsiChar(AnsiString(ValueName)), nil, @ValueType, Data, @ByteCount) <> ERROR_SUCCESS then
  begin
    Result := DefaultValue;
    RegCloseKey(Key);
    FreeEC(Data);
    Exit;
  end;

  if ValueType <> REG_SZ then Result := DefaultValue
  else Result := PAnsiChar(Data);
  FreeEC(Data);
  RegCloseKey(Key);
end;
{ @end $7CC7B8 }

{ @routine $7CC8F4 ReadRegistryInteger }
function ReadRegistryInteger(Root: Cardinal; KeyPath, ValueName: WideString; DefaultValue: Integer): Integer;
var Key: HKey; ValueType: Cardinal; Value: Integer; ByteCount: Cardinal;
begin
  if RegOpenKeyExA(Root, PAnsiChar(AnsiString(KeyPath)), 0, KEY_READ, Key) <> ERROR_SUCCESS then
  begin
    Result := DefaultValue;
    Exit;
  end;

  ByteCount := 4;
  if RegQueryValueExA(Key, PAnsiChar(AnsiString(ValueName)), nil, @ValueType, @Value, @ByteCount) <> ERROR_SUCCESS then
  begin
    Result := DefaultValue;
    RegCloseKey(Key);
    Exit;
  end;

  if ValueType <> REG_DWORD then Result := DefaultValue
  else Result := Value;
  RegCloseKey(Key);
end;
{ @end $7CC8F4 }

{ @routine $7CC9E4 RaiseWideMessage }
procedure RaiseWideMessage(const Message: WideString);
begin
  raise Exception.Create(Message);
end;
{ @end $7CC9E4 }

{ @routine $7CCA3C Direct3DErrorText }
function Direct3DErrorText(Code: Integer): AnsiString;
begin
  Result := '';
  case Code of
    0: Result := 'D3D_OK';
    -2005530600: Result := 'D3DERR_WRONGTEXTUREFORMAT';
    -2005530599: Result := 'D3DERR_UNSUPPORTEDCOLOROPERATION';
    -2005530598: Result := 'D3DERR_UNSUPPORTEDCOLORARG';
    -2005530597: Result := 'D3DERR_UNSUPPORTEDALPHAOPERATION';
    -2005530596: Result := 'D3DERR_UNSUPPORTEDALPHAARG';
    -2005530595: Result := 'D3DERR_TOOMANYOPERATIONS';
    -2005530594: Result := 'D3DERR_CONFLICTINGTEXTUREFILTER';
    -2005530593: Result := 'D3DERR_UNSUPPORTEDFACTORVALUE';
    -2005530591: Result := 'D3DERR_CONFLICTINGRENDERSTATE';
    -2005530590: Result := 'D3DERR_UNSUPPORTEDTEXTUREFILTER';
    -2005530586: Result := 'D3DERR_CONFLICTINGTEXTUREPALETTE';
    -2005530585: Result := 'D3DERR_DRIVERINTERNALERROR';
    -2005530522: Result := 'D3DERR_NOTFOUND';
    -2005530521: Result := 'D3DERR_MOREDATA';
    -2005530520: Result := 'D3DERR_DEVICELOST';
    -2005530519: Result := 'D3DERR_DEVICENOTRESET';
    -2005530518: Result := 'D3DERR_NOTAVAILABLE';
    -2005532292: Result := 'D3DERR_OUTOFVIDEOMEMORY';
    -2005530517: Result := 'D3DERR_INVALIDDEVICE';
    -2005530516: Result := 'D3DERR_INVALIDCALL';
    -2005530515: Result := 'D3DERR_DRIVERINVALIDCALL';
  else
    Result := SysUtils.IntToStr(Code);
    Exit;
  end;
  Result := Result + ' (' + SysUtils.IntToStr(Code) + ')';
end;
{ @end $7CCA3C }

{ @routine $7CD008 FormatUnixDateTime }
function FormatUnixDateTime(Value: Cardinal): WideString;
var
  DateValue: TDateTime;
begin
  DateValue := UnixToDateTime(Value);
  Result := DateTimeToStr(DateValue);
end;
{ @end $7CD008 }

{ @routine $7CD074 LoadInformationColorTags }
procedure LoadInformationColorTags;
var Block: TBlockParEC;
begin
  InfoNameColorTag := DefaultInfoNameColorTag;
  InfoHullSeriesColorTag := DefaultInfoHullSeriesColorTag;
  if GameDataConfig.CountBlocks('StyleColor') <= 0 then Exit;
  Block := GameDataConfig.GetBlock('StyleColor');
  if Block.CountParamsByPath('InfoNameColor') > 0 then
    InfoNameColorTag := '<color=' + Block.GetParamByPath('InfoNameColor') + '>';
  if Block.CountParamsByPath('InfoHullSeriesColor') > 0 then
    InfoHullSeriesColorTag := '<color=' + Block.GetParamByPath('InfoHullSeriesColor') + '>';
end;
{ @end $7CD074 }

{ @routine $7CD24C GetStyleColorGI }
function GetStyleColorGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): Cardinal;
var Style: TBlockParEC; ColorText: WideString;
begin
  if GameDataConfig.CountBlocks('StyleColor') > 0 then
  begin
    Style := GameDataConfig.GetBlock('StyleColor');
    if Style.CountParamsByPath(StyleName) > 0 then
    begin
      ColorText := Style.GetParamByPath(StyleName);
      Result := CurrentPixelFormat.PackRgb(
        ExtractDigitsToIntW(ExtractDelimitedPartW(ColorText, 0, ',')),
        ExtractDigitsToIntW(ExtractDelimitedPartW(ColorText, 1, ',')),
        ExtractDigitsToIntW(ExtractDelimitedPartW(ColorText, 2, ',')));
      Exit;
    end;
  end;
  Result := CurrentPixelFormat.PackRgb(DefaultRed, DefaultGreen, DefaultBlue);
end;
{ @end $7CD24C }

{ @routine $7CD38C GetStyleColorTagGI }
function GetStyleColorTagGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): WideString;
var Style: TBlockParEC;
begin
  if GameDataConfig.CountBlocks('StyleColor') > 0 then
  begin
    Style := GameDataConfig.GetBlock('StyleColor');
    if Style.CountParamsByPath(StyleName) > 0 then
    begin
      Result := Style.GetParamByPath(StyleName);
      Result := '<color=' + Style.GetParamByPath(StyleName) + '>';
      Exit;
    end;
  end;
  Result := '<color=' + IntToWideString(DefaultRed) + ',' + IntToWideString(DefaultGreen) + ',' + IntToWideString(DefaultBlue) + '>';
end;
{ @end $7CD38C }

{ @routine $7CD4E4 GetGameUserDirectory }
function GetGameUserDirectory: WideString;
var PathBuffer: PAnsiChar; ItemIdList: PItemIDList; DocumentsPath: WideString;
begin
  if CachedGameUserDirectory <> '' then Result := CachedGameUserDirectory
  else if OverrideGameUserDirectory <> '' then
  begin
    CreateDir(OverrideGameUserDirectory);
    Result := OverrideGameUserDirectory + '\';
  end
  else
  begin
    SHGetSpecialFolderLocation(0, CSIDL_PERSONAL, ItemIdList);
    PathBuffer := StrAlloc(MAX_PATH);
    SHGetPathFromIDListA(ItemIdList, PathBuffer);
    CoTaskMemFree(ItemIdList);
    DocumentsPath := StrPas(PathBuffer) + '\';
    StrDispose(PathBuffer);
    CreateDir(DocumentsPath + 'SpaceRangersHD');
    CachedGameUserDirectory := DocumentsPath + 'SpaceRangersHD\';
    Result := CachedGameUserDirectory;
  end;
end;
{ @end $7CD4E4 }

{ @routine $7CD688 ComputeMachineFingerprintCRC }
function ComputeMachineFingerprintCRC: Cardinal;
var Buffer: TBufEC;
  ProcessorName: AnsiString;
  Serial, Flags: Cardinal;
begin
  GetVolumeInformationA('c:\', nil, 0, @Serial, Flags, Flags, nil, 0);
  ProcessorName := AnsiString(ReadRegistryText(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString', ''));
  Buffer := TBufEC.Create;
  Buffer.AddInt32(Serial);
  if Length(ProcessorName) > 0 then Buffer.AddBytes(Pointer(ProcessorName), Length(ProcessorName));
  Result := Buffer.ComputeCrc32;
  Buffer.Clear;
  Buffer.Free;
end;
{ @end $7CD688 }

{ @routine $7CD804 GetClipboardWideText }
function GetClipboardWideText: WideString;
var Handle: HGLOBAL;
begin
  Clipboard.Open;
  Handle := GetClipboardData(CF_UNICODETEXT);
  try
    if Handle <> 0 then Result := PWideChar(GlobalLock(Handle)) else Result := '';
  finally
    if Handle <> 0 then GlobalUnlock(Handle);
    Clipboard.Close;
  end;
end;
{ @end $7CD804 }

{ @routine $7CD880 SetClipboardWideText }
procedure SetClipboardWideText(Text: WideString);
var
  Size: Integer;
  Handle: HGLOBAL;
begin
  Size := Length(Text) * 2 + 2;
  Handle := GlobalAlloc(GMEM_MOVEABLE, Size);
  CopyMemory(GlobalLock(Handle), PWideChar(Text), Size);
  GlobalUnlock(Handle);
  OpenClipboard(0);
  EmptyClipboard;
  SetClipboardData(CF_UNICODETEXT, Handle);
  CloseClipboard;
end;
{ @end $7CD880 }

{ @routine $7CDA80 LogPresentationParameters }
procedure LogPresentationParameters;
var CurrentValue, PreviousValue: Cardinal; Text: WideString;
  // @nested $7CD914 LogPresentationField
  procedure LogPresentationField(Name: WideString); // @addr $7CD914 @calls "0x007CDAC9,0x007CDAE0,0x007CDAF7,0x007CDB0E,0x007CDB25,0x007CDB3C,0x007CDB53,0x007CDB6A,0x007CDB99,0x007CDBC8,0x007CDBDF,0x007CDBF6,0x007CDC0D,0x007CDC24"
  begin
    if CurrentValue = PreviousValue then
      Text := Name + ' = ' + SysUtils.IntToStr(Int64(CurrentValue))
    else Text := Name + ' = ' + SysUtils.IntToStr(Int64(CurrentValue)) + ', previous value = ' + SysUtils.IntToStr(Int64(PreviousValue));
    AppendLogLineThreadSafe(Text);
  end;
begin
  AppendLogLineThreadSafe('');
  AppendLogLineThreadSafe('D3DPresent structure:');
  CurrentValue := Direct3DPresentParameters.BackBufferWidth;
  PreviousValue := PreviousPresentParameters.BackBufferWidth;
  LogPresentationField('BackBufferWidth');
  CurrentValue := Direct3DPresentParameters.BackBufferHeight;
  PreviousValue := PreviousPresentParameters.BackBufferHeight;
  LogPresentationField('BackBufferHeight');
  CurrentValue := Direct3DPresentParameters.BackBufferCount;
  PreviousValue := PreviousPresentParameters.BackBufferCount;
  LogPresentationField('BackBufferCount');
  CurrentValue := Direct3DPresentParameters.BackBufferFormat;
  PreviousValue := PreviousPresentParameters.BackBufferFormat;
  LogPresentationField('BackBufferFormat');
  CurrentValue := Direct3DPresentParameters.MultiSampleQuality;
  PreviousValue := PreviousPresentParameters.MultiSampleQuality;
  LogPresentationField('MultiSampleQuality');
  CurrentValue := Direct3DPresentParameters.MultiSampleType;
  PreviousValue := PreviousPresentParameters.MultiSampleType;
  LogPresentationField('MultiSampleType');
  CurrentValue := Direct3DPresentParameters.SwapEffect;
  PreviousValue := PreviousPresentParameters.SwapEffect;
  LogPresentationField('SwapEffect');
  CurrentValue := Direct3DPresentParameters.DeviceWindow;
  PreviousValue := PreviousPresentParameters.DeviceWindow;
  LogPresentationField('hDeviceWindow');
  CurrentValue := Ord(Boolean(Direct3DPresentParameters.Windowed) = True);
  PreviousValue := Ord(Boolean(PreviousPresentParameters.Windowed) = True);
  LogPresentationField('Windowed');
  CurrentValue := Ord(Boolean(Direct3DPresentParameters.EnableAutoDepthStencil) = True);
  PreviousValue := Ord(Boolean(PreviousPresentParameters.EnableAutoDepthStencil) = True);
  LogPresentationField('EnableAutoDepthStencil');
  CurrentValue := Direct3DPresentParameters.AutoDepthStencilFormat;
  PreviousValue := PreviousPresentParameters.AutoDepthStencilFormat;
  LogPresentationField('AutoDepthStencilFormat');
  CurrentValue := Direct3DPresentParameters.Flags;
  PreviousValue := PreviousPresentParameters.Flags;
  LogPresentationField('Flags');
  CurrentValue := Direct3DPresentParameters.FullScreenRefreshRateInHz;
  PreviousValue := PreviousPresentParameters.FullScreenRefreshRateInHz;
  LogPresentationField('FullScreen_RefreshRateInHz');
  CurrentValue := Direct3DPresentParameters.PresentationInterval;
  PreviousValue := PreviousPresentParameters.PresentationInterval;
  LogPresentationField('PresentationInterval');
  AppendLogLineThreadSafe('');
end;
{ @end $7CDA80 }

end.
