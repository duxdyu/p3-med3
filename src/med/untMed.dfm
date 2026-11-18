object Form1: TForm1
  Left = 490
  Top = 272
  Width = 302
  Height = 228
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'P3Med'#21551#21160#31243#24207
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 33
    Top = 31
    Width = 72
    Height = 13
    Caption = #28216#25103#31383#21475#21517#65306
  end
  object Edit1: TEdit
    Left = 121
    Top = 28
    Width = 100
    Height = 21
    TabOrder = 0
    Text = #22823' '#33322' '#28023' '#23478' 3'
  end
  object StaBar: TStatusBar
    Left = 0
    Top = 163
    Width = 286
    Height = 27
    Panels = <
      item
        Width = 50
      end>
  end
  object Button1: TButton
    Left = 68
    Top = 80
    Width = 145
    Height = 45
    Caption = #36864#20986
    TabOrder = 2
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 240
    Top = 56
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer2Timer
    Left = 240
    Top = 112
  end
end
