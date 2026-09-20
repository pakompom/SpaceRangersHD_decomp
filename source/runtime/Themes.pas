unit Themes;
// Unit bracket (inferred): .text 0x0044C0C8..0x0044CC3D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876678..0x0087667F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TThemedReBar = ( trRebarDontCare, trRebarRoot, trGripper, trGripperVert, trBandNormal, trBandHot, trBandPressed, trBandDisabled, trBandChecked, trBandHotChecked, trChevronNormal, trChevronHot, trChevronPressed, trChevronDisabled, trChevronVertNormal, trChevronVertHot, trChevronVertPressed, trChevronVertDisabled ); // @size 0x1

  TThemeServices = class(TObject) // @size 0x70
  public
    constructor Create; virtual; // @note "DCC32 MAP Themes.TThemeServices.Create. Source vcl/Themes.pas:504." @slot 0x4
    destructor Destroy; // @note "DCC32 MAP Themes.TThemeServices.Destroy. Source vcl/Themes.pas:515."
    function GetTheme(Element: TThemedElement): Cardinal; // @note "DCC32 MAP Themes.TThemeServices.GetTheme. Source vcl/Themes.pas:522."
    function GetThemesEnabled: Boolean; // @note "DCC32 MAP Themes.TThemeServices.GetThemesEnabled. Source vcl/Themes.pas:529."
    procedure DoOnThemeChange; virtual; // @note "DCC32 MAP Themes.TThemeServices.DoOnThemeChange. Source vcl/Themes.pas:534." @slot 0x0
    procedure UnloadThemeData; // @note "DCC32 MAP Themes.TThemeServices.UnloadThemeData. Source vcl/Themes.pas:540."
    procedure DrawEdge(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal; ContentRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^12>, unsigned __int32 Edge@<^8>, unsigned __int32 Flags@<^4>, PRect ContentRect@<^0>);" @note "DCC32 MAP Themes.TThemeServices.DrawEdge. Source vcl/Themes.pas:574."
    procedure DrawElement(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^4>, PRect ClipRect@<^0>);" @note "DCC32 MAP Themes.TThemeServices.DrawElement. Source vcl/Themes.pas:581."
    procedure DrawParentBackground(Window: Cardinal; Target: Cardinal; Details: PThemedElementDetails; OnlyIfTransparent: Boolean; Bounds: PRect); // @note "DCC32 MAP Themes.TThemeServices.DrawParentBackground. Source vcl/Themes.pas:595."
    procedure GetElementDetails; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure GetElementDetails_44C5F4; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure GetElementDetails_44C690; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure PaintBorder(Control: TWinControl; EraseLRCorner: Boolean); // @note "DCC32 MAP Themes.TThemeServices.PaintBorder. Source vcl/Themes.pas:1779."
    procedure UpdateThemes; // @note "DCC32 MAP Themes.TThemeServices.UpdateThemes. Source vcl/Themes.pas:1823."
  end;

  TThemedElement = ( teButton, teClock, teComboBox, teEdit, teExplorerBar, teHeader, teListView, teMenu, tePage, teProgress, teRebar, teScrollBar, teSpin, teStartPanel, teStatus, teTab, teTaskBand, teTaskBar, teToolBar, teToolTip, teTrackBar, teTrayNotify, teTreeview, teWindow ); // @size 0x1

  TThemedElementDetails = record;

  PThemedElementDetails = ^TThemedElementDetails;

function UnthemedDesigner(AControl: TControl): Boolean; // @note "DCC32 MAP Themes.UnthemedDesigner. Source vcl/Themes.pas:487."

function ThemeControl(AControl: TControl): Boolean; // @note "DCC32 MAP Themes.ThemeControl. Source vcl/Themes.pas:1840."

procedure FinalizeThemes; // @nameonly @note "DCC32 MAP Themes.Finalization. Prototype pending: no unique source declaration."

implementation
end.
