unit Themes;
// Unit bracket (inferred): .text 0x0044C0C8..0x0044CC3D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00875678..0x0087567F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

type
  TThemedReBar = ( trRebarDontCare, trRebarRoot, trGripper, trGripperVert, trBandNormal, trBandHot, trBandPressed, trBandDisabled, trBandChecked, trBandHotChecked, trChevronNormal, trChevronHot, trChevronPressed, trChevronDisabled, trChevronVertNormal, trChevronVertHot, trChevronVertPressed, trChevronVertDisabled ); // @size 0x1

  TThemeServices = class(TObject) // @size 0x70
  public
    constructor Create; virtual; // @ida "TThemeServices * __usercall $name@<eax>(void * SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);" @note "DCC32 MAP Themes.TThemeServices.Create. Source vcl/Themes.pas:504." @slot 0x4
    destructor Destroy; // @ida "void __usercall $name(TThemeServices *Self@<eax>, unsigned __int8 DestroyFlags@<dl>);" @note "DCC32 MAP Themes.TThemeServices.Destroy. Source vcl/Themes.pas:515."
    function GetTheme(Element: TThemedElement): Cardinal; // @ida "unsigned __int32 __usercall $name@<eax>(TThemeServices *Self@<eax>, TThemedElement Element@<dl>);" @note "DCC32 MAP Themes.TThemeServices.GetTheme. Source vcl/Themes.pas:522."
    function GetThemesEnabled: Boolean; // @ida "bool __usercall $name@<al>(TThemeServices *Self@<eax>);" @note "DCC32 MAP Themes.TThemeServices.GetThemesEnabled. Source vcl/Themes.pas:529."
    procedure DoOnThemeChange; virtual; // @ida "void __usercall $name(TThemeServices *Self@<eax>);" @note "DCC32 MAP Themes.TThemeServices.DoOnThemeChange. Source vcl/Themes.pas:534." @slot 0x0
    procedure UnloadThemeData; // @ida "void __usercall $name(TThemeServices *Self@<eax>);" @note "DCC32 MAP Themes.TThemeServices.UnloadThemeData. Source vcl/Themes.pas:540."
    procedure DrawEdge(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal; ContentRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^12>, unsigned __int32 Edge@<^8>, unsigned __int32 Flags@<^4>, PRect ContentRect@<^0>);" @note "DCC32 MAP Themes.TThemeServices.DrawEdge. Source vcl/Themes.pas:574."
    procedure DrawElement(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^4>, PRect ClipRect@<^0>);" @note "DCC32 MAP Themes.TThemeServices.DrawElement. Source vcl/Themes.pas:581."
    procedure DrawParentBackground(Window: Cardinal; Target: Cardinal; Details: PThemedElementDetails; OnlyIfTransparent: Boolean; Bounds: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 Window@<edx>, unsigned __int32 Target@<ecx>, PThemedElementDetails Details@<^8>, bool OnlyIfTransparent@<^4>, PRect Bounds@<^0>);" @note "DCC32 MAP Themes.TThemeServices.DrawParentBackground. Source vcl/Themes.pas:595."
    procedure GetElementDetails; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure GetElementDetails_44C5F4; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure GetElementDetails_44C690; // @nameonly @note "DCC32 MAP Themes.TThemeServices.GetElementDetails. Prototype pending: no unique source declaration."
    procedure PaintBorder(Control: TWinControl; EraseLRCorner: Boolean); // @ida "void __usercall $name(TThemeServices *Self@<eax>, TWinControl *Control@<edx>, bool EraseLRCorner@<cl>);" @note "DCC32 MAP Themes.TThemeServices.PaintBorder. Source vcl/Themes.pas:1779."
    procedure UpdateThemes; // @ida "void __usercall $name(TThemeServices *Self@<eax>);" @note "DCC32 MAP Themes.TThemeServices.UpdateThemes. Source vcl/Themes.pas:1823."
  end;

  TThemedElement = ( teButton, teClock, teComboBox, teEdit, teExplorerBar, teHeader, teListView, teMenu, tePage, teProgress, teRebar, teScrollBar, teSpin, teStartPanel, teStatus, teTab, teTaskBand, teTaskBar, teToolBar, teToolTip, teTrackBar, teTrayNotify, teTreeview, teWindow ); // @size 0x1

  TThemedElementDetails = record;

  PThemedElementDetails = ^TThemedElementDetails;

function UnthemedDesigner(AControl: TControl): Boolean; // @ida "bool __usercall $name@<al>(TControl *AControl@<eax>);" @note "DCC32 MAP Themes.UnthemedDesigner. Source vcl/Themes.pas:487."

function ThemeControl(AControl: TControl): Boolean; // @ida "bool __usercall $name@<al>(TControl *AControl@<eax>);" @note "DCC32 MAP Themes.ThemeControl. Source vcl/Themes.pas:1840."

procedure FinalizeThemes; // @nameonly @note "DCC32 MAP Themes.Finalization. Prototype pending: no unique source declaration."

implementation
end.
