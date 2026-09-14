unit EC_OKGF;

interface

uses Types;


type
  TOkgfImageKind = (oikUnknown = 0, oikBmp = 1, oikIndexedBmp = 2,
    oikJpeg = 3, oikPng = 4, oikIndexedPsd = 5, oikGrayscalePsd = 6,
    oikRgbPsd = 7, oikCmykPsd = 8); // @size 0x04

  TOkgfReadContext = packed record // @size 0x20
    CodecContext: Pointer; // @offset 0x00
    ImageKind: TOkgfImageKind; // @offset 0x04
    Width: Integer; // @offset 0x08
    Height: Integer; // @offset 0x0C
    PaletteCount: Integer; // @offset 0x10
    SourceData: Pointer; // @offset 0x14
    SourceSize: Integer; // @offset 0x18
    OwnsSource: Integer; // @offset 0x1C
  end;
  POkgfReadContext = ^TOkgfReadContext;

function OKGF_ZLib_UnCompress2(Dest: Pointer; DestCapacity: Integer; Source: Pointer; SourceSize: Integer): Integer; stdcall; external 'ZLib.dll' name 'OKGF_ZLib_UnCompress2'; // @addr $4B81C4 @note "Accepts a ZL02 header followed by a zlib stream. Returns the decompressed byte count or zero on invalid input/decompression failure. Native DLL export uses four stack arguments and RET 16."

implementation

uses GR_GraphBuf;

end.
