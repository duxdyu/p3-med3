object FrmJT: TFrmJT
  Left = 497
  Top = 420
  Align = alClient
  BorderStyle = bsNone
  Caption = #20854#23427
  ClientHeight = 640
  ClientWidth = 921
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
    Width = 689
    Height = 640
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
    object StrGid: TStringGrid
      Left = 1
      Top = 35
      Width = 687
      Height = 604
      Align = alClient
      Color = clBtnFace
      ColCount = 8
      RowCount = 41
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
      OnClick = StrGidClick
      OnDrawCell = StrGidDrawCell
    end
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 687
      Height = 34
      Align = alTop
      Caption = #25945#22530
      TabOrder = 1
      object Button2: TButton
        Left = 0
        Top = 4
        Width = 129
        Height = 29
        Caption = #25193#24314#25945#22530
        TabOrder = 0
        OnClick = Button2Click
      end
      object Button1: TButton
        Left = 581
        Top = 0
        Width = 73
        Height = 29
        Caption = #21047#26032
        TabOrder = 1
        Visible = False
        OnClick = Button1Click
      end
    end
  end
  object Panel2: TPanel
    Left = 689
    Top = 0
    Width = 232
    Height = 640
    Align = alClient
    TabOrder = 1
    Visible = False
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 253
      Height = 638
      Align = alLeft
      TabOrder = 0
    end
  end
end
