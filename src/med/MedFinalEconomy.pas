unit MedFinalEconomy;

interface

type
  TFinalFactoryCounts = array[0..17] of Integer;
  TFinalGoodsValues = array[0..19] of Integer;
  TFinalBalance = array[0..19, 0..15] of Int64;

// Reconstructed from MED final 00478810; all quantities are raw game units.
procedure CalculateFinalBalance(const Factories: TFinalFactoryCounts;
  const PopulationUse, CityOutput, CityUse, OfficeOutput, OfficeUse: TFinalGoodsValues;
  Days: Byte; out Balance: TFinalBalance);

implementation

uses System.Math;

const
  Goods: array[0..17,0..3] of Byte = (
    (9,255,17,12),(2,255,17,4),(3,255,11,0),(12,255,11,16),
    (5,255,255,255),(0,255,255,255),(1,13,11,4),(11,255,255,255),
    (8,255,14,255),(4,255,11,255),(16,255,255,255),(14,255,255,255),
    (7,255,255,255),(18,255,11,255),(19,255,11,255),(15,255,11,255),
    (17,255,255,255),(2,10,17,4));
  Rates: array[0..17,0..3] of Integer = (
    (200,0,10,10),(2000,0,200,400),(1410,0,141,352),(600,0,600,600),
    (400,0,0,0),(2000,0,0,0),(500,200,40,145),(4000,0,0,0),
    (600,0,600,0),(1001,0,800,0),(1000,0,0,0),(1002,0,0,0),
    (402,0,0,0),(402,0,402,0),(2010,0,1005,0),(200,0,200,0),
    (500,0,0,0),(1499,810,150,300));

procedure CalculateFinalBalance(const Factories: TFinalFactoryCounts;
  const PopulationUse, CityOutput, CityUse, OfficeOutput, OfficeUse: TFinalGoodsValues;
  Days: Byte; out Balance: TFinalBalance);
var Kind, Slot, G: Integer; Amount, Factor: Extended;
begin
  FillChar(Balance, SizeOf(Balance), 0);
  for Kind := 0 to 17 do
    for Slot := 0 to 3 do
    begin
      G := Goods[Kind, Slot];
      if G = 255 then Continue;
      if G = 10 then Factor := 1
      else if Slot < 2 then Factor := 1.0996
      else Factor := 1.099;
      Amount := Rates[Kind, Slot] * Factories[Kind];
      Amount := Amount * Factor * Days;
      if Slot < 2 then Inc(Balance[G, 0], Ceil(Amount))
      else Dec(Balance[G, 1], Ceil(Amount));
    end;
  for G := 0 to 19 do
  begin
    Balance[G,2] := -Int64(PopulationUse[G])*Days;
    Balance[G,3] := Int64(CityOutput[G])*Days;
    Balance[G,4] := -Int64(CityUse[G])*Days;
    Balance[G,5] := Balance[G,0]+Balance[G,3];
    Balance[G,6] := Balance[G,1]+Balance[G,2]+Balance[G,4];
    Balance[G,7] := Balance[G,5]+Balance[G,6];
    Balance[G,8] := Int64(OfficeOutput[G])*Days;
    Balance[G,9] := -Int64(OfficeUse[G])*Days;
    Balance[G,10] := Balance[G,8]+Balance[G,3];
    Balance[G,11] := Balance[G,9]+Balance[G,2]+Balance[G,4];
    Balance[G,12] := Balance[G,10]+Balance[G,11];
    Balance[G,13] := Balance[G,8]+Balance[G,9]+Balance[G,2];
  end;
end;

end.
