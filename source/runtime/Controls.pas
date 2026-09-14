unit Controls;
// Unit bracket (inferred): .text 0x0043860C..0x0044C0C7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008755E8..0x00875676; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TControl = class(TComponent) // @size 0x190
  public
    constructor Create(AOwner: TComponent); override; // @ida "TControl * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Controls.TControl.Create. Source vcl/Controls.pas:3581." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TControl *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Controls.TControl.Destroy. Source vcl/Controls.pas:3606."
    procedure SetParentComponent(Value: TComponent); // @ida "void __usercall $name(TControl *Self@<eax>, TComponent *Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetParentComponent. Source vcl/Controls.pas:3652."
    function PaletteChanged(Foreground: Boolean): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, bool Foreground@<dl>);" @note "DCC32 MAP Controls.TControl.PaletteChanged. Source vcl/Controls.pas:3658."
    procedure SetAnchors(Value: TAnchors); // @ida "void __usercall $name(TControl *Self@<eax>, TAnchors *Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetAnchors. Source vcl/Controls.pas:3686."
    procedure SetAction(Value: TBasicAction); // @ida "void __usercall $name(TControl *Self@<eax>, TBasicAction *Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetAction. Source vcl/Controls.pas:3704."
    function IsAnchorsStored: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.IsAnchorsStored. Source vcl/Controls.pas:3724."
    procedure SetDesignVisible(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetDesignVisible. Source vcl/Controls.pas:3729."
    procedure Resize; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.Resize. Source vcl/Controls.pas:3751."
    procedure ReadState(Reader: TReader); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TControl.ReadState. Source vcl/Controls.pas:3756." @slot 0x14
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @ida "void __usercall $name(TControl *Self@<eax>, TComponent *AComponent@<edx>, TOperation Operation@<cl>);" @note "DCC32 MAP Controls.TControl.Notification. Source vcl/Controls.pas:3772." @slot 0x10
    procedure SetAlign(Value: TAlign); // @ida "void __usercall $name(TControl *Self@<eax>, TAlign Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetAlign. Source vcl/Controls.pas:3787."
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); virtual; // @ida "void __userpurge $name(TControl *Self@<eax>, __int32 ALeft@<edx>, __int32 ATop@<ecx>, __int32 AWidth@<^4>, __int32 AHeight@<^0>);" @note "DCC32 MAP Controls.TControl.SetBounds. Source vcl/Controls.pas:3809." @slot 0x88
    procedure UpdateAnchorRules; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.UpdateAnchorRules. Source vcl/Controls.pas:3829."
    procedure SetLeft(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetLeft. Source vcl/Controls.pas:3862."
    procedure SetTop(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetTop. Source vcl/Controls.pas:3870."
    procedure SetWidth(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetWidth. Source vcl/Controls.pas:3878."
    procedure SetHeight(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetHeight. Source vcl/Controls.pas:3886."
    procedure Dock(NewDockSite: TWinControl; ARect: TRect); // @ida "void __usercall $name(TControl *Self@<eax>, TWinControl *NewDockSite@<edx>, TRect *ARect@<ecx>);" @note "DCC32 MAP Controls.TControl.Dock. Source vcl/Controls.pas:3894."
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect); // @ida "void __usercall $name(TControl *Self@<eax>, TWinControl *NewDockSite@<edx>, TRect *ARect@<ecx>);" @note "DCC32 MAP Controls.TControl.DoDock. Source vcl/Controls.pas:3934."
    procedure SetHelpContext(const Value: THelpContext); // @ida "void __usercall $name(TControl *Self@<eax>, THelpContext Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetHelpContext. Source vcl/Controls.pas:3944."
    procedure SetHelpKeyword(const Value: AnsiString); // @ida "void __usercall $name(TControl *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetHelpKeyword. Source vcl/Controls.pas:3950."
    function GetBoundsRect: TRect; // @ida "void __usercall $name(TControl *Self@<eax>, TRect *Result@<edx>);" @note "DCC32 MAP Controls.TControl.GetBoundsRect. Source vcl/Controls.pas:3961."
    procedure SetBoundsRect(const Rect: TRect); // @ida "void __usercall $name(TControl *Self@<eax>, TRect *Rect@<edx>);" @note "DCC32 MAP Controls.TControl.SetBoundsRect. Source vcl/Controls.pas:3969."
    function GetClientRect: TRect; virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TRect *Result@<edx>);" @note "DCC32 MAP Controls.TControl.GetClientRect. Source vcl/Controls.pas:3974." @slot 0x44
    function GetClientWidth: Integer; // @ida "__int32 __usercall $name@<eax>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.GetClientWidth. Source vcl/Controls.pas:3982."
    procedure SetClientWidth(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetClientWidth. Source vcl/Controls.pas:3987."
    function GetClientHeight: Integer; // @ida "__int32 __usercall $name@<eax>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.GetClientHeight. Source vcl/Controls.pas:3992."
    procedure SetClientHeight(Value: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetClientHeight. Source vcl/Controls.pas:3997."
    function GetClientOrigin: TPoint; virtual; // @calls "0x43DDA2" @ida "void __usercall $name(TControl *Self@<eax>, TPoint *Result@<edx>);" @note "DCC32 MAP Controls.TControl.GetClientOrigin. Source vcl/Controls.pas:4002." @slot 0x40
    function ClientToScreen(const Point: TPoint): TPoint; // @ida "void __usercall $name(TControl *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);" @note "DCC32 MAP Controls.TControl.ClientToScreen. Source vcl/Controls.pas:4011."
    procedure ScaleConstraints(M, D: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 M@<edx>, __int32 D@<ecx>);" @note "DCC32 MAP Controls.TControl.ScaleConstraints. Source vcl/Controls.pas:4020."
    function ScreenToClient(const Point: TPoint): TPoint; // @ida "void __usercall $name(TControl *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);" @note "DCC32 MAP Controls.TControl.ScreenToClient. Source vcl/Controls.pas:4035."
    procedure SendCancelMode(Sender: TControl); // @ida "void __usercall $name(TControl *Self@<eax>, TControl *Sender@<edx>);" @note "DCC32 MAP Controls.TControl.SendCancelMode. Source vcl/Controls.pas:4044."
    procedure SendDockNotification(Msg: Cardinal; WParam, LParam: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, unsigned __int32 Msg@<edx>, __int32 WParam@<ecx>, __int32 LParam@<^0>);" @note "DCC32 MAP Controls.TControl.SendDockNotification. Source vcl/Controls.pas:4057."
    procedure SetAutoSize(Value: Boolean); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetAutoSize. Source vcl/Controls.pas:4117." @slot 0x60
    procedure SetName(const Value: TComponentName); override; // @ida "void __usercall $name(TControl *Self@<eax>, TComponentName Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetName. Source vcl/Controls.pas:4126." @slot 0x18
    procedure SetClientSize(Value: TPoint); // @ida "void __usercall $name(TControl *Self@<eax>, TPoint *Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetClientSize. Source vcl/Controls.pas:4138."
    procedure SetParent(AParent: TWinControl); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TWinControl *AParent@<edx>);" @note "DCC32 MAP Controls.TControl.SetParent. Source vcl/Controls.pas:4147." @slot 0x6C
    procedure SetVisible(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetVisible. Source vcl/Controls.pas:4163."
    procedure SetEnabled(Value: Boolean); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetEnabled. Source vcl/Controls.pas:4174." @slot 0x68
    procedure SetPopupMenu(Value: TPopupMenu); // @ida "void __usercall $name(TControl *Self@<eax>, TPopupMenu *Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetPopupMenu. Source vcl/Controls.pas:4217."
    procedure SetTextBuf(Buffer: PAnsiChar); // @ida "void __usercall $name(TControl *Self@<eax>, PAnsiChar Buffer@<edx>);" @note "DCC32 MAP Controls.TControl.SetTextBuf. Source vcl/Controls.pas:4227."
    function GetText: TCaption; // @ida "void __usercall $name(TControl *Self@<eax>, TCaption *Result@<edx>);" @note "DCC32 MAP Controls.TControl.GetText. Source vcl/Controls.pas:4233."
    procedure SetText(const Value: TCaption); // @ida "void __usercall $name(TControl *Self@<eax>, TCaption Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetText. Source vcl/Controls.pas:4242."
    procedure SetBiDiMode(Value: TBiDiMode); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TBiDiMode Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetBiDiMode. Source vcl/Controls.pas:4247." @slot 0x74
    procedure FontChanged(Sender: TObject); // @ida "void __usercall $name(TControl *Self@<eax>, TObject *Sender@<edx>);" @note "DCC32 MAP Controls.TControl.FontChanged. Source vcl/Controls.pas:4257."
    procedure SetParentFont(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetParentFont. Source vcl/Controls.pas:4289."
    procedure SetShowHint(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetShowHint. Source vcl/Controls.pas:4308."
    procedure SetColor(Value: TColor); // @ida "void __usercall $name(TControl *Self@<eax>, TColor Value@<edx>);" @note "DCC32 MAP Controls.TControl.SetColor. Source vcl/Controls.pas:4328."
    procedure SetParentColor(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetParentColor. Source vcl/Controls.pas:4345."
    procedure SetParentBiDiMode(Value: Boolean); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetParentBiDiMode. Source vcl/Controls.pas:4355." @slot 0x70
    procedure SetMouseCapture(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetMouseCapture. Source vcl/Controls.pas:4379."
    procedure SetZOrderPosition(Position: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 Position@<edx>);" @note "DCC32 MAP Controls.TControl.SetZOrderPosition. Source vcl/Controls.pas:4395."
    procedure SetZOrder(TopMost: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool TopMost@<dl>);" @note "DCC32 MAP Controls.TControl.SetZOrder. Source vcl/Controls.pas:4424."
    function GetDeviceContext(var WindowHandle: Cardinal): Cardinal; virtual; // @ida "unsigned __int32 __usercall $name@<eax>(TControl *Self@<eax>, unsigned __int32 *WindowHandle@<edx>);" @note "DCC32 MAP Controls.TControl.GetDeviceContext. Source vcl/Controls.pas:4432." @slot 0x48
    procedure InvalidateControl(IsVisible, IsOpaque: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool IsVisible@<dl>, bool IsOpaque@<cl>);" @note "DCC32 MAP Controls.TControl.InvalidateControl. Source vcl/Controls.pas:4441."
    function MouseActivate(Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer): TMouseActivate; // @ida "TMouseActivate __userpurge $name@<al>(TControl *Self@<eax>, TMouseButton Button@<dl>, TShiftState *Shift@<ecx>, __int32 X@<^8>, __int32 Y@<^4>, __int32 HitTest@<^0>);" @note "DCC32 MAP Controls.TControl.MouseActivate. Source vcl/Controls.pas:4485."
    procedure MouseWheelHandler(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.MouseWheelHandler. Source vcl/Controls.pas:4493."
    procedure Update; virtual; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.Update. Source vcl/Controls.pas:4523." @slot 0x8C
    procedure Repaint; virtual; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.Repaint. Source vcl/Controls.pas:4533." @slot 0x84
    function UseRightToLeftReading: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.UseRightToLeftReading. Source vcl/Controls.pas:4566."
    function UseRightToLeftAlignment: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.UseRightToLeftAlignment. Source vcl/Controls.pas:4571."
    function UseRightToLeftScrollBar: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.UseRightToLeftScrollBar. Source vcl/Controls.pas:4576."
    procedure BeginDrag(Immediate: Boolean; Threshold: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, bool Immediate@<dl>, __int32 Threshold@<ecx>);" @note "DCC32 MAP Controls.TControl.BeginDrag. Source vcl/Controls.pas:4587."
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); // @ida "void __userpurge $name(TControl *Self@<eax>, TObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^8>, TDragState State@<^4>, bool *Accept@<^0>);" @note "DCC32 MAP Controls.TControl.DragOver. Source vcl/Controls.pas:4630."
    procedure DragDrop(Source: TObject; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.DragDrop. Source vcl/Controls.pas:4641."
    procedure DoStartDrag(var DragObject: TDragObject); // @ida "void __usercall $name(TControl *Self@<eax>, TDragObject **DragObject@<edx>);" @note "DCC32 MAP Controls.TControl.DoStartDrag. Source vcl/Controls.pas:4646."
    procedure DoEndDrag(Target: TObject; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TObject *Target@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.DoEndDrag. Source vcl/Controls.pas:4651."
    procedure PositionDockRect(DragDockObject: TDragDockObject); // @ida "void __usercall $name(TControl *Self@<eax>, TDragDockObject *DragDockObject@<edx>);" @note "DCC32 MAP Controls.TControl.PositionDockRect. Source vcl/Controls.pas:4656."
    procedure DockTrackNoTarget(Source: TDragDockObject; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TDragDockObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.DockTrackNoTarget. Source vcl/Controls.pas:4690."
    procedure DoEndDock(Target: TObject; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TObject *Target@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.DoEndDock. Source vcl/Controls.pas:4695."
    procedure DoStartDock(var DragObject: TDragObject); // @ida "void __usercall $name(TControl *Self@<eax>, TDragObject **DragObject@<edx>);" @note "DCC32 MAP Controls.TControl.DoStartDock. Source vcl/Controls.pas:4700."
    procedure DoMouseActivate(var Message: TCMMouseActivate); // @ida "void __usercall $name(TControl *Self@<eax>, TCMMouseActivate *Message@<edx>);" @note "DCC32 MAP Controls.TControl.DoMouseActivate. Source vcl/Controls.pas:4705."
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; // @ida "bool __userpurge $name@<al>(TControl *Self@<eax>, TShiftState *Shift@<edx>, __int32 WheelDelta@<ecx>, TPoint *MousePos@<^0>);" @note "DCC32 MAP Controls.TControl.DoMouseWheel. Source vcl/Controls.pas:4712."
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, TShiftState *Shift@<edx>, TPoint *MousePos@<ecx>);" @note "DCC32 MAP Controls.TControl.DoMouseWheelDown. Source vcl/Controls.pas:4738."
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, TShiftState *Shift@<edx>, TPoint *MousePos@<ecx>);" @note "DCC32 MAP Controls.TControl.DoMouseWheelUp. Source vcl/Controls.pas:4745."
    procedure DefaultDockImage(DragDockObject: TDragDockObject; Erase: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, TDragDockObject *DragDockObject@<edx>, bool Erase@<cl>);" @note "DCC32 MAP Controls.TControl.DefaultDockImage. Source vcl/Controls.pas:4752."
    procedure DoDragMsg(var DragMsg: TCMDrag); // @ida "void __usercall $name(TControl *Self@<eax>, TCMDrag *DragMsg@<edx>);" @note "DCC32 MAP Controls.TControl.DoDragMsg. Source vcl/Controls.pas:4794."
    function ManualDock(NewDockSite: TWinControl; DropControl: TControl; ControlSide: TAlign): Boolean; // @ida "bool __userpurge $name@<al>(TControl *Self@<eax>, TWinControl *NewDockSite@<edx>, TControl *DropControl@<ecx>, TAlign ControlSide@<^0>);" @note "DCC32 MAP Controls.TControl.ManualDock. Source vcl/Controls.pas:4828."
    function ManualFloat(ScreenPos: TRect): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, TRect *ScreenPos@<edx>);" @note "DCC32 MAP Controls.TControl.ManualFloat. Source vcl/Controls.pas:4880."
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; virtual; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TControl.CanResize. Source vcl/Controls.pas:4932." @slot 0x30
    function DoCanAutoSize(var NewWidth, NewHeight: Integer): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TControl.DoCanAutoSize. Source vcl/Controls.pas:4938."
    function DoCanResize(var NewWidth, NewHeight: Integer): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TControl.DoCanResize. Source vcl/Controls.pas:4955."
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); virtual; // @ida "void __userpurge $name(TControl *Self@<eax>, __int32 *MinWidth@<edx>, __int32 *MinHeight@<ecx>, __int32 *MaxWidth@<^4>, __int32 *MaxHeight@<^0>);" @note "DCC32 MAP Controls.TControl.ConstrainedResize. Source vcl/Controls.pas:4961." @slot 0x38
    function CalcCursorPos: TPoint; // @ida "void __usercall $name(TControl *Self@<eax>, TPoint *Result@<edx>);" @note "DCC32 MAP Controls.TControl.CalcCursorPos. Source vcl/Controls.pas:4968."
    function DesignWndProc(var Message: TMessage): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.DesignWndProc. Source vcl/Controls.pas:4974."
    procedure DoConstrainedResize(var NewWidth, NewHeight: Integer); // @ida "void __usercall $name(TControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TControl.DoConstrainedResize. Source vcl/Controls.pas:4981."
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint; // @ida "__int32 __userpurge $name@<eax>(TControl *Self@<eax>, unsigned __int32 Msg@<edx>, __int32 WParam@<ecx>, __int32 LParam@<^0>);" @note "DCC32 MAP Controls.TControl.Perform. Source vcl/Controls.pas:5013."
    procedure CalcDockSizes; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.CalcDockSizes. Source vcl/Controls.pas:5025."
    procedure UpdateBoundsRect(const R: TRect); // @ida "void __usercall $name(TControl *Self@<eax>, TRect *R@<edx>);" @note "DCC32 MAP Controls.TControl.UpdateBoundsRect. Source vcl/Controls.pas:5043."
    procedure WndProc(var Message: TMessage); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WndProc. Source vcl/Controls.pas:5057." @slot 0x78
    procedure DefaultHandler(Message: Pointer); // @ida "void __usercall $name(TControl *Self@<eax>, void * Message@<edx>);" @note "DCC32 MAP Controls.TControl.DefaultHandler. Source vcl/Controls.pas:5149."
    procedure DefineProperties(Filer: TFiler); override; // @ida "void __usercall $name(TControl *Self@<eax>, TFiler *Filer@<edx>);" @note "DCC32 MAP Controls.TControl.DefineProperties. Source vcl/Controls.pas:5182." @slot 0x4
    procedure Click; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.Click. Source vcl/Controls.pas:5219."
    procedure DblClick; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.DblClick. Source vcl/Controls.pas:5232."
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TMouseButton Button@<dl>, TShiftState *Shift@<ecx>, __int32 X@<^4>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.MouseDown. Source vcl/Controls.pas:5237."
    procedure DoMouseDown(var Message: TWMMouse; Button: TMouseButton; Shift: TShiftState); // @ida "void __userpurge $name(TControl *Self@<eax>, TWMMouse *Message@<edx>, TMouseButton Button@<cl>, TShiftState *Shift@<^0>);" @note "DCC32 MAP Controls.TControl.DoMouseDown. Source vcl/Controls.pas:5243."
    procedure WMLButtonDown(var Message: TWMLButtonDown); // @ida "void __usercall $name(TControl *Self@<eax>, TWMLButtonDown *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMLButtonDown. Source vcl/Controls.pas:5255."
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); // @ida "void __usercall $name(TControl *Self@<eax>, TWMNCLButtonDown *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMNCLButtonDown. Source vcl/Controls.pas:5264."
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); // @ida "void __usercall $name(TControl *Self@<eax>, TWMLButtonDblClk *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMLButtonDblClk. Source vcl/Controls.pas:5270."
    function CheckNewSize(var NewWidth, NewHeight: Integer): Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TControl.CheckNewSize. Source vcl/Controls.pas:5284."
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TShiftState *Shift@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.MouseMove. Source vcl/Controls.pas:5329."
    procedure WMMouseMove(var Message: TWMMouseMove); // @ida "void __usercall $name(TControl *Self@<eax>, TWMMouseMove *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMMouseMove. Source vcl/Controls.pas:5334."
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); // @ida "void __userpurge $name(TControl *Self@<eax>, TMouseButton Button@<dl>, TShiftState *Shift@<ecx>, __int32 X@<^4>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TControl.MouseUp. Source vcl/Controls.pas:5346."
    procedure DoMouseUp(var Message: TWMMouse; Button: TMouseButton); // @ida "void __usercall $name(TControl *Self@<eax>, TWMMouse *Message@<edx>, TMouseButton Button@<cl>);" @note "DCC32 MAP Controls.TControl.DoMouseUp. Source vcl/Controls.pas:5352."
    procedure WMLButtonUp(var Message: TWMLButtonUp); // @ida "void __usercall $name(TControl *Self@<eax>, TWMLButtonUp *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMLButtonUp. Source vcl/Controls.pas:5358."
    procedure WMRButtonUp(var Message: TWMRButtonUp); // @nameonly @note "DCC32 MAP Controls.TControl.WMRButtonUp. Source vcl/Controls.pas:5370. Prototype pending: RET mismatch: expected 0, native []."
    procedure WMMButtonUp(var Message: TWMMButtonUp); // @ida "void __usercall $name(TControl *Self@<eax>, TWMMButtonUp *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMMButtonUp. Source vcl/Controls.pas:5376."
    procedure WMMouseWheel(var Message: TWMMouseWheel); // @ida "void __usercall $name(TControl *Self@<eax>, TWMMouseWheel *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMMouseWheel. Source vcl/Controls.pas:5382."
    procedure WMCancelMode(var Message: TWMCancelMode); // @ida "void __usercall $name(TControl *Self@<eax>, TWMCancelMode *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMCancelMode. Source vcl/Controls.pas:5394."
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); // @ida "void __usercall $name(TControl *Self@<eax>, TWMWindowPosChanged *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMWindowPosChanged. Source vcl/Controls.pas:5407."
    procedure CMVisibleChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMVisibleChanged. Source vcl/Controls.pas:5432."
    procedure CMParentColorChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMParentColorChanged. Source vcl/Controls.pas:5454."
    procedure CMParentBiDiModeChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMParentBiDiModeChanged. Source vcl/Controls.pas:5477."
    procedure CMMouseWheel(var Message: TCMMouseWheel); // @ida "void __usercall $name(TControl *Self@<eax>, TCMMouseWheel *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMMouseWheel. Source vcl/Controls.pas:5486."
    procedure CMBiDiModeChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMBiDiModeChanged. Source vcl/Controls.pas:5499."
    procedure CMParentShowHintChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMParentShowHintChanged. Source vcl/Controls.pas:5504."
    procedure CMParentFontChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMParentFontChanged. Source vcl/Controls.pas:5514."
    procedure CMSysFontChanged(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMSysFontChanged. Source vcl/Controls.pas:5525."
    procedure CMMouseEnter(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMMouseEnter. Source vcl/Controls.pas:5539."
    procedure CMMouseLeave(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMMouseLeave. Source vcl/Controls.pas:5547."
    function CreateFloatingDockSite(Bounds: TRect): TWinControl; // @ida "TWinControl * __usercall $name@<eax>(TControl *Self@<eax>, TRect *Bounds@<edx>);" @note "DCC32 MAP Controls.TControl.CreateFloatingDockSite. Source vcl/Controls.pas:5560."
    procedure CMFloat(var Message: TCMFloat); // @ida "void __usercall $name(TControl *Self@<eax>, TCMFloat *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMFloat. Source vcl/Controls.pas:5577."
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, TObject *Sender@<edx>, bool CheckDefaults@<cl>);" @note "DCC32 MAP Controls.TControl.ActionChange. Source vcl/Controls.pas:5607."
    procedure DoActionChange(Sender: TObject); // @ida "void __usercall $name(TControl *Self@<eax>, TObject *Sender@<edx>);" @note "DCC32 MAP Controls.TControl.DoActionChange. Source vcl/Controls.pas:5625."
    function IsEnabledStored: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.IsEnabledStored. Source vcl/Controls.pas:5640."
    function IsHintStored: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.IsHintStored. Source vcl/Controls.pas:5645."
    function IsHelpContextStored: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.IsHelpContextStored. Source vcl/Controls.pas:5650."
    function IsVisibleStored: Boolean; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.IsVisibleStored. Source vcl/Controls.pas:5655."
    procedure Loaded; virtual; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.Loaded. Source vcl/Controls.pas:5665." @slot 0xC
    procedure AssignTo(Dest: TPersistent); virtual; // @ida "void __usercall $name(TControl *Self@<eax>, TPersistent *Dest@<edx>);" @note "DCC32 MAP Controls.TControl.AssignTo. Source vcl/Controls.pas:5672." @slot 0x0
    function GetDockEdge(MousePos: TPoint): TAlign; // @ida "TAlign __usercall $name@<al>(TControl *Self@<eax>, TPoint *MousePos@<edx>);" @note "DCC32 MAP Controls.TControl.GetDockEdge. Source vcl/Controls.pas:5686."
    function GetFloating: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.GetFloating. Source vcl/Controls.pas:5724." @slot 0x54
    procedure AdjustSize; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.AdjustSize. Source vcl/Controls.pas:5734."
    function DrawTextBiDiModeFlagsReadingOnly: Longint; // @ida "__int32 __usercall $name@<eax>(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.DrawTextBiDiModeFlagsReadingOnly. Source vcl/Controls.pas:5751."
    procedure CMHintShow(var Message: TMessage); // @ida "void __usercall $name(TControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMHintShow. Source vcl/Controls.pas:5764."
    procedure WMContextMenu(var Message: TWMContextMenu); // @ida "void __usercall $name(TControl *Self@<eax>, TWMContextMenu *Message@<edx>);" @note "DCC32 MAP Controls.TControl.WMContextMenu. Source vcl/Controls.pas:5771."
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, TPoint *MousePos@<edx>, bool *Handled@<ecx>);" @note "DCC32 MAP Controls.TControl.DoContextPopup. Source vcl/Controls.pas:5817."
    procedure CMMouseActivate(var Message: TCMMouseActivate); // @ida "void __usercall $name(TControl *Self@<eax>, TCMMouseActivate *Message@<edx>);" @note "DCC32 MAP Controls.TControl.CMMouseActivate. Source vcl/Controls.pas:5877."
    procedure SetAlignWithMargins(Value: Boolean); // @ida "void __usercall $name(TControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControl.SetAlignWithMargins. Source vcl/Controls.pas:5899."
    procedure UpdateExplicitBounds; // @ida "void __usercall $name(TControl *Self@<eax>);" @note "DCC32 MAP Controls.TControl.UpdateExplicitBounds. Source vcl/Controls.pas:5911."
    procedure ReadExplicitWidth(Reader: TReader); // @ida "void __usercall $name(TControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TControl.ReadExplicitWidth. Source vcl/Controls.pas:5937."
    procedure ReadExplicitTop(Reader: TReader); // @ida "void __usercall $name(TControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TControl.ReadExplicitTop. Source vcl/Controls.pas:5947."
    procedure ReadExplicitHeight(Reader: TReader); // @ida "void __usercall $name(TControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TControl.ReadExplicitHeight. Source vcl/Controls.pas:5952."
    procedure ReadExplicitLeft(Reader: TReader); // @ida "void __usercall $name(TControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TControl.ReadExplicitLeft. Source vcl/Controls.pas:5957."
  end;

  TWinControl = class(TControl) // @size 0x24C
  public
    constructor Create(AOwner: TComponent); override; // @ida "TWinControl * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Controls.TWinControl.Create. Source vcl/Controls.pas:5983." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Controls.TWinControl.Destroy. Source vcl/Controls.pas:6029."
    procedure FixupTabList; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.FixupTabList. Source vcl/Controls.pas:6063."
    procedure ReadState(Reader: TReader); override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TWinControl.ReadState. Source vcl/Controls.pas:6092." @slot 0x14
    procedure AdjustClientRect(var Rect: TRect); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TRect *Rect@<edx>);" @note "DCC32 MAP Controls.TWinControl.AdjustClientRect. Source vcl/Controls.pas:6105." @slot 0x90
    procedure ArrangeControl(AControl: TControl; const ParentSize: TPoint; AAlign: TAlign; AAlignInfo: TAlignInfo; var Rect: TRect; UpdateAnchorOrigin: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TControl *AControl@<edx>, TPoint *ParentSize@<ecx>, TAlign AAlign@<^12>, TAlignInfo *AAlignInfo@<^8>, TRect *Rect@<^4>, bool UpdateAnchorOrigin@<^0>);" @note "DCC32 MAP Controls.TWinControl.ArrangeControl. Source vcl/Controls.pas:6114."
    procedure AlignControls(AControl: TControl; var Rect: TRect); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>, TRect *Rect@<ecx>);" @note "DCC32 MAP Controls.TWinControl.AlignControls. Source vcl/Controls.pas:6213." @slot 0x94
    procedure AlignControl(AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.AlignControl. Source vcl/Controls.pas:6439."
    procedure EnableAlign; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.EnableAlign. Source vcl/Controls.pas:6464."
    procedure DoFlipChildren; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DoFlipChildren. Source vcl/Controls.pas:6478."
    procedure FlipChildren(AllLevels: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool AllLevels@<dl>);" @note "DCC32 MAP Controls.TWinControl.FlipChildren. Source vcl/Controls.pas:6501."
    function ContainsControl(Control: TControl): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TControl *Control@<edx>);" @note "DCC32 MAP Controls.TWinControl.ContainsControl. Source vcl/Controls.pas:6535."
    procedure RemoveFocus(Removing: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Removing@<dl>);" @note "DCC32 MAP Controls.TWinControl.RemoveFocus. Source vcl/Controls.pas:6541."
    procedure Insert(AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.Insert. Source vcl/Controls.pas:6549."
    procedure Remove(AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.Remove. Source vcl/Controls.pas:6563."
    procedure InsertControl(AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.InsertControl. Source vcl/Controls.pas:6574."
    procedure RemoveControl(AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.RemoveControl. Source vcl/Controls.pas:6601."
    function GetControl(Index: Integer): TControl; // @ida "TControl * __usercall $name@<eax>(TWinControl *Self@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetControl. Source vcl/Controls.pas:6623."
    function GetControlCount: Integer; // @ida "__int32 __usercall $name@<eax>(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.GetControlCount. Source vcl/Controls.pas:6633."
    procedure Broadcast(Message: Pointer); // @ida "void __usercall $name(TWinControl *Self@<eax>, void * Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.Broadcast. Source vcl/Controls.pas:6640."
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TComponent *AComponent@<edx>, TOperation Operation@<cl>);" @note "DCC32 MAP Controls.TWinControl.Notification. Source vcl/Controls.pas:6651." @slot 0x10
    procedure NotifyControls(Msg: Word); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int16 Msg@<dx>);" @note "DCC32 MAP Controls.TWinControl.NotifyControls. Source vcl/Controls.pas:6659."
    procedure AddBiDiModeExStyle(var ExStyle: DWord); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int32 *ExStyle@<edx>);" @note "DCC32 MAP Controls.TWinControl.AddBiDiModeExStyle. Source vcl/Controls.pas:6691."
    procedure CreateParams(var Params: TCreateParams); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TCreateParams *Params@<edx>);" @note "DCC32 MAP Controls.TWinControl.CreateParams. Source vcl/Controls.pas:6704." @slot 0x9C
    procedure CreateWnd; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.CreateWnd. Source vcl/Controls.pas:6736." @slot 0xA4
    procedure CreateWindowHandle(const Params: TCreateParams); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TCreateParams *Params@<edx>);" @note "DCC32 MAP Controls.TWinControl.CreateWindowHandle. Source vcl/Controls.pas:6776." @slot 0xA0
    procedure ReadDesignSize(Reader: TReader); // @ida "void __usercall $name(TWinControl *Self@<eax>, TReader *Reader@<edx>);" @note "DCC32 MAP Controls.TWinControl.ReadDesignSize. Source vcl/Controls.pas:6783."
    procedure WriteDesignSize(Writer: TWriter); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWriter *Writer@<edx>);" @note "DCC32 MAP Controls.TWinControl.WriteDesignSize. Source vcl/Controls.pas:6792."
    procedure DefineProperties(Filer: TFiler); override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TFiler *Filer@<edx>);" @note "DCC32 MAP Controls.TWinControl.DefineProperties. Source vcl/Controls.pas:6801." @slot 0x4
    procedure DestroyWnd; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DestroyWnd. Source vcl/Controls.pas:6836." @slot 0xB8
    procedure DestroyWindowHandle; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DestroyWindowHandle. Source vcl/Controls.pas:6853." @slot 0xB4
    function PrecedingWindow(Control: TWinControl): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(TWinControl *Self@<eax>, TWinControl *Control@<edx>);" @note "DCC32 MAP Controls.TWinControl.PrecedingWindow. Source vcl/Controls.pas:6865."
    procedure CreateHandle; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.CreateHandle. Source vcl/Controls.pas:6877." @slot 0x98
    function CustomAlignInsertBefore(C1, C2: TControl): Boolean; virtual; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TControl *C1@<edx>, TControl *C2@<ecx>);" @note "DCC32 MAP Controls.TWinControl.CustomAlignInsertBefore. Source vcl/Controls.pas:6894." @slot 0xA8
    procedure CustomAlignPosition(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo); virtual; // @ida "void __userpurge $name(TWinControl *Self@<eax>, TControl *Control@<edx>, __int32 *NewLeft@<ecx>, __int32 *NewTop@<^16>, __int32 *NewWidth@<^12>, __int32 *NewHeight@<^8>, TRect *AlignRect@<^4>, TAlignInfo *AlignInfo@<^0>);" @note "DCC32 MAP Controls.TWinControl.CustomAlignPosition. Source vcl/Controls.pas:6902." @slot 0xAC
    procedure DestroyHandle; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DestroyHandle. Source vcl/Controls.pas:6926." @slot 0xB0
    procedure RecreateWnd; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.RecreateWnd. Source vcl/Controls.pas:6943."
    procedure CMRecreateWnd(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMRecreateWnd. Source vcl/Controls.pas:6948."
    procedure SetParentWindow(Value: Cardinal); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int32 Value@<edx>);" @note "DCC32 MAP Controls.TWinControl.SetParentWindow. Source vcl/Controls.pas:7011."
    procedure MainWndProc(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.MainWndProc. Source vcl/Controls.pas:7036."
    function ControlAtPos(const Pos: TPoint; AllowDisabled, AllowWinControls, AllLevels: Boolean): TControl; // @ida "TControl * __userpurge $name@<eax>(TWinControl *Self@<eax>, TPoint *Pos@<edx>, bool AllowDisabled@<cl>, bool AllowWinControls@<^4>, bool AllLevels@<^0>);" @note "DCC32 MAP Controls.TWinControl.ControlAtPos. Source vcl/Controls.pas:7050."
    function IsControlActivateMsg(var Message: TWMMouseActivate; Control: TControl): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMMouseActivate *Message@<edx>, TControl *Control@<ecx>);" @note "DCC32 MAP Controls.TWinControl.IsControlActivateMsg. Source vcl/Controls.pas:7090."
    function IsControlMouseMsg(var Message: TWMMouse): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMMouse *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.IsControlMouseMsg. Source vcl/Controls.pas:7130."
    procedure DefaultHandler(Message: Pointer); // @ida "void __usercall $name(TWinControl *Self@<eax>, void * Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.DefaultHandler. Source vcl/Controls.pas:7277."
    procedure PaintHandler(var Message: TWMPaint); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMPaint *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.PaintHandler. Source vcl/Controls.pas:7325."
    procedure PaintWindow(DC: Cardinal); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int32 DC@<edx>);" @note "DCC32 MAP Controls.TWinControl.PaintWindow. Source vcl/Controls.pas:7360." @slot 0xC4
    procedure PaintControls(DC: Cardinal; First: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int32 DC@<edx>, TControl *First@<ecx>);" @note "DCC32 MAP Controls.TWinControl.PaintControls. Source vcl/Controls.pas:7371."
    procedure PaintTo; // @nameonly @note "DCC32 MAP Controls.TWinControl.PaintTo. Prototype pending: no unique source declaration."
    procedure WMNotify(var Message: TWMNotify); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMNotify *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMNotify. Source vcl/Controls.pas:7582."
    procedure WMSysColorChange(var Message: TWMSysColorChange); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMSysColorChange *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMSysColorChange. Source vcl/Controls.pas:7587."
    procedure WMCompareItem(var Message: TWMCompareItem); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMCompareItem *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMCompareItem. Source vcl/Controls.pas:7618."
    procedure WMDeleteItem(var Message: TWMDeleteItem); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMDeleteItem *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMDeleteItem. Source vcl/Controls.pas:7623."
    procedure WMDrawItem(var Message: TWMDrawItem); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMDrawItem *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMDrawItem. Source vcl/Controls.pas:7628."
    procedure WMMeasureItem(var Message: TWMMeasureItem); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMMeasureItem *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMMeasureItem. Source vcl/Controls.pas:7633."
    procedure WMMouseActivate(var Message: TWMMouseActivate); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMMouseActivate *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMMouseActivate. Source vcl/Controls.pas:7638."
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMEraseBkgnd *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMEraseBkgnd. Source vcl/Controls.pas:7647."
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMWindowPosChanged *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMWindowPosChanged. Source vcl/Controls.pas:7669."
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMWindowPosChanging *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMWindowPosChanging. Source vcl/Controls.pas:7689."
    procedure WMSize(var Message: TWMSize); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMSize *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMSize. Source vcl/Controls.pas:7698."
    procedure WMMove(var Message: TWMMove); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMMove *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMMove. Source vcl/Controls.pas:7707."
    procedure WMSetFocus(var Message: TWMSetFocus); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMSetFocus *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMSetFocus. Source vcl/Controls.pas:7759."
    procedure WMKillFocus(var Message: TWMSetFocus); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMSetFocus *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMKillFocus. Source vcl/Controls.pas:7766."
    procedure WMIMEStartComp(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMIMEStartComp. Source vcl/Controls.pas:7773."
    procedure WMIMEEndComp(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMIMEEndComp. Source vcl/Controls.pas:7779."
    procedure SetIme; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.SetIme. Source vcl/Controls.pas:7836."
    procedure ResetIme; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.ResetIme. Source vcl/Controls.pas:7859."
    procedure DoEnter; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DoEnter. Source vcl/Controls.pas:7880."
    procedure DoExit; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.DoExit. Source vcl/Controls.pas:7885."
    procedure DockDrop(Source: TDragDockObject; X, Y: Integer); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TDragDockObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TWinControl.DockDrop. Source vcl/Controls.pas:7890."
    procedure DoDockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TDragDockObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^8>, TDragState State@<^4>, bool *Accept@<^0>);" @note "DCC32 MAP Controls.TWinControl.DoDockOver. Source vcl/Controls.pas:7897."
    procedure DockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TDragDockObject *Source@<edx>, __int32 X@<ecx>, __int32 Y@<^8>, TDragState State@<^4>, bool *Accept@<^0>);" @note "DCC32 MAP Controls.TWinControl.DockOver. Source vcl/Controls.pas:7904."
    function DoUnDock(NewTarget: TWinControl; Client: TControl): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWinControl *NewTarget@<edx>, TControl *Client@<ecx>);" @note "DCC32 MAP Controls.TWinControl.DoUnDock. Source vcl/Controls.pas:7911."
    procedure ReloadDockedControl(const AControlName: AnsiString; var AControl: TControl); // @ida "void __usercall $name(TWinControl *Self@<eax>, char * AControlName@<edx>, TControl **AControl@<ecx>);" @note "DCC32 MAP Controls.TWinControl.ReloadDockedControl. Source vcl/Controls.pas:7918."
    function GetDockClients(Index: Integer): TControl; // @ida "TControl * __usercall $name@<eax>(TWinControl *Self@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetDockClients. Source vcl/Controls.pas:7930."
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TControl *Client@<edx>, TRect *InfluenceRect@<ecx>, TPoint *MousePos@<^4>, bool *CanDock@<^0>);" @note "DCC32 MAP Controls.TWinControl.GetSiteInfo. Source vcl/Controls.pas:7936."
    function GetVisibleDockClientCount: Integer; // @ida "__int32 __usercall $name@<eax>(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.GetVisibleDockClientCount. Source vcl/Controls.pas:7947."
    function CreateDockManager: IDockManager; // @ida "void __usercall $name(TWinControl *Self@<eax>, IDockManager **Result@<edx>);" @note "DCC32 MAP Controls.TWinControl.CreateDockManager. Source vcl/Controls.pas:7962."
    procedure SetDesignVisible(Value: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetDesignVisible. Source vcl/Controls.pas:7971."
    procedure SetDockSite(Value: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetDockSite. Source vcl/Controls.pas:7983."
    procedure CMDockClient(var Message: TCMDockClient); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMDockClient *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMDockClient. Source vcl/Controls.pas:8007."
    procedure CMUnDockClient(var Message: TCMUnDockClient); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMUnDockClient *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMUnDockClient. Source vcl/Controls.pas:8033."
    procedure CMFloat(var Message: TCMFloat); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMFloat *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMFloat. Source vcl/Controls.pas:8043."
    procedure KeyDown(var Key: Word; Shift: TShiftState); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int16 *Key@<edx>, TShiftState *Shift@<ecx>);" @note "DCC32 MAP Controls.TWinControl.KeyDown. Source vcl/Controls.pas:8060."
    function DoKeyDown(var Message: TWMKey): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMKey *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.DoKeyDown. Source vcl/Controls.pas:8065."
    procedure KeyUp(var Key: Word; Shift: TShiftState); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int16 *Key@<edx>, TShiftState *Shift@<ecx>);" @note "DCC32 MAP Controls.TWinControl.KeyUp. Source vcl/Controls.pas:8110."
    function DoKeyUp(var Message: TWMKey): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMKey *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.DoKeyUp. Source vcl/Controls.pas:8115."
    procedure KeyPress(var Key: Char); // @ida "void __usercall $name(TWinControl *Self@<eax>, char *Key@<edx>);" @note "DCC32 MAP Controls.TWinControl.KeyPress. Source vcl/Controls.pas:8146."
    function DoKeyPress(var Message: TWMKey): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMKey *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.DoKeyPress. Source vcl/Controls.pas:8151."
    procedure WMSysCommand(var Message: TWMSysCommand); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMSysCommand *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMSysCommand. Source vcl/Controls.pas:8176."
    procedure WMParentNotify(var Message: TWMParentNotify); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMParentNotify *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMParentNotify. Source vcl/Controls.pas:8228."
    procedure WMDestroy(var Message: TWMDestroy); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMDestroy *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMDestroy. Source vcl/Controls.pas:8240."
    procedure WMNCDestroy(var Message: TWMNCDestroy); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMNCDestroy *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMNCDestroy. Source vcl/Controls.pas:8257."
    procedure WMNCHitTest(var Message: TWMNCHitTest); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMNCHitTest *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMNCHitTest. Source vcl/Controls.pas:8264."
    function PaletteChanged(Foreground: Boolean): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, bool Foreground@<dl>);" @note "DCC32 MAP Controls.TWinControl.PaletteChanged. Source vcl/Controls.pas:8273."
    procedure WMQueryNewPalette(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMQueryNewPalette. Source vcl/Controls.pas:8286."
    procedure WMPaletteChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMPaletteChanged. Source vcl/Controls.pas:8292."
    procedure CMShowHintChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMShowHintChanged. Source vcl/Controls.pas:8297."
    procedure CMBiDiModeChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMBiDiModeChanged. Source vcl/Controls.pas:8303."
    procedure CMEnter(var Message: TCMEnter); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMEnter *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMEnter. Source vcl/Controls.pas:8310."
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMDesignHitTest *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMDesignHitTest. Source vcl/Controls.pas:8329."
    procedure CMVisibleChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMVisibleChanged. Source vcl/Controls.pas:8359."
    procedure CMShowingChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMShowingChanged. Source vcl/Controls.pas:8366."
    procedure CMEnabledChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMEnabledChanged. Source vcl/Controls.pas:8375."
    procedure CMColorChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMColorChanged. Source vcl/Controls.pas:8382."
    procedure CMFontChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMFontChanged. Source vcl/Controls.pas:8389."
    procedure CMCursorChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMCursorChanged. Source vcl/Controls.pas:8396."
    procedure CMBorderChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMBorderChanged. Source vcl/Controls.pas:8408."
    procedure CMCtl3DChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMCtl3DChanged. Source vcl/Controls.pas:8420."
    procedure CMParentCtl3DChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMParentCtl3DChanged. Source vcl/Controls.pas:8427."
    procedure CMDrag(var Message: TCMDrag); // @ida "void __usercall $name(TWinControl *Self@<eax>, TCMDrag *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMDrag. Source vcl/Controls.pas:8458."
    procedure CMSysFontChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMSysFontChanged. Source vcl/Controls.pas:8482."
    function IsMenuKey(var Message: TWMKey): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TWMKey *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.IsMenuKey. Source vcl/Controls.pas:8488."
    procedure CNKeyDown(var Message: TWMKeyDown); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMKeyDown *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CNKeyDown. Source vcl/Controls.pas:8513."
    procedure CNKeyUp(var Message: TWMKeyUp); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMKeyUp *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CNKeyUp. Source vcl/Controls.pas:8544."
    procedure CNChar(var Message: TWMChar); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMChar *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CNChar. Source vcl/Controls.pas:8555."
    procedure CNSysKeyDown(var Message: TWMKeyDown); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMKeyDown *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CNSysKeyDown. Source vcl/Controls.pas:8568."
    procedure CNSysChar(var Message: TWMChar); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMChar *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CNSysChar. Source vcl/Controls.pas:8584."
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override; // @ida "void __userpurge $name(TWinControl *Self@<eax>, __int32 ALeft@<edx>, __int32 ATop@<ecx>, __int32 AWidth@<^4>, __int32 AHeight@<^0>);" @note "DCC32 MAP Controls.TWinControl.SetBounds. Source vcl/Controls.pas:8593." @slot 0x88
    procedure ScaleControls(M, D: Integer); // @ida "void __usercall $name(TWinControl *Self@<eax>, __int32 M@<edx>, __int32 D@<ecx>);" @note "DCC32 MAP Controls.TWinControl.ScaleControls. Source vcl/Controls.pas:8623."
    procedure ChangeScale(M, D: Integer); // @ida "void __usercall $name(TWinControl *Self@<eax>, __int32 M@<edx>, __int32 D@<ecx>);" @note "DCC32 MAP Controls.TWinControl.ChangeScale. Source vcl/Controls.pas:8630."
    procedure ScrollBy(DeltaX, DeltaY: Integer); // @ida "void __usercall $name(TWinControl *Self@<eax>, __int32 DeltaX@<edx>, __int32 DeltaY@<ecx>);" @note "DCC32 MAP Controls.TWinControl.ScrollBy. Source vcl/Controls.pas:8663."
    procedure ShowControl(AControl: TControl); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TWinControl.ShowControl. Source vcl/Controls.pas:8687." @slot 0xCC
    procedure SetZOrderPosition(Position: Integer); // @ida "void __usercall $name(TWinControl *Self@<eax>, __int32 Position@<edx>);" @note "DCC32 MAP Controls.TWinControl.SetZOrderPosition. Source vcl/Controls.pas:8692."
    procedure SetZOrder(TopMost: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool TopMost@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetZOrder. Source vcl/Controls.pas:8727."
    function GetDeviceContext(var WindowHandle: Cardinal): Cardinal; override; // @ida "unsigned __int32 __usercall $name@<eax>(TWinControl *Self@<eax>, unsigned __int32 *WindowHandle@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetDeviceContext. Source vcl/Controls.pas:8745." @slot 0x48
    procedure CMInvalidate(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMInvalidate. Source vcl/Controls.pas:8779."
    procedure Update; override; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.Update. Source vcl/Controls.pas:8798." @slot 0x8C
    procedure Repaint; override; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.Repaint. Source vcl/Controls.pas:8803." @slot 0x84
    procedure InvalidateFrame; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.InvalidateFrame. Source vcl/Controls.pas:8809."
    function CanFocus: Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.CanFocus. Source vcl/Controls.pas:8818."
    procedure SetFocus; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.SetFocus. Source vcl/Controls.pas:8837." @slot 0xD4
    function Focused: Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.Focused. Source vcl/Controls.pas:8850."
    procedure HandleNeeded; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.HandleNeeded. Source vcl/Controls.pas:8855."
    function GetControlExtents: TRect; virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TRect *Result@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetControlExtents. Source vcl/Controls.pas:8870." @slot 0xC0
    function GetClientOrigin: TPoint; override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TPoint *Result@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetClientOrigin. Source vcl/Controls.pas:8889." @slot 0x40
    procedure SetBorderWidth; // @nameonly @note "DCC32 MAP Controls.TWinControl.SetBorderWidth. Source vcl/Controls.pas:8911. Prototype pending: unsupported source type TBorderWidth: 0..MaxInt."
    procedure SetCtl3D(Value: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetCtl3D. Source vcl/Controls.pas:8920."
    function GetTabOrder: TTabOrder; // @ida "TTabOrder __usercall $name@<ax>(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.GetTabOrder. Source vcl/Controls.pas:8964."
    procedure UpdateTabOrder(Value: TTabOrder); // @ida "void __usercall $name(TWinControl *Self@<eax>, TTabOrder Value@<dx>);" @note "DCC32 MAP Controls.TWinControl.UpdateTabOrder. Source vcl/Controls.pas:8972."
    procedure SetUseDockManager(Value: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetUseDockManager. Source vcl/Controls.pas:9014."
    procedure UpdateBounds; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.UpdateBounds. Source vcl/Controls.pas:9029."
    procedure GetTabOrderList(List: TList); // @ida "void __usercall $name(TWinControl *Self@<eax>, TList *List@<edx>);" @note "DCC32 MAP Controls.TWinControl.GetTabOrderList. Source vcl/Controls.pas:9059."
    function FindNextControl(CurControl: TWinControl; GoForward, CheckTabStop, CheckParent: Boolean): TWinControl; // @ida "TWinControl * __userpurge $name@<eax>(TWinControl *Self@<eax>, TWinControl *CurControl@<edx>, bool GoForward@<cl>, bool CheckTabStop@<^4>, bool CheckParent@<^0>);" @note "DCC32 MAP Controls.TWinControl.FindNextControl. Source vcl/Controls.pas:9073."
    procedure SelectNext(CurControl: TWinControl; GoForward, CheckTabStop: Boolean); // @ida "void __userpurge $name(TWinControl *Self@<eax>, TWinControl *CurControl@<edx>, bool GoForward@<cl>, bool CheckTabStop@<^0>);" @note "DCC32 MAP Controls.TWinControl.SelectNext. Source vcl/Controls.pas:9111."
    procedure GetChildren; // @nameonly @note "DCC32 MAP Controls.TWinControl.GetChildren. Source vcl/Controls.pas:9135. Prototype pending: unsupported source type TGetChildProc: procedure (Child: TComponent) of object."
    procedure SetChildOrder(Child: TComponent; Order: Integer); // @ida "void __usercall $name(TWinControl *Self@<eax>, TComponent *Child@<edx>, __int32 Order@<ecx>);" @note "DCC32 MAP Controls.TWinControl.SetChildOrder. Source vcl/Controls.pas:9147."
    procedure CalcConstraints(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); // @ida "void __userpurge $name(TWinControl *Self@<eax>, __int32 *MinWidth@<edx>, __int32 *MinHeight@<ecx>, __int32 *MaxWidth@<^4>, __int32 *MaxHeight@<^0>);" @note "DCC32 MAP Controls.TWinControl.CalcConstraints. Source vcl/Controls.pas:9161."
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); override; // @ida "void __userpurge $name(TWinControl *Self@<eax>, __int32 *MinWidth@<edx>, __int32 *MinHeight@<ecx>, __int32 *MaxWidth@<^4>, __int32 *MaxHeight@<^0>);" @note "DCC32 MAP Controls.TWinControl.ConstrainedResize. Source vcl/Controls.pas:9354." @slot 0x38
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, TObject *Sender@<edx>, bool CheckDefaults@<cl>);" @note "DCC32 MAP Controls.TWinControl.ActionChange. Source vcl/Controls.pas:9361."
    procedure AssignTo(Dest: TPersistent); override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TPersistent *Dest@<edx>);" @note "DCC32 MAP Controls.TWinControl.AssignTo. Source vcl/Controls.pas:9376." @slot 0x0
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; virtual; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, __int32 *NewWidth@<edx>, __int32 *NewHeight@<ecx>);" @note "DCC32 MAP Controls.TWinControl.CanAutoSize. Source vcl/Controls.pas:9382." @slot 0x34
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMNCCalcSize *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMNCCalcSize. Source vcl/Controls.pas:9479."
    procedure WMNCPaint(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMNCPaint. Source vcl/Controls.pas:9503."
    procedure WMContextMenu(var Message: TWMContextMenu); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMContextMenu *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMContextMenu. Source vcl/Controls.pas:9588."
    procedure UpdateUIState(CharCode: Word); // @ida "void __usercall $name(TWinControl *Self@<eax>, unsigned __int16 CharCode@<dx>);" @note "DCC32 MAP Controls.TWinControl.UpdateUIState. Source vcl/Controls.pas:9601."
    procedure WMPrintClient(var Message: TWMPrintClient); // @ida "void __usercall $name(TWinControl *Self@<eax>, TWMPrintClient *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.WMPrintClient. Source vcl/Controls.pas:9615."
    procedure SetParentBackground(Value: Boolean); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TWinControl.SetParentBackground. Source vcl/Controls.pas:9641." @slot 0xC8
    procedure CMTextChanged(var Message: TMessage); // @ida "void __usercall $name(TWinControl *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TWinControl.CMTextChanged. Source vcl/Controls.pas:9653."
    procedure InvalidateDockHostSite; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.InvalidateDockHostSite. Source vcl/Controls.pas:9659."
    procedure RemoveWindowProps; // @ida "void __usercall $name(TWinControl *Self@<eax>);" @note "DCC32 MAP Controls.TWinControl.RemoveWindowProps. Source vcl/Controls.pas:9693."
    function IsQualifyingSite(const Client: TControl): Boolean; // @ida "bool __usercall $name@<al>(TWinControl *Self@<eax>, TControl *Client@<edx>);" @note "DCC32 MAP Controls.TWinControl.IsQualifyingSite. Source vcl/Controls.pas:9699."
    procedure UpdateRecreatingFlag(Recreating: Boolean); // @ida "void __usercall $name(TWinControl *Self@<eax>, bool Recreating@<dl>);" @note "DCC32 MAP Controls.TWinControl.UpdateRecreatingFlag. Source vcl/Controls.pas:9714."
    procedure UpdateControlOriginalParentSize(AControl: TControl; var AOriginalParentSize: TPoint); virtual; // @ida "void __usercall $name(TWinControl *Self@<eax>, TControl *AControl@<edx>, TPoint *AOriginalParentSize@<ecx>);" @note "DCC32 MAP Controls.TWinControl.UpdateControlOriginalParentSize. Source vcl/Controls.pas:9727." @slot 0xD0
    procedure SetParent(AParent: TWinControl); override; // @ida "void __usercall $name(TWinControl *Self@<eax>, TWinControl *AParent@<edx>);" @note "DCC32 MAP Controls.TWinControl.SetParent. Source vcl/Controls.pas:9745." @slot 0x6C
  end;

  TSiteList = class(TList) // @size 0x10
  public
    function Find(ParentWnd: Cardinal; var Index: Integer): Boolean; // @ida "bool __usercall $name@<al>(TSiteList *Self@<eax>, unsigned __int32 ParentWnd@<edx>, __int32 *Index@<ecx>);" @note "DCC32 MAP Controls.TSiteList.Find. Source vcl/Controls.pas:2268."
    procedure AddSite(ASite: TWinControl); // @ida "void __usercall $name(TSiteList *Self@<eax>, TWinControl *ASite@<edx>);" @note "DCC32 MAP Controls.TSiteList.AddSite. Source vcl/Controls.pas:2280."
    procedure Clear; override; // @ida "void __usercall $name(TSiteList *Self@<eax>);" @note "DCC32 MAP Controls.TSiteList.Clear. Source vcl/Controls.pas:2321." @slot 0x8
    function GetTopSite: TWinControl; // @ida "TWinControl * __usercall $name@<eax>(TSiteList *Self@<eax>);" @note "DCC32 MAP Controls.TSiteList.GetTopSite. Source vcl/Controls.pas:2330."
  end;

  TDragObject = class(TObject) // @size 0x3C
  public
    procedure Assign(Source: TDragObject); virtual; // @ida "void __usercall $name(TDragObject *Self@<eax>, TDragObject *Source@<edx>);" @note "DCC32 MAP Controls.TDragObject.Assign. Source vcl/Controls.pas:2380." @slot 0x10
    function GetName: AnsiString; virtual; // @ida "void __usercall $name(TDragObject *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Controls.TDragObject.GetName. Source vcl/Controls.pas:2405." @slot 0x14
    procedure WndProc(var Msg: TMessage); virtual; // @ida "void __usercall $name(TDragObject *Self@<eax>, TMessage *Msg@<edx>);" @note "DCC32 MAP Controls.TDragObject.WndProc. Source vcl/Controls.pas:2421." @slot 0xC
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; virtual; // @ida "TCursor __userpurge $name@<ax>(TDragObject *Self@<eax>, bool Accepted@<dl>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TDragObject.GetDragCursor. Source vcl/Controls.pas:2471." @slot 0x4
  end;

  TCursor = SmallInt;

  TBaseDragControlObject = class(TDragObject) // @size 0x44
  public
    constructor Create(AControl: TControl); virtual; // @ida "TBaseDragControlObject * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TControl *AControl@<ecx>);" @note "DCC32 MAP Controls.TBaseDragControlObject.Create. Source vcl/Controls.pas:2526." @slot 0x28
    procedure Assign(Source: TDragObject); override; // @ida "void __usercall $name(TBaseDragControlObject *Self@<eax>, TDragObject *Source@<edx>);" @note "DCC32 MAP Controls.TBaseDragControlObject.Assign. Source vcl/Controls.pas:2531." @slot 0x10
    procedure EndDrag(Target: TObject; X, Y: Integer); virtual; // @ida "void __userpurge $name(TBaseDragControlObject *Self@<eax>, TObject *Target@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TBaseDragControlObject.EndDrag. Source vcl/Controls.pas:2538." @slot 0x24
    procedure Finished(Target: TObject; X, Y: Integer; Accepted: Boolean); virtual; // @ida "void __userpurge $name(TBaseDragControlObject *Self@<eax>, TObject *Target@<edx>, __int32 X@<ecx>, __int32 Y@<^4>, bool Accepted@<^0>);" @note "DCC32 MAP Controls.TBaseDragControlObject.Finished. Source vcl/Controls.pas:2544." @slot 0x0
  end;

  TDragControlObject = class(TBaseDragControlObject) // @size 0x48
  public
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override; // @ida "TCursor __userpurge $name@<ax>(TDragControlObject *Self@<eax>, bool Accepted@<dl>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TDragControlObject.GetDragCursor. Source vcl/Controls.pas:2556." @slot 0x4
  end;

  TDragDockObject = class(TBaseDragControlObject) // @size 0x78
  public
    constructor Create(AControl: TControl); override; // @ida "TDragDockObject * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TControl *AControl@<ecx>);" @note "DCC32 MAP Controls.TDragDockObject.Create. Source vcl/Controls.pas:2589." @slot 0x28
    destructor Destroy; // @ida "void __usercall $name(TDragDockObject *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Controls.TDragDockObject.Destroy. Source vcl/Controls.pas:2604."
    procedure Assign(Source: TDragObject); override; // @ida "void __usercall $name(TDragDockObject *Self@<eax>, TDragObject *Source@<edx>);" @note "DCC32 MAP Controls.TDragDockObject.Assign. Source vcl/Controls.pas:2610." @slot 0x10
    procedure EndDrag(Target: TObject; X, Y: Integer); override; // @ida "void __userpurge $name(TDragDockObject *Self@<eax>, TObject *Target@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TDragDockObject.EndDrag. Source vcl/Controls.pas:2629." @slot 0x24
    procedure AdjustDockRect(ARect: TRect); virtual; // @ida "void __usercall $name(TDragDockObject *Self@<eax>, TRect *ARect@<edx>);" @note "DCC32 MAP Controls.TDragDockObject.AdjustDockRect. Source vcl/Controls.pas:2634." @slot 0x2C
  end;

  TDragMessage = (dmDragEnter, dmDragLeave, dmDragMove, dmDragDrop, dmDragCancel, dmFindTarget); // @size 0x1

  TDragKind = (dkDrag, dkDock); // @size 0x1

  TControlCanvas = class(TCanvas) // @size 0x64
  public
    procedure CreateHandle; virtual; // @ida "void __usercall $name(TControlCanvas *Self@<eax>);" @note "DCC32 MAP Controls.TControlCanvas.CreateHandle. Source vcl/Controls.pas:3336." @slot 0x14
    procedure FreeHandle; // @ida "void __usercall $name(TControlCanvas *Self@<eax>);" @note "DCC32 MAP Controls.TControlCanvas.FreeHandle. Source vcl/Controls.pas:3356."
    procedure SetControl(AControl: TControl); // @ida "void __usercall $name(TControlCanvas *Self@<eax>, TControl *AControl@<edx>);" @note "DCC32 MAP Controls.TControlCanvas.SetControl. Source vcl/Controls.pas:3367."
    procedure UpdateTextFlags; // @ida "void __usercall $name(TControlCanvas *Self@<eax>);" @note "DCC32 MAP Controls.TControlCanvas.UpdateTextFlags. Source vcl/Controls.pas:3376."
  end;

  TSizeConstraints = class(TPersistent) // @size 0x20
  public
    procedure AssignTo(Dest: TPersistent); virtual; // @ida "void __usercall $name(TSizeConstraints *Self@<eax>, TPersistent *Dest@<edx>);" @note "DCC32 MAP Controls.TSizeConstraints.AssignTo. Source vcl/Controls.pas:3393." @slot 0x0
    procedure SetConstraints; // @nameonly @note "DCC32 MAP Controls.TSizeConstraints.SetConstraints. Source vcl/Controls.pas:3407. Prototype pending: unsupported source type TConstraintSize: 0..MaxInt."
  end;

  TControlActionLink = class(TActionLink) // @size 0x1C
  public
    function DoShowHint(var HintStr: AnsiString): Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>, char * *HintStr@<edx>);" @note "DCC32 MAP Controls.TControlActionLink.DoShowHint. Source vcl/Controls.pas:3458." @slot 0x84
    function IsCaptionLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsCaptionLinked. Source vcl/Controls.pas:3472." @slot 0x20
    function IsEnabledLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsEnabledLinked. Source vcl/Controls.pas:3483." @slot 0x28
    function IsHintLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsHintLinked. Source vcl/Controls.pas:3494." @slot 0x38
    function IsPopupMenuLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsPopupMenuLinked. Source vcl/Controls.pas:3500." @slot 0x80
    function IsVisibleLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsVisibleLinked. Source vcl/Controls.pas:3506." @slot 0x44
    function IsOnExecuteLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsOnExecuteLinked. Source vcl/Controls.pas:3512." @slot 0x8
    procedure SetEnabled(Value: Boolean); virtual; // @ida "void __usercall $name(TControlActionLink *Self@<eax>, bool Value@<dl>);" @note "DCC32 MAP Controls.TControlActionLink.SetEnabled. Source vcl/Controls.pas:3527." @slot 0x54
    procedure SetHint(const Value: AnsiString); virtual; // @ida "void __usercall $name(TControlActionLink *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Controls.TControlActionLink.SetHint. Source vcl/Controls.pas:3536." @slot 0x68
    procedure SetOnExecute; // @nameonly @note "DCC32 MAP Controls.TControlActionLink.SetOnExecute. Source vcl/Controls.pas:3546. Prototype pending: unsupported source type TNotifyEvent: procedure(Sender: TObject) of object."
    function IsHelpLinked: Boolean; virtual; // @ida "bool __usercall $name@<al>(TControlActionLink *Self@<eax>);" @note "DCC32 MAP Controls.TControlActionLink.IsHelpLinked. Source vcl/Controls.pas:3551." @slot 0x34
    procedure SetHelpType(Value: THelpType); virtual; // @ida "void __usercall $name(TControlActionLink *Self@<eax>, THelpType Value@<dl>);" @note "DCC32 MAP Controls.TControlActionLink.SetHelpType. Source vcl/Controls.pas:3569." @slot 0x64
    procedure SetPopupMenu(Value: TPopupMenu); virtual; // @ida "void __usercall $name(TControlActionLink *Self@<eax>, TPopupMenu *Value@<edx>);" @note "DCC32 MAP Controls.TControlActionLink.SetPopupMenu. Source vcl/Controls.pas:3574." @slot 0x90
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
    procedure AssignClient(AClient: TObject); virtual; // @ida "void __usercall $name(TWinControlActionLink *Self@<eax>, TObject *AClient@<edx>);" @note "DCC32 MAP Controls.TWinControlActionLink.AssignClient. Source vcl/Controls.pas:5964." @slot 0x0
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
    constructor Create(AOwner: TComponent); override; // @ida "TCustomControl * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Controls.TCustomControl.Create. Source vcl/Controls.pas:10089." @slot 0x2C
    destructor Destroy; // @ida "void __usercall $name(TCustomControl *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Controls.TCustomControl.Destroy. Source vcl/Controls.pas:10096."
    procedure WMPaint(var Message: TWMPaint); // @ida "void __usercall $name(TCustomControl *Self@<eax>, TWMPaint *Message@<edx>);" @note "DCC32 MAP Controls.TCustomControl.WMPaint. Source vcl/Controls.pas:10102."
    procedure PaintWindow(DC: Cardinal); override; // @ida "void __usercall $name(TCustomControl *Self@<eax>, unsigned __int32 DC@<edx>);" @note "DCC32 MAP Controls.TCustomControl.PaintWindow. Source vcl/Controls.pas:10109." @slot 0xC4
  end;

  THintWindow = class(TCustomControl) // @size 0x260
  public
    constructor Create(AOwner: TComponent); override; // @ida "THintWindow * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TComponent *AOwner@<ecx>);" @note "DCC32 MAP Controls.THintWindow.Create. Source vcl/Controls.pas:9800." @slot 0x2C
    procedure CreateParams(var Params: TCreateParams); override; // @ida "void __usercall $name(THintWindow *Self@<eax>, TCreateParams *Params@<edx>);" @note "DCC32 MAP Controls.THintWindow.CreateParams. Source vcl/Controls.pas:9808." @slot 0x9C
    procedure WMNCPaint(var Message: TMessage); // @ida "void __usercall $name(THintWindow *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.THintWindow.WMNCPaint. Source vcl/Controls.pas:9830."
    procedure Paint; virtual; // @ida "void __usercall $name(THintWindow *Self@<eax>);" @note "DCC32 MAP Controls.THintWindow.Paint. Source vcl/Controls.pas:9842." @slot 0xD8
    function IsHintMsg(var Msg: TMsg): Boolean; virtual; // @ida "bool __usercall $name@<al>(THintWindow *Self@<eax>, TMsg *Msg@<edx>);" @note "DCC32 MAP Controls.THintWindow.IsHintMsg. Source vcl/Controls.pas:9854." @slot 0xEC
    procedure CMTextChanged(var Message: TMessage); // @ida "void __usercall $name(THintWindow *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.THintWindow.CMTextChanged. Source vcl/Controls.pas:9869."
    procedure ActivateHintData(Rect: TRect; const AHint: AnsiString; AData: Pointer); virtual; // @ida "void __userpurge $name(THintWindow *Self@<eax>, TRect *Rect@<edx>, char * AHint@<ecx>, void * AData@<^0>);" @note "DCC32 MAP Controls.THintWindow.ActivateHintData. Source vcl/Controls.pas:9927." @slot 0xE4
    function CalcHintRect(MaxWidth: Integer; const AHint: AnsiString; AData: Pointer): TRect; virtual; // @ida "void __userpurge $name(THintWindow *Self@<eax>, __int32 MaxWidth@<edx>, char * AHint@<ecx>, void * AData@<^4>, TRect *Result@<^0>);" @note "DCC32 MAP Controls.THintWindow.CalcHintRect. Source vcl/Controls.pas:9932." @slot 0xE8
    procedure NCPaint(DC: Cardinal); virtual; // @ida "void __usercall $name(THintWindow *Self@<eax>, unsigned __int32 DC@<edx>);" @note "DCC32 MAP Controls.THintWindow.NCPaint. Source vcl/Controls.pas:9941." @slot 0xDC
    procedure WMPrint(var Message: TMessage); // @ida "void __usercall $name(THintWindow *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.THintWindow.WMPrint. Source vcl/Controls.pas:9956."
  end;

  TDragImageList = class(TCustomImageList) // @partial
  public
    function SetDragImage(Index, HotSpotX, HotSpotY: Integer): Boolean; // @ida "bool __userpurge $name@<al>(TDragImageList *Self@<eax>, __int32 Index@<edx>, __int32 HotSpotX@<ecx>, __int32 HotSpotY@<^0>);" @note "DCC32 MAP Controls.TDragImageList.SetDragImage. Source vcl/Controls.pas:9988."
    procedure SetDragCursor(Value: TCursor); // @ida "void __usercall $name(TDragImageList *Self@<eax>, TCursor Value@<dx>);" @note "DCC32 MAP Controls.TDragImageList.SetDragCursor. Source vcl/Controls.pas:10002."
    function BeginDrag(Window: Cardinal; X, Y: Integer): Boolean; // @ida "bool __userpurge $name@<al>(TDragImageList *Self@<eax>, unsigned __int32 Window@<edx>, __int32 X@<ecx>, __int32 Y@<^0>);" @note "DCC32 MAP Controls.TDragImageList.BeginDrag. Source vcl/Controls.pas:10019."
    function DragLock(Window: Cardinal; XPos, YPos: Integer): Boolean; // @ida "bool __userpurge $name@<al>(TDragImageList *Self@<eax>, unsigned __int32 Window@<edx>, __int32 XPos@<ecx>, __int32 YPos@<^0>);" @note "DCC32 MAP Controls.TDragImageList.DragLock. Source vcl/Controls.pas:10034."
    procedure DragUnlock; // @ida "void __usercall $name(TDragImageList *Self@<eax>);" @note "DCC32 MAP Controls.TDragImageList.DragUnlock. Source vcl/Controls.pas:10046."
    function DragMove(X, Y: Integer): Boolean; // @ida "bool __usercall $name@<al>(TDragImageList *Self@<eax>, __int32 X@<edx>, __int32 Y@<ecx>);" @note "DCC32 MAP Controls.TDragImageList.DragMove. Source vcl/Controls.pas:10055."
    function EndDrag: Boolean; // @ida "bool __usercall $name@<al>(TDragImageList *Self@<eax>);" @note "DCC32 MAP Controls.TDragImageList.EndDrag. Source vcl/Controls.pas:10074."
  end;

  TDockZone = class(TObject) // @size 0x28
  public
    constructor Create(Tree: TDockTree); // @ida "TDockZone * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TDockTree *Tree@<ecx>);" @note "DCC32 MAP Controls.TDockZone.Create. Source vcl/Controls.pas:10145."
    function GetChildCount: Integer; // @ida "__int32 __usercall $name@<eax>(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.GetChildCount. Source vcl/Controls.pas:10150."
    function GetVisibleChildCount: Integer; // @ida "__int32 __usercall $name@<eax>(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.GetVisibleChildCount. Source vcl/Controls.pas:10163."
    function GetVisible: Boolean; // @ida "bool __usercall $name@<al>(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.GetVisible. Source vcl/Controls.pas:10176."
    function GetTopLeft(Orient: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(TDockZone *Self@<eax>, __int32 Orient@<edx>);" @note "DCC32 MAP Controls.TDockZone.GetTopLeft. Source vcl/Controls.pas:10229."
    function GetHeightWidth(Orient: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(TDockZone *Self@<eax>, __int32 Orient@<edx>);" @note "DCC32 MAP Controls.TDockZone.GetHeightWidth. Source vcl/Controls.pas:10256."
    procedure ResetChildren; // @ida "void __usercall $name(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.ResetChildren. Source vcl/Controls.pas:10291."
    function GetControlName: AnsiString; // @ida "void __usercall $name(TDockZone *Self@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Controls.TDockZone.GetControlName. Source vcl/Controls.pas:10317."
    function SetControlName(const Value: AnsiString): Boolean; // @ida "bool __usercall $name@<al>(TDockZone *Self@<eax>, char * Value@<edx>);" @note "DCC32 MAP Controls.TDockZone.SetControlName. Source vcl/Controls.pas:10328."
    procedure Update; // @ida "void __usercall $name(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.Update. Source vcl/Controls.pas:10349."
    function GetZoneLimit: Integer; // @ida "__int32 __usercall $name@<eax>(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.GetZoneLimit. Source vcl/Controls.pas:10401."
    procedure ExpandZoneLimit(NewLimit: Integer); // @ida "void __usercall $name(TDockZone *Self@<eax>, __int32 NewLimit@<edx>);" @note "DCC32 MAP Controls.TDockZone.ExpandZoneLimit. Source vcl/Controls.pas:10415."
    procedure ResetZoneLimits; // @ida "void __usercall $name(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.ResetZoneLimits. Source vcl/Controls.pas:10441."
    function PrevVisible: TDockZone; // @ida "TDockZone * __usercall $name@<eax>(TDockZone *Self@<eax>);" @note "DCC32 MAP Controls.TDockZone.PrevVisible. Source vcl/Controls.pas:10465."
  end;

  TDockTree = class(TInterfacedObject) // @size 0x7C
  public
    constructor Create(DockSite: TWinControl); virtual; // @ida "TDockTree * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TWinControl *DockSite@<ecx>);" @note "DCC32 MAP Controls.TDockTree.Create. Source vcl/Controls.pas:10483." @slot 0x44
    destructor Destroy; // @ida "void __usercall $name(TDockTree *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Controls.TDockTree.Destroy. Source vcl/Controls.pas:10512."
    procedure AdjustDockRect(Control: TControl; var ARect: TRect); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>, TRect *ARect@<ecx>);" @note "DCC32 MAP Controls.TDockTree.AdjustDockRect. Source vcl/Controls.pas:10524." @slot 0x0
    procedure EndUpdate; // @ida "void __usercall $name(TDockTree *Self@<eax>);" @note "DCC32 MAP Controls.TDockTree.EndUpdate. Source vcl/Controls.pas:10538."
    function FindControlZone(Control: TControl): TDockZone; // @ida "TDockZone * __usercall $name@<eax>(TDockTree *Self@<eax>, TControl *Control@<edx>);" @note "DCC32 MAP Controls.TDockTree.FindControlZone. Source vcl/Controls.pas:10548."
    procedure ForEachAt; // @nameonly @note "DCC32 MAP Controls.TDockTree.ForEachAt. Source vcl/Controls.pas:10572. Prototype pending: unsupported source type TForEachZoneProc: procedure(Zone: TDockZone) of object."
    procedure GetControlBounds(Control: TControl; out CtlBounds: TRect); // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>, TRect *CtlBounds@<ecx>);" @note "DCC32 MAP Controls.TDockTree.GetControlBounds. Source vcl/Controls.pas:10588."
    procedure InsertControl(Control: TControl; InsertAt: TAlign; DropCtl: TControl); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TControl *Control@<edx>, TAlign InsertAt@<cl>, TControl *DropCtl@<^0>);" @note "DCC32 MAP Controls.TDockTree.InsertControl. Source vcl/Controls.pas:10609." @slot 0xC
    procedure InsertNewParent(NewZone, SiblingZone: TDockZone; ParentOrientation: TDockOrientation; InsertLast: Boolean); // @ida "void __userpurge $name(TDockTree *Self@<eax>, TDockZone *NewZone@<edx>, TDockZone *SiblingZone@<ecx>, TDockOrientation ParentOrientation@<^4>, bool InsertLast@<^0>);" @note "DCC32 MAP Controls.TDockTree.InsertNewParent. Source vcl/Controls.pas:10693."
    procedure InsertSibling(NewZone, SiblingZone: TDockZone; InsertLast: Boolean); // @ida "void __userpurge $name(TDockTree *Self@<eax>, TDockZone *NewZone@<edx>, TDockZone *SiblingZone@<ecx>, bool InsertLast@<^0>);" @note "DCC32 MAP Controls.TDockTree.InsertSibling. Source vcl/Controls.pas:10768."
    function ZoneCaptionHitTest(const Zone: TDockZone; const MousePos: TPoint; var HTFlag: Integer): Boolean; virtual; // @ida "bool __userpurge $name@<al>(TDockTree *Self@<eax>, TDockZone *Zone@<edx>, TPoint *MousePos@<ecx>, __int32 *HTFlag@<^0>);" @note "DCC32 MAP Controls.TDockTree.ZoneCaptionHitTest. Source vcl/Controls.pas:10805." @slot 0x40
    function FindControlAtPos(const Pos: TPoint): TControl; // @ida "TControl * __usercall $name@<eax>(TDockTree *Self@<eax>, TPoint *Pos@<edx>);" @note "DCC32 MAP Controls.TDockTree.FindControlAtPos. Source vcl/Controls.pas:10841."
    function InternalHitTest(const MousePos: TPoint; out HTFlag: Integer): TDockZone; // @ida "TDockZone * __usercall $name@<eax>(TDockTree *Self@<eax>, TPoint *MousePos@<edx>, __int32 *HTFlag@<ecx>);" @note "DCC32 MAP Controls.TDockTree.InternalHitTest. Source vcl/Controls.pas:10863."
    procedure LoadFromStream(Stream: TStream); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TStream *Stream@<edx>);" @note "DCC32 MAP Controls.TDockTree.LoadFromStream. Source vcl/Controls.pas:10918." @slot 0x10
    procedure PaintDockFrame(Canvas: TCanvas; Control: TControl; const ARect: TRect); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TCanvas *Canvas@<edx>, TControl *Control@<ecx>, TRect *ARect@<^0>);" @note "DCC32 MAP Controls.TDockTree.PaintDockFrame. Source vcl/Controls.pas:11055." @slot 0x20
    procedure PaintSite(DC: Cardinal); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, unsigned __int32 DC@<edx>);" @note "DCC32 MAP Controls.TDockTree.PaintSite. Source vcl/Controls.pas:11130." @slot 0x48
    procedure PositionDockRect(Client, DropCtl: TControl; DropAlign: TAlign; var DockRect: TRect); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TControl *Client@<edx>, TControl *DropCtl@<ecx>, TAlign DropAlign@<^4>, TRect *DockRect@<^0>);" @note "DCC32 MAP Controls.TDockTree.PositionDockRect. Source vcl/Controls.pas:11166." @slot 0x24
    procedure PruneZone(Zone: TDockZone); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *Zone@<edx>);" @note "DCC32 MAP Controls.TDockTree.PruneZone. Source vcl/Controls.pas:11209."
    procedure RemoveControl(Control: TControl); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>);" @note "DCC32 MAP Controls.TDockTree.RemoveControl. Source vcl/Controls.pas:11239." @slot 0x2C
    procedure RemoveZone(Zone: TDockZone); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *Zone@<edx>);" @note "DCC32 MAP Controls.TDockTree.RemoveZone. Source vcl/Controls.pas:11256."
    procedure ResetBounds(Force: Boolean); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, bool Force@<dl>);" @note "DCC32 MAP Controls.TDockTree.ResetBounds. Source vcl/Controls.pas:11374." @slot 0x38
    procedure ScaleZone(Zone: TDockZone); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *Zone@<edx>);" @note "DCC32 MAP Controls.TDockTree.ScaleZone. Source vcl/Controls.pas:11408."
    procedure SaveToStream(Stream: TStream); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TStream *Stream@<edx>);" @note "DCC32 MAP Controls.TDockTree.SaveToStream. Source vcl/Controls.pas:11416." @slot 0x30
    procedure SetNewBounds(Zone: TDockZone); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *Zone@<edx>);" @note "DCC32 MAP Controls.TDockTree.SetNewBounds. Source vcl/Controls.pas:11494."
    procedure SetReplacingControl(Control: TControl); // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>);" @note "DCC32 MAP Controls.TDockTree.SetReplacingControl. Source vcl/Controls.pas:11519."
    procedure ShiftZone(Zone: TDockZone); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *Zone@<edx>);" @note "DCC32 MAP Controls.TDockTree.ShiftZone. Source vcl/Controls.pas:11524."
    procedure SplitterMouseDown(OnZone: TDockZone; MousePos: TPoint); // @ida "void __usercall $name(TDockTree *Self@<eax>, TDockZone *OnZone@<edx>, TPoint *MousePos@<ecx>);" @note "DCC32 MAP Controls.TDockTree.SplitterMouseDown. Source vcl/Controls.pas:11531."
    procedure SplitterMouseUp; // @ida "void __usercall $name(TDockTree *Self@<eax>);" @note "DCC32 MAP Controls.TDockTree.SplitterMouseUp. Source vcl/Controls.pas:11542."
    procedure UpdateAll; // @ida "void __usercall $name(TDockTree *Self@<eax>);" @note "DCC32 MAP Controls.TDockTree.UpdateAll. Source vcl/Controls.pas:11555."
    procedure WindowProc(var Message: TMessage); // @ida "void __usercall $name(TDockTree *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TDockTree.WindowProc. Source vcl/Controls.pas:11566."
    procedure DrawSizeSplitter; // @ida "void __usercall $name(TDockTree *Self@<eax>);" @note "DCC32 MAP Controls.TDockTree.DrawSizeSplitter. Source vcl/Controls.pas:11571."
    function GetNextLimit(AZone: TDockZone): Integer; // @ida "__int32 __usercall $name@<eax>(TDockTree *Self@<eax>, TDockZone *AZone@<edx>);" @note "DCC32 MAP Controls.TDockTree.GetNextLimit. Source vcl/Controls.pas:11601."
    procedure ControlVisibilityChanged(Control: TControl; Visible: Boolean); // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>, bool Visible@<cl>);" @note "DCC32 MAP Controls.TDockTree.ControlVisibilityChanged. Source vcl/Controls.pas:11625."
    procedure WndProc(var Message: TMessage); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TMessage *Message@<edx>);" @note "DCC32 MAP Controls.TDockTree.WndProc. Source vcl/Controls.pas:11736." @slot 0x3C
    function ActualSize(const RelativeSize, Reference: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(TDockTree *Self@<eax>, __int32 RelativeSize@<edx>, __int32 Reference@<ecx>);" @note "DCC32 MAP Controls.TDockTree.ActualSize. Source vcl/Controls.pas:11805."
    function RelativeSize(const ActualSize, Reference: Integer): Integer; // @ida "__int32 __usercall $name@<eax>(TDockTree *Self@<eax>, __int32 ActualSize@<edx>, __int32 Reference@<ecx>);" @note "DCC32 MAP Controls.TDockTree.RelativeSize. Source vcl/Controls.pas:11810."
    procedure AdjustFrameRect(Control: TControl; var ARect: TRect); virtual; // @ida "void __usercall $name(TDockTree *Self@<eax>, TControl *Control@<edx>, TRect *ARect@<ecx>);" @note "DCC32 MAP Controls.TDockTree.AdjustFrameRect. Source vcl/Controls.pas:11826." @slot 0x4
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TMouseButton Button@<dl>, TShiftState *Shift@<ecx>, __int32 X@<^8>, __int32 Y@<^4>, bool *Handled@<^0>);" @note "DCC32 MAP Controls.TDockTree.MouseDown. Source vcl/Controls.pas:11839." @slot 0x14
    procedure MouseMove(Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TShiftState *Shift@<edx>, __int32 X@<ecx>, __int32 Y@<^4>, bool *Handled@<^0>);" @note "DCC32 MAP Controls.TDockTree.MouseMove. Source vcl/Controls.pas:11885." @slot 0x18
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TMouseButton Button@<dl>, TShiftState *Shift@<ecx>, __int32 X@<^8>, __int32 Y@<^4>, bool *Handled@<^0>);" @note "DCC32 MAP Controls.TDockTree.MouseUp. Source vcl/Controls.pas:11919." @slot 0x1C
    procedure ShowHint(CursorPos: TPoint; var CursorRect: TRect; var HintStr: AnsiString); virtual; // @ida "void __userpurge $name(TDockTree *Self@<eax>, TPoint *CursorPos@<edx>, TRect *CursorRect@<ecx>, char * *HintStr@<^0>);" @note "DCC32 MAP Controls.TDockTree.ShowHint. Source vcl/Controls.pas:11943." @slot 0x34
  end;

  TDockOrientation = (doNoOrient, doHorizontal, doVertical); // @size 0x1

  TMouse = class(TObject) // @size 0x30
  public
    constructor Create; // @ida "TMouse * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP Controls.TMouse.Create. Source vcl/Controls.pas:11967."
    function CreatePanningWindow: TCustomPanningWindow; // @ida "TCustomPanningWindow * __usercall $name@<eax>(TMouse *Self@<eax>);" @note "DCC32 MAP Controls.TMouse.CreatePanningWindow. Source vcl/Controls.pas:11982."
    function GetIsPanning: Boolean; // @ida "bool __usercall $name@<al>(TMouse *Self@<eax>);" @note "DCC32 MAP Controls.TMouse.GetIsPanning. Source vcl/Controls.pas:12016."
    procedure GetMouseData; // @ida "void __usercall $name(TMouse *Self@<eax>);" @note "DCC32 MAP Controls.TMouse.GetMouseData. Source vcl/Controls.pas:12021."
    procedure GetNativeData; // @ida "void __usercall $name(TMouse *Self@<eax>);" @note "DCC32 MAP Controls.TMouse.GetNativeData. Source vcl/Controls.pas:12026."
    procedure GetRegisteredData; // @ida "void __usercall $name(TMouse *Self@<eax>);" @note "DCC32 MAP Controls.TMouse.GetRegisteredData. Source vcl/Controls.pas:12033."
    procedure SetCapture(const Value: Cardinal); // @ida "void __usercall $name(TMouse *Self@<eax>, unsigned __int32 Value@<edx>);" @note "DCC32 MAP Controls.TMouse.SetCapture. Source vcl/Controls.pas:12042."
    procedure SetPanningWindow(const Value: TCustomPanningWindow); // @ida "void __usercall $name(TMouse *Self@<eax>, TCustomPanningWindow *Value@<edx>);" @note "DCC32 MAP Controls.TMouse.SetPanningWindow. Source vcl/Controls.pas:12058."
    procedure SettingChanged(Setting: Integer); // @ida "void __usercall $name(TMouse *Self@<eax>, __int32 Setting@<edx>);" @note "DCC32 MAP Controls.TMouse.SettingChanged. Source vcl/Controls.pas:12068."
  end;

  TCustomPanningWindow = class(TCustomControl) // @partial
  end;

  TImeMode = (imDisable, imClose, imOpen, imDontCare, imSAlpha, imAlpha, imHira, imSKata, imKata, imChinese, imSHanguel, imHanguel); // @size 0x1

  TControlMargins = class(TPersistent) // @size 0x20
  public
    constructor Create(Control: TControl); virtual; // @ida "TControlMargins * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TControl *Control@<ecx>);" @note "DCC32 MAP Controls.TMargins.Create. Source vcl/Controls.pas:12554." @slot 0x18
    procedure AssignTo(Dest: TPersistent); virtual; // @ida "void __usercall $name(TControlMargins *Self@<eax>, TPersistent *Dest@<edx>);" @note "DCC32 MAP Controls.TMargins.AssignTo. Source vcl/Controls.pas:12561." @slot 0x0
    class procedure InitDefaults(Margins: TControlMargins); virtual; // @ida "void __usercall $name(void *Self@<eax>, TControlMargins *Margins@<edx>);" @note "DCC32 MAP Controls.TMargins.InitDefaults. Source vcl/Controls.pas:12582." @slot 0x14
    procedure SetControlBounds; // @nameonly @note "DCC32 MAP Controls.TMargins.SetControlBounds. Prototype pending: no unique source declaration."
    function GetControlBound(Index: Integer): Integer; virtual; // @ida "__int32 __usercall $name@<eax>(TControlMargins *Self@<eax>, __int32 Index@<edx>);" @note "DCC32 MAP Controls.TMargins.GetControlBound. Source vcl/Controls.pas:12664." @slot 0x10
  end;

  TCMPopupHWndDestroy = record;

  TCMActivate = TWMNoParams;

  TCMDeactivate = TWMNoParams;

  TCMDialogKey = TWMKey;

  TCMDockNotification = record;

  THintWindowClass = class of THintWindow;

function InitWndProc(HWindow: Cardinal; Message, WParam, LParam: Longint): Longint; // @nameonly @note "DCC32 MAP Controls.InitWndProc. Source vcl/Controls.pas:2034. Prototype pending: RET mismatch: expected 4, native [16]."

function ObjectFromHWnd(Handle: Cardinal): TWinControl; // @ida "TWinControl * __usercall $name@<eax>(unsigned __int32 Handle@<eax>);" @note "DCC32 MAP Controls.ObjectFromHWnd. Source vcl/Controls.pas:2078."

function FindControl(Handle: Cardinal): TWinControl; // @ida "TWinControl * __usercall $name@<eax>(unsigned __int32 Handle@<eax>);" @note "DCC32 MAP Controls.FindControl. Source vcl/Controls.pas:2095."

function IsVCLControl(Handle: Cardinal): Boolean; // @ida "bool __usercall $name@<al>(unsigned __int32 Handle@<eax>);" @note "DCC32 MAP Controls.IsVCLControl. Source vcl/Controls.pas:2110."

function SendAppMessage(Msg: Cardinal; WParam, LParam: Longint): Longint; // @ida "__int32 __usercall $name@<eax>(unsigned __int32 Msg@<eax>, __int32 WParam@<edx>, __int32 LParam@<ecx>);" @note "DCC32 MAP Controls.SendAppMessage. Source vcl/Controls.pas:2119."

function GetShortHint(const Hint: AnsiString): AnsiString; // @ida "void __usercall $name(char * Hint@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Controls.GetShortHint. Source vcl/Controls.pas:2188."

function GetLongHint(const Hint: AnsiString): AnsiString; // @ida "void __usercall $name(char * Hint@<eax>, char * *Result@<edx>);" @note "DCC32 MAP Controls.GetLongHint. Source vcl/Controls.pas:2198."

procedure PerformEraseBackground(Control: TControl; DC: Cardinal); // @ida "void __usercall $name(TControl *Control@<eax>, unsigned __int32 DC@<edx>);" @note "DCC32 MAP Controls.PerformEraseBackground. Source vcl/Controls.pas:2208."

function GetCaptureControl: TControl; // @ida "TControl * __usercall $name@<eax>(void);" @note "DCC32 MAP Controls.GetCaptureControl. Source vcl/Controls.pas:2223."

procedure SetCaptureControl(Control: TControl); // @ida "void __usercall $name(TControl *Control@<eax>);" @note "DCC32 MAP Controls.SetCaptureControl. Source vcl/Controls.pas:2230."

function GetTopParent: Cardinal; // @nameonly @note "DCC32 MAP Controls.GetTopParent. Source vcl/Controls.pas:2282. Prototype pending: nested routine has a parent-frame parameter."

function AbsMin(Value1, Value2: Integer): Integer; // @nameonly @note "DCC32 MAP Controls.AbsMin. Source vcl/Controls.pas:2638. Prototype pending: nested routine has a parent-frame parameter."

function IsBeforeTargetWindow(Window: Cardinal; Data: Longint): LongBool; stdcall; // @ida "__int32 __stdcall $name(unsigned __int32 Window, __int32 Data);" @note "DCC32 MAP Controls.IsBeforeTargetWindow. Source vcl/Controls.pas:2700."

function ValidDockTarget(Target: TWinControl): Boolean; // @nameonly @note "DCC32 MAP Controls.ValidDockTarget. Source vcl/Controls.pas:2738. Prototype pending: nested routine has a parent-frame parameter."

function IsSiteChildOfClient: Boolean; // @nameonly @note "DCC32 MAP Controls.IsSiteChildOfClient. Source vcl/Controls.pas:2792. Prototype pending: nested routine has a parent-frame parameter."

function GetDockSiteAtPos(MousePos: TPoint; Client: TControl): TWinControl; // @ida "TWinControl * __usercall $name@<eax>(TPoint *MousePos@<eax>, TControl *Client@<edx>);" @note "DCC32 MAP Controls.GetDockSiteAtPos. Source vcl/Controls.pas:2731."

procedure RegisterDockSite(Site: TWinControl; DoRegister: Boolean); // @ida "void __usercall $name(TWinControl *Site@<eax>, bool DoRegister@<dl>);" @note "DCC32 MAP Controls.RegisterDockSite. Source vcl/Controls.pas:2825."

function DragMessage(Handle: Cardinal; Msg: TDragMessage; Source: TDragObject; Target: Pointer; const Pos: TPoint): Longint; // @ida "__int32 __userpurge $name@<eax>(unsigned __int32 Handle@<eax>, TDragMessage Msg@<dl>, TDragObject *Source@<ecx>, void * Target@<^4>, TPoint *Pos@<^0>);" @note "DCC32 MAP Controls.DragMessage. Source vcl/Controls.pas:2846."

function IsDelphiHandle(Handle: Cardinal): Boolean; // @ida "bool __usercall $name@<al>(unsigned __int32 Handle@<eax>);" @note "DCC32 MAP Controls.IsDelphiHandle. Source vcl/Controls.pas:2864."

procedure DragFindWindow; // @nameonly @note "DCC32 MAP Controls.DragFindWindow. Prototype pending: no unique source declaration."

function DragFindTarget(const Pos: TPoint; var Handle: Cardinal; DragKind: TDragKind; Client: TControl): Pointer; // @ida "void * __userpurge $name@<eax>(TPoint *Pos@<eax>, unsigned __int32 *Handle@<edx>, TDragKind DragKind@<cl>, TControl *Client@<^0>);" @note "DCC32 MAP Controls.DragFindTarget. Source vcl/Controls.pas:2887."

function DoDragOver(DragMsg: TDragMessage): Boolean; // @ida "bool __usercall $name@<al>(TDragMessage DragMsg@<al>);" @note "DCC32 MAP Controls.DoDragOver. Source vcl/Controls.pas:2902."

function GetDropCtl: TControl; // @nameonly @note "DCC32 MAP Controls.GetDropCtl. Source vcl/Controls.pas:2912. Prototype pending: nested routine has a parent-frame parameter."

procedure DragTo; // @nameonly @note "DCC32 MAP Controls.DragTo. Prototype pending: no unique source declaration."

procedure DragInit(ADragObject: TDragObject; Immediate: Boolean; Threshold: Integer); // @ida "void __usercall $name(TDragObject *ADragObject@<eax>, bool Immediate@<dl>, __int32 Threshold@<ecx>);" @note "DCC32 MAP Controls.DragInit. Source vcl/Controls.pas:3021."

procedure DragInitControl(Control: TControl; Immediate: Boolean; Threshold: Integer); // @ida "void __usercall $name(TControl *Control@<eax>, bool Immediate@<dl>, __int32 Threshold@<ecx>);" @note "DCC32 MAP Controls.DragInitControl. Source vcl/Controls.pas:3059."

function CheckUndock: Boolean; // @nameonly @note "DCC32 MAP Controls.CheckUndock. Source vcl/Controls.pas:3115. Prototype pending: nested routine has a parent-frame parameter."

procedure DragDone(Drop: Boolean); // @ida "void __usercall $name(bool Drop@<al>);" @note "DCC32 MAP Controls.DragDone. Source vcl/Controls.pas:3113."

function FindVCLWindow(const Pos: TPoint): TWinControl; // @ida "TWinControl * __usercall $name@<eax>(TPoint *Pos@<eax>);" @note "DCC32 MAP Controls.FindVCLWindow. Source vcl/Controls.pas:3223."

function FindDragTarget(const Pos: TPoint; AllowDisabled: Boolean): TControl; // @ida "TControl * __usercall $name@<eax>(TPoint *Pos@<eax>, bool AllowDisabled@<dl>);" @note "DCC32 MAP Controls.FindDragTarget. Source vcl/Controls.pas:3237."

procedure ListAdd(var List: TList; Item: Pointer); // @ida "void __usercall $name(TList **List@<eax>, void * Item@<edx>);" @note "DCC32 MAP Controls.ListAdd. Source vcl/Controls.pas:3254."

procedure ListRemove(var List: TList; Item: Pointer); // @ida "void __usercall $name(TList **List@<eax>, void * Item@<edx>);" @note "DCC32 MAP Controls.ListRemove. Source vcl/Controls.pas:3260."

procedure MoveWindowOrg(DC: Cardinal; DX, DY: Integer); // @ida "void __usercall $name(unsigned __int32 DC@<eax>, __int32 DX@<edx>, __int32 DY@<ecx>);" @note "DCC32 MAP Controls.MoveWindowOrg. Source vcl/Controls.pas:3272."

procedure FreeDeviceContext; // @ida "void __usercall $name(void);" @note "DCC32 MAP Controls.FreeDeviceContext. Source vcl/Controls.pas:3291."

function BackgroundClipped: Boolean; // @nameonly @note "DCC32 MAP Controls.BackgroundClipped. Source vcl/Controls.pas:4445. Prototype pending: nested routine has a parent-frame parameter."

function DoWriteIsControl: Boolean; // @nameonly @note "DCC32 MAP Controls.DoWriteIsControl. Source vcl/Controls.pas:5186. Prototype pending: nested routine has a parent-frame parameter."

function DoWriteExplicit(Dim: TExplicitDimension): Boolean; // @nameonly @note "DCC32 MAP Controls.DoWriteExplicit. Source vcl/Controls.pas:5193. Prototype pending: nested routine has a parent-frame parameter."

procedure SetParentColor(Value: TColor); // @nameonly @note "DCC32 MAP Controls.SetParentColor. Source vcl/Controls.pas:5457. Prototype pending: nested routine has a parent-frame parameter."

procedure UpdateFloatingDockSitePos; // @nameonly @note "DCC32 MAP Controls.UpdateFloatingDockSitePos. Source vcl/Controls.pas:5581. Prototype pending: nested routine has a parent-frame parameter."

function MinVar(const Data: array of Double): Integer; // @nameonly @note "DCC32 MAP Controls.MinVar. Source vcl/Controls.pas:5688. Prototype pending: nested routine has a parent-frame parameter."

function GetClientSize(Control: TWinControl): TPoint; // @nameonly @note "DCC32 MAP Controls.GetClientSize. Source vcl/Controls.pas:6217. Prototype pending: nested routine has a parent-frame parameter."

function InsertBefore(C1, C2: TControl; AAlign: TAlign): Boolean; // @nameonly @note "DCC32 MAP Controls.InsertBefore. Source vcl/Controls.pas:6227. Prototype pending: nested routine has a parent-frame parameter."

procedure DoPosition(Control: TControl; AAlign: TAlign; AlignInfo: TAlignInfo); // @nameonly @note "DCC32 MAP Controls.DoPosition. Source vcl/Controls.pas:6239. Prototype pending: nested routine has a parent-frame parameter."

procedure DoAlign(AAlign: TAlign); // @nameonly @note "DCC32 MAP Controls.DoAlign. Source vcl/Controls.pas:6364. Prototype pending: nested routine has a parent-frame parameter."

function AlignWork: Boolean; // @nameonly @note "DCC32 MAP Controls.AlignWork. Source vcl/Controls.pas:6402. Prototype pending: nested routine has a parent-frame parameter."

function PointsEqual(const P1, P2: TPoint): Boolean; // @nameonly @note "DCC32 MAP Controls.PointsEqual. Source vcl/Controls.pas:6803. Prototype pending: nested routine has a parent-frame parameter."

function DoWriteDesignSize: Boolean; // @nameonly @note "DCC32 MAP Controls.DoWriteDesignSize. Source vcl/Controls.pas:6808. Prototype pending: nested routine has a parent-frame parameter."

function DestroyChildWindow(Window: Cardinal; Data: PDestroyChildData): LongBool; stdcall; // @ida "__int32 __stdcall $name(unsigned __int32 Window, PDestroyChildData Data);" @note "DCC32 MAP Controls.DestroyChildWindow. Source vcl/Controls.pas:6918."

function GetControlAtPos(AControl: TControl): Boolean; // @nameonly @note "DCC32 MAP Controls.GetControlAtPos. Source vcl/Controls.pas:7057. Prototype pending: nested routine has a parent-frame parameter."

function DoControlMsg(ControlHandle: Cardinal; Message: Pointer): Boolean; // @ida "bool __usercall $name@<al>(unsigned __int32 ControlHandle@<eax>, void * Message@<edx>);" @note "DCC32 MAP Controls.DoControlMsg. Source vcl/Controls.pas:7311."

procedure DrawThemeEdge(DC: Cardinal; var DrawRect: TRect); // @nameonly @note "DCC32 MAP Controls.DrawThemeEdge. Source vcl/Controls.pas:7441. Prototype pending: nested routine has a parent-frame parameter."

function TraverseControls(Container: TWinControl): Boolean; // @nameonly @note "DCC32 MAP Controls.TraverseControls. Source vcl/Controls.pas:8180. Prototype pending: nested routine has a parent-frame parameter."

procedure DoCalcConstraints(Control: TControl; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); // @nameonly @note "DCC32 MAP Controls.DoCalcConstraints. Source vcl/Controls.pas:9176. Prototype pending: nested routine has a parent-frame parameter."

function ClientToWindow(Handle: Cardinal; X, Y: Integer): TPoint; // @ida "void __userpurge $name(unsigned __int32 Handle@<eax>, __int32 X@<edx>, __int32 Y@<ecx>, TPoint *Result@<^0>);" @note "DCC32 MAP Controls.ClientToWindow. Source vcl/Controls.pas:9969."

function NextVisibleZone(StartZone: TDockZone): TDockZone; // @ida "TDockZone * __usercall $name@<eax>(TDockZone *StartZone@<eax>);" @note "DCC32 MAP Controls.NextVisibleZone. Source vcl/Controls.pas:10131."

function IsOrientationSet(Zone: TDockZone): Boolean; // @ida "bool __usercall $name@<al>(TDockZone *Zone@<eax>);" @note "DCC32 MAP Controls.IsOrientationSet. Source vcl/Controls.pas:10138."

function ParentNotLast: Boolean; // @nameonly @note "DCC32 MAP Controls.ParentNotLast. Source vcl/Controls.pas:10351. Prototype pending: nested routine has a parent-frame parameter."

procedure DoFindControlZone(StartZone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoFindControlZone. Source vcl/Controls.pas:10552. Prototype pending: nested routine has a parent-frame parameter."

procedure DoForEach(Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoForEach. Source vcl/Controls.pas:10574. Prototype pending: nested routine has a parent-frame parameter."

procedure DoFindZone(Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoFindZone. Source vcl/Controls.pas:10868. Prototype pending: nested routine has a parent-frame parameter."

procedure ReadControlName(var ControlName: AnsiString); // @nameonly @note "DCC32 MAP Controls.ReadControlName. Source vcl/Controls.pas:10920. Prototype pending: nested routine has a parent-frame parameter."

procedure DrawCloseButton(Left, Top: Integer); // @nameonly @note "DCC32 MAP Controls.DrawCloseButton. Source vcl/Controls.pas:11058. Prototype pending: nested routine has a parent-frame parameter."

procedure DrawGrabberLine(Left, Top, Right, Bottom: Integer); // @nameonly @note "DCC32 MAP Controls.DrawGrabberLine. Source vcl/Controls.pas:11073. Prototype pending: nested routine has a parent-frame parameter."

procedure DrawThemedGrabber(const GripperType: TThemedReBar; const Left, Top, Right, Bottom: Integer); // @nameonly @note "DCC32 MAP Controls.DrawThemedGrabber. Source vcl/Controls.pas:11087. Prototype pending: nested routine has a parent-frame parameter."

procedure DoPrune(Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoPrune. Source vcl/Controls.pas:11211. Prototype pending: nested routine has a parent-frame parameter."

procedure WriteControlName(ControlName: AnsiString); // @nameonly @note "DCC32 MAP Controls.WriteControlName. Source vcl/Controls.pas:11418. Prototype pending: nested routine has a parent-frame parameter."

procedure DoSaveZone(Zone: TDockZone; Level: Integer); // @nameonly @note "DCC32 MAP Controls.DoSaveZone. Source vcl/Controls.pas:11427. Prototype pending: nested routine has a parent-frame parameter."

procedure DoSetNewBounds(Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoSetNewBounds. Source vcl/Controls.pas:11496. Prototype pending: nested routine has a parent-frame parameter."

procedure DoGetNextLimit(Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.DoGetNextLimit. Source vcl/Controls.pas:11605. Prototype pending: nested routine has a parent-frame parameter."

function GetDockAlign(Client, DropCtl: TControl): TAlign; // @nameonly @note "DCC32 MAP Controls.GetDockAlign. Source vcl/Controls.pas:11628. Prototype pending: nested routine has a parent-frame parameter."

procedure HideZone(const Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.HideZone. Source vcl/Controls.pas:11648. Prototype pending: nested routine has a parent-frame parameter."

procedure ShowZone(const Zone: TDockZone); // @nameonly @note "DCC32 MAP Controls.ShowZone. Source vcl/Controls.pas:11663. Prototype pending: nested routine has a parent-frame parameter."

procedure CalcSplitterPos; // @nameonly @note "DCC32 MAP Controls.CalcSplitterPos. Source vcl/Controls.pas:11888. Prototype pending: nested routine has a parent-frame parameter."

procedure InitIMM32; // @ida "void __usercall $name(void);" @note "DCC32 MAP Controls.InitIMM32. Source vcl/Controls.pas:12113."

function Win32NLSEnableIME(hWnd: Cardinal; Enable: Boolean): Boolean; // @ida "bool __usercall $name@<al>(unsigned __int32 hWnd@<eax>, bool Enable@<dl>);" @note "DCC32 MAP Controls.Win32NLSEnableIME. Source vcl/Controls.pas:12168."

procedure SetImeMode(hWnd: Cardinal; Mode: TImeMode); // @ida "void __usercall $name(unsigned __int32 hWnd@<eax>, TImeMode Mode@<dl>);" @note "DCC32 MAP Controls.SetImeMode. Source vcl/Controls.pas:12176."

procedure DoneControls; // @ida "void __usercall $name(void);" @note "DCC32 MAP Controls.DoneControls. Source vcl/Controls.pas:12367."

procedure InitControls; // @ida "void __usercall $name(void);" @note "DCC32 MAP Controls.InitControls. Source vcl/Controls.pas:12383."

procedure FinalizeControls; // @nameonly @note "DCC32 MAP Controls.Finalization. Prototype pending: no unique source declaration."

implementation
end.
