unit MedGameEvents;

interface

uses Windows, SysUtils, MedLoanRules;

type
  TMedEventRecord = packed record
    Time: Cardinal;
    NextIndex, Kind: Word;
    Data: array[0..15] of Byte;
  end;
  TMedEvent = record
    Pool: Cardinal;
    Index: Word;
    Value: TMedEventRecord;
  end;
  TMedEvents = array of TMedEvent;
  TMedCityEventKind = (ceFire, ceDisease, ceFrozen, cePoorHarvest, ceGoodHarvest, ceSiege);
  TMedCityEvent = record
    Event: TMedEvent;
    City: Byte;
    Kind: TMedCityEventKind;
    Pending: Boolean;
    Uncertain: Boolean;
    StartTime, EndTime: Cardinal;
    EndKnown: Boolean;
  end;
  TMedCityEvents = array of TMedCityEvent;

function MedRead(Address: Cardinal; var Value; Size: Cardinal): Boolean;
function MedGameReady: Boolean;
function MedNow: Cardinal;
function MedPlayer: Byte;
function MedScanEvents(out Items: TMedEvents): Boolean;
function MedScanCityEvents(out Items: TMedCityEvents): Boolean;
function MedEventLive(const Item: TMedEvent; out Address: Cardinal): Boolean;
function MedSetLoanBranch(const Item: TMedEvent; Cash: Boolean; out Error: string): Boolean;
function MedGrantLoan(City, Slot, Tier: Integer; const Expected: TMedLoanDemand;
  out Error: string): Boolean;
function MedDeleteCityEvent(const Item: TMedCityEvent; out Error: string): Boolean;
function MedClearFireGroup(const Selected: TMedCityEvent;
  const Expected: TMedCityEvents; out Error: string): Boolean;
function MedCityEventName(Kind: TMedCityEventKind): string;
function MedRemaining(Time, Now: Cardinal): string;

implementation

uses MedHookLifetime, MedFireRules;

type
  TManager = packed record
    Pool, Busy: Cardinal;
    Head, FreeHead, Capacity, Padding: Word;
  end;

function MedRead(Address: Cardinal; var Value; Size: Cardinal): Boolean;
var N: NativeUInt;
begin
  N:=0;
  Result:=(Address<>0) and ReadProcessMemory(GetCurrentProcess,Pointer(Address),
    @Value,Size,N) and (N=Size);
end;

function U32(Address: Cardinal): Cardinal;
begin
  Result:=0;
  MedRead(Address,Result,4);
end;

function MedNow: Cardinal;
begin Result:=U32($71CDBC); end;

function MedPlayer: Byte;
begin Result:=Byte(U32($70C77C)); end;

function MedGameReady: Boolean;
var PID: DWORD; Code: array[0..3] of Byte;
begin
  PID:=0;
  Result:=(GetModuleHandle(nil)=HMODULE($400000)) and
    (MedParentWindow<>0) and
    (GetWindowThreadProcessId(MedParentWindow,@PID)=GetCurrentThreadId) and
    (PID=GetCurrentProcessId) and (U32($71CDB8)>0) and
    (U32($71CDB8)<=40) and (U32($71CE10)<>0) and (MedNow<>0) and
    (U32($70C77C)<255);
  if Result then
    Result:=MedRead($409F20,Code,4) and (Code[0]=$56) and
      (Code[1]=$8B) and (Code[2]=$F1) and (Code[3]=$8B);
end;

function MedScanEvents(out Items: TMedEvents): Boolean;
var M: TManager; Seen: array of Boolean; Index: Word; E: TMedEvent; N: Integer;
begin
  Items:=nil; Result:=False;
  if not MedGameReady or not MedRead($6DD480,M,SizeOf(M)) or
    (M.Pool=0) or (M.Capacity=0) then Exit;
  SetLength(Seen,M.Capacity);
  Index:=M.Head;
  while Index<>$FFFF do
  begin
    if (Index>=M.Capacity) or Seen[Index] then begin Items:=nil; Exit; end;
    Seen[Index]:=True; E.Pool:=M.Pool; E.Index:=Index;
    if not MedRead(M.Pool+Cardinal(Index)*24,E.Value,24) then begin Items:=nil; Exit; end;
    N:=Length(Items); SetLength(Items,N+1); Items[N]:=E;
    Index:=E.Value.NextIndex;
  end;
  Result:=True;
end;

function MedEventLive(const Item: TMedEvent; out Address: Cardinal): Boolean;
var All: TMedEvents; I: Integer;
begin
  Address:=0; Result:=False;
  if not MedScanEvents(All) then Exit;
  for I:=0 to High(All) do
    if (All[I].Pool=Item.Pool) and (All[I].Index=Item.Index) and
      (All[I].Value.Kind=Item.Value.Kind) and (All[I].Value.Time=Item.Value.Time) and
      CompareMem(@All[I].Value.Data,@Item.Value.Data,16) then
    begin Address:=Item.Pool+Cardinal(Item.Index)*24; Exit(True); end;
end;

procedure NativeQuote(var Q: TMedLoanQuote);
asm
  PUSH EAX
  MOV EDX,$5DF4B0
  CALL EDX
  ADD ESP,4
end;

procedure NativeLoan(Command: Pointer);
asm
  MOV ECX,EAX
  MOV EAX,$409F20
  CALL EAX
end;

function NativeRandom: Cardinal;
asm
  MOV EAX,$63939F
  CALL EAX
end;

function MedGrantLoan(City, Slot, Tier: Integer; const Expected: TMedLoanDemand;
  out Error: string): Boolean;
var Address: Cardinal; Current: TMedLoanDemand; Q: TMedLoanQuote;
    Command: array[0..4] of Cardinal; P: Byte; MoneyBefore, MoneyAfter: Integer;
    Players: Cardinal;
begin
  Result:=False; Error:='';
  if not MedGameReady or (City<0) or (Cardinal(City)>=U32($71CDB8)) or
    not (Slot in [0..2]) or not (Tier in [0..4]) then
  begin Error:='游戏尚未就绪或版本不匹配'; Exit; end;
  Address:=U32($71CE10)+Cardinal(City)*$9F8+$9D8+Cardinal(Slot)*6;
  if not MedRead(Address,Current,6) or not CompareMem(@Current,@Expected,6) or
    (Current.Principal=0) or (Current.Weeks=0) or (Current.Rank>7) then
  begin Error:='贷款需求已变化，请刷新'; Exit; end;
  P:=MedPlayer; Players:=U32($71CE20);
  if not MedRead(Players+Cardinal(P)*$650,MoneyBefore,4) or
    (MoneyBefore<Current.Principal) then begin Error:='金币不足'; Exit; end;
  FillChar(Q,SizeOf(Q),0);
  Q.Rank:=Current.Rank; Q.Surname:=Current.Surname; Q.GivenName:=Current.GivenName;
  Q.Principal:=Current.Principal; Q.Weeks:=Current.Weeks;
  Q.Lender:=P; Q.Borrower:=$FF; Q.City:=City;
  Q.Options:=Byte(((Slot+3) shl 4) or Tier);
  // Commit exactly once. Native quote chooses the original repayment branch.
  NativeQuote(Q);
  Command[0]:=$29; Move(Q,Command[1],16);
  NativeLoan(@Command);
  MedRead(Players+Cardinal(P)*$650,MoneyAfter,4);
  MedRead(Address,Current,6);
  Result:=(Current.Principal=0) and (MoneyAfter=MoneyBefore-Expected.Principal);
  if not Result then Error:='原生放贷结果不符，已停止后续放款，请检查游戏';
end;

function MedSetLoanBranch(const Item: TMedEvent; Cash: Boolean; out Error: string): Boolean;
var Address: Cardinal; Branch: Byte;
begin
  Result:=False; Error:='';
  if not MedEventLive(Item,Address) or (Item.Value.Kind<>1) or
    (Item.Value.Data[8]<>MedPlayer) or (Item.Value.Data[9]<>$FF) or
    (Item.Value.Data[10]=0) or (Item.Value.Time<=MedNow) then
  begin Error:='只能切换本人尚未到期、尚未进入处置期的贷款，请刷新'; Exit; end;
  Branch:=Item.Value.Data[4];
  if Cash then Branch:=0
  else if Branch=0 then Branch:=Byte((NativeRandom and $FF) mod 78+51);
  // Preserve the upper 24-bit loan date, maturity, rate and all other payload.
  PByte(Address+12)^:=Branch;
  Result:=True;
end;

function MedScanCityEvents(out Items: TMedCityEvents): Boolean;
var All: TMedEvents; I,N,Stage: Integer; E: TMedCityEvent; Flags,Now: Cardinal;
begin
  Items:=nil; Result:=MedScanEvents(All); if not Result then Exit;
  Now:=MedNow;
  for I:=0 to High(All) do
  begin
    E:=Default(TMedCityEvent); E.Event:=All[I]; Stage:=0;
    case All[I].Value.Kind of
      29: begin E.Kind:=ceFire; E.City:=All[I].Value.Data[10];
        E.StartTime:=PCardinal(@All[I].Value.Data[0])^; end;
      28: begin E.Kind:=ceDisease; E.City:=All[I].Value.Data[14];
        E.StartTime:=All[I].Value.Time;
        E.EndTime:=PCardinal(@All[I].Value.Data[4])^; E.EndKnown:=True; end;
      53: begin E.Kind:=ceFrozen;
        if PCardinal(@All[I].Value.Data[0])^>=U32($71CDB8) then Continue;
        E.City:=All[I].Value.Data[0]; E.EndTime:=All[I].Value.Time; E.EndKnown:=True; end;
      9: begin
        Stage:=PCardinal(@All[I].Value.Data[0])^;
        if (Stage<0) or (Stage>2) then Continue; // Follow-up letters are not an active effect.
        if PWord(@All[I].Value.Data[8])^>=U32($71CDB8) then Continue;
        E.City:=All[I].Value.Data[8];
        if All[I].Value.Data[12]=0 then E.Kind:=cePoorHarvest else E.Kind:=ceGoodHarvest;
        E.StartTime:=All[I].Value.Time;
        // Stage 2 points to effect end; earlier stages include season adjustments.
        E.EndKnown:=Stage=2; E.EndTime:=All[I].Value.Time;
      end;
    else Continue;
    end;
    if E.City>=U32($71CDB8) then Continue;
    Flags:=U32(U32($71CE10)+Cardinal(E.City)*$9F8+$2C8);
    case E.Kind of
      ceFire:begin
        Stage:=MedFirePhase(E.StartTime,All[I].Value.Time,Now,PWord(@All[I].Value.Data[4])^);
        E.Pending:=Stage<>1; E.Uncertain:=Stage=2;
      end;
      ceDisease:E.Pending:=Flags and 8=0;
      ceFrozen:begin
        if Flags and $4000000=0 then Continue;
        E.Pending:=False;
      end;
      cePoorHarvest,ceGoodHarvest:E.Pending:=Stage=0;
    end;
    N:=Length(Items); SetLength(Items,N+1); Items[N]:=E;
  end;
end;

function MedCityEventName(Kind: TMedCityEventKind): string;
const Names: array[TMedCityEventKind] of string =
   ('火灾','瘟疫','港口冻结','歉收天气','丰收天气','围城');
begin Result:=Names[Kind]; end;

function MedRemaining(Time, Now: Cardinal): string;
var Delta: Cardinal;
begin
  if Time<=Now then Exit('待处理');
  Delta:=Time-Now;
  if Delta<256 then Result:='不足1天'
  else Result:=UIntToStr((Delta+255) div 256)+'天';
end;

function NativeManagerCall(Manager: Pointer; Entry: Cardinal): Cardinal;
asm
  MOV ECX,EAX
  CALL EDX
end;

procedure NativeWeatherEnd(Event: Pointer);
asm
  PUSH EAX
  MOV ECX,$6DD480
  MOV EDX,$469FB4
  CALL EDX
end;

function MedClearFireGroup(const Selected: TMedCityEvent;
  const Expected: TMedCityEvents; out Error: string): Boolean;
var Current: TMedCityEvents; All,After: TMedEvents; M: TManager;
    Targets,Active,FreeSeen,Burning,BuildingFree: array of Boolean;
    I,J,Count,ExpectedCount,Removed: Integer; Found: Boolean;
    CityAddress,Buildings,Address,Anchor,OldTime,NativeResult: Cardinal;
    Index,Cap,Next: Word; R: ^TMedEventRecord; Link: PWord;
    RecordBytes: array[0..7] of Byte;
begin
  Result:=False; Error:='';
  if (Selected.Kind<>ceFire) or Selected.Pending or Selected.Uncertain or
    not MedEventLive(Selected.Event,Address) or not MedScanCityEvents(Current) or
    not MedScanEvents(All) or not MedRead($6DD480,M,SizeOf(M)) or (M.Busy<>0) then
  begin Error:='火势或游戏状态已变化，请刷新后再操作'; Exit; end;
  SetLength(Targets,M.Capacity); SetLength(Active,M.Capacity);
  SetLength(FreeSeen,M.Capacity); Count:=0; ExpectedCount:=0;
  for I:=0 to High(All) do Active[All[I].Index]:=True;
  for I:=0 to High(Current) do
    if (Current[I].Kind=ceFire) and (Current[I].City=Selected.City) then
    begin
      if Current[I].Uncertain then
      begin Error:='同城有启动状态未确认的火灾，请推进少量游戏时间后刷新'; Exit; end;
      if Current[I].Pending then Continue;
      Found:=False;
      for J:=0 to High(Expected) do
        if (Expected[J].Kind=ceFire) and not Expected[J].Pending and
          (Expected[J].City=Selected.City) and
          (Expected[J].Event.Pool=Current[I].Event.Pool) and
          (Expected[J].Event.Index=Current[I].Event.Index) and
          (Expected[J].Event.Value.Time=Current[I].Event.Value.Time) and
          CompareMem(@Expected[J].Event.Value.Data,@Current[I].Event.Value.Data,16) then
          Found:=True;
      if not Found then
      begin Error:='当前火势组已变化，请刷新后重新选择'; Exit; end;
      Targets[Current[I].Event.Index]:=True; Inc(Count);
    end;
  for I:=0 to High(Expected) do
    if (Expected[I].Kind=ceFire) and not Expected[I].Pending and
      (Expected[I].City=Selected.City) then Inc(ExpectedCount);
  if (Count=0) or (Count<>ExpectedCount) then
  begin Error:='当前火势组数量已变化，请刷新'; Exit; end;
  Index:=M.FreeHead;
  while (Index<>$FFFF) and (Index<>M.Capacity) do
  begin
    if (Index>=M.Capacity) or Active[Index] or FreeSeen[Index] then
    begin Error:='事件空闲链异常，未执行清除'; Exit; end;
    FreeSeen[Index]:=True;
    if not MedRead(M.Pool+Cardinal(Index)*24+4,Next,2) then
    begin Error:='读取事件空闲链失败，未执行清除'; Exit; end;
    Index:=Next;
  end;
  CityAddress:=U32($71CE10)+Cardinal(Selected.City)*$9F8;
  if not MedRead(CityAddress+$75C,Buildings,4) or
    not MedRead(CityAddress+$776,Cap,2) then
  begin Error:='读取建筑池失败，未执行清除'; Exit; end;
  SetLength(Burning,Cap); SetLength(BuildingFree,Cap);
  if not MedRead(CityAddress+$760,Index,2) then
  begin Error:='读取建筑空闲链头失败，未执行清除'; Exit; end;
  while Index<>Cap do
  begin
    if (Index>=Cap) or BuildingFree[Index] then
    begin Error:='建筑空闲链异常，未执行清除'; Exit; end;
    BuildingFree[Index]:=True;
    if not MedRead(Buildings+Cardinal(Index)*8+4,Next,2) then
    begin Error:='读取建筑空闲节点失败，未执行清除'; Exit; end;
    Index:=Next;
  end;
  if not MedRead(CityAddress+$76A,Index,2) then
  begin Error:='读取燃烧链头失败，未执行清除'; Exit; end;
  while Index<>$FFFF do
  begin
    if (Index>=Cap) or Burning[Index] or BuildingFree[Index] then
    begin Error:='燃烧建筑链异常，未执行清除'; Exit; end;
    if not MedRead(Buildings+Cardinal(Index)*8,RecordBytes,8) then
    begin Error:='读取燃烧建筑失败，未执行清除'; Exit; end;
    if RecordBytes[3] in [$32,$33] then
    begin Error:='存在原生结束流程跳过的燃烧节点，未执行清除'; Exit; end;
    Burning[Index]:=True; Index:=PWord(@RecordBytes[4])^;
  end;
  // No message pumping from first write until verification. Stop every spread
  // record first, then finish the shared burning chain exactly once.
  Anchor:=Selected.Event.Index; R:=Pointer(M.Pool+Anchor*24); OldTime:=R.Time;
  for I:=0 to High(Targets) do if Targets[I] then
  begin
    R:=Pointer(M.Pool+Cardinal(I)*24);
    PWord(@R.Data[6])^:=PWord(@R.Data[4])^;
  end;
  for I:=0 to High(Burning) do if Burning[I] then
    PByte(Buildings+Cardinal(I)*8+6)^:=0;
  M.Head:=Word(Anchor); NativeResult:=NativeManagerCall(@M,$470CF4);
  if (NativeResult<>0) or (PWord(CityAddress+$76A)^<>$FFFF) or
    (PCardinal(CityAddress+$2C8)^ and $8000<>0) then
  begin
    R:=Pointer(M.Pool+Anchor*24); R.Time:=OldTime;
    Error:='已停止本组传播，但原生收尾未完成；请刷新查看，不要重复批量清除'; Exit;
  end;
  // Handler does not recycle event records. Edit the REAL head/freehead only;
  // the pointer-to-link remains in place when adjacent target nodes are removed.
  Link:=Pointer($6DD488); Removed:=0;
  for I:=0 to High(All) do
  begin
    Index:=Link^;
    if Index=$FFFF then Break;
    R:=Pointer(M.Pool+Cardinal(Index)*24); Next:=R.NextIndex;
    if Targets[Index] then
    begin
      Link^:=Next; R.NextIndex:=PWord($6DD48A)^; R.Kind:=$FFFF;
      PWord($6DD48A)^:=Index; Inc(Removed);
    end
    else Link:=@R.NextIndex;
  end;
  if (Removed<>Count) or not MedScanEvents(After) then
  begin Error:='火势已结束，但事件回收校验失败，请停止操作并保留日志'; Exit; end;
  for I:=0 to High(After) do if Targets[After[I].Index] then
  begin Error:='火势记录仍在活动链，请停止操作'; Exit; end;
  for I:=0 to High(All) do if not Targets[All[I].Index] then
  begin
    Found:=False;
    for J:=0 to High(After) do
      if (After[J].Index=All[I].Index) and
        (After[J].Value.Kind=All[I].Value.Kind) and
        (After[J].Value.Time=All[I].Value.Time) and
        CompareMem(@After[J].Value.Data,@All[I].Value.Data,16) then Found:=True;
    if not Found then
    begin Error:='非目标事件校验失败，请停止操作'; Exit; end;
  end;
  FillChar(FreeSeen[0],Length(FreeSeen)*SizeOf(Boolean),0);
  FillChar(Active[0],Length(Active)*SizeOf(Boolean),0);
  for I:=0 to High(After) do Active[After[I].Index]:=True;
  Index:=PWord($6DD48A)^;
  while (Index<>$FFFF) and (Index<>M.Capacity) do
  begin
    if (Index>=M.Capacity) or FreeSeen[Index] or Active[Index] then
    begin Error:='清除后的事件空闲链异常，请停止操作'; Exit; end;
    FreeSeen[Index]:=True; R:=Pointer(M.Pool+Cardinal(Index)*24);
    Index:=R.NextIndex;
  end;
  for I:=0 to High(Targets) do if Targets[I] then
    if not FreeSeen[I] or (PWord(M.Pool+Cardinal(I)*24+6)^<>$FFFF) then
    begin Error:='火灾记录未完整回收，请停止操作'; Exit; end;
  if Cap>0 then FillChar(BuildingFree[0],Length(BuildingFree)*SizeOf(Boolean),0);
  Index:=PWord(CityAddress+$760)^;
  while Index<>Cap do
  begin
    if (Index>=Cap) or BuildingFree[Index] then
    begin Error:='清除后建筑空闲链校验失败，请停止操作'; Exit; end;
    BuildingFree[Index]:=True;
    Index:=PWord(Buildings+Cardinal(Index)*8+4)^;
  end;
  for I:=0 to High(Burning) do if Burning[I] and not BuildingFree[I] then
  begin Error:='燃烧建筑未完整回收，请停止操作'; Exit; end;
  Result:=True;
end;

function MedDeleteCityEvent(const Item: TMedCityEvent; out Error: string): Boolean;
var Address,CityAddress,Buildings: Cardinal; M: TManager;
    All: TMedEvents; I: Integer; Prev,Index,Next,Cap: Word;
    R: ^TMedEventRecord; Link: PWord; Seen: array of Boolean;
begin
  Result:=False; Error:='';
  if Item.Kind=ceSiege then
  begin Error:='战争事件仅提供详情，不支持强制清除'; Exit; end;
  if Item.Uncertain then
  begin Error:='事件处于启动或收尾边界，请推进少量游戏时间后刷新'; Exit; end;
  if not MedEventLive(Item.Event,Address) then
  begin Error:='事件已变化，请刷新后再操作'; Exit; end;
  if not MedScanEvents(All) then Exit;
  // Fire/disease city flags and fire building chains are shared by simultaneous instances.
  if not Item.Pending then
    for I:=0 to High(All) do
      if (All[I].Index<>Item.Event.Index) and (All[I].Value.Kind=Item.Event.Value.Kind) and
        (((Item.Kind=ceFire) and (All[I].Value.Data[10]=Item.City)) or
         ((Item.Kind=ceDisease) and (All[I].Value.Data[14]=Item.City)) or
         ((Item.Kind=ceFrozen) and (All[I].Value.Data[0]=Item.City))) then
      begin Error:='此城同类事件存在多个实例，请先取消其他未发生实例后再清除当前状态'; Exit; end;
  MedRead($6DD480,M,SizeOf(M)); M.Head:=Item.Event.Index;
  CityAddress:=U32($71CE10)+Cardinal(Item.City)*$9F8;
  R:=Pointer(Address);
  if not Item.Pending then
    case Item.Kind of
      ceFire: begin
        // Stop further spread. Finish currently burning buildings using the game
        // handler, not by clearing its state bit or refunding existing damage.
        Buildings:=U32(CityAddress+$75C); Cap:=PWord(CityAddress+$776)^;
        SetLength(Seen,Cap); Index:=PWord(CityAddress+$76A)^;
        while Index<>$FFFF do
        begin
          if (Index>=Cap) or Seen[Index] then begin Error:='燃烧建筑链异常，未执行清除'; Exit; end;
          Seen[Index]:=True; Index:=PWord(Buildings+Cardinal(Index)*8+4)^;
        end;
        for I:=0 to High(Seen) do
          if Seen[I] then PByte(Buildings+Cardinal(I)*8+6)^:=0;
        PWord(@R.Data[6])^:=PWord(@R.Data[4])^;
        NativeManagerCall(@M,$470CF4);
        if (PCardinal(CityAddress+$2C8)^ and $8000<>0) then
        begin Error:='原生灭火流程仍在处理中，请刷新'; Exit; end;
      end;
      ceDisease: begin
        // 00470C10 is the native terminal branch: clear disease state, then
        // dispatcher releases the event. Do not run another mortality tick.
        PCardinal(CityAddress+$2C8)^:=PCardinal(CityAddress+$2C8)^ and not Cardinal(8);
      end;
      ceFrozen:NativeManagerCall(@M,$470C34);
      cePoorHarvest,ceGoodHarvest:begin
        PCardinal(@R.Data[0])^:=5; PWord(@R.Data[10])^:=0;
        NativeWeatherEnd(R);
      end;
    end;
  // Unlink exactly this known simple event, returning it to the native free pool.
  // Same-thread modal UI prevents simulation ticks while this link is changed.
  Link:=Pointer($6DD488); Prev:=$FFFF;
  for I:=0 to High(All) do
  begin
    if All[I].Index=Item.Event.Index then Break;
    Prev:=All[I].Index;
  end;
  if Prev<>$FFFF then Link:=Pointer(M.Pool+Cardinal(Prev)*24+4);
  if Link^<>Item.Event.Index then begin Error:='事件链已变化，未移除'; Exit; end;
  Next:=R.NextIndex; Link^:=Next;
  R.Kind:=$FFFF; R.NextIndex:=PWord($6DD48A)^;
  PWord($6DD48A)^:=Item.Event.Index;
  Result:=True;
end;

end.
