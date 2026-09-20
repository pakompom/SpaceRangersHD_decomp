unit Menus;
// Unit bracket (inferred): .text 0x00430B4C..0x004385D0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876560..0x00876560; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TMenuItem = class(TComponent) // @size 0xAC
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Menus.TMenuItem.Create. Source vcl/Menus.pas:811." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Menus.TMenuItem.Destroy. Source vcl/Menus.pas:824."
    procedure PopulateMenu; // @note "DCC32 MAP Menus.TMenuItem.PopulateMenu. Source vcl/Menus.pas:914."
    procedure ReadShortCutText(Reader: TReader); // @note "DCC32 MAP Menus.TMenuItem.ReadShortCutText. Source vcl/Menus.pas:937."
    procedure MergeWith(Menu: TMenuItem); // @note "DCC32 MAP Menus.TMenuItem.MergeWith. Source vcl/Menus.pas:942."
    procedure Loaded; virtual; // @note "DCC32 MAP Menus.TMenuItem.Loaded. Source vcl/Menus.pas:959." @slot 0xC
    procedure RebuildHandle; // @note "DCC32 MAP Menus.TMenuItem.RebuildHandle. Source vcl/Menus.pas:966."
    procedure VerifyGroupIndex(Position: Integer; Value: Byte); // @note "DCC32 MAP Menus.TMenuItem.VerifyGroupIndex. Source vcl/Menus.pas:1007."
    function GetHandle: Cardinal; // @note "DCC32 MAP Menus.TMenuItem.GetHandle. Source vcl/Menus.pas:1021."
    procedure DefineProperties(Filer: TFiler); override; // @note "DCC32 MAP Menus.TMenuItem.DefineProperties. Source vcl/Menus.pas:1035." @slot 0x4
    procedure DrawItem(ACanvas: TCanvas; ARect: TRect; Selected: Boolean); virtual; // @note "DCC32 MAP Menus.TMenuItem.DrawItem. Source vcl/Menus.pas:1094." @slot 0x34
    function GetImageList: TCustomImageList; // @note "DCC32 MAP Menus.TMenuItem.GetImageList. Source vcl/Menus.pas:1551."
    procedure SetCaption(const Value: AnsiString); // @note "DCC32 MAP Menus.TMenuItem.SetCaption. Source vcl/Menus.pas:1664."
    procedure TurnSiblingsOff; // @note "DCC32 MAP Menus.TMenuItem.TurnSiblingsOff. Source vcl/Menus.pas:1673."
    procedure SetChecked(Value: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SetChecked. Source vcl/Menus.pas:1687."
    procedure SetEnabled(Value: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SetEnabled. Source vcl/Menus.pas:1699."
    procedure SetGroupIndex(Value: Byte); // @note "DCC32 MAP Menus.TMenuItem.SetGroupIndex. Source vcl/Menus.pas:1716."
    function GetItem(Index: Integer): TMenuItem; // @note "DCC32 MAP Menus.TMenuItem.GetItem. Source vcl/Menus.pas:1745."
    procedure SetShortCut(Value: TShortCut); // @note "DCC32 MAP Menus.TMenuItem.SetShortCut. Source vcl/Menus.pas:1751."
    procedure SetVisible(Value: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SetVisible. Source vcl/Menus.pas:1760."
    procedure SetImageIndex(Value: TImageIndex); // @note "DCC32 MAP Menus.TMenuItem.SetImageIndex. Source vcl/Menus.pas:1769."
    function GetMenuIndex: Integer; // @note "DCC32 MAP Menus.TMenuItem.GetMenuIndex. Source vcl/Menus.pas:1778."
    procedure SetMenuIndex(Value: Integer); // @note "DCC32 MAP Menus.TMenuItem.SetMenuIndex. Source vcl/Menus.pas:1784."
    procedure GetChildren; // @nameonly @note "DCC32 MAP Menus.TMenuItem.GetChildren. Source vcl/Menus.pas:1803. Prototype pending: unsupported source type TGetChildProc: procedure (Child: TComponent) of object."
    procedure SetChildOrder(Child: TComponent; Order: Integer); // @note "DCC32 MAP Menus.TMenuItem.SetChildOrder. Source vcl/Menus.pas:1810."
    procedure SetDefault(Value: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SetDefault. Source vcl/Menus.pas:1815."
    procedure Insert(Index: Integer; Item: TMenuItem); // @note "DCC32 MAP Menus.TMenuItem.Insert. Source vcl/Menus.pas:1834."
    procedure Delete(Index: Integer); // @note "DCC32 MAP Menus.TMenuItem.Delete. Source vcl/Menus.pas:1849."
    procedure Click; virtual; // @note "DCC32 MAP Menus.TMenuItem.Click. Source vcl/Menus.pas:1862." @slot 0x44
    function IndexOf(Item: TMenuItem): Integer; // @note "DCC32 MAP Menus.TMenuItem.IndexOf. Source vcl/Menus.pas:1881."
    procedure Add; // @nameonly @note "DCC32 MAP Menus.TMenuItem.Add. Prototype pending: no unique source declaration."
    procedure Remove(Item: TMenuItem); // @note "DCC32 MAP Menus.TMenuItem.Remove. Source vcl/Menus.pas:1892."
    procedure MenuChanged(Rebuild: Boolean); virtual; // @note "DCC32 MAP Menus.TMenuItem.MenuChanged. Source vcl/Menus.pas:1901." @slot 0x3C
    procedure SubItemChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SubItemChanged. Source vcl/Menus.pas:1911."
    function GetBitmap: TBitmap; // @note "DCC32 MAP Menus.TMenuItem.GetBitmap. Source vcl/Menus.pas:1918."
    procedure SetAction(Value: TBasicAction); // @note "DCC32 MAP Menus.TMenuItem.SetAction. Source vcl/Menus.pas:1925."
    procedure SetBitmap(Value: TBitmap); // @note "DCC32 MAP Menus.TMenuItem.SetBitmap. Source vcl/Menus.pas:1943."
    procedure InitiateActions; // @note "DCC32 MAP Menus.TMenuItem.InitiateActions. Source vcl/Menus.pas:1950."
    function GetParentComponent: TComponent; // @note "DCC32 MAP Menus.TMenuItem.GetParentComponent. Source vcl/Menus.pas:1958."
    procedure SetParentComponent(Value: TComponent); // @note "DCC32 MAP Menus.TMenuItem.SetParentComponent. Source vcl/Menus.pas:1965."
    procedure SetRadioItem(Value: Boolean); // @note "DCC32 MAP Menus.TMenuItem.SetRadioItem. Source vcl/Menus.pas:1984."
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); // @note "DCC32 MAP Menus.TMenuItem.ActionChange. Source vcl/Menus.pas:1995."
    procedure DoActionChange(Sender: TObject); // @note "DCC32 MAP Menus.TMenuItem.DoActionChange. Source vcl/Menus.pas:2025."
    function IsCaptionStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsCaptionStored. Source vcl/Menus.pas:2030."
    function IsCheckedStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsCheckedStored. Source vcl/Menus.pas:2035."
    function IsEnabledStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsEnabledStored. Source vcl/Menus.pas:2040."
    function IsHintStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsHintStored. Source vcl/Menus.pas:2045."
    function IsHelpContextStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsHelpContextStored. Source vcl/Menus.pas:2050."
    function IsImageIndexStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsImageIndexStored. Source vcl/Menus.pas:2055."
    function IsShortCutStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsShortCutStored. Source vcl/Menus.pas:2060."
    function IsVisibleStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsVisibleStored. Source vcl/Menus.pas:2065."
    function IsOnClickStored: Boolean; // @note "DCC32 MAP Menus.TMenuItem.IsOnClickStored. Source vcl/Menus.pas:2070."
    procedure AssignTo(Dest: TPersistent); virtual; // @note "DCC32 MAP Menus.TMenuItem.AssignTo. Source vcl/Menus.pas:2075." @slot 0x0
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @note "DCC32 MAP Menus.TMenuItem.Notification. Source vcl/Menus.pas:2091." @slot 0x10
    procedure SetSubMenuImages(Value: TCustomImageList); // @note "DCC32 MAP Menus.TMenuItem.SetSubMenuImages. Source vcl/Menus.pas:2104."
    function InternalRethinkHotkeys(ForceRethink: Boolean): Boolean; // @note "DCC32 MAP Menus.TMenuItem.InternalRethinkHotkeys. Source vcl/Menus.pas:2150."
    function InternalRethinkLines(ForceRethink: Boolean): Boolean; // @note "DCC32 MAP Menus.TMenuItem.InternalRethinkLines. Source vcl/Menus.pas:2393."
    procedure SetAutoLineReduction(const Value: TMenuItemAutoFlag); // @note "DCC32 MAP Menus.TMenuItem.SetAutoLineReduction. Source vcl/Menus.pas:2448."
    function GetAutoHotkeys: Boolean; // @note "DCC32 MAP Menus.TMenuItem.GetAutoHotkeys. Source vcl/Menus.pas:2464."
    function GetAutoLineReduction: Boolean; // @note "DCC32 MAP Menus.TMenuItem.GetAutoLineReduction. Source vcl/Menus.pas:2475."
  end;

  TMenuActionLink = class(TActionLink) // @size 0x1C
  public
    function IsAutoCheckLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsAutoCheckLinked. Source vcl/Menus.pas:673." @slot 0x78
    function IsCaptionLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsCaptionLinked. Source vcl/Menus.pas:678." @slot 0x20
    function IsCheckedLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsCheckedLinked. Source vcl/Menus.pas:684." @slot 0x24
    function IsEnabledLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsEnabledLinked. Source vcl/Menus.pas:690." @slot 0x28
    function IsHelpContextLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsHelpContextLinked. Source vcl/Menus.pas:696." @slot 0x30
    function IsHintLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsHintLinked. Source vcl/Menus.pas:702." @slot 0x38
    function IsGroupIndexLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsGroupIndexLinked. Source vcl/Menus.pas:708." @slot 0x2C
    function IsImageIndexLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsImageIndexLinked. Source vcl/Menus.pas:714." @slot 0x3C
    function IsShortCutLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsShortCutLinked. Source vcl/Menus.pas:720." @slot 0x40
    function IsVisibleLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsVisibleLinked. Source vcl/Menus.pas:726." @slot 0x44
    function IsOnExecuteLinked: Boolean; virtual; // @note "DCC32 MAP Menus.TMenuActionLink.IsOnExecuteLinked. Source vcl/Menus.pas:732." @slot 0x8
    procedure SetAutoCheck(Value: Boolean); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetAutoCheck. Source vcl/Menus.pas:738." @slot 0x48
    procedure SetChecked(Value: Boolean); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetChecked. Source vcl/Menus.pas:748." @slot 0x50
    procedure SetEnabled(Value: Boolean); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetEnabled. Source vcl/Menus.pas:753." @slot 0x54
    procedure SetHelpContext(Value: THelpContext); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetHelpContext. Source vcl/Menus.pas:758." @slot 0x5C
    procedure SetHint(const Value: AnsiString); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetHint. Source vcl/Menus.pas:763." @slot 0x68
    procedure SetImageIndex(Value: Integer); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetImageIndex. Source vcl/Menus.pas:768." @slot 0x6C
    procedure SetShortCut(Value: TShortCut); virtual; // @note "DCC32 MAP Menus.TMenuActionLink.SetShortCut. Source vcl/Menus.pas:773." @slot 0x70
    procedure SetOnExecute; // @nameonly @note "DCC32 MAP Menus.TMenuActionLink.SetOnExecute. Source vcl/Menus.pas:783. Prototype pending: unsupported source type TNotifyEvent: procedure(Sender: TObject) of object."
  end;

  TMenuItemAutoFlag = (maAutomatic, maManual, maParent); // @size 0x1

  TMenu = class(TComponent) // @size 0x58
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Menus.TMenu.Create. Source vcl/Menus.pas:2488." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Menus.TMenu.Destroy. Source vcl/Menus.pas:2507."
    procedure GetChildren; // @nameonly @note "DCC32 MAP Menus.TMenu.GetChildren. Source vcl/Menus.pas:2514. Prototype pending: unsupported source type TGetChildProc: procedure (Child: TComponent) of object."
    procedure UpdateItems; // @note "DCC32 MAP Menus.TMenu.UpdateItems. Source vcl/Menus.pas:2529."
    function FindItem(Value: Integer; Kind: TFindItemKind): TMenuItem; // @note "DCC32 MAP Menus.TMenu.FindItem. Source vcl/Menus.pas:2542."
    function GetHelpContext(Value: Integer; ByCommand: Boolean): THelpContext; // @note "DCC32 MAP Menus.TMenu.GetHelpContext. Source vcl/Menus.pas:2574."
    function DispatchCommand(ACommand: Word): Boolean; // @note "DCC32 MAP Menus.TMenu.DispatchCommand. Source vcl/Menus.pas:2594."
    function DispatchPopup(AHandle: Cardinal): Boolean; // @note "DCC32 MAP Menus.TMenu.DispatchPopup. Source vcl/Menus.pas:2607."
    function IsShortCut(var Message: TWMKey): Boolean; // @note "DCC32 MAP Menus.TMenu.IsShortCut. Source vcl/Menus.pas:2734."
    procedure DoBiDiModeChanged; // @note "DCC32 MAP Menus.TMenu.DoBiDiModeChanged. Source vcl/Menus.pas:2826."
    function UpdateImage: Boolean; // @note "DCC32 MAP Menus.TMenu.UpdateImage. Source vcl/Menus.pas:2851."
    procedure AdjustBiDiBehavior; // @note "DCC32 MAP Menus.TMenu.AdjustBiDiBehavior. Source vcl/Menus.pas:2915."
    procedure SetWindowHandle(Value: Cardinal); // @note "DCC32 MAP Menus.TMenu.SetWindowHandle. Source vcl/Menus.pas:2934."
    procedure DoChange(Source: TMenuItem; Rebuild: Boolean); virtual; // @note "DCC32 MAP Menus.TMenu.DoChange. Source vcl/Menus.pas:2948." @slot 0x30
    procedure Loaded; virtual; // @note "DCC32 MAP Menus.TMenu.Loaded. Source vcl/Menus.pas:2953." @slot 0xC
    procedure MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); virtual; // @note "DCC32 MAP Menus.TMenu.MenuChanged. Source vcl/Menus.pas:2959." @slot 0x38
    procedure SetImages(Value: TCustomImageList); // @note "DCC32 MAP Menus.TMenu.SetImages. Source vcl/Menus.pas:2969."
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @note "DCC32 MAP Menus.TMenu.Notification. Source vcl/Menus.pas:2981." @slot 0x10
    function IsRightToLeft: Boolean; // @note "DCC32 MAP Menus.TMenu.IsRightToLeft. Source vcl/Menus.pas:2988."
    procedure ProcessMenuChar(var Message: TWMMenuChar); // @note "DCC32 MAP Menus.TMenu.ProcessMenuChar. Source vcl/Menus.pas:2993."
    function DoGetMenuString(Menu: Cardinal; ItemID: Cardinal; Str: PAnsiChar; MaxCount: Integer; Flag: Cardinal): Integer; // @note "DCC32 MAP Menus.TMenu.DoGetMenuString. Source vcl/Menus.pas:3122."
    procedure ParentBiDiModeChanged; // @nameonly @note "DCC32 MAP Menus.TMenu.ParentBiDiModeChanged. Prototype pending: no unique source declaration."
    procedure ParentBiDiModeChanged_437834; // @nameonly @note "DCC32 MAP Menus.TMenu.ParentBiDiModeChanged. Prototype pending: no unique source declaration."
  end;

  TFindItemKind = (fkCommand, fkHandle, fkShortCut); // @size 0x1

  TClickResult = (crDisabled, crClicked, crShortCutMoved, crShortCutFreed); // @size 0x1

  TMainMenu = class(TMenu) // @size 0x60
  public
    procedure MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean); override; // @note "DCC32 MAP Menus.TMainMenu.MenuChanged. Source vcl/Menus.pas:3231." @slot 0x38
    procedure Unmerge(Menu: TMainMenu); // @note "DCC32 MAP Menus.TMainMenu.Unmerge. Source vcl/Menus.pas:3253."
    procedure ItemChanged; // @note "DCC32 MAP Menus.TMainMenu.ItemChanged. Source vcl/Menus.pas:3259."
  end;

  TPopupList = class(TList) // @size 0x14
  public
    procedure MainWndProc(var Message: TMessage); // @note "DCC32 MAP Menus.TPopupList.MainWndProc. Source vcl/Menus.pas:3370."
    procedure WndProc(var Message: TMessage); virtual; // @note "DCC32 MAP Menus.TPopupList.WndProc. Source vcl/Menus.pas:3379." @slot 0x10
    procedure Add(Popup: TPopupMenu); // @note "DCC32 MAP Menus.TPopupList.Add. Source vcl/Menus.pas:3519."
    procedure Remove(Popup: TPopupMenu); // @note "DCC32 MAP Menus.TPopupList.Remove. Source vcl/Menus.pas:3530."
  end;

  TPopupMenu = class(TMenu) // @size 0x78
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Menus.TPopupMenu.Create. Source vcl/Menus.pas:3543." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Menus.TPopupMenu.Destroy. Source vcl/Menus.pas:3554."
    procedure DoPopup(Sender: TObject); virtual; // @note "DCC32 MAP Menus.TPopupMenu.DoPopup. Source vcl/Menus.pas:3560." @slot 0x3C
    procedure SetBiDiModeFromPopupControl; // @note "DCC32 MAP Menus.TPopupMenu.SetBiDiModeFromPopupControl. Source vcl/Menus.pas:3575."
    function UseRightToLeftAlignment: Boolean; // @note "DCC32 MAP Menus.TPopupMenu.UseRightToLeftAlignment. Source vcl/Menus.pas:3598."
    procedure Popup(X, Y: Integer); virtual; // @note "DCC32 MAP Menus.TPopupMenu.Popup. Source vcl/Menus.pas:3618." @slot 0x40
    procedure SetPopupPoint(APopupPoint: TPoint); // @note "DCC32 MAP Menus.TPopupMenu.SetPopupPoint. Source vcl/Menus.pas:3639."
  end;

  TMenuItemStack = class(TStack) // @size 0x8
  public
    procedure ClearItem(AItem: TMenuItem); // @note "DCC32 MAP Menus.TMenuItemStack.ClearItem. Source vcl/Menus.pas:3646."
  end;

function FindPopupControl(const Pos: TPoint): TControl; // @note "DCC32 MAP Menus.FindPopupControl. Source vcl/Menus.pas:456."

function ShortCut(Key: Word; Shift: TShiftState): TShortCut; // @note "DCC32 MAP Menus.ShortCut. Source vcl/Menus.pas:482."

function GetSpecialName(ShortCut: TShortCut): AnsiString; // @note "DCC32 MAP Menus.GetSpecialName. Source vcl/Menus.pas:512."

function ShortCutToText(ShortCut: TShortCut): AnsiString; // @note "DCC32 MAP Menus.ShortCutToText. Source vcl/Menus.pas:526."

function CompareFront(var Text: AnsiString; const Front: AnsiString): Boolean; // @nameonly @note "DCC32 MAP Menus.CompareFront. Source vcl/Menus.pas:565. Prototype pending: nested routine has a parent-frame parameter."

function TextToShortCut(Text: AnsiString): TShortCut; // @note "DCC32 MAP Menus.TextToShortCut. Source vcl/Menus.pas:560."

function UniqueCommand: Word; // @note "DCC32 MAP Menus.UniqueCommand. Source vcl/Menus.pas:604."

function Iterate(var I: Integer; MenuItem: TMenuItem; AFunc: Pointer): Boolean; // @nameonly @note "DCC32 MAP Menus.Iterate. Source vcl/Menus.pas:619. Prototype pending: nested routine has a parent-frame parameter."

procedure IterateMenus(Func: Pointer; Menu1, Menu2: TMenuItem); // @note "DCC32 MAP Menus.IterateMenus. Source vcl/Menus.pas:612."

function AddIn(MenuItem: TMenuItem): Boolean; // @nameonly @note "DCC32 MAP Menus.AddIn. Source vcl/Menus.pas:918. Prototype pending: nested routine has a parent-frame parameter."

procedure GetMenuSize; // @nameonly @note "DCC32 MAP Menus.GetMenuSize. Source vcl/Menus.pas:1583. Prototype pending: nested routine has a parent-frame parameter."

function IfHotkeyAvailable(const AHotkey: AnsiString): Boolean; // @nameonly @note "DCC32 MAP Menus.IfHotkeyAvailable. Source vcl/Menus.pas:2155. Prototype pending: nested routine has a parent-frame parameter."

procedure CopyToBest; // @nameonly @note "DCC32 MAP Menus.CopyToBest. Source vcl/Menus.pas:2164. Prototype pending: nested routine has a parent-frame parameter."

procedure InsertHotkeyFarEastFormat(var ACaption: AnsiString; const AHotKey: AnsiString; AColumn: Integer); // @nameonly @note "DCC32 MAP Menus.InsertHotkeyFarEastFormat. Source vcl/Menus.pas:2174. Prototype pending: nested routine has a parent-frame parameter."

function Find(Item: TMenuItem): Boolean; // @nameonly @note "DCC32 MAP Menus.Find. Source vcl/Menus.pas:2546. Prototype pending: nested routine has a parent-frame parameter."

procedure GetAltGRStatus; // @nameonly @note "DCC32 MAP Menus.GetAltGRStatus. Source vcl/Menus.pas:2646. Prototype pending: nested routine has a parent-frame parameter."

function IsAltGRPressed: boolean; // @note "DCC32 MAP Menus.IsAltGRPressed. Source vcl/Menus.pas:2644."

function ShortCutFromMessage(Message: TWMKey): TShortCut; // @ida "TShortCut __usercall $name@<ax>(TWMKey *Message@<eax>);" @note "DCC32 MAP Menus.ShortCutFromMessage. Source vcl/Menus.pas:2714."

function DoClick(var Item: TMenuItem; Level: Integer): TClickResult; // @nameonly @note "DCC32 MAP Menus.DoClick. Source vcl/Menus.pas:2753. Prototype pending: nested routine has a parent-frame parameter."

procedure BuildImage(Menu: Cardinal); // @nameonly @note "DCC32 MAP Menus.BuildImage. Source vcl/Menus.pas:2855. Prototype pending: nested routine has a parent-frame parameter."

function IsAccelChar(Menu: Cardinal; State: Word; I: Integer; C: Char): Boolean; // @nameonly @note "DCC32 MAP Menus.IsAccelChar. Source vcl/Menus.pas:2998. Prototype pending: nested routine has a parent-frame parameter."

function IsInitialChar(Menu: Cardinal; State: Word; I: Integer; C: Char): Boolean; // @nameonly @note "DCC32 MAP Menus.IsInitialChar. Source vcl/Menus.pas:3020. Prototype pending: nested routine has a parent-frame parameter."

procedure DrawMenuItem; // @nameonly @note "DCC32 MAP Menus.DrawMenuItem. Source vcl/Menus.pas:3732. Prototype pending: ambiguous source type: TOwnerDrawState."

function StripHotkey(const Text: AnsiString): AnsiString; // @note "DCC32 MAP Menus.StripHotkey. Source vcl/Menus.pas:3762."

function GetHotkey(const Text: AnsiString): AnsiString; // @note "DCC32 MAP Menus.GetHotkey. Source vcl/Menus.pas:3783."

procedure FinalizeMenus; // @nameonly @note "DCC32 MAP Menus.Finalization. Prototype pending: no unique source declaration."

implementation
end.
