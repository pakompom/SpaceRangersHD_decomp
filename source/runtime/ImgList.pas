unit ImgList;

interface

type
  TCustomImageList = class(TComponent) // @size 0x68
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure InitBitmap;
    procedure SetNewDimensions(Value: HImageList);
    procedure SetHandle(Value: HImageList);
    function GetImageHandle(Image, ImageDDB: TBitmap): Cardinal;
    procedure FreeHandle;
    procedure CreateImageList;
    function Add(Image, Mask: TBitmap): Integer;
    function GetCount: Integer;
    procedure Delete(Index: Integer);
    procedure SetBkColor(Value: TColor);
    function GetBkColor: TColor;
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure Draw; // @nameonly
    procedure Draw_44D5A0; // @nameonly
    procedure CopyImages(Value: HImageList; Index: Integer);
    procedure AddImages(Value: TCustomImageList);
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Style: Cardinal; Enabled: Boolean); virtual; // @slot 0x30
    procedure Initialize; virtual; // @slot 0x34
    procedure CheckImage(Image: TGraphic);
    procedure SetDrawingStyle(Value: TDrawingStyle);
    procedure Change;
    procedure UnRegisterChanges(Value: TChangeLink);
    function Equal(IL: TCustomImageList): Boolean;
    procedure DefineProperties(Filer: TFiler); override; // @slot 0x4
    procedure ReadD2Stream(Stream: TStream);
    procedure ReadD3Stream(Stream: TStream);
    procedure ReadData(Stream: TStream); virtual; // @addr $44E0B8 @slot $38 @note "After reading, if not ThemeServices.ThemesEnabled, calls ImageList_SetImageCount(Handle, ImageList_GetImageCount(Handle))."
    procedure WriteData(Stream: TStream); virtual; // @slot 0x3C
    procedure EndUpdate;
  end;

  TImageIndex = Integer;

  TDrawingStyle = (dsFocus, dsSelected, dsNormal, dsTransparent); // @size 0x1

  TChangeLink = class(TObject) // @size 0x10
  public
    destructor Destroy;
    procedure Change;
  end;

function GetRGBColor(Value: TColor): DWord;

function GetColor(Value: DWord): TColor;

function StreamsEqual(S1, S2: TMemoryStream): Boolean; // @nameonly

function DoWrite_44DBA8: Boolean; // @nameonly

implementation
end.
