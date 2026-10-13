unit HelpIntfs;

interface

type
  THelpManager = class(TInterfacedObject) // @size 0x30
  public
    constructor Create;
    destructor Destroy;
    procedure DoSoftShutDown;
    function CallSpecialWinHelp(Handle: LongInt; const HelpFile: AnsiString; Command: Word; Data: LongInt): Boolean;
    procedure ShowContextHelp(const ContextID: Longint; const HelpFileName: AnsiString);
    procedure Release(const ViewerID: Integer);
  end;

procedure EnsureHelpManager;

procedure GetHelpSystem; // @nameonly

procedure DefaultContextHelp(const ContextId: LongInt; const HelpFileName: AnsiString); // @nameonly

implementation
end.
