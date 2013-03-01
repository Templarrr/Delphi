unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    Button1: TButton;
    Edit7: TEdit;
    Edit8: TEdit;
    Label7: TLabel;
    Button2: TButton;
    Edit9: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function Dice (K : integer;D : integer) : integer;
var
  res,i:integer;
begin
  res:=0;
  for i:=1 to K do
    res:=res+(1+Random(D));
  Result:=res;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Edit1.Text:=inttostr(Dice(3,6));
  Edit2.Text:=inttostr(Dice(3,6));
  Edit3.Text:=inttostr(Dice(3,6));
  Edit4.Text:=inttostr(Dice(3,6));
  Edit5.Text:=inttostr(Dice(3,6));
  Edit6.Text:=inttostr(Dice(3,6));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Edit9.Text:=inttostr(Dice(strtoint(Edit7.Text),strtoint(Edit8.Text)));
end;

end.
