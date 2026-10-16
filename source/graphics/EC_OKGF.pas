unit EC_OKGF;

interface

uses Types;


type
  TOkgfImageFormat = (image_format_unknown = 0, image_format_bmp = 1, image_format_bmp_indexed = 2,
    image_format_jpeg = 3, image_format_png = 4, image_format_psd_indexed = 5, image_format_psd_grayscale = 6,
    image_format_psd_rgb = 7, image_format_psd_cmyk = 8); // @size 0x04

  TOkgfReadContext = packed record // @size 0x20
    CodecContext: Pointer; // @offset 0x00
    ImageKind: TOkgfImageFormat; // @offset 0x04
    Width: Integer; // @offset 0x08
    Height: Integer; // @offset 0x0C
    PaletteCount: Integer; // @offset 0x10
    SourceData: Pointer; // @offset 0x14
    SourceSize: Integer; // @offset 0x18
    OwnsSource: Integer; // @offset 0x1C
  end;
  POkgfReadContext = ^TOkgfReadContext;

function OKGF_ZLib_UnCompress2(Dest: Pointer; DestCapacity: Integer; Source: Pointer; SourceSize: Integer): Integer; stdcall; external 'ZLib.dll' name 'OKGF_ZLib_UnCompress2'; // @addr $4829CC @note "Accepts a ZL02 header followed by a zlib stream. Returns the decompressed byte count or zero on invalid input/decompression failure. Native DLL export uses four stack arguments and RET 16."

implementation

uses GR_GraphBuf;

end.
