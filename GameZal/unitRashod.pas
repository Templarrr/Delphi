unit unitRashod;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ABSMain, Mask, StdCtrls;

type
  TformRashod = class(TForm)
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Edit2: TEdit;
    ABSQuery1: TABSQuery;
    Edit3: TEdit;
    Edit1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formRashod: TformRashod;
  k : Integer = 1;

implementation

{$R *.dfm}

uses unitLogin;

procedure TformRashod.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
   Edit3.Text := '';
   Edit1.Text := '';
   Edit2.Text := '';
end;

procedure TformRashod.Button1Click(Sender: TObject);
begin
  if Edit3.Text<>'' then
  begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('insert into rashod (stat,comm,summ,dat,login) values (:stat,:comm,:summ,:dat,:login)');
      ABSQuery1.ParamByName('dat').AsDateTime:=now;
      ABSQuery1.ParamByName('stat').AsString:=Edit3.Text;
      ABSQuery1.ParamByName('comm').AsString:=Edit2.Text;
      ABSQuery1.ParamByName('login').AsString:=unitLogin.login;
      ABSQuery1.ParamByName('summ').AsFloat:=k*StrToFloat(Edit1.Text);
      ABSQuery1.ExecSQL;
      Close;
  end
  else
    ShowMessage('Заполните название статьи расходов');
end;

procedure TformRashod.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '.' then Key:= ',';
end;

end.
