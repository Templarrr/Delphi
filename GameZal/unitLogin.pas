unit unitLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, StdCtrls, DB, ABSMain;

type
  TformLogin = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    editLogin: TEdit;
    Label2: TLabel;
    editPass: TMaskEdit;
    Button1: TButton;
    ABSDatabase1: TABSDatabase;
    ABSQuery1: TABSQuery;
    ABSQuery2: TABSQuery;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure editPassKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  ANON_LEVEL  = 0;
  ADMIN_LEVEL = 1; //права администратора
  OWNER_LEVEL = 2; //права владельца

var
  formLogin: TformLogin;
  hMutex : THandle;
  login: string;
  access_level : Byte;

implementation

uses unitMain, unitSklad;

{$R *.dfm}

function CheckLogin(login: string; pass:string) : integer;
  begin
    //проверяем верный ли логин и какие ему даны права
    formLogin.ABSQuery1.SQL.Clear;
    formLogin.ABSQuery1.SQL.Add('select access from users where login = :login AND pass = :pass');
    formLogin.ABSQuery1.ParamByName('login').AsString := login;
    formLogin.ABSQuery1.ParamByName('pass').AsString := pass;
    formLogin.ABSQuery1.Open;
    if (formLogin.ABSQuery1.RecordCount > 0)
    then
      Result:=formLogin.ABSQuery1.FieldByName('access').AsInteger
    else
      Result:=ANON_LEVEL;
  end;

procedure TformLogin.Button1Click(Sender: TObject);
var
  level : integer;
begin
  level := CheckLogin(editLogin.Text,editPass.Text);
  if level <> ANON_LEVEL then
  begin
    login := editLogin.Text;
    access_level := level;
    formMain.Initiate;
    if (access_level = ADMIN_LEVEL)
      then formSklad.ABSTable1.ReadOnly := True
      else formSklad.ABSTable1.ReadOnly := False;
    formMain.Show;
    formLogin.Hide;
  end
  else
  begin
    ShowMessage('Данные неверны, проверьте раскладку и повторите попытку');
  end;
end;

procedure TformLogin.FormCreate(Sender: TObject);
begin
  if WaitForSingleObject(hMutex, 0)<>0 then
  begin
    ShowMessage('Уже запущенo');
    Application.Terminate;
  end
  else
  begin
    DecimalSeparator := ',';
    ABSDatabase1.DatabaseFileName := ExtractFilePath(Application.ExeName) + 'gamezal.abs';
    ABSDatabase1.Open;
  end;
end;

procedure TformLogin.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

procedure TformLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  formMain.Timer1.Enabled:=false;
  ABSDatabase1.Close;
end;

procedure TformLogin.editPassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Button1.Click;
end;

initialization

  hMutex := CreateMutex(nil, True, PChar('GameZal by Templar (c) 2011'));

finalization

  CloseHandle(hMutex);

end.
