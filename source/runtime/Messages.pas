unit Messages;

interface

type
  TMessage = record;

  TWMInitDialog = record;

  TWMNoParams = record;

  TWMNCDestroy = TWMNoParams;

  TWMKey = record;

  TWMMenuChar = record;

  TWMMouse = record;

  TWMLButtonDown = TWMMouse;

  TWMNCHitMessage = record;

  TWMNCLButtonDown = TWMNCHitMessage;

  TWMLButtonDblClk = TWMMouse;

  TWMMouseMove = TWMMouse;

  TWMLButtonUp = TWMMouse;

  TWMRButtonUp = TWMMouse;

  TWMMButtonUp = TWMMouse;

  TWMMouseWheel = record;

  TWMCancelMode = TWMNoParams;

  TWMWindowPosMsg = record;

  TWMWindowPosChanged = TWMWindowPosMsg;

  TWMContextMenu = record;

  TWMMouseActivate = record;

  TWMPaint = record;

  TWMNotify = record;

  TWMSysColorChange = TWMNoParams;

  TWMCompareItem = record;

  TWMDeleteItem = record;

  TWMDrawItem = record;

  TWMMeasureItem = record;

  TWMEraseBkgnd = record;

  TWMWindowPosChanging = TWMWindowPosMsg;

  TWMSize = record;

  TWMMove = record;

  TWMSetFocus = record;

  TWMSysCommand = record;

  TWMParentNotify = record;

  TWMDestroy = TWMNoParams;

  TWMNCHitTest = record;

  TWMKeyDown = TWMKey;

  TWMKeyUp = TWMKey;

  TWMChar = TWMKey;

  TWMNCCalcSize = record;

  TWMPrint = record;

  TWMPrintClient = TWMPrint;

  TWMScroll = record;

  TWMHScroll = TWMScroll;

  TWMVScroll = TWMScroll;

  TWMNCPaint = record;

  TWMIconEraseBkgnd = TWMEraseBkgnd;

  TWMNCCreate = record;

  TWMCommand = record;

  TWMInitMenuPopup = record;

  TWMMenuSelect = record;

  TWMActivate = record;

  TWMQueryEndSession = record;

  TWMShowWindow = record;

  TWMMDIActivate = record;

  TWMHelp = record;

  TWMGetMinMaxInfo = record;

  TWMSettingChange = record;

implementation
end.
