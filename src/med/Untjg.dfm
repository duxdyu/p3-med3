object FrmJg: TFrmJg
  Left = 1052
  Top = 395
  Align = alClient
  BorderStyle = bsNone
  Caption = 'FrmJg'
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
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 522
    Align = alClient
    TabOrder = 0
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 780
      Height = 489
      Align = alClient
      TabOrder = 0
      object Panel1: TPanel
        Left = 1
        Top = 1
        Width = 552
        Height = 487
        Align = alLeft
        TabOrder = 0
        object StrGidLW: TStringGrid
          Left = 1
          Top = 333
          Width = 550
          Height = 153
          Align = alClient
          Color = clBtnFace
          ColCount = 6
          Ctl3D = False
          DefaultColWidth = 80
          DefaultRowHeight = 18
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
          ParentCtl3D = False
          TabOrder = 0
          OnClick = StrGidLWClick
        end
        object memo1: TMemo
          Left = 1
          Top = 1
          Width = 550
          Height = 332
          Align = alTop
          Color = clScrollBar
          Ctl3D = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMenuText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 1
        end
      end
      object Panel2: TPanel
        Left = 553
        Top = 1
        Width = 417
        Height = 487
        Align = alLeft
        TabOrder = 1
        object GroupBox1: TGroupBox
          Left = 1
          Top = 79
          Width = 415
          Height = 407
          Align = alClient
          Caption = #33337#38271
          TabOrder = 0
          object StrGidCz: TStringGrid
            Left = 2
            Top = 15
            Width = 411
            Height = 390
            Align = alClient
            Color = clBtnFace
            Ctl3D = False
            DefaultColWidth = 60
            DefaultRowHeight = 18
            RowCount = 30
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
            ParentCtl3D = False
            TabOrder = 0
            OnDblClick = StrGidCzDblClick
            RowHeights = (
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18
              18)
          end
        end
        object Panel4: TPanel
          Left = 1
          Top = 1
          Width = 415
          Height = 78
          Align = alTop
          TabOrder = 1
          object Button2: TButton
            Left = 285
            Top = 19
            Width = 101
            Height = 29
            Caption = #31354#33337#25307#28385#27700#25163
            TabOrder = 0
            OnClick = Button2Click
          end
          object ComBox1: TComboBox
            Left = 12
            Top = 20
            Width = 93
            Height = 21
            ItemHeight = 13
            TabOrder = 1
            Text = #36873#25321#30446#30340#28207#21475
            OnChange = ComBox1Change
          end
          object Button3: TButton
            Left = 144
            Top = 16
            Width = 101
            Height = 29
            Caption = #31354#38386#33337#36716#31227
            TabOrder = 2
            OnClick = Button3Click
          end
          object Button1: TButton
            Left = 17
            Top = 45
            Width = 89
            Height = 25
            Caption = #20219#21153
            TabOrder = 3
            Visible = False
            OnClick = Button1Click
          end
          object BitBtn1: TBitBtn
            Left = 254
            Top = 52
            Width = 81
            Height = 25
            Caption = #33337#38271
            TabOrder = 4
            Visible = False
            OnClick = BitBtn1Click
          end
          object Button4: TButton
            Left = 320
            Top = 52
            Width = 81
            Height = 25
            Caption = 'Button4'
            TabOrder = 5
            Visible = False
            OnClick = Button4Click
          end
        end
      end
    end
    object StaBar: TStatusBar
      Left = 1
      Top = 490
      Width = 780
      Height = 31
      Panels = <
        item
          Width = 200
        end
        item
          Width = 200
        end>
    end
  end
end
