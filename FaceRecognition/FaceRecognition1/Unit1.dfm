object Form1: TForm1
  Left = 324
  Top = 33
  Width = 547
  Height = 653
  AutoSize = True
  BorderWidth = 5
  Caption = 
    #1055#1088#1086#1074#1077#1088#1082#1072' '#1072#1083#1075#1086#1088#1080#1090#1084#1086#1074', '#1095#1072#1089#1090#1100' 1. '#1042#1099#1076#1077#1083#1077#1085#1080#1077' '#1079#1088#1072#1095#1082#1086#1074', '#1074#1099#1088#1072#1074#1085#1080#1074#1072#1085#1080#1077', '#1086 +
    #1073#1088#1077#1079#1082#1072'.'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 184
    Top = 488
    Width = 148
    Height = 13
    Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1084#1077#1078#1076#1091' '#1079#1088#1072#1095#1082#1072#1084#1080
  end
  object Label2: TLabel
    Left = 184
    Top = 520
    Width = 138
    Height = 13
    Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1083#1077#1074#1086#1075#1086' '#1079#1088#1072#1095#1082#1072
  end
  object Label3: TLabel
    Left = 184
    Top = 548
    Width = 160
    Height = 13
    Caption = #1064#1080#1088#1080#1085#1072'/'#1074#1099#1089#1086#1090#1072' '#1085#1086#1088#1084'.'#1082#1072#1088#1090#1080#1085#1082#1080
  end
  object LoadImageButton: TButton
    Left = 8
    Top = 456
    Width = 169
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    TabOrder = 0
    OnClick = LoadImageButtonClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 529
    Height = 441
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet1: TTabSheet
      BorderWidth = 5
      Caption = 'Base'
      object Image: TImage
        Left = 0
        Top = 0
        Width = 511
        Height = 403
        Align = alClient
      end
    end
    object TabSheet2: TTabSheet
      BorderWidth = 5
      Caption = 'Sobel'
      ImageIndex = 1
      object SImage: TImage
        Left = 0
        Top = 0
        Width = 511
        Height = 403
        Align = alClient
      end
    end
    object TabSheet4: TTabSheet
      BorderWidth = 5
      Caption = 'Otsu'
      ImageIndex = 3
      object OImage: TImage
        Left = 0
        Top = 0
        Width = 511
        Height = 403
        Align = alClient
      end
    end
    object TabSheet5: TTabSheet
      BorderWidth = 5
      Caption = 'Eye catch'
      ImageIndex = 4
      object EyeImage: TImage
        Left = 0
        Top = 0
        Width = 511
        Height = 403
        Align = alClient
        OnMouseDown = EyeImageMouseDown
      end
    end
    object TabSheet3: TTabSheet
      BorderWidth = 5
      Caption = 'Turn'
      ImageIndex = 2
      object TImage: TImage
        Left = 0
        Top = 0
        Width = 511
        Height = 403
        Align = alClient
      end
    end
  end
  object TurnAround: TButton
    Left = 8
    Top = 552
    Width = 169
    Height = 25
    Caption = #1053#1086#1088#1084#1072#1083#1080#1079#1086#1074#1072#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = TurnAroundClick
  end
  object EyeButton: TButton
    Left = 8
    Top = 520
    Width = 169
    Height = 25
    Caption = #1053#1072#1081#1090#1080' '#1094#1077#1085#1090#1088#1099' '#1079#1088#1072#1095#1082#1086#1074
    Enabled = False
    TabOrder = 3
    OnClick = EyeButtonClick
  end
  object iris_dist: TEdit
    Left = 352
    Top = 488
    Width = 33
    Height = 21
    TabOrder = 4
    Text = '40'
  end
  object l_iris_x: TEdit
    Left = 352
    Top = 516
    Width = 33
    Height = 21
    TabOrder = 5
    Text = '20'
  end
  object l_iris_y: TEdit
    Left = 392
    Top = 516
    Width = 33
    Height = 21
    TabOrder = 6
    Text = '20'
  end
  object nimage_width: TEdit
    Left = 352
    Top = 540
    Width = 33
    Height = 21
    TabOrder = 7
    Text = '40'
  end
  object nimage_height: TEdit
    Left = 392
    Top = 540
    Width = 33
    Height = 21
    TabOrder = 8
    Text = '80'
  end
  object SaveButton: TButton
    Left = 8
    Top = 584
    Width = 169
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1085#1086#1088#1084#1072#1083#1080#1079#1086#1074#1072#1085#1085#1086#1077
    Enabled = False
    TabOrder = 9
    OnClick = SaveButtonClick
  end
  object CheckButton: TButton
    Left = 184
    Top = 456
    Width = 217
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
    TabOrder = 10
    OnClick = CheckButtonClick
  end
  object testbutton: TButton
    Left = 8
    Top = 488
    Width = 169
    Height = 25
    Caption = #1054#1087#1077#1088#1072#1090#1086#1088' '#1057#1086#1073#1077#1083#1103', '#1084#1077#1090#1086#1076' '#1054#1090#1089#1091
    Enabled = False
    TabOrder = 11
    OnClick = testbuttonClick
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 216
    Top = 576
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Bitmaps|*.bmp'
    Left = 184
    Top = 576
  end
end
