unit ActnList;
// Unit bracket (inferred): .text 0x0044E320..0x0044F620; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TContainedAction = class(TBasicAction) // @size 0x60
  public
    destructor Destroy; // @note "DCC32 MAP ActnList.TContainedAction.Destroy. Source vcl/ActnList.pas:304."
    procedure ReadState(Reader: TReader); virtual; // @note "DCC32 MAP ActnList.TContainedAction.ReadState. Source vcl/ActnList.pas:336." @slot 0x14
    procedure SetIndex(Value: Integer); // @note "DCC32 MAP ActnList.TContainedAction.SetIndex. Source vcl/ActnList.pas:343."
    procedure SetCategory(const Value: AnsiString); // @note "DCC32 MAP ActnList.TContainedAction.SetCategory. Source vcl/ActnList.pas:361."
    procedure SetActionList(AActionList: TCustomActionList); // @note "DCC32 MAP ActnList.TContainedAction.SetActionList. Source vcl/ActnList.pas:371."
    procedure SetParentComponent(AParent: TComponent); // @note "DCC32 MAP ActnList.TContainedAction.SetParentComponent. Source vcl/ActnList.pas:380."
    function Execute: Boolean; // @note "DCC32 MAP ActnList.TContainedAction.Execute. Source vcl/ActnList.pas:386."
    function Update: Boolean; override; // @note "DCC32 MAP ActnList.TContainedAction.Update. Source vcl/ActnList.pas:393." @slot 0x44
  end;

  TCustomAction = class(TContainedAction) // @size 0xA0
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP ActnList.TCustomAction.Create. Source vcl/ActnList.pas:709." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP ActnList.TCustomAction.Destroy. Source vcl/ActnList.pas:718."
    procedure AssignTo(Dest: TPersistent); virtual; // @note "DCC32 MAP ActnList.TCustomAction.AssignTo. Source vcl/ActnList.pas:727." @slot 0x0
    procedure SetCaption(const Value: AnsiString); // @note "DCC32 MAP ActnList.TCustomAction.SetCaption. Source vcl/ActnList.pas:760."
    procedure SetChecked(Value: Boolean); // @note "DCC32 MAP ActnList.TCustomAction.SetChecked. Source vcl/ActnList.pas:778."
    procedure SetEnabled(Value: Boolean); // @note "DCC32 MAP ActnList.TCustomAction.SetEnabled. Source vcl/ActnList.pas:812."
    procedure SetHelpKeyword(const Value: AnsiString); virtual; // @note "DCC32 MAP ActnList.TCustomAction.SetHelpKeyword. Source vcl/ActnList.pas:871." @slot 0x4C
    procedure SetHelpContext(Value: THelpContext); virtual; // @note "DCC32 MAP ActnList.TCustomAction.SetHelpContext. Source vcl/ActnList.pas:885." @slot 0x48
    procedure SetHint(const Value: AnsiString); // @note "DCC32 MAP ActnList.TCustomAction.SetHint. Source vcl/ActnList.pas:903."
    procedure SetImageIndex(Value: TImageIndex); // @note "DCC32 MAP ActnList.TCustomAction.SetImageIndex. Source vcl/ActnList.pas:921."
    procedure SetShortCut(Value: TShortCut); // @note "DCC32 MAP ActnList.TCustomAction.SetShortCut. Source vcl/ActnList.pas:939."
    procedure SetVisible(Value: Boolean); // @note "DCC32 MAP ActnList.TCustomAction.SetVisible. Source vcl/ActnList.pas:957."
    procedure SetName(const Value: TComponentName); override; // @note "DCC32 MAP ActnList.TCustomAction.SetName. Source vcl/ActnList.pas:975." @slot 0x18
    function DoHint(var HintStr: AnsiString): Boolean; // @note "DCC32 MAP ActnList.TCustomAction.DoHint. Source vcl/ActnList.pas:986."
    function Execute: Boolean; // @note "DCC32 MAP ActnList.TCustomAction.Execute. Source vcl/ActnList.pas:992."
    function GetSecondaryShortCuts: TShortCutList; // @note "DCC32 MAP ActnList.TCustomAction.GetSecondaryShortCuts. Source vcl/ActnList.pas:1003."
  end;

  TActionLink = class(TBasicActionLink) // @size 0x18
  end;

  TCustomActionList = class(TComponent) // @size 0x68
  public
    constructor Create(AOwner: TComponent); override; // @note "DCC32 MAP ActnList.TCustomActionList.Create. Source vcl/ActnList.pas:423." @slot 0x2C
    destructor Destroy; // @note "DCC32 MAP ActnList.TCustomActionList.Destroy. Source vcl/ActnList.pas:432."
    procedure GetChildren; // @nameonly @note "DCC32 MAP ActnList.TCustomActionList.GetChildren. Source vcl/ActnList.pas:440. Prototype pending: unsupported source type TGetChildProc: procedure (Child: TComponent) of object."
    procedure SetChildOrder(Component: TComponent; Order: Integer); // @note "DCC32 MAP ActnList.TCustomActionList.SetChildOrder. Source vcl/ActnList.pas:452."
    procedure SetImages(Value: TCustomImageList); virtual; // @note "DCC32 MAP ActnList.TCustomActionList.SetImages. Source vcl/ActnList.pas:478." @slot 0x34
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @note "DCC32 MAP ActnList.TCustomActionList.Notification. Source vcl/ActnList.pas:494." @slot 0x10
    procedure AddAction(Action: TContainedAction); // @note "DCC32 MAP ActnList.TCustomActionList.AddAction. Source vcl/ActnList.pas:505."
    procedure RemoveAction(Action: TContainedAction); // @note "DCC32 MAP ActnList.TCustomActionList.RemoveAction. Source vcl/ActnList.pas:512."
    procedure Change; virtual; // @note "DCC32 MAP ActnList.TCustomActionList.Change. Source vcl/ActnList.pas:518." @slot 0x30
    function IsShortCut(var Message: TWMKey): Boolean; // @note "DCC32 MAP ActnList.TCustomActionList.IsShortCut. Source vcl/ActnList.pas:532."
    function ExecuteAction(Action: TBasicAction): Boolean; // @note "DCC32 MAP ActnList.TCustomActionList.ExecuteAction. Source vcl/ActnList.pas:557."
    function UpdateAction(Action: TBasicAction): Boolean; // @note "DCC32 MAP ActnList.TCustomActionList.UpdateAction. Source vcl/ActnList.pas:563."
    procedure SetState(const Value: TActionListState); virtual; // @note "DCC32 MAP ActnList.TCustomActionList.SetState. Source vcl/ActnList.pas:569." @slot 0x38
  end;

  TActionListState = (asNormal, asSuspended, asSuspendedEnabled); // @size 0x1

  TShortCutList = class(TStringList) // @size 0x38
  public
    function Add(const S: AnsiString): Integer; override; // @note "DCC32 MAP ActnList.TShortCutList.Add. Source vcl/ActnList.pas:1029." @slot 0x38
    function IndexOfShortCut(const Shortcut: TShortCut): Integer; // @note "DCC32 MAP ActnList.TShortCutList.IndexOfShortCut. Source vcl/ActnList.pas:1048."
  end;

implementation
end.
