unit Contnrs;
// Unit bracket (inferred): .text 0x0041DFF8..0x0041E188; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System, Classes;

type
  TOrderedList = class(TObject) // @size 0x08
  private
    FList: TList; // @offset 0x04
  protected
    // Slot 0 is the abstract PushItem dispatcher; its shared RTL target is
    // not a routine owned by Contnrs.
    function PopItem: Pointer; virtual; // @slot 0x04
    function PeekItem: Pointer; virtual; // @addr 0x41E14C @slot 0x08 @calls "0x41E168"
  public
    function Pop: Pointer; // @addr $41E0C0
    constructor Create;
    destructor Destroy; override; // @addr $41E11C
  end;

  TStack = class(TOrderedList) // @size 0x08
  protected
    procedure PushItem(AItem: Pointer); virtual; // @addr 0x41E180 @slot 0x0
  end;

implementation
end.
