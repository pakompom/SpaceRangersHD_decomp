unit ImgList;
// Unit bracket (inferred): .text 0x0044CC40..0x0044E31C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TCustomImageList = class(TComponent) // @size 0x68
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP ImgList.TCustomImageList.Create. Source vcl/ImgList.pas:197." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP ImgList.TCustomImageList.Destroy. Source vcl/ImgList.pas:213."
    procedure Initialize; virtual; // @note "DCC32 MAP ImgList.TCustomImageList.Initialize. Source vcl/ImgList.pas:225." @slot 0x34
    procedure InitBitmap; // @note "DCC32 MAP ImgList.TCustomImageList.InitBitmap. Source vcl/ImgList.pas:252."
    procedure SetNewDimensions(Value: HImageList); // @note "DCC32 MAP ImgList.TCustomImageList.SetNewDimensions. Source vcl/ImgList.pas:274."
    procedure SetHandle(Value: HImageList); // @note "DCC32 MAP ImgList.TCustomImageList.SetHandle. Source vcl/ImgList.pas:310."
    function GetImageHandle(Image, ImageDDB: TBitmap): Cardinal; // @note "DCC32 MAP ImgList.TCustomImageList.GetImageHandle. Source vcl/ImgList.pas:334."
    procedure FreeHandle; // @note "DCC32 MAP ImgList.TCustomImageList.FreeHandle. Source vcl/ImgList.pas:349."
    procedure CreateImageList; // @note "DCC32 MAP ImgList.TCustomImageList.CreateImageList. Source vcl/ImgList.pas:357."
    function Add(Image, Mask: TBitmap): Integer; // @note "DCC32 MAP ImgList.TCustomImageList.Add. Source vcl/ImgList.pas:391."
    function GetCount: Integer; // @note "DCC32 MAP ImgList.TCustomImageList.GetCount. Source vcl/ImgList.pas:474."
    procedure Delete(Index: Integer); // @note "DCC32 MAP ImgList.TCustomImageList.Delete. Source vcl/ImgList.pas:556."
    procedure SetBkColor(Value: TColor); // @note "DCC32 MAP ImgList.TCustomImageList.SetBkColor. Source vcl/ImgList.pas:568."
    function GetBkColor: TColor; // @note "DCC32 MAP ImgList.TCustomImageList.GetBkColor. Source vcl/ImgList.pas:575."
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Style: Cardinal; Enabled: Boolean); virtual; // @note "DCC32 MAP ImgList.TCustomImageList.DoDraw. Source vcl/ImgList.pas:581." @slot 0x30
    procedure Draw; // @nameonly @note "DCC32 MAP ImgList.TCustomImageList.Draw. Prototype pending: no unique source declaration."
    procedure Draw_44D5A0; // @nameonly @note "DCC32 MAP ImgList.TCustomImageList.Draw. Prototype pending: no unique source declaration."
    procedure CopyImages(Value: HImageList; Index: Integer); // @note "DCC32 MAP ImgList.TCustomImageList.CopyImages. Source vcl/ImgList.pas:670."
    procedure AddImages(Value: TCustomImageList); // @note "DCC32 MAP ImgList.TCustomImageList.AddImages. Source vcl/ImgList.pas:882."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP ImgList.TCustomImageList.Assign. Source vcl/ImgList.pas:887." @slot 0x8
    procedure AssignTo(Dest: TPersistent); virtual; // @note "DCC32 MAP ImgList.TCustomImageList.AssignTo. Source vcl/ImgList.pas:910." @slot 0x0
    procedure CheckImage(Image: TGraphic); // @note "DCC32 MAP ImgList.TCustomImageList.CheckImage. Source vcl/ImgList.pas:935."
    procedure SetDrawingStyle(Value: TDrawingStyle); // @note "DCC32 MAP ImgList.TCustomImageList.SetDrawingStyle. Source vcl/ImgList.pas:943."
    procedure Change; // @note "DCC32 MAP ImgList.TCustomImageList.Change. Source vcl/ImgList.pas:1041."
    procedure UnRegisterChanges(Value: TChangeLink); // @note "DCC32 MAP ImgList.TCustomImageList.UnRegisterChanges. Source vcl/ImgList.pas:1053."
    function Equal(IL: TCustomImageList): Boolean; // @note "DCC32 MAP ImgList.TCustomImageList.Equal. Source vcl/ImgList.pas:1073."
    procedure DefineProperties(Filer: TFiler); override; // @note "DCC32 MAP ImgList.TCustomImageList.DefineProperties. Source vcl/ImgList.pas:1108." @slot 0x4
    procedure ReadD2Stream(Stream: TStream); // @note "DCC32 MAP ImgList.TCustomImageList.ReadD2Stream. Source vcl/ImgList.pas:1124."
    procedure ReadD3Stream(Stream: TStream); // @note "DCC32 MAP ImgList.TCustomImageList.ReadD3Stream. Source vcl/ImgList.pas:1177."
    procedure ReadData(Stream: TStream); virtual; // @addr $44E0B8 @slot $38 @note "Native VMT $44CD08. After reading, if not ThemeServices.ThemesEnabled, calls ImageList_SetImageCount(Handle, ImageList_GetImageCount(Handle)); Supplied by the selected Update 4 library; all 180 native instruction bytes and call identities verified."
    procedure WriteData(Stream: TStream); virtual; // @note "DCC32 MAP ImgList.TCustomImageList.WriteData. Source vcl/ImgList.pas:1269." @slot 0x3C
    procedure EndUpdate; // @note "DCC32 MAP ImgList.TCustomImageList.EndUpdate. Source vcl/ImgList.pas:1379."
  end;

  TImageIndex = Integer;

  TDrawingStyle = (dsFocus, dsSelected, dsNormal, dsTransparent); // @size 0x1

  TChangeLink = class(TObject) // @size 0x10
  public
    destructor Destroy; // @note "DCC32 MAP ImgList.TChangeLink.Destroy. Source vcl/ImgList.pas:1391."
    procedure Change; // @note "DCC32 MAP ImgList.TChangeLink.Change. Source vcl/ImgList.pas:1397."
  end;

function GetRGBColor(Value: TColor): DWord; // @note "DCC32 MAP ImgList.GetRGBColor. Source vcl/ImgList.pas:178."

function GetColor(Value: DWord): TColor; // @note "DCC32 MAP ImgList.GetColor. Source vcl/ImgList.pas:187."

function StreamsEqual(S1, S2: TMemoryStream): Boolean; // @nameonly @note "DCC32 MAP ImgList.StreamsEqual. Source vcl/ImgList.pas:1075. Prototype pending: nested routine has a parent-frame parameter."

function DoWrite_44DBA8: Boolean; // @nameonly @note "DCC32 MAP ImgList.DoWrite. Source vcl/ImgList.pas:1110. Prototype pending: nested routine has a parent-frame parameter."

implementation
end.
