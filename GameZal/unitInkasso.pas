unit unitInkasso;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ABSMain, Mask, StdCtrls;

type
  TformInkasso = class(TForm)
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Edit2: TEdit;
    ABSQuery1: TABSQuery;
    Label1: TLabel;
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
  formInkasso: TformInkasso;

implementation

{$R *.dfm}
uses
  unitLogin;

procedure TformInkasso.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
   Edit1.Text := '';
   Edit2.Text := '';
end;

procedure TformInkasso.Button1Click(Sender: TObject);
begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('insert into rashod (stat,comm,summ,dat,login) values (:stat,:comm,:summ,:dat,:login)');
      ABSQuery1.ParamByName('dat').AsDateTime:=now;
      ABSQuery1.ParamByName('stat').AsString:='Инкассация';
      ABSQuery1.ParamByName('comm').AsString:=Edit2.Text;
      ABSQuery1.ParamByName('login').AsString:=unitLogin.login;
      ABSQuery1.ParamByName('summ').AsFloat:=StrToFloat(Edit1.Text);
      ABSQuery1.ExecSQL;
      Close;
end;

procedure TformInkasso.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '.' then Key:= ',';
end;

end.
