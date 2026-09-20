unit Forms;
// Unit bracket (inferred): .text 0x0044F674..0x0045E7BF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008766AC..0x0087670B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TScrollingWinControl = class(TWinControl) // @size 0x264
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Forms.TScrollingWinControl.Create. Source vcl/Forms.pas:2336." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Forms.TScrollingWinControl.Destroy. Source vcl/Forms.pas:2345."
    procedure CreateWnd; override; // @note "DCC32 MAP Forms.TScrollingWinControl.CreateWnd. Source vcl/Forms.pas:2359." @slot 0xA4
    procedure AlignControls(AControl: TControl; var ARect: TRect); override; // @note "DCC32 MAP Forms.TScrollingWinControl.AlignControls. Source vcl/Forms.pas:2371." @slot 0x94
    function AutoScrollEnabled: Boolean; virtual; // @note "DCC32 MAP Forms.TScrollingWinControl.AutoScrollEnabled. Source vcl/Forms.pas:2377." @slot 0xD8
    procedure DoFlipChildren; // @note "DCC32 MAP Forms.TScrollingWinControl.DoFlipChildren. Source vcl/Forms.pas:2382."
    procedure CalcAutoRange; // @note "DCC32 MAP Forms.TScrollingWinControl.CalcAutoRange. Source vcl/Forms.pas:2418."
    procedure SetAutoScroll(Value: Boolean); // @note "DCC32 MAP Forms.TScrollingWinControl.SetAutoScroll. Source vcl/Forms.pas:2427."
    procedure UpdateScrollBars; // @note "DCC32 MAP Forms.TScrollingWinControl.UpdateScrollBars. Source vcl/Forms.pas:2450."
    procedure AutoScrollInView(AControl: TControl); virtual; // @note "DCC32 MAP Forms.TScrollingWinControl.AutoScrollInView. Source vcl/Forms.pas:2475." @slot 0xDC
    procedure ScrollInView(AControl: TControl); // @note "DCC32 MAP Forms.TScrollingWinControl.ScrollInView. Source vcl/Forms.pas:2497."
    procedure ScaleScrollBars(M, D: Integer); // @note "DCC32 MAP Forms.TScrollingWinControl.ScaleScrollBars. Source vcl/Forms.pas:2527."
    procedure ChangeScale(M, D: Integer); // @note "DCC32 MAP Forms.TScrollingWinControl.ChangeScale. Source vcl/Forms.pas:2548."
    procedure WMSize(var Message: TWMSize); // @note "DCC32 MAP Forms.TScrollingWinControl.WMSize. Source vcl/Forms.pas:2559."
    procedure WMHScroll(var Message: TWMHScroll); // @note "DCC32 MAP Forms.TScrollingWinControl.WMHScroll. Source vcl/Forms.pas:2588."
    procedure WMVScroll(var Message: TWMVScroll); // @note "DCC32 MAP Forms.TScrollingWinControl.WMVScroll. Source vcl/Forms.pas:2595."
    procedure AdjustClientRect(var Rect: TRect); override; // @note "DCC32 MAP Forms.TScrollingWinControl.AdjustClientRect. Source vcl/Forms.pas:2602." @slot 0x90
    procedure CMBiDiModeChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TScrollingWinControl.CMBiDiModeChanged. Source vcl/Forms.pas:2610."
  end;

  TCustomForm = class(TScrollingWinControl) // @size 0x35C
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Forms.TCustomForm.Create. Source vcl/Forms.pas:2829." @slot 0x2C
    procedure AfterConstruction; // @note "DCC32 MAP Forms.TCustomForm.AfterConstruction. Source vcl/Forms.pas:2850."
    constructor CreateNew(AOwner: TComponent; Dummy: Integer); virtual; // @note "DCC32 MAP Forms.TCustomForm.CreateNew. Source vcl/Forms.pas:2860." @slot 0xF0
    procedure BeforeDestruction; // @note "DCC32 MAP Forms.TCustomForm.BeforeDestruction. Source vcl/Forms.pas:2898."
    destructor Destroy; // @note "DCC32 MAP Forms.TCustomForm.Destroy. Source vcl/Forms.pas:2909."
    procedure DoCreate; virtual; // @note "DCC32 MAP Forms.TCustomForm.DoCreate. Source vcl/Forms.pas:2930." @slot 0xE4
    procedure DoDestroy; virtual; // @note "DCC32 MAP Forms.TCustomForm.DoDestroy. Source vcl/Forms.pas:2942." @slot 0xE8
    procedure Loaded; override; // @note "DCC32 MAP Forms.TCustomForm.Loaded. Source vcl/Forms.pas:2952." @slot 0xC
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @note "DCC32 MAP Forms.TCustomForm.Notification. Source vcl/Forms.pas:2967." @slot 0x10
    procedure ReadState(Reader: TReader); override; // @note "DCC32 MAP Forms.TCustomForm.ReadState. Source vcl/Forms.pas:3012." @slot 0x14
    procedure DefineProperties(Filer: TFiler); override; // @note "DCC32 MAP Forms.TCustomForm.DefineProperties. Source vcl/Forms.pas:3064." @slot 0x4
    procedure ReadIgnoreFontProperty(Reader: TReader); // @note "DCC32 MAP Forms.TCustomForm.ReadIgnoreFontProperty. Source vcl/Forms.pas:3096."
    procedure ReadTextHeight(Reader: TReader); // @note "DCC32 MAP Forms.TCustomForm.ReadTextHeight. Source vcl/Forms.pas:3102."
    function GetLeft: Integer; // @note "DCC32 MAP Forms.TCustomForm.GetLeft. Source vcl/Forms.pas:3117."
    function GetTop: Integer; // @note "DCC32 MAP Forms.TCustomForm.GetTop. Source vcl/Forms.pas:3125."
    procedure IconChanged(Sender: TObject); // @note "DCC32 MAP Forms.TCustomForm.IconChanged. Source vcl/Forms.pas:3159."
    function IsFormSizeStored: Boolean; // @note "DCC32 MAP Forms.TCustomForm.IsFormSizeStored. Source vcl/Forms.pas:3174."
    function IsAutoScrollStored: Boolean; // @note "DCC32 MAP Forms.TCustomForm.IsAutoScrollStored. Source vcl/Forms.pas:3180."
    procedure DoClose(var Action: TCloseAction); // @note "DCC32 MAP Forms.TCustomForm.DoClose. Source vcl/Forms.pas:3186."
    procedure DoHide; // @note "DCC32 MAP Forms.TCustomForm.DoHide. Source vcl/Forms.pas:3191."
    procedure DoShow; // @note "DCC32 MAP Forms.TCustomForm.DoShow. Source vcl/Forms.pas:3196."
    function GetClientRect: TRect; override; // @note "DCC32 MAP Forms.TCustomForm.GetClientRect. Source vcl/Forms.pas:3201." @slot 0x44
    procedure GetChildren; // @nameonly @note "DCC32 MAP Forms.TCustomForm.GetChildren. Source vcl/Forms.pas:3215. Prototype pending: unsupported source type TGetChildProc: procedure (Child: TComponent) of object."
    function GetFloating: Boolean; override; // @note "DCC32 MAP Forms.TCustomForm.GetFloating. Source vcl/Forms.pas:3229." @slot 0x54
    procedure SetChildOrder(Child: TComponent; Order: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetChildOrder. Source vcl/Forms.pas:3242."
    procedure SetParentBiDiMode(Value: Boolean); override; // @note "DCC32 MAP Forms.TCustomForm.SetParentBiDiMode. Source vcl/Forms.pas:3265." @slot 0x70
    procedure SetClientWidth(Value: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetClientWidth. Source vcl/Forms.pas:3276."
    procedure SetClientHeight(Value: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetClientHeight. Source vcl/Forms.pas:3285."
    procedure SetVisible(Value: Boolean); // @note "DCC32 MAP Forms.TCustomForm.SetVisible. Source vcl/Forms.pas:3294."
    procedure SetParent(AParent: TWinControl); override; // @note "DCC32 MAP Forms.TCustomForm.SetParent. Source vcl/Forms.pas:3331." @slot 0x6C
    procedure ValidateRename(AComponent: TComponent; const CurName, NewName: AnsiString); override; // @note "DCC32 MAP Forms.TCustomForm.ValidateRename. Source vcl/Forms.pas:3355." @slot 0x20
    procedure ClientWndProc(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.ClientWndProc. Source vcl/Forms.pas:3510."
    procedure AlignControls(AControl: TControl; var Rect: TRect); override; // @note "DCC32 MAP Forms.TCustomForm.AlignControls. Source vcl/Forms.pas:3584." @slot 0x94
    procedure CMBiDiModeChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMBiDiModeChanged. Source vcl/Forms.pas:3600."
    procedure CMParentBiDiModeChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMParentBiDiModeChanged. Source vcl/Forms.pas:3621."
    procedure CMPopupHwndDestroy(var Message: TCMPopupHWndDestroy); // @note "DCC32 MAP Forms.TCustomForm.CMPopupHwndDestroy. Source vcl/Forms.pas:3641."
    procedure GetBorderIconStyles(var Style, ExStyle: Cardinal); // @note "DCC32 MAP Forms.TCustomForm.GetBorderIconStyles. Source vcl/Forms.pas:3659."
    procedure SetBorderIcons(Value: TBorderIcons); // @ida "void __usercall $name(TCustomForm *Self@<eax>, TBorderIcons *Value@<edx>);" @note "DCC32 MAP Forms.TCustomForm.SetBorderIcons. Source vcl/Forms.pas:3695."
    procedure GetBorderStyles(var Style, ExStyle, ClassStyle: Cardinal); // @note "DCC32 MAP Forms.TCustomForm.GetBorderStyles. Source vcl/Forms.pas:3722."
    procedure SetBorderStyle(Value: TFormBorderStyle); // @note "DCC32 MAP Forms.TCustomForm.SetBorderStyle. Source vcl/Forms.pas:3761."
    procedure Dock(NewDockSite: TWinControl; ARect: TRect); // @note "DCC32 MAP Forms.TCustomForm.Dock. Source vcl/Forms.pas:3804."
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect); // @note "DCC32 MAP Forms.TCustomForm.DoDock. Source vcl/Forms.pas:3815."
    function GetActiveMDIChild: TForm; // @note "DCC32 MAP Forms.TCustomForm.GetActiveMDIChild. Source vcl/Forms.pas:3828."
    function GetMDIChildCount: Integer; // @note "DCC32 MAP Forms.TCustomForm.GetMDIChildCount. Source vcl/Forms.pas:3836."
    function GetMDIChildren(I: Integer): TForm; // @note "DCC32 MAP Forms.TCustomForm.GetMDIChildren. Source vcl/Forms.pas:3846."
    function GetMonitor: TMonitor; // @note "DCC32 MAP Forms.TCustomForm.GetMonitor. Source vcl/Forms.pas:3876."
    function IsIconStored: Boolean; // @note "DCC32 MAP Forms.TCustomForm.IsIconStored. Source vcl/Forms.pas:3915."
    procedure SetFormStyle(Value: TFormStyle); // @note "DCC32 MAP Forms.TCustomForm.SetFormStyle. Source vcl/Forms.pas:3920."
    procedure RefreshMDIMenu; // @note "DCC32 MAP Forms.TCustomForm.RefreshMDIMenu. Source vcl/Forms.pas:3960."
    procedure SetObjectMenuItem(Value: TMenuItem); // @note "DCC32 MAP Forms.TCustomForm.SetObjectMenuItem. Source vcl/Forms.pas:3977."
    procedure SetWindowMenu(Value: TMenuItem); // @note "DCC32 MAP Forms.TCustomForm.SetWindowMenu. Source vcl/Forms.pas:3987."
    procedure SetMenu(Value: TMainMenu); // @note "DCC32 MAP Forms.TCustomForm.SetMenu. Source vcl/Forms.pas:3997."
    function GetPixelsPerInch: Integer; // @note "DCC32 MAP Forms.TCustomForm.GetPixelsPerInch. Source vcl/Forms.pas:4041."
    function GetPopupChildren: TList; // @note "DCC32 MAP Forms.TCustomForm.GetPopupChildren. Source vcl/Forms.pas:4047."
    function GetRecreateChildren: TList; // @note "DCC32 MAP Forms.TCustomForm.GetRecreateChildren. Source vcl/Forms.pas:4054."
    procedure SetPixelsPerInch(Value: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetPixelsPerInch. Source vcl/Forms.pas:4061."
    procedure SetPosition(Value: TPosition); // @note "DCC32 MAP Forms.TCustomForm.SetPosition. Source vcl/Forms.pas:4068."
    procedure SetPopupMode(Value: TPopupMode); // @note "DCC32 MAP Forms.TCustomForm.SetPopupMode. Source vcl/Forms.pas:4077."
    procedure SetPopupParent(Value: TCustomForm); // @note "DCC32 MAP Forms.TCustomForm.SetPopupParent. Source vcl/Forms.pas:4091."
    procedure SetScaled(Value: Boolean); // @note "DCC32 MAP Forms.TCustomForm.SetScaled. Source vcl/Forms.pas:4115."
    procedure CMColorChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMColorChanged. Source vcl/Forms.pas:4125."
    function NormalColor: TColor; // @note "DCC32 MAP Forms.TCustomForm.NormalColor. Source vcl/Forms.pas:4131."
    procedure CMCtl3DChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMCtl3DChanged. Source vcl/Forms.pas:4137."
    procedure CMFontChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMFontChanged. Source vcl/Forms.pas:4147."
    procedure CMMenuChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMMenuChanged. Source vcl/Forms.pas:4153."
    procedure SetWindowState(Value: TWindowState); // @note "DCC32 MAP Forms.TCustomForm.SetWindowState. Source vcl/Forms.pas:4159."
    procedure SetWindowToMonitor; // @note "DCC32 MAP Forms.TCustomForm.SetWindowToMonitor. Source vcl/Forms.pas:4172."
    procedure CreateWnd; override; // @note "DCC32 MAP Forms.TCustomForm.CreateWnd. Source vcl/Forms.pas:4360." @slot 0xA4
    procedure CreateWindowHandle(const Params: TCreateParams); override; // @ida "void __usercall $name(TCustomForm *Self@<eax>, TCreateParams *Params@<edx>);" @note "DCC32 MAP Forms.TCustomForm.CreateWindowHandle. Source vcl/Forms.pas:4411." @slot 0xA0
    procedure DestroyWindowHandle; override; // @note "DCC32 MAP Forms.TCustomForm.DestroyWindowHandle. Source vcl/Forms.pas:4489." @slot 0xB4
    procedure DefaultHandler(Message: Pointer); // @note "DCC32 MAP Forms.TCustomForm.DefaultHandler. Source vcl/Forms.pas:4498."
    procedure SetActiveControl(Control: TWinControl); // @note "DCC32 MAP Forms.TCustomForm.SetActiveControl. Source vcl/Forms.pas:4509."
    procedure DefocusControl(Control: TWinControl; Removing: Boolean); // @note "DCC32 MAP Forms.TCustomForm.DefocusControl. Source vcl/Forms.pas:4535."
    procedure FocusControl(Control: TWinControl); // @note "DCC32 MAP Forms.TCustomForm.FocusControl. Source vcl/Forms.pas:4542."
    function SetFocusedControl(Control: TWinControl): Boolean; virtual; // @note "DCC32 MAP Forms.TCustomForm.SetFocusedControl. Source vcl/Forms.pas:4551." @slot 0xF8
    procedure SetWindowFocus; // @note "DCC32 MAP Forms.TCustomForm.SetWindowFocus. Source vcl/Forms.pas:4630."
    procedure SetActive(Value: Boolean); // @note "DCC32 MAP Forms.TCustomForm.SetActive. Source vcl/Forms.pas:4648."
    procedure SendCancelMode(Sender: TControl); // @note "DCC32 MAP Forms.TCustomForm.SendCancelMode. Source vcl/Forms.pas:4662."
    procedure MergeMenu(MergeState: Boolean); // @note "DCC32 MAP Forms.TCustomForm.MergeMenu. Source vcl/Forms.pas:4670."
    procedure Activate; // @note "DCC32 MAP Forms.TCustomForm.Activate. Source vcl/Forms.pas:4698."
    procedure Deactivate; // @note "DCC32 MAP Forms.TCustomForm.Deactivate. Source vcl/Forms.pas:4704."
    procedure Paint; // @note "DCC32 MAP Forms.TCustomForm.Paint. Source vcl/Forms.pas:4710."
    procedure PaintWindow(DC: Cardinal); override; // @note "DCC32 MAP Forms.TCustomForm.PaintWindow. Source vcl/Forms.pas:4721." @slot 0xC4
    function PaletteChanged(Foreground: Boolean): Boolean; // @note "DCC32 MAP Forms.TCustomForm.PaletteChanged. Source vcl/Forms.pas:4768."
    procedure WMPaint(var Message: TWMPaint); // @note "DCC32 MAP Forms.TCustomForm.WMPaint. Source vcl/Forms.pas:4788."
    procedure WMNCPaint(var Message: TWMNCPaint); // @note "DCC32 MAP Forms.TCustomForm.WMNCPaint. Source vcl/Forms.pas:4807."
    procedure WMIconEraseBkgnd(var Message: TWMIconEraseBkgnd); // @note "DCC32 MAP Forms.TCustomForm.WMIconEraseBkgnd. Source vcl/Forms.pas:4813."
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); // @note "DCC32 MAP Forms.TCustomForm.WMEraseBkgnd. Source vcl/Forms.pas:4821."
    procedure WMNCCreate(var Message: TWMNCCreate); // @note "DCC32 MAP Forms.TCustomForm.WMNCCreate. Source vcl/Forms.pas:4835."
    procedure WMNCHitTest(var Message: TWMNCHitTest); // @note "DCC32 MAP Forms.TCustomForm.WMNCHitTest. Source vcl/Forms.pas:4875."
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); // @note "DCC32 MAP Forms.TCustomForm.WMNCLButtonDown. Source vcl/Forms.pas:4883."
    procedure WMCommand(var Message: TWMCommand); // @note "DCC32 MAP Forms.TCustomForm.WMCommand. Source vcl/Forms.pas:4937."
    procedure WMInitMenuPopup(var Message: TWMInitMenuPopup); // @note "DCC32 MAP Forms.TCustomForm.WMInitMenuPopup. Source vcl/Forms.pas:4944."
    procedure WMMenuChar(var Message: TWMMenuChar); // @note "DCC32 MAP Forms.TCustomForm.WMMenuChar. Source vcl/Forms.pas:4949."
    procedure WMMenuSelect(var Message: TWMMenuSelect); // @note "DCC32 MAP Forms.TCustomForm.WMMenuSelect. Source vcl/Forms.pas:4963."
    procedure WMActivate(var Message: TWMActivate); // @note "DCC32 MAP Forms.TCustomForm.WMActivate. Source vcl/Forms.pas:4990."
    procedure Resizing(State: TWindowState); virtual; // @note "DCC32 MAP Forms.TCustomForm.Resizing. Source vcl/Forms.pas:4997." @slot 0xE0
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); // @note "DCC32 MAP Forms.TCustomForm.WMQueryEndSession. Source vcl/Forms.pas:5011."
    procedure CMAppSysCommand(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMAppSysCommand. Source vcl/Forms.pas:5016."
    procedure WMSysCommand(var Message: TWMSysCommand); // @note "DCC32 MAP Forms.TCustomForm.WMSysCommand. Source vcl/Forms.pas:5031."
    procedure WMShowWindow(var Message: TWMShowWindow); // @note "DCC32 MAP Forms.TCustomForm.WMShowWindow. Source vcl/Forms.pas:5046."
    procedure WMMDIActivate(var Message: TWMMDIActivate); // @note "DCC32 MAP Forms.TCustomForm.WMMDIActivate. Source vcl/Forms.pas:5075."
    procedure WMEnterMenuLoop(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.WMEnterMenuLoop. Source vcl/Forms.pas:5097."
    procedure WMHelp(var Message: TWMHelp); // @note "DCC32 MAP Forms.TCustomForm.WMHelp. Source vcl/Forms.pas:5103."
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); // @note "DCC32 MAP Forms.TCustomForm.WMGetMinMaxInfo. Source vcl/Forms.pas:5182."
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); // @note "DCC32 MAP Forms.TCustomForm.WMNCCalcSize. Source vcl/Forms.pas:5273."
    procedure CMActivate(var Message: TCMActivate); // @note "DCC32 MAP Forms.TCustomForm.CMActivate. Source vcl/Forms.pas:5287."
    procedure CMDeactivate(var Message: TCMDeactivate); // @note "DCC32 MAP Forms.TCustomForm.CMDeactivate. Source vcl/Forms.pas:5294."
    procedure CMDialogKey(var Message: TCMDialogKey); // @note "DCC32 MAP Forms.TCustomForm.CMDialogKey. Source vcl/Forms.pas:5301."
    procedure CMIconChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMIconChanged. Source vcl/Forms.pas:5462."
    procedure CMTextChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMTextChanged. Source vcl/Forms.pas:5472."
    procedure CMParentFontChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.CMParentFontChanged. Source vcl/Forms.pas:5485."
    procedure CMIsShortCut(var Message: TWMKey); // @note "DCC32 MAP Forms.TCustomForm.CMIsShortCut. Source vcl/Forms.pas:5503."
    procedure Close; // @note "DCC32 MAP Forms.TCustomForm.Close. Source vcl/Forms.pas:5511."
    function CloseQuery: Boolean; virtual; // @note "DCC32 MAP Forms.TCustomForm.CloseQuery. Source vcl/Forms.pas:5535." @slot 0xF4
    procedure CloseModal; // @note "DCC32 MAP Forms.TCustomForm.CloseModal. Source vcl/Forms.pas:5549."
    procedure SetFocus; override; // @note "DCC32 MAP Forms.TCustomForm.SetFocus. Source vcl/Forms.pas:5679." @slot 0xD4
    procedure RecreateAsPopup(AWindowHandle: Cardinal); // @note "DCC32 MAP Forms.TCustomForm.RecreateAsPopup. Source vcl/Forms.pas:5693."
    procedure Release; // @note "DCC32 MAP Forms.TCustomForm.Release. Source vcl/Forms.pas:5703."
    function ShowModal: Integer; virtual; // @note "DCC32 MAP Forms.TCustomForm.ShowModal. Source vcl/Forms.pas:5708." @slot 0xFC
    procedure UpdateActions; virtual; // @note "DCC32 MAP Forms.TCustomForm.UpdateActions. Source vcl/Forms.pas:5773." @slot 0xEC
    procedure WMSettingChange(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.WMSettingChange. Source vcl/Forms.pas:5831."
    function IsShortCut(var Message: TWMKey): Boolean; // @note "DCC32 MAP Forms.TCustomForm.IsShortCut. Source vcl/Forms.pas:5908."
    function QueryInterface(const IID: TGUID; Obj: Pointer): HResult; // @nameonly @note "DCC32 MAP Forms.TCustomForm.QueryInterface. Source vcl/Forms.pas:5944. Prototype pending: RET mismatch: expected 0, native [12]."
    procedure MouseWheelHandler(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomForm.MouseWheelHandler. Source vcl/Forms.pas:5953."
    procedure SetLayeredAttribs; // @note "DCC32 MAP Forms.TCustomForm.SetLayeredAttribs. Source vcl/Forms.pas:5970."
    procedure SetTransparentColor(const Value: Boolean); // @note "DCC32 MAP Forms.TCustomForm.SetTransparentColor. Source vcl/Forms.pas:6023."
    procedure InitAlphaBlending(var Params: TCreateParams); // @note "DCC32 MAP Forms.TCustomForm.InitAlphaBlending. Source vcl/Forms.pas:6034."
    procedure SetLeft(Value: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetLeft. Source vcl/Forms.pas:6061."
    procedure SetTop(Value: Integer); // @note "DCC32 MAP Forms.TCustomForm.SetTop. Source vcl/Forms.pas:6072."
  end;

  TControlScrollBar = class(TPersistent) // @size 0x48
  public
    constructor Create(AControl: TScrollingWinControl; AKind: TScrollBarKind); // @note "DCC32 MAP Forms.TControlScrollBar.Create. Source vcl/Forms.pas:1908."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Forms.TControlScrollBar.Assign. Source vcl/Forms.pas:1930." @slot 0x8
    procedure ChangeBiDiPosition; // @note "DCC32 MAP Forms.TControlScrollBar.ChangeBiDiPosition. Source vcl/Forms.pas:1943."
    procedure CalcAutoRange; // @note "DCC32 MAP Forms.TControlScrollBar.CalcAutoRange. Source vcl/Forms.pas:1953."
    function IsScrollBarVisible: Boolean; // @note "DCC32 MAP Forms.TControlScrollBar.IsScrollBarVisible. Source vcl/Forms.pas:1997."
    function ControlSize(ControlSB, AssumeSB: Boolean): Integer; // @note "DCC32 MAP Forms.TControlScrollBar.ControlSize. Source vcl/Forms.pas:2007."
    function NeedsScrollBarVisible: Boolean; // @note "DCC32 MAP Forms.TControlScrollBar.NeedsScrollBarVisible. Source vcl/Forms.pas:2044."
    procedure ScrollMessage(var Msg: TWMScroll); // @note "DCC32 MAP Forms.TControlScrollBar.ScrollMessage. Source vcl/Forms.pas:2049."
    procedure SetButtonSize(Value: Integer); // @note "DCC32 MAP Forms.TControlScrollBar.SetButtonSize. Source vcl/Forms.pas:2141."
    procedure SetColor(Value: TColor); // @note "DCC32 MAP Forms.TControlScrollBar.SetColor. Source vcl/Forms.pas:2160."
    procedure SetPosition(Value: Integer); // @note "DCC32 MAP Forms.TControlScrollBar.SetPosition. Source vcl/Forms.pas:2180."
    procedure SetSize(Value: Integer); // @note "DCC32 MAP Forms.TControlScrollBar.SetSize. Source vcl/Forms.pas:2213."
    procedure DoSetRange(Value: Integer); // @note "DCC32 MAP Forms.TControlScrollBar.DoSetRange. Source vcl/Forms.pas:2252."
    procedure SetRange(Value: Integer); // @note "DCC32 MAP Forms.TControlScrollBar.SetRange. Source vcl/Forms.pas:2259."
    procedure Update(ControlSB, AssumeSB: Boolean); // @note "DCC32 MAP Forms.TControlScrollBar.Update. Source vcl/Forms.pas:2277."
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
    function GetLeft: Integer; // @note "DCC32 MAP Forms.TMonitor.GetLeft. Source vcl/Forms.pas:6256."
    function GetHeight: Integer; // @note "DCC32 MAP Forms.TMonitor.GetHeight. Source vcl/Forms.pas:6261."
    function GetTop: Integer; // @note "DCC32 MAP Forms.TMonitor.GetTop. Source vcl/Forms.pas:6267."
    function GetWidth: Integer; // @note "DCC32 MAP Forms.TMonitor.GetWidth. Source vcl/Forms.pas:6272."
    function GetBoundsRect: TRect; // @note "DCC32 MAP Forms.TMonitor.GetBoundsRect. Source vcl/Forms.pas:6278."
    function GetWorkareaRect: TRect; // @note "DCC32 MAP Forms.TMonitor.GetWorkareaRect. Source vcl/Forms.pas:6287."
    function GetPrimary: Boolean; // @note "DCC32 MAP Forms.TMonitor.GetPrimary. Source vcl/Forms.pas:6296."
  end;

  TFormStyle = (fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop); // @size 0x1

  TPosition = (poDesigned, poDefault, poDefaultPosOnly, poDefaultSizeOnly, poScreenCenter, poDesktopCenter, poMainFormCenter, poOwnerFormCenter); // @size 0x1

  TPopupMode = (pmNone, pmAuto, pmExplicit); // @size 0x1

  TWindowState = (wsNormal, wsMinimized, wsMaximized); // @size 0x1

  TDestroyPopupData = record;

  PDestroyPopupData = ^TDestroyPopupData;

  TCustomDockForm = class(TCustomForm) // @size 0x360
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Forms.TCustomDockForm.Create. Source vcl/Forms.pas:6120." @slot 0x2C
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); // @note "DCC32 MAP Forms.TCustomDockForm.DoAddDockClient. Source vcl/Forms.pas:6129."
    procedure DoRemoveDockClient(Client: TControl); // @note "DCC32 MAP Forms.TCustomDockForm.DoRemoveDockClient. Source vcl/Forms.pas:6157."
    procedure Loaded; override; // @note "DCC32 MAP Forms.TCustomDockForm.Loaded. Source vcl/Forms.pas:6163." @slot 0xC
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean); // @note "DCC32 MAP Forms.TCustomDockForm.GetSiteInfo. Source vcl/Forms.pas:6173."
    procedure WMNCHitTest(var Message: TWMNCHitTest); // @note "DCC32 MAP Forms.TCustomDockForm.WMNCHitTest. Source vcl/Forms.pas:6179."
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); // @note "DCC32 MAP Forms.TCustomDockForm.WMNCLButtonDown. Source vcl/Forms.pas:6186."
    procedure CMControlListChange(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomDockForm.CMControlListChange. Source vcl/Forms.pas:6203."
    procedure CMDockNotification(var Message: TCMDockNotification); // @note "DCC32 MAP Forms.TCustomDockForm.CMDockNotification. Source vcl/Forms.pas:6214."
    procedure CMVisibleChanged(var Message: TMessage); // @note "DCC32 MAP Forms.TCustomDockForm.CMVisibleChanged. Source vcl/Forms.pas:6244."
  end;

  TScreen = class(TComponent) // @size 0xA0
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Forms.TScreen.Create. Source vcl/Forms.pas:6329." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Forms.TScreen.Destroy. Source vcl/Forms.pas:6356."
    function GetMonitorCount: Integer; // @note "DCC32 MAP Forms.TScreen.GetMonitorCount. Source vcl/Forms.pas:6414."
    procedure UpdateLastActive; // @note "DCC32 MAP Forms.TScreen.UpdateLastActive. Source vcl/Forms.pas:6442."
    procedure AddForm(AForm: TCustomForm); // @note "DCC32 MAP Forms.TScreen.AddForm. Source vcl/Forms.pas:6456."
    procedure RemoveForm(AForm: TCustomForm); // @note "DCC32 MAP Forms.TScreen.RemoveForm. Source vcl/Forms.pas:6466."
    procedure CreateCursors; // @note "DCC32 MAP Forms.TScreen.CreateCursors. Source vcl/Forms.pas:6520."
    procedure DestroyCursors; // @note "DCC32 MAP Forms.TScreen.DestroyCursors. Source vcl/Forms.pas:6550."
    procedure InsertCursor(Index: Integer; Handle: Cardinal); // @note "DCC32 MAP Forms.TScreen.InsertCursor. Source vcl/Forms.pas:6602."
    function GetImes: TStrings; // @note "DCC32 MAP Forms.TScreen.GetImes. Source vcl/Forms.pas:6613."
    function GetDefaultIME: AnsiString; // @note "DCC32 MAP Forms.TScreen.GetDefaultIME. Source vcl/Forms.pas:6658."
    procedure IconFontChanged(Sender: TObject); // @note "DCC32 MAP Forms.TScreen.IconFontChanged. Source vcl/Forms.pas:6664."
    function GetCursors(Index: Integer): Cardinal; // @note "DCC32 MAP Forms.TScreen.GetCursors. Source vcl/Forms.pas:6684."
    procedure SetCursor(Value: TCursor); // @note "DCC32 MAP Forms.TScreen.SetCursor. Source vcl/Forms.pas:6697."
    procedure GetMetricSettings; // @note "DCC32 MAP Forms.TScreen.GetMetricSettings. Source vcl/Forms.pas:6754."
    procedure EnableAlign; // @note "DCC32 MAP Forms.TScreen.EnableAlign. Source vcl/Forms.pas:6790."
    procedure AlignForms(AForm: TCustomForm; var Rect: TRect); // @note "DCC32 MAP Forms.TScreen.AlignForms. Source vcl/Forms.pas:6801."
    procedure AlignForm(AForm: TCustomForm); // @note "DCC32 MAP Forms.TScreen.AlignForm. Source vcl/Forms.pas:6933."
    procedure ClearMonitors; // @note "DCC32 MAP Forms.TScreen.ClearMonitors. Source vcl/Forms.pas:7158."
    procedure GetMonitors; // @note "DCC32 MAP Forms.TScreen.GetMonitors. Source vcl/Forms.pas:7167."
    function GetPrimaryMonitor: TMonitor; // @note "DCC32 MAP Forms.TScreen.GetPrimaryMonitor. Source vcl/Forms.pas:7173."
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
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP Forms.TApplication.Create. Source vcl/Forms.pas:7214." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP Forms.TApplication.Destroy. Source vcl/Forms.pas:7263."
    procedure ControlDestroyed(Control: TControl); // @note "DCC32 MAP Forms.TApplication.ControlDestroyed. Source vcl/Forms.pas:7350."
    procedure DoNormalizeTopMosts(IncludeMain: Boolean); // @note "DCC32 MAP Forms.TApplication.DoNormalizeTopMosts. Source vcl/Forms.pas:7387."
    procedure ModalStarted; // @note "DCC32 MAP Forms.TApplication.ModalStarted. Source vcl/Forms.pas:7413."
    procedure ModalFinished; // @note "DCC32 MAP Forms.TApplication.ModalFinished. Source vcl/Forms.pas:7420."
    procedure RemovePopupForm(APopupForm: TCustomForm); // @note "DCC32 MAP Forms.TApplication.RemovePopupForm. Source vcl/Forms.pas:7437."
    procedure RestoreTopMosts; // @note "DCC32 MAP Forms.TApplication.RestoreTopMosts. Source vcl/Forms.pas:7450."
    procedure DoShowOwnedPopups(Show: Boolean); // @note "DCC32 MAP Forms.TApplication.DoShowOwnedPopups. Source vcl/Forms.pas:7492."
    function UseRightToLeftReading: Boolean; // @note "DCC32 MAP Forms.TApplication.UseRightToLeftReading. Source vcl/Forms.pas:7532."
    function UseRightToLeftAlignment: Boolean; // @note "DCC32 MAP Forms.TApplication.UseRightToLeftAlignment. Source vcl/Forms.pas:7537."
    procedure SettingChange(var Message: TWMSettingChange); // @note "DCC32 MAP Forms.TApplication.SettingChange. Source vcl/Forms.pas:7569."
    function GetIconHandle: Cardinal; // @note "DCC32 MAP Forms.TApplication.GetIconHandle. Source vcl/Forms.pas:7754."
    procedure Restore; // @note "DCC32 MAP Forms.TApplication.Restore. Source vcl/Forms.pas:7786."
    function GetTitle: AnsiString; // @note "DCC32 MAP Forms.TApplication.GetTitle. Source vcl/Forms.pas:7831."
    function IsDlgMsg(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.IsDlgMsg. Source vcl/Forms.pas:7886."
    function IsMDIMsg(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.IsMDIMsg. Source vcl/Forms.pas:7896."
    function IsKeyMsg(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.IsKeyMsg. Source vcl/Forms.pas:7904."
    function IsHintMsg(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.IsHintMsg. Source vcl/Forms.pas:7946."
    function IsShortCut(var Message: TWMKey): Boolean; // @note "DCC32 MAP Forms.TApplication.IsShortCut. Source vcl/Forms.pas:7953."
    procedure PopupControlProc(var Message: TMessage); // @note "DCC32 MAP Forms.TApplication.PopupControlProc. Source vcl/Forms.pas:7961."
    function ProcessMessage(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.ProcessMessage. Source vcl/Forms.pas:7987."
    procedure HandleMessage; // @note "DCC32 MAP Forms.TApplication.HandleMessage. Source vcl/Forms.pas:8030."
    procedure HookMainWindow; // @nameonly @note "DCC32 MAP Forms.TApplication.HookMainWindow. Source vcl/Forms.pas:8037. Prototype pending: unsupported source type TWindowHook: function (var Message: TMessage): Boolean of object."
    procedure UnhookMainWindow; // @nameonly @note "DCC32 MAP Forms.TApplication.UnhookMainWindow. Source vcl/Forms.pas:8054. Prototype pending: unsupported source type TWindowHook: function (var Message: TMessage): Boolean of object."
    procedure HandleException(Sender: TObject); // @note "DCC32 MAP Forms.TApplication.HandleException. Source vcl/Forms.pas:8151."
    function MessageBox(const Text, Caption: PAnsiChar; Flags: Longint): Integer; // @note "DCC32 MAP Forms.TApplication.MessageBox. Source vcl/Forms.pas:8165."
    procedure ShowException(E: Exception); // @note "DCC32 MAP Forms.TApplication.ShowException. Source vcl/Forms.pas:8208."
    function InvokeHelp(Command: Word; Data: Longint): Boolean; // @note "DCC32 MAP Forms.TApplication.InvokeHelp. Source vcl/Forms.pas:8217."
    function DoOnHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean; // @note "DCC32 MAP Forms.TApplication.DoOnHelp. Source vcl/Forms.pas:8258."
    function HelpKeyword(const Keyword: AnsiString): Boolean; // @note "DCC32 MAP Forms.TApplication.HelpKeyword. Source vcl/Forms.pas:8289."
    function HelpContext(Context: THelpContext): Boolean; // @note "DCC32 MAP Forms.TApplication.HelpContext. Source vcl/Forms.pas:8307."
    procedure SetShowHint(Value: Boolean); // @note "DCC32 MAP Forms.TApplication.SetShowHint. Source vcl/Forms.pas:8360."
    procedure DoActionIdle; // @note "DCC32 MAP Forms.TApplication.DoActionIdle. Source vcl/Forms.pas:8388."
    function DoMouseIdle: TControl; // @note "DCC32 MAP Forms.TApplication.DoMouseIdle. Source vcl/Forms.pas:8399."
    procedure Idle(const Msg: TMsg); // @note "DCC32 MAP Forms.TApplication.Idle. Source vcl/Forms.pas:8424."
    procedure NotifyForms(Msg: Word); // @note "DCC32 MAP Forms.TApplication.NotifyForms. Source vcl/Forms.pas:8470."
    procedure IconChanged(Sender: TObject); // @note "DCC32 MAP Forms.TApplication.IconChanged. Source vcl/Forms.pas:8477."
    procedure SetHint(const Value: AnsiString); // @note "DCC32 MAP Forms.TApplication.SetHint. Source vcl/Forms.pas:8489."
    procedure UpdateVisible; // @note "DCC32 MAP Forms.TApplication.UpdateVisible. Source vcl/Forms.pas:8513."
    function ValidateHelpSystem: Boolean; // @note "DCC32 MAP Forms.TApplication.ValidateHelpSystem. Source vcl/Forms.pas:8549."
    procedure StartHintTimer(Value: Integer; TimerMode: TTimerMode); // @note "DCC32 MAP Forms.TApplication.StartHintTimer. Source vcl/Forms.pas:8561."
    procedure StopHintTimer; // @note "DCC32 MAP Forms.TApplication.StopHintTimer. Source vcl/Forms.pas:8569."
    procedure HintMouseMessage(Control: TControl; var Message: TMessage); // @note "DCC32 MAP Forms.TApplication.HintMouseMessage. Source vcl/Forms.pas:8578."
    procedure HintTimerExpired; // @note "DCC32 MAP Forms.TApplication.HintTimerExpired. Source vcl/Forms.pas:8617."
    procedure HideHint; // @note "DCC32 MAP Forms.TApplication.HideHint. Source vcl/Forms.pas:8633."
    procedure CancelHint; // @note "DCC32 MAP Forms.TApplication.CancelHint. Source vcl/Forms.pas:8652."
    procedure ActivateHint(CursorPos: TPoint); // @note "DCC32 MAP Forms.TApplication.ActivateHint. Source vcl/Forms.pas:8664."
    function AddPopupForm(APopupForm: TCustomForm): Integer; // @note "DCC32 MAP Forms.TApplication.AddPopupForm. Source vcl/Forms.pas:8838."
    function GetCurrentHelpFile: AnsiString; // @note "DCC32 MAP Forms.TApplication.GetCurrentHelpFile. Source vcl/Forms.pas:8865."
    function GetActiveFormHandle: Cardinal; // @note "DCC32 MAP Forms.TApplication.GetActiveFormHandle. Source vcl/Forms.pas:8891."
    function GetMainFormHandle: Cardinal; // @note "DCC32 MAP Forms.TApplication.GetMainFormHandle. Source vcl/Forms.pas:8902."
    function DispatchAction(Msg: Longint; Action: TBasicAction): Boolean; // @note "DCC32 MAP Forms.TApplication.DispatchAction. Source vcl/Forms.pas:8911."
    function ExecuteAction(Action: TBasicAction): Boolean; // @note "DCC32 MAP Forms.TApplication.ExecuteAction. Source vcl/Forms.pas:8926."
    function UpdateAction(Action: TBasicAction): Boolean; // @note "DCC32 MAP Forms.TApplication.UpdateAction. Source vcl/Forms.pas:8932."
    function IsPreProcessMessage(var Msg: TMsg): Boolean; // @note "DCC32 MAP Forms.TApplication.IsPreProcessMessage. Source vcl/Forms.pas:8964."
  end;

  TTimerMode = (tmShow, tmHide); // @size 0x1

  TCustomFormHelper = class // @partial
  public
    procedure ReadGlassFrameBottom(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameBottom. Source vcl/Forms.pas:9000."
    procedure ReadGlassFrameEnabled(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameEnabled. Source vcl/Forms.pas:9005."
    procedure ReadGlassFrameLeft(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameLeft. Source vcl/Forms.pas:9010."
    procedure ReadGlassFrameRight(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameRight. Source vcl/Forms.pas:9015."
    procedure ReadGlassFrameSheetOfGlass(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameSheetOfGlass. Source vcl/Forms.pas:9020."
    procedure ReadGlassFrameTop(Reader: TReader); // @note "DCC32 MAP Forms.TCustomFormHelper.ReadGlassFrameTop. Source vcl/Forms.pas:9025."
    procedure UpdateGlassFrame(Sender: TObject); // @note "DCC32 MAP Forms.TCustomFormHelper.UpdateGlassFrame. Source vcl/Forms.pas:9035."
    procedure WriteGlassFrameBottom(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameBottom. Source vcl/Forms.pas:9076."
    procedure WriteGlassFrameEnabled(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameEnabled. Source vcl/Forms.pas:9081."
    procedure WriteGlassFrameLeft(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameLeft. Source vcl/Forms.pas:9086."
    procedure WriteGlassFrameRight(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameRight. Source vcl/Forms.pas:9091."
    procedure WriteGlassFrameSheetOfGlass(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameSheetOfGlass. Source vcl/Forms.pas:9096."
    procedure WriteGlassFrameTop(Writer: TWriter); // @note "DCC32 MAP Forms.TCustomFormHelper.WriteGlassFrameTop. Source vcl/Forms.pas:9101."
  end;

  TGlassFrame = class(TPersistent) // @size 0x2C
  public
    constructor Create(Client: TCustomForm); // @note "DCC32 MAP Forms.TGlassFrame.Create. Source vcl/Forms.pas:9108."
    procedure Assign(Source: TPersistent); virtual; // @note "DCC32 MAP Forms.TGlassFrame.Assign. Source vcl/Forms.pas:9119." @slot 0x8
    procedure Change; virtual; // @note "DCC32 MAP Forms.TGlassFrame.Change. Source vcl/Forms.pas:9134." @slot 0xC
    function FrameExtended: Boolean; // @note "DCC32 MAP Forms.TGlassFrame.FrameExtended. Source vcl/Forms.pas:9140."
    procedure SetEnabled(Value: Boolean); // @note "DCC32 MAP Forms.TGlassFrame.SetEnabled. Source vcl/Forms.pas:9169."
    procedure SetExtendedFrame(Index: Integer; Value: Integer); // @note "DCC32 MAP Forms.TGlassFrame.SetExtendedFrame. Source vcl/Forms.pas:9180."
  end;

procedure ShowMDIClientEdge(ClientHandle: Cardinal; ShowEdge: Boolean); // @note "DCC32 MAP Forms.ShowMDIClientEdge. Source vcl/Forms.pas:1493."

procedure DoneApplication; // @note "DCC32 MAP Forms.DoneApplication. Source vcl/Forms.pas:1556."

function DoDisableWindow(Window: Cardinal; Data: Longint): LongBool; stdcall; // @note "DCC32 MAP Forms.DoDisableWindow. Source vcl/Forms.pas:1567."

function DisableTaskWindows(ActiveWindow: Cardinal): Pointer; // @note "DCC32 MAP Forms.DisableTaskWindows. Source vcl/Forms.pas:1583."

procedure EnableTaskWindows(WindowList: Pointer); // @note "DCC32 MAP Forms.EnableTaskWindows. Source vcl/Forms.pas:1627."

function DoFindWindow(Window: Cardinal; Param: Longint): LongBool; stdcall; // @note "DCC32 MAP Forms.DoFindWindow. Source vcl/Forms.pas:1640."

function FindTopMostWindow(ActiveWindow: Cardinal): Cardinal; // @note "DCC32 MAP Forms.FindTopMostWindow. Source vcl/Forms.pas:1654."

function SendFocusMessage(Window: Cardinal; Msg: Word): Boolean; // @note "DCC32 MAP Forms.SendFocusMessage. Source vcl/Forms.pas:1665."

function CheckTaskWindow(Window: Cardinal; Data: Longint): LongBool; stdcall; // @note "DCC32 MAP Forms.CheckTaskWindow. Source vcl/Forms.pas:1684."

function CheckTaskWindowAll(Window: Cardinal; Data: Longint): LongBool; stdcall; // @note "DCC32 MAP Forms.CheckTaskWindowAll. Source vcl/Forms.pas:1694."

function ForegroundTaskCheck(CheckAll: Boolean): Boolean; // @note "DCC32 MAP Forms.ForegroundTaskCheck. Source vcl/Forms.pas:1709."

function FindGlobalComponent_451C2C(const Name: AnsiString): TComponent; // @note "DCC32 MAP Forms.FindGlobalComponent. Source vcl/Forms.pas:1729."

function KeysToShiftState(Keys: Word): TShiftState; // @note "DCC32 MAP Forms.KeysToShiftState. Source vcl/Forms.pas:1819."

function KeyDataToShiftState(KeyData: Longint): TShiftState; // @note "DCC32 MAP Forms.KeyDataToShiftState. Source vcl/Forms.pas:1832."

procedure KeyboardStateToShiftState; // @nameonly @note "DCC32 MAP Forms.KeyboardStateToShiftState. Prototype pending: no unique source declaration."

function IsAccel(VK: Word; const Str: AnsiString): Boolean; // @note "DCC32 MAP Forms.IsAccel. Source vcl/Forms.pas:1873."

function GetRealParentForm(Control: TControl; TopForm: Boolean): TCustomForm; // @note "DCC32 MAP Forms.GetRealParentForm. Source vcl/Forms.pas:1880."

function ValidParentForm(Control: TControl; TopForm: Boolean): TCustomForm; // @note "DCC32 MAP Forms.ValidParentForm. Source vcl/Forms.pas:1899."

procedure ProcessHorz(Control: TControl); // @nameonly @note "DCC32 MAP Forms.ProcessHorz. Source vcl/Forms.pas:1958. Prototype pending: nested routine has a parent-frame parameter."

procedure ProcessVert(Control: TControl); // @nameonly @note "DCC32 MAP Forms.ProcessVert. Source vcl/Forms.pas:1969. Prototype pending: nested routine has a parent-frame parameter."

function ScrollBarVisible(Code: Word): Boolean; // @nameonly @note "DCC32 MAP Forms.ScrollBarVisible. Source vcl/Forms.pas:2011. Prototype pending: nested routine has a parent-frame parameter."

function Adjustment(Code, Metric: Word): Integer; // @nameonly @note "DCC32 MAP Forms.Adjustment. Source vcl/Forms.pas:2020. Prototype pending: nested routine has a parent-frame parameter."

function GetRealScrollPosition: Integer; // @nameonly @note "DCC32 MAP Forms.GetRealScrollPosition. Source vcl/Forms.pas:2054. Prototype pending: nested routine has a parent-frame parameter."

procedure UpdateScrollProperties(Redraw: Boolean); // @nameonly @note "DCC32 MAP Forms.UpdateScrollProperties. Source vcl/Forms.pas:2295. Prototype pending: nested routine has a parent-frame parameter."

function DoWriteGlassFrame(Element: TGlassFrameElemnt): Boolean; // @nameonly @note "DCC32 MAP Forms.DoWriteGlassFrame. Source vcl/Forms.pas:3069. Prototype pending: nested routine has a parent-frame parameter."

procedure Default; // @nameonly @note "DCC32 MAP Forms.Default. Prototype pending: no unique source declaration."

function MaximizedChildren: Boolean; // @nameonly @note "DCC32 MAP Forms.MaximizedChildren. Source vcl/Forms.pas:3518. Prototype pending: nested routine has a parent-frame parameter."

function EnumMonitorsProc(hm: Cardinal; dc: Cardinal; r: PRect; Data: Pointer): Boolean; stdcall; // @note "DCC32 MAP Forms.EnumMonitorsProc. Source vcl/Forms.pas:3863."

function GetNonToolWindowPopupParent(WndParent: Cardinal): Cardinal; // @note "DCC32 MAP Forms.GetNonToolWindowPopupParent. Source vcl/Forms.pas:4219."

function DestroyPopupWindow(Window: Cardinal; Data: PDestroyPopupData): LongBool; stdcall; // @note "DCC32 MAP Forms.DestroyPopupWindow. Source vcl/Forms.pas:4453."

procedure DoNestedActivation(Msg: Cardinal; Control: TWinControl; Form: TCustomForm); // @note "DCC32 MAP Forms.DoNestedActivation. Source vcl/Forms.pas:4688."

procedure ModifySystemMenu; // @nameonly @note "DCC32 MAP Forms.ModifySystemMenu. Source vcl/Forms.pas:4837. Prototype pending: nested routine has a parent-frame parameter."

function GetMenuHelpContext(Menu: TMenu): Integer; // @nameonly @note "DCC32 MAP Forms.GetMenuHelpContext. Source vcl/Forms.pas:5105. Prototype pending: nested routine has a parent-frame parameter."

function ControlHasHelp(const Control: TWinControl): Boolean; // @nameonly @note "DCC32 MAP Forms.ControlHasHelp. Source vcl/Forms.pas:5114. Prototype pending: nested routine has a parent-frame parameter."

procedure GetHelpInfo(const Control: TWinControl; var HType: THelpType; var ContextID: Integer; var Keyword: AnsiString); // @nameonly @note "DCC32 MAP Forms.GetHelpInfo. Source vcl/Forms.pas:5123. Prototype pending: nested routine has a parent-frame parameter."

procedure HandleEdge(var Edge: Integer; SnapToEdge: Integer; SnapDistance: Integer); // @nameonly @note "DCC32 MAP Forms.HandleEdge. Source vcl/Forms.pas:5205. Prototype pending: nested routine has a parent-frame parameter."

procedure TraverseClients; // @nameonly @note "DCC32 MAP Forms.TraverseClients. Prototype pending: no unique source declaration."

function ProcessExecute(Control: TControl): Boolean; // @nameonly @note "DCC32 MAP Forms.ProcessExecute. Source vcl/Forms.pas:5840. Prototype pending: nested routine has a parent-frame parameter."

function ProcessUpdate(Control: TControl): Boolean; // @nameonly @note "DCC32 MAP Forms.ProcessUpdate. Source vcl/Forms.pas:5875. Prototype pending: nested routine has a parent-frame parameter."

function DispatchShortCut(const Owner: TComponent): Boolean; // @nameonly @note "DCC32 MAP Forms.DispatchShortCut. Source vcl/Forms.pas:5910. Prototype pending: nested routine has a parent-frame parameter."

function InsertBefore_45A764(C1, C2: TCustomForm; AAlign: TAlign): Boolean; // @nameonly @note "DCC32 MAP Forms.InsertBefore. Source vcl/Forms.pas:6805. Prototype pending: nested routine has a parent-frame parameter."

procedure DoPosition_45A7EC(Form: TCustomForm; AAlign: TAlign); // @nameonly @note "DCC32 MAP Forms.DoPosition. Source vcl/Forms.pas:6816. Prototype pending: nested routine has a parent-frame parameter."

procedure DoAlign_45A9A8(AAlign: TAlign); // @nameonly @note "DCC32 MAP Forms.DoAlign. Source vcl/Forms.pas:6876. Prototype pending: nested routine has a parent-frame parameter."

function AlignWork_45AAF8: Boolean; // @nameonly @note "DCC32 MAP Forms.AlignWork. Source vcl/Forms.pas:6905. Prototype pending: nested routine has a parent-frame parameter."

function GetHint(Control: TControl): AnsiString; // @note "DCC32 MAP Forms.GetHint. Source vcl/Forms.pas:6981."

function GetHintControl(Control: TControl): TControl; // @note "DCC32 MAP Forms.GetHintControl. Source vcl/Forms.pas:6994."

procedure HintTimerProc(Wnd: Cardinal; Msg, TimerID, SysTime: Longint); stdcall; // @note "DCC32 MAP Forms.HintTimerProc. Source vcl/Forms.pas:7001."

procedure HintMouseThread(Param: Integer); stdcall; // @note "DCC32 MAP Forms.HintMouseThread. Source vcl/Forms.pas:7017."

function HintGetMsgHook(nCode: Integer; wParam: Longint; var Msg: TMsg): Longint; stdcall; // @note "DCC32 MAP Forms.HintGetMsgHook. Source vcl/Forms.pas:7037."

procedure HookHintHooks; // @note "DCC32 MAP Forms.HookHintHooks. Source vcl/Forms.pas:7043."

procedure UnhookHintHooks; // @note "DCC32 MAP Forms.UnhookHintHooks. Source vcl/Forms.pas:7058."

function GetAnimation: Boolean; // @note "DCC32 MAP Forms.GetAnimation. Source vcl/Forms.pas:7072."

procedure SetAnimation(Value: Boolean); // @note "DCC32 MAP Forms.SetAnimation. Source vcl/Forms.pas:7082."

procedure ShowWinNoAnimate(Handle: Cardinal; CmdShow: Integer); // @note "DCC32 MAP Forms.ShowWinNoAnimate. Source vcl/Forms.pas:7091."

function GetTopMostWindows(Handle: Cardinal; Info: Pointer): LongBool; stdcall; // @note "DCC32 MAP Forms.GetTopMostWindows. Source vcl/Forms.pas:7372."

function GetPopupOwnerWindows(Handle: Cardinal; Info: Pointer): LongBool; stdcall; // @note "DCC32 MAP Forms.GetPopupOwnerWindows. Source vcl/Forms.pas:7470."

procedure Default_45BB34; // @nameonly @note "DCC32 MAP Forms.Default. Prototype pending: no unique source declaration."

procedure DrawAppIcon; // @nameonly @note "DCC32 MAP Forms.DrawAppIcon. Source vcl/Forms.pas:7590. Prototype pending: nested routine has a parent-frame parameter."

function IsClass(Obj: TObject; Cls: TClass): Boolean; // @note "DCC32 MAP Forms.IsClass. Source vcl/Forms.pas:8141."

procedure IdleTimerProc(Wnd: Cardinal; Msg, TimerID, SysTime: Longint); stdcall; // @note "DCC32 MAP Forms.IdleTimerProc. Source vcl/Forms.pas:8412."

function GetCursorHeightMargin: Integer; // @nameonly @note "DCC32 MAP Forms.GetCursorHeightMargin. Source vcl/Forms.pas:8674. Prototype pending: nested routine has a parent-frame parameter."

procedure ValidateHintWindow(HintClass: THintWindowClass); // @nameonly @note "DCC32 MAP Forms.ValidateHintWindow. Source vcl/Forms.pas:8734. Prototype pending: nested routine has a parent-frame parameter."

function MultiLineWidth(const Value: AnsiString): Integer; // @nameonly @note "DCC32 MAP Forms.MultiLineWidth. Source vcl/Forms.pas:8744. Prototype pending: nested routine has a parent-frame parameter."

procedure FinalizeForms; // @nameonly @note "DCC32 MAP Forms.Finalization. Prototype pending: no unique source declaration."

procedure ResolveSetLayeredWindowAttributes; // @addr 0x45E118 @note "Resolves SetLayeredWindowAttributes from the loaded User32 module."

var
  Application: TApplication; // @addr $889CCC

implementation
end.
