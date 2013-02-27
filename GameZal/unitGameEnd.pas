unit unitGameEnd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ABSMain;

type
  TformGameEnd = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ABSQuery1: TABSQuery;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations}
  public
    { Public declarations}
  end;

var
  formGameEnd: TformGameEnd;
  table_name : string;
  table_id : integer;
  table_num : integer;
  table_typ : Integer;
  table_tarif : Double;
  summ : double;

implementation

{$R *.dfm}

uses unitMain;

procedure TformGameEnd.Button3Click(Sender: TObject);
begin
  ABSQuery1.SQL.Clear;
  ABSQuery1.SQL.Add('delete from actions where table_id = :id and complete = 0');
  ABSQuery1.ParamByName('id').AsInteger := table_id;
  ABSQuery1.ExecSQL;

  if table_typ = 2 then
  begin
    unitMain.xbox[table_num].GetState;
    unitMain.xbox[table_num].ResetFields;
  end
  else
  begin
    unitMain.tennis[table_num].GetState;
    unitMain.tennis[table_num].ResetFields;
  end;
  formGameEnd.Close;
end;

procedure CompleteGame;
begin
  with formGameEnd do
  begin
    ABSQuery1.SQL.Clear;
    ABSQuery1.SQL.Add('update actions set summ=:summ, time_end=:time_end, complete=1 where table_id = :id and complete = 0');
    ABSQuery1.ParamByName('summ').AsFloat := summ;
    ABSQuery1.ParamByName('id').AsInteger := table_id;
    ABSQuery1.ParamByName('time_end').AsDateTime := Now;
    ABSQuery1.ExecSQL;
  end;
  if table_typ = 2 then
  begin
    unitMain.xbox[table_num].GetState;
    unitMain.xbox[table_num].ResetFields;
  end
  else
  begin
    unitMain.tennis[table_num].GetState;
    unitMain.tennis[table_num].ResetFields;
  end;
  formGameEnd.Close;
end;

procedure TformGameEnd.Button1Click(Sender: TObject);
begin
  summ:=StrToFloat(Label2.Caption);
  CompleteGame;
end;

procedure TformGameEnd.Button2Click(Sender: TObject);
begin
  summ:=StrToFloat(Label4.Caption);
  CompleteGame;
end;

procedure TformGameEnd.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

end.
