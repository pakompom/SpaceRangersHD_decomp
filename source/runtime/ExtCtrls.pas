unit ExtCtrls;

interface

type
  TTimer = class(TComponent) // @size 0x44
  public
    constructor Create(AOwner: TComponent); override; // @slot 0x2C
    destructor Destroy;
    procedure WndProc(var Msg: TMessage);
    procedure UpdateTimer;
    procedure SetOnTimer; // @nameonly
  end;

implementation
end.
