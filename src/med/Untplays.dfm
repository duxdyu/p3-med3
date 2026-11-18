object FrmPlays: TFrmPlays
  Left = 712
  Top = 184
  Align = alClient
  BorderStyle = bsNone
  Caption = #31454#20105#32773
  ClientHeight = 522
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 522
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object StrGid1: TStringGrid
      Left = 1
      Top = 1
      Width = 780
      Height = 520
      Align = alClient
      Color = clBtnFace
      ColCount = 9
      DefaultColWidth = 90
      DefaultRowHeight = 20
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
      OnDrawCell = StrGid1DrawCell
    end
    object Button1: TButton
      Left = 624
      Top = 512
      Width = 109
      Height = 33
      Caption = #21047#26032
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 644
      Top = 616
      Width = 85
      Height = 33
      Caption = 'Button2'
      TabOrder = 2
      Visible = False
      OnClick = Button2Click
    end
  end
end
