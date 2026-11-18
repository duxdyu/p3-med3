object FrmSWS: TFrmSWS
  Left = 282
  Top = 177
  Align = alClient
  BorderStyle = bsNone
  Caption = #20107#21153#25152
  ClientHeight = 771
  ClientWidth = 1448
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
    Width = 897
    Height = 771
    Align = alLeft
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 49
      Width = 895
      Height = 721
      Align = alClient
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      object Panel3: TPanel
        Left = 1
        Top = 1
        Width = 893
        Height = 500
        Align = alTop
        Caption = 'Panel3'
        TabOrder = 0
        object StrGid: TStringGrid
          Left = 1
          Top = 1
          Width = 588
          Height = 498
          Align = alLeft
          Color = clBtnFace
          ColCount = 8
          Ctl3D = True
          DefaultColWidth = 60
          DefaultRowHeight = 22
          RowCount = 21
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          OnDrawCell = StrGidDrawCell
          OnKeyUp = StrGidKeyUp
          OnMouseDown = StrGidMouseDown
          OnMouseUp = StrGidMouseUp
        end
        object Button10: TButton
          Left = 125
          Top = 3
          Width = 60
          Height = 22
          Caption = '<--->'
          Font.Charset = GB2312_CHARSET
          Font.Color = clRed
          Font.Height = -16
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = Button10Click
        end
        object StrGid2: TStringGrid
          Left = 589
          Top = 1
          Width = 237
          Height = 498
          Align = alLeft
          Color = clBtnFace
          ColCount = 3
          Ctl3D = True
          DefaultColWidth = 76
          DefaultRowHeight = 22
          FixedCols = 0
          RowCount = 21
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
          ParentCtl3D = False
          ScrollBars = ssNone
          TabOrder = 2
          OnSetEditText = StrGid2SetEditText
        end
      end
      object Panel5: TPanel
        Left = 1
        Top = 501
        Width = 893
        Height = 140
        Align = alTop
        TabOrder = 1
        object GroupBox1: TGroupBox
          Left = 588
          Top = 1
          Width = 233
          Height = 138
          Caption = #20215#26684#27169#26495
          TabOrder = 0
          object RadGroup: TRadioGroup
            Left = 1
            Top = 14
            Width = 231
            Height = 52
            Align = alTop
            Columns = 2
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ItemIndex = 0
            Items.Strings = (
              #27169#26495'1'
              #27169#26495'2')
            ParentFont = False
            TabOrder = 0
            OnClick = RadGroupClick
          end
          object Button11: TButton
            Left = 9
            Top = 75
            Width = 77
            Height = 29
            Caption = #24212#29992#20215#26684
            TabOrder = 1
            OnClick = Button11Click
          end
        end
        object GroupBox4: TGroupBox
          Left = 1
          Top = 1
          Width = 236
          Height = 138
          Align = alLeft
          Caption = #20107#21153#25152#24037#21378#26448#26009#38145#23450
          TabOrder = 1
          object Label1: TLabel
            Left = 32
            Top = 24
            Width = 92
            Height = 13
            Caption = #24037#21378#26448#26009'['#22825']'#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object SpinEdit1: TSpinEdit
            Left = 147
            Top = 20
            Width = 66
            Height = 22
            EditorEnabled = False
            MaxValue = 0
            MinValue = 0
            TabOrder = 0
            Value = 7
            OnChange = SpinEdit1Change
          end
          object Button6: TButton
            Left = 63
            Top = 92
            Width = 98
            Height = 29
            Caption = #19968#38190#38145#23450
            TabOrder = 1
            OnClick = Button6Click
          end
        end
        object GroupBox2: TGroupBox
          Left = 237
          Top = 1
          Width = 244
          Height = 138
          Align = alLeft
          TabOrder = 2
          Visible = False
          object Button1: TButton
            Left = 16
            Top = 16
            Width = 81
            Height = 33
            Caption = #26234#33021#37319#36141
            TabOrder = 0
            OnClick = Button1Click
          end
          object Spin: TSpinEdit
            Left = 110
            Top = 20
            Width = 63
            Height = 22
            MaxValue = 10
            MinValue = 1
            TabOrder = 1
            Value = 2
          end
        end
      end
      object StaBar: TStatusBar
        Left = 1
        Top = 686
        Width = 893
        Height = 34
        Panels = <
          item
            Width = 200
          end
          item
            Width = 50
          end>
      end
    end
    object Panel7: TPanel
      Left = 1
      Top = 1
      Width = 895
      Height = 48
      Align = alTop
      TabOrder = 1
      object Button3: TButton
        Left = 477
        Top = 4
        Width = 68
        Height = 33
        Caption = '>'
        TabOrder = 0
        OnClick = Button3Click
      end
      object ComBox: TComboBox
        Left = 324
        Top = 12
        Width = 129
        Height = 21
        ItemHeight = 13
        TabOrder = 1
        Text = 'ComBox'
        OnChange = ComBoxChange
      end
      object Button2: TButton
        Left = 236
        Top = 4
        Width = 66
        Height = 33
        Caption = '<'
        TabOrder = 2
        OnClick = Button2Click
      end
    end
  end
  object StrGid1: TStringGrid
    Left = 897
    Top = 0
    Width = 551
    Height = 771
    Align = alClient
    ColCount = 6
    RowCount = 100
    TabOrder = 1
    Visible = False
    OnClick = StrGid1Click
  end
  object Button5: TButton
    Left = 1160
    Top = -4
    Width = 165
    Height = 37
    Caption = 'Button5'
    TabOrder = 2
    Visible = False
    OnClick = Button5Click
  end
end
