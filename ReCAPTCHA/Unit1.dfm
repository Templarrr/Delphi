object Form1: TForm1
  Left = 219
  Top = 156
  Width = 537
  Height = 480
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
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 377
    Height = 105
  end
  object Image2: TImage
    Left = 8
    Top = 120
    Width = 377
    Height = 105
  end
  object Image3: TImage
    Left = 8
    Top = 232
    Width = 377
    Height = 105
  end
  object Label1: TLabel
    Left = 8
    Top = 352
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 8
    Top = 368
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object Button1: TButton
    Left = 432
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 432
    Top = 104
    Width = 73
    Height = 25
    Caption = 'Otsu+Opening'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 432
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Normalize'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 432
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Opening'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 432
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Cut'
    TabOrder = 4
    OnClick = Button6Click
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 392
    Top = 40
  end
end
