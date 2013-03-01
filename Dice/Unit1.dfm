object Form1: TForm1
  Left = 193
  Top = 198
  Width = 144
  Height = 327
  Caption = 'STATS'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 16
    Width = 22
    Height = 13
    Caption = 'STR'
  end
  object Label2: TLabel
    Left = 32
    Top = 40
    Width = 22
    Height = 13
    Caption = 'DEX'
  end
  object Label3: TLabel
    Left = 32
    Top = 64
    Width = 23
    Height = 13
    Caption = 'CON'
  end
  object Label4: TLabel
    Left = 32
    Top = 88
    Width = 18
    Height = 13
    Caption = 'INT'
  end
  object Label5: TLabel
    Left = 32
    Top = 112
    Width = 21
    Height = 13
    Caption = 'WIZ'
  end
  object Label6: TLabel
    Left = 32
    Top = 136
    Width = 22
    Height = 13
    Caption = 'CHA'
  end
  object Label7: TLabel
    Left = 56
    Top = 224
    Width = 6
    Height = 13
    Caption = 'd'
  end
  object Edit1: TEdit
    Left = 64
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 64
    Top = 32
    Width = 41
    Height = 21
    TabOrder = 1
  end
  object Edit3: TEdit
    Left = 64
    Top = 56
    Width = 41
    Height = 21
    TabOrder = 2
  end
  object Edit4: TEdit
    Left = 64
    Top = 80
    Width = 41
    Height = 21
    TabOrder = 3
  end
  object Edit5: TEdit
    Left = 64
    Top = 104
    Width = 41
    Height = 21
    TabOrder = 4
  end
  object Edit6: TEdit
    Left = 64
    Top = 128
    Width = 41
    Height = 21
    TabOrder = 5
  end
  object Button1: TButton
    Left = 32
    Top = 160
    Width = 75
    Height = 25
    Caption = 'ROLL STAT'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Edit7: TEdit
    Left = 8
    Top = 216
    Width = 41
    Height = 21
    TabOrder = 7
    Text = '3'
  end
  object Edit8: TEdit
    Left = 72
    Top = 216
    Width = 41
    Height = 21
    TabOrder = 8
    Text = '6'
  end
  object Button2: TButton
    Left = 8
    Top = 248
    Width = 75
    Height = 25
    Caption = 'ROLL DICE'
    TabOrder = 9
    OnClick = Button2Click
  end
  object Edit9: TEdit
    Left = 88
    Top = 248
    Width = 41
    Height = 21
    ReadOnly = True
    TabOrder = 10
  end
end
