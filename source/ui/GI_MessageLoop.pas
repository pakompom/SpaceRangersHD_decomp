unit GI_MessageLoop;
// Unit bracket (inferred): .text 0x004BAEA4..0x004C221A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

  TCursorStateGI = packed record // @size 0x18 // Native RTTI at $4BAE84 includes three trailing padding bytes.
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
    SkipOwnQueuedDraw: Integer; // @offset $5C  Nonzero skips this object's queued draw, after visiting children ($4BCC06).
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

    constructor Create(Owner: TObjectGI); // @addr 0x4BB218 @ida "TObjectGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4BB2DC @ida "void __usercall $name(TObjectGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; virtual; // @addr 0x4BB3C4 @slot 0x00 @note "Does not free children."
    procedure FreeOwnedChildren; // @addr 0x4BB3A0
    procedure AttachOwnedChild(Child: TObjectGI); // @addr 0x4BB448 @note "Takes ownership; caller must detach an existing parent. Descendants' MessageLoop values are unchanged."
    procedure InsertOwnedChildBefore(BeforeChild, Child: TObjectGI); // @addr 0x4BB4B4
    procedure InsertOwnedChildByDepth(Child: TObjectGI; NewDepth: Double); // @addr 0x4BB538 @ida "void __userpurge $name(TObjectGI *Self@<eax>, TObjectGI *Child@<edx>, double NewDepth@<^0>);" @note "Inserts in descending Depth order."
    procedure FreeOwnedChild(Child: TObjectGI); // @addr 0x4BB5A8
    procedure UnlinkOwnedChild(Child: TObjectGI); // @addr 0x4BB5CC @note "Leaves sibling pointers and MessageLoop unchanged."
    procedure Reparent(NewParent: TObjectGI); // @addr 0x4BB644 @note "Preserves Depth."
    procedure SetMouseViewUpdates(Enabled: Boolean); // @addr 0x4BB678
    procedure UpdateAbsolutePosition; // @addr 0x4BB6AC @note "Updates this control and recurses through active children."
    function GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint; virtual; // @addr 0x4BB738 @slot 0x04 @calls "0x4BB6D7" @ida "void __userpurge $name(TObjectGI *Self@<eax>, TPoint *LocalPosition@<edx>, bool ModeW@<cl>, TPoint *Result@<^0>);" @note "Base implementation ignores ModeW."
    procedure UpdateHitTestBounds; virtual; // @addr 0x4BB774 @slot 0x08 @calls "0x4BB7EA"
    procedure UpdateSubtreeHitBounds; // @addr 0x4BB7DC @note "Updates this control's hit-test rectangle and recurses through active children."
    procedure SetPosition(Position: TPoint); virtual; // @addr 0x4BB944 @slot 0x0C @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetDepth(NewDepth: Double); virtual; // @addr 0x4BB9C4 @slot 0x10 @ida "void __userpurge $name(TObjectGI *Self@<eax>, double NewDepth@<^0>);" @note "Does nothing without Parent." @calls "0x56934C 0x5698B8 0x56A597 0x56A607 0x56A7AD 0x56A81D 0x56A8E0 0x56A9E7 0x56ABD4 0x56AD77 0x56AE5A 0x57F808 0x57F8F8 0x57F96C"
    procedure SetDepthByName(const Name: WideString); virtual; // @addr $4BBA7C @slot $14
    procedure SetSize(Size: TPoint); virtual; // @addr 0x4BBB0C @slot 0x18 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure SetOrigin(Origin: TPoint); virtual; // @addr 0x4BBB8C @slot 0x1C @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Origin@<edx>);"
    procedure SetPositionModeW(Enabled: Boolean); // @addr 0x4BBC0C
    procedure SetConfigPath(const Path: WideString); virtual; // @addr 0x4BBC6C @slot 0x20 @note "Virtual loading sees the previous ConfigPath."
    function GetLocalBounds: TRect; virtual; // @addr 0x4BBC98 @slot 0x24 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Result@<edx>);"
    procedure SetName(const Name: WideString); // @addr 0x4BBCFC
    procedure SetActive(Enabled: Boolean); virtual; // @addr 0x4BBD1C @slot 0x28
    procedure SetHitTestDisabled(Disabled: Boolean); virtual; // @addr 0x4BBD88 @slot 0x2C
    procedure QueueImageLoad(PendingLoads: TList); virtual; // @addr 0x4BBE90 @slot 0x30
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BBEA0 @slot 0x38 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC228 @slot 0x54 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC2B0 @slot 0x58 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC338 @slot 0x5C @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC3E4 @slot 0x60 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC46C @slot 0x64 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessRightButtonDoubleClick(KeyState: Cardinal; Point: TPoint); virtual; // @addr 0x4BC4F4 @slot 0x68 @ida "void __usercall $name(TObjectGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure OnMouseEnter; virtual; // @addr 0x4BBF9C @slot 0x3C
    procedure OnMouseLeave; virtual; // @addr 0x4BC030 @slot 0x40
    procedure BroadcastKeyDown(Key: Cardinal); virtual; // @addr 0x4BC57C @slot 0x6C
    procedure BroadcastKeyUp(Key: Cardinal); virtual; // @addr 0x4BC5FC @slot 0x70
    procedure DispatchNamedEvent(EventKind, Param1, Param2: Integer); // @addr 0x4BC830
    procedure SetHelpCallbackRecursive(Callback: TObjectHelpEventGI); // @addr $4BB820
    procedure OnHoverGained; virtual; // @addr $4BC65C @slot $74 @calls "0x4C1073"
    procedure OnHoverLost; virtual; // @addr $4BC668 @slot $78 @calls "0x4C1056"
    procedure OnFocusGained; virtual; // @addr 0x4BC674 @slot 0x7C @calls "0x4C1018"
    procedure OnFocusLost; virtual; // @addr 0x4BC680 @slot 0x80 @calls "0x4C0FF8"
    procedure ProcessKeyDown(Key: Integer); virtual; // @addr 0x4BC68C @slot 0x84
    procedure ProcessCharacter(Character: WideChar); virtual; // @addr 0x4BC69C @slot 0x88
    procedure OnCaretBlink; virtual; // @addr $4BC6B0 @slot $8C @note "Called on the focused control when CaretBlinkOn changes."
    procedure NativeHook48; virtual; // @addr $4BC15C @slot $48 @note "Purpose unresolved; the base hook visits children whose Active flag equals True."
    procedure NativeHook50; virtual; // @addr $4BC1EC @slot $50 @note "Purpose unresolved; the base hook visits children whose Active flag equals True."
    procedure NativeHookB0; virtual; // @addr $4BCF00 @slot $B0 @note "Purpose unresolved; the base hook visits active children."
    procedure NativeHookBC(Rect: TRect); virtual; // @addr $4BCF9C @slot $BC @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>);" @note "Empty base hook; purpose unresolved."
    procedure OnActivate; virtual; // @addr 0x4BC0FC @slot 0x44
    procedure OnDeactivate; virtual; // @addr 0x4BC198 @slot 0x4C
    procedure PrepareRegionDraw(ClipRect: TRect); virtual; // @addr $4BCF80 @slot $B8 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Empty base hook called before queued drawing for RegionDrawControl."
    procedure CommitFrameDraw; virtual; // @addr $4BCE80 @slot $A8 @note "After a successful frame; derived controls retain state needed to erase their previous drawing."
    procedure ErasePreviousFrame; virtual; // @addr $4BCEC0 @slot $AC @note "Before queued drawing; derived controls restore their saved background pixels."
    procedure PrepareFrameDraw; virtual; // @addr $4BCF40 @slot $B4 @note "Before DrawUpdateRects; derived controls capture backgrounds or prepare geometry."
    procedure InvalidateChildren(IncludePanels: Boolean); // @addr $4BC954
    function InvalidateScrollOverlap(Rect: TRect; Delta: TPoint; StartControl: TObjectGI): TObjectGI; // @addr $4BC9BC @note "Walks active panel subtrees until StartControl, then invalidates affected controls by moving them out and back. Rect is passed through but unused." @ida "TObjectGI *__userpurge $name@<eax>(TObjectGI *Self@<eax>, TRect *Rect@<edx>, TPoint *Delta@<ecx>, TObjectGI *StartControl@<^0>);"
    procedure Draw(ClipRect: TRect); virtual; // @addr 0x4BCABC @slot 0xA0 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Suppressed while PendingRedraw is set."
    procedure DrawUpdateRects(ClipRect: TRect); virtual; // @addr 0x4BCB30 @slot 0xA4 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *ClipRect@<edx>);"
    procedure LoadFromConfigPath(const Path: WideString); virtual; // @addr 0x4BCFB8 @slot 0x34
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x4BD69C @slot 0xC0
    function OffsetChildRect(Rect: TRect; ModeW: Boolean): TRect; // @addr $4BB88C @ida "void __userpurge $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>, bool ModeW@<cl>, TRect *Result@<^0>);" @note "Adds LocalPosition and subtracts ScrollOffset when ModeW is set."
    procedure InvalidateRect(Rect: TRect); virtual; // @addr $4BC874 @slot $98 @ida "void __usercall $name(TObjectGI *Self@<eax>, TRect *Rect@<edx>);"
    procedure Invalidate; virtual; // @addr 0x4BC910 @slot 0x9C
    procedure ReloadFromBlock; // @addr $4BDE7C
    procedure UpdateAutoGeometry; virtual; // @addr 0x4BDEA0 @slot 0xC4
    function FindDeepestChildAtPoint(Point: TPoint): TObjectGI; // @addr 0x4BBDF4 @ida "TObjectGI *__usercall $name@<eax>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);" @note "Returns Self when no child contains Point."
    function IsOccludedAtPoint(Point: TPoint): Boolean; // @addr 0x4BBE54 @ida "bool __usercall $name@<al>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);"
    function ContainsPoint(Point: TPoint): Boolean; // @addr 0x4BC6BC @ida "bool __usercall $name@<al>(TObjectGI *Self@<eax>, TPoint *Point@<edx>);" @note "Requires Active and enabled hit testing; right and bottom edges are exclusive."
    function ToLocalPoint(Point: TPoint): TPoint; virtual; // @addr 0x4BC7C0 @slot 0x90 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);"
    function ToAbsolutePoint(Point: TPoint): TPoint; virtual; // @addr 0x4BC7F8 @slot 0x94 @ida "void __usercall $name(TObjectGI *Self@<eax>, TPoint *Point@<edx>, TPoint *Result@<ecx>);"
    function HitTestCursor: Boolean; // @addr 0x4BC728
    function FindByNameRecursive(const Name: WideString): TObjectGI; // @addr 0x4BC754 @note "Case-sensitive; includes Self. Duplicate names resolve in child-list order."
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

    constructor Create; // @addr 0x4BDF20 @ida "TFormSoundGroup *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4BDF74 @ida "void __usercall $name(TFormSoundGroup *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x4BDFC0 @note "Preserves timing fields and TotalWeight."
    procedure LoadFromBlock(Block: TBlockParEC); // @addr 0x4BDFE0 @note "Numeric parameter names are weights; their values are sound names."
    procedure ScheduleNextPlayback; // @addr 0x4BE1D4
    procedure PlayIfDue; // @addr 0x4BE200
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

    constructor Create; // @addr 0x4BE2BC @ida "TMessageLoopGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4BE37C @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function Run: Integer; virtual; // @addr 0x4BE77C @slot 0x00 @calls "0x52C9AE"
    procedure ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer); virtual; // @addr 0x4BFB78 @slot 0x04 @note "Dispatches mouse/keyboard messages, deferred UI code and layout-inspector keys. Button coordinates are unsigned words; move and wheel coordinates are signed."
    function RunContinuous: Integer; virtual; // @addr 0x4BEFD4 @slot 0x08 @calls "0x52C95E"
    procedure AdvanceTimerTick; virtual; // @addr 0x4BF7D0 @slot 0x0C
    procedure DrawFrame; virtual; // @addr 0x4BFA70 @slot 0x10
    procedure Present; virtual; // @addr 0x4BFA98 @slot 0x14
    procedure ProcessNamedControlEvent(ControlName: WideString; EventKind, Param1, Param2: Integer); virtual; // @addr 0x4C107C @slot 0x18
    procedure OnOpen; virtual; // @addr 0x4C10C4 @slot 0x1C
    procedure OnClose; virtual; // @addr 0x4C10D8 @slot 0x20
    procedure SelectMusic; virtual; // @addr 0x4C11C0 @slot 0x28
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); virtual; // @addr 0x4C1B7C @slot 0x2C @ida "void __userpurge $name(TMessageLoopGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; virtual; // @addr 0x4C2164 @slot 0x30
    procedure UpdateActionCursor(CanTake: Boolean); virtual; // @addr 0x4C217C @slot 0x34
    function GetActionParentLoop: TMessageLoopGI; virtual; // @addr 0x4C218C @slot 0x38 @note "Base returns nil."
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); virtual; // @addr 0x4C2208 @slot 0x3C @note "Key is zero for deferred mouse actions; key-down handlers pass the virtual key."
    procedure QueueUiCode(Block: TBlockParEC; RefreshMouse: Boolean); // @addr 0x4C21A4 @note "Borrows Block until event completion or Run exits."
    procedure RefreshMouseDispatch; // @addr 0x4C21D8
    procedure SetHelpCallback(Callback: TObjectHelpEventGI); // @addr $4C0E18
    procedure InitializeFromConfig(ConfigRoot: TBlockParEC; const ScreenName: WideString; UnusedFlag: Boolean); // @addr 0x4C1E58
    procedure FreeSavedPixels16; // @addr $4C1828
    procedure RestoreSavedPixels16; // @addr $4C1864 @note "Contains a native handwritten PUSHAD/POPAD loop at $4C189D..$4C18B9."
    procedure FreeSecondaryPixelBuffer; // @addr $4C18CC
    procedure ResetSecondaryPixelCount; // @addr $4C1914
    procedure FreeSavedLines; // @addr $4C1938 @note "Frees every allocated array slot, including slots beyond SavedLineCount."
    procedure AddSavedLine(First, Last: TPoint; Pixels: Pointer); // @addr $4C19B4 @ida "void __userpurge $name(TMessageLoopGI *Self@<eax>, TPoint *First@<edx>, TPoint *Last@<ecx>, void *Pixels@<^0>);" @note "Takes the pixel allocation; records the process heap."
    procedure RestoreSavedLines; // @addr $4C1AA0 @note "Restores SavedLineCount lines unless SkipSavedPixelRestore is set; retains the count."
    procedure ResetSavedLineCount; // @addr $4C1B64
    procedure InvalidateMouseViewControls; // @addr $4BE604
    procedure ClearTransientControl; // @addr $4C1B9C
    procedure InvalidateTransientControl; // @addr $4C1C08 @note "Temporarily enables queued invalidation; an exception leaves it enabled."
    procedure ResetRuntime; // @addr 0x4BE400 @note "Frees the root tree and cancels callback timers."
    procedure QueueUpdateRect(Rect: TRect); // @addr 0x4BE4C4 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TRect *Rect@<edx>);" @note "Clips to GameScreenRect; does nothing when update rectangles are disabled."
    procedure InvalidateViewport; // @addr 0x4BE50C
    function FindMouseViewUpdateControl(Control: TObjectGI): Integer; // @addr 0x4BE544
    procedure AddMouseViewUpdateControl(Control: TObjectGI); // @addr 0x4BE5A0 @note "Duplicates are ignored."
    procedure RemoveMouseViewUpdateControl(Control: TObjectGI); // @addr 0x4BE5D0
    procedure DrawQueuedControlRects; // @addr $4BE6CC @note "Sets PendingRedraw and traverses queued drawing through the root tree."
    procedure CommitFrameDraw; // @addr $4BE734
    procedure ErasePreviousFrame; // @addr $4BE74C
    procedure PrepareFrameDraw; // @addr $4BE764
    procedure FinishQueuedDraw; // @addr $4BE720 @note "Clears RegionDrawPending."
    procedure SetSystemCursorPosition(Point: TPoint); // @addr $4C1710 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TPoint *Point@<edx>);" @note "Uses screen coordinates."
    function ConsumeTimerTickChange: Boolean; // @addr $4C1738 @note "Returns true once for each changed TimerTick."
    procedure DrawQueuedUpdateRects; // @addr 0x4BE654 @note "Leaves queued rectangles in place."
    procedure CaptureScreenshot; // @addr $4C0B88 @note "Uses the first free Shot000..Shot999 name; silently skips when all names are occupied."
    procedure RequestClose(ResultCode: Integer); // @addr 0x4C0DFC
    function GetByName(const Name: WideString): TObjectGI; // @addr 0x4C0E38 @note "Search is limited to ContentPanel; raises when absent."
    function FindControlByPath(const Path: WideString): TObjectGI; // @addr 0x4C0F10 @note "Each component may match a descendant, not just a direct child. Returns nil when absent."
    procedure SetFocusedControl(Control: TObjectGI); // @addr 0x4C0FD0
    procedure SetHoveredControl(Control: TObjectGI); // @addr 0x4C1020
    procedure ProcessCallbackTimers; virtual; // @slot 0x24 @addr 0x4C10EC @note "May wait for a timer or Windows message; zero RepeatMs still repeats."
    function ScheduleCallbackTimer(DelayMs, RepeatMs: Integer; Callback: TCallbackTimerEventGI; UserData: Integer = 0): PCallbackTimerGI; // @addr 0x4C11CC @note "Computes DueTick from the stored TimerTick, not a new clock sample."
    procedure CancelCallbackTimer(Timer: PCallbackTimerGI); // @addr 0x4C1278
    procedure UpdateCallbackTimer(Timer: PCallbackTimerGI; DelayMs, RepeatMs: Integer); // @addr 0x4C1310
    procedure ReinsertCallbackTimer(Timer: PCallbackTimerGI); // @addr 0x4C136C @note "Equal deadlines run in reverse insertion order; clock wraparound is not handled."
    procedure RefreshTimerTick; // @addr 0x4C14DC
    procedure SetCursorImage(const ImagePath: WideString; HotSpot: TPoint); // @addr 0x4C14F4 @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, unsigned __int16 *ImagePath@<edx>, TPoint *HotSpot@<ecx>);" @note "Does nothing when custom cursors are disabled."
    procedure SetCursorByName(const Name: WideString); // @addr 0x4C1550
    function IsCursorImageSelected(const RegisteredName: WideString): Boolean; // @addr 0x4C158C @note "Ignores cursor activity; registered names with the same image path compare equal."
    function IsCursorActive: Boolean; // @addr 0x4C15C0
    procedure SetCursorActive(Enabled: Boolean); // @addr 0x4C15DC
    procedure CaptureCursorState(State: PCursorStateGI); // @addr 0x4C1608 @note "Writes caller-owned state; its WideString must be initialized. Pointer form is required by native record-copy evaluation order."
    procedure RestoreCursorState(State: PCursorStateGI); // @addr 0x4C1660 @note "Reads caller-owned state through a pointer; ignored when custom cursors are disabled."
    procedure UpdateCursorPosition; // @addr 0x4C16AC @note "Moves the image cursor to the system mouse position, converted to client coordinates in windowed mode."
    function GetCursorPoint: TPoint; // @addr 0x4C16EC @ida "void __usercall $name(TMessageLoopGI *Self@<eax>, TPoint *Result@<edx>);" @note "Returns CursorControl's local position."
    function QueryPointOcclusionState(Point: TPoint; IgnoreControl, StartControl: TObjectGI): Integer; // @addr 0x4C176C @ida "int __userpurge $name@<eax>(TMessageLoopGI *Self@<eax>, TPoint *Point@<edx>, TObjectGI *IgnoreControl@<ecx>, TObjectGI *StartControl@<^0>);" @note "Starts at RootUiObject when StartControl is nil; returns 1 for a blocker, -1 for IgnoreControl, or 0 for no hit."
    procedure InitializeDefaults; // @addr 0x4C1C4C
  end;

procedure PushMessageLoop(Loop: TMessageLoopGI); // @addr $4BB164
procedure PopMessageLoop(Loop: TMessageLoopGI); // @addr $4BB198

var
  MessageLoopStack: TList = nil; // @addr $87AA08
  IgnoreWarpMouseMove: Boolean = False; // @addr $87AA0C  Consumes the mouse move generated by viewport cursor recentering.
  LastMousePosition: TPoint; // @addr $889E64  Written by ProcessWindowMessage and reused by RefreshMouseDispatch.

implementation

uses PopUp, BreakMessageGIException, EC_Mem, MMSystem, Windows, Messages, GI_Cursor, GI_Label, GI_Main, GI_Panel, GI_GraphBuf, GlobalsV, Globals, GR_Main, GR_GraphBuf, SysUtils, aMyFunction, GR_Sound, GR_Music;

{ @routine $4BB164 PushMessageLoop }
procedure PushMessageLoop(Loop: TMessageLoopGI);
begin
  if MessageLoopStack = nil then MessageLoopStack := TList.Create;
  MessageLoopStack.Add(Loop);
end;
{ @end $4BB164 }

{ @routine $4BB198 PopMessageLoop }
procedure PopMessageLoop(Loop: TMessageLoopGI);
begin
  if (MessageLoopStack = nil) or (MessageLoopStack.Count < 1) then RaiseWideMessage('ML 1');
  if MessageLoopStack[MessageLoopStack.Count - 1] <> Loop then RaiseWideMessage('ML 2');
  MessageLoopStack.Delete(MessageLoopStack.Count - 1);
end;
{ @end $4BB198 }

{ @routine $4BB218 TObjectGI_Create }
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
{ @end $4BB218 }

{ @routine $4BB2DC TObjectGI_Destroy }
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
{ @end $4BB2DC }

{ @routine $4BB3A0 TObjectGI_FreeOwnedChildren }
procedure TObjectGI.FreeOwnedChildren;
begin
  while LastChild <> nil do FreeOwnedChild(FirstChild);
end;
{ @end $4BB3A0 }

{ @routine $4BB3C4 TObjectGI_Clear }
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
{ @end $4BB3C4 }

{ @routine $4BB448 TObjectGI_AttachOwnedChild }
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
{ @end $4BB448 }

{ @routine $4BB4B4 TObjectGI_InsertOwnedChildBefore }
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
{ @end $4BB4B4 }

{ @routine $4BB538 TObjectGI_InsertOwnedChildByDepth }
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
{ @end $4BB538 }

{ @routine $4BB5A8 TObjectGI_FreeOwnedChild }
procedure TObjectGI.FreeOwnedChild(Child: TObjectGI);
begin
  UnlinkOwnedChild(Child);
  Child.Free;
end;
{ @end $4BB5A8 }

{ @routine $4BB5CC TObjectGI_UnlinkOwnedChild }
procedure TObjectGI.UnlinkOwnedChild(Child: TObjectGI);
begin
  if Child.PrevSibling <> nil then Child.PrevSibling.NextSibling := Child.NextSibling;
  if Child.NextSibling <> nil then Child.NextSibling.PrevSibling := Child.PrevSibling;
  if LastChild = Child then LastChild := Child.PrevSibling;
  if FirstChild = Child then FirstChild := Child.NextSibling;
  Child.Parent := nil;
end;
{ @end $4BB5CC }

{ @routine $4BB644 TObjectGI_Reparent }
procedure TObjectGI.Reparent(NewParent: TObjectGI);
begin
  Parent.UnlinkOwnedChild(Self);
  NewParent.InsertOwnedChildByDepth(Self, Depth);
end;
{ @end $4BB644 }

{ @routine $4BB678 TObjectGI_SetMouseViewUpdates }
procedure TObjectGI.SetMouseViewUpdates(Enabled: Boolean);
begin
  if Enabled = True then MessageLoop.AddMouseViewUpdateControl(Self)
  else MessageLoop.RemoveMouseViewUpdateControl(Self);
end;
{ @end $4BB678 }

{ @routine $4BB6AC TObjectGI_UpdateAbsolutePosition }
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
{ @end $4BB6AC }

{ @routine $4BB738 TObjectGI_GetChildAbsolutePosition }
function TObjectGI.GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint;
begin
  Result.X := AbsolutePosition.X + LocalPosition.X;
  Result.Y := AbsolutePosition.Y + LocalPosition.Y;
end;
{ @end $4BB738 }

{ @routine $4BB774 TObjectGI_UpdateHitTestBounds }
procedure TObjectGI.UpdateHitTestBounds;
begin
  HitTestBounds := Classes.Rect(AbsolutePosition.X - OriginPoint.X, AbsolutePosition.Y - OriginPoint.Y,
    AbsolutePosition.X - OriginPoint.X + ClientSize.X, AbsolutePosition.Y - OriginPoint.Y + ClientSize.Y);
end;
{ @end $4BB774 }

{ @routine $4BB7DC TObjectGI_UpdateSubtreeHitBounds }
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
{ @end $4BB7DC }

{ @routine $4BB820 TObjectGI_SetHelpCallbackRecursive }
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
{ @end $4BB820 }

{ @routine $4BB88C TObjectGI_OffsetChildRect }
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
{ @end $4BB88C }

{ @routine $4BB944 TObjectGI_SetPosition }
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
{ @end $4BB944 }

{ @routine $4BB9C4 TObjectGI_SetDepth }
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
{ @end $4BB9C4 }

{ @routine $4BBA7C TObjectGI_SetDepthByName }
procedure TObjectGI.SetDepthByName(const Name: WideString);
var Value: WideString;
begin
  Value := UiDepthConfig.GetParamOrMarker(Name);
  if Value <> '' then SetDepth(ExtractDecimalToSingleW(Value))
  else SetDepth(ExtractDecimalToSingleW(Name));
end;
{ @end $4BBA7C }

{ @routine $4BBB0C TObjectGI_SetSize }
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
{ @end $4BBB0C }

{ @routine $4BBB8C TObjectGI_SetOrigin }
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
{ @end $4BBB8C }

{ @routine $4BBC0C TObjectGI_SetPositionModeW }
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
{ @end $4BBC0C }

{ @routine $4BBC6C TObjectGI_SetConfigPath }
procedure TObjectGI.SetConfigPath(const Path: WideString);
begin
  LoadFromConfigPath(Path);
  ConfigPath := Path;
end;
{ @end $4BBC6C }

{ @routine $4BBC98 TObjectGI_GetLocalBounds }
function TObjectGI.GetLocalBounds: TRect;
begin
  Result.Left := LocalPosition.X - OriginPoint.X;
  Result.Top := LocalPosition.Y - OriginPoint.Y;
  Result.Right := LocalPosition.X - OriginPoint.X + ClientSize.X;
  Result.Bottom := LocalPosition.Y - OriginPoint.Y + ClientSize.Y;
end;
{ @end $4BBC98 }

{ @routine $4BBCFC TObjectGI_SetName }
procedure TObjectGI.SetName(const Name: WideString);
begin
  ControlName := Name;
end;
{ @end $4BBCFC }

{ @routine $4BBD1C TObjectGI_SetActive }
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
{ @end $4BBD1C }

{ @routine $4BBD88 TObjectGI_SetHitTestDisabled }
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
{ @end $4BBD88 }

{ @routine $4BBDF4 TObjectGI_FindDeepestChildAtPoint }
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
{ @end $4BBDF4 }

{ @routine $4BBE54 TObjectGI_IsOccludedAtPoint }
function TObjectGI.IsOccludedAtPoint(Point: TPoint): Boolean;
begin
  if MessageLoop.QueryPointOcclusionState(Point, Self, nil) = 1 then Result := True
  else Result := False;
end;
{ @end $4BBE54 }

{ @routine $4BBE90 TObjectGI_QueueImageLoad }
procedure TObjectGI.QueueImageLoad(PendingLoads: TList);
begin
end;
{ @end $4BBE90 }

{ @routine $4BBEA0 TObjectGI_ProcessMouseMove }
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
{ @end $4BBEA0 }

{ @routine $4BBF9C TObjectGI_OnMouseEnter }
procedure TObjectGI.OnMouseEnter;
begin
  if Assigned(MouseEnterCallback) then MouseEnterCallback(Self);
  if OnMouseEnterCode <> nil then MessageLoop.QueueUiCode(OnMouseEnterCode, False);
  MouseInside := True;
  if HelpText <> '' then
    if MessageLoop.HelpLabel <> nil then (MessageLoop.HelpLabel as TLabelGI).SetText(HelpText);
end;
{ @end $4BBF9C }

{ @routine $4BC030 TObjectGI_OnMouseLeave }
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
{ @end $4BC030 }

{ @routine $4BC0FC TObjectGI_OnActivate }
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
{ @end $4BC0FC }

{ @routine $4BC15C TObjectGI_NativeHook48 }
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
{ @end $4BC15C }

{ @routine $4BC198 TObjectGI_OnDeactivate }
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
{ @end $4BC198 }

{ @routine $4BC1EC TObjectGI_NativeHook50 }
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
{ @end $4BC1EC }

{ @routine $4BC228 TObjectGI_ProcessLeftButtonDown }
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
{ @end $4BC228 }

{ @routine $4BC2B0 TObjectGI_ProcessLeftButtonUp }
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
{ @end $4BC2B0 }

{ @routine $4BC338 TObjectGI_ProcessRightButtonDown }
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
{ @end $4BC338 }

{ @routine $4BC3E4 TObjectGI_ProcessRightButtonUp }
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
{ @end $4BC3E4 }

{ @routine $4BC46C TObjectGI_ProcessLeftButtonDoubleClick }
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
{ @end $4BC46C }

{ @routine $4BC4F4 TObjectGI_ProcessRightButtonDoubleClick }
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
{ @end $4BC4F4 }

{ @routine $4BC57C TObjectGI_BroadcastKeyDown }
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
{ @end $4BC57C }

{ @routine $4BC5FC TObjectGI_BroadcastKeyUp }
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
{ @end $4BC5FC }

{ @routine $4BC65C TObjectGI_OnHoverGained }
procedure TObjectGI.OnHoverGained;
begin
end;
{ @end $4BC65C }

{ @routine $4BC668 TObjectGI_OnHoverLost }
procedure TObjectGI.OnHoverLost;
begin
end;
{ @end $4BC668 }

{ @routine $4BC674 TObjectGI_OnFocusGained }
procedure TObjectGI.OnFocusGained;
begin
end;
{ @end $4BC674 }

{ @routine $4BC680 TObjectGI_OnFocusLost }
procedure TObjectGI.OnFocusLost;
begin
end;
{ @end $4BC680 }

{ @routine $4BC68C TObjectGI_ProcessKeyDown }
procedure TObjectGI.ProcessKeyDown(Key: Integer);
begin
end;
{ @end $4BC68C }

{ @routine $4BC69C TObjectGI_ProcessCharacter }
procedure TObjectGI.ProcessCharacter(Character: WideChar);
begin
end;
{ @end $4BC69C }

{ @routine $4BC6B0 TObjectGI_OnCaretBlink }
procedure TObjectGI.OnCaretBlink;
begin
end;
{ @end $4BC6B0 }

{ @routine $4BC6BC TObjectGI_ContainsPoint }
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
{ @end $4BC6BC }

{ @routine $4BC728 TObjectGI_HitTestCursor }
function TObjectGI.HitTestCursor: Boolean;
begin
  Result := ContainsPoint(MessageLoop.GetCursorPoint);
end;
{ @end $4BC728 }

{ @routine $4BC754 TObjectGI_FindByNameRecursive }
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
{ @end $4BC754 }

{ @routine $4BC7C0 TObjectGI_ToLocalPoint }
function TObjectGI.ToLocalPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X - AbsolutePosition.X;
  Result.Y := Point.Y - AbsolutePosition.Y;
end;
{ @end $4BC7C0 }

{ @routine $4BC7F8 TObjectGI_ToAbsolutePoint }
function TObjectGI.ToAbsolutePoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X + AbsolutePosition.X;
  Result.Y := Point.Y + AbsolutePosition.Y;
end;
{ @end $4BC7F8 }

{ @routine $4BC830 TObjectGI_DispatchNamedEvent }
procedure TObjectGI.DispatchNamedEvent(EventKind, Param1, Param2: Integer);
begin
  if Length(ControlName) > 0 then MessageLoop.ProcessNamedControlEvent(ControlName, EventKind, Param1, Param2);
end;
{ @end $4BC830 }

{ @routine $4BC874 TObjectGI_InvalidateRect }
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
{ @end $4BC874 }

{ @routine $4BC910 TObjectGI_Invalidate }
procedure TObjectGI.Invalidate;
begin
  if MessageLoop.UpdateRectsEnabled and (Parent <> nil) and (Active = True) then
    InvalidateRect(GetLocalBounds);
end;
{ @end $4BC910 }

{ @routine $4BC954 TObjectGI_InvalidateChildren }
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
{ @end $4BC954 }

{ @routine $4BC9BC TObjectGI_InvalidateScrollOverlap }
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
{ @end $4BC9BC }

{ @routine $4BCABC TObjectGI_Draw }
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
{ @end $4BCABC }

{ @routine $4BCB30 TObjectGI_DrawUpdateRects }
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
{ @end $4BCB30 }

{ @routine $4BCE80 TObjectGI_CommitFrameDraw }
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
{ @end $4BCE80 }

{ @routine $4BCEC0 TObjectGI_ErasePreviousFrame }
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
{ @end $4BCEC0 }

{ @routine $4BCF00 TObjectGI_NativeHookB0 }
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
{ @end $4BCF00 }

{ @routine $4BCF40 TObjectGI_PrepareFrameDraw }
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
{ @end $4BCF40 }

{ @routine $4BCF80 TObjectGI_PrepareRegionDraw }
procedure TObjectGI.PrepareRegionDraw(ClipRect: TRect);
begin
end;
{ @end $4BCF80 }

{ @routine $4BCF9C TObjectGI_NativeHookBC }
procedure TObjectGI.NativeHookBC(Rect: TRect);
begin
end;
{ @end $4BCF9C }

{ @routine $4BCFB8 TObjectGI_LoadFromConfigPath }
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
{ @end $4BCFB8 }

{ @routine $4BD69C TObjectGI_LoadFromBlock }
procedure TObjectGI.LoadFromBlock(Block: TBlockParEC);
var Count: Integer; Text: WideString;

  // @nested $4BD50C LoadConfiguredChildren
  procedure LoadConfiguredChildren(Block: TBlockParEC); // @addr $4BD50C @ida "void __usercall $name(TBlockParEC *Block@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4BD6CA 0x4BD5F8" @note "Nested helper of TObjectGI.LoadFromBlock; creates recognized controls and descends through other blocks."
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
{ @end $4BD69C }

{ @routine $4BDE7C TObjectGI_ReloadFromBlock }
procedure TObjectGI.ReloadFromBlock;
begin
  FreeOwnedChildren;
  LoadFromBlock(SourceBlock);
end;
{ @end $4BDE7C }

{ @routine $4BDEA0 TObjectGI_UpdateAutoGeometry }
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
{ @end $4BDEA0 }

{ @routine $4BDF20 TFormSoundGroup_Create }
constructor TFormSoundGroup.Create;
begin
  inherited Create;
  Sounds := TStringsEC.Create;
end;
{ @end $4BDF20 }

{ @routine $4BDF74 TFormSoundGroup_Destroy }
destructor TFormSoundGroup.Destroy;
begin
  Clear;
  Sounds.Free;
  Sounds := nil;
  inherited Destroy;
end;
{ @end $4BDF74 }

{ @routine $4BDFC0 TFormSoundGroup_Clear }
procedure TFormSoundGroup.Clear;
begin
  Sounds.Clear;
  Section := 0;
end;
{ @end $4BDFC0 }

{ @routine $4BDFE0 TFormSoundGroup_LoadFromBlock }
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
{ @end $4BDFE0 }

{ @routine $4BE1D4 TFormSoundGroup_ScheduleNextPlayback }
procedure TFormSoundGroup.ScheduleNextPlayback;
begin
  NextPlayTick := Cardinal(RandomIntRange(MinDelayMs, MaxDelayMs)) + timeGetTime;
end;
{ @end $4BE1D4 }

{ @routine $4BE200 TFormSoundGroup_PlayIfDue }
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
{ @end $4BE200 }

{ @routine $4BE2BC TMessageLoopGI_Create }
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
{ @end $4BE2BC }

{ @routine $4BE37C TMessageLoopGI_Destroy }
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
{ @end $4BE37C }

{ @routine $4BE400 TMessageLoopGI_ResetRuntime }
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
{ @end $4BE400 }

{ @routine $4BE4C4 TMessageLoopGI_QueueUpdateRect }
procedure TMessageLoopGI.QueueUpdateRect(Rect: TRect);
var Intersection: TRect;
begin
  if UpdateRectsEnabled then
    if IntersectRects(Intersection, Rect, GameScreenRect) then UpdateRects.AddRect(Intersection);
end;
{ @end $4BE4C4 }

{ @routine $4BE50C TMessageLoopGI_InvalidateViewport }
procedure TMessageLoopGI.InvalidateViewport;
begin
  QueueUpdateRect(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
end;
{ @end $4BE50C }

{ @routine $4BE544 TMessageLoopGI_FindMouseViewUpdateControl }
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
{ @end $4BE544 }

{ @routine $4BE5A0 TMessageLoopGI_AddMouseViewUpdateControl }
procedure TMessageLoopGI.AddMouseViewUpdateControl(Control: TObjectGI);
begin
  if FindMouseViewUpdateControl(Control) < 0 then MouseViewUpdateControls.Add(Control);
end;
{ @end $4BE5A0 }

{ @routine $4BE5D0 TMessageLoopGI_RemoveMouseViewUpdateControl }
procedure TMessageLoopGI.RemoveMouseViewUpdateControl(Control: TObjectGI);
var Index: Integer;
begin
  Index := FindMouseViewUpdateControl(Control);
  if Index >= 0 then MouseViewUpdateControls.Delete(Index);
end;
{ @end $4BE5D0 }

{ @routine $4BE604 TMessageLoopGI_InvalidateMouseViewControls }
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
{ @end $4BE604 }

{ @routine $4BE654 TMessageLoopGI_DrawQueuedUpdateRects }
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
{ @end $4BE654 }

{ @routine $4BE6CC TMessageLoopGI_DrawQueuedControlRects }
procedure TMessageLoopGI.DrawQueuedControlRects;
begin
  if UpdateRects.FirstRect <> nil then
  begin
    PendingRedraw := True;
    RootUiObject.DrawUpdateRects(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
  end;
end;
{ @end $4BE6CC }

{ @routine $4BE720 TMessageLoopGI_FinishQueuedDraw }
procedure TMessageLoopGI.FinishQueuedDraw;
begin
  RegionDrawPending := False;
end;
{ @end $4BE720 }

{ @routine $4BE734 TMessageLoopGI_CommitFrameDraw }
procedure TMessageLoopGI.CommitFrameDraw;
begin
  RootUiObject.CommitFrameDraw;
end;
{ @end $4BE734 }

{ @routine $4BE74C TMessageLoopGI_ErasePreviousFrame }
procedure TMessageLoopGI.ErasePreviousFrame;
begin
  RootUiObject.ErasePreviousFrame;
end;
{ @end $4BE74C }

{ @routine $4BE764 TMessageLoopGI_PrepareFrameDraw }
procedure TMessageLoopGI.PrepareFrameDraw;
begin
  RootUiObject.PrepareFrameDraw;
end;
{ @end $4BE764 }

{ @routine $4BE77C TMessageLoopGI_Run }
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
{ @end $4BE77C }

{ @routine $4BEFD4 TMessageLoopGI_RunContinuous }
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
{ @end $4BEFD4 }

{ @routine $4BF7D0 TMessageLoopGI_AdvanceTimerTick }
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
{ @end $4BF7D0 }

{ @routine $4BFA70 TMessageLoopGI_DrawFrame }
procedure TMessageLoopGI.DrawFrame;
begin
  if UpdateRects.FirstRect <> nil then
  begin
    DrawQueuedUpdateRects;
    FinishQueuedDraw;
  end;
end;
{ @end $4BFA70 }

{ @routine $4BFA98 TMessageLoopGI_Present }
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
{ @end $4BFA98 }

{ @routine $4BFB78 TMessageLoopGI_ProcessWindowMessage }
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

  // @nested $4BFB04 ConvertMousePointToViewport
  procedure ConvertMousePointToViewport; // @addr $4BFB04 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4BFD6E 0x4BFED2 0x4BFF1C 0x4BFF7B 0x4BFFFF 0x4C0183 0x4C01E6 0x4C02A9" @note "Nested ProcessWindowMessage helper; scales or offsets its captured mouse point."
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
{ @end $4BFB78 }

{ @routine $4C0B88 TMessageLoopGI_CaptureScreenshot }
procedure TMessageLoopGI.CaptureScreenshot;
var
  Digits: AnsiString;
  DigitCount: Integer;
  Extension, BaseName, FileName: AnsiString;
  Buffer: TGraphBufGR;

  // @nested $4C0A14 FindFreeScreenshotName
  function FindFreeScreenshotName: Boolean; // @addr $4C0A14 @ida "bool __usercall $name@<al>(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x4C0C40" @note "Nested CaptureScreenshot helper; updates the captured filename strings."
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
{ @end $4C0B88 }

{ @routine $4C0DFC TMessageLoopGI_RequestClose }
procedure TMessageLoopGI.RequestClose(ResultCode: Integer);
begin
  ExitCode := ResultCode;
end;
{ @end $4C0DFC }

{ @routine $4C0E18 TMessageLoopGI_SetHelpCallback }
procedure TMessageLoopGI.SetHelpCallback(Callback: TObjectHelpEventGI);
begin
  ContentPanel.SetHelpCallbackRecursive(Callback);
end;
{ @end $4C0E18 }

{ @routine $4C0E38 TMessageLoopGI_GetByName }
function TMessageLoopGI.GetByName(const Name: WideString): TObjectGI;
begin
  Result := ContentPanel.FindByNameRecursive(Name);
  if Result = nil then raise Exception.Create('TMessageLoopGI.GetByName. Name=' + Name);
end;
{ @end $4C0E38 }

{ @routine $4C0F10 TMessageLoopGI_FindControlByPath }
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
{ @end $4C0F10 }

{ @routine $4C0FD0 TMessageLoopGI_SetFocusedControl }
procedure TMessageLoopGI.SetFocusedControl(Control: TObjectGI);
begin
  if FocusedControl = Control then Exit;
  if FocusedControl <> nil then FocusedControl.OnFocusLost;
  FocusedControl := Control;
  if FocusedControl <> nil then FocusedControl.OnFocusGained;
end;
{ @end $4C0FD0 }

{ @routine $4C1020 TMessageLoopGI_SetHoveredControl }
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
{ @end $4C1020 }

{ @routine $4C107C TMessageLoopGI_ProcessNamedControlEvent }
procedure TMessageLoopGI.ProcessNamedControlEvent(ControlName: WideString; EventKind, Param1, Param2: Integer);
begin
end;
{ @end $4C107C }

{ @routine $4C10C4 TMessageLoopGI_OnOpen }
procedure TMessageLoopGI.OnOpen;
begin
  IsOpen := True;
end;
{ @end $4C10C4 }

{ @routine $4C10D8 TMessageLoopGI_OnClose }
procedure TMessageLoopGI.OnClose;
begin
  IsOpen := False;
end;
{ @end $4C10D8 }

{ @routine $4C10EC TMessageLoopGI_ProcessCallbackTimers }
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
{ @end $4C10EC }

{ @routine $4C11C0 TMessageLoopGI_SelectMusic }
procedure TMessageLoopGI.SelectMusic;
begin
end;
{ @end $4C11C0 }

{ @routine $4C11CC TMessageLoopGI_ScheduleCallbackTimer }
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
{ @end $4C11CC }

{ @routine $4C1278 TMessageLoopGI_CancelCallbackTimer }
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
{ @end $4C1278 }

{ @routine $4C1310 TMessageLoopGI_UpdateCallbackTimer }
procedure TMessageLoopGI.UpdateCallbackTimer(Timer: PCallbackTimerGI; DelayMs, RepeatMs: Integer);
var Current: PCallbackTimerGI;
begin
  Current := Timer;
  if (TimerTick + Cardinal(DelayMs) = Current.DueTick) and (Current.RepeatMs = RepeatMs) then Exit;
  Current.DueTick := TimerTick + Cardinal(DelayMs);
  Current.RepeatMs := RepeatMs;
  ReinsertCallbackTimer(Current);
end;
{ @end $4C1310 }

{ @routine $4C136C TMessageLoopGI_ReinsertCallbackTimer }
procedure TMessageLoopGI.ReinsertCallbackTimer(Timer: PCallbackTimerGI);
var Current, Before: PCallbackTimerGI;
begin
  Current := Timer;
  if Current.Prev <> nil then Current.Prev.Next := Current.Next;
  if Current.Next <> nil then Current.Next.Prev := Current.Prev;
  if LastTimer = Current then LastTimer := Current.Prev;
  if FirstTimer = Current then FirstTimer := Current.Next;
  if FirstTimer = nil then
  begin
    FirstTimer := Current;
    LastTimer := Current;
    Current.Prev := nil;
    Current.Next := nil;
    Exit;
  end;
  if LastTimer.DueTick < Current.DueTick then
  begin
    LastTimer.Next := Current;
    Current.Prev := LastTimer;
    Current.Next := nil;
    LastTimer := Current;
    Exit;
  end;
  if FirstTimer.DueTick >= Current.DueTick then
  begin
    Current.Prev := nil;
    Current.Next := FirstTimer;
    FirstTimer.Prev := Current;
    FirstTimer := Current;
    Exit;
  end;
  begin
    Before := LastTimer.Prev;
    while Current.DueTick <= Before.DueTick do Before := Before.Prev;
    Current.Prev := Before;
    Current.Next := Before.Next;
    Before.Next.Prev := Current;
    Before.Next := Current;
  end;
end;
{ @end $4C136C }

{ @routine $4C14DC TMessageLoopGI_RefreshTimerTick }
procedure TMessageLoopGI.RefreshTimerTick;
begin
  TimerTick := timeGetTime;
end;
{ @end $4C14DC }

{ @routine $4C14F4 TMessageLoopGI_SetCursorImage }
procedure TMessageLoopGI.SetCursorImage(const ImagePath: WideString; HotSpot: TPoint);
begin
  if CustomCursorEnabled then
  begin
    (CursorControl as TCursorGI).SetImagePath(ImagePath);
    CursorControl.SetOrigin(HotSpot);
    CursorImagePath := ImagePath;
  end;
end;
{ @end $4C14F4 }

{ @routine $4C1550 TMessageLoopGI_SetCursorByName }
procedure TMessageLoopGI.SetCursorByName(const Name: WideString);
var Cursor: TCursorUnit;
begin
  if CustomCursorEnabled then
  begin
    Cursor := FindCursorByName(Name);
    SetCursorImage(Cursor.ImagePath, Cursor.HotSpot);
  end;
end;
{ @end $4C1550 }

{ @routine $4C158C TMessageLoopGI_IsCursorImageSelected }
function TMessageLoopGI.IsCursorImageSelected(const RegisteredName: WideString): Boolean;
var Cursor: TCursorUnit;
begin
  Cursor := FindCursorByName(RegisteredName);
  Result := Cursor.ImagePath = CursorImagePath;
end;
{ @end $4C158C }

{ @routine $4C15C0 TMessageLoopGI_IsCursorActive }
function TMessageLoopGI.IsCursorActive: Boolean;
begin
  Result := CursorControl.Active;
end;
{ @end $4C15C0 }

{ @routine $4C15DC TMessageLoopGI_SetCursorActive }
procedure TMessageLoopGI.SetCursorActive(Enabled: Boolean);
begin
  if CursorControl.Active <> Enabled then CursorControl.SetActive(Enabled);
end;
{ @end $4C15DC }

{ @routine $4C1608 TMessageLoopGI_CaptureCursorState }
procedure TMessageLoopGI.CaptureCursorState(State: PCursorStateGI);
begin
  State^.ImagePath := CursorImagePath;
  State^.Active := IsCursorActive;
  State^.HotSpot := CursorControl.OriginPoint;
  State^.Position := CursorControl.LocalPosition;
end;
{ @end $4C1608 }

{ @routine $4C1660 TMessageLoopGI_RestoreCursorState }
procedure TMessageLoopGI.RestoreCursorState(State: PCursorStateGI);
begin
  if CustomCursorEnabled then
  begin
    SetCursorImage(State^.ImagePath, State^.HotSpot);
    SetCursorActive(State^.Active);
    CursorControl.SetPosition(State^.Position);
  end;
end;
{ @end $4C1660 }

{ @routine $4C16AC TMessageLoopGI_UpdateCursorPosition }
procedure TMessageLoopGI.UpdateCursorPosition;
var Point: TPoint;
begin
  GetCursorPos(Point);
  if Direct3DPresentParameters.Windowed then ScreenToClient(MainWindowHandle, Point);
  CursorControl.SetPosition(Point);
end;
{ @end $4C16AC }

{ @routine $4C16EC TMessageLoopGI_GetCursorPoint }
function TMessageLoopGI.GetCursorPoint: TPoint;
begin
  Result := CursorControl.LocalPosition;
end;
{ @end $4C16EC }

{ @routine $4C1710 TMessageLoopGI_SetSystemCursorPosition }
procedure TMessageLoopGI.SetSystemCursorPosition(Point: TPoint);
begin
  SetCursorPos(Point.X, Point.Y);
end;
{ @end $4C1710 }

{ @routine $4C1738 TMessageLoopGI_ConsumeTimerTickChange }
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
{ @end $4C1738 }

{ @routine $4C176C TMessageLoopGI_QueryPointOcclusionState }
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
{ @end $4C176C }

{ @routine $4C1828 TMessageLoopGI_FreeSavedPixels16 }
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
{ @end $4C1828 }

{ @routine $4C1864 TMessageLoopGI_RestoreSavedPixels16 }
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
{ @end $4C1864 }

{ @routine $4C18CC TMessageLoopGI_FreeSecondaryPixelBuffer }
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
{ @end $4C18CC }

{ @routine $4C1914 TMessageLoopGI_ResetSecondaryPixelCount }
procedure TMessageLoopGI.ResetSecondaryPixelCount;
begin
  if SecondaryPixelCount < 1 then Exit;
  SecondaryPixelCount := 0;
end;
{ @end $4C1914 }

{ @routine $4C1938 TMessageLoopGI_FreeSavedLines }
procedure TMessageLoopGI.FreeSavedLines;
var Index: Integer;
begin
  for Index := 0 to High(SavedLines) do
    FreeFromHeapEC(SavedLines[Index].Heap, SavedLines[Index].Pixels);
  SavedLines := nil;
  SavedLineCount := 0;
end;
{ @end $4C1938 }

{ @routine $4C19B4 TMessageLoopGI_AddSavedLine }
procedure TMessageLoopGI.AddSavedLine(First, Last: TPoint; Pixels: Pointer);
begin
  if High(SavedLines) + 1 = SavedLineCount then SetLength(SavedLines, SavedLineCount + 100);
  SavedLines[SavedLineCount].First := First;
  SavedLines[SavedLineCount].Last := Last;
  SavedLines[SavedLineCount].Pixels := Pixels;
  SavedLines[SavedLineCount].Heap := GetProcessHeap;
  Inc(SavedLineCount);
end;
{ @end $4C19B4 }

{ @routine $4C1AA0 TMessageLoopGI_RestoreSavedLines }
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
{ @end $4C1AA0 }

{ @routine $4C1B64 TMessageLoopGI_ResetSavedLineCount }
procedure TMessageLoopGI.ResetSavedLineCount;
begin
  SavedLineCount := 0;
end;
{ @end $4C1B64 }

{ @routine $4C1B7C TMessageLoopGI_ProcessMouseWheel }
procedure TMessageLoopGI.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
end;
{ @end $4C1B7C }

{ @routine $4C1B9C TMessageLoopGI_ClearTransientControl }
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
{ @end $4C1B9C }

{ @routine $4C1C08 TMessageLoopGI_InvalidateTransientControl }
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
{ @end $4C1C08 }

{ @routine $4C1C4C TMessageLoopGI_InitializeDefaults }
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
{ @end $4C1C4C }

{ @routine $4C1E58 TMessageLoopGI_InitializeFromConfig }
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
{ @end $4C1E58 }

{ @routine $4C2164 TMessageLoopGI_InitializeLayout }
procedure TMessageLoopGI.InitializeLayout;
begin
  RootUiObject.UpdateAutoGeometry;
end;
{ @end $4C2164 }

{ @routine $4C217C TMessageLoopGI_UpdateActionCursor }
procedure TMessageLoopGI.UpdateActionCursor(CanTake: Boolean);
begin
end;
{ @end $4C217C }

{ @routine $4C218C TMessageLoopGI_GetActionParentLoop }
function TMessageLoopGI.GetActionParentLoop: TMessageLoopGI;
begin
  Result := nil;
end;
{ @end $4C218C }

{ @routine $4C21A4 TMessageLoopGI_QueueUiCode }
procedure TMessageLoopGI.QueueUiCode(Block: TBlockParEC; RefreshMouse: Boolean);
begin
  DeferredCodeBlocks.Add(Block);
  if RefreshMouse then RefreshMouseAfterCode := True;
end;
{ @end $4C21A4 }

{ @routine $4C21D8 TMessageLoopGI_RefreshMouseDispatch }
procedure TMessageLoopGI.RefreshMouseDispatch;
var Point: TPoint;
begin
  Point.X := LastMousePosition.X;
  Point.Y := LastMousePosition.Y;
  RootUiObject.ProcessMouseMove(0, Point);
end;
{ @end $4C21D8 }

{ @routine $4C2208 TMessageLoopGI_ExecuteUiCode }
procedure TMessageLoopGI.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
end;
{ @end $4C2208 }

end.
