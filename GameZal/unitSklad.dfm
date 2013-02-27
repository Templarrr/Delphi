object formSklad: TformSklad
  Left = 448
  Top = 101
  Width = 419
  Height = 317
  AutoSize = True
  BorderWidth = 5
  Caption = #1058#1086#1074#1072#1088#1099' '#1085#1072' '#1089#1082#1083#1072#1076#1077
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
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 400
    Height = 169
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Width = 25
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'name'
        Title.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        Width = 168
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'cost'
        Title.Caption = #1055#1088#1086#1076#1072#1078#1085#1072#1103' '#1094#1077#1085#1072
        Width = 91
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'col'
        Title.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
        Visible = True
      end>
  end
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = 176
    Width = 400
    Height = 41
    DataSource = DataSource1
    TabOrder = 1
  end
  object Button1: TButton
    Left = 264
    Top = 224
    Width = 137
    Height = 49
    Caption = #1054#1082
    TabOrder = 2
    OnClick = Button1Click
  end
  object ABSTable1: TABSTable
    CurrentVersion = '6.09 '
    DatabaseName = 'gamezal'
    InMemory = False
    ReadOnly = False
    Active = True
    TableName = 'sklad'
    Exclusive = False
    Left = 200
    Top = 40
  end
  object DataSource1: TDataSource
    DataSet = ABSTable1
    Left = 168
    Top = 40
  end
end
