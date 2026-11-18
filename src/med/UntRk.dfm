object FrmRk: TFrmRk
  Left = 848
  Top = 286
  Align = alClient
  BorderStyle = bsNone
  Caption = 'FrmRk'
  ClientHeight = 626
  ClientWidth = 891
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
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 891
    Height = 626
    Align = alClient
    Caption = 'Panel4'
    TabOrder = 0
    object Image1: TImage
      Left = 760
      Top = 184
      Width = 41
      Height = 41
    end
    object StrGid: TStringGrid
      Left = 1
      Top = 1
      Width = 889
      Height = 624
      Align = alClient
      Color = clBtnFace
      ColCount = 12
      DefaultColWidth = 75
      DefaultRowHeight = 22
      RowCount = 2
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnDblClick = StrGidDblClick
      OnDrawCell = StrGidDrawCell
    end
    object Button1: TButton
      Left = 952
      Top = 126
      Width = 105
      Height = 34
      Caption = #21047#26032
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
  end
end
