object FrmSc: TFrmSc
  Left = 839
  Top = 170
  Align = alClient
  BorderStyle = bsNone
  Caption = #21830#21697#20648#22791
  ClientHeight = 815
  ClientWidth = 1291
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1291
    Height = 815
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 0
    object TabControl1: TTabControl
      Left = 1
      Top = 1
      Width = 1289
      Height = 813
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
        Width = 1281
        Height = 785
        Align = alClient
        Color = clBtnFace
        ColCount = 21
        DefaultColWidth = 44
        DefaultRowHeight = 22
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
        OnDrawCell = StrGidDrawCell
      end
    end
  end
end
