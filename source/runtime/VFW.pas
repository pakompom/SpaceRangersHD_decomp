unit VFW;
// Unit bracket (inferred): .text 0x00472D34..0x00472D64; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types;

type
  // Native RTTI retains 11/7 methods, but no GUIDs. Calls in this game use the
  // exported AVIFile API; the COM Info/SetInfo pointers below are Unicode forms.
  // ABI: https://github.com/wine-mirror/wine/blob/master/include/vfw.h
  IAVIStream = interface(IInterface)
    function Create(Param1, Param2: Integer): LongInt; stdcall;
    function Info(StreamInfoW: Pointer; Size: Integer): LongInt; stdcall;
    function FindSample(Position, Flags: Integer): Integer; stdcall;
    function ReadFormat(Position: Integer; Format: Pointer; var Size: Integer): LongInt; stdcall;
    function SetFormat(Position: Integer; Format: Pointer; Size: Integer): LongInt; stdcall;
    function Read(Start, Samples: Integer; Buffer: Pointer; Size: Integer; BytesRead, SamplesRead: PInteger): LongInt; stdcall;
    function Write(Start, Samples: Integer; Buffer: Pointer; Size: Integer; Flags: Cardinal; SamplesWritten, BytesWritten: PInteger): LongInt; stdcall;
    function Delete(Start, Samples: Integer): LongInt; stdcall;
    function ReadData(Chunk: Cardinal; Buffer: Pointer; var Size: Integer): LongInt; stdcall;
    function WriteData(Chunk: Cardinal; Buffer: Pointer; Size: Integer): LongInt; stdcall;
    function SetInfo(StreamInfoW: Pointer; Size: Integer): LongInt; stdcall;
  end;
  IAVIFile = interface(IInterface)
    function Info(FileInfoW: Pointer; Size: Integer): LongInt; stdcall;
    function GetStream(out Stream: IAVIStream; StreamType: Cardinal; Param: Integer): LongInt; stdcall;
    function CreateStream(out Stream: IAVIStream; StreamInfoW: Pointer): LongInt; stdcall;
    function WriteData(Chunk: Cardinal; Buffer: Pointer; Size: Integer): LongInt; stdcall;
    function ReadData(Chunk: Cardinal; Buffer: Pointer; var Size: Integer): LongInt; stdcall;
    function EndRecord: LongInt; stdcall;
    function DeleteStream(StreamType: Cardinal; Param: Integer): LongInt; stdcall;
  end;

  TAVIStreamInfoA = packed record // @size $8C
    StreamType: Cardinal; // @offset $00
    Handler: Cardinal; // @offset $04
    Flags: Cardinal; // @offset $08
    Caps: Cardinal; // @offset $0C
    Priority: Word; // @offset $10
    Language: Word; // @offset $12
    Scale: Cardinal; // @offset $14
    Rate: Cardinal; // @offset $18
    Start: Cardinal; // @offset $1C
    Length: Cardinal; // @offset $20
    InitialFrames: Cardinal; // @offset $24
    SuggestedBufferSize: Cardinal; // @offset $28
    Quality: Cardinal; // @offset $2C
    SampleSize: Cardinal; // @offset $30
    Frame: TRect; // @offset $34
    EditCount: Cardinal; // @offset $44
    FormatChangeCount: Cardinal; // @offset $48
    Name: array[0..63] of AnsiChar; // @offset $4C
  end;

procedure AVIFileInit; stdcall;
  external 'AVIFIL32.DLL' name 'AVIFileInit'; // @addr $472D8C
procedure AVIFileExit; stdcall;
  external 'AVIFIL32.DLL' name 'AVIFileExit'; // @addr $472D94
function AVIFileOpenA(var FileHandle: IAVIFile; FileName: PAnsiChar; Mode: Cardinal; Handler: Pointer): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIFileOpenA'; // @addr $472D9C
function AVIFileGetStream(const FileHandle: IAVIFile; var Stream: IAVIStream; StreamType: Cardinal; Index: Integer): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIFileGetStream'; // @addr $472DA4
function AVIStreamInfoA(const Stream: IAVIStream; var Info: TAVIStreamInfoA; Size: Integer): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIStreamInfoA'; // @addr $472DAC
function AVIStreamReadFormat(const Stream: IAVIStream; Position: Integer; Format: Pointer; var FormatSize: Integer): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIStreamReadFormat'; // @addr $472DB4
function AVIStreamRead(const Stream: IAVIStream; Start, Samples: Integer; Buffer: Pointer; BufferSize: Integer; BytesRead, SamplesRead: PCardinal): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIStreamRead'; // @addr $472DBC
function AVIStreamLength(const Stream: IAVIStream): Integer; stdcall;
  external 'AVIFIL32.DLL' name 'AVIStreamLength'; // @addr $472DC4

implementation
end.
