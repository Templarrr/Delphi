unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtDlgs, ExtCtrls, StdCtrls, Math, ComCtrls, DIBUltra, Series,
  TeEngine, TeeProcs, Chart;

type
  TIris = record
    x:integer;
    y:integer;
    Hoh_value : longint;
  end;
  FaceRect = record
        xSrc: Integer;
        ySrc: Integer;
        width: Integer;
        height: Integer;
  end;
  TForm1 = class(TForm)
    LoadImageButton: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    OImage: TImage;
    TImage: TImage;
    Image: TImage;
    SImage: TImage;
    TabSheet5: TTabSheet;
    EyeImage: TImage;
    TurnAround: TButton;
    EyeButton: TButton;
    iris_dist: TEdit;
    Label1: TLabel;
    l_iris_x: TEdit;
    Label2: TLabel;
    l_iris_y: TEdit;
    nimage_width: TEdit;
    Label3: TLabel;
    nimage_height: TEdit;
    SaveButton: TButton;
    SaveDialog1: TSaveDialog;
    CheckButton: TButton;
    testbutton: TButton;
    procedure LoadImageButtonClick(Sender: TObject);
    procedure testbuttonClick(Sender: TObject);
    procedure TurnAroundClick(Sender: TObject);
    procedure EyeButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveButtonClick(Sender: TObject);
    procedure CheckButtonClick(Sender: TObject);
    procedure EyeImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function DetectFaces(nWidth:Integer; nHeight:Integer; Bpp:Integer; nPixels:Pointer):Integer;stdcall;external 'BuFaLo.dll';
  function GetFaceRect(idx:Integer; Face: Pointer):Integer;stdcall;external 'BuFaLo.dll';

var
  Form1: TForm1;
  filename: string;
  workpicture : TBitmap;
  DIBpicture : TDIBUltra;
  sobelpicture,otspicture : TBitmap;
  turnpicture : TBitmap;
  eyepicture:TBitmap;
  l_iris,r_iris : TPoint;
  r,r_min,r_max : byte;
  iris_finded : boolean;

implementation

{$R *.dfm}

procedure Turn;
var
  i,j : integer;
  x,y : double;
  turn_x,turn_y : integer;
  R,ang1 : double;
  angle:double;
  k:double; //коэффициент изменения;
begin
  angle:=arctan2(r_iris.Y-l_iris.Y,r_iris.X-l_iris.X);
  k:=strtoint(form1.iris_dist.Text)/sqrt(sqr(r_iris.Y-l_iris.Y)+sqr(r_iris.X-l_iris.X));
  turnpicture:=TBitmap.Create;
  turnpicture.Width:=strtoint(form1.nimage_width.Text);
  turnpicture.Height:=strtoint(form1.nimage_height.Text);
  turn_x:=l_iris.X;
  turn_y:=l_iris.Y;


  for i:=0 to turnpicture.Width-1 do
    for j:=0 to turnpicture.Height-1 do
    begin
      R:=sqrt(sqr(i-strtoint(form1.l_iris_x.Text))+sqr(j-strtoint(form1.l_iris_y.Text)))/k;
      if R=0 then
        ang1:=0
      else
        ang1:=arctan2(j-strtoint(form1.l_iris_y.Text),i-strtoint(form1.l_iris_x.Text));
      ang1:=ang1+angle;
      x:=round(turn_x+R*cos(ang1));
      y:=round(turn_y+R*sin(ang1));
      if (x<0) or (x>=workpicture.Width) or
         (y<0) or (y>=workpicture.Height) then
        turnpicture.canvas.Pixels[i,j]:=0
      else
        turnpicture.canvas.Pixels[i,j]:=workpicture.Canvas.Pixels[round(x),round(y)];
    end;



  Form1.TImage.Canvas.Draw(0,0,turnpicture);
end;

procedure ClearCanvas(img:TImage);
begin
  img.Canvas.Pen.Color:=clWhite;
  img.Canvas.Brush.Color:=clWhite;
  img.Canvas.Rectangle(0,0,img.width,img.Height);
end;

procedure Sobel(limit:integer);
var
  a,b,c,d,e,f,g,h,i : byte;
  f1,j : integer;
  Sx,Sy,S:integer;
begin
  sobelpicture:=TBitmap.Create;
  sobelpicture.Width:=workpicture.Width;
  sobelpicture.Height:=workpicture.Height;
  for f1 := 1 to workpicture.Width-2 do    // Iterate
    for j := 1 to workpicture.Height-2 do
    begin
      a:=workpicture.Canvas.Pixels[f1-1,j-1] mod 256;
      b:=workpicture.Canvas.Pixels[f1-1,j] mod 256;
      c:=workpicture.Canvas.Pixels[f1-1,j+1] mod 256;
      d:=workpicture.Canvas.Pixels[f1,j-1] mod 256;
      e:=workpicture.Canvas.Pixels[f1,j] mod 256;
      f:=workpicture.Canvas.Pixels[f1,j+1] mod 256;
      g:=workpicture.Canvas.Pixels[f1+1,j-1] mod 256;
      h:=workpicture.Canvas.Pixels[f1+1,j] mod 256;
      i:=workpicture.Canvas.Pixels[f1+1,j+1] mod 256;
      Sx:=(c+2*f+i)-(a+2*d+g); //Sobel
      Sy:=(g+2*h+i)-(a+2*b+c);
      //Sx:=(b+2*c+f)-(d+2*g+h);  //my own method...who knows :)
      //Sy:=(d+2*a+b)-(f+2*h+i);
      //Sx:=2*a+10*b+5*c+3*f-5*g-6*h-10*i;   //Scharr Operator (? maybe...must find correct matrix)
      //Sy:=10*a+8*b-5*c-10*e-3*f+3*g-3*h;
      //S:=round(sqrt(sqr(Sx)+sqr(Sy)));
      S:=round(abs(Sx)+abs(Sy));
      //S:=4*e-b-d-f-h;
      if S>255 then s:=255;


      if (S<limit) then sobelpicture.Canvas.Pixels[f1,j]:=255*(65536+256+1)
      else sobelpicture.Canvas.Pixels[f1,j]:=(255-S)*(65536+256+1);
    end;

    clearCanvas(Form1.SImage);
    Form1.SImage.Canvas.Draw(0,0,sobelpicture);
end;

Procedure Ots;
var
  totalpixels : integer;
  hist_pixels : array[0..255] of double;
  i,j,t : integer;
  w0,w1 : double;
  m0,m1 : double;

  sig,sigmax : double;
  limit : integer;
  light : integer;
begin
  otspicture:=TBitmap.Create;
  otspicture.Width:=sobelpicture.Width;
  otspicture.Height:=sobelpicture.Height;

  totalpixels:=sobelpicture.Width*sobelpicture.Height;

  for i:=0 to 255 do hist_pixels[i]:=0;

  for i := 0 to sobelpicture.Width-1 do
    for j := 0 to sobelpicture.Height-1 do
    begin
      light:=sobelpicture.Canvas.Pixels[i,j] mod 256;
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

  for i := 0 to sobelpicture.Width-1 do
    for j := 0 to sobelpicture.Height-1 do
    begin
      light:=sobelpicture.Canvas.Pixels[i,j] mod 256;
      if light>limit then
        otspicture.Canvas.Pixels[i,j]:=255*(65536+256+1)
      else
        otspicture.Canvas.Pixels[i,j]:=0;
    end;

  clearCanvas(Form1.OImage);
  Form1.OImage.Canvas.Draw(0,0,otspicture);
end;

function selectface(input:TBitmap):TBitmap;
var
  output:TBitmap;
  count : integer;
  face: FaceRect ;
  frect,destrect:TRect;
begin
  DIBpicture:=TDIBUltra.CreateFromFile(filename);
  count:=DetectFaces(DIBPicture.Width,DIBPicture.Height,DIBPicture.Bpp,DIBPicture.Bits);
  if count<1 then
  begin
    ShowMessage ('Модуль BuFaLo не смог найти лица на этом изображении.'+#13+'Возможно оно недостаточно освещено или лицо находится под большим углом к камере.');
    Result:=input;
  end;
  if count>1 then
  begin
    ShowMessage ('Ошибка модуля BuFaLo : на фотографии найдено больше одного лица.');
    GetFaceRect (1,@face);
    fRect.Left := Face.xSrc;
    fRect.Top  := Face.ySrc;
    fRect.Right:= Face.xSrc+Face.width;
    fRect.Bottom:= Face.ySrc+Face.height;
    destrect.Left := 0;
    destrect.Top  := 0;
    destrect.Right:= Face.width;
    destrect.Bottom:= Face.height;

    output:=TBitmap.Create;
    output.Width:=Face.width;
    output.Height:=Face.height;

    output.Canvas.CopyRect(destrect,input.Canvas,frect);

    Result:=output;
  end;
  if count=1 then
  begin
    GetFaceRect (0,@face);
    fRect.Left := Face.xSrc;
    fRect.Top  := Face.ySrc;
    fRect.Right:= Face.xSrc+Face.width;
    fRect.Bottom:= Face.ySrc+Face.height;
    destrect.Left := 0;
    destrect.Top  := 0;
    destrect.Right:= Face.width;
    destrect.Bottom:= Face.height;

    output:=TBitmap.Create;
    output.Width:=Face.width;
    output.Height:=Face.height;

    output.Canvas.CopyRect(destrect,input.Canvas,frect);

    Result:=output;
  end;
end;

function greyscale(input:TBitmap):TBitmap;
var
  output:TBitmap;
  copyrect:TRect;
  i,j: integer;
  r,g,b:byte;
begin
  output:=TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;
  copyrect.Left:=0;
  copyrect.Right:=input.Width;
  copyrect.Top:=0;
  copyrect.Bottom:=input.Height;
  output.Canvas.CopyRect(copyrect,input.Canvas,copyrect);

  for i:=0 to input.Width-1 do
    for j:=0 to input.Height-1 do
    begin
      b:=input.Canvas.Pixels[i,j] div 65536;
      g:=(input.Canvas.Pixels[i,j] - 65536*b) div 256;
      r:=(input.Canvas.Pixels[i,j] - 65536*b - 256*g);
      output.Canvas.Pixels[i,j]:=(65536+256+1)*round(0.3*r+0.59*g+0.11*b);
    end;

  Result:=output;
end;

function EdgeEnhance(input:TBitmap):TBitmap;
var
  output:TBitmap;
  copyrect:TRect;
  i,j: integer;
begin

  output:=TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;
  copyrect.Left:=0;
  copyrect.Right:=input.Width;
  copyrect.Top:=0;
  copyrect.Bottom:=input.Height;
  output.Canvas.CopyRect(copyrect,input.Canvas,copyrect);

  for i:=1 to input.Width-2 do
    for j:=1 to input.Height-2 do
    begin
      output.Canvas.Pixels[i,j]:=5*input.Canvas.Pixels[i,j]-
                                  input.Canvas.Pixels[i-1,j]-
                                  input.Canvas.Pixels[i+1,j]-
                                  input.Canvas.Pixels[i,j-1]-
                                  input.Canvas.Pixels[i,j+1];

    end;


  Result:=output;
end;

procedure TForm1.LoadImageButtonClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    workpicture:=TBitmap.Create;
    filename:=OpenPictureDialog1.FileName;
    workpicture.LoadFromFile(filename);
    iris_finded:=false;


    workpicture:=selectface(workpicture);
    workpicture:=greyscale(workpicture);
    //workpicture:=EdgeEnhance(workpicture);


    clearCanvas(Image);
    Image.Canvas.Draw(0,0,workpicture);
    testButton.Enabled:=true;
    eyeButton.Enabled:=true;
    turnAround.Enabled:=false;
    PageControl1.TabIndex:=0;
  end;

end;

procedure TForm1.testbuttonClick(Sender: TObject);
begin
  Sobel(40);
  Ots;
  eyebutton.Enabled:=true;
  PageControl1.TabIndex:=2;
end;


//уменьшение изначально найденной области глаз
function TrimRect (source:TBitmap;startRect:TRect) : TRect;
var
  output:TRect;
  h_proj,v_proj : array of longint;
  sum : longint;
  v_sr,h_sr  : double;
  i,j : integer;
  newleft,newright,newtop,newbottom : integer;
  k : double;
Begin
  Form1.TabSheet5.Show;
  output:=startrect;
    newleft:=output.left;
    newtop:=output.top;
    newright:=output.right;
    newbottom:=output.bottom;

    sum:=0;
    setlength(h_proj,output.Bottom-output.Top+1);
    for i:=0 to output.Bottom-output.Top do h_proj[i]:=0;
    setlength(v_proj,output.Right-output.Left+1);
    for j:=0 to output.Right-output.Left do v_proj[j]:=0;

    for i:=output.Top to output.Bottom do
      for j:=output.Left to output.Right do
      begin
        h_proj[i-output.Top]:=h_proj[i-output.Top]+(source.Canvas.Pixels[i,j] mod 256);
        v_proj[j-output.Left]:=v_proj[j-output.Left]+(source.Canvas.Pixels[i,j] mod 256);
        sum:=sum+(source.Canvas.Pixels[i,j] mod 256);
      end;

    v_sr:=sum/(output.Right-output.Left+1);
    h_sr:=sum/(output.Bottom-output.Top+1);

    k:=1;

    for i:=output.Top to output.Bottom do
      if (h_proj[i-output.Top]>k*h_sr) and not (newbottom=newtop+1) then
        newtop:=newtop+1
      else break;

    for i:=output.Bottom downto output.Top do
      if (h_proj[i-output.Top]>k*h_sr) and not (newbottom=newtop+1) then
        newbottom:=newbottom-1
      else break;

    for j:=output.Left to output.Right do
      if (v_proj[j-output.Left]>k*v_sr) and not(newright=newleft+1) then
        newleft:=newleft+1
      else break;

    for j:=output.Right downto output.Left do
      if (v_proj[j-output.Left]>k*v_sr) and not(newright=newleft+1) then
        newright:=newright-1
      else break;

    output.left:=newleft;
    output.top:=newtop;
    output.right:=newright;
    output.bottom:=newbottom;

  Result:=output;
end;


procedure EyeCatch;
var
  i,j,k : integer;
  copyrect:TRect;
  h_proj : array of longint;  //горизонтальная проекция
  h_min : longint;  //горизонтальная проекция - минимум
  y_min : integer;  //координаты по у
  start_y, end_y : integer;
  eyes,l_eye,r_eye : TRect; //глаза, левый, правый.
  hoh,hohmin:longint;
begin
  eyepicture:=TBitmap.Create;
  eyepicture.Width:=otspicture.Width;
  eyepicture.Height:=otspicture.Height;

  copyrect.Left:=0;
  copyrect.Right:=otspicture.Width;
  copyrect.Top:=0;
  copyrect.Bottom:=otspicture.Height;

  eyepicture.Canvas.CopyRect(copyrect,otspicture.Canvas,copyrect);

    r:=ceil(eyepicture.Width /30);


    eyes.Left:=round(eyepicture.Width/2-6.5*r);
    eyes.Right:=round(eyepicture.Width/2+6.5*r);
    eyes.Top:=round(eyepicture.Width/4.8);
    eyes.Bottom:=round(eyepicture.Width/2);

    l_eye:=eyes;
    l_eye.Right:=round((eyes.Right+eyes.Left)/2 - 1.5*r);
    r_eye:=eyes;
    r_eye.Left:=round((eyes.Right+eyes.Left)/2 + 1.5*r);




    {find left iris}
    hohmin:=100000000;
    for i:=l_eye.Left to l_eye.Right do
      for j:=l_eye.Top to l_eye.Bottom do
      begin
        if workpicture.Canvas.Pixels[i,j] mod 256>100 then continue;
        hoh:=eyepicture.Canvas.Pixels[i,j] mod 256;
//        hoh:=0;
        for r:=r_min to r_max do
        for k:=-r to r do
          hoh:=hoh+(eyepicture.Canvas.Pixels[i+k,j-round(sqrt(sqr(r)-sqr(k)))] mod 256)+
                   (eyepicture.Canvas.Pixels[i+k,j+round(sqrt(sqr(r)-sqr(k)))] mod 256);
        if hoh<hohmin then
        begin
          hohmin:=hoh;
          l_iris.X:=i;
          l_iris.Y:=j;
        end;
      end;


    {l_iris candidates}
    {eyepicture.Canvas.Pen.Color:=clBlue;
    eyepicture.Canvas.Brush.Style:=bsClear;
    for i:=l_eye.Left to l_eye.Right do
      for j:=l_eye.Top to l_eye.Bottom do
      begin
        hoh:=0;
        for r:=r_min to r_max do
        for k:=-r to r do
          hoh:=hoh+(eyepicture.Canvas.Pixels[i+k,j-round(sqrt(sqr(r)-sqr(k)))] mod 256)+
                   (eyepicture.Canvas.Pixels[i+k,j+round(sqrt(sqr(r)-sqr(k)))] mod 256);
        if hoh<1.5*hohmin then
        begin
          eyepicture.Canvas.MoveTo(i-r,j);
          eyepicture.Canvas.LineTo(i+r,j);
          eyepicture.Canvas.MoveTo(i,j-r);
          eyepicture.Canvas.LineTo(i,j+r);
        end;
      end;}

    {find right iris}
    hohmin:=100000000;
    for i:=r_eye.Left to r_eye.Right do
      for j:=r_eye.Top to r_eye.Bottom do
      begin
        if workpicture.Canvas.Pixels[i,j] mod 256>100 then continue;
        hoh:=eyepicture.Canvas.Pixels[i,j] mod 256;
//        hoh:=0;
        for r:=r_min to r_max do
        for k:=-r to r do
          hoh:=hoh+(eyepicture.Canvas.Pixels[i+k,j-round(sqrt(sqr(r)-sqr(k)))] mod 256)+
                   (eyepicture.Canvas.Pixels[i+k,j+round(sqrt(sqr(r)-sqr(k)))] mod 256);
        if hoh<hohmin then
        begin
          hohmin:=hoh;
          r_iris.X:=i;
          r_iris.Y:=j;
        end;
      end;

      {for i:=r_eye.Left to r_eye.Right do
      for j:=r_eye.Top to r_eye.Bottom do
      begin
        hoh:=0;
        for r:=r_min to r_max do
        for k:=-r to r do
          hoh:=hoh+(eyepicture.Canvas.Pixels[i+k,j-round(sqrt(sqr(r)-sqr(k)))] mod 256)+
                   (eyepicture.Canvas.Pixels[i+k,j+round(sqrt(sqr(r)-sqr(k)))] mod 256);
        if hoh<1.5*hohmin then
        begin
          eyepicture.Canvas.MoveTo(i-r,j);
          eyepicture.Canvas.LineTo(i+r,j);
          eyepicture.Canvas.MoveTo(i,j-r);
          eyepicture.Canvas.LineTo(i,j+r);
        end;
      end;}

    eyepicture.Canvas.CopyRect(copyrect,workpicture.Canvas,copyrect);


    {visualisations}


    {chosen}
    eyepicture.Canvas.Pen.Color:=clRed;
    eyepicture.Canvas.Brush.Style:=bsClear;
    {left iris}
    eyepicture.Canvas.MoveTo(l_iris.X-r,l_iris.Y);
    eyepicture.Canvas.LineTo(l_iris.X+r,l_iris.Y);
    eyepicture.Canvas.MoveTo(l_iris.X,l_iris.Y-r);
    eyepicture.Canvas.LineTo(l_iris.X,l_iris.Y+r);
    {right iris}
    eyepicture.Canvas.MoveTo(r_iris.X-r,r_iris.Y);
    eyepicture.Canvas.LineTo(r_iris.X+r,r_iris.Y);
    eyepicture.Canvas.MoveTo(r_iris.X,r_iris.Y-r);
    eyepicture.Canvas.LineTo(r_iris.X,r_iris.Y+r);


    {eye zones}
    //eyepicture.Canvas.Rectangle(l_eye);
    //eyepicture.Canvas.Rectangle(r_eye);

  form1.EyeImage.Canvas.Draw(0,0,eyepicture);
end;

procedure EyeCatch2;
var
  i,j,i1,j1 : integer;
  copyrect:TRect;

  start_y, end_y : integer;
  eyes,l_eye,r_eye : TRect; //глаза, левый, правый.
  hoh,hohmin:longint;
begin
  eyepicture:=TBitmap.Create;
  eyepicture.Width:=workpicture.Width;
  eyepicture.Height:=workpicture.Height;
  copyrect.Left:=0;
  copyrect.Right:=workpicture.Width;
  copyrect.Top:=0;
  copyrect.Bottom:=workpicture.Height;

  eyepicture.Canvas.CopyRect(copyrect,workpicture.Canvas,copyrect);

    r:=ceil(eyepicture.Width /30);

    eyes.Left:=round(eyepicture.Width/2-7*r);
    eyes.Right:=round(eyepicture.Width/2+7*r);
    eyes.Top:=round(eyepicture.Width/4.8);
    eyes.Bottom:=round(eyepicture.Width/1.8);

    l_eye:=eyes;
    l_eye.Right:=round((eyes.Right+eyes.Left)/2 - 1.5*r);
    r_eye:=eyes;
    r_eye.Left:=round((eyes.Right+eyes.Left)/2 + 1.5*r);

    {initial iris}
    l_iris.X:=(l_eye.Left+l_eye.Right) div 2;
    l_iris.Y:=(l_eye.Top+l_eye.Bottom) div 2;
    r_iris.X:=(r_eye.Left+r_eye.Right) div 2;
    r_iris.Y:=(r_eye.Top+r_eye.Bottom) div 2;
    {find left iris}


    hohmin:=High(longint);

    for i:=l_eye.Left to l_eye.Right do
      for j:=l_eye.Top to l_eye.Bottom do
      begin
        if workpicture.Canvas.Pixels[i,j] mod 256>150 then continue;
        {init}
        hoh:=0;
        {calculate}
        for i1:=ceil(i-1.5*r) to floor(i+1.5*r) do
          for j1:=j-round(sqrt(sqr(r)-sqr((i-i1)/1.5))) to j+round(sqrt(sqr(r)-sqr((i-i1)/1.5))) do
          if sqrt(sqr(i-i1)+sqr(j-j1))<=r then
            hoh:=hoh+(eyepicture.Canvas.Pixels[i1,j1] mod 256)
          else
            hoh:=hoh-(eyepicture.Canvas.Pixels[i1,j1] mod 256);
        {choose}
        if hoh<hohmin then
        begin
          l_iris.X:=i;
          l_iris.Y:=j;
          hohmin:=hoh;
        end
      end;
    {find right iris}

    hohmin:=High(longint);

    for i:=r_eye.Left to r_eye.Right do
      for j:=r_eye.Top to r_eye.Bottom do
      begin
{magic!}if (sqrt(sqr(l_iris.X-i)+sqr(l_iris.Y-j))>12.3*r) then continue;
        if (sqrt(sqr(l_iris.X-i)+sqr(l_iris.Y-j))<9*r) then continue;
      //if workpicture.Canvas.Pixels[i,j] mod 256>150 then continue;
        {init}
        hoh:=0;
        {calcurate}
        for i1:=ceil(i-1.5*r) to floor(i+1.5*r) do
          for j1:=j-round(sqrt(sqr(r)-sqr((i-i1)/1.5))) to j+round(sqrt(sqr(r)-sqr((i-i1)/1.5))) do
          if sqrt(sqr(i-i1)+sqr(j-j1))<=r then
            hoh:=hoh+(eyepicture.Canvas.Pixels[i1,j1] mod 256)
          else
            hoh:=hoh-(eyepicture.Canvas.Pixels[i1,j1] mod 256);
        {choose}
        if hoh<hohmin then
        begin
          r_iris.X:=i;
          r_iris.Y:=j;
          hohmin:=hoh;
        end
      end;
    {visualisations}

    {chosen}
    eyepicture.Canvas.Pen.Color:=clRed;
    eyepicture.Canvas.Brush.Style:=bsClear;
    {left iris}
    eyepicture.Canvas.MoveTo(l_iris.X-r,l_iris.Y);
    eyepicture.Canvas.LineTo(l_iris.X+r,l_iris.Y);
    eyepicture.Canvas.MoveTo(l_iris.X,l_iris.Y-r);
    eyepicture.Canvas.LineTo(l_iris.X,l_iris.Y+r);
    {right iris}
    eyepicture.Canvas.MoveTo(r_iris.X-r,r_iris.Y);
    eyepicture.Canvas.LineTo(r_iris.X+r,r_iris.Y);
    eyepicture.Canvas.MoveTo(r_iris.X,r_iris.Y-r);
    eyepicture.Canvas.LineTo(r_iris.X,r_iris.Y+r);


    {eye zones}
    //eyepicture.Canvas.Rectangle(l_eye);
    //eyepicture.Canvas.Rectangle(r_eye);

  form1.EyeImage.Canvas.Draw(0,0,eyepicture);
end;

procedure TForm1.TurnAroundClick(Sender: TObject);
begin
  ClearCanvas(TImage);
  Turn;
  PageControl1.TabIndex:=4;
  SaveButton.Enabled:=true;
end;

procedure TForm1.EyeButtonClick(Sender: TObject);
begin
  ClearCanvas(EyeImage);
  //EyeCatch;
  EyeCatch2;
  PageControl1.TabIndex:=3;
  turnaround.Enabled:=true;
  iris_finded:=true;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DIBpicture.Free;
  workpicture.Free;
end;

procedure TForm1.SaveButtonClick(Sender: TObject);
var
  savefilename:string;
begin
  if SaveDialog1.Execute then
  begin
    if pos('.',SaveDialog1.FileName)<>0 then
      savefilename:=SaveDialog1.FileName
    else
      savefilename:=SaveDialog1.FileName+'.bmp';
    turnpicture.SaveToFile(savefilename);
  end
end;

procedure CheckPicture (input : TBitmap);
var
  i,j : integer;
  sum, count :longint;
  l_med,r_med : longint;
  md : byte;
  m,sig : double;
  light : byte;
  lights:array [0..255] of longint;
  resstring:string;
  correct : boolean;
begin
  correct :=true;
  sum:=0;
  count:=0;
  l_med:=0;
  r_med:=0;
  resstring:='';
  sig:=0;
  for i:=0 to 255 do
    lights[i]:=0;

  {загрузка и анализ изображения}
  for i:=(input.Width div 4) to 3*(input.Width div 4) do
    for j:=(input.Height div 4) to 3*(input.Height div 4) do
    begin
      light:=workpicture.Canvas.Pixels[i,j] mod 256;
      sum :=sum+light;
      inc(count);
      inc(lights[light]);
    end;

  {среднее значение освещенности}
  m:=sum/count;
  resstring:=resstring+'Средняя яркость m='+floattostr(m)+#13;

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

  resstring:=resstring+'Медиана яркости md='+inttostr(md)+#13;

  {среднеквадратическое отклонение}
  for i:=0 to 255 do
    sig:=sig+lights[i]*sqr(i-m);
    sig:=sig/count; //дисперсия
    sig:=sqrt(sig); //отклонение
//  sig:=(sum_sq/count)-sqr(m);
  resstring:=resstring+'среднеквадратическое отклонение яркости sig='+floattostr(sig)+#13;

  resstring:=resstring+#13+'Контрольные величины'+#13+#13;
  resstring:=resstring+'sig/M='+floattostr(sig/m);
  if ((sig/m)>0.45) or ((sig/m)<0.2) then
  begin
    correct:=false;
    resstring:=resstring+' - ВНЕ ДОПУСТИМОГО ДИАПАЗОНА(0.2-0.45)!'+#13;
  end
  else     resstring:=resstring+' - норма'+#13;
  resstring:=resstring+'M='+floattostr(m);
  if (m>180) or (m<120) then
  begin
    correct:=false;
    resstring:=resstring+' - ВНЕ ДОПУСТИМОГО ДИАПАЗОНА(120-180)!'+#13;
  end
  else     resstring:=resstring+' - норма'+#13;
  resstring:=resstring+'M/Md='+floattostr(m/md);
  if ((m/md)>0.95) then
  begin
    correct:=false;
    resstring:=resstring+' - ВНЕ ДОПУСТИМОГО ДИАПАЗОНА (<0.95)! '+#13;
  end
  else     resstring:=resstring+' - норма'+#13;

  if not correct then resstring:=resstring+#13+'ИЗОБРАЖЕНИЕ НЕ ПОДХОДИТ ПО КОНТРОЛЬНЫМ ПАРАМЕТРАМ'+#13;

  {Вывод результата}
  ShowMessage (resstring);

end;

procedure TForm1.CheckButtonClick(Sender: TObject);
begin
  CheckPicture(workpicture);
end;

procedure TForm1.EyeImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  copyrect:TRect;
begin
  if (iris_finded) and (x<=eyepicture.Width) and (y<=eyepicture.Height) then
  begin
    if (x>r_iris.X) or (abs(r_iris.X-x)<abs(l_iris.X-x)) then
    begin
      r_iris.X:=x;
      r_iris.Y:=y;
    end
    else
    begin
      l_iris.X:=x;
      l_iris.Y:=y;
    end;

    copyrect.Left:=0;
    copyrect.Right:=workpicture.Width;
    copyrect.Top:=0;
    copyrect.Bottom:=workpicture.Height;

    eyepicture.Canvas.CopyRect(copyrect,workpicture.Canvas,copyrect);
    {visualisations}
    eyepicture.Canvas.Pen.Color:=clRed;
    eyepicture.Canvas.Brush.Style:=bsClear;
    {left iris}
    eyepicture.Canvas.MoveTo(l_iris.X-r,l_iris.Y);
    eyepicture.Canvas.LineTo(l_iris.X+r,l_iris.Y);
    eyepicture.Canvas.MoveTo(l_iris.X,l_iris.Y-r);
    eyepicture.Canvas.LineTo(l_iris.X,l_iris.Y+r);
    {right iris}
    eyepicture.Canvas.MoveTo(r_iris.X-r,r_iris.Y);
    eyepicture.Canvas.LineTo(r_iris.X+r,r_iris.Y);
    eyepicture.Canvas.MoveTo(r_iris.X,r_iris.Y-r);
    eyepicture.Canvas.LineTo(r_iris.X,r_iris.Y+r);

    form1.EyeImage.Canvas.Draw(0,0,eyepicture);
  end;
end;

end.
