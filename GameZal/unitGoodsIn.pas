unit unitGoodsIn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ABSMain, StdCtrls, Mask;

type
  TformGoodsIn = class(TForm)
    Label3: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    ABSQuery1: TABSQuery;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure InitComboBox;

var
  formGoodsIn: TformGoodsIn;

implementation

{$R *.dfm}

uses unitLogin;

procedure InitComboBox;
var
  i : Integer;
  nam : string;
  id,col,f:integer;
  cost:double;
  test : string;
begin
    with formGoodsIn do
    begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select * from tables');
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin

      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select * from sklad order by name');
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin
        ABSQuery1.First;
        ComboBox2.Items.Clear;
        for i:=1 to ABSQuery1.RecordCount do
        begin
          nam := ABSQuery1.FieldByName('name').AsString;
          f:=ComboBox2.Items.Add(nam);
          ABSQuery1.Next;
        end;
        ComboBox2.ItemIndex:=0;
      end;
    end;
  end;
end;

procedure TformGoodsIn.Button1Click(Sender: TObject);
var
  id : integer;
begin
  if ComboBox2.Text<>'' then
  begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('insert into goods_in (name,cost,col,summ,dat,login) values (:name,:cost,:col,:summ,:dat,:login)');
      ABSQuery1.ParamByName('dat').AsDateTime:=now;
      ABSQuery1.ParamByName('name').AsString:=ComboBox2.Text;
      ABSQuery1.ParamByName('login').AsString:=unitLogin.login;
      ABSQuery1.ParamByName('cost').AsFloat:=StrToFloat(Edit1.Text);
      ABSQuery1.ParamByName('col').AsInteger:=StrToInt(Edit2.Text);
      ABSQuery1.ParamByName('summ').AsFloat:=StrToFloat(Edit1.Text)*StrToInt(Edit2.Text);
      ABSQuery1.ExecSQL;


      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select id from sklad where name = :name');
      ABSQuery1.ParamByName('name').AsString:=ComboBox2.Text;
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin
        ABSQuery1.First;
        id  := ABSQuery1.FieldByName('id').AsInteger;

        ABSQuery1.SQL.Clear;
        ABSQuery1.SQL.Add('update sklad set col = col + :col where id = :id');
        ABSQuery1.ParamByName('id').AsInteger:=id;
        ABSQuery1.ParamByName('col').AsInteger:=StrToInt(Edit2.Text);
        ABSQuery1.ExecSQL;
        
      end
      else
      begin
        ABSQuery1.SQL.Clear;
        ABSQuery1.SQL.Add('insert into sklad (name,cost,col) values (:name,:cost,:col)');
        ABSQuery1.ParamByName('name').AsString:=ComboBox2.Text;
        ABSQuery1.ParamByName('cost').AsFloat:=StrToFloat(Edit1.Text);
        ABSQuery1.ParamByName('col').AsInteger:=StrToInt(Edit2.Text);
        ABSQuery1.ExecSQL;
        Close;

        ShowMessage('ѕоступил новый товар. ¬оздержитесь от продаж, пока владелец не укажет стоимость.');
      end;
      Close;
  end
  else
    ShowMessage('«аполните наименование товара');
end;

procedure TformGoodsIn.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
   ComboBox2.Text := '';
   Edit1.Text := '';
   Edit2.Text := '1';
end;

procedure TformGoodsIn.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
if Key = '.' then Key:= ',';
end;

end.
