unit fCustom;

interface

uses GI_MessageLoop, EC_BlockPar;

type
  TfCustomLoop = class(TMessageLoopGI) // @size $D8
  public
    ReservedBeforeText: WideString; // @offset $D0 Native cleanup at $621F10; purpose unresolved.
    ReservedAfterText: WideString; // @offset $D4
    procedure InitializeLayout; override; // @addr $621F38
    procedure ProcessCallbackTimers; override; // @addr $621F4C
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr $621F80
  end;

// Native TfCustomLoop VMT $621ED0 and the surrounding modal launcher establish ownership.
function ShowCustomDialog(Parent: TMessageLoopGI; const ScreenName: WideString): Integer; // @addr $621FF8 @note "Loads the named layout and executes its opening/closing script text. Restores the previous active custom dialog on return."

var
  CurrentCustomDialog: TMessageLoopGI = nil; // @addr $87B7A0 Borrowed while ShowCustomDialog is active; nested custom dialogs restore the previous value.

implementation

uses GR_Main, Globals, GlobalsV, GI_GraphBuf, aGalaxy, aGalaxyStruct, aScript;

{ @routine $621F38 TfCustomLoop_InitializeLayout }
procedure TfCustomLoop.InitializeLayout;
begin
  inherited;
end;
{ @end $621F38 }

{ @routine $621F4C TfCustomLoop_ProcessCallbackTimers }
procedure TfCustomLoop.ProcessCallbackTimers;
begin
  inherited;
  if ParentLoop.ExitCode <> 0 then
    if ExitCode = 0 then RequestClose(255);
end;
{ @end $621F4C }

{ @routine $621F80 TfCustomLoop_ExecuteUiCode }
procedure TfCustomLoop.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop and (TurnCalculationPhase in [tcpIdle,tcpGalaxyFinished,tcpPlayerStarFinished,tcpPlayerStarPrepared]) then
  begin
    if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(30011);
    ExecuteGameplayUiCode(Block,Key);
    if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(40011);
  end;
end;
{ @end $621F80 }

{ @routine $621FF8 ShowCustomDialog }
function ShowCustomDialog(Parent: TMessageLoopGI; const ScreenName: WideString): Integer;
var
  Dialog: TfCustomLoop;
  Previous: TMessageLoopGI;
  Block: TBlockParEC;
  Background: TObjectGI;
  BeforeCode, AfterCode: WideString;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(False,0);
  Dialog := TfCustomLoop.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeFromConfig(UiStyleConfig,ScreenName,True);
  Block := UiStyleConfig.GetBlock(ScreenName).FindBlock('CodeBeforeRun');
  if Block <> nil then BeforeCode := Block.ConcatenateValues else BeforeCode := '';
  Block := UiStyleConfig.GetBlock(ScreenName).FindBlock('CodeAfterRun');
  if Block <> nil then AfterCode := Block.ConcatenateValues else AfterCode := '';
  Dialog.InitializeLayout;
  Previous := CurrentCustomDialog;
  try
    CurrentCustomDialog := Dialog;
    ExecuteScriptText(BeforeCode,nil);
    Background := Dialog.FindControlByPath('BGBuf');
    if Background <> nil then
    begin
      CaptureScreenBackground(True,0);
      (Background as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
    end;
    Result := Dialog.Run;
    ExecuteScriptText(AfterCode,nil);
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    CurrentCustomDialog := Previous;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
end;
{ @end $621FF8 }

end.

