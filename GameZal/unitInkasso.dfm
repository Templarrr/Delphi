object formInkasso: TformInkasso
  Left = 447
  Top = 352
  Width = 377
  Height = 165
  AutoSize = True
  BorderWidth = 5
  Caption = #1048#1085#1082#1072#1089#1089#1072#1094#1080#1103
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 0
    Top = 32
    Width = 58
    Height = 24
    Caption = #1057#1091#1084#1084#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 0
    Top = 64
    Width = 124
    Height = 24
    Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 0
    Top = 0
    Width = 64
    Height = 24
    Caption = #1057#1090#1072#1090#1100#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 184
    Top = 0
    Width = 105
    Height = 24
    Caption = #1048#1085#1082#1072#1089#1089#1072#1094#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Button1: TButton
    Left = 136
    Top = 96
    Width = 73
    Height = 25
    Caption = #1047#1072#1087#1080#1089#1072#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 184
    Top = 64
    Width = 175
    Height = 21
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 184
    Top = 32
    Width = 169
    Height = 21
    TabOrder = 0
    OnKeyPress = Edit1KeyPress
  end
  object ABSQuery1: TABSQuery
    CurrentVersion = '6.09 '
    DatabaseName = 'gamezal'
    InMemory = False
    ReadOnly = False
    Left = 288
    Top = 40
  end
end
