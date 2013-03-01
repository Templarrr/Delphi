unit Auth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, StdCtrls, CoolCtrls;

type
  TAuthForm = class(TForm)
    resultLabel: TCoolLabel;
    CoolLabel6: TCoolLabel;
    CoolBtn1: TCoolBtn;
    CoolBtn2: TCoolBtn;
    CoolGroupBox1: TCoolGroupBox;
    CoolLabel2: TCoolLabel;
    CoolLabel1: TCoolLabel;
    CoolLabel3: TCoolLabel;
    CoolLabel4: TCoolLabel;
    CoolLabel5: TCoolLabel;
    CoolCheckRadioBox1: TCoolCheckRadioBox;
    CoolCheckRadioBox2: TCoolCheckRadioBox;
    ComboBox1: TCoolComboBox;
    Edit1: TEdit;
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ChangeEnterprise(Sender: TObject);
    procedure CoolBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    id,ent:integer;
    fio:string;
    text:string;
    { Public declarations }
  end;

var
  AuthForm: TAuthForm;

implementation

uses Unit1;

{$R *.dfm}

function GetUserName:string;
{Определение имени пользователя}
var
 Buffer: array[0..MAX_PATH] of Char;
 sz:DWord;
begin
  sz:=MAX_PATH-1;
  if windows.GetUserName(Buffer,sz)
  then
  begin
    if sz>0 then dec(sz);
    SetString(Result,Buffer,sz);
  end
  else
  begin
    Result:='Error '+inttostr(GetLastError);
  end;
end;

function GetComputerName:string;
var
  Buffer: array[0..MAX_PATH] of Char;
  sz:DWord;
begin
  sz:=MAX_PATH-1;
  if windows.GetComputerName(Buffer,sz) then
  begin
    SetString(Result,Buffer,sz);
  end
  else if GetLastError<>0 then
    Result:='#Error#'+inttostr(GetLastError)
  else Result:='';
end;

procedure TAuthForm.FormCreate(Sender: TObject);
begin
visible:=false;
end;

procedure TAuthForm.FormShow(Sender: TObject);
begin
  ChatForm.ConnectByGuest;
  CoolGroupBox1.Visible:=true;
  CoolBtn1.Visible:=true;
  CoolBtn2.Visible:=true;
  id:=0;
  fio:='';
  ent:=0;
  edit1.Text:='';
  ComboBox1.tag:=0;
  CoolCheckRadioBox2.Checked:=true;
  ChangeEnterprise(CoolCheckRadioBox2);
  resultLabel.Visible:=false;
end;

procedure TAuthForm.ChangeEnterprise(Sender:Tobject);
var
  a : string;
begin
  ComboBox1.tag:=0;
//запрос списка пользователей
  ChatForm.SimpleQ1('select id,fio from anketa_b,users_logins where '+
  'ent=%d AND id=userid ORDER BY fio', [(sender as TCoolCheckRadioBox).Tag]);
//заполнение селекта
  ComboBox1.Items.Clear;
  ComboBox1.tag:=0;
  while not ChatForm.SQL1.Eof do
  begin
    ComboBox1.Items.AddObject(ChatForm.SQL1.FieldByName('fio').asString,
    TObject(ChatForm.SQL1.FieldByName('id').asInteger));
    ChatForm.SQL1.next;
  end;
//выбор пользователя, который входил с этого компа и профиля
  a:=GetUserName+'@'+GetComputerName;
  ChatForm.SimpleQ1('SELECT userid FROM USERS_LOGINS where LAST_ENTER_FROM like upper(%s)',[#39+a+#39]);
  ChatForm.GoToNumber(ComboBox1,ChatForm.SQL1.Fields[0].asInteger);
end;

procedure TAuthForm.CoolBtn1Click(Sender: TObject);
var
  a,s:String;
  id:integer;
begin
//узнать под какой ролью подключаться

  id:=ChatForm.NumFromCombo(ComboBox1);
  ChatForm.ConnectByGuest;

  ChatForm.SimpleQ1('SELECT login,srole from USERS_loginS Where userid=%d', [id ]);
//  ChatForm.SimpleQ1('Commit', []);
//  Chatform.commitquery.ExecSQL;
  a:=ChatForm.SQL1.Fields[0].asstring;
  s:=ChatForm.SQL1.Fields[1].asstring;
//  a:='Templar';
//  s:='Developer';
  ChatForm.AUserRole:=s;
{  ChatForm.database.Close;
  ChatForm.Database.Params.Clear;
  ChatForm.Database.Params.add('user_name='+a);
  ChatForm.Database.Params.add('password='+edit1.text);
  ChatForm.Database.Params.add('sql_role_name='+s);
  resultLabel.Caption:='Ок. Производим вход.';
  resultLabel.font.color:=clGreen;
  try
    ChatForm.Database.Open;
  except
    resultLabel.Caption:='Пароль неверный.';
    resultLabel.font.color:=clred;
    focusControl(edit1);
  end;}
  resultLabel.visible:=true;
  if ChatForm.Database.Connected then
  begin
    ChatForm.AUserId:=id;
    ChatForm.SimpleQ1('SELECT ent,sex,fio FROM anketa_b WHERE id=%d',[id]);
    ChatForm.AUserEnt:=ChatForm.SQL1.Fields[0].AsInteger;
    ChatForm.AUserSex:=ChatForm.SQL1.Fields[1].AsString;
    ChatForm.AUserName:=ChatForm.SQL1.Fields[2].AsString;
    ChatForm.SimpleQ1('SELECT ENT_NAME FROM ENTERPRISES WHERE id=%d',[ChatForm.AUserEnt]);
    ChatForm.AUserEntName:=ChatForm.SQL1.Fields[0].AsString;
//ChatForm.fioDialog.ent:=ChatForm.AUserEnt;
//запись профиля и компа с которого происходит вход
    ChatForm.SimpleQ1('EXECUTE PROCEDURE SET_LASTENTER(%d,%s)',
    [id,#39+GetUserName+'@'+GetComputerName+#39]);
    timer1.Enabled:=false;
    ModalResult := mrOk;
  end;
end;

end.
