object FrmJS: TFrmJS
  Left = 453
  Top = 145
  BorderStyle = bsNone
  Caption = #20891#20107
  ClientHeight = 690
  ClientWidth = 1006
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
  object Button1: TButton
    Left = 617
    Top = 8
    Width = 89
    Height = 25
    Caption = #21047#26032
    TabOrder = 0
    Visible = False
    OnClick = Button1Click
  end
  object StrGid: TStringGrid
    Left = 0
    Top = 0
    Width = 1006
    Height = 690
    Align = alClient
    Color = clBtnFace
    ColCount = 10
    DefaultColWidth = 70
    DefaultRowHeight = 25
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ParentFont = False
    TabOrder = 1
    OnDrawCell = StrGidDrawCell
  end
end
