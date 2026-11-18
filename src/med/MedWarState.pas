unit MedWarState;

interface

uses System.SysUtils;

type
  TMedWarView = record
    Caption, Detail: string;
    ShowIcon, Pending: Boolean;
  end;
  TMedWarViews = array of TMedWarView;

procedure MedScanWars(out Views: TMedWarViews);

implementation

uses MedGameEvents, MedWarModel, Untpublic;

type
  TWarCache = record
    War, StartDay, EndSeen: Cardinal;
    SeenActive: Boolean;
    Outcome: string;
  end;
  TWarMessage = record
    City: Byte;
    Signature: string;
    Day,Month: Byte;
    Year,Duration: Word;
    Victory: Boolean;
    Money: Cardinal;
    Buildings: Word;
  end;
  TWarMessages = array of TWarMessage;
var
  Cache: array[0..39] of TWarCache;
  LastBase,LastManager,LastNow: Cardinal;

function WarMessages(out Items: TWarMessages): Boolean;
var Pool: Cardinal; Cap,Index,Next: Word; Seen: array of Boolean;
    Data: array[0..15] of Byte; I,N: Integer; Msg: TWarMessage;
begin
  Result:=False; Items:=nil;
  if not MedRead($6DD2B0,Pool,4) or not MedRead($6DD2B6,Cap,2) or
    not MedRead($6DD2B8,Index,2) or (Pool=0) then Exit;
  SetLength(Seen,Cap);
  while Index<>$FFFF do
  begin
    if (Index>=Cap) or Seen[Index] then Exit;
    Seen[Index]:=True;
    if not MedRead(Pool+Cardinal(Index)*16,Data,16) then Exit;
    Next:=PWord(@Data[6])^;
    if Data[4]=$38 then
    begin
      Msg:=Default(TWarMessage); Msg.City:=Data[5];
      Msg.Day:=Data[0]; Msg.Month:=Data[1];
      Msg.Year:=PWord(@Data[2])^; Msg.Duration:=PWord(@Data[8])^;
      // Calendar date/type/target/result bytes, not link position or recycled slot.
      for I:=0 to 15 do if not (I in [6,7]) then
        Msg.Signature:=Msg.Signature+IntToHex(Data[I],2);
      Msg.Money:=PCardinal(@Data[10])^; Msg.Buildings:=PWord(@Data[14])^;
      Msg.Victory:=Msg.Money=$FFFFFFFF;
      N:=Length(Items); SetLength(Items,N+1); Items[N]:=Msg;
    end;
    Index:=Next;
  end;
  Result:=True;
end;

function Read32(Address: Cardinal; out Value: Cardinal): Boolean;
begin
  Result:=MedRead(Address,Value,4);
end;

procedure MedScanWars(out Views: TMedWarViews);
var Count,Base,Manager,Now,CityFlags,War,StartDay,Ticks,Settings,Rate,Days,LastWar,Gate: Cardinal; I,J: Integer;
    Raw: array[0..$64F] of Byte; Active,Valid,MessagesOK,Conflict: Boolean;
    Stage: TMedWarStage; Attack,Phase,NextPhase,Matched,Outcome: string;
    Approach,Loot,Retreat,Duration,Counter: Word; Messages: TWarMessages;
    Population: Integer; Special,Difficulty,Suspended: Byte;
    Node,Top,Root: Cardinal;
begin
  Views:=nil;
  Node:=0; Top:=0; Root:=0;
  if Read32($6E202C,Node) and (Node<>0) then Read32(Node+8,Top);
  if Top<>0 then Read32(Top,Root);
  if not MedGameReady or not Read32($71CDB8,Count) or (Count>40) or
    (Root=$6899B0) or (Root=$68B318) then
  begin
    for I:=0 to 39 do Cache[I]:=Default(TWarCache);
    LastBase:=0; LastManager:=0; LastNow:=0; Exit;
  end;
  SetLength(Views,Count);
  if not Read32($71CE10,Base) or not Read32($71DAF8,Manager) then Exit;
  Now:=MedNow;
  if (Base<>LastBase) or (Manager<>LastManager) or (Now<LastNow) then
  begin
    for I:=0 to 39 do Cache[I]:=Default(TWarCache);
  end;
  MessagesOK:=WarMessages(Messages);
  LastBase:=Base; LastManager:=Manager; LastNow:=Now;
  for I:=0 to Integer(Count)-1 do
  begin
    Views[I].Caption:='读取失败';
    Views[I].Detail:=CityName[I]+' · 战争状态读取失败';
    if not Read32(Base+Cardinal(I)*$9F8+$2C8,CityFlags) or
      not Read32(Manager+Cardinal(I)*$1024+8,War) then Continue;
    Active:=CityFlags and $10<>0;
    Views[I].ShowIcon:=Active;
    if Views[I].ShowIcon then
    begin
      Views[I].Caption:='围城[未知]';
      Views[I].Detail:=CityName[I]+' · 正在围城'+sLineBreak+'下一阶段时间尚未确定';
    end else
    begin
      Views[I].Caption:='';
      Views[I].Detail:=CityName[I]+' · 当前未检测到围城';
    end;
    Valid:=(War<>0) and MedRead(War,Raw,SizeOf(Raw)) and (Raw[$5D3]=I);
    if Valid then
    begin
      StartDay:=PCardinal(@Raw[$584])^;
      if (Cache[I].War<>War) or (Cache[I].StartDay<>StartDay) then
      begin
        Cache[I]:=Default(TWarCache); Cache[I].War:=War; Cache[I].StartDay:=StartDay;
      end;
      if Active then Cache[I].SeenActive:=True;
      if Raw[$61C]=0 then Attack:='强盗／雇佣兵' else Attack:='统治者军队';
      Approach:=PWord(@Raw[$42])^; Loot:=PWord(@Raw[$3C])^;
      Retreat:=PWord(@Raw[$3A])^; Duration:=PWord(@Raw[$68])^;
      Stage:=MedWarStage(Active,True,Approach,Loot,Retreat);
      Phase:=''; NextPhase:='';
      case Stage of
        wsApproach:begin
          Phase:='围城·进军'; NextPhase:='正式交战';
          Ticks:=Approach; Views[I].Caption:='围城['+MedWarDays(Ticks)+']';
        end;
        wsFighting:begin
          Phase:='正在交战'; NextPhase:='战斗结果';
          Views[I].Caption:='交战[未知]';
        end;
        wsLooting:begin
          Phase:='城镇被攻破，正在掠夺'; NextPhase:='解除围城';
          Ticks:=MedWarLootRemaining(Loot,Duration);
          Views[I].Caption:='掠夺['+MedWarDays(Ticks)+']';
        end;
        wsReleased:begin
          Phase:='围城已解除，原生对象仍在收尾'; NextPhase:='无围城倒计时';
          if Cache[I].EndSeen=0 then Cache[I].EndSeen:=Now;
          if Now-Cache[I].EndSeen<512 then Views[I].Caption:='解除'
          else Views[I].Caption:='';
        end;
        else begin
          Phase:='围城状态过渡'; NextPhase:='待原生更新';
          Views[I].Caption:='围城[未知]';
        end;
      end;
      // Bind calendar day AND inclusive siege duration to this exact start day.
      // Re-read matching live messages every time: failed city reads do not consume
      // a global cursor, and same-address loads cannot turn old letters into wins.
      Matched:=''; Conflict:=False;
      if MessagesOK then
        for J:=0 to High(Messages) do if Messages[J].City=I then
        begin
          if not MedWarMessageMatches(Messages[J].Day,Messages[J].Month,
            Messages[J].Year,Messages[J].Duration,StartDay,Now) then Continue;
          if Messages[J].Victory then Outcome:='守方胜利，敌军被击退'
          else Outcome:='守方失败；掠夺金币：'+UIntToStr(Messages[J].Money)+
            '；毁坏建筑：'+IntToStr(Messages[J].Buildings);
          if (Matched<>'') and (Matched<>Outcome) then Conflict:=True;
          Matched:=Outcome;
        end;
      if MessagesOK then
      begin
        if Conflict then Cache[I].Outcome:='' else Cache[I].Outcome:=Matched;
      end;
      if not Active and (Cache[I].Outcome<>'') and (Now-Cache[I].EndSeen<512) then
        if Pos('守方胜利',Cache[I].Outcome)=1 then Views[I].Caption:='胜利'
        else Views[I].Caption:='失败';
      Views[I].Detail:=CityName[I]+' · '+Phase+sLineBreak+
        '进攻方：'+Attack+sLineBreak+'下一阶段：'+NextPhase+sLineBreak+
        '显示：'+Views[I].Caption+sLineBreak+
        '围城开始：'+Time_To_String(StartDay shl 8);
      if Active and ((Now shr 8)>=StartDay) then Views[I].Detail:=Views[I].Detail+sLineBreak+
        '已持续（仅详情）：'+UIntToStr((Now shr 8)-StartDay)+'天';
      if not Active then Views[I].Detail:=Views[I].Detail+sLineBreak+
        '围城已结束；对象收尾期间不继续累加战争持续时间。';
      if Cache[I].Outcome<>'' then
        Views[I].Detail:=Views[I].Detail+sLineBreak+'原生结算消息：'+Cache[I].Outcome
      else Views[I].Detail:=Views[I].Detail+sLineBreak+'尚未读到可绑定本次围城的结算消息，不推测胜负。';
      if Raw[$61C]=0 then Views[I].Detail:=Views[I].Detail+sLineBreak+
        '原生不同界面也称此类攻击方为强盗、雇佣兵或野蛮部落；不是三个独立枚举。';
    end
    else if not Active then
    begin
      if Cache[I].Outcome<>'' then Views[I].Detail:=Views[I].Detail+sLineBreak+
        '本会话最近已确认结果：'+Cache[I].Outcome;
    end;
    // Prediction is conditional daily generation, never an already scheduled
    // event. Do not create a future siege icon/hourglass from this estimate.
    if not Active and (War=0) and MedRead(Manager+Cardinal(I)*$1024+$1018,Counter,2) and
      (Counter>0) then
    begin
      Views[I].Detail:=Views[I].Detail+sLineBreak+'战争生成计数：'+IntToStr(Counter);
      if (I>=32) then
      begin Views[I].Detail:=Views[I].Detail+sLineBreak+'此城市索引不套用已验证的每日调度估算。'; Continue; end;
      if not Read32($6E1858,Settings) or (Settings=0) or
        not MedRead(Settings+22,Difficulty,1) or
        not MedRead(Manager+Cardinal(I)*$1024+$101B,Special,1) or
        not MedRead(Base+Cardinal(I)*$9F8+$2D4,Population,4) or
        not Read32(Manager+Cardinal(I)*$1024,LastWar) or
        not Read32($70BE84,Gate) or not MedRead($71CE32,Suspended,1) then
      begin Views[I].Caption:='读取失败'; Continue; end;
      Rate:=MedWarDailyStep(Population,Special,Difficulty);
      Days:=MedWarEstimate(Counter,Rate);
      if (Suspended<>0) or (Gate<>0) then
        Views[I].Caption:='来袭[未知]'
      else if (Counter<=Rate) and ((Now<LastWar) or (Now-LastWar<$1C00)) then
        Views[I].Caption:='来袭[未知]'
      else if Days>0 then
        Views[I].Caption:='来袭[约'+UIntToStr(Days)+']';
      Views[I].Detail:=Views[I].Detail+sLineBreak+
        '战前估算：'+Views[I].Caption+sLineBreak+
        '按当前人口/难度每日递减 '+UIntToStr(Rate)+'；尚非排定到达日期，条件不满足会延期。'+sLineBreak+
        '进攻方尚未生成，不预先猜测国王或强盗。';
      // Retain the original near-term horizon; distant conditional counters
      // remain available in details, not as hundreds of days of table noise.
      if Days>=90 then Views[I].Caption:='';
    end;
  end;
end;

end.
