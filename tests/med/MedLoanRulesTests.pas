unit MedLoanRulesTests;
interface
procedure RunLoanRuleTests;
implementation
uses System.SysUtils, MedLoanRules;
procedure RunLoanRuleTests;
const
  Principals: array[0..2] of Integer=(8284,6181,9621);
  Weeks: array[0..2] of Integer=(34,11,14);
  Rates: array[0..2,0..4] of Byte=((14,15,17,19,21),(18,21,23,25,28),(16,18,20,22,24));
  Dues: array[0..2,0..4] of Cardinal=((13290,13743,14694,15709,16792),
    (7521,7768,7937,8110,8374),(12015,12350,12694,13047,13409));
var I,J: Integer; Rate: Byte; Due: Cardinal;
begin
  if (SizeOf(TMedLoanDemand)<>6) or (SizeOf(TMedLoanQuote)<>16) then
    raise Exception.Create('Loan ABI layout');
  for I:=0 to 2 do for J:=0 to 4 do
    if not LoanQuote(Principals[I],Weeks[I],J,Rate,Due) or
      (Rate<>Rates[I,J]) or (Due<>Dues[I,J]) then
      raise Exception.CreateFmt('Native loan fixture %d/%d: rate=%d due=%d',[I,J,Rate,Due]);
  for I:=0 to 7 do for J:=0 to 7 do
    if (LoanMatches(I,J,0)<>(I>J)) or (LoanMatches(I,J,1)<>(I<J)) then
      raise Exception.Create('Strict rank boundary');
  if LoanMatches(255,1,0) or LoanMatches(2,-1,0) or LoanMatches(2,1,2) or
    LoanQuote(0,12,2,Rate,Due) or LoanQuote(100,0,2,Rate,Due) or
    LoanQuote(100,12,5,Rate,Due) then raise Exception.Create('Invalid loan input accepted');
  if not LoanQuote(65000,255,4,Rate,Due) or (Due<>65000) then
    raise Exception.Create('Native repayment cap');
  Writeln('PASS: 15 recorded native loan quotes, ABI, strict rank comparisons, invalid inputs and cap');
end;
end.
