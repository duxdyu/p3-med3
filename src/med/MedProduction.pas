unit MedProduction;

interface

uses Windows, P3ProductionRules;

const
  ColumnGoods: array[0..19] of Byte =
    (8,0,5,10,15,17,11,3,13,7,1,16,9,18,12,6,4,14,2,19);
  ProductionColumn: array[0..16] of Byte =
    (12,18,7,14,2,1,10,6,0,16,11,17,9,13,19,4,5);
  ColumnProduction: array[0..19] of Byte =
    (8,5,4,17,15,16,7,2,6,12,6,10,0,13,3,255,9,11,1,14);

type
  TProductionValues = array[0..19] of Byte;

function ProductionLevel(Rate: Word; Whale: Boolean): Byte;
function ProductionOffset(Column: Integer): Integer;
function TryReadProduction(Process: THandle; City: NativeUInt;
  var Values: TProductionValues): Boolean;
function TryEditProduction(Process: THandle; City: NativeUInt; Column: Integer;
  var Values: TProductionValues): Boolean;
function TryReadNativeProductionTables(Process: THandle;
  var Tables: TProductionTables): Boolean;
function TryEditProductionWithTables(Process: THandle; City: NativeUInt;
  Column: Integer; const Tables: TProductionTables;
  var Values: TProductionValues): Boolean;
{$IFDEF MED_PRODUCTION_TESTS}
procedure SetProductionTestTables(const Tables: TProductionTables);
{$ENDIF}

implementation

uses TlHelp32;

type
  TProductionRates = array[0..17] of Cardinal;
  TLocalRecord = packed record
    Coefficient: Cardinal;
    Scale: Word;
    ProductionType, CityId: Byte;
    Rate, Reserve: Word;
    Adjustment: Single;
  end;
  TWritePart = record
    Address: NativeUInt;
    Count: NativeUInt;
    BeforeValue, AfterValue: Cardinal;
  end;

{$IFDEF MED_PRODUCTION_TESTS}
var
  TestTables: TProductionTables;
  TestTablesSet: Boolean;

procedure SetProductionTestTables(const Tables: TProductionTables);
begin
  TestTables:=Tables;
  TestTablesSet:=True;
end;
{$ENDIF}

function ProductionLevel(Rate: Word; Whale: Boolean): Byte;
begin
  Result:=ClassifyProduction(Rate,Whale);
end;

function ProductionOffset(Column: Integer): Integer;
begin
  Result:=-1;
  if (Column<0) or (Column>19) then Exit;
  if ColumnProduction[Column]=$FF then Exit;
  if Column=3 then Result:=$2CC
  else Result:=$888+ColumnProduction[Column]*16;
end;

function ReadExact(Process: THandle; Address: NativeUInt; Buffer: Pointer;
  Count: NativeUInt): Boolean;
var
  Transferred: NativeUInt;
begin
  Transferred:=0;
  Result:=ReadProcessMemory(Process,Pointer(Address),Buffer,Count,Transferred);
  Result:=Result and (Transferred=Count);
end;

function WriteExact(Process: THandle; Address: NativeUInt; Buffer: Pointer;
  Count: NativeUInt): Boolean;
var
  Transferred: NativeUInt;
begin
  Transferred:=0;
  Result:=WriteProcessMemory(Process,Pointer(Address),Buffer,Count,Transferred);
  Result:=Result and (Transferred=Count);
end;

function ValidTables(const Tables: TProductionTables): Boolean;
var I: Integer;
begin
  Result:=False;
  for I:=0 to 20 do
    if (Tables.Coefficient[I]<>ExpectedProductionFactors[I]) or
       (Tables.Capacity[I]<>ExpectedProductionCaps[I]) then Exit;
  Result:=True;
end;

function TryReadNativeProductionTables(Process: THandle;
  var Tables: TProductionTables): Boolean;
var
  Snapshot: THandle;
  ModuleEntry: TModuleEntry32;
  Base: NativeUInt;
  DosHeader: TImageDosHeader;
  NtHeader: TImageNtHeaders32;
  Candidate: TProductionTables;
  Pid: DWORD;
begin
  Result:=False;
  Pid:=GetProcessId(Process);
  if Pid=0 then Exit;
  Snapshot:=CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,Pid);
  if Snapshot=INVALID_HANDLE_VALUE then Exit;
  try
    FillChar(ModuleEntry,SizeOf(ModuleEntry),0);
    ModuleEntry.dwSize:=SizeOf(ModuleEntry);
    if not Module32First(Snapshot,ModuleEntry) then Exit;
    Base:=NativeUInt(ModuleEntry.modBaseAddr);
    if Base<>$400000 then Exit;
    if ModuleEntry.modBaseSize<$292032 then Exit;
    if not ReadExact(Process,Base,@DosHeader,SizeOf(DosHeader)) then Exit;
    if (DosHeader.e_magic<>IMAGE_DOS_SIGNATURE) or (DosHeader._lfanew<64) or
      (DosHeader._lfanew>$100000) then Exit;
    if not ReadExact(Process,Base+NativeUInt(DosHeader._lfanew),
      @NtHeader,SizeOf(NtHeader)) then Exit;
    if (NtHeader.Signature<>IMAGE_NT_SIGNATURE) or
      (NtHeader.FileHeader.Machine<>IMAGE_FILE_MACHINE_I386) or
      (NtHeader.OptionalHeader.Magic<>$10B) or
      (NtHeader.OptionalHeader.ImageBase<>Base) or
      (NtHeader.OptionalHeader.SizeOfImage< $292032) then Exit;
    if not ReadExact(Process,Base+$292008,@Candidate.Coefficient,
      SizeOf(Candidate.Coefficient)) then Exit;
    if not ReadExact(Process,Base+$28BAA0,@Candidate.Capacity,
      SizeOf(Candidate.Capacity)) then Exit;
    if not ValidTables(Candidate) then Exit;
    Tables:=Candidate;
    Result:=True;
  finally
    CloseHandle(Snapshot);
  end;
end;

function ReadRates(Process: THandle; City: NativeUInt;
  var Rates: TProductionRates; var Kind: Byte): Boolean;
var
  I: Integer;
begin
  Result:=False;
  if City=0 then Exit;
  FillChar(Rates,SizeOf(Rates),0);
  for I:=0 to 16 do
    if not ReadExact(Process,City+$888+NativeUInt(I)*16,@Rates[I],SizeOf(Word)) then Exit;
  if not ReadExact(Process,City+$2CC,@Rates[17],SizeOf(Cardinal)) then Exit;
  if not ReadExact(Process,City+$2CB,@Kind,SizeOf(Kind)) then Exit;
  Result:=True;
end;

procedure DisplayValues(const Rates: TProductionRates; Kind: Byte;
  var Values: TProductionValues);
var
  I: Integer;
begin
  for I:=0 to 19 do
    if ColumnProduction[I]=$FF then Values[I]:=0
    else Values[I]:=ClassifyProduction(Rates[ColumnProduction[I]],I=3);
  // Preserve MED's regional compatibility display. This artificial spice marker
  // for city kinds 8/9 is not a native Hanseatic ordinary production specialty.
  if (Kind=8) or (Kind=9) then Values[15]:=4;
end;

function TryReadProduction(Process: THandle; City: NativeUInt;
  var Values: TProductionValues): Boolean;
var
  Rates: TProductionRates;
  Kind: Byte;
begin
  Result:=ReadRates(Process,City,Rates,Kind);
  if Result then DisplayValues(Rates,Kind,Values);
end;

function TryEditProduction(Process: THandle; City: NativeUInt; Column: Integer;
  var Values: TProductionValues): Boolean;
var Tables: TProductionTables;
begin
  Result:=False;
  if ProductionOffset(Column)<0 then Exit;
{$IFDEF MED_PRODUCTION_TESTS}
  if TestTablesSet then Tables:=TestTables
  else
{$ENDIF}
  if not TryReadNativeProductionTables(Process,Tables) then Exit;
  Result:=TryEditProductionWithTables(Process,City,Column,Tables,Values);
end;

function TryEditProductionWithTables(Process: THandle; City: NativeUInt;
  Column: Integer; const Tables: TProductionTables;
  var Values: TProductionValues): Boolean;
var
  Rates: TProductionRates;
  Kind: Byte;
  Slot,ProductionType,I,J,PartCount: Integer;
  Rate,NewScale: Word;
  Whale: Cardinal;
  RecordAddress: NativeUInt;
  Local: TLocalRecord;
  Parts: array[0..3] of TWritePart;

  procedure AddPart(Address: NativeUInt; Count: NativeUInt;
    BeforeValue,AfterValue: Cardinal);
  begin
    if BeforeValue=AfterValue then Exit;
    Parts[PartCount].Address:=Address;
    Parts[PartCount].Count:=Count;
    Parts[PartCount].BeforeValue:=BeforeValue;
    Parts[PartCount].AfterValue:=AfterValue;
    Inc(PartCount);
  end;
begin
  Result:=False;
  if ProductionOffset(Column)<0 then Exit;
  if not ValidTables(Tables) then Exit;
  if not ReadRates(Process,City,Rates,Kind) then Exit;
  Slot:=ColumnProduction[Column];
  ProductionType:=GoodsToProductionType(ColumnGoods[Column]);
  if ProductionType=ProductionWhaleType then ProductionType:=ProductionFishType;
  RecordAddress:=City+$840+NativeUInt(ProductionType)*16;
  if not ReadExact(Process,RecordAddress,@Local,SizeOf(Local)) then Exit;
  if Local.ProductionType<>ProductionType then Exit;
  Whale:=Rates[17];
  Rate:=Local.Rate;
  if (Column=3) or (Column=18) then
  begin
    EditFishWhale(Column=3,Rate,Whale);
    Slot:=1; // MED's ordinary fish slot (native type5).
  end
  else Rate:=EditProductionRate(Rate,False);
  NewScale:=NextLocalScale(Local.Scale,Rate,
    LocalProductionCapacity(Tables,ProductionType,Whale));
  PartCount:=0;
  AddPart(RecordAddress,4,Local.Coefficient,
    ComputeLocalCoefficient(Rate,Tables.Coefficient[ProductionType]));
  AddPart(RecordAddress+4,2,Local.Scale,NewScale);
  AddPart(RecordAddress+8,2,Local.Rate,Rate);
  if (Column=3) or (Column=18) then AddPart(City+$2CC,4,Rates[17],Whale);
  for I:=0 to PartCount-1 do
    if not WriteExact(Process,Parts[I].Address,@Parts[I].AfterValue,Parts[I].Count) then
    begin
      // Restore even the failed part, since an API may report a partial write.
      // Never publish UI values after any failed write or rollback attempt.
      for J:=I downto 0 do
        WriteExact(Process,Parts[J].Address,@Parts[J].BeforeValue,Parts[J].Count);
      Exit;
    end;
  Rates[Slot]:=Rate;
  Rates[17]:=Whale;
  DisplayValues(Rates,Kind,Values);
  Result:=True;
end;

end.
