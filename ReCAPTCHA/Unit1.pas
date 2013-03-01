unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ExtDlgs, Math;

type
  vert = record
    min : integer;
    max : integer;
    sr : integer;
    height : integer;
  end;

  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Button1: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button4: TButton;
    Button6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  captcha,ress : TBitmap;
  v_proj : array of vert;
  cap_sr,cap_height : integer;

implementation

{$R *.dfm}

procedure FreeCanvas (input:TImage);
begin
  input.Canvas.Pen.Color:=clWhite;
  input.Canvas.Brush.Color:=clWhite;
  input.Canvas.Rectangle(0,0,input.Width,input.Height);
end;

procedure FreeBitmap (input:TBitmap);
begin
  input.Canvas.Pen.Color:=clWhite;
  input.Canvas.Brush.Color:=clWhite;
  input.Canvas.Rectangle(0,0,input.Width,input.Height);
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

function Erosion (input : TBitmap) : TBitmap;
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
      // lights[1]:=(input.Canvas.Pixels[i-1,j-1] mod 256);
      // lights[2]:=(input.Canvas.Pixels[i-1,j] mod 256);
      // lights[3]:=(input.Canvas.Pixels[i-1,j+1] mod 256);
      // lights[4]:=(input.Canvas.Pixels[i,j-1] mod 256);
      // lights[5]:=(input.Canvas.Pixels[i,j] mod 256);
      // lights[6]:=(input.Canvas.Pixels[i,j+1] mod 256);
      // lights[7]:=(input.Canvas.Pixels[i+1,j-1] mod 256);
      // lights[8]:=(input.Canvas.Pixels[i+1,j] mod 256);
      // lights[9]:=(input.Canvas.Pixels[i+1,j+1] mod 256);

      lights[1]:=(input.Canvas.Pixels[i,j] mod 256);
      lights[2]:=(input.Canvas.Pixels[i+1,j] mod 256);
      lights[3]:=(input.Canvas.Pixels[i+1,j+1] mod 256);
      lights[4]:=(input.Canvas.Pixels[i,j+1] mod 256);


      for i1:=1 to 3 do
        for j1:=i1+1 to 4 do
          if lights[i1]>lights[j1] then
          begin
            light:=lights[i1];
            lights[i1]:=lights[j1];
            lights[j1]:=light;
          end;

      light:=lights[1];

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

function Dilation (input : TBitmap) : TBitmap;
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
      // lights[1]:=(input.Canvas.Pixels[i-1,j-1] mod 256);
      // lights[2]:=(input.Canvas.Pixels[i-1,j] mod 256);
      // lights[3]:=(input.Canvas.Pixels[i-1,j+1] mod 256);
      // lights[4]:=(input.Canvas.Pixels[i,j-1] mod 256);
      // lights[5]:=(input.Canvas.Pixels[i,j] mod 256);
      // lights[6]:=(input.Canvas.Pixels[i,j+1] mod 256);
      // lights[7]:=(input.Canvas.Pixels[i+1,j-1] mod 256);
      // lights[8]:=(input.Canvas.Pixels[i+1,j] mod 256);
      // lights[9]:=(input.Canvas.Pixels[i+1,j+1] mod 256);

      lights[1]:=(input.Canvas.Pixels[i,j] mod 256);
      lights[2]:=(input.Canvas.Pixels[i+1,j] mod 256);
      lights[3]:=(input.Canvas.Pixels[i+1,j+1] mod 256);
      lights[4]:=(input.Canvas.Pixels[i,j+1] mod 256);


      for i1:=1 to 3 do
        for j1:=i1+1 to 4 do
          if lights[i1]>lights[j1] then
          begin
            light:=lights[i1];
            lights[i1]:=lights[j1];
            lights[j1]:=light;
          end;

      light:=lights[4];

      if light<0 then light:=0;
      if light>255 then light:=255;
      output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
    end;
  //input.Free;
  Result :=output;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  captcha:= TBitmap.Create;
     ress:= TBitmap.Create;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  captcha.Free;
  ress.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    captcha.LoadFromFile(OpenPictureDialog1.FileName);
  FreeCanvas(Image1);
  Image1.Canvas.Draw(0,0,captcha);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  captcha:=Otsu(captcha);
  captcha:=Dilation(captcha);
  captcha:=Erosion(captcha);
  FreeCanvas(Image2);
  Image2.Canvas.Draw(0,0,captcha);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i,j : integer;
  sum_sr,sum_hei: integer;
  count: integer;
begin
  setlength(v_proj,captcha.width);
  sum_sr:=0;
  sum_hei:=0;
  count:=0;
  for i:=0 to captcha.width-1 do
  begin
    v_proj[i].min:=0;
    v_proj[i].max:=0;
    v_proj[i].sr:=0;
    v_proj[i].height:=0;
    for j:=0 to captcha.Height-1 do
      if captcha.Canvas.Pixels[i,j]=0 then
      begin
        v_proj[i].min:=j;
        break;
      end;
    for j:=captcha.Height-1 downto 0 do
      if captcha.Canvas.Pixels[i,j]=0 then
      begin
        v_proj[i].max:=j;
        break;
      end;
    v_proj[i].sr:=round((v_proj[i].min+v_proj[i].max)/2);
    v_proj[i].height:=v_proj[i].max-v_proj[i].min;
    if v_proj[i].height<>0 then
    begin
      sum_sr:=sum_sr+v_proj[i].sr;
      sum_hei:=sum_hei+v_proj[i].height;
      count:=count+1;
    end;
  end;
  cap_sr:=round(sum_sr/count);
  cap_height:=round(sum_hei/count);
  Label1.Caption:='—редн€€ высота буквы ' + floattostr(cap_height);
  Label2.Caption:='—реднее положение центра буквы ' + floattostr(cap_sr);

  for i:=0 to captcha.width-1 do
  begin
    if (v_proj[i].height<>0) then
    if (abs(v_proj[i].sr-cap_sr)>captcha.Height/4) then
      v_proj[i].sr:=cap_sr;
  end;

  for i:=0 to captcha.width-1 do
  begin
    if v_proj[i].height<>0 then
      Image2.Canvas.Pixels[i,v_proj[i].sr]:=255;
  end;



  ress.Width:=captcha.Width;
  ress.Height:=captcha.Height;
  FreeBitmap(ress);

  for i:=0 to captcha.width-1 do
  begin
    if v_proj[i].height<>0 then
    for j:=max(v_proj[i].sr-ceil(v_proj[i].height/2),0) to min(v_proj[i].sr+ceil(v_proj[i].height/2),captcha.height-1)do
    if v_proj[i].height>cap_height/1.5 then
      ress.Canvas.Pixels[i,j-(v_proj[i].sr-cap_sr)]:=captcha.Canvas.Pixels[i,j]
    else
      ress.Canvas.Pixels[i,j]:=captcha.Canvas.Pixels[i,j]
  end;


  FreeCanvas(Image3);
  Image3.Canvas.Draw(0,0,ress);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  //Opening = Dilation + Erosion
  //Closing = Erosion + Dilation
  ress:=Dilation(ress);
  ress:=Erosion(ress);
  FreeCanvas(Image3);
  Image3.Canvas.Draw(0,0,ress);
end;

// function laplasMod (input : TBitmap) : TBitmap;      
// var                                                  
//   output : TBitmap;                                  
//   i,j : integer;                                     
//   light : longint;                                   
// begin                                                
//   output:= TBitmap.Create;                           
//   output.Width:=input.Width;                         
//   output.Height:=input.Height;                       
//                                                      
//   for i:=0 to input.Width-1 do                       
//     for j:=0 to input.Height-1 do                    
//     begin                                            
//       light:=9*(input.Canvas.Pixels[i,j] mod 256)-   
//             2*(input.Canvas.Pixels[i+1,j] mod 256)-  
//             2*(input.Canvas.Pixels[i-1,j] mod 256)-  
//             2*(input.Canvas.Pixels[i,j+1] mod 256)-  
//             2*(input.Canvas.Pixels[i,j-1] mod 256);  
//                                                      
//       if light<0 then light:=0;                      
//       if light>255 then light:=255;                  
//       output.Canvas.Pixels[i,j]:=(65536+256+1)*light;
//     end;                                             
//   //input.Free;                                      
//   Result :=output;                                   
// end;


function wordCut (input : TBitmap) : TBitmap;
var
  output : TBitmap;
  i,i1,j,j1 : integer;
  light : longint;
  clear: boolean;
  dest,src : TRect;
begin
  output:= TBitmap.Create;
  output.Width:=input.Width;
  output.Height:=input.Height;

  i:=0;
  Repeat

    clear:=true;
    for i1:=0 to 4 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i+i1,j] mod 256;
      if light<200 then clear:=false;
    end;
    i:=i+5;
  Until not clear;
  src.left:=i-5;
  i:=i+5;
  Repeat
    clear:=true;
    for i1:=0 to 4 do
    for j:=0 to input.Height-1 do
    begin
      light:=input.Canvas.Pixels[i+i1,j] mod 256;
      if light<200 then clear:=false;
    end;
    i:=i+5;
  Until clear;
  src.right:=i;

  j:=0;
  Repeat
    clear:=true;
    for j1:=0 to 4 do
    for i:=src.Left to src.Right do
    begin
      light:=input.Canvas.Pixels[i,j+j1] mod 256;
      if light<200 then clear:=false;
    end;
    j:=j+5;
  Until not clear;
  src.top:=j-5;

  Repeat
    clear:=true;
    for j1:=0 to 4 do
    for i:=src.Left to src.Right do
    begin
      light:=input.Canvas.Pixels[i,j+j1] mod 256;
      if light<200 then clear:=false;
    end;
    j:=j+5;
  Until clear;
  src.bottom:=j-5;
  dest.Left:=0;
  dest.Right:=src.Right-src.Left;
  dest.Top:=0;
  dest.Bottom:=src.Bottom-src.Top;

  output.Canvas.CopyRect(dest,input.Canvas,src);
  //input.Free;
  Result :=output;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  captcha:=wordCut(captcha);
  FreeCanvas(Image1);
  Image1.Canvas.Draw(0,0,captcha);
end;

end.
