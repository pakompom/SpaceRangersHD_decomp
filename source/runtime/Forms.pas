unit Forms;

interface

type
  TScrollingWinControl = class(TWinControl) // @size 0x264
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure CreateWnd; override; // @slot 0xA4
    procedure AlignControls(AControl: TControl; var ARect: TRect); override; // @slot 0x94
    function AutoScrollEnabled: Boolean; virtual; // @slot 0xD8
    procedure DoFlipChildren;
    procedure CalcAutoRange;
    procedure SetAutoScroll(Value: Boolean);
    procedure UpdateScrollBars;
    procedure AutoScrollInView(AControl: TControl); virtual; // @slot 0xDC
    procedure ScrollInView(AControl: TControl);
    procedure ScaleScrollBars(M, D: Integer);
    procedure ChangeScale(M, D: Integer);
    procedure WMSize(var Message: TWMSize);
    procedure WMHScroll(var Message: TWMHScroll);
    procedure WMVScroll(var Message: TWMVScroll);
    procedure AdjustClientRect(var Rect: TRect); override; // @slot 0x90
    procedure CMBiDiModeChanged(var Message: TMessage);
  end;

  TCustomForm = class(TScrollingWinControl) // @size 0x35C
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    procedure AfterConstruction;
    procedure Resizing(State: TWindowState); virtual; // @slot 0xE0
    procedure BeforeDestruction;
    destructor Destroy;
    procedure DoCreate; virtual; // @slot 0xE4
    procedure DoDestroy; virtual; // @slot 0xE8
    procedure Loaded; override; // @slot 0xC
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    procedure ReadState(Reader: TReader); override; // @slot 0x14
    procedure DefineProperties(Filer: TFiler); override; // @slot 0x4
    procedure ReadIgnoreFontProperty(Reader: TReader);
    procedure ReadTextHeight(Reader: TReader);
    function GetLeft: Integer;
    function GetTop: Integer;
    procedure IconChanged(Sender: TObject);
    function IsFormSizeStored: Boolean;
    function IsAutoScrollStored: Boolean;
    procedure DoClose(var Action: TCloseAction);
    procedure DoHide;
    procedure DoShow;
    function GetClientRect: TRect; override; // @slot 0x44
    procedure GetChildren; // @nameonly
    function GetFloating: Boolean; override; // @slot 0x54
    procedure SetChildOrder(Child: TComponent; Order: Integer);
    procedure SetParentBiDiMode(Value: Boolean); override; // @slot 0x70
    procedure SetClientWidth(Value: Integer);
    procedure SetClientHeight(Value: Integer);
    procedure SetVisible(Value: Boolean);
    procedure SetParent(AParent: TWinControl); override; // @slot 0x6C
    procedure ValidateRename(AComponent: TComponent; const CurName, NewName: AnsiString); override; // @slot 0x20
    procedure ClientWndProc(var Message: TMessage);
    procedure AlignControls(AControl: TControl; var Rect: TRect); override; // @slot 0x94
    procedure CMBiDiModeChanged(var Message: TMessage);
    procedure CMParentBiDiModeChanged(var Message: TMessage);
    procedure CMPopupHwndDestroy(var Message: TCMPopupHWndDestroy);
    procedure GetBorderIconStyles(var Style, ExStyle: Cardinal);
    procedure SetBorderIcons(Value: TBorderIcons); // @ida "void __usercall $name(TCustomForm *Self@<eax>, TBorderIcons *Value@<edx>);"
    procedure GetBorderStyles(var Style, ExStyle, ClassStyle: Cardinal);
    procedure SetBorderStyle(Value: TFormBorderStyle);
    procedure Dock(NewDockSite: TWinControl; ARect: TRect);
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect);
    function GetActiveMDIChild: TForm;
    function GetMDIChildCount: Integer;
    function GetMDIChildren(I: Integer): TForm;
    function GetMonitor: TMonitor;
    function IsIconStored: Boolean;
    procedure SetFormStyle(Value: TFormStyle);
    procedure RefreshMDIMenu;
    procedure SetObjectMenuItem(Value: TMenuItem);
    procedure SetWindowMenu(Value: TMenuItem);
    procedure SetMenu(Value: TMainMenu);
    function GetPixelsPerInch: Integer;
    function GetPopupChildren: TList;
    function GetRecreateChildren: TList;
    procedure SetPixelsPerInch(Value: Integer);
    procedure SetPosition(Value: TPosition);
    procedure SetPopupMode(Value: TPopupMode);
    procedure SetPopupParent(Value: TCustomForm);
    procedure SetScaled(Value: Boolean);
    procedure CMColorChanged(var Message: TMessage);
    function NormalColor: TColor;
    procedure CMCtl3DChanged(var Message: TMessage);
    procedure CMFontChanged(var Message: TMessage);
    procedure CMMenuChanged(var Message: TMessage);
    procedure SetWindowState(Value: TWindowState);
    procedure SetWindowToMonitor;
    procedure CreateWnd; override; // @slot 0xA4
    procedure CreateWindowHandle(const Params: TCreateParams); override; // @ida "void __usercall $name(TCustomForm *Self@<eax>, TCreateParams *Params@<edx>);" @slot 0xA0
    procedure DestroyWindowHandle; override; // @slot 0xB4
    procedure DefaultHandler(Message: Pointer);
    procedure SetActiveControl(Control: TWinControl);
    procedure DefocusControl(Control: TWinControl; Removing: Boolean);
    procedure FocusControl(Control: TWinControl);
    procedure UpdateActions; virtual; // @slot 0xEC
    procedure SetWindowFocus;
    procedure SetActive(Value: Boolean);
    procedure SendCancelMode(Sender: TControl);
    procedure MergeMenu(MergeState: Boolean);
    procedure Activate;
    procedure Deactivate;
    procedure Paint;
    procedure PaintWindow(DC: Cardinal); override; // @slot 0xC4
    function PaletteChanged(Foreground: Boolean): Boolean;
    procedure WMPaint(var Message: TWMPaint);
    procedure WMNCPaint(var Message: TWMNCPaint);
    procedure WMIconEraseBkgnd(var Message: TWMIconEraseBkgnd);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
    procedure WMNCCreate(var Message: TWMNCCreate);
    procedure WMNCHitTest(var Message: TWMNCHitTest);
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown);
    procedure WMCommand(var Message: TWMCommand);
    procedure WMInitMenuPopup(var Message: TWMInitMenuPopup);
    procedure WMMenuChar(var Message: TWMMenuChar);
    procedure WMMenuSelect(var Message: TWMMenuSelect);
    procedure WMActivate(var Message: TWMActivate);
    constructor CreateNew(AOwner: TComponent; Dummy: Integer); virtual; // @slot 0xF0
    procedure WMQueryEndSession(var Message: TWMQueryEndSession);
    procedure CMAppSysCommand(var Message: TMessage);
    procedure WMSysCommand(var Message: TWMSysCommand);
    procedure WMShowWindow(var Message: TWMShowWindow);
    procedure WMMDIActivate(var Message: TWMMDIActivate);
    procedure WMEnterMenuLoop(var Message: TMessage);
    procedure WMHelp(var Message: TWMHelp);
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
    procedure WMNCCalcSize(var Message: TWMNCCalcSize);
    procedure CMActivate(var Message: TCMActivate);
    procedure CMDeactivate(var Message: TCMDeactivate);
    procedure CMDialogKey(var Message: TCMDialogKey);
    procedure CMIconChanged(var Message: TMessage);
    procedure CMTextChanged(var Message: TMessage);
    procedure CMParentFontChanged(var Message: TMessage);
    procedure CMIsShortCut(var Message: TWMKey);
    procedure Close;
    function CloseQuery: Boolean; virtual; // @slot 0xF4
    procedure CloseModal;
    procedure SetFocus; override; // @slot 0xD4
    procedure RecreateAsPopup(AWindowHandle: Cardinal);
    procedure Release;
    function SetFocusedControl(Control: TWinControl): Boolean; virtual; // @slot 0xF8
    function ShowModal: Integer; virtual; // @slot 0xFC
    procedure WMSettingChange(var Message: TMessage);
    function IsShortCut(var Message: TWMKey): Boolean;
    function QueryInterface(const IID: TGUID; Obj: Pointer): HResult; // @nameonly
    procedure MouseWheelHandler(var Message: TMessage);
    procedure SetLayeredAttribs;
    procedure SetTransparentColor(const Value: Boolean);
    procedure InitAlphaBlending(var Params: TCreateParams);
    procedure SetLeft(Value: Integer);
    procedure SetTop(Value: Integer);
  end;

  TControlScrollBar = class(TPersistent) // @size 0x48
  public
    constructor Create(AControl: TScrollingWinControl; AKind: TScrollBarKind);
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure ChangeBiDiPosition;
    procedure CalcAutoRange;
    function IsScrollBarVisible: Boolean;
    function ControlSize(ControlSB, AssumeSB: Boolean): Integer;
    function NeedsScrollBarVisible: Boolean;
    procedure ScrollMessage(var Msg: TWMScroll);
    procedure SetButtonSize(Value: Integer);
    procedure SetColor(Value: TColor);
    procedure SetPosition(Value: Integer);
    procedure SetSize(Value: Integer);
    procedure DoSetRange(Value: Integer);
    procedure SetRange(Value: Integer);
    procedure Update(ControlSB, AssumeSB: Boolean);
  end;

  TScrollBarKind = (sbHorizontal, sbVertical); // @size 0x1

  TGlassFrameElemnt = (geLeft, geTop, geRight, geBottom, geEnabled, geSheetOfGlass); // @size 0x1

  TCloseAction = (caNone, caHide, caFree, caMinimize); // @size 0x1

  TBorderIcon = (biSystemMenu, biMinimize, biMaximize, biHelp); // @size 0x1

  TBorderIcons = set of TBorderIcon; // @size 0x1

  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin); // @size 0x1

  TForm = class(TCustomForm) // @size 0x360
  end;

  TMonitor = class(TObject) // @size 0xC
  public
    function GetLeft: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    function GetBoundsRect: TRect;
    function GetWorkareaRect: TRect;
    function GetPrimary: Boolean;
  end;

  TFormStyle = (fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop); // @size 0x1

  TPosition = (poDesigned, poDefault, poDefaultPosOnly, poDefaultSizeOnly, poScreenCenter, poDesktopCenter, poMainFormCenter, poOwnerFormCenter); // @size 0x1

  TPopupMode = (pmNone, pmAuto, pmExplicit); // @size 0x1

  TWindowState = (wsNormal, wsMinimized, wsMaximized); // @size 0x1

  TDestroyPopupData = record;

  PDestroyPopupData = ^TDestroyPopupData;

  TCustomDockForm = class(TCustomForm) // @size 0x360
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    procedure DoAddDockClient(Client: TControl; const ARect: TRect);
    procedure DoRemoveDockClient(Client: TControl);
    procedure Loaded; override; // @slot 0xC
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure WMNCHitTest(var Message: TWMNCHitTest);
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown);
    procedure CMControlListChange(var Message: TMessage);
    procedure CMDockNotification(var Message: TCMDockNotification);
    procedure CMVisibleChanged(var Message: TMessage);
  end;

  TScreen = class(TComponent) // @size 0xA0
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    function GetMonitorCount: Integer;
    procedure UpdateLastActive;
    procedure AddForm(AForm: TCustomForm);
    procedure RemoveForm(AForm: TCustomForm);
    procedure CreateCursors;
    procedure DestroyCursors;
    procedure InsertCursor(Index: Integer; Handle: Cardinal);
    function GetImes: TStrings;
    function GetDefaultIME: AnsiString;
    procedure IconFontChanged(Sender: TObject);
    function GetCursors(Index: Integer): Cardinal;
    procedure SetCursor(Value: TCursor);
    procedure GetMetricSettings;
    procedure EnableAlign;
    procedure AlignForms(AForm: TCustomForm; var Rect: TRect);
    procedure AlignForm(AForm: TCustomForm);
    procedure ClearMonitors;
    procedure GetMonitors;
    function GetPrimaryMonitor: TMonitor;
  end;

  TApplication = class(TComponent) // @size 0x168
  public
    procedure Initialize; // @addr $45CA94 @note "Installed VCL Forms.pas:8077; calls System.InitProc when assigned. Native startup passes Application as Self."
    function GetExeName: AnsiString; // @addr $45D114 @note "Installed VCL getter: ParamStr(0)."
    property ExeName: AnsiString read GetExeName;
  public
    function CheckIniChange(var Message: TMessage): Boolean; // @addr $45BA4C @note "Native VCL variant additionally refreshes taskbar-owner visibility after resetting fonts; installed Delphi RTL lacks that tail. Identity and signature only, body unrecovered."
    procedure SetHandle(Value: Cardinal); // @addr $45C57C
    Active: Boolean; // @offset $A5
    OnDeactivate: TNotifyEvent; // @offset $130
    OnActivate: TNotifyEvent; // @offset $138
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure ControlDestroyed(Control: TControl);
    procedure DoNormalizeTopMosts(IncludeMain: Boolean);
    procedure ModalStarted;
    procedure ModalFinished;
    procedure RemovePopupForm(APopupForm: TCustomForm);
    procedure RestoreTopMosts;
    procedure DoShowOwnedPopups(Show: Boolean);
    function UseRightToLeftReading: Boolean;
    function UseRightToLeftAlignment: Boolean;
    procedure SettingChange(var Message: TWMSettingChange);
    function GetIconHandle: Cardinal;
    procedure Restore;
    function GetTitle: AnsiString;
    function IsDlgMsg(var Msg: TMsg): Boolean;
    function IsMDIMsg(var Msg: TMsg): Boolean;
    function IsKeyMsg(var Msg: TMsg): Boolean;
    function IsHintMsg(var Msg: TMsg): Boolean;
    function IsShortCut(var Message: TWMKey): Boolean;
    procedure PopupControlProc(var Message: TMessage);
    function ProcessMessage(var Msg: TMsg): Boolean;
    procedure HandleMessage;
    procedure HookMainWindow; // @nameonly
    procedure UnhookMainWindow; // @nameonly
    procedure HandleException(Sender: TObject);
    function MessageBox(const Text, Caption: PAnsiChar; Flags: Longint): Integer;
    procedure ShowException(E: Exception);
    function InvokeHelp(Command: Word; Data: Longint): Boolean;
    function DoOnHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
    function HelpKeyword(const Keyword: AnsiString): Boolean;
    function HelpContext(Context: THelpContext): Boolean;
    procedure SetShowHint(Value: Boolean);
    procedure DoActionIdle;
    function DoMouseIdle: TControl;
    procedure Idle(const Msg: TMsg);
    procedure NotifyForms(Msg: Word);
    procedure IconChanged(Sender: TObject);
    procedure SetHint(const Value: AnsiString);
    procedure UpdateVisible;
    function ValidateHelpSystem: Boolean;
    procedure StartHintTimer(Value: Integer; TimerMode: TTimerMode);
    procedure StopHintTimer;
    procedure HintMouseMessage(Control: TControl; var Message: TMessage);
    procedure HintTimerExpired;
    procedure HideHint;
    procedure CancelHint;
    procedure ActivateHint(CursorPos: TPoint);
    function AddPopupForm(APopupForm: TCustomForm): Integer;
    function GetCurrentHelpFile: AnsiString;
    function GetActiveFormHandle: Cardinal;
    function GetMainFormHandle: Cardinal;
    function DispatchAction(Msg: Longint; Action: TBasicAction): Boolean;
    function ExecuteAction(Action: TBasicAction): Boolean;
    function UpdateAction(Action: TBasicAction): Boolean;
    function IsPreProcessMessage(var Msg: TMsg): Boolean;
  end;

  TTimerMode = (tmShow, tmHide); // @size 0x1

  TCustomFormHelper = class // @partial
  public
    procedure ReadGlassFrameBottom(Reader: TReader);
    procedure ReadGlassFrameEnabled(Reader: TReader);
    procedure ReadGlassFrameLeft(Reader: TReader);
    procedure ReadGlassFrameRight(Reader: TReader);
    procedure ReadGlassFrameSheetOfGlass(Reader: TReader);
    procedure ReadGlassFrameTop(Reader: TReader);
    procedure UpdateGlassFrame(Sender: TObject);
    procedure WriteGlassFrameBottom(Writer: TWriter);
    procedure WriteGlassFrameEnabled(Writer: TWriter);
    procedure WriteGlassFrameLeft(Writer: TWriter);
    procedure WriteGlassFrameRight(Writer: TWriter);
    procedure WriteGlassFrameSheetOfGlass(Writer: TWriter);
    procedure WriteGlassFrameTop(Writer: TWriter);
  end;

  TGlassFrame = class(TPersistent) // @size 0x2C
  public
    constructor Create(Client: TCustomForm);
    procedure Assign(Source: TPersistent); virtual; // @slot 0x8
    procedure Change; virtual; // @slot 0xC
    function FrameExtended: Boolean;
    procedure SetEnabled(Value: Boolean);
    procedure SetExtendedFrame(Index: Integer; Value: Integer);
  end;

procedure ShowMDIClientEdge(ClientHandle: Cardinal; ShowEdge: Boolean);

procedure DoneApplication;

function DoDisableWindow(Window: Cardinal; Data: Longint): LongBool; stdcall;

function DisableTaskWindows(ActiveWindow: Cardinal): Pointer;

procedure EnableTaskWindows(WindowList: Pointer);

function DoFindWindow(Window: Cardinal; Param: Longint): LongBool; stdcall;

function FindTopMostWindow(ActiveWindow: Cardinal): Cardinal;

function SendFocusMessage(Window: Cardinal; Msg: Word): Boolean;

function CheckTaskWindow(Window: Cardinal; Data: Longint): LongBool; stdcall;

function CheckTaskWindowAll(Window: Cardinal; Data: Longint): LongBool; stdcall;

function ForegroundTaskCheck(CheckAll: Boolean): Boolean;

function FindGlobalComponent_451C2C(const Name: AnsiString): TComponent;

function KeysToShiftState(Keys: Word): TShiftState;

function KeyDataToShiftState(KeyData: Longint): TShiftState;

procedure KeyboardStateToShiftState; // @nameonly

function IsAccel(VK: Word; const Str: AnsiString): Boolean;

function GetRealParentForm(Control: TControl; TopForm: Boolean): TCustomForm;

function ValidParentForm(Control: TControl; TopForm: Boolean): TCustomForm;

procedure ProcessHorz(Control: TControl); // @nameonly

procedure ProcessVert(Control: TControl); // @nameonly

function ScrollBarVisible(Code: Word): Boolean; // @nameonly

function Adjustment(Code, Metric: Word): Integer; // @nameonly

function GetRealScrollPosition: Integer; // @nameonly

procedure UpdateScrollProperties(Redraw: Boolean); // @nameonly

function DoWriteGlassFrame(Element: TGlassFrameElemnt): Boolean; // @nameonly

procedure Default; // @nameonly

function MaximizedChildren: Boolean; // @nameonly

function EnumMonitorsProc(hm: Cardinal; dc: Cardinal; r: PRect; Data: Pointer): Boolean; stdcall;

function GetNonToolWindowPopupParent(WndParent: Cardinal): Cardinal;

function DestroyPopupWindow(Window: Cardinal; Data: PDestroyPopupData): LongBool; stdcall;

procedure DoNestedActivation(Msg: Cardinal; Control: TWinControl; Form: TCustomForm);

procedure ModifySystemMenu; // @nameonly

function GetMenuHelpContext(Menu: TMenu): Integer; // @nameonly

function ControlHasHelp(const Control: TWinControl): Boolean; // @nameonly

procedure GetHelpInfo(const Control: TWinControl; var HType: THelpType; var ContextID: Integer; var Keyword: AnsiString); // @nameonly

procedure HandleEdge(var Edge: Integer; SnapToEdge: Integer; SnapDistance: Integer); // @nameonly

procedure TraverseClients; // @nameonly

function ProcessExecute(Control: TControl): Boolean; // @nameonly

function ProcessUpdate(Control: TControl): Boolean; // @nameonly

function DispatchShortCut(const Owner: TComponent): Boolean; // @nameonly

function InsertBefore_45A764(C1, C2: TCustomForm; AAlign: TAlign): Boolean; // @nameonly

procedure DoPosition_45A7EC(Form: TCustomForm; AAlign: TAlign); // @nameonly

procedure DoAlign_45A9A8(AAlign: TAlign); // @nameonly

function AlignWork_45AAF8: Boolean; // @nameonly

function GetHint(Control: TControl): AnsiString;

function GetHintControl(Control: TControl): TControl;

procedure HintTimerProc(Wnd: Cardinal; Msg, TimerID, SysTime: Longint); stdcall;

procedure HintMouseThread(Param: Integer); stdcall;

function HintGetMsgHook(nCode: Integer; wParam: Longint; var Msg: TMsg): Longint; stdcall;

procedure HookHintHooks;

procedure UnhookHintHooks;

function GetAnimation: Boolean;

procedure SetAnimation(Value: Boolean);

procedure ShowWinNoAnimate(Handle: Cardinal; CmdShow: Integer);

function GetTopMostWindows(Handle: Cardinal; Info: Pointer): LongBool; stdcall;

function GetPopupOwnerWindows(Handle: Cardinal; Info: Pointer): LongBool; stdcall;

procedure Default_45BB34; // @nameonly

procedure DrawAppIcon; // @nameonly

function IsClass(Obj: TObject; Cls: TClass): Boolean;

procedure IdleTimerProc(Wnd: Cardinal; Msg, TimerID, SysTime: Longint); stdcall;

function GetCursorHeightMargin: Integer; // @nameonly

procedure ValidateHintWindow(HintClass: THintWindowClass); // @nameonly

function MultiLineWidth(const Value: AnsiString): Integer; // @nameonly

procedure FinalizeForms; // @nameonly

procedure ResolveSetLayeredWindowAttributes; // @addr 0x0045E118 @note "Resolves SetLayeredWindowAttributes from the loaded User32 module."

var
  Application: TApplication; // @addr $819CCC

implementation
end.
