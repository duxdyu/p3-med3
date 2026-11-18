object FrmWc: TFrmWc
  Left = 853
  Top = 151
  Align = alClient
  BorderStyle = bsNone
  Caption = #29289#20135
  ClientHeight = 737
  ClientWidth = 1170
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
    Width = 1170
    Height = 737
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 1168
      Height = 36
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 344
        Top = 8
        Width = 168
        Height = 16
        Caption = #29289'                 '#20135
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object Button1: TButton
        Left = 865
        Top = 2
        Width = 115
        Height = 35
        Caption = 'Button1'
        TabOrder = 0
        Visible = False
        OnClick = Button1Click
      end
    end
    object StrGid: TStringGrid
      Left = 1
      Top = 37
      Width = 1168
      Height = 699
      Align = alClient
      Color = clBtnFace
      ColCount = 24
      DefaultColWidth = 38
      RowCount = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ParentFont = False
      TabOrder = 1
      OnDblClick = StrGidDblClick
      OnDrawCell = StrGidDrawCell
    end
  end
end
