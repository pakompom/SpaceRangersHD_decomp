unit Clipbrd;
// VCL binding. Native TClipboard VMT $430130 agrees with Delphi 2007.
interface
uses Classes, Windows;
type
  TClipboard = class(TPersistent) // @size $10
  public
    FOpenRefCount: Integer; // @offset $4
    FClipboardWindow: Cardinal; // @offset $8
    FAllocated: Boolean; // @offset $C
    FEmptied: Boolean; // @offset $D
    procedure Close; virtual; // @addr $4301DC @slot $14
    procedure Open; virtual; // @addr $430208 @slot $18
  end;
function Clipboard: TClipboard; // @addr $4305C4
implementation
end.
