object FrmPH: TFrmPH
  Left = 226
  Top = 138
  BorderStyle = bsNone
  Caption = #21306#22495#24179#34913
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
    Width = 105
    Height = 522
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
    object RadioGroup: TRadioGroup
      Left = 1
      Top = 1
      Width = 103
      Height = 184
      Align = alTop
      Caption = #21306#22495#35268#21010
      ItemIndex = 0
      Items.Strings = (
        #19996#21306
        #20013#21306
        #35199#21306
        #20854#23427)
      TabOrder = 0
      OnClick = RadioGroupClick
    end
    object CheckListBox: TCheckListBox
      Left = 1
      Top = 185
      Width = 103
      Height = 336
      OnClickCheck = CheckListBoxClickCheck
      Align = alClient
      Color = clBtnFace
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = #23435#20307
      Font.Style = []
      ItemHeight = 15
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 105
    Top = 0
    Width = 677
    Height = 522
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 675
      Height = 176
      Align = alTop
      TabOrder = 0
      object Panel5: TPanel
        Left = 1
        Top = 1
        Width = 918
        Height = 174
        Align = alLeft
        Caption = 'Panel5'
        TabOrder = 0
        object Panel6: TPanel
          Left = 1
          Top = 1
          Width = 276
          Height = 172
          Align = alLeft
          TabOrder = 0
          object Label7: TLabel
            Left = 28
            Top = 12
            Width = 52
            Height = 13
            Caption = #24635#20154#21475#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label8: TLabel
            Left = 28
            Top = 40
            Width = 53
            Height = 13
            Caption = #23500'  '#35946#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label9: TLabel
            Left = 28
            Top = 68
            Width = 53
            Height = 13
            Caption = #23500'  '#20154#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label10: TLabel
            Left = 28
            Top = 96
            Width = 53
            Height = 13
            Caption = #31351'  '#20154#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label11: TLabel
            Left = 178
            Top = 8
            Width = 59
            Height = 13
            Caption = #20154#21475#27604#20363'%'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object E4: TEdit
            Left = 88
            Top = 92
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 0
            Text = 'E4'
          end
          object E3: TEdit
            Left = 88
            Top = 64
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 1
            Text = 'E3'
          end
          object E2: TEdit
            Left = 88
            Top = 36
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 2
            Text = 'E2'
          end
          object Sp1: TSpinEdit
            Left = 179
            Top = 35
            Width = 61
            Height = 22
            Ctl3D = False
            EditorEnabled = False
            MaxValue = 100
            MinValue = 0
            ParentCtl3D = False
            TabOrder = 3
            Value = 12
            OnChange = Sp1Change
          end
          object Sp2: TSpinEdit
            Left = 179
            Top = 63
            Width = 61
            Height = 22
            Ctl3D = False
            EditorEnabled = False
            MaxValue = 100
            MinValue = 0
            ParentCtl3D = False
            TabOrder = 4
            Value = 20
            OnChange = Sp2Change
          end
          object Sp3: TSpinEdit
            Left = 179
            Top = 91
            Width = 61
            Height = 22
            Ctl3D = False
            EditorEnabled = False
            MaxValue = 100
            MinValue = 0
            ParentCtl3D = False
            TabOrder = 5
            Value = 68
            OnChange = Sp3Change
          end
          object Panel7: TPanel
            Left = 1
            Top = 136
            Width = 274
            Height = 35
            Align = alBottom
            Caption = #24037' '#21378' '#35745' '#31639' '#22120
            Color = clSkyBlue
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = #23435#20307
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 6
          end
          object CkB: TCheckBox
            Left = 88
            Top = 116
            Width = 121
            Height = 13
            Caption = #20351#29992#24403#21069#20154#21475
            TabOrder = 7
            OnClick = CkBClick
          end
          object Sp0: TSpinEdit
            Left = 84
            Top = 8
            Width = 73
            Height = 22
            Increment = 1000
            MaxLength = 7
            MaxValue = 9999999
            MinValue = 0
            TabOrder = 8
            Value = 1000000
            OnChange = Sp0Change
            OnKeyPress = Sp0KeyPress
          end
        end
        object Panel4: TPanel
          Left = 277
          Top = 1
          Width = 640
          Height = 172
          Align = alClient
          TabOrder = 1
          object Label2: TLabel
            Left = 28
            Top = 12
            Width = 52
            Height = 13
            Caption = #24635#20154#21475#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label3: TLabel
            Left = 28
            Top = 40
            Width = 53
            Height = 13
            Caption = #23500'  '#35946#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label4: TLabel
            Left = 28
            Top = 68
            Width = 53
            Height = 13
            Caption = #23500'  '#20154#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label5: TLabel
            Left = 28
            Top = 96
            Width = 53
            Height = 13
            Caption = #31351'  '#20154#65306
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Label6: TLabel
            Left = 178
            Top = 8
            Width = 59
            Height = 13
            Caption = #20154#21475#27604#20363'%'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
          end
          object Ed4: TEdit
            Left = 88
            Top = 92
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 0
            Text = '0'
          end
          object Ed3: TEdit
            Left = 88
            Top = 64
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 1
            Text = '0'
          end
          object Ed2: TEdit
            Left = 88
            Top = 36
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 2
            Text = '0'
          end
          object Ed1: TEdit
            Left = 88
            Top = 8
            Width = 69
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 3
            Text = '0'
          end
          object Ed5: TEdit
            Left = 180
            Top = 36
            Width = 61
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 4
            Text = '0'
          end
          object Ed6: TEdit
            Left = 180
            Top = 64
            Width = 61
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 5
            Text = '0'
          end
          object Ed7: TEdit
            Left = 180
            Top = 92
            Width = 61
            Height = 19
            Color = clGradientActiveCaption
            Ctl3D = False
            Enabled = False
            ParentCtl3D = False
            TabOrder = 6
            Text = '0'
          end
          object Panel10: TPanel
            Left = 1
            Top = 136
            Width = 638
            Height = 35
            Align = alBottom
            Caption = #22478'  '#24066' '#20379' '#38656
            Color = clSkyBlue
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = #23435#20307
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 7
          end
          object RG: TRadioGroup
            Left = 264
            Top = 8
            Width = 121
            Height = 109
            Caption = #32479#35745#26041#24335
            ItemIndex = 0
            Items.Strings = (
              #25353#24037#21378#35745#31639
              #25353#23454#38469#20135#33021)
            TabOrder = 8
            OnClick = RGClick
          end
          object CheckBox1: TCheckBox
            Left = 392
            Top = 14
            Width = 119
            Height = 23
            Caption = #22478#38215#33258#20135#28040
            Checked = True
            State = cbChecked
            TabOrder = 9
            OnClick = CheckBox1Click
          end
        end
      end
    end
    object StrGid2: TStringGrid
      Left = 1
      Top = 177
      Width = 675
      Height = 568
      Align = alTop
      BorderStyle = bsNone
      Color = clBtnFace
      ColCount = 15
      Ctl3D = False
      DefaultColWidth = 60
      DefaultRowHeight = 23
      FixedCols = 0
      RowCount = 22
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ParentCtl3D = False
      TabOrder = 1
      OnDrawCell = StrGid2DrawCell
    end
  end
end
