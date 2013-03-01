object Form1: TForm1
  Left = 190
  Top = 75
  Width = 805
  Height = 600
  Caption = 'gsn'
  Color = clBtnFace
  Constraints.MaxHeight = 600
  Constraints.MaxWidth = 805
  Constraints.MinHeight = 460
  Constraints.MinWidth = 695
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 393
    Height = 461
    Align = alLeft
    Caption = #1048#1089#1093#1086#1076#1085#1086#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    TabOrder = 0
    object Image1: TImage
      Left = 2
      Top = 15
      Width = 389
      Height = 444
      Align = alClient
    end
  end
  object GroupBox2: TGroupBox
    Left = 397
    Top = 0
    Width = 400
    Height = 461
    Align = alRight
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
    TabOrder = 1
    object Image2: TImage
      Left = 2
      Top = 15
      Width = 396
      Height = 444
      Align = alClient
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 461
    Width = 797
    Height = 105
    Align = alBottom
    Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
    TabOrder = 2
    object Label1: TLabel
      Left = 600
      Top = 40
      Width = 32
      Height = 13
      Caption = 'alpha='
    end
    object Button1: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 88
      Top = 40
      Width = 81
      Height = 25
      Caption = #1051#1072#1087#1083#1072#1089' 4'#1089#1074#1103#1079
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 88
      Top = 64
      Width = 81
      Height = 25
      Caption = #1051#1072#1087#1083#1072#1089' 8'#1089#1074#1103#1079
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 168
      Top = 40
      Width = 81
      Height = 25
      Caption = #1057#1086#1073#1077#1083#1100
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 248
      Top = 40
      Width = 81
      Height = 25
      Caption = #1052#1077#1076#1080#1072#1085#1072
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 168
      Top = 64
      Width = 81
      Height = 25
      Caption = #1054#1090#1089#1091
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 248
      Top = 64
      Width = 81
      Height = 25
      Caption = #1053#1077#1075#1072#1090#1080#1074
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 328
      Top = 40
      Width = 105
      Height = 25
      Caption = #1040#1074#1090#1086#1082#1086#1085#1090#1088#1072#1089#1090
      TabOrder = 7
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 328
      Top = 64
      Width = 105
      Height = 25
      Caption = #1040#1074#1090#1086#1082#1086#1085#1090#1088#1072#1089#1090' SM'
      TabOrder = 8
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 432
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Box3'
      TabOrder = 9
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 432
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Gauss5'
      TabOrder = 10
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 520
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Deriche'
      TabOrder = 11
      OnClick = Button12Click
    end
    object Edit1: TEdit
      Left = 640
      Top = 40
      Width = 41
      Height = 21
      TabOrder = 12
      Text = '3'
    end
    object Button13: TButton
      Left = 520
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Otsu(Deriche)'
      TabOrder = 13
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 440
      Top = 8
      Width = 81
      Height = 25
      Caption = #1051#1072#1087#1083#1072#1089#1052#1086#1076
      TabOrder = 14
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 520
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Deriche('#1051#1072#1087#1083#1072#1089#1052#1086#1076')'
      TabOrder = 15
      OnClick = Button15Click
    end
    object Button16: TButton
      Left = 640
      Top = 8
      Width = 121
      Height = 25
      Caption = #1051#1072#1087#1083#1072#1089#1052#1086#1076'(Deriche)'
      TabOrder = 16
      OnClick = Button16Click
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 16
    Top = 288
  end
end
