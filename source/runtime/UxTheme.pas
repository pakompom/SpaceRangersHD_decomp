unit UxTheme;
// Unit bracket (inferred): .text 0x00429688..0x0042A240; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008763B0..0x008763B0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
function CallDrawThemeTextEx(Theme, DC: Cardinal; PartId, StateId: Integer; Text: PWideChar; CharCount: Integer; TextFlags: Cardinal; Rect: PRect; Options: Pointer): HResult; // @addr 0x429688 @note "Resolves DrawThemeTextEx lazily; returns E_NOTIMPL if unavailable."
function InitThemeLibrary: Boolean;
function UseThemes: Boolean;

type
  TBufferedPaintParams = record;

  TBPPaintParams = TBufferedPaintParams;

  PBPPaintParams = ^TBPPaintParams;

function BeginBufferedPaint(hdcTarget: Cardinal; var prcTarget: TRect; dwFormat: DWord; pPaintParams: PBPPaintParams; var phdc: Cardinal): Cardinal; // @note "DCC32 MAP UxTheme.BeginBufferedPaint. Source rtl/win/UxTheme.pas:5322."

function EndBufferedPaint(hBufferedPaint: Cardinal; fUpdateTarget: LongBool): HResult; // @note "DCC32 MAP UxTheme.EndBufferedPaint. Source rtl/win/UxTheme.pas:5341."

function BufferedPaintSetAlpha(hBufferedPaint: Cardinal; prc: PRect; alpha: Byte): HResult; // @note "DCC32 MAP UxTheme.BufferedPaintSetAlpha. Source rtl/win/UxTheme.pas:5439."

procedure FinalizeUxTheme; // @nameonly @note "DCC32 MAP UxTheme.Finalization. Prototype pending: no unique source declaration."

implementation
end.
