unit MedFireRules;

interface

// 0=pending, 1=confirmed spread, 2=ambiguous zero-spread/clamped timestamp.
function MedFirePhase(StartTime, NextTime, Now: Cardinal; SpreadSteps: Word): Integer;

implementation

function MedFirePhase(StartTime, NextTime, Now: Cardinal; SpreadSteps: Word): Integer;
begin
  if StartTime>Now then Exit(0);
  if SpreadSteps>0 then Exit(1);
  if NextTime=StartTime then Exit(0);
  Result:=2;
end;

end.
