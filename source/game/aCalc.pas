unit aCalc;
// Native wrappers occupy $4D75A0..$4D75EB, separate from ThreadCalc.
// PACKAGEINFO visits aCalc immediately before its ThreadCalc dependency.

interface

uses ThreadCalc;

// UI-facing turn calculation wrappers.
procedure WaitForTurnCalculationUI; // @addr 0x4D75A0
function IsTurnCalculationRunningUI: Boolean; // @addr 0x4D75A8
procedure CalculateGalaxyTurnAndWait; // @addr 0x4D75BC
procedure QueueGalaxyTurnCalculation; // @addr 0x4D75C8
procedure CalculatePlayerStarTurnAndWait; // @addr 0x4D75D0
procedure QueuePlayerStarTurnCalculation; // @addr 0x4D75DC
procedure QueuePlayerStarPreparation; // @addr 0x4D75E4

var
  TurnCalculationPhase: TTurnCalculationPhase; // @addr 0x889218

implementation

uses ThreadCalc;

{ @routine $4D75A0 WaitForTurnCalculationUI }
procedure WaitForTurnCalculationUI;
begin
  WaitForTurnCalculation;
end;
{ @end $4D75A0 }

{ @routine $4D75A8 IsTurnCalculationRunningUI }
function IsTurnCalculationRunningUI: Boolean;
begin
  Result := IsTurnCalculationRunning;
end;
{ @end $4D75A8 }

{ @routine $4D75BC CalculateGalaxyTurnAndWait }
procedure CalculateGalaxyTurnAndWait;
begin
  StartGalaxyTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4D75BC }

{ @routine $4D75C8 QueueGalaxyTurnCalculation }
procedure QueueGalaxyTurnCalculation;
begin
  StartGalaxyTurnCalculation;
end;
{ @end $4D75C8 }

{ @routine $4D75D0 CalculatePlayerStarTurnAndWait }
procedure CalculatePlayerStarTurnAndWait;
begin
  StartPlayerStarTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4D75D0 }

{ @routine $4D75DC QueuePlayerStarTurnCalculation }
procedure QueuePlayerStarTurnCalculation;
begin
  StartPlayerStarTurnCalculation;
end;
{ @end $4D75DC }

{ @routine $4D75E4 QueuePlayerStarPreparation }
procedure QueuePlayerStarPreparation;
begin
  StartPlayerStarPreparation;
end;
{ @end $4D75E4 }

end.
