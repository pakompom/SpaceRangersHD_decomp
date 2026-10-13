unit ThreadCalc;

interface

uses EC_Thread;

type
  TTurnCalculationJob = (
    tcjGalaxy = 1, tcjPlayerStar = 2, tcjPreparePlayerStar = 3,
    tcjUnknown5 = 5 // Native hover guards exclude this job; its operation is not identified.
  ); // @size 0x4
  TTurnCalculationPhase = (
    tcpIdle = 0, // Zero-initialized phase; accepted by the native debug-key callback.
    tcpGalaxyRunning = 1, tcpGalaxyFinished = 2,
    tcpPlayerStarRunning = 3, tcpPlayerStarFinished = 4,
    tcpPlayerStarPreparationRunning = 5, tcpPlayerStarPrepared = 6,
    tcpNotStarted = $FFFFFFFF
  ); // @size 0x4

  TThreadCalc = class(TThreadEC) // @size 0x30
  public
    Job: TTurnCalculationJob; // @offset 0x2C
    procedure Execute; override; // @addr 0x006F3B88
  end;

procedure StartGalaxyTurnCalculation; // @addr 0x006F38B0
procedure StartPlayerStarTurnCalculation; // @addr 0x006F38CC
procedure StartPlayerStarPreparation; // @addr 0x006F38E8
function IsTurnCalculationRunning: Boolean; // @addr 0x006F3904
procedure WaitForTurnCalculation; // @addr 0x006F3920 @note "Requires an initialized calculation thread."
procedure ProcessPlayerStarTurn; // @addr 0x006F3940


var
  AdaptiveBeginCalcNextTurn: Single = 0.5; // @addr $80FF54 Smoothed film-progress threshold derived from measured galaxy-turn duration.
  LastGalaxyTurnDuration: Integer; // @addr $81B8F8 Measured milliseconds; native smoothing uses signed arithmetic.

implementation

uses Windows, MMSystem, SysUtils, Math, Globals, GlobalsV, GR_Main, aGalaxy, aPlayer, aShip, aGalaxyStruct;

{ @routine $6F38B0 StartGalaxyTurnCalculation }
procedure StartGalaxyTurnCalculation;
begin
  TurnCalculationThread.Job := tcjGalaxy;
  TurnCalculationThread.Start;
end;
{ @end $6F38B0 }

{ @routine $6F38CC StartPlayerStarTurnCalculation }
procedure StartPlayerStarTurnCalculation;
begin
  TurnCalculationThread.Job := tcjPlayerStar;
  TurnCalculationThread.Start;
end;
{ @end $6F38CC }

{ @routine $6F38E8 StartPlayerStarPreparation }
procedure StartPlayerStarPreparation;
begin
  TurnCalculationThread.Job := tcjPreparePlayerStar;
  TurnCalculationThread.Start;
end;
{ @end $6F38E8 }

{ @routine $6F3904 IsTurnCalculationRunning }
function IsTurnCalculationRunning: Boolean;
begin
  if TurnCalculationThread = nil then Result := False
  else Result := TurnCalculationThread.IsRunning;
end;
{ @end $6F3904 }

{ @routine $6F3920 WaitForTurnCalculation }
procedure WaitForTurnCalculation;
begin
  if TurnCalculationThread.IsRunning then TurnCalculationThread.WaitForIdle(INFINITE);
end;
{ @end $6F3920 }

{ @routine $6F3940 ProcessPlayerStarTurn }
procedure ProcessPlayerStarTurn;
var RecordFilm: Boolean;
    Stage: Integer;
begin
  Stage := 0;
  try
    if not PlayerStarDayPrepared then PrimaryFilm.Clear;
    Stage := 1;
    RecordFilm := GetPlayer.InNormalSpace or
      ((GetPlayer.Order = soTakeoff) and ((GetPlayer.CurrentPlanet <> nil) or (GetPlayer.DockedTo <> nil))) or
      (GetPlayer.InHyperspace and (Cardinal(GetPlayer.OrderStateData and $FFFF) <= 1));
    PlayerStar.NextDay(RecordFilm);
    Stage := 2;
    if Galaxy.StasisModEnabled <> 1 then Galaxy.CompleteDay(RecordFilm);
    Stage := 3;
    Galaxy.TransferShipsInTransit;
    Stage := 4;
    PlayerStarDayPrepared := False;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      RequestedScreenId := screenNone;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
      ExitScreenLoop := True;
      raise Exception.Create('Error in procedure ThCa label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $6F3940 }

{ @routine $6F3B88 TThreadCalc_Execute }
procedure TThreadCalc.Execute;
var ControlWord: Word;
    StartTick, EndTick: Cardinal;
    FrameMs: Integer;
begin
  // Native handwritten x87 setup: each calculation thread establishes its own control word.
  asm
    mov ControlWord, $133F
    fclex
    and ControlWord, $FCFF
    fldcw ControlWord
  end;
  if Job = tcjGalaxy then
  begin
    TurnCalculationPhase := tcpGalaxyRunning;
    if Galaxy.StasisModEnabled <> 1 then
    try
      if (GetPlayer <> nil) and GetPlayer.InNormalSpace then
      begin
        StartTick := timeGetTime;
        Galaxy.NextDay;
        EndTick := timeGetTime;
        LastGalaxyTurnDuration := EndTick - StartTick;
        if FilmSpeed = 0 then FrameMs := 16
        else if FilmSpeed = 1 then FrameMs := 12
        else FrameMs := 8;
        AdaptiveBeginCalcNextTurn := Math.Min(0.9, (AdaptiveBeginCalcNextTurn + 1 -
          Math.Min(1, (LastGalaxyTurnDuration + 100) / (BaseMovementStepsPerTurn * FrameMs))) / 2);
      end
      else Galaxy.NextDay;
      Galaxy.TransferShipsInTransit;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe('ThreadCalc exception 1');
        if Galaxy.CurrentTurn < GalaxyWarmupTurns then
          AppendLogLineThreadSafe('Galaxy create exception, seed = ' + IntToStr(Integer(Galaxy.GenerationSeed)));
        SetEvent(IdleEvent);
        raise;
      end;
    end;
    TurnCalculationPhase := tcpGalaxyFinished;
  end
  else if Job = tcjPlayerStar then
  begin
    TurnCalculationPhase := tcpPlayerStarRunning;
    try
      ProcessPlayerStarTurn;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe('ThreadCalc exception 2');
        if Galaxy.CurrentTurn < GalaxyWarmupTurns then
          AppendLogLineThreadSafe('Galaxy create exception, seed = ' + IntToStr(Integer(Galaxy.GenerationSeed)));
        SetEvent(IdleEvent);
        raise;
      end;
    end;
    TurnCalculationPhase := tcpPlayerStarFinished;
  end
  else
  begin
    TurnCalculationPhase := tcpPlayerStarPreparationRunning;
    PlayerStarDayPrepared := True;
    try
      PrimaryFilm.Clear;
      if Galaxy.StasisModEnabled <> 1 then PlayerStar.PrepareNextDay;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe('ThreadCalc exception 3');
        if Galaxy.CurrentTurn < GalaxyWarmupTurns then
          AppendLogLineThreadSafe('Galaxy create exception, seed = ' + IntToStr(Integer(Galaxy.GenerationSeed)));
        SetEvent(IdleEvent);
        raise;
      end;
    end;
    TurnCalculationPhase := tcpPlayerStarPrepared;
  end;
end;
{ @end $6F3B88 }

end.
