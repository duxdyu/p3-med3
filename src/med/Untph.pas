unit Untph;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Untpublic, Grids, StdCtrls, CheckLst, ExtCtrls, Spin, IniFiles;

type
  TFrmPH = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StrGid2: TStringGrid;
    RadioGroup: TRadioGroup;
    CheckListBox: TCheckListBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel10: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    E2: TEdit;
    E3: TEdit;
    E4: TEdit;
    Ed1: TEdit;
    Ed2: TEdit;
    Ed3: TEdit;
    Ed4: TEdit;
    Ed5: TEdit;
    Ed6: TEdit;
    Ed7: TEdit;
    Sp0: TSpinEdit;
    Sp1: TSpinEdit;
    Sp2: TSpinEdit;
    Sp3: TSpinEdit;
    RG: TRadioGroup;
    CkB: TCheckBox;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure StrGid2DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure CheckListBoxClickCheck(Sender: TObject);
    procedure RadioGroupClick(Sender: TObject);
    procedure Sp1Change(Sender: TObject);
    procedure Sp2Change(Sender: TObject);
    procedure Sp3Change(Sender: TObject);
    procedure Sp0Change(Sender: TObject);
    procedure Sp0KeyPress(Sender: TObject; var Key: Char);
    procedure RGClick(Sender: TObject);
    procedure CkBClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    FUpdating: Boolean;
    FTownBalance: array[0..19] of Int64;
    procedure ReadBalance;
    procedure PredictBalance;
  public
    { Compatibility entry used by the recovered main unit. }
    procedure Button1Click(Sender: TObject);
  end;

procedure PH_init;

var
  FrmPH: TFrmPH;

implementation

uses MedConfigPath;

{$R *.dfm}

const
  { MED3.dll 004C91DC, 004C92CC, 004C9314, 004C94D4, 004C9538. }
  Consumption: array[0..19,0..2] of Integer = (
    (90,120,150),(110,87,12),(40,80,100),(65,130,65),(1,1,1),
    (50,25,5),(4,2,2),(150,38,0),(50,35,15),(60,30,0),
    (50,35,10),(80,80,40),(100,75,25),(44,35,5),(10,40,20),
    (0,0,0),(0,0,0),(5,3,2),(30,18,12),(1,1,0));
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
  OutputRate: array[0..19] of Integer =
    (2000,500,2000,1410,1001,400,0,402,600,200,810,4000,600,200,1002,200,999,500,401,2010);
  FactoryGoods: array[0..17] of Byte =
    (9,2,3,12,5,0,1,11,8,4,16,14,7,18,19,15,17,10);
  PValue: array[0..19] of Single =
    (17.16,38.39,27.06,2.71,3.93,8.99,0,8.99,8.39,16.44,
     1.68,7.86,9.27,9.32,31.45,8.65,32.38,74.01,8.65,11.79);

type
  TGoodsCount = array[0..19] of Int64;
  TFactoryCount = array[0..17,0..1] of Integer;

function ReadValue(Address: Cardinal; Size: Integer): Integer;
begin
  Result := 0;
  ReadProcessMemory(GHandle, Pointer(Address), @Result, Size, tmpNum);
end;

function FactoryFactor(Good: Integer): Single;
begin
  case Good of
    0: Result := 1.0909091;
    5,9,17: Result := 1.1428572;
    10: Result := 1.0996;
  else Result := 1;
  end;
end;

procedure CountFactories(City: Integer; var Counts: TFactoryCount);
var
  Land, Traders, Base: Cardinal;
  I, Climate, CompletedNodes: Integer;
  Pending: array[0..17] of Integer;
  procedure Walk(Head: Word; Building: Integer; Filter: Boolean);
  var
    Node: Word;
    Kind, Steps: Integer;
  begin
    Node := Head;
    Steps := 0;
    while (Node <> $FFFF) and (Steps < $FFFF) do
    begin
      Kind := ReadValue(Land + Cardinal(Node) * 8 + 3, 1);
      if (not Filter) or ((Kind > 3) and (Kind < 30)) then
      begin
        if Building = 0 then Inc(CompletedNodes);
        if (Kind >= 4) and (Kind <= 20) then
        begin
          Dec(Kind, 4);
          if (Climate = 4) and (Kind = 1) then Kind := 17;
          if Building = 1 then Inc(Pending[Kind]) else Inc(Counts[Kind,0]);
        end;
      end;
      Node := ReadValue(Land + Cardinal(Node) * 8 + 4, 2);
      Inc(Steps);
    end;
  end;
begin
  { Relevant factory-count branch of 00478150; includes construction in totals. }
  FillChar(Pending, SizeOf(Pending), 0);
  CompletedNodes := 0;
  Base := Cardinal(CityDZ[City]) + $75C;
  Land := ReadValue(Base, 4);
  Climate := ReadValue(Cardinal(CityDZ[City]) + $2CD, 1);
  Walk(ReadValue(Base + 6, 2), 1, True);
  Walk(ReadValue(Base + 8, 2), 0, True);
  Traders := ReadValue($71CE1C, 4);
  for I := 0 to ReadValue($71CE26, 1) - 1 do
  begin
    Base := Traders + Cardinal(I) * $44C + $2C4;
    if ReadValue(Base + 2, 1) = City then
    begin
      Walk(ReadValue(Base + 12, 2), 0, False);
      Walk(ReadValue(Base + 10, 2), 0, False);
    end;
  end;
  { 004784BE tests the completed chain even on the construction pass. }
  if CompletedNodes <> 0 then
    for I := 0 to 17 do
    begin
      Inc(Counts[I,0], Pending[I]);
      Inc(Counts[I,1], Pending[I]);
    end;
end;

procedure PH_init;
var I: Integer;
begin
  FrmPH.CheckListBox.Items.Clear;
  for I := 0 to CityCunt - 1 do
    FrmPH.CheckListBox.Items.Add(CityName[I]);
end;

procedure TFrmPH.ReadBalance;
var
  Counts: TFactoryCount;
  Stock, PopulationUse, ActualOut, ActualUse, Production, Materials,
    Gap, Factories, Building, FactoryGap, PGap: TGoodsCount;
  Population: array[0..3] of Integer;
  I, J, K, Good, Row: Integer;
  Value: Single;
  TotalFactories, TotalBuilding, TotalP: Int64;
begin
  { 004C0E58: daily raw units, seven-day display, independent stock column. }
  FillChar(Counts, SizeOf(Counts), 0);
  FillChar(Population, SizeOf(Population), 0);
  FillChar(FTownBalance, SizeOf(FTownBalance), 0);
  FillChar(Stock, SizeOf(Stock), 0);
  FillChar(PopulationUse, SizeOf(PopulationUse), 0);
  FillChar(ActualOut, SizeOf(ActualOut), 0);
  FillChar(ActualUse, SizeOf(ActualUse), 0);
  FillChar(Production, SizeOf(Production), 0);
  FillChar(Materials, SizeOf(Materials), 0);
  FillChar(Factories, SizeOf(Factories), 0);
  FillChar(Building, SizeOf(Building), 0);
  FillChar(FactoryGap, SizeOf(FactoryGap), 0);
  for I := 0 to CheckListBox.Items.Count - 1 do
    if CheckListBox.Checked[I] then
    begin
      Inc(Population[0], ReadValue(Cardinal(CityDZ[I]) + $2D4, 4));
      for J := 1 to 3 do
        Inc(Population[J], ReadValue(Cardinal(CityDZ[I]) + $2E4 + Cardinal(J) * 4, 4));
      CountFactories(I, Counts);
      FinalCityBalance(I,1);
      for J := 0 to 19 do
      begin
        if CheckBox1.Checked then
          Inc(FTownBalance[J], FinalBalance[J,3]+FinalBalance[J,4]);
        Inc(PopulationUse[J], FinalBalance[J,2]);
        if SwsDZ[I] > 0 then
        begin
          Inc(ActualOut[J], FinalBalance[J,8]);
          Inc(ActualUse[J], FinalBalance[J,9]);
          Inc(Stock[J], ReadValue(Cardinal(SwsDZ[I]) + 4 + Cardinal(J)*4,4));
        end;
      end;
    end;
  for I := 0 to 17 do
    if Counts[I,0] <> 0 then
    begin
      for K := 0 to 1 do
      begin
        Good := Goods[I,K];
        Value := Rates[I,K] * Counts[I,0] * 1.0996;
        if Good < 20 then
          case Good of
            0: Inc(Production[Good], Round(Value * 11 / 12));
            5,7,17: Inc(Production[Good], Round(Value * 7 / 8));
            6: ;
            10: Inc(Production[Good], Rates[I,K] * Counts[I,0]);
          else Inc(Production[Good], Round(Value));
          end;
        Good := Goods[I,K+2];
        if Good <> 255 then
          Dec(Materials[Good], Round(Rates[I,K+2] * Counts[I,0] * 1.0995));
      end;
      Factories[FactoryGoods[I]] := Counts[I,0];
      Building[FactoryGoods[I]] := Counts[I,1];
    end;
  TotalFactories := 0;
  TotalBuilding := 0;
  TotalP := 0;
  for I := 0 to 19 do
  begin
    if RG.ItemIndex = 1 then
    begin
      Production[I] := ActualOut[I];
      Materials[I] := ActualUse[I];
    end;
    Gap[I] := Production[I] + Materials[I] + PopulationUse[I] + FTownBalance[I];
    if OutputRate[I] <> 0 then
      FactoryGap[I] := Round(Gap[I] * FactoryFactor(I) / (1.0996 * OutputRate[I]));
    PGap[I] := Round(Gap[I] * PValue[I] / Get_BZLX(I));
    Inc(TotalFactories, Factories[I]);
    Inc(TotalBuilding, Building[I]);
    Inc(TotalP, PGap[I]);
    Row := sp_index(I) + 1;
    StrGid2.Cells[4,Row] := FormatFloat('0.0', Stock[I] / Get_BZLX(I));
    StrGid2.Cells[5,Row] := FormatFloat('0.0', FTownBalance[I] * 7 / Get_BZLX(I));
    StrGid2.Cells[6,Row] := FormatFloat('0.0', PopulationUse[I] * 7 / Get_BZLX(I));
    StrGid2.Cells[7,Row] := FormatFloat('0.0', Production[I] * 7 / Get_BZLX(I));
    StrGid2.Cells[8,Row] := FormatFloat('0.0', Materials[I] * 7 / Get_BZLX(I));
    StrGid2.Cells[9,Row] := FormatFloat('0.0', Gap[I] * 7 / Get_BZLX(I));
    StrGid2.Cells[10,Row] := IntToStr(FactoryGap[I]);
    StrGid2.Cells[11,Row] := IntToStr(Factories[I]);
    StrGid2.Cells[12,Row] := IntToStr(Building[I]);
    StrGid2.Cells[13,Row] := IntToStr(PGap[I]);
  end;
  StrGid2.Cells[11,21] := IntToStr(TotalFactories);
  StrGid2.Cells[12,21] := IntToStr(TotalBuilding);
  StrGid2.Cells[13,21] := IntToStr(TotalP);
  Ed1.Text := IntToStr(Population[0]);
  Ed2.Text := IntToStr(Population[1]);
  Ed3.Text := IntToStr(Population[2]);
  Ed4.Text := IntToStr(Population[3]);
  if Population[0] <> 0 then
  begin
    Ed5.Text := FormatFloat('0.0', Population[1] * 100 / Population[0]);
    Ed6.Text := FormatFloat('0.0', Population[2] * 100 / Population[0]);
    Ed7.Text := FormatFloat('0.0', Population[3] * 100 / Population[0]);
  end;
end;

procedure TFrmPH.PredictBalance;
var
  People: array[0..2] of Int64;
  Demand, Total: TGoodsCount;
  I, J, Row: Integer;
  Required: Single;
begin
  if FUpdating or (csLoading in ComponentState) then Exit;
  FUpdating := True;
  try
    { 004C1D74: integer population split and per-stratum daily consumption. }
    People[0] := Int64(Sp0.Value) * Sp1.Value div 100;
    People[1] := Int64(Sp0.Value) * Sp2.Value div 100;
    People[2] := Sp0.Value - People[0] - People[1];
    if CkB.Checked then
    begin
      Sp0.Value := StrToIntDef(Ed1.Text,0);
      People[0] := StrToIntDef(Ed2.Text,0);
      People[1] := StrToIntDef(Ed3.Text,0);
      People[2] := StrToIntDef(Ed4.Text,0);
    end;
    Sp1.Enabled := not CkB.Checked;
    Sp2.Enabled := not CkB.Checked;
    Sp3.Enabled := not CkB.Checked;
    E2.Text := IntToStr(People[0]);
    E3.Text := IntToStr(People[1]);
    E4.Text := IntToStr(People[2]);
    for I := 0 to 19 do
    begin
      Demand[I] := 0;
      for J := 0 to 2 do
        Inc(Demand[I], People[J] * Consumption[I,J] div 100);
      if (I = 9) or (I = 11) then Demand[I] := Round(Demand[I] * 1.05);
      Row := sp_index(I) + 1;
      StrGid2.Cells[1,Row] := FormatFloat('0.0', Demand[I] * 7 / Get_BZLX(I));
      Dec(Demand[I], FTownBalance[I]);
      Total[I] := Demand[I];
    end;
    { 004C21F1..004C2678: intermediate inputs are propagated in this order. }
    Total[2] := Demand[2] - Round(Demand[10] * 1499 / 810);
    Inc(Demand[4], Round((Demand[2] - Demand[10] * 1499 / 810) / 5 +
      Demand[1] / 500 * 145 * 5 / 7 + Demand[13] / 200 * 290 / 7 + Demand[10] * 15 / 81));
    Total[4] := Demand[4];
    Inc(Demand[12], Round(Demand[9] / 20));
    Total[12] := Demand[12];
    Total[0] := Demand[0] + Round(Demand[3] * 352 / 1410);
    Total[11] := Demand[11] + Round(Demand[1] * 2 / 35 + Demand[13] / 14 +
      Demand[3] * 141 / 1410 + Demand[4] * 800 / 1001 + Demand[12] + Demand[15] +
      Demand[18] * 200 / 401 + Demand[19] * 1005 / 2010);
    Total[17] := Demand[17] + Round((Demand[2] - Demand[10] * 1599 / 810) * 0.1 +
      Demand[10] * 15 / 81 + Demand[9] / 20);
    Total[14] := Demand[14] + Demand[8];
    Total[16] := Demand[16] + Demand[12];
    for I := 0 to 19 do
    begin
      Row := sp_index(I) + 1;
      StrGid2.Cells[2,Row] := FormatFloat('0.0', Total[I] * 7 / Get_BZLX(I));
      if OutputRate[I] <> 0 then
      begin
        Required := Total[I] * FactoryFactor(I) / (1.0996 * OutputRate[I]);
        StrGid2.Cells[3,Row] := FormatFloat('0.0', Required);
      end;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TFrmPH.FormCreate(Sender: TObject);
const
  Headers: array[0..13] of string = ('商品名','人口消耗','总消耗','工厂需求',
    '库存','城镇产消','人口消耗','工厂产出','工厂消耗','商品缺口','工厂缺口',
    '工厂总数','在建工厂','P值缺口');
var I: Integer;
begin
  for I := 0 to 13 do StrGid2.Cells[I,0] := Headers[I];
  StrGid2.ColWidths[0] := 80;
  StrGid2.ColWidths[14] := 25;
  for I := 0 to 19 do StrGid2.Cells[0,I+1] := '        ' + SpName[index_sp(I)];
  StrGid2.Cells[0,21] := '        合计';
end;

procedure TFrmPH.StrGid2DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Value: Extended;
  Text: string;
  OldFont, OldBrush: TColor;
  OldStyle: TBrushStyle;
begin
  if ARow = 0 then Exit;
  with StrGid2.Canvas do
  begin
    OldFont := Font.Color;
    OldBrush := Brush.Color;
    OldStyle := Brush.Style;
    try
      Brush.Style := bsSolid;
      Brush.Color := StrGid2.Color;
      Font.Color := StrGid2.Font.Color;
      if gdFixed in State then Brush.Color := StrGid2.FixedColor;
      if gdSelected in State then
      begin
        Brush.Color := clHighlight;
        Font.Color := clHighlightText;
      end;
      if (ACol > 0) and (ACol < 4) then Brush.Color := $8CB4D2;
      // VCL already drew default text before OnDrawCell. Erase that layer
      // before custom text, otherwise the different baselines leave a ghost.
      FillRect(Rect);
      Text := StrGid2.Cells[ACol,ARow];
      if (ACol > 0) and TryStrToFloat(Text, Value) then
      begin
        if Value = 0 then Text := '';
        if ((ACol = 9) or (ACol = 10) or (ACol = 13)) and (Value < 0) then Font.Color := clRed;
      end;
      TextOut(Rect.Left+2, Rect.Top+2, Text);
      if ((ACol = 0) or (ACol = 14)) and (ARow < 21) then
        Draw(Rect.Left+2, Rect.Top+2, SpBmp[index_sp(ARow-1)]);
    finally
      Font.Color := OldFont;
      Brush.Color := OldBrush;
      Brush.Style := OldStyle;
    end;
  end;
end;

procedure TFrmPH.CheckListBoxClickCheck(Sender: TObject);
var I, J: Integer; Ini: TIniFile; Section: string;
begin
  for I := 1 to StrGid2.RowCount-1 do
    for J := 1 to StrGid2.ColCount-1 do StrGid2.Cells[J,I] := '';
  Section := RadioGroup.Items[RadioGroup.ItemIndex];
  Ini := TIniFile.Create(MedConfigFileName);
  try
    for I := 0 to CheckListBox.Items.Count-1 do
      Ini.WriteString(Section, 'Q'+IntToStr(I), IntToStr(Ord(CheckListBox.Checked[I])));
  finally Ini.Free;
  end;
  ReadBalance;
  PredictBalance;
end;

procedure TFrmPH.RadioGroupClick(Sender: TObject);
var I, V: Integer; Ini: TIniFile; Section: string;
begin
  if csLoading in ComponentState then Exit;
  PH_init;
  Section := RadioGroup.Items[RadioGroup.ItemIndex];
  Ini := TIniFile.Create(MedConfigFileName);
  try
    for I := 0 to CheckListBox.Items.Count-1 do
    begin
      V := Ini.ReadInteger(Section, 'Q'+IntToStr(I), 0);
      if V in [0,1] then CheckListBox.Checked[I] := V = 1;
    end;
  finally Ini.Free;
  end;
  ReadBalance;
  PredictBalance;
end;

procedure TFrmPH.Sp1Change(Sender: TObject);
begin
  if FUpdating or (csLoading in ComponentState) or (Sp1.Text = '') then Exit;
  FUpdating := True;
  try
    Sp2.Value := 100 - Sp1.Value - Sp3.Value;
    Sp3.Value := 100 - Sp1.Value - Sp2.Value;
  finally FUpdating := False;
  end;
  PredictBalance;
end;

procedure TFrmPH.Sp2Change(Sender: TObject);
begin
  if FUpdating or (csLoading in ComponentState) or (Sp2.Text = '') then Exit;
  FUpdating := True;
  try
    Sp3.Value := 100 - Sp1.Value - Sp2.Value;
    Sp1.Value := 100 - Sp2.Value - Sp3.Value;
  finally FUpdating := False;
  end;
  PredictBalance;
end;

procedure TFrmPH.Sp3Change(Sender: TObject);
begin
  if FUpdating or (csLoading in ComponentState) or (Sp3.Text = '') then Exit;
  FUpdating := True;
  try
    Sp2.Value := 100 - Sp1.Value - Sp3.Value;
    Sp1.Value := 100 - Sp2.Value - Sp3.Value;
  finally FUpdating := False;
  end;
  PredictBalance;
end;

procedure TFrmPH.Sp0Change(Sender: TObject);
begin
  if (Sp0.Text <> '') then PredictBalance;
end;

procedure TFrmPH.Sp0KeyPress(Sender: TObject; var Key: Char);
begin
  if Sp0.Text = '' then Sp0.Value := 0;
end;

procedure TFrmPH.RGClick(Sender: TObject);
begin
  if not (csLoading in ComponentState) then ReadBalance;
end;

procedure TFrmPH.CkBClick(Sender: TObject);
begin
  PredictBalance;
end;

procedure TFrmPH.CheckBox1Click(Sender: TObject);
begin
  if not (csLoading in ComponentState) then ReadBalance;
end;

procedure TFrmPH.Button1Click(Sender: TObject);
begin
  ReadBalance;
  PredictBalance;
end;

end.
