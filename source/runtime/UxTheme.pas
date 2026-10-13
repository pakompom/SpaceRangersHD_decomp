unit UxTheme;

interface

uses System, Types, Windows;

type
  TMargins = record // @size 0x10
    cxLeftWidth: Integer; // @offset 0x00
    cxRightWidth: Integer; // @offset 0x04
    cyTopHeight: Integer; // @offset 0x08
    cyBottomHeight: Integer; // @offset 0x0C
  end;

procedure FreeThemeLibrary;
function CallDrawThemeTextEx(Theme, DC: Cardinal; PartId, StateId: Integer; Text: PWideChar; CharCount: Integer; TextFlags: Cardinal; Rect: PRect; Options: Pointer): HResult; // @addr 0x00429688 @note "Resolves DrawThemeTextEx lazily; returns E_NOTIMPL if unavailable."
function InitThemeLibrary: Boolean;
function UseThemes: Boolean;

type
  TBufferedPaintParams = record;

  TBPPaintParams = TBufferedPaintParams;

  PBPPaintParams = ^TBPPaintParams;

function BeginBufferedPaint(hdcTarget: Cardinal; var prcTarget: TRect; dwFormat: DWord; pPaintParams: PBPPaintParams; var phdc: Cardinal): Cardinal;

function EndBufferedPaint(hBufferedPaint: Cardinal; fUpdateTarget: LongBool): HResult;

function BufferedPaintSetAlpha(hBufferedPaint: Cardinal; prc: PRect; alpha: Byte): HResult;

procedure FinalizeUxTheme; // @nameonly

implementation
end.
