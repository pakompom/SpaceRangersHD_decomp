unit Contnrs;

interface

uses System, Classes;

type
  TOrderedList = class(TObject) // @size 0x08
  private
    FList: TList; // @offset 0x04
  protected
    function PopItem: Pointer; virtual; // @slot 0x04
    function PeekItem: Pointer; virtual; // @addr 0x0041E14C @slot 0x08
  public
    function Pop: Pointer; // @addr $41E0C0
    constructor Create;
    destructor Destroy; override; // @addr $41E11C
  end;

  TStack = class(TOrderedList) // @size 0x08
  protected
    procedure PushItem(AItem: Pointer); virtual; // @addr 0x0041E180 @slot 0x0
  end;

implementation
end.
