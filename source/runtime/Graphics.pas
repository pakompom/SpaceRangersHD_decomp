unit Graphics;
// Unit bracket (inferred): .text 0x00420038..0x00429519; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008762B4..0x008762B4; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System, Classes;

type
  TCanvas = class;

  TSharedImage = class(TObject) // @size 0x08
  public
    RefCount: Integer; // @offset 0x04
    procedure Reference; // @addr 0x42643C
    procedure Release; // @note "Accepts nil; releases the handle and frees Self when the count reaches zero."
  end;

  TGraphic = class(TInterfacedPersistent) // @size 0x28
  public
    Modified: Boolean; // @offset 0x20
    PaletteModified: Boolean; // @offset 0x22

    constructor Create; virtual; // @slot 0x48
    procedure Changed(Sender: TObject); virtual; // @slot 0x10
    procedure LoadFromFile(FileName: AnsiString); virtual; // @slot 0x4C
    procedure SaveToFile(FileName: AnsiString); virtual; // @slot 0x50 @note "Creates or truncates FileName."
  public
    procedure DefineProperties(Filer: TFiler); virtual; // @note "DCC32 MAP Graphics.TGraphic.DefineProperties. Source vcl/Graphics.pas:3665." @slot 0x4
    function Equals(Graphic: TGraphic): Boolean; virtual; // @note "DCC32 MAP Graphics.TGraphic.Equals. Source vcl/Graphics.pas:3680." @slot 0x18
    procedure Progress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: AnsiString); // @note "DCC32 MAP Graphics.TGraphic.Progress. Source vcl/Graphics.pas:3731."
    procedure SetSize(AWidth, AHeight: Integer); virtual; // @note "DCC32 MAP Graphics.TGraphic.SetSize. Source vcl/Graphics.pas:3766." @slot 0x64
    procedure SetTransparent(Value: Boolean); virtual; // @note "DCC32 MAP Graphics.TGraphic.SetTransparent. Source vcl/Graphics.pas:3772." @slot 0x3C
  end;

  TBitmap = class(TGraphic) // @partial
  public
    constructor Create; override; // @slot 0x48
    function GetScanLine(Row: Integer): Pointer; // @note "Borrowed DIB scanline; validates Row and accounts for bottom-up storage."
  public
    destructor Destroy; // @note "DCC32 MAP Graphics.TBitmap.Destroy. Source vcl/Graphics.pas:5653."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TBitmap.Assign. Source vcl/Graphics.pas:5661." @slot 0x8
    procedure CopyImage(AHandle: Cardinal; APalette: Cardinal; DIB: TDIBSection); // @ida "void __userpurge $name(TBitmap *Self@<eax>, unsigned __int32 AHandle@<edx>, unsigned __int32 APalette@<ecx>, TDIBSection *DIB@<^0>);" @note "DCC32 MAP Graphics.TBitmap.CopyImage. Source vcl/Graphics.pas:5693."
    procedure Changing(Sender: TObject); // @note "DCC32 MAP Graphics.TBitmap.Changing. Source vcl/Graphics.pas:5718."
    procedure Dormant; // @note "DCC32 MAP Graphics.TBitmap.Dormant. Source vcl/Graphics.pas:5732."
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @note "DCC32 MAP Graphics.TBitmap.Draw. Source vcl/Graphics.pas:5747." @slot 0x14
    procedure FreeImage; // @note "DCC32 MAP Graphics.TBitmap.FreeImage. Source vcl/Graphics.pas:5817."
    procedure GetEmpty; // @nameonly @note "DCC32 MAP Graphics.TBitmap.GetEmpty. Source vcl/Graphics.pas:5840. Prototype pending: Graphics.pas:2:18: expected ':', got ';'."
    function GetCanvas: TCanvas; // @note "DCC32 MAP Graphics.TBitmap.GetCanvas. Source vcl/Graphics.pas:5846."
    function GetHandle: Cardinal; virtual; // @note "DCC32 MAP Graphics.TBitmap.GetHandle. Source vcl/Graphics.pas:5864." @slot 0x68
    function GetHandleType: TBitmapHandleType; // @note "DCC32 MAP Graphics.TBitmap.GetHandleType. Source vcl/Graphics.pas:5877."
    function GetMonochrome: Boolean; // @note "DCC32 MAP Graphics.TBitmap.GetMonochrome. Source vcl/Graphics.pas:5905."
    function GetPixelFormat: TPixelFormat; // @note "DCC32 MAP Graphics.TBitmap.GetPixelFormat. Source vcl/Graphics.pas:5917."
    function GetTransparentColor: TColor; // @note "DCC32 MAP Graphics.TBitmap.GetTransparentColor. Source vcl/Graphics.pas:5953."
    procedure DIBNeeded; // @note "DCC32 MAP Graphics.TBitmap.DIBNeeded. Source vcl/Graphics.pas:5971."
    procedure HandleNeeded; // @note "DCC32 MAP Graphics.TBitmap.HandleNeeded. Source vcl/Graphics.pas:5998."
    procedure MaskHandleNeeded; // @note "DCC32 MAP Graphics.TBitmap.MaskHandleNeeded. Source vcl/Graphics.pas:6046."
    procedure PaletteNeeded; // @note "DCC32 MAP Graphics.TBitmap.PaletteNeeded. Source vcl/Graphics.pas:6069."
    procedure LoadFromClipboardFormat(AFormat: Word; AData: Cardinal; APalette: Cardinal); virtual; // @note "DCC32 MAP Graphics.TBitmap.LoadFromClipboardFormat. Source vcl/Graphics.pas:6089." @slot 0x5C
    procedure LoadFromStream(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TBitmap.LoadFromStream. Source vcl/Graphics.pas:6106." @slot 0x54
    procedure NewImage(NewHandle: Cardinal; NewPalette: Cardinal; const NewDIB: TDIBSection; OS2Format: Boolean; RLEStream: TStream); // @ida "void __userpurge $name(TBitmap *Self@<eax>, unsigned __int32 NewHandle@<edx>, unsigned __int32 NewPalette@<ecx>, TDIBSection *NewDIB@<^8>, bool OS2Format@<^4>, TStream *RLEStream@<^0>);" @note "DCC32 MAP Graphics.TBitmap.NewImage. Source vcl/Graphics.pas:6139."
    procedure ReadData(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TBitmap.ReadData. Source vcl/Graphics.pas:6169." @slot 0x30
    procedure ReadDIB(Stream: TStream; ImageSize: Cardinal; bmf: PBitmapFileHeader); // @note "DCC32 MAP Graphics.TBitmap.ReadDIB. Source vcl/Graphics.pas:6177."
    procedure ReadStream(Stream: TStream; Size: Longint); // @note "DCC32 MAP Graphics.TBitmap.ReadStream. Source vcl/Graphics.pas:6368."
    procedure SetHandle(Value: Cardinal); // @note "DCC32 MAP Graphics.TBitmap.SetHandle. Source vcl/Graphics.pas:6387."
    procedure SetHandleType(Value: TBitmapHandleType); virtual; // @note "DCC32 MAP Graphics.TBitmap.SetHandleType. Source vcl/Graphics.pas:6419." @slot 0x70
    procedure SetHeight(Value: Integer); virtual; // @note "DCC32 MAP Graphics.TBitmap.SetHeight. Source vcl/Graphics.pas:6476." @slot 0x34
    procedure SetMonochrome(Value: Boolean); // @note "DCC32 MAP Graphics.TBitmap.SetMonochrome. Source vcl/Graphics.pas:6492."
    procedure SetPalette(Value: Cardinal); virtual; // @note "DCC32 MAP Graphics.TBitmap.SetPalette. Source vcl/Graphics.pas:6514." @slot 0x38
    procedure SetPixelFormat(Value: TPixelFormat); // @note "DCC32 MAP Graphics.TBitmap.SetPixelFormat. Source vcl/Graphics.pas:6546."
    procedure SetWidth(Value: Integer); virtual; // @note "DCC32 MAP Graphics.TBitmap.SetWidth. Source vcl/Graphics.pas:6632." @slot 0x40
    procedure WriteStream(Stream: TStream; WriteSize: Boolean); // @note "DCC32 MAP Graphics.TBitmap.WriteStream. Source vcl/Graphics.pas:6642."
    procedure SaveToClipboardFormat(var Format: Word; var Data: Cardinal; var APalette: Cardinal); virtual; // @note "DCC32 MAP Graphics.TBitmap.SaveToClipboardFormat. Source vcl/Graphics.pas:6776." @slot 0x60
    procedure SetSize(AWidth, AHeight: Integer); override; // @note "DCC32 MAP Graphics.TBitmap.SetSize. Source vcl/Graphics.pas:6798." @slot 0x64
  end;

type
  TResourceManager = class(TObject) // @size 0x24
  public
    constructor Create(AResDataSize: Word); // @note "DCC32 MAP Graphics.TResourceManager.Create. Source vcl/Graphics.pas:1283."
    destructor Destroy; // @note "DCC32 MAP Graphics.TResourceManager.Destroy. Source vcl/Graphics.pas:1289."
    function AllocResource(ResData: Pointer): PResource; // @note "DCC32 MAP Graphics.TResourceManager.AllocResource. Source vcl/Graphics.pas:1304."
    procedure FreeResource(Resource: PResource); // @note "DCC32 MAP Graphics.TResourceManager.FreeResource. Source vcl/Graphics.pas:1334."
    procedure ChangeResource(GraphicsObject: TGraphicsObject; ResData: Pointer); // @note "DCC32 MAP Graphics.TResourceManager.ChangeResource. Source vcl/Graphics.pas:1369."
    procedure AssignResource(GraphicsObject: TGraphicsObject; AResource: PResource); // @note "DCC32 MAP Graphics.TResourceManager.AssignResource. Source vcl/Graphics.pas:1389."
  end;

  TResource = record;

  PResource = ^TResource;

  TGraphicsObject = class(TPersistent) // @size 0x18
  public
    procedure Changed; // @note "DCC32 MAP Graphics.TGraphicsObject.Changed. Source vcl/Graphics.pas:1568."
  end;

  TFontData = record;

  TFont = class(TGraphicsObject) // @size 0x24
  public
    constructor Create; // @note "DCC32 MAP Graphics.TFont.Create. Source vcl/Graphics.pas:1661."
    procedure Changed; // @note "DCC32 MAP Graphics.TFont.Changed. Source vcl/Graphics.pas:1674."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TFont.Assign. Source vcl/Graphics.pas:1680." @slot 0x8
    procedure GetData(var FontData: TFontData); // @note "DCC32 MAP Graphics.TFont.GetData. Source vcl/Graphics.pas:1703."
    procedure SetColor(const Value: TColor); // @note "DCC32 MAP Graphics.TFont.SetColor. Source vcl/Graphics.pas:1719."
    function GetHandle: Cardinal; // @note "DCC32 MAP Graphics.TFont.GetHandle. Source vcl/Graphics.pas:1734."
    procedure SetHandle(const Value: Cardinal); // @note "DCC32 MAP Graphics.TFont.SetHandle. Source vcl/Graphics.pas:1794."
    function GetName: TFontName; // @note "DCC32 MAP Graphics.TFont.GetName. Source vcl/Graphics.pas:1813."
    procedure SetName(const Value: TFontName); // @note "DCC32 MAP Graphics.TFont.SetName. Source vcl/Graphics.pas:1818."
    function GetSize: Integer; // @note "DCC32 MAP Graphics.TFont.GetSize. Source vcl/Graphics.pas:1831."
    procedure SetSize(const Value: Integer); // @note "DCC32 MAP Graphics.TFont.SetSize. Source vcl/Graphics.pas:1836."
  end;

  TColor = Integer;

  TFontName = AnsiString;

  TPen = class(TGraphicsObject) // @size 0x1C
  public
    constructor Create; // @note "DCC32 MAP Graphics.TPen.Create. Source vcl/Graphics.pas:1966."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TPen.Assign. Source vcl/Graphics.pas:1977." @slot 0x8
    procedure GetData(var PenData: TPenData); // @note "DCC32 MAP Graphics.TPen.GetData. Source vcl/Graphics.pas:1998."
    function GetHandle: HPen; // @note "DCC32 MAP Graphics.TPen.GetHandle. Source vcl/Graphics.pas:2028."
    procedure SetMode(Value: TPenMode); // @note "DCC32 MAP Graphics.TPen.SetMode. Source vcl/Graphics.pas:2063."
  end;

  TPenData = record;

  TPenMode = (pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy, pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge, pmNotMerge, pmMask, pmNotMask, pmXor, pmNotXor); // @size 0x1

  TBrush = class(TGraphicsObject) // @size 0x18
  public
    constructor Create; // @note "DCC32 MAP Graphics.TBrush.Create. Source vcl/Graphics.pas:2144."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TBrush.Assign. Source vcl/Graphics.pas:2154." @slot 0x8
    procedure GetData(var BrushData: TBrushData); // @note "DCC32 MAP Graphics.TBrush.GetData. Source vcl/Graphics.pas:2174."
    procedure SetBitmap(Value: TBitmap); // @note "DCC32 MAP Graphics.TBrush.SetBitmap. Source vcl/Graphics.pas:2196."
    function GetHandle: Cardinal; // @note "DCC32 MAP Graphics.TBrush.GetHandle. Source vcl/Graphics.pas:2220."
  end;

  TBrushData = record;

  TCanvasStates = (csHandleValid, csFontValid, csPenValid, csBrushValid); // @size 0x1

  TCanvasState = set of TCanvasStates; // @size 0x1

  TIconRec = record;

  TMetafileHeader = record;

  TProgressStage = (psStarting, psRunning, psEnding); // @size 0x1

  TFileFormatsList = class(TList) // @size 0x10
  public
    constructor Create; // @note "DCC32 MAP Graphics.TFileFormatsList.Create. Source vcl/Graphics.pas:3809."
    destructor Destroy; // @note "DCC32 MAP Graphics.TFileFormatsList.Destroy. Source vcl/Graphics.pas:3818."
    procedure Add(const Ext, Desc: AnsiString; DescID: Integer; AClass: TGraphicClass); // @note "DCC32 MAP Graphics.TFileFormatsList.Add. Source vcl/Graphics.pas:3827."
    function FindClassName(const ClassName: AnsiString): TGraphicClass; // @note "DCC32 MAP Graphics.TFileFormatsList.FindClassName. Source vcl/Graphics.pas:3858."
    procedure Remove(AClass: TGraphicClass); // @note "DCC32 MAP Graphics.TFileFormatsList.Remove. Source vcl/Graphics.pas:3870."
  end;

  TGraphicClass = class of TGraphic;

  TClipboardFormats = class(TObject) // @size 0xC
  public
    procedure Remove(AClass: TGraphicClass); // @note "DCC32 MAP Graphics.TClipboardFormats.Remove. Source vcl/Graphics.pas:3971."
  end;

  TPicture = class(TInterfacedPersistent) // @size 0x2C
  public
    procedure AssignTo(Dest: TPersistent); virtual; // @note "DCC32 MAP Graphics.TPicture.AssignTo. Source vcl/Graphics.pas:4012." @slot 0x0
    procedure ForceType(GraphicType: TGraphicClass); // @note "DCC32 MAP Graphics.TPicture.ForceType. Source vcl/Graphics.pas:4020."
    procedure SetGraphic(Value: TGraphic); // @note "DCC32 MAP Graphics.TPicture.SetGraphic. Source vcl/Graphics.pas:4066."
    procedure LoadFromStream(Stream: TStream); // @note "DCC32 MAP Graphics.TPicture.LoadFromStream. Source vcl/Graphics.pas:4158."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TPicture.Assign. Source vcl/Graphics.pas:4168." @slot 0x8
    class procedure RegisterFileFormat(const AExtension, ADescription: AnsiString; AGraphicClass: TGraphicClass); // @note "DCC32 MAP Graphics.TPicture.RegisterFileFormat. Source vcl/Graphics.pas:4180."
    class procedure UnregisterGraphicClass(AClass: TGraphicClass); // @note "DCC32 MAP Graphics.TPicture.UnregisterGraphicClass. Source vcl/Graphics.pas:4198."
    procedure Changed(Sender: TObject); // @note "DCC32 MAP Graphics.TPicture.Changed. Source vcl/Graphics.pas:4204."
    procedure Progress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: AnsiString); // @note "DCC32 MAP Graphics.TPicture.Progress. Source vcl/Graphics.pas:4210."
    procedure ReadData(Stream: TStream); // @note "DCC32 MAP Graphics.TPicture.ReadData. Source vcl/Graphics.pas:4216."
    procedure WriteData(Stream: TStream); // @note "DCC32 MAP Graphics.TPicture.WriteData. Source vcl/Graphics.pas:4246."
    procedure DefineProperties(Filer: TFiler); virtual; // @note "DCC32 MAP Graphics.TPicture.DefineProperties. Source vcl/Graphics.pas:4261." @slot 0x4
  end;

  TMetafileImage = class(TSharedImage) // @size 0x24
  public
    destructor Destroy; // @note "DCC32 MAP Graphics.TMetafileImage.Destroy. Source vcl/Graphics.pas:4299."
  end;

  TMetafile = class(TGraphic) // @size 0x30
  public
    constructor Create; override; // @note "DCC32 MAP Graphics.TMetafile.Create. Source vcl/Graphics.pas:4369." @slot 0x48
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TMetafile.Assign. Source vcl/Graphics.pas:4383." @slot 0x8
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @note "DCC32 MAP Graphics.TMetafile.Draw. Source vcl/Graphics.pas:4418." @slot 0x14
    function GetHeight: Integer; virtual; // @note "DCC32 MAP Graphics.TMetafile.GetHeight. Source vcl/Graphics.pas:4487." @slot 0x20
    function GetPalette: Cardinal; virtual; // @note "DCC32 MAP Graphics.TMetafile.GetPalette. Source vcl/Graphics.pas:4525." @slot 0x24
    function GetWidth: Integer; virtual; // @note "DCC32 MAP Graphics.TMetafile.GetWidth. Source vcl/Graphics.pas:4548." @slot 0x2C
    procedure LoadFromStream(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TMetafile.LoadFromStream. Source vcl/Graphics.pas:4568." @slot 0x54
    procedure NewImage; // @note "DCC32 MAP Graphics.TMetafile.NewImage. Source vcl/Graphics.pas:4578."
    procedure ReadData(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TMetafile.ReadData. Source vcl/Graphics.pas:4585." @slot 0x30
    procedure ReadEMFStream(Stream: TStream); // @note "DCC32 MAP Graphics.TMetafile.ReadEMFStream. Source vcl/Graphics.pas:4601."
    procedure ReadWMFStream(Stream: TStream; Length: Longint); // @note "DCC32 MAP Graphics.TMetafile.ReadWMFStream. Source vcl/Graphics.pas:4629."
    procedure SaveToFile(const Filename: AnsiString); override; // @note "DCC32 MAP Graphics.TMetafile.SaveToFile. Source vcl/Graphics.pas:4678." @slot 0x50
    procedure SaveToStream(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TMetafile.SaveToStream. Source vcl/Graphics.pas:4692." @slot 0x58
    procedure SetHeight(Value: Integer); virtual; // @note "DCC32 MAP Graphics.TMetafile.SetHeight. Source vcl/Graphics.pas:4725." @slot 0x34
    procedure SetMMHeight(Value: Integer); // @note "DCC32 MAP Graphics.TMetafile.SetMMHeight. Source vcl/Graphics.pas:4756."
    procedure SetMMWidth(Value: Integer); // @note "DCC32 MAP Graphics.TMetafile.SetMMWidth. Source vcl/Graphics.pas:4768."
    procedure SetWidth(Value: Integer); virtual; // @note "DCC32 MAP Graphics.TMetafile.SetWidth. Source vcl/Graphics.pas:4786." @slot 0x40
    function TestEMF(Stream: TStream): Boolean; // @note "DCC32 MAP Graphics.TMetafile.TestEMF. Source vcl/Graphics.pas:4806."
    procedure UniqueImage; // @note "DCC32 MAP Graphics.TMetafile.UniqueImage. Source vcl/Graphics.pas:4821."
    procedure WriteData(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TMetafile.WriteData. Source vcl/Graphics.pas:4844." @slot 0x44
    procedure WriteEMFStream(Stream: TStream); // @note "DCC32 MAP Graphics.TMetafile.WriteEMFStream. Source vcl/Graphics.pas:4864."
    procedure WriteWMFStream(Stream: TStream); // @note "DCC32 MAP Graphics.TMetafile.WriteWMFStream. Source vcl/Graphics.pas:4881."
    procedure LoadFromClipboardFormat(AFormat: Word; AData: Cardinal; APalette: Cardinal); virtual; // @note "DCC32 MAP Graphics.TMetafile.LoadFromClipboardFormat. Source vcl/Graphics.pas:4924." @slot 0x5C
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: Cardinal; var APalette: Cardinal); virtual; // @note "DCC32 MAP Graphics.TMetafile.SaveToClipboardFormat. Source vcl/Graphics.pas:4948." @slot 0x60
    procedure SetSize(AWidth, AHeight: Integer); override; // @note "DCC32 MAP Graphics.TMetafile.SetSize. Source vcl/Graphics.pas:4964." @slot 0x64
  end;

  TBitmapCanvas = class(TCanvas) // @size 0x64
  public
    constructor Create(ABitmap: TBitmap); // @note "DCC32 MAP Graphics.TBitmapCanvas.Create. Source vcl/Graphics.pas:5056."
    procedure FreeContext; // @note "DCC32 MAP Graphics.TBitmapCanvas.FreeContext. Source vcl/Graphics.pas:5068."
    procedure CreateHandle; virtual; // @note "DCC32 MAP Graphics.TBitmapCanvas.CreateHandle. Source vcl/Graphics.pas:5088." @slot 0x14
  end;

  TBitmapImage = class(TSharedImage) // @size 0x74
  public
    destructor Destroy; // @note "DCC32 MAP Graphics.TBitmapImage.Destroy. Source vcl/Graphics.pas:5141."
    procedure FreeHandle; virtual; // @note "DCC32 MAP Graphics.TBitmapImage.FreeHandle. Source vcl/Graphics.pas:5155." @slot 0x0
  end;

  TBitmapHandleType = (bmDIB, bmDDB); // @size 0x1

  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom); // @size 0x1

  TIconImage = class(TSharedImage) // @size 0x18
  public
    procedure FreeHandle; virtual; // @note "DCC32 MAP Graphics.TIconImage.FreeHandle. Source vcl/Graphics.pas:6829." @slot 0x0
  end;

  TIcon = class(TGraphic) // @size 0x34
  public
    constructor Create; override; // @note "DCC32 MAP Graphics.TIcon.Create. Source vcl/Graphics.pas:6837." @slot 0x48
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Graphics.TIcon.Assign. Source vcl/Graphics.pas:6851." @slot 0x8
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); virtual; // @note "DCC32 MAP Graphics.TIcon.Draw. Source vcl/Graphics.pas:6868." @slot 0x14
    function GetEmpty: Boolean; virtual; // @note "DCC32 MAP Graphics.TIcon.GetEmpty. Source vcl/Graphics.pas:6877." @slot 0x1C
    procedure HandleNeeded; // @note "DCC32 MAP Graphics.TIcon.HandleNeeded. Source vcl/Graphics.pas:6908."
    procedure ImageNeeded; // @note "DCC32 MAP Graphics.TIcon.ImageNeeded. Source vcl/Graphics.pas:6930."
    procedure LoadFromStream(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TIcon.LoadFromStream. Source vcl/Graphics.pas:6968." @slot 0x54
    procedure NewImage(NewHandle: Cardinal; NewImage: TMemoryStream); // @note "DCC32 MAP Graphics.TIcon.NewImage. Source vcl/Graphics.pas:6987."
    procedure SetHandle(Value: Cardinal); // @note "DCC32 MAP Graphics.TIcon.SetHandle. Source vcl/Graphics.pas:7015."
    procedure SetSize(AWidth, AHeight: Integer); override; // @note "DCC32 MAP Graphics.TIcon.SetSize. Source vcl/Graphics.pas:7043." @slot 0x64
    procedure SaveToStream(Stream: TStream); virtual; // @note "DCC32 MAP Graphics.TIcon.SaveToStream. Source vcl/Graphics.pas:7068." @slot 0x58
  end;

  TPatternManager = class(TObject) // @size 0x20
  public
    constructor Create; // @note "DCC32 MAP Graphics.TPatternManager.Create. Source vcl/Graphics.pas:7195."
    destructor Destroy; // @note "DCC32 MAP Graphics.TPatternManager.Destroy. Source vcl/Graphics.pas:7200."
    function AllocPattern(BkColor, FgColor: TColorRef): PPattern; // @note "DCC32 MAP Graphics.TPatternManager.AllocPattern. Source vcl/Graphics.pas:7216."
    function CreateBitmap(BkColor, FgColor: TColor): TBitmap; // @note "DCC32 MAP Graphics.TPatternManager.CreateBitmap. Source vcl/Graphics.pas:7241."
    procedure FreePatterns; // @note "DCC32 MAP Graphics.TPatternManager.FreePatterns. Source vcl/Graphics.pas:7269."
  end;

  TPattern = record;

  PPattern = ^TPattern;

  TCanvas = class(TPersistent) // @size 0x58
  public
    constructor Create; // @note "DCC32 MAP Graphics.TCanvas.Create. Source vcl/Graphics.pas:2305."
    destructor Destroy; // @note "DCC32 MAP Graphics.TCanvas.Destroy. Source vcl/Graphics.pas:2323."
    procedure CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect); // @note "DCC32 MAP Graphics.TCanvas.CopyRect. Source vcl/Graphics.pas:2428."
    procedure Draw(X, Y: Integer; Graphic: TGraphic); // @note "DCC32 MAP Graphics.TCanvas.Draw. Source vcl/Graphics.pas:2440."
    procedure FillRect(const Rect: TRect); // @note "DCC32 MAP Graphics.TCanvas.FillRect. Source vcl/Graphics.pas:2474."
    procedure LineTo(X, Y: Integer); // @note "DCC32 MAP Graphics.TCanvas.LineTo. Source vcl/Graphics.pas:2507."
    procedure Lock; // @note "DCC32 MAP Graphics.TCanvas.Lock. Source vcl/Graphics.pas:2515."
    procedure MoveTo(X, Y: Integer); // @note "DCC32 MAP Graphics.TCanvas.MoveTo. Source vcl/Graphics.pas:2523."
    procedure StretchDraw(const Rect: TRect; Graphic: TGraphic); // @note "DCC32 MAP Graphics.TCanvas.StretchDraw. Source vcl/Graphics.pas:2599."
    procedure TextExtent; // @nameonly @note "DCC32 MAP Graphics.TCanvas.TextExtent. Source vcl/Graphics.pas:2649. Prototype pending: ambiguous source type: TSize."
    function TextWidth(const Text: AnsiString): Integer; // @note "DCC32 MAP Graphics.TCanvas.TextWidth. Source vcl/Graphics.pas:2657."
    function TextHeight(const Text: AnsiString): Integer; // @note "DCC32 MAP Graphics.TCanvas.TextHeight. Source vcl/Graphics.pas:2662."
    function TryLock: Boolean; // @note "DCC32 MAP Graphics.TCanvas.TryLock. Source vcl/Graphics.pas:2667."
    procedure Unlock; // @note "DCC32 MAP Graphics.TCanvas.Unlock. Source vcl/Graphics.pas:2678."
    function GetPenPos: TPoint; // @note "DCC32 MAP Graphics.TCanvas.GetPenPos. Source vcl/Graphics.pas:2701."
    procedure SetPenPos(Value: TPoint); // @note "DCC32 MAP Graphics.TCanvas.SetPenPos. Source vcl/Graphics.pas:2707."
    function GetPixel(X, Y: Integer): TColor; // @note "DCC32 MAP Graphics.TCanvas.GetPixel. Source vcl/Graphics.pas:2712."
    procedure SetPixel(X, Y: Integer; Value: TColor); // @note "DCC32 MAP Graphics.TCanvas.SetPixel. Source vcl/Graphics.pas:2718."
    function GetHandle: Cardinal; // @note "DCC32 MAP Graphics.TCanvas.GetHandle. Source vcl/Graphics.pas:2732."
    procedure DeselectHandles; // @note "DCC32 MAP Graphics.TCanvas.DeselectHandles. Source vcl/Graphics.pas:2739."
    procedure SetHandle(Value: Cardinal); // @note "DCC32 MAP Graphics.TCanvas.SetHandle. Source vcl/Graphics.pas:2754."
    procedure RequiredState(ReqState: TCanvasState); // @ida "void __usercall $name(TCanvas *Self@<eax>, TCanvasState *ReqState@<edx>);" @note "DCC32 MAP Graphics.TCanvas.RequiredState. Source vcl/Graphics.pas:2774."
    procedure Changing; virtual; // @note "DCC32 MAP Graphics.TCanvas.Changing. Source vcl/Graphics.pas:2794." @slot 0x10
    procedure Changed; virtual; // @note "DCC32 MAP Graphics.TCanvas.Changed. Source vcl/Graphics.pas:2799." @slot 0xC
    procedure CreateFont; // @note "DCC32 MAP Graphics.TCanvas.CreateFont. Source vcl/Graphics.pas:2804."
    procedure CreatePen; // @note "DCC32 MAP Graphics.TCanvas.CreatePen. Source vcl/Graphics.pas:2810."
    procedure CreateBrush; // @note "DCC32 MAP Graphics.TCanvas.CreateBrush. Source vcl/Graphics.pas:2821."
    procedure FontChanged(AFont: TObject); // @note "DCC32 MAP Graphics.TCanvas.FontChanged. Source vcl/Graphics.pas:2839."
    procedure PenChanged(APen: TObject); // @note "DCC32 MAP Graphics.TCanvas.PenChanged. Source vcl/Graphics.pas:2848."
    procedure BrushChanged(ABrush: TObject); // @note "DCC32 MAP Graphics.TCanvas.BrushChanged. Source vcl/Graphics.pas:2857."
  end;

function GetHashCode(Buffer: Pointer; Count: Integer): Word; // @note "DCC32 MAP Graphics.GetHashCode. Source vcl/Graphics.pas:1271."

procedure ClearColor(ResMan: TResourceManager); // @nameonly @note "DCC32 MAP Graphics.ClearColor. Source vcl/Graphics.pas:1422. Prototype pending: nested routine has a parent-frame parameter."

procedure PaletteChanged; // @note "DCC32 MAP Graphics.PaletteChanged. Source vcl/Graphics.pas:1420."

function GetFontData(Font: Cardinal): TFontData; // @ida "void __usercall $name(unsigned __int32 Font@<eax>, TFontData *Result@<edx>);" @note "DCC32 MAP Graphics.GetFontData. Source vcl/Graphics.pas:1628."

function IsDefaultFont(const FontData: TFontData): Boolean; // @ida "bool __usercall $name@<al>(TFontData *FontData@<eax>);" @note "DCC32 MAP Graphics.IsDefaultFont. Source vcl/Graphics.pas:1728."

procedure GDIError; // @note "DCC32 MAP Graphics.GDIError. Source vcl/Graphics.pas:2917."

function DupBits(Src: Cardinal; Size: TPoint; Mono: Boolean): Cardinal; // @note "DCC32 MAP Graphics.DupBits. Source vcl/Graphics.pas:2936."

function GetDInColors(BitCount: Word): Integer; // @note "DCC32 MAP Graphics.GetDInColors. Source vcl/Graphics.pas:2977."

function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint; // @note "DCC32 MAP Graphics.BytesPerScanline. Source vcl/Graphics.pas:2986."

function TransparentStretchBlt(DstDC: Cardinal; DstX, DstY, DstW, DstH: Integer; SrcDC: Cardinal; SrcX, SrcY, SrcW, SrcH: Integer; MaskDC: Cardinal; MaskX, MaskY: Integer): Boolean; // @note "DCC32 MAP Graphics.TransparentStretchBlt. Source vcl/Graphics.pas:2993."

procedure RGBTripleToQuad(ColorTable: Pointer); // @note "DCC32 MAP Graphics.RGBTripleToQuad. Source vcl/Graphics.pas:3057."

procedure RGBQuadToTriple(ColorTable: Pointer; var ColorCount: Integer); // @note "DCC32 MAP Graphics.RGBQuadToTriple. Source vcl/Graphics.pas:3077."

procedure ByteSwapColors(Colors: Pointer; Count: Integer); // @note "DCC32 MAP Graphics.ByteSwapColors. Source vcl/Graphics.pas:3099."

function CreateSystemPalette(const Entries: array of TColor): Cardinal; // @nameonly @note "DCC32 MAP Graphics.CreateSystemPalette. Source vcl/Graphics.pas:3135. Prototype pending: open-array ABI needs expansion."

function SystemPaletteOverride(var Pal: TMaxLogPalette): Boolean; // @note "DCC32 MAP Graphics.SystemPaletteOverride. Source vcl/Graphics.pas:3171."

function PaletteFromDIBColorTable(DIBHandle: Cardinal; ColorTable: Pointer; ColorCount: Integer): Cardinal; // @note "DCC32 MAP Graphics.PaletteFromDIBColorTable. Source vcl/Graphics.pas:3196."

function PaletteToDIBColorTable(Pal: Cardinal; var ColorTable: array of TRGBQuad): Integer; // @nameonly @note "DCC32 MAP Graphics.PaletteToDIBColorTable. Source vcl/Graphics.pas:3224. Prototype pending: open-array ABI needs expansion."

procedure TwoBitsFromDIB(var BI: TBitmapInfoHeader; var XorBits, AndBits: Cardinal; const IconSize: TPoint); // @note "DCC32 MAP Graphics.TwoBitsFromDIB. Source vcl/Graphics.pas:3236."

function BetterSize(const Old, New: TIconRec): Boolean; // @nameonly @note "DCC32 MAP Graphics.BetterSize. Source vcl/Graphics.pas:3323. Prototype pending: nested routine has a parent-frame parameter."

procedure ReadIcon(Stream: TStream; var Icon: Cardinal; ImageCount: Integer; StartOffset: Integer; const RequestedSize: TPoint; var IconSize: TPoint); // @note "DCC32 MAP Graphics.ReadIcon. Source vcl/Graphics.pas:3286."

function ComputeAldusChecksum(var WMF: TMetafileHeader): Word; // @note "DCC32 MAP Graphics.ComputeAldusChecksum. Source vcl/Graphics.pas:3440."

procedure InitializeBitmapInfoHeader(Bitmap: Cardinal; var BI: TBitmapInfoHeader; Colors: Integer); // @note "DCC32 MAP Graphics.InitializeBitmapInfoHeader. Source vcl/Graphics.pas:3457."

procedure InternalGetDIBSizes(Bitmap: Cardinal; var InfoHeaderSize: DWord; var ImageSize: DWord; Colors: Integer); // @note "DCC32 MAP Graphics.InternalGetDIBSizes. Source vcl/Graphics.pas:3501."

function InternalGetDIB(Bitmap: Cardinal; Palette: Cardinal; BitmapInfo: Pointer; Bits: Pointer; Colors: Integer): Boolean; // @note "DCC32 MAP Graphics.InternalGetDIB. Source vcl/Graphics.pas:3529."

function GetDIB(Bitmap: Cardinal; Palette: Cardinal; BitmapInfo: Pointer; Bits: Pointer): Boolean; // @note "DCC32 MAP Graphics.GetDIB. Source vcl/Graphics.pas:3552."

procedure WriteIcon(Stream: TStream; Icon: Cardinal; WriteLength: Boolean); // @note "DCC32 MAP Graphics.WriteIcon. Source vcl/Graphics.pas:3566."

procedure DoWrite_4243CC; // @nameonly @note "DCC32 MAP Graphics.DoWrite. Prototype pending: no unique source declaration."

procedure DoWrite_425238; // @nameonly @note "DCC32 MAP Graphics.DoWrite. Prototype pending: no unique source declaration."

procedure DeselectBitmap(AHandle: Cardinal); // @note "DCC32 MAP Graphics.DeselectBitmap. Source vcl/Graphics.pas:5040."

procedure UpdateDIBColorTable(DIBHandle: Cardinal; Pal: Cardinal; const DIB: TDIBSection); // @ida "void __usercall $name(unsigned __int32 DIBHandle@<eax>, unsigned __int32 Pal@<edx>, TDIBSection *DIB@<ecx>);" @note "DCC32 MAP Graphics.UpdateDIBColorTable. Source vcl/Graphics.pas:5361."

procedure FixupBitFields(var DIB: TDIBSection); // @note "DCC32 MAP Graphics.FixupBitFields. Source vcl/Graphics.pas:5386."

function CopyBitmap(Handle: Cardinal; OldPalette, NewPalette: Cardinal; var DIB: TDIBSection; Canvas: TCanvas): Cardinal; // @note "DCC32 MAP Graphics.CopyBitmap. Source vcl/Graphics.pas:5405."

function CopyPalette(Palette: Cardinal): Cardinal; // @note "DCC32 MAP Graphics.CopyPalette. Source vcl/Graphics.pas:5560."

function CopyBitmapAsMask(Handle: Cardinal; Palette: Cardinal; TransparentColor: TColorRef): Cardinal; // @note "DCC32 MAP Graphics.CopyBitmapAsMask. Source vcl/Graphics.pas:5579."

procedure InitScreenLogPixels; // @note "DCC32 MAP Graphics.InitScreenLogPixels. Source vcl/Graphics.pas:7113."

procedure GetDefFontCharSet; // @nameonly @note "DCC32 MAP Graphics.GetDefFontCharSet. Source vcl/Graphics.pas:7131. Prototype pending: unsupported source type TFontCharSet: 0..255."

procedure InitDefFontData; // @note "DCC32 MAP Graphics.InitDefFontData. Source vcl/Graphics.pas:7147."

function AllocPatternBitmap(BkColor, FgColor: TColor): TBitmap; // @note "DCC32 MAP Graphics.AllocPatternBitmap. Source vcl/Graphics.pas:7294."

procedure FinalizeGraphics; // @nameonly @note "DCC32 MAP Graphics.Finalization. Prototype pending: no unique source declaration."

implementation
end.
