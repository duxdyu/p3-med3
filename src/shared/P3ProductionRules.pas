unit P3ProductionRules;

// Pure data contract shared by PI and MED. Goods indexes are zero-based.
interface

const
  ProductionNone = 0;
  ProductionLow = 768;
  ProductionHigh = 1024;
  ProductionFishType = 5;
  ProductionWhaleType = -2; // DWORD city+$2CC, not an ordinary record
  ProductionUnsupportedType = -1; // spice
  GoodsProductionType: array[0..19] of ShortInt =
    (9,10,5,6,13,8,-1,16,12,4,-2,11,7,10,15,19,14,20,17,18);
  // Verification constants, not a substitute for reading the current EXE.
  ExpectedProductionFactors: array[0..20] of Word =
    (1024,1024,1024,1024,2048,942,1638,2048,1229,1331,1638,
     1229,1536,1024,1024,1229,4096,1024,1024,1024,1024);
  ExpectedProductionCaps: array[0..20] of Byte =
    (250,40,25,5,72,65,68,78,60,68,60,48,60,54,70,50,93,58,27,26,62);

type
  TProductionTables = record
    Coefficient: array[0..20] of Word;
    Capacity: array[0..20] of Byte;
  end;

function GoodsToProductionType(Goods0: Integer): Integer;
function Goods0ToProductionType(Goods0: Integer): Integer;
function ProductionLevel(Rate: Word; Whale: Boolean): Byte;
function ClassifyProduction(Rate: Cardinal; Whale: Boolean): Byte;
function NormalizeProductionRate(Rate: Cardinal; Whale: Boolean): Word;
function EditProductionRate(Rate: Cardinal; Whale: Boolean): Word;
procedure NormalizeFishWhale(var Fish: Word; var Whale: Cardinal);
procedure EditFishWhale(EditWhale: Boolean; var Fish: Word; var Whale: Cardinal);
procedure NextFishWhale(EditWhale: Boolean; OldFish: Word; OldWhale: Cardinal;
  out NewFish: Word; out NewWhale: Cardinal);
function ComputeLocalCoefficient(Rate, NativeFactor: Word): Cardinal;
function NextLocalScale(OldScale, Rate: Word; Cap: Byte): Word;
function LocalProductionCapacity(const Tables: TProductionTables;
  ProductionType: Integer; Whale: Cardinal): Word;

implementation

function Goods0ToProductionType(Goods0: Integer): Integer;
begin
  Result:=GoodsToProductionType(Goods0);
end;

function ProductionLevel(Rate: Word; Whale: Boolean): Byte;
begin
  Result:=ClassifyProduction(Rate,Whale);
end;

function GoodsToProductionType(Goods0: Integer): Integer;
begin
  Result:=ProductionUnsupportedType;
  if (Goods0>=0) and (Goods0<=19) then Result:=GoodsProductionType[Goods0];
end;

function ClassifyProduction(Rate: Cardinal; Whale: Boolean): Byte;
begin
  Result:=0;
  if Whale then
  begin
    if Rate>1000 then Result:=4 else if Rate>0 then Result:=3;
  end
  else
  begin
    if Rate>900 then Result:=4
    else if (Rate>200) and (Rate<900) then Result:=3;
  end;
end;

function NormalizeProductionRate(Rate: Cardinal; Whale: Boolean): Word;
begin
  Result:=0;
  if Whale then
  begin
    if Rate>0 then Result:=ProductionHigh;
  end
  else
    case ClassifyProduction(Rate,False) of
      3: Result:=ProductionLow;
      4: Result:=ProductionHigh;
    end;
end;

function EditProductionRate(Rate: Cardinal; Whale: Boolean): Word;
begin
  if Whale then
  begin
    if ClassifyProduction(Rate,True)=4 then Result:=0
    else Result:=ProductionHigh;
  end
  else
    case ClassifyProduction(Rate,False) of
      0: Result:=ProductionLow;
      3: Result:=ProductionHigh;
    else Result:=0;
    end;
end;

procedure NormalizeFishWhale(var Fish: Word; var Whale: Cardinal);
begin
  Fish:=NormalizeProductionRate(Fish,False);
  if Fish=ProductionLow then Whale:=ProductionHigh else Whale:=0;
end;

procedure EditFishWhale(EditWhale: Boolean; var Fish: Word; var Whale: Cardinal);
begin
  if EditWhale then
  begin
    Whale:=EditProductionRate(Whale,True);
    if Whale=0 then Fish:=ProductionHigh else Fish:=ProductionLow;
  end
  else
  begin
    Fish:=EditProductionRate(Fish,False);
    NormalizeFishWhale(Fish,Whale);
  end;
end;

procedure NextFishWhale(EditWhale: Boolean; OldFish: Word; OldWhale: Cardinal;
  out NewFish: Word; out NewWhale: Cardinal);
begin
  NewFish:=OldFish;
  NewWhale:=OldWhale;
  EditFishWhale(EditWhale,NewFish,NewWhale);
end;

function ComputeLocalCoefficient(Rate, NativeFactor: Word): Cardinal;
begin
  Result:=(Cardinal(NativeFactor)*Cardinal(Rate)) div 1024;
end;

function NextLocalScale(OldScale, Rate: Word; Cap: Byte): Word;
begin
  Result:=OldScale;
  if Rate=0 then Result:=0
  else if OldScale=0 then Result:=Cap;
end;

function LocalProductionCapacity(const Tables: TProductionTables;
  ProductionType: Integer; Whale: Cardinal): Word;
begin
  Result:=0;
  if (ProductionType<0) or (ProductionType>20) then Exit;
  Result:=Tables.Capacity[ProductionType];
  if (ProductionType=ProductionFishType) and (Whale>10) then Result:=72;
end;

end.
