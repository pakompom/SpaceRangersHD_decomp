unit GR_Main;
// Unit bracket (inferred): .text 0x004B8CD8..0x004C87DA; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008757E0..0x008757E7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GR_Music, DirectSound, EC_Thread, GR_Sound, EC_Data, EC_OKGF, EC_Buf, GR_GraphBufPal, Direct3D9, EC_Cache, EC_BlockPar, EC_Str, GR_GraphBuf, SyncObjs, Classes, Types;

// Unit attribution of the cursor registry is inferred from its VMT and
// implementation region; it is not an explicit class RTTI unit name.
type
  TWindowMessageCallbackGR = procedure(Message, WParam: Cardinal; LParam: Integer) of object;
  TRuntimeCallbackGR = procedure;
  TDebugKeyCallbackGR = procedure(Key: Word);
  TTriangleRasterizer16 = procedure(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Clip: PRect); cdecl;
  TLineRasterizer16 = procedure(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal); cdecl;
  TBlendPixel16 = procedure(Pixel: Pointer; Color: Word; Alpha: Byte); cdecl;

  TMemoryStatusEx = packed record // @size 64
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

  // VMT and methods share the native GR_Main contribution.
  PCCSnapshot = ^TCCSnapshot;
  // Links hide the live snapshot among randomized decoys. Unidentified payload
  // slots remain explicit alongside the recovered status/checksum channels.
  TCCSnapshot = record // @size $30
    Prev: PCCSnapshot; // @offset $00
    Next: PCCSnapshot; // @offset $04
    ResourceChecksumFailed: Boolean; // @offset $08
    TamperDetected: Boolean; // @offset $09
    Flag0A: Boolean; // @offset $0A
    ProtectedStateXorSeed: Integer; // @offset $0C Nonzero while galaxy state is XOR-obfuscated ($84564C/$8456A8).
    Value10: Integer; // @offset $10
    IntegrityStatus: Integer; // @offset $14
    IntegrityError: Integer; // @offset $18
    IntegrityChecksum: Cardinal; // @offset $1C
    IntegrityChecksum1: Cardinal; // @offset $20
    IntegrityChecksum2: Cardinal; // @offset $24
    EncodedCheatPoints: Integer; // @offset $28
    EditableStateApplied: Boolean; // @offset $2C Set by ApplyEditableState ($83F3B8); saved and checked for score eligibility and cheat warnings.
  end;
  TCCInterface = class(TObject) // @size 0x10
  public
    Buffer: TBufEC; // @offset $04
    SnapshotHead: PCCSnapshot; // @offset $08
    Lock: TCriticalSection; // @offset 0x0C
    constructor Create; // @addr $4B9C44 @ida "TCCInterface *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $4B9CC0 @ida "void __usercall $name(TCCInterface *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Reset; // @addr $4B9D10
    function CreateEmptySnapshot: PCCSnapshot; // @addr $4B9EAC
    function GetSnapshot: PCCSnapshot; // @addr $4B9D58
    function CreateDecoy: PCCSnapshot; // @addr $4B9D9C
    function CopySnapshot(Source: PCCSnapshot): PCCSnapshot; // @addr $4B9F28
    procedure CommitSnapshot(Snapshot: PCCSnapshot); // @addr $4B9FD8
    procedure ClearSnapshots; // @addr $4BA10C
    function GetResourceChecksumFailed: Boolean; // @addr $4BA188
    procedure SetResourceChecksumFailed(Value: Boolean); // @addr $4BA1BC
    procedure SetFlag0A(Value: Boolean); // @addr $4BA2C4
    function GetValue10: Integer; // @addr $4BA41C Protected payload with unresolved purpose.
    procedure SetValue10(Value: Integer); // @addr $4BA450
    function GetFlag0A: Boolean; // @addr $4BA290 Protected flag consumed by the dormant galaxy checksum; purpose unresolved.
    procedure SetEditableStateApplied(Value: Boolean); // @addr $4BA348 Replaces the protected score-mod warning flag.
    function GetEditableStateApplied: Boolean; // @addr $4BA314 Read under Lock; used for the score-mod cheat warning.
    procedure SetProtectedStateXorSeed(Value: Integer); // @addr $4BA3CC Protected-state XOR seed; zero denotes restored state.
    function GetProtectedStateXorSeed: Integer; // @addr $4BA398 @note "Protected-state XOR seed; zero denotes restored state. Rangers reads it after the screen loop."
    function GetTamperDetected: Boolean; // @addr 0x4BA20C @note "Reads the protected tamper flag under Lock. SetMoney checks its encoded mirror and rereads after Sleep(1); NextDay similarly checks ammunition."
    procedure SetTamperDetected(Value: Boolean); // @addr 0x4BA240 @note "Copies the current snapshot, replaces byte 9 and commits it under Lock."
    function GetIntegrityStatus: Integer; // @addr $4BA4A0
    procedure SetIntegrityStatus(Value: Integer); // @addr $4BA4D4
    function GetIntegrityError: Integer; // @addr $4BA524
    procedure SetIntegrityError(Value: Integer); // @addr $4BA558
    function GetIntegrityChecksum: Cardinal; // @addr $4BA5A8
    procedure SetIntegrityChecksum(Value: Cardinal); // @addr $4BA5DC
    function GetIntegrityChecksum1: Cardinal; // @addr $4BA62C
    procedure SetIntegrityChecksum1(Value: Cardinal); // @addr $4BA660
    function GetIntegrityChecksum2: Cardinal; // @addr $4BA6B0
    procedure SetIntegrityChecksum2(Value: Cardinal); // @addr $4BA6E4
    function GetEncodedCheatPoints: Integer; // @addr $4BA734
    procedure SetEncodedCheatPoints(Value: Integer); // @addr $4BA768
  end;

function AddCursorUnit: TCursorUnit; // @addr 0x4C6CC4
procedure RemoveCursorUnit(Cursor: TCursorUnit); // @addr 0x4C6D28
function FindCursorByName(const Name: WideString): TCursorUnit; // @addr 0x4C6D94 @note "Case-sensitive lookup; raises when absent."
procedure PostMouseMoveMessage; // @addr 0x4C6E08 @note "Uses a zero key/button state."

procedure CheckRuntimeWatchdog; // @addr $4BDE24 @note "Native uses an explicit indirect jump into a generated fault sequence if the watchdog stops."
function MainWindowProc(Window, Message, WParam: Cardinal; LParam: Integer): Integer; stdcall; // @addr $4C4F50
procedure CaptureSavePreview; // @addr $4C5684 Creates a 300x225 RGB preview and equally sized scratch buffer.
procedure FreeSavePreviewBuffers; // @addr $4C5730
function GetGameUserDirectory: WideString; // @addr 0x4C7CC0 @ida "void __usercall $name(unsigned __int16 **Result@<eax>);" @note "Returns a trailing directory separator."
procedure CreateStartupLogFile; // @addr 0x4BDE5C
function MeasureCpuClockMHz: Double; // @addr $4C6E4C @note "Samples the low 32 bits of RDTSC over 200ms; returns 1500 on an exception."
function ReadRegistryText(Root: Cardinal; KeyPath, ValueName, DefaultValue: WideString): WideString; // @addr $4C6F28 @ida "void __userpurge $name(unsigned int Root@<eax>, unsigned __int16 *KeyPath@<edx>, unsigned __int16 *ValueName@<ecx>, unsigned __int16 *DefaultValue@<^4>, unsigned __int16 **Result@<^0>);" @note "ANSI registry API, fixed 2048-byte buffer, REG_SZ only."
function ReadRegistryInteger(Root: Cardinal; KeyPath, ValueName: WideString; DefaultValue: Integer): Integer; // @addr $4C7070
procedure ApplyProcessAffinity; // @addr $4BDDD8
procedure CheckPlatformModules; // @addr $4B92E0 @note "Native entry exits before the retained module/process checks; the entire dormant body is preserved."
procedure InitializePlatformRuntimeAndMainWindow; // @addr 0x4BDF20
procedure LoadLanguageAndPackages; // @addr 0x4BE5A8 @note "Falls back to Russian when the selected language is unavailable; raises on package-open failure."
procedure LoadSelectedModInstallBlocks; // @addr 0x4BE95C
procedure ResetInstalledPackageState; // @addr 0x4BED50
procedure FinalizePlatformRuntime; // @addr 0x4BEDDC
function HasWow64Support: Boolean; // @addr 0x4BEE34 @note "Requires a WOW64 process and the filesystem-redirection and extended registry APIs."
procedure ApplyMainWindowGeometry; // @addr 0x4BEF88
procedure ShowAndFocusMainWindow; // @addr 0x4BF1C8
procedure LoadDatConfigAndModOverrides; // @addr 0x4BF3D0
procedure FreeDatConfigRoots; // @addr 0x4BFA68
function IsInstallFeatureEnabled(const Path: WideString): Boolean; // @addr $4C6C50
procedure LoadInformationColorTags; // @addr $4C7834
procedure InitializeRuntimeAndSettings; // @addr 0x4BFB40
procedure FinalizeRuntimeAndSettings; // @addr 0x4C2694

procedure EnumerateAndSelectDisplayModes; // @addr 0x4C2788 @note "Keeps the highest refresh rate for each size. A zero-width entry means automatic resolution; a custom size may be appended."
procedure ConfigureDefaultRenderState; // @addr $4C3224
procedure PreparePresentationParameters; // @addr $4C32D4
procedure FreeScreenRenderBuffers; // @addr $4C48A8
procedure LogPresentationParameters; // @addr $4C8290
function Direct3DErrorText(Code: Integer): AnsiString; // @addr $4C71D4 @ida "void __usercall $name(int Code@<eax>, char **Result@<edx>);"
procedure GR_DXInit; // @addr 0x4C345C
procedure ApplyGammaRamp(Brightness, Contrast: Single); // @addr $4C4900 @ida "void __userpurge $name(float Brightness@<^4>, float Contrast@<^0>);" @note "Linear RGB ramp with brightness/contrast endpoints; returns when no device is present."
procedure GR_DXReset; // @addr 0x4C4720
function BeginFramePresentation: Boolean; // @addr $4C5278 @note "Increments the nesting count and always returns true."
procedure EndFramePresentation; // @addr $4C528C @note "Presents at the outermost level, subject to the frame-rate limit."
procedure PresentScreenBuffer; // @addr $4C52EC @note "Hardware mode ends/presents/restarts the scene; software mode draws the buffer texture unless OffscreenTexture is assigned."
function GR_WinMessage(Callback: TWindowMessageCallbackGR): Integer; // @addr $4C4C04 @note "Method callback receives Context/EAX, Message/EDX, WParam/ECX and LParam on stack. Returns zero when exiting."
procedure DrawOffscreenTexture; // @addr $4C5450 @note "Presents OffscreenTexture, fitting or cropping it to the viewport."
procedure CaptureScreenBackground(ApplyEffects: Boolean; UnusedOption: Byte); // @addr $4C5634
procedure CopyBgraToRgb24(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); // @addr $4C5768
procedure CaptureRecordingFrame; // @addr $4C586C @note "Copies a due software frame into the recording ring and flushes it when full."
procedure FlushRecordingFrames; // @addr $4C58EC @note "Writes pending RGB565 frames as sequential Film\\NNNNNN.bmp files."
function IsVirtualKeyDown(Key: Integer): Boolean; // @addr $4C689C @note "Tests bit 15 of GetAsyncKeyState."

function LookupLocalizedTextByKey(const Path: WideString): WideString; // @addr 0x4C68C8 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns one raw value, or a marker containing Path on lookup failure."
function LookupLocalizedTextOrEmpty(const Path: WideString): WideString; // @addr 0x4C68E8 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, unsigned __int16 **Result@<edx>);" @note "Returns one raw value; missing paths return empty and may create intermediate blocks."
function FormatUnixDateTime(Value: Cardinal): WideString; // @addr $4C77C8 @ida "void __usercall $name(unsigned int Value@<eax>, unsigned __int16 **Result@<edx>);"

function GiResourceSuffix: WideString; // @addr 0x4C6938 @ida "void __usercall $name(unsigned __int16 **Result@<eax>);" @note "Always returns 2 in this binary."
function GiResourceVariant: Integer; // @addr $4C6924 @note "Always returns 2; variant 1 retains the legacy quest-picture downscaling branch."
procedure AppendLogLineThreadSafe(const Text: AnsiString); // @addr 0x4C698C @note "Appends a line to the session log and closes the file. The lock is not released if a write raises."
procedure AppendDebugLogLine(const Text: AnsiString); // @addr $4C6A4C Creates #####add.log when absent; native unchecked TextFile I/O.
procedure AppendOptionalDebugLogLine(const Text: AnsiString); // @addr $4C6AF8 @note "Appends only when #####add.log already exists; shares SessionLogLock and native unchecked TextFile I/O."
procedure AppendLogTextThreadSafe(const Text: AnsiString); // @addr 0x4C69EC @note "Appends without a newline, flushes and closes the file."
procedure LogMemoryUsage; // @addr 0x4B993C

// Delphi wrappers translate DLL exceptions into Exception objects.
function BeginImageRead(Source: Pointer; SourceSize: Integer; out Width, Height: Integer): POkgfReadContext; // @addr 0x4BA8A0 @note "Borrows Source until ReadImagePixels consumes the context. Returns nil for unsupported input. Detection requires at least 34 bytes and accepts BMP, JFIF JPEG, PNG and supported PSD modes."
function ReadImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer; // @addr 0x4BA938 @note "Consumes Context on success; returns nonzero on success."
function BeginIndexedImageRead(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext; // @addr 0x4BA9D8 @note "Borrows Source; accepts indexed PNG and indexed or grayscale PSD. Returns nil on failure. BytesPerPixel is one or two."
function ReadIndexedImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer; // @addr 0x4BAA7C @note "Consumes Context on success. Palette requires the count returned by BeginIndexedImageRead."
function WritePngFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer; // @addr 0x4BAB10
function WriteBmpFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer; // @addr 0x4BABB8

// Delphi exception wrappers around the named OKGF/OKGR DLL exports.
// Ex_ distinguishes wrappers from DLL import symbols; full parameter types remain unresolved.
function Ex_OKGF_MulTable256x256: Pointer; // @addr 0x4BA7B8
function Ex_OKGF_DXVersion: Cardinal; // @addr 0x4BA830
procedure Ex_OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BAC6C
procedure Ex_OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BAD00
procedure Ex_OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BAD98
procedure Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BAE30
procedure Ex_OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BAECC
procedure Ex_OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BAF60
procedure Ex_OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BB004
function Ex_OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer; // @addr $4BB0A8
function Ex_OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $4BB150
procedure Ex_OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BB1F8
procedure Ex_OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BB2A0
function Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $4BB340
function Ex_OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; // @addr $4BB3F0
procedure Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $4BB498
procedure Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA); // @addr $4BB54C
procedure Ex_OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect); // @addr $4BB60C
procedure Ex_OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect); // @addr $4BB6B4
procedure Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal); // @addr $4BB758
procedure Ex_OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word); // @addr $4BB804
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BB8AC
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); // @addr $4BB958
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); // @addr $4BBA0C
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); // @addr $4BBAB4
function Ex_OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer; // @addr $4BBB68
procedure Ex_OKGR_RotateBuf_Free(Buffer: Pointer); // @addr $4BBC0C
procedure Ex_OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect); // @addr $4BBC88
procedure Ex_OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer); // @addr $4BBD20
procedure Ex_OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer); // @addr $4BBDC8
procedure Ex_OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect); // @addr $4BBE70
function Ex_OKGR_LightBuf_Create(Width, Height: Integer): Pointer; // @addr $4BBF24
procedure Ex_OKGR_LightBuf_Destroy(Buffer: Pointer); // @addr $4BBFB0
procedure Ex_OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer); // @addr $4BC02C
procedure Ex_OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte); // @addr $4BC0BC
procedure Ex_OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA); // @addr $4BC140
procedure Ex_OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte); // @addr $4BC1E4
function Ex_OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer; // @addr $4BC278
function Ex_OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer; // @addr $4BC320
procedure Ex_OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $4BC3A4
procedure Ex_OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $4BC45C
procedure Ex_OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $4BC51C
procedure Ex_OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $4BC5D4
procedure Ex_OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); // @addr $4BC694
procedure Ex_OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); // @addr $4BC74C
procedure Ex_OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $4BC80C
procedure Ex_OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer); // @addr $4BC8B8
procedure Ex_OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word); // @addr $4BC96C
procedure Ex_OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer); // @addr $4BCA20
procedure Ex_OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $4BCACC
procedure Ex_OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal); // @addr 0x4BCB78
procedure Ex_OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word); // @addr 0x4BCC14
procedure Ex_OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer); // @addr 0x4BCCA4
procedure Ex_OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr 0x4BCD3C
procedure Ex_OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr $4BCDD8
procedure Ex_OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); // @addr $4BCE74
procedure Ex_OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); // @addr $4BCF10
procedure Ex_OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer); // @addr 0x4BCFBC
procedure Ex_OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); // @addr $4BD050
procedure Ex_OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte); // @addr $4BD0EC
procedure Ex_OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); // @addr 0x4BD184
procedure Ex_OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); // @addr 0x4BD228
procedure Ex_OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); // @addr 0x4BD2CC
procedure Ex_OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); // @addr 0x4BD374
function Ex_OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer; // @addr $4BD41C @ida "int __userpurge $name@<eax>(int *X1@<eax>, int *Y1@<edx>, int *X2@<ecx>, int *Y2@<^4>, const TRect *Clip@<^0>);"
procedure DrawGradientLine16Clipped(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; Clip: TRect); // @addr $4C6820 @ida "void __userpurge $name(void *Pixels@<eax>, int Pitch@<edx>, int X1@<ecx>, int Y1@<^20>, unsigned int Color1@<^16>, int X2@<^12>, int Y2@<^8>, unsigned int Color2@<^4>, TRect *Clip@<^0>);" @note "Native implementation ignores Pixels/Pitch and draws into ScreenRenderBuffer."
function Ex_OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer; // @addr $4BD4B4 @ida "int __userpurge $name@<eax>(int *X1@<eax>, int *Y1@<edx>, unsigned int *Color1@<ecx>, int *X2@<^12>, int *Y2@<^8>, unsigned int *Color2@<^4>, const TRect *Clip@<^0>);"
procedure Ex_OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word); // @addr 0x4BD55C
procedure Ex_OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect); // @addr 0x4BD5FC
function Ex_OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; // @addr $4BD6A4
function Ex_OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; // @addr $4BD750 @note "Restores one saved 16-bit pixel per rasterized line point; returns the pixel count."
procedure Ex_OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect); // @addr 0x4BD7FC
procedure Ex_OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect); // @addr 0x4BD8AC
procedure Ex_OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer); // @addr 0x4BD954
procedure Ex_OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); // @addr 0x4BDA0C
procedure Ex_OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); // @addr 0x4BDABC
procedure Ex_OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect); // @addr 0x4BDB6C
procedure Ex_OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer); // @addr 0x4BDC1C
procedure Ex_OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BDCC0
procedure Ex_OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); // @addr $4BDD4C

var
  // Decoded: 'libogg-0', 'libvorbis-0', 'libvorbisfile', 'matrixgame',
  // 'okgf', 'steam_ach', 'steam_api', 'xvidcore', 'zlib'.
  // Differences from the 1024x768 UI baseline; may be negative.

function GiScalePixels(Value: Integer): Integer; // @addr 0x4C6958 @note "Identity function in this binary."
function GiScalePixelsEx(Value, AlternateValue: Integer): Integer; // @addr 0x4C6970 @note "Returns Value; AlternateValue is unused in this binary."

procedure RaiseWideMessage(const Message: WideString); // @addr 0x4C7178 @note "Converts the borrowed UTF-16 message to AnsiString and raises Exception."

procedure DrawTransparentBuffer16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Clip: TRect; HalfAlpha: Boolean); // @addr $4C5B94 @ida "void __userpurge $name(void *Dest@<eax>, int Pitch@<edx>, int X@<ecx>, int Y@<^12>, void *Source@<^8>, TRect *Clip@<^4>, unsigned __int8 HalfAlpha@<^0>);"
procedure CopyPalettedBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source, Palette: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect); // @addr $4C5C10 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^24>, void *Source@<^20>, void *Palette@<^16>, int SourcePitch@<^12>, int Width@<^8>, int Height@<^4>, TRect *Clip@<^0>);"
procedure CopyBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect; UnusedOption: Boolean); // @addr $4C5E74 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^24>, void *Source@<^20>, int SourcePitch@<^16>, int Width@<^12>, int Height@<^8>, TRect *Clip@<^4>, unsigned __int8 UnusedOption@<^0>);"
procedure DrawAlphaBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect); // @addr $4C61C4 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^20>, void *Source@<^16>, int SourcePitch@<^12>, int Width@<^8>, int Height@<^4>, TRect *Clip@<^0>);"
procedure ExpandPaletteToBgra(Dest: Pointer; DestPitch: Integer; Width, Height: Cardinal; Source: Pointer; SourcePitch: Integer; Palette: Pointer); // @addr $4C63F0

function GetStyleColorGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): Cardinal; // @addr 0x4C7A10 @note "Uses Data.StyleColor from Main.dat and the current pixel format. Missing entries use the defaults; malformed configured RGB text may raise."
function GetStyleColorTagGI(StyleName: WideString; DefaultRed, DefaultGreen, DefaultBlue: Integer): WideString; // @addr 0x4C7B64 @ida "void __userpurge $name(unsigned __int16 *StyleName@<eax>, int DefaultRed@<edx>, int DefaultGreen@<ecx>, int DefaultBlue@<^4>, unsigned __int16 **Result@<^0>);" @note "Returns a complete opening <color=...> tag. Configured Data.StyleColor text is inserted verbatim; missing entries use the default RGB values."

procedure CopyGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; HalfAlpha, UnusedOption: Boolean); // @addr $4C5D18 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^16>, TGraphBufGR *Source@<^12>, TRect *Clip@<^8>, bool HalfAlpha@<^4>, bool UnusedOption@<^0>);"

procedure DrawAlphaGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect); // @addr $4C60A0 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^8>, TGraphBufGR *Source@<^4>, TRect *Clip@<^0>);"

procedure CopyTransparentGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; TransparentColor: Word); // @addr $4C5F78 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^12>, TGraphBufGR *Source@<^8>, TRect *Clip@<^4>, unsigned __int16 TransparentColor@<^0>);"

procedure DrawPaletteAlphaBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect); // @addr $4C62C8 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^8>, TGraphBufPalGR *Source@<^4>, TRect *Clip@<^0>);"

procedure BlendPaletteBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect); // @addr $4C64D4 @ida "void __userpurge $name(void *Dest@<eax>, int DestPitch@<edx>, int X@<ecx>, int Y@<^8>, TGraphBufPalGR *Source@<^4>, TRect *Clip@<^0>);"

function GetClipboardWideText: WideString; // @addr $4C8004 @ida "void __usercall $name(unsigned __int16 **Result@<eax>);"
procedure SetClipboardWideText(Text: WideString); // @addr $4C8084
procedure WriteTextFileThreadSafe(FileName, Text: AnsiString); // @addr $4C6B98

function ComputeMachineFingerprintCRC: Cardinal; // @addr $4C7E6C CRC32 of the C: volume serial and ANSI processor name. Native code ignores volume-query failure.

var
  // Managed globals follow the verified native finalization order.
var
  RuntimeActive: Boolean; // @addr $888E60 @note "Message pump returns without sleeping when active; cleared during device loss."
  VSyncEnabled: Boolean; // @addr $888E61
  PathGrowEnabled: Boolean; // @addr $888E62 @note "User setting PathGrow; permits extending the shared path-node pool."
  ShowSystemMouse: Boolean; // @addr $888E63 @note "User setting ShowSystemMouse; uses Windows cursor handles instead of drawing the image child."
  ScreenRenderBuffer: TGraphBufGR; // @addr 0x888E64
  RenderScratchBuffer: TGraphBufGR; // @addr $888E68
  AuxRenderBuffer: TGraphBufGR; // @addr $888E6C  Second shared scratch buffer, also used for captured screen backgrounds.
  SelectedLanguage: WideString; // @addr $888E70
  RequestedLanguage: WideString; // @addr $888E74
  AvailableLanguageCodes: WideString; // @addr $888E78
  OverrideGameUserDirectory: WideString; // @addr $888E7C
var
  CurrentPixelFormat: TPixelFormatGR; // @addr $888E80
  GameScreenWidth: Integer; // @addr $888E84
  GameScreenHeight: Integer; // @addr $888E88
  PresentationWidth: Integer; // @addr $888E8C
  PresentationHeight: Integer; // @addr $888E90
  ViewportOffset: TPoint; // @addr $888E94
  AlternateViewportEnabled: Boolean; // @addr $888E9C  Enables scaled or panned software presentation and mouse-coordinate conversion.
  GameScreenRect: TRect; // @addr $888EA0
  PresentationRect: TRect; // @addr $888EB0
  ScrollInteriorRect: TRect; // @addr $888EC0
  MainWindowHandle: Cardinal; // @addr 0x888ED0
  WideCaseTable: array of TWideCasePair; // @addr 0x888ED4

function OKGF_ZLib_Compress(Dest, Source: Pointer; SourceSize, Mode: Integer): Integer; stdcall;
  external 'ZLib.dll' name 'OKGF_ZLib_Compress'; // @addr 0x4B8DC8
function OKGF_ZLib_UnCompress(Dest: Pointer; DestCapacity: Integer; Source: Pointer; SourceSize: Integer): Integer; stdcall;
  external 'ZLib.dll' name 'OKGF_ZLib_UnCompress'; // @addr 0x4B8DD0

function GlobalMemoryStatusEx(var Status: TMemoryStatusEx): LongBool; stdcall;
  external 'kernel32' name 'GlobalMemoryStatusEx'; // @addr 0x4B8DD8

function OKGF_MulTable256x256: Pointer; cdecl;
  external 'okgf.dll' name 'OKGF_MulTable256x256'; // @addr $4B8DE0

function OKGF_DXVersion: Cardinal; cdecl;
  external 'okgf.dll' name 'DXVersion'; // @addr $4B8DE8

function OKGF_ReadStart_Buf(Source: Pointer; SourceSize: Integer; out Width, Height: Integer): POkgfReadContext; cdecl;
  external 'okgf.dll' name 'OKGF_ReadStart_Buf'; // @addr $4B8DF0

function OKGF_Read(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Read'; // @addr $4B8DF8

function OKGF_ReadStartPal_Buf(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext; cdecl;
  external 'okgf.dll' name 'OKGF_ReadStartPal_Buf'; // @addr $4B8E00

function OKGF_ReadPal(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_ReadPal'; // @addr $4B8E08

function OKGF_Write_PNG_File(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Write_PNG_File'; // @addr $4B8E10

function OKGF_Write_BMP_File(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGF_Write_BMP_File'; // @addr $4B8E18

procedure OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_Draw_RGBA'; // @addr $4B8E20

procedure OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_Draw_RGBA'; // @addr $4B8E28

procedure OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_Draw_RGBA'; // @addr $4B8E30

procedure OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDraw_RGBA'; // @addr $4B8E38

procedure OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_Draw_RGBA'; // @addr $4B8E40

procedure OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_DrawClip_WORD'; // @addr $4B8E48

procedure OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_HADrawClip_16'; // @addr $4B8E50

function OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_Build_WORD'; // @addr $4B8E58

function OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_BuildFromRGBA_16'; // @addr $4B8E60

procedure OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_DrawClip_WORD'; // @addr $4B8E68

procedure OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_DrawClip_16'; // @addr $4B8E70

function OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_TransAlphaBuf_BuildFromRGBA_16'; // @addr $4B8E78

function OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_AlphaBuf_BuildFromRGBA'; // @addr $4B8E80

procedure OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaSimpleBuf_Draw_16'; // @addr $4B8E88

procedure OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaSimpleBufPalAlpha_Draw_16'; // @addr $4B8E90

procedure OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_MaskBuf_DrawClip_DWORD'; // @addr $4B8E98

procedure OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_MaskBuf_DrawClip_WORD'; // @addr $4B8EA0

procedure OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_FillAlphaClip_RGBA'; // @addr $4B8EA8

procedure OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_TransBuf_FillAlphaClip_16'; // @addr $4B8EB0

procedure OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_CopyDrawClip_WORD'; // @addr $4B8EB8

procedure OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_CopyDrawClip_Alpha_16'; // @addr $4B8EC0

procedure OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDrawClip_16'; // @addr $4B8EC8

procedure OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16'; // @addr $4B8ED0

function OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Build'; // @addr $4B8ED8

procedure OKGR_RotateBuf_Free(Buffer: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Free'; // @addr $4B8EE0

procedure OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Size'; // @addr $4B8EE8

procedure OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Draw_DWORD'; // @addr $4B8EF0

procedure OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_Draw_BYTE'; // @addr $4B8EF8

procedure OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_RotateBuf_DrawTransClip_WORD'; // @addr $4B8F00

function OKGR_LightBuf_Create(Width, Height: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Create'; // @addr $4B8F08

procedure OKGR_LightBuf_Destroy(Buffer: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Destroy'; // @addr $4B8F10

procedure OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_SetSme'; // @addr $4B8F18

procedure OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Init'; // @addr $4B8F20

procedure OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_LoadFromPalBuf'; // @addr $4B8F28

procedure OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_LightBuf_Rotate'; // @addr $4B8F30

function OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer; cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_TemplBuild'; // @addr $4B8F38

// The native Delphi binding preserves EAX, but the DLL defines no result contract.
function OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_TemplDel'; // @addr $4B8F40

procedure OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_DrawAndLight_32'; // @addr $4B8F48

procedure OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet2_DrawAndLightClip_16'; // @addr $4B8F50

procedure OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet3_DrawAndLight_32'; // @addr $4B8F58

procedure OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet3_DrawAndLightClip_16'; // @addr $4B8F60

procedure OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Planet4_DrawAndLight_32'; // @addr $4B8F68

procedure OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Planet4_DrawAndLightClip_16'; // @addr $4B8F70

procedure OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_Copy_XY_XY_WORD'; // @addr $4B8F78

procedure OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_PalCopy_XY_XY_WORD'; // @addr $4B8F80

procedure OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word); cdecl;
  external 'okgf.dll' name 'OKGR_CopyTrans_XY_XY_WORD'; // @addr $4B8F88

procedure OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_CopySingleBuf_XY_XY_WORD'; // @addr $4B8F90

procedure OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_HACopy_XY_XY_16'; // @addr $4B8F98

procedure OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGR_StretchGdi_WORD'; // @addr $4B8FA0

procedure OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_Fill_WORD'; // @addr $4B8FA8

procedure OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_ConvertRGBto565'; // @addr $4B8FB0

procedure OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toRGB'; // @addr $4B8FB8

procedure OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toBGR'; // @addr $4B8FC0

procedure OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert565toBGRA'; // @addr $4B8FC8

procedure OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Convert_8888to565'; // @addr $4B8FD0

procedure OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_ShrLight_16'; // @addr $4B8FD8

procedure OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_ShrLightMask_16'; // @addr $4B8FE0

procedure OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_Light_BYTE'; // @addr $4B8FE8

procedure OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawClip_WORD'; // @addr $4B8FF0

procedure OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawClip_BYTE'; // @addr $4B8FF8

procedure OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawFillClip_WORD'; // @addr $4B9000

procedure OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Circle_DrawFillClip_BYTE'; // @addr $4B9008

procedure OKGR_PixelAlpha_16(Pixel: Pointer; Color: Word; Alpha: Byte); cdecl;
  external 'okgf.dll' name 'OKGR_PixelAlpha_16'; // @addr $4B9010

function OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_Clip'; // @addr $4B9018

function OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_LineColor_Clip'; // @addr $4B9020

procedure OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word); cdecl;
  external 'okgf.dll' name 'OKGR_Line_Draw_WORD'; // @addr $4B9028

procedure OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Line_DrawClip_WORD'; // @addr $4B9030

function OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_CopyToBuf_WORD'; // @addr $4B9038

function OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer; cdecl;
  external 'okgf.dll' name 'OKGR_Line_CopyFromBuf_WORD'; // @addr $4B9040

procedure OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Line_DrawClip_Alpha_16'; // @addr $4B9048

procedure OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_AnimLine_Draw_16'; // @addr $4B9050

procedure OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer); cdecl;
  external 'okgf.dll' name 'OKGR_AnimShadowLine_Draw_16'; // @addr $4B9058

procedure OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Alpha64Trapezium_16'; // @addr $4B9060

procedure OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_Alpha128Trapezium_16'; // @addr $4B9068

procedure OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect); cdecl;
  external 'okgf.dll' name 'OKGR_FillTrapezium_DWORD'; // @addr $4B9070

procedure OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer); cdecl;
  external 'okgf.dll' name 'OKGF_Rescale'; // @addr $4B9078

procedure OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_F5_DrawRGBA'; // @addr $4B9080

procedure OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer); cdecl;
  external 'okgf.dll' name 'OKGR_F6_DrawRGBA'; // @addr $4B9088

procedure OKGF_Triangle_16(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Clip: PRect); cdecl;
  external 'okgf.dll' name 'OKGF_Triangle_16'; // @addr $4B9090 @note "Cdecl triangle ABI verified at native caller $60369C."

procedure OKGF_LineIp_16(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal); cdecl;
  external 'okgf.dll' name 'OKGF_LineIp_16'; // @addr $4B9098 @note "Cdecl gradient-line ABI verified at native caller $4C6820."

var
  InstallConfig: TBlockParEC; // @addr 0x888ED8
  LanguageInstallConfig: TBlockParEC; // @addr 0x888EDC
  UserSettingsConfig: TBlockParEC; // @addr 0x888EE0
  MainDataConfig: TBlockParEC; // @addr 0x888EE4
  LanguageDataConfig: TBlockParEC; // @addr 0x888EE8
  UiStyleConfig: TBlockParEC; // @addr $888EEC
  SelectedMods: WideString; // @addr $888EF0
  SelectedModsDisplaySuffix: WideString; // @addr $888EF4
  LoadedSaveModSet: WideString; // @addr 0x888EF8
var
  SuppressModRetryPrompt: Boolean = False; // @addr $87A6DC @note "Startup failure guard; other writers remain to be recovered."
  SkipModsOnReload: Boolean = False; // @addr $87A6E0
  WindowedModeRequested: Boolean = False; // @addr $87A6E4
  ExitScreenLoop: Boolean = False; // @addr 0x87A6E8
  FullFrameRedrawRequested: Boolean = True; // @addr $87A6EC
  DisplayBrightness: Single = 0; // @addr $87A6F0
  DisplayContrast: Single = 0; // @addr $87A6F4
  RobotBrightness: Single = 0; // @addr $87A6F8
  RobotContrast: Single = 0; // @addr $87A6FC
  OffscreenFrameUpdated: Boolean = False; // @addr $87A700
  OffscreenLastPresentationTick: Cardinal = 0; // @addr $87A704
  InterfaceBlendPalette: Pointer = nil; // @addr $87A708 @note "256 RGB565 colors blended between (8,32,255) and (200,128,128)."
  RequestedRefreshRate: Integer = 0; // @addr $87A70C
  PresentWithoutLimit: Boolean = False; // @addr $87A710
  DisableHardwareVertexProcessing: Boolean = False; // @addr $87A714
  DisableMultithreadFlag: Boolean = False; // @addr $87A718
  DisableTripleBuffer: Boolean = False; // @addr $87A71C
  ModInstallConfigs: TList = nil; // @addr $87A720 @note "Owns TBlockParEC entries loaded from selected mods' Install.txt files."
  ModLanguageInstallConfigs: TList = nil; // @addr $87A724 @note "Owns the selected mods' language-specific install blocks."
  ApplyEditableSaveOnLoad: Boolean = False; // @addr $87A728
  EditableSaveFileName: WideString = ''; // @addr $87A72C
var
  // Both need initialized storage, including the nil pointer, so native dormant
  // checks adding 4 to PlatformCheckAnchor's address still target ModShipNameConfig.
  PlatformCheckAnchor: Integer = -35753766; // @addr $87A730 @note "Dormant checks write a random integer at byte offset 4 from this address, overlapping ModShipNameConfig. Original anchor meaning unresolved."
  ModShipNameConfig: TBlockParEC = nil; // @addr $87A734
  ModRuinNameConfig: TBlockParEC = nil; // @addr $87A738
  NewGameSeedText: WideString = ''; // @addr $87A73C User-supplied galaxy seed, edited by CheatSeed.
var
  CacheLoadLoggingEnabled: Boolean = False; // @addr $87A740
  SoundManager: TSoundControl = nil; // @addr $87A744
  MusicManager: TMusicControl = nil; // @addr $87A748
  ShowFrameRate: Boolean = False; // @addr $87A74C
  RecordingFrames: Boolean = False; // @addr $87A750
  RecordingFrameBuffers: TList = nil; // @addr $87A754
  FirstRegisteredCursor: TCursorUnit = nil; // @addr 0x87A758
  LastRegisteredCursor: TCursorUnit = nil; // @addr 0x87A75C
  BuildVersionMismatch: Boolean = False; // @addr $87A760
  SessionLogLock: TCriticalSection = nil; // @addr 0x87A764
  DebugKeyCallback: TDebugKeyCallbackGR = nil; // @addr $87A768  Receives Ctrl+Shift keys when Alt is not held.
  CustomCursorEnabled: Boolean = True; // @addr $87A76C @note "Gates message-loop cursor selection and restoration."
  DirectXVersion: Cardinal = 0; // @addr $87A770
  RecordingFrameCount: Integer = 0; // @addr $87A774
  RecordingFrameInterval: Integer = 50; // @addr $87A778 @note "1000 div FilmFPS; native does not check for zero."
  LastRecordingFrameTick: Cardinal = 0; // @addr $87A77C
  // Keep these zero-filled globals consecutive and in this order. Native
  // VerifyStartupModuleChecksum subtracts 8 from StartupChecksumAnchor's address;
  // other routines access each variable directly. DCC32 preserves this storage order.
  UnknownPresentState: Integer = 0; // @addr $87A780 Signed integrity marker: positive after a failed startup module checksum, negative after a clean check; reset by TMessageLoopGI.Present.
  LastMouseMessageTick: Cardinal = 0; // @addr $87A784
  StartupChecksumAnchor: Integer = 0; // @addr $87A788 @note "Checksum helper accesses UnknownPresentState at byte offset -8; original anchor meaning unresolved."
  RobotBattleActive: Boolean = False; // @addr $87A78C Set across MatrixGame Run, including its exception handler.
  ProcessorCoreCount: Integer = 1; // @addr $87A790 @note "Counts CentralProcessor registry subkeys, with a minimum of one."
  Direct3D: IDirect3D9 = nil; // @addr $87A794
  Direct3DDevice: IDirect3DDevice9 = nil; // @addr 0x87A798
  OffscreenTexture: IDirect3DTexture9 = nil; // @addr $87A79C
var
  OffscreenFillViewport: Boolean = False; // @addr $87A7A0  Fill/crop instead of fitting the entire video frame.
  UseDesktopDisplayMode: Boolean = False; // @addr $87A7A4
  GameDisplayModeCount: Integer = 0; // @addr 0x87A7A8
  SelectedGameDisplayMode: Integer = -1; // @addr 0x87A7AC
  SmallestGameDisplayMode: Integer = -1; // @addr $87A7B0
  UseAutomaticRobotDisplayMode: Boolean = False; // @addr $87A7B4
  RobotDisplayModeCount: Integer = 0; // @addr 0x87A7B8
  SelectedRobotDisplayMode: Integer = -1; // @addr 0x87A7BC
  AltResolutionSwitch: Boolean = False; // @addr $87A7C0
  LastPresentationTick: Cardinal = 0; // @addr $87A7C4
  PresentationFrameRate: Cardinal = 0; // @addr $87A7C8
  RuntimeWatchdog: TThreadEC = nil; // @addr $87A7CC
  PresentationDepth: Integer = 0; // @addr $87A7D0

var
  EditableSaveBlock: TBlockParEC; // @addr $888EFC
  GameDataConfig: TBlockParEC; // @addr 0x888F00 @note "Borrowed MainDataConfig.Data block; contains StyleColor."
  NewGameSettingsConfig: TBlockParEC; // @addr $888F04 @note "Optional user-directory newgame.txt."
  UiDepthConfig: TBlockParEC; // @addr $888F08  Borrowed MainDataConfig.ZPos depth-name table.
  CacheDataRoot: TDataEC; // @addr $888F0C
  GlobalCache: TCacheEC; // @addr 0x888F10
  SessionLog: TextFile; // @addr 0x888F14
  SavePreviewGraph: TGraphBufGR; // @addr $8890E0
  SecondarySavePreviewGraph: TGraphBufGR; // @addr $8890E4
  PerformanceCounterFrequency: Int64; // @addr $8890E8
  DebugCommandMessage: Cardinal; // @addr $8890F0
  SuppressExceptionLogCopy: Boolean; // @addr $8890F4  Consumed by $602884 to skip the separate exception-log copy.
  BlendPixel16: TBlendPixel16; // @addr $8890F8
  TriangleRasterizer16: TTriangleRasterizer16; // @addr $8890FC @note "OKGF_Triangle_16 callback; cdecl pixel, pitch, vertex/color arguments."
  LineRasterizer16: TLineRasterizer16; // @addr $889100 @note "OKGF_LineIp_16 callback; cdecl pixel, pitch, vertex/color arguments."
  RuntimeExitCheckCallback1: procedure; // @addr $889104 Assigned by Rangers.start; no native reads indexed.
  RuntimeExitCheckCallback2: procedure; // @addr $889108 Assigned by Rangers.start; no native reads indexed.
  OnMessageIdle: TRuntimeCallbackGR; // @addr $88910C
  OnMessageResume: TRuntimeCallbackGR; // @addr $889110
  CCInterface: TCCInterface; // @addr $889114 @note "Owned here: direct startup/helper accesses; other units use reference cell $882218."
  RuntimeStartupTick: Cardinal; // @addr $889118
  MainRuntimeThreadId: Cardinal; // @addr $88911C
type
  // This value-object declaration advances DCC32's anonymous RTTI counter.
  // Its position reproduces the display arrays' native names; original spelling is unknown.
  PDisplayModeGR = ^TDisplayModeGR;
  TDisplayModeGR = object // @size 0x10
    Width: Cardinal; // @offset 0x00
    Height: Cardinal; // @offset 0x04
    RefreshRate: Cardinal; // @offset 0x08
    Format: Cardinal; // @offset 0x0C
  end;

  TDisplayModeArrayGR = array of TDisplayModeGR;

var
  DesktopDisplayMode: TDisplayModeGR; // @addr $889120
  Direct3DPresentParameters: TD3DPresentParameters; // @addr $889130
  PreviousPresentParameters: TD3DPresentParameters; // @addr $889168
  GameDisplayModes: array of TDisplayModeGR; // @addr 0x8891A0
  RobotDisplayModes: array of TDisplayModeGR; // @addr 0x8891A4
var
  ExtraScreenWidth: Integer; // @addr 0x8891A8
  ExtraScreenHeight: Integer; // @addr 0x8891AC
  EncodedPlatformModuleNames: array[0..8] of AnsiString = (
    'loinbaosgaga-10a', 'loinbavrokrablius-->0', 'loinbaveohrablissufainlae',
    'mhastorhinxagrakmae', 'ookogifa', 'sotoenalm^_^aucah', 'sotoenalm^_^aupki',
    'xavriadeccomrie', 'zoloimba'); // @addr $87A7D4 @note "Alternating-character DLL basenames consumed by dormant CheckPlatformModules."
  CachedGameUserDirectory: WideString = ''; // @addr $87A7F8

implementation

// @unit-initialization $8757E0
// @unit-finalization $4C86E0

uses GI_Main, DirectXRenderException, TlHelp32, aPacket, DateUtils, Robot, GI_MessageLoop, MMSystem, EC_Mem, GR_DX, Globals, aMyFunction, MessageText, GlobalsV, ShlObj, Math, Forms, Clipbrd, SysUtils, Messages, ActiveX, Windows, Registry;

var
  StartupState: Cardinal; // @addr $8891B4 @note "Cleared by settings initialization; no retained reader found, original meaning unresolved."
  ScreenCenterX: Cardinal; // @addr $8891B8
  ScreenCenterY: Cardinal; // @addr $8891BC
  LastWindowMessageTick: Cardinal; // @addr $8891C0
  MessageIdle: Boolean; // @addr $8891C4

{$I-}

{ @routine $4B92E0 CheckPlatformModules }
procedure CheckPlatformModules;
var
  GameDirectory, ModulePath: AnsiString;
  Snapshot, SteamProcessId: Cardinal;
  Index, FailureOffset: Integer;
  Found: Boolean;
  DllSuffix: WideString;
  SteamClientPath: AnsiString;
  Entry: TModuleEntry32;

  // @nested $4B91D4 MatchesModuleDirectoryPrefix
  function MatchesModuleDirectoryPrefix(Prefix, Path: AnsiString): Boolean; // @addr $4B91D4 @ida "bool __usercall $name@<al>(char *Prefix@<eax>, char *Path@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4B93D1" @note "Nested helper. Requires Prefix no longer than Path, but compares only characters 1 through Length(Prefix)-1."
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
  // This build disables the checks, but Delphi O- retained their native bytes.
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
      repeat
        if MatchesModuleDirectoryPrefix(GameDirectory,
          AnsiLowerCase(ExtractFilePath(AnsiString(Entry.szExePath)))) then
        begin
          Found := False;
          ModulePath := AnsiLowerCase(AnsiString(Entry.szModule));
          for Index := 0 to 8 do
          begin
            // Decoded: 'libogg-0.dll', 'libvorbis-0.dll', 'libvorbisfile.dll',
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
      until not Module32Next(Snapshot, Entry);
    end;
    CloseHandle(Snapshot);
  end;
  SteamClientPath := AnsiLowerCase(AnsiString(ReadRegistryText(HKEY_CURRENT_USER,
    DecodeTextW('Sdonf6t4wdabrden\7Vga4l-v7ef\3Sdt6e8a,mu\gAcczt1i2v3e2Pvrnohcyetsrs'), // Decoded: 'Software\Valve\Steam\ActiveProcess'
    DecodeTextW('S4tgefadm.ClliitevnvteDtlfls'), ''))); // Decoded: 'SteamClientDll'
  SteamProcessId := ReadRegistryInteger(HKEY_CURRENT_USER,
    DecodeTextW('Sdonf6t4wdabrden\7Vga4l-v7ef\3Sdt6e8a,mu\gAcczt1i2v3e2Pvrnohcyetsrs'), 'pid', 0); // Decoded: 'Software\Valve\Steam\ActiveProcess'
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
          DecodeTextW('s1t2eda5mg.he7xie'))) then // Decoded: 'steam.exe'
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
{ @end $4B92E0 }

{ @routine $4B993C LogMemoryUsage }
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
{ @end $4B993C }

{ @routine $4B9C44 TCCInterface_Create }
constructor TCCInterface.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  Randomize;
  Buffer := TBufEC.Create;
  CommitSnapshot(CreateEmptySnapshot);
end;
{ @end $4B9C44 }

{ @routine $4B9CC0 TCCInterface_Destroy }
destructor TCCInterface.Destroy;
begin
  Lock.Free;
  Buffer.Free;
  ClearSnapshots;
  inherited Destroy;
end;
{ @end $4B9CC0 }

{ @routine $4B9D10 TCCInterface_Reset }
procedure TCCInterface.Reset;
begin
  Lock.Enter;
  Buffer.Clear;
  ClearSnapshots;
  CommitSnapshot(CreateEmptySnapshot);
  Lock.Leave;
end;
{ @end $4B9D10 }

{ @routine $4B9D58 TCCInterface_GetSnapshot }
function TCCInterface.GetSnapshot: PCCSnapshot;
var Entry: PCCSnapshot;
begin
  Entry := SnapshotHead;
  while (Entry.Prev = nil) or (Entry.Next.Prev = Entry) do Entry := Entry.Next;
  Result := Entry.Next;
end;
{ @end $4B9D58 }

{ @routine $4B9D9C TCCInterface_CreateDecoy }
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
{ @end $4B9D9C }

{ @routine $4B9EAC TCCInterface_CreateEmptySnapshot }
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
{ @end $4B9EAC }

{ @routine $4B9F28 TCCInterface_CopySnapshot }
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
{ @end $4B9F28 }

{ @routine $4B9FD8 TCCInterface_CommitSnapshot }
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
{ @end $4B9FD8 }

{ @routine $4BA10C TCCInterface_ClearSnapshots }
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
{ @end $4BA10C }

{ @routine $4BA188 TCCInterface_GetResourceChecksumFailed }
function TCCInterface.GetResourceChecksumFailed: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.ResourceChecksumFailed;
  Lock.Leave;
end;
{ @end $4BA188 }

{ @routine $4BA1BC TCCInterface_SetResourceChecksumFailed }
procedure TCCInterface.SetResourceChecksumFailed(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.ResourceChecksumFailed := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA1BC }

{ @routine $4BA20C TCCInterface_GetTamperDetected }
function TCCInterface.GetTamperDetected: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.TamperDetected;
  Lock.Leave;
end;
{ @end $4BA20C }

{ @routine $4BA240 TCCInterface_SetTamperDetected }
procedure TCCInterface.SetTamperDetected(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.TamperDetected := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA240 }

{ @routine $4BA290 TCCInterface_GetFlag0A }
function TCCInterface.GetFlag0A: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.Flag0A;
  Lock.Leave;
end;
{ @end $4BA290 }

{ @routine $4BA2C4 TCCInterface_SetFlag0A }
procedure TCCInterface.SetFlag0A(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.Flag0A := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA2C4 }

{ @routine $4BA314 TCCInterface_GetEditableStateApplied }
function TCCInterface.GetEditableStateApplied: Boolean;
begin
  Lock.Enter;
  Result := GetSnapshot.EditableStateApplied;
  Lock.Leave;
end;
{ @end $4BA314 }

{ @routine $4BA348 TCCInterface_SetEditableStateApplied }
procedure TCCInterface.SetEditableStateApplied(Value: Boolean);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.EditableStateApplied := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA348 }

{ @routine $4BA398 TCCInterface_GetProtectedStateXorSeed }
function TCCInterface.GetProtectedStateXorSeed: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.ProtectedStateXorSeed;
  Lock.Leave;
end;
{ @end $4BA398 }

{ @routine $4BA3CC TCCInterface_SetProtectedStateXorSeed }
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
{ @end $4BA3CC }

{ @routine $4BA41C TCCInterface_GetValue10 }
function TCCInterface.GetValue10: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.Value10;
  Lock.Leave;
end;
{ @end $4BA41C }

{ @routine $4BA450 TCCInterface_SetValue10 }
procedure TCCInterface.SetValue10(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.Value10 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA450 }

{ @routine $4BA4A0 TCCInterface_GetIntegrityStatus }
function TCCInterface.GetIntegrityStatus: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityStatus;
  Lock.Leave;
end;
{ @end $4BA4A0 }

{ @routine $4BA4D4 TCCInterface_SetIntegrityStatus }
procedure TCCInterface.SetIntegrityStatus(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityStatus := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA4D4 }

{ @routine $4BA524 TCCInterface_GetIntegrityError }
function TCCInterface.GetIntegrityError: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityError;
  Lock.Leave;
end;
{ @end $4BA524 }

{ @routine $4BA558 TCCInterface_SetIntegrityError }
procedure TCCInterface.SetIntegrityError(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityError := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA558 }

{ @routine $4BA5A8 TCCInterface_GetIntegrityChecksum }
function TCCInterface.GetIntegrityChecksum: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum;
  Lock.Leave;
end;
{ @end $4BA5A8 }

{ @routine $4BA5DC TCCInterface_SetIntegrityChecksum }
procedure TCCInterface.SetIntegrityChecksum(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA5DC }

{ @routine $4BA62C TCCInterface_GetIntegrityChecksum1 }
function TCCInterface.GetIntegrityChecksum1: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum1;
  Lock.Leave;
end;
{ @end $4BA62C }

{ @routine $4BA660 TCCInterface_SetIntegrityChecksum1 }
procedure TCCInterface.SetIntegrityChecksum1(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum1 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA660 }

{ @routine $4BA6B0 TCCInterface_GetIntegrityChecksum2 }
function TCCInterface.GetIntegrityChecksum2: Cardinal;
begin
  Lock.Enter;
  Result := GetSnapshot.IntegrityChecksum2;
  Lock.Leave;
end;
{ @end $4BA6B0 }

{ @routine $4BA6E4 TCCInterface_SetIntegrityChecksum2 }
procedure TCCInterface.SetIntegrityChecksum2(Value: Cardinal);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.IntegrityChecksum2 := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA6E4 }

{ @routine $4BA734 TCCInterface_GetEncodedCheatPoints }
function TCCInterface.GetEncodedCheatPoints: Integer;
begin
  Lock.Enter;
  Result := GetSnapshot.EncodedCheatPoints;
  Lock.Leave;
end;
{ @end $4BA734 }

{ @routine $4BA768 TCCInterface_SetEncodedCheatPoints }
procedure TCCInterface.SetEncodedCheatPoints(Value: Integer);
var Snapshot: PCCSnapshot;
begin
  Lock.Enter;
  Snapshot := CopySnapshot(GetSnapshot);
  Snapshot.EncodedCheatPoints := Value;
  CommitSnapshot(Snapshot);
  Lock.Leave;
end;
{ @end $4BA768 }

{ @routine $4BA7B8 Ex_OKGF_MulTable256x256 }
function Ex_OKGF_MulTable256x256: Pointer;
begin
  try
    Result := OKGF_MulTable256x256;
  except
    raise Exception.Create('Error in OKGF_MulTable256x256');
  end;
end;
{ @end $4BA7B8 }

{ @routine $4BA830 Ex_OKGF_DXVersion }
function Ex_OKGF_DXVersion: Cardinal;
begin
  try
    Result := OKGF_DXVersion;
  except
    raise Exception.Create('Error in OKGF_DXVersion');
  end;
end;
{ @end $4BA830 }

{ @routine $4BA8A0 BeginImageRead }
function BeginImageRead(Source: Pointer; SourceSize: Integer; out Width, Height: Integer): POkgfReadContext;
begin
  try
    Result := OKGF_ReadStart_Buf(Source, SourceSize, Width, Height);
  except
    raise Exception.Create('Error in OKGF_ReadStart_Buf');
  end;
end;
{ @end $4BA8A0 }

{ @routine $4BA938 ReadImagePixels }
function ReadImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; BytesPerPixel: Integer): Integer;
begin
  try
    Result := OKGF_Read(Context, Pixels, PitchBytes, RedMask, GreenMask, BlueMask, AlphaMask, BytesPerPixel);
  except
    raise Exception.Create('Error in OKGF_Read');
  end;
end;
{ @end $4BA938 }

{ @routine $4BA9D8 BeginIndexedImageRead }
function BeginIndexedImageRead(Source: Pointer; SourceSize: Integer; out Width, Height, PaletteCount, BytesPerPixel: Integer): POkgfReadContext;
begin
  try
    Result := OKGF_ReadStartPal_Buf(Source, SourceSize, Width, Height, PaletteCount, BytesPerPixel);
  except
    raise Exception.Create('Error in OKGF_ReadStartPal_Buf');
  end;
end;
{ @end $4BA9D8 }

{ @routine $4BAA7C ReadIndexedImagePixels }
function ReadIndexedImagePixels(Context: POkgfReadContext; Pixels: Pointer; PitchBytes: Integer; Palette: PColorRGBA): Integer;
begin
  try
    Result := OKGF_ReadPal(Context, Pixels, PitchBytes, Palette);
  except
    raise Exception.Create('Error in OKGF_ReadPal');
  end;
end;
{ @end $4BAA7C }

{ @routine $4BAB10 WritePngFile }
function WritePngFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, Width, Height, HasAlpha, SwapRedBlue: Integer): Integer;
begin
  try
    Result := OKGF_Write_PNG_File(FileName, Pixels, PitchBytes, Width, Height, HasAlpha, SwapRedBlue);
  except
    raise Exception.Create('Error in OKGF_Write_PNG_File');
  end;
end;
{ @end $4BAB10 }

{ @routine $4BABB8 WriteBmpFile }
function WriteBmpFile(FileName: PAnsiChar; Pixels: Pointer; PitchBytes, BitsPerPixel: Integer; RedMask, GreenMask, BlueMask, AlphaMask: Cardinal; Width, Height: Integer): Integer;
begin
  try
    Result := OKGF_Write_BMP_File(FileName, Pixels, PitchBytes, BitsPerPixel, RedMask, GreenMask, BlueMask, AlphaMask, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Write_BMP_File');
  end;
end;
{ @end $4BABB8 }

{ @routine $4BAC6C Ex_OKGR_AlphaBuf_Draw_RGBA }
procedure Ex_OKGR_AlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_Draw_RGBA');
  end;
end;
{ @end $4BAC6C }

{ @routine $4BAD00 Ex_OKGR_TransAlphaBuf_Draw_RGBA }
procedure Ex_OKGR_TransAlphaBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_TransAlphaBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_Draw_RGBA');
  end;
end;
{ @end $4BAD00 }

{ @routine $4BAD98 Ex_OKGR_AlphaIndexed_Draw_RGBA }
procedure Ex_OKGR_AlphaIndexed_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaIndexed_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_Draw_RGBA');
  end;
end;
{ @end $4BAD98 }

{ @routine $4BAE30 Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA }
procedure Ex_OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_AlphaIndexed_AlphaDraw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDraw_RGBA');
  end;
end;
{ @end $4BAE30 }

{ @routine $4BAECC Ex_OKGR_TransBuf_Draw_RGBA }
procedure Ex_OKGR_TransBuf_Draw_RGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_TransBuf_Draw_RGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_TransBuf_Draw_RGBA');
  end;
end;
{ @end $4BAECC }

{ @routine $4BAF60 Ex_OKGR_TransBuf_DrawClip_WORD }
procedure Ex_OKGR_TransBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransBuf_DrawClip_WORD');
  end;
end;
{ @end $4BAF60 }

{ @routine $4BB004 Ex_OKGR_TransBuf_HADrawClip_16 }
procedure Ex_OKGR_TransBuf_HADrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransBuf_HADrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransBuf_HADrawClip_16');
  end;
end;
{ @end $4BB004 }

{ @routine $4BB0A8 Ex_OKGR_TransBuf_Build_WORD }
function Ex_OKGR_TransBuf_Build_WORD(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer; TransparentColor: Word): Integer;
begin
  try
    Result := OKGR_TransBuf_Build_WORD(Source, Pitch, Width, Height, Dest, TransparentColor);
  except
    raise Exception.Create('Error in OKGR_TransBuf_Build_WORD');
  end;
end;
{ @end $4BB0A8 }

{ @routine $4BB150 Ex_OKGR_TransBuf_BuildFromRGBA_16 }
function Ex_OKGR_TransBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_TransBuf_BuildFromRGBA_16(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_TransBuf_BuildFromRGBA_16');
  end;
end;
{ @end $4BB150 }

{ @routine $4BB1F8 Ex_OKGR_TransAlphaBuf_DrawClip_WORD }
procedure Ex_OKGR_TransAlphaBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_TransAlphaBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_DrawClip_WORD');
  end;
end;
{ @end $4BB1F8 }

{ @routine $4BB2A0 Ex_OKGR_AlphaBuf_DrawClip_16 }
procedure Ex_OKGR_AlphaBuf_DrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaBuf_DrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_DrawClip_16');
  end;
end;
{ @end $4BB2A0 }

{ @routine $4BB340 Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16 }
function Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_TransAlphaBuf_BuildFromRGBA_16(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_TransAlphaBuf_BuildFromRGBA_16');
  end;
end;
{ @end $4BB340 }

{ @routine $4BB3F0 Ex_OKGR_AlphaBuf_BuildFromRGBA }
function Ex_OKGR_AlphaBuf_BuildFromRGBA(Source: Pointer; Pitch, Width, Height: Integer; Dest: Pointer): Integer;
begin
  try
    Result := OKGR_AlphaBuf_BuildFromRGBA(Source, Pitch, Width, Height, Dest);
  except
    raise Exception.Create('Error in OKGR_AlphaBuf_BuildFromRGBA');
  end;
end;
{ @end $4BB3F0 }

{ @routine $4BB498 Ex_OKGR_AlphaSimpleBuf_Draw_16 }
procedure Ex_OKGR_AlphaSimpleBuf_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_AlphaSimpleBuf_Draw_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_AlphaSimpleBuf_Draw_16');
  end;
end;
{ @end $4BB498 }

{ @routine $4BB54C Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16 }
procedure Ex_OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; Palette: PColorRGBA);
begin
  try
    OKGR_AlphaSimpleBufPalAlpha_Draw_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height, Palette);
  except
    raise Exception.Create('Error in OKGR_AlphaSimpleBufPalAlpha_Draw_16');
  end;
end;
{ @end $4BB54C }

{ @routine $4BB60C Ex_OKGR_MaskBuf_DrawClip_DWORD }
procedure Ex_OKGR_MaskBuf_DrawClip_DWORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Cardinal; const Clip: TRect);
begin
  try
    OKGR_MaskBuf_DrawClip_DWORD(Dest, Pitch, X, Y, Source, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_MaskBuf_DrawClip_DWORD');
  end;
end;
{ @end $4BB60C }

{ @routine $4BB6B4 Ex_OKGR_MaskBuf_DrawClip_WORD }
procedure Ex_OKGR_MaskBuf_DrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_MaskBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_MaskBuf_DrawClip_WORD');
  end;
end;
{ @end $4BB6B4 }

{ @routine $4BB758 Ex_OKGR_TransBuf_FillAlphaClip_RGBA }
procedure Ex_OKGR_TransBuf_FillAlphaClip_RGBA(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Cardinal);
begin
  try
    OKGR_TransBuf_FillAlphaClip_RGBA(Dest, Pitch, X, Y, Source, Clip, Color);
  except
    raise Exception.Create('Error in OKGR_TransBuf_FillAlphaClip_RGBA');
  end;
end;
{ @end $4BB758 }

{ @routine $4BB804 Ex_OKGR_TransBuf_FillAlphaClip_16 }
procedure Ex_OKGR_TransBuf_FillAlphaClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Color: Word);
begin
  try
    OKGR_TransBuf_FillAlphaClip_16(Dest, Pitch, X, Y, Source, Clip, Color);
  except
    raise Exception.Create('Error in OKGR_TransBuf_FillAlphaClip_16');
  end;
end;
{ @end $4BB804 }

{ @routine $4BB8AC Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD }
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaIndexed_CopyDrawClip_WORD(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_CopyDrawClip_WORD');
  end;
end;
{ @end $4BB8AC }

{ @routine $4BB958 Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16 }
procedure Ex_OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte);
begin
  try
    OKGR_AlphaIndexed_CopyDrawClip_Alpha_16(Dest, Pitch, X, Y, Source, Clip, Alpha);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_CopyDrawClip_Alpha_16');
  end;
end;
{ @end $4BB958 }

{ @routine $4BBA0C Ex_OKGR_AlphaIndexed_AlphaDrawClip_16 }
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect);
begin
  try
    OKGR_AlphaIndexed_AlphaDrawClip_16(Dest, Pitch, X, Y, Source, Clip);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDrawClip_16');
  end;
end;
{ @end $4BBA0C }

{ @routine $4BBAB4 Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16 }
procedure Ex_OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; const Clip: TRect; Alpha: Byte);
begin
  try
    OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16(Dest, Pitch, X, Y, Source, Clip, Alpha);
  except
    raise Exception.Create('Error in OKGR_AlphaIndexed_AlphaDrawClip_Alpha_16');
  end;
end;
{ @end $4BBAB4 }

{ @routine $4BBB68 Ex_OKGR_RotateBuf_Build }
function Ex_OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY: Integer): Pointer;
begin
  try
    Result := OKGR_RotateBuf_Build(Width, Height, SourceWidth, SourceHeight, CenterX, CenterY);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Build');
  end;
end;
{ @end $4BBB68 }

{ @routine $4BBC0C Ex_OKGR_RotateBuf_Free }
procedure Ex_OKGR_RotateBuf_Free(Buffer: Pointer);
begin
  try
    OKGR_RotateBuf_Free(Buffer);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Free');
  end;
end;
{ @end $4BBC0C }

{ @routine $4BBC88 Ex_OKGR_RotateBuf_Size }
procedure Ex_OKGR_RotateBuf_Size(X, Y: Integer; Angle: Byte; RotationMap: Pointer; var Bounds: TRect);
begin
  try OKGR_RotateBuf_Size(X, Y, Angle, RotationMap, Bounds);
  except raise Exception.Create('Error in OKGR_RotateBuf_Size'); end;
end;
{ @end $4BBC88 }

{ @routine $4BBD20 Ex_OKGR_RotateBuf_Draw_DWORD }
procedure Ex_OKGR_RotateBuf_Draw_DWORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer);
begin
  try
    OKGR_RotateBuf_Draw_DWORD(Dest, DestPitch, Source, SourcePitch, CenterX, CenterY, Angle, RotationMap);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Draw_DWORD');
  end;
end;
{ @end $4BBD20 }

{ @routine $4BBDC8 Ex_OKGR_RotateBuf_Draw_BYTE }
procedure Ex_OKGR_RotateBuf_Draw_BYTE(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Angle: Byte; RotationMap: Pointer);
begin
  try
    OKGR_RotateBuf_Draw_BYTE(Dest, DestPitch, Source, SourcePitch, Width, Height, Angle, RotationMap);
  except
    raise Exception.Create('Error in OKGR_RotateBuf_Draw_BYTE');
  end;
end;
{ @end $4BBDC8 }

{ @routine $4BBE70 Ex_OKGR_RotateBuf_DrawTransClip_WORD }
procedure Ex_OKGR_RotateBuf_DrawTransClip_WORD(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, CenterX, CenterY: Integer; Angle: Byte; RotationMap: Pointer; const Clip: TRect);
begin
  try OKGR_RotateBuf_DrawTransClip_WORD(Dest, DestPitch, Source, SourcePitch, CenterX, CenterY, Angle, RotationMap, Clip);
  except raise Exception.Create('Error in OKGR_RotateBuf_DrawTransClip_WORD'); end;
end;
{ @end $4BBE70 }

{ @routine $4BBF24 Ex_OKGR_LightBuf_Create }
function Ex_OKGR_LightBuf_Create(Width, Height: Integer): Pointer;
begin
  try
    Result := OKGR_LightBuf_Create(Width, Height);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Create');
  end;
end;
{ @end $4BBF24 }

{ @routine $4BBFB0 Ex_OKGR_LightBuf_Destroy }
procedure Ex_OKGR_LightBuf_Destroy(Buffer: Pointer);
begin
  try
    OKGR_LightBuf_Destroy(Buffer);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Destroy');
  end;
end;
{ @end $4BBFB0 }

{ @routine $4BC02C Ex_OKGR_LightBuf_SetSme }
procedure Ex_OKGR_LightBuf_SetSme(Buffer: Pointer; X, Y: Integer);
begin
  try
    OKGR_LightBuf_SetSme(Buffer, X, Y);
  except
    raise Exception.Create('Error in OKGR_LightBuf_SetSme');
  end;
end;
{ @end $4BC02C }

{ @routine $4BC0BC Ex_OKGR_LightBuf_Init }
procedure Ex_OKGR_LightBuf_Init(Buffer: Pointer; Value: Byte);
begin
  try
    OKGR_LightBuf_Init(Buffer, Value);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Init');
  end;
end;
{ @end $4BC0BC }

{ @routine $4BC140 Ex_OKGR_LightBuf_LoadFromPalBuf }
procedure Ex_OKGR_LightBuf_LoadFromPalBuf(Buffer, Source: Pointer; Width, Height, Pitch: Integer; Palette: PColorRGBA);
begin
  try
    OKGR_LightBuf_LoadFromPalBuf(Buffer, Source, Width, Height, Pitch, Palette);
  except
    raise Exception.Create('Error in OKGR_LightBuf_LoadFromPalBuf');
  end;
end;
{ @end $4BC140 }

{ @routine $4BC1E4 Ex_OKGR_LightBuf_Rotate }
procedure Ex_OKGR_LightBuf_Rotate(Dest, Source, RotationMap: Pointer; Angle: Byte);
begin
  try
    OKGR_LightBuf_Rotate(Dest, Source, RotationMap, Angle);
  except
    raise Exception.Create('Error in OKGR_LightBuf_Rotate');
  end;
end;
{ @end $4BC1E4 }

{ @routine $4BC278 Ex_OKGR_Planet2_TemplBuild }
function Ex_OKGR_Planet2_TemplBuild(Source: Pointer; Pitch, Height, TextureWidth, TextureHeight: Integer; var ByteCount: Integer): Pointer;
begin
  try
    Result := OKGR_Planet2_TemplBuild(Source, Pitch, Height, TextureWidth, TextureHeight, ByteCount);
  except
    raise Exception.Create('Error in OKGR_Planet2_TemplBuild');
  end;
end;
{ @end $4BC278 }

{ @routine $4BC320 Ex_OKGR_Planet2_TemplDel }
function Ex_OKGR_Planet2_TemplDel(TemplateData: Pointer): Integer;
begin
  try
    Result := OKGR_Planet2_TemplDel(TemplateData);
  except
    raise Exception.Create('Error in OKGR_Planet2_TemplDel');
  end;
end;
{ @end $4BC320 }

{ @routine $4BC3A4 Ex_OKGR_Planet2_DrawAndLight_32 }
procedure Ex_OKGR_Planet2_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet2_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet2_DrawAndLight_32');
  end;
end;
{ @end $4BC3A4 }

{ @routine $4BC45C Ex_OKGR_Planet2_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet2_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet2_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet2_DrawAndLightClip_16');
  end;
end;
{ @end $4BC45C }

{ @routine $4BC51C Ex_OKGR_Planet3_DrawAndLight_32 }
procedure Ex_OKGR_Planet3_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet3_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet3_DrawAndLight_32');
  end;
end;
{ @end $4BC51C }

{ @routine $4BC5D4 Ex_OKGR_Planet3_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet3_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet3_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet3_DrawAndLightClip_16');
  end;
end;
{ @end $4BC5D4 }

{ @routine $4BC694 Ex_OKGR_Planet4_DrawAndLight_32 }
procedure Ex_OKGR_Planet4_DrawAndLight_32(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer);
begin
  try
    OKGR_Planet4_DrawAndLight_32(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y);
  except
    raise Exception.Create('Error in OKGR_Planet4_DrawAndLight_32');
  end;
end;
{ @end $4BC694 }

{ @routine $4BC74C Ex_OKGR_Planet4_DrawAndLightClip_16 }
procedure Ex_OKGR_Planet4_DrawAndLightClip_16(Dest: Pointer; DestPitch: Integer; TemplateData, Source: Pointer; SourcePitch, WidthMask, MapOffset: Integer; LightBuffer, Palette: Pointer; X, Y: Integer; const Clip: TRect);
begin
  try
    OKGR_Planet4_DrawAndLightClip_16(Dest, DestPitch, TemplateData, Source, SourcePitch, WidthMask, MapOffset, LightBuffer, Palette, X, Y, Clip);
  except
    raise Exception.Create('Error in OKGR_Planet4_DrawAndLightClip_16');
  end;
end;
{ @end $4BC74C }

{ @routine $4BC80C Ex_OKGR_Copy_XY_XY_WORD }
procedure Ex_OKGR_Copy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_Copy_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_Copy_XY_XY_WORD');
  end;
end;
{ @end $4BC80C }

{ @routine $4BC8B8 Ex_OKGR_PalCopy_XY_XY_WORD }
procedure Ex_OKGR_PalCopy_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY: Integer; Palette: Pointer; Width, Height: Integer);
begin
  try
    OKGR_PalCopy_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Palette, Width, Height);
  except
    raise Exception.Create('Error in OKGR_PalCopy_XY_XY_WORD');
  end;
end;
{ @end $4BC8B8 }

{ @routine $4BC96C Ex_OKGR_CopyTrans_XY_XY_WORD }
procedure Ex_OKGR_CopyTrans_XY_XY_WORD(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer; TransparentColor: Word);
begin
  try
    OKGR_CopyTrans_XY_XY_WORD(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height, TransparentColor);
  except
    raise Exception.Create('Error in OKGR_CopyTrans_XY_XY_WORD');
  end;
end;
{ @end $4BC96C }

{ @routine $4BCA20 Ex_OKGR_CopySingleBuf_XY_XY_WORD }
procedure Ex_OKGR_CopySingleBuf_XY_XY_WORD(Pixels: Pointer; Pitch, DestX, DestY, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_CopySingleBuf_XY_XY_WORD(Pixels, Pitch, DestX, DestY, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_CopySingleBuf_XY_XY_WORD');
  end;
end;
{ @end $4BCA20 }

{ @routine $4BCACC Ex_OKGR_HACopy_XY_XY_16 }
procedure Ex_OKGR_HACopy_XY_XY_16(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGR_HACopy_XY_XY_16(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGR_HACopy_XY_XY_16');
  end;
end;
{ @end $4BCACC }

{ @routine $4BCB78 Ex_OKGR_StretchGdi_WORD }
procedure Ex_OKGR_StretchGdi_WORD(Dest: Pointer; Width, Height: Cardinal; Source: Pointer; SourceWidth, SourceHeight: Cardinal);
begin
  try
    OKGR_StretchGdi_WORD(Dest, Width, Height, Source, SourceWidth, SourceHeight);
  except
    raise Exception.Create('Error in OKGR_StretchGdi_WORD');
  end;
end;
{ @end $4BCB78 }

{ @routine $4BCC14 Ex_OKGR_Fill_WORD }
procedure Ex_OKGR_Fill_WORD(Pixels: Pointer; Pitch, Width, Height: Integer; Color: Word);
begin
  try
    OKGR_Fill_WORD(Pixels, Pitch, Width, Height, Color);
  except
    raise Exception.Create('Error in OKGR_Fill_WORD');
  end;
end;
{ @end $4BCC14 }

{ @routine $4BCCA4 Ex_OKGF_ConvertRGBto565 }
procedure Ex_OKGF_ConvertRGBto565(Source, Dest: Pointer; Pitch, Width, Height: Integer);
begin
  try
    OKGF_ConvertRGBto565(Source, Dest, Pitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_ConvertRGBto565');
  end;
end;
{ @end $4BCCA4 }

{ @routine $4BCD3C Ex_OKGF_Convert565toRGB }
procedure Ex_OKGF_Convert565toRGB(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toRGB(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toRGB');
  end;
end;
{ @end $4BCD3C }

{ @routine $4BCDD8 Ex_OKGF_Convert565toBGR }
procedure Ex_OKGF_Convert565toBGR(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toBGR(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toBGR');
  end;
end;
{ @end $4BCDD8 }

{ @routine $4BCE74 Ex_OKGF_Convert565toBGRA }
procedure Ex_OKGF_Convert565toBGRA(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Width, Height: Integer);
begin
  try
    OKGF_Convert565toBGRA(Source, SourcePitch, Dest, DestPitch, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert565toBGRA');
  end;
end;
{ @end $4BCE74 }

{ @routine $4BCF10 Ex_OKGF_Convert_8888to565 }
procedure Ex_OKGF_Convert_8888to565(Dest: Pointer; DestPitch, DestX, DestY: Integer; Source: Pointer; SourcePitch, SourceX, SourceY, Width, Height: Integer);
begin
  try
    OKGF_Convert_8888to565(Dest, DestPitch, DestX, DestY, Source, SourcePitch, SourceX, SourceY, Width, Height);
  except
    raise Exception.Create('Error in OKGF_Convert_8888to565');
  end;
end;
{ @end $4BCF10 }

{ @routine $4BCFBC Ex_OKGR_ShrLight_16 }
procedure Ex_OKGR_ShrLight_16(Pixels: Pointer; Pitch, Width, Height, Shift: Integer);
begin
  try
    OKGR_ShrLight_16(Pixels, Pitch, Width, Height, Shift);
  except
    raise Exception.Create('Error in OKGR_ShrLight_16');
  end;
end;
{ @end $4BCFBC }

{ @routine $4BD050 Ex_OKGR_ShrLightMask_16 }
procedure Ex_OKGR_ShrLightMask_16(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer);
begin
  try
    OKGR_ShrLightMask_16(Dest, DestPitch, Source, SourcePitch, Width, Height);
  except
    raise Exception.Create('Error in OKGR_ShrLightMask_16');
  end;
end;
{ @end $4BD050 }

{ @routine $4BD0EC Ex_OKGR_Light_BYTE }
procedure Ex_OKGR_Light_BYTE(Pixels: Pointer; PixelStride, Pitch, Width, Height: Integer; Alpha: Byte);
begin
  try
    OKGR_Light_BYTE(Pixels, PixelStride, Pitch, Width, Height, Alpha);
  except
    raise Exception.Create('Error in OKGR_Light_BYTE');
  end;
end;
{ @end $4BD0EC }

{ @routine $4BD184 Ex_OKGR_Circle_DrawClip_WORD }
procedure Ex_OKGR_Circle_DrawClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawClip_WORD(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawClip_WORD');
  end;
end;
{ @end $4BD184 }

{ @routine $4BD228 Ex_OKGR_Circle_DrawClip_BYTE }
procedure Ex_OKGR_Circle_DrawClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawClip_BYTE(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawClip_BYTE');
  end;
end;
{ @end $4BD228 }

{ @routine $4BD2CC Ex_OKGR_Circle_DrawFillClip_WORD }
procedure Ex_OKGR_Circle_DrawFillClip_WORD(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawFillClip_WORD(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawFillClip_WORD');
  end;
end;
{ @end $4BD2CC }

{ @routine $4BD374 Ex_OKGR_Circle_DrawFillClip_BYTE }
procedure Ex_OKGR_Circle_DrawFillClip_BYTE(Pixels: Pointer; Pitch, X, Y, Radius: Integer; Color: Byte; const Clip: TRect);
begin
  try
    OKGR_Circle_DrawFillClip_BYTE(Pixels, Pitch, X, Y, Radius, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Circle_DrawFillClip_BYTE');
  end;
end;
{ @end $4BD374 }

{ @routine $4BD41C Ex_OKGR_Line_Clip }
function Ex_OKGR_Line_Clip(var X1, Y1, X2, Y2: Integer; const Clip: TRect): Integer;
begin
  try
    Result := OKGR_Line_Clip(X1, Y1, X2, Y2, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_Clip');
  end;
end;
{ @end $4BD41C }

{ @routine $4BD4B4 Ex_OKGR_LineColor_Clip }
function Ex_OKGR_LineColor_Clip(var X1, Y1: Integer; var Color1: Cardinal; var X2, Y2: Integer; var Color2: Cardinal; const Clip: TRect): Integer;
begin
  try
    Result := OKGR_LineColor_Clip(X1, Y1, Color1, X2, Y2, Color2, Clip);
  except
    raise Exception.Create('Error in Ex_OKGR_LineColor_Clip');
  end;
end;
{ @end $4BD4B4 }

{ @routine $4BD55C Ex_OKGR_Line_Draw_WORD }
procedure Ex_OKGR_Line_Draw_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word);
begin
  try
    OKGR_Line_Draw_WORD(Pixels, Pitch, X1, Y1, X2, Y2, Color);
  except
    raise Exception.Create('Error in OKGR_Line_Draw_WORD');
  end;
end;
{ @end $4BD55C }

{ @routine $4BD5FC Ex_OKGR_Line_DrawClip_WORD }
procedure Ex_OKGR_Line_DrawClip_WORD(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Line_DrawClip_WORD(Pixels, Pitch, X1, Y1, X2, Y2, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_DrawClip_WORD');
  end;
end;
{ @end $4BD5FC }

{ @routine $4BD6A4 Ex_OKGR_Line_CopyToBuf_WORD }
function Ex_OKGR_Line_CopyToBuf_WORD(Dest, Source: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer;
begin
  try
    Result := OKGR_Line_CopyToBuf_WORD(Dest, Source, Pitch, X1, Y1, X2, Y2);
  except
    raise Exception.Create('Error in OKGR_Line_CopyToBuf_WORD');
  end;
end;
{ @end $4BD6A4 }

{ @routine $4BD750 Ex_OKGR_Line_CopyFromBuf_WORD }
function Ex_OKGR_Line_CopyFromBuf_WORD(Source, Dest: Pointer; Pitch, X1, Y1, X2, Y2: Integer): Integer;
begin
  try
    Result := OKGR_Line_CopyFromBuf_WORD(Source, Dest, Pitch, X1, Y1, X2, Y2);
  except
    raise Exception.Create('Error in OKGR_Line_CopyFromBuf_WORD');
  end;
end;
{ @end $4BD750 }

{ @routine $4BD7FC Ex_OKGR_Line_DrawClip_Alpha_16 }
procedure Ex_OKGR_Line_DrawClip_Alpha_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; const Clip: TRect);
begin
  try
    OKGR_Line_DrawClip_Alpha_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Alpha, Clip);
  except
    raise Exception.Create('Error in OKGR_Line_DrawClip_Alpha_16');
  end;
end;
{ @end $4BD7FC }

{ @routine $4BD8AC Ex_OKGR_AnimLine_Draw_16 }
procedure Ex_OKGR_AnimLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect);
begin
  try
    OKGR_AnimLine_Draw_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Phase, Clip);
  except
    raise Exception.Create('Error in OKGR_AnimLine_Draw_16');
  end;
end;
{ @end $4BD8AC }

{ @routine $4BD954 Ex_OKGR_AnimShadowLine_Draw_16 }
procedure Ex_OKGR_AnimShadowLine_Draw_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2: Integer; Color: Word; Phase: Integer; const Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer);
begin
  try
    OKGR_AnimShadowLine_Draw_16(Pixels, Pitch, X1, Y1, X2, Y2, Color, Phase, Clip, ShadowPixels, ShadowPitch);
  except
    raise Exception.Create('Error in OKGR_AnimShadowLine_Draw_16');
  end;
end;
{ @end $4BD954 }

{ @routine $4BDA0C Ex_OKGR_Alpha64Trapezium_16 }
procedure Ex_OKGR_Alpha64Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Alpha64Trapezium_16(Pixels, Pitch, X1, Y1, X2, Y2, X3, X4, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Alpha64Trapezium_16');
  end;
end;
{ @end $4BDA0C }

{ @routine $4BDABC Ex_OKGR_Alpha128Trapezium_16 }
procedure Ex_OKGR_Alpha128Trapezium_16(Pixels: Pointer; Pitch, X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; const Clip: TRect);
begin
  try
    OKGR_Alpha128Trapezium_16(Pixels, Pitch, X1, Y1, X2, Y2, X3, X4, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_Alpha128Trapezium_16');
  end;
end;
{ @end $4BDABC }

{ @routine $4BDB6C Ex_OKGR_FillTrapezium_DWORD }
procedure Ex_OKGR_FillTrapezium_DWORD(Pixels: Pointer; Pitch, X1, X2, Y1, X3, X4, Y2: Integer; Color: Cardinal; const Clip: TRect);
begin
  try
    OKGR_FillTrapezium_DWORD(Pixels, Pitch, X1, X2, Y1, X3, X4, Y2, Color, Clip);
  except
    raise Exception.Create('Error in OKGR_FillTrapezium_DWORD');
  end;
end;
{ @end $4BDB6C }

{ @routine $4BDC1C Ex_OKGF_Rescale }
procedure Ex_OKGF_Rescale(Dest: Pointer; Width, Height, DestPitch: Integer; Source: Pointer; SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter: Integer);
begin
  try
    OKGF_Rescale(Dest, Width, Height, DestPitch, Source, SourceWidth, SourceHeight, SourcePitch, BytesPerPixel, Filter);
  except
    raise Exception.Create('Error in OKGF_Rescale');
  end;
end;
{ @end $4BDC1C }

{ @routine $4BDCC0 Ex_OKGR_F5_DrawRGBA }
procedure Ex_OKGR_F5_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_F5_DrawRGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_F5_DrawRGBA');
  end;
end;
{ @end $4BDCC0 }

{ @routine $4BDD4C Ex_OKGR_F6_DrawRGBA }
procedure Ex_OKGR_F6_DrawRGBA(Dest: Pointer; Pitch: Integer; Source: Pointer);
begin
  try
    OKGR_F6_DrawRGBA(Dest, Pitch, Source);
  except
    raise Exception.Create('Error in OKGR_F6_DrawRGBA');
  end;
end;
{ @end $4BDD4C }

{ @routine $4BDDD8 ApplyProcessAffinity }
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
{ @end $4BDDD8 }

{ @routine $4BDE24 CheckRuntimeWatchdog }
procedure CheckRuntimeWatchdog;
var FaultCode: Pointer;
begin
  if RuntimeWatchdog <> nil then
    if not RuntimeWatchdog.IsRunning then
    begin
      FaultCode := AllocEC(5);
      PCardinal(FaultCode)^ := $89C033;
      // This jump is handwritten in the native routine, unlike the Delphi body.
      asm
        jmp FaultCode
      end;
    end;
end;
{ @end $4BDE24 }

{ @routine $4BDE5C CreateStartupLogFile }
procedure CreateStartupLogFile;
begin
  AssignFile(SessionLog, GetGameUserDirectory + '########.log');
  Rewrite(SessionLog);
  Writeln(SessionLog, 'Start');
  CloseFile(SessionLog);
end;
{ @end $4BDE5C }

{ @routine $4BDF20 InitializePlatformRuntimeAndMainWindow }
procedure InitializePlatformRuntimeAndMainWindow;
var SystemDirectory: WideString; Module: HModule; WindowClass: TWndClassW;
  UnusedLocal: Int64; // Native reserves eight unreferenced local bytes here; original type and purpose unknown.
begin
  SetLength(SystemDirectory, 256);
  SetLength(SystemDirectory, GetSystemDirectoryW(PWideChar(SystemDirectory), 256));
  Module := LoadLibraryW(PWideChar(SystemDirectory + DecodeTextW('\/di34da9..idalal'))); // Decoded: '\d3d9.dll'
  Direct3DCreate9 := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('Drinroekcata33DICAroevaltaen9')))); // Decoded: 'Direct3DCreate9'
  Module := LoadLibraryW(PWideChar(SystemDirectory + DecodeTextW('\/dosdosusnuds.idalal'))); // Decoded: '\dsound.dll'
  DirectSoundCreate := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('DrinroekcataSnowusnud.Carvenaltie')))); // Decoded: 'DirectSoundCreate'
  DirectSoundEnumerate := GetProcAddress(Module, PAnsiChar(AnsiString(DecodeTextW('DrinroekcataSnowusnud.ElnourmieArtastaenAi')))); // Decoded: 'DirectSoundEnumerateA'
  CheckPlatformModules;
  CoInitialize(nil);
  DirectXVersion := Ex_OKGF_DXVersion;
  DebugCommandMessage := RegisterWindowMessage('DebugMsgCommand');
  CopyFile('#ship_c.dbf', '#ship.dbf', False);
  AppendLogLineThreadSafe('Build=2.1.2500 (13 October 2025)');
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
{ @end $4BDF20 }

{ @routine $4BE5A8 LoadLanguageAndPackages }
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
  if SelectedLanguage <> '' then
    if not FileExists('install_' + SelectedLanguage + '.txt') then
    begin
      AppendLogLineThreadSafe('Not installed - ' + SelectedLanguage + ', try to switch to russian');
      SelectedLanguage := 'russian';
    end;
  if SelectedLanguage = '' then SelectedLanguage := 'russian';
  // Keep the else: DCC32 emits the native jump at $4BE74E after the raise.
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
{ @end $4BE5A8 }

{ @routine $4BE95C LoadSelectedModInstallBlocks }
procedure LoadSelectedModInstallBlocks;
var Index: Integer; ModNames, ModPath: WideString; Block: TBlockParEC;
begin
  ModNames := '';
  if FileExists('Mods\ModCFG.txt') then
  begin
    Block := TBlockParEC.Create;
    Block.LoadFromTextFileWithEncodingProbe('Mods\ModCFG.txt', False);
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
  if not SkipModsOnReload then
  begin
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
end;
{ @end $4BE95C }

{ @routine $4BED50 ResetInstalledPackageState }
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
{ @end $4BED50 }

{ @routine $4BEDDC FinalizePlatformRuntime }
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
{ @end $4BEDDC }

{ @routine $4BEE34 HasWow64Support }
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
{ @end $4BEE34 }

{ @routine $4BEF88 ApplyMainWindowGeometry }
procedure ApplyMainWindowGeometry;
var
  Style: Cardinal;
  Width, Height: Integer;
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
      Bounds.Left := ExtractDigitsToIntW(ExtractDelimitedPartW(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('OverrideWindowPosition')), 0, ','));
      Bounds.Top := ExtractDigitsToIntW(ExtractDelimitedPartW(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('OverrideWindowPosition')), 1, ','));
    end
    else
    begin
      Bounds.Left := (DesktopDisplayMode.Width - Cardinal(Width)) div 2;
      Bounds.Top := (DesktopDisplayMode.Height - Cardinal(Height)) div 2;
    end;
    Bounds.Right := Bounds.Left + Width;
    Bounds.Bottom := Bounds.Top + Height;
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
{ @end $4BEF88 }

{ @routine $4BF1C8 ShowAndFocusMainWindow }
procedure ShowAndFocusMainWindow;
begin
  if not Direct3DPresentParameters.Windowed then ShowWindow(MainWindowHandle, SW_SHOWMAXIMIZED)
  else ShowWindow(MainWindowHandle, SW_SHOWNORMAL);
  UpdateWindow(MainWindowHandle);
  SetFocus(MainWindowHandle);
  RedrawWindow(0, nil, 0, $787);
end;
{ @end $4BF1C8 }

{ @routine $4BF3D0 LoadDatConfigAndModOverrides }
procedure LoadDatConfigAndModOverrides;
var ModNames, ModPath: WideString; HasOverrides: Boolean; Block: TBlockParEC;
  Data: TDataEC; Index: Integer;
  // @nested $4BF214 LoadBlockDatConfig
  procedure LoadBlockDatConfig(Root: TBlockParEC; FileName: WideString); // @ida "void __usercall $name(TBlockParEC *Root@<eax>, unsigned __int16 *FileName@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4BF47F,0x4BF534,0x4BF5D3,0x4BF6BC" @addr 0x4BF214 @note "An empty tree produces a log warning, not an exception from this wrapper."
  begin
    Root.LoadFromEncryptedDatFile(FileName);
    if (Root.GetBlockCount <= 0) and (Root.GetParamCount <= 0) then
      AppendLogLineThreadSafe('Warning! <' + FileName + '> is empty!');
  end;

  // @nested $4BF2F8 LoadCacheDatConfig
  procedure LoadCacheDatConfig(Root: TDataEC; FileName: WideString); // @ida "void __usercall $name(TDataEC *Root@<eax>, unsigned __int16 *FileName@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4BF731,0x4BF7E6" @addr 0x4BF2F8
  begin
    Root.LoadFromEncryptedDatFile(FileName);
    if Root.IsEmpty then AppendLogLineThreadSafe('Warning! <' + FileName + '> is empty!');
  end;

begin
  MainDataConfig := TBlockParEC.Create;
  ModNames := '';
  if not SkipModsOnReload and FileExists('Mods\ModCFG.txt') then
  begin
    Block := TBlockParEC.Create;
    Block.LoadFromTextFileWithEncodingProbe('Mods\ModCFG.txt', False);
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
{ @end $4BF3D0 }

{ @routine $4BFA68 FreeDatConfigRoots }
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
{ @end $4BFA68 }

{ @routine $4BFB40 InitializeRuntimeAndSettings }
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

  // @nested $4BFAC0 VerifyStartupModuleChecksum
  procedure VerifyStartupModuleChecksum; // @addr $4BFAC0 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4c157c,0x4c15b6,0x4c15de,0x4c1606,0x4c162e,0x4c1656,0x4c16a3,0x4c16d3,0x4c1703" @note "Nested startup helper; checks the module path at parent-frame -4 and writes the signed integrity marker."
  var
    MarkerOffset: Integer;
  begin
    CCInterface.SetResourceChecksumFailed(False);
    VerifyResourceFileChecksum(ModuleName);
    MarkerOffset := 8;
    if CCInterface.GetResourceChecksumFailed then
      PInteger(PAnsiChar(@StartupChecksumAnchor) - MarkerOffset)^ :=
        RandomIntRange(1000000000, 2000000000)
    else if PInteger(PAnsiChar(@StartupChecksumAnchor) - MarkerOffset)^ <= 0 then
      PInteger(PAnsiChar(@StartupChecksumAnchor) - MarkerOffset)^ :=
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
    AppendLogLineThreadSafe(AnsiString('Wine compatibility mode is set to ''' + Text + ExtraText + ModuleName + ''''))
  else
    AppendLogLineThreadSafe(AnsiString('Operating System=' + Text + ExtraText + ModuleName));
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
  AppendLogLineThreadSafe(AnsiString('Processor=' + ExtraText + ModuleName));
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
  if not FileExists(AnsiString(Text)) then
  begin
    AppendLogTextThreadSafe('Creating cfg.txt ... ');
    CopyFileW('cfg.txt', PWideChar(Text), False);
    UserSettingsConfig.LoadFromTextFileWithEncodingProbe(PWideChar(Text), True);
    UserSettingsConfig.AddParam('CurrentVersion', '2.1.2500');
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
      UserSettingsConfig.AddParam('CurrentVersion', '2.1.2500');
      UserSettingsConfig.SetOrAddParam('HardwareRender', 'True');
      UserSettingsConfig.SetOrAddParam('MultiThread', 'False');
      UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
      AppendLogLineThreadSafe('ok!');
    end
    else if UserSettingsConfig.GetParamByPathOrMarker('CurrentVersion') <> '2.1.2500' then
    begin
      AppendLogTextThreadSafe('Updating cfg.txt version ... ');
      if (UserSettingsConfig.GetParam('CurrentVersion') = '2.1.1800') and
        (UserSettingsConfig.CountParamsByPath('CountFilmSave') > 0) and
        (UserSettingsConfig.GetParamByPathOrMarker('CountFilmSave') = '30') then
        UserSettingsConfig.SetOrAddParam('CountFilmSave', '7');
      UserSettingsConfig.SetOrAddParam('CurrentVersion', '2.1.2500');
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
  if FileExists(AnsiString(PWideChar(Text))) then
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
    SoundVolume := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('SoundVolume'))) / 100;
  if SoundVolume > 1 then SoundVolume := 1;
  if SoundVolume < 0 then SoundVolume := 0;
  if UserSettingsConfig.CountParamsByPath('RobotSoundVolume') > 0 then
    RobotSoundVolume := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('RobotSoundVolume'))) / 100;
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
    MusicVolume := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('MusicVolume'))) / 100;
  if MusicVolume > 1 then MusicVolume := 1;
  if MusicVolume < 0 then MusicVolume := 0;
  if UserSettingsConfig.CountParamsByPath('RobotMusicVolume') > 0 then
    RobotMusicVolume := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('RobotMusicVolume'))) / 100;
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
  ScreenCenterX := Cardinal(GameScreenWidth) shr 1;
  ScreenCenterY := Cardinal(GameScreenHeight) shr 1;
  ShowAndFocusMainWindow;
  if not ShowSystemMouse then ShowCursor(False);
  AppendLogLineThreadSafe(AnsiString('Sound=' + BoolToWideString(SoundEnabled)));
  AppendLogLineThreadSafe(AnsiString('Music=' + BoolToWideString(MusicEnabled)));
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
      Count := ((BufferSize shl 10) shl 10) div (GameScreenWidth * GameScreenHeight * 2) + 1;
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
  if LanguageDataConfig.GetParamByPathOrMarker('BV.BV') <> '2.1.2500' then
  begin
    AppendLogLineThreadSafe('Build version mismatch with Lang.dat!');
    BuildVersionMismatch := True;
  end;
  if MainDataConfig.GetParamByPathOrMarker('BV.BV') <> '2.1.2500' then
  begin
    AppendLogLineThreadSafe('Build version mismatch with Main.dat!');
    BuildVersionMismatch := True;
  end;
  if CacheDataRoot.FindEntry('BV').ChildData.FindEntry('BV').SharedFileRef.FileRef.FileName <> '2.1.2500' then
  begin
    AppendLogLineThreadSafe('Build version mismatch with CacheData.dat!');
    BuildVersionMismatch := True;
  end;
  SavedChecksumFailed := CCInterface.GetResourceChecksumFailed;
  Text := 'll';
  Text := '.d' + Text;
  ModuleName := DecodeTextW('sotoenalm^_^aucah') + Text; // Decoded: 'steam_ach'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('sotoenalm^_^aupki') + Text; // Decoded: 'steam_api'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('zoloimba') + Text; // Decoded: 'zlib'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('MhastorhinxaGrakmae') + Text; // Decoded: 'MatrixGame'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('ookogifa') + Text; // Decoded: 'okgf'
  VerifyStartupModuleChecksum;
  ModuleName := DecodeTextW('xavriadeccomrie') + Text; // Decoded: 'xvidcore'
  VerifyStartupModuleChecksum;
  ExtraText := 'ib';
  ExtraText := 'l' + ExtraText;
  ModuleName := ExtraText + DecodeTextW('osgaga-10a') + Text; // Decoded: 'ogg-0'
  VerifyStartupModuleChecksum;
  ModuleName := ExtraText + DecodeTextW('vrokrablius-->0') + Text; // Decoded: 'vorbis-0'
  VerifyStartupModuleChecksum;
  ModuleName := ExtraText + DecodeTextW('veohrablissufainlae') + Text; // Decoded: 'vorbisfile'
  VerifyStartupModuleChecksum;
  CCInterface.SetResourceChecksumFailed(SavedChecksumFailed);
end;
{ @end $4BFB40 }

{ @routine $4C2694 FinalizeRuntimeAndSettings }
procedure FinalizeRuntimeAndSettings;
begin
  while not (FirstRegisteredCursor = nil) do RemoveCursorUnit(LastRegisteredCursor);
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
{ @end $4C2694 }

{ @routine $4C2788 EnumerateAndSelectDisplayModes }
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
  if (Cardinal(GameScreenWidth) < 1024) or (Cardinal(GameScreenHeight) < 720) then
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
    if Mode.Height >= 720 then
    begin
      ModeKey := SysUtils.IntToHex(Int64(Mode.Width), 6) + SysUtils.IntToHex(Int64(Mode.Height), 6);
      if (Modes.CountParams(ModeKey) <= 0) or
         (SysUtils.StrToInt(AnsiString(ExtractDelimitedPartW(Modes.GetParam(ModeKey), 0, ','))) < Integer(Mode.RefreshRate)) then
        Modes.SetOrAddParam(ModeKey, WideString(SysUtils.IntToStr(Int64(Mode.RefreshRate)) + ',' + SysUtils.IntToStr(Index)));
    end;
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
      SysUtils.StrToInt(AnsiString(ExtractDelimitedPartW(ModeKey, 1, ','))), Mode);
    GameDisplayModes[Index] := Mode;
    RobotDisplayModes[Index] := Mode;
    if (SmallestArea < 0) or (Integer(Mode.Width * Mode.Height) < SmallestArea) then
    begin
      SmallestArea := Mode.Width * Mode.Height;
      SmallestGameDisplayMode := Index;
    end;
    if (Mode.Width = Cardinal(GameScreenWidth)) and (Mode.Height = Cardinal(GameScreenHeight)) then SelectedGameDisplayMode := Index;
    if (Cardinal(RobotSettings.ScreenWidth) = Mode.Width) and (Cardinal(RobotSettings.ScreenHeight) = Mode.Height) then SelectedRobotDisplayMode := Index;
    if Index > 0 then AppendLogTextThreadSafe(', ');
    AppendLogTextThreadSafe(SysUtils.IntToStr(Int64(Mode.Width)) + 'x' + SysUtils.IntToStr(Int64(Mode.Height)));
  end;
  Modes.Free;
  if GameDisplayModeCount = 0 then
  begin
    AppendLogTextThreadSafe('No supported resolutions found!');
    if (Cardinal(GameScreenWidth) < 1024) or (Cardinal(GameScreenHeight) < 720) then
    begin
      AlternateViewportEnabled := True;
      ViewportOffset := Classes.Point(0, 0);
      PresentationWidth := GameScreenWidth;
      PresentationHeight := GameScreenHeight;
      RobotSettings.ScreenWidth := GameScreenWidth;
      RobotSettings.ScreenHeight := GameScreenHeight;
      if ScaleViewportToWindow then
      begin
        if Cardinal(GameScreenWidth) > Cardinal(GameScreenHeight) then
        begin
          GameScreenHeight := 720;
          GameScreenWidth := Cardinal(GameScreenHeight * PresentationWidth) div Cardinal(PresentationHeight);
        end
        else
        begin
          GameScreenWidth := 1024;
          GameScreenHeight := Cardinal(GameScreenWidth * PresentationHeight) div Cardinal(PresentationWidth);
        end;
      end
      else
      begin
        GameScreenWidth := Math.Max(1024, Int64(Cardinal(GameScreenWidth)));
        GameScreenHeight := Math.Max(720, Int64(Cardinal(GameScreenHeight)));
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
  ExtraScreenWidth := GameScreenWidth - 1024;
  ExtraScreenHeight := GameScreenHeight - 768;
  GameScreenRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  PresentationRect := Classes.Rect(0, 0, PresentationWidth, PresentationHeight);
end;
{ @end $4C2788 }

{ @routine $4C3224 ConfigureDefaultRenderState }
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
{ @end $4C3224 }

{ @routine $4C32D4 PreparePresentationParameters }
procedure PreparePresentationParameters;
begin
  PreviousPresentParameters := Direct3DPresentParameters;
  with Direct3DPresentParameters do
  begin
    ZeroMemory(@Direct3DPresentParameters, SizeOf(Direct3DPresentParameters));
    Windowed := WindowedModeRequested and (Cardinal(GameScreenHeight) < DesktopDisplayMode.Height);
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
{ @end $4C32D4 }

{ @routine $4C345C GR_DXInit }
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
  // The native code directly clears x87 exceptions and loads the local control
  // word; this small handwritten sequence has no Pascal intrinsic equivalent.
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
        ExtraScreenWidth := GameScreenWidth - 1024;
        ExtraScreenHeight := GameScreenHeight - 768;
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
        AppendLogLineThreadSafe(' [' + IntToStr(Int64(Cardinal(GameScreenWidth))) + 'x' +
          IntToStr(Int64(Cardinal(GameScreenHeight))) + ']');
    end
    else
    begin
      if AlternateViewportEnabled then
        AppendLogTextThreadSafe(IntToStr(Int64(Cardinal(PresentationWidth))) + 'x' +
          IntToStr(Int64(Cardinal(PresentationHeight))) + ' [');
      AppendLogTextThreadSafe(IntToStr(Int64(Cardinal(GameScreenWidth))) + 'x' + IntToStr(Int64(Cardinal(GameScreenHeight))));
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
    Angle := Index * (3.1415926 / 180);
    CircleCos[Index] := Cos(Angle);
    CircleSin[Index] := Sin(Angle);
  end;
  for Index := Low(LineAlphaTable) to High(LineAlphaTable) do
    LineAlphaTable[Index] := Trunc(Cos(Index / 180 * 3.14159265354) * 127 + 128);
  PendingPointCapacity := 1024;
  SetLength(PendingPoints, PendingPointCapacity);
end;
{ @end $4C345C }

{ @routine $4C4720 GR_DXReset }
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
{ @end $4C4720 }

{ @routine $4C48A8 FreeScreenRenderBuffers }
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
{ @end $4C48A8 }

{ @routine $4C4900 ApplyGammaRamp }
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
{ @end $4C4900 }

{ @routine $4C4C04 GR_WinMessage }
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
{ @end $4C4C04 }

{ @routine $4C4F50 MainWindowProc }
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
        TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).UpdateActionCursor(False)
      else if (CurrentScreenId = screenShip) or (CurrentScreenId = screenStarMap) then
        TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).UpdateActionCursor(True);
      if (TMessageLoopGI(RegisteredScreens[Ord(screenShip)]) <> nil) and
         (TMessageLoopGI(RegisteredScreens[Ord(screenShip)]).GetActionParentLoop <> nil) and
         (TMessageLoopGI(RegisteredScreens[Ord(screenShip)]).GetActionParentLoop = TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])) then
        TMessageLoopGI(RegisteredScreens[Ord(screenShip)]).UpdateActionCursor(True);
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
{ @end $4C4F50 }

{ @routine $4C5278 BeginFramePresentation }
function BeginFramePresentation: Boolean;
begin
  Inc(PresentationDepth);
  Result := True;
end;
{ @end $4C5278 }

{ @routine $4C528C EndFramePresentation }
procedure EndFramePresentation;
var Tick: Cardinal;
begin
  if PresentationDepth > 0 then
  begin
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
end;
{ @end $4C528C }

{ @routine $4C52EC PresentScreenBuffer }
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
      DrawTexture(ScreenRenderBuffer.GetTexture, 0, 0, 255, $FFFFFF, nil, False, False)
    else if ScaleViewportToWindow then
      DrawTextureSized(ScreenRenderBuffer.GetTexture, 0, 0, PresentationWidth, PresentationHeight, 255, $FFFFFF, nil, False, False)
    else
      DrawTexture(ScreenRenderBuffer.GetTexture, ViewportOffset.X, ViewportOffset.Y, 255, $FFFFFF, nil, False, False);
    Direct3DDevice.EndScene;
    Direct3DDevice.Present(nil, nil, 0, nil);
  end;
end;
{ @end $4C52EC }

{ @routine $4C5450 DrawOffscreenTexture }
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
       ((Height < ViewHeight) and (OffscreenFillViewport <> False)) then
    begin
      Width := Round((Desc.Width / Desc.Height) * ViewHeight);
      Height := ViewHeight;
    end;
    X := Integer(ViewWidth - Width) div 2;
    Y := Integer(ViewHeight - Height) div 2;
    Direct3DDevice.Clear(0, nil, D3DCLEAR_TARGET, 0, 1, 0);
    if HardwareRenderingEnabled then
      DrawTextureSized(OffscreenTexture, X, Y, Width, Height, 255, $FFFFFF, @GameScreenRect, False, False)
    else
    begin
      Direct3DDevice.BeginScene;
      DrawTextureSized(OffscreenTexture, X, Y, Width, Height, 255, $FFFFFF, @GameScreenRect, False, False);
      Direct3DDevice.EndScene;
      Direct3DDevice.Present(nil, nil, 0, nil);
    end;
  end;
end;
{ @end $4C5450 }

{ @routine $4C5634 CaptureScreenBackground }
procedure CaptureScreenBackground(ApplyEffects: Boolean; UnusedOption: Byte);
begin
  AuxRenderBuffer.LoadFromScreen(UnusedOption);
  if ApplyEffects then
  begin
    if BackgroundShade then AuxRenderBuffer.AdjustBrightness(-50);
    if BackgroundGrayscale then AuxRenderBuffer.ConvertToGrayscale;
  end;
end;
{ @end $4C5634 }

{ @routine $4C5684 CaptureSavePreview }
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
{ @end $4C5684 }

{ @routine $4C5730 FreeSavePreviewBuffers }
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
{ @end $4C5730 }

{ @routine $4C5768 CopyBgraToRgb24 }
procedure CopyBgraToRgb24(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer);
var X, Y: Integer;
begin
  Y := 0;
  while Y < Height do
  begin
    X := 0;
    while X < Width do
    begin
      PByte(AddPointerOffset(Dest, X * 3))^ := PByte(AddPointerOffset(Source, X * 4 + 2))^;
      PByte(AddPointerOffset(Dest, X * 3 + 1))^ := PByte(AddPointerOffset(Source, X * 4 + 1))^;
      PByte(AddPointerOffset(Dest, X * 3 + 2))^ := PByte(AddPointerOffset(Source, X * 4))^;
      Inc(X);
    end;
    Dest := AddPointerOffset(Dest, DestPitch);
    Source := AddPointerOffset(Source, SourcePitch);
    Inc(Y);
  end;
end;
{ @end $4C5768 }

{ @routine $4C586C CaptureRecordingFrame }
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
{ @end $4C586C }

{ @routine $4C58EC FlushRecordingFrames }
procedure FlushRecordingFrames;
var
  SearchHandle: THandle;
  FirstFrameNumber, Index: Integer;
  Directory: AnsiString;
  Frame: TGraphBufGR;
  FileName: AnsiString;
  FindData: TWin32FindDataA;
begin
  if RecordingFrameCount >= 1 then
  begin
    Directory := GetCurrentDir;
    SetCurrentDir('Film');
    FirstFrameNumber := -1;
    SearchHandle := Windows.FindFirstFile('*.*', FindData);
    // Native code scans without testing for INVALID_HANDLE_VALUE.
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> FILE_ATTRIBUTE_DIRECTORY then
        FirstFrameNumber := Max(FirstFrameNumber, ExtractDigitsToIntW(WideString(AnsiString(FindData.cFileName))));
    until not Boolean(Windows.FindNextFile(SearchHandle, FindData));
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
end;
{ @end $4C58EC }

{ @routine $4C5B94 DrawTransparentBuffer16 }
procedure DrawTransparentBuffer16(Dest: Pointer; Pitch, X, Y: Integer; Source: Pointer; Clip: TRect; HalfAlpha: Boolean);
var InclusiveClip: TRect;
begin
  InclusiveClip.Left := Clip.Left; InclusiveClip.Top := Clip.Top;
  InclusiveClip.Right := Clip.Right - 1; InclusiveClip.Bottom := Clip.Bottom - 1;
  if HalfAlpha then Ex_OKGR_TransBuf_HADrawClip_16(Dest, Pitch, X, Y, Source, InclusiveClip)
  else Ex_OKGR_TransBuf_DrawClip_WORD(Dest, Pitch, X, Y, Source, InclusiveClip);
end;
{ @end $4C5B94 }

{ @routine $4C5C10 CopyPalettedBuffer16Clipped }
procedure CopyPalettedBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source, Palette: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect);
var SourceX, SourceY: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Width - 1 < Clip.Left) or (Y + Height - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C5C10 }

{ @routine $4C5D18 CopyGraphBuffer16Clipped }
procedure CopyGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; HalfAlpha, UnusedOption: Boolean);
var SourceX, SourceY, Width, Height: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Source.Width + X - 1 < Clip.Left) or (Source.Height + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C5D18 }

{ @routine $4C5E74 CopyBuffer16Clipped }
procedure CopyBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect; UnusedOption: Boolean);
var SourceX, SourceY: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Width - 1 < Clip.Left) or (Y + Height - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C5E74 }

{ @routine $4C5F78 CopyTransparentGraphBuffer16Clipped }
procedure CopyTransparentGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect; TransparentColor: Word);
var SourceX, SourceY, Width, Height: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Source.Width + X - 1 < Clip.Left) or (Source.Height + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C5F78 }

{ @routine $4C60A0 DrawAlphaGraphBuffer16Clipped }
procedure DrawAlphaGraphBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufGR; Clip: TRect);
var SourceX, SourceY, Width, Height: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (Source.Width + X - 1 < Clip.Left) or (Source.Height + Y - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C60A0 }

{ @routine $4C61C4 DrawAlphaBuffer16Clipped }
procedure DrawAlphaBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: Pointer; SourcePitch, Width, Height: Integer; Clip: TRect);
var SourceX, SourceY: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or (X + Width - 1 < Clip.Left) or (Y + Height - 1 < Clip.Top) then Exit;
  SourceX := 0; SourceY := 0;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C61C4 }

{ @routine $4C62C8 DrawPaletteAlphaBuffer16Clipped }
procedure DrawPaletteAlphaBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect);
var SourceX, SourceY, Width, Height: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
    (X + 0 + Source.Width - 1 < Clip.Left) or (Y + 0 + Source.Height - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
{ @end $4C62C8 }

{ @routine $4C63F0 ExpandPaletteToBgra }
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
{ @end $4C63F0 }

{ @routine $4C64D4 BlendPaletteBuffer16Clipped }
procedure BlendPaletteBuffer16Clipped(Dest: Pointer; DestPitch, X, Y: Integer; Source: TGraphBufPalGR; Clip: TRect);
var
  SourcePixels: Pointer;
  Width: Integer;
  Palette, MulTable: Pointer;
  ColumnCount, SourceSkip, DestSkip, Height: Integer;
  SourceX, SourceY: Integer;
begin
  if (X >= Clip.Right) or (Y >= Clip.Bottom) or
     (X + Source.Width - 1 < Clip.Left) or (Y + Source.Height - 1 < Clip.Top) then Exit;
  SourceX := 0;
  SourceY := 0;
  Width := Source.Width;
  Height := Source.Height;
  if X + Width - 1 >= Clip.Right then Dec(Width, X + Width - 1 - (Clip.Right - 1));
  if Y + Height - 1 >= Clip.Bottom then Dec(Height, Y + Height - 1 - (Clip.Bottom - 1));
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
  SourcePixels := Pointer(SourceY * Source.PitchBytes + PAnsiChar(Source.Pixels) + SourceX);
  Dest := Pointer(Y * DestPitch + PAnsiChar(Dest) + X * 2);
  SourceSkip := Source.PitchBytes - Width;
  DestSkip := DestPitch - Width * 2;
  MulTable := Ex_OKGF_MulTable256x256;
  Palette := Source.Palette;
  ColumnCount := Width;
  { Native handwritten loops blend palette alpha into RGB565 or RGB555. }
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
{ @end $4C64D4 }

{ @routine $4C6820 DrawGradientLine16Clipped }
procedure DrawGradientLine16Clipped(Pixels: Pointer; Pitch, X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; Clip: TRect);
begin
  if Ex_OKGR_LineColor_Clip(X1, Y1, Color1, X2, Y2, Color2, Clip) <> 0 then
    LineRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      X1, Y1, Color1, X2, Y2, Color2);
end;
{ @end $4C6820 }

{ @routine $4C689C IsVirtualKeyDown }
function IsVirtualKeyDown(Key: Integer): Boolean;
begin
  Result := GetAsyncKeyState(Key) and $8000 = $8000;
end;
{ @end $4C689C }

{ @routine $4C68C8 LookupLocalizedTextByKey }
function LookupLocalizedTextByKey(const Path: WideString): WideString;
begin
  Result := LanguageDataConfig.GetParamByPathOrMarker(Path);
end;
{ @end $4C68C8 }

{ @routine $4C68E8 LookupLocalizedTextOrEmpty }
function LookupLocalizedTextOrEmpty(const Path: WideString): WideString;
begin
  if LanguageDataConfig.CountParamsByPath(Path) > 0 then
    Result := LanguageDataConfig.GetParamByPathOrMarker(Path)
  else Result := '';
end;
{ @end $4C68E8 }

{ @routine $4C6924 GiResourceVariant }
function GiResourceVariant: Integer;
begin
  Result := 2;
end;
{ @end $4C6924 }

{ @routine $4C6938 GiResourceSuffix }
function GiResourceSuffix: WideString;
begin
  Result := '2';
end;
{ @end $4C6938 }

{ @routine $4C6958 GiScalePixels }
function GiScalePixels(Value: Integer): Integer;
begin
  Result := Value;
end;
{ @end $4C6958 }

{ @routine $4C6970 GiScalePixelsEx }
function GiScalePixelsEx(Value, AlternateValue: Integer): Integer;
begin
  Result := Value;
end;
{ @end $4C6970 }

{ @routine $4C698C AppendLogLineThreadSafe }
procedure AppendLogLineThreadSafe(const Text: AnsiString);
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  Append(SessionLog);
  Writeln(SessionLog, Text);
  CloseFile(SessionLog);
  SessionLogLock.Leave;
end;
{ @end $4C698C }

{ @routine $4C69EC AppendLogTextThreadSafe }
procedure AppendLogTextThreadSafe(const Text: AnsiString);
begin
  if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
  SessionLogLock.Enter;
  Append(SessionLog);
  Write(SessionLog, Text);
  CloseFile(SessionLog);
  SessionLogLock.Leave;
end;
{ @end $4C69EC }

{ @routine $4C6A4C AppendDebugLogLine }
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
{ @end $4C6A4C }

{ @routine $4C6AF8 AppendOptionalDebugLogLine }
procedure AppendOptionalDebugLogLine(const Text: AnsiString);
var Log: TextFile;
begin
  if FileExists('#####add.log') then
  begin
    if SessionLogLock = nil then SessionLogLock := TCriticalSection.Create;
    SessionLogLock.Enter;
    AssignFile(Log, '#####add.log');
    Append(Log);
    Writeln(Log, Text);
    CloseFile(Log);
    SessionLogLock.Leave;
  end;
end;
{ @end $4C6AF8 }

{ @routine $4C6B98 WriteTextFileThreadSafe }
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
{ @end $4C6B98 }

{ @routine $4C6C50 IsInstallFeatureEnabled }
function IsInstallFeatureEnabled(const Path: WideString): Boolean;
begin
  if InstallConfig.CountParamsByPath(Path) < 1 then Result := False
  else Result := ParseEnabledNameGI(InstallConfig.GetParamByPathOrMarker(Path));
end;
{ @end $4C6C50 }

{ @routine $4C6CC4 AddCursorUnit }
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
{ @end $4C6CC4 }

{ @routine $4C6D28 RemoveCursorUnit }
procedure RemoveCursorUnit(Cursor: TCursorUnit);
begin
  if Cursor.Prev <> nil then Cursor.Prev.Next := Cursor.Next;
  if Cursor.Next <> nil then Cursor.Next.Prev := Cursor.Prev;
  if LastRegisteredCursor = Cursor then LastRegisteredCursor := Cursor.Prev;
  if FirstRegisteredCursor = Cursor then FirstRegisteredCursor := Cursor.Next;
  Cursor.Free;
end;
{ @end $4C6D28 }

{ @routine $4C6D94 FindCursorByName }
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
{ @end $4C6D94 }

{ @routine $4C6E08 PostMouseMoveMessage }
procedure PostMouseMoveMessage;
var
  Point: TPoint;
begin
  GetCursorPos(Point);
  ScreenToClient(MainWindowHandle, Point);
  PostMessage(MainWindowHandle, WM_MOUSEMOVE, 0, Word(Point.X) or (Word(Point.Y) shl 16));
end;
{ @end $4C6E08 }

{ @routine $4C6E4C MeasureCpuClockMHz }
function MeasureCpuClockMHz: Double;
var TickLow, TickHigh: Cardinal; ProcessPriority: Cardinal; ThreadPriority: Integer;
begin
  ProcessPriority := GetPriorityClass(GetCurrentProcess);
  ThreadPriority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  try
    SysUtils.Sleep(10);
    // The native timestamp reads and 64-bit subtraction are handwritten asm.
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
{ @end $4C6E4C }

{ @routine $4C6F28 ReadRegistryText }
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
{ @end $4C6F28 }

{ @routine $4C7070 ReadRegistryInteger }
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
{ @end $4C7070 }

{ @routine $4C7178 RaiseWideMessage }
procedure RaiseWideMessage(const Message: WideString);
begin
  raise Exception.Create(Message);
end;
{ @end $4C7178 }

{ @routine $4C71D4 Direct3DErrorText }
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
{ @end $4C71D4 }

{ @routine $4C77C8 FormatUnixDateTime }
function FormatUnixDateTime(Value: Cardinal): WideString;
var
  DateValue: TDateTime;
begin
  DateValue := UnixToDateTime(Value);
  Result := DateTimeToStr(DateValue);
end;
{ @end $4C77C8 }

{ @routine $4C7834 LoadInformationColorTags }
procedure LoadInformationColorTags;
var Block: TBlockParEC;
begin
  InfoNameColorTag := '<color=57,239,255>';
  InfoHullSeriesColorTag := '<color=82,166,255>';
  if GameDataConfig.CountBlocks('StyleColor') > 0 then
  begin
    Block := GameDataConfig.GetBlock('StyleColor');
    if Block.CountParamsByPath('InfoNameColor') > 0 then
      InfoNameColorTag := '<color=' + Block.GetParamByPath('InfoNameColor') + '>';
    if Block.CountParamsByPath('InfoHullSeriesColor') > 0 then
      InfoHullSeriesColorTag := '<color=' + Block.GetParamByPath('InfoHullSeriesColor') + '>';
  end;
end;
{ @end $4C7834 }

{ @routine $4C7A10 GetStyleColorGI }
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
{ @end $4C7A10 }

{ @routine $4C7B64 GetStyleColorTagGI }
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
{ @end $4C7B64 }

{ @routine $4C7CC0 GetGameUserDirectory }
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
{ @end $4C7CC0 }

{ @routine $4C7E6C ComputeMachineFingerprintCRC }
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
{ @end $4C7E6C }

{ @routine $4C8004 GetClipboardWideText }
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
{ @end $4C8004 }

{ @routine $4C8084 SetClipboardWideText }
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
{ @end $4C8084 }

{ @routine $4C8290 LogPresentationParameters }
procedure LogPresentationParameters;
var CurrentValue, PreviousValue: Cardinal; Text: WideString;
  // @nested $4C8124 LogPresentationField
  procedure LogPresentationField(Name: WideString); // @addr $4C8124 @ida "void __usercall $name(unsigned __int16 *Name@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4C82D0,0x4C82EC,0x4C8308,0x4C8324,0x4C8340,0x4C835C,0x4C8378,0x4C8394,0x4C83CA,0x4C8400,0x4C841C,0x4C8438,0x4C8454,0x4C8470"
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
{ @end $4C8290 }

end.
