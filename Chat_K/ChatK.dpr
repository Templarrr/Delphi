program ChatK;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ChatForm},
  dlg_auth in 'dlg_auth.pas' {AuthDialog},
  UtilsForm in 'UtilsForm.pas' {DM: TDataModule},
  Auth in 'Auth.pas' {AuthForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Kenarius Chat Module';
  Application.CreateForm(TChatForm, ChatForm);
  Application.CreateForm(TAuthForm, AuthForm);
  Application.Run;
end.
