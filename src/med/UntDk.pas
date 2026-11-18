unit UntDk;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls, Menus, Untpublic,
  MedLoanRules, MedGameEvents;

type
  TLoanRow = record
    City, Slot: Integer;
    Demand: TMedLoanDemand;
  end;
  TFrmDk = class(TForm)
    Panel3, Panel1: TPanel;
    StrGid1, StrGid2: TStringGrid;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    Panel4, Panel5, Panel6, Panel7: TPanel;
    Button2, Button1: TButton;
    ComBox: TComboBox;
    Label1: TLabel;
    Panel8: TPanel;
    Label2: TLabel;
    Edit1, Edit2, Edit3: TEdit;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure ComBoxChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure StrGid2DblClick(Sender: TObject);
  private
    CompareBox, RankBox: TComboBox;
    LoanMenu: TPopupMenu;
    CashItem, GoodsItem: TMenuItem;
    Demands: array of TLoanRow;
    Confirmed: TMedEvents;
    Busy, Loading: Boolean;
    PopupEvent: TMedEvent;
    PopupValid: Boolean;
    procedure RuleChange(Sender: TObject);
    procedure RepaymentClick(Sender: TObject);
    procedure LoanMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure LoanMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
    procedure LoanPopup(Sender: TObject);
    procedure DrawDemand(Sender: TObject; ACol,ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RefreshDemands;
    procedure RefreshConfirmed;
  end;

procedure Read_Dkxq;
procedure QR_Dk;

var FrmDk: TFrmDk;

implementation

uses IniFiles, MedConfigPath;
{$R *.dfm}

function RankName(Rank: Byte): string;
begin
  if Rank<=7 then Result:=PeopCap[Rank] else Result:='未知';
end;

function PersonName(Surname, GivenName: Byte): string;
begin
  if (Surname<=High(popnamex)) and (GivenName<=High(popnamem)) then
    Result:=popnamex[Surname]+'·'+popnamem[GivenName]
  else Result:='未知姓名';
end;

procedure ClearGrid(Grid: TStringGrid);
var I: Integer;
begin
  Grid.RowCount:=2;
  for I:=0 to Grid.ColCount-1 do Grid.Cells[I,1]:='';
end;

procedure Read_Dkxq;
begin if Assigned(FrmDk) then FrmDk.RefreshDemands; end;
procedure QR_Dk;
begin if Assigned(FrmDk) then FrmDk.RefreshConfirmed; end;

procedure TFrmDk.FormCreate(Sender: TObject);
const
  LeftHeads: array[0..7] of string=('序号','城市','称呼','姓名','本金','期限[周]','周利率','到期应收');
  RightHeads: array[0..7] of string=('序号','借款城市','称呼','姓名','应收金额','到期/处置日期','周利率','偿还方式');
var I: Integer; Ini: TIniFile; CaptionLabel: TLabel;
begin
  Loading:=True;
  Panel1.Caption:=''; Panel3.Caption:='';
  StrGid1.ColCount:=8; StrGid2.ColCount:=8;
  for I:=0 to 7 do begin StrGid1.Cells[I,0]:=LeftHeads[I]; StrGid2.Cells[I,0]:=RightHeads[I]; end;
  StrGid1.ColWidths[0]:=40; StrGid2.ColWidths[0]:=40;
  StrGid1.ColWidths[1]:=80; StrGid2.ColWidths[1]:=80;
  StrGid1.ColWidths[2]:=90; StrGid2.ColWidths[2]:=90;
  StrGid1.ColWidths[3]:=145; StrGid2.ColWidths[3]:=145;
  StrGid2.ColWidths[5]:=115; StrGid2.ColWidths[7]:=145;
  StrGid1.OnDrawCell:=DrawDemand;
  Panel2.Height:=76; StatusBar1.Align:=alBottom; StatusBar1.Height:=22;
  Panel7.Align:=alClient; Panel7.BevelOuter:=bvNone;
  Button1.SetBounds(12,12,90,28); Button1.Caption:='一键放贷';
  Label1.SetBounds(112,19,24,16); Label1.Caption:='对';
  CompareBox:=TComboBox.Create(Self); CompareBox.Parent:=Panel7;
  CompareBox.Style:=csDropDownList; CompareBox.SetBounds(136,14,75,24);
  CompareBox.Items.Add('高于'); CompareBox.Items.Add('低于');
  RankBox:=TComboBox.Create(Self); RankBox.Parent:=Panel7;
  RankBox.Style:=csDropDownList; RankBox.SetBounds(218,14,130,24);
  for I:=0 to 7 do RankBox.Items.Add(RankName(I));
  CaptionLabel:=TLabel.Create(Self); CaptionLabel.Parent:=Panel7;
  CaptionLabel.SetBounds(354,19,110,16); CaptionLabel.Caption:='的借款人，以';
  ComBox.SetBounds(458,14,95,24); ComBox.Style:=csDropDownList;
  ComBox.Items.Clear;
  ComBox.Items.Add('非常低'); ComBox.Items.Add('低'); ComBox.Items.Add('一般');
  ComBox.Items.Add('高'); ComBox.Items.Add('非常高');
  CaptionLabel:=TLabel.Create(Self); CaptionLabel.Parent:=Panel7;
  CaptionLabel.SetBounds(561,19,90,16); CaptionLabel.Caption:='利率档位放贷';
  Button2.SetBounds(660,12,65,28); Button2.Visible:=True;
  Panel5.Caption:='贷款需求（符合筛选的行高亮）';
  Panel6.Caption:='已放贷（右键切换偿还方式）';
  Ini:=TIniFile.Create(MedConfigFileName);
  try
    I:=Ini.ReadInteger('Loans','Comparison',0); if not (I in [0,1]) then I:=0; CompareBox.ItemIndex:=I;
    I:=Ini.ReadInteger('Loans','Rank',1); if not (I in [0..7]) then I:=1; RankBox.ItemIndex:=I;
    I:=Ini.ReadInteger('Loans','Tier',2); if not (I in [0..4]) then I:=2; ComBox.ItemIndex:=I;
  finally Ini.Free; end;
  CompareBox.OnChange:=RuleChange; RankBox.OnChange:=RuleChange;
  LoanMenu:=TPopupMenu.Create(Self); LoanMenu.OnPopup:=LoanPopup;
  CashItem:=TMenuItem.Create(LoanMenu); CashItem.Caption:='改为现金还款'; CashItem.Tag:=0;
  CashItem.OnClick:=RepaymentClick; LoanMenu.Items.Add(CashItem);
  GoodsItem:=TMenuItem.Create(LoanMenu); GoodsItem.Caption:='改为实物抵债处置'; GoodsItem.Tag:=1;
  GoodsItem.OnClick:=RepaymentClick; LoanMenu.Items.Add(GoodsItem);
  StrGid2.OnMouseDown:=LoanMouseDown; StrGid2.OnMouseUp:=LoanMouseUp;
  Loading:=False;
end;

procedure TFrmDk.RefreshDemands;
var City,Slot,N: Integer; Row: TLoanRow; Rate: Byte; Due: Cardinal;
begin
  ClearGrid(StrGid1); Demands:=nil;
  if not MedGameReady then Exit;
  for City:=0 to Integer(CityCunt)-1 do
  begin
    if SWSDZ[City]=0 then Continue;
    for Slot:=0 to 2 do
    begin
      Row.City:=City; Row.Slot:=Slot;
      if not MedRead(CityDZ[City]+$9D8+Cardinal(Slot)*6,Row.Demand,6) or
        not LoanQuote(Row.Demand.Principal,Row.Demand.Weeks,ComBox.ItemIndex,Rate,Due) then Continue;
      N:=Length(Demands); SetLength(Demands,N+1); Demands[N]:=Row;
      StrGid1.RowCount:=N+2;
      StrGid1.Cells[0,N+1]:=IntToStr(N+1);
      StrGid1.Cells[1,N+1]:=CityName[City];
      StrGid1.Cells[2,N+1]:=RankName(Row.Demand.Rank);
      StrGid1.Cells[3,N+1]:=PersonName(Row.Demand.Surname,Row.Demand.GivenName);
      StrGid1.Cells[4,N+1]:=IntToStr(Row.Demand.Principal);
      StrGid1.Cells[5,N+1]:=IntToStr(Row.Demand.Weeks);
      StrGid1.Cells[6,N+1]:=FormatFloat('0.0',Rate/10)+'%';
      StrGid1.Cells[7,N+1]:=UIntToStr(Due);
    end;
  end;
  StrGid1.Invalidate;
end;

procedure TFrmDk.RefreshConfirmed;
var All: TMedEvents; I,N: Integer; E: TMedEvent; Branch: string;
begin
  ClearGrid(StrGid2); Confirmed:=nil; PopupValid:=False;
  if not MedScanEvents(All) then Exit;
  for I:=0 to High(All) do
  begin
    E:=All[I];
    if (E.Value.Kind<>1) or (E.Value.Data[8]<>MedPlayer) or
      (E.Value.Data[9]<>$FF) then Continue;
    N:=Length(Confirmed); SetLength(Confirmed,N+1); Confirmed[N]:=E;
    StrGid2.RowCount:=N+2;
    StrGid2.Cells[0,N+1]:=IntToStr(N+1);
    if E.Value.Data[12]<CityCunt then StrGid2.Cells[1,N+1]:=CityName[E.Value.Data[12]];
    StrGid2.Cells[2,N+1]:=RankName(E.Value.Data[13]);
    StrGid2.Cells[3,N+1]:=PersonName(E.Value.Data[14],E.Value.Data[15]);
    StrGid2.Cells[4,N+1]:=UIntToStr(PCardinal(@E.Value.Data[0])^);
    StrGid2.Cells[5,N+1]:=Time_To_String(E.Value.Time);
    if E.Value.Data[10]>0 then
      StrGid2.Cells[6,N+1]:=FormatFloat('0.0',E.Value.Data[10]/10)+'%';
    if E.Value.Data[10]=0 then Branch:='待处置：'+MedRemaining(E.Value.Time,MedNow)
    else if E.Value.Data[4]=0 then Branch:='现金还款'
    else Branch:='实物抵债处置';
    StrGid2.Cells[7,N+1]:=Branch;
  end;
end;

procedure TFrmDk.DrawDemand(Sender: TObject; ACol,ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if (ARow=0) or (ARow>Length(Demands)) then Exit;
  with StrGid1.Canvas do
  begin
    if gdSelected in State then begin Brush.Color:=clHighlight; Font.Color:=clHighlightText; end
    else begin
      Font.Color:=clWindowText;
      if LoanMatches(Demands[ARow-1].Demand.Rank,RankBox.ItemIndex,CompareBox.ItemIndex) then
        Brush.Color:=$E8F4DE else Brush.Color:=StrGid1.Color;
    end;
    FillRect(Rect); TextOut(Rect.Left+3,Rect.Top+3,StrGid1.Cells[ACol,ARow]);
  end;
end;

procedure TFrmDk.RuleChange(Sender: TObject);
var Ini: TIniFile;
begin
  if Loading then Exit;
  try
    Ini:=TIniFile.Create(MedConfigFileName);
    try
      Ini.WriteInteger('Loans','Comparison',CompareBox.ItemIndex);
      Ini.WriteInteger('Loans','Rank',RankBox.ItemIndex);
      Ini.WriteInteger('Loans','Tier',ComBox.ItemIndex);
    finally Ini.Free; end;
  except on E: Exception do StatusBar1.Panels[0].Text:='规则保存失败：'+E.Message; end;
  RefreshDemands;
end;

procedure TFrmDk.ComBoxChange(Sender: TObject);
begin RuleChange(Sender); end;

procedure TFrmDk.Button1Click(Sender: TObject);
var I,Done: Integer; Error: string; Row: TLoanRow;
begin
  if Busy then Exit;
  Busy:=True; Button1.Enabled:=False; Done:=0;
  try
    RefreshDemands;
    for I:=0 to High(Demands) do
    begin
      Row:=Demands[I];
      if not LoanMatches(Row.Demand.Rank,RankBox.ItemIndex,CompareBox.ItemIndex) then Continue;
      if not MedGrantLoan(Row.City,Row.Slot,ComBox.ItemIndex,Row.Demand,Error) then Break;
      Inc(Done);
    end;
    StatusBar1.Panels[0].Text:=Format('已按原生规则放贷 %d 笔。',[Done])+Error;
    RefreshDemands; RefreshConfirmed;
  finally Busy:=False; Button1.Enabled:=True; end;
end;

procedure TFrmDk.Button2Click(Sender: TObject);
begin RefreshDemands; RefreshConfirmed; end;

procedure TFrmDk.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
  var Resize: Boolean);
begin
  if (StrGid1=nil) or (Panel5=nil) then Exit;
  StrGid1.Width:=NewWidth div 2; Panel5.Width:=StrGid1.Width;
end;

procedure TFrmDk.LoanMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
var Col,Row: Integer;
begin
  if Button<>mbRight then Exit;
  StrGid2.MouseToCell(X,Y,Col,Row);
  PopupValid:=(Row>0) and (Row<=Length(Confirmed));
  if PopupValid then begin StrGid2.Row:=Row; PopupEvent:=Confirmed[Row-1]; end;
end;

procedure TFrmDk.LoanPopup(Sender: TObject);
begin
  CashItem.Enabled:=PopupValid and (PopupEvent.Value.Data[10]>0) and (PopupEvent.Value.Time>MedNow);
  GoodsItem.Enabled:=CashItem.Enabled;
end;

procedure TFrmDk.LoanMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
type TRealClientToScreen = function(Window: HWND; var Point: TPoint): BOOL; stdcall;
var P: TPoint; RealScreen: TRealClientToScreen;
begin
  if (Button<>mbRight) or not PopupValid then Exit;
  P.X:=X; P.Y:=Y;
  @RealScreen:=GetProcAddress(GetModuleHandle('user32.dll'),'ClientToScreen');
  if Assigned(RealScreen) and RealScreen(StrGid2.Handle,P) then LoanMenu.Popup(P.X,P.Y);
end;

procedure TFrmDk.RepaymentClick(Sender: TObject);
var Error: string;
begin
  if not PopupValid then Exit;
  if not MedSetLoanBranch(PopupEvent,TMenuItem(Sender).Tag=0,Error) then ShowMessage(Error);
  RefreshConfirmed;
end;

procedure TFrmDk.StrGid2DblClick(Sender: TObject);
begin
  if (StrGid2.Row<1) or (StrGid2.Row>Length(Confirmed)) then Exit;
  ShowMessage('偿还方式是当前贷款的预定分支。实物抵债会在到期后进入原生处置流程，'+
    '由信件选择没收财产或豁免；并非到期自动交付某种商品。待处置贷款不可再切换分支。');
end;

procedure TFrmDk.Button3Click(Sender: TObject);
begin RefreshConfirmed; end;

end.
