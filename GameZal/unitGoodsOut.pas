unit unitGoodsOut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ABSMain, StdCtrls, Mask;

type
  TformGoodsOut = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    ABSQuery1: TABSQuery;
    Label2: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure InitComboBox;

var
  formGoodsOut: TformGoodsOut;
  combovalues : array of Integer;
  combovalues2 : array of double;
  combovalues3 : array of Integer;

implementation

uses unitGameBegin, unitLogin;

{$R *.dfm}

procedure InitComboBox;
var
  i : Integer;
  nam : string;
  id,col,f:integer;
  cost:double;
  test : string;
  begin
    with formGoodsOut do
    begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select * from tables');
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin
        ABSQuery1.First;
        SetLength(combovalues,ABSQuery1.RecordCount);
        ComboBox1.Items.Clear;
        for i:=1 to ABSQuery1.RecordCount do
        begin
          nam := ABSQuery1.FieldByName('name').AsString;
          id := ABSQuery1.FieldByName('id').AsInteger;
          combovalues[ComboBox1.Items.Add(nam)]:=id;
          ABSQuery1.Next;
        end;
        ComboBox1.ItemIndex:=0;
      end;

      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('select * from sklad where col>0 order by name');
      ABSQuery1.Open;
      if (ABSQuery1.RecordCount > 0) then
      begin
        ABSQuery1.First;
        SetLength(combovalues2,ABSQuery1.RecordCount);
        SetLength(combovalues3,ABSQuery1.RecordCount);
        ComboBox2.Items.Clear;
        for i:=1 to ABSQuery1.RecordCount do
        begin
          nam := ABSQuery1.FieldByName('name').AsString;
          cost := ABSQuery1.FieldByName('cost').AsFloat;
          col := ABSQuery1.FieldByName('col').AsInteger;
          f:=ComboBox2.Items.Add(nam);
          combovalues2[f]:=cost;
          combovalues3[f]:=col;

          ABSQuery1.Next;
        end;
        ComboBox2.ItemIndex:=0;
        test := FloatToStrF(combovalues2[0],ffFixed,5,2);
        Edit1.Text:=test;
      end;
    end;
  end;

procedure TformGoodsOut.Button1Click(Sender: TObject);
begin
  if (strtoint(Edit2.Text) <= combovalues3[ComboBox2.ItemIndex]) then
begin
      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('insert into goods_out (name,cost,col,summ,dat,table_id,login) values (:name,:cost,:col,:summ,:dat,:table_id,:login)');
      ABSQuery1.ParamByName('dat').AsDateTime:=now;
      ABSQuery1.ParamByName('name').AsString:=ComboBox2.Text;
      ABSQuery1.ParamByName('login').AsString:=unitLogin.login;
      ABSQuery1.ParamByName('cost').AsFloat:=StrToFloat(Edit1.Text);
      ABSQuery1.ParamByName('col').AsInteger:=StrToInt(Edit2.Text);
      ABSQuery1.ParamByName('summ').AsFloat:=StrToFloat(Edit1.Text)*StrToInt(Edit2.Text);
      ABSQuery1.ParamByName('table_id').AsInteger:=combovalues[ComboBox1.ItemIndex];
      ABSQuery1.ExecSQL;

      ABSQuery1.SQL.Clear;
      ABSQuery1.SQL.Add('update sklad set col = col - :col where name = :name');
      ABSQuery1.ParamByName('name').AsString:=ComboBox2.Text;
      ABSQuery1.ParamByName('col').AsInteger:=StrToInt(Edit2.Text);
      ABSQuery1.ExecSQL;

      Close;
end
else
  ShowMessage('Ќа складе нет достаточного количества товара - '+inttostr(combovalues3[ComboBox2.ItemIndex]));
end;

procedure TformGoodsOut.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
   Edit2.Text := '1';
end;

procedure TformGoodsOut.ComboBox2Change(Sender: TObject);
begin
  Edit1.Text := FloatToStrF(combovalues2[ComboBox2.ItemIndex],ffFixed,5,2);
end;

procedure TformGoodsOut.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '.' then Key:= ',';
end;

end.
