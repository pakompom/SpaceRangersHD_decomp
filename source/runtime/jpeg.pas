unit jpeg;

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
    procedure FreeHandle; virtual; // @addr 0x0046EDA4 @slot 0x00 @note "Empty; the stream is released by Destroy."
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
    procedure Changed(Sender: TObject); override; // @addr 0x0046F2E8 @slot 0x10
    procedure Draw(Canvas: TCanvas; Rect: TRect); virtual; // @slot 0x14
    function Equals(Graphic: TGraphic): Boolean; override; // @slot 0x18
    function GetEmpty: Boolean; virtual; // @slot 0x1C
    function GetHeight: Integer; virtual; // @slot 0x20
    function GetPalette: Cardinal; virtual; // @slot 0x24 @note "May allocate and retain a halftone palette."
    function GetWidth: Integer; virtual; // @slot 0x2C
    procedure ReadData(Stream: TStream); virtual; // @slot 0x30 @note "Reads a signed 32-bit byte count followed by that many JPEG bytes."
    procedure SetHeight(Value: Integer); virtual; // @addr 0x0046FF78 @slot 0x34 @note "Always raises an invalid-operation error."
    procedure SetPalette(Value: Cardinal); virtual; // @slot 0x38 @note "Takes ownership of Value and deletes the previous temporary palette."
    procedure SetWidth(Value: Integer); virtual; // @addr 0x00470018 @slot 0x40 @note "Always raises an invalid-operation error."
    procedure WriteData(Stream: TStream); virtual; // @slot 0x44 @note "Writes a 32-bit length and existing compressed bytes; does not compress a pending bitmap."
    procedure LoadFromStream(Stream: TStream); virtual; // @slot 0x54 @note "Consumes the remaining stream bytes; the remaining length is truncated to 32 bits."
    procedure SaveToStream(Stream: TStream); virtual; // @slot 0x58 @note "Ensures compressed data exists and writes it without a length prefix."

    procedure NewImage; // @note "Releases shared compressed data and creates a new empty image; Bitmap is retained."
    procedure NewBitmap;
    procedure FreeBitmap; // @addr 0x0046F6D4
    function GetBitmap: TBitmap; // @note "Lazily decodes the JPEG; returns a borrowed bitmap owned by Self."
    procedure CalcOutputDimensions;
    procedure Compress; // @note "Replaces compressed data using Bitmap and the current encoding options."
    procedure EnsureJpegData; // @addr 0x0046FD1C
    procedure ReadJpegData(ByteCount: Integer; Stream: TStream); // @note "Replaces image data and validates the JPEG header before marking the graphic changed."
  public
    procedure LoadFromClipboardFormat; // @nameonly
    procedure SaveToClipboardFormat; // @nameonly
  end;

// C library bridges use the stream's virtual byte-oriented Read/Write methods.
function JpegAllocate(ByteCount: Integer): Pointer; cdecl; // @addr 0x0046EBD8
procedure JpegFree(Block: Pointer); cdecl; // @addr 0x0046EBE8
procedure JpegFill(Buffer: Pointer; Value: Byte; ByteCount: Integer); cdecl;
procedure JpegMove(Dest, Source: Pointer; ByteCount: Integer); cdecl; // @addr 0x0046EC0C
function JpegStreamRead(Buffer: Pointer; ElementSize, ElementCount: Integer; Stream: TStream): Integer; cdecl; // @note "Returns bytes read, not the number of complete elements."
function JpegStreamWrite(Buffer: Pointer; ElementSize, ElementCount: Integer; Stream: TStream): Integer; cdecl; // @note "Returns bytes written, not the number of complete elements."

procedure __ftol; // @nameonly

procedure JpegError; // @nameonly

procedure ReleaseContext; // @nameonly

procedure InitDecompressor; // @nameonly

procedure BuildPalette; // @nameonly

procedure BuildColorMap; // @nameonly

procedure InitDefaults; // @nameonly

procedure jpeg_CreateDecompress; // @nameonly

procedure jpeg_read_header; // @nameonly

procedure jpeg_consume_input; // @nameonly

procedure jpeg_has_multiple_scans; // @nameonly

procedure jpeg_finish_decompress; // @nameonly

procedure jinit_memory_mgr; // @nameonly

procedure jinit_input_controller; // @nameonly

procedure jpeg_stdio_src; // @nameonly

procedure jpeg_start_decompress; // @nameonly

procedure jpeg_read_scanlines; // @nameonly

procedure jpeg_start_output; // @nameonly

procedure jpeg_finish_output; // @nameonly

procedure jpeg_calc_output_dimensions; // @nameonly

procedure jinit_master_decompress; // @nameonly

procedure jinit_phuff_decoder; // @nameonly

procedure jpeg_make_d_derived_tbl; // @nameonly

procedure jpeg_fill_bit_buffer; // @nameonly

procedure jpeg_huff_decode; // @nameonly

procedure jinit_huff_decoder; // @nameonly

procedure jinit_merged_upsampler; // @nameonly

procedure jinit_color_deconverter; // @nameonly

procedure jinit_1pass_quantizer; // @nameonly

procedure jinit_2pass_quantizer; // @nameonly

procedure jinit_d_main_controller; // @nameonly

procedure jinit_d_coef_controller; // @nameonly

procedure jinit_d_post_controller; // @nameonly

procedure jinit_inverse_dct; // @nameonly

procedure jinit_upsampler; // @nameonly

procedure jpeg_idct_float; // @nameonly

procedure jpeg_idct_ifast; // @nameonly

procedure jpeg_idct_4x4; // @nameonly

procedure jpeg_idct_2x2; // @nameonly

procedure jpeg_idct_1x1; // @nameonly

procedure jpeg_resync_to_restart; // @nameonly

procedure jinit_marker_reader; // @nameonly

procedure jpeg_save_markers; // @nameonly

procedure jround_up; // @nameonly

procedure jcopy_sample_rows; // @nameonly

procedure jpeg_abort; // @nameonly

procedure jpeg_destroy; // @nameonly

procedure jpeg_alloc_quant_table; // @nameonly

procedure jpeg_alloc_huff_table; // @nameonly

procedure jpeg_stdio_dest; // @nameonly

procedure jpeg_set_quality; // @nameonly

procedure jpeg_set_defaults; // @nameonly

procedure jpeg_set_colorspace; // @nameonly

procedure jpeg_simple_progression; // @nameonly

procedure jpeg_start_compress; // @nameonly

procedure jpeg_write_scanlines; // @nameonly

procedure jpeg_CreateCompress; // @nameonly

procedure jpeg_suppress_tables; // @nameonly

procedure jpeg_finish_compress; // @nameonly

procedure jinit_compress_master; // @nameonly

procedure jinit_marker_writer; // @nameonly

procedure jinit_c_master_control; // @nameonly

procedure jinit_c_main_controller; // @nameonly

procedure jinit_c_prep_controller; // @nameonly

procedure jinit_c_coef_controller; // @nameonly

procedure jinit_color_converter; // @nameonly

procedure jinit_downsampler; // @nameonly

procedure jinit_forward_dct; // @nameonly

procedure jinit_phuff_encoder; // @nameonly

procedure jpeg_fdct_ifast; // @nameonly

procedure jpeg_fdct_float; // @nameonly

procedure jpeg_make_c_derived_tbl; // @nameonly

procedure jpeg_gen_optimal_table; // @nameonly

procedure jinit_huff_encoder; // @nameonly

procedure Finalizejpeg; // @nameonly

implementation
end.
