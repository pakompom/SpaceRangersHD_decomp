unit Controls;

interface

type
  TControl = class(TComponent) // @size 0x190
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure SetParentComponent(Value: TComponent);
    function PaletteChanged(Foreground: Boolean): Boolean;
    procedure SetAnchors(Value: TAnchors);
    procedure SetAction(Value: TBasicAction);
    function IsAnchorsStored: Boolean;
    procedure SetDesignVisible(Value: Boolean);
    procedure Resize;
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    procedure SetAlign(Value: TAlign);
    procedure Loaded; virtual; // @slot 0xC
    procedure UpdateAnchorRules;
    procedure SetLeft(Value: Integer);
    procedure SetTop(Value: Integer);
    procedure SetWidth(Value: Integer);
    procedure SetHeight(Value: Integer);
    procedure Dock(NewDockSite: TWinControl; ARect: TRect);
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect);
    procedure SetHelpContext(const Value: THelpContext);
    procedure SetHelpKeyword(const Value: AnsiString);
    function GetBoundsRect: TRect;
    procedure SetBoundsRect(const Rect: TRect);
    procedure ReadState(Reader: TReader); virtual; // @slot 0x14
    function GetClientWidth: Integer;
    procedure SetClientWidth(Value: Integer);
    function GetClientHeight: Integer;
    procedure SetClientHeight(Value: Integer);
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; virtual; // @slot 0x30
    function ClientToScreen(const Point: TPoint): TPoint;
    procedure ScaleConstraints(M, D: Integer);
    function ScreenToClient(const Point: TPoint): TPoint;
    procedure SendCancelMode(Sender: TControl);
    procedure SendDockNotification(Msg: Cardinal; WParam, LParam: Integer);
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); virtual; // @slot 0x38
    procedure SetName(const Value: TComponentName); override; // @slot 0x18
    procedure SetClientSize(Value: TPoint);
    function GetClientOrigin: TPoint; virtual; // @slot 0x40
    procedure SetVisible(Value: Boolean);
    function GetClientRect: TRect; virtual; // @slot 0x44
    procedure SetPopupMenu(Value: TPopupMenu);
    procedure SetTextBuf(Buffer: PAnsiChar);
    function GetText: TCaption;
    procedure SetText(const Value: TCaption);
    function GetDeviceContext(var WindowHandle: Cardinal): Cardinal; virtual; // @slot 0x48
    procedure FontChanged(Sender: TObject);
    procedure SetParentFont(Value: Boolean);
    procedure SetShowHint(Value: Boolean);
    procedure SetColor(Value: TColor);
    procedure SetParentColor(Value: Boolean);
    function GetFloating: Boolean; virtual; // @slot 0x54
    procedure SetMouseCapture(Value: Boolean);
    procedure SetZOrderPosition(Position: Integer);
    procedure SetZOrder(TopMost: Boolean);
    procedure SetAutoSize(Value: Boolean); virtual; // @slot 0x60
    procedure InvalidateControl(IsVisible, IsOpaque: Boolean);
    function MouseActivate(Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer): TMouseActivate;
    procedure MouseWheelHandler(var Message: TMessage);
    procedure SetEnabled(Value: Boolean); virtual; // @slot 0x68
    procedure SetParent(AParent: TWinControl); virtual; // @slot 0x6C
    function UseRightToLeftReading: Boolean;
    function UseRightToLeftAlignment: Boolean;
    function UseRightToLeftScrollBar: Boolean;
    procedure BeginDrag(Immediate: Boolean; Threshold: Integer);
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DragDrop(Source: TObject; X, Y: Integer);
    procedure DoStartDrag(var DragObject: TDragObject);
    procedure DoEndDrag(Target: TObject; X, Y: Integer);
    procedure PositionDockRect(DragDockObject: TDragDockObject);
    procedure DockTrackNoTarget(Source: TDragDockObject; X, Y: Integer);
    procedure DoEndDock(Target: TObject; X, Y: Integer);
    procedure DoStartDock(var DragObject: TDragObject);
    procedure DoMouseActivate(var Message: TCMMouseActivate);
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
    procedure DefaultDockImage(DragDockObject: TDragDockObject; Erase: Boolean);
    procedure DoDragMsg(var DragMsg: TCMDrag);
    function ManualDock(NewDockSite: TWinControl; DropControl: TControl; ControlSide: TAlign): Boolean;
    function ManualFloat(ScreenPos: TRect): Boolean;
    procedure SetParentBiDiMode(Value: Boolean); virtual; // @slot 0x70
    function DoCanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
    function DoCanResize(var NewWidth, NewHeight: Integer): Boolean;
    procedure SetBiDiMode(Value: TBiDiMode); virtual; // @slot 0x74
    function CalcCursorPos: TPoint;
    function DesignWndProc(var Message: TMessage): Boolean;
    procedure DoConstrainedResize(var NewWidth, NewHeight: Integer);
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure CalcDockSizes;
    procedure UpdateBoundsRect(const R: TRect);
    procedure WndProc(var Message: TMessage); virtual; // @slot 0x78
    procedure DefaultHandler(Message: Pointer);
    procedure DefineProperties(Filer: TFiler); override; // @slot 0x4
    procedure Click;
    procedure DblClick;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseDown(var Message: TWMMouse; Button: TMouseButton; Shift: TShiftState);
    procedure WMLButtonDown(var Message: TWMLButtonDown);
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown);
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
    function CheckNewSize(var NewWidth, NewHeight: Integer): Boolean;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure WMMouseMove(var Message: TWMMouseMove);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUp(var Message: TWMMouse; Button: TMouseButton);
    procedure WMLButtonUp(var Message: TWMLButtonUp);
    procedure WMRButtonUp(var Message: TWMRButtonUp); // @nameonly
    procedure WMMButtonUp(var Message: TWMMButtonUp);
    procedure WMMouseWheel(var Message: TWMMouseWheel);
    procedure WMCancelMode(var Message: TWMCancelMode);
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
    procedure CMVisibleChanged(var Message: TMessage);
    procedure CMParentColorChanged(var Message: TMessage);
    procedure CMParentBiDiModeChanged(var Message: TMessage);
    procedure CMMouseWheel(var Message: TCMMouseWheel);
    procedure CMBiDiModeChanged(var Message: TMessage);
    procedure CMParentShowHintChanged(var Message: TMessage);
    procedure CMParentFontChanged(var Message: TMessage);
    procedure CMSysFontChanged(var Message: TMessage);
    procedure CMMouseEnter(var Message: TMessage);
    procedure CMMouseLeave(var Message: TMessage);
    function CreateFloatingDockSite(Bounds: TRect): TWinControl;
    procedure CMFloat(var Message: TCMFloat);
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean);
    procedure DoActionChange(Sender: TObject);
    function IsEnabledStored: Boolean;
    function IsHintStored: Boolean;
    function IsHelpContextStored: Boolean;
    function IsVisibleStored: Boolean;
    procedure Repaint; virtual; // @slot 0x84
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); virtual; // @slot 0x88
    function GetDockEdge(MousePos: TPoint): TAlign;
    procedure Update; virtual; // @slot 0x8C
    procedure AdjustSize;
    function DrawTextBiDiModeFlagsReadingOnly: Longint;
    procedure CMHintShow(var Message: TMessage);
    procedure WMContextMenu(var Message: TWMContextMenu);
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean);
    procedure CMMouseActivate(var Message: TCMMouseActivate);
    procedure SetAlignWithMargins(Value: Boolean);
    procedure UpdateExplicitBounds;
    procedure ReadExplicitWidth(Reader: TReader);
    procedure ReadExplicitTop(Reader: TReader);
    procedure ReadExplicitHeight(Reader: TReader);
    procedure ReadExplicitLeft(Reader: TReader);
  end;

  TWinControl = class(TControl) // @size 0x24C
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure FixupTabList;
    procedure ReadState(Reader: TReader); override; // @slot 0x14
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; virtual; // @slot 0x34
    procedure ArrangeControl(AControl: TControl; const ParentSize: TPoint; AAlign: TAlign; AAlignInfo: TAlignInfo; var Rect: TRect; UpdateAnchorOrigin: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TControl *AControl@<edx>, TPoint *ParentSize@<ecx>, TAlign AAlign@<^12>, TAlignInfo *AAlignInfo@<^8>, TRect *Rect@<^4>, bool UpdateAnchorOrigin@<^0>);"
    procedure AdjustClientRect(var Rect: TRect); virtual; // @slot 0x90
    procedure AlignControl(AControl: TControl);
    procedure EnableAlign;
    procedure DoFlipChildren;
    procedure FlipChildren(AllLevels: Boolean);
    function ContainsControl(Control: TControl): Boolean;
    procedure RemoveFocus(Removing: Boolean);
    procedure Insert(AControl: TControl);
    procedure Remove(AControl: TControl);
    procedure InsertControl(AControl: TControl);
    procedure RemoveControl(AControl: TControl);
    function GetControl(Index: Integer): TControl;
    function GetControlCount: Integer;
    procedure Broadcast(Message: Pointer);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    procedure NotifyControls(Msg: Word);
    procedure AddBiDiModeExStyle(var ExStyle: DWord);
    procedure AlignControls(AControl: TControl; var Rect: TRect); virtual; // @slot 0x94
    procedure CreateHandle; virtual; // @slot 0x98
    procedure CreateParams(var Params: TCreateParams); virtual; // @slot 0x9C
    procedure ReadDesignSize(Reader: TReader);
    procedure WriteDesignSize(Writer: TWriter);
    procedure DefineProperties(Filer: TFiler); override; // @slot 0x4
    procedure CreateWindowHandle(const Params: TCreateParams); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TCreateParams *Params@<edx>);" @slot 0xA0
    procedure CreateWnd; virtual; // @slot 0xA4
    function PrecedingWindow(Control: TWinControl): Cardinal;
    function CustomAlignInsertBefore(C1, C2: TControl): Boolean; virtual; // @slot 0xA8
    procedure CustomAlignPosition(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo); virtual; // @ida "void __userpurge $name(TWinControl *Self@<eax>, TControl *Control@<edx>, __int32 *NewLeft@<ecx>, __int32 *NewTop@<^16>, __int32 *NewWidth@<^12>, __int32 *NewHeight@<^8>, TRect *AlignRect@<^4>, TAlignInfo *AlignInfo@<^0>);" @slot 0xAC
    procedure DestroyHandle; virtual; // @slot 0xB0
    procedure DestroyWindowHandle; virtual; // @slot 0xB4
    procedure RecreateWnd;
    procedure CMRecreateWnd(var Message: TMessage);
    procedure SetParentWindow(Value: Cardinal);
    procedure MainWndProc(var Message: TMessage);
    function ControlAtPos(const Pos: TPoint; AllowDisabled, AllowWinControls, AllLevels: Boolean): TControl;
    function IsControlActivateMsg(var Message: TWMMouseActivate; Control: TControl): Boolean;
    function IsControlMouseMsg(var Message: TWMMouse): Boolean;
    procedure DefaultHandler(Message: Pointer);
    procedure PaintHandler(var Message: TWMPaint);
    procedure DestroyWnd; virtual; // @slot 0xB8
    procedure PaintControls(DC: Cardinal; First: TControl);
    procedure PaintTo; // @nameonly
    procedure WMNotify(var Message: TWMNotify);
    procedure WMSysColorChange(var Message: TWMSysColorChange);
    procedure WMCompareItem(var Message: TWMCompareItem);
    procedure WMDeleteItem(var Message: TWMDeleteItem);
    procedure WMDrawItem(var Message: TWMDrawItem);
    procedure WMMeasureItem(var Message: TWMMeasureItem);
    procedure WMMouseActivate(var Message: TWMMouseActivate);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
    procedure WMSize(var Message: TWMSize);
    procedure WMMove(var Message: TWMMove);
    procedure WMSetFocus(var Message: TWMSetFocus);
    procedure WMKillFocus(var Message: TWMSetFocus);
    procedure WMIMEStartComp(var Message: TMessage);
    procedure WMIMEEndComp(var Message: TMessage);
    procedure SetIme;
    procedure ResetIme;
    procedure DoEnter;
    procedure DoExit;
    procedure DockDrop(Source: TDragDockObject; X, Y: Integer);
    procedure DoDockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    function DoUnDock(NewTarget: TWinControl; Client: TControl): Boolean;
    procedure ReloadDockedControl(const AControlName: AnsiString; var AControl: TControl);
    function GetDockClients(Index: Integer): TControl;
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    function GetVisibleDockClientCount: Integer;
    function CreateDockManager: IDockManager;
    procedure SetDesignVisible(Value: Boolean);
    procedure SetDockSite(Value: Boolean);
    procedure CMDockClient(var Message: TCMDockClient);
    procedure CMUnDockClient(var Message: TCMUnDockClient);
    procedure CMFloat(var Message: TCMFloat);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    function DoKeyDown(var Message: TWMKey): Boolean;
    procedure KeyUp(var Key: Word; Shift: TShiftState);
    function DoKeyUp(var Message: TWMKey): Boolean;
    procedure KeyPress(var Key: Char);
    function DoKeyPress(var Message: TWMKey): Boolean;
    procedure WMSysCommand(var Message: TWMSysCommand);
    procedure WMParentNotify(var Message: TWMParentNotify);
    procedure WMDestroy(var Message: TWMDestroy);
    procedure WMNCDestroy(var Message: TWMNCDestroy);
    procedure WMNCHitTest(var Message: TWMNCHitTest);
    function PaletteChanged(Foreground: Boolean): Boolean;
    procedure WMQueryNewPalette(var Message: TMessage);
    procedure WMPaletteChanged(var Message: TMessage);
    procedure CMShowHintChanged(var Message: TMessage);
    procedure CMBiDiModeChanged(var Message: TMessage);
    procedure CMEnter(var Message: TCMEnter);
    procedure CMDesignHitTest(var Message: TCMDesignHitTest);
    procedure CMVisibleChanged(var Message: TMessage);
    procedure CMShowingChanged(var Message: TMessage);
    procedure CMEnabledChanged(var Message: TMessage);
    procedure CMColorChanged(var Message: TMessage);
    procedure CMFontChanged(var Message: TMessage);
    procedure CMCursorChanged(var Message: TMessage);
    procedure CMBorderChanged(var Message: TMessage);
    procedure CMCtl3DChanged(var Message: TMessage);
    procedure CMParentCtl3DChanged(var Message: TMessage);
    procedure CMDrag(var Message: TCMDrag);
    procedure CMSysFontChanged(var Message: TMessage);
    function IsMenuKey(var Message: TWMKey): Boolean;
    procedure CNKeyDown(var Message: TWMKeyDown);
    procedure CNKeyUp(var Message: TWMKeyUp);
    procedure CNChar(var Message: TWMChar);
    procedure CNSysKeyDown(var Message: TWMKeyDown);
    procedure CNSysChar(var Message: TWMChar);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override; // @slot 0x88
    procedure ScaleControls(M, D: Integer);
    procedure ChangeScale(M, D: Integer);
    procedure ScrollBy(DeltaX, DeltaY: Integer);
    function GetControlExtents: TRect; virtual; // @slot 0xC0
    procedure SetZOrderPosition(Position: Integer);
    procedure SetZOrder(TopMost: Boolean);
    function GetDeviceContext(var WindowHandle: Cardinal): Cardinal; override; // @slot 0x48
    procedure CMInvalidate(var Message: TMessage);
    procedure Update; override; // @slot 0x8C
    procedure Repaint; override; // @slot 0x84
    procedure InvalidateFrame;
    function CanFocus: Boolean;
    procedure PaintWindow(DC: Cardinal); virtual; // @slot 0xC4
    function Focused: Boolean;
    procedure HandleNeeded;
    procedure SetParentBackground(Value: Boolean); virtual; // @slot 0xC8
    function GetClientOrigin: TPoint; override; // @slot 0x40
    procedure SetBorderWidth; // @nameonly
    procedure SetCtl3D(Value: Boolean);
    function GetTabOrder: TTabOrder;
    procedure UpdateTabOrder(Value: TTabOrder);
    procedure SetUseDockManager(Value: Boolean);
    procedure UpdateBounds;
    procedure GetTabOrderList(List: TList);
    function FindNextControl(CurControl: TWinControl; GoForward, CheckTabStop, CheckParent: Boolean): TWinControl;
    procedure SelectNext(CurControl: TWinControl; GoForward, CheckTabStop: Boolean);
    procedure GetChildren; // @nameonly
    procedure SetChildOrder(Child: TComponent; Order: Integer);
    procedure CalcConstraints(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); override; // @slot 0x38
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean);
    procedure AssignTo(Dest: TPersistent); override; // @slot 0x0
    procedure ShowControl(AControl: TControl); virtual; // @slot 0xCC
    procedure WMNCCalcSize(var Message: TWMNCCalcSize);
    procedure WMNCPaint(var Message: TMessage);
    procedure WMContextMenu(var Message: TWMContextMenu);
    procedure UpdateUIState(CharCode: Word);
    procedure WMPrintClient(var Message: TWMPrintClient);
    procedure UpdateControlOriginalParentSize(AControl: TControl; var AOriginalParentSize: TPoint); virtual; // @slot 0xD0
    procedure CMTextChanged(var Message: TMessage);
    procedure InvalidateDockHostSite;
    procedure RemoveWindowProps;
    function IsQualifyingSite(const Client: TControl): Boolean;
    procedure UpdateRecreatingFlag(Recreating: Boolean);
    procedure SetFocus; virtual; // @slot 0xD4
    procedure SetParent(AParent: TWinControl); override; // @slot 0x6C
  end;

  TSiteList = class(TList) // @size 0x10
  public
    function Find(ParentWnd: Cardinal; var Index: Integer): Boolean;
    procedure AddSite(ASite: TWinControl);
    procedure Clear; override; // @slot 0x8
    function GetTopSite: TWinControl;
  end;

  TDragObject = class(TObject) // @size 0x3C
  public
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; virtual; // @slot 0x4
    procedure WndProc(var Msg: TMessage); virtual; // @slot 0xC
    procedure Assign(Source: TDragObject); virtual; // @slot 0x10
    function GetName: AnsiString; virtual; // @slot 0x14
  end;

  TCursor = SmallInt;

  TBaseDragControlObject = class(TDragObject) // @size 0x44
  public
    procedure Finished(Target: TObject; X, Y: Integer; Accepted: Boolean); virtual; // @slot 0x0
    procedure Assign(Source: TDragObject); override; // @slot 0x10
    procedure EndDrag(Target: TObject; X, Y: Integer); virtual; // @slot 0x24
    constructor Create(AControl: TControl); virtual; // @slot 0x28
  end;

  TDragControlObject = class(TBaseDragControlObject) // @size 0x48
  public
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override; // @slot 0x4
  end;

  TDragDockObject = class(TBaseDragControlObject) // @size 0x78
  public
    constructor Create(AControl: TControl); override; // @slot 0x28
    destructor Destroy;
    procedure Assign(Source: TDragObject); override; // @slot 0x10
    procedure EndDrag(Target: TObject; X, Y: Integer); override; // @slot 0x24
    procedure AdjustDockRect(ARect: TRect); virtual; // @slot 0x2C
  end;

  TDragMessage = (dmDragEnter, dmDragLeave, dmDragMove, dmDragDrop, dmDragCancel, dmFindTarget); // @size 0x1

  TDragKind = (dkDrag, dkDock); // @size 0x1

  TControlCanvas = class(TCanvas) // @size 0x64
  public
    procedure CreateHandle; virtual; // @slot 0x14
    procedure FreeHandle;
    procedure SetControl(AControl: TControl);
    procedure UpdateTextFlags;
  end;

  TSizeConstraints = class(TPersistent) // @size 0x20
  public
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure SetConstraints; // @nameonly
  end;

  TControlActionLink = class(TActionLink) // @size 0x1C
  public
    function IsOnExecuteLinked: Boolean; virtual; // @slot 0x8
    function IsCaptionLinked: Boolean; virtual; // @slot 0x20
    function IsEnabledLinked: Boolean; virtual; // @slot 0x28
    function IsHelpLinked: Boolean; virtual; // @slot 0x34
    function IsHintLinked: Boolean; virtual; // @slot 0x38
    function IsVisibleLinked: Boolean; virtual; // @slot 0x44
    procedure SetEnabled(Value: Boolean); virtual; // @slot 0x54
    procedure SetHelpType(Value: THelpType); virtual; // @slot 0x64
    procedure SetHint(const Value: AnsiString); virtual; // @slot 0x68
    procedure SetOnExecute; // @nameonly
    function IsPopupMenuLinked: Boolean; virtual; // @slot 0x80
    function DoShowHint(var HintStr: AnsiString): Boolean; virtual; // @slot 0x84
    procedure SetPopupMenu(Value: TPopupMenu); virtual; // @slot 0x90
  end;

  TAnchorKind = (akLeft, akTop, akRight, akBottom); // @size 0x1

  TAnchors = set of TAnchorKind; // @size 0x1

  TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom); // @size 0x1

  TCaption = AnsiString;

  TMouseButton = (mbLeft, mbRight, mbMiddle); // @size 0x1

  TMouseActivate = (maDefault, maActivate, maActivateAndEat, maNoActivate, maNoActivateAndEat); // @size 0x1

  TDragState = (dsDragEnter, dsDragLeave, dsDragMove); // @size 0x1

  TCMMouseActivate = record;

  TCMDrag = record;

  TExplicitDimension = (edLeft, edTop, edWidth, edHeight); // @size 0x1

  TCMMouseWheel = record;

  TCMFloat = record;

  TWinControlActionLink = class(TControlActionLink) // @size 0x24
  public
    procedure AssignClient(AClient: TObject); virtual; // @slot 0x0
  end;

  TAlignInfo = record;

  TCreateParams = record;

  TDestroyChildData = record;

  PDestroyChildData = ^TDestroyChildData;

  IDockManager = interface;

  TCMDockClient = record;

  TCMUnDockClient = record;

  TCMEnter = TWMNoParams;

  TCMDesignHitTest = TWMMouse;

  TTabOrder = SmallInt;

  TCustomControl = class(TWinControl) // @size 0x254
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure WMPaint(var Message: TWMPaint);
    procedure PaintWindow(DC: Cardinal); override; // @slot 0xC4
  end;

  THintWindow = class(TCustomControl) // @size 0x260
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    procedure CreateParams(var Params: TCreateParams); override; // @slot 0x9C
    procedure WMNCPaint(var Message: TMessage);
    procedure Paint; virtual; // @slot 0xD8
    procedure NCPaint(DC: Cardinal); virtual; // @slot 0xDC
    procedure CMTextChanged(var Message: TMessage);
    procedure ActivateHintData(Rect: TRect; const AHint: AnsiString; AData: Pointer); virtual; // @slot 0xE4
    function CalcHintRect(MaxWidth: Integer; const AHint: AnsiString; AData: Pointer): TRect; virtual; // @slot 0xE8
    function IsHintMsg(var Msg: TMsg): Boolean; virtual; // @slot 0xEC
    procedure WMPrint(var Message: TMessage);
  end;

  TDragImageList = class(TCustomImageList) // @partial
  public
    function SetDragImage(Index, HotSpotX, HotSpotY: Integer): Boolean;
    procedure SetDragCursor(Value: TCursor);
    function BeginDrag(Window: Cardinal; X, Y: Integer): Boolean;
    function DragLock(Window: Cardinal; XPos, YPos: Integer): Boolean;
    procedure DragUnlock;
    function DragMove(X, Y: Integer): Boolean;
    function EndDrag: Boolean;
  end;

  TDockZone = class(TObject) // @size 0x28
  public
    constructor Create(Tree: TDockTree);
    function GetChildCount: Integer;
    function GetVisibleChildCount: Integer;
    function GetVisible: Boolean;
    function GetTopLeft(Orient: Integer): Integer;
    function GetHeightWidth(Orient: Integer): Integer;
    procedure ResetChildren;
    function GetControlName: AnsiString;
    function SetControlName(const Value: AnsiString): Boolean;
    procedure Update;
    function GetZoneLimit: Integer;
    procedure ExpandZoneLimit(NewLimit: Integer);
    procedure ResetZoneLimits;
    function PrevVisible: TDockZone;
  end;

  TDockTree = class(TInterfacedObject) // @size 0x7C
  public
    procedure AdjustDockRect(Control: TControl; var ARect: TRect); virtual; // @slot 0x0
    destructor Destroy;
    procedure AdjustFrameRect(Control: TControl; var ARect: TRect); virtual; // @slot 0x4
    procedure EndUpdate;
    function FindControlZone(Control: TControl): TDockZone;
    procedure ForEachAt; // @nameonly
    procedure GetControlBounds(Control: TControl; out CtlBounds: TRect);
    procedure InsertControl(Control: TControl; InsertAt: TAlign; DropCtl: TControl); virtual; // @slot 0xC
    procedure InsertNewParent(NewZone, SiblingZone: TDockZone; ParentOrientation: TDockOrientation; InsertLast: Boolean);
    procedure InsertSibling(NewZone, SiblingZone: TDockZone; InsertLast: Boolean);
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x10
    function FindControlAtPos(const Pos: TPoint): TControl;
    function InternalHitTest(const MousePos: TPoint; out HTFlag: Integer): TDockZone;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @slot 0x14
    procedure MouseMove(Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @slot 0x18
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @slot 0x1C
    procedure PaintDockFrame(Canvas: TCanvas; Control: TControl; const ARect: TRect); virtual; // @slot 0x20
    procedure PruneZone(Zone: TDockZone);
    procedure PositionDockRect(Client, DropCtl: TControl; DropAlign: TAlign; var DockRect: TRect); virtual; // @slot 0x24
    procedure RemoveZone(Zone: TDockZone);
    procedure RemoveControl(Control: TControl); virtual; // @slot 0x2C
    procedure ScaleZone(Zone: TDockZone);
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x30
    procedure SetNewBounds(Zone: TDockZone);
    procedure SetReplacingControl(Control: TControl);
    procedure ShiftZone(Zone: TDockZone);
    procedure SplitterMouseDown(OnZone: TDockZone; MousePos: TPoint);
    procedure SplitterMouseUp;
    procedure UpdateAll;
    procedure WindowProc(var Message: TMessage);
    procedure DrawSizeSplitter;
    function GetNextLimit(AZone: TDockZone): Integer;
    procedure ControlVisibilityChanged(Control: TControl; Visible: Boolean);
    procedure ShowHint(CursorPos: TPoint; var CursorRect: TRect; var HintStr: AnsiString); virtual; // @slot 0x34
    function ActualSize(const RelativeSize, Reference: Integer): Integer;
    function RelativeSize(const ActualSize, Reference: Integer): Integer;
    procedure ResetBounds(Force: Boolean); virtual; // @slot 0x38
    procedure WndProc(var Message: TMessage); virtual; // @slot 0x3C
    function ZoneCaptionHitTest(const Zone: TDockZone; const MousePos: TPoint; var HTFlag: Integer): Boolean; virtual; // @slot 0x40
    constructor Create(DockSite: TWinControl); virtual; // @slot 0x44
    procedure PaintSite(DC: Cardinal); virtual; // @slot 0x48
  end;

  TDockOrientation = (doNoOrient, doHorizontal, doVertical); // @size 0x1

  TMouse = class(TObject) // @size 0x30
  public
    constructor Create;
    function CreatePanningWindow: TCustomPanningWindow;
    function GetIsPanning: Boolean;
    procedure GetMouseData;
    procedure GetNativeData;
    procedure GetRegisteredData;
    procedure SetCapture(const Value: Cardinal);
    procedure SetPanningWindow(const Value: TCustomPanningWindow);
    procedure SettingChanged(Setting: Integer);
  end;

  TCustomPanningWindow = class(TCustomControl) // @partial
  end;

  TImeMode = (imDisable, imClose, imOpen, imDontCare, imSAlpha, imAlpha, imHira, imSKata, imKata, imChinese, imSHanguel, imHanguel); // @size 0x1

  TControlMargins = class(TPersistent) // @size 0x20
  public
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    class procedure InitDefaults(Margins: TControlMargins); virtual; // @slot 0x14
    function GetControlBound(Index: Integer): Integer; virtual; // @slot 0x10
    procedure SetControlBounds; // @nameonly
    constructor Create(Control: TControl); virtual; // @slot 0x18
  end;

  TCMPopupHWndDestroy = record;

  TCMActivate = TWMNoParams;

  TCMDeactivate = TWMNoParams;

  TCMDialogKey = TWMKey;

  TCMDockNotification = record;

  THintWindowClass = class of THintWindow;

function InitWndProc(HWindow: Cardinal; Message, WParam, LParam: Longint): Longint; // @nameonly

function ObjectFromHWnd(Handle: Cardinal): TWinControl;

function FindControl(Handle: Cardinal): TWinControl;

function IsVCLControl(Handle: Cardinal): Boolean;

function SendAppMessage(Msg: Cardinal; WParam, LParam: Longint): Longint;

function GetShortHint(const Hint: AnsiString): AnsiString;

function GetLongHint(const Hint: AnsiString): AnsiString;

procedure PerformEraseBackground(Control: TControl; DC: Cardinal);

function GetCaptureControl: TControl;

procedure SetCaptureControl(Control: TControl);

function GetTopParent: Cardinal; // @nameonly

function AbsMin(Value1, Value2: Integer): Integer; // @nameonly

function IsBeforeTargetWindow(Window: Cardinal; Data: Longint): LongBool; stdcall;

function ValidDockTarget(Target: TWinControl): Boolean; // @nameonly

function IsSiteChildOfClient: Boolean; // @nameonly

function GetDockSiteAtPos(MousePos: TPoint; Client: TControl): TWinControl;

procedure RegisterDockSite(Site: TWinControl; DoRegister: Boolean);

function DragMessage(Handle: Cardinal; Msg: TDragMessage; Source: TDragObject; Target: Pointer; const Pos: TPoint): Longint;

function IsDelphiHandle(Handle: Cardinal): Boolean;

procedure DragFindWindow; // @nameonly

function DragFindTarget(const Pos: TPoint; var Handle: Cardinal; DragKind: TDragKind; Client: TControl): Pointer;

function DoDragOver(DragMsg: TDragMessage): Boolean;

function GetDropCtl: TControl; // @nameonly

procedure DragTo; // @nameonly

procedure DragInit(ADragObject: TDragObject; Immediate: Boolean; Threshold: Integer);

procedure DragInitControl(Control: TControl; Immediate: Boolean; Threshold: Integer);

function CheckUndock: Boolean; // @nameonly

procedure DragDone(Drop: Boolean);

function FindVCLWindow(const Pos: TPoint): TWinControl;

function FindDragTarget(const Pos: TPoint; AllowDisabled: Boolean): TControl;

procedure ListAdd(var List: TList; Item: Pointer);

procedure ListRemove(var List: TList; Item: Pointer);

procedure MoveWindowOrg(DC: Cardinal; DX, DY: Integer);

procedure FreeDeviceContext;

function BackgroundClipped: Boolean; // @nameonly

function DoWriteIsControl: Boolean; // @nameonly

function DoWriteExplicit(Dim: TExplicitDimension): Boolean; // @nameonly

procedure SetParentColor(Value: TColor); // @nameonly

procedure UpdateFloatingDockSitePos; // @nameonly

function MinVar(const Data: array of Double): Integer; // @nameonly

function GetClientSize(Control: TWinControl): TPoint; // @nameonly

function InsertBefore(C1, C2: TControl; AAlign: TAlign): Boolean; // @nameonly

procedure DoPosition(Control: TControl; AAlign: TAlign; AlignInfo: TAlignInfo); // @nameonly

procedure DoAlign(AAlign: TAlign); // @nameonly

function AlignWork: Boolean; // @nameonly

function PointsEqual(const P1, P2: TPoint): Boolean; // @nameonly

function DoWriteDesignSize: Boolean; // @nameonly

function DestroyChildWindow(Window: Cardinal; Data: PDestroyChildData): LongBool; stdcall;

function GetControlAtPos(AControl: TControl): Boolean; // @nameonly

function DoControlMsg(ControlHandle: Cardinal; Message: Pointer): Boolean;

procedure DrawThemeEdge(DC: Cardinal; var DrawRect: TRect); // @nameonly

function TraverseControls(Container: TWinControl): Boolean; // @nameonly

procedure DoCalcConstraints(Control: TControl; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); // @nameonly

function ClientToWindow(Handle: Cardinal; X, Y: Integer): TPoint;

function NextVisibleZone(StartZone: TDockZone): TDockZone;

function IsOrientationSet(Zone: TDockZone): Boolean;

function ParentNotLast: Boolean; // @nameonly

procedure DoFindControlZone(StartZone: TDockZone); // @nameonly

procedure DoForEach(Zone: TDockZone); // @nameonly

procedure DoFindZone(Zone: TDockZone); // @nameonly

procedure ReadControlName(var ControlName: AnsiString); // @nameonly

procedure DrawCloseButton(Left, Top: Integer); // @nameonly

procedure DrawGrabberLine(Left, Top, Right, Bottom: Integer); // @nameonly

procedure DrawThemedGrabber(const GripperType: TThemedReBar; const Left, Top, Right, Bottom: Integer); // @nameonly

procedure DoPrune(Zone: TDockZone); // @nameonly

procedure WriteControlName(ControlName: AnsiString); // @nameonly

procedure DoSaveZone(Zone: TDockZone; Level: Integer); // @nameonly

procedure DoSetNewBounds(Zone: TDockZone); // @nameonly

procedure DoGetNextLimit(Zone: TDockZone); // @nameonly

function GetDockAlign(Client, DropCtl: TControl): TAlign; // @nameonly

procedure HideZone(const Zone: TDockZone); // @nameonly

procedure ShowZone(const Zone: TDockZone); // @nameonly

procedure CalcSplitterPos; // @nameonly

procedure InitIMM32;

function Win32NLSEnableIME(hWnd: Cardinal; Enable: Boolean): Boolean;

procedure SetImeMode(hWnd: Cardinal; Mode: TImeMode);

procedure DoneControls;

procedure InitControls;

procedure FinalizeControls; // @nameonly

implementation
end.
