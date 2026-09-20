# Delphi declarations and native annotations

This reference describes the Pascal syntax and annotations understood by the
tooling. For setup and build commands, see [development.md](development.md).
Offsets, sizes and addresses refer to the original Win32 binary.

## Source structure

Use ordinary `unit`, `interface`, optional `uses`, declarations, `implementation`
and `end.` sections. The tools read interface declarations, annotated unit-private
globals and annotated nested routines. The builder checks implementation signatures
against the interface and compiles all implementation text.

Native implementations carry ownership markers:

```pascal
{ @routine $78CB00 TPlanet_UpdateMarketState }
procedure TPlanet.UpdateMarketState;
begin
  { recovered code }
end;
{ @end $78CB00 }
```

A recovered nested routine uses `// @nested $Address Name`. An unrecovered one
uses `// @unrecovered $Address Name` with an explicit failure body and is excluded
from recovered-byte totals. Put its `@addr` and ABI annotations on the local
declaration. Private source helpers need no native address.

`source/Rangers.dpr` owns the program's main block, globals, classes and helpers.
Use the same ownership markers around its main `begin`/`end` block and helper
bodies. The parameterless entry declaration and compiler exception symbols live
in the unlinked `Rangers.pas` companion.

DLL imports use ordinary `external` declarations:

```pascal
function QueryAttributes(const FileName): Cardinal; stdcall;
  external 'kernel32.dll' name 'GetFileAttributesA'; // @addr $407E8C
```

`@addr` identifies the native import thunk; the matcher checks the DLL/export
binding.

## Annotations and layouts

Write annotations as `@key value` in Delphi comments (`//`, `{ }`, or `(* *)`),
within a declaration or directly after its last token. Quote values containing
spaces. Addresses, offsets and sizes accept `0xHEX`, `0XHEX`, `$HEX` and decimal.
Routine addresses also accept `sub_HEX`, interpreted as a hexadecimal literal.
`@note "..."` adds text to a routine's or global's IDA comment.

```pascal
type
  TStar = class; // opaque: references are pointers

  TPointF = packed record // @size 0x8
    X: Single; // @offset 0x00
    Y: Single; // @offset 0x04
  end;

  TShip = class // @partial
    Position: TPointF; // @offset 0x14
    CurrentStar: TStar; // @offset 0x24
  end;
```

Fields require explicit offsets from the instance or record start. Gaps become
padding. A class has a `Vmt` pointer at offset zero; class-valued fields are pointers
and records remain inline. Inheritance retains known parent fields at their
original offsets. Overlaps, duplicate names, unknown types and invalid sizes are
errors.

Use `@size` for a complete byte size and `@partial` for a known prefix. A partial
IDA structure ends at its last known field. `record` and `packed record` retain
Delphi alignment in generated source; identical field offsets can still produce
different alignment for local variables.

Field-only old-style `object` types are also supported, without inheritance,
methods or properties. They use record storage and ABI in the annotation model;
generated Pascal preserves `object`, since DCC32 advances its anonymous-symbol
counter for an object declaration but not for a named record.

An opaque `TFoo = class;` can be completed later in the same unit, allowing mutual
references. Opaque records (`TMessage = record;`) and their aliases support pointers
and `var`/`out` parameters, but require a complete size for inline storage or array
elements.

### Interfaces

Opaque interfaces use `IFoo = interface;`. Defined interfaces support inheritance,
GUIDs, methods, properties and forward declarations completed in the same unit.
Interface references occupy four bytes. Dispatch slots follow inherited methods;
`IInterface` supplies the three COM base slots and is the default ancestor.
Interface methods have no native implementation address.

Register-convention interface results have an inferred hidden result pointer,
including results using aliases. The compiler emits reference counting for defined
interfaces and RTL bindings. Matching checks all 16 GUID bytes and the interface RTTI flags,
method counts and relocated parent chain. Extended method RTTI is unresolved.

### Arrays, enums and sets

Supported types include fixed arrays (`array[0..7] of T`), pointer aliases
(`PItem = ^TItem`), scalar aliases, explicitly sized enums and sets:

```pascal
  TBit = (bFirst=0, bThird=2); // @size 0x1
  TBits = set of TBit; // @size 0x1
  TOwners = set of 0..7; // @size 0x1
  TItems = set of 0..79; // @size 0xA
```

Sets use enum ordinals or a zero-based integer range as bit positions. Ranges
support up to 256 bits and must fit the declared storage, including DCC32's
rounding of three-byte sets to four bytes. IDA uses bitmask enums for sizes 1, 2,
4 and 8, and byte arrays for other sizes.

Generated source preserves integer-range sets for membership and singleton
arguments; enum sets use scalar views for generated bitwise expressions.
Sets of 1, 2 or 4 bytes use the corresponding integer ABI for value parameters
and results, returning in AL, AX or EAX under `register`. Larger sets require
`@ida` and are passed by address. Value-parameter alignment also depends on whether
DCC32 parses source or loads a DCU; see the branch settings in
[Build and match](development.md#build-and-match).

### Strings and dynamic arrays

In IDA, `WideString` maps to a pointer to 16-bit characters and `AnsiString` to a
pointer to 8-bit characters. Dynamic arrays (`array of T`) map to pointers to their
first element. These representations omit runtime headers and reference counts.
Use explicit string types in native declarations; plain `String` is ambiguous.

A named dynamic-array parameter is one pointer. An inline `array of T` parameter
is an open array with a separate high index; `array of const` uses `TVarRec`
elements. Register-convention string and dynamic-array results have an inferred
hidden result pointer, appended after the explicit parameters.

### Procedural and class references

Plain procedural types such as `TCallback = function(Context: Pointer): Integer;`
occupy four bytes. Parameter modes, results and calling conventions determine the
native function-pointer type and remain intact in generated Delphi.

Register-convention method pointers (`of object`) occupy eight bytes: `Code` at
offset zero and `Data` at offset four. The signature receives its context in EAX.
Value and const parameters use eight inline stack bytes without consuming an
argument register; var/out parameters pass a pointer. Register callbacks pass
value records larger than four bytes by reference while retaining the Pascal
value declaration. Callbacks share the routine ABI rules, including hidden
results. Non-register method pointers and variant-record layouts need further
native layout support.

Class references such as `TItemClass = class of TItem;` require a declared class,
which may be opaque. They use the four-byte pointer ABI and appear as `void *`
VMT addresses in IDA, distinct from pointers to class instances.

## Calling conventions

Default parameter values are retained in generated interfaces; implementations
may omit them. They leave the native parameter ABI unchanged.

Win32 Delphi `register` is the default for top-level routines and methods.
Eligible scalar/pointer arguments use EAX, EDX and ECX (or their byte/word parts),
then four-byte stack slots pushed left to right and removed by the callee. See the
[Win32 Delphi parameter rules](https://docwiki.embarcadero.com/RADStudio/Sydney/en/Program_Control_(Delphi)#Register_Convention).
`var`/`out` parameters add indirection; untyped `var Buffer` and `const Buffer`
parameters carry an address.

`Single`, `Double` and `Extended` value/const parameters occupy stack slots rounded
to four bytes without consuming argument registers. Their results return in x87
`ST(0)`. The generator represents ten-byte `Extended` parameters as `_TBYTE` in
twelve-byte slots and their results as `double`. Hex-Rays models x87 registers as
eight bytes, so this representation loses precision that the Pascal declaration
retains. IDA's `long double` is not equivalent under the database compiler settings.

Value/const `Int64`/`UInt64` parameters occupy eight-byte stack slots; later eligible
arguments can still use available registers. Results use EDX:EAX. Aliases follow
the same rules.

Under `register`, value records larger than four bytes are passed by address.
Records of one, two or four bytes use the corresponding scalar registers; other
small value records occupy a rounded stack slot. Record results of one, two or
four bytes return in AL, AX or EAX; other sizes use a hidden result pointer after
the explicit parameters. These rules need a complete record size.

Nested register routines add a parent-frame pointer above their other stack
arguments. Their generated cleanup count excludes that pointer, which the caller
removes. This follows the lexical Pascal declaration and requires no `@ida` or
`@stackpop` annotation. Explicit `@ida` overrides retain their supplied ABI and
need `@stackpop` when their call-site cleanup differs from the signature's default.

Scalar/pointer `cdecl` and `stdcall` are supported, including stack-passed
floating-point and 64-bit values. Non-register hidden results, unsupported
parameter types and other ABIs require `@ida` with `$name` as the generated name:

```pascal
procedure Special; // @addr 0x400100 @ida "void __usercall $name(void *ctx@<eax>);"
```

For non-void `__usercall`/`__userpurge` signatures, place the return location after
the routine name, such as `$name@<eax>` or `$name@<al>`. `check` catches missing
locations on simple scalar/pointer signatures; IDA validates the complete native
C declaration during `diff` or `apply`.

For an unresolved ABI, `@nameonly` imports the name and source comment while
leaving the prototype unchanged. It cannot accompany an explicit calling
convention or `@ida`.

## Methods and VMT slots

Declare instance methods inside their owning class:

```pascal
type
  TEquipment = class // @partial
  public
    EquippedFlag: Byte; // @offset 0x49
    function GetLevel: Integer; // @addr 0x7F256C
    function GetStatBonus(BonusKind: Byte): Integer; // @addr 0x7F3354
  end;
```

The importer supplies `Self` in EAX; explicit arguments begin in EDX and ECX.
For example, `procedure Init(Weight: Integer; Level, Owner: Byte);` places Weight
in EDX, Level in CL and Owner in a four-byte stack slot. Omit `Self` from the
Pascal declaration. Methods and properties consume no instance storage.

Accepted method directives are `virtual`, `override`, `reintroduce` and `abstract`.
Add `@slot 0x04` to record a verified virtual or override method's byte offset from
the VMT dispatch pointer. Offsets must be nonnegative and four-byte aligned;
negative RTL slots such as Destroy are unsupported. Directives alone assign no slots.

Known slots produce a reserved `Class_VMT` structure and type the instance's `Vmt`
pointer. Descendants inherit slots, with overrides replacing native signatures.
An explicit override offset must agree with the inherited slot. Unknown gaps
remain padding, and the table ends after the last known slot. Slot methods need
a usable inferred or explicit prototype; `@nameonly` is insufficient.

Abstract slots use `virtual; abstract;` or `override; abstract;`, with `@slot` and
no `@addr`. They contribute an inherited VMT signature without annotating the
shared RTL abstract-error routine. Only `@ida`, `@note` and `@calls` are allowed
as additional annotations. Recover the ABI from concrete implementations and
call sites:

```pascal
function GetName: WideString; virtual; abstract; // @slot 0x24
```

Non-register method ABIs require `@ida` for the complete signature, including
`Self` and hidden parameters. Class methods (`class function` / `class procedure`)
receive the class's VMT address as `Self` in EAX and otherwise follow the same rules.
Static methods, class constructors/destructors and record methods are unsupported.

IDA symbols use `Class_Method` for methods and declared names for top-level
routines and globals. Names must be unique across headers; units and filenames
are not added as prefixes. Source paths appear in managed comments.

Register constructors infer `SelfOrClass` in EAX, the allocation flag in DL and
the returned instance in EAX. Destructors infer `Self` in EAX and signed destruction
flags in DL. Explicit parameters follow these hidden arguments:

```pascal
constructor Create; // @addr 0x400300
destructor Destroy; override; // @addr 0x400400
```

## Call-site ABI overrides

For a call with incorrectly inferred arguments, add `@calls "0x487B6E 0x482E32"`
to the callee declaration. Each address must be a call instruction inside an IDA
function and unique across headers. Verify each target and its full ABI, including
stack cleanup. The importer applies the signature to the call operand and sets
the stack delta to zero for caller cleanup or the stack argument area for callee
cleanup. Manual edits follow the [sync conflict rules](#synchronizing-with-ida).

For exceptional split cleanup, add `@stackpop 0x4` alongside `@calls`. It overrides
the callee's cleanup count at those calls while keeping every argument in the
prototype. Ordinary nested register routines infer this count automatically.
The explicit count must be four-byte aligned, fit the declared stack argument
area, and agree with the native
return and caller cleanup. It cannot accompany `@countedstack`.

For a helper with a register count and that many trailing four-byte stack
arguments, use `@countedstack "Count:WideString"`. The count names an
Integer/Cardinal parameter in EAX, EDX or ECX; the element type must be a four-byte
scalar or pointer. Supply a variadic `__usercall` `@ida` declaration with no fixed
stack arguments. The importer specializes direct calls as `__userpurge`, using
left-to-right push order and callee cleanup.

Append `:caller` for caller cleanup and nearest-first stack order, for example
`@countedstack "DimensionCount:Integer:caller"` for DCC32's `@DynArraySetLength`.
The first dimension occupies IDA stack offset zero, the caller removes the slots,
and calls retain `__usercall`.

Both forms require a positive immediate count (1..256) within the preceding
16 instructions of the same straight-line block. Branches, register clobbers,
unrecognized instructions and unresolved counts stop import before any writes.
`@countedstack` cannot accompany `@calls`; indirect calls need separate analysis.

## Globals and library identities

Declare each global once in its owning unit, with `@addr` pointing to its storage:

```pascal
var
  CurrentShip: TShip; // @addr 0x880AFC
  Points: array[0..7] of TPointF; // @addr 0x880BFC
```

Use ordinary references such as `aGalaxy.Galaxy` from other units. Unit-private
globals can appear in the implementation section with the same annotation; they
retain that placement in generated source. Routine stack locals need no `@addr`.

Globals define native data layout and types. The importer combines complete data
items into the declared aggregate, replacing interior labels. The range must
exclude code. An unchanged aggregate previously imported by the tool can be resized.

Typed constants can carry `@addr`. Keep their initializer in the owning unit's
interface, for example `const Table: TLookupTable = (...); // @addr $880CFC`.
They compile as Delphi constants and import as typed storage. Matching checks the
entire declared constant, including elements beyond an indexed load's width.
AnsiString fields are checked through relocated static literals, including lengths
and terminators; WideString fields use native initializer descriptors. Other
pointer-bearing constant storage is unresolved.

When overlapping biased array bases make a reference ambiguous, add
`@indexrefs "$59C6A4"` to the array declaration. List native instruction addresses
and explain the index bounds using loop or case-dispatch evidence. The matcher
checks indexed displacement, element stride, relocation and the complete constant
contents. The rebuilt operand must refer to the same linked array. The annotation
identifies storage; index bounds require separate evidence.

Initialized variables use ordinary Delphi syntax, for example
`var EncodedPlayer: Cardinal = $B1CD15D3; // @addr $87B050`. Source generation
preserves their values, and matching checks them, including managed-string
initializer descriptors.

DCC32 generates cross-unit address cells. The matcher identifies them from PE
relocations and declared storage ranges, then checks the referenced global and
offset, including references into arrays and records. Direct and indirect accesses
also help recover unit ownership; see the
[two-unit compiler control](../tests/delphi/units/UnitReferences.dpr).

Compiler unit entries use `// @unit-initialization $ADDR` and
`// @unit-finalization $ADDR` alongside Delphi `initialization`/`finalization`
sections or managed globals. Select them with `./decomp match Unit.initialization`
or `./decomp match Unit.finalization`; they need no ordinary procedure declaration.

Matched RTL routines obtain their addresses from `reference/library_matches.json`
and need no `@addr`. The catalog relates native entries, DCC32 MAP symbols and
readable declaration names. Matching can discover missing library identities from
native bodies. Overloads require unique matches of calls, data and literals.

## Comments

Use prose comments for non-obvious contracts, ownership, encodings and uncertain
meanings. Examples include a getter that extends a list, an output left unwritten
on failure, or a result that borrows storage. Avoid repeating names, types or the
code's steps. Keep native annotations; omit migration history and routine
verification logs.

## Synchronizing with IDA

For commands and database setup, see the
[IDA workflow](development.md#optional-ida-integration).

On first sync, signatures and global types replace IDA/Hex-Rays inferred types.
Definite types from user edits or type libraries produce conflicts. After import,
the database stores the last applied value of each managed annotation. Source
changes apply when IDA still matches that baseline; independent IDA edits produce
conflicts showing both values.

To retain an IDA edit, copy it into the source and run `diff` again. To choose the
source value, use `--take-header KEY`, for example
`./decomp sync apply --take-header prototype:400100`. Repeat the option for multiple
conflicts, or use it with `diff` to preview resolutions.

Removing declarations or call annotations removes their unchanged imported names,
types, comments and stack overrides. Independently edited values produce conflicts;
unrelated annotations and binary bytes remain untouched.

### Data and function repair

Adjacent globals can split an inferred IDA data item when they cover the entire
item without gaps. Partial coverage, definite types and independently edited
imports are protected.

Routine addresses normally must be IDA function entries. The importer can trim
an alignment prefix shorter than 16 bytes, containing only `NOP` or `MOV EAX,EAX`,
before an aligned `PUSH EBP; MOV EBP,ESP`. Prefixes with real references, user
annotations or another declaration are rejected. Automatic offset guesses over
independently referenced, length-prefixed UTF-16 literals are ignored.

For a missing function, `@codeend $Address` records the exclusive end of a
contiguous native body. Sync can recreate an unowned Delphi frame entry with a
direct native call reference and repair automatic data guesses within it. The
range must decode completely and end at RET; existing chunks, other declarations
and annotated data prevent the repair.

`diff` previews these repairs; `apply` performs them before importing declarations.
Removing a declaration does not undo a function repair.

## Unit coverage and address brackets

`./decomp coverage` combines declarations with RTTI/VMT evidence and reports
conflicting unit placement. Counts measure annotation coverage. Evidence comes
from `reference/unit_ownership.json` and `reference/library_matches.json`; the
library comparisons cover native entry spans and exclude separate tail chunks.

Generated `// Unit bracket (inferred):` comments record inclusive evidence spans,
not complete unit boundaries. They are ordinary comments. Refresh them with
`./decomp coverage --annotate-ranges`; `--ranges PATH` and `--limits PATH` export
coverage and boundary CSVs.
