unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs, ComCtrls, Math;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Image2: TImage;
    GroupBox3: TGroupBox;
    Image3: TImage;
    Button3: TButton;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    CheckBox1: TCheckBox;
    Label5: TLabel;
    Edit4: TEdit;
    Label6: TLabel;
    Edit5: TEdit;
    ProgressBar1: TProgressBar;
    CheckBox2: TCheckBox;
    Label1: TLabel;
    Edit6: TEdit;
    RadioGroup1: TRadioGroup;
    Edit7: TEdit;
    Label7: TLabel;
    Edit8: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit9: TEdit;
    RadioGroup2: TRadioGroup;
    Edit10: TEdit;
    Button4: TButton;
    TrackBar1: TTrackBar;
    Edit11: TEdit;
    Edit12: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Edit15: TEdit;
    Edit16: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  source1,source2,
  work1,work2,
  MorphPic, morphgrid, morphvect, morphpole : TBitmap;

implementation

{$R *.dfm}

procedure FreeCanvas (input:TBitmap); overload;
begin
  input.Canvas.Pen.Color:=clWhite;
  input.Canvas.Brush.Color:=clWhite;
  input.Canvas.Rectangle(0,0,input.Width-1,input.Height-1);
  input.Canvas.Pen.Color:=clBlack;
end;

procedure FreeCanvas (input:TImage);  overload;
begin
  input.Canvas.Pen.Color:=clWhite;
  input.Canvas.Brush.Color:=clWhite;
  input.Canvas.Rectangle(0,0,input.Width-1,input.Height-1);
  input.Canvas.Pen.Color:=clBlack;
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

function threshold (input : TBitmap; l_tr : integer; h_tr:integer) : TBitmap;
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
      light:=(input.Canvas.Pixels[i,j] mod 256);

      if light<l_tr then light:=0;
      if light>h_tr then light:=254;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function interpol (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,j : integer;
  i1,j1 : integer;
  light : longint;
  iter_change : boolean;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
      output.Canvas.Pixels[i,j]:=input.Canvas.Pixels[i,j];

  Repeat
    iter_change:=false;

    for i:=1 to input.Width-2 do
      for j:=0 to input.Height-1 do
        if (output.Canvas.Pixels[i,j] mod 256 = 255) and
           (output.Canvas.Pixels[i-1,j] mod 256 <> 255) and
           (output.Canvas.Pixels[i+1,j] mod 256 <> 255) then
           begin
             output.Canvas.Pixels[i,j]:=round(((output.Canvas.Pixels[i-1,j] mod 256)+(output.Canvas.Pixels[i+1,j] mod 256))/2)*(65536+256+1);
             iter_change:=true;
           end;

    for i:=0 to input.Width-1 do
      for j:=1 to input.Height-2 do
        if (output.Canvas.Pixels[i,j] mod 256 = 255) and
           (output.Canvas.Pixels[i,j-1] mod 256 <> 255) and
           (output.Canvas.Pixels[i,j+1] mod 256 <> 255) then
           begin
             output.Canvas.Pixels[i,j]:=round(((output.Canvas.Pixels[i,j-1] mod 256)+(output.Canvas.Pixels[i,j+1] mod 256))/2)*(65536+256+1);
             iter_change:=true;
           end;

    for i:=1 to input.Width-2 do
      for j:=1 to input.Height-2 do
        if (output.Canvas.Pixels[i,j] mod 256 = 255) and
           (output.Canvas.Pixels[i-1,j-1] mod 256 <> 255) and
           (output.Canvas.Pixels[i+1,j+1] mod 256 <> 255) then
           begin
             output.Canvas.Pixels[i,j]:=round(((output.Canvas.Pixels[i-1,j-1] mod 256)+(output.Canvas.Pixels[i+1,j+1] mod 256))/2)*(65536+256+1);
             iter_change:=true;
           end;

    for i:=1 to input.Width-2 do
      for j:=1 to input.Height-2 do
        if (output.Canvas.Pixels[i,j] mod 256 = 255) and
           (output.Canvas.Pixels[i-1,j+1] mod 256 <> 255) and
           (output.Canvas.Pixels[i+1,j-1] mod 256 <> 255) then
           begin
             output.Canvas.Pixels[i,j]:=round(((output.Canvas.Pixels[i-1,j+1] mod 256)+(output.Canvas.Pixels[i+1,j-1] mod 256))/2)*(65536+256+1);
             iter_change:=true;
           end;

  Until not iter_change;


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

    //подавление границ
  for i:=1 to input.Width-2 do
  begin
    output.Canvas.Pixels[i,0]:=output.Canvas.Pixels[i,1];
    output.Canvas.Pixels[i,input.Height-1]:=output.Canvas.Pixels[i,input.Height-2];
  end;

  for j:=0 to input.Height-1 do
  begin
    output.Canvas.Pixels[0,j]:=output.Canvas.Pixels[1,j];
    output.Canvas.Pixels[input.Width-1,j]:=output.Canvas.Pixels[input.Width-2,j];
  end;

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

  Result :=output;
end;

function avtokontrastE (input : TBitmap;  r : double) : TBitmap;
var
  output : TBitmap;
  i,j,f : integer;
  light : byte;
  Hi : array [0..255] of integer;
  sumHi,Q  : double;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  for i:=0 to 255 do Hi[i]:=0;

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      inc(Hi[light]);
    end;

  Q:=0;
  for i:=0 to 255 do if Hi[i]<>0 then Q:=Q+exp(ln(Hi[i])*r);


  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i,j] mod 256;
      sumHi:=0;
      for f:=0 to light do if Hi[f]<>0 then sumHi:=sumHi+exp(ln(Hi[f])*r);
      light:=round(255*sumHi/Q);
      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;

  Result :=output;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    FreeCanvas(image1);
    source1.LoadFromFile(OpenPictureDialog1.FileName);
    case Radiogroup2.ItemIndex of
    0 : begin work1:=source1; end;
    1 : begin
          work1:=avtokontrast(source1);
        end;
    2 : begin
          work1:=avtokontrastE(source1,strtofloat(Edit10.Text));
        end;
    end;
    if CheckBox1.Checked then work1:=avtokontrast(threshold(deriche(work1,3),10,245));
    Image1.Canvas.Draw(0,0,work1);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    FreeCanvas(image2);
    source2.LoadFromFile(OpenPictureDialog1.FileName);
    case Radiogroup2.ItemIndex of
    0 : begin work2:=source2; end;
    1 : begin
          work2:=avtokontrast(source2);
        end;
    2 : begin
          work2:=avtokontrastE(source2,strtofloat(Edit10.Text));
        end;
    end;
    if CheckBox1.Checked then work2:=avtokontrast(threshold(deriche(work2,3),10,245));
    Image2.Canvas.Draw(0,0,work2);
  end;
end;

procedure morph (src1 : TBitmap; src2 : Tbitmap; iters : integer);
type
  TFpoint = record
    x : double;
    y : double;
  end;
var
  shiftarray,newshiftarray : array of array of TFPoint;
  diff,newdiff : double;
  f,f1,i,j : integer;
  Rmax,R,ang,x,y,dx,dy,dist,dist_i : double;
  iris : TPoint;
  iris_rad,iris_dist : integer;
  brow,nose,mouth : TRect;
  v,vr,vd : double;
  s : double;

  Ha,Hb : array[0..255] of integer;
  sumHa, sumHb : integer;
  Ka,Kb : array[0..255] of double;
  Sa,Sb : double;
  aij,bij : byte;
  a,b : integer;
  k : double;

  perc : real; // процент соответствия

  a1,b1:byte;
  p_iter,n_iter:integer;

  pix_num : double;
begin
//prepare
  pix_num:=src1.Width*src1.height;
  Randomize;
  Form1.ProgressBar1.Position:=0;
  Form1.ProgressBar1.Max:=iters;
  s:=strtofloat(Form1.Edit9.text);

  setlength (shiftarray,src1.Width,src1.Height);
  for i:=0 to src1.Width-1 do
    for j:=0 to src1.Height-1 do
    begin
      shiftarray[i,j].x:=0;
      shiftarray[i,j].y:=0;
    end;

  Rmax:=strtoint(Form1.Edit2.Text);

  iris_dist :=strtoint(Form1.Edit7.Text);
  iris_rad  :=strtoint(Form1.Edit8.Text);
  iris.X:=strtoint(Form1.Edit3.Text);
  iris.Y:=strtoint(Form1.Edit6.Text);

  brow.Left:=round(iris.X-30*(iris_dist/50));
  brow.Top:=round(iris.Y-25*(iris_dist/50));
  brow.Right:=round(iris.X+25*(iris_dist/50));
  brow.Bottom:=round(iris.Y-2*(iris_dist/50));

  nose.Left:=round(iris.X);
  nose.Top:=round(iris.Y+15*(iris_dist/50));
  nose.Right:=round(iris.X+50*(iris_dist/50));
  nose.Bottom:=round(iris.Y+50*(iris_dist/50));

  mouth.Left:=round(iris.X-5*(iris_dist/50));
  mouth.Top:=round(iris.Y+45*(iris_dist/50));
  mouth.Right:=round(iris.X+55*(iris_dist/50));
  mouth.Bottom:=round(iris.Y+75*(iris_dist/50));

    for i:=0 to 255 do
      begin
        Ha[i]:=0;
        Hb[i]:=0;
      end;
    for i:=0 to src1.Width-1 do
      for j:=0 to src1.Height-1 do
      begin
        inc(Ha[src1.Canvas.Pixels[i,j] mod 256]);
        inc(Hb[src2.Canvas.Pixels[i,j] mod 256]);
      end;
    Sa:=0;
    Sb:=0;
    for i:=0 to 255 do
    begin
      if (Ha[i]<>0) then Ka[i]:=Sa+(Ha[i]+1)/2;
      Sa:=Sa+Ha[i];
      if (Hb[i]<>0) then Kb[i]:=Sb+(Hb[i]+1)/2;
      Sb:=Sb+Hb[i];
    end;

  {calculate basic difference}

  vr:=0;
    for i:=0 to src1.Width-1 do
      for j:=0 to src1.Height-1 do
      begin
        aij:=src1.Canvas.Pixels[i,j] mod 256;
        bij:=src2.Canvas.Pixels[i,j] mod 256;
        vr:=vr+sqr(Ka[aij]-Kb[bij]);
      end;

  vr:=6*vr/((sqr(pix_num)-1)*pix_num);
  vd:=0;
  diff:=vr+0.1*vd;
  Form1.Edit4.Text:=floattostr(diff);

  {main iteration}
  p_iter:=0;
  n_iter:=0;
  for f:=1 to iters do
  begin
    setlength (newshiftarray,src1.Width,src1.Height);
    //morph
    x:=Random(src1.Width);
    y:=Random(src1.Height);
    if Form1.RadioGroup1.ItemIndex=0
      then ang:=2*Pi*Random
    else
      begin
        ang:=arctan2(j-iris.Y, i-iris.X);
        if Random(2)=1 then ang:=-ang;
      end;

    if (x>brow.Left) and
       (x<brow.Right) and
       (y>brow.Top) and
       (y<brow.bottom) then
       begin
         //brow zone
         R:=Random((brow.Bottom-brow.Top) div 2);
         a:=1; b:=2;
       end
    else
    if (x>nose.Left) and
       (x<nose.Right) and
       (y>nose.Top) and
       (y<nose.bottom) then
       begin
         //nose zone
         R:=Random((nose.Left-nose.Right) div 2);
         a:=2; b:=1;
       end
    else
    if (x>mouth.Left) and
       (x<mouth.Right) and
       (y>mouth.Top) and
       (y<mouth.bottom) then
       begin
         //mouth zone
         R:=Random((mouth.Bottom-mouth.Top) div 2);
         a:=2; b:=1;
       end
    else
      begin
        R:=Random*Rmax;
        a:=1; b:=1;
      end;
    dx:=R*cos(ang);
    dy:=R*sin(ang);

    for i:=0 to src1.Width-1 do
      for j:=0 to src1.Height-1 do
      begin
        dist_i:=sqrt(sqr(i-iris.X)+sqr(j-iris.Y));
        dist:=sqrt(sqr(a*(i-x))+sqr(b*(j-y)));
        if dist_i>=iris_rad
          then k:=exp(-s*dist*exp(-s)*exp(-s))
        else k:=exp(-s*dist*exp(-s*(dist_i-iris_rad))*exp(-s));

        newshiftarray[i,j].x:=shiftarray[i,j].x+dx*k;
        newshiftarray[i,j].y:=shiftarray[i,j].y+dy*k;
      end;

    {calculate new difference}

  vr:=0;
    for i:=0 to src1.Width-1 do
      for j:=0 to src1.Height-1 do
      begin
        aij:=src1.Canvas.Pixels[i,j] mod 256;
        bij:=src2.Canvas.Pixels[round(i+newshiftarray[i,j].x),round(j+newshiftarray[i,j].y)] mod 256;
        vr:=vr+sqr(Ka[aij]-Kb[bij]);
      end;

  vr:=6*vr/((sqr(pix_num)-1)*pix_num);
  vd:=0;

  for i:=0 to src1.Width-2 do
    for j:=0 to src1.Height-2 do
    begin
      vd:=vd+
          abs(newshiftarray[i,j].x - newshiftarray[i+1,j].x)+
          abs(newshiftarray[i,j].y - newshiftarray[i+1,j].y)+
          abs(newshiftarray[i,j].x - newshiftarray[i,j+1].x)+
          abs(newshiftarray[i,j].y - newshiftarray[i,j+1].y);
    end;
    vd:=vd/((src1.Width-1)*(src1.Height-1));

    newdiff:=vr+0.1*vd;

    if newdiff<diff then
    begin
      p_iter:=p_iter+1;
      diff:=newdiff;
      shiftarray:=newshiftarray;
    end
    else
      n_iter:=n_iter+1;

    newshiftarray:=nil;
    Form1.ProgressBar1.Position:=f;

  end;

  //вывод результатов
  Form1.Edit5.Text:=floattostr(diff);
  Form1.Edit15.Text:=inttostr(p_iter);
  Form1.Edit16.Text:=inttostr(n_iter);
  perc := 100*(strtofloat(Form1.Edit12.Text)-diff)/(strtofloat(Form1.Edit12.Text)-strtofloat(Form1.Edit11.Text));
  if perc>100 then perc:=100;
  if perc<0 then perc:=0;
  Form1.Label11.Caption:='Совпадение '+floattostr(perc)+'%';
    //morph pole
  MorphPole.Width:=src1.Width;
  MorphPole.Height:=src1.Height;
  FreeCanvas(MorphPole);

  MorphPole.Canvas.Pen.Color:=clBlack;
  MorphPole.Canvas.Brush.Color:=clBlack;
  MorphPole.Canvas.Rectangle(0,0,MorphPole.Width-1,MorphPole.Height-1);
  MorphPole.Canvas.Pen.Color:=clWhite;
  MorphPole.Canvas.Brush.Color:=clWhite;

  morphpole.Canvas.MoveTo(round(shiftarray[0,0].x),round(shiftarray[0,0].y));
  for i:=1 to src1.Width-1 do
    morphpole.Canvas.LineTo(round(i+shiftarray[i,0].x),round(shiftarray[i,0].y));
  for j:=1 to src1.Height-1 do
    morphpole.Canvas.LineTo(round(src1.Width-1+shiftarray[src1.Width-1,j].x),round(j+shiftarray[src1.Width-1,j].y));
  for i:=src1.Width-2 downto 0 do
    morphpole.Canvas.LineTo(round(i+shiftarray[i,src1.Height-1].x),src1.Height-1+round(shiftarray[i,src1.Height-1].y));
  for j:=src1.Height-2 downto 0 do
    morphpole.Canvas.LineTo(round(shiftarray[0,j].x),round(j+shiftarray[0,j].y));

  morphpole.Canvas.FloodFill(MorphPole.Width div 2,MorphPole.Height div 2,clBlack,fsSurface);

  //morphpic
  MorphPic.Width:=src1.Width;
  MorphPic.Height:=src1.Height;
  FreeCanvas(MorphPic);
  morphpic.Canvas.Draw(0,0,morphpole);
  for i:=0 to src1.Width-1 do
    for j:=0 to src1.Height-1 do
      MorphPic.Canvas.Pixels[round(i+shiftarray[i,j].x),round(j+shiftarray[i,j].y)]:=src1.Canvas.Pixels[i,j];
  if Form1.CheckBox2.Checked then  MorphPic:=interpol(MorphPic);
  Form1.Image3.Canvas.Draw(0,0,MorphPic);
  //grid of morph
  MorphGrid.Width:=src1.Width;
  MorphGrid.Height:=src1.Height;
  FreeCanvas(MorphGrid);
  f:=5;
  for i:=0 to ((src1.Width-1) div f) do
    for j:=0 to ((src1.Height-1) div f) do
    begin
      if i<>0 then
      begin
        morphgrid.Canvas.MoveTo(round(i*f+shiftarray[i*f,j*f].x),round(j*f+shiftarray[i*f,j*f].y));
        morphgrid.Canvas.LineTo(round((i-1)*f+shiftarray[(i-1)*f,j*f].x),round(j*f+shiftarray[(i-1)*f,j*f].y));
      end;
      if j<>0 then
      begin
        morphgrid.Canvas.MoveTo(round(i*f+shiftarray[i*f,j*f].x),round(j*f+shiftarray[i*f,j*f].y));
        morphgrid.Canvas.LineTo(round(i*f+shiftarray[i*f,(j-1)*f].x),round((j-1)*f+shiftarray[i*f,(j-1)*f].y));
      end;
    end;

  // morph vectors
    MorphVect.Width:=src1.Width;
  MorphVect.Height:=src1.Height;
  FreeCanvas(MorphVect);
  f:=5;
  for i:=0 to ((src1.Width-1) div f) do
    for j:=0 to ((src1.Height-1) div f) do
    begin
      morphvect.Canvas.MoveTo(i*f,j*f);
      morphvect.Canvas.LineTo(round(i*f+shiftarray[i*f,j*f].x),round(j*f+shiftarray[i*f,j*f].y));
    end;

  Form1.TrackBar1.Position:=0;
  shiftarray:=nil;
  newshiftarray:=nil;
end;



procedure TForm1.Button3Click(Sender: TObject);
begin
  FreeCanvas(image3);
  morph (work1,work2,strtoint(Edit1.Text));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  source1:=TBitmap.Create;
  source2:=TBitmap.Create;
  work1:=TBitmap.Create;
  work2:=TBitmap.Create;
  MorphPic:=TBitmap.Create;
  morphgrid:=Tbitmap.Create;
  morphvect:=Tbitmap.Create;
  morphpole:=Tbitmap.Create;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  source1.Free;
  source2.Free;
  work1.Free;
  work2.Free;
  MorphPic.Free;
  morphgrid.Free;
  morphvect.Free;
  morphpole.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  case Radiogroup2.ItemIndex of
    0 : begin
          work1:=source1;
          work2:=source2;
        end;
    1 : begin
          work1:=avtokontrast(source1);
          work2:=avtokontrast(source2);
        end;
    2 : begin
          work1:=avtokontrastE(source1,strtofloat(Edit10.Text));
          work2:=avtokontrastE(source2,strtofloat(Edit10.Text));
        end;
  end;
      if CheckBox1.Checked then work1:=deriche(work1,3);
      if CheckBox1.Checked then work2:=deriche(work2,3);
    Image1.Canvas.Draw(0,0,work1);
    Image2.Canvas.Draw(0,0,work2);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  FreeCanvas(Image3);
  case TrackBar1.Position of
   -1: Image3.Canvas.Draw(0,0,work1);
    0: Image3.Canvas.Draw(0,0,morphpic);
    1: Image3.Canvas.Draw(0,0,work2);
    2: Image3.Canvas.Draw(0,0,morphpole);
    3: Image3.Canvas.Draw(0,0,morphgrid);
    4: Image3.Canvas.Draw(0,0,morphvect);
  end;


end;

end.
