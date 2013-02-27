unit unitReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, ABSMain, Grids, DBGrids, StdCtrls, ComObj, ActiveX;

type
  TformReport = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Label4: TLabel;
    TabSheet4: TTabSheet;
    DBGrid3: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid1: TDBGrid;
    Label5: TLabel;
    ABSQuery1: TABSQuery;
    ABSQuery2: TABSQuery;
    ABSQuery3: TABSQuery;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label8: TLabel;
    ComboBox1: TComboBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    ABSQueryCalc: TABSQuery;
    Button2: TButton;
    TabSheet5: TTabSheet;
    DBGrid4: TDBGrid;
    ABSQuery4: TABSQuery;
    DataSource4: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure Initialize;

var
  formReport: TformReport;

implementation

{$R *.dfm}

procedure Initialize;
var
  i:integer;
  login : string;
begin
  formReport.ABSQuery1.Active:=False;
  formReport.ABSQuery2.Active:=False;
  formReport.ABSQuery3.Active:=False;
  formReport.Label9.Caption:='---';
  formReport.Label10.Caption:='---';
  formReport.Label11.Caption:='---';
  formReport.Label12.Caption:='---';
  formReport.Label13.Caption:='---';

  formReport.DateTimePicker1.DateTime:=Date;
  formReport.DateTimePicker2.DateTime:=0;
  formReport.DateTimePicker3.DateTime:=Date+1;
  formReport.DateTimePicker4.DateTime:=0;
  with formReport do
    begin
      ABSQueryCalc.SQL.Clear;
      ABSQueryCalc.SQL.Add('select login from users');
      ABSQueryCalc.Open;
      if (ABSQueryCalc.RecordCount > 0) then
      begin
        ABSQueryCalc.First;
        ComboBox1.Items.Clear;
        for i:=1 to ABSQueryCalc.RecordCount do
        begin
          login := ABSQueryCalc.FieldByName('login').AsString;
          ComboBox1.Items.Add(login);
          ABSQueryCalc.Next;
        end;
        ComboBox1.ItemIndex:=0;
      end;
    end;
end;

procedure TformReport.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

procedure TformReport.Button1Click(Sender: TObject);
var
  sql1,sql2,sql3,sql4 : string;
  wh1,wh2,wh3,wh4 : string;
  or1,or2,or3,or4 : string;
  tennis_money, xbox_money, debet, credit : double;
  i : integer;
begin
  tennis_money := 0;
  xbox_money := 0;
  debet := 0;
  credit := 0;

  if CheckBox3.Checked or CheckBox4.Checked then
  begin
    //вычисляем для игровых мест
    sql1 := 'select t1.time_begin,t1.time_end,t1.tarif,t1.summ,t1.login, t2.name, t2.type from actions t1 left join tables t2 on t1.table_id = t2.id where complete = 1';
    wh1 := '';
    or1 := ' order by time_begin asc';
    if CheckBox3.Checked and not CheckBox4.Checked then wh1 := wh1 + ' and type = 1 ';
    if CheckBox4.Checked and not CheckBox3.Checked then wh1 := wh1 + ' and type = 2 ';
    if CheckBox1.Checked then wh1 := wh1 + ' AND time_begin BETWEEN :time_start AND :time_end';
    if CheckBox2.Checked then wh1 := wh1 + ' AND login = :login';
    ABSQuery1.SQL.Clear;
    ABSQuery1.SQL.Add(sql1+wh1+or1);
    if CheckBox1.Checked then
    begin
    ABSQuery1.ParamByName('time_start').AsDateTime:=DateTimePicker1.DateTime+DateTimePicker2.DateTime;
    ABSQuery1.ParamByName('time_end').AsDateTime:=DateTimePicker3.DateTime+DateTimePicker4.DateTime;
    end;
    if CheckBox2.Checked then
      ABSQuery1.ParamByName('login').AsString:=ComboBox1.Text;
    ABSQuery1.Open;
    if (ABSQuery1.RecordCount > 0) then
    begin
      ABSQuery1.First;
      for i:=1 to ABSQuery1.RecordCount do
      begin
        if ABSQuery1.FieldByName('type').AsInteger = 1 then
          tennis_money := tennis_money + ABSQuery1.FieldByName('summ').AsFloat
        else
          xbox_money := xbox_money + ABSQuery1.FieldByName('summ').AsFloat;
        ABSQuery1.Next;
      end;
    end;
  end;

  if CheckBox5.Checked then
  begin
    //вычисляем для доходов от товаров
    sql2 := 'select t1.dat,t1.name, t1.cost, t1.col, t1.summ, t1.login, t2.name  as tablename from goods_out t1 left join tables t2 on t1.table_id = t2.id ';
    wh2 := ' where 1=1 ';
    or2 := ' order by dat asc';
    if CheckBox1.Checked then wh2 := wh2 + ' AND dat BETWEEN :time_start AND :time_end';
    if CheckBox2.Checked then wh2 := wh2 + ' AND login = :login';
    ABSQuery2.SQL.Clear;
    ABSQuery2.SQL.Add(sql2+wh2+or2);
    if CheckBox1.Checked then
    begin
    ABSQuery2.ParamByName('time_start').AsDateTime:=DateTimePicker1.DateTime+DateTimePicker2.DateTime;
    ABSQuery2.ParamByName('time_end').AsDateTime:=DateTimePicker3.DateTime+DateTimePicker4.DateTime;
    end;
    if CheckBox2.Checked then
      ABSQuery2.ParamByName('login').AsString:=ComboBox1.Text;
    ABSQuery2.Open;
    if (ABSQuery2.RecordCount > 0) then
    begin
      ABSQuery2.First;
      for i:=1 to ABSQuery2.RecordCount do
      begin
          debet := debet + ABSQuery2.FieldByName('summ').AsFloat;
        ABSQuery2.Next;
      end;
    end;
  end;

  if CheckBox5.Checked then
  begin
    //вычисляем для прихода товаров
    sql3 := 'select t1.dat,t1.name, t1.cost, t1.col, t1.summ, t1.login from goods_in t1 ';
    wh3 := ' where 1=1 ';
    or3 := ' order by dat asc';
    if CheckBox1.Checked then wh3 := wh3 + ' AND dat BETWEEN :time_start AND :time_end';
    if CheckBox2.Checked then wh3 := wh3 + ' AND login = :login';
    ABSQuery3.SQL.Clear;
    ABSQuery3.SQL.Add(sql3+wh3+or3);
    if CheckBox1.Checked then
    begin
    ABSQuery3.ParamByName('time_start').AsDateTime:=DateTimePicker1.DateTime+DateTimePicker2.DateTime;
    ABSQuery3.ParamByName('time_end').AsDateTime:=DateTimePicker3.DateTime+DateTimePicker4.DateTime;
    end;
    if CheckBox2.Checked then
      ABSQuery3.ParamByName('login').AsString:=ComboBox1.Text;
    ABSQuery3.Open;
  end;

  if CheckBox6.Checked then
  begin
    //вычисляем для прихода товаров
    sql4 := 'select * from rashod ';
    wh4 := ' where 1=1 ';
    or4 := ' order by dat asc';
    if CheckBox1.Checked then wh4 := wh4 + ' AND dat BETWEEN :time_start AND :time_end';
    if CheckBox2.Checked then wh4 := wh4 + ' AND login = :login';
    ABSQuery4.SQL.Clear;
    ABSQuery4.SQL.Add(sql4+wh4+or4);
    if CheckBox1.Checked then
    begin
    ABSQuery4.ParamByName('time_start').AsDateTime:=DateTimePicker1.DateTime+DateTimePicker2.DateTime;
    ABSQuery4.ParamByName('time_end').AsDateTime:=DateTimePicker3.DateTime+DateTimePicker4.DateTime;
    end;
    if CheckBox2.Checked then
      ABSQuery4.ParamByName('login').AsString:=ComboBox1.Text;
    ABSQuery4.Open;
    if (ABSQuery4.RecordCount > 0) then
    begin
      ABSQuery4.First;
      for i:=1 to ABSQuery4.RecordCount do
      begin
          credit := credit + ABSQuery4.FieldByName('summ').AsFloat;
        ABSQuery4.Next;
      end;
    end;
  end;

  Label9.Caption:=FloatToStrF(tennis_money,ffFixed,5,2);
  Label10.Caption:=FloatToStrF(xbox_money,ffFixed,5,2);
  Label11.Caption:=FloatToStrF(debet,ffFixed,5,2);
  Label12.Caption:=FloatToStrF(credit,ffFixed,5,2);
  Label13.Caption:=FloatToStrF(tennis_money+xbox_money+debet-credit,ffFixed,5,2);

end;

function IsOLEObjectInstalled(Name: String): boolean;
var
  ClassID: TCLSID;
  Rez : HRESULT;
begin

// Ищем CLSID OLE-объекта
  Rez := CLSIDFromProgID(PWideChar(WideString(Name)), ClassID);
  if Rez = S_OK then
 // Объект найден
    Result := true
  else
    Result := false;
end;

procedure TformReport.Button2Click(Sender: TObject);
var
  ExcelApp : Variant;
  i,j : integer;
  currow : integer;
begin
  if IsOLEObjectInstalled('Excel.Application') then
  begin
    try

      // Ищем запущеный экземплят Excel, если он не найден, вызывается исключение
      ExcelApp := GetActiveOleObject('Excel.Application');

      // Делаем его видимым
      ExcelApp.Visible := true;
    except
      ExcelApp := CreateOleObject(PWideChar(WideString('Excel.Application')));
      ExcelApp.Visible := true;

    end;
    ExcelApp.Application.EnableEvents := false;
    ExcelApp.Workbooks.Add;
    ExcelApp.ActiveWorkBook.Sheets.Item[1].Name := 'Отчет';
    if (ExcelApp.ActiveWorkBook.Sheets.Count > 1) then
    begin
      for i:= ExcelApp.ActiveWorkBook.Sheets.Count downto 2 do
         ExcelApp.ActiveWorkBook.Sheets.Item[i].Delete;
    end;
    //форматируем
    for i:=1 to 7 do
      ExcelApp.Columns[i].ColumnWidth:=20;
    ExcelApp.Range['B1:B6'].Select;
    ExcelApp.Selection.HorizontalAlignment:=3;
    //пишем заголовок
    ExcelApp.Cells[1,1]:='Отчет сформирован';
    ExcelApp.Cells[1,2]:=Now;
    ExcelApp.Cells[2,1]:='Выручка от тенниса';
    ExcelApp.Cells[2,2]:=Label9.Caption;
    ExcelApp.Cells[3,1]:='Выручка от приставок';
    ExcelApp.Cells[3,2]:=Label10.Caption;
    ExcelApp.Cells[4,1]:='Выручка от товаров';
    ExcelApp.Cells[4,2]:=Label11.Caption;
    ExcelApp.Cells[5,1]:='Расходы';
    ExcelApp.Cells[5,2]:=Label12.Caption;
    ExcelApp.Cells[6,1]:='Балланс';
    ExcelApp.Cells[6,2]:=Label13.Caption;
    //пишем первую таблицу
    currow:=8;
    ExcelApp.Cells[currow,1]:='Игры';
    for j:=0 to DBGrid1.Columns.Count-1 do
    begin
      ExcelApp.Cells[currow+1,j+1]:=DBGrid1.Columns.Items[j].Title.Caption;
      ExcelApp.Cells[currow+1,j+1].Borders.LineStyle:=1;
    end;
    if ABSQuery1.RecordCount>0 then
    begin
      ABSQuery1.First;
      for i:=1 to ABSQuery1.RecordCount do
      begin
        for j:=0 to DBGrid1.Columns.Count-1 do
        begin
          ExcelApp.Cells[currow+1+i,j+1]:=ABSQuery1.FieldByName(DBGrid1.Columns.Items[j].FieldName).AsString;
          ExcelApp.Cells[currow+1+i,j+1].Borders.LineStyle:=1;
          ExcelApp.Cells[currow+1+i,j+1].HorizontalAlignment:=3;
        end;
        ABSQuery1.Next;
      end;
    end;

    currow:=currow+3+ABSQuery1.RecordCount;

    //пишем вторую таблицу
    ExcelApp.Cells[currow,1]:='Продажи';
    for j:=0 to DBGrid2.Columns.Count-1 do
    begin
      ExcelApp.Cells[currow+1,j+1]:=DBGrid2.Columns.Items[j].Title.Caption;
      ExcelApp.Cells[currow+1,j+1].Borders.LineStyle:=1;
    end;
    if ABSQuery2.RecordCount>0 then
    begin
      ABSQuery2.First;
      for i:=1 to ABSQuery2.RecordCount do
      begin
        for j:=0 to DBGrid2.Columns.Count-1 do
        begin
          ExcelApp.Cells[currow+1+i,j+1]:=ABSQuery2.FieldByName(DBGrid2.Columns.Items[j].FieldName).AsString;
          ExcelApp.Cells[currow+1+i,j+1].Borders.LineStyle:=1;
          ExcelApp.Cells[currow+1+i,j+1].HorizontalAlignment:=3;
        end;
        ABSQuery2.Next;
      end;
    end;

    currow:=currow+3+ABSQuery2.RecordCount;
    //пишем третью таблицу
    ExcelApp.Cells[currow,1]:='Приход товара';
    for j:=0 to DBGrid3.Columns.Count-1 do
    begin
      ExcelApp.Cells[currow+1,j+1]:=DBGrid3.Columns.Items[j].Title.Caption;
      ExcelApp.Cells[currow+1,j+1].Borders.LineStyle:=1;
    end;
    if ABSQuery3.RecordCount>0 then
    begin
      ABSQuery3.First;
      for i:=1 to ABSQuery3.RecordCount do
      begin
        for j:=0 to DBGrid3.Columns.Count-1 do
        begin
          ExcelApp.Cells[currow+1+i,j+1]:=ABSQuery3.FieldByName(DBGrid3.Columns.Items[j].FieldName).AsString;
          ExcelApp.Cells[currow+1+i,j+1].Borders.LineStyle:=1;
          ExcelApp.Cells[currow+1+i,j+1].HorizontalAlignment:=3;
        end;
        ABSQuery3.Next;
      end;
    end;

    currow:=currow+3+ABSQuery2.RecordCount;
    //пишем четвертую таблицу
    ExcelApp.Cells[currow,1]:='Расходы';
    for j:=0 to DBGrid4.Columns.Count-1 do
    begin
      ExcelApp.Cells[currow+1,j+1]:=DBGrid4.Columns.Items[j].Title.Caption;
      ExcelApp.Cells[currow+1,j+1].Borders.LineStyle:=1;
    end;
    if ABSQuery4.RecordCount>0 then
    begin
      ABSQuery4.First;
      for i:=1 to ABSQuery4.RecordCount do
      begin
        for j:=0 to DBGrid4.Columns.Count-1 do
        begin
          ExcelApp.Cells[currow+1+i,j+1]:=ABSQuery4.FieldByName(DBGrid4.Columns.Items[j].FieldName).AsString;
          ExcelApp.Cells[currow+1+i,j+1].Borders.LineStyle:=1;
          ExcelApp.Cells[currow+1+i,j+1].HorizontalAlignment:=3;
        end;
        ABSQuery4.Next;
      end;
    end;

    currow:=currow+3+ABSQuery2.RecordCount;
    //пишем пятую таблицу
    ExcelApp.Application.EnableEvents := true;
  end
  else
    ShowMessage('На данном компьютере не установлен Excel либо Excel не поддерживаемой версии');
end;

end.
