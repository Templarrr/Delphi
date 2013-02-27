unit unitTarifs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, DB, ABSMain;

type
  TformTarifs = class(TForm)
    ABSTable1: TABSTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formTarifs: TformTarifs;

implementation

{$R *.dfm}

procedure TformTarifs.Button1Click(Sender: TObject);
begin
  formTarifs.Close;
end;

procedure TformTarifs.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

end.
