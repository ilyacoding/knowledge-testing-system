unit UnitModel;

interface

type
  TOpt = ^TOption;
  TQuest = ^TQuestion;

  TOption = record
    ID: integer;
    Info: string;
    NextOpt: TOpt;
    Answer: boolean;
  end;

  TQuestion = record
    ID: integer;
    Title: string;
    Time: integer;
    TOQ: string;
    Options: TOpt;
    Mark: integer;
    Answers: string;
    Solved: boolean;
    PrevQuest: TQuest;
    NextQuest: TQuest;
  end;

function GetHash(str: string): integer;
function GetSalt: integer;
function GetFileHash(testFile: string): integer;
function IsTestValid(testFile: string): boolean;
function OpenTest(testFile: string): TQuest;
function GetNOQ(CurrQuest: TQuest): integer;
function GetNOO(CurrQuest: TQuest): integer;
function GetQuestID(CurrQuest: TQuest): integer;
function GetOptID(CurrOpt: TOpt): integer;
procedure NextOpt(var CurrOpt: TOpt);
function GetAnswers(CurrQuest: TQuest): string;
function GetUserAnswers(CurrQuest: TQuest): string;
function NextQuest(CurrQuest: TQuest): TQuest;
function PrevQuest(CurrQuest: TQuest): TQuest;
function GetMark(CurrQuest: TQuest): integer;
function GetCurrMark(CurrQuest: TQuest): integer;
function GetTOQ(CurrQuest: TQuest): string;
function GetOptInfo(CurrOpt: TOpt): string;
function GetOptAnswer(CurrOpt: TOpt): boolean;
function GetQuestHash(FirstQuest: TQuest): integer;
function GetTitle(CurrQuest: TQuest): string;
function GetTime(CurrQuest: TQuest): integer;
function IsSolved(CurrQuest: TQuest): boolean;
function SortString(answers: string): string;
procedure CheckQuest(CurrQuest: TQuest);
function GetMaxMark(CurrQuest: TQuest): integer;
procedure CreateTest(var FQuest: TQuest);
procedure FillFirstQuest(FQuest: TQuest; Title: string; Time: integer);
procedure AddQuest(var FQuest: TQuest; Title: string; Mark: integer; TOQ: string);
procedure FillFirstOption(FQuest: TQuest);
procedure AddOption(CurrQuest: TQuest; Info: string; Answer: boolean);
procedure DeleteQuest(CurrQuest: TQuest);
procedure ClearOptions(var CurrQuest: TQuest);
function GetQP(const FQuest, CurrQuest: TQuest): integer;

implementation

uses
  SysUtils;

function GetHash(str: string): integer;
var
  i: integer;
begin
  result := 1;
  for i := 1 to length(str) do
    result := result + ord(str[i]) * i;
  result := result;
end;

function GetSalt: integer;
var
  Salt: string;
  i: integer;
begin
  Salt := '2E98SDWQ8hd';
  result := 0;
  for i := 1 to length(Salt) do
    result := (result + ord(Salt[i])) mod 21;
end;

function GetFileHash(testFile: string): integer;
var
  f: TextFile;
  HashFile, row: string;
  HashCalc, r: integer;
begin
  AssignFile(f, testFile);
  Reset(f);

  readln(f, HashFile);
  HashCalc := 0;
  r := 1;
  while not EoF(f) do
  begin
    readln(f, row);
    HashCalc := (HashCalc + GetHash(row)*r) mod 100000000;
    inc(r);
  end;
  HashCalc := HashCalc * GetSalt;
  CloseFile(f);
  result := HashCalc;
end;

function IsTestValid(testFile: string): boolean;
var
  f: TextFile;
  HashFile: string;
begin
  AssignFile(f, testFile);
  Reset(f);

  readln(f, HashFile);
  CloseFile(f);

  if (HashFile = IntToStr(GetFileHash(testFile))) then
    result := true
  else
    result := false;
end;

function GetUserAnswers(CurrQuest: TQuest): string;
begin
  result := CurrQuest^.Answers;
end;

function GetOptAnswer(CurrOpt: TOpt): boolean;
begin
  result := CurrOpt^.Answer;
end;

function OpenTest(testFile: string): TQuest;
var
  f: TextFile;
  FirstQuest, CurrQuest: TQuest;
  CurrOpt: TOpt;
  Title, TOQ, Correct, Option: string;
  i, j, k, NOQ, NOO, Time, Mark, CorrectInt: integer;
  is_answer: boolean;
begin
  AssignFile(f, testFile);
  Reset(f);
  readln(f, Title);
  readln(f, Title);
  readln(f, Time);
  readln(f, NOQ);

  new(FirstQuest);

  FirstQuest^.ID := 0;
  FirstQuest^.Title := Title;
  FirstQuest^.Time := Time;
  FirstQuest^.Options := Nil;
  FirstQuest^.NextQuest := Nil;
  FirstQuest^.PrevQuest := Nil;
  FirstQuest^.Solved := false;

  CurrQuest := FirstQuest;

  for i := 1 to NOQ do
  begin
    new(CurrQuest^.NextQuest);
    CurrQuest^.NextQuest^.PrevQuest := CurrQuest;
    CurrQuest := CurrQuest^.NextQuest;
    readln(f, Title);
    readln(f, Mark);
    readln(f, TOQ);
    readln(f, NOO);
    readln(f, CorrectInt);

    Correct := IntToStr(CorrectInt);

    CurrQuest^.ID := i;
    CurrQuest^.Title := Title;
    CurrQuest^.Mark := Mark;
    CurrQuest^.TOQ := TOQ;
    CurrQuest^.Time := 0;
    CurrQuest^.Solved := false;
    CurrQuest^.NextQuest := Nil;

    CurrQuest^.Answers := '0';
    new(CurrQuest^.Options);
    CurrOpt := CurrQuest^.Options;
    CurrOpt^.NextOpt := Nil;

    for j := 1 to NOO do
    begin
      is_answer := false;
      for k := 1 to length(Correct) do
        if (Correct[k] = IntToStr(j)) then
          is_answer := true;

      readln(f, Option);
      new(CurrOpt^.NextOpt);
      CurrOpt := CurrOpt^.NextOpt;

      CurrOpt^.Info := Option;
      CurrOpt^.ID := j;
      CurrOpt^.Answer := is_answer;
      CurrOpt^.NextOpt := Nil;
    end;

  end;
  FirstQuest^.NextQuest^.PrevQuest := Nil;
  CloseFile(f);
  result := FirstQuest;
end;

function GetNOQ(CurrQuest: TQuest): integer;
begin
  result := 0;
  CurrQuest := CurrQuest^.NextQuest;
  while (CurrQuest <> Nil) do
  begin
    CurrQuest := CurrQuest^.NextQuest;
    result := result + 1;
  end;
end;

function GetQP(const FQuest, CurrQuest: TQuest): integer;
var
  CountQuest: TQuest;
begin
  result := 0;
  CountQuest := FQuest;
  while (CountQuest <> Nil) do
  begin
    CountQuest := NextQuest(CountQuest);
    inc(result);
    if (CountQuest = CurrQuest) then
      CountQuest := Nil;
  end;
end;

function GetNOO(CurrQuest: TQuest): integer;
var
  CurrOpt: TOpt;
begin
  result := 0;
  CurrOpt := CurrQuest^.Options^.NextOpt;
  while (CurrOpt <> Nil) do
  begin
    CurrOpt := CurrOpt^.NextOpt;
    inc(result);
  end;
end;

function GetOptID(CurrOpt: TOpt): integer;
begin
  result := CurrOpt^.ID;
end;

procedure NextOpt(var CurrOpt: TOpt);
begin
  if (CurrOpt <> Nil) then
    CurrOpt := CurrOpt^.NextOpt;
end;

function GetAnswers(CurrQuest: TQuest): string;
var
  CO: TOpt;
  i, answers: integer;
begin
  CO := CurrQuest^.Options;
  i := 1;
  answers := 0;
  while (CO <> Nil) do
  begin
    if (CO^.Answer = true) then
    begin
      answers := answers*i + GetOptID(CO);
      i := 10;
    end;
    NextOpt(CO);
  end;
  result := IntToStr(answers);
end;

function NextQuest(CurrQuest: TQuest): TQuest;
begin
  result := Nil;
  if (CurrQuest <> Nil) then
    result := CurrQuest^.NextQuest;
end;

function PrevQuest(CurrQuest: TQuest): TQuest;
begin
  result := Nil;
  if ((CurrQuest <> Nil) and (CurrQuest^.PrevQuest <> Nil)) then
    result := CurrQuest^.PrevQuest;
end;

function GetMark(CurrQuest: TQuest): integer;
begin
  CurrQuest := CurrQuest^.NextQuest;
  result := 0;
  while (CurrQuest <> Nil) do
  begin
    if (CurrQuest^.Solved) then
      result := result + CurrQuest^.Mark;
    CurrQuest := CurrQuest^.NextQuest;
  end;
end;

function GetCurrMark(CurrQuest: TQuest): integer;
begin
  result := CurrQuest^.Mark;
end;

function GetTOQ(CurrQuest: TQuest): string;
begin
  result := CurrQuest^.TOQ;
end;

function GetQuestID(CurrQuest: TQuest): integer;
begin
  result := CurrQuest^.ID;
end;

function GetOptInfo(CurrOpt: TOpt): string;
begin
  result := CurrOpt^.Info;
end;

function GetQuestHash(FirstQuest: TQuest): integer;
var
  CurrQuest: TQuest;
  CurrOpt: TOpt;
  i, j, HashCalc, r: integer;
begin
  r := 1;
  HashCalc := 0;
  HashCalc := (HashCalc + GetHash(FirstQuest^.Title) * r) mod 100000000;
  inc(r);
  HashCalc := (HashCalc + GetHash(IntToStr(FirstQuest^.Time)) * r) mod 100000000;
  inc(r);
  HashCalc := (HashCalc + GetHash(IntToStr(GetNOQ(FirstQuest))) * r) mod 100000000;
  inc(r);
  CurrQuest := FirstQuest;
  for i := 1 to GetNOQ(FirstQuest) do
  begin
    CurrQuest := NextQuest(CurrQuest);
    HashCalc := (HashCalc + GetHash(CurrQuest^.Title) * r) mod 100000000;
    inc(r);
    HashCalc := (HashCalc + GetHash(IntToStr(GetCurrMark(CurrQuest))) * r) mod 100000000;
    inc(r);
    HashCalc := (HashCalc + GetHash(GetTOQ(CurrQuest)) * r) mod 100000000;
    inc(r);
    HashCalc := (HashCalc + GetHash(IntToStr(GetNOO(CurrQuest))) * r) mod 100000000;
    inc(r);
    HashCalc := (HashCalc + GetHash(GetAnswers(CurrQuest)) * r) mod 100000000;
    inc(r);
    CurrOpt := CurrQuest^.Options;
    for j := 1 to GetNOO(CurrQuest) do
    begin
      NextOpt(CurrOpt);
      HashCalc := (HashCalc + GetHash(GetOptInfo(CurrOpt)) * r) mod 100000000;
      inc(r);
    end;
  end;
  HashCalc := HashCalc * GetSalt;
  result := HashCalc;
end;

function GetTitle(CurrQuest: TQuest): string;
begin
  result := CurrQuest^.Title;
end;

function GetTime(CurrQuest: TQuest): integer;
begin
  result := CurrQuest^.Time;
end;

function IsSolved(CurrQuest: TQuest): boolean;
begin
  result := CurrQuest^.Solved;
end;

function SortString(answers: string): string;
var
  i, j, n, tmp, ans: integer;
  a: array[1..255] of integer;
begin
  n := length(answers);
  for i := 1 to n do
    a[i] := StrToInt(answers[i]);

  for i := 1 to n do
    for j := 1 to n-1 do
      if (a[j] > a[j + 1]) then
      begin
        tmp := a[j + 1];
        a[j + 1] := a[j];
        a[j] := tmp;
      end;

  ans := 0;
  for i := 1 to n do
  begin
    ans := ans*10 + a[i];
  end;

  result := IntToStr(ans);

end;

procedure CheckQuest(CurrQuest: TQuest);
begin
  if (GetUserAnswers(CurrQuest) = GetAnswers(CurrQuest)) then
    CurrQuest^.Solved := true
  else
    CurrQuest^.Solved := false;
end;

function GetMaxMark(CurrQuest: TQuest): integer;
begin
  CurrQuest := CurrQuest^.NextQuest;
  result := 0;
  while (CurrQuest <> Nil) do
  begin
    result := result + CurrQuest^.Mark;
    CurrQuest := CurrQuest^.NextQuest;
  end;
end;


// ADMIN Functions

procedure CreateTest(var FQuest: TQuest);
begin
  FQuest := Nil;
  new(FQuest);
end;

procedure FillFirstQuest(FQuest: TQuest; Title: string; Time: integer);
begin
  FQuest^.Title := Title;
  FQuest^.Time := Time;
  FQuest^.NextQuest := Nil;
  FQuest^.Options := Nil;
  FQuest^.PrevQuest := Nil;
  FQuest^.Solved := false;
end;

procedure AddQuest(var FQuest: TQuest; Title: string; Mark: integer; TOQ: string);
var
  CurrQuest: TQuest;
begin
  CurrQuest := FQuest;
  while (CurrQuest^.NextQuest <> Nil) do
  begin
    CurrQuest := CurrQuest^.NextQuest;
  end;

  new(CurrQuest^.NextQuest);
  CurrQuest^.NextQuest^.PrevQuest := CurrQuest;
  CurrQuest := CurrQuest^.NextQuest;
  CurrQUest^.Title := Title;
  CurrQuest^.Mark := Mark;
  CurrQuest^.TOQ := TOQ;
  CurrQuest^.Solved := false;
  CurrQuest^.NextQuest := Nil;
  CurrQuest^.Options := Nil;

  FQuest^.NextQuest^.PrevQuest := Nil;
end;

procedure ClearOptions(var CurrQuest: TQuest);
begin
  CurrQuest^.Options := Nil;
  new(CurrQuest^.Options);
  CurrQuest^.Options^.NextOpt := Nil;
end;

procedure FillFirstOption(FQuest: TQuest);
var
  CurrOpt: TOpt;
  CurrQuest: TQuest;
begin
  CurrQuest := FQuest;
  while (CurrQuest^.NextQuest <> Nil) do
  begin
    CurrQuest := CurrQuest^.NextQuest;
  end;

  new(CurrQuest^.Options);
  CurrOpt := CurrQuest^.Options;
  CurrOpt^.NextOpt := Nil;
end;

procedure AddOption(CurrQuest: TQuest; Info: string; Answer: boolean);
var
  CurrOpt: TOpt;
  ID: integer;
begin

  CurrOpt := CurrQuest^.Options;
  ID := 1;
  while (CurrOpt^.NextOpt <> Nil) do
  begin
    CurrOpt := CurrOpt^.NextOpt;
    inc(ID);
  end;

  new(CurrOpt^.NextOpt);
  CurrOpt := CurrOpt^.NextOpt;

  CurrOpt^.ID := ID;
  CurrOpt^.Info := Info;
  CurrOpt^.Answer := Answer;
  CurrOpt^.NextOpt := Nil;
end;

procedure DeleteQuest(CurrQuest: TQuest);
begin
  CurrQuest^.PrevQuest^.NextQuest := CurrQuest^.NextQuest;
  CurrQuest^.NextQuest^.PrevQuest := CurrQuest^.PrevQuest;
end;

end.
 