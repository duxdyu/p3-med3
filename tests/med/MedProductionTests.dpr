program MedProductionTests;
{$SETPEOSVERSION 5.1}
{$SETPESUBSYSVERSION 5.1}

{$APPTYPE CONSOLE}
{$RANGECHECKS ON}
{$OVERFLOWCHECKS ON}

uses
  Winapi.UIAutomation in '..\..\src\sdk-overlay\Winapi.UIAutomation.pas',
  Windows, SysUtils, Forms, P3ProductionRules, MedProduction, UntWc, Untpublic;

const
  ExpectedOffsets: array[0..19] of Integer =
    ($908,$8D8,$8C8,$2CC,$978,$988,$8F8,$8A8,$8E8,$948,
     $8E8,$928,$888,$958,$8B8,-1,$918,$938,$898,$968);
  ExpectedGoods: array[0..19] of Byte =
    (8,0,5,10,15,17,11,3,13,7,1,16,9,18,12,6,4,14,2,19);
  ExpectedTypes: array[0..19] of ShortInt =
    (9,10,5,6,13,8,-1,16,12,4,-2,11,7,10,15,19,14,20,17,18);
  Inputs: array[0..20] of Word =
    (0,1,199,200,201,600,767,768,800,899,900,901,1000,1001,
     $400,$600,$800,$1000,$301,$4FF,$FFFF);
  OrdinaryLevels: array[0..20] of Byte =
    (0,0,0,0,3,3,3,3,3,3,0,4,4,4,4,4,4,4,3,4,4);
  WhaleLevels: array[0..20] of Byte =
    (0,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,3,4,4);
type
  // Includes a trailing private-record guard region, outside the city stride.
  TCityBytes = array[0..$1FFF] of Byte;
var
  City,Expected: TCityBytes;
  Values,BeforeValues: TProductionValues;
  Checks: Integer;
  Form: TFrmWc;
  Tables: TProductionTables;

procedure Check(Condition: Boolean; const Description: string);
begin
  Inc(Checks);
  if not Condition then raise Exception.Create(Description);
end;

procedure PutWord(var Data: TCityBytes; Offset: Integer; Rate: Word);
begin
  Move(Rate,Data[Offset],SizeOf(Rate));
end;

procedure PutDword(var Data: TCityBytes; Offset: Integer; Value: Cardinal);
begin
  Move(Value,Data[Offset],SizeOf(Value));
end;

function GetDword(const Data: TCityBytes; Offset: Integer): Cardinal;
begin
  Move(Data[Offset],Result,SizeOf(Result));
end;

function GetWord(const Data: TCityBytes; Offset: Integer): Word;
begin
  Move(Data[Offset],Result,SizeOf(Result));
end;

procedure ResetCity;
var I: Integer;
begin
  FillChar(City,SizeOf(City),$A5);
  City[$2CB]:=0;
  for I:=0 to 19 do
    if ExpectedOffsets[I]>=0 then PutWord(City,ExpectedOffsets[I],0);
  PutDword(City,$2CC,0);
  for I:=0 to 20 do
  begin
    PutDword(City,$840+I*16,0);
    PutWord(City,$844+I*16,0);
    City[$846+I*16]:=I;
    City[$847+I*16]:=7;
  end;
  FillChar(City[$9B4],4,0); // Empty auxiliary goods list for real form refresh.
end;

procedure TestMappingAndCycles;
var
  C,I,J,T,R: Integer;
  Rate,Other: Word;
  Level: Byte;
begin
  for C:=0 to 19 do
  begin
    Check(ColumnGoods[C]=ExpectedGoods[C],'goods map '+IntToStr(C));
    Check(ProductionOffset(C)=ExpectedOffsets[C],'WORD offset '+IntToStr(C));
    for I:=0 to High(Inputs) do
    begin
      ResetCity;
      if C=15 then Continue;
      PutWord(City,ExpectedOffsets[C],Inputs[I]);
      T:=ExpectedTypes[ExpectedGoods[C]];
      if T=-2 then T:=5;
      R:=$840+T*16;
      PutDword(City,R,$11223344); // Deliberately stale K must be recomputed.
      if Odd(I) then PutWord(City,R+4,123); // Existing scale must not be capped.
      Check(TryReadProduction(GetCurrentProcess,NativeUInt(@City),Values),'read full WORD');
      if C=3 then Level:=WhaleLevels[I] else Level:=OrdinaryLevels[I];
      Check(Values[C]=Level,'read category column/rate '+IntToStr(C)+'/'+IntToStr(Inputs[I]));
      Expected:=City;
      if C=3 then
      begin
        if Level=4 then begin Rate:=0; Other:=$400; end
        else begin Rate:=$400; Other:=$300; end;
        PutWord(Expected,$898,Other);
      end
      else
      begin
        case Level of 0: Rate:=$300; 3: Rate:=$400; else Rate:=0; end;
        if C=18 then
        begin
          if Rate=$300 then Other:=$400 else Other:=0;
            PutDword(Expected,$2CC,Other);
        end;
      end;
      if C=3 then PutDword(Expected,$2CC,Rate)
      else PutWord(Expected,ExpectedOffsets[C],Rate);
      PutDword(Expected,R,(Cardinal(Tables.Coefficient[T])*GetWord(Expected,R+8)) div 1024);
      if GetWord(Expected,R+8)=0 then PutWord(Expected,R+4,0)
      else if GetWord(City,R+4)=0 then
      begin
        if (T=5) and (GetDword(Expected,$2CC)>10) then J:=72
        else J:=Tables.Capacity[T];
        PutWord(Expected,R+4,J);
      end;
      Check(TryEditProduction(GetCurrentProcess,NativeUInt(@City),C,Values),'edit accepted');
      Check(CompareMem(@City,@Expected,SizeOf(City)),
        'only K/N/rate/whale change; identity/B/float/population/stock/private guards preserved '+IntToStr(C)+'/'+IntToStr(I));
      Check(Values[8]=Values[10],'meat/leather display shared');
      Check(GetWord(City,ExpectedOffsets[C])=Rate,'low byte cleared');
    end;
  end;
  for I:=0 to 16 do
    Check(ColumnProduction[ProductionColumn[I]]=I,'inverse slot mapping');
  for I:=0 to High(Inputs) do
  begin
    Check(MedProduction.ProductionLevel(Inputs[I],False)=OrdinaryLevels[I],'ordinary boundary');
    Check(MedProduction.ProductionLevel(Inputs[I],True)=WhaleLevels[I],'whale boundary');
  end;
  ResetCity;
  for J:=0 to 2 do
  begin
    Check(TryEditProduction(GetCurrentProcess,NativeUInt(@City),16,Values),'salt cycle accepted');
    case J of
      0: Rate:=$300;
      1: Rate:=$400;
    else Rate:=0;
    end;
    Check(GetWord(City,$918)=Rate,'salt no-low-high-no');
  end;
  Writeln('PASS: all 20 mappings; 19 editable columns x 21 input rates; K sync, scale lifecycle, whole-city/private guards; sharing/linkage; native boundaries; PI multipliers.');
end;

procedure TestInvalidAndRegion;
var C: Integer;
begin
  ResetCity;
  Expected:=City;
  FillChar(Values,SizeOf(Values),$5A);
  BeforeValues:=Values;
  for C:=-2 to 21 do
    if (C<0) or (C>19) or (C=15) then
    begin
      Check(not TryEditProduction(GetCurrentProcess,NativeUInt(@City),C,Values),'invalid/spice denied');
      Check(CompareMem(@Values,@BeforeValues,SizeOf(Values)),'failed edit output unchanged');
      Check(CompareMem(@City,@Expected,SizeOf(City)),'invalid edit memory unchanged');
    end;
  Check(not TryReadProduction(0,NativeUInt(@City),Values),'invalid handle read');
  Check(not TryEditProduction(0,NativeUInt(@City),16,Values),'invalid handle edit');
  Check(not TryReadProduction(GetCurrentProcess,0,Values),'null city');
  Check(not TryReadProduction(GetCurrentProcess,1,Values),'unmapped city');
  Check(CompareMem(@Values,@BeforeValues,SizeOf(Values)),'failed reads do not publish');
  for C:=0 to 255 do
  begin
    City[$2CB]:=C;
    Check(TryReadProduction(GetCurrentProcess,NativeUInt(@City),Values),'regional read');
    if (C=8) or (C=9) then Check(Values[15]=4,'regional artificial spice')
    else Check(Values[15]=0,'no ordinary spice slot');
  end;
  Writeln('PASS: invalid columns/handle/address, unchanged failure output, all 256 city kinds.');
end;

procedure FillGrid;
var I: Integer;
begin
  for I:=1 to 20 do Form.StrGid.Cells[I,1]:='unchanged';
end;

procedure CheckGridUnchanged;
var I: Integer;
begin
  for I:=1 to 20 do Check(Form.StrGid.Cells[I,1]='unchanged','API failure leaves UI unchanged');
end;

procedure TestRealFormAndFailures;
var
  ReadOnlyHandle: THandle;
  Pages: Pointer;
  Base: NativeUInt;
  OldProtect: DWORD;
  Fish: Word;
begin
  ResetCity;
  CityCunt:=1;
  CityDZ[0]:=Integer(@City);
  GHandle:=GetCurrentProcess;
  Form:=TFrmWc.Create(nil);
  try
    Form.StrGid.RowCount:=2;
    Form.StrGid.Col:=17;
    Form.StrGid.Row:=1;
    Form.StrGidDblClick(nil);
    Check(GetWord(City,$918)=$300,'real form salt writes');
    Check(Form.StrGid.Cells[17,1]='☆','real form salt low display');
    PutWord(City,$918,$1001);
    Form.Button1Click(nil);
    Check(Form.StrGid.Cells[17,1]='★★','real form PI high refresh');
    Form.StrGidDblClick(nil);
    Check(GetWord(City,$918)=0,'real form PI high normalizes');
    Check(Form.StrGid.Cells[17,1]='','real form PI high to none');
    FillGrid;
    GHandle:=0;
    Form.StrGidDblClick(nil);
    CheckGridUnchanged;
    Form.Button1Click(nil);
    CheckGridUnchanged;
    ReadOnlyHandle:=OpenProcess(PROCESS_VM_READ,False,GetCurrentProcessId);
    Check(ReadOnlyHandle<>0,'read-only process handle');
    try
      GHandle:=ReadOnlyHandle;
      Expected:=City;
      Form.StrGidDblClick(nil);
      CheckGridUnchanged;
      Check(CompareMem(@City,@Expected,SizeOf(City)),'write access denied leaves memory');
    finally CloseHandle(ReadOnlyHandle); end;

    // Fish resides in the second page; whale resides in the read-only first page.
    // The first write succeeds and the linked second write fails, exercising rollback.
    Pages:=VirtualAlloc(nil,16384,MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE);
    Check(Pages<>nil,'allocate linked-failure fixture');
    try
      Base:=NativeUInt(Pages)+4096-$888;
      ResetCity;
      PutDword(City,$2CC,1024);
      PutDword(City,$890,706);
      PutWord(City,$894,72);
      Move(City,Pointer(Base)^,SizeOf(City));
      Fish:=$301;
      Move(Fish,Pointer(Base+$898)^,2);
      Check(VirtualProtect(Pages,4096,PAGE_READONLY,OldProtect),'protect linked whale');
      GHandle:=GetCurrentProcess;
      CityDZ[0]:=Integer(Base);
      Form.StrGid.Col:=19;
      Form.StrGidDblClick(nil);
      CheckGridUnchanged;
      Check(PWord(Base+$898)^=$301,'linked failure restores full fish WORD');
      Check(PCardinal(Base+$2CC)^=1024,'failed linked whale DWORD unchanged');
      Check(PCardinal(Base+$890)^=706,'linked failure restores K');
      Check(PWord(Base+$894)^=72,'linked failure preserves scale');
    finally VirtualFree(Pages,0,MEM_RELEASE); end;
  finally Form.Free; end;
  Writeln('PASS: actual form salt/PI refresh and toggle; failed reads, denied primary write and failed linked write preserve UI; linked rollback.');
end;

procedure TestSharedContractAndLifecycle;
var
  I,J,T,R: Integer;
  Fish,NewFish: Word;
  Whale,NewWhale: Cardinal;
  BadTables,UnchangedTables: TProductionTables;
begin
  for I:=0 to 19 do
    Check(Goods0ToProductionType(I)=ExpectedTypes[I],'shared zero-based goods map');
  Check(Goods0ToProductionType(-1)=-1,'negative goods denied');
  Check(Goods0ToProductionType(20)=-1,'excess goods denied');
  for I:=0 to High(Inputs) do
  begin
    Check(P3ProductionRules.ProductionLevel(Inputs[I],False)=OrdinaryLevels[I],'shared ordinary boundaries');
    Check(P3ProductionRules.ProductionLevel(Inputs[I],True)=WhaleLevels[I],'shared whale boundaries');
    Fish:=Inputs[I]; Whale:=$FFFFFFFF;
    NormalizeFishWhale(Fish,Whale);
    Check(((Fish=0) and (Whale=0)) or ((Fish=768) and (Whale=1024)) or
      ((Fish=1024) and (Whale=0)),'normalization always three-state');
    for J:=0 to 1 do
    begin
      NextFishWhale(J=1,Inputs[I],Inputs[I],NewFish,NewWhale);
      Check(((NewFish=0) and (NewWhale=0)) or ((NewFish=768) and (NewWhale=1024)) or
        ((NewFish=1024) and (NewWhale=0)),'next always three-state');
    end;
  end;
  NextFishWhale(True,0,1024,NewFish,NewWhale);
  Check((NewFish=1024) and (NewWhale=0),'whale off always enables high fish');
  NextFishWhale(True,0,0,NewFish,NewWhale);
  Check((NewFish=768) and (NewWhale=1024),'whale on enables low fish');
  Check(ComputeLocalCoefficient(0,942)=0,'zero K');
  Check(ComputeLocalCoefficient(768,942)=706,'low fish K floor');
  Check(ComputeLocalCoefficient(1024,942)=942,'high fish K');
  Check(ComputeLocalCoefficient(65535,65535)=4194176,'unsigned product boundary');
  Check(NextLocalScale(123,1024,65)=123,'live scale left for native adjustment');
  Check(NextLocalScale(123,0,65)=0,'disable scale');
  Check(NextLocalScale(0,768,72)=72,'enable scale');
  for I:=0 to 19 do
  begin
    if I=15 then Continue;
    ResetCity;
    T:=ExpectedTypes[ExpectedGoods[I]];
    if T=-2 then T:=5;
    R:=$840+T*16;
    PutWord(City,R+8,1024);
    PutDword(City,R,123456);
    PutWord(City,R+4,99);
    if I=3 then PutDword(City,$2CC,1024);
    Check(TryEditProduction(GetCurrentProcess,NativeUInt(@City),I,Values),'lifecycle disable/toggle');
    if I=3 then
    begin
      Check((GetWord(City,R+8)=1024) and (GetDword(City,$2CC)=0),'whale off high fish');
      Check(GetWord(City,R+4)=99,'whale off does not clamp live scale');
      Continue;
    end;
    Check((GetWord(City,R+8)=0) and (GetDword(City,R)=0) and
      (GetWord(City,R+4)=0),'clear K N rate');
    Check(TryEditProduction(GetCurrentProcess,NativeUInt(@City),I,Values),'re-enable accepted');
    Check(GetWord(City,R+8)=768,'re-enable low');
    if T=5 then J:=72 else J:=Tables.Capacity[T];
    Check(GetWord(City,R+4)=J,'re-enable reads native capacity');
    Check(GetDword(City,R)=(Cardinal(Tables.Coefficient[T])*768) div 1024,'re-enable K');
  end;
  ResetCity;
  Expected:=City;
  FillChar(Values,SizeOf(Values),$5A); BeforeValues:=Values;
  for I:=0 to 20 do
  begin
    BadTables:=Tables;
    Inc(BadTables.Coefficient[I]);
    Check(not TryEditProductionWithTables(GetCurrentProcess,NativeUInt(@City),18,BadTables,Values),'mismatched coefficient rejected');
    BadTables:=Tables;
    Inc(BadTables.Capacity[I]);
    Check(not TryEditProductionWithTables(GetCurrentProcess,NativeUInt(@City),18,BadTables,Values),'mismatched capacity rejected');
  end;
  Check(CompareMem(@City,@Expected,SizeOf(City)),'bad tables never write');
  Check(CompareMem(@Values,@BeforeValues,SizeOf(Values)),'bad tables never publish');
  BadTables:=Tables; UnchangedTables:=BadTables;
  Check(not TryReadNativeProductionTables(GetCurrentProcess,BadTables),'test executable is not native game');
  Check(CompareMem(@BadTables,@UnchangedTables,SizeOf(BadTables)),'failed table read unchanged');
  City[$896]:=6;
  Check(not TryEditProductionWithTables(GetCurrentProcess,NativeUInt(@City),18,Tables,Values),'wrong local record type denied');
  ResetCity;
  PutDword(City,$2CC,$10000);
  Check(TryReadProduction(GetCurrentProcess,NativeUInt(@City),Values),'whale full DWORD read');
  Check(Values[3]=4,'whale high DWORD classified without truncation');
  Check(TryEditProduction(GetCurrentProcess,NativeUInt(@City),3,Values),'whale high DWORD toggle');
  Check(GetDword(City,$2CC)=0,'whale high DWORD fully cleared');
  Writeln('PASS: shared rules, exact table rejection, clear/re-enable all goods, DWORD whale, local identity guard.');
end;

begin
  try
    Application.Initialize;
    Move(ExpectedProductionFactors,Tables.Coefficient,SizeOf(Tables.Coefficient));
    Move(ExpectedProductionCaps,Tables.Capacity,SizeOf(Tables.Capacity));
    SetProductionTestTables(Tables);
    TestMappingAndCycles;
    TestInvalidAndRegion;
    TestRealFormAndFailures;
    TestSharedContractAndLifecycle;
    Writeln('PASS: ',Checks,' checks; no game process accessed.');
  except
    on E: Exception do
    begin Writeln('FAIL: ',E.ClassName,': ',E.Message); Halt(1); end;
  end;
end.
