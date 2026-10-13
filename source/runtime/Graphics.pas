unit Graphics;

interface

uses System, Classes;

type
  TCanvas = class;

  TSharedImage = class(TObject) // @size 0x08
  public
    RefCount: Integer; // @offset 0x04
    procedure Reference; // @addr 0x0042643C
    procedure Release; // @note "Accepts nil; releases the handle and frees Self when the count reaches zero."
  end;

  TGraphic = class(TInterfacedPersistent) // @size 0x28
  public
    Modified: Boolean; // @offset 0x20
    PaletteModified: Boolean; // @offset 0x22
    procedure DefineProperties(Filer: TFiler); virtual; // @slot 0x4
    procedure Changed(Sender: TObject); virtual; // @slot 0x10
    function Equals(Graphic: TGraphic): Boolean; virtual; // @slot 0x18
    procedure SetTransparent(Value: Boolean); virtual; // @slot 0x3C
  public

    constructor Create; virtual; // @slot 0x48
    procedure LoadFromFile(FileName: AnsiString); virtual; // @slot 0x4C
    procedure Progress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: AnsiString);
    procedure SaveToFile(FileName: AnsiString); virtual; // @slot 0x50 @note "Creates or truncates FileName."
    procedure SetSize(AWidth, AHeight: Integer); virtual; // @slot 0x64
  end;

  TBitmap = class(TGraphic) // @partial
  public
    constructor Create; override; // @slot 0x48
    function GetScanLine(Row: Integer): Pointer; // @note "Borrowed DIB scanline; validates Row and accounts for bottom-up storage."
  public
    destructor Destroy;
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure CopyImage(AHandle: Cardinal; APalette: Cardinal; DIB: TDIBSection); // @ida "void __userpurge $name(TBitmap *Self@<eax>, unsigned __int32 AHandle@<edx>, unsigned __int32 APalette@<ecx>, TDIBSection *DIB@<^0>);"
    procedure Changing(Sender: TObject);
    procedure Dormant;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @slot 0x14
    procedure FreeImage;
    procedure GetEmpty; // @nameonly
    function GetCanvas: TCanvas;
    procedure ReadData(Stream: TStream); virtual; // @slot 0x30
    function GetHandleType: TBitmapHandleType;
    function GetMonochrome: Boolean;
    function GetPixelFormat: TPixelFormat;
    function GetTransparentColor: TColor;
    procedure DIBNeeded;
    procedure HandleNeeded;
    procedure MaskHandleNeeded;
    procedure PaletteNeeded;
    procedure SetHeight(Value: Integer); virtual; // @slot 0x34
    procedure SetPalette(Value: Cardinal); virtual; // @slot 0x38
    procedure NewImage(NewHandle: Cardinal; NewPalette: Cardinal; const NewDIB: TDIBSection; OS2Format: Boolean; RLEStream: TStream); // @ida "void __userpurge $name(TBitmap *Self@<eax>, unsigned __int32 NewHandle@<edx>, unsigned __int32 NewPalette@<ecx>, TDIBSection *NewDIB@<^8>, bool OS2Format@<^4>, TStream *RLEStream@<^0>);"
    procedure SetWidth(Value: Integer); virtual; // @slot 0x40
    procedure ReadDIB(Stream: TStream; ImageSize: Cardinal; bmf: PBitmapFileHeader);
    procedure ReadStream(Stream: TStream; Size: Longint);
    procedure SetHandle(Value: Cardinal);
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x54
    procedure LoadFromClipboardFormat(AFormat: Word; AData: Cardinal; APalette: Cardinal); virtual; // @slot 0x5C
    procedure SetMonochrome(Value: Boolean);
    procedure SaveToClipboardFormat(var Format: Word; var Data: Cardinal; var APalette: Cardinal); virtual; // @slot 0x60
    procedure SetPixelFormat(Value: TPixelFormat);
    function GetHandle: Cardinal; virtual; // @slot 0x68
    procedure WriteStream(Stream: TStream; WriteSize: Boolean);
    procedure SetHandleType(Value: TBitmapHandleType); virtual; // @slot 0x70
    procedure SetSize(AWidth, AHeight: Integer); override; // @slot 0x64
  end;

type
  TResourceManager = class(TObject) // @size 0x24
  public
    constructor Create(AResDataSize: Word);
    destructor Destroy;
    function AllocResource(ResData: Pointer): PResource;
    procedure FreeResource(Resource: PResource);
    procedure ChangeResource(GraphicsObject: TGraphicsObject; ResData: Pointer);
    procedure AssignResource(GraphicsObject: TGraphicsObject; AResource: PResource);
  end;

  TResource = record;

  PResource = ^TResource;

  TGraphicsObject = class(TPersistent) // @size 0x18
  public
    procedure Changed;
  end;

  TFontData = record;

  TFont = class(TGraphicsObject) // @size 0x24
  public
    constructor Create;
    procedure Changed;
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure GetData(var FontData: TFontData);
    procedure SetColor(const Value: TColor);
    function GetHandle: Cardinal;
    procedure SetHandle(const Value: Cardinal);
    function GetName: TFontName;
    procedure SetName(const Value: TFontName);
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
  end;

  TColor = Integer;

  TFontName = AnsiString;

  TPen = class(TGraphicsObject) // @size 0x1C
  public
    constructor Create;
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure GetData(var PenData: TPenData);
    function GetHandle: HPen;
    procedure SetMode(Value: TPenMode);
  end;

  TPenData = record;

  TPenMode = (pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy, pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge, pmNotMerge, pmMask, pmNotMask, pmXor, pmNotXor); // @size 0x1

  TBrush = class(TGraphicsObject) // @size 0x18
  public
    constructor Create;
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure GetData(var BrushData: TBrushData);
    procedure SetBitmap(Value: TBitmap);
    function GetHandle: Cardinal;
  end;

  TBrushData = record;

  TCanvasStates = (csHandleValid, csFontValid, csPenValid, csBrushValid); // @size 0x1

  TCanvasState = set of TCanvasStates; // @size 0x1

  TIconRec = record;

  TMetafileHeader = record;

  TProgressStage = (psStarting, psRunning, psEnding); // @size 0x1

  TFileFormatsList = class(TList) // @size 0x10
  public
    constructor Create;
    destructor Destroy;
    procedure Add(const Ext, Desc: AnsiString; DescID: Integer; AClass: TGraphicClass);
    function FindClassName(const ClassName: AnsiString): TGraphicClass;
    procedure Remove(AClass: TGraphicClass);
  end;

  TGraphicClass = class of TGraphic;

  TClipboardFormats = class(TObject) // @size 0xC
  public
    procedure Remove(AClass: TGraphicClass);
  end;

  TPicture = class(TInterfacedPersistent) // @size 0x2C
  public
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure ForceType(GraphicType: TGraphicClass);
    procedure SetGraphic(Value: TGraphic);
    procedure LoadFromStream(Stream: TStream);
    procedure DefineProperties(Filer: TFiler); virtual; // @slot 0x4
    procedure Changed(Sender: TObject);
    procedure Progress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: AnsiString);
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    class procedure RegisterFileFormat(const AExtension, ADescription: AnsiString; AGraphicClass: TGraphicClass);
    class procedure UnregisterGraphicClass(AClass: TGraphicClass);
  end;

  TMetafileImage = class(TSharedImage) // @size 0x24
  public
    destructor Destroy;
  end;

  TMetafile = class(TGraphic) // @size 0x30
  public
    constructor Create; override; // @slot 0x48
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @slot 0x14
    function GetHeight: Integer; virtual; // @slot 0x20
    function GetPalette: Cardinal; virtual; // @slot 0x24
    function GetWidth: Integer; virtual; // @slot 0x2C
    procedure ReadData(Stream: TStream); virtual; // @slot 0x30
    procedure NewImage;
    procedure SetHeight(Value: Integer); virtual; // @slot 0x34
    procedure ReadEMFStream(Stream: TStream);
    procedure ReadWMFStream(Stream: TStream; Length: Longint);
    procedure SaveToFile(const Filename: AnsiString); override; // @slot 0x50
    procedure SetWidth(Value: Integer); virtual; // @slot 0x40
    procedure WriteData(Stream: TStream); virtual; // @slot 0x44
    procedure SetMMHeight(Value: Integer);
    procedure SetMMWidth(Value: Integer);
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x54
    function TestEMF(Stream: TStream): Boolean;
    procedure UniqueImage;
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x58
    procedure WriteEMFStream(Stream: TStream);
    procedure WriteWMFStream(Stream: TStream);
    procedure LoadFromClipboardFormat(AFormat: Word; AData: Cardinal; APalette: Cardinal); virtual; // @slot 0x5C
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: Cardinal; var APalette: Cardinal); virtual; // @slot 0x60
    procedure SetSize(AWidth, AHeight: Integer); override; // @slot 0x64
  end;

  TBitmapCanvas = class(TCanvas) // @size 0x64
  public
    constructor Create(ABitmap: TBitmap);
    procedure FreeContext;
    procedure CreateHandle; virtual; // @slot 0x14
  end;

  TBitmapImage = class(TSharedImage) // @size 0x74
  public
    destructor Destroy;
    procedure FreeHandle; virtual; // @slot 0x0
  end;

  TBitmapHandleType = (bmDIB, bmDDB); // @size 0x1

  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom); // @size 0x1

  TIconImage = class(TSharedImage) // @size 0x18
  public
    procedure FreeHandle; virtual; // @slot 0x0
  end;

  TIcon = class(TGraphic) // @size 0x34
  public
    constructor Create; override; // @slot 0x48
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @slot 0x14
    function GetEmpty: Boolean; virtual; // @slot 0x1C
    procedure HandleNeeded;
    procedure ImageNeeded;
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x54
    procedure NewImage(NewHandle: Cardinal; NewImage: TMemoryStream);
    procedure SetHandle(Value: Cardinal);
    procedure SetSize(AWidth, AHeight: Integer); override; // @slot 0x64
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x58
  end;

  TPatternManager = class(TObject) // @size 0x20
  public
    constructor Create;
    destructor Destroy;
    function AllocPattern(BkColor, FgColor: TColorRef): PPattern;
    function CreateBitmap(BkColor, FgColor: TColor): TBitmap;
    procedure FreePatterns;
  end;

  TPattern = record;

  PPattern = ^TPattern;

  TCanvas = class(TPersistent) // @size 0x58
  public
    constructor Create;
    destructor Destroy;
    procedure CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect);
    procedure Draw(X, Y: Integer; Graphic: TGraphic);
    procedure FillRect(const Rect: TRect);
    procedure LineTo(X, Y: Integer);
    procedure Lock;
    procedure MoveTo(X, Y: Integer);
    procedure StretchDraw(const Rect: TRect; Graphic: TGraphic);
    procedure TextExtent; // @nameonly
    function TextWidth(const Text: AnsiString): Integer;
    function TextHeight(const Text: AnsiString): Integer;
    function TryLock: Boolean;
    procedure Unlock;
    function GetPenPos: TPoint;
    procedure SetPenPos(Value: TPoint);
    function GetPixel(X, Y: Integer): TColor;
    procedure SetPixel(X, Y: Integer; Value: TColor);
    function GetHandle: Cardinal;
    procedure DeselectHandles;
    procedure SetHandle(Value: Cardinal);
    procedure RequiredState(ReqState: TCanvasState); // @ida "void __usercall $name(TCanvas *Self@<eax>, TCanvasState *ReqState@<edx>);"
    procedure Changed; virtual; // @slot 0xC
    procedure Changing; virtual; // @slot 0x10
    procedure CreateFont;
    procedure CreatePen;
    procedure CreateBrush;
    procedure FontChanged(AFont: TObject);
    procedure PenChanged(APen: TObject);
    procedure BrushChanged(ABrush: TObject);
  end;

function GetHashCode(Buffer: Pointer; Count: Integer): Word;

procedure ClearColor(ResMan: TResourceManager); // @nameonly

procedure PaletteChanged;

function GetFontData(Font: Cardinal): TFontData; // @ida "void __usercall $name(unsigned __int32 Font@<eax>, TFontData *Result@<edx>);"

function IsDefaultFont(const FontData: TFontData): Boolean; // @ida "bool __usercall $name@<al>(TFontData *FontData@<eax>);"

procedure GDIError;

function DupBits(Src: Cardinal; Size: TPoint; Mono: Boolean): Cardinal;

function GetDInColors(BitCount: Word): Integer;

function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;

function TransparentStretchBlt(DstDC: Cardinal; DstX, DstY, DstW, DstH: Integer; SrcDC: Cardinal; SrcX, SrcY, SrcW, SrcH: Integer; MaskDC: Cardinal; MaskX, MaskY: Integer): Boolean;

procedure RGBTripleToQuad(ColorTable: Pointer);

procedure RGBQuadToTriple(ColorTable: Pointer; var ColorCount: Integer);

procedure ByteSwapColors(Colors: Pointer; Count: Integer);

function CreateSystemPalette(const Entries: array of TColor): Cardinal; // @nameonly

function SystemPaletteOverride(var Pal: TMaxLogPalette): Boolean;

function PaletteFromDIBColorTable(DIBHandle: Cardinal; ColorTable: Pointer; ColorCount: Integer): Cardinal;

function PaletteToDIBColorTable(Pal: Cardinal; var ColorTable: array of TRGBQuad): Integer; // @nameonly

procedure TwoBitsFromDIB(var BI: TBitmapInfoHeader; var XorBits, AndBits: Cardinal; const IconSize: TPoint);

function BetterSize(const Old, New: TIconRec): Boolean; // @nameonly

procedure ReadIcon(Stream: TStream; var Icon: Cardinal; ImageCount: Integer; StartOffset: Integer; const RequestedSize: TPoint; var IconSize: TPoint);

function ComputeAldusChecksum(var WMF: TMetafileHeader): Word;

procedure InitializeBitmapInfoHeader(Bitmap: Cardinal; var BI: TBitmapInfoHeader; Colors: Integer);

procedure InternalGetDIBSizes(Bitmap: Cardinal; var InfoHeaderSize: DWord; var ImageSize: DWord; Colors: Integer);

function InternalGetDIB(Bitmap: Cardinal; Palette: Cardinal; BitmapInfo: Pointer; Bits: Pointer; Colors: Integer): Boolean;

function GetDIB(Bitmap: Cardinal; Palette: Cardinal; BitmapInfo: Pointer; Bits: Pointer): Boolean;

procedure WriteIcon(Stream: TStream; Icon: Cardinal; WriteLength: Boolean);

procedure DoWrite_4243CC; // @nameonly

procedure DoWrite_425238; // @nameonly

procedure DeselectBitmap(AHandle: Cardinal);

procedure UpdateDIBColorTable(DIBHandle: Cardinal; Pal: Cardinal; const DIB: TDIBSection); // @ida "void __usercall $name(unsigned __int32 DIBHandle@<eax>, unsigned __int32 Pal@<edx>, TDIBSection *DIB@<ecx>);"

procedure FixupBitFields(var DIB: TDIBSection);

function CopyBitmap(Handle: Cardinal; OldPalette, NewPalette: Cardinal; var DIB: TDIBSection; Canvas: TCanvas): Cardinal;

function CopyPalette(Palette: Cardinal): Cardinal;

function CopyBitmapAsMask(Handle: Cardinal; Palette: Cardinal; TransparentColor: TColorRef): Cardinal;

procedure InitScreenLogPixels;

procedure GetDefFontCharSet; // @nameonly

procedure InitDefFontData;

function AllocPatternBitmap(BkColor, FgColor: TColor): TBitmap;

procedure FinalizeGraphics; // @nameonly

implementation
end.
