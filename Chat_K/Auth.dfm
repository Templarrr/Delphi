object AuthForm: TAuthForm
  Left = 509
  Top = 93
  Width = 334
  Height = 222
  Caption = 'AuthForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object resultLabel: TCoolLabel
    Left = 10
    Top = 154
    Width = 85
    Height = 23
    SimpleView = True
    Alignment = taCenter
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = cl3DDkShadow
    Font.Height = -21
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object CoolLabel6: TCoolLabel
    Left = 10
    Top = 4
    Width = 133
    Height = 15
    SimpleView = True
    Alignment = taCenter
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1085#1086#1074#1086#1081' '#1074#1077#1088#1089#1080#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object CoolBtn1: TCoolBtn
    Left = 135
    Top = 158
    Width = 75
    Height = 25
    Caption = #1042#1086#1081#1090#1080
    TabOrder = 0
    Visible = False
    OnClick = CoolBtn1Click
    BtnPaintOptions = []
    ColorEnd = clLime
    ColorStart = clGreen
    GradientDirection = gdVertical
    Options = [ocPaintGradiently]
    SimpleView = True
  end
  object CoolBtn2: TCoolBtn
    Left = 243
    Top = 158
    Width = 75
    Height = 25
    Caption = #1042#1099#1081#1090#1080
    ModalResult = 2
    TabOrder = 1
    Visible = False
    BtnPaintOptions = []
    ColorEnd = 8388863
    ColorStart = 33023
    GradientDirection = gdVertical
    Options = [ocPaintGradiently]
    SimpleView = True
  end
  object CoolGroupBox1: TCoolGroupBox
    Left = 0
    Top = 0
    Width = 319
    Height = 151
    SimpleView = True
    TabOrder = 2
    Visible = False
    object CoolLabel2: TCoolLabel
      Left = 5
      Top = 10
      Width = 266
      Height = 13
      SimpleView = True
      Caption = #1057#1087#1086#1095#1072#1090#1082#1091' '#1074#1082#1072#1078#1110#1090#1100' '#1091' '#1103#1082#1086#1084#1091' '#1079' '#1087#1110#1076#1088#1086#1079#1076#1110#1083#1110#1074' '#1074#1080' '#1087#1088#1072#1094#1102#1108#1090#1077':'
    end
    object CoolLabel1: TCoolLabel
      Left = 5
      Top = 80
      Width = 297
      Height = 13
      SimpleView = True
      Caption = #1055#1086#1090#1110#1084' '#1074#1080#1073#1077#1088#1110#1090#1100' '#1089#1074#1086#1108' '#1087#1088#1110#1079#1074#1080#1097#1077' '#1079' '#1089#1087#1080#1089#1082#1091' '#1090#1072' '#1074#1082#1072#1078#1110#1090#1100' '#1087#1072#1088#1086#1083#1100'.'
    end
    object CoolLabel3: TCoolLabel
      Left = 48
      Top = 124
      Width = 50
      Height = 13
      SimpleView = True
      Caption = #1087#1088#1110#1079#1074#1080#1097#1077' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = cl3DDkShadow
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CoolLabel4: TCoolLabel
      Left = 208
      Top = 124
      Width = 36
      Height = 13
      SimpleView = True
      Caption = #1087#1072#1088#1086#1083#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = cl3DDkShadow
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CoolLabel5: TCoolLabel
      Left = 174
      Top = 34
      Width = 122
      Height = 29
      SimpleView = True
      Caption = '"'#1050#1077#1085#1072#1088#1080#1091#1089'"'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = cl3DDkShadow
      Font.Height = -25
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object CoolCheckRadioBox1: TCoolCheckRadioBox
      Tag = 1
      Left = 5
      Top = 30
      Width = 147
      Height = 17
      BevelInner = bvRaised
      CheckRadioType = crRadioBox
      SimpleView = True
      Caption = #1050#1050' '#1053#1040#1059' ('#1050#1056#1040#1059#1057#1057')'
      UseDockManager = False
      TabOrder = 1
      OnClick = ChangeEnterprise
    end
    object CoolCheckRadioBox2: TCoolCheckRadioBox
      Tag = 2
      Left = 5
      Top = 50
      Width = 147
      Height = 17
      BevelInner = bvRaised
      CheckRadioType = crRadioBox
      SimpleView = True
      Caption = #1048#1042#1058' '#1053#1040#1059
      UseDockManager = False
      TabOrder = 2
      OnClick = ChangeEnterprise
    end
    object ComboBox1: TCoolComboBox
      Left = 5
      Top = 100
      Width = 145
      Height = 22
      FileMask = '*.*'
      ListBoxWidth = 145
      SelFont.Charset = DEFAULT_CHARSET
      SelFont.Color = clHighlightText
      SelFont.Height = -11
      SelFont.Name = 'MS Sans Serif'
      SelFont.Style = []
      SimpleView = True
      ItemHeight = 16
      TabOrder = 3
    end
    object Edit1: TEdit
      Left = 155
      Top = 101
      Width = 151
      Height = 21
      PasswordChar = '*'
      TabOrder = 0
      Text = 'Sardukar'
    end
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    Host = '192.168.10.5'
    Port = 8080
    AllowCookies = False
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 290
    Top = 126
  end
  object Timer1: TTimer
    Interval = 100
    Left = 258
    Top = 124
  end
end
