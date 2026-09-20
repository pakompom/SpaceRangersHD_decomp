unit Windows;
// Unit bracket (inferred): .text 0x00407C6C..0x00408AD3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876098..0x00876098; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  HResult = LongInt;
  TSystemTime = packed record // @size $10
    wYear: Word; // @offset $00
    wMonth: Word; // @offset $02
    wDayOfWeek: Word; // @offset $04
    wDay: Word; // @offset $06
    wHour: Word; // @offset $08
    wMinute: Word; // @offset $0A
    wSecond: Word; // @offset $0C
    wMilliseconds: Word; // @offset $0E
  end;
  TFileTime = packed record // @size 0x08
    LowDateTime: Cardinal; // @offset 0x00
    HighDateTime: Cardinal; // @offset 0x04
  end;

procedure FillMemory(Dest: Pointer; ByteCount: Cardinal; Value: Byte);
procedure MoveMemory(Dest, Source: Pointer; ByteCount: Cardinal); // @addr 0x4088BC
procedure CopyMemory(Dest, Source: Pointer; ByteCount: Cardinal); // @addr 0x4088C4 @note "This implementation also supports overlapping ranges."

type
  TLargeInteger = Int64;

  PLargeInteger = ^TLargeInteger;

  HPen = Cardinal;

  TMaxLogPalette = record;

  TWinRGBQuad = record;

  TRGBQuad = TWinRGBQuad;

  TWinBitmapInfoHeader = record;

  TBitmapInfoHeader = TWinBitmapInfoHeader;

  TWinDIBSection = record;

  TDIBSection = TWinDIBSection;

  TColorRef = DWord;

  TWinBitmapFileHeader = record;

  TBitmapFileHeader = TWinBitmapFileHeader;

  PBitmapFileHeader = ^TBitmapFileHeader;

  TMsg = packed record // @size $1C
    hwnd: Cardinal; // @offset $00
    message: Cardinal; // @offset $04
    wParam: Cardinal; // @offset $08
    lParam: Integer; // @offset $0C
    time: Cardinal; // @offset $10
    pt: TPoint; // @offset $14
  end;

  TWin32FindDataA = packed record // @size $140
    dwFileAttributes: Cardinal; // @offset $00
    ftCreationTime: TFileTime; // @offset $04
    ftLastAccessTime: TFileTime; // @offset $0C
    ftLastWriteTime: TFileTime; // @offset $14
    nFileSizeHigh: Cardinal; // @offset $1C
    nFileSizeLow: Cardinal; // @offset $20
    dwReserved0: Cardinal; // @offset $24
    dwReserved1: Cardinal; // @offset $28
    cFileName: array[0..259] of AnsiChar; // @offset $2C
    cAlternateFileName: array[0..13] of AnsiChar; // @offset $130
  end;

  TTrackMouseEvent = packed record // @size $10
    cbSize: Cardinal; // @offset $00
    dwFlags: Cardinal; // @offset $04
    hwndTrack: Cardinal; // @offset $08
    dwHoverTime: Cardinal; // @offset $0C
  end;

  TWinMsg = TMsg;

function HwndMSWheel(var puiMsh_MsgMouseWheel, puiMsh_Msg3DSupport, puiMsh_MsgScrollLines: Cardinal; var pf3DSupport: LongBool; var piScrollLines: Integer): Cardinal; // @note "DCC32 MAP Windows.HwndMSWheel. Source rtl/win/Windows.pas:31956."

procedure FinalizeWindows; // @nameonly @note "DCC32 MAP Windows.Finalization. Prototype pending: no unique source declaration."

function CreateWindowExPreservingFpuW(ExStyle: Cardinal; ClassName, WindowName: PWideChar; Style: Cardinal; X, Y, Width, Height: Integer; Parent, Menu, Instance: Cardinal; Param: Pointer): Cardinal; // @addr $408940

implementation
end.
