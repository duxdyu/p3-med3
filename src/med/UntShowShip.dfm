object FrmShowShip: TFrmShowShip
  Left = 435
  Top = 130
  Align = alClient
  BorderStyle = bsNone
  Caption = 'FrmShowShip'
  ClientHeight = 881
  ClientWidth = 1338
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
    Top = 45
    Width = 1338
    Height = 836
    Align = alClient
    TabOrder = 0
    object StrGid: TStringGrid
      Left = 1
      Top = 1
      Width = 1336
      Height = 800
      Align = alClient
      Color = clBtnFace
      ColCount = 11
      Ctl3D = True
      DefaultColWidth = 70
      DefaultRowHeight = 18
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = StrGidDrawCell
    end
    object Panel3: TPanel
      Left = 1
      Top = 801
      Width = 1336
      Height = 34
      Align = alBottom
      Caption = 'Panel3'
      TabOrder = 1
      object StatusBar1: TStatusBar
        Left = 1
        Top = 1
        Width = 1334
        Height = 32
        Align = alClient
        Panels = <
          item
            Width = 160
          end
          item
            Width = 100
          end>
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1338
    Height = 45
    Align = alTop
    TabOrder = 1
    object CheckBox1: TCheckBox
      Left = 10
      Top = 9
      Width = 109
      Height = 19
      Caption = #26174#31034#40657#30333#33337
      TabOrder = 0
      OnClick = CheckBox1Click
    end
  end
end
