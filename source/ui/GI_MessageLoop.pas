unit GI_MessageLoop;
// Unit bracket (inferred): .text 0x004C9034..0x004D036A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GR_Rect, Classes, EC_BlockPar, EC_Str, EC_Struct, Types;

type
  TDialogChoiceEventGI = procedure(Value: Integer) of object;
  TObjectNotifyEventGI = procedure(Sender: TObjectGI) of object;
  TObjectMouseEventGI = procedure(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint) of object;
  TObjectHelpEventGI = procedure(Sender: TObjectGI; Visible: Boolean) of object;
  TObjectKeyEventGI = procedure(Sender: TObjectGI; Key: Cardinal) of object;

  TObjectGI = class;
  TFormSoundGroup = class;
  TMessageLoopGI = class;

  TCursorStateGI = packed record // @size 0x18 // Native RTTI at $4C9014 includes three trailing padding bytes.
    ImagePath: WideString; // @offset 0x00
    Active: Boolean; // @offset 0x04
    HotSpot: TPoint; // @offset 0x05
    Position: TPoint; // @offset 0x0D
  end;

  TObjectGI = class(TObjectEx) // @size 0x120
  public
    FirstChild: TObjectGI; // @offset 0x04
    LastChild: TObjectGI; // @offset 0x08
    PrevSibling: TObjectGI; // @offset 0x0C
    NextSibling: TObjectGI; // @offset 0x10
    Parent: TObjectGI; // @offset 0x14
    MessageLoop: TMessageLoopGI; // @offset 0x18
    SourceBlock: TBlockParEC; // @offset $1C  Borrowed block used by ReloadFromBlock.
    LocalPosition: TPoint; // @offset 0x20
    ClientSize: TPoint; // @offset 0x28
    OriginPoint: TPoint; // @offset 0x30
    Depth: Double; // @offset 0x38
    PositionModeW: Boolean; // @offset 0x40
    Active: Boolean; // @offset 0x41
    HitTestDisabled: Boolean; // @offset 0x42
    ConfigPath: WideString; // @offset 0x44
    AutoOffsetEnabled: Boolean; // @offset $48
    AutoOffsetScale: TPointF; // @offset $4C
    ScrollOffset: TPoint; // @offset $54  Copied as one point by panel scrolling.
    SkipOwnQueuedDraw: Integer; // @offset $5C  Nonzero skips this object's queued draw, after visiting children ($4CAD96).
    HitTestBounds: TRect; // @offset 0x60
    AbsolutePosition: TPoint; // @offset 0x70
    ControlName: WideString; // @offset 0x78
    HelpText: WideString; // @offset 0x7C
    HelpCallback: TObjectHelpEventGI; // @offset $80
    MouseInside: Boolean; // @offset 0x88
    MouseBlocking: Boolean; // @offset 0x89
    MouseBlockingTest: Boolean; // @offset 0x8A
    ScrollUpdate: Boolean; // @offset $8B  Controls panel invalidation during scrolling; loaded from ScrollUpdate.
    UserValue: Integer; // @offset $8C  Per-frame delay in TAImageGI; embedded object ID in TLabelGI.
    UserIndex: Integer; // @offset $90  Embedded object index in TLabelGI; other uses remain unresolved.
    UserData: Integer; // @offset $94  Fixed-width quest parameter text stores Boolean-as-Integer here; other uses remain unresolved.
    UserState: Integer; // @offset $98  One selects the disabled quest-choice inline image; other uses remain unresolved.
    MouseMoveCallback: TObjectMouseEventGI; // @offset 0xA0
    LeftButtonDownCallback: TObjectMouseEventGI; // @offset 0xA8
    LeftButtonUpCallback: TObjectMouseEventGI; // @offset 0xB0
    RightButtonDownCallback: TObjectMouseEventGI; // @offset 0xB8
    RightButtonUpCallback: TObjectMouseEventGI; // @offset 0xC0
    LeftButtonDoubleClickCallback: TObjectMouseEventGI; // @offset 0xC8
    RightButtonDoubleClickCallback: TObjectMouseEventGI; // @offset 0xD0
    MouseEnterCallback: TObjectNotifyEventGI; // @offset 0xD8
    MouseLeaveCallback: TObjectNotifyEventGI; // @offset 0xE0
    ActivateCallback: TObjectNotifyEventGI; // @offset 0xE8
    DeactivateCallback: TObjectNotifyEventGI; // @offset 0xF0
    DestroyNotify: TObjectNotifyEventGI; // @offset 0xF8
    KeyDownCallback: TObjectKeyEventGI; // @offset 0x100
    KeyUpCallback: TObjectKeyEventGI; // @offset 0x108
    OnKeyDownCode: TBlockParEC; // @offset 0x110
    OnMouseEnterCode: TBlockParEC; // @offset 0x114
    OnMouseLeaveCode: TBlockParEC; // @offset 0x118
    OnRightButtonDownCode: TBlockParEC; // @offset 0x11C
    // Callback pairs contain a Delphi method's code and instance pointers.
    // Mouse move and button callbacks receive Context/EAX, Sender/EDX, key state/ECX and Point on stack;
    // key callbacks receive Context/EAX, Sender/EDX and virtual key/ECX.
    // Code blocks are borrowed from the UI configuration.
    // PositionModeW is the fourth Pos component ('w'); selects the parent's coordinate mode.
    // Notify callbacks receive Context in EAX and this object in EDX.

    constructor Create(Owner: TObjectGI); // @addr 0x4C93A8 @ida "TObjectGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4C946C @ida "void __usercall $name(TObjectGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; virtual; // @addr 0x4C9554 @slot 0x00 @note "Does not free children."
    procedure FreeOwnedChildren; // @addr 0x4C9530
    procedure AttachOwnedChild(Child: TObjectGI); // @addr 0x4C95D8 @note "Takes ownership; caller must detach an existing parent. Descendants' MessageLoop values are unchanged."
    procedure InsertOwnedChildBefore(BeforeChild, Child: TObjectGI); // @addr 0x4C9644
    procedure InsertOwnedChildByDepth(Child: TObjectGI; NewDepth: Double); // @addr 0x4C96C8 @ida "void __userpurge $name(TObjectGI *Self@<eax>, TObjectGI *Child@<edx>, double NewDepth@<^0>);" @note "Inserts in descending Depth order."
    procedure FreeOwnedChild(Child: TObjectGI); // @addr 0x4C9738
    procedure UnlinkOwnedChild(Child: TObjectGI); // @addr 0x4C975C @note "Leaves sibling pointers and MessageLoop unchanged."
    procedure Reparent(NewParent: TObjectGI); // @addr 0x4C97D4 @note "Preserves Depth."
    procedure SetMouseViewUpdates(Enabled: Boolean); // @addr 0x4C9808
    procedure UpdateAbsolutePosition; // @addr 0x4C983C @note "Updates this control and recurses through active children."
    function GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint; virtual; // @addr 0x4C98C8 @slot 0x04 @calls "0x4C9867" @ida "void __userpurge $name(TObjectGI *Self@<eax>, TPoint *LocalPosition@<edx>, bool ModeW@<cl>, TPoint *Result@<^0>);" @note "Base implementation ignores ModeW."
    procedure UpdateHitTestBounds; virtual; // @addr 0x4C9904 @slot 0x08 @calls "0x4C997A"
    procedure UpdateSubtreeHitBounds; // @addr 0x4C996C @note "Updates this control's hit-test rectangle and recurses through active children."
    procedure SetPosition(Position: TPoint); virtual; // @addr 0x4C9AD4 @slot 0x0C @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetDepth(NewDepth: Double); virtual; // @addr 0x4C9B54 @slot 0x10 @ida "void __userpurge $name(TObjectGI *Self@<eax>, double NewDepth@<^0>);" @note "Does nothing without Parent." @calls "0x5EE3B4 0x5EE920 0x5EF5FF 0x5EF66F 0x5EF815 0x5EF885 0x5EF948 0x5EFA4F 0x5EFC3C 0x5EFDDF 0x5EFEC2 0x6BBD40 0x6BBE30 0x6BBEA4"
    procedure SetDepthByName(const Name: WideString); virtual; // @addr $4C9C0C @slot $14
    procedure SetSize(Size: TPoint); virtual; // @addr 0x4C9C9C @slot 0x18 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure SetOrigin(Origin: TPoint); virtual; // @addr 0x4C9D1C @slot 0x1C @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Origin@<edx>);"
    procedure SetPositionModeW(Enabled: Boolean); // @addr 0x4C9D9C
    procedure SetConfigPath(const Path: WideString); virtual; // @addr 0x4C9DFC @slot 0x20 @note "Virtual loading sees the previous ConfigPath."
    function GetLocalBounds: TRect; virtual; // @addr 0x4C9E28 @slot 0x24 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Result@<edx>);"
    procedure SetName(const Name: WideString); // @addr 0x4C9E8C
    procedure SetActive(Enabled: Boolean); virtual; // @addr 0x4C9EAC @slot 0x28
    procedure SetHitTestDisabled(Disabled: Boolean); virtual; // @addr 0x4C9F18 @slot 0x2C
    procedure QueueImageLoad(PendingLoads: TList); virtual; // @addr 0x4CA020 @slot 0x30
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA030 @slot 0x38 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA3B8 @slot 0x54 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA440 @slot 0x58 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA4C8 @slot 0x5C @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA574 @slot 0x60 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA5FC @slot 0x64 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonDoubleClick(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4CA684 @slot 0x68 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure OnMouseEnter; virtual; // @addr 0x4CA12C @slot 0x3C
    procedure OnMouseLeave; virtual; // @addr 0x4CA1C0 @slot 0x40
    procedure BroadcastKeyDown(Key: Cardinal); virtual; // @addr 0x4CA70C @slot 0x6C
    procedure BroadcastKeyUp(Key: Cardinal); virtual; // @addr 0x4CA78C @slot 0x70
    procedure DispatchNamedEvent(EventKind, Param1, Param2: Integer); // @addr 0x4CA9C0
    procedure SetHelpCallbackRecursive(Callback: TObjectHelpEventGI); // @addr $4C99B0
    procedure OnHoverGained; virtual; // @addr $4CA7EC @slot $74 @calls "0x4CF203"
    procedure OnHoverLost; virtual; // @addr $4CA7F8 @slot $78 @calls "0x4CF1E6"
    procedure OnFocusGained; virtual; // @addr 0x4CA804 @slot 0x7C @calls "0x4CF1A8"
    procedure OnFocusLost; virtual; // @addr 0x4CA810 @slot 0x80 @calls "0x4CF188"
    procedure ProcessKeyDown(Key: Integer); virtual; // @addr 0x4CA81C @slot 0x84
    procedure ProcessCharacter(Character: WideChar); virtual; // @addr 0x4CA82C @slot 0x88
    procedure OnCaretBlink; virtual; // @addr $4CA840 @slot $8C @note "Called on the focused control when CaretBlinkOn changes."
    procedure NativeHook48; virtual; // @addr $4CA2EC @slot $48 @note "Purpose unresolved; the base hook visits children whose Active flag equals True."
    procedure NativeHook50; virtual; // @addr $4CA37C @slot $50 @note "Purpose unresolved; the base hook visits children whose Active flag equals True."
    procedure NativeHookB0; virtual; // @addr $4CB090 @slot $B0 @note "Purpose unresolved; the base hook visits active children."
    procedure NativeHookBC(Rect: TRect); virtual; // @addr $4CB12C @slot $BC @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>);" @note "Empty base hook; purpose unresolved."
    procedure OnActivate; virtual; // @addr 0x4CA28C @slot 0x44
    procedure OnDeactivate; virtual; // @addr 0x4CA328 @slot 0x4C
    procedure PrepareRegionDraw(ClipRect: TRect); virtual; // @addr $4CB110 @slot $B8 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Empty base hook called before queued drawing for RegionDrawControl."
    procedure CommitFrameDraw; virtual; // @addr $4CB010 @slot $A8 @note "After a successful frame; derived controls retain state needed to erase their previous drawing."
    procedure ErasePreviousFrame; virtual; // @addr $4CB050 @slot $AC @note "Before queued drawing; derived controls restore their saved background pixels."
    procedure PrepareFrameDraw; virtual; // @addr $4CB0D0 @slot $B4 @note "Before DrawUpdateRects; derived controls capture backgrounds or prepare geometry."
    procedure InvalidateChildren(IncludePanels: Boolean); // @addr $4CAAE4
    function InvalidateScrollOverlap(Rect: TRect; Delta: TPoint; StartControl: TObjectGI): TObjectGI; // @addr $4CAB4C @note "Walks active panel subtrees until StartControl, then invalidates affected controls by moving them out and back. Rect is passed through but unused." @ida "TObjectGI *__userpurge $name@<eax>(TObjectGI *Self@<eax>, TRect *Rect@<edx>, TPoint *Delta@<ecx>, TObjectGI *StartControl@<^0>);"
    procedure Draw(ClipRect: TRect); virtual; // @addr 0x4CAC4C @slot 0xA0 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Suppressed while PendingRedraw is set."
    procedure DrawUpdateRects(ClipRect: TRect); virtual; // @addr 0x4CACC0 @slot 0xA4 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure LoadFromConfigPath(const Path: WideString); virtual; // @addr 0x4CB148 @slot 0x34
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x4CB82C @slot 0xC0
    function OffsetChildRect(Rect: TRect; ModeW: Boolean): TRect; // @addr $4C9A1C @ida "void __userpurge $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>, bool ModeW@<cl>, TRect *Result@<^0>);" @note "Adds LocalPosition and subtracts ScrollOffset when ModeW is set."
    procedure InvalidateRect(Rect: TRect); virtual; // @addr $4CAA04 @slot $98 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>);"
    procedure Invalidate; virtual; // @addr 0x4CAAA0 @slot 0x9C
    procedure ReloadFromBlock; // @addr $4CC00C
    procedure UpdateAutoGeometry; virtual; // @addr 0x4CC030 @slot 0xC4
    function FindDeepestChildAtPoint(Point: TPoint): TObjectGI; // @addr 0x4C9F84 @ida "TObjectGI *__usercall $name@<eax>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);" @note "Returns Self when no child contains Point."
    function IsOccludedAtPoint(Point: TPoint): Boolean; // @addr 0x4C9FE4 @ida "bool __usercall $name@<al>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);"
    function ContainsPoint(Point: TPoint): Boolean; // @addr 0x4CA84C @ida "bool __usercall $name@<al>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);" @note "Requires Active and enabled hit testing; right and bottom edges are exclusive."
    function ToLocalPoint(Point: TPoint): TPoint; virtual; // @addr 0x4CA950 @slot 0x90 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);"
    function ToAbsolutePoint(Point: TPoint): TPoint; virtual; // @addr 0x4CA988 @slot 0x94 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);"
    function HitTestCursor: Boolean; // @addr 0x4CA8B8
    function FindByNameRecursive(const Name: WideString): TObjectGI; // @addr 0x4CA8E4 @note "Case-sensitive; includes Self. Duplicate names resolve in child-list order."
  end;

  PCursorStateGI = ^TCursorStateGI;
  TFormSoundGroup = class(TObjectEx) // @size 0x1C
  public
    Section: Integer; // @offset 0x04
    MinDelayMs: Integer; // @offset 0x08
    MaxDelayMs: Integer; // @offset 0x0C
    NextPlayTick: Cardinal; // @offset 0x10
    TotalWeight: Integer; // @offset 0x14
    Sounds: TStringsEC; // @offset 0x18
    // Each string is a sound name; its Data slot stores an integer weight.

    constructor Create; // @addr 0x4CC0B0 @ida "TFormSoundGroup *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4CC104 @ida "void __usercall $name(TFormSoundGroup *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x4CC150 @note "Preserves timing fields and TotalWeight."
    procedure LoadFromBlock(Block: TBlockParEC); // @addr 0x4CC170 @note "Numeric parameter names are weights; their values are sound names."
    procedure ScheduleNextPlayback; // @addr 0x4CC364
    procedure PlayIfDue; // @addr 0x4CC390
  end;

  PCallbackTimerGI = ^TCallbackTimerGI;
  TCallbackTimerEventGI = procedure(Timer: PCallbackTimerGI; UserData: Integer) of object;
  TCallbackTimerGI = packed record // @size 0x20
    // Callback ABI: Context in EAX, this timer in EDX, UserData in ECX.
    Callback: TCallbackTimerEventGI; // @offset 0x00
    UserData: Integer; // @offset 0x08
    RepeatMs: Integer; // @offset 0x0C
    DueTick: Cardinal; // @offset 0x10
    Prev: PCallbackTimerGI; // @offset 0x14
    Next: PCallbackTimerGI; // @offset 0x18
    // The final dword is not initialized or read by the timer list routines.
  end;

  TSavedLineGI = record // @size $18
    First: TPoint; // @offset $00
    Last: TPoint; // @offset $08
    Pixels: Pointer; // @offset $10
    Heap: Cardinal; // @offset $14
  end;
  TSavedLinesGI = array of TSavedLineGI;

  TMessageLoopGI = class(TObjectEx) // @size 0xD0
  public
    RegisteredLoopName: WideString; // @offset 0x04
    ParentLoop: TMessageLoopGI; // @offset 0x08
    ChildLoop: TMessageLoopGI; // @offset 0x0C
    DebugControl: TObjectGI; // @offset $10  Control selected by the built-in layout inspector.
    StatusLabel: TObjectGI; // @offset 0x14
    RootUiObject: TObjectGI; // @offset 0x18
    ContentPanel: TObjectGI; // @offset 0x1C
    BackgroundPanel: TObjectGI; // @offset 0x20
    OverlayPanel: TObjectGI; // @offset 0x24
    CursorControl: TObjectGI; // @offset 0x28
    FocusedControl: TObjectGI; // @offset 0x2C
    HoveredControl: TObjectGI; // @offset 0x30
    HelpLabel: TObjectGI; // @offset 0x34
    RegionDrawControl: TObjectGI; // @offset $38
    MouseViewUpdateControls: TList; // @offset 0x3C
    RegionDrawPending: Boolean; // @offset $40
    CursorImagePath: WideString; // @offset 0x44
    ViewportRect: TRect; // @offset 0x48
    UpdateRectsEnabled: Boolean; // @offset 0x58
    UpdateRects: TArrayRectGR; // @offset 0x5C
    ExitCode: Integer; // @offset 0x60
    CaretBlinkOn: Boolean; // @offset 0x64
    TimerTick: Cardinal; // @offset 0x68
    FirstTimer: PCallbackTimerGI; // @offset 0x6C
    LastTimer: PCallbackTimerGI; // @offset 0x70
    NextTimerToProcess: PCallbackTimerGI; // @offset 0x74
    LastObservedTimerTick: Cardinal; // @offset $78
    SavedPixels16: Pointer; // @offset $7C  Eight-byte entries: byte offset, then a pixel word in a dword slot.
    SavedPixelCount16: Integer; // @offset $80
    SavedPixelCapacity16: Integer; // @offset $84
    SecondaryPixelBuffer: Pointer; // @offset $88  Element format unresolved.
    SecondaryPixelCount: Integer; // @offset $8C
    SecondaryPixelCapacity: Integer; // @offset $90
    SavedLines: array of TSavedLineGI; // @offset $94
    SavedLineCount: Integer; // @offset $98
    PendingRedraw: Boolean; // @offset 0x9C
    ContinuousLoop: Boolean; // @offset 0x9D
    FramesPerSecond: Integer; // @offset 0xA0
    PlayTransitionSounds: Boolean; // @offset 0xA4
    OpenSoundName: WideString; // @offset 0xA8
    CloseSoundName: WideString; // @offset 0xAC
    SoundSection: Integer; // @offset 0xB0
    SoundGroupList: TList; // @offset 0xB4
    TransientControl: TObjectGI; // @offset $B8  Freed when Run/RunContinuous finishes; creation path not yet recovered.
    TransientData: TObject; // @offset $BC  Owned object freed before TransientControl; concrete class unresolved.
    IsOpen: Boolean; // @offset 0xC0
    SavedBackgroundControl: TObjectGI; // @offset 0xC4
    DeferredCodeBlocks: TList; // @offset 0xC8
    RefreshMouseAfterCode: Boolean; // @offset 0xCC

    constructor Create; // @addr 0x4CC44C @ida "TMessageLoopGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4CC50C @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function Run: Integer; virtual; // @addr 0x4CC90C @slot 0x00 @calls "0x80735A"
    procedure ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer); virtual; // @addr 0x4CDD08 @slot 0x04 @note "Dispatches mouse/keyboard messages, deferred UI code and layout-inspector keys. Button coordinates are unsigned words; move and wheel coordinates are signed."
    function RunContinuous: Integer; virtual; // @addr 0x4CD164 @slot 0x08 @calls "0x80730A"
    procedure AdvanceTimerTick; virtual; // @addr 0x4CD960 @slot 0x0C
    procedure DrawFrame; virtual; // @addr 0x4CDC00 @slot 0x10
    procedure Present; virtual; // @addr 0x4CDC28 @slot 0x14
    procedure ProcessNamedControlEvent(ControlName: WideString; EventKind, Param1, Param2: Integer); virtual; // @addr 0x4CF20C @slot 0x18
    procedure OnOpen; virtual; // @addr 0x4CF254 @slot 0x1C
    procedure OnClose; virtual; // @addr 0x4CF268 @slot 0x20
    procedure SelectMusic; virtual; // @addr 0x4CF350 @slot 0x28
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); virtual; // @addr 0x4CFCCC @slot 0x2C @ida "void __userpurge $name(TMessageLoopGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; virtual; // @addr 0x4D02B4 @slot 0x30
    procedure UpdateActionCursor(CanTake: Boolean); virtual; // @addr 0x4D02CC @slot 0x34
    function GetActionParentLoop: TMessageLoopGI; virtual; // @addr 0x4D02DC @slot 0x38 @note "Base returns nil."
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); virtual; // @addr 0x4D0358 @slot 0x3C @note "Key is zero for deferred mouse actions; key-down handlers pass the virtual key."
    procedure QueueUiCode(Block: TBlockParEC; RefreshMouse: Boolean); // @addr 0x4D02F4 @note "Borrows Block until event completion or Run exits."
    procedure RefreshMouseDispatch; // @addr 0x4D0328
    procedure SetHelpCallback(Callback: TObjectHelpEventGI); // @addr $4CEFA8
    procedure InitializeFromConfig(ConfigRoot: TBlockParEC; const ScreenName: WideString; UnusedFlag: Boolean); // @addr 0x4CFFA8
    procedure FreeSavedPixels16; // @addr $4CF978
    procedure RestoreSavedPixels16; // @addr $4CF9B4 @note "Contains a native handwritten PUSHAD/POPAD loop at $4CF9ED..$4CFA09."
    procedure FreeSecondaryPixelBuffer; // @addr $4CFA1C
    procedure ResetSecondaryPixelCount; // @addr $4CFA64
    procedure FreeSavedLines; // @addr $4CFA88 @note "Frees every allocated array slot, including slots beyond SavedLineCount."
    procedure AddSavedLine(First, Last: TPoint; Pixels: Pointer); // @addr $4CFB04 @ida "void __userpurge $name(TMessageLoopGI *Self@<eax>, TPoint *First@<edx>, TPoint *Last@<ecx>, void *Pixels@<^0>);" @note "Takes the pixel allocation; records the process heap."
    procedure RestoreSavedLines; // @addr $4CFBF0 @note "Restores SavedLineCount lines unless SkipSavedPixelRestore is set; retains the count."
    procedure ResetSavedLineCount; // @addr $4CFCB4
    procedure InvalidateMouseViewControls; // @addr $4CC794
    procedure ClearTransientControl; // @addr $4CFCEC
    procedure InvalidateTransientControl; // @addr $4CFD58 @note "Temporarily enables queued invalidation; an exception leaves it enabled."
    procedure ResetRuntime; // @addr 0x4CC590 @note "Frees the root tree and cancels callback timers."
    procedure QueueUpdateRect(Rect: TRect); // @addr 0x4CC654 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TRect *Rect@<edx>);" @note "Clips to GameScreenRect; does nothing when update rectangles are disabled."
    procedure InvalidateViewport; // @addr 0x4CC69C
    function FindMouseViewUpdateControl(Control: TObjectGI): Integer; // @addr 0x4CC6D4
    procedure AddMouseViewUpdateControl(Control: TObjectGI); // @addr 0x4CC730 @note "Duplicates are ignored."
    procedure RemoveMouseViewUpdateControl(Control: TObjectGI); // @addr 0x4CC760
    procedure DrawQueuedControlRects; // @addr $4CC85C @note "Sets PendingRedraw and traverses queued drawing through the root tree."
    procedure CommitFrameDraw; // @addr $4CC8C4
    procedure ErasePreviousFrame; // @addr $4CC8DC
    procedure PrepareFrameDraw; // @addr $4CC8F4
    procedure FinishQueuedDraw; // @addr $4CC8B0 @note "Clears RegionDrawPending."
    procedure SetSystemCursorPosition(Point: TPoint); // @addr $4CF860 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TPoint *Point@<edx>);" @note "Uses screen coordinates."
    function ConsumeTimerTickChange: Boolean; // @addr $4CF888 @note "Returns true once for each changed TimerTick."
    procedure DrawQueuedUpdateRects; // @addr 0x4CC7E4 @note "Leaves queued rectangles in place."
    procedure CaptureScreenshot; // @addr $4CED18 @note "Uses the first free Shot000..Shot999 name; silently skips when all names are occupied."
    procedure RequestClose(ResultCode: Integer); // @addr 0x4CEF8C
    function GetByName(const Name: WideString): TObjectGI; // @addr 0x4CEFC8 @note "Search is limited to ContentPanel; raises when absent."
    function FindControlByPath(const Path: WideString): TObjectGI; // @addr 0x4CF0A0 @note "Each component may match a descendant, not just a direct child. Returns nil when absent."
    procedure SetFocusedControl(Control: TObjectGI); // @addr 0x4CF160
    procedure SetHoveredControl(Control: TObjectGI); // @addr 0x4CF1B0
    procedure ProcessCallbackTimers; virtual; // @slot 0x24 @addr 0x4CF27C @note "May wait for a timer or Windows message; zero RepeatMs still repeats."
    function ScheduleCallbackTimer(DelayMs, RepeatMs: Integer; Callback: TCallbackTimerEventGI; UserData: Integer = 0): PCallbackTimerGI; // @addr 0x4CF35C @note "Computes DueTick from the stored TimerTick, not a new clock sample."
    procedure CancelCallbackTimer(Timer: PCallbackTimerGI); // @addr 0x4CF408
    procedure UpdateCallbackTimer(Timer: PCallbackTimerGI; DelayMs, RepeatMs: Integer); // @addr 0x4CF4A0
    procedure ReinsertCallbackTimer(Timer: PCallbackTimerGI); // @addr 0x4CF4FC @note "Equal deadlines run in reverse insertion order; clock wraparound is not handled."
    procedure RefreshTimerTick; // @addr 0x4CF62C
    procedure SetCursorImage(const ImagePath: WideString; HotSpot: TPoint); // @addr 0x4CF644 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, unsigned __int16 *ImagePath@<edx>, TPoint *HotSpot@<ecx>);" @note "Does nothing when custom cursors are disabled."
    procedure SetCursorByName(const Name: WideString); // @addr 0x4CF6A0
    function IsCursorImageSelected(const RegisteredName: WideString): Boolean; // @addr 0x4CF6DC @note "Ignores cursor activity; registered names with the same image path compare equal."
    function IsCursorActive: Boolean; // @addr 0x4CF710
    procedure SetCursorActive(Enabled: Boolean); // @addr 0x4CF72C
    procedure CaptureCursorState(State: PCursorStateGI); // @addr 0x4CF758 @note "Writes caller-owned state; its WideString must be initialized. Pointer form is required by native record-copy evaluation order."
    procedure RestoreCursorState(State: PCursorStateGI); // @addr 0x4CF7B0 @note "Reads caller-owned state through a pointer; ignored when custom cursors are disabled."
    procedure UpdateCursorPosition; // @addr 0x4CF7FC @note "Moves the image cursor to the system mouse position, converted to client coordinates in windowed mode."
    function GetCursorPoint: TPoint; // @addr 0x4CF83C @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TPoint *Result@<edx>);" @note "Returns CursorControl's local position."
    function QueryPointOcclusionState(Point: TPoint; IgnoreControl, StartControl: TObjectGI): Integer; // @addr 0x4CF8BC @ida "int __userpurge $name@<eax>(TMessageLoopGI *Self@<eax>, TPoint *Point@<edx>, TObjectGI *IgnoreControl@<ecx>, TObjectGI *StartControl@<^0>);" @note "Starts at RootUiObject when StartControl is nil; returns 1 for a blocker, -1 for IgnoreControl, or 0 for no hit."
    procedure InitializeDefaults; // @addr 0x4CFD9C
  end;

procedure PushMessageLoop(Loop: TMessageLoopGI); // @addr $4C92F4
procedure PopMessageLoop(Loop: TMessageLoopGI); // @addr $4C9328

var
  MessageLoopStack: TList = nil; // @addr $87A7FC
  IgnoreWarpMouseMove: Boolean = False; // @addr $87A800  Consumes the mouse move generated by viewport cursor recentering.
  LastMousePosition: TPoint; // @addr $8891C8  Written by ProcessWindowMessage and reused by RefreshMouseDispatch.

implementation

uses PopUp, BreakMessageGIException, EC_Mem, MMSystem, Windows, Messages, GI_Cursor, GI_Label, GI_Main, GI_Panel, GI_GraphBuf, GlobalsV, Globals, GR_Main, GR_GraphBuf, SysUtils, aMyFunction, GR_Sound, GR_Music;

{ @routine $4C92F4 PushMessageLoop }
procedure PushMessageLoop(Loop: TMessageLoopGI);
begin
  if MessageLoopStack = nil then MessageLoopStack := TList.Create;
  MessageLoopStack.Add(Loop);
end;
{ @end $4C92F4 }

{ @routine $4C9328 PopMessageLoop }
procedure PopMessageLoop(Loop: TMessageLoopGI);
begin
  if (MessageLoopStack = nil) or (MessageLoopStack.Count < 1) then RaiseWideMessage('ML 1');
  if MessageLoopStack[MessageLoopStack.Count - 1] <> Loop then RaiseWideMessage('ML 2');
  MessageLoopStack.Delete(MessageLoopStack.Count - 1);
end;
{ @end $4C9328 }

{ @routine $4C93A8 TObjectGI_Create }
constructor TObjectGI.Create(Owner: TObjectGI);
begin
  inherited Create;
  Active := True;
  HitTestDisabled := False;
  MouseBlocking := False;
  MouseBlockingTest := True;
  ScrollUpdate := False;
  AutoOffsetEnabled := False;
  AutoOffsetScale.X := 0;
  AutoOffsetScale.Y := 0;
  if Owner <> nil then Owner.AttachOwnedChild(Self);
  OnKeyDownCode := nil;
  OnMouseEnterCode := nil;
  OnMouseLeaveCode := nil;
  OnRightButtonDownCode := nil;
end;
{ @end $4C93A8 }

{ @routine $4C946C TObjectGI_Destroy }
destructor TObjectGI.Destroy;
begin
  if MessageLoop <> nil then
  begin
    MessageLoop.RemoveMouseViewUpdateControl(Self);
    if MessageLoop.FocusedControl = Self then MessageLoop.SetFocusedControl(nil);
    if MessageLoop.HoveredControl = Self then MessageLoop.HoveredControl := nil;
  end;
  Clear;
  FreeOwnedChildren;
  if Parent <> nil then Parent.UnlinkOwnedChild(Self);
  if Assigned(DestroyNotify) then DestroyNotify(Self);
  inherited Destroy;
end;
{ @end $4C946C }

{ @routine $4C9530 TObjectGI_FreeOwnedChildren }
procedure TObjectGI.FreeOwnedChildren;
begin
  while LastChild <> nil do FreeOwnedChild(FirstChild);
end;
{ @end $4C9530 }

{ @routine $4C9554 TObjectGI_Clear }
procedure TObjectGI.Clear;
begin
  LocalPosition.X := 0;
  LocalPosition.Y := 0;
  ClientSize.X := 0;
  ClientSize.Y := 0;
  OriginPoint.X := 0;
  OriginPoint.Y := 0;
  Depth := 0;
  PositionModeW := False;
  Active := True;
  HitTestDisabled := False;
  ConfigPath := '';
  MouseBlocking := False;
  MouseBlockingTest := True;
  ScrollUpdate := False;
end;
{ @end $4C9554 }

{ @routine $4C95D8 TObjectGI_AttachOwnedChild }
procedure TObjectGI.AttachOwnedChild(Child: TObjectGI);
begin
  if LastChild <> nil then LastChild.NextSibling := Child;
  Child.PrevSibling := LastChild;
  Child.NextSibling := nil;
  LastChild := Child;
  if FirstChild = nil then FirstChild := Child;
  Child.Parent := Self;
  Child.MessageLoop := MessageLoop;
end;
{ @end $4C95D8 }

{ @routine $4C9644 TObjectGI_InsertOwnedChildBefore }
procedure TObjectGI.InsertOwnedChildBefore(BeforeChild, Child: TObjectGI);
begin
  if BeforeChild <> nil then
  begin
    Child.PrevSibling := BeforeChild.PrevSibling;
    Child.NextSibling := BeforeChild;
    if BeforeChild.PrevSibling <> nil then BeforeChild.PrevSibling.NextSibling := Child;
    BeforeChild.PrevSibling := Child;
    if FirstChild = BeforeChild then FirstChild := Child;
    Child.Parent := Self;
    Child.MessageLoop := MessageLoop;
  end
  else AttachOwnedChild(Child);
end;
{ @end $4C9644 }

{ @routine $4C96C8 TObjectGI_InsertOwnedChildByDepth }
procedure TObjectGI.InsertOwnedChildByDepth(Child: TObjectGI; NewDepth: Double);
var BeforeChild: TObjectGI;
begin
  Child.Depth := NewDepth;
  BeforeChild := FirstChild;
  while BeforeChild <> nil do
  begin
    if BeforeChild.Depth <= NewDepth then
    begin
      InsertOwnedChildBefore(BeforeChild, Child);
      Break;
    end;
    BeforeChild := BeforeChild.NextSibling;
  end;
  if BeforeChild = nil then AttachOwnedChild(Child);
end;
{ @end $4C96C8 }

{ @routine $4C9738 TObjectGI_FreeOwnedChild }
procedure TObjectGI.FreeOwnedChild(Child: TObjectGI);
begin
  UnlinkOwnedChild(Child);
  Child.Free;
end;
{ @end $4C9738 }

{ @routine $4C975C TObjectGI_UnlinkOwnedChild }
procedure TObjectGI.UnlinkOwnedChild(Child: TObjectGI);
begin
  if Child.PrevSibling <> nil then Child.PrevSibling.NextSibling := Child.NextSibling;
  if Child.NextSibling <> nil then Child.NextSibling.PrevSibling := Child.PrevSibling;
  if LastChild = Child then LastChild := Child.PrevSibling;
  if FirstChild = Child then FirstChild := Child.NextSibling;
  Child.Parent := nil;
end;
{ @end $4C975C }

{ @routine $4C97D4 TObjectGI_Reparent }
procedure TObjectGI.Reparent(NewParent: TObjectGI);
begin
  Parent.UnlinkOwnedChild(Self);
  NewParent.InsertOwnedChildByDepth(Self, Depth);
end;
{ @end $4C97D4 }

{ @routine $4C9808 TObjectGI_SetMouseViewUpdates }
procedure TObjectGI.SetMouseViewUpdates(Enabled: Boolean);
begin
  if Enabled = True then MessageLoop.AddMouseViewUpdateControl(Self)
  else MessageLoop.RemoveMouseViewUpdateControl(Self);
end;
{ @end $4C9808 }

{ @routine $4C983C TObjectGI_UpdateAbsolutePosition }
procedure TObjectGI.UpdateAbsolutePosition;
var Child: TObjectGI;
begin
  if Parent <> nil then
    AbsolutePosition := Parent.GetChildAbsolutePosition(LocalPosition, PositionModeW)
  else
  begin
    AbsolutePosition.X := LocalPosition.X;
    AbsolutePosition.Y := LocalPosition.Y;
  end;
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active = True then Child.UpdateAbsolutePosition;
    Child := Child.NextSibling;
  end;
end;
{ @end $4C983C }

{ @routine $4C98C8 TObjectGI_GetChildAbsolutePosition }
function TObjectGI.GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint;
begin
  Result.X := AbsolutePosition.X + LocalPosition.X;
  Result.Y := AbsolutePosition.Y + LocalPosition.Y;
end;
{ @end $4C98C8 }

{ @routine $4C9904 TObjectGI_UpdateHitTestBounds }
procedure TObjectGI.UpdateHitTestBounds;
begin
  HitTestBounds := Classes.Rect(AbsolutePosition.X - OriginPoint.X, AbsolutePosition.Y - OriginPoint.Y,
    AbsolutePosition.X - OriginPoint.X + ClientSize.X, AbsolutePosition.Y - OriginPoint.Y + ClientSize.Y);
end;
{ @end $4C9904 }

{ @routine $4C996C TObjectGI_UpdateSubtreeHitBounds }
procedure TObjectGI.UpdateSubtreeHitBounds;
var Child: TObjectGI;
begin
  UpdateHitTestBounds;
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active = True then Child.UpdateSubtreeHitBounds;
    Child := Child.NextSibling;
  end;
end;
{ @end $4C996C }

{ @routine $4C99B0 TObjectGI_SetHelpCallbackRecursive }
procedure TObjectGI.SetHelpCallbackRecursive(Callback: TObjectHelpEventGI);
var Child: TObjectGI;
begin
  if (HelpText <> '') or Assigned(HelpCallback) then HelpCallback := Callback;
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.SetHelpCallbackRecursive(Callback);
    Child := Child.NextSibling;
  end;
end;
{ @end $4C99B0 }

{ @routine $4C9A1C TObjectGI_OffsetChildRect }
function TObjectGI.OffsetChildRect(Rect: TRect; ModeW: Boolean): TRect;
begin
  if not ModeW then
  begin
    Result.Left := LocalPosition.X + Rect.Left;
    Result.Top := LocalPosition.Y + Rect.Top;
    Result.Right := LocalPosition.X + Rect.Right;
    Result.Bottom := LocalPosition.Y + Rect.Bottom;
  end
  else
  begin
    Result.Left := LocalPosition.X + Rect.Left - ScrollOffset.X;
    Result.Top := LocalPosition.Y + Rect.Top - ScrollOffset.Y;
    Result.Right := LocalPosition.X + Rect.Right - ScrollOffset.X;
    Result.Bottom := LocalPosition.Y + Rect.Bottom - ScrollOffset.Y;
  end;
end;
{ @end $4C9A1C }

{ @routine $4C9AD4 TObjectGI_SetPosition }
procedure TObjectGI.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X = Position.X) and (LocalPosition.Y = Position.Y) then Exit;
  if not Active then LocalPosition := Position
  else
  begin
    Invalidate;
    LocalPosition := Position;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $4C9AD4 }

{ @routine $4C9B54 TObjectGI_SetDepth }
procedure TObjectGI.SetDepth(NewDepth: Double);
begin
  if Depth = NewDepth then Exit;
  if Parent = nil then Exit;
  if PrevSibling <> nil then PrevSibling.NextSibling := NextSibling;
  if NextSibling <> nil then NextSibling.PrevSibling := PrevSibling;
  if Parent.LastChild = Self then Parent.LastChild := PrevSibling;
  if Parent.FirstChild = Self then Parent.FirstChild := NextSibling;
  Parent.InsertOwnedChildByDepth(Self, NewDepth);
  Invalidate;
end;
{ @end $4C9B54 }

{ @routine $4C9C0C TObjectGI_SetDepthByName }
procedure TObjectGI.SetDepthByName(const Name: WideString);
var Value: WideString;
begin
  Value := UiDepthConfig.GetParamOrMarker(Name);
  if Value <> '' then SetDepth(ExtractDecimalToSingleW(Value))
  else SetDepth(ExtractDecimalToSingleW(Name));
end;
{ @end $4C9C0C }

{ @routine $4C9C9C TObjectGI_SetSize }
procedure TObjectGI.SetSize(Size: TPoint);
begin
  if (ClientSize.X = Size.X) and (ClientSize.Y = Size.Y) then Exit;
  if not Active then ClientSize := Size
  else
  begin
    Invalidate;
    ClientSize := Size;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $4C9C9C }

{ @routine $4C9D1C TObjectGI_SetOrigin }
procedure TObjectGI.SetOrigin(Origin: TPoint);
begin
  if (OriginPoint.X = Origin.X) and (OriginPoint.Y = Origin.Y) then Exit;
  if not Active then OriginPoint := Origin
  else
  begin
    Invalidate;
    OriginPoint := Origin;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $4C9D1C }

{ @routine $4C9D9C TObjectGI_SetPositionModeW }
procedure TObjectGI.SetPositionModeW(Enabled: Boolean);
begin
  if PositionModeW = Enabled then Exit;
  if not Active then PositionModeW := Enabled
  else
  begin
    Invalidate;
    PositionModeW := Enabled;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $4C9D9C }

{ @routine $4C9DFC TObjectGI_SetConfigPath }
procedure TObjectGI.SetConfigPath(const Path: WideString);
begin
  LoadFromConfigPath(Path);
  ConfigPath := Path;
end;
{ @end $4C9DFC }

{ @routine $4C9E28 TObjectGI_GetLocalBounds }
function TObjectGI.GetLocalBounds: TRect;
begin
  Result.Left := LocalPosition.X - OriginPoint.X;
  Result.Top := LocalPosition.Y - OriginPoint.Y;
  Result.Right := LocalPosition.X - OriginPoint.X + ClientSize.X;
  Result.Bottom := LocalPosition.Y - OriginPoint.Y + ClientSize.Y;
end;
{ @end $4C9E28 }

{ @routine $4C9E8C TObjectGI_SetName }
procedure TObjectGI.SetName(const Name: WideString);
begin
  ControlName := Name;
end;
{ @end $4C9E8C }

{ @routine $4C9EAC TObjectGI_SetActive }
procedure TObjectGI.SetActive(Enabled: Boolean);
begin
  if Active = Enabled then Exit;
  if Enabled = True then
  begin
    Active := Enabled;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    OnActivate;
  end
  else
  begin
    Invalidate;
    Active := Enabled;
    OnDeactivate;
  end;
end;
{ @end $4C9EAC }

{ @routine $4C9F18 TObjectGI_SetHitTestDisabled }
procedure TObjectGI.SetHitTestDisabled(Disabled: Boolean);
begin
  if HitTestDisabled = Disabled then Exit;
  if Disabled = True then
  begin
    HitTestDisabled := Disabled;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
    OnActivate;
  end
  else
  begin
    Invalidate;
    HitTestDisabled := Disabled;
    OnDeactivate;
  end;
end;
{ @end $4C9F18 }

{ @routine $4C9F84 TObjectGI_FindDeepestChildAtPoint }
function TObjectGI.FindDeepestChildAtPoint(Point: TPoint): TObjectGI;
var Child: TObjectGI;
begin
  Child := LastChild;
  while Child <> nil do
  begin
    if Child.ContainsPoint(Point) then
    begin
      Result := Child.FindDeepestChildAtPoint(Point);
      Exit;
    end;
    Child := Child.PrevSibling;
  end;
  Result := Self;
end;
{ @end $4C9F84 }

{ @routine $4C9FE4 TObjectGI_IsOccludedAtPoint }
function TObjectGI.IsOccludedAtPoint(Point: TPoint): Boolean;
begin
  if MessageLoop.QueryPointOcclusionState(Point, Self, nil) = 1 then Result := True
  else Result := False;
end;
{ @end $4C9FE4 }

{ @routine $4CA020 TObjectGI_QueueImageLoad }
procedure TObjectGI.QueueImageLoad(PendingLoads: TList);
begin
end;
{ @end $4CA020 }

{ @routine $4CA030 TObjectGI_ProcessMouseMove }
procedure TObjectGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(MouseMoveCallback) then MouseMoveCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and not Child.ContainsPoint(Point) and (Child.MouseInside = True) then
      Child.OnMouseLeave;
    Child := Child.NextSibling;
  end;
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then
    begin
      if Child.MouseInside = False then Child.OnMouseEnter;
      Child.ProcessMouseMove(KeyState, Point);
      DispatchNamedEvent(3, Point.X, Point.Y);
    end;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA030 }

{ @routine $4CA12C TObjectGI_OnMouseEnter }
procedure TObjectGI.OnMouseEnter;
begin
  if Assigned(MouseEnterCallback) then MouseEnterCallback(Self);
  if OnMouseEnterCode <> nil then MessageLoop.QueueUiCode(OnMouseEnterCode, False);
  MouseInside := True;
  if HelpText <> '' then
    if MessageLoop.HelpLabel <> nil then (MessageLoop.HelpLabel as TLabelGI).SetText(HelpText);
end;
{ @end $4CA12C }

{ @routine $4CA1C0 TObjectGI_OnMouseLeave }
procedure TObjectGI.OnMouseLeave;
var Child: TObjectGI;
begin
  if Assigned(MouseLeaveCallback) then MouseLeaveCallback(Self);
  if OnMouseLeaveCode <> nil then MessageLoop.QueueUiCode(OnMouseLeaveCode, False);
  MouseInside := False;
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and (Child.MouseInside = True) then Child.OnMouseLeave;
    Child := Child.NextSibling;
  end;
  if HelpText <> '' then
    if MessageLoop.HelpLabel <> nil then (MessageLoop.HelpLabel as TLabelGI).SetText('');
end;
{ @end $4CA1C0 }

{ @routine $4CA28C TObjectGI_OnActivate }
procedure TObjectGI.OnActivate;
var Child: TObjectGI;
begin
  if Assigned(ActivateCallback) then ActivateCallback(Self);
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active = True then Child.OnActivate;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA28C }

{ @routine $4CA2EC TObjectGI_NativeHook48 }
procedure TObjectGI.NativeHook48;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active = True then Child.NativeHook48;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA2EC }

{ @routine $4CA328 TObjectGI_OnDeactivate }
procedure TObjectGI.OnDeactivate;
var Child: TObjectGI;
begin
  if Assigned(DeactivateCallback) then DeactivateCallback(Self);
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.OnDeactivate;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA328 }

{ @routine $4CA37C TObjectGI_NativeHook50 }
procedure TObjectGI.NativeHook50;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active = True then Child.NativeHook50;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA37C }

{ @routine $4CA3B8 TObjectGI_ProcessLeftButtonDown }
procedure TObjectGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(LeftButtonDownCallback) then LeftButtonDownCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessLeftButtonDown(KeyState, Point);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA3B8 }

{ @routine $4CA440 TObjectGI_ProcessLeftButtonUp }
procedure TObjectGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(LeftButtonUpCallback) then LeftButtonUpCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessLeftButtonUp(KeyState, Point);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA440 }

{ @routine $4CA4C8 TObjectGI_ProcessRightButtonDown }
procedure TObjectGI.ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(RightButtonDownCallback) then RightButtonDownCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessRightButtonDown(KeyState, Point);
    Child := Child.NextSibling;
  end;
  if OnRightButtonDownCode <> nil then MessageLoop.QueueUiCode(OnRightButtonDownCode, False);
end;
{ @end $4CA4C8 }

{ @routine $4CA574 TObjectGI_ProcessRightButtonUp }
procedure TObjectGI.ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(RightButtonUpCallback) then RightButtonUpCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessRightButtonUp(KeyState, Point);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA574 }

{ @routine $4CA5FC TObjectGI_ProcessLeftButtonDoubleClick }
procedure TObjectGI.ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(LeftButtonDoubleClickCallback) then LeftButtonDoubleClickCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessLeftButtonDoubleClick(KeyState, Point);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA5FC }

{ @routine $4CA684 TObjectGI_ProcessRightButtonDoubleClick }
procedure TObjectGI.ProcessRightButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
var Child: TObjectGI;
begin
  if Assigned(RightButtonDoubleClickCallback) then RightButtonDoubleClickCallback(Self, KeyState, Point);
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child.Active = True) and Child.ContainsPoint(Point) then Child.ProcessRightButtonDoubleClick(KeyState, Point);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA684 }

{ @routine $4CA70C TObjectGI_BroadcastKeyDown }
procedure TObjectGI.BroadcastKeyDown(Key: Cardinal);
var Child: TObjectGI;
begin
  if OnKeyDownCode <> nil then MessageLoop.ExecuteUiCode(OnKeyDownCode, Key);
  if Assigned(KeyDownCallback) then KeyDownCallback(Self, Key);
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.BroadcastKeyDown(Key);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA70C }

{ @routine $4CA78C TObjectGI_BroadcastKeyUp }
procedure TObjectGI.BroadcastKeyUp(Key: Cardinal);
var Child: TObjectGI;
begin
  if Assigned(KeyUpCallback) then KeyUpCallback(Self, Key);
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.BroadcastKeyUp(Key);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CA78C }

{ @routine $4CA7EC TObjectGI_OnHoverGained }
procedure TObjectGI.OnHoverGained;
begin
end;
{ @end $4CA7EC }

{ @routine $4CA7F8 TObjectGI_OnHoverLost }
procedure TObjectGI.OnHoverLost;
begin
end;
{ @end $4CA7F8 }

{ @routine $4CA804 TObjectGI_OnFocusGained }
procedure TObjectGI.OnFocusGained;
begin
end;
{ @end $4CA804 }

{ @routine $4CA810 TObjectGI_OnFocusLost }
procedure TObjectGI.OnFocusLost;
begin
end;
{ @end $4CA810 }

{ @routine $4CA81C TObjectGI_ProcessKeyDown }
procedure TObjectGI.ProcessKeyDown(Key: Integer);
begin
end;
{ @end $4CA81C }

{ @routine $4CA82C TObjectGI_ProcessCharacter }
procedure TObjectGI.ProcessCharacter(Character: WideChar);
begin
end;
{ @end $4CA82C }

{ @routine $4CA840 TObjectGI_OnCaretBlink }
procedure TObjectGI.OnCaretBlink;
begin
end;
{ @end $4CA840 }

{ @routine $4CA84C TObjectGI_ContainsPoint }
function TObjectGI.ContainsPoint(Point: TPoint): Boolean;
begin
  if (Active = False) or (HitTestDisabled = True) then
  begin
    Result := False;
    Exit;
  end;
  if (Point.X >= HitTestBounds.Left) and (Point.Y >= HitTestBounds.Top) and
    (Point.X < HitTestBounds.Right) and (Point.Y < HitTestBounds.Bottom) then Result := True
  else Result := False;
end;
{ @end $4CA84C }

{ @routine $4CA8B8 TObjectGI_HitTestCursor }
function TObjectGI.HitTestCursor: Boolean;
begin
  Result := ContainsPoint(MessageLoop.GetCursorPoint);
end;
{ @end $4CA8B8 }

{ @routine $4CA8E4 TObjectGI_FindByNameRecursive }
function TObjectGI.FindByNameRecursive(const Name: WideString): TObjectGI;
var Child, Found: TObjectGI;
begin
  if ControlName = Name then
  begin
    Result := Self;
    Exit;
  end;
  Child := FirstChild;
  while Child <> nil do
  begin
    Found := Child.FindByNameRecursive(Name);
    if Found <> nil then
    begin
      Result := Found;
      Exit;
    end;
    Child := Child.NextSibling;
  end;
  Result := nil;
end;
{ @end $4CA8E4 }

{ @routine $4CA950 TObjectGI_ToLocalPoint }
function TObjectGI.ToLocalPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X - AbsolutePosition.X;
  Result.Y := Point.Y - AbsolutePosition.Y;
end;
{ @end $4CA950 }

{ @routine $4CA988 TObjectGI_ToAbsolutePoint }
function TObjectGI.ToAbsolutePoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X + AbsolutePosition.X;
  Result.Y := Point.Y + AbsolutePosition.Y;
end;
{ @end $4CA988 }

{ @routine $4CA9C0 TObjectGI_DispatchNamedEvent }
procedure TObjectGI.DispatchNamedEvent(EventKind, Param1, Param2: Integer);
begin
  if Length(ControlName) > 0 then MessageLoop.ProcessNamedControlEvent(ControlName, EventKind, Param1, Param2);
end;
{ @end $4CA9C0 }

{ @routine $4CAA04 TObjectGI_InvalidateRect }
procedure TObjectGI.InvalidateRect(Rect: TRect);
var Intersection, First, Second: TRect;
begin
  if Active <> True then Exit;
  if Parent = nil then MessageLoop.QueueUpdateRect(Rect)
  else
  begin
    First := Parent.OffsetChildRect(Rect, PositionModeW);
    Second := Parent.OffsetChildRect(GetLocalBounds, PositionModeW);
    if IntersectRects(Intersection, First, Second) then Parent.InvalidateRect(Intersection);
  end;
end;
{ @end $4CAA04 }

{ @routine $4CAAA0 TObjectGI_Invalidate }
procedure TObjectGI.Invalidate;
begin
  if MessageLoop.UpdateRectsEnabled and (Parent <> nil) and (Active = True) then
    InvalidateRect(GetLocalBounds);
end;
{ @end $4CAAA0 }

{ @routine $4CAAE4 TObjectGI_InvalidateChildren }
procedure TObjectGI.InvalidateChildren(IncludePanels: Boolean);
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active then
    begin
      if not IncludePanels and (Child is TPanelGI) then Child.InvalidateChildren(IncludePanels)
      else Child.Invalidate;
    end;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CAAE4 }

{ @routine $4CAB4C TObjectGI_InvalidateScrollOverlap }
function TObjectGI.InvalidateScrollOverlap(Rect: TRect; Delta: TPoint; StartControl: TObjectGI): TObjectGI;
var Child: TObjectGI;
begin
  if Self = StartControl then StartControl := nil;
  if (Self is TPanelGI) and not ScrollUpdate then
  begin
    Child := FirstChild;
    while Child <> nil do
    begin
      if Child.Active then StartControl := Child.InvalidateScrollOverlap(Rect, Delta, StartControl);
      Child := Child.NextSibling;
    end;
  end
  else if (StartControl = nil) and (not PositionModeW or ScrollUpdate) then
  begin
    SetPosition(Classes.Point(LocalPosition.X + Delta.X, LocalPosition.Y + Delta.Y));
    SetPosition(Classes.Point(LocalPosition.X - Delta.X, LocalPosition.Y - Delta.Y));
  end;
  Result := StartControl;
end;
{ @end $4CAB4C }

{ @routine $4CAC4C TObjectGI_Draw }
procedure TObjectGI.Draw(ClipRect: TRect);
var Child: TObjectGI; Intersection: TRect;
begin
  if MessageLoop.PendingRedraw then Exit;
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active and IntersectRects(Intersection, ClipRect, Child.HitTestBounds) then
      Child.Draw(Intersection);
    Child := Child.NextSibling;
  end;
end;
{ @end $4CAC4C }

{ @routine $4CACC0 TObjectGI_DrawUpdateRects }
procedure TObjectGI.DrawUpdateRects(ClipRect: TRect);
var
  RectNode: TRectGR;
  Child: TObjectGI;
  Stage: Integer;
  DrawRect, Intersection: TRect;
begin
  Stage := 0;
  Child := nil;
  try
    if IntersectRects(Intersection, ClipRect, HitTestBounds) then
    begin
      Stage := 1;
      Child := FirstChild;
      while Child <> nil do
      begin
        Stage := 2;
        if Child.Active then Child.DrawUpdateRects(Intersection);
        Child := Child.NextSibling;
      end;
      Stage := 3;
      if SkipOwnQueuedDraw = 0 then
      begin
        Stage := 4;
        RectNode := MessageLoop.UpdateRects.FirstRect;
        while RectNode <> nil do
        begin
          Stage := 5;
          if IntersectRects(DrawRect, RectNode.Bounds, Intersection) then Draw(DrawRect);
          RectNode := RectNode.Next;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      if Child <> nil then
      begin
        AppendLogLineThreadSafe('Error in TObjectGI.DrawEx, label = ' + IntToStr(Stage));
        raise Exception.Create('obj - ' + Child.ControlName + ' ' + Child.ClassName);
      end
      else raise Exception.Create('TObjectGI.DrawEx, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4CACC0 }

{ @routine $4CB010 TObjectGI_CommitFrameDraw }
procedure TObjectGI.CommitFrameDraw;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active then Child.CommitFrameDraw;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CB010 }

{ @routine $4CB050 TObjectGI_ErasePreviousFrame }
procedure TObjectGI.ErasePreviousFrame;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active then Child.ErasePreviousFrame;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CB050 }

{ @routine $4CB090 TObjectGI_NativeHookB0 }
procedure TObjectGI.NativeHookB0;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active then Child.NativeHookB0;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CB090 }

{ @routine $4CB0D0 TObjectGI_PrepareFrameDraw }
procedure TObjectGI.PrepareFrameDraw;
var Child: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    if Child.Active then Child.PrepareFrameDraw;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CB0D0 }

{ @routine $4CB110 TObjectGI_PrepareRegionDraw }
procedure TObjectGI.PrepareRegionDraw(ClipRect: TRect);
begin
end;
{ @end $4CB110 }

{ @routine $4CB12C TObjectGI_NativeHookBC }
procedure TObjectGI.NativeHookBC(Rect: TRect);
begin
end;
{ @end $4CB12C }

{ @routine $4CB148 TObjectGI_LoadFromConfigPath }
procedure TObjectGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Text: WideString; Count: Integer;
begin
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('Pos') > 0 then
  begin
    Text := Block.GetParam('Pos');
    Count := CountDelimitedPartsW(Text, ',');
    if Count >= 2 then
    begin
      LocalPosition.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
      LocalPosition.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    end;
    if Count >= 3 then SetDepthByName(ExtractDelimitedPartW(Text, 2, ','));
    if Count >= 4 then
      if TrimWideString(ExtractDelimitedPartW(Text, 3, ',')) = 'w' then PositionModeW := True;
  end;
  if Block.CountParams('PosZ') > 0 then SetDepthByName(Block.GetParam('PosZ'));
  if Block.CountParams('Size') > 0 then
  begin
    Text := Block.GetParam('Size');
    ClientSize.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    ClientSize.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
  end;
  if Block.CountParams('Sme') > 0 then
  begin
    Text := Block.GetParam('Sme');
    OriginPoint.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    OriginPoint.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
  end;
  if Block.CountParams('Name') > 0 then ControlName := TrimWideString(Block.GetParam('Name'));
  if Block.CountParams('Help') > 0 then HelpText := LookupLocalizedTextByKey(TrimWideString(Block.GetParam('Help')));
  if Block.CountParams('Active') > 0 then
    if TrimWideString(Block.GetParam('Active')) = 'False' then Active := False;
  if Block.CountParams('MouseBlocking') > 0 then MouseBlocking := ParseEnabledNameGI(TrimWideString(Block.GetParam('MouseBlocking')));
  if Block.CountParams('MouseBlockingTest') > 0 then MouseBlockingTest := ParseEnabledNameGI(TrimWideString(Block.GetParam('MouseBlockingTest')));
  if Block.CountParams('MVUpdate') > 0 then SetMouseViewUpdates(ParseEnabledNameGI(TrimWideString(Block.GetParam('MVUpdate'))));
end;
{ @end $4CB148 }

{ @routine $4CB82C TObjectGI_LoadFromBlock }
procedure TObjectGI.LoadFromBlock(Block: TBlockParEC);
var Count: Integer; Text: WideString;

  // @nested $4CB69C LoadConfiguredChildren
  procedure LoadConfiguredChildren(Block: TBlockParEC); // @addr $4CB69C @ida "void __usercall $name(TBlockParEC *Block@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4CB85A 0x4CB788" @note "Nested helper of TObjectGI.LoadFromBlock; creates recognized controls and descends through other blocks."
  var Index, Count: Integer; Child: TObjectGI;
  begin
    Count := Block.GetBlockCount;
    for Index := 0 to Count - 1 do
    begin
      Child := CreateControlByName(Block.GetBlockNameByIndex(Index), Self);
      if Child <> nil then Child.LoadFromBlock(Block.GetBlockByIndex(Index))
      else if (Block.GetBlockNameByIndex(Index) <> 'OnPressCode') and
        (Block.GetBlockNameByIndex(Index) <> 'OnMouseEnterCode') and
        (Block.GetBlockNameByIndex(Index) <> 'OnMouseLeaveCode') then
        LoadConfiguredChildren(Block.GetBlockByIndex(Index));
    end;
  end;

begin
  Clear;
  LoadConfiguredChildren(Block);
  SourceBlock := Block;
  Depth := -1;
  SetDepth(0);
  if Block.CountParams('Style') > 0 then SetConfigPath(Block.GetParam('Style'));
  if Block.CountParams('Pos') > 0 then
  begin
    Text := Block.GetParam('Pos');
    Count := CountDelimitedPartsW(Text, ',');
    if Count >= 2 then
    begin
      LocalPosition.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
      LocalPosition.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    end;
    if Count >= 3 then SetDepthByName(ExtractDelimitedPartW(Text, 2, ','));
    if Count >= 4 then
      if TrimWideString(ExtractDelimitedPartW(Text, 3, ',')) = 'w' then PositionModeW := True;
  end;
  if Block.CountParams('PosZ') > 0 then SetDepthByName(Block.GetParam('PosZ'));
  if Block.CountParams('Size') > 0 then SetSize(GetPointGI(Block.GetParam('Size')));
  if Block.CountParams('Sme') > 0 then SetOrigin(GetPointGI(Block.GetParam('Sme')));
  ControlName := '';
  if Block.CountParams('Name') > 0 then ControlName := TrimWideString(Block.GetParam('Name'));
  if Block.CountParams('Help') > 0 then HelpText := LookupLocalizedTextByKey(TrimWideString(Block.GetParam('Help')));
  Active := True;
  if Block.CountParams('Active') > 0 then
    if TrimWideString(Block.GetParam('Active')) = 'False' then Active := False;
  if Block.CountParams('MouseBlocking') > 0 then MouseBlocking := ParseEnabledNameGI(TrimWideString(Block.GetParam('MouseBlocking')));
  if Block.CountParams('MouseBlockingTest') > 0 then MouseBlockingTest := ParseEnabledNameGI(TrimWideString(Block.GetParam('MouseBlockingTest')));
  if Block.CountParams('ScrollUpdate') > 0 then ScrollUpdate := ParseEnabledNameGI(TrimWideString(Block.GetParam('ScrollUpdate')));
  if Block.CountParams('MVUpdate') > 0 then SetMouseViewUpdates(ParseEnabledNameGI(TrimWideString(Block.GetParam('MVUpdate'))));
  if Block.CountParams('PosAutoCorrection') > 0 then AutoOffsetEnabled := ParseEnabledNameGI(TrimWideString(Block.GetParam('PosAutoCorrection')));
  if Block.CountParams('PosAutoCorrectionXCoef') > 0 then AutoOffsetScale.X := ExtractDecimalToSingleW(TrimWideString(Block.GetParam('PosAutoCorrectionXCoef')));
  if Block.CountParams('PosAutoCorrectionYCoef') > 0 then AutoOffsetScale.Y := ExtractDecimalToSingleW(TrimWideString(Block.GetParam('PosAutoCorrectionYCoef')));
  if Block.CountBlocks('OnKey') > 0 then OnKeyDownCode := Block.GetBlock('OnKey');
  if Block.CountBlocks('OnMouseEnterCode') > 0 then OnMouseEnterCode := Block.GetBlock('OnMouseEnterCode');
  if Block.CountBlocks('OnMouseLeaveCode') > 0 then OnMouseLeaveCode := Block.GetBlock('OnMouseLeaveCode');
  if Block.CountBlocks('OnMouseRightClick') > 0 then OnRightButtonDownCode := Block.GetBlock('OnMouseRightClick');
end;
{ @end $4CB82C }

{ @routine $4CC00C TObjectGI_ReloadFromBlock }
procedure TObjectGI.ReloadFromBlock;
begin
  FreeOwnedChildren;
  LoadFromBlock(SourceBlock);
end;
{ @end $4CC00C }

{ @routine $4CC030 TObjectGI_UpdateAutoGeometry }
procedure TObjectGI.UpdateAutoGeometry;
var Child: TObjectGI;
begin
  if AutoOffsetEnabled then
  begin
    LocalPosition.X := Round(ExtraScreenWidth * AutoOffsetScale.X + LocalPosition.X);
    LocalPosition.Y := Round(ExtraScreenHeight * AutoOffsetScale.Y + LocalPosition.Y);
  end;
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.UpdateAutoGeometry;
    Child := Child.NextSibling;
  end;
end;
{ @end $4CC030 }

{ @routine $4CC0B0 TFormSoundGroup_Create }
constructor TFormSoundGroup.Create;
begin
  inherited Create;
  Sounds := TStringsEC.Create;
end;
{ @end $4CC0B0 }

{ @routine $4CC104 TFormSoundGroup_Destroy }
destructor TFormSoundGroup.Destroy;
begin
  Clear;
  Sounds.Free;
  Sounds := nil;
  inherited Destroy;
end;
{ @end $4CC104 }

{ @routine $4CC150 TFormSoundGroup_Clear }
procedure TFormSoundGroup.Clear;
begin
  Sounds.Clear;
  Section := 0;
end;
{ @end $4CC150 }

{ @routine $4CC170 TFormSoundGroup_LoadFromBlock }
procedure TFormSoundGroup.LoadFromBlock(Block: TBlockParEC);
var Text: WideString; Index, Count: Integer;
begin
  Clear;
  TotalWeight := 0;
  Text := Block.GetParam('NextTime');
  MinDelayMs := StrToInt(ExtractDelimitedPartW(Text, 0, ',-'));
  MaxDelayMs := StrToInt(ExtractDelimitedPartW(Text, 1, ',-'));
  if Block.CountParams('Section') > 0 then Section := StrToInt(Block.GetParam('Section'));
  Count := Block.GetParamCount;
  for Index := 0 to Count - 1 do
  begin
    Text := Block.GetParamName(Index);
    if IsIntegerTextW(Text) then
    begin
      Sounds.Add(Block.GetParamValue(Index));
      Sounds.SetDataAt(Sounds.GetCount - 1, Pointer(ExtractDigitsToIntW(Text)));
      TotalWeight := TotalWeight + ExtractDigitsToIntW(Text);
    end;
  end;
end;
{ @end $4CC170 }

{ @routine $4CC364 TFormSoundGroup_ScheduleNextPlayback }
procedure TFormSoundGroup.ScheduleNextPlayback;
begin
  NextPlayTick := Cardinal(RandomIntRange(MinDelayMs, MaxDelayMs)) + timeGetTime;
end;
{ @end $4CC364 }

{ @routine $4CC390 TFormSoundGroup_PlayIfDue }
procedure TFormSoundGroup.PlayIfDue;
var Weight: Integer;
begin
  if timeGetTime > NextPlayTick then
  begin
    ScheduleNextPlayback;
    Weight := RandomIntRange(0, TotalWeight - 1);
    Sounds.First;
    while not Sounds.IsAtEnd do
    begin
      Weight := Weight - Integer(Sounds.GetCurrentData);
      if Weight < 0 then Break;
      Sounds.Next;
    end;
    SoundManager.PlaySound(Sounds.GetCurrentText);
  end;
end;
{ @end $4CC390 }

{ @routine $4CC44C TMessageLoopGI_Create }
constructor TMessageLoopGI.Create;
begin
  inherited Create;
  UpdateRects := TArrayRectGR.Create;
  MouseViewUpdateControls := TList.Create;
  UpdateRectsEnabled := True;
  SoundGroupList := TList.Create;
  PlayTransitionSounds := True;
  SavedBackgroundControl := nil;
  IsOpen := False;
  DeferredCodeBlocks := TList.Create;
  RefreshMouseAfterCode := False;
end;
{ @end $4CC44C }

{ @routine $4CC50C TMessageLoopGI_Destroy }
destructor TMessageLoopGI.Destroy;
begin
  ResetRuntime;
  UpdateRects.Free;
  MouseViewUpdateControls.Free;
  SoundGroupList.Free;
  SoundGroupList := nil;
  DeferredCodeBlocks.Free;
  DeferredCodeBlocks := nil;
  inherited Destroy;
end;
{ @end $4CC50C }

{ @routine $4CC590 TMessageLoopGI_ResetRuntime }
procedure TMessageLoopGI.ResetRuntime;
var Index: Integer; Item: TObject;
begin
  FreeSecondaryPixelBuffer;
  FreeSavedLines;
  if SoundGroupList <> nil then
  begin
    for Index := 0 to SoundGroupList.Count - 1 do
    begin
      Item := SoundGroupList[Index];
      Item.Free;
    end;
    SoundGroupList.Clear;
  end;
  if RootUiObject <> nil then
  begin
    RootUiObject.Free;
    RootUiObject := nil;
  end;
  CursorControl := nil;
  FocusedControl := nil;
  HoveredControl := nil;
  while FirstTimer <> nil do CancelCallbackTimer(LastTimer);
end;
{ @end $4CC590 }

{ @routine $4CC654 TMessageLoopGI_QueueUpdateRect }
procedure TMessageLoopGI.QueueUpdateRect(Rect: TRect);
var Intersection: TRect;
begin
  if UpdateRectsEnabled then
    if IntersectRects(Intersection, Rect, GameScreenRect) then UpdateRects.AddRect(Intersection);
end;
{ @end $4CC654 }

{ @routine $4CC69C TMessageLoopGI_InvalidateViewport }
procedure TMessageLoopGI.InvalidateViewport;
begin
  QueueUpdateRect(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $4CC69C }

{ @routine $4CC6D4 TMessageLoopGI_FindMouseViewUpdateControl }
function TMessageLoopGI.FindMouseViewUpdateControl(Control: TObjectGI): Integer;
var Index, Count: Integer;
begin
  Count := MouseViewUpdateControls.Count;
  for Index := 0 to Count - 1 do
    if MouseViewUpdateControls[Index] = Control then
    begin
      Result := Index;
      Exit;
    end;
  Result := -1;
end;
{ @end $4CC6D4 }

{ @routine $4CC730 TMessageLoopGI_AddMouseViewUpdateControl }
procedure TMessageLoopGI.AddMouseViewUpdateControl(Control: TObjectGI);
begin
  if FindMouseViewUpdateControl(Control) < 0 then MouseViewUpdateControls.Add(Control);
end;
{ @end $4CC730 }

{ @routine $4CC760 TMessageLoopGI_RemoveMouseViewUpdateControl }
procedure TMessageLoopGI.RemoveMouseViewUpdateControl(Control: TObjectGI);
var Index: Integer;
begin
  Index := FindMouseViewUpdateControl(Control);
  if Index >= 0 then MouseViewUpdateControls.Delete(Index);
end;
{ @end $4CC760 }

{ @routine $4CC794 TMessageLoopGI_InvalidateMouseViewControls }
procedure TMessageLoopGI.InvalidateMouseViewControls;
var Count, Index: Integer; Control: TObjectGI;
begin
  Count := MouseViewUpdateControls.Count;
  for Index := 0 to Count - 1 do
  begin
    Control := MouseViewUpdateControls[Index];
    Control.Invalidate;
  end;
end;
{ @end $4CC794 }

{ @routine $4CC7E4 TMessageLoopGI_DrawQueuedUpdateRects }
procedure TMessageLoopGI.DrawQueuedUpdateRects;
var RectNode: TRectGR;
begin
  if RegionDrawPending and (RegionDrawControl <> nil) then
    RegionDrawControl.PrepareRegionDraw(RegionDrawControl.HitTestBounds);
  PendingRedraw := False;
  RectNode := UpdateRects.FirstRect;
  while RectNode <> nil do
  begin
    RootUiObject.Draw(RectNode.Bounds);
    RectNode := RectNode.Next;
  end;
end;
{ @end $4CC7E4 }

{ @routine $4CC85C TMessageLoopGI_DrawQueuedControlRects }
procedure TMessageLoopGI.DrawQueuedControlRects;
begin
  if UpdateRects.FirstRect <> nil then
  begin
    PendingRedraw := True;
    RootUiObject.DrawUpdateRects(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
  end;
end;
{ @end $4CC85C }

{ @routine $4CC8B0 TMessageLoopGI_FinishQueuedDraw }
procedure TMessageLoopGI.FinishQueuedDraw;
begin
  RegionDrawPending := False;
end;
{ @end $4CC8B0 }

{ @routine $4CC8C4 TMessageLoopGI_CommitFrameDraw }
procedure TMessageLoopGI.CommitFrameDraw;
begin
  RootUiObject.CommitFrameDraw;
end;
{ @end $4CC8C4 }

{ @routine $4CC8DC TMessageLoopGI_ErasePreviousFrame }
procedure TMessageLoopGI.ErasePreviousFrame;
begin
  RootUiObject.ErasePreviousFrame;
end;
{ @end $4CC8DC }

{ @routine $4CC8F4 TMessageLoopGI_PrepareFrameDraw }
procedure TMessageLoopGI.PrepareFrameDraw;
begin
  RootUiObject.PrepareFrameDraw;
end;
{ @end $4CC8F4 }

{ @routine $4CC90C TMessageLoopGI_Run }
function TMessageLoopGI.Run: Integer;
var
  LastCaretTick, Tick: Cardinal;
  Point: TPoint;
  Index: Integer;
  RecordingTime: Cardinal;
  Stage: Integer;
  Background: TGraphBufGI;
begin
  Stage := 0;
  try
    PushMessageLoop(Self);
    ExitCode := 0;
    ContinuousLoop := False;
    Stage := 1;
    FreeSecondaryPixelBuffer;
    FreeSavedLines;
    FreeSavedPixels16;
    Stage := 2;
    SetCursorByName('Main');
    Stage := 3;
    GetCursorPos(Point);
    if Direct3DPresentParameters.Windowed then ScreenToClient(MainWindowHandle, Point);
    CursorControl.SetPosition(Point);
    if CustomCursorEnabled then SetCursorActive(True);
    TimerTick := timeGetTime;
    Stage := 4;
    OnOpen;
    Stage := 5;
    RootUiObject.UpdateAbsolutePosition;
    RootUiObject.UpdateSubtreeHitBounds;
    QueueUpdateRect(ViewportRect);
    LastCaretTick := 0;
    CaretBlinkOn := False;
    Stage := 6;
    RootUiObject.OnActivate;
    if (ViewportRect.Right - ViewportRect.Left < GameScreenWidth) or
      (ViewportRect.Bottom - ViewportRect.Top < GameScreenHeight) then
    begin
      Stage := 7;
      if SavedBackgroundControl = nil then
        SavedBackgroundControl := TGraphBufGI.Create(BackgroundPanel, HardwareRenderingEnabled);
      Stage := 8;
      Background := SavedBackgroundControl as TGraphBufGI;
      Background.SetDepth(1E30);
      Background.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      Background.AllocateBuffer(GameScreenWidth, GameScreenHeight, False);
      Background.CopyScreenRectToBuffer(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight),
        Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
    end;
    Stage := 9;
    for Index := 0 to SoundGroupList.Count - 1 do
      TFormSoundGroup(SoundGroupList[Index]).ScheduleNextPlayback;
    if PlayTransitionSounds and (OpenSoundName <> '') then SoundManager.PlaySound(OpenSoundName);
    Stage := 10;
    while (GR_WinMessage(ProcessWindowMessage) <> 0) and (ExitCode = 0) do
    begin
      Stage := 11;
      Tick := timeGetTime;
      if Tick - LastCaretTick > 200 then
      begin
        Stage := 12;
        LastCaretTick := Tick;
        if CaretBlinkOn = True then CaretBlinkOn := False else CaretBlinkOn := True;
        if FocusedControl <> nil then FocusedControl.OnCaretBlink;
      end;
      if not MemorySnapshotActive then
      begin
        Stage := 13;
        if OffscreenTexture <> nil then
        begin
          Stage := 14;
          DrawOffscreenTexture;
        end
        else
        begin
          Stage := 15;
          if PopupController = nil then DrawQueuedUpdateRects
          else
          begin
            RootUiObject.AttachOwnedChild(PopupController);
            DrawQueuedUpdateRects;
            RootUiObject.UnlinkOwnedChild(PopupController);
          end;
        end;
        if not BeginFramePresentation then
        begin
          RequestedScreenId := screenNone;
          PostLoadScreenId := FormToId(Self);
          Break;
        end;
        Stage := 16;
        FinishQueuedDraw;
        Stage := 17;
        EndFramePresentation;
        if RecordingFrames then
        begin
          Stage := 18;
          RecordingTime := timeGetTime;
          CaptureRecordingFrame;
          RecordingTime := timeGetTime - RecordingTime;
          Inc(TimerTick, RecordingTime);
          NextTimerToProcess := FirstTimer;
          while NextTimerToProcess <> nil do
          begin
            Inc(NextTimerToProcess.DueTick, RecordingTime);
            NextTimerToProcess := NextTimerToProcess.Next;
          end;
        end;
        Stage := 19;
        if MusicEnabled and not MusicManager.HasSelectedMusic then
        begin
          Stage := 20;
          MusicManager.HasSelectedMusic;
          SelectMusic;
        end;
        Stage := 21;
        ProcessCallbackTimers;
        if PopupController <> nil then PopupController.AdvancePopups(TimerTick);
        Stage := 22;
        for Index := 0 to SoundGroupList.Count - 1 do
          if (TFormSoundGroup(SoundGroupList[Index]).Section = 0) or
            (TFormSoundGroup(SoundGroupList[Index]).Section = SoundSection) then
            TFormSoundGroup(SoundGroupList[Index]).PlayIfDue;
      end;
    end;
    Stage := 23;
    try
      RootUiObject.OnMouseLeave;
      RefreshMouseAfterCode := False;
      for Index := 0 to DeferredCodeBlocks.Count - 1 do ExecuteUiCode(TBlockParEC(DeferredCodeBlocks[Index]), 0);
      DeferredCodeBlocks.Clear;
    except
      on E: EBreakMessageGI do;
    end;
    RootUiObject.OnDeactivate;
    if CustomCursorEnabled then SetCursorActive(False);
    Stage := 24;
    if PlayTransitionSounds and (CloseSoundName <> '') then SoundManager.PlaySound(CloseSoundName);
    Stage := 25;
    ClearTransientControl;
    Stage := 26;
    OnClose;
    Stage := 27;
    FreeSavedPixels16;
    FreeSecondaryPixelBuffer;
    FreeSavedLines;
    Result := ExitCode;
    Stage := 28;
    PopMessageLoop(Self);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TMessageLoopGI.Run, ' + RegisteredLoopName + ', label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4CC90C }

{ @routine $4CD164 TMessageLoopGI_RunContinuous }
function TMessageLoopGI.RunContinuous: Integer;
var
  Point: TPoint;
  FrameTime, ProcessingTime: Cardinal;
  CarryTicks: Cardinal;
  LastFpsTick: Cardinal;
  FrameCount: Integer;
  RecordingTime: Cardinal;
  Index, Stage: Integer;
begin
  Stage := 0;
  try
    PushMessageLoop(Self);
    ExitCode := 0;
    ContinuousLoop := True;
    Stage := 1;
    FreeSecondaryPixelBuffer;
    Stage := 2;
    FreeSavedPixels16;
    Stage := 3;
    FreeSavedLines;
    Stage := 4;
    SetCursorByName('Main');
    GetCursorPos(Point);
    if Direct3DPresentParameters.Windowed then ScreenToClient(MainWindowHandle, Point);
    Stage := 5;
    CursorControl.SetPosition(Point);
    if CustomCursorEnabled then SetCursorActive(True);
    TimerTick := timeGetTime;
    Stage := 6;
    OnOpen;
    Stage := 7;
    RootUiObject.UpdateAbsolutePosition;
    Stage := 8;
    RootUiObject.UpdateSubtreeHitBounds;
    Stage := 9;
    QueueUpdateRect(ViewportRect);
    Stage := 10;
    CaretBlinkOn := False;
    RootUiObject.OnActivate;
    Stage := 11;
    if ExitCode = 0 then DrawFrame;
    LastFpsTick := timeGetTime;
    FrameCount := 0;
    CarryTicks := 0;
    Stage := 12;
    for Index := 0 to SoundGroupList.Count - 1 do
      TFormSoundGroup(SoundGroupList[Index]).ScheduleNextPlayback;
    if PlayTransitionSounds and (OpenSoundName <> '') then SoundManager.PlaySound(OpenSoundName);
    while (GR_WinMessage(ProcessWindowMessage) <> 0) and (ExitCode = 0) do
    begin
      Stage := 13;
      if not MemorySnapshotActive then
      begin
        Stage := 14;
        FrameTime := timeGetTime;
        if PopupController = nil then
        begin
          Stage := 15;
          DrawFrame;
        end
        else
        begin
          Stage := 16;
          RootUiObject.AttachOwnedChild(PopupController);
          Stage := 17;
          DrawFrame;
          Stage := 18;
          RootUiObject.UnlinkOwnedChild(PopupController);
        end;
        Stage := 19;
        SysUtils.Sleep(1);
        FrameTime := timeGetTime - FrameTime;
        if FrameTime > 200 then FrameTime := 200;
        Stage := 20;
        if RecordingFrames then
        begin
          Stage := 21;
          RecordingTime := timeGetTime;
          CaptureRecordingFrame;
          RecordingTime := timeGetTime - RecordingTime;
          Inc(LastFpsTick, RecordingTime);
        end;
        ProcessingTime := timeGetTime;
        Inc(FrameCount);
        if timeGetTime - LastFpsTick > 500 then
        begin
          Stage := 22;
          FramesPerSecond := FrameCount * 2;
          LastFpsTick := timeGetTime;
          FrameCount := 0;
          if ShowFrameRate then (GetByName('FPS') as TLabelGI).SetText('FPS: ' + IntToStr(FramesPerSecond));
        end;
        for Index := 0 to FrameTime + CarryTicks - 1 do
        begin
          Stage := 23;
          AdvanceTimerTick;
          if PopupController <> nil then PopupController.AdvancePopups(TimerTick);
        end;
        Stage := 24;
        for Index := 0 to SoundGroupList.Count - 1 do
          if (TFormSoundGroup(SoundGroupList[Index]).Section = 0) or
            (TFormSoundGroup(SoundGroupList[Index]).Section = SoundSection) then
            TFormSoundGroup(SoundGroupList[Index]).PlayIfDue;
        if MusicEnabled and not MusicManager.HasSelectedMusic then
        begin
          Stage := 25;
          MusicManager.HasSelectedMusic;
          SelectMusic;
        end;
        ProcessingTime := timeGetTime - ProcessingTime;
        CarryTicks := ProcessingTime;
        if CarryTicks > 200 then CarryTicks := 0;
        Stage := 26;
      end;
    end;
    Stage := 27;
    try
      RootUiObject.OnMouseLeave;
      RefreshMouseAfterCode := False;
      for Index := 0 to DeferredCodeBlocks.Count - 1 do ExecuteUiCode(TBlockParEC(DeferredCodeBlocks[Index]), 0);
      DeferredCodeBlocks.Clear;
    except
      on E: EBreakMessageGI do;
    end;
    RootUiObject.OnDeactivate;
    if CustomCursorEnabled then SetCursorActive(False);
    Stage := 28;
    if PlayTransitionSounds and (CloseSoundName <> '') then SoundManager.PlaySound(CloseSoundName);
    Stage := 29;
    ClearTransientControl;
    Stage := 30;
    OnClose;
    Stage := 31;
    FreeSavedPixels16;
    Stage := 32;
    FreeSecondaryPixelBuffer;
    Stage := 33;
    FreeSavedLines;
    Result := ExitCode;
    Stage := 34;
    PopMessageLoop(Self);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TMessageLoopGI.Run2, ' + RegisteredLoopName + ', label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4CD164 }

{ @routine $4CD960 TMessageLoopGI_AdvanceTimerTick }
procedure TMessageLoopGI.AdvanceTimerTick;
var Timer: PCallbackTimerGI; Stage: Integer;
begin
  Stage := 0;
  try
    Inc(TimerTick);
    Stage := 1;
    NextTimerToProcess := FirstTimer;
    while NextTimerToProcess <> nil do
    begin
      Stage := 2;
      if NextTimerToProcess.DueTick > TimerTick then Break;
      Stage := 3;
      Timer := NextTimerToProcess;
      NextTimerToProcess := NextTimerToProcess.Next;
      Timer.DueTick := TimerTick + Cardinal(Timer.RepeatMs);
      Stage := 4;
      ReinsertCallbackTimer(Timer);
      Stage := 5;
      Timer.Callback(Timer, Timer.UserData);
      Stage := 6;
    end;
    NextTimerToProcess := nil;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TMessageLoopGI.Takt2, ' + RegisteredLoopName + ', label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4CD960 }

{ @routine $4CDC00 TMessageLoopGI_DrawFrame }
procedure TMessageLoopGI.DrawFrame;
begin
  if UpdateRects.FirstRect <> nil then
  begin
    DrawQueuedUpdateRects;
    FinishQueuedDraw;
  end;
end;
{ @end $4CDC00 }

{ @routine $4CDC28 TMessageLoopGI_Present }
procedure TMessageLoopGI.Present;
begin
  UnknownPresentState := 0;
  if ContinuousLoop then
  begin
    FullFrameRedrawRequested := True;
    DrawFrame;
  end
  else
  begin
    DrawQueuedUpdateRects;
    if not BeginFramePresentation then
    begin
      RequestedScreenId := screenNone;
      PostLoadScreenId := FormToId(Self);
      Exit;
    end;
    FinishQueuedDraw;
    EndFramePresentation;
  end;
end;
{ @end $4CDC28 }

{ @routine $4CDD08 TMessageLoopGI_ProcessWindowMessage }
procedure TMessageLoopGI.ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer);
var
  Point: TPoint;
  MoveStep: Integer;
  BreakAfterDoubleClick: Boolean;
  Stage, Index: Integer;
  NewOffset: TPoint;
  // Native reserves twelve unreferenced bytes at EBP-$4C..EBP-$41.
  // DCC32 O- allocates unused locals after live ones; original types are unknown.
  UnusedLocals: array[0..11] of Byte;

  // @nested $4CDC94 ConvertMousePointToViewport
  procedure ConvertMousePointToViewport; // @addr $4CDC94 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4CDEFE 0x4CE062 0x4CE0AC 0x4CE10B 0x4CE18F 0x4CE313 0x4CE376 0x4CE439" @note "Nested ProcessWindowMessage helper; scales or offsets its captured mouse point."
  begin
    if AlternateViewportEnabled then
      if ScaleViewportToWindow then
      begin
        Point.X := Point.X * GameScreenWidth div PresentationWidth;
        Point.Y := Point.Y * GameScreenHeight div PresentationHeight;
      end
      else
      begin
        Dec(Point.X, ViewportOffset.X);
        Dec(Point.Y, ViewportOffset.Y);
      end;
  end;

begin
  if MemorySnapshotActive then Exit;
  if ExitCode <> 0 then Exit;
  Stage := 0;
  try
    if Message = WM_MOUSEMOVE then
    begin
      Point.X := SmallInt(LParam);
      Point.Y := SmallInt(LParam shr 16);
      LastMousePosition.X := Point.X;
      LastMousePosition.Y := Point.Y;
      if IgnoreWarpMouseMove then
      begin
        IgnoreWarpMouseMove := False;
        Exit;
      end;
      if not ScaleViewportToWindow then
      begin
        Stage := 1;
        NewOffset.X := ViewportOffset.X + ((PresentationWidth shr 1) - Point.X);
        NewOffset.Y := ViewportOffset.Y + ((PresentationHeight shr 1) - Point.Y);
        if NewOffset.X > 0 then NewOffset.X := 0;
        if NewOffset.Y > 0 then NewOffset.Y := 0;
        if GameScreenWidth + NewOffset.X < PresentationWidth then NewOffset.X := -(GameScreenWidth - PresentationWidth);
        if GameScreenHeight + NewOffset.Y < PresentationHeight then NewOffset.Y := -(GameScreenHeight - PresentationHeight);
        if ViewportOffset.X <> NewOffset.X then Point.X := PresentationWidth shr 1;
        if ViewportOffset.Y <> NewOffset.Y then Point.Y := PresentationHeight shr 1;
        Stage := 2;
        if (ViewportOffset.X <> NewOffset.X) or (ViewportOffset.Y <> NewOffset.Y) then
        begin
          IgnoreWarpMouseMove := True;
          ClientToScreen(MainWindowHandle, Point);
          SetCursorPos(Point.X, Point.Y);
          ScreenToClient(MainWindowHandle, Point);
        end;
        ViewportOffset := NewOffset;
      end;
      Stage := 3;
      ConvertMousePointToViewport;
      if CursorControl.Active = True then (CursorControl as TCursorGI).SetPosition(Point);
      Stage := 4;
      if FocusedControl <> nil then FocusedControl.ProcessMouseMove(WParam, Point);
      Stage := 5;
      if RootUiObject.ContainsPoint(Point) then
      begin
        if not RootUiObject.MouseInside then
        begin
          Stage := 6;
          RootUiObject.OnMouseEnter;
        end;
        RootUiObject.ProcessMouseMove(WParam, Point);
      end
      else if RootUiObject.MouseInside = True then
      begin
        Stage := 7;
        RootUiObject.OnMouseLeave;
      end;
    end
    else if Message = WM_MOUSELEAVE then
    begin
      Stage := 8;
      GetCursorPos(Point);
      ScreenToClient(MainWindowHandle, Point);
      Stage := 9;
      ProcessWindowMessage(WM_MOUSEMOVE, 0, Word(Point.X) or (Word(Point.Y) shl 16));
      Stage := 10;
      LastMouseMessageTick := timeGetTime;
    end
    else if Message = WM_MOUSEWHEEL then
    begin
      Stage := 11;
      Point := Classes.Point(SmallInt(LParam), SmallInt(LParam shr 16));
      ScreenToClient(MainWindowHandle, Point);
      ConvertMousePointToViewport;
      ProcessMouseWheel(Word(WParam), Point, SmallInt(WParam shr 16));
    end
    else if Message = WM_LBUTTONDOWN then
    begin
      Stage := 12;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 13;
        RootUiObject.ProcessLeftButtonDown(WParam, Point);
      end;
    end
    else if Message = WM_LBUTTONUP then
    begin
      Stage := 14;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if FocusedControl <> nil then
      begin
        Stage := 15;
        FocusedControl.ProcessLeftButtonUp(WParam, Point);
      end;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 16;
        RootUiObject.ProcessLeftButtonUp(WParam, Point);
      end;
    end
    else if Message = WM_RBUTTONDOWN then
    begin
      Stage := 17;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 18;
        RootUiObject.ProcessRightButtonDown(WParam, Point);
      end;
      if StatusLabel.Active then
      begin
        Stage := 19;
        if (DebugControl = nil) or (DebugControl.Parent = ContentPanel) or not DebugControl.ContainsPoint(Point) then
          DebugControl := ContentPanel.FindDeepestChildAtPoint(Point)
        else DebugControl := DebugControl.Parent;
        Stage := 20;
        (StatusLabel as TLabelGI).SetText(DebugControl.ControlName + ' (' + DebugControl.ClassName + ') Pos=' +
          IntToStr(DebugControl.LocalPosition.X) + ',' + IntToStr(DebugControl.LocalPosition.Y));
      end;
    end
    else if Message = WM_RBUTTONUP then
    begin
      Stage := 21;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 22;
        RootUiObject.ProcessRightButtonUp(WParam, Point);
      end;
    end
    else if Message = WM_LBUTTONDBLCLK then
    begin
      Stage := 23;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 24;
        BreakAfterDoubleClick := True;
        try
          RootUiObject.ProcessLeftButtonDown(WParam, Point);
        except
          on E: EBreakMessageGI do BreakAfterDoubleClick := True;
        end;
        Stage := 25;
        RootUiObject.ProcessLeftButtonDoubleClick(WParam, Point);
        if BreakAfterDoubleClick then BreakUiMessage;
      end;
    end
    else if Message = WM_RBUTTONDBLCLK then
    begin
      Stage := 26;
      Point := Classes.Point(Word(LParam), Word(LParam shr 16));
      ConvertMousePointToViewport;
      if RootUiObject.ContainsPoint(Point) then
      begin
        Stage := 27;
        BreakAfterDoubleClick := True;
        try
          RootUiObject.ProcessRightButtonDown(WParam, Point);
        except
          on E: EBreakMessageGI do BreakAfterDoubleClick := True;
        end;
        Stage := 28;
        RootUiObject.ProcessRightButtonDoubleClick(WParam, Point);
        if BreakAfterDoubleClick then BreakUiMessage;
      end;
    end
    else if Message = WM_CHAR then
    begin
      Stage := 29;
      if (WParam >= Ord(' ')) and (FocusedControl <> nil) then
      begin
        Stage := 30;
        FocusedControl.ProcessCharacter(WideChar(WParam));
      end;
    end
    else if (Message = WM_KEYDOWN) or ((Message = WM_SYSKEYDOWN) and
      (WParam in [VK_MENU, VK_LEFT..VK_DOWN, VK_F5])) then
    begin
      Stage := 31;
      RootUiObject.BroadcastKeyDown(WParam);
      if FocusedControl <> nil then
      begin
        Stage := 32;
        FocusedControl.ProcessKeyDown(WParam);
      end;
      Stage := 33;
      if IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) and Assigned(DebugKeyCallback) then
        DebugKeyCallback(Word(WParam));
      Stage := 34;
      if WParam = VK_F9 then CaptureScreenshot;
      Stage := 35;
      if (WParam = Ord('M')) and IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and IsVirtualKeyDown(VK_MENU) then
        StatusLabel.SetActive(not StatusLabel.Active);
      Stage := 36;
      if StatusLabel.Active and (DebugControl <> nil) then
      begin
        Stage := 37;
        if GetAsyncKeyState(VK_CONTROL) and $8000 = $8000 then MoveStep := 10 else MoveStep := 1;
        Stage := 38;
        if WParam = VK_UP then DebugControl.SetPosition(Classes.Point(DebugControl.LocalPosition.X, DebugControl.LocalPosition.Y - MoveStep))
        else if WParam = VK_DOWN then DebugControl.SetPosition(Classes.Point(DebugControl.LocalPosition.X, DebugControl.LocalPosition.Y + MoveStep))
        else if WParam = VK_LEFT then DebugControl.SetPosition(Classes.Point(DebugControl.LocalPosition.X - MoveStep, DebugControl.LocalPosition.Y))
        else if WParam = VK_RIGHT then DebugControl.SetPosition(Classes.Point(DebugControl.LocalPosition.X + MoveStep, DebugControl.LocalPosition.Y));
        Stage := 39;
        (StatusLabel as TLabelGI).SetText(DebugControl.ControlName + ' (' + DebugControl.ClassName + ') Pos=' +
          IntToStr(DebugControl.LocalPosition.X) + ',' + IntToStr(DebugControl.LocalPosition.Y));
      end
      else if StatusLabel.Active and (DebugControl = nil) then
      begin
        Stage := 40;
        (StatusLabel as TLabelGI).SetText('Not object');
      end;
    end
    else if (Message = WM_KEYUP) or ((Message = WM_SYSKEYUP) and
      (WParam in [VK_MENU, VK_LEFT..VK_DOWN])) then
    begin
      Stage := 41;
      RootUiObject.BroadcastKeyUp(WParam);
    end
    else if Message = WM_PAINT then
    begin
      Stage := 42;
      InvalidateViewport;
    end;
    Stage := 43;
    for Index := 0 to DeferredCodeBlocks.Count - 1 do ExecuteUiCode(TBlockParEC(DeferredCodeBlocks[Index]), 0);
    if RefreshMouseAfterCode then
    begin
      Point.X := LastMousePosition.X;
      Point.Y := LastMousePosition.Y;
      RootUiObject.ProcessMouseMove(0, Point);
    end;
    RefreshMouseAfterCode := False;
    DeferredCodeBlocks.Clear;
  except
    on E: EBreakMessageGI do;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      if Stage in [31, 32] then AppendLogLineThreadSafe('key=' + IntToWideString(WParam));
      raise Exception.Create('Error in procedure TMessageLoopGI.SysMessage, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4CDD08 }

{ @routine $4CED18 TMessageLoopGI_CaptureScreenshot }
procedure TMessageLoopGI.CaptureScreenshot;
var
  Digits: AnsiString;
  DigitCount: Integer;
  Extension, BaseName, FileName: AnsiString;
  Buffer: TGraphBufGR;

  // @nested $4CEBA4 FindFreeScreenshotName
  function FindFreeScreenshotName: Boolean; // @addr $4CEBA4 @ida "bool __usercall $name@<al>(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4CEDD0" @note "Nested CaptureScreenshot helper; updates the captured filename strings."
  var Index: Integer;
  begin
    Result := False;
    Index := 0;
    while Index < 1000 do
    begin
      Digits := IntToStr(Index);
      while Length(Digits) < DigitCount do Digits := '0' + Digits;
      BaseName := 'Shot' + Digits + Extension;
      FileName := GetGameUserDirectory + 'Screenshots' + '\' + BaseName;
      if not SysUtils.FileExists(FileName) then Break;
      Inc(Index);
    end;
    if Index < 1000 then Result := True;
  end;

begin
  CreateDir(GetGameUserDirectory + 'Screenshots');
  DigitCount := Length(IntToStr(999));
  case ScreenshotFormat of
    0: Extension := '.bmp';
    1: Extension := '.png';
    2: Extension := '.jpg';
  end;
  if FindFreeScreenshotName then
  begin
    DrawQueuedUpdateRects;
    Buffer := TGraphBufGR.Create(False);
    try
      if HardwareRenderingEnabled then Buffer.LoadFromScreen(0)
      else
      begin
        Buffer.AllocateRgbaTight(GameScreenWidth, GameScreenHeight);
        Ex_OKGF_Convert565toBGRA(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
          Buffer.GetPixels, Buffer.PitchBytes, Buffer.Width, Buffer.Height);
      end;
      case ScreenshotFormat of
        0: Buffer.SaveBmp(FileName);
        1: Buffer.SavePng(FileName);
        2: Buffer.SaveJpeg(FileName, ScreenshotJpegQuality);
      end;
    finally
      Buffer.Free;
    end;
  end;
end;
{ @end $4CED18 }

{ @routine $4CEF8C TMessageLoopGI_RequestClose }
procedure TMessageLoopGI.RequestClose(ResultCode: Integer);
begin
  ExitCode := ResultCode;
end;
{ @end $4CEF8C }

{ @routine $4CEFA8 TMessageLoopGI_SetHelpCallback }
procedure TMessageLoopGI.SetHelpCallback(Callback: TObjectHelpEventGI);
begin
  ContentPanel.SetHelpCallbackRecursive(Callback);
end;
{ @end $4CEFA8 }

{ @routine $4CEFC8 TMessageLoopGI_GetByName }
function TMessageLoopGI.GetByName(const Name: WideString): TObjectGI;
begin
  Result := ContentPanel.FindByNameRecursive(Name);
  if Result = nil then raise Exception.Create('TMessageLoopGI.GetByName. Name=' + Name);
end;
{ @end $4CEFC8 }

{ @routine $4CF0A0 TMessageLoopGI_FindControlByPath }
function TMessageLoopGI.FindControlByPath(const Path: WideString): TObjectGI;
var Index, Count: Integer;
begin
  Count := CountDelimitedPartsW(Path, ':');
  if Count <= 1 then Result := ContentPanel.FindByNameRecursive(Path)
  else
  begin
    Result := ContentPanel;
    for Index := 0 to Count - 1 do
    begin
      Result := Result.FindByNameRecursive(ExtractDelimitedPartW(Path, Index, ':'));
      if Result = nil then Break;
    end;
  end;
end;
{ @end $4CF0A0 }

{ @routine $4CF160 TMessageLoopGI_SetFocusedControl }
procedure TMessageLoopGI.SetFocusedControl(Control: TObjectGI);
begin
  if FocusedControl = Control then Exit;
  if FocusedControl <> nil then FocusedControl.OnFocusLost;
  FocusedControl := Control;
  if FocusedControl <> nil then FocusedControl.OnFocusGained;
end;
{ @end $4CF160 }

{ @routine $4CF1B0 TMessageLoopGI_SetHoveredControl }
procedure TMessageLoopGI.SetHoveredControl(Control: TObjectGI);
var Previous: TObjectGI;
begin
  if HoveredControl = Control then Exit;
  if HoveredControl <> nil then
  begin
    Previous := HoveredControl;
    HoveredControl := nil;
    Previous.OnHoverLost;
  end;
  HoveredControl := Control;
  if HoveredControl <> nil then HoveredControl.OnHoverGained;
end;
{ @end $4CF1B0 }

{ @routine $4CF20C TMessageLoopGI_ProcessNamedControlEvent }
procedure TMessageLoopGI.ProcessNamedControlEvent(ControlName: WideString; EventKind, Param1, Param2: Integer);
begin
end;
{ @end $4CF20C }

{ @routine $4CF254 TMessageLoopGI_OnOpen }
procedure TMessageLoopGI.OnOpen;
begin
  IsOpen := True;
end;
{ @end $4CF254 }

{ @routine $4CF268 TMessageLoopGI_OnClose }
procedure TMessageLoopGI.OnClose;
begin
  IsOpen := False;
end;
{ @end $4CF268 }

{ @routine $4CF27C TMessageLoopGI_ProcessCallbackTimers }
procedure TMessageLoopGI.ProcessCallbackTimers;
var
  NowTick: Cardinal;
  Timer: PCallbackTimerGI;
  WaitMs: Integer;
  Handle: THandle;
begin
  NowTick := timeGetTime;
  if FirstTimer <> nil then
  begin
    WaitMs := Integer(FirstTimer.DueTick - NowTick);
    if WaitMs > 0 then
    begin
      Handle := 0;
      MsgWaitForMultipleObjects(0, Handle, False, WaitMs, $1FF);
      NowTick := timeGetTime;
    end;
  end;
  NextTimerToProcess := FirstTimer;
  while NextTimerToProcess <> nil do
  begin
    if NextTimerToProcess.DueTick > NowTick then Break;
    Timer := NextTimerToProcess;
    NextTimerToProcess := NextTimerToProcess.Next;
    Timer.DueTick := NowTick + Cardinal(Timer.RepeatMs);
    ReinsertCallbackTimer(Timer);
    Timer.Callback(Timer, Timer.UserData);
  end;
  NextTimerToProcess := nil;
  TimerTick := NowTick;
end;
{ @end $4CF27C }

{ @routine $4CF350 TMessageLoopGI_SelectMusic }
procedure TMessageLoopGI.SelectMusic;
begin
end;
{ @end $4CF350 }

{ @routine $4CF35C TMessageLoopGI_ScheduleCallbackTimer }
function TMessageLoopGI.ScheduleCallbackTimer(DelayMs, RepeatMs: Integer; Callback: TCallbackTimerEventGI; UserData: Integer): PCallbackTimerGI;
var Timer: PCallbackTimerGI;
begin
  Timer := AllocEC(SizeOf(TCallbackTimerGI));
  if LastTimer <> nil then LastTimer.Next := Timer;
  Timer.Prev := LastTimer;
  Timer.Next := nil;
  LastTimer := Timer;
  if FirstTimer = nil then FirstTimer := Timer;
  Timer.DueTick := TimerTick + Cardinal(DelayMs);
  Timer.RepeatMs := RepeatMs;
  Timer.UserData := UserData;
  Timer.Callback := Callback;
  ReinsertCallbackTimer(Timer);
  Result := Timer;
end;
{ @end $4CF35C }

{ @routine $4CF408 TMessageLoopGI_CancelCallbackTimer }
procedure TMessageLoopGI.CancelCallbackTimer(Timer: PCallbackTimerGI);
var Current: PCallbackTimerGI;
begin
  Current := Timer;
  if NextTimerToProcess = Current then NextTimerToProcess := NextTimerToProcess.Next;
  if Current.Prev <> nil then Current.Prev.Next := Current.Next;
  if Current.Next <> nil then Current.Next.Prev := Current.Prev;
  if LastTimer = Current then LastTimer := Current.Prev;
  if FirstTimer = Current then FirstTimer := Current.Next;
  FreeEC(Current);
end;
{ @end $4CF408 }

{ @routine $4CF4A0 TMessageLoopGI_UpdateCallbackTimer }
procedure TMessageLoopGI.UpdateCallbackTimer(Timer: PCallbackTimerGI; DelayMs, RepeatMs: Integer);
var Current: PCallbackTimerGI;
begin
  Current := Timer;
  if (TimerTick + Cardinal(DelayMs) = Current.DueTick) and (Current.RepeatMs = RepeatMs) then Exit;
  Current.DueTick := TimerTick + Cardinal(DelayMs);
  Current.RepeatMs := RepeatMs;
  ReinsertCallbackTimer(Current);
end;
{ @end $4CF4A0 }

{ @routine $4CF4FC TMessageLoopGI_ReinsertCallbackTimer }
procedure TMessageLoopGI.ReinsertCallbackTimer(Timer: PCallbackTimerGI);
var Current, Before: PCallbackTimerGI;
begin
  Current := Timer;
  if Current.Prev <> nil then Current.Prev.Next := Current.Next;
  if Current.Next <> nil then Current.Next.Prev := Current.Prev;
  if LastTimer = Current then LastTimer := Current.Prev;
  if FirstTimer = Current then FirstTimer := Current.Next;
  Before := FirstTimer;
  while Before <> nil do
  begin
    if Current.DueTick <= Before.DueTick then
    begin
      Current.Prev := Before.Prev;
      Current.Next := Before;
      if Before.Prev <> nil then Before.Prev.Next := Current;
      Before.Prev := Current;
      if FirstTimer = Before then FirstTimer := Current;
      Exit;
    end;
    Before := Before.Next;
  end;
  if LastTimer <> nil then LastTimer.Next := Current;
  Current.Prev := LastTimer;
  Current.Next := nil;
  LastTimer := Current;
  if FirstTimer = nil then FirstTimer := Current;
end;
{ @end $4CF4FC }

{ @routine $4CF62C TMessageLoopGI_RefreshTimerTick }
procedure TMessageLoopGI.RefreshTimerTick;
begin
  TimerTick := timeGetTime;
end;
{ @end $4CF62C }

{ @routine $4CF644 TMessageLoopGI_SetCursorImage }
procedure TMessageLoopGI.SetCursorImage(const ImagePath: WideString; HotSpot: TPoint);
begin
  if CustomCursorEnabled then
  begin
    (CursorControl as TCursorGI).SetImagePath(ImagePath);
    CursorControl.SetOrigin(HotSpot);
    CursorImagePath := ImagePath;
  end;
end;
{ @end $4CF644 }

{ @routine $4CF6A0 TMessageLoopGI_SetCursorByName }
procedure TMessageLoopGI.SetCursorByName(const Name: WideString);
var Cursor: TCursorUnit;
begin
  if CustomCursorEnabled then
  begin
    Cursor := FindCursorByName(Name);
    SetCursorImage(Cursor.ImagePath, Cursor.HotSpot);
  end;
end;
{ @end $4CF6A0 }

{ @routine $4CF6DC TMessageLoopGI_IsCursorImageSelected }
function TMessageLoopGI.IsCursorImageSelected(const RegisteredName: WideString): Boolean;
var Cursor: TCursorUnit;
begin
  Cursor := FindCursorByName(RegisteredName);
  Result := Cursor.ImagePath = CursorImagePath;
end;
{ @end $4CF6DC }

{ @routine $4CF710 TMessageLoopGI_IsCursorActive }
function TMessageLoopGI.IsCursorActive: Boolean;
begin
  Result := CursorControl.Active;
end;
{ @end $4CF710 }

{ @routine $4CF72C TMessageLoopGI_SetCursorActive }
procedure TMessageLoopGI.SetCursorActive(Enabled: Boolean);
begin
  if CursorControl.Active <> Enabled then CursorControl.SetActive(Enabled);
end;
{ @end $4CF72C }

{ @routine $4CF758 TMessageLoopGI_CaptureCursorState }
procedure TMessageLoopGI.CaptureCursorState(State: PCursorStateGI);
begin
  State^.ImagePath := CursorImagePath;
  State^.Active := IsCursorActive;
  State^.HotSpot := CursorControl.OriginPoint;
  State^.Position := CursorControl.LocalPosition;
end;
{ @end $4CF758 }

{ @routine $4CF7B0 TMessageLoopGI_RestoreCursorState }
procedure TMessageLoopGI.RestoreCursorState(State: PCursorStateGI);
begin
  if CustomCursorEnabled then
  begin
    SetCursorImage(State^.ImagePath, State^.HotSpot);
    SetCursorActive(State^.Active);
    CursorControl.SetPosition(State^.Position);
  end;
end;
{ @end $4CF7B0 }

{ @routine $4CF7FC TMessageLoopGI_UpdateCursorPosition }
procedure TMessageLoopGI.UpdateCursorPosition;
var Point: TPoint;
begin
  GetCursorPos(Point);
  if Direct3DPresentParameters.Windowed then ScreenToClient(MainWindowHandle, Point);
  CursorControl.SetPosition(Point);
end;
{ @end $4CF7FC }

{ @routine $4CF83C TMessageLoopGI_GetCursorPoint }
function TMessageLoopGI.GetCursorPoint: TPoint;
begin
  Result := CursorControl.LocalPosition;
end;
{ @end $4CF83C }

{ @routine $4CF860 TMessageLoopGI_SetSystemCursorPosition }
procedure TMessageLoopGI.SetSystemCursorPosition(Point: TPoint);
begin
  SetCursorPos(Point.X, Point.Y);
end;
{ @end $4CF860 }

{ @routine $4CF888 TMessageLoopGI_ConsumeTimerTickChange }
function TMessageLoopGI.ConsumeTimerTickChange: Boolean;
begin
  if LastObservedTimerTick = TimerTick then
  begin
    Result := False;
    Exit;
  end;
  LastObservedTimerTick := TimerTick;
  Result := True;
end;
{ @end $4CF888 }

{ @routine $4CF8BC TMessageLoopGI_QueryPointOcclusionState }
function TMessageLoopGI.QueryPointOcclusionState(Point: TPoint; IgnoreControl, StartControl: TObjectGI): Integer;
var Child: TObjectGI;
begin
  if StartControl = nil then StartControl := RootUiObject;
  if ((StartControl.Parent <> nil) and StartControl.ContainsPoint(Point)) or (StartControl.Parent = nil) then
  begin
    Child := StartControl.LastChild;
    while Child <> nil do
    begin
      Result := QueryPointOcclusionState(Point, IgnoreControl, Child);
      if Result <> 0 then Exit;
      Child := Child.PrevSibling;
    end;
    if StartControl.MouseBlocking and (StartControl <> IgnoreControl) then
    begin
      Result := 1;
      Exit;
    end;
  end;
  if StartControl = IgnoreControl then Result := -1
  else Result := 0;
end;
{ @end $4CF8BC }

{ @routine $4CF978 TMessageLoopGI_FreeSavedPixels16 }
procedure TMessageLoopGI.FreeSavedPixels16;
begin
  if SavedPixels16 <> nil then
  begin
    FreeEC(SavedPixels16);
    SavedPixels16 := nil;
  end;
  SavedPixelCount16 := 0;
  SavedPixelCapacity16 := 0;
end;
{ @end $4CF978 }

{ @routine $4CF9B4 TMessageLoopGI_RestoreSavedPixels16 }
procedure TMessageLoopGI.RestoreSavedPixels16;
var Entries, Pixels: Pointer; Count: Integer;
begin
  if SavedPixelCount16 < 1 then Exit;
  Pixels := ScreenRenderBuffer.GetPixels;
  Count := SavedPixelCount16;
  Entries := SavedPixels16;
  // Native handwritten block: PUSHAD/POPAD and the compact eight-byte-entry loop.
  asm
    pushad
    mov edi, Entries
    mov esi, Pixels
    mov ecx, Count
  @@NextPixel:
    mov ebx, [edi]
    add edi, 4
    mov ax, [edi]
    add edi, 4
    mov [esi+ebx], ax
    dec ecx
    jnz @@NextPixel
    popad
  end;
  SavedPixelCount16 := 0;
end;
{ @end $4CF9B4 }

{ @routine $4CFA1C TMessageLoopGI_FreeSecondaryPixelBuffer }
procedure TMessageLoopGI.FreeSecondaryPixelBuffer;
begin
  if SecondaryPixelBuffer <> nil then
  begin
    FreeEC(SecondaryPixelBuffer);
    SecondaryPixelBuffer := nil;
  end;
  SecondaryPixelCount := 0;
  SecondaryPixelCapacity := 0;
end;
{ @end $4CFA1C }

{ @routine $4CFA64 TMessageLoopGI_ResetSecondaryPixelCount }
procedure TMessageLoopGI.ResetSecondaryPixelCount;
begin
  if SecondaryPixelCount < 1 then Exit;
  SecondaryPixelCount := 0;
end;
{ @end $4CFA64 }

{ @routine $4CFA88 TMessageLoopGI_FreeSavedLines }
procedure TMessageLoopGI.FreeSavedLines;
var Index: Integer;
begin
  for Index := 0 to High(SavedLines) do
    FreeFromHeapEC(SavedLines[Index].Heap, SavedLines[Index].Pixels);
  SavedLines := nil;
  SavedLineCount := 0;
end;
{ @end $4CFA88 }

{ @routine $4CFB04 TMessageLoopGI_AddSavedLine }
procedure TMessageLoopGI.AddSavedLine(First, Last: TPoint; Pixels: Pointer);
begin
  if High(SavedLines) + 1 = SavedLineCount then SetLength(SavedLines, SavedLineCount + 100);
  SavedLines[SavedLineCount].First := First;
  SavedLines[SavedLineCount].Last := Last;
  SavedLines[SavedLineCount].Pixels := Pixels;
  SavedLines[SavedLineCount].Heap := GetProcessHeap;
  Inc(SavedLineCount);
end;
{ @end $4CFB04 }

{ @routine $4CFBF0 TMessageLoopGI_RestoreSavedLines }
procedure TMessageLoopGI.RestoreSavedLines;
var Index: Integer;
begin
  if not SkipSavedPixelRestore then
    for Index := 0 to SavedLineCount - 1 do
      Ex_OKGR_Line_CopyFromBuf_WORD(SavedLines[Index].Pixels,
        ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
        SavedLines[Index].First.X, SavedLines[Index].First.Y,
        SavedLines[Index].Last.X, SavedLines[Index].Last.Y);
end;
{ @end $4CFBF0 }

{ @routine $4CFCB4 TMessageLoopGI_ResetSavedLineCount }
procedure TMessageLoopGI.ResetSavedLineCount;
begin
  SavedLineCount := 0;
end;
{ @end $4CFCB4 }

{ @routine $4CFCCC TMessageLoopGI_ProcessMouseWheel }
procedure TMessageLoopGI.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
end;
{ @end $4CFCCC }

{ @routine $4CFCEC TMessageLoopGI_ClearTransientControl }
procedure TMessageLoopGI.ClearTransientControl;
begin
  InvalidateTransientControl;
  if TransientData <> nil then
  begin
    TransientData.Free;
    TransientData := nil;
  end;
  if TransientControl <> nil then
  begin
    TransientControl.SetActive(False);
    TransientControl.Free;
    TransientControl := nil;
  end;
end;
{ @end $4CFCEC }

{ @routine $4CFD58 TMessageLoopGI_InvalidateTransientControl }
procedure TMessageLoopGI.InvalidateTransientControl;
var WasEnabled: Boolean;
begin
  if TransientControl <> nil then
  begin
    WasEnabled := UpdateRectsEnabled;
    UpdateRectsEnabled := True;
    TransientControl.Invalidate;
    UpdateRectsEnabled := WasEnabled;
  end;
end;
{ @end $4CFD58 }

{ @routine $4CFD9C TMessageLoopGI_InitializeDefaults }
procedure TMessageLoopGI.InitializeDefaults;
var LabelControl: TLabelGI;
begin
  RootUiObject := CreateControlByName('Panel', nil);
  RootUiObject.MessageLoop := Self;
  RootUiObject.SetPosition(Classes.Point(0, 0));
  RootUiObject.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  BackgroundPanel := CreateControlByName('Panel', RootUiObject);
  BackgroundPanel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  BackgroundPanel.SetDepth(1);
  ContentPanel := CreateControlByName('Panel', RootUiObject);
  ContentPanel.SetDepth(0);
  OverlayPanel := CreateControlByName('Panel', RootUiObject);
  OverlayPanel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  OverlayPanel.SetDepth(-1);
  StatusLabel := TLabelGI.Create(OverlayPanel);
  LabelControl := StatusLabel as TLabelGI;
  LabelControl.SetActive(False);
  LabelControl.SetFontName(NormalFontName);
  LabelControl.SetDepth(-1E29);
  LabelControl.SetPosition(Classes.Point(5, 5));
  LabelControl.SetSize(Classes.Point(400, 20));
  LabelControl.SetTextAlignX(taxLeft);
  LabelControl.SetTextAlignY(tayCenterEx);
  CursorControl := TCursorGI.Create(OverlayPanel);
  CursorControl.SetDepth(-1E30);
end;
{ @end $4CFD9C }

{ @routine $4CFFA8 TMessageLoopGI_InitializeFromConfig }
procedure TMessageLoopGI.InitializeFromConfig(ConfigRoot: TBlockParEC; const ScreenName: WideString; UnusedFlag: Boolean);
var
  ScreenBlock, SoundBlock: TBlockParEC;
  Text: WideString;
  Index, Count: Integer;
  Group: TFormSoundGroup;
begin
  ResetRuntime;
  InitializeDefaults;
  ScreenBlock := ConfigRoot.GetBlockByPath(ScreenName);
  RegisteredLoopName := ScreenName;
  Text := ScreenBlock.GetParam('Border');
  ViewportRect.Left := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
  ViewportRect.Top := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
  ViewportRect.Right := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
  ViewportRect.Bottom := StrToInt(ExtractDelimitedPartW(Text, 3, ','));
  if ScreenBlock.CountBlocks('Sound') > 0 then
  begin
    SoundBlock := ScreenBlock.GetBlock('Sound');
    if SoundBlock.CountParams('Open') > 0 then OpenSoundName := SoundBlock.GetParam('Open');
    if SoundBlock.CountParams('Close') > 0 then CloseSoundName := SoundBlock.GetParam('Close');
    Count := SoundBlock.GetBlockCount;
    for Index := 0 to Count - 1 do
    begin
      Group := TFormSoundGroup.Create;
      SoundGroupList.Add(Group);
      Group.LoadFromBlock(SoundBlock.GetBlockByIndex(Index));
    end;
  end;
  ContentPanel.LoadFromBlock(ScreenBlock.GetBlockByPath('Panel'));
  RootUiObject.UpdateAbsolutePosition;
  RootUiObject.UpdateSubtreeHitBounds;
  QueueUpdateRect(ViewportRect);
end;
{ @end $4CFFA8 }

{ @routine $4D02B4 TMessageLoopGI_InitializeLayout }
procedure TMessageLoopGI.InitializeLayout;
begin
  RootUiObject.UpdateAutoGeometry;
end;
{ @end $4D02B4 }

{ @routine $4D02CC TMessageLoopGI_UpdateActionCursor }
procedure TMessageLoopGI.UpdateActionCursor(CanTake: Boolean);
begin
end;
{ @end $4D02CC }

{ @routine $4D02DC TMessageLoopGI_GetActionParentLoop }
function TMessageLoopGI.GetActionParentLoop: TMessageLoopGI;
begin
  Result := nil;
end;
{ @end $4D02DC }

{ @routine $4D02F4 TMessageLoopGI_QueueUiCode }
procedure TMessageLoopGI.QueueUiCode(Block: TBlockParEC; RefreshMouse: Boolean);
begin
  DeferredCodeBlocks.Add(Block);
  if RefreshMouse then RefreshMouseAfterCode := True;
end;
{ @end $4D02F4 }

{ @routine $4D0328 TMessageLoopGI_RefreshMouseDispatch }
procedure TMessageLoopGI.RefreshMouseDispatch;
var Point: TPoint;
begin
  Point.X := LastMousePosition.X;
  Point.Y := LastMousePosition.Y;
  RootUiObject.ProcessMouseMove(0, Point);
end;
{ @end $4D0328 }

{ @routine $4D0358 TMessageLoopGI_ExecuteUiCode }
procedure TMessageLoopGI.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
end;
{ @end $4D0358 }

end.
