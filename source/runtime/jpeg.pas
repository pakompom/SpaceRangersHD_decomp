unit jpeg;
// Unit bracket (inferred): .text 0x00851D68..0x008650CF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008779F8..0x00877A8A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System, Classes, Graphics, Types;

type
  TJPEGPerformance = (jpBestQuality = 0, jpBestSpeed = 1); // @size 0x01
  TJPEGScale = (jsFullSize = 0, jsHalf = 1, jsQuarter = 2, jsEighth = 3); // @size 0x01
  TJPEGPixelFormat = (jf24Bit = 0, jf8Bit = 1); // @size 0x01

  TJPEGData = class(TSharedImage) // @size 0x18
  public
    Data: TCustomMemoryStream; // @offset 0x08
    Height: Integer; // @offset 0x0C
    Width: Integer; // @offset 0x10
    Grayscale: Boolean; // @offset 0x14

    destructor Destroy; override;
    procedure FreeHandle; virtual; // @addr 0x852074 @slot 0x00 @note "Empty; the stream is released by Destroy."
  end;

  TJPEGImage = class(TGraphic) // @size 0x48
  public
    Image: TJPEGData; // @offset 0x28
    Bitmap: TBitmap; // @offset 0x2C
    ScaledWidth: Integer; // @offset 0x30
    ScaledHeight: Integer; // @offset 0x34
    TempPalette: Cardinal; // @offset 0x38
    Smoothing: Boolean; // @offset 0x3C
    Grayscale: Boolean; // @offset 0x3D
    PixelFormat: TJPEGPixelFormat; // @offset 0x3E
    Quality: Byte; // @offset 0x3F
    property CompressionQuality: Byte read Quality write Quality;
    ProgressiveDisplay: Boolean; // @offset 0x40
    ProgressiveEncoding: Boolean; // @offset 0x41
    Performance: TJPEGPerformance; // @offset 0x42
    Scale: TJPEGScale; // @offset 0x43
    NeedsSizeRecalc: Boolean; // @offset 0x44

    constructor Create; override; // @slot 0x48
    destructor Destroy; override;
    procedure AssignTo(Dest: TPersistent); virtual; // @slot 0x00
    procedure Assign(Source: TPersistent); virtual; // @slot 0x08 @note "JPEG sources share compressed data; bitmap sources copy pixels into a fresh image."
    procedure Changed(Sender: TObject); override; // @addr 0x8525B8 @slot 0x10
    procedure Draw(Canvas: TCanvas; Rect: TRect); virtual; // @slot 0x14
    function Equals(Graphic: TGraphic): Boolean; override; // @slot 0x18
    function GetEmpty: Boolean; virtual; // @slot 0x1C
    function GetHeight: Integer; virtual; // @slot 0x20
    function GetPalette: Cardinal; virtual; // @slot 0x24 @note "May allocate and retain a halftone palette."
    function GetWidth: Integer; virtual; // @slot 0x2C
    procedure ReadData(Stream: TStream); virtual; // @slot 0x30 @note "Reads a signed 32-bit byte count followed by that many JPEG bytes."
    procedure SetHeight(Value: Integer); virtual; // @addr 0x853248 @slot 0x34 @note "Always raises an invalid-operation error."
    procedure SetPalette(Value: Cardinal); virtual; // @slot 0x38 @note "Takes ownership of Value and deletes the previous temporary palette."
    procedure SetWidth(Value: Integer); virtual; // @addr 0x8532E8 @slot 0x40 @note "Always raises an invalid-operation error."
    procedure WriteData(Stream: TStream); virtual; // @slot 0x44 @note "Writes a 32-bit length and existing compressed bytes; does not compress a pending bitmap."
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x54 @note "Consumes the remaining stream bytes; the remaining length is truncated to 32 bits."
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x58 @note "Ensures compressed data exists and writes it without a length prefix."

    procedure NewImage; // @note "Releases shared compressed data and creates a new empty image; Bitmap is retained."
    procedure NewBitmap;
    procedure FreeBitmap; // @addr 0x8529A4
    function GetBitmap: TBitmap; // @note "Lazily decodes the JPEG; returns a borrowed bitmap owned by Self."
    procedure CalcOutputDimensions;
    procedure Compress; // @note "Replaces compressed data using Bitmap and the current encoding options."
    procedure EnsureJpegData; // @addr 0x852FEC
    procedure ReadJpegData(ByteCount: Integer; Stream: TStream); // @note "Replaces image data and validates the JPEG header before marking the graphic changed."
  public
    procedure LoadFromClipboardFormat; // @nameonly @note "DCC32 MAP jpeg.TJPEGImage.LoadFromClipboardFormat. Prototype pending: no unique source declaration."
    procedure SaveToClipboardFormat; // @nameonly @note "DCC32 MAP jpeg.TJPEGImage.SaveToClipboardFormat. Prototype pending: no unique source declaration."
  end;

// C library bridges use the stream's virtual byte-oriented Read/Write methods.
function JpegAllocate(ByteCount: Integer): Pointer; cdecl; // @addr 0x851EA8
procedure JpegFree(Block: Pointer); cdecl; // @addr 0x851EB8
procedure JpegFill(Buffer: Pointer; Value: Byte; ByteCount: Integer); cdecl;
procedure JpegMove(Dest, Source: Pointer; ByteCount: Integer); cdecl; // @addr 0x851EDC
function JpegStreamRead(Buffer: Pointer; ElementSize, ElementCount: Integer; Stream: TStream): Integer; cdecl; // @note "Returns bytes read, not the number of complete elements."
function JpegStreamWrite(Buffer: Pointer; ElementSize, ElementCount: Integer; Stream: TStream): Integer; cdecl; // @note "Returns bytes written, not the number of complete elements."

procedure __ftol; // @nameonly @note "DCC32 MAP jpeg.__ftol. Prototype pending: no unique source declaration."

procedure JpegError; // @nameonly @note "DCC32 MAP jpeg.JpegError. Prototype pending: no unique source declaration."

procedure ReleaseContext; // @nameonly @note "DCC32 MAP jpeg.ReleaseContext. Prototype pending: no unique source declaration."

procedure InitDecompressor; // @nameonly @note "DCC32 MAP jpeg.InitDecompressor. Prototype pending: no unique source declaration."

procedure BuildPalette; // @nameonly @note "DCC32 MAP jpeg.BuildPalette. Prototype pending: no unique source declaration."

procedure BuildColorMap; // @nameonly @note "DCC32 MAP jpeg.BuildColorMap. Prototype pending: no unique source declaration."

procedure InitDefaults; // @nameonly @note "DCC32 MAP jpeg.InitDefaults. Prototype pending: no unique source declaration."

procedure jpeg_CreateDecompress; // @nameonly @note "DCC32 MAP jpeg.jpeg_CreateDecompress. Prototype pending: no unique source declaration."

procedure jpeg_read_header; // @nameonly @note "DCC32 MAP jpeg.jpeg_read_header. Prototype pending: no unique source declaration."

procedure jpeg_consume_input; // @nameonly @note "DCC32 MAP jpeg.jpeg_consume_input. Prototype pending: no unique source declaration."

procedure jpeg_has_multiple_scans; // @nameonly @note "DCC32 MAP jpeg.jpeg_has_multiple_scans. Prototype pending: no unique source declaration."

procedure jpeg_finish_decompress; // @nameonly @note "DCC32 MAP jpeg.jpeg_finish_decompress. Prototype pending: no unique source declaration."

procedure jinit_memory_mgr; // @nameonly @note "DCC32 MAP jpeg.@jinit_memory_mgr. Prototype pending: no unique source declaration."

procedure jinit_input_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_input_controller. Prototype pending: no unique source declaration."

procedure jpeg_stdio_src; // @nameonly @note "DCC32 MAP jpeg.jpeg_stdio_src. Prototype pending: no unique source declaration."

procedure jpeg_start_decompress; // @nameonly @note "DCC32 MAP jpeg.jpeg_start_decompress. Prototype pending: no unique source declaration."

procedure jpeg_read_scanlines; // @nameonly @note "DCC32 MAP jpeg.jpeg_read_scanlines. Prototype pending: no unique source declaration."

procedure jpeg_start_output; // @nameonly @note "DCC32 MAP jpeg.jpeg_start_output. Prototype pending: no unique source declaration."

procedure jpeg_finish_output; // @nameonly @note "DCC32 MAP jpeg.jpeg_finish_output. Prototype pending: no unique source declaration."

procedure jpeg_calc_output_dimensions; // @nameonly @note "DCC32 MAP jpeg.jpeg_calc_output_dimensions. Prototype pending: no unique source declaration."

procedure jinit_master_decompress; // @nameonly @note "DCC32 MAP jpeg.@jinit_master_decompress. Prototype pending: no unique source declaration."

procedure jinit_phuff_decoder; // @nameonly @note "DCC32 MAP jpeg.@jinit_phuff_decoder. Prototype pending: no unique source declaration."

procedure jpeg_make_d_derived_tbl; // @nameonly @note "DCC32 MAP jpeg.@jpeg_make_d_derived_tbl. Prototype pending: no unique source declaration."

procedure jpeg_fill_bit_buffer; // @nameonly @note "DCC32 MAP jpeg.@jpeg_fill_bit_buffer. Prototype pending: no unique source declaration."

procedure jpeg_huff_decode; // @nameonly @note "DCC32 MAP jpeg.@jpeg_huff_decode. Prototype pending: no unique source declaration."

procedure jinit_huff_decoder; // @nameonly @note "DCC32 MAP jpeg.@jinit_huff_decoder. Prototype pending: no unique source declaration."

procedure jinit_merged_upsampler; // @nameonly @note "DCC32 MAP jpeg.@jinit_merged_upsampler. Prototype pending: no unique source declaration."

procedure jinit_color_deconverter; // @nameonly @note "DCC32 MAP jpeg.@jinit_color_deconverter. Prototype pending: no unique source declaration."

procedure jinit_1pass_quantizer; // @nameonly @note "DCC32 MAP jpeg.@jinit_1pass_quantizer. Prototype pending: no unique source declaration."

procedure jinit_2pass_quantizer; // @nameonly @note "DCC32 MAP jpeg.@jinit_2pass_quantizer. Prototype pending: no unique source declaration."

procedure jinit_d_main_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_d_main_controller. Prototype pending: no unique source declaration."

procedure jinit_d_coef_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_d_coef_controller. Prototype pending: no unique source declaration."

procedure jinit_d_post_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_d_post_controller. Prototype pending: no unique source declaration."

procedure jinit_inverse_dct; // @nameonly @note "DCC32 MAP jpeg.@jinit_inverse_dct. Prototype pending: no unique source declaration."

procedure jinit_upsampler; // @nameonly @note "DCC32 MAP jpeg.@jinit_upsampler. Prototype pending: no unique source declaration."

procedure jpeg_idct_float; // @nameonly @note "DCC32 MAP jpeg.@jpeg_idct_float. Prototype pending: no unique source declaration."

procedure jpeg_idct_ifast; // @nameonly @note "DCC32 MAP jpeg.@jpeg_idct_ifast. Prototype pending: no unique source declaration."

procedure jpeg_idct_4x4; // @nameonly @note "DCC32 MAP jpeg.@jpeg_idct_4x4. Prototype pending: no unique source declaration."

procedure jpeg_idct_2x2; // @nameonly @note "DCC32 MAP jpeg.@jpeg_idct_2x2. Prototype pending: no unique source declaration."

procedure jpeg_idct_1x1; // @nameonly @note "DCC32 MAP jpeg.@jpeg_idct_1x1. Prototype pending: no unique source declaration."

procedure jpeg_resync_to_restart; // @nameonly @note "DCC32 MAP jpeg.@jpeg_resync_to_restart. Prototype pending: no unique source declaration."

procedure jinit_marker_reader; // @nameonly @note "DCC32 MAP jpeg.@jinit_marker_reader. Prototype pending: no unique source declaration."

procedure jpeg_save_markers; // @nameonly @note "DCC32 MAP jpeg.jpeg_save_markers. Prototype pending: no unique source declaration."

procedure jround_up; // @nameonly @note "DCC32 MAP jpeg.@jround_up. Prototype pending: no unique source declaration."

procedure jcopy_sample_rows; // @nameonly @note "DCC32 MAP jpeg.@jcopy_sample_rows. Prototype pending: no unique source declaration."

procedure jpeg_abort; // @nameonly @note "DCC32 MAP jpeg.@jpeg_abort. Prototype pending: no unique source declaration."

procedure jpeg_destroy; // @nameonly @note "DCC32 MAP jpeg.jpeg_destroy. Prototype pending: no unique source declaration."

procedure jpeg_alloc_quant_table; // @nameonly @note "DCC32 MAP jpeg.@jpeg_alloc_quant_table. Prototype pending: no unique source declaration."

procedure jpeg_alloc_huff_table; // @nameonly @note "DCC32 MAP jpeg.@jpeg_alloc_huff_table. Prototype pending: no unique source declaration."

procedure jpeg_stdio_dest; // @nameonly @note "DCC32 MAP jpeg.jpeg_stdio_dest. Prototype pending: no unique source declaration."

procedure jpeg_set_quality; // @nameonly @note "DCC32 MAP jpeg.jpeg_set_quality. Prototype pending: no unique source declaration."

procedure jpeg_set_defaults; // @nameonly @note "DCC32 MAP jpeg.jpeg_set_defaults. Prototype pending: no unique source declaration."

procedure jpeg_set_colorspace; // @nameonly @note "DCC32 MAP jpeg.jpeg_set_colorspace. Prototype pending: no unique source declaration."

procedure jpeg_simple_progression; // @nameonly @note "DCC32 MAP jpeg.jpeg_simple_progression. Prototype pending: no unique source declaration."

procedure jpeg_start_compress; // @nameonly @note "DCC32 MAP jpeg.jpeg_start_compress. Prototype pending: no unique source declaration."

procedure jpeg_write_scanlines; // @nameonly @note "DCC32 MAP jpeg.jpeg_write_scanlines. Prototype pending: no unique source declaration."

procedure jpeg_CreateCompress; // @nameonly @note "DCC32 MAP jpeg.jpeg_CreateCompress. Prototype pending: no unique source declaration."

procedure jpeg_suppress_tables; // @nameonly @note "DCC32 MAP jpeg.@jpeg_suppress_tables. Prototype pending: no unique source declaration."

procedure jpeg_finish_compress; // @nameonly @note "DCC32 MAP jpeg.jpeg_finish_compress. Prototype pending: no unique source declaration."

procedure jinit_compress_master; // @nameonly @note "DCC32 MAP jpeg.@jinit_compress_master. Prototype pending: no unique source declaration."

procedure jinit_marker_writer; // @nameonly @note "DCC32 MAP jpeg.@jinit_marker_writer. Prototype pending: no unique source declaration."

procedure jinit_c_master_control; // @nameonly @note "DCC32 MAP jpeg.@jinit_c_master_control. Prototype pending: no unique source declaration."

procedure jinit_c_main_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_c_main_controller. Prototype pending: no unique source declaration."

procedure jinit_c_prep_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_c_prep_controller. Prototype pending: no unique source declaration."

procedure jinit_c_coef_controller; // @nameonly @note "DCC32 MAP jpeg.@jinit_c_coef_controller. Prototype pending: no unique source declaration."

procedure jinit_color_converter; // @nameonly @note "DCC32 MAP jpeg.@jinit_color_converter. Prototype pending: no unique source declaration."

procedure jinit_downsampler; // @nameonly @note "DCC32 MAP jpeg.@jinit_downsampler. Prototype pending: no unique source declaration."

procedure jinit_forward_dct; // @nameonly @note "DCC32 MAP jpeg.@jinit_forward_dct. Prototype pending: no unique source declaration."

procedure jinit_phuff_encoder; // @nameonly @note "DCC32 MAP jpeg.@jinit_phuff_encoder. Prototype pending: no unique source declaration."

procedure jpeg_fdct_ifast; // @nameonly @note "DCC32 MAP jpeg.@jpeg_fdct_ifast. Prototype pending: no unique source declaration."

procedure jpeg_fdct_float; // @nameonly @note "DCC32 MAP jpeg.@jpeg_fdct_float. Prototype pending: no unique source declaration."

procedure jpeg_make_c_derived_tbl; // @nameonly @note "DCC32 MAP jpeg.@jpeg_make_c_derived_tbl. Prototype pending: no unique source declaration."

procedure jpeg_gen_optimal_table; // @nameonly @note "DCC32 MAP jpeg.@jpeg_gen_optimal_table. Prototype pending: no unique source declaration."

procedure jinit_huff_encoder; // @nameonly @note "DCC32 MAP jpeg.@jinit_huff_encoder. Prototype pending: no unique source declaration."

procedure Finalizejpeg; // @nameonly @note "DCC32 MAP jpeg.Finalization. Prototype pending: no unique source declaration."

implementation
end.
