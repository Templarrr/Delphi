unit unitSklad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ABSMain, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids;

type
  TformSklad = class(TForm)
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Button1: TButton;
    ABSTable1: TABSTable;
    DataSource1: TDataSource;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formSklad: TformSklad;

implementation

{$R *.dfm}

procedure TformSklad.Button1Click(Sender: TObject);
begin
  formSklad.Close;
end;

procedure TformSklad.FormShow(Sender: TObject);
begin
   Left:= (Screen.Width - Width) div 2;
   Top:= (Screen.Height - Height) div 2;
end;

end.
