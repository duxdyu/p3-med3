unit Untimt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Untpublic, Buttons, Grids, ExtCtrls, Math, MedCityEventUI;

type
  TFrmImt = class(TForm)
    Panel1: TPanel;
    StrGid: TStringGrid;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure StrGidDblClick(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    CaptainSkill: array[0..39,0..2] of Byte;
    HasCaptain: array[0..39] of Boolean;
    CityIcon: array[0..39] of Byte;
    CityEvents: TMedCityEventView;
  end;

var
  FrmImt: TFrmImt;

implementation

{$R *.dfm}

// Projection of 00478150 onto the three housing occupancy results used here.
// Houses are counted from city and office building chains, not the old +$2F8
// capacity fields. The final helper uses 8/14/28 residents per ten houses.
function HousingOccupancy(ACity: Byte): Integer;
const
  Capacity: array[0..2] of Byte = (8,14,28);
var
  Counts: array[0..1,0..2] of Word;
  Buildings, OfficeBase, DZ, I, J, Residents, Rate, FirstListCount: Integer;
  OfficeCount, OfficeCity, Kind: Byte;
  Index: Word;

  procedure CountChain(HeadAddress, Group: Integer; Filter: Boolean);
  begin
    ReadProcessMemory(GHandle,Pointer(HeadAddress),@Index,2,tmpNum);
    while Index<>$FFFF do
    begin
      DZ:=Buildings+Index*8;
      ReadProcessMemory(GHandle,Pointer(DZ+3),@Kind,1,tmpNum);
      if (not Filter) or ((Kind>3) and (Kind<30)) then
      begin
        if Group=0 then Inc(FirstListCount);
        case Kind of
          21..23: Inc(Counts[Group,0]);
          24..26: Inc(Counts[Group,1]);
          27..29: Inc(Counts[Group,2]);
        end;
      end;
      ReadProcessMemory(GHandle,Pointer(DZ+4),@Index,2,tmpNum);
    end;
  end;

begin
  FillChar(Counts,SizeOf(Counts),0);
  FirstListCount:=0;
  ReadProcessMemory(GHandle,Pointer(CityDZ[ACity]+$75C),@Buildings,4,tmpNum);
  CountChain(CityDZ[ACity]+$762,1,True);
  CountChain(CityDZ[ACity]+$764,0,True);
  // The shipped helper reads one byte, even though SWSCunt is a Word elsewhere.
  ReadProcessMemory(GHandle,Pointer($71CE26),@OfficeCount,1,tmpNum);
  ReadProcessMemory(GHandle,Pointer($71CE1C),@OfficeBase,4,tmpNum);
  for I:=0 to Integer(OfficeCount)-1 do
  begin
    ReadProcessMemory(GHandle,Pointer(OfficeBase+I*$44C+$2C6),@OfficeCity,1,tmpNum);
    if OfficeCity<>ACity then Continue;
    CountChain(OfficeBase+I*$44C+$2D0,0,False);
    CountChain(OfficeBase+I*$44C+$2CE,0,False);
  end;
  // 004784BE gates both groups on list zero being nonempty.
  if FirstListCount=0 then FillChar(Counts,SizeOf(Counts),0);
  Result:=0;
  for J:=0 to 2 do
  begin
    ReadProcessMemory(GHandle,Pointer(CityDZ[ACity]+$2D8+J*4),@Residents,4,tmpNum);
    if Counts[0,J]+Counts[1,J]=0 then Rate:=100
    else Rate:=Residents*10 div ((Counts[0,J]+Counts[1,J])*Capacity[J]);
    Rate:=Word(Rate);
    if Rate>Result then Result:=Rate;
  end;
end;

// 00477EB8: signed custom 16-bit quantity to the final two-decimal display.
function ReputationText(Value: SmallInt): string;
var
  Exponent, Fraction: SmallInt;
  Base, Scale, Part, Decoded: Single;
begin
  Decoded:=0;
  if Value>0 then
  begin
    Value:=SmallInt(Word(Value)-$3C00);
    if Value<0 then Value:=0;
    Fraction:=Value mod 128;
    Exponent:=Value div 128;
    Base:=Power(2,-7);
    Scale:=Power(2,Exponent-8);
    Part:=(Fraction/128)*Power(2,Exponent-7);
    Decoded:=2*Scale-Base+Part;
  end;
  if Value<0 then
  begin
    Value:=SmallInt(Word(Value)-$BC00);
    if Value<0 then Value:=0;
    Fraction:=Value mod 128;
    Exponent:=Value div 128;
    Base:=Power(2,-8);
    Scale:=Power(2,Exponent-8);
    Part:=(Fraction/128)*Power(2,Exponent-7);
    Decoded:=-(2*Scale-Base+Part);
  end;
  Result:=FormatFloat('0.00',Decoded);
end;

procedure TFrmImt.FormCreate(Sender: TObject);
const
  Headers: array[0..13] of string = ('城市','船长','满意度','房屋','水井',
    '道路','礼拜堂','医院','原材料','状态','战争[天]','永久','公众','贸易');
var
  I: Integer;
  HomeCity: Byte;
begin
  ReadProcessMemory(GHandle,Pointer(PlaysJZ+(Player-1)*$650+$18),@HomeCity,1,tmpNum);
  for I:=0 to 39 do
  begin
    CityIcon[I]:=23;
    if SWSDZ[I]<>0 then CityIcon[I]:=24;
    if HomeCity=I then CityIcon[I]:=25;
  end;
  for I:=0 to 13 do StrGid.Cells[I,0]:=Headers[I];
  StrGid.ColWidths[1]:=150;
  StrGid.ColWidths[0]:=100;
   StrGid.ColWidths[3]:=48;
   StrGid.ColWidths[4]:=48;
   StrGid.ColWidths[5]:=48;
   StrGid.ColWidths[9]:=120;
   StrGid.ColWidths[10]:=70;
   CityEvents:=TMedCityEventView.CreateFor(Self,StrGid);
end;

// 004C41A4; register/stack operands checked against the PE instructions.
procedure TFrmImt.BitBtn1Click(Sender: TObject);
var
  I, J, DZ, Population, Required, Rate, CaptainBase, PlayerBase: Integer;
  Satisfaction, Reputation: SmallInt;
  RoadDone, RoadTotal, Captain: Word;
  C, C1, C2, HomeCity: Byte;
begin
  FillChar(HasCaptain,SizeOf(HasCaptain),0);
  PlayerBase:=PlaysJZ+(Player-1)*$650;
  ReadProcessMemory(GHandle,Pointer(PlayerBase+$18),@HomeCity,1,tmpNum);
  ReadProcessMemory(GHandle,Pointer($6DFB88),@CaptainBase,4,tmpNum);
  StrGid.RowCount:=CityCunt+1;
  for I:=0 to CityCunt-1 do
  begin
    CityIcon[I]:=23;
    if SWSDZ[I]<>0 then CityIcon[I]:=24;
    if HomeCity=I then CityIcon[I]:=25;
    StrGid.Cells[0,I+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$304),@Satisfaction,2,tmpNum);
    if Satisfaction<=10 then StrGid.Cells[2,I+1]:=IntToStr(Satisfaction)
    else StrGid.Cells[2,I+1]:='';
    Rate:=HousingOccupancy(I);
    if Rate>90 then StrGid.Cells[3,I+1]:=IntToStr(Rate)+'%'
    else StrGid.Cells[3,I+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$2D4),@Population,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$770),@C,1,tmpNum);
    Required:=Round(Population/10000);
    if C<Required then StrGid.Cells[6,I+1]:=IntToStr(C)+'/'+IntToStr(Required)
    else StrGid.Cells[6,I+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$772),@C,1,tmpNum);
    Required:=Ceil(Population/10000);
    if C<Required then StrGid.Cells[7,I+1]:=IntToStr(C)+'/'+IntToStr(Required)
    else StrGid.Cells[7,I+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$789),@C,1,tmpNum);
    StrGid.Cells[4,I+1]:='';
    if Population<>0 then
    begin
      Rate:=C*50000 div Population;
      if Rate<80 then StrGid.Cells[4,I+1]:=IntToStr(Rate)+'%';
    end;
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$790),@RoadDone,2,tmpNum);
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$792),@RoadTotal,2,tmpNum);
    StrGid.Cells[5,I+1]:='';
    if RoadTotal<>0 then
    begin
      RoadDone:=RoadDone*100 div RoadTotal;
      if RoadDone<80 then StrGid.Cells[5,I+1]:=IntToStr(RoadDone)+'%';
    end;
    StrGid.Cells[8,I+1]:='';
    if SWSDZ[I]>0 then
    begin
      ReadProcessMemory(GHandle,Pointer(SWSDZ[I]+2),@C,1,tmpNum);
      if C=1 then StrGid.Cells[8,I+1]:='缺';
    end;
    StrGid.Cells[9,I+1]:='';
  end;
  for I:=0 to CityCunt-1 do
  begin
    StrGid.Cells[1,I+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[I]+$82E),@Captain,2,tmpNum);
    if Captain=$FFFF then Continue;
    repeat
      DZ:=CaptainBase+Captain*16;
      ReadProcessMemory(GHandle,Pointer(DZ+8),@C,1,tmpNum);
      ReadProcessMemory(GHandle,Pointer(DZ),@Captain,2,tmpNum);
    until (Captain=$FFFF) or (C<31);
    if C>31 then Continue;
    for J:=0 to 2 do
    begin
      ReadProcessMemory(GHandle,Pointer(DZ+9+J),@C,1,tmpNum);
      CaptainSkill[I,J]:=C div 50;
    end;
    HasCaptain[I]:=True;
  end;
  for I:=0 to CityCunt-1 do
    for J:=0 to 2 do
    begin
      ReadProcessMemory(GHandle,Pointer(PlayerBase+$11E+I*12+J*4),@Reputation,2,tmpNum);
      StrGid.Cells[11+J,I+1]:=ReputationText(Reputation);
    end;
  if Assigned(CityEvents) then CityEvents.Refresh;
  StrGid.Invalidate;
end;

procedure TFrmImt.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  J: Integer;
begin
  if ARow=0 then Exit;
  with StrGid.Canvas do
  begin
    if gdSelected in State then Brush.Color:=clHighlight;
    case ACol of
      0: begin
        Draw(Rect.Left+2,Rect.Top+2,SpBmp[CityIcon[ARow-1]]);
        TextOut(Rect.Left+25,Rect.Top+5,CityName[ARow-1]);
      end;
      1: if HasCaptain[ARow-1] then
      begin
        for J:=0 to 2 do Draw(Rect.Left+5+J*50,Rect.Top+2,SpBmp[26+J]);
        TextOut(Rect.Left+28,Rect.Top+5,IntToStr(CaptainSkill[ARow-1,1]));
        TextOut(Rect.Left+78,Rect.Top+5,IntToStr(CaptainSkill[ARow-1,0]));
        TextOut(Rect.Left+128,Rect.Top+5,IntToStr(CaptainSkill[ARow-1,2]));
      end;
      9: if Assigned(CityEvents) then CityEvents.Draw(ARow,Rect,State);
      11..13: if StrToFloatDef(StrGid.Cells[ACol,ARow],0)<0 then
      begin
        Brush.Style:=bsSolid;
        if gdSelected in State then Brush.Color:=clHighlight
        else Brush.Color:=StrGid.Color;
        FillRect(Rect);
        Font.Color:=clRed;
        TextOut(Rect.Left+2,Rect.Top+2,StrGid.Cells[ACol,ARow]);
        Font.Color:=StrGid.Font.Color;
      end;
    end;
  end;
end;

procedure TFrmImt.StrGidDblClick(Sender: TObject);
begin
  // State edits now require selecting a specific icon's context-menu action.
end;

end.
