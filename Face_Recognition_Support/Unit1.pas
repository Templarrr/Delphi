unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Button1: TButton;
    Image1: TImage;
    Image2: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  source : TBitmap;


implementation

{$R *.dfm}

procedure FreeCanvas (input:TImage);
begin
  input.Canvas.Pen.Color:=clWhite;
  input.Canvas.Brush.Color:=clWhite;
  input.Canvas.Rectangle(0,0,Form1.Image1.Width,Form1.Image1.Height);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  source:=TBitmap.Create;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  source.Free;
end;

function greyscale (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  r,g,b : byte;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      b:=input.Canvas.Pixels[i,j] div 65536;
      g:=(input.Canvas.Pixels[i,j] - 65536*b) div 256;
      r:=(input.Canvas.Pixels[i,j] - 65536*b - 256*g);
      output.Canvas.Pixels[i,j]:=(65536+256+1)*round(0.11*r+0.59*g+0.3*b);
    end;

  input.Free;
  Result :=output;
end;

function avtokontrastSM (input : TBitmap; m_normal : integer; sig_normal : integer) : TBitmap;
var
  i,j : integer;
  sum, count :longint;
  l_med,r_med : longint;
  md : byte;
  m,sig : double;
  light : integer;
  lights:array [0..255] of longint;
  k : double;
  output:TBitmap;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  sum:=0;
  count:=0;
  l_med:=0;
  r_med:=0;

  sig:=0;
  for i:=0 to 255 do
    lights[i]:=0;

  {загрузка и анализ изображения}
  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      sum :=sum+light;
      inc(count);
      inc(lights[light]);
    end;

  {среднее значение освещенности}
  m:=sum/count;


  {нахождение медианы}
  i:=0;
  j:=255;
  Repeat
    if l_med<r_med then
    begin
      l_med:=l_med+lights[i];
      inc(i);
    end
    else
    if l_med=r_med then
    begin
      l_med:=l_med+lights[i];
      inc(i);
      r_med:=r_med+lights[j];
      dec(j);
    end
    else
    begin
      r_med:=r_med+lights[j];
      dec(j);
    end;
  Until i>=j;
  md:=i;

  {среднеквадратическое отклонение}
  for i:=0 to 255 do
    sig:=sig+lights[i]*sqr(i-m);
    sig:=sig/count; //дисперсия
    sig:=sqrt(sig); //отклонение

  k:=sig_normal/sig;



  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      light:=round(m_normal+(light-m)*k);
      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;

  //input.Free;
  Result :=output;

end;

function avtokontrast (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : byte;
  max_light,min_light : byte;
  k : double;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  max_light:=0;
  min_light:=255;

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      if light>max_light then max_light:=light;
      if light<min_light then min_light:=light;
    end;
  k:=255/(max_light-min_light);

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      light:=round((light-min_light)*k);
      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;

  //input.Free;
  Result :=output;
end;

function laplas4 (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      light:=4*(input.Canvas.Pixels[i,j] mod 256)-
            (input.Canvas.Pixels[i+1,j] mod 256)-
            (input.Canvas.Pixels[i-1,j] mod 256)-
            (input.Canvas.Pixels[i,j+1] mod 256)-
            (input.Canvas.Pixels[i,j-1] mod 256);

      light:=light+128;

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function laplasMod (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=9*(input.Canvas.Pixels[i,j] mod 256)-
            2*(input.Canvas.Pixels[i+1,j] mod 256)-
            2*(input.Canvas.Pixels[i-1,j] mod 256)-
            2*(input.Canvas.Pixels[i,j+1] mod 256)-
            2*(input.Canvas.Pixels[i,j-1] mod 256);

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function box3 (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      light:=round(((input.Canvas.Pixels[i,j] mod 256)+
             (input.Canvas.Pixels[i+1,j] mod 256)+
             (input.Canvas.Pixels[i-1,j] mod 256)+
             (input.Canvas.Pixels[i,j+1] mod 256)+
             (input.Canvas.Pixels[i,j-1] mod 256)+
             (input.Canvas.Pixels[i+1,j+1] mod 256)+
             (input.Canvas.Pixels[i-1,j-1] mod 256)+
             (input.Canvas.Pixels[i-1,j+1] mod 256)+
             (input.Canvas.Pixels[i+1,j-1] mod 256))/9);

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function deriche (input : TBitmap; alph:double) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  im1,im2 : integer;
  ip,ip1,ip2 : integer;
  jm1,jm2 : integer;
  jp,jp1,jp2 : integer;
  light : int64;
  c,k : double; //константы в формулах Дериша

  S : array of array of double;
  x_plus,x_minus : array of double;
  R : array of array of double;
  R_vert : array of array of double;
  r_plus, r_minus : array of double;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  c:=-(1-exp(-alph));
  k:=sqr(c)/(1+2*alph*exp(-alph)-exp(-2*alph));

  setlength(x_plus,input.Width);
  for i:=0 to input.Width-1 do x_plus[i]:=0;
  setlength(x_minus,input.Width);
  for i:=0 to input.Width-1 do x_minus[i]:=0;
  setlength(S,input.Width,input.Height);

  setlength(r_plus,input.Height);
  for j:=0 to input.Height-1 do r_plus[j]:=0;
  setlength(r_minus,input.Height);
  for j:=0 to input.Height-1 do r_minus[j]:=0;
  setlength(R,input.Width,input.Height);

for j:=0 to input.Height-1 do
begin
  for i:=0 to input.Width-1 do
    begin
      im1:=i-1; if im1<0 then im1:=im1+input.Width;
      im2:=i-2; if im2<0 then im2:=im2+input.Width;
      ip:=input.Width-1-i;
      ip1:=ip+1; if ip1>=input.Width then ip1:=ip1-input.Width;
      ip2:=ip+2; if ip2>=input.Width then ip2:=ip2-input.Width;
      x_plus[i]:=(input.Canvas.Pixels[im1,j] mod 256)+
                  2*exp(-alph)*x_plus[im1]-
                  exp(-2*alph)*x_plus[im2];
      x_minus[ip]:=(input.Canvas.Pixels[ip1,j] mod 256)+
                  2*exp(-alph)*x_minus[ip1]-
                  exp(-2*alph)*x_minus[ip2];



    end;
  for i:=0 to input.Width-1 do
    S[i,j]:=c*(x_plus[i]-x_minus[i]);
end;

for i:=0 to input.Width-1 do
begin
  for j:=0 to input.Height-1 do
  begin
      jm1:=j-1; if jm1<0 then jm1:=jm1+input.Height;
      jm2:=j-2; if jm2<0 then jm2:=jm2+input.Height;
      jp:=input.Height-1-j;
      jp1:=jp+1; if jp1>=input.Height then jp1:=jp1-input.Height;
      jp2:=jp+2; if jp2>=input.Height then jp2:=jp2-input.Height;

      r_plus[j]:=k*S[i,j]+
                 k*exp(-alph)*(alph-1)*S[i,jm1]+
                 2*exp(-alph)*r_plus[jm1]-
                 exp(-2*alph)*r_plus[jm2];
      r_minus[jp]:=k*exp(-alph)*(alph+1)*S[i,jp1]-
                  exp(-2*alph)*S[i,jp2]+
                  2*exp(-alph)*r_minus[jp1]-
                  exp(-2*alph)*r_minus[jp2];
  end;

  for j:=0 to input.Height-1 do
  begin
    R[i,j]:=r_plus[j]+r_minus[j];
  end;
end;

{vertical}
 setlength(x_plus,input.Height);
  for i:=0 to input.Height-1 do x_plus[i]:=0;
  setlength(x_minus,input.Height);
  for i:=0 to input.Height-1 do x_minus[i]:=0;
  setlength(S,input.Width,input.Height);
  setlength(r_plus,input.Width);
  for j:=0 to input.Width-1 do r_plus[j]:=0;
  setlength(r_minus,input.Width);
  for j:=0 to input.Width-1 do r_minus[j]:=0;
  setlength(R_vert,input.Width,input.Height);

for i:=0 to input.Width-1 do
begin
  for j:=0 to input.Height-1 do
    begin
      jm1:=j-1; if im1<0 then im1:=im1+input.Height;
      jm2:=j-2; if im2<0 then im2:=im2+input.Height;
      jp:=input.Height-1-j;
      jp1:=jp+1; if jp1>=input.Height then jp1:=jp1-input.Height;
      jp2:=jp+2; if jp2>=input.Height then jp2:=jp2-input.Height;

      x_plus[j]:=(input.Canvas.Pixels[i,jm1] mod 256)+
                 2*exp(-alph)*x_plus[jm1]-
                 exp(-2*alph)*x_plus[jm2];
      x_minus[jp]:=(input.Canvas.Pixels[i,jp1] mod 256)+
                 2*exp(-alph)*x_minus[jp1]-
                 exp(-2*alph)*x_minus[jp2];



    end;
  for j:=0 to input.Height-1 do
    S[i,j]:=c*(x_plus[j]-x_minus[j]);
end;

for j:=0 to input.Height-1 do
begin
  for i:=0 to input.Width-1 do
  begin
      im1:=i-1; if im1<0 then im1:=im1+input.Width;
      im2:=i-2; if im2<0 then im2:=im2+input.Width;
      ip:=input.Width-1-i;
      ip1:=ip+1; if ip1>=input.Width then ip1:=ip1-input.Width;
      ip2:=ip+2; if ip2>=input.Width then ip2:=ip2-input.Width;

      r_plus[i]:=k*S[i,j]+
                 k*exp(-alph)*(alph-1)*S[im1,j]+
                 2*exp(-alph)*r_plus[im1]-
                 exp(-2*alph)*r_plus[im2];
      r_minus[ip]:=k*exp(-alph)*(alph+1)*S[ip1,j]-
                  exp(-2*alph)*S[ip2,j]+
                  2*exp(-alph)*r_minus[ip1]-
                  exp(-2*alph)*r_minus[ip2];
  end;

  for i:=0 to input.Width-1 do
  begin
    R_vert[i,j]:=r_plus[i]+r_minus[i];
  end;
end;

{/vertical}
for i:=0 to input.Width-1 do
  for j:=0 to input.Height-1 do
  begin
      light:=round(256-sqrt(sqr(R[i,j])+sqr(R_vert[i,j])));
      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
  end;

  //input.Free;
  Result :=output;
end;

function gauss5 (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=2 to input.Width-3 do
    for j:=2 to input.Height-3 do
    begin
      light:=round((2*(input.Canvas.Pixels[i-2,j-2] mod 256)+
             4*(input.Canvas.Pixels[i-2,j-1] mod 256)+
             5*(input.Canvas.Pixels[i-2,j] mod 256)+
             4*(input.Canvas.Pixels[i-2,j+1] mod 256)+
             2*(input.Canvas.Pixels[i-2,j+2] mod 256)+
             4*(input.Canvas.Pixels[i-1,j-2] mod 256)+
             9*(input.Canvas.Pixels[i-1,j-1] mod 256)+
             12*(input.Canvas.Pixels[i-1,j] mod 256)+
             9*(input.Canvas.Pixels[i-1,j+1] mod 256)+
             4*(input.Canvas.Pixels[i-1,j+2] mod 256)+
             5*(input.Canvas.Pixels[i,j-2] mod 256)+
             12*(input.Canvas.Pixels[i,j-1] mod 256)+
             15*(input.Canvas.Pixels[i,j] mod 256)+
             12*(input.Canvas.Pixels[i,j+1] mod 256)+
             5*(input.Canvas.Pixels[i,j+2] mod 256)+
             4*(input.Canvas.Pixels[i+1,j-2] mod 256)+
             9*(input.Canvas.Pixels[i+1,j-1] mod 256)+
             12*(input.Canvas.Pixels[i+1,j] mod 256)+
             9*(input.Canvas.Pixels[i+1,j+1] mod 256)+
             4*(input.Canvas.Pixels[i+1,j+2] mod 256)+
             2*(input.Canvas.Pixels[i+2,j-2] mod 256)+
             4*(input.Canvas.Pixels[i+2,j-1] mod 256)+
             5*(input.Canvas.Pixels[i+2,j] mod 256)+
             4*(input.Canvas.Pixels[i+2,j+1] mod 256)+
             2*(input.Canvas.Pixels[i+2,j+2] mod 256))/159);

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function laplas8 (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      light:=12*(input.Canvas.Pixels[i,j] mod 256)-
            2*(input.Canvas.Pixels[i+1,j] mod 256)-
            2*(input.Canvas.Pixels[i-1,j] mod 256)-
            2*(input.Canvas.Pixels[i,j+1] mod 256)-
            2*(input.Canvas.Pixels[i,j-1] mod 256)-
            (input.Canvas.Pixels[i+1,j+1] mod 256)-
            (input.Canvas.Pixels[i-1,j-1] mod 256)-
            (input.Canvas.Pixels[i-1,j+1] mod 256)-
            (input.Canvas.Pixels[i+1,j-1] mod 256);

      light:=light+128;

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function Sobel (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
  grad_x,grad_y : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      grad_x:=(input.Canvas.Pixels[i+1,j-1] mod 256)+
              2*(input.Canvas.Pixels[i+1,j] mod 256)+
              (input.Canvas.Pixels[i+1,j+1] mod 256)-
              (input.Canvas.Pixels[i-1,j-1] mod 256)-
              2*(input.Canvas.Pixels[i-1,j] mod 256)-
              (input.Canvas.Pixels[i-1,j+1] mod 256);
      grad_y:=(input.Canvas.Pixels[i-1,j+1] mod 256)+
              2*(input.Canvas.Pixels[i,j+1] mod 256)+
              (input.Canvas.Pixels[i+1,j+1] mod 256)-
              (input.Canvas.Pixels[i-1,j-1] mod 256)-
              2*(input.Canvas.Pixels[i,j-1] mod 256)-
              (input.Canvas.Pixels[i+1,j-1] mod 256);

      light:=abs(grad_x)+abs(grad_y);

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function MedianCont (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  i1,j1 : integer;
  light : longint;
  lights: array [1..9] of byte;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      lights[1]:=(input.Canvas.Pixels[i-1,j-1] mod 256);
      lights[2]:=(input.Canvas.Pixels[i-1,j] mod 256);
      lights[3]:=(input.Canvas.Pixels[i-1,j+1] mod 256);
      lights[4]:=(input.Canvas.Pixels[i,j-1] mod 256);
      lights[5]:=(input.Canvas.Pixels[i,j] mod 256);
      lights[6]:=(input.Canvas.Pixels[i,j+1] mod 256);
      lights[7]:=(input.Canvas.Pixels[i+1,j-1] mod 256);
      lights[8]:=(input.Canvas.Pixels[i+1,j] mod 256);
      lights[9]:=(input.Canvas.Pixels[i+1,j+1] mod 256);
      light:=lights[5];


      for i1:=1 to 8 do
        for j1:=i1+1 to 9 do
          if lights[i1]>lights[j1] then
          begin
            light:=lights[i1];
            lights[i1]:=lights[j1];
            lights[j1]:=light;
          end;

      if light<=lights[5] then light:=0
      else if light>lights[5] then light:=255;
//      else light:=127;

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function Median3 (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  i1,j1 : integer;
  light : longint;
  lights: array [1..9] of byte;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      lights[1]:=(input.Canvas.Pixels[i-1,j-1] mod 256);
      lights[2]:=(input.Canvas.Pixels[i-1,j] mod 256);
      lights[3]:=(input.Canvas.Pixels[i-1,j+1] mod 256);
      lights[4]:=(input.Canvas.Pixels[i,j-1] mod 256);
      lights[5]:=(input.Canvas.Pixels[i,j] mod 256);
      lights[6]:=(input.Canvas.Pixels[i,j+1] mod 256);
      lights[7]:=(input.Canvas.Pixels[i+1,j-1] mod 256);
      lights[8]:=(input.Canvas.Pixels[i+1,j] mod 256);
      lights[9]:=(input.Canvas.Pixels[i+1,j+1] mod 256);


      for i1:=1 to 8 do
        for j1:=i1+1 to 9 do
          if lights[i1]>lights[j1] then
          begin
            light:=lights[i1];
            lights[i1]:=lights[j1];
            lights[j1]:=light;
          end;

      light:=lights[5];

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function negativ (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  light : longint;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      light:=(input.Canvas.Pixels[i,j] mod 256);
      light:=255-light;

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function otsu (input : TBitmap) : TBitmap;
var
  output:TBitmap;
  totalpixels : integer;
  hist_pixels : array[0..255] of double;
  i,j,t : integer;
  w0,w1 : double;
  m0,m1 : double;

  sig,sigmax : double;
  limit : integer;
  light : integer;
begin
  output:=TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  totalpixels:=input.Width*input.Height;

  for i:=0 to 255 do hist_pixels[i]:=0;

  for i := 0 to input.Width-1 do
    for j := 0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      hist_pixels[light]:=hist_pixels[light]+(1/totalpixels);
    end;

  sigmax:=0;
  limit:=0;
  for t:=65 to 254 do
  begin
    w0:=0;
    w1:=0;
    m0:=0;
    m1:=0;
    sig:=0;

    for i := 0 to t do
      w0:=w0+hist_pixels[i];
    w1:=1-w0;

    if (w0=0) or (w1=0) then continue;

    for i := 0 to t do
      m0:=m0+hist_pixels[i]*i/w0;

    for i := t+1 to 255 do
      m1:=m1+hist_pixels[i]*i/w1;

    sig:=w1*w0*sqr(m1-m0);
    if sig>sigmax then
    begin
      sigmax:=sig;
      limit:=t;
    end;
  end;

  for i := 0 to input.Width-1 do
    for j := 0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      if light>limit then
        output.Canvas.Pixels[i,j]:=255*(65536+256+1)
      else
        output.Canvas.Pixels[i,j]:=0;
    end;

  Result:=output;
end;

function Canny (input : TBitmap) : TBitmap;
var
  output : TBitmap;
begin
end;



procedure TForm1.Button1Click(Sender: TObject);
begin

  if OpenPictureDialog1.Execute then
  begin
    source.LoadFromFile(OpenPictureDialog1.FileName);
    source:=greyscale(source);
    FreeCanvas(Image1);
    Image1.Canvas.Draw(0,0,source);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,laplas4(source));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,laplas8(source));
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,sobel(source));
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,median3(source));
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,otsu(source));
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,negativ(source));
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,avtokontrast(source));
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,avtokontrastSM(source,128,100));
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,box3(source));
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,gauss5(source));
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,deriche(source,strtofloat(Form1.Edit1.Text)));
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,otsu(deriche(source,strtofloat(Form1.Edit1.Text))));
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,laplasMod(source));
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,deriche(laplasMod(source),strtofloat(Form1.Edit1.Text)));
end;

procedure TForm1.Button16Click(Sender: TObject);
begin
  Image2.Canvas.Draw(0,0,laplasMod(deriche(source,strtofloat(Form1.Edit1.Text))));
end;

end.
