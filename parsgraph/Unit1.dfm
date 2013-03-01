object Form1: TForm1
  Left = 264
  Top = 78
  Width = 691
  Height = 461
  BorderWidth = 5
  Caption = #1043#1088#1072#1092#1080#1082' '#1092#1091#1085#1082#1094#1080#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    673
    417)
  PixelsPerInch = 96
  TextHeight = 13
  object Chart1: TChart
    Left = 240
    Top = 0
    Width = 433
    Height = 417
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.Text.Strings = (
      #1043#1088#1072#1092#1080#1082' '#1092#1091#1085#1082#1094#1080#1080)
    Legend.Visible = False
    View3D = False
    TabOrder = 0
    Anchors = [akLeft, akTop, akRight, akBottom]
    object Series1: TLineSeries
      Marks.ArrowLength = 8
      Marks.Style = smsValue
      Marks.Visible = False
      SeriesColor = clBlue
      LineBrush = bsClear
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Style = psCircle
      Pointer.VertSize = 3
      Pointer.Visible = False
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
    object Series2: TPointSeries
      Marks.ArrowLength = 0
      Marks.Visible = False
      SeriesColor = clRed
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Style = psCircle
      Pointer.VertSize = 3
      Pointer.Visible = False
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 233
    Height = 57
    Caption = #1060#1091#1085#1082#1094#1080#1103
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 28
      Width = 11
      Height = 13
      Caption = 'y='
    end
    object Edit1: TEdit
      Left = 96
      Top = 20
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'exp(sin(x))'
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 64
    Width = 233
    Height = 113
    Caption = #1042#1099#1095#1080#1089#1083#1080#1090#1100' '#1079#1085#1072#1095#1077#1085#1080#1077
    TabOrder = 2
    object Label2: TLabel
      Left = 16
      Top = 24
      Width = 11
      Height = 13
      Caption = 'x='
    end
    object Label3: TLabel
      Left = 16
      Top = 48
      Width = 52
      Height = 13
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
    end
    object Edit2: TEdit
      Left = 96
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '2'
    end
    object Edit3: TEdit
      Left = 96
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object Button1: TButton
      Left = 62
      Top = 80
      Width = 75
      Height = 25
      Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 184
    Width = 233
    Height = 129
    Caption = #1043#1088#1072#1092#1080#1082' '#1092#1091#1085#1082#1094#1080#1080
    TabOrder = 3
    object Label4: TLabel
      Left = 16
      Top = 24
      Width = 72
      Height = 13
      Caption = #1053#1072#1095'. '#1079#1085#1072#1095#1077#1085#1080#1077
    end
    object Label5: TLabel
      Left = 16
      Top = 48
      Width = 72
      Height = 13
      Caption = #1050#1086#1085'. '#1079#1085#1072#1095#1077#1085#1080#1077
    end
    object Label6: TLabel
      Left = 16
      Top = 72
      Width = 76
      Height = 13
      Caption = #1064#1072#1075' '#1072#1088#1075#1091#1084#1077#1085#1090#1072
    end
    object Edit4: TEdit
      Left = 96
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '-10'
    end
    object Edit5: TEdit
      Left = 96
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '10'
    end
    object Edit6: TEdit
      Left = 96
      Top = 64
      Width = 121
      Height = 21
      TabOrder = 2
      Text = '0,3'
    end
    object Button2: TButton
      Left = 64
      Top = 96
      Width = 75
      Height = 25
      Caption = #1053#1072#1095#1077#1088#1090#1080#1090#1100
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object RadioGroup1: TRadioGroup
    Left = 0
    Top = 320
    Width = 233
    Height = 97
    Caption = #1058#1080#1087' '#1075#1088#1072#1092#1080#1082#1072
    ItemIndex = 0
    Items.Strings = (
      #1051#1080#1085#1077#1081#1085#1099#1081
      #1058#1086#1095#1077#1095#1085#1099#1081)
    TabOrder = 4
    OnClick = RadioGroup1Click
  end
end
