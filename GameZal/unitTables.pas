unit unitTables;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, DB, ABSMain;

type
  TformTables = class(TForm)
    ABSTable1: TABSTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formTables: TformTables;

implementation

{$R *.dfm}

uses unitMain;

procedure TformTables.Button1Click(Sender: TObject);
begin
  formTables.Close;
end;

procedure TformTables.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  formMain.Timer1.Enabled := false;
  unitMain.CloseTables;
  formMain.Initiate;
  formMain.Timer1.Enabled := true;
end;

procedure TformTables.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

end.
