object FrmImt: TFrmImt
  Left = 226
  Top = 168
  Align = alClient
  BorderStyle = bsNone
  Caption = #37325#35201#36164#35759
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
    Width = 782
    Height = 522
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object StrGid: TStringGrid
      Left = 1
      Top = 1
      Width = 780
      Height = 520
      Align = alClient
      Color = clBtnFace
      ColCount = 14
      Ctl3D = True
      DefaultColWidth = 58
      DefaultRowHeight = 25
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      ParentCtl3D = False
      TabOrder = 0
      OnDblClick = StrGidDblClick
      OnDrawCell = StrGidDrawCell
    end
  end
  object BitBtn1: TBitBtn
    Left = 896
    Top = 20
    Width = 101
    Height = 37
    Caption = 'BitBtn1'
    TabOrder = 1
    Visible = False
    OnClick = BitBtn1Click
  end
end
