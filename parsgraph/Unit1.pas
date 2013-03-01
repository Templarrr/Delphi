unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, TeEngine, Series, ExtCtrls, TeeProcs, Chart;

type
  TForm1 = class(TForm)
    Chart1: TChart;
    Series1: TLineSeries;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Button1: TButton;
    GroupBox3: TGroupBox;
    Edit4: TEdit;
    Label4: TLabel;
    Edit5: TEdit;
    Label5: TLabel;
    Edit6: TEdit;
    Label6: TLabel;
    Button2: TButton;
    RadioGroup1: TRadioGroup;
    Series2: TPointSeries;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function rightpos (substr:string ;str : string) : integer;
var
  res : integer;
begin
  if pos(substr,str)=0 then res:=0
  else res:=length(str)+2-length(substr)-pos(reversestring(substr),reversestring(str));
  rightpos:=res;
end;

function rightposprime (substr:string ;str : string) : integer;
var
  res : integer;
  f   : integer;
  counter : integer;
begin
  res:=0;
  counter:=0;
  for f:=length(str) downto 1 do
  begin
    if str[f]=')' then inc(counter);
    if str[f]='(' then dec(counter);
    if (str[f]=substr[1]) and (counter=0) then
    begin
      res:=f;
      break;
    end;
  end;
  rightposprime:=res;
end;


function parser (pstring:string;x:real) : real;
var
  res : real;
//  ps : integer;
  errcode : integer;
begin
    val(pstring,res,errcode);
    if errcode<>0 then
    if rightposprime('+',pstring)<>0 then
      res:=parser(copy(pstring,1,rightposprime('+',pstring)-1),x)
          +parser(copy(pstring,rightposprime('+',pstring)+1,length(pstring)-rightposprime('+',pstring)),x)
    else
    if rightposprime('-',pstring)<>0 then
      if rightposprime('-',pstring)<>1 then
        res:=parser(copy(pstring,1,rightposprime('-',pstring)-1),x)
            -parser(copy(pstring,rightposprime('-',pstring)+1,length(pstring)-rightposprime('-',pstring)),x)
      else
        res:=-1 * parser(copy(pstring,2,length(pstring)-1),x)
    else
    if rightposprime('*',pstring)<>0 then
      res:=parser(copy(pstring,1,rightposprime('*',pstring)-1),x)
          *parser(copy(pstring,rightposprime('*',pstring)+1,length(pstring)-rightposprime('*',pstring)),x)
    else
    if rightposprime('/',pstring)<>0 then
      res:=parser(copy(pstring,1,rightposprime('/',pstring)-1),x)
          /parser(copy(pstring,rightposprime('/',pstring)+1,length(pstring)-rightposprime('/',pstring)),x)
    else
    if pstring[1]='(' then
      res:=parser(copy(pstring,2,length(pstring)-2),x)
    else
    if pos('sin(',pstring)=1 then
      res:=sin(parser(copy(pstring,5,length(pstring)-5),x))
    else
    if pos('cos(',pstring)=1 then
      res:=cos(parser(copy(pstring,5,length(pstring)-5),x))
    else
    if pos('exp(',pstring)=1 then
      res:=exp(parser(copy(pstring,5,length(pstring)-5),x))
    else
    if pos('ln(',pstring)=1 then
      res:=ln(parser(copy(pstring,4,length(pstring)-4),x))
    else
    if pos('sqrt(',pstring)=1 then
      res:=sqrt(parser(copy(pstring,6,length(pstring)-6),x))
    else
    if rightpos('+',pstring)<>0 then
      res:=parser(copy(pstring,1,rightpos('+',pstring)-1),x)
          +parser(copy(pstring,rightpos('+',pstring)+1,length(pstring)-rightpos('+',pstring)),x)
    else
    if rightpos('-',pstring)<>0 then
      if rightpos('-',pstring)<>1 then
        res:=parser(copy(pstring,1,rightpos('-',pstring)-1),x)
          -parser(copy(pstring,rightpos('-',pstring)+1,length(pstring)-rightpos('-',pstring)),x)
      else
        res:=-1 * parser(copy(pstring,2,length(pstring)-1),x)
    else
    if rightpos('*',pstring)<>0 then
      res:=parser(copy(pstring,1,rightpos('*',pstring)-1),x)
          *parser(copy(pstring,rightpos('*',pstring)+1,length(pstring)-rightpos('*',pstring)),x)
    else
    if rightpos('/',pstring)<>0 then
      res:=parser(copy(pstring,1,rightpos('/',pstring)-1),x)
          /parser(copy(pstring,rightpos('/',pstring)+1,length(pstring)-rightpos('/',pstring)),x)
    else
    if (pstring='x') then
      res:=x
    else
    if (pstring='') then
      res:=0;

    parser:=res;
end;

function skipspaces(str:string) : string;
var
  res:string;
begin
  res:=str;
  while(pos(' ',res)<>0) do
    res:=copy(res,1,pos(' ',res)-1)+copy(res,pos(' ',res)+1,length(res)-pos(' ',res));
  skipspaces :=res;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  x : real;
  pstr : string;
begin
  pstr:=Edit1.Text;
  pstr:=skipspaces(pstr);
  x:=strtofloat(Edit2.Text);
  Edit3.Text:=floattostr(parser(pstr,x));

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  x,y : real;
  pstr : string;
  a,b,dx : real;
begin
  Series1.Clear;
  Series2.Clear;
  pstr:=Edit1.Text;
  pstr:=skipspaces(pstr);
  a:=strtofloat(Edit4.Text);
  b:=strtofloat(Edit5.Text);
  dx:=strtofloat(Edit6.Text);
  x:=a;
  While(x<=b) do
  begin
    try
      y:=parser(pstr,x);
      Series1.AddXY(x,y);
      Series2.AddXY(x,y);
      x:=x+dx;
    except
      x:=x+dx;
    end;
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex=1 then
  begin
    Series1.LinePen.Visible:=false;
    Series2.Pointer.Visible:=true;
  end
  else
  begin
    Series1.LinePen.Visible:=true;
    Series2.Pointer.Visible:=false;
  end

end;

end.
