unit dlg_auth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, IBCustomDataSet, ExtCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, ComCtrls, StdCtrls, CoolCtrls, IniFiles, basic;

type
  TAuthDialog = class(TForm)
    CoolBtn1: TCoolBtn;
    CoolBtn2: TCoolBtn;
    resultLabel: TCoolLabel;
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
    CoolBtn3: TCoolBtn;
    CoolLabel6: TCoolLabel;
    CoolBtn4: TCoolBtn;
    Timer1: TTimer;
    ProgressBar1: TProgressBar;
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CoolBtn2Click(Sender: TObject);
    procedure ChangeEnterprise(Sender: TObject);
    procedure ComboBox1MouseEnter(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CoolBtn1Click(Sender: TObject);
//    procedure CoolBtn3Click(Sender: TObject);
    procedure CoolBtn4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure IdHTTP1Work(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
  private
    { Private declarations }
  public
    id,ent:integer;
    fio:string;
    text:string;
    function Execute: Boolean;
    constructor Create(AOwner: TComponent); override;
    { Public declarations }
  end;

var
  AuthDialog: TAuthDialog;

implementation
uses UtilsForm;

{$R *.dfm}

procedure TAuthDialog.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if (key=VK_RETURN) and (shift=[]) then CoolBtn1Click(nil);
if (key=VK_ESCAPE) and (shift=[]) then CoolBtn2Click(nil);
end;

procedure TAuthDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if ModalResult<> mrOk then ModalResult := mrCancel;
hide;
end;

procedure TAuthDialog.CoolBtn2Click(Sender: TObject);
begin
ModalResult := mrCancel;
end;

constructor TAuthDialog.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
visible:=false;
end;

function TAuthDialog.Execute;
var cur_build,new_build:string;
    ini:TIniFile;
    a:string;
begin
//прячем компоненты
//CoolGroupBox1.Visible:=false;
//CoolBtn1.Visible:=false;
//CoolBtn2.Visible:=false;
//CoolBtn3.Visible:=false;
//coolbtn4.visible:=false;
//проверяем новую версию
{
CoolLabel6.Caption:='Проверка доступности новой версии клиента.';
cur_build:=GetFileVersion(paramstr(0),4);
ini:=TIniFile.Create(DM.path+'connect.ini');
a:=ini.ReadString('Main','updateURL','localhost');
FreeAndNil(ini);
try new_build:=IdHTTP1.Get(a+'build.txt'); except
if IdHTTP1.Response.ResponseText='HTTP/1.1 404 Not Found' then begin
CoolLabel6.Caption:=CoolLabel6.Caption+#13+'Невозможно проверить новую версию.';
coolbtn4.visible:=true;
end;
new_build:=cur_build;
end;
//
if (strToInt(cur_build)<strToInt(new_build)) then begin
CoolLabel6.Caption:=CoolLabel6.Caption+#13+'Обнаружена более новая версия клиента.'+#13+' Для продолжения работы нужно обновится.';
CoolBtn3.caption:='Обновить';
CoolBtn3.Visible:=true;
CoolBtn2.Visible:=true;
end else begin
CoolGroupBox1.Visible:=true and not coolbtn4.visible;
CoolBtn1.Visible:=true and not coolbtn4.visible;
CoolBtn2.Visible:=true and not coolbtn4.visible;
end;                       }
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
if (GetComputername='ALBATROS') AND (GetUserName='Charger') then begin
DM.GoToNumber(combobox1,167);
edit1.Text:='Sardukar';
end;
if (GetComputername='STATION-7') AND (GetUserName='Templar') then begin
DM.GoToNumber(combobox1,227);
edit1.Text:='freeman';
end;
if (GetComputername<>'ALBATROS') then
begin
  DM.SimpleQ2('SELECT userid,aa.ent FROM USERS_LOGINS ul, anketa_a aa WHERE LAST_ENTER_FROM =%s and userid=id order by last_enter_time desc',
  [#39+UpperCaseRus(GetUserName+'@'+GetComputerName)+#39 ]);
  if DM.sql2.fieldByName('ent').asinteger=1 then
  begin
    CoolCheckRadioBox1.Checked:=true;
    CoolCheckRadioBox2.Checked:=false;
    ChangeEnterprise(CoolCheckRadioBox1);
  end;
  if DM.sql2.fieldByName('ent').asinteger=2 then
  begin
    CoolCheckRadioBox2.Checked:=true;
    CoolCheckRadioBox1.Checked:=false;
    ChangeEnterprise(CoolCheckRadioBox2);
  end;
  if DM.sql2.fieldByName('userid').asinteger<>0 then DM.GoToNumber(combobox1,DM.sql2.fieldByName('userid').asinteger);
end;
if ShowModal=mrOK then
result:=true else result:=false;
end;


procedure TAuthDialog.ChangeEnterprise(Sender: TObject);
var a:string;
begin
ComboBox1.tag:=0;
//запрос списка пользователей
DM.SimpleQ1('select id,fio from anketa_b,users_logins where '+
'ent=%d AND id=userid ORDER BY fio', [(sender as TCoolCheckRadioBox).Tag]);
//заполнение селекта
ComboBox1.Items.Clear;
ComboBox1.tag:=0;
while not DM.SQL1.Eof do begin
ComboBox1.Items.AddObject(DM.SQL1.FieldByName('fio').asString,
  TObject(DM.SQL1.FieldByName('id').asInteger));
DM.SQL1.next;
end;
//выбор пользователя, который входил с этого компа и профиля
a:=GetUserName+'@'+GetComputerName;
DM.SimpleQ1('SELECT userid FROM USERS_LOGINS where LAST_ENTER_FROM like upper(%s)',[#39+a+#39]);
DM.GoToNumber(ComboBox1,dm.SQL1.Fields[0].asInteger);
end;

procedure TAuthDialog.ComboBox1MouseEnter(Sender: TObject);
begin
if (Sender as TCoolComboBox).tag=0 then begin
(Sender as TCoolComboBox).DroppedDown:=true;
(Sender as TCoolComboBox).tag:=1;
end;
end;

procedure TAuthDialog.ComboBox1Change(Sender: TObject);
begin
focusControl(edit1);
end;

procedure TAuthDialog.CoolBtn1Click(Sender: TObject);
var a,s:String;
id:integer;
begin
//узнать под какой ролью подключаться
id:=DM.NumFromCombo(ComboBox1);
DM.ConnectByGuest;
DM.SimpleQ1('SELECT login,srole from USERS_loginS Where userid=%d', [id ]);
a:=DM.SQL1.Fields[0].asstring;
s:=DM.SQL1.Fields[1].asstring;
DM.AUserRole:=s;
DM.Database.Close;
DM.Database.Params.Clear;
DM.Database.Params.add('user_name='+a);
DM.Database.Params.add('password='+edit1.text);
DM.Database.Params.add('sql_role_name='+s);
resultLabel.Caption:='Ок. Производим вход.';
resultLabel.font.color:=clGreen;
try DM.Database.Open; except
resultLabel.Caption:='Пароль неверный.';
resultLabel.font.color:=clred;
focusControl(edit1);
end;
resultLabel.visible:=true;
if DM.Database.Connected then begin
DM.AUserId:=id;
DM.SimpleQ1('SELECT ent,sex,fio FROM anketa_b WHERE id=%d',[id]);
DM.AUserEnt:=DM.SQL1.Fields[0].AsInteger;
DM.AUserSex:=DM.SQL1.Fields[1].AsString;
DM.AUserName:=DM.SQL1.Fields[2].AsString;
DM.SimpleQ1('SELECT ENT_NAME FROM ENTERPRISES WHERE id=%d',[DM.AUserEnt]);
DM.AUserEntName:=DM.SQL1.Fields[0].AsString;
//DM.fioDialog.ent:=dm.AUserEnt;
//запись профиля и компа с которого происходит вход
DM.SimpleQ1('EXECUTE PROCEDURE SET_LASTENTER(%d,%s)',
 [id,#39+GetUserName+'@'+GetComputerName+#39]);
timer1.Enabled:=false;
ModalResult := mrOk;
end;
end;

{procedure TAuthDialog.CoolBtn3Click(Sender: TObject);
var m:TMemoryStream;
    ini:TIniFile;
    a:string;
begin
CoolLabel6.Caption:=CoolLabel6.Caption+#13+'Скачивание новой версии. Может занять 1-5 минут.';
CoolBtn3.caption:='Скачивание...';
CoolBtn3.Enabled:=false;
application.ProcessMessages;
ini:=TIniFile.Create(DM.path+'connect.ini');
a:=ini.ReadString('Main','updateURL','localhost');
FreeAndNil(ini);
m:=TMemoryStream.Create;
try IdHTTP1.Get(a+'pack.zip',m);except
ShowMessage(IdHTTP1.Response.ResponseText);
if IdHTTP1.Response.ResponseText='HTTP/1.1 404 Not Found' then begin
CoolLabel6.Caption:=CoolLabel6.Caption+#13+'Невозможно скачать обновление.';
end;
end;
m.SaveToFile(DM.path+'pack.zip');
if fileexists(DM.path+'pack.zip') then begin//надо бы запустить обновление
ShellExecute(0,'open','updater.exe',nil,pchar(dm.path),SW_NORMAL);
close;
end;
CoolBtn3.Enabled:=true;
coolbtn3.Visible:=false;
coolbtn4.Visible:=true;
ProgressBar1.Visible:=true;
//close;
//ShowMessage(SysErrorMessage(GetLastError));
freeandnil(m);

end;}

procedure TAuthDialog.CoolBtn4Click(Sender: TObject);
begin
CoolGroupBox1.Visible:=true;
CoolBtn1.Visible:=true;
CoolBtn2.Visible:=true;
CoolBtn4.Visible:=false;
ProgressBar1.Visible:=false;
end;

procedure TAuthDialog.Timer1Timer(Sender: TObject);
var a:TCoolLabel;
    s:integer;
begin
//украшательство изменением цвета
a:=CoolLabel5;
s:=round(sin(a.Tag/57.32)*40)+200;
a.Font.color:=RGB(45,45,s);
//CoolLabel3.Caption:=intToStr(s);
a.Tag:=a.Tag+10;
end;

procedure TAuthDialog.IdHTTP1Work(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
if (IdHTTP1.Response.ContentLength<>-1) then begin
ProgressBar1.Max:=IdHTTP1.Response.ContentLength;
ProgressBar1.Position:=IdHTTP1.Response.ContentStream.Size;
end;
end;

end.
