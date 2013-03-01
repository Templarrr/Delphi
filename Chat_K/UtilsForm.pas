unit UtilsForm;

interface

uses
  SysUtils, Classes, IBSQL, IBDatabase, DB,basic,forms, ImgList, Controls,
  CoolCtrlsDB,CoolCtrls, Dialogs, ExtDlgs,IniFiles,
  dlg_auth, math, IBCustomDataSet, IBQuery, shellapi;

type
  TDM = class(TDataModule)
    Database: TIBDatabase;
    Transaction: TIBTransaction;
    SQL1: TIBSQL;
    SQL2: TIBSQL;
    SQL3: TIBSQL;
    ImageList: TImageList;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenPictureDialog;
    SQL4: TIBDataSet;
    procedure ExecDB(sqlStr:string;sql:TIBSQL);
    procedure ExecDBQuery(sqlStr:string;sql:TIBDataSet);
    procedure SimpleQ1(const Format: string; const Args: array of const);
    procedure SimpleQ2(const Format: string; const Args: array of const);
    procedure SimpleQ3(const Format: string; const Args: array of const);
    procedure SimpleQ4(const Format: string; const Args: array of const);
//    procedure DataModuleCreate(Sender: TObject);
    function InitEnv():boolean;
//    procedure AppException(Sender: TObject; E: Exception);
    procedure AddToLog(str:string;fname:string='message.log');
    procedure GoToNumber(list:TCoolComboBox;num:integer);
    procedure GoToText(list:TCoolComboBox;str:string);
    Function NumFromCombo(list:TCoolComboBox):integer;
    Function StrFromCombo(list:TCoolComboBox):string;
    Function GetValueFromIni(paramname:string;default:string=''):string;
    procedure SetValueToIni(paramname,paramvalue:string);
//    procedure DataModuleDestroy(Sender: TObject);
    procedure DatabaseAfterConnect(Sender: TObject);
//    procedure SetMainMenuStatus;
//    procedure FREndDoc(Sender: TObject);
    procedure TablePost(table:TDataSet);
    procedure TableEdit(table:TDataSet);
    procedure TableInsert(table:TDataSet);
//    procedure Commit;
//    procedure Rollback;
    procedure ConnectByGuest;
//    Function Dlg_spec_execute(var obj:Tdlg_Speciality;mode,id:integer):boolean;
//    procedure ViewFileFromEdoc(table1: TIBDataSet);
    Function CountNotSignedDoc(id:integer=0):integer;
  private
    { Private declarations }
  public
  n:integer;
  path,FRStrResult:string;
  form:array[1..16] of TForm;
//  fioDialog:TFioSelecter;
//  dayDialog:Tdat_calc;
//  specDialog:Tdlg_Speciality;
  AuthDialog:TAuthDialog;
//  SignDialog:Tdlg_SignRequest;
//  ProgressWind:TThreadWindow;
  AUserId,AUserEnt:integer;
  AUserName,AUserSex,AUserEntName,AUserRole:String;
  marks:array[1..5] of TBookmark;
{
form[8]- semVed -form7
form[16]- AnketaAA -form14}
    { Public declarations }
  end;

var
  DM: TDM;

implementation

//uses mainmenu;


{$R *.dfm}

procedure TDM.ExecDB(sqlStr:string;sql:TIBSQL);
begin
if not DM.Transaction.active then DM.Transaction.active:=true;
try sql.CheckClosed; except sql.Close;end;
sql.SQL.Clear;
sql.SQL.Add(sqlStr);
sql.Prepare;
try sql.ExecQuery; except
ShowMessage('Ошибка проиошла в запросе: '+#13+sqlStr);
end;
end;

procedure TDM.ExecDBQuery(sqlStr:string;sql:TIBDataSet);
begin
if not DM.Transaction.active then DM.Transaction.active:=true;
try sql.Active:=false; except sql.Close;end;
sql.SelectSQL.Clear;
sql.SelectSQL.Add(sqlStr);
sql.Prepare;
try sql.Open; except
ShowMessage('Ошибка проиошла в запросе: '+#13+sqlStr);
end;
end;

procedure TDM.SimpleQ1(const Format: string; const Args: array of const);
var sqlStr:string;
begin
FmtStr(sqlStr, Format, Args);
ExecDB(sqlStr,sql1);
end;

procedure TDM.SimpleQ2(const Format: string; const Args: array of const);
var sqlStr:string;
begin
FmtStr(sqlStr, Format, Args);
ExecDB(sqlStr,sql2);
end;

procedure TDM.SimpleQ3(const Format: string; const Args: array of const);
var sqlStr:string;
begin
FmtStr(sqlStr, Format, Args);
ExecDB(sqlStr,sql3);
end;

procedure TDM.SimpleQ4(const Format: string; const Args: array of const);
var sqlStr:string;
begin
FmtStr(sqlStr, Format, Args);
ExecDBQuery(sqlStr,SQL4);
end;
{
procedure TDM.DataModuleCreate(Sender: TObject);
var ini:TIniFile;
    a,s:string;
begin
//назначим свой обработчик событий
//Application.OnException:=AppException;
path:=ExtractFilePath(ParamStr(0));
InitEnv();
Database.close;
//удалим временный файл обновлений
if fileexists(DM.path+'pack.zip') then deleteFile(DM.path+'pack.zip');
//создадим доступные всем компоненты
fioDialog:=TFioSelecter.create(nil);
fioDialog.visible:=false;
dayDialog:=Tdat_calc.Create(nil);
SignDialog:=Tdlg_SignRequest.create(nil);
DM.AuthDialog:=TAuthDialog.Create(nil);
DM.AuthDialog.Visible:=false;
//dayDialog.visible:=false;
//прочтем и установим хост
if Database.Connected then Database.Close;
ini:=TIniFile.Create(path+'connect.ini');
a:=ini.ReadString('Main','host','localhost');
s:=ini.ReadString('Main','DB','kenarius');
Database.DatabaseName:=a+':'+s;
FreeAndNil(ini);
Database.Connected:=true;
Transaction.Active:=true;
end;

procedure TDM.AppException(Sender: TObject; E: Exception);
begin
Application.ShowException(E);
//if e.ClassName='EIBInterBaseError' then A;
end;
}
function TDM.InitEnv():boolean; //проверяем наличие всех необходдимых папок и настроек, если вернем фалсе, то не надо запускать прогу
begin
if (not directoryexists(path+'log')) then CreateDir(path+'log');
if (not directoryexists(path+'lib')) then CreateDir(path+'lib');
if (not directoryexists(path+'tmp')) then CreateDir(path+'tmp');
end;

procedure TDM.AddToLog(str:string;fname:string='message.log');
var f:textfile;
begin
fname:=ChangeEmptyFileExt(fname,'log');
str:=DateTimeToStr(Now)+' '+str;
AddStrToFile(path+'log\'+fname,str,true);
end;

procedure TDM.GoToText(list:TCoolComboBox;str:string);//выделить строку комбобокса которая равна аргументу
var n:integer;
begin
for n:=0 to list.Items.Count-1 do begin
if list.Items[n]=str then begin
   list.ItemIndex:=n;exit;
   end;
end;
end;

procedure TDM.GoToNumber(list:TCoolComboBox;num:integer); //в недрах комбо бокса есть число,  надо найти его и выделить.
var n:integer;
begin
for n:=0 to list.Items.Count-1 do begin
if integer(list.Items.Objects[n])=num then begin
    list.ItemIndex:=n;exit;
    end;
end;
end;

Function TDM.NumFromCombo(list:TCoolComboBox):integer;
begin
if list.ItemIndex=-1 then exit;
result:=integer(list.Items.Objects[list.ItemIndex]);
end;

Function TDM.StrFromCombo(list:TCoolComboBox):string;
begin
result:=inttostr(NumFromCombo(list));
end;

Function TDM.GetValueFromIni(paramname:string;default:string=''):string;
begin //прочтем настройку этого пользователя
SimpleQ1('SELECT * FROM USERS_SETTINGS WHERE userid=%d AND PARAMNAME=%s',
 [AUserId,  #39+paramname+#39]);
if sql1.RecordCount=0 then begin//такой записи вообще нет, надо создать
SimpleQ2('INSERT INTO USERS_SETTINGS (USERID,PARAMNAME,PARAMVALUE) VALUES (%d,%s,%s)',
 [DM.AUserId,  #39+paramname+#39,  #39+default+#39 ]);
//добавив строку надо ее прочесть
try DM.sql1.CheckClosed; except sql1.Close;end;
DM.sql1.ExecQuery;
end;
result:=sql1.FieldByName('paramvalue').asString;
end;

procedure TDM.SetValueToIni(paramname,paramvalue:string);
begin
if paramname='' then paramname:='-0-!';
SimpleQ1('SELECT * FROM USERS_SETTINGS WHERE userid=%d AND PARAMNAME=%s',
 [AUserId,  #39+paramname+#39]);
if sql1.RecordCount=0 then begin//такой записи вообще нет, надо создать
SimpleQ2('INSERT INTO USERS_SETTINGS (USERID,PARAMNAME,PARAMVALUE) VALUES (%d,%s,%s)',
 [DM.AUserId,  #39+paramname+#39,  #39+paramvalue+#39 ]);
end else begin
SimpleQ2('UPDATE USERS_SETTINGS SET PARAMVALUE=%s WHERE userid=%d AND paramname=%s',
 [#39+paramvalue+#39,DM.AUserId,  #39+paramname+#39 ]);
end;
end;
{
procedure TDM.DataModuleDestroy(Sender: TObject);
var FileRec : TSearchRec;
begin
//очистим временную папку.
FindFirst(path+'tmp\*.*',faAnyFile,FileRec);
repeat
if FileRec.Attr<>faDirectory then deleteFile(path+'tmp\'+FileRec.Name);
until FindNext(FileRec) <> 0;
//разрушим доступные всем компоненты
FreeAndNil(fioDialog);
FreeAndNil(dayDialog);
IF AuthDialog<>nil then FreeAndNil(AuthDialog);
IF specDialog<>nil then FreeAndNil(specDialog);
IF SignDialog<>nil then FreeAndNil(SignDialog);
end;
}
procedure TDM.DatabaseAfterConnect(Sender: TObject);
begin
Transaction.Active:=true;
end;

{procedure TDM.SetMainMenuStatus();
begin //устанавливает активность или неактивность элементов, в зависимости от того, открыта ли форма какая-то или нет
exit; //пока не трогаю эту ф-цию. Если заблочить пункт вызова окна, то при открытом окне не получится выводить его наверх
//анкеты работников
form1.N2.Enabled:=(dm.form[2]=nil);
//справочник
form1.N1.Enabled:=(dm.form[1]=nil);
//анкеты курсантов
form1.N5.Enabled:=(dm.form[6]=nil);
//ведомости
form1.N7.Enabled:=(dm.form[8]=nil);
end;  }

{procedure TDM.FREndDoc(Sender: TObject);
begin
//if not DM.FR.Variables['outSQL'].isNull then
FRStrResult:=DM.FR.Variables['outSQL'];
end;}

procedure TDM.TablePost(table:TDataSet);
begin
if table.state=dsInactive then exit;
if table.state<>dsBrowse then table.post;
end;

procedure TDM.TableInsert(table:TDataSet);
begin
if table.state=dsInactive then table.open;
TablePost(table);
if table.state=dsBrowse then table.Insert;
end;

procedure TDM.TableEdit(table:TDataSet);
begin
if table.state=dsBrowse then table.edit;
end;

{procedure TDM.Commit;
begin
form1.N3Click(nil);
end;

procedure TDM.RollBack;
begin
form1.N8Click(nil);
end;}

procedure TDM.ConnectByGuest;
begin
if database.connected then Database.Close;
Database.Params.Clear;
Database.Params.add('user_name=login');
Database.Params.add('password=123');
Database.Params.add('sql_role_name=GUEST');
Database.Open;
end;

{Function TDM.Dlg_spec_execute(var obj:Tdlg_Speciality;mode,id:integer):boolean;
begin
//mode: 0=edit, 1=view
if obj=nil then obj:=Tdlg_Speciality.Create(nil);
result:=obj.Execute(mode,id);
end;}

{procedure TDM.ViewFileFromEdoc(table1: TIBDataSet);
var ext,fname,nam,editor:string;
begin
editor:='';
if table1.fieldbyname('data').asstring='' then begin ShowMessage('Изображение не загружено.');exit;end;
ext:=table1.fieldbyName('ftype').AsString;
//if ext='DJVU'
if (ext='GIF') or (ext='TIF') or (ext='PNG') or (ext='BMP') or (ext='JPG')
  then editor:='irfan';
if (ext='DJVU') then editor:='djvu';
if (ext='DOC') or (ext='XLS') then editor:='shell';
//приступаем к показу
nam:=table1.fieldbyName('subj').AsString+table1.fieldbyName('num').AsString;
nam:=ReplaceStr(nam,'\','_');
nam:=ReplaceStr(nam,'/','_');
nam:=ReplaceStr(nam,'"',#39);
nam:=ReplaceStr(nam,':','_');
fname:=format(dm.path+'tmp\%s.%s',[
nam,ext ]);
//отметим в журнале обращение к файлу.
dm.simpleq2('INSERT INTO ORDERS_STORAGE_LOG (USERID,SUBID,ACT,fname) VALUES (%d,%d,0,%s)',
[dm.auserId,table1.fieldByName('id').asinteger,#39+getComputername+'\'+GetUserName+#39 ]);
if editor='irfan' then begin
BlobToFile(table1,'data',fname);
ShellExecute(form1.Handle,'open',pchar(dm.path+'lib\IrfanView\i_view32.exe '),pchar(fname),'',0	);
end;

if editor='djvu' then begin
BlobToFile(table1,'data',fname);
ShellExecute(form1.Handle,'open',pchar(dm.path+'lib\WinDjView\WinDjView-0.5.exe '),pchar(#34+fname+#34),'',1);
end;
if editor='shell' then begin
BlobToFile(table1,'data',#34+fname+#34);
ShellExecute(form1.handle,'open',pchar(#34+fname+#34),nil,nil,1);
end;

if editor='' then begin
ShowMessage('Не понятно, чем обрабатывать расширение: '+ext+' Сохраните и разбирайтесь сами.');
//SaveFile(nil);
end;
DM.Commit;
end;}

Function TDM.CountNotSignedDoc(id:integer=0):integer;
begin //подсчет числа документов с которыми еще надо ознакомиться
if id=0 then id:=AUserId;
DM.SimpleQ3('SELECT count(*) from ORDERS_SUBDATA where userId=%d AND signdate is null', [id]);
result:=DM.SQL3.Fields[0].asInteger;
end;



end.
