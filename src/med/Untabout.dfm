object FrmAbout: TFrmAbout
  Left = 2
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  Caption = #20851#20110
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
  OnCanResize = FormCanResize
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 37
    Width = 782
    Height = 485
    Align = alClient
    TabOrder = 2
    object StrGid: TStringGrid
      Left = 1
      Top = 1
      Width = 780
      Height = 483
      Align = alClient
      ColCount = 10
      DefaultColWidth = 80
      RowCount = 40
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 37
    Align = alTop
    Caption = 'P3MED  3.180927'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 9
      Top = 3
      Width = 151
      Height = 28
      Caption = #24320#22987#27604#36739
      TabOrder = 0
      OnClick = BitBtn1Click
    end
  end
  object Button1: TButton
    Left = 318
    Top = -1
    Width = 154
    Height = 35
    Caption = #36827#31243#21047#26032
    TabOrder = 1
    OnClick = Button1Click
  end
end
