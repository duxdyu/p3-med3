unit MedCityEventUI;

interface

uses Windows, Classes, SysUtils, Types, Graphics, Controls, Forms, Grids, Menus, ExtCtrls,
  MedGameEvents, MedWarState;

type
  TMedCityEventView = class(TComponent)
  private
    Grid: TStringGrid;
    Items: TMedCityEvents;
    Menu: TPopupMenu;
    RemoveItem, DetailItem, ClearDomainItem: TMenuItem;
    Selected: Integer;
    ReadOK: Boolean;
    Interacting: Boolean;
    PopupEvent: TMedCityEvent;
    PopupItems: TMedCityEvents;
    PopupValid: Boolean;
    Clock: TTimer;
    Wars: TMedWarViews;
    PopupWar: string;
    procedure Tick(Sender: TObject);
    function RowItems(City: Integer): TArray<Integer>;
    function FireCount(City: Integer): Integer;
    function DiseaseCount(City: Integer): Integer;
    function GroupCount(const E: TMedCityEvent): Integer;
    procedure GroupState(const E: TMedCityEvent; out Active,Future,Unknown: Boolean);
    function Describe(Index: Integer): string;
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure Details(Sender: TObject);
    procedure Remove(Sender: TObject);
    procedure ClearDomain(Sender: TObject);
    function Hit(X,Y: Integer; out OverflowCity: Integer): Integer;
  public
    constructor CreateFor(Owner: TComponent; AGrid: TStringGrid);
    procedure Refresh;
    procedure Draw(ARow: Integer; Rect: TRect; State: TGridDrawState);
  end;

implementation

uses Dialogs, Untpublic;

constructor TMedCityEventView.CreateFor(Owner: TComponent; AGrid: TStringGrid);
begin
  inherited Create(Owner); Grid:=AGrid; Selected:=-1;
  Menu:=TPopupMenu.Create(Self);
  DetailItem:=TMenuItem.Create(Menu); DetailItem.Caption:='查看事件详情';
  DetailItem.OnClick:=Details; Menu.Items.Add(DetailItem);
  RemoveItem:=TMenuItem.Create(Menu); RemoveItem.Caption:='删除 / 清除这个事件';
  RemoveItem.OnClick:=Remove; Menu.Items.Add(RemoveItem);
  ClearDomainItem:=TMenuItem.Create(Menu); ClearDomainItem.OnClick:=ClearDomain;
  ClearDomainItem.Visible:=False; Menu.Items.Add(ClearDomainItem);
  Grid.OnMouseDown:=MouseDown; Grid.OnMouseUp:=MouseUp;
  // Viewing an event never clears the old whole-city status byte.
  Grid.OnDblClick:=nil;
  Clock:=TTimer.Create(Self); Clock.Interval:=1000; Clock.OnTimer:=Tick;
end;

procedure TMedCityEventView.Tick(Sender: TObject);
begin
  if Interacting then Exit;
  if Grid.Showing then begin Refresh; Grid.Invalidate; end
  else MedScanWars(Wars); // Track newly emitted result messages between MED visits.
end;

procedure TMedCityEventView.Refresh;
var I,J,N: Integer; E: TMedCityEvent;
begin
  ReadOK:=MedScanCityEvents(Items); Selected:=-1;
  for I:=1 to Grid.RowCount-1 do Grid.Cells[10,I]:='';
  MedScanWars(Wars);
  for I:=0 to High(Wars) do
  begin
    if I+1<Grid.RowCount then Grid.Cells[10,I+1]:=Wars[I].Caption;
    if Wars[I].ShowIcon then
    begin
      E:=Default(TMedCityEvent); E.Kind:=ceSiege; E.City:=I;
      E.Pending:=Wars[I].Pending;
      N:=Length(Items); SetLength(Items,N+1); Items[N]:=E;
    end;
  end;
  for I:=1 to High(Items) do
  begin
    E:=Items[I]; J:=I-1;
    while (J>=0) and ((Ord(Items[J].Kind)>Ord(E.Kind)) or
      ((Items[J].Kind=E.Kind) and (Items[J].Pending>E.Pending))) do
    begin Items[J+1]:=Items[J]; Dec(J); end;
    Items[J+1]:=E;
  end;
end;

function TMedCityEventView.RowItems(City: Integer): TArray<Integer>;
var I,J,N: Integer;
begin
  Result:=nil;
  for I:=0 to High(Items) do if Items[I].City=City then
  begin
    if Items[I].Resolving then Continue;
    if Items[I].Kind in [ceBlockade,ceBoycott,ceNavalAttack] then Continue;
    J:=0;
    while (J<Length(Result)) and (Items[Result[J]].Kind<>Items[I].Kind) do Inc(J);
    if J<Length(Result) then Continue;
    N:=Length(Result); SetLength(Result,N+1); Result[N]:=I;
  end;
end;

function TMedCityEventView.GroupCount(const E: TMedCityEvent): Integer;
var I: Integer;
begin
  Result:=0;
  for I:=0 to High(Items) do
    if (Items[I].City=E.City) and (Items[I].Kind=E.Kind) and not Items[I].Resolving then Inc(Result);
end;

procedure TMedCityEventView.GroupState(const E: TMedCityEvent; out Active,Future,Unknown: Boolean);
var I: Integer;
begin
  Active:=False; Future:=False; Unknown:=False;
  for I:=0 to High(Items) do
    if (Items[I].City=E.City) and (Items[I].Kind=E.Kind) and not Items[I].Resolving then
    begin
      Active:=Active or Items[I].EffectPresent or (not Items[I].Pending and not Items[I].Uncertain);
      Future:=Future or (Items[I].Pending and not Items[I].Uncertain);
      Unknown:=Unknown or Items[I].Uncertain;
    end;
end;

function TMedCityEventView.FireCount(City: Integer): Integer;
var I: Integer;
begin
  Result:=0;
  for I:=0 to High(Items) do
    if (Items[I].City=City) and (Items[I].Kind=ceFire) and
      not Items[I].Pending then Inc(Result);
end;

function TMedCityEventView.DiseaseCount(City: Integer): Integer;
var I: Integer;
begin
  Result:=0;
  for I:=0 to High(Items) do
    if (Items[I].City=City) and (Items[I].Kind=ceDisease) then Inc(Result);
end;

procedure TMedCityEventView.Draw(ARow: Integer; Rect: TRect; State: TGridDrawState);
const Icons: array[TMedCityEventKind] of Integer=(37,31,29,0,0,32,34,33,36);
var Row: TArray<Integer>; I,Count,X,Y,MarkerX: Integer; B: BLENDFUNCTION;
    E: TMedCityEvent; C: TCanvas; R: TRect; Badge: string; BadgeWidth: Integer;
    Active,Future,Unknown: Boolean;
begin
  if ARow<1 then Exit;
  C:=Grid.Canvas;
  C.Brush.Style:=bsSolid; C.Font.Assign(Grid.Font);
  if gdSelected in State then begin C.Brush.Color:=clHighlight; C.Font.Color:=clHighlightText; end
  else begin C.Brush.Color:=Grid.Color; C.Font.Color:=Grid.Font.Color; end;
  C.FillRect(Rect);
  if not ReadOK and (Length(Items)=0) then
  begin C.TextOut(Rect.Left+2,Rect.Top+2,'读取失败'); Exit; end;
  Row:=RowItems(ARow-1); Count:=(Rect.Right-Rect.Left-4) div 24;
  if Length(Row)>Count then Dec(Count);
  if Count<0 then Count:=0;
  Y:=Rect.Top+(Rect.Bottom-Rect.Top-20) div 2;
  for I:=0 to Length(Row)-1 do
  begin
    if I>=Count then Break;
    X:=Rect.Left+2+I*24; E:=Items[Row[I]];
    GroupState(E,Active,Future,Unknown);
    MarkerX:=X+11;
    if not Active and Future and not Unknown then
    begin
      B.BlendOp:=AC_SRC_OVER; B.BlendFlags:=0;
      B.SourceConstantAlpha:=128; B.AlphaFormat:=0;
      Windows.AlphaBlend(C.Handle,X,Y,20,20,SpBmp[Icons[E.Kind]].Canvas.Handle,
        0,0,20,20,B);
    end else C.Draw(X,Y,SpBmp[Icons[E.Kind]]);
    if E.Kind in [cePoorHarvest,ceGoodHarvest] then
    begin
      C.Font.Style:=[fsBold]; C.Font.Size:=9;
      if E.Kind=ceGoodHarvest then begin C.Font.Color:=clLime; C.TextOut(X+10,Y+2,'+'); end
      else begin C.Font.Color:=clRed; C.TextOut(X+10,Y+2,'-'); end;
      C.Font.Assign(Grid.Font);
    end;
    if Active and (E.Kind<>ceSiege) then
    begin
      Badge:=IntToStr(GroupCount(E));
      C.Font.Name:='Tahoma'; C.Font.Height:=-10; C.Font.Style:=[fsBold];
      BadgeWidth:=C.TextWidth(Badge)+2;
      if BadgeWidth<9 then BadgeWidth:=9;
      if BadgeWidth>20 then BadgeWidth:=20;
      R:=Types.Rect(X+20-BadgeWidth,Y+10,X+20,Y+20);
      C.Brush.Style:=bsSolid; C.Brush.Color:=$E7FFFF; C.FillRect(R);
      C.Font.Color:=$006090;
      Windows.DrawText(C.Handle,PChar(Badge),Length(Badge),R,
        DT_RIGHT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
      C.Font.Assign(Grid.Font);
    end;
    if Unknown and not Active then
    begin
      C.Font.Color:=clGrayText; C.TextOut(MarkerX,Y+8,'?'); C.Font.Assign(Grid.Font);
    end
    else if Future and not Active then
    begin
      // Opaque hourglass, independent of the icon's 50% opacity.
      C.Brush.Color:=$E7FFFF; R:=Types.Rect(MarkerX,Y+10,MarkerX+9,Y+20); C.FillRect(R);
      C.Pen.Color:=$006090; C.Pen.Width:=1;
      C.MoveTo(MarkerX+1,Y+11); C.LineTo(MarkerX+8,Y+11);
      C.MoveTo(MarkerX+1,Y+19); C.LineTo(MarkerX+8,Y+19);
      C.MoveTo(MarkerX+2,Y+12); C.LineTo(MarkerX+7,Y+18);
      C.MoveTo(MarkerX+7,Y+12); C.LineTo(MarkerX+2,Y+18);
    end;
  end;
  if Length(Row)>Count then
  begin
    if gdSelected in State then C.Font.Color:=clHighlightText else C.Font.Color:=clWindowText;
    C.Brush.Style:=bsClear;
    C.TextOut(Rect.Left+2+Count*24,Rect.Top+3,'+'+IntToStr(Length(Row)-Count));
  end;
  C.Brush.Style:=bsSolid; C.Font.Assign(Grid.Font);
end;

function TMedCityEventView.Describe(Index: Integer): string;
var E: TMedCityEvent; Now: Cardinal; I: Integer; IDs: string;
begin
  Result:=''; if (Index<0) or (Index>High(Items)) then Exit;
  E:=Items[Index]; Now:=MedNow;
  if E.Kind=ceSiege then Exit(Wars[E.City].Detail);
  Result:=CityName[E.City]+' · '+MedCityEventName(E.Kind)+sLineBreak;
  if E.Kind=ceDisease then
  begin
    Result:=Result+'本城共有'+IntToStr(DiseaseCount(E.City))+'条瘟疫记录。'+sLineBreak;
    for I:=0 to High(Items) do if (Items[I].Kind=ceDisease) and (Items[I].City=E.City) then
    begin
      Result:=Result+'实例 '+IntToStr(Items[I].Event.Index)+'：';
      if Items[I].Uncertain then Result:=Result+'启动阶段尚未确认'
      else if Items[I].Pending then Result:=Result+'预约 '+Time_To_String(Items[I].StartTime)
      else Result:=Result+'已开始';
      Result:=Result+'；原生结束阈值 '+Time_To_String(Items[I].EndTime)+sLineBreak;
    end;
    Exit;
  end;
  if E.ReadOnlyEvent then
  begin
    if E.EffectPresent then Result:=Result+'正在发生。'
    else if E.Uncertain then Result:=Result+'相关行动存在，当前阶段尚未确定。'
    else Result:=Result+'已存在原生行动记录；下次阶段处理：'+Time_To_String(E.StartTime)+
      '。这不是保证封锁到达或结束的日期。';
    if E.Kind=ceBlockade then Result:=Result+sLineBreak+'封锁行动也可能伴随抵制效果，期限受原生条件影响。';
    if E.Kind=ceNavalAttack then Result:=Result+sLineBreak+'已确认港口海战状态；仅凭此标签不能确认攻击方一定是海盗。';
    Result:=Result+sLineBreak+'只读状态，不提供删除或强制结束。'; Exit;
  end;
  if E.Uncertain then
    Result:=Result+'火势暂未确定，请推进少量游戏时间等待刷新'
  else if E.Pending then
    Result:=Result+'即将发生：'+MedRemaining(E.StartTime,Now)+sLineBreak+
      '排定日期：'+Time_To_String(E.StartTime)
  else if E.Resolving then
    Result:=Result+'效果已结束，原生通知仍在收尾。'
  else if E.Kind=ceDisease then
    Result:=Result+'瘟疫实例已开始；原生结束阈值：'+Time_To_String(E.EndTime)+sLineBreak+
      '停止时刻由处理步长决定，阈值不是保证精确解除了疾病的时刻。'
  else if E.EndKnown then
    Result:=Result+'正在发生；距计划结束：'+MedRemaining(E.EndTime,Now)+sLineBreak+
      '计划结束：'+Time_To_String(E.EndTime)
  else if E.Kind=ceFire then Result:=Result+'正在发生；扑灭时间未定，由燃烧进展决定'
  else Result:=Result+'正在发生；效果结束时间尚未确定（后续阶段可能调整）';
  if E.Kind in [cePoorHarvest,ceGoodHarvest] then
    Result:=Result+sLineBreak+'这是独立收成事件，不是冬季固定减产。';
  if E.Kind=ceFrozen then Result:=Result+sLineBreak+'普通冬季不等于冻港；未排定的冻结时间不作确定预测。';
  if (E.Kind=ceFire) and not E.Pending then
  begin
    IDs:='';
    for I:=0 to High(Items) do
      if (Items[I].City=E.City) and (Items[I].Kind=ceFire) and not Items[I].Pending then
      begin
        if IDs<>'' then IDs:=IDs+'、';
        IDs:=IDs+IntToStr(Items[I].Event.Index);
      end;
    Result:=Result+sLineBreak+'当前火势实例：'+IntToStr(FireCount(E.City))+
      '（不是燃烧建筑数）'+sLineBreak+'原生事件编号：'+IDs;
  end else Result:=Result+sLineBreak+'原生事件编号：'+IntToStr(E.Event.Index);
  if E.Kind<>ceDisease then
    for I:=0 to High(Items) do
      if (I<>Index) and (Items[I].City=E.City) and (Items[I].Kind=E.Kind) then
      begin
        Result:=Result+sLineBreak+'实例 '+IntToStr(Items[I].Event.Index)+'：';
        if Items[I].Uncertain then Result:=Result+'状态暂未确定'
        else if Items[I].Pending then Result:=Result+'即将发生，'+Time_To_String(Items[I].StartTime)
        else if Items[I].Resolving then Result:=Result+'已结束'
        else Result:=Result+'正在发生';
      end;
end;

function TMedCityEventView.Hit(X,Y: Integer; out OverflowCity: Integer): Integer;
var Col,Row,Position,Count: Integer; R: TRect; Indices: TArray<Integer>;
begin
  Result:=-1; OverflowCity:=-1;
  Grid.MouseToCell(X,Y,Col,Row);
  if (Col<>9) or (Row<1) or (Row>=Grid.RowCount) then Exit;
  R:=Grid.CellRect(Col,Row); Indices:=RowItems(Row-1);
  Position:=(X-R.Left-2) div 24;
  if X<R.Left+2 then Exit;
  Count:=(R.Right-R.Left-4) div 24;
  if Length(Indices)>Count then Dec(Count);
  if (Position>=0) and (Position<Length(Indices)) then
    if Position<Count then Result:=Indices[Position]
    else OverflowCity:=Row-1;
end;

procedure TMedCityEventView.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
var Overflow: Integer; Active,Future,Unknown: Boolean;
begin
  if Button<>mbRight then Exit;
  PopupWar:='';
  Selected:=Hit(X,Y,Overflow);
  if Selected<0 then Exit;
  GroupState(Items[Selected],Active,Future,Unknown);
  RemoveItem.Caption:='删除事件';
  ClearDomainItem.Caption:='删除未来事件';
  RemoveItem.Visible:=(Active or Unknown) and not Items[Selected].ReadOnlyEvent and (Items[Selected].Kind<>ceSiege);
  RemoveItem.Enabled:=Active or (Items[Selected].Kind in [ceDisease,ceFire]);
  ClearDomainItem.Visible:=Future and not Items[Selected].ReadOnlyEvent and (Items[Selected].Kind<>ceSiege);
  ClearDomainItem.Enabled:=Future;
end;

procedure TMedCityEventView.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
type TRealClientToScreen = function(Window: HWND; var Point: TPoint): BOOL; stdcall;
var Overflow,I,Col,Row: Integer; Point: TPoint; Text: string; Indices: TArray<Integer>;
    RealScreen: TRealClientToScreen;
begin
  if not (Button in [mbLeft,mbRight]) then Exit;
  Grid.MouseToCell(X,Y,Col,Row);
  if (Col=10) and (Row>0) and (Row<=Length(Wars)) then
  begin
    if not Wars[Row-1].ShowIcon then Exit;
    Interacting:=True;
    try ShowMessage(Wars[Row-1].Detail); finally Interacting:=False; end;
    Exit;
  end;
  Selected:=Hit(X,Y,Overflow);
  Interacting:=True;
  try
  if Selected>=0 then
    if Button=mbRight then
    begin
      // Derive menu and operation from the SAME final hit/snapshot.
      MouseDown(Sender,Button,Shift,X,Y);
      PopupEvent:=Items[Selected]; PopupItems:=Copy(Items); PopupValid:=True;
      PopupWar:='';
      if PopupEvent.Kind=ceSiege then PopupWar:=Wars[PopupEvent.City].Detail;
      Point:=Types.Point(X,Y);
      @RealScreen:=GetProcAddress(GetModuleHandle('user32.dll'),'ClientToScreen');
      if not Assigned(RealScreen) or not RealScreen(Grid.Handle,Point) then Exit;
      Menu.Popup(Point.X,Point.Y);
    end
    else Details(Self)
  else if Overflow>=0 then
  begin
    Text:=''; Indices:=RowItems(Overflow);
    for I:=0 to High(Indices) do Text:=Text+Describe(Indices[I])+sLineBreak+sLineBreak;
    ShowMessage(Text);
  end;
  finally Interacting:=False; Selected:=-1; end;
end;

procedure TMedCityEventView.Details(Sender: TObject);
var Saved: TMedCityEvents; Index,I: Integer; WasInteracting: Boolean;
begin
  WasInteracting:=Interacting; Interacting:=True;
  try
  if (Sender=DetailItem) and PopupValid then
  begin
    if PopupEvent.Kind=ceSiege then begin ShowMessage(PopupWar); Exit; end;
    Saved:=Items; Index:=Selected;
    Items:=PopupItems;
    try
      for I:=0 to High(Items) do
         if (Items[I].Event.Pool=PopupEvent.Event.Pool) and
           (Items[I].Event.Index=PopupEvent.Event.Index) and
           (Items[I].Kind=PopupEvent.Kind) and (Items[I].City=PopupEvent.City) then
        begin ShowMessage(Describe(I)); Break; end;
    finally Items:=Saved; Selected:=Index; end;
  end
  else if Selected>=0 then ShowMessage(Describe(Selected));
  finally Interacting:=WasInteracting; end;
end;

procedure TMedCityEventView.Remove(Sender: TObject);
var Error: string;
begin
  if not PopupValid then Exit;
  PopupValid:=False;
  if PopupEvent.Kind=ceFire then
  begin
    if not MedClearFireGroup(PopupEvent,PopupItems,Error,True) then ShowMessage(Error);
  end
  else if not MedClearCityDomain(PopupEvent,PopupItems,Error) then ShowMessage(Error);
  Refresh; Grid.Invalidate;
end;

procedure TMedCityEventView.ClearDomain(Sender: TObject);
var Error: string;
begin
  if not PopupValid then Exit;
  PopupValid:=False;
  if not MedDeleteFutureGroup(PopupEvent,PopupItems,Error) then ShowMessage(Error);
  Refresh; Grid.Invalidate;
end;

end.
