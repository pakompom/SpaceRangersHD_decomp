unit Menus;

interface

type
  TMenuItem = class(TComponent) // @size 0xAC
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure PopulateMenu;
    procedure ReadShortCutText(Reader: TReader);
    procedure MergeWith(Menu: TMenuItem);
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure RebuildHandle;
    procedure VerifyGroupIndex(Position: Integer; Value: Byte);
    function GetHandle: Cardinal;
    procedure DefineProperties(Filer: TFiler); override; // @slot 0x4
    procedure Loaded; virtual; // @slot 0xC
    function GetImageList: TCustomImageList;
    procedure SetCaption(const Value: AnsiString);
    procedure TurnSiblingsOff;
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetGroupIndex(Value: Byte);
    function GetItem(Index: Integer): TMenuItem;
    procedure SetShortCut(Value: TShortCut);
    procedure SetVisible(Value: Boolean);
    procedure SetImageIndex(Value: TImageIndex);
    function GetMenuIndex: Integer;
    procedure SetMenuIndex(Value: Integer);
    procedure GetChildren; // @nameonly
    procedure SetChildOrder(Child: TComponent; Order: Integer);
    procedure SetDefault(Value: Boolean);
    procedure Insert(Index: Integer; Item: TMenuItem);
    procedure Delete(Index: Integer);
    procedure DrawItem(ACanvas: TCanvas; ARect: TRect; Selected: Boolean); virtual; // @slot 0x34
    function IndexOf(Item: TMenuItem): Integer;
    procedure Add; // @nameonly
    procedure Remove(Item: TMenuItem);
    procedure MenuChanged(Rebuild: Boolean); virtual; // @slot 0x3C
    procedure SubItemChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    function GetBitmap: TBitmap;
    procedure SetAction(Value: TBasicAction);
    procedure SetBitmap(Value: TBitmap);
    procedure InitiateActions;
    function GetParentComponent: TComponent;
    procedure SetParentComponent(Value: TComponent);
    procedure SetRadioItem(Value: Boolean);
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean);
    procedure DoActionChange(Sender: TObject);
    function IsCaptionStored: Boolean;
    function IsCheckedStored: Boolean;
    function IsEnabledStored: Boolean;
    function IsHintStored: Boolean;
    function IsHelpContextStored: Boolean;
    function IsImageIndexStored: Boolean;
    function IsShortCutStored: Boolean;
    function IsVisibleStored: Boolean;
    function IsOnClickStored: Boolean;
    procedure Click; virtual; // @slot 0x44
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    procedure SetSubMenuImages(Value: TCustomImageList);
    function InternalRethinkHotkeys(ForceRethink: Boolean): Boolean;
    function InternalRethinkLines(ForceRethink: Boolean): Boolean;
    procedure SetAutoLineReduction(const Value: TMenuItemAutoFlag);
    function GetAutoHotkeys: Boolean;
    function GetAutoLineReduction: Boolean;
  end;

  TMenuActionLink = class(TActionLink) // @size 0x1C
  public
    function IsOnExecuteLinked: Boolean; virtual; // @slot 0x8
    function IsCaptionLinked: Boolean; virtual; // @slot 0x20
    function IsCheckedLinked: Boolean; virtual; // @slot 0x24
    function IsEnabledLinked: Boolean; virtual; // @slot 0x28
    function IsGroupIndexLinked: Boolean; virtual; // @slot 0x2C
    function IsHelpContextLinked: Boolean; virtual; // @slot 0x30
    function IsHintLinked: Boolean; virtual; // @slot 0x38
    function IsImageIndexLinked: Boolean; virtual; // @slot 0x3C
    function IsShortCutLinked: Boolean; virtual; // @slot 0x40
    function IsVisibleLinked: Boolean; virtual; // @slot 0x44
    procedure SetAutoCheck(Value: Boolean); virtual; // @slot 0x48
    procedure SetChecked(Value: Boolean); virtual; // @slot 0x50
    procedure SetEnabled(Value: Boolean); virtual; // @slot 0x54
    procedure SetHelpContext(Value: THelpContext); virtual; // @slot 0x5C
    procedure SetHint(const Value: AnsiString); virtual; // @slot 0x68
    procedure SetImageIndex(Value: Integer); virtual; // @slot 0x6C
    procedure SetShortCut(Value: TShortCut); virtual; // @slot 0x70
    function IsAutoCheckLinked: Boolean; virtual; // @slot 0x78
    procedure SetOnExecute; // @nameonly
  end;

  TMenuItemAutoFlag = (maAutomatic, maManual, maParent); // @size 0x1

  TMenu = class(TComponent) // @size 0x58
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure GetChildren; // @nameonly
    procedure UpdateItems;
    function FindItem(Value: Integer; Kind: TFindItemKind): TMenuItem;
    function GetHelpContext(Value: Integer; ByCommand: Boolean): THelpContext;
    function DispatchCommand(ACommand: Word): Boolean;
    function DispatchPopup(AHandle: Cardinal): Boolean;
    function IsShortCut(var Message: TWMKey): Boolean;
    procedure DoBiDiModeChanged;
    function UpdateImage: Boolean;
    procedure AdjustBiDiBehavior;
    procedure SetWindowHandle(Value: Cardinal);
    procedure Loaded; virtual; // @slot 0xC
    procedure DoChange(Source: TMenuItem; Rebuild: Boolean); virtual; // @slot 0x30
    procedure MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); virtual; // @slot 0x38
    procedure SetImages(Value: TCustomImageList);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    function IsRightToLeft: Boolean;
    procedure ProcessMenuChar(var Message: TWMMenuChar);
    function DoGetMenuString(Menu: Cardinal; ItemID: Cardinal; Str: PAnsiChar; MaxCount: Integer; Flag: Cardinal): Integer;
    procedure ParentBiDiModeChanged; // @nameonly
    procedure ParentBiDiModeChanged_437834; // @nameonly
  end;

  TFindItemKind = (fkCommand, fkHandle, fkShortCut); // @size 0x1

  TClickResult = (crDisabled, crClicked, crShortCutMoved, crShortCutFreed); // @size 0x1

  TMainMenu = class(TMenu) // @size 0x60
  public
    procedure MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); override; // @slot 0x38
    procedure Unmerge(Menu: TMainMenu);
    procedure ItemChanged;
  end;

  TPopupList = class(TList) // @size 0x14
  public
    procedure MainWndProc(var Message: TMessage);
    procedure WndProc(var Message: TMessage); virtual; // @slot 0x10
    procedure Add(Popup: TPopupMenu);
    procedure Remove(Popup: TPopupMenu);
  end;

  TPopupMenu = class(TMenu) // @size 0x78
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure DoPopup(Sender: TObject); virtual; // @slot 0x3C
    procedure SetBiDiModeFromPopupControl;
    function UseRightToLeftAlignment: Boolean;
    procedure Popup(X, Y: Integer); virtual; // @slot 0x40
    procedure SetPopupPoint(APopupPoint: TPoint);
  end;

  TMenuItemStack = class(TStack) // @size 0x8
  public
    procedure ClearItem(AItem: TMenuItem);
  end;

function FindPopupControl(const Pos: TPoint): TControl;

function ShortCut(Key: Word; Shift: TShiftState): TShortCut;

function GetSpecialName(ShortCut: TShortCut): AnsiString;

function ShortCutToText(ShortCut: TShortCut): AnsiString;

function CompareFront(var Text: AnsiString; const Front: AnsiString): Boolean; // @nameonly

function TextToShortCut(Text: AnsiString): TShortCut;

function UniqueCommand: Word;

function Iterate(var I: Integer; MenuItem: TMenuItem; AFunc: Pointer): Boolean; // @nameonly

procedure IterateMenus(Func: Pointer; Menu1, Menu2: TMenuItem);

function AddIn(MenuItem: TMenuItem): Boolean; // @nameonly

procedure GetMenuSize; // @nameonly

function IfHotkeyAvailable(const AHotkey: AnsiString): Boolean; // @nameonly

procedure CopyToBest; // @nameonly

procedure InsertHotkeyFarEastFormat(var ACaption: AnsiString; const AHotKey: AnsiString; AColumn: Integer); // @nameonly

function Find(Item: TMenuItem): Boolean; // @nameonly

procedure GetAltGRStatus; // @nameonly

function IsAltGRPressed: boolean;

function ShortCutFromMessage(Message: TWMKey): TShortCut; // @ida "TShortCut __usercall $name@<ax>(TWMKey *Message@<eax>);"

function DoClick(var Item: TMenuItem; Level: Integer): TClickResult; // @nameonly

procedure BuildImage(Menu: Cardinal); // @nameonly

function IsAccelChar(Menu: Cardinal; State: Word; I: Integer; C: Char): Boolean; // @nameonly

function IsInitialChar(Menu: Cardinal; State: Word; I: Integer; C: Char): Boolean; // @nameonly

procedure DrawMenuItem; // @nameonly

function StripHotkey(const Text: AnsiString): AnsiString;

function GetHotkey(const Text: AnsiString): AnsiString;

procedure FinalizeMenus; // @nameonly

implementation
end.
