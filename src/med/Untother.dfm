object Frmother: TFrmother
  Left = 418
  Top = 160
  BorderStyle = bsNone
  Caption = #20854#23427
  ClientHeight = 522
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 392
    Top = 416
    Width = 32
    Height = 13
    Caption = 'Label8'
  end
  object BitBtn1: TBitBtn
    Left = 428
    Top = 312
    Width = 113
    Height = 49
    Caption = 'BitBtn1'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object Strtest: TStringGrid
    Left = 0
    Top = 0
    Width = 229
    Height = 522
    Align = alLeft
    ColCount = 3
    DefaultColWidth = 60
    DefaultRowHeight = 22
    RowCount = 26
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 248
    Top = 12
    Width = 337
    Height = 253
    TabOrder = 2
    object Label4: TLabel
      Left = 12
      Top = 44
      Width = 26
      Height = 13
      Caption = #28040#32791
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 12
      Top = 84
      Width = 26
      Height = 13
      Caption = #20493#37327
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 16
      Top = 116
      Width = 26
      Height = 13
      Caption = #24066#22330
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Edit2: TEdit
      Left = 56
      Top = 44
      Width = 89
      Height = 21
      TabOrder = 0
    end
    object Edit3: TEdit
      Left = 56
      Top = 80
      Width = 89
      Height = 21
      TabOrder = 1
      Text = '1'
    end
    object Edit5: TEdit
      Left = 52
      Top = 164
      Width = 89
      Height = 21
      TabOrder = 2
      Text = 'Edit5'
    end
    object Button2: TButton
      Left = 192
      Top = 40
      Width = 97
      Height = 29
      Caption = #20889#20837#24066#22330
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 44
      Top = 192
      Width = 89
      Height = 25
      Caption = #21047#26032
      TabOrder = 4
      OnClick = Button3Click
    end
    object Edit4: TEdit
      Left = 56
      Top = 112
      Width = 89
      Height = 21
      TabOrder = 5
      Text = '0'
    end
    object Button1: TButton
      Left = 192
      Top = 76
      Width = 93
      Height = 37
      Caption = #23548#20986
      TabOrder = 6
      OnClick = Button1Click
    end
    object Button4: TButton
      Left = 196
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Button4'
      TabOrder = 7
      OnClick = Button4Click
    end
  end
end
