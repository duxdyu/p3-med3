unit MedLoanRules;

interface

type
  TMedLoanDemand = packed record
    Rank, Surname, GivenName, Weeks: Byte;
    Principal: Word;
  end;
  TMedLoanQuote = packed record
    Due: Cardinal;
    Rate, Rank, Surname, GivenName: Byte;
    Principal: Word;
    Weeks, Decision, Lender, Borrower, City, Options: Byte;
  end;

function LoanMatches(Rank, Threshold, Comparison: Integer): Boolean;
function LoanQuote(Principal, Weeks, Tier: Integer; out Rate: Byte;
  out Due: Cardinal): Boolean;

implementation

uses System.Math;

function LoanMatches(Rank, Threshold, Comparison: Integer): Boolean;
begin
  Result := (Rank >= 0) and (Rank <= 7) and (Threshold >= 0) and
    (Threshold <= 7) and (Comparison in [0,1]);
  if Result then
    if Comparison=0 then Result:=Rank>Threshold else Result:=Rank<Threshold;
end;

function LoanQuote(Principal, Weeks, Tier: Integer; out Rate: Byte;
  out Due: Cardinal): Boolean;
var Product, Root, Base, RawRate, Factor, Amount: Single; I: Integer;
begin
  Rate:=0; Due:=0;
  Result:=(Principal>0) and (Principal<=65535) and (Weeks>0) and
    (Weeks<=255) and (Tier>=0) and (Tier<=4);
  if not Result then Exit;
  // Preserve the native x87 float-store boundaries. No RNG in previews.
  Product:=Single(Principal)*Single(Weeks);
  Root:=Sqrt(1.0/Product);
  Base:=Root*300.0+Single(1.2);
  RawRate:=Single(Tier+8)*Base;
  Rate:=Byte(Trunc(RawRate) and $FF);
  Factor:=Single(Rate)*Single(0.001)+1.0;
  Amount:=Principal;
  for I:=1 to Weeks do Amount:=Amount*Factor;
  if (Amount>65000) or (Amount<Principal) then Due:=65000
  else Due:=Cardinal(Trunc(Amount)) and $FFFF;
end;

end.
