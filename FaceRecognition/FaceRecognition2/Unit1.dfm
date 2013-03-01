object Form1: TForm1
  Left = 265
  Top = 69
  Width = 635
  Height = 593
  AutoSize = True
  BorderWidth = 5
  Caption = 'Form1'
  Color = clBtnFace
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
  object Label2: TLabel
    Left = 0
    Top = 360
    Width = 80
    Height = 13
    Caption = #1042#1089#1077#1075#1086' '#1080#1090#1077#1088#1072#1094#1080#1081
  end
  object Label3: TLabel
    Left = 0
    Top = 384
    Width = 124
    Height = 13
    Caption = #1052#1072#1082#1089'. '#1088#1072#1076#1080#1091#1089' '#1089#1084#1077#1097#1077#1085#1080#1103
  end
  object Label4: TLabel
    Left = 0
    Top = 408
    Width = 45
    Height = 13
    Caption = #1061' '#1079#1088#1072#1095#1082#1072
  end
  object Label5: TLabel
    Left = 280
    Top = 392
    Width = 98
    Height = 13
    Caption = #1057#1090#1072#1088#1090#1086#1074#1072#1103' '#1088#1072#1079#1085#1080#1094#1072
  end
  object Label6: TLabel
    Left = 280
    Top = 416
    Width = 93
    Height = 13
    Caption = #1050#1086#1085#1077#1095#1085#1072#1103' '#1088#1072#1079#1085#1080#1094#1072
  end
  object Label1: TLabel
    Left = 0
    Top = 432
    Width = 46
    Height = 13
    Caption = #1059' '#1079#1088#1072#1095#1082#1072
  end
  object Label7: TLabel
    Left = 0
    Top = 480
    Width = 148
    Height = 13
    Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1084#1077#1078#1076#1091' '#1079#1088#1072#1095#1082#1072#1084#1080
  end
  object Label8: TLabel
    Left = 0
    Top = 456
    Width = 74
    Height = 13
    Caption = #1056#1072#1076#1080#1091#1089' '#1079#1088#1072#1095#1082#1072
  end
  object Label9: TLabel
    Left = 296
    Top = 360
    Width = 176
    Height = 13
    Caption = #1050#1086#1077#1092#1080#1094#1080#1077#1085#1090' '#1078#1077#1089#1090#1082#1086#1089#1090#1080' '#1084#1077#1084#1073#1088#1072#1085#1099
  end
  object Label10: TLabel
    Left = 288
    Top = 456
    Width = 310
    Height = 13
    Caption = 
      '<--'#1086#1076#1080#1085' '#1095#1077#1083#1086#1074#1077#1082'                 '#1085#1077#1086#1087#1088#1077#1076#1077#1083#1077#1085#1086'                   '#1088 +
      #1072#1079#1085#1099#1077'-->'
  end
  object Label11: TLabel
    Left = 288
    Top = 480
    Width = 127
    Height = 24
    Caption = #1057#1086#1074#1087#1072#1076#1077#1085#1080#1077' : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label13: TLabel
    Left = 488
    Top = 504
    Width = 56
    Height = 13
    Caption = '+ '#1080#1090#1077#1088#1072#1094#1080#1081
  end
  object Label14: TLabel
    Left = 488
    Top = 528
    Width = 53
    Height = 13
    Caption = '- '#1080#1090#1077#1088#1072#1094#1080#1081
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 200
    Height = 200
    Caption = #1048#1089#1093#1086#1076#1085#1086#1077' 1'
    TabOrder = 0
    object Image1: TImage
      Left = 2
      Top = 15
      Width = 196
      Height = 183
      Align = alClient
    end
  end
  object GroupBox2: TGroupBox
    Left = 416
    Top = 0
    Width = 200
    Height = 200
    Caption = #1048#1089#1093#1086#1076#1085#1086#1077' 2'
    TabOrder = 1
    object Image2: TImage
      Left = 2
      Top = 15
      Width = 196
      Height = 183
      Align = alClient
    end
  end
  object Button1: TButton
    Left = 0
    Top = 216
    Width = 75
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 536
    Top = 216
    Width = 75
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 3
    OnClick = Button2Click
  end
  object GroupBox3: TGroupBox
    Left = 208
    Top = 0
    Width = 200
    Height = 241
    Caption = #1058#1088#1072#1085#1089#1092#1086#1088#1084#1072#1094#1080#1103' 1 '#1074' 2'
    TabOrder = 4
    object Image3: TImage
      Left = 2
      Top = 15
      Width = 196
      Height = 183
    end
    object TrackBar1: TTrackBar
      Left = 8
      Top = 208
      Width = 185
      Height = 25
      Max = 4
      Min = -1
      TabOrder = 0
      OnChange = TrackBar1Change
    end
  end
  object Button3: TButton
    Left = 16
    Top = 504
    Width = 105
    Height = 25
    Caption = #1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1100
    TabOrder = 5
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 152
    Top = 360
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '1000'
  end
  object Edit2: TEdit
    Left = 152
    Top = 384
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '10'
  end
  object Edit3: TEdit
    Left = 152
    Top = 408
    Width = 121
    Height = 21
    TabOrder = 8
    Text = '20'
  end
  object CheckBox1: TCheckBox
    Left = 0
    Top = 312
    Width = 217
    Height = 17
    Caption = #1055#1088#1077#1076#1086#1073#1088#1072#1073#1086#1090#1082#1072' '#1086#1087#1077#1088#1072#1090#1086#1088#1086#1084' '#1044#1077#1088#1080#1096#1072
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object Edit4: TEdit
    Left = 384
    Top = 392
    Width = 121
    Height = 21
    TabOrder = 10
  end
  object Edit5: TEdit
    Left = 384
    Top = 416
    Width = 121
    Height = 21
    TabOrder = 11
  end
  object ProgressBar1: TProgressBar
    Left = 128
    Top = 512
    Width = 353
    Height = 17
    Max = 1000
    TabOrder = 12
  end
  object CheckBox2: TCheckBox
    Left = 0
    Top = 336
    Width = 361
    Height = 17
    Caption = #1080#1085#1090#1077#1088#1087#1086#1083#1103#1094#1080#1103' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1072' ('#1091#1076#1072#1083#1077#1085#1080#1077' '#1088#1072#1079#1088#1099#1074#1086#1074')'
    Checked = True
    State = cbChecked
    TabOrder = 13
  end
  object Edit6: TEdit
    Left = 152
    Top = 432
    Width = 121
    Height = 21
    TabOrder = 14
    Text = '20'
  end
  object RadioGroup1: TRadioGroup
    Left = 0
    Top = 248
    Width = 209
    Height = 57
    Caption = #1061#1072#1088#1072#1082#1090#1077#1088' '#1076#1077#1092#1086#1088#1084#1072#1094#1080#1081
    ItemIndex = 0
    Items.Strings = (
      #1057#1083#1091#1095#1072#1081#1085#1099#1081
      #1056#1072#1076#1080#1072#1083#1100#1085#1099#1081)
    TabOrder = 15
  end
  object Edit7: TEdit
    Left = 152
    Top = 480
    Width = 121
    Height = 21
    TabOrder = 16
    Text = '40'
  end
  object Edit8: TEdit
    Left = 152
    Top = 456
    Width = 121
    Height = 21
    TabOrder = 17
    Text = '4'
  end
  object Edit9: TEdit
    Left = 480
    Top = 352
    Width = 121
    Height = 21
    TabOrder = 18
    Text = '0,3'
  end
  object RadioGroup2: TRadioGroup
    Left = 216
    Top = 248
    Width = 265
    Height = 89
    Caption = #1042#1099#1088#1072#1074#1085#1080#1074#1072#1085#1080#1077' '#1091#1088#1086#1074#1085#1077#1081
    ItemIndex = 1
    Items.Strings = (
      #1041#1077#1079' '#1086#1073#1088#1072#1073#1086#1090#1082#1080
      #1040#1074#1090#1086#1082#1086#1085#1090#1088#1072#1089#1090'('#1083#1080#1085#1077#1081#1085#1099#1081')'
      #1040#1074#1090#1086#1082#1086#1085#1090#1088#1072#1089#1090'('#1101#1082#1089#1087'.)')
    TabOrder = 19
  end
  object Edit10: TEdit
    Left = 424
    Top = 312
    Width = 49
    Height = 21
    TabOrder = 20
    Text = '0,5'
  end
  object Button4: TButton
    Left = 536
    Top = 320
    Width = 75
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '
    TabOrder = 21
    OnClick = Button4Click
  end
  object Edit11: TEdit
    Left = 368
    Top = 448
    Width = 49
    Height = 21
    TabOrder = 22
    Text = '0,32'
  end
  object Edit12: TEdit
    Left = 496
    Top = 448
    Width = 49
    Height = 21
    TabOrder = 23
    Text = '0,5'
  end
  object Edit15: TEdit
    Left = 560
    Top = 504
    Width = 57
    Height = 21
    TabOrder = 24
  end
  object Edit16: TEdit
    Left = 560
    Top = 528
    Width = 57
    Height = 21
    TabOrder = 25
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 440
    Top = 208
  end
end
