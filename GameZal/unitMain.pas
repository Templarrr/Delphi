unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, math, ComCtrls;

type
  GameTable = class(TComponent)
  private
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    id : integer;
    name : string;
    typ : Integer;
    start : TDateTime;
    stop  : TDateTime;
    state : Integer;
    tarif : Double;
    num : Integer;
    procedure GroupBoxClick(Sender: TObject);

  public
    procedure ResetFields;
    procedure Tick;
    procedure GetState;
    constructor Create(id:Integer; name:string;typ:integer;num:Integer);
  end;
  TformMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    Timer1: TTimer;
    N12: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    procedure N9Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure Initiate;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N4Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure CloseTables;

var
  formMain: TformMain;
  xbox : array [0..99] of GameTable;
  tennis : array [0..99] of GameTable;
  num_xbox : integer;
  num_tennis : Integer;

implementation

uses unitLogin, unitTables, unitGames, unitUsers, unitTarifs, unitReport,
  unitGameBegin, unitGameEnd, unitGoodsIn, unitGoodsOut, unitSklad,
  unitRashod, unitInkasso;

{$R *.dfm}

{begin GameTable}
procedure GameTable.GroupBoxClick(Sender: TObject);
begin
  if Self.state=0 then
  begin

    unitGameBegin.table_name:=Self.name;
    unitGameBegin.table_id:=Self.id;
    formGameBegin.Label4.Caption:=Self.name;
    unitGameBegin.table_num:=Self.num;
    unitGameBegin.table_typ:=Self.typ;
    unitGameBegin.InitComboBox;
    formGameBegin.Show;
  end
  else
  begin
    unitGameEnd.table_name:=Self.name;
    unitGameEnd.table_id:=Self.id;
    unitGameEnd.table_tarif:=Self.tarif;
    unitGameEnd.table_num:=Self.num;
    unitGameEnd.table_typ:=Self.typ;
    formGameEnd.Label2.Caption:=FloatToStrF(Ceil(Self.tarif*((self.stop - self.start - 0.0007)*24)),ffFixed,5,2);
    formGameEnd.Label4.Caption:=FloatToStrF(Ceil(Self.tarif*((now-self.start)*24)),ffFixed,5,2);
    formGameEnd.Show;
  end;
end;

constructor GameTable.Create(id:Integer; name:string;typ:integer;num:Integer);
begin
  //inherited Create(self);
  Self.id := id;
  Self.Name := name;
  self.typ := typ;
  Self.num := num;

  GroupBox3 := TGroupBox.Create(Self);
  Label1 := TLabel.Create(Self);
  Label2 := TLabel.Create(Self);
  Label3 := TLabel.Create(Self);
  Label4 := TLabel.Create(Self);
  Label5 := TLabel.Create(Self);
  Label6 := TLabel.Create(Self);
  Label7 := TLabel.Create(Self);
  Label8 := TLabel.Create(Self);
  Label9 := TLabel.Create(Self);
  Label10 := TLabel.Create(Self);

  //GroupBox3
  GroupBox3.Name := 'GroupBox3';
  if (typ = 1)
  then
    GroupBox3.Parent := formMain.GroupBox1
  else
    GroupBox3.Parent := formMain.GroupBox2;
  GroupBox3.Left := 100*(num mod 5);
  GroupBox3.Top := 15+170*(num div 5);
  GroupBox3.Width := 100;
  GroupBox3.Height := 170;
  GroupBox3.Caption := name;
  GroupBox3.TabOrder := num;
  GroupBox3.Tag:=id;
  GroupBox3.OnClick := GroupBoxClick;

  //Label1
  Label1.Name := 'Label1';
  Label1.Parent := GroupBox3;
  Label1.Left := 10;
  Label1.Top := 15;
  Label1.Width := 74;
  Label1.Height := 13;
  Label1.Caption := 'начало сеанса';

  //Label2
  Label2.Name := 'Label2';
  Label2.Parent := GroupBox3;
  Label2.Left := 10;
  Label2.Top := 30;
  Label2.Width := 42;
  Label2.Height := 13;
  Label2.Caption := '00:00:00';

  //Label3
  Label3.Name := 'Label3';
  Label3.Parent := GroupBox3;
  Label3.Left := 10;
  Label3.Top := 45;
  Label3.Width := 69;
  Label3.Height := 13;
  Label3.Caption := 'конец сеанса';

  //Label4
  Label4.Name := 'Label4';
  Label4.Parent := GroupBox3;
  Label4.Left := 10;
  Label4.Top := 60;
  Label4.Width := 42;
  Label4.Height := 13;
  Label4.Caption := '00:00:00';

  //Label5
  Label5.Name := 'Label5';
  Label5.Parent := GroupBox3;
  Label5.Left := 10;
  Label5.Top := 75;
  Label5.Width := 37;
  Label5.Height := 13;
  Label5.Caption := 'таймер';

  //Label6
  Label6.Name := 'Label6';
  Label6.Parent := GroupBox3;
  Label6.Left := 10;
  Label6.Top := 90;
  Label6.Width := 42;
  Label6.Height := 13;
  Label6.Caption := '00:00:00';

  //Label7
  Label7.Name := 'Label7';
  Label7.Parent := GroupBox3;
  Label7.Left := 10;
  Label7.Top := 120;
  Label7.Width := 27;
  Label7.Height := 13;
  Label7.Caption := '00,00';

  //Label8
  Label8.Name := 'Label8';
  Label8.Parent := GroupBox3;
  Label8.Left := 10;
  Label8.Top := 105;
  Label8.Width := 31;
  Label8.Height := 13;
  Label8.Caption := 'тариф';

  //Label9
  Label9.Name := 'Label9';
  Label9.Parent := GroupBox3;
  Label9.Left := 10;
  Label9.Top := 135;
  Label9.Width := 33;
  Label9.Height := 13;
  Label9.Caption := 'сумма';

  //Label10
  Label10.Name := 'Label10';
  Label10.Parent := GroupBox3;
  Label10.Left := 10;
  Label10.Top := 150;
  Label10.Width := 27;
  Label10.Height := 13;
  Label10.Caption := '00,00';
end;
{end GameTable}

procedure TformMain.N9Click(Sender: TObject);
begin
  formLogin.Close;
end;

procedure TformMain.N7Click(Sender: TObject);
begin
  unitLogin.login := '';
  unitLogin.access_level := unitLogin.ANON_LEVEL;
  formLogin.editLogin.Text := '';
  formLogin.editPass.Text := '';
  formLogin.Show;
  formMain.Hide;
end;


procedure GameTable.GetState;
begin
  formLogin.ABSQuery2.SQL.Clear;
  formLogin.ABSQuery2.SQL.Add('select * from actions where table_id = :id and complete = 0');
  formLogin.ABSQuery2.ParamByName('id').AsInteger := self.id;
  formLogin.ABSQuery2.Open;
  if formLogin.ABSQuery2.RecordCount>0 then
  begin
    Self.state := 1;
    Self.start := formLogin.ABSQuery2.FieldByName('time_begin').AsDateTime;
    Self.stop  := formLogin.ABSQuery2.FieldByName('time_end').AsDateTime;
    Self.tarif := formLogin.ABSQuery2.FieldByName('tarif').AsFloat;
    Self.GroupBox3.Color:=clYellow;
  end
  else
  begin
    Self.state := 0;
    Self.start := 0;
    Self.stop  := 0;
    Self.tarif := 0;
    Self.GroupBox3.Color:=clLime;
  end;
end;

procedure GameTable.Tick;
var
  Cur : TDateTime;
begin
  if self.state=0 then exit;
  cur:=now;
  if Cur>Self.stop then Self.GroupBox3.Color:=clRed;
  Label2.Caption:=TimeToStr(Self.start);
  Label4.Caption:=TimeToStr(Self.stop);
  Label6.Caption:=TimeToStr(cur-Self.stop);
  Label7.Caption:=FloatToStrF(Self.tarif,ffFixed,5,2);
  Label10.Caption:=FloatToStrF(Ceil(Self.tarif*((cur-self.start)*24)),ffFixed,5,2);
end;

procedure CloseTables;
var
  i : integer;
begin
  if num_xbox > 0 then
  for i:=0 to num_xbox-1 do
    xbox[i].Destroy;
  if num_tennis > 0 then
  for i:=0 to num_tennis-1 do
    tennis[i].Destroy;
end;

procedure TformMain.Initiate;
var
  i : integer;
  name : string;
  id : Integer;

  Typ : Integer;
begin
  if unitLogin.access_level = unitLogin.ANON_LEVEL
  then formLogin.Close
  else
  begin
    if unitLogin.access_level = unitLogin.ADMIN_LEVEL
    then
    begin
      N5.Enabled:=false;
      N14.Enabled:=false;
    end;
    if unitLogin.access_level = unitLogin.OWNER_LEVEL
    then
    begin
      N5.Enabled:=true;
      N14.Enabled:=true;
    end;
    formLogin.ABSQuery1.SQL.Clear;
    formLogin.ABSQuery1.SQL.Add('select * from tables');
    formLogin.ABSQuery1.Open;
    if (formLogin.ABSQuery1.RecordCount > 0) then
    begin
      formLogin.ABSQuery1.First;
      num_xbox:=0;
      num_tennis:=0;
      for i:=1 to formLogin.ABSQuery1.RecordCount do
      begin
        typ:=formLogin.ABSQuery1.FieldByName('type').AsInteger;
        id := formLogin.ABSQuery1.FieldByName('id').AsInteger;
        name := formLogin.ABSQuery1.FieldByName('name').AsString;
        if Typ=2 then
        begin
          xbox[num_xbox]:=GameTable.Create(id,name,Typ,num_xbox);
          inc(num_xbox);
        end
        else
        begin
          tennis[num_tennis]:=GameTable.Create(id,name,Typ,num_tennis);
          inc(num_tennis);
        end;
        formLogin.ABSQuery1.Next;
      end;
      if num_xbox>0 then
        for i:=0 to num_xbox-1 do
          xbox[i].GetState;
      if num_tennis>0 then
        for i:=0 to num_tennis-1 do
          tennis[i].GetState;

    end;
  end;
end;

procedure TformMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := false;
  formLogin.Show;
end;

procedure TformMain.N4Click(Sender: TObject);
begin
  formTables.Show;
end;

procedure TformMain.N13Click(Sender: TObject);
begin
  formGames.Show;
end;

procedure TformMain.N5Click(Sender: TObject);
begin
  formUsers.Show;
end;

procedure TformMain.N14Click(Sender: TObject);
begin
  formTarifs.Show;
end;

procedure TformMain.N6Click(Sender: TObject);
begin
  unitReport.Initialize;
  formReport.Show;
end;

procedure TformMain.Timer1Timer(Sender: TObject);
var
  Cur : TDateTime;
  i : Integer;
begin
  Cur := Now;
  Caption:='Учет деятельности игрового зала'+' ['+unitLogin.login+'] '+DateTimeToStr(Cur);
  if num_xbox>0 then
    for i:=0 to num_xbox-1 do
      xbox[i].Tick;
  if num_tennis>0 then
    for i:=0 to num_tennis-1 do
      tennis[i].Tick;
end;

procedure GameTable.ResetFields;
begin
  Label2.Caption := '00:00:00';
  Label4.Caption := '00:00:00';
  Label6.Caption := '00:00:00';
  Label7.Caption := '00,00';
  Label10.Caption := '00,00';
end;

procedure TformMain.N11Click(Sender: TObject);
begin
  unitGoodsIn.InitComboBox;
  formGoodsIn.Show;
end;

procedure TformMain.N10Click(Sender: TObject);
begin
  unitGoodsOut.InitComboBox;
  formGoodsOut.Show;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
   Timer1.Enabled:=True;
end;

procedure TformMain.N12Click(Sender: TObject);
begin
  formSklad.show;
end;

procedure TformMain.N16Click(Sender: TObject);
begin
  formRashod.Hide;
  formRashod.Caption := 'Расходы';
  unitRashod.k := 1;
  formRashod.Show;
end;

procedure TformMain.N17Click(Sender: TObject);
begin
  formInkasso.Show;
end;

procedure TformMain.N18Click(Sender: TObject);
begin
  formRashod.Hide;
  formRashod.Caption := 'Доходы';
  unitRashod.k := -1;
  formRashod.Show;
end;

end.
