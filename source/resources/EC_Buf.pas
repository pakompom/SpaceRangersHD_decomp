unit EC_Buf;
// Unit bracket (inferred): .text 0x0082EA5C..0x008304FB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_File, EC_Struct;

type
  TBufEC = class(TObjectEx) // @size 0x14
  public
    DataSize: Integer; // @offset 0x04
    Capacity: Integer; // @offset 0x08
    Position: Integer; // @offset 0x0C
    Data: Pointer; // @offset 0x10

    constructor Create; // @addr 0x82EAB0 @ida "TBufEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x82EAF4 @ida "void __usercall $name(TBufEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x82EB30
    function IsAtEnd: Boolean; // @addr 0x82EBD8
    procedure SetSize(NewSize: Integer); // @addr 0x82EB70 @note "Nonpositive sizes clear the buffer; shrinking clamps Position."
    procedure SetPosition(NewPosition: Integer); // @addr 0x82EC00
    procedure EnsureWriteCapacity(AddedBytes: Integer); // @addr 0x82ECB4 @note "AddedBytes must be positive. Extends DataSize without advancing Position."
    procedure EnsureWriteCapacityAtOffset(Offset, AddedBytes: Integer); // @addr 0x82EDDC @note "AddedBytes must be positive; Offset must be in 0..DataSize. Position is unchanged."
    procedure EnsureReadable(Bytes: Integer); // @addr 0x82EF40
    procedure EnsureReadableAtOffset(Offset, Bytes: Integer); // @addr 0x82EFF0 @note "Rejects nonpositive counts and ranges ending past DataSize; does not reject negative Offset."

    procedure SetByteAt(Offset: Integer; Value: Byte); // @addr 0x82F0CC
    procedure SetInt32At(Offset: Integer; Value: Integer); // @addr 0x82F108
    function GetByteAt(Offset: Integer): Byte; // @addr 0x82F69C
    function GetUInt32At(Offset: Integer): Cardinal; // @addr 0x82F6D4
    function GetInt32At(Offset: Integer): Integer; // @addr 0x82F70C

    // Sequential operations use Position, including writes into existing data.
    procedure AddBytes(Source: Pointer; ByteCount: Integer); // @addr 0x82F144
    procedure AddByte(Value: Byte); // @addr 0x82F344
    procedure AddWord(Value: Word); // @addr 0x82F38C
    procedure AddInt32(Value: Integer); // @addr 0x82F3D8
    procedure AddInteger(Value: Integer); // @addr 0x82F420
    procedure AddDWord(Value: Cardinal); // @addr 0x82F4FC
    procedure AddIntegerValue(Value: Integer); // @addr 0x82F544
    procedure AddSingle(Value: Single); // @addr 0x82F58C @ida "void __userpurge $name(TBufEC *Self@<eax>, float Value@<^0>);"
    procedure AddDouble(Value: Double); // @addr 0x82F5D0 @ida "void __userpurge $name(TBufEC *Self@<eax>, double Value);"
    procedure AddBoolean(Value: Boolean); // @addr 0x82F618
    procedure AddBuffer(Value: TBufEC); // @addr 0x82F660 @note "Writes a four-byte size followed by the entire source payload, ignoring its Position."

    procedure AddAnsiStringZ(const Value: AnsiString); // @addr 0x82F18C
    procedure AddWideStringZ(const Value: WideString); // @addr 0x82F200
    procedure AddAnsiStringRaw(const Value: AnsiString); // @addr 0x82F26C
    procedure AddWideStringRaw(const Value: WideString); // @addr 0x82F2E0
    procedure AddAnsiChar(Value: AnsiChar); // @addr 0x82F468
    procedure AddWideChar(Value: WideChar); // @addr 0x82F4B0

    function ReadBytes(Dest: Pointer; ByteCount: Integer): Pointer; // @addr 0x82F744 @note "Returns Dest; requires a positive ByteCount."
    // Several scalar readers contain native inline assembly after the bounds check.
    function GetByte: Byte; // @addr 0x82F81C
    function GetWideChar: WideChar; // @addr 0x82F854
    function GetWord: Word; // @addr 0x82F890
    function GetUInt32: Cardinal; // @addr 0x82F8CC
    function GetInt32: Integer; // @addr 0x82F904
    function GetSingle: Single; // @addr 0x82F93C @note "Replaces NaN with zero."
    function GetDouble: Double; // @addr 0x82F9C8 @note "Replaces NaN with zero."
    function GetBoolean: Boolean; // @addr 0x82FA5C
    procedure ReadLengthPrefixedBuffer(Dest: TBufEC); // @addr 0x82FA94 @note "Dest.Position is preserved unless it exceeds the new size."

    // Lengths count characters, stop at the buffer end, and leave Position unchanged.
    function GetWideStringLength: Integer; // @addr 0x82FAD4
    function GetWideStringLengthAt(Offset: Integer): Integer; // @addr 0x82FAF8
    function GetAnsiTextLineLength: Integer; // @addr 0x82FB58
    function GetAnsiTextLineLengthAt(Offset: Integer): Integer; // @addr 0x82FB7C
    function GetWideTextLineLength: Integer; // @addr 0x82FBEC
    function GetWideTextLineLengthAt(Offset: Integer): Integer; // @addr 0x82FC10

    // Dest must have room for the text and a terminating zero; returns Dest.
    // Line readers stop at NUL, CR or LF and consume up to two such characters.
    function ReadAnsiTextLineToBuffer(Dest: PAnsiChar): PAnsiChar; // @addr 0x82FC84
    function ReadWideTextLineToBuffer(Dest: PWideChar): PWideChar; // @addr 0x82FDC4
    function ReadWideStringToBuffer(Dest: PWideChar): PWideChar; // @addr 0x82F798 @note "Consumes the terminating zero; an empty scan advances Position by two even at the buffer end."
    function ReadAnsiTextLine: AnsiString; // @addr 0x82FD58 @ida "void __usercall $name(TBufEC *Self@<eax>, char **Result@<edx>);"
    function ReadWideTextLine: WideString; // @addr 0x82FEAC @ida "void __usercall $name(TBufEC *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function ReadWideString: WideString; // @addr 0x82FF18 @ida "void __usercall $name(TBufEC *Self@<eax>, unsigned __int16 **Result@<edx>);"

    // Successful transforms replace the entire payload and reset Position to zero.
    // False leaves the buffer intact, including when DataSize is less than eight.
    function CompressZlibPayloadInPlace(FastMode: Boolean): Boolean; // @addr 0x82FF90 @note "FastMode is ignored in this binary."
    function ExpandZlibPayloadInPlace: Boolean; // @addr 0x830034
    procedure ApplyDatXorCipher(Seed: Integer); // @addr 0x830148 @note "Leaves Position unchanged."
    function ComputeCrc32: Cardinal; // @addr 0x830198
    function ComputeCrc32Range(StartOffset, EndOffset: Integer): Cardinal; // @addr 0x8301BC @note "EndOffset is exclusive; offsets are not validated."
    procedure UpdateEmbeddedCrc32(StartOffset, EndOffset, CrcOffset: Integer); // @addr 0x8301EC @note "CrcOffset reserves eight bytes inside the half-open range. Stores the range CRC followed by a correction word preserving the previous prefix CRC through that slot."

    // Loaders replace the payload and leave Position at zero.
    procedure LoadFromFileChunk(SourceFile: TFileEC; ByteCount: Integer); // @addr 0x8302D4 @note "Consumes from the current file position; balances its own handle acquisition."
    procedure LoadFromFile(SourceFile: TFileEC); // @addr 0x8303A4 @note "Reads only the remaining file bytes; balances its own handle acquisition."
    procedure LoadFromWideFilePath(FileName: PWideChar); // @addr 0x830430
    procedure SaveToFile(DestFile: TFileEC); // @addr 0x8304D8 @note "Writes the entire payload at the open file's current position, ignoring the buffer's Position."
  end;

implementation

uses CrcUnit, EC_Mem, GR_Main, Math, SysUtils, Windows;

const
  BufferGrowthSlack = 256;
  CarriageReturnCode = 13;
  LineFeedCode = 10;

{ @routine $82EAB0 TBufEC_Create }
constructor TBufEC.Create;
begin inherited Create end;
{ @end $82EAB0 }

{ @routine $82EAF4 TBufEC_Destroy }
destructor TBufEC.Destroy;
begin Clear; inherited Destroy end;
{ @end $82EAF4 }

{ @routine $82EB30 TBufEC_Clear }
procedure TBufEC.Clear;
begin
  if Data <> nil then
  begin
    FreeEC(Data);
    Data := nil;
  end;
  DataSize := 0;
  Capacity := 0;
  Position := 0;
end;
{ @end $82EB30 }

{ @routine $82EB70 TBufEC_SetSize }
procedure TBufEC.SetSize(NewSize: Integer);
begin
  if NewSize < 1 then Clear
  else
  begin
    DataSize := NewSize;
    Capacity := NewSize + BufferGrowthSlack;
    Data := ReAllocREC(Data, Capacity);
    if Position > DataSize then Position := DataSize;
  end;
end;
{ @end $82EB70 }

{ @routine $82EBD8 TBufEC_IsAtEnd }
function TBufEC.IsAtEnd: Boolean;
begin
  if Position >= DataSize then Result := True else Result := False;
end;
{ @end $82EBD8 }

{ @routine $82EC00 TBufEC_SetPosition }
procedure TBufEC.SetPosition(NewPosition: Integer);
begin
  if (NewPosition < 0) or (NewPosition > DataSize) then
    raise Exception.Create('TBufEC.PointerSet. zn=' + SysUtils.IntToStr(NewPosition));
  Position := NewPosition;
end;
{ @end $82EC00 }

{ @routine $82ECB4 TBufEC_EnsureWriteCapacity }
procedure TBufEC.EnsureWriteCapacity(AddedBytes: Integer);
begin
  if AddedBytes < 1 then raise Exception.Create('TBufEC.TestAddLenBuf. addlen=' + SysUtils.IntToStr(AddedBytes));
  if Position + AddedBytes > DataSize then
  begin
    DataSize := Position + AddedBytes;
    if DataSize > Capacity then
    begin
      Capacity := Max(Capacity * 2, DataSize + BufferGrowthSlack);
      Data := ReAllocREC(Data, Capacity);
    end;
  end;
end;
{ @end $82ECB4 }

{ @routine $82EDDC TBufEC_EnsureWriteCapacityAtOffset }
procedure TBufEC.EnsureWriteCapacityAtOffset(Offset, AddedBytes: Integer);
begin
  if (AddedBytes < 1) or (Offset < 0) or (Offset > DataSize) then
    raise Exception.Create('TBufEC.TestAddLenBuf. sme=' + SysUtils.IntToStr(Offset) + ' addlen=' + SysUtils.IntToStr(AddedBytes));
  if Offset + AddedBytes > DataSize then
  begin
    DataSize := Offset + AddedBytes;
    if DataSize > Capacity then
    begin
      Capacity := Max(Capacity * 2, DataSize + BufferGrowthSlack);
      Data := ReAllocREC(Data, Capacity);
    end;
  end;
end;
{ @end $82EDDC }

{ @routine $82EF40 TBufEC_EnsureReadable }
procedure TBufEC.EnsureReadable(Bytes: Integer);
begin
  if (Bytes < 1) or (Position + Bytes > DataSize) then
    raise Exception.Create('TBufEC.TestGet. len=' + SysUtils.IntToStr(Bytes));
end;
{ @end $82EF40 }

{ @routine $82EFF0 TBufEC_EnsureReadableAtOffset }
procedure TBufEC.EnsureReadableAtOffset(Offset, Bytes: Integer);
begin
  if (Bytes < 1) or (Offset + Bytes > DataSize) then
    raise Exception.Create('TBufEC.TestGet. sme=' + SysUtils.IntToStr(Offset) + ' len=' + SysUtils.IntToStr(Bytes));
end;
{ @end $82EFF0 }

{ @routine $82F0CC TBufEC_SetByteAt }
procedure TBufEC.SetByteAt(Offset: Integer; Value: Byte);
begin
  EnsureWriteCapacityAtOffset(Offset, SizeOf(Value));
  WriteByteEC(PAnsiChar(Data) + Offset, Value);
end;
{ @end $82F0CC }

{ @routine $82F108 TBufEC_SetInt32At }
procedure TBufEC.SetInt32At(Offset: Integer; Value: Integer);
begin
  EnsureWriteCapacityAtOffset(Offset, SizeOf(Value));
  WriteIntegerEC(PAnsiChar(Data) + Offset, Value);
end;
{ @end $82F108 }

{ @routine $82F144 TBufEC_AddBytes }
procedure TBufEC.AddBytes(Source: Pointer; ByteCount: Integer);
begin
  EnsureWriteCapacity(ByteCount);
  Windows.CopyMemory(AddPointerOffset(Data, Position), Source, ByteCount);
  Inc(Position, ByteCount);
end;
{ @end $82F144 }

{ @routine $82F18C TBufEC_AddAnsiStringZ }
procedure TBufEC.AddAnsiStringZ(const Value: AnsiString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value);
  EnsureWriteCapacity(ByteCount + 1);
  Windows.CopyMemory(AddPointerOffset(Data, Position), PAnsiChar(Value), ByteCount + 1);
  Position := Position + ByteCount + 1;
end;
{ @end $82F18C }

{ @routine $82F200 TBufEC_AddWideStringZ }
procedure TBufEC.AddWideStringZ(const Value: WideString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value) * SizeOf(WideChar);
  EnsureWriteCapacity(ByteCount + SizeOf(WideChar));
  Windows.CopyMemory(AddPointerOffset(Data, Position), PWideChar(Value), ByteCount + SizeOf(WideChar));
  Position := Position + ByteCount + SizeOf(WideChar);
end;
{ @end $82F200 }

{ @routine $82F26C TBufEC_AddAnsiStringRaw }
procedure TBufEC.AddAnsiStringRaw(const Value: AnsiString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value);
  if ByteCount > 0 then
  begin
    EnsureWriteCapacity(ByteCount);
    Windows.CopyMemory(AddPointerOffset(Data, Position), PAnsiChar(Value), ByteCount);
    Inc(Position, ByteCount);
  end;
end;
{ @end $82F26C }

{ @routine $82F2E0 TBufEC_AddWideStringRaw }
procedure TBufEC.AddWideStringRaw(const Value: WideString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value) * SizeOf(WideChar);
  if ByteCount > 0 then
  begin
    EnsureWriteCapacity(ByteCount);
    Windows.CopyMemory(AddPointerOffset(Data, Position), PWideChar(Value), ByteCount);
    Inc(Position, ByteCount);
  end;
end;
{ @end $82F2E0 }

{ @routine $82F344 TBufEC_AddByte }
procedure TBufEC.AddByte(Value: Byte);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F344 }

{ @routine $82F38C TBufEC_AddWord }
procedure TBufEC.AddWord(Value: Word);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteWordEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F38C }

{ @routine $82F3D8 TBufEC_AddInt32 }
procedure TBufEC.AddInt32(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteIntegerEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F3D8 }

{ @routine $82F420 TBufEC_AddInteger }
procedure TBufEC.AddInteger(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteInt32EC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F420 }

{ @routine $82F468 TBufEC_AddAnsiChar }
procedure TBufEC.AddAnsiChar(Value: AnsiChar);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Byte(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $82F468 }

{ @routine $82F4B0 TBufEC_AddWideChar }
procedure TBufEC.AddWideChar(Value: WideChar);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteWordEC(AddPointerOffset(Data, Position), Word(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $82F4B0 }

{ @routine $82F4FC TBufEC_AddDWord }
procedure TBufEC.AddDWord(Value: Cardinal);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteIntegerEC(AddPointerOffset(Data, Position), Integer(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $82F4FC }

{ @routine $82F544 TBufEC_AddIntegerValue }
procedure TBufEC.AddIntegerValue(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteInt32EC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F544 }

{ @routine $82F58C TBufEC_AddSingle }
procedure TBufEC.AddSingle(Value: Single);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteSingleEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F58C }

{ @routine $82F5D0 TBufEC_AddDouble }
procedure TBufEC.AddDouble(Value: Double);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteDoubleEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $82F5D0 }

{ @routine $82F618 TBufEC_AddBoolean }
procedure TBufEC.AddBoolean(Value: Boolean);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Byte(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $82F618 }

{ @routine $82F660 TBufEC_AddBuffer }
procedure TBufEC.AddBuffer(Value: TBufEC);
begin
  AddDWord(Value.DataSize);
  if Value.DataSize > 0 then AddBytes(Value.Data, Value.DataSize);
end;
{ @end $82F660 }

{ @routine $82F69C TBufEC_GetByteAt }
function TBufEC.GetByteAt(Offset: Integer): Byte;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadByteEC(PAnsiChar(Data) + Offset);
end;
{ @end $82F69C }

{ @routine $82F6D4 TBufEC_GetUInt32At }
function TBufEC.GetUInt32At(Offset: Integer): Cardinal;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadDWordEC(PAnsiChar(Data) + Offset);
end;
{ @end $82F6D4 }

{ @routine $82F70C TBufEC_GetInt32At }
function TBufEC.GetInt32At(Offset: Integer): Integer;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadIntegerEC(PAnsiChar(Data) + Offset);
end;
{ @end $82F70C }

{ @routine $82F744 TBufEC_ReadBytes }
function TBufEC.ReadBytes(Dest: Pointer; ByteCount: Integer): Pointer;
begin
  EnsureReadable(ByteCount);
  Windows.CopyMemory(Dest, AddPointerOffset(Data, Position), ByteCount);
  Inc(Position, ByteCount);
  Result := Dest;
end;
{ @end $82F744 }

{ @routine $82F798 TBufEC_ReadWideStringToBuffer }
function TBufEC.ReadWideStringToBuffer(Dest: PWideChar): PWideChar;
var
  Count: Integer;
begin
  Count := GetWideStringLengthAt(Position);
  if Count > 0 then
  begin
    EnsureReadable(Count * SizeOf(WideChar) + SizeOf(WideChar));
    Windows.CopyMemory(Dest, PAnsiChar(Data) + Position, Count * SizeOf(WideChar) + SizeOf(WideChar));
    Position := Position + Count * SizeOf(WideChar) + SizeOf(WideChar);
  end
  else
  begin
    Inc(Position, SizeOf(WideChar));
    Dest^ := #0;
  end;
  Result := Dest;
end;
{ @end $82F798 }

{ @routine $82F81C TBufEC_GetByte }
function TBufEC.GetByte: Byte;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    INC [EBX].TBufEC.Position
    MOV AL, [EDI + EAX]
    MOV Result, AL
    POP EDI
    POP EBX
    POP EAX
  end;
end;
{ @end $82F81C }

{ @routine $82F854 TBufEC_GetWideChar }
function TBufEC.GetWideChar: WideChar;
begin
  EnsureReadable(SizeOf(Result));
  Result := ReadWideCharEC(PAnsiChar(Data) + Position);
  Inc(Position, 2);
end;
{ @end $82F854 }

{ @routine $82F890 TBufEC_GetWord }
function TBufEC.GetWord: Word;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    ADD [EBX].TBufEC.Position, 2
    MOV AX, [EDI + EAX]
    MOV Result, AX
    POP EDI
    POP EBX
    POP EAX
  end;
end;
{ @end $82F890 }

{ @routine $82F8CC TBufEC_GetUInt32 }
function TBufEC.GetUInt32: Cardinal;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    ADD [EBX].TBufEC.Position, 4
    MOV EAX, [EDI + EAX]
    MOV Result, EAX
    POP EDI
    POP EBX
    POP EAX
  end;
end;
{ @end $82F8CC }

{ @routine $82F904 TBufEC_GetInt32 }
function TBufEC.GetInt32: Integer;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    ADD [EBX].TBufEC.Position, 4
    MOV EAX, [EDI + EAX]
    MOV Result, EAX
    POP EDI
    POP EBX
    POP EAX
  end;
end;
{ @end $82F904 }

{ @routine $82F93C TBufEC_GetSingle }
function TBufEC.GetSingle: Single;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    ADD [EBX].TBufEC.Position, 4
    MOV EAX, [EDI + EAX]
    MOV Result, EAX
    POP EDI
    POP EBX
    POP EAX
  end;
  if IsNan(Result) then
  begin
    Result := 0;
    AppendLogLineThreadSafe('Warning! NaN encountered, replaced with zero.');
  end;
end;
{ @end $82F93C }

{ @routine $82F9C8 TBufEC_GetDouble }
function TBufEC.GetDouble: Double;
begin
  EnsureReadable(SizeOf(Result));
  Result := ReadDoubleEC(PAnsiChar(Data) + Position);
  if IsNan(Result) then
  begin
    Result := 0;
    AppendLogLineThreadSafe('Warning! NaN encountered, replaced with zero.');
  end;
  Inc(Position, SizeOf(Result));
end;
{ @end $82F9C8 }

{ @routine $82FA5C TBufEC_GetBoolean }
function TBufEC.GetBoolean: Boolean;
begin
  EnsureReadable(SizeOf(Result));
  asm
    PUSH EAX
    PUSH EBX
    PUSH EDI
    MOV EBX, Self
    MOV EAX, [EBX].TBufEC.Position
    MOV EDI, [EBX].TBufEC.Data
    INC [EBX].TBufEC.Position
    MOV AL, [EDI + EAX]
    MOV Result, AL
    POP EDI
    POP EBX
    POP EAX
  end;
end;
{ @end $82FA5C }

{ @routine $82FA94 TBufEC_ReadLengthPrefixedBuffer }
procedure TBufEC.ReadLengthPrefixedBuffer(Dest: TBufEC);
var
  ByteCount: Integer;
begin
  ByteCount := GetUInt32;
  Dest.SetSize(ByteCount);
  if ByteCount > 0 then ReadBytes(Dest.Data, ByteCount);
end;
{ @end $82FA94 }

{ @routine $82FAD4 TBufEC_GetWideStringLength }
function TBufEC.GetWideStringLength: Integer;
begin Result := GetWideStringLengthAt(Position) end;
{ @end $82FAD4 }

{ @routine $82FAF8 TBufEC_GetWideStringLengthAt }
function TBufEC.GetWideStringLengthAt(Offset: Integer): Integer;
var
  Count, Cursor: Integer;

begin
  Cursor := Offset;
  Count := 0;
  while Cursor + 1 < DataSize do
  begin
    if ReadWordEC(AddPointerOffset(Data, Cursor)) = 0 then
    begin
      Result := Count;
      Exit;
    end;
    Inc(Count);
    Inc(Cursor, SizeOf(WideChar));
  end;
  Result := Count;
end;
{ @end $82FAF8 }

{ @routine $82FB58 TBufEC_GetAnsiTextLineLength }
function TBufEC.GetAnsiTextLineLength: Integer;
begin Result := GetAnsiTextLineLengthAt(Position) end;
{ @end $82FB58 }

{ @routine $82FB7C TBufEC_GetAnsiTextLineLengthAt }
function TBufEC.GetAnsiTextLineLengthAt(Offset: Integer): Integer;
var
  Count, Cursor: Integer;
  Ch: Byte;
begin
  Cursor := Offset;
  Count := 0;
  while Cursor < DataSize do
  begin
    Ch := ReadByteEC(AddPointerOffset(Data, Cursor));
    if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then
    begin
      Result := Count;
      Exit;
    end;
    Inc(Count);
    Inc(Cursor, 1);
  end;
  Result := Count;
end;
{ @end $82FB7C }

{ @routine $82FBEC TBufEC_GetWideTextLineLength }
function TBufEC.GetWideTextLineLength: Integer;
begin Result := GetWideTextLineLengthAt(Position) end;
{ @end $82FBEC }

{ @routine $82FC10 TBufEC_GetWideTextLineLengthAt }
function TBufEC.GetWideTextLineLengthAt(Offset: Integer): Integer;
var
  Count, Cursor: Integer;
  Ch: Word;
begin
  Cursor := Offset;
  Count := 0;
  while Cursor + 1 < DataSize do
  begin
    Ch := ReadWordEC(AddPointerOffset(Data, Cursor));
    if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then
    begin
      Result := Count;
      Exit;
    end;
    Inc(Count);
    Inc(Cursor, SizeOf(WideChar));
  end;
  Result := Count;
end;
{ @end $82FC10 }

{ @routine $82FC84 TBufEC_ReadAnsiTextLineToBuffer }
function TBufEC.ReadAnsiTextLineToBuffer(Dest: PAnsiChar): PAnsiChar;
var
  Count: Integer;
  Ch: Byte;
begin
  Count := GetAnsiTextLineLength;
  if Count > 0 then
  begin
    Windows.CopyMemory(Dest, PAnsiChar(Data) + Position, Count);
    Dest[Count] := #0;
    Inc(Position, Count);
  end
  else Dest^ := #0;
  if Position < DataSize then
  begin
    Ch := ReadByteEC(PAnsiChar(Data) + Position);
    if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then Inc(Position, 1);
    if Position < DataSize then
    begin
      Ch := ReadByteEC(PAnsiChar(Data) + Position);
      if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then Inc(Position, 1);
    end;
  end;
  Result := Dest;
end;
{ @end $82FC84 }

{ @routine $82FD58 TBufEC_ReadAnsiTextLine }
function TBufEC.ReadAnsiTextLine: AnsiString;
var
  Count: Integer;
begin
  Count := GetAnsiTextLineLength;
  if Count > 0 then
  begin
    SetLength(Result, Count);
    ReadAnsiTextLineToBuffer(PAnsiChar(Result));
  end
  else
  begin
    SetLength(Result, 2);
    ReadAnsiTextLineToBuffer(PAnsiChar(Result));
    Result := '';
  end;
end;
{ @end $82FD58 }

{ @routine $82FDC4 TBufEC_ReadWideTextLineToBuffer }
function TBufEC.ReadWideTextLineToBuffer(Dest: PWideChar): PWideChar;
var
  Count: Integer;
  Ch: Word;
begin
  Count := GetWideTextLineLength;
  if Count > 0 then
  begin
    Windows.CopyMemory(Dest, PAnsiChar(Data) + Position, Count * SizeOf(WideChar));
    Dest[Count] := #0;
    Inc(Position, Count * SizeOf(WideChar));
  end
  else Dest^ := #0;
  if Position + 1 < DataSize then
  begin
    Ch := ReadWordEC(PAnsiChar(Data) + Position);
    if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then Inc(Position, SizeOf(WideChar));
    if Position + 1 < DataSize then
    begin
      Ch := ReadWordEC(PAnsiChar(Data) + Position);
      if (Ch = 0) or (Ch = CarriageReturnCode) or (Ch = LineFeedCode) then Inc(Position, SizeOf(WideChar));
    end;
  end;
  Result := Dest;
end;
{ @end $82FDC4 }

{ @routine $82FEAC TBufEC_ReadWideTextLine }
function TBufEC.ReadWideTextLine: WideString;
var
  Count: Integer;
begin
  Count := GetWideTextLineLength;
  if Count > 0 then
  begin
    SetLength(Result, Count);
    ReadWideTextLineToBuffer(PWideChar(Result));
  end
  else
  begin
    SetLength(Result, 2);
    ReadWideTextLineToBuffer(PWideChar(Result));
    Result := '';
  end;
end;
{ @end $82FEAC }

{ @routine $82FF18 TBufEC_ReadWideString }
function TBufEC.ReadWideString: WideString;
var
  Count: Integer;
begin
  Count := GetWideStringLength;
  if Count > 0 then
  begin
    SetLength(Result, Count);
    ReadWideStringToBuffer(PWideChar(Result));
    SetLength(Result, Count);
  end
  else
  begin
    SetLength(Result, 1);
    ReadWideStringToBuffer(@Count);
    SetLength(Result, 0);
    Result := '';
  end;
end;
{ @end $82FF18 }

{ @routine $82FF90 TBufEC_CompressZlibPayloadInPlace }
function TBufEC.CompressZlibPayloadInPlace(FastMode: Boolean): Boolean;
var
  Mode, ByteCount: Integer;
  Buffer: Pointer;
begin
  Mode := 0;
  if FastMode = True then Mode := 0;
  if DataSize < 8 then
  begin
    Result := False;
    Exit;
  end;
  Buffer := AllocEC(DataSize);
  ByteCount := OKGF_ZLib_Compress(Buffer, Data, DataSize, Mode);
  if ByteCount = 0 then
  begin
    FreeEC(Buffer);
    Result := False;
    Exit;
  end;
  FreeEC(Data);
  Data := Buffer;
  DataSize := ByteCount;
  Capacity := ByteCount;
  Position := 0;
  Result := True;
end;
{ @end $82FF90 }

{ @routine $830034 TBufEC_ExpandZlibPayloadInPlace }
function TBufEC.ExpandZlibPayloadInPlace: Boolean;
var
  ByteCount: Integer;
  Buffer: Pointer;
begin
  if DataSize < 8 then
  begin
    Result := False;
    Exit;
  end;
  ByteCount := OKGF_ZLib_UnCompress(nil, 0, Data, DataSize);
  if ByteCount = 0 then
  begin
    Result := False;
    Exit;
  end;
  Buffer := AllocEC(ByteCount);
  ByteCount := OKGF_ZLib_UnCompress(Buffer, ByteCount, Data, DataSize);
  if ByteCount = 0 then
  begin
    FreeEC(Buffer);
    Result := False;
    Exit;
  end;
  FreeEC(Data);
  Data := Buffer;
  DataSize := ByteCount;
  Capacity := ByteCount;
  Position := 0;
  Result := True;
end;
{ @end $830034 }

{ @routine $830148 TBufEC_ApplyDatXorCipher }
procedure TBufEC.ApplyDatXorCipher(Seed: Integer);
var
  State, i: Integer;
  Cursor: PByte;

  // @nested $8300EC StepDatXorSeedState
  function StepDatXorSeedState: Integer; // @addr 0x8300EC @ida "int __cdecl $name(void *ParentFrame);" @note "Nested helper of TBufEC.ApplyDatXorCipher; requires its parent stack frame."
  begin
    State := 16807 * (State mod 127773) - 2836 * (State div 127773);
    if State <= 0 then State := State + $7FFFFFFF;
    Result := State - 1;
  end;

begin
  State := Seed;
  Cursor := Data;
  for i := 0 to DataSize - 1 do
  begin
    Cursor^ := Cursor^ xor Byte(StepDatXorSeedState);
    Cursor := PByte(PAnsiChar(Cursor) + 1);
  end;
end;
{ @end $830148 }

{ @routine $830198 TBufEC_ComputeCrc32 }
function TBufEC.ComputeCrc32: Cardinal;
begin Result := CrcUnit.ComputeCrc32(Data, DataSize) end;
{ @end $830198 }

{ @routine $8301BC TBufEC_ComputeCrc32Range }
function TBufEC.ComputeCrc32Range(StartOffset, EndOffset: Integer): Cardinal;
begin Result := CrcUnit.ComputeCrc32(Pointer(PAnsiChar(Data) + StartOffset), EndOffset - StartOffset) end;
{ @end $8301BC }

{ @routine $8301EC TBufEC_UpdateEmbeddedCrc32 }
procedure TBufEC.UpdateEmbeddedCrc32(StartOffset, EndOffset, CrcOffset: Integer);
var
  WholeCrc, PreviousPrefixCrc, NewPrefixCrc: Cardinal;
begin
  if CrcOffset < StartOffset then raise Exception.Create('CRC update error');
  if CrcOffset + 8 > EndOffset then raise Exception.Create('CRC update error');
  WholeCrc := ExtendCrc32(0, Pointer(PAnsiChar(Data) + StartOffset), EndOffset - StartOffset);
  PreviousPrefixCrc := ExtendCrc32(0, Pointer(PAnsiChar(Data) + StartOffset), CrcOffset - StartOffset + 8);
  PCardinal(PAnsiChar(Data) + CrcOffset)^ := WholeCrc;
  NewPrefixCrc := ExtendCrc32(0, Pointer(PAnsiChar(Data) + StartOffset), CrcOffset - StartOffset + 4);
  WriteCrc32Correction(NewPrefixCrc, PreviousPrefixCrc, Pointer(CrcOffset + 4 + PAnsiChar(Data)));
end;
{ @end $8301EC }

{ @routine $8302D4 TBufEC_LoadFromFileChunk }
procedure TBufEC.LoadFromFileChunk(SourceFile: TFileEC; ByteCount: Integer);
var
  ChunkSize: Integer;
  Cursor: Pointer;
  NextChunkSize: Integer;
begin
  Self.Clear;
  SourceFile.AcquireReadWriteHandle;
  try
    Self.SetSize(ByteCount);
    Cursor := Self.Data;
    if (ByteCount > 0) then
    begin
      repeat
        if (ByteCount > 262144) then
        begin
          NextChunkSize := 262144;
        end
        else
        begin
          NextChunkSize := ByteCount;
        end;
        ChunkSize := NextChunkSize;
        SourceFile.ReadBuffer(Cursor, ChunkSize);
        Cursor := AddPointerOffset(Cursor, ChunkSize);
        ByteCount := (ByteCount - ChunkSize);
        if (ByteCount > 0) then
        begin
          SysUtils.Sleep(1);
        end;
      until ByteCount <= 0;
    end;
  except
    Self.Clear;
  end;
  SourceFile.ReleaseHandle;
  Exit;
end;
{ @end $8302D4 }

{ @routine $8303A4 TBufEC_LoadFromFile }
procedure TBufEC.LoadFromFile(SourceFile: TFileEC);
var
  ByteCount: Integer;
begin
  Clear;
  SourceFile.AcquireReadWriteHandle;
  try
    ByteCount := SourceFile.GetSize - SourceFile.GetPointer;
    SetSize(ByteCount);
    SourceFile.ReadBuffer(Data, ByteCount);
  except
    Clear;
  end;
  SourceFile.ReleaseHandle;
end;
{ @end $8303A4 }

{ @routine $830430 TBufEC_LoadFromWideFilePath }
procedure TBufEC.LoadFromWideFilePath(FileName: PWideChar);
var
  SourceFile: TFileEC;
begin
  SourceFile := TFileEC.Create;
  try
    SourceFile.SetFileName(WideString(FileName));
    SourceFile.AcquireReadHandle(False);
    LoadFromFile(SourceFile);
  finally
    SourceFile.Free;
  end;
end;
{ @end $830430 }

{ @routine $8304D8 TBufEC_SaveToFile }
procedure TBufEC.SaveToFile(DestFile: TFileEC);
begin DestFile.WriteBuffer(Data, DataSize) end;
{ @end $8304D8 }

end.
