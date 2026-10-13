unit aCalc;

interface

uses ThreadCalc;

// UI-facing turn calculation wrappers.
procedure WaitForTurnCalculationUI; // @addr 0x004D8F64
function IsTurnCalculationRunningUI: Boolean; // @addr 0x004D8F6C
procedure CalculateGalaxyTurnAndWait; // @addr 0x004D8F74
procedure QueueGalaxyTurnCalculation; // @addr 0x004D8F80
procedure CalculatePlayerStarTurnAndWait; // @addr 0x004D8F88
procedure QueuePlayerStarTurnCalculation; // @addr 0x004D8F94
procedure QueuePlayerStarPreparation; // @addr 0x004D8F9C

var
  TurnCalculationPhase: TTurnCalculationPhase; // @addr 0x0081AE00

implementation

uses ThreadCalc;

{ @routine $4D8F64 WaitForTurnCalculationUI }
procedure WaitForTurnCalculationUI;
begin
  WaitForTurnCalculation;
end;
{ @end $4D8F64 }

{ @routine $4D8F6C IsTurnCalculationRunningUI }
function IsTurnCalculationRunningUI: Boolean;
begin
  Result := IsTurnCalculationRunning;
end;
{ @end $4D8F6C }

{ @routine $4D8F74 CalculateGalaxyTurnAndWait }
procedure CalculateGalaxyTurnAndWait;
begin
  StartGalaxyTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4D8F74 }

{ @routine $4D8F80 QueueGalaxyTurnCalculation }
procedure QueueGalaxyTurnCalculation;
begin
  StartGalaxyTurnCalculation;
end;
{ @end $4D8F80 }

{ @routine $4D8F88 CalculatePlayerStarTurnAndWait }
procedure CalculatePlayerStarTurnAndWait;
begin
  StartPlayerStarTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4D8F88 }

{ @routine $4D8F94 QueuePlayerStarTurnCalculation }
procedure QueuePlayerStarTurnCalculation;
begin
  StartPlayerStarTurnCalculation;
end;
{ @end $4D8F94 }

{ @routine $4D8F9C QueuePlayerStarPreparation }
procedure QueuePlayerStarPreparation;
begin
  StartPlayerStarPreparation;
end;
{ @end $4D8F9C }

end.
