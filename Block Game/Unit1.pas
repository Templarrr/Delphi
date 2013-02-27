unit Unit1;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Math,
  Spin,
  Buttons,
  Gauges,
  FileCtrl,
  GameField;

type
  TForm1 = class (TForm)
    Image1 :           TImage;
    btnGenerate: TButton;
    dlgSave1 :         TSaveDialog;
    dlgOpen1 :         TOpenDialog;
    btnLoad :          TButton;
    btnSave :          TButton;
    Image2 :           TImage;
    lblSolved :        TLabel;
    lbShuffled :       TLabel;
    grp1 :             TGroupBox;
    lbl1 :             TLabel;
    lbl2 :             TLabel;
    lbl3 :             TLabel;
    seBoxTypes :       TSpinEdit;
    seMinBlockCount :  TSpinEdit;
    seMaxBlockCount :  TSpinEdit;
    grp2 :             TGroupBox;
    chkShuffle :       TCheckBox;
    seShuffle :        TSpinEdit;
    lbl4 :             TLabel;
    chkSideMoveAllow : TCheckBox;
    chkSideSwapAllow : TCheckBox;
    chkDropMoveAllow : TCheckBox;
    grp3 :             TGroupBox;
    sePuzzleCount :    TSpinEdit;
    lbl5 :             TLabel;
    Gauge1 :           TGauge;
    lbl6 :             TLabel;
    edtFolder :        TEdit;
    btnFolder :        TSpeedButton;
    btnStart :         TButton;
    seWidth :          TSpinEdit;
    lbl7 :             TLabel;
    seHeight :         TSpinEdit;
    lbl8 :             TLabel;
    procedure btnGenerateClick(Sender : TObject);
    procedure btnSaveClick(Sender : TObject);
    procedure btnLoadClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure btnFolderClick(Sender : TObject);
    procedure btnStartClick(Sender : TObject);
  private


  public
    { Public declarations }
  end;

var
  Form1 :        TForm1;
  game :         TGameField;
  BLOCK_SIZE_X : integer = 20;
  BLOCK_SIZE_Y : integer = 20;
  generate_in_progress : Boolean = FALSE;


implementation

{$R *.dfm}

procedure TForm1.btnGenerateClick(Sender : TObject);
begin
  btnGenerate.Enabled := FALSE;
  //RandSeed := 0; //for debug
  try
    if (game <> nil) then game.Destroy;
    game      := TGameField.Create(seWidth.Value, seHeight.Value);
    game.generateCorrectPuzzle;
    game.show := TRUE;
    if chkShuffle.Checked then
      game.shuffleCorrect
    else
      game.Visualize(Image1.Canvas, Image1.ClientWidth, Image1.ClientHeight);
    game.Visualize(Image2.Canvas, Image2.ClientWidth, Image2.ClientHeight);
  except
    On E : Exception do
    begin
      ShowMessage('Something messed up.' + #13 + #10 + E.Message + #13 + #10 +
        'Try to launch puzzle generation with different settings or just launch it again.');
    end;
  end;
  btnSave.Enabled := TRUE;
  btnGenerate.Enabled := TRUE;
end;


procedure TForm1.btnSaveClick(Sender : TObject);
begin
  try
    if (dlgSave1.Execute) then
      game.save(dlgSave1.FileName);
  except
    on E : Exception do
      ShowMessage('Cann''t save puzzle. Check if you have access to write to that place.');
  end;
end;

procedure TForm1.btnLoadClick(Sender : TObject);
begin

  try
    if dlgOpen1.Execute then
    begin
      game := TGameField.Create;
      game.Load(dlgOpen1.FileName);
      game.Visualize(Image2.Canvas, Image2.ClientWidth, Image2.ClientHeight);
    end;
    btnSave.Enabled := TRUE;
  except
    on E : Exception do
      ShowMessage('Cann''t load puzzle. Check if you have access to read from that file.');
  end;
end;

procedure TForm1.FormCreate(Sender : TObject);
begin
  edtFolder.Text := GetCurrentDir;
  Randomize;
end;

procedure TForm1.btnFolderClick(Sender : TObject);
var
  options :         TSelectDirOpts;
  chosenDirectory : string;
begin
  chosenDirectory := edtFolder.Text;  // ”становка начального каталога
  // ѕросим пользовател€ выбрать использу€ полностью различные диалоги!
  if SelectDirectory(chosenDirectory, options, 0) then
    edtFolder.Text := chosenDirectory;
end;

procedure MassPuzzleGenerate(amount : Integer; curdir : string);
var
  i :            Integer;
  tries, fails : integer;
  game :         TGameField;
  to_shuffle :   Boolean;
  perc :         double;
begin
  i          := 0;
  tries      := 0;
  fails      := 0;
  SetCurrentDir(curdir);
  game       := TGameField.Create(Form1.seWidth.Value, Form1.seHeight.Value);
  to_shuffle := Form1.chkShuffle.Checked;
  Form1.Gauge1.MaxValue := amount;
  while (i < amount) and generate_in_progress do
  begin
    Application.ProcessMessages;
    try
      Inc(tries);
      game.resetField;
      game.generateCorrectPuzzle;
      if to_shuffle then
        game.shuffleCorrect;
      Inc(i);
      Form1.Gauge1.Progress := i;
      game.Save(IntToStr(i) + '.pzl');
    except
      on E : Exception do
        Inc(fails);
    end;
    if (tries > 10) and (fails > tries * 0.5) then
      Break;
  end;
  FreeAndNil(game);
  generate_in_progress := FALSE;
  Form1.btnStart.Caption := 'Start';
  Form1.btnGenerate.Enabled := TRUE;
  Form1.btnLoad.Enabled := TRUE;
  if (tries > 10) and (fails > tries * 0.5) then
    ShowMessage('Something wrong with settings. ' + #13#10 +
      'On the test run more then 50% tries failed. ' + #13#10 +
      'Try adjust your setting and check your permissions.')
  else
  begin
    perc := 100*fails / (i + fails);
    ShowMessage('Generation complete! Total generated : ' + inttostr(i + fails) + #13#10 +
      ' Discarded : ' + inttostr(fails) + #13#10 + ' Accepted : ' + inttostr(i) + #13#10 + ' % of fails : ' +
      floattostrf(perc, ffFixed, 5, 2));
  end;
end;

procedure TForm1.btnStartClick(Sender : TObject);
begin
  generate_in_progress := not generate_in_progress;
  if (generate_in_progress) then
  begin
    btnStart.Caption := 'Stop';
    btnGenerate.Enabled  := FALSE;
    btnLoad.Enabled  := FALSE;
    MassPuzzleGenerate(sePuzzleCount.Value, edtFolder.Text);
  end
  else
  begin
    btnStart.Caption := 'Start';
    btnGenerate.Enabled  := TRUE;
    btnLoad.Enabled  := TRUE;
  end;
end;

end.
