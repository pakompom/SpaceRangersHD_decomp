unit Themes;

interface

type
  TThemedReBar = ( trRebarDontCare, trRebarRoot, trGripper, trGripperVert, trBandNormal, trBandHot, trBandPressed, trBandDisabled, trBandChecked, trBandHotChecked, trChevronNormal, trChevronHot, trChevronPressed, trChevronDisabled, trChevronVertNormal, trChevronVertHot, trChevronVertPressed, trChevronVertDisabled ); // @size 0x1

  TThemeServices = class(TObject) // @size 0x70
  public
    procedure DoOnThemeChange; virtual; // @slot 0x0
    destructor Destroy;
    function GetTheme(Element: TThemedElement): Cardinal;
    function GetThemesEnabled: Boolean;
    constructor Create; virtual; // @slot 0x4
    procedure UnloadThemeData;
    procedure DrawEdge(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal; ContentRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^12>, unsigned __int32 Edge@<^8>, unsigned __int32 Flags@<^4>, PRect ContentRect@<^0>);"
    procedure DrawElement(DC: Cardinal; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect); // @ida "void __userpurge $name(TThemeServices *Self@<eax>, unsigned __int32 DC@<edx>, TThemedElementDetails *Details@<ecx>, TRect *R@<^4>, PRect ClipRect@<^0>);"
    procedure DrawParentBackground(Window: Cardinal; Target: Cardinal; Details: PThemedElementDetails; OnlyIfTransparent: Boolean; Bounds: PRect);
    procedure GetElementDetails; // @nameonly
    procedure GetElementDetails_44C5F4; // @nameonly
    procedure GetElementDetails_44C690; // @nameonly
    procedure PaintBorder(Control: TWinControl; EraseLRCorner: Boolean);
    procedure UpdateThemes;
  end;

  TThemedElement = ( teButton, teClock, teComboBox, teEdit, teExplorerBar, teHeader, teListView, teMenu, tePage, teProgress, teRebar, teScrollBar, teSpin, teStartPanel, teStatus, teTab, teTaskBand, teTaskBar, teToolBar, teToolTip, teTrackBar, teTrayNotify, teTreeview, teWindow ); // @size 0x1

  TThemedElementDetails = record;

  PThemedElementDetails = ^TThemedElementDetails;

function UnthemedDesigner(AControl: TControl): Boolean;

function ThemeControl(AControl: TControl): Boolean;

procedure FinalizeThemes; // @nameonly

implementation
end.
