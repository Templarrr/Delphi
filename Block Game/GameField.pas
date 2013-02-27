unit GameField;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Math,
  FileCtrl,
  Forms;

const
  {different strategies}
  CAN_LEFT_SWAP    = 1;
  CAN_RIGHT_SWAP   = 2;
  CAN_UP           = 3;
  CAN_DOWN         = 4;
  CAN_UP_LEFT      = 5;
  CAN_UP_RIGHT     = 6;
  CAN_LEFT_INSERT  = 7;
  CAN_RIGHT_INSERT = 8;
  {number of tries for algorithm before discard unlucky level}
  MAX_TRIES        = 300;

type
  {class for single blocks}
  TGameBlock = class
  public
    coords :  TPoint;
    boxtype : byte;
    collapseOnThisTurn : Boolean;
    constructor Create(xy : TPoint; boxtype : byte);
    procedure drawOnCanvas(canvas : TCanvas);
    procedure moveTo(xy : TPoint);
  end;

  {class for puzzle}
  TGameField = class
  private
    max_block_types :  byte;
    min_blocks_count : Byte;
    max_blocks_count : byte;
    steps_of_shuffle : Byte;
    left_side :        Byte;
    right_side :       Byte;
    allow_side_moves : Boolean;
    allow_swaps :      Boolean;
    allow_drops :      Boolean;
    heightmap :        array of byte;

    field :     array of array of TGameBlock;
    blocks :    TList;
    width :     byte;
    height :    byte;

    procedure applyGravity;
    procedure applyRandomMove(block : TGameBlock; avMoves : TList);
    procedure collapse;
    procedure collapseStep;
    procedure generatePuzzle;
    procedure insertBlock(fromXY : TPoint; toXY : TPoint);
    procedure moveBlock(fromXY : TPoint; toXY : TPoint);
    procedure placeBlockOnPoint(xy : TPoint; boxtype : byte);
    procedure placeIBlock(xy : TPoint; boxtype : Byte);
    procedure place_Block(xy : TPoint; boxtype : Byte);
    procedure placeRandomBlock(xy : TPoint; boxtype : Byte);
    procedure removeBlockOnPoint(xy : TPoint);
    procedure restoreFromClone(clone : TGameField);
    procedure setParams;
    procedure setSize(width, height : byte);
    procedure shuffle;
    procedure shuffleStep;
    function checkPointOnCollapsing(xy : TPoint) : boolean;
    function checkAllPointsOnCollapsing : Integer;
    function collapseTest : Boolean;
    function makeClone : TGameField;
    function prepareAvailableMoves(block : TGameBlock) : TList;
    function randNormal(min, max : Integer) : integer;
    function randChooser(choises : TList) : integer;
    function selectBlockForShuufle : TGameBlock;
    function selectXforBlock : integer;
    function zeroTest : Boolean;
  public
    show :      Boolean;
    constructor Create; overload;
    constructor Create(width : byte; height : byte); overload;
    destructor Destroy; override;
    procedure Visualize(canvas : TCanvas; width, height : integer);
    procedure generateCorrectPuzzle;
    procedure shuffleCorrect;
    procedure Save(filename : string);
    procedure Load(filename : string);
    procedure resetField;
  end;

implementation

uses
  Unit1;

{ TGameField }

procedure TGameField.applyGravity;
var
  i, j :  integer;
  block : TGameBlock;
begin
  for i := 0 to self.width - 1 do
    Self.heightmap[i] := self.height - 1;
  for j               := self.height - 1 downto 0 do
    for i := 0 to self.width - 1 do
    begin
      if self.field[i, j] = NIL then
        continue;
      block := self.field[i, j];
      if Self.heightmap[i] <> j then
        self.MoveBlock(block.coords, Point(i, Self.heightmap[i]));
      dec(Self.heightmap[i]);
    end;
end;

function TGameField.checkAllPointsOnCollapsing : Integer;
var
  i :   Integer;
  res : Integer;
begin
  res := 0;
  for i := 0 to self.blocks.Count - 1 do
    if (self.checkPointOnCollapsing(TGameBlock(Self.blocks.Items[i]).coords)) then
      Inc(res);
  Result := res;
end;

function TGameField.checkPointOnCollapsing(xy : TPoint) : boolean;
var
  left, right, up, down : byte;
  xyBlock : TGameBlock;
  i, j : Integer;
begin
  xyBlock := TGameBlock(Self.field[xy.X, xy.Y]);

  left := 0;
  for i := xy.X downto 0 do
    if (Self.field[i, xy.Y] = NIL) or (TGameBlock(Self.field[i, xy.Y]).boxtype <>
      xyBlock.boxtype) then
      Break
    else
      Inc(left);

  right := 0;
  for i := xy.X to self.width - 1 do
    if (Self.field[i, xy.Y] = NIL) or (TGameBlock(Self.field[i, xy.Y]).boxtype <>
      xyBlock.boxtype) then
      Break
    else
      Inc(right);

  up := 0;
  for j := xy.Y downto 0 do
    if (Self.field[xy.X, j] = NIL) or (TGameBlock(Self.field[xy.X, j]).boxtype <>
      xyBlock.boxtype) then
      Break
    else
      Inc(up);

  down := 0;
  for j := xy.Y to Self.height - 1 do
    if (Self.field[xy.X, j] = NIL) or (TGameBlock(Self.field[xy.X, j]).boxtype <>
      xyBlock.boxtype) then
      Break
    else
      Inc(down);

  if (left + right >= 4) or (up + down >= 4) then
    xyBlock.collapseOnThisTurn := TRUE
  else
    xyBlock.collapseOnThisTurn := FALSE;
  Result := xyBlock.collapseOnThisTurn;
end;

procedure TGameField.collapse;
var
  oldcount, newcount : Byte;
  try_counter :        integer;
begin
  newcount    := self.blocks.Count;
  try_counter := 0;
  repeat
    Inc(try_counter);
    oldcount := newcount;
    if oldcount <> 0 then
      Self.collapseStep;
    newcount := Self.blocks.Count;
  until (oldcount = newcount) or (try_counter >= MAX_TRIES);
  if oldcount <> newcount then
    raise Exception.Create('Cannot collapse level');
end;

procedure TGameField.collapseStep;
var
  i : Integer;
begin
  Self.checkAllPointsOnCollapsing;

  i := 0;
  while i < self.blocks.Count do
    if (TGameBlock(Self.blocks.Items[i]).collapseOnThisTurn) then
      self.removeBlockOnPoint(TGameBlock(Self.blocks.Items[i]).coords)
    else
      Inc(i);

  Self.applyGravity;
end;

function TGameField.collapseTest : Boolean;
var
  tempfield : TGameField;
  res :       Boolean;
begin
  tempfield := Self.makeClone;
  tempfield.collapse;
  res       := tempfield.zeroTest;
  tempfield.Destroy;
  Result    := res;
end;

constructor TGameField.Create(width, height : byte);
begin
  self.Create;
  Self.setSize(width, height);
end;

constructor TGameField.Create;
begin
  self.blocks := TList.Create;
  self.setParams;
  self.show   := FALSE;
end;

procedure TGameField.generateCorrectPuzzle;
var
  try_counter : integer;
  correct :     boolean;
begin
  try_counter := 0;
  repeat
    Inc(try_counter);
    Self.resetField;
    Self.generatePuzzle;
    correct := Self.collapseTest;
  until correct or (try_counter >= MAX_TRIES);
  if (not correct) then
    raise Exception.Create('Cannot generate correct level');
end;

procedure TGameField.generatePuzzle;
var
  i, x : integer;
  boxtype, blockcount : Byte;
begin
  blockcount := self.randNormal(Self.min_blocks_count, self.max_blocks_count);
  for i := 1 to blockcount do
  begin
    boxtype := (i mod Self.max_block_types) + 1;
    x       := self.selectXforBlock;
    self.placeRandomBlock(Point(x, 1), boxtype);
    self.applyGravity;
  end;
end;


procedure TGameField.Load(filename : string);
var
  i, j :          integer;
  inpf :          textfile;
  width, height : Byte;
  boxtype :       char;
begin
  AssignFile(inpf, filename);
  Reset(inpf);
  Readln(inpf, width);
  Readln(inpf, height);
  self.setSize(width, height);
  for j := 0 to self.height - 1 do
  begin
    for i := 0 to Self.width - 1 do
    begin
      Read(inpf, boxtype);
      if boxtype = '0' then
        Continue
      else
        Self.placeBlockOnPoint(Point(i, j), StrToInt(boxtype));
    end;
    Readln(inpf);
  end;
  CloseFile(inpf);
end;

function TGameField.makeClone : TGameField;
var
  newfield : TGameField;
  block :    TGameBlock;
  i :        integer;
begin
  newfield := TGameField.Create(Self.width, Self.height);
  for i := 0 to Self.blocks.Count - 1 do
  begin
    block := TGameBlock(self.blocks.Items[i]);
    newfield.placeBlockOnPoint(block.coords, block.boxtype);
  end;
  Result := newfield;
end;

function TGameField.zeroTest : Boolean;
var
  types_count : array of Byte;
  i :           integer;
  res :         Boolean;
begin
  SetLength(types_count, Self.max_block_types + 1);
  for i := 0 to Self.blocks.Count - 1 do
    Inc(types_count[TGameBlock(Self.blocks.Items[i]).boxtype]);
  res := TRUE;
  for i := 1 to Self.max_block_types do
    if types_count[i] <> 0 then
      res := FALSE;
  Result := res;
end;

procedure TGameField.MoveBlock(fromXY, toXY : TPoint);
var
  block, sideblock : TGameBlock;
begin
  if self.field[fromXY.X][fromXY.Y] = NIL then
    Exit;

  if self.field[toXY.X][toXY.Y] <> NIL then
    sideblock := self.field[toXY.X][toXY.Y]
  else
    sideblock := NIL;
  block := self.field[fromXY.X][fromXY.Y];
  block.moveTo(toXY);
  self.field[toXY.X][toXY.Y] := block;
  self.field[fromXY.X][fromXY.Y] := sideblock;
  if sideblock <> NIL then
    sideblock.moveTo(fromXY);
end;

procedure TGameField.placeBlockOnPoint(xy : TPoint; boxtype : byte);
var
  block : TGameBlock;
begin
  block           := TGameBlock.Create(xy, boxtype);
  self.field[xy.X][xy.Y] := block;
  self.blocks.Add(block);
  self.left_side  := Min(Self.left_side, xy.X);
  Self.right_side := Max(Self.right_side, xy.X);
end;

procedure TGameField.placeIBlock(xy : TPoint; boxtype : Byte);
begin
  Self.placeBlockOnPoint(xy, boxtype);
  Self.placeBlockOnPoint(Point(xy.X, xy.Y - 1), boxtype);
  Self.placeBlockOnPoint(Point(xy.X, xy.Y + 1), boxtype);
end;

procedure TGameField.placeRandomBlock(xy : TPoint; boxtype : Byte);
var
  blocktype : Integer;
begin
  blocktype := self.randNormal(1, 2);
  case (blocktype) of
    1 :
      self.placeIBlock(xy, boxtype);
    2 :
      self.place_Block(xy, boxtype);
  end;
end;

procedure TGameField.place_Block(xy : TPoint; boxtype : Byte);
begin
  Self.placeBlockOnPoint(xy, boxtype);
  Self.placeBlockOnPoint(Point(xy.X - 1, xy.Y), boxtype);
  Self.placeBlockOnPoint(Point(xy.X + 1, xy.Y), boxtype);
end;

function TGameField.randChooser(choises : TList) : integer;
var
  i : Integer;
begin
  i      := Self.randNormal(0, choises.Count - 1);
  Result := Integer(choises.items[i]);
end;

function TGameField.randNormal(min, max : Integer) : integer;
begin
  Result := Round(Random * (max - min) + min);
end;

procedure TGameField.removeBlockOnPoint(xy : TPoint);
var
  block : TGameBlock;
begin
  if self.field[xy.X, xy.Y] <> NIL then
  begin
    block := self.field[xy.X, xy.Y];
    self.blocks.Remove(block);
    self.field[xy.X, xy.Y] := NIL;
    FreeAndNil(block);
  end;
end;

procedure TGameField.resetField;
var
  i, j :  Byte;
  block : TGameBlock;
begin
  if Self.blocks.count > 0 then
    for i := 0 to Self.blocks.Count - 1 do
    begin
      block := TGameBlock(Self.blocks[i]);
      FreeAndNil(block);
    end;

  Self.blocks.Clear;
  for i := 0 to Self.width - 1 do
    for j := 0 to self.height - 1 do
      self.field[i, j] := NIL;
  Self.left_side := Self.width;
  Self.right_side := 0;
end;

procedure TGameField.Save(filename : string);
var
  i, j : integer;
  outf : textfile;
begin
  AssignFile(outf, filename);
  Rewrite(outf);
  Writeln(outf, self.width);
  Writeln(outf, self.height);
  for j := 0 to self.height - 1 do
  begin
    for i := 0 to Self.width - 1 do
      if self.field[i, j] = NIL then
        Write(outf, 0)
      else
        Write(outf, self.field[i, j].boxtype);
    Writeln(outf);
  end;
  CloseFile(outf);
end;

function TGameField.selectXforBlock : integer;
var
  x :           byte;
  left_border, right_border : Byte;
  try_counter : integer;
begin
  if Self.right_side = 0 then
    x           := Round(Self.width / 2)
  else
  begin
    try_counter := 0;
    repeat
      Inc(try_counter);
      left_border  := Max(1, Self.left_side - 2);
      right_border := Min(self.width - 2, Self.right_side + 2);
      x            := Self.randNormal(left_border, right_border);
    until (Self.heightmap[x] > 2) or (try_counter > self.width);
    if (Self.heightmap[x] <= 2) then
      raise Exception.Create('Game field is too filled. At least four upper rows must remain empty');
  end;
  result := x;
end;

procedure TGameField.setParams;
begin
  Self.min_blocks_count := Form1.seMinBlockCount.Value;
  Self.max_blocks_count := Form1.seMaxBlockCount.Value;
  self.max_block_types  := Form1.seBoxTypes.Value;
  Self.steps_of_shuffle := Form1.seShuffle.Value;
  Self.allow_side_moves := Form1.chkSideMoveAllow.Checked;
  self.allow_swaps      := Form1.chkSideSwapAllow.Checked;
  Self.allow_drops      := Form1.chkDropMoveAllow.Checked;
end;

procedure TGameField.setSize(width, height : byte);
var
  i : integer;
begin
  self.width  := width;
  self.height := height;
  setlength(self.field, width, height);
  setlength(Self.heightmap, self.width);
  for i := 0 to self.width - 1 do
    Self.heightmap[i] := self.height - 1;

  Self.left_side  := Self.width;
  Self.right_side := 0;
end;

procedure TGameField.shuffle;
var
  i : integer;
begin
  for i := 1 to self.steps_of_shuffle do
  begin
    Self.shuffleStep;
    Self.applyGravity;
  end;
end;

procedure TGameField.Visualize(canvas : TCanvas; width, height : integer);
var
  i : integer;
begin
  BLOCK_SIZE_X     := floor(width / self.width);
  BLOCK_SIZE_Y     := floor(height / self.height);
  canvas.Font.Size := floor(BLOCK_SIZE_Y / 2) - 1;
  PatBlt(canvas.Handle, 0, 0, 400, 400, WHITENESS);
  canvas.Pen.Style := psSolid;
  canvas.Pen.Color := clBlack;
  if self.blocks.Count <> 0 then
    for i := 0 to self.blocks.Count - 1 do
      TGameBlock(self.blocks[i]).drawOnCanvas(canvas);
end;

procedure TGameField.restoreFromClone(clone : TGameField);
var
  block : TGameBlock;
  i :     integer;
begin
  Self.resetField;
  for i := 0 to clone.blocks.Count - 1 do
  begin
    block := TGameBlock(clone.blocks.Items[i]);
    self.placeBlockOnPoint(block.coords, block.boxtype);
  end;
end;

procedure TGameField.shuffleCorrect;
var
  i :               integer;
  shuffled :        TGameField;
  collapseCounter : Integer;
  try_counter :     Integer;
begin
  try_counter := 0;
  repeat
    Inc(try_counter);
    for i := 1 to MAX_TRIES do
    begin
      shuffled        := self.makeClone;
      shuffled.shuffle;
      collapseCounter := shuffled.checkAllPointsOnCollapsing;
      Application.ProcessMessages;
      if (collapseCounter = 0) then
        Break
      else
        shuffled.Destroy;
    end;

    if (collapseCounter <> 0) then
    begin
      Self.resetField;
      Self.generateCorrectPuzzle;
    end;
  until (collapseCounter = 0) or (try_counter >= MAX_TRIES);
  if collapseCounter <> 0 then
    raise Exception.Create('Cannot shuffle solved level.');
  if Self.show then
    self.Visualize(Form1.Image1.Canvas, Form1.Image1.ClientWidth, Form1.Image1.ClientHeight);
  Self.restoreFromClone(shuffled);
  shuffled.Destroy;
end;

procedure TGameField.shuffleStep;
var
  randblock :   TGameBlock;
  moves :       TList;
  try_counter : integer;
begin
  try_counter := 0;
  repeat
    randblock := self.selectBlockForShuufle;
    moves := Self.prepareAvailableMoves(randblock);
    Inc(try_counter);
  until (moves.Count > 0) or (try_counter > Self.blocks.Count);
  //if (moves.Count = 0) then raise Exception.Create('No available moves');  TODO think about it
  Self.applyRandomMove(randblock, moves);
end;

procedure TGameField.applyRandomMove(block : TGameBlock; avMoves : TList);
var
  fromXY, toXY : TPoint;
  move :         integer;
  y :            integer;
begin
  if avMoves.Count = 0 then
    Exit;
  fromXY := block.coords;
  move   := Self.randChooser(avMoves);
  case (move) of
    CAN_LEFT_SWAP, CAN_LEFT_INSERT :
      toXY := Point(block.coords.X - 1, block.coords.Y);
    CAN_RIGHT_SWAP, CAN_RIGHT_INSERT :
      toXY := Point(block.coords.X + 1, block.coords.Y);
    CAN_UP :
      toXY := Point(block.coords.X, block.coords.Y - 1);
    CAN_DOWN :
      toXY := Point(block.coords.X, block.coords.Y + 1);
    CAN_UP_LEFT :
    begin
      y    := Self.randNormal(self.heightmap[block.coords.X - 1], block.coords.Y - 1);
      toXY := Point(block.coords.X - 1, y);
    end;
    CAN_UP_RIGHT :
    begin
      y    := Self.randNormal(self.heightmap[block.coords.X + 1], block.coords.Y - 1);
      toXY := Point(block.coords.X + 1, y);
    end;
  end;
  case (move) of
    CAN_LEFT_SWAP, CAN_RIGHT_SWAP, CAN_UP, CAN_DOWN :
      Self.MoveBlock(fromXY, toXY);
    CAN_UP_LEFT, CAN_UP_RIGHT, CAN_LEFT_INSERT, CAN_RIGHT_INSERT :
      Self.InsertBlock(fromXY, toXY);
  end;
end;

function TGameField.prepareAvailableMoves(block : TGameBlock) : TList;
var
  res : TList;
begin
  res := TList.Create;
  self.applyGravity;

  if (block.coords.X > 0) and
    (
    ((Self.heightmap[block.coords.X - 1] < block.coords.Y) and
    (TGameBlock(self.field[block.coords.X - 1, block.coords.Y]).boxtype <> block.boxtype) and
    self.allow_swaps) or
    ((Self.heightmap[block.coords.X - 1] = block.coords.Y) and
    (Self.heightmap[block.coords.X] = block.coords.Y - 1) and Self.allow_side_moves)
    ) then
    res.Add(Pointer(CAN_LEFT_SWAP));

  if (block.coords.X > 0) and (Self.heightmap[block.coords.X - 1] = block.coords.Y) and
    (Self.heightmap[block.coords.X] = block.coords.Y - 1) and Self.allow_side_moves then
    res.Add(Pointer(CAN_LEFT_INSERT));

  if (block.coords.X < self.width - 1) and
    (
    ((Self.heightmap[block.coords.X + 1] < block.coords.Y) and
    (TGameBlock(self.field[block.coords.X + 1, block.coords.Y]).boxtype <> block.boxtype) and
    self.allow_swaps) or
    ((Self.heightmap[block.coords.X + 1] = block.coords.Y) and
    (Self.heightmap[block.coords.X] = block.coords.Y - 1) and Self.allow_side_moves)
    ) then
    res.Add(Pointer(CAN_RIGHT_SWAP));

  if (block.coords.X < self.width - 1) and (Self.heightmap[block.coords.X + 1] =
    block.coords.Y) and (Self.heightmap[block.coords.X] = block.coords.Y - 1) and
    Self.allow_side_moves then
    res.Add(Pointer(CAN_RIGHT_INSERT));

  if (Self.heightmap[block.coords.X] < block.coords.Y - 1) and
    (TGameBlock(self.field[block.coords.X, block.coords.Y - 1]).boxtype <> block.boxtype) and
    self.allow_swaps then
    res.Add(Pointer(CAN_UP));

  if (block.coords.Y < Self.height - 1) and
    (TGameBlock(self.field[block.coords.X, block.coords.Y + 1]).boxtype <> block.boxtype) and
    self.allow_swaps then
    res.Add(Pointer(CAN_DOWN));

  if (block.coords.X > 0) and (Self.heightmap[block.coords.X - 1] < block.coords.Y) and
    (Self.heightmap[block.coords.X] = block.coords.Y - 1) and Self.allow_drops then
    res.Add(Pointer(CAN_UP_LEFT));

  if (block.coords.X > 0) and (Self.heightmap[block.coords.X + 1] < block.coords.Y) and
    (Self.heightmap[block.coords.X] = block.coords.Y - 1) and Self.allow_drops then
    res.Add(Pointer(CAN_UP_RIGHT));

  Result := res;
end;

function TGameField.selectBlockForShuufle : TGameBlock;
var
  block : TGameBlock;
begin
  if (Self.checkAllPointsOnCollapsing > 0) then
    repeat
      block := self.blocks.items[self.randNormal(0, Self.blocks.Count - 1)];
    until block.collapseOnThisTurn
  else
    block := self.blocks.items[self.randNormal(0, Self.blocks.Count - 1)];

  Result := block;
end;

procedure TGameField.InsertBlock(fromXY, toXY : TPoint);
var
  j : integer;
begin
  for j := 1 to toXY.Y do
    Self.MoveBlock(Point(toXY.X, j), Point(toXY.X, j - 1));
  self.MoveBlock(fromXY, toXY);
end;

destructor TGameField.Destroy;
begin
  self.resetField;
  Self.field     := NIL;
  self.heightmap := NIL;
  FreeAndNil(Self.blocks);

  inherited;
end;

{ TGameBlock }

constructor TGameBlock.Create(xy : TPoint; boxtype : byte);
begin
  self.coords  := xy;
  self.boxtype := boxtype;
  self.collapseOnThisTurn := FALSE;
end;

procedure TGameBlock.drawOnCanvas(canvas : TCanvas);
begin
  case self.boxtype of
    1 :
      canvas.Brush.Color := clRed;
    2 :
      canvas.Brush.Color := clGreen;
    3 :
      canvas.Brush.Color := clBlue;
    4 :
      canvas.Brush.Color := clOlive;
    5 :
      canvas.Brush.Color := clGray;
    else
      canvas.Brush.Color := clWhite;
  end;
  canvas.Rectangle(BLOCK_SIZE_X * self.coords.X, BLOCK_SIZE_Y * self.coords.Y,
    BLOCK_SIZE_X * (self.coords.X + 1), BLOCK_SIZE_Y * (self.coords.Y + 1));
  canvas.TextOut(BLOCK_SIZE_X * self.coords.X + 1, BLOCK_SIZE_Y * self.coords.Y + 1,
    IntToStr(Self.boxtype));
end;

procedure TGameBlock.moveTo(xy : TPoint);
begin
  self.coords := xy;
end;

end.
