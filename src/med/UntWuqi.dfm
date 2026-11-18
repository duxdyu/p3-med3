object FrmWuqi: TFrmWuqi
  Left = 510
  Top = 208
  BorderStyle = bsNone
  Caption = #27494#22120
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
  PixelsPerInch = 96
  TextHeight = 13
  object TabControl1: TTabControl
    Left = 0
    Top = 0
    Width = 782
    Height = 522
    Align = alClient
    TabOrder = 0
    Tabs.Strings = (
      #24066#22330
      #20107#21153#25152)
    TabIndex = 0
    OnChange = TabControl1Change
    object StrGid: TStringGrid
      Left = 4
      Top = 24
      Width = 774
      Height = 494
      Align = alClient
      Color = clBtnFace
      ColCount = 12
      DefaultRowHeight = 25
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
      OnDrawCell = StrGidDrawCell
    end
    object Button1: TButton
      Left = 795
      Top = 33
      Width = 112
      Height = 40
      Caption = 'Button1'
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
  end
end
