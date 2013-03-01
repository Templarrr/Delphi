unit Basic;

INTERFACE
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShlObj, ComObj, ActiveX, registry,zlib,db,DBTables, Masks;

Type
 PLongintArray=^TLongintArray;
 TLongintArray = array[0..(Maxint div 16) - 1] of Longint;

Const
 Deg_To_Rad:extended=pi/180;
 Rad_To_Deg:extended=180/pi;
 sin_45:extended=0.7071067811865;
 Bits_Per_Int=SizeOf(Integer)*8;

procedure HideTaskBar;
procedure ShowTaskBar;
procedure CreateLnk(const PathToObj, PathToLink, Desc, Param: string);
procedure DisableChangeControl;
procedure EnableChangeControl;
procedure AutorunInReg(name,path:string; add:boolean);
Function GetWinDir:string;
Function AltKeyDown : boolean;
Function ShiftKeyDown : boolean;
Function CtrlKeyDown : boolean;
Function CapsLock : boolean;
Function NumLock : boolean;
Function ScrollLock : boolean;
Function CaptureScreenRect(ARect : TRect): TBitmap;
Function CaptureScreen : TBitmap;
Function CaptureClientImage(Control:TControl):TBitmap;
Function CaptureControlImage(Control:TControl):TBitmap;
Function DelLeft(str:string; characters:integer=1) : string;
Function DelRight(str:string; characters:integer=1) : string;
Function DelLR(str:string; characters:integer=1) : string;
Procedure SetBit(var Data:longint;nPos:integer);{установка бита=1 по номеру}
Procedure ResetBit(var Data:longint;nPos:integer);{установка бита=0 по номеру}
Procedure InvertBit(var Data:longint;nPos:integer);{инверсия бита по номеру}
Procedure PutBit(var Data:longint;nPos:integer;Value:boolean);{установка бита=Value по номеру}
Function TestBit(const Data:longint;nPos:integer):boolean;{проверка значения бита}
Function UpCaseRus( ch : Char ) : Char;
Function LoCaseRus( ch : Char ) : Char;
Function ReplaceStr(const S, Srch, Replace: string): string;
Procedure AddStrToFile(const FileName:string;S:string;doNextLine:boolean);
Function GetFileSize(const FileName:string):longint;
Function IsDelphiRun:boolean;
function GetUserName:string;
{(c) 1999 Victor P. Ivlichev Kernel Library (ivlich@mail.ru) http://www.fortunecity.com/skyscraper/pixel/1000/delphi.htm }
Function UpperCaseRus(const S: string): string;
Function LowerCaseRus(const S: string): string;
Function CapCaseRus(const S: string): string;
Function InvertCaseRus(const S: string): string;
Function InvCaseRus( ch : Char ) : Char;
Function whatCaseRusCh(ch:char):byte;
Function whatCaseRus(s_word:string):byte;
Function AddShrTo(s:string; ch:char;maxlen:integer):string;
Function RotateStr(const s:string; NToRight:integer):string;
Function DoValidName(s:string;Flags:longint):string;
Function SignInt(const Value: Integer): SmallInt;
Function Between(A1,A2,Value:integer):boolean;
Procedure SwapInt(var a1,a2:integer);{обмен}
Procedure SwapWord(var a1,a2:word);{обмен}
Procedure SwapByte(var a1,a2:byte);{обмен}
Procedure SwapFloat(var a1,a2:extended);{обмен}
Procedure SwapDateTime(var a1,a2:TdateTime);{обмен}
Function DoValidFileName(const s:string):string;
Function ChangeEmptyFileExt(const FileName,Ext:string):string;
Function GetSystemPath: string;
Function DriveByteToRoot(Drive:byte):string;
Function DriveByteExists(Drive:byte):boolean;
Function GetComputerName:string;
function GetEnvVar(const VarName: string): string;
Function isPointInRect(const Point:TPoint;const Rect:TRect):boolean;
Function isRectInRect(const ALeft,ATop,ARight,ABottom,subLeft,subTop,subRight,subBottom:integer):boolean;
Function isPtInEllipse(const x,y:integer;const ALeft,ATop,ARight,ABottom:integer):boolean;
Function isRectCrossRect(const ALeft,ATop,ARight,ABottom,subLeft,subTop,subRight,subBottom:integer):boolean;
Function StdRectangle(R:Trect):Trect;
Function StdRect(var Left,Top,Right,Bottom:integer):TRect;
Function ScaleRect(R:TRect;Scale:double):TRect;
{Charger        charger@alba.dp.ua}
Procedure RegistryExt(Ext,Description,PathToExe:string; Icon:string='';event:string='DefaultAction'; eventDescr:string='open');
{Еще нет в Хелпе}
Function BinToDec(bin:string):integer;
Function BinToHex(bin:string):string;
function DecToBin(Dec:integer;dig:integer):string;
function WhatIsChar(a:char):integer;
function GetRegValue(RootKey:HKEY;KeyName,Parametr: string): string;
function SubStr(S:String;B:integer=1;E:integer=0): string;
function FindInStr(S,F:String;FindForward:boolean=true): integer;
function FindInStrI(S,F:String;FindForward:boolean=true): integer;
function StrRepeat(str:String;count:integer): string;
function FindPosition(str,separator:String;pos:integer): string;
function DelLastChar(str,ch:String):string;
function Rnd(min,max:integer):integer;
function SecondToMinute(n:integer;a:string=''):string;
function CVal(s:string;default:integer=0):integer;
procedure ZPackStream(Var sSrc: TMemoryStream);
procedure ZUnPackStream(Var sSrc: TMemoryStream);
function CountInStr(s,find:string):integer;
function GetFileOwner(FileName: string; var Domain, Username: string): Boolean;
procedure FindFiles(StartFolder, Mask: String; List: TStrings;ScanSubFolders: Boolean = True);
function CheckDirectory(DirName:string):boolean;
function Quote(str:string):string;
function GetFileVersion(const FileName: String;const param:integer): String;
function NumbToStr (Numb: Int64; Cl: byte; const Item1, Item2, Item3: String): String;
function ExecAndWait(const FileName, Params: ShortString; const WinState: Word): boolean; export;

implementation

procedure HideTaskBar;
var hTaskBar : THandle;
begin
hTaskbar := FindWindow('Shell_TrayWnd', Nil);
ShowWindow(hTaskBar, SW_HIDE);
end;{procedure}

procedure ShowTaskBar;
var hTaskBar : THandle;
begin
hTaskbar := FindWindow('Shell_TrayWnd', Nil);
ShowWindow(hTaskBar, SW_SHOWNORMAL);
end;{procedure}

Function GetWinDir:string;
var PRes: PChar;  // Каталог, где установлена Windows
    Res : word;
    BRes: boolean;
    lpVersionInformation : TOSVersionInfo;
    c: string;
begin
PRes := StrAlloc(255);
Res := GetWindowsDirectory(PRes, 255);
if Res > 0 then GetWinDir:= StrPas(PRes)+'\';
end;

procedure CreateLnk(const PathToObj, PathToLink, Desc, Param: string);
  var  //Создать ярлык
    IObject: IUnknown;
    SLink: IShellLink;
    PFile: IPersistFile;
begin
IObject := CreateComObject(CLSID_ShellLink);
SLink := IObject as IShellLink;
PFile := IObject as IPersistFile;
with SLink do begin
 SetArguments(PChar(Param));
 SetDescription(PChar(Desc));
 SetPath(PChar(PathToObj));
 end;
PFile.Save(PWChar(WideString(PathToLink)), FALSE);
end;

Function AltKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_MENU)) and $8000)>0;
end;

Function CtrlKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_CONTROL)) and $8000)>0;
end;

Function ShiftKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_SHIFT)) and $8000)>0;
end;

Function CapsLock : boolean;
begin
 result:=(GetKeyState(VK_CAPITAL) and 1)>0;
end;

Function NumLock : boolean;
begin
 result:=(GetKeyState(VK_NUMLOCK) and 1)>0;
end;

Function ScrollLock : boolean;
begin
 result:=(GetKeyState(VK_SCROLL) and 1)>0;
end;

Function GetSystemPalette : HPalette;
var
 PaletteSize  : integer;
 LogSize      : integer;
 LogPalette   : PLogPalette;
 DC           : HDC;
 Focus        : HWND;
begin
 result:=0;
 Focus:=GetFocus;
 DC:=GetDC(Focus);
 try
   PaletteSize:=GetDeviceCaps(DC, SIZEPALETTE);
   LogSize:=SizeOf(TLogPalette)+
  (PaletteSize-1)*SizeOf(TPaletteEntry);
   GetMem(LogPalette, LogSize);
   try
     with LogPalette^ do
     begin
       palVersion:=$0300;
       palNumEntries:=PaletteSize;
       GetSystemPaletteEntries(DC, 0, PaletteSize,
   palPalEntry);
     end;
     result:=CreatePalette(LogPalette^);
   finally
     FreeMem(LogPalette, LogSize);
   end;
 finally
   ReleaseDC(Focus, DC);
 end;
end;

{ Копирует прямоугольную область экрана }
function CaptureScreenRect(ARect : TRect) :
 TBitmap;
var
 ScreenDC : HDC;
begin
 Result:=TBitmap.Create;
 with result, ARect do begin
  Width:=Right-Left;
  Height:=Bottom-Top;
  ScreenDC:=GetDC(0);
  try
    BitBlt(Canvas.Handle, 0,0,Width,Height,
  ScreenDC,
  Left, Top, SRCCOPY );
  finally
    ReleaseDC(0, ScreenDC);
  end;
  Palette:=GetSystemPalette;
 end;
end;

 { Копирование всего экрана }
Function CaptureScreen : TBitmap;
begin
 with Screen do  Result:=CaptureScreenRect(Rect(0,0,Width,Height));
end;

 { Копирование клиентской области формы или элемента }
Function CaptureClientImage(Control : TControl):TBitmap;
begin
with Control, Control.ClientOrigin do
  result:=CaptureScreenRect(Bounds(X,Y,ClientWidth,ClientHeight));
end;

{ Копирование всей формы элемента }
function CaptureControlImage(Control : TControl):TBitmap;
begin
with Control do
  if Parent=Nil then result:=CaptureScreenRect(Bounds(Left,Top,Width,Height))
  else
   with Parent.ClientToScreen(Point(Left, Top)) do
    result:=CaptureScreenRect(Bounds(X,Y,Width,Height));
end;

procedure DisableChangeControl;
  var i : integer;
begin
  i := 0;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, @i, 0);
  SystemParametersInfo(SPI_SETFASTTASKSWITCH, 1, @i, 0);
end;

procedure EnableChangeControl;
  var i : integer;
begin
  i := 0;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, @i, 0);
  SystemParametersInfo(SPI_SETFASTTASKSWITCH, 0, @i, 0);
end;

procedure AutorunInReg(name,path:string; add:boolean);
var  Reg: TRegIniFile;
     a:string;
begin
 a:='\softWare\Microsoft\Windows\CurrentVersion\';
 Reg:=TRegIniFile.Create;
 Reg.RootKey:=HKEY_LOCAL_MACHINE;
 if add then reg.WriteString(a+'Run',name,path) else
 reg.DeleteKey(a+'run',name);
end;

Function DelLeft(str:string; characters:integer=1) : string;
Begin
DelLeft:=copy(str, characters+1, length(str)-characters);
end;{procedure}

Function DelRight(str:string; characters:integer=1) : string;
Begin
DelRight:=copy(str, 1, length(str)-characters);
end;{procedure}

Function DelLR(str:string; characters:integer=1) : string;
var sss:string;
Begin
sss:=copy(str, 1, length(str)-characters);
DelLR:=copy(sss, characters+1, length(str)-characters);
end;{procedure}

procedure SetBit(var Data:longint;nPos:integer);{установка бита=1 по номеру}
var
 Mask:longint;
begin
 Mask:=1;
 Mask:=Mask shl nPos;
 Data:=Data or Mask;
end;

procedure ResetBit(var Data:longint;nPos:integer);{установка бита=0 по номеру}
var
 Mask:longint;
begin
 Mask:=1;
 Mask:=Mask shl nPos;
 Mask:=not Mask;
 Data:=Data and Mask;
end;

procedure InvertBit(var Data:longint;nPos:integer);{инверсия бита по номеру}
var
 Mask:longint;
begin
 Mask:=1;
 Mask:=Mask shl nPos;
 Data:=Data xor Mask;
end;

procedure PutBit(var Data:longint;nPos:integer;Value:boolean);{установка бита=Value по номеру}
var
 Mask:longint;
begin
 Mask:=1;
 Mask:=Mask shl nPos;
 if Value=true then Data:=Data or Mask
 else begin
  Mask:=not Mask;
  Data:=Data and Mask;
 end;
end;

function TestBit(const Data:longint;nPos:integer):boolean;{проверка значения бита}
var
 Mask:longint;
begin
 Mask:=1;
 Mask:=Mask shl nPos;
 if (Mask and Data)=Mask then Result:=true else Result:=false;
end;

function UpCaseRus( ch : Char ) : Char;
asm
        CMP     AL,'a'
        JB      @@exit
        CMP     AL,'z'
        JA      @@Rus
        SUB     AL,'a' - 'A'
        RET
@@Rus:
        CMP     AL,'я'
        JA      @@Exit
        CMP     AL,'а'
        JB      @@yo
        SUB     AL,'я' - 'Я'
        RET
@@yo:
        CMP     AL,'ё'
        JNE      @@exit
        MOV     AL,'Ё'
@@exit:
end;

function LoCaseRus( ch : Char ) : Char;
asm
        CMP     AL,'A'
        JB      @@exit
        CMP     AL,'Z'
        JA      @@Rus
        ADD     AL,'a' - 'A'
        RET
@@Rus:
        CMP     AL,'Я'
        JA      @@Exit
        CMP     AL,'А'
        JB      @@yo
        ADD     AL,'я' - 'Я'
        RET
@@yo:
        CMP     AL,'Ё'
        JNE      @@exit
        MOV     AL,'ё'
@@exit:
end;

function ReplaceStr(const S, Srch, Replace: string): string;
{замена подстроки в строке}
var
 I:Integer;
 Source:string;
begin
 Source:= S;
 Result:= '';
 repeat
  I:=Pos(Srch, Source);
  if I > 0 then begin
   Result:=Result+Copy(Source,1,I-1)+Replace;
   Source:=Copy(Source,I+Length(Srch),MaxInt);
  end else Result:=Result+Source;
 until I<=0;
end;

procedure AddStrToFile(const FileName:string;S:string;doNextLine:boolean);
{Добавление строки к файлу doNextLine - перевод строки}
const
 CR=#13#10;
var
 f:TFileStream;
begin
 if FileExists(FileName)
 then f:=TFileStream.Create(FileName,fmOpenWrite+fmShareDenyNone)
 else f:=TFileStream.Create(FileName,fmCreate);
 f.Position:=f.Size;
 if doNextLine and (f.Size>0)
 then f.Write(CR,2);
 f.Write(pointer(s)^,length(s));
 f.Destroy;
end;

function GetFileSize(const FileName:string):longint;
{Определение размера файла}
var
 SearchRec:TSearchRec;
begin
 if FindFirst(ExpandFileName(FileName),faAnyFile,SearchRec)=0
 then Result:=SearchRec.Size
 else Result:=-1;
 FindClose(SearchRec);
end;

function IsDelphiRun:boolean;
{Работает ли Delphi сейчас}
var
 h1,h2,h3:Hwnd;
begin
 h1:=FindWindow('TAppBuilder',nil);
 h2:=FindWindow('TAlignPalette',nil);
 h3:=FindWindow('TPropertyInspector',nil);
 Result:=(h1<>0)and(h2<>0)and(h3<>0);
end;

function GetUserName:string;
{Определение имени пользователя}
var
 Buffer: array[0..MAX_PATH] of Char;
 sz:DWord;
begin
 sz:=MAX_PATH-1;
 if windows.GetUserName(Buffer,sz)
 then begin
  if sz>0 then dec(sz);
  SetString(Result,Buffer,sz);
 end else begin
  Result:='Error '+inttostr(GetLastError);
 end;
end;

{byte utils}



{string utils}
function UpperCaseRus(const S: string): string;
var
  Ch: Char;
  L: Integer;
  Source, Dest: PChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32)
    else if (Ch>='а')and (Ch<='я') then Dec(Ch,32)
    else if Ch='ё' then Ch:='Ё';
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function LowerCaseRus(const S: string): string;
var
  Ch: Char;
  L: Integer;
  Source, Dest: PChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'A') and (Ch <= 'Z') then Inc(Ch, 32)
    else if (Ch>='А')and (Ch<='Я') then Inc(Ch,32)
    else if Ch='Ё' then Ch:='ё';
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function CapCaseRus(const S: string): string;
var
 startword:boolean;
 i:integer;
begin
 startword:=true;
 Result:=s;
 for i:=1 to length(Result) do begin
  if startword then Result[i]:=UpCaseRus(Result[i])
  else Result[i]:=LoCaseRus(Result[i]);
  startword:=Result[i] in [' ','.',',',';',':','?','!','-'];
 end;
end;

function InvertCaseRus(const S: string): string;
var
 i:integer;
begin
 Result:=s;
 for i:=1 to length(s) do begin
  result[i]:=invCaseRus(Result[i]);
 end;
end;


function InvCaseRus( ch : Char ) : Char;
asm
{ ->    AL      Character       }
{ <-    AL      Result          }

        CMP     AL,'A'
        JB      @@up
        CMP     AL,'Z'
        JA      @@Rus
        ADD     AL,'a' - 'A'
        RET
@@Rus:
        CMP     AL,'Я'
        JA      @@up
        CMP     AL,'А'
        JB      @@yo
        ADD     AL,'я' - 'Я'
        RET
@@yo:
        CMP     AL,'Ё'
        JNE      @@up
        MOV     AL,'ё'
@@up:
        CMP     AL,'a'
        JB      @@exit
        CMP     AL,'z'
        JA      @@upRus
        SUB     AL,'a' - 'A'
        RET
@@upRus:
        CMP     AL,'я'
        JA      @@Exit
        CMP     AL,'а'
        JB      @@upyo
        SUB     AL,'я' - 'Я'
        RET
@@upyo:
        CMP     AL,'ё'
        JNE      @@exit
        MOV     AL,'Ё'
@@exit:
end;


function whatCaseRusCh(ch:char):byte;
 {return case of character 0:not letter 1:locase; 2:upcase}
asm
{ ->    AL      Character       }
{ <-    AL      Result          }
{CHECK UP LAT}
        CMP     AL,'A'
        JB      @@lo_lat
        CMP     AL,'Z'
        JA      @@lo_lat
        MOV     AL,2
        RET
@@lo_lat:
        CMP     AL,'a'
        JB      @@up_rus
        CMP     AL,'z'
        JA      @@up_rus
        MOV     AL,1
        RET
@@up_Rus:
        CMP     AL,'Я'
        JA      @@up_yo
        CMP     AL,'А'
        JB      @@up_yo
        MOV     AL,2
        RET
@@up_yo:
        CMP     AL,'Ё'
        JNE      @@lo_Rus
        MOV     AL,2
        RET
@@lo_Rus:
        CMP     AL,'я'
        JA      @@lo_yo
        CMP     AL,'а'
        JB      @@lo_yo
        MOV     AL,1
        RET
@@lo_yo:
        CMP     AL,'ё'
        JNE      @@not_letter
        MOV     AL,1
        RET
@@not_letter:
        MOV     AL,0
end;

function whatCaseRus(s_word:string):byte;
 {return case of caharacters in word 0:different,1:locase,2:upcase,3:capcase}
var
 i:integer;
 case1:byte;
{ nonletters,}locases,upcases:integer;
begin
 if s_word='' then begin
  result:=0;
  exit;
 end;
 case1:=whatCaseRusCh(s_word[1]);
 if length(s_word)=1 then begin
  Result:=case1;
  exit;
 end;
// nonletters:=0;
 locases:=0;
 upcases:=0;
 for i:=2 to length(s_word) do begin
  case whatCaseRusCh(s_word[i]) of
//  0:inc(nonletters);
  1:inc(locases);
  2:inc(upcases);
  end;
 end;
 if locases=0 then Result:=2
 else if upcases=0 then Result:=1
 else Result:=0;
 if (Result=1)and (case1=2) then Result:=3
 else if (Result=2)and (case1=1) then Result:=0;
end;

function AddShrTo(s:string; ch:char;maxlen:integer):string;
var
 i:integer;
begin
 result:=s;
 for i:=length(s)+1 to maxlen do Result:=Result+ch;
end;

function RotateStr(const s:string;NToRight:integer):string;
var
 i,l:integer;
 ch:char;
begin
 Result:=s;
 l:=length(Result);
 if l<2 then exit;
 if NToRight>0 then begin
  for i:=1 to NToRight do begin
   ch:=Result[l];
   Result:=ch+copy(Result,1,l-1);
  end;
 end else begin
  for i:=-1 downto NToRight do begin
   ch:=Result[1];
   delete(Result,1,1);
   Result:=Result+ch;
  end;
 end;
end;

function DoValidName(s:string;Flags:longint):string;{оставить в строке только допустимые символы}
{оставить в строке только допустимые символы}
 {1:allow English Letters; 2:allow Rus Letters; 4:allow digits; 8:allow digits in first pos;
  16:replace other to _}
var
 i:integer;
 ch:char;
begin
 Result:='';
 for i:=1 to length(s) do begin
  ch:=s[i];
  if ((flags and 1)=1)and (ch in['a'..'z','A'..'Z']) then result:=Result+ch
  else if ((flags and 2)=2)and (ch in['а'..'я','А'..'Я','ё','Ё']) then result:=Result+ch
  else if ((flags and 4)=4)and (ch in['0'..'9']) then begin
   if ((flags and 8)=8)or(length(s)>0)
   then Result:=Result+ch;
  end else if ((flags and 16)=16) then Result:=Result+'_';
 end;
end;

{calc utils}
function SignInt(const Value: Integer): SmallInt;
begin
 if Value > 0 then Result := 1
 else if Value = 0 then Result := 0
 else Result := -1;
end;

function Between(A1,A2,Value:integer):boolean;
{находится ли Value от A1 до A2 включительно, A1 может быть больше или меньше или равно A2 }
begin
 if (Value<=A1) and (Value>=A2) then Result:=true
 else if (Value>=A1) and (Value<=A2) then Result:=true
 else Result:=false;
end;



procedure SwapInt(var a1,a2:integer);{обмен}
var
 x:integer;
begin
 x:=a1;
 a1:=a2;
 a2:=x;
end;

procedure SwapWord(var a1,a2:word);{обмен}
var
 x:word;
begin
 x:=a1;
 a1:=a2;
 a2:=x;
end;

procedure SwapByte(var a1,a2:byte);{обмен}
var
 x:byte;
begin
 x:=a1;
 a1:=a2;
 a2:=x;
end;

procedure SwapFloat(var a1,a2:extended);{обмен}
var
 x:extended;
begin
 x:=a1;
 a1:=a2;
 a2:=x;
end;

procedure SwapDateTime(var a1,a2:TdateTime);{обмен}
var
 x:TDateTime;
begin
 x:=a1;
 a1:=a2;
 a2:=x;
end;

{file string utils}




function DoValidFileName(const s:string):string;
{создать из строки доп имя файла}
{inv}
const
 InvalidChars='?*:><\/|"'';,=+[]';
var
 i,j:integer;
 ch:char;
begin
 Result:=s;
 for i:=1 to length(Result) do begin
  ch:=result[i];
  for j:=1 to length(InvalidChars) do begin
   if ch=InvalidChars[j] then begin
    Result[i]:=' ';
    break;
   end;
  end;
 end;
 Result:=trim(Result);
end;

function ChangeEmptyFileExt(const FileName,Ext:string):string;
 {изменить расширение имени файла, если у него имеется пустое расширени}
var
 NewExt,OldExt:string;
begin
 OldExt:=ExtractFileExt(FileName);
 if (OldExt='')or(oldExt='.') then begin
  if (Ext='') or (Ext='.')then NewExt:=''
  else if Ext[1]<>'.' then NewExt:='.'+Ext
  else NewExt:=Ext;
  Result:=ChangeFileExt(FileName,NewExt);
 end else Result:=Filename;
end;

{system utils}
function GetSystemPath: string;
var
 Buffer: array[0..MAX_PATH] of Char;
begin
 SetString(Result, Buffer, windows.GetSystemDirectory(Buffer,SizeOf(Buffer)));
 Result:=Result+'\';
end;

function GetComputerName:string;
var
 Buffer: array[0..MAX_PATH] of Char;
 sz:DWord;
begin
 sz:=MAX_PATH-1;
 if windows.GetComputerName(Buffer,sz)
 then begin
//  if sz>0 then dec(sz);
  SetString(Result,Buffer,sz);
 end else if GetLastError<>0 then  Result:='#Error#'+inttostr(GetLastError)
 else Result:='';
end;

function GetEnvVar(const VarName: string): string;
var
  i: integer;
begin
  Result := '';
  try
    i := GetEnvironmentVariable(PChar(VarName), nil, 0);
    if i > 0 then
      begin
        SetLength(Result, i-1);
        GetEnvironmentVariable(Pchar(VarName), PChar(Result), i);
      end;
  except
    Result := '';
  end;
end;

function DriveByteToRoot(Drive:byte):string;
{convert Number of Logical Drive to path
for example: 0->A, 1->B}
Begin
 result:=Chr(Drive+$41)+':\';
End;

function DriveByteExists(Drive:byte):boolean;
{A:0; B:1; C:3}
Begin
 Result:=Boolean(GetLogicalDrives AND (1 shl Drive))
End;

function isPointInRect(const Point:TPoint;const Rect:TRect):boolean;
begin
 with Rect do begin
  Result:=(Point.x>=Left)and(Point.x<Right)
  and(Point.y>=Top)and(Point.y<Bottom);
 end;
end;

function isPtInEllipse(const x,y:integer;const ALeft,ATop,ARight,ABottom:integer):boolean;
{если эллипс не круг, то модифицирум все координаты, чтобы эллипс стал кругом
см. док PINC # 1}
var
 x0,y0:extended;{center of circle}
 EHeight,EWidth:integer;{размеры эллипса}
 xs,ys:extended;{координаты точки в системе круга}
 ek:extended;{коэффицинт отношения большей стороны к меньшей}
 dx,dy,R,Dist:extended;
begin
{проверка на описывающий прямоугольник}
 if (x<ALeft) then Result:=false
 else if (x>ARight)then Result:=false
 else if (y<ATop) then Result:=false
 else if (y<=ABottom) then Result:=true
 else Result:=false;
 if Result=false then exit;
 Result:=false;
 EWidth:=ARight-ALeft;
 EHeight:=ABottom-ATop;
 if (EHeight=0) or (EWidth=0) then exit;
 x0:=(ARight+ALeft)*0.5;
 y0:=(ABottom+ATop)*0.5;
 xs:=x;
 ys:=y;
 R:=EHeight*0.5;
 if EWidth<EHeight then begin
  ek:=EHeight/EWidth;
  x0:=x0*ek;
  xs:=xs*ek;
 end else if EWidth>EHeight then begin
  ek:=EWidth/EHeight;
  y0:=y0*ek;
  ys:=ys*ek;
  R:=R*ek;
 end;
 dx:=xs-x0;
 dy:=ys-y0;
 Dist:=sqrt(dx*dx+dy*dy);
 if Dist<=R then Result:=true;
end;

function isRectInRect(const ALeft,ATop,ARight,ABottom,subLeft,subTop,subRight,subBottom:integer):boolean;
 {находится ли прямоугольник sub в прямоугольнике A включительно}
begin
 if between(Aleft,Aright,subLeft)=false then result:=false
 else if between(Aleft,Aright,subRight)=false then result:=false
 else if between(ATop,ABottom,subTop)=false then result:=false
 else if between(ATop,ABottom,subBottom)=false then result:=false
 else Result:=true;
end;

function isRectCrossRect(const ALeft,ATop,ARight,ABottom,subLeft,subTop,subRight,subBottom:integer):boolean;
 {пересекает ли прямоугольник sub прямоугольник A включительно}
var
 isLeft,isRight,isTop,isBottom:boolean;
begin
 isleft:=between(Aleft,Aright,subLeft);
 isRight:=between(Aleft,Aright,subRight);
 isTop:=between(ATop,ABottom,subTop);
 isBottom:=between(ATop,ABottom,subBottom);
 if isTop and isLeft then Result:=true
 else if isTop and isRight then Result:=true
 else if isBottom and isLeft then Result:=true
 else if isBottom and isRight then Result:=true
 else Result:=false;
end;

function StdRect(var Left,Top,Right,Bottom:integer):TRect;
{приводит прямоугольник к  стандартному расположению left<=right,top<=bottom}
var
 x:integer;
begin
 if Left>Right then begin
  x:=Left;
  Left:=Right;
  Right:=x;
 end;
 if Top>Bottom then begin
  x:=Top;
  Top:=Bottom;
  Bottom:=x;
 end;
 Result.Left:=Left;
 Result.Right:=Right;
 Result.Top:=Top;
 Result.Bottom:=Bottom;
end;

function ScaleRect(R:TRect;Scale:double):TRect;//масштабирование всех координат прямоугольника
//масштабирование всех координат прямоугольника
begin
 with Result do begin
  Left:=Round(R.Left*Scale);
  Right:=Round(R.Right*Scale);
  Top:=Round(R.Top*Scale);
  Bottom:=Round(R.Bottom*Scale);
 end;
end;

function StdRectangle(R:Trect):Trect;
 {возвращает прямоугольник со стандартным расположением left<=right,top<=bottom}
begin
 Result:=R;
 if R.Left>R.Right then begin
  Result.Left:=R.Right;
  Result.Right:=R.Left;
 end;
 if R.Top>R.Bottom then begin
  Result.Top:=R.Bottom;
  Result.Bottom:=R.Top;
 end;
end;

Procedure RegistryExt(Ext,Description,PathToExe:string; Icon:string='';event:string='DefaultAction'; eventDescr:string='open');
var
 R : TRegIniFile;
begin
if icon='' then icon:=PathToExe+',0';
R:= TRegIniFile.Create('');
with R do begin
RootKey := HKEY_CLASSES_ROOT;
WriteString(ext,'','MyExt');
WriteString('MyExt','',Description);
WriteString('MyExt\DefaultIcon' ,'',Icon);
WriteString('MyExt\Shell','','DefaultAction');
WriteString('MyExt\Shell\'+event,'', EventDescr);
WriteString('MyExt\Shell\'+event+'\command','',PathToExe);
Free;
end;
end;

function BinToDec(bin:string):integer;
var n,b:integer;
begin
b:=0;
for n:=1 to length(bin) do begin
if bin[length(bin)-n+1]='1' then b:=b+round(exp(ln(2)*(n-1)));
end;
BinToDec:=b;
end;{function}

function BinToHex(bin:string):string;
var n,m,b:integer;
    a:string;
    const hex:array[1..16] of char=('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
    const binary:array[1..16] of string=('0000','0001','0010','0011','0100','0101','0110','0111','1000','1001','1010','1011','1100','1101','1110','1111');
begin
while length(bin)<4 do bin:='0'+bin;
a:='';n:=1;while n<length(bin) do begin
for m:=1 to 16 do begin
if copy(bin,n,4)=binary[m] then begin a:=a+hex[m];n:=n+4 end;
end;end;BinToHex:=a;
end;{function}

function DecToBin(Dec:integer;dig:integer):string;
var m:integer;
begin
Result:='';
for m:=0 to dig do
if TestBit(dec,m) then Result:='1'+Result else Result:='0'+Result;
end;{function}

function WhatIsChar(a:char):integer;
begin
result:=0;
if ord(a) in [48..57] then result:=1; {Цифра}
if ord(a) in [65..90] then result:=2; {Большая латинская}
if ord(a) in [97..122] then result:=3; {Малая латинская}
if ord(a) in [192..223] then result:=4; {Большая русская}
if ord(a) in [224..255] then result:=5; {Малая русская}
end;

function GetRegValue(RootKey:HKEY;KeyName,Parametr: string): string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := RootKey;
    Registry.OpenKey(KeyName, False); // False because we do not want to create it if it doesn't exist
    Result := Registry.ReadString(Parametr);
  finally
    Registry.Free;
  end;
end;

function SubStr(S:String;B:integer=1;E:integer=0): string;
var n:integer;
begin
n:=length(S);
if b<0 then b:=n+b;
if e=0 then e:=n-b+1;
if e<0 then e:=n-b+e+1;
Result:=copy(s,B,E);
end;

function FindInStr(S,F:String;FindForward:boolean=true): integer;
var n:integer;
begin
result:=-1;
if FindForward then
  for n:=1 to length(S) do if SubStr(S,n,length(F))=F then begin result:=n;exit;end;
if not FindForward then
  for n:=length(S) downto 1 do if SubStr(S,n,length(F))=F then begin result:=n;exit;end;
end;

function FindInStrI(S,F:String;FindForward:boolean=true): integer; // без учета регистра
var n:integer;
begin
result:=-1;
if FindForward then
  for n:=1 to length(S) do if AnsiStrIComp(pchar(SubStr(S,n,length(F))),pchar(F))=0 then begin result:=n;exit;end;
if not FindForward then
  for n:=length(S) downto 1 do if AnsiStrIComp(pchar(SubStr(S,n,length(F))),pchar(F))=0 then begin result:=n;exit;end;
end;

function StrRepeat(str:String;count:integer): string;
var n:integer;
begin
result:='';
for n:=1 to count do result:=result+str;
end;

function FindPosition(str,separator:String;pos:integer): string;
var StartPos,EndPos,part,b,correcter:integer;
begin
b:=1;
str:=str+separator+'`'+separator;
part:=0;
StartPos:=0;
EndPos:=-1;
correcter:=0;
while (pos<>part) AND (b<=length(str)) do begin
if (copy(str,b,length(separator)))=separator then begin
  if EndPos<>-1 then  begin StartPos:=EndPos+length(separator);correcter:=0;end else begin StartPos:=0;correcter:=1;end;
  EndPos:=b;
  part:=part+1;
  end;
b:=b+1;
end;
if b<length(str) then
    result:=DelLastChar(copy(str,StartPos,(EndPos-StartPos-correcter)),separator)
    else result:='';
end;


function DelLastChar(str,ch:String):string;
var a,s:integer;
begin
a:=length(str);
s:=length(ch);
if copy(str,a-s+1,s)=ch then result:=copy(str,1,a-s) else result:=str;
end;

function Rnd(min,max:integer):integer;
begin
result:=round(random(max-min))+min+1;
end;

function SecondToMinute(n:integer;a:string=''):string;
begin
if n=0 then begin result:=a;exit;end;
result:=format('%d м %d с',[round(int(n/60)),round((n-int(n/60)*60))]);
end;

function CVal(s:string;default:integer=0):integer;
begin
if s='' then begin result:=default;exit;end;
try
result:=strtoint(s);
except
result:=default;
end;
end;


procedure ZPackStream(Var sSrc: TMemoryStream);
var //by  RIVco mailto:r%69v%63o%40p%6Cc%61r%64.%69m%70e%78b%61n%6B.%72u
  UnknownPtr :pointer;
  NewSize    :integer;
begin
  sSrc.Position:=0;
  try
    CompressBuf(sSrc.Memory,sSrc.Size,UnknownPtr,NewSize);
    sSrc.clear;
    sSrc.Write(UnknownPtr^,NewSize);
    sSrc.Position:=0;
  finally
    FreeMem(UnknownPtr,NewSize);
  end;
end;

procedure ZUnPackStream(Var sSrc: TMemoryStream);
var //by  RIVco mailto:r%69v%63o%40p%6Cc%61r%64.%69m%70e%78b%61n%6B.%72u
  UnknownPtr :pointer;
  NewSize    :integer;
begin
  sSrc.Position:=0;
  try
    DeCompressBuf(sSrc.Memory,sSrc.Size,0,UnknownPtr,NewSize);
    sSrc.clear;
    sSrc.Position:=0;
    sSrc.Write(UnknownPtr^,NewSize);
    sSrc.Position:=0;
  finally
    FreeMem(UnknownPtr,NewSize);
  end;
end;

function CountInStr(s,find:string):integer;
var
  n,t,m: Integer;
begin
result:=0;
m:=length(find);
t:=length(s)-m;
for n := 1 to t do begin
if copy(s,n,m)=find then result:=result+1;
end;
end;

function GetFileOwner(FileName: string; var Domain, Username: string): Boolean;
{Определить владельца файла}
var
  SecDescr: PSecurityDescriptor;
  SizeNeeded, SizeNeeded2: DWORD;
  OwnerSID: PSID;
  OwnerDefault: BOOL;
  OwnerName, DomainName: PChar;
  OwnerType: SID_NAME_USE;
begin
  GetFileOwner := False;
  GetMem(SecDescr, 1024);
  GetMem(OwnerSID, SizeOf(PSID));
  GetMem(OwnerName, 1024);
  GetMem(DomainName, 1024);
  try
    if not GetFileSecurity(PChar(FileName),
      OWNER_SECURITY_INFORMATION,
      SecDescr, 1024, SizeNeeded) then
      Exit;
    if not GetSecurityDescriptorOwner(SecDescr,
      OwnerSID, OwnerDefault) then
      Exit;
    SizeNeeded  := 1024;
    SizeNeeded2 := 1024;
    if not LookupAccountSID(nil, OwnerSID, OwnerName,
      SizeNeeded, DomainName, SizeNeeded2, OwnerType) then
      Exit;
    Domain  := DomainName;
    Username := OwnerName;
  finally
    FreeMem(SecDescr);
    FreeMem(OwnerName);
    FreeMem(DomainName);
  end;
  GetFileOwner := True;
end;

///Dimka Maslov (Санкт-Петербург) (29 апреля 2002 г.) © Dimka Maslov
//Поиск файлов по маске по всему дереву каталогов, начиная с указанного
procedure FindFiles(StartFolder, Mask: String; List: TStrings;ScanSubFolders: Boolean = True);
var
SearchRec: TSearchRec;
FindResult:
Integer;
begin
List.BeginUpdate;
try
StartFolder:=IncludeTrailingBackslash(StartFolder);
FindResult:=FindFirst(StartFolder+'*.*', faAnyFile, SearchRec);
try
while FindResult = 0 do with SearchRec do begin
if (Attr and
faDirectory)<>0 then begin
if ScanSubFolders and
(Name<>'.') and (Name<>'..') then
FindFiles(StartFolder+Name, Mask, List, ScanSubFolders);
end else begin
if MatchesMask(Name, Mask) then
List.Add(StartFolder+Name);
end;
FindResult:=FindNext(SearchRec);
end;
finally
FindClose(SearchRec);
end;
finally
List.EndUpdate;
end;
end;

function CheckDirectory(DirName:string):boolean;
begin //проверить есть ли такая директория и если нет, то создать
if not DirectoryExists(DirName) then
 if not CreateDir(DirName) then result:=false else result:=true;
end;

function Quote(str:string):string;
begin //Обрамить строку кавычками
result:=#39+str+#39;
end;

function GetFileVersion(const FileName: String;const param:integer): String;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
  ver1,ver2,ver3,build:string;
begin
  Result := '';
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then begin
        ver1:=IntToStr(FI.dwFileVersionMS shr 16);
        ver2:=IntToStr(FI.dwFileVersionMS and $FFFF);
        ver3:=IntToStr(FI.dwFileVersionLS shr 16);
        build:=IntToStr(FI.dwFileVersionLS and $FFFF);
        if param=0 then Result := ver1 + '.' +ver2+ '.'+ver3 + ' build '+build;
        if param=1 then Result := ver1;
        if param=2 then Result := ver2;
        if param=3 then Result := ver3;
        if param=4 then Result := build;
        end;
     finally
        FreeMem(VerBuf);
     end;
  end;
end;

function NumbToStr (Numb: Int64; Cl: byte; const Item1, Item2, Item3: String): String;
{Описание: Преобразование числа в его текстовую запись или, другими словами, з
апись числа прописью. Подпрограммы на Basic, Pascal. Требование записи денежной
суммы прописью актуально для любой бухгалтерской программы. Предлагаемая
подпрограмма позволяет получить текстовое представление целого числа. Если
денежная сумма содержит копейки, подпрограмму нужно вызывать дважды - первый раз
для рублей, второй - для копеек. Функция NumbToStr принимает следующие параметры:
Numb - целое число, которое нужно представить в виде текстовой записи; Cl - род
определяемого слова: 1 - мужской ("рубль"); 2 - женский ("тонна"); 0 - средний
("ведро"); Item1 - образец записи определяемого слова в количестве "одна штука";
Item2 - образец записи определяемого слова в количестве "две-четыре штуки";
Item3 - образец записи определяемого слова в количестве "много штук". Функция
возвращает текстовую запись целого числа с последующим указанием через пробел
определяемого слова.}
  {===============================================================}
  {число прописью}
  { Выбор определяемого слова в соответствии с величиной числа.   }
  { Вызов: N     - значение младшей триады,                       }
  {        Item1 - определяемое слово для Ед.(N) = 1,             }
  {        Item2 - определяемое слово для 1 < Ед.(N) < 5,         }
  {        Item3 - определяемое слово в остальных случаях.        }
  {===============================================================}
const
  {----------------------------------}
  { Текстовая запись разрядов триад. }
  {----------------------------------}
  SN: array [1..4, 1..9] of String =
      (('один', 'два', 'три', 'четыре', 'п`ять', 'шість', 'сім', 'вісімь', 'дев`ять'),
      ('десять', 'дванадцать', 'тринадцать', 'сорок', 'п`ятьдесят', 'шістьдесят', 'сімьдесят', 'вісімьдесят', 'дев`яносто'),
      ('сто', 'двісти', 'триста', 'чотириста', 'п`ятьсот', 'шістьсот', 'сімьсот', 'вісімьсот', 'дев`ятьсот'),
      ('одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать'));

  function GetDeterm (N: Integer; Item1: String; Item2: String; Item3: String): String;
  var
    N1, N2: integer;        { разряды триады }
  begin
    N1 := N mod 10;      { разряд единиц триады }
    N := N div 10;
    N2 := N mod 10;      { разряд десятков триады }
    if N2 <> 1 then
      case N1 of
        1: GetDeterm := Item1;
        2..4: GetDeterm := Item2;
      else
        GetDeterm := Item3
      end
    else
      GetDeterm := Item3
  end;
  {========================================================}
  { Преобразование триады в текстовую запись.              }
  { Вызов: Triad - числовое значение триады (от 0 до 999), }
  {        Cl    - род определяемого слова.                }
  { Возврат: текстовая запись триады.                      }
  {========================================================}
  function TriadToStr (Triad: integer; Cl: byte): String;
  var
    TTS: String;          { аккумулятор - текстовая запись триады }
    N1, N2, N3: integer;  { разряды триады }
  begin
    {-------------------------------------------}
    { Проверка необходимости выполнения работы. }
    {-------------------------------------------}
    if Triad = 0 then
    begin
      TriadToStr := '';
      Exit
    end;
    TTS := '';
    {---------------------------------------------}
    { Выделение разрядов единиц, десятков, сотен. }
    {---------------------------------------------}
    N1 := Triad mod 10; Triad := Trunc (Triad * 0.1);
    N2 := Triad mod 10; Triad := Trunc (Triad * 0.1);
    N3 := Triad;
    {---------------------------}
    { Обработка разряда единиц. }
    {---------------------------}
    if N2 = 1 then
      if N1 = 0 then TTS := SN[2, 1] else TTS := SN[4, N1]
    else
      if N1 > 0 then
        if N1 = 1 then
          case Cl of
            0: TTS := 'одно';
            1: TTS := SN[1,1];
            2: TTS := 'одна'
          end
        else if N1 = 2 then
          case Cl of
            0, 1: TTS := SN[1, N1];
            2: TTS := 'две'
          end
        else
          TTS := SN[1, N1];
    {-----------------------------}
    { Обработка разряда десятков. }
    {-----------------------------}
    if N2 > 1 then
      if N1 > 0 then
        TTS := SN[2, N2] + ' ' + TTS
      else
        TTS := SN[2, N2];
    {---------------------------}
    { Разработка разряда сотен. }
    {---------------------------}
    if N3 > 0 then
      if N1 + N2 > 0 then
        TTS := SN[3, N3] + ' ' + TTS
      else
        TTS := SN[3, N3];
    TriadToStr := TTS
  end;
var
  NTS: String;      { текстовая запись преобразуемого числа }
  Triad: integer;   { величина триады }
  St: integer;      { номер преобразуемой триады }
begin
  if Numb = 0 then
  begin
    NumbToStr := '';
    Exit
  end;
  NTS := GetDeterm (Numb mod 1000, Item1, Item2, Item3);
  St := 1;
  {------------------------------------------------}
  { Перебор триад и формирование текстовой записи. }
  {------------------------------------------------}
  while Numb > 0 do
  begin
    Triad := Numb mod 1000;
    case St of
      1: { единицы }
        if Triad > 0 then
          NTS := TriadToStr (Triad, Cl) + ' ' + NTS;
      2: { тысячи }
        If Triad > 0 then
          NTS := TriadToStr (Triad, 2) + ' ' + GetDeterm (Triad, 'тысяча', 'тысячи', 'тысяч') + ' ' + NTS;
      3: { миллионы }
        If Triad > 0 then
          NTS := TriadToStr (Triad, 1) + ' ' + GetDeterm (Triad, 'миллион', 'миллиона', 'миллионов') + ' ' + NTS;
      4: { миллиарды }
        If Triad > 0 then
          NTS := TriadToStr (Triad, 1) + ' ' + GetDeterm (Triad, 'миллиард', 'миллиарда', 'миллиардов') + ' ' + NTS;
      5: { триллионы }
        If Triad > 0 then
          NTS := TriadToStr (Triad, 1) + ' ' + GetDeterm (Triad, 'триллион', 'триллиона', 'триллионов') + ' ' + NTS;
      6: { неизвестные }
        If Triad > 0 then
          NTS := TriadToStr (Triad, 1) + ' ' + GetDeterm (Triad, '???', '???', '???') + ' ' + NTS;
    end;
    Numb := Numb div 1000;
    if St < 6 then Inc (St)
  end;
  NumbToStr := NTS
end;

function ExecAndWait(const FileName, Params: ShortString; const WinState: Word): boolean; export;
var
  StartInfo: TStartupInfo; 
  ProcInfo: TProcessInformation; 
  CmdLine: ShortString; 
begin 
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x } 
  CmdLine := '"' + Filename + '" ' + Params; 
  FillChar(StartInfo, SizeOf(StartInfo), #0); 
  with StartInfo do 
  begin 
    cb := SizeOf(StartInfo); 
    dwFlags := STARTF_USESHOWWINDOW; 
    wShowWindow := WinState; 
  end; 
  Result := CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false, 
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, 
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo); 
  { Ожидаем завершения приложения } 
  if Result then 
  begin 
    WaitForSingleObject(ProcInfo.hProcess, INFINITE); 
    { Free the Handles } 
    CloseHandle(ProcInfo.hProcess); 
    CloseHandle(ProcInfo.hThread); 
  end; 
end;

end.
