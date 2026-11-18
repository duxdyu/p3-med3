object FrmDk: TFrmDk
  Left = 1072
  Top = 325
  Align = alClient
  BorderStyle = bsNone
  Caption = #20511#36151
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
  object Panel3: TPanel
    Left = 0
    Top = 33
    Width = 782
    Height = 489
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 0
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 780
      Height = 449
      Align = alClient
      Caption = 'Panel1'
      TabOrder = 0
      object StrGid1: TStringGrid
        Left = 1
        Top = 1
        Width = 480
        Height = 447
        Align = alLeft
        Color = clBtnFace
        ColCount = 6
        DefaultColWidth = 60
        DefaultRowHeight = 20
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
      object StrGid2: TStringGrid
        Left = 481
        Top = 1
        Width = 298
        Height = 447
        Align = alClient
        Color = clBtnFace
        ColCount = 6
        DefaultColWidth = 100
        DefaultRowHeight = 20
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 1
        OnDblClick = StrGid2DblClick
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 450
      Width = 780
      Height = 38
      Align = alBottom
      TabOrder = 1
      object StatusBar1: TStatusBar
        Left = 1
        Top = 1
        Width = 480
        Height = 36
        Align = alLeft
        Panels = <
          item
            Width = 50
          end>
      end
      object Panel7: TPanel
        Left = 481
        Top = 1
        Width = 298
        Height = 36
        Align = alClient
        TabOrder = 1
        object Label1: TLabel
          Left = 112
          Top = 12
          Width = 36
          Height = 13
          Caption = #21033#29575#65306
        end
        object Button2: TButton
          Left = 356
          Top = 4
          Width = 81
          Height = 29
          Caption = #21047#26032
          TabOrder = 0
          Visible = False
          OnClick = Button2Click
        end
        object Button1: TButton
          Left = 16
          Top = 3
          Width = 81
          Height = 29
          Caption = #19968#38190#25918#36151
          TabOrder = 1
          OnClick = Button1Click
        end
        object ComBox: TComboBox
          Left = 152
          Top = 8
          Width = 73
          Height = 21
          ItemHeight = 13
          TabOrder = 2
          Text = '2.0%'
          OnChange = ComBoxChange
          Items.Strings = (
            '1.7%'
            '2.0%'
            '2.2%')
        end
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 33
    Align = alTop
    TabOrder = 1
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 484
      Height = 31
      Align = alLeft
      Caption = #36151#27454#38656#27714
      TabOrder = 0
    end
    object Panel6: TPanel
      Left = 485
      Top = 1
      Width = 296
      Height = 31
      Align = alClient
      Caption = #30830#35748#36151#27454
      TabOrder = 1
      object Panel8: TPanel
        Left = 1
        Top = 1
        Width = 316
        Height = 29
        Align = alLeft
        Caption = 'Panel8'
        TabOrder = 0
        Visible = False
        object Label2: TLabel
          Left = 69
          Top = 8
          Width = 140
          Height = 13
          AutoSize = False
          Caption = #24180'               '#26376'             '#26085
        end
        object Edit1: TEdit
          Left = 4
          Top = 4
          Width = 61
          Height = 21
          TabOrder = 0
          Text = '1300'
        end
        object Edit2: TEdit
          Left = 88
          Top = 4
          Width = 29
          Height = 21
          TabOrder = 1
          Text = '8'
        end
        object Edit3: TEdit
          Left = 144
          Top = 4
          Width = 29
          Height = 21
          TabOrder = 2
          Text = '20'
        end
        object Button3: TButton
          Left = 219
          Top = 4
          Width = 93
          Height = 25
          Caption = 'Button3'
          TabOrder = 3
          OnClick = Button3Click
        end
      end
    end
  end
end
