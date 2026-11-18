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
    RemoveItem, DetailItem: TMenuItem;
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
    function Describe(Index: Integer): string;
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure Details(Sender: TObject);
    procedure Remove(Sender: TObject);
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
var I,N: Integer; HasActiveFire: Boolean;
begin
  Result:=nil; HasActiveFire:=False;
  for I:=0 to High(Items) do if Items[I].City=City then
  begin
    // Only presentation is grouped. Keep every native record for details and
    // identity checks; future warnings retain their hourglass and schedule.
    if (Items[I].Kind=ceFire) and not Items[I].Pending then
    begin
      if HasActiveFire then Continue;
      HasActiveFire:=True;
    end;
    N:=Length(Result); SetLength(Result,N+1); Result[N]:=I;
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

procedure TMedCityEventView.Draw(ARow: Integer; Rect: TRect; State: TGridDrawState);
const Icons: array[TMedCityEventKind] of Integer=(37,31,29,0,0,32);
var Row: TArray<Integer>; I,Count,X,Y: Integer; B: BLENDFUNCTION;
    E: TMedCityEvent; C: TCanvas; R: TRect; Badge: string; BadgeWidth: Integer;
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
    if E.Pending and not E.Uncertain then
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
    end
    else if (E.Kind=ceFire) and not E.Pending then
    begin
      Badge:=IntToStr(FireCount(E.City));
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
    if E.Uncertain then
    begin
      C.Font.Color:=clGrayText; C.TextOut(X+11,Y+8,'?'); C.Font.Assign(Grid.Font);
    end
    else if E.Pending then
    begin
      // Opaque hourglass, independent of the icon's 50% opacity.
      C.Brush.Color:=$E7FFFF; R:=Types.Rect(X+11,Y+10,X+20,Y+20); C.FillRect(R);
      C.Pen.Color:=$006090; C.Pen.Width:=1;
      C.MoveTo(X+12,Y+11); C.LineTo(X+19,Y+11);
      C.MoveTo(X+12,Y+19); C.LineTo(X+19,Y+19);
      C.MoveTo(X+13,Y+12); C.LineTo(X+18,Y+18);
      C.MoveTo(X+18,Y+12); C.LineTo(X+13,Y+18);
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
  if E.Uncertain then
    Result:=Result+'处于启动或收尾边界，尚不能确认本实例是否开始传播；请推进少量游戏时间后刷新。'
  else if E.Pending then
    Result:=Result+'即将发生：'+MedRemaining(E.StartTime,Now)+sLineBreak+
      '排定日期：'+Time_To_String(E.StartTime)
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
    Result:=Result+sLineBreak+'清除将结束整组当前火势，已着火建筑按原生结束流程处理；不恢复既有损失。';
  end else Result:=Result+sLineBreak+'原生事件编号：'+IntToStr(E.Event.Index);
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
var Overflow: Integer;
begin
  if Button<>mbRight then Exit;
  PopupWar:='';
  Selected:=Hit(X,Y,Overflow);
  if Selected<0 then Exit;
  RemoveItem.Enabled:=(Items[Selected].Kind<>ceSiege) and not Items[Selected].Uncertain;
  if Items[Selected].Kind=ceSiege then
    RemoveItem.Caption:='战争事件不支持强制清除'
  else if (Items[Selected].Kind=ceFire) and not Items[Selected].Pending then
    RemoveItem.Caption:='清除当前火势（'+IntToStr(FireCount(Items[Selected].City))+'个实例）'
  else if Items[Selected].Uncertain then RemoveItem.Caption:='状态待确认，请刷新'
  else if Items[Selected].Pending then RemoveItem.Caption:='删除：取消这个未发生事件'
  else RemoveItem.Caption:='清除：结束这个当前事件';
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
          (Items[I].Event.Index=PopupEvent.Event.Index) then
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
  if (PopupEvent.Kind=ceFire) and not PopupEvent.Pending then
  begin
    if not MedClearFireGroup(PopupEvent,PopupItems,Error) then ShowMessage(Error);
  end
  else if not MedDeleteCityEvent(PopupEvent,Error) then ShowMessage(Error);
  Refresh; Grid.Invalidate;
end;

end.
