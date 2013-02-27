program GameZal;

uses
  Forms,
  unitLogin in 'unitLogin.pas' {formLogin},
  unitMain in 'unitMain.pas' {formMain},
  unitTables in 'unitTables.pas' {formTables},
  unitGames in 'unitGames.pas' {formGames},
  unitUsers in 'unitUsers.pas' {formUsers},
  unitTarifs in 'unitTarifs.pas' {formTarifs},
  unitReport in 'unitReport.pas' {formReport},
  unitGameBegin in 'unitGameBegin.pas' {formGameBegin},
  unitGameEnd in 'unitGameEnd.pas' {formGameEnd},
  unitGoodsIn in 'unitGoodsIn.pas' {formGoodsIn},
  unitGoodsOut in 'unitGoodsOut.pas' {formGoodsOut},
  unitSklad in 'unitSklad.pas' {formSklad},
  unitRashod in 'unitRashod.pas' {formRashod},
  unitInkasso in 'unitInkasso.pas' {formInkasso};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformLogin, formLogin);
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TformTables, formTables);
  Application.CreateForm(TformGames, formGames);
  Application.CreateForm(TformUsers, formUsers);
  Application.CreateForm(TformTarifs, formTarifs);
  Application.CreateForm(TformReport, formReport);
  Application.CreateForm(TformGameBegin, formGameBegin);
  Application.CreateForm(TformGameEnd, formGameEnd);
  Application.CreateForm(TformGoodsIn, formGoodsIn);
  Application.CreateForm(TformGoodsOut, formGoodsOut);
  Application.CreateForm(TformSklad, formSklad);
  Application.CreateForm(TformRashod, formRashod);
  Application.CreateForm(TformInkasso, formInkasso);
  Application.Run;
end.
