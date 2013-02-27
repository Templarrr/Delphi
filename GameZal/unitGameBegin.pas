unit unitGameBegin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ABSMain;

type
  TformGameBegin = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Button1: TButton;
    ABSQuery1: TABSQuery;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure InitComboBox;

var
  formGameBegin: TformGameBegin;
  combovalues : array of Double;
  table_name : string;
  table_id : integer;
  table_num : integer;
  table_typ : Integer;

implementation

{$R *.dfm}

uses unitLogin,unitMain;

procedure InitComboBox;
var
  i : Integer;
  nam : string;
  cost:double;
  begin
    with formGameBegin do
    begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select * from tarifs where type = '+inttostr(table_typ));
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin
        ABSQuery1.First;
        SetLength(combovalues,ABSQuery1.RecordCount);
        formGameBegin.ComboBox1.Items.Clear;
        for i:=1 to ABSQuery1.RecordCount do
        begin
          nam := ABSQuery1.FieldByName('name').AsString;
          cost := ABSQuery1.FieldByName('cost').AsFloat;
          combovalues[ComboBox1.Items.Add(nam)]:=cost;
          ABSQuery1.Next;
        end;
        ComboBox1.ItemIndex:=0;
      end;
    end;
  end;

procedure TformGameBegin.Button1Click(Sender: TObject);
var
  time_begin,time_end : TDateTime;
begin
    time_begin := Now;
    time_end := Now+strtofloat(Edit1.Text)/24;
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('insert into actions (time_begin,time_end,table_id,tarif,login) values (:time_begin,:time_end,:table_id,:tarif,:login)');
      ABSQuery1.ParamByName('time_begin').AsDateTime:=time_begin;
      ABSQuery1.ParamByName('time_end').AsDateTime:=time_end;
      ABSQuery1.ParamByName('table_id').AsInteger:=table_id;
      ABSQuery1.ParamByName('tarif').AsFloat:=combovalues[ComboBox1.ItemIndex];
      ABSQuery1.ParamByName('login').AsString:=unitLogin.login;
      ABSQuery1.ExecSQL;
      if table_typ = 2 then
        unitMain.xbox[table_num].GetState
      else
        unitMain.tennis[table_num].GetState;
      formGameBegin.Close;

end;

procedure TformGameBegin.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

end.
