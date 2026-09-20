unit EC_Buf;
// Unit bracket (inferred): .text 0x0086BA78..0x0086D517; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_File, EC_Struct;

type
  TBufEC = class(TObjectEx) // @size 0x14
  public
    DataSize: Integer; // @offset 0x04
    Capacity: Integer; // @offset 0x08
    Position: Integer; // @offset 0x0C
    Data: Pointer; // @offset 0x10

    constructor Create; // @addr 0x86BACC
    destructor Destroy; override; // @addr 0x86BB10
    procedure Clear; // @addr 0x86BB4C
    function IsAtEnd: Boolean; // @addr 0x86BBF4
    procedure SetSize(NewSize: Integer); // @addr 0x86BB8C @note "Nonpositive sizes clear the buffer; shrinking clamps Position."
    procedure SetPosition(NewPosition: Integer); // @addr 0x86BC1C
    procedure EnsureWriteCapacity(AddedBytes: Integer); // @addr 0x86BCD0 @note "AddedBytes must be positive. Extends DataSize without advancing Position."
    procedure EnsureWriteCapacityAtOffset(Offset, AddedBytes: Integer); // @addr 0x86BDF8 @note "AddedBytes must be positive; Offset must be in 0..DataSize. Position is unchanged."
    procedure EnsureReadable(Bytes: Integer); // @addr 0x86BF5C
    procedure EnsureReadableAtOffset(Offset, Bytes: Integer); // @addr 0x86C00C @note "Rejects nonpositive counts and ranges ending past DataSize; does not reject negative Offset."

    procedure SetByteAt(Offset: Integer; Value: Byte); // @addr 0x86C0E8
    procedure SetInt32At(Offset: Integer; Value: Integer); // @addr 0x86C124
    function GetByteAt(Offset: Integer): Byte; // @addr 0x86C6B8
    function GetUInt32At(Offset: Integer): Cardinal; // @addr 0x86C6F0
    function GetInt32At(Offset: Integer): Integer; // @addr 0x86C728

    // Sequential operations use Position, including writes into existing data.
    procedure AddBytes(Source: Pointer; ByteCount: Integer); // @addr 0x86C160
    procedure AddByte(Value: Byte); // @addr 0x86C360
    procedure AddWord(Value: Word); // @addr 0x86C3A8
    procedure AddInt32(Value: Integer); // @addr 0x86C3F4
    procedure AddInteger(Value: Integer); // @addr 0x86C43C
    procedure AddDWord(Value: Cardinal); // @addr 0x86C518
    procedure AddIntegerValue(Value: Integer); // @addr 0x86C560
    procedure AddSingle(Value: Single); // @addr 0x86C5A8
    procedure AddDouble(Value: Double); // @addr 0x86C5EC @ida "void __userpurge $name(TBufEC *Self@<eax>, double Value);"
    procedure AddBoolean(Value: Boolean); // @addr 0x86C634
    procedure AddBuffer(Value: TBufEC); // @addr 0x86C67C @note "Writes a four-byte size followed by the entire source payload, ignoring its Position."

    procedure AddAnsiStringZ(const Value: AnsiString); // @addr 0x86C1A8
    procedure AddWideStringZ(const Value: WideString); // @addr 0x86C21C
    procedure AddAnsiStringRaw(const Value: AnsiString); // @addr 0x86C288
    procedure AddWideStringRaw(const Value: WideString); // @addr 0x86C2FC
    procedure AddAnsiChar(Value: AnsiChar); // @addr 0x86C484
    procedure AddWideChar(Value: WideChar); // @addr 0x86C4CC

    function ReadBytes(Dest: Pointer; ByteCount: Integer): Pointer; // @addr 0x86C760 @note "Returns Dest; requires a positive ByteCount."
    // Several scalar readers contain native inline assembly after the bounds check.
    function GetByte: Byte; // @addr 0x86C838
    function GetWideChar: WideChar; // @addr 0x86C870
    function GetWord: Word; // @addr 0x86C8AC
    function GetUInt32: Cardinal; // @addr 0x86C8E8
    function GetInt32: Integer; // @addr 0x86C920
    function GetSingle: Single; // @addr 0x86C958 @note "Replaces NaN with zero."
    function GetDouble: Double; // @addr 0x86C9E4 @note "Replaces NaN with zero."
    function GetBoolean: Boolean; // @addr 0x86CA78
    procedure ReadLengthPrefixedBuffer(Dest: TBufEC); // @addr 0x86CAB0 @note "Dest.Position is preserved unless it exceeds the new size."

    // Lengths count characters, stop at the buffer end, and leave Position unchanged.
    function GetWideStringLength: Integer; // @addr 0x86CAF0
    function GetWideStringLengthAt(Offset: Integer): Integer; // @addr 0x86CB14
    function GetAnsiTextLineLength: Integer; // @addr 0x86CB74
    function GetAnsiTextLineLengthAt(Offset: Integer): Integer; // @addr 0x86CB98
    function GetWideTextLineLength: Integer; // @addr 0x86CC08
    function GetWideTextLineLengthAt(Offset: Integer): Integer; // @addr 0x86CC2C

    // Dest must have room for the text and a terminating zero; returns Dest.
    // Line readers stop at NUL, CR or LF and consume up to two such characters.
    function ReadAnsiTextLineToBuffer(Dest: PAnsiChar): PAnsiChar; // @addr 0x86CCA0
    function ReadWideTextLineToBuffer(Dest: PWideChar): PWideChar; // @addr 0x86CDE0
    function ReadWideStringToBuffer(Dest: PWideChar): PWideChar; // @addr 0x86C7B4 @note "Consumes the terminating zero; an empty scan advances Position by two even at the buffer end."
    function ReadAnsiTextLine: AnsiString; // @addr 0x86CD74
    function ReadWideTextLine: WideString; // @addr 0x86CEC8
    function ReadWideString: WideString; // @addr 0x86CF34

    // Successful transforms replace the entire payload and reset Position to zero.
    // False leaves the buffer intact, including when DataSize is less than eight.
    function CompressZlibPayloadInPlace(FastMode: Boolean): Boolean; // @addr 0x86CFAC @note "FastMode is ignored in this binary."
    function ExpandZlibPayloadInPlace: Boolean; // @addr 0x86D050
    procedure ApplyDatXorCipher(Seed: Integer); // @addr 0x86D164 @note "Leaves Position unchanged."
    function ComputeCrc32: Cardinal; // @addr 0x86D1B4
    function ComputeCrc32Range(StartOffset, EndOffset: Integer): Cardinal; // @addr 0x86D1D8 @note "EndOffset is exclusive; offsets are not validated."
    procedure UpdateEmbeddedCrc32(StartOffset, EndOffset, CrcOffset: Integer); // @addr 0x86D208 @note "CrcOffset reserves eight bytes inside the half-open range. Stores the range CRC followed by a correction word preserving the previous prefix CRC through that slot."

    // Loaders replace the payload and leave Position at zero.
    procedure LoadFromFileChunk(SourceFile: TFileEC; ByteCount: Integer); // @addr 0x86D2F0 @note "Consumes from the current file position; balances its own handle acquisition."
    procedure LoadFromFile(SourceFile: TFileEC); // @addr 0x86D3C0 @note "Reads only the remaining file bytes; balances its own handle acquisition."
    procedure LoadFromWideFilePath(FileName: PWideChar); // @addr 0x86D44C
    procedure SaveToFile(DestFile: TFileEC); // @addr 0x86D4F4 @note "Writes the entire payload at the open file's current position, ignoring the buffer's Position."
  end;

implementation

uses CrcUnit, EC_Mem, GR_Main, Math, SysUtils, Windows;

const
  BufferGrowthSlack = 256;
  CarriageReturnCode = 13;
  LineFeedCode = 10;

{ @routine $86BACC TBufEC_Create }
constructor TBufEC.Create;
begin inherited Create end;
{ @end $86BACC }

{ @routine $86BB10 TBufEC_Destroy }
destructor TBufEC.Destroy;
begin Clear; inherited Destroy end;
{ @end $86BB10 }

{ @routine $86BB4C TBufEC_Clear }
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
{ @end $86BB4C }

{ @routine $86BB8C TBufEC_SetSize }
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
{ @end $86BB8C }

{ @routine $86BBF4 TBufEC_IsAtEnd }
function TBufEC.IsAtEnd: Boolean;
begin
  if Position >= DataSize then Result := True else Result := False;
end;
{ @end $86BBF4 }

{ @routine $86BC1C TBufEC_SetPosition }
procedure TBufEC.SetPosition(NewPosition: Integer);
begin
  if (NewPosition < 0) or (NewPosition > DataSize) then
    raise Exception.Create('TBufEC.PointerSet. zn=' + SysUtils.IntToStr(NewPosition));
  Position := NewPosition;
end;
{ @end $86BC1C }

{ @routine $86BCD0 TBufEC_EnsureWriteCapacity }
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
{ @end $86BCD0 }

{ @routine $86BDF8 TBufEC_EnsureWriteCapacityAtOffset }
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
{ @end $86BDF8 }

{ @routine $86BF5C TBufEC_EnsureReadable }
procedure TBufEC.EnsureReadable(Bytes: Integer);
begin
  if (Bytes < 1) or (Position + Bytes > DataSize) then
    raise Exception.Create('TBufEC.TestGet. len=' + SysUtils.IntToStr(Bytes));
end;
{ @end $86BF5C }

{ @routine $86C00C TBufEC_EnsureReadableAtOffset }
procedure TBufEC.EnsureReadableAtOffset(Offset, Bytes: Integer);
begin
  if (Bytes < 1) or (Offset + Bytes > DataSize) then
    raise Exception.Create('TBufEC.TestGet. sme=' + SysUtils.IntToStr(Offset) + ' len=' + SysUtils.IntToStr(Bytes));
end;
{ @end $86C00C }

{ @routine $86C0E8 TBufEC_SetByteAt }
procedure TBufEC.SetByteAt(Offset: Integer; Value: Byte);
begin
  EnsureWriteCapacityAtOffset(Offset, SizeOf(Value));
  WriteByteEC(PAnsiChar(Data) + Offset, Value);
end;
{ @end $86C0E8 }

{ @routine $86C124 TBufEC_SetInt32At }
procedure TBufEC.SetInt32At(Offset: Integer; Value: Integer);
begin
  EnsureWriteCapacityAtOffset(Offset, SizeOf(Value));
  WriteIntegerEC(PAnsiChar(Data) + Offset, Value);
end;
{ @end $86C124 }

{ @routine $86C160 TBufEC_AddBytes }
procedure TBufEC.AddBytes(Source: Pointer; ByteCount: Integer);
begin
  EnsureWriteCapacity(ByteCount);
  Windows.CopyMemory(AddPointerOffset(Data, Position), Source, ByteCount);
  Inc(Position, ByteCount);
end;
{ @end $86C160 }

{ @routine $86C1A8 TBufEC_AddAnsiStringZ }
procedure TBufEC.AddAnsiStringZ(const Value: AnsiString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value);
  EnsureWriteCapacity(ByteCount + 1);
  Windows.CopyMemory(AddPointerOffset(Data, Position), PAnsiChar(Value), ByteCount + 1);
  Position := Position + ByteCount + 1;
end;
{ @end $86C1A8 }

{ @routine $86C21C TBufEC_AddWideStringZ }
procedure TBufEC.AddWideStringZ(const Value: WideString);
var
  ByteCount: Integer;
begin
  ByteCount := Length(Value) * SizeOf(WideChar);
  EnsureWriteCapacity(ByteCount + SizeOf(WideChar));
  Windows.CopyMemory(AddPointerOffset(Data, Position), PWideChar(Value), ByteCount + SizeOf(WideChar));
  Position := Position + ByteCount + SizeOf(WideChar);
end;
{ @end $86C21C }

{ @routine $86C288 TBufEC_AddAnsiStringRaw }
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
{ @end $86C288 }

{ @routine $86C2FC TBufEC_AddWideStringRaw }
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
{ @end $86C2FC }

{ @routine $86C360 TBufEC_AddByte }
procedure TBufEC.AddByte(Value: Byte);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C360 }

{ @routine $86C3A8 TBufEC_AddWord }
procedure TBufEC.AddWord(Value: Word);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteWordEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C3A8 }

{ @routine $86C3F4 TBufEC_AddInt32 }
procedure TBufEC.AddInt32(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteIntegerEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C3F4 }

{ @routine $86C43C TBufEC_AddInteger }
procedure TBufEC.AddInteger(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteInt32EC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C43C }

{ @routine $86C484 TBufEC_AddAnsiChar }
procedure TBufEC.AddAnsiChar(Value: AnsiChar);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Byte(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $86C484 }

{ @routine $86C4CC TBufEC_AddWideChar }
procedure TBufEC.AddWideChar(Value: WideChar);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteWordEC(AddPointerOffset(Data, Position), Word(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $86C4CC }

{ @routine $86C518 TBufEC_AddDWord }
procedure TBufEC.AddDWord(Value: Cardinal);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteIntegerEC(AddPointerOffset(Data, Position), Integer(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $86C518 }

{ @routine $86C560 TBufEC_AddIntegerValue }
procedure TBufEC.AddIntegerValue(Value: Integer);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteInt32EC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C560 }

{ @routine $86C5A8 TBufEC_AddSingle }
procedure TBufEC.AddSingle(Value: Single);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteSingleEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C5A8 }

{ @routine $86C5EC TBufEC_AddDouble }
procedure TBufEC.AddDouble(Value: Double);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteDoubleEC(AddPointerOffset(Data, Position), Value);
  Inc(Position, SizeOf(Value));
end;
{ @end $86C5EC }

{ @routine $86C634 TBufEC_AddBoolean }
procedure TBufEC.AddBoolean(Value: Boolean);
begin
  EnsureWriteCapacity(SizeOf(Value));
  WriteByteEC(AddPointerOffset(Data, Position), Byte(Value));
  Inc(Position, SizeOf(Value));
end;
{ @end $86C634 }

{ @routine $86C67C TBufEC_AddBuffer }
procedure TBufEC.AddBuffer(Value: TBufEC);
begin
  AddDWord(Value.DataSize);
  if Value.DataSize > 0 then AddBytes(Value.Data, Value.DataSize);
end;
{ @end $86C67C }

{ @routine $86C6B8 TBufEC_GetByteAt }
function TBufEC.GetByteAt(Offset: Integer): Byte;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadByteEC(PAnsiChar(Data) + Offset);
end;
{ @end $86C6B8 }

{ @routine $86C6F0 TBufEC_GetUInt32At }
function TBufEC.GetUInt32At(Offset: Integer): Cardinal;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadDWordEC(PAnsiChar(Data) + Offset);
end;
{ @end $86C6F0 }

{ @routine $86C728 TBufEC_GetInt32At }
function TBufEC.GetInt32At(Offset: Integer): Integer;
begin
  EnsureReadableAtOffset(Offset, SizeOf(Result));
  Result := ReadIntegerEC(PAnsiChar(Data) + Offset);
end;
{ @end $86C728 }

{ @routine $86C760 TBufEC_ReadBytes }
function TBufEC.ReadBytes(Dest: Pointer; ByteCount: Integer): Pointer;
begin
  EnsureReadable(ByteCount);
  Windows.CopyMemory(Dest, AddPointerOffset(Data, Position), ByteCount);
  Inc(Position, ByteCount);
  Result := Dest;
end;
{ @end $86C760 }

{ @routine $86C7B4 TBufEC_ReadWideStringToBuffer }
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
{ @end $86C7B4 }

{ @routine $86C838 TBufEC_GetByte }
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
{ @end $86C838 }

{ @routine $86C870 TBufEC_GetWideChar }
function TBufEC.GetWideChar: WideChar;
begin
  EnsureReadable(SizeOf(Result));
  Result := ReadWideCharEC(PAnsiChar(Data) + Position);
  Inc(Position, 2);
end;
{ @end $86C870 }

{ @routine $86C8AC TBufEC_GetWord }
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
{ @end $86C8AC }

{ @routine $86C8E8 TBufEC_GetUInt32 }
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
{ @end $86C8E8 }

{ @routine $86C920 TBufEC_GetInt32 }
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
{ @end $86C920 }

{ @routine $86C958 TBufEC_GetSingle }
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
{ @end $86C958 }

{ @routine $86C9E4 TBufEC_GetDouble }
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
{ @end $86C9E4 }

{ @routine $86CA78 TBufEC_GetBoolean }
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
{ @end $86CA78 }

{ @routine $86CAB0 TBufEC_ReadLengthPrefixedBuffer }
procedure TBufEC.ReadLengthPrefixedBuffer(Dest: TBufEC);
var
  ByteCount: Integer;
begin
  ByteCount := GetUInt32;
  Dest.SetSize(ByteCount);
  if ByteCount > 0 then ReadBytes(Dest.Data, ByteCount);
end;
{ @end $86CAB0 }

{ @routine $86CAF0 TBufEC_GetWideStringLength }
function TBufEC.GetWideStringLength: Integer;
begin Result := GetWideStringLengthAt(Position) end;
{ @end $86CAF0 }

{ @routine $86CB14 TBufEC_GetWideStringLengthAt }
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
{ @end $86CB14 }

{ @routine $86CB74 TBufEC_GetAnsiTextLineLength }
function TBufEC.GetAnsiTextLineLength: Integer;
begin Result := GetAnsiTextLineLengthAt(Position) end;
{ @end $86CB74 }

{ @routine $86CB98 TBufEC_GetAnsiTextLineLengthAt }
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
{ @end $86CB98 }

{ @routine $86CC08 TBufEC_GetWideTextLineLength }
function TBufEC.GetWideTextLineLength: Integer;
begin Result := GetWideTextLineLengthAt(Position) end;
{ @end $86CC08 }

{ @routine $86CC2C TBufEC_GetWideTextLineLengthAt }
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
{ @end $86CC2C }

{ @routine $86CCA0 TBufEC_ReadAnsiTextLineToBuffer }
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
{ @end $86CCA0 }

{ @routine $86CD74 TBufEC_ReadAnsiTextLine }
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
{ @end $86CD74 }

{ @routine $86CDE0 TBufEC_ReadWideTextLineToBuffer }
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
{ @end $86CDE0 }

{ @routine $86CEC8 TBufEC_ReadWideTextLine }
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
{ @end $86CEC8 }

{ @routine $86CF34 TBufEC_ReadWideString }
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
{ @end $86CF34 }

{ @routine $86CFAC TBufEC_CompressZlibPayloadInPlace }
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
{ @end $86CFAC }

{ @routine $86D050 TBufEC_ExpandZlibPayloadInPlace }
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
{ @end $86D050 }

{ @routine $86D164 TBufEC_ApplyDatXorCipher }
procedure TBufEC.ApplyDatXorCipher(Seed: Integer);
var
  State, i: Integer;
  Cursor: PByte;

  // @nested $86D108 StepDatXorSeedState
  function StepDatXorSeedState: Integer; // @addr 0x86D108 @ida "int __cdecl $name(void *ParentFrame);" @note "Nested helper of TBufEC.ApplyDatXorCipher; requires its parent stack frame."
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
{ @end $86D164 }

{ @routine $86D1B4 TBufEC_ComputeCrc32 }
function TBufEC.ComputeCrc32: Cardinal;
begin Result := CrcUnit.ComputeCrc32(Data, DataSize) end;
{ @end $86D1B4 }

{ @routine $86D1D8 TBufEC_ComputeCrc32Range }
function TBufEC.ComputeCrc32Range(StartOffset, EndOffset: Integer): Cardinal;
begin Result := CrcUnit.ComputeCrc32(Pointer(PAnsiChar(Data) + StartOffset), EndOffset - StartOffset) end;
{ @end $86D1D8 }

{ @routine $86D208 TBufEC_UpdateEmbeddedCrc32 }
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
{ @end $86D208 }

{ @routine $86D2F0 TBufEC_LoadFromFileChunk }
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
{ @end $86D2F0 }

{ @routine $86D3C0 TBufEC_LoadFromFile }
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
{ @end $86D3C0 }

{ @routine $86D44C TBufEC_LoadFromWideFilePath }
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
{ @end $86D44C }

{ @routine $86D4F4 TBufEC_SaveToFile }
procedure TBufEC.SaveToFile(DestFile: TFileEC);
begin DestFile.WriteBuffer(Data, DataSize) end;
{ @end $86D4F4 }

end.
