unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, ToolWin, Menus, IBEvents, DB,
  IBDatabase, IBCustomDataSet, IBQuery, ActnList, XPStyleActnCtrls, ActnMan, CoolCtrls, IBSQL;

type
  TChatInfo = class
    chatlines     : TStrings;
    userlist      : TStrings;
    messagestring : String;
    lastupd       : TDateTime;
    constructor Create (channel_id : integer);
    destructor  Destroy;
    procedure RecieveNewMessages;
    procedure RecieveChannelUsers;
  end;

  TChatForm = class(TForm)
    channels: TTabControl;
    tabimages: TImageList;
    status: TStatusBar;
    CoolBar1: TCoolBar;
    toolbar: TToolBar;
    messageEdit: TEdit;
    users: TListBox;
    Label1: TLabel;
    UserPopup: TPopupMenu;
    chat: TMemo;
    N1: TMenuItem;
    N2: TMenuItem;
    ToolButton1: TToolButton;
    Label2: TLabel;
    toolimages: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    N3: TMenuItem;
    NewMessageEvent: TIBEvents;
    ToolButton4: TToolButton;
    database: TIBDatabase;
    NewMesQuery: TIBQuery;
    AddMesQuery: TIBQuery;
    Actions: TActionManager;
    AddMessage: TAction;
    RecieveNewMessages: TAction;
    transaction: TIBTransaction;
    CommitQuery: TIBQuery;
    nickname: TComboBox;
    sql1: TIBSQL;
    procedure usersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShowStatusMessage(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure N3Click(Sender: TObject);
    procedure NewMessageEventEventAlert(Sender: TObject; EventName: String;
      EventCount: Integer; var CancelAlerts: Boolean);
    procedure AddMessageExecute(Sender: TObject);
    procedure messageEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RecieveNewMessagesExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ConnectByGuest;
    procedure ExecDB(sqlStr:string; sql:TIBSQL);
    procedure SimpleQ1(const Format: string; const Args: array of const);
    procedure GoToNumber(list:TCoolComboBox; num:integer); //в недрах комбо бокса есть число,  надо найти его и выделить.
    Function  NumFromCombo(list:TCoolComboBox):integer;
  private
    { Private declarations }
  public
    AUserId,AUserEnt:integer;
    AUserName,AUserSex,AUserEntName,AUserRole:String;
  end;

var
  ChatForm: TChatForm;

implementation

uses Auth;

{$R *.dfm}

procedure TChatForm.usersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then users.ItemIndex:=Y div users.ItemHeight;
end;

procedure TChatForm.ShowStatusMessage(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  status.Panels[0].Text:=TControl(Sender).Hint;
end;

procedure TChatForm.N3Click(Sender: TObject);
begin
  if users.ItemIndex<>-1 then messageEdit.Text:=users.Items[users.ItemIndex]+', '+messageEdit.Text;
end;

procedure TChatForm.NewMessageEventEventAlert(Sender: TObject;
  EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
begin
  Chat.Clear;
//  ShowMessage('test event catch! '+EventName);
  RecieveNewMessages.Execute;
end;

procedure TChatForm.AddMessageExecute(Sender: TObject);
var
  sql_str : string;
begin
    AddMesQuery.SQL.Clear;
    sql_str := 'insert into CHAT_MESSAGES (sender,receiver,msg) values ('+inttostr(nickname.ItemIndex)+',1001,'''+MessageEdit.Text+''');';
//    ShowMessage (sql_str);
    AddMesQuery.SQL.Add(sql_str);
    AddMesQuery.ExecSQL;
    commitquery.ExecSQL;
end;

procedure TChatForm.messageEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
  begin
    AddMessage.Execute;
    MessageEdit.Clear;
  end;
end;

procedure TChatForm.RecieveNewMessagesExecute(Sender: TObject);
begin
  {}

end;

procedure TChatForm.FormShow(Sender: TObject);
begin
  messageEdit.SetFocus;
  AuthForm.ShowModal;
//  RecieveNewMessages.Execute;
end;

procedure TChatForm.ConnectByGuest;
begin
  if database.connected then database.Close;
  database.Params.Clear;
  database.Params.add('user_name=login');
  database.Params.add('password=123');
  database.Params.add('sql_role_name=guest');
  database.Open;
end;

procedure TChatForm.ExecDB (sqlStr:string;sql:TIBSQL);
begin
  if not Transaction.active
    then Transaction.active:=true;
  try
    sql.CheckClosed;
  except
    sql.Close;
  end;
  sql.SQL.Clear;
  sql.SQL.Add(sqlStr);
  sql.Prepare;
  try
    sql.ExecQuery;
  except
    ShowMessage('Ошибка проиошла в запросе: '+#13+sqlStr);
  end;
end;


procedure TChatForm.SimpleQ1(const Format: string;
  const Args: array of const);
var sqlStr:string;
begin
  FmtStr(sqlStr, Format, Args);
  ExecDB(sqlStr,sql1);
end;

procedure TChatForm.GoToNumber(list: TCoolComboBox; num: integer);
var n:integer;
begin
  for n:=0 to list.Items.Count-1 do
    if integer(list.Items.Objects[n])=num then
    begin
      list.ItemIndex:=n;exit;
    end;
end;

function TChatForm.NumFromCombo(list:TCoolComboBox):integer;
begin
  if list.ItemIndex=-1 then exit;
  result:=integer(list.Items.Objects[list.ItemIndex]);
end;

{ TChatInfo }

constructor TChatInfo.Create(channel_id: integer);
begin
 {}
 self.messagestring:='';
 self.lastupd:=now()-3600;
 self.chatlines:=Tstrings.Create;
 self.userlist:=TStrings.Create;
 self.RecieveChannelUsers;
 self.RecieveNewMessages;
end;

destructor TChatInfo.Destroy;
begin
 self.chatlines.Destroy;
 self.userlist.Destroy;
end;

procedure TChatInfo.RecieveChannelUsers;
begin
  {}
end;

procedure TChatInfo.RecieveNewMessages;
begin
  {}
  ChatForm.commitquery.ExecSQL;
  ChatForm.NewMesQuery.Open;
  ChatForm.NewMesQuery.First;
  while (not ChatForm.NewMesQuery.Eof) do
  begin
    chatlines.Add('['+datetostr(ChatForm.NewMesQuery.FieldValues['DAT_SENT'])+' '+timetostr(ChatForm.NewMesQuery.FieldValues['DAT_SENT'])+'] '+ChatForm.nickname.Items[ChatForm.NewMesQuery.FieldValues['SENDER']]+': '+ChatForm.NewMesQuery.FieldValues['MSG']);
    ChatForm.NewMesQuery.Next;
  end;
  ChatForm.NewMesQuery.Close;
end;

end.
