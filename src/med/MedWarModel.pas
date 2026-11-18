unit MedWarModel;

interface

uses System.SysUtils;

type
  TMedWarStage = (wsNone, wsApproach, wsFighting, wsLooting, wsReleased, wsTransition);
function MedWarStage(Active: Boolean; HasObject: Boolean; Approach,Loot,Retreat: Word): TMedWarStage;
function MedWarLootRemaining(Loot,Duration: Word): Cardinal;
function MedWarDailyStep(Population: Integer; Special: Byte; Difficulty: Byte): Cardinal;
function MedWarEstimate(Counter: Word; Step: Cardinal): Cardinal;
function MedWarMessageMatches(Day,MonthByte: Byte; Year,Duration: Word;
  StartDay,Now: Cardinal): Boolean;

function MedWarDays(Ticks: Cardinal): string;

implementation

function MedWarMessageMatches(Day,MonthByte: Byte; Year,Duration: Word;
  StartDay,Now: Cardinal): Boolean;
const Starts: array[0..11] of Integer=(0,31,59,90,120,151,181,212,243,273,304,334);
      Lengths: array[0..11] of Integer=(31,28,31,30,31,30,31,31,30,31,30,31);
var Month: Integer; MessageDay: Int64;
begin
  Result:=False; Month:=MonthByte and $7F;
  if (Month>11) or (Day=0) or (Duration=0) then Exit;
  if Day>Lengths[Month] then Exit;
  MessageDay:=Int64(Year)*365+Starts[Month]+Day-1;
  Result:=(MessageDay>=Int64(StartDay)) and (MessageDay<=Int64(Now shr 8)) and
    (MessageDay-Int64(StartDay)+1=Duration);
end;

function MedWarDailyStep(Population: Integer; Special: Byte; Difficulty: Byte): Cardinal;
var Rate: Integer;
begin
  if (Special=$FF) or (Population<=800) then Rate:=41
  else Rate:=(4121-(1638400 div Population)) div 50;
  case Difficulty of
    0: Rate:=(7*Rate+5) div 10;
    2: Rate:=(3*Rate+1) div 2;
  end;
  if Rate>0 then Result:=Cardinal(Rate) else Result:=0;
end;

function MedWarEstimate(Counter: Word; Step: Cardinal): Cardinal;
begin
  if (Counter=0) or (Step=0) then Exit(0);
  Result:=(Cardinal(Counter)+Step-1) div Step;
end;

function MedWarStage(Active: Boolean; HasObject: Boolean; Approach,Loot,Retreat: Word): TMedWarStage;
begin
  if not Active then
  begin if HasObject then Exit(wsReleased) else Exit(wsNone); end;
  if not HasObject then Exit(wsTransition);
  if Approach>0 then Exit(wsApproach);
  if Loot>0 then Exit(wsLooting);
  if Retreat=0 then Exit(wsFighting);
  Result:=wsTransition;
end;

function MedWarLootRemaining(Loot,Duration: Word): Cardinal;
var Delta: Integer;
begin
  Delta:=Integer(Loot)-Integer(Duration shr 1);
  if Delta>0 then Result:=Cardinal(Delta) else Result:=0;
end;

function MedWarDays(Ticks: Cardinal): string;
begin
  if Ticks=0 then Exit('未知');
  if Ticks<256 then Exit('<1');
  Result:=UIntToStr((UInt64(Ticks)+255) div 256);
end;

end.
