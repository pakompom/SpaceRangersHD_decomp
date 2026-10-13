unit ActnList;

interface

type
  TContainedAction = class(TBasicAction) // @size 0x60
  public
    destructor Destroy;
    procedure ReadState(Reader: TReader); virtual; // @slot 0x14
    procedure SetIndex(Value: Integer);
    procedure SetCategory(const Value: AnsiString);
    procedure SetActionList(AActionList: TCustomActionList);
    procedure SetParentComponent(AParent: TComponent);
    function Execute: Boolean;
    function Update: Boolean; override; // @slot 0x44
  end;

  TCustomAction = class(TContainedAction) // @size 0xA0
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x0
    procedure SetCaption(const Value: AnsiString);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: THelpContext); virtual; // @slot 0x48
    procedure SetHelpKeyword(const Value: AnsiString); virtual; // @slot 0x4C
    procedure SetHint(const Value: AnsiString);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetShortCut(Value: TShortCut);
    procedure SetVisible(Value: Boolean);
    procedure SetName(const Value: TComponentName); override; // @slot 0x18
    function DoHint(var HintStr: AnsiString): Boolean;
    function Execute: Boolean;
    function GetSecondaryShortCuts: TShortCutList;
  end;

  TActionLink = class(TBasicActionLink) // @size 0x18
  end;

  TCustomActionList = class(TComponent) // @size 0x68
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure GetChildren; // @nameonly
    procedure SetChildOrder(Component: TComponent; Order: Integer);
    procedure Change; virtual; // @slot 0x30
    procedure Notification(AComponent: TComponent; Operation: TOperation); override; // @slot 0x10
    procedure AddAction(Action: TContainedAction);
    procedure RemoveAction(Action: TContainedAction);
    procedure SetImages(Value: TCustomImageList); virtual; // @slot 0x34
    function IsShortCut(var Message: TWMKey): Boolean;
    function ExecuteAction(Action: TBasicAction): Boolean;
    function UpdateAction(Action: TBasicAction): Boolean;
    procedure SetState(const Value: TActionListState); virtual; // @slot 0x38
  end;

  TActionListState = (asNormal, asSuspended, asSuspendedEnabled); // @size 0x1

  TShortCutList = class(TStringList) // @size 0x38
  public
    function Add(const S: AnsiString): Integer; override; // @slot 0x38
    function IndexOfShortCut(const Shortcut: TShortCut): Integer;
  end;

implementation
end.
