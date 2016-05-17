unit UnitAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Unit2, ExtCtrls, ComCtrls, sSkinManager, Buttons,
  sGauge, sButton, sCheckBox, sPanel, acSlider, acMeter, OleCtrls, SHDocVw,
  acWebBrowser, sScrollBar;

type
  TForm1 = class(TForm)
    ButtonCreate: TButton;
    ButtonEdit: TButton;
    EditTitle: TEdit;
    EditTime: TEdit;
    ButtonStart: TButton;
    ButtonPrev: TButton;
    ButtonNext: TButton;
    ButtonNewQuest: TButton;
    LabelEditTitle: TLabel;
    LabelEditTime: TLabel;
    EditQuestTitle: TEdit;
    LabelTitle: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    LabelAnswers: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    LabelAnswersValid: TLabel;
    ButtonSaveResult: TButton;
    EditMark: TEdit;
    LabelMark: TLabel;
    LabelSavedSucc: TLabel;
    ListBoxFileSelect: TListBox;
    LabelSelectTest: TLabel;
    ButtonDelete: TButton;
    sSkinManager1: TsSkinManager;
    sGauge1: TsGauge;
    procedure ButtonCreateClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonNewQuestClick(Sender: TObject);
    procedure ButtonPrevClick(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure ButtonSaveResultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxFileSelectDblClick(Sender: TObject);
    procedure EditTimeKeyPress(Sender: TObject; var Key: Char);
    procedure EditTitleKeyPress(Sender: TObject; var Key: Char);
    procedure EditMarkKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  FQuest, CQ: TQuest;
  TOA, testName: string;
  IsRunning: boolean;

implementation

procedure InitCQ;
begin
  AddQuest(FQuest, '', 0, '');
  FillFirstOption(FQuest);
  CQ^.NextQuest^.PrevQuest := CQ;
  CQ := NextQuest(CQ);
end;

function SaveTest(FQuest: TQuest; fileName: string): string;
var
  f: TextFile;
  FirstQuest, CurrQuest, PrevQuest: TQuest;
  FirstOpt, CurrOpt: TOpt;
  Title, TOQ, Correct, Option: string;
  i, j, k, NOQ, NOO, Time, Mark, CorrectInt: integer;
  is_answer: boolean;
begin
  // ????? ?????
  if (fileName = '') then
  begin
    for i := 1 to 1000 do
      if not (FileExists(ExtractFilePath(Application.ExeName) + 'Tests/' + 'test' + IntToStr(i) + '.txt')) then
      begin
        result := 'test' + IntToStr(i) + '.txt';
        break;
      end;
  end
  else
    result := fileName;

  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'Tests/') then
    CreateDir(ExtractFilePath(Application.ExeName) + 'Tests/');

  AssignFile(f, ExtractFilePath(Application.ExeName) + 'Tests/' + result);
  ReWrite(f);
  writeln(f, GetQuestHash(FQuest));
  writeln(f, FQuest^.Title);
  writeln(f, FQuest^.Time);
  writeln(f, GetNOQ(FQuest));

  CurrQuest := NextQuest(FQuest);
  for i := 1 to GetNOQ(FQuest) do
  begin
    Title := CurrQuest^.Title;
    Mark := CurrQuest^.Mark;
    TOQ := CurrQuest^.TOQ;
    NOO := GetNOO(CurrQuest);
    CorrectInt := StrToInt(GetAnswers(CurrQuest));

    writeln(f, Title);
    writeln(f, Mark);
    writeln(f, TOQ);
    writeln(f, NOO);
    writeln(f, CorrectInt);

    CurrOpt := CurrQuest^.Options;
    NextOpt(CurrOpt);

    for j := 1 to GetNOO(CurrQuest) do
    begin
      Option := CurrOpt^.Info;
      writeln(f, Option);
      NextOpt(CurrOpt);
    end;
    CurrQuest := NextQuest(CurrQuest);
  end;
  CloseFile(f);
end;

procedure SaveFields;
begin
  CQ^.Title := Form1.EditQuestTitle.Text;
  if ((Form1.EditMark.Text = '') or (StrToInt(Form1.EditMark.Text) = 0)) then
    Form1.EditMark.Text := '1';

  CQ^.Mark := StrToInt(Form1.EditMark.Text);

  ClearOptions(CQ);

  if (length(Form1.Edit1.Text) > 0) then
    AddOption(CQ, Form1.Edit1.Text, Form1.CheckBox1.Checked);
  if (length(Form1.Edit2.Text) > 0) then
    AddOption(CQ, Form1.Edit2.Text, Form1.CheckBox2.Checked);
  if (length(Form1.Edit3.Text) > 0) then
    AddOption(CQ, Form1.Edit3.Text, Form1.CheckBox3.Checked);
  if (length(Form1.Edit4.Text) > 0) then
    AddOption(CQ, Form1.Edit4.Text, Form1.CheckBox4.Checked);
  if (length(Form1.Edit5.Text) > 0) then
    AddOption(CQ, Form1.Edit5.Text, Form1.CheckBox5.Checked);

  if (length(GetAnswers(CQ)) > 1) then
    CQ^.TOQ := 'checkbox'
  else
    CQ^.TOQ := 'radio';
end;

function IsFieldsTitleClean: boolean;
begin
  result := true;
  if (Trim(Form1.EditQuestTitle.Text) <> '') then
    result := false
  else if (Trim(Form1.EditMark.Text) <> '') then
    result := false;
end;

function IsFieldsClean: boolean;
begin
  result := true;
  if (Trim(Form1.Edit1.Text) <> '') then
    result := false
  else if (Trim(Form1.Edit2.Text) <> '') then
    result := false
  else if (Trim(Form1.Edit3.Text) <> '') then
    result := false
  else if (Trim(Form1.Edit4.Text) <> '') then
    result := false
  else if (Trim(Form1.Edit5.Text) <> '') then
    result := false;
end;

procedure LoadFields;
var
  CO: TOpt;
begin
  Form1.EditQuestTitle.Text := GetTitle(CQ);
  Form1.EditMark.Text := IntToStr(GetCurrMark(CQ));

  CO := CQ^.Options;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    Form1.Edit1.Text := GetOptInfo(CO);
    Form1.CheckBox1.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    Form1.Edit2.Text := GetOptInfo(CO);
    Form1.CheckBox2.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    Form1.Edit3.Text := GetOptInfo(CO);
    Form1.CheckBox3.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    Form1.Edit4.Text := GetOptInfo(CO);
    Form1.CheckBox4.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    Form1.Edit5.Text := GetOptInfo(CO);
    Form1.CheckBox5.Checked := GetOptAnswer(CO);
  end;
end;

procedure SetFieldVisible;
begin
  Form1.LabelAnswers.Visible := true;
  Form1.LabelAnswersValid.Visible := true;
  Form1.LabelTitle.Visible := true;
  Form1.EditQuestTitle.Visible := true;
  Form1.EditMark.Visible := true;
  Form1.LabelMark.Visible := true;

  Form1.Edit1.Visible := true;
  Form1.Edit2.Visible := true;
  Form1.Edit3.Visible := true;
  Form1.Edit4.Visible := true;
  Form1.Edit5.Visible := true;

  Form1.CheckBox1.Visible := true;
  Form1.CheckBox2.Visible := true;
  Form1.CheckBox3.Visible := true;
  Form1.CheckBox4.Visible := true;
  Form1.CheckBox5.Visible := true;
end;

procedure SetFieldUnVisible;
begin
  Form1.LabelAnswers.Visible := false;
  Form1.LabelAnswersValid.Visible := false;
  Form1.LabelTitle.Visible := false;
  Form1.EditQuestTitle.Visible := false;
  Form1.EditMark.Visible := false;
  Form1.LabelMark.Visible := false;
  Form1.ButtonSaveResult.Visible := false;
  Form1.ButtonPrev.Visible := false;
  Form1.ButtonNext.Visible := false;
  Form1.ButtonNewQuest.Visible := false;
  Form1.ButtonSaveResult.Visible := false;
  Form1.ButtonDelete.Visible := false;

  Form1.EditTitle.Visible := false;
  Form1.EditTime.Visible := false;
  Form1.LabelEditTitle.Visible := false;
  Form1.LabelEditTime.Visible := false;

  Form1.Edit1.Visible := false;
  Form1.Edit2.Visible := false;
  Form1.Edit3.Visible := false;
  Form1.Edit4.Visible := false;
  Form1.Edit5.Visible := false;

  Form1.CheckBox1.Visible := false;
  Form1.CheckBox2.Visible := false;
  Form1.CheckBox3.Visible := false;
  Form1.CheckBox4.Visible := false;
  Form1.CheckBox5.Visible := false;
end;

procedure ClearField;
begin
  Form1.EditQuestTitle.Text := '';
  Form1.EditMark.Text := '';

  Form1.Edit1.Text := '';
  Form1.Edit2.Text := '';
  Form1.Edit3.Text := '';
  Form1.Edit4.Text := '';
  Form1.Edit5.Text := '';

  Form1.CheckBox1.Checked := false;
  Form1.CheckBox2.Checked := false;
  Form1.CheckBox3.Checked := false;
  Form1.CheckBox4.Checked := false;
  Form1.CheckBox5.Checked := false;
end;

procedure SetButtons;
begin
  if (CQ <> Nil) then
  begin
    Form1.ButtonPrev.Visible := true;
    Form1.ButtonNext.Visible := true;
    Form1.ButtonNewQuest.Visible := false;
    Form1.ButtonSaveResult.Visible := false;
    Form1.ButtonDelete.Visible := true;

    Form1.sGauge1.MaxValue := GetNOQ(FQuest);
    Form1.sGauge1.Progress := GetQP(FQuest, CQ);

    if ((PrevQuest(CQ) = Nil) and (NextQuest(CQ) = Nil)) then
    begin
      Form1.ButtonPrev.Visible := false;
      Form1.ButtonNext.Visible := false;
      Form1.ButtonNewQuest.Visible := true;
    end
    else if (PrevQuest(CQ) = Nil) and (NextQuest(CQ) <> Nil) then
    begin
      Form1.ButtonPrev.Visible := false;
      Form1.ButtonNext.Visible := true;
      Form1.ButtonNewQuest.Visible := false;
    end
    else if (NextQuest(CQ) = Nil) then
    begin
      Form1.ButtonPrev.Visible := true;
      Form1.ButtonNext.Visible := false;
      Form1.ButtonNewQuest.Visible := true;
      Form1.ButtonSaveResult.Visible := true;
    end;
  end;
end;

{$R *.dfm}

procedure SetCreateEditUnVisible;
begin
  Form1.ButtonCreate.Visible := false;
  Form1.ButtonEdit.Visible := false;
end;

procedure SetTitleTimeVisible;
begin
  SetCreateEditUnVisible;
  Form1.EditTitle.Visible := true;
  Form1.EditTime.Visible := true;
  Form1.LabelEditTitle.Visible := true;
  Form1.LabelEditTime.Visible := true;
  Form1.ButtonStart.Visible := true;
end;

procedure TForm1.ButtonCreateClick(Sender: TObject);
begin
  SetTitleTimeVisible;
  TOA := 'create';
end;

procedure TForm1.ButtonEditClick(Sender: TObject);
begin
  SetCreateEditUnVisible;
  TOA := 'edit';
  Form1.ListBoxFileSelect.Visible := true;
  Form1.LabelSelectTest.Visible := true;
end;

procedure TForm1.ListBoxFileSelectDblClick(Sender: TObject);
begin
  if (length(Form1.ListBoxFileSelect.Items[Form1.ListBoxFileSelect.ItemIndex]) > 1) then
  begin          
    SetTitleTimeVisible;
    testName := Form1.ListBoxFileSelect.Items[Form1.ListBoxFileSelect.ItemIndex];
    FQuest := OpenTest(ExtractFilePath(Application.ExeName) + 'Tests/' + Form1.ListBoxFileSelect.Items[Form1.ListBoxFileSelect.ItemIndex] + '.txt');
    Form1.EditTitle.Text := GetTitle(FQuest);
    Form1.EditTime.Text := IntToStr(GetTime(FQuest));
  end;
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  if ((length(Form1.EditTitle.Text) > 3) and (length(Form1.EditTime.Text) > 1)) then
  begin

    Form1.EditTitle.Readonly := true;
    Form1.EditTime.Readonly := true;
    Form1.EditTitle.Enabled := false;
    Form1.EditTime.Enabled := false;
    //Form1.LabelEditTitle.Visible := false;
    //Form1.LabelEditTime.Visible := false;
    Form1.ButtonStart.Visible := false;
    Form1.ListBoxFileSelect.Visible := false;
    Form1.LabelSelectTest.Visible := false;

    if (StrToInt(Form1.EditTime.Text) = 0) then
      Form1.EditTime.Text := '10';

    if (TOA = 'create') then
    begin
      CreateTest(FQuest);
      FillFirstQuest(FQuest, Form1.EditTitle.Text, StrToInt(Form1.EditTime.Text));
      CQ := FQuest;
      // Начальные установки
      AddQuest(FQuest, '', 0, '');
      FillFirstOption(FQuest);
      CQ := NextQuest(FQuest);

    end
    else if (TOA = 'edit') then
    begin
      FQuest^.Title := Form1.EditTitle.Text;
      FQuest^.Time := StrToInt(Form1.EditTime.Text);
      CQ := NextQuest(FQuest);
      LoadFields;
    end;
    
    SetFieldVisible;
    SetButtons;
    IsRunning := true;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 4 символа, для времени - 2 символа.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TForm1.ButtonNewQuestClick(Sender: TObject);
begin
  if (length(Form1.EditQuestTitle.Text) > 2) then
  begin
    SaveFields;
    InitCQ;
    ClearField;
    SetFieldVisible;
    SetButtons;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за тест не будет указана, то она будет равна 1 по-умолчанию.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TForm1.ButtonPrevClick(Sender: TObject);
begin

  if (IsFieldsTitleClean and IsFieldsClean) and (PrevQuest(CQ) <> Nil) then
  begin
    CQ^.PrevQuest^.NextQuest := Nil;
    CQ := PrevQuest(CQ);
    SetButtons;
    LoadFields;
  end
  else if ((length(Form1.EditQuestTitle.Text) > 2) and (not IsFieldsClean)) then
  begin
    SaveFields;

    ClearField;
    SetFieldVisible;

    CQ := PrevQuest(CQ);
    SetButtons;

    LoadFields;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за тест не будет указана, то она будет равна 1 по-умолчанию. Поля должны быть заполнены.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TForm1.ButtonNextClick(Sender: TObject);
begin
  if (length(Form1.EditQuestTitle.Text) > 2) then
  begin
    SaveFields;

    ClearField;
    SetFieldVisible;

    CQ := NextQuest(CQ);
    SetButtons;
                     
    LoadFields;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за тест не будет указана, то она будет равна 1 по-умолчанию.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TForm1.ButtonSaveResultClick(Sender: TObject);
begin
  if (length(Form1.EditQuestTitle.Text) > 2) then
  begin
    SaveFields;

    ClearField;
    SetFieldUnVisible;
    if (TOA = 'create') then
    begin
      Form1.LabelSavedSucc.Visible := true;
      Form1.LabelSavedSucc.Caption := Form1.LabelSavedSucc.Caption + ' Tests/' + SaveTest(FQuest, '');
    end
    else if (TOA = 'edit') then
    begin
      Form1.LabelSavedSucc.Visible := true;
      Form1.LabelSavedSucc.Caption := Form1.LabelSavedSucc.Caption + ' Tests/' + SaveTest(FQuest, testname + '.txt') + ' [Обновлено]';
    end;
    IsRunning := false;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за тест не будет указана, то она будет равна 1 по-умолчанию.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, de: integer;
  fileName, testName: string;
begin
  ButtonCreate.TabStop := false;
  ButtonEdit.TabStop := false;
  i := 1;
  de := 0;
  while (de <= 1000) do
  begin
    testName := 'test' + IntToStr(i) + '.txt';
    fileName := ExtractFilePath(Application.ExeName) + 'Tests/' + testName;
    if (FileExists(fileName)) then
    begin
      if (IsTestValid(fileName)) then
      begin
        Form1.ListBoxFileSelect.Items.Add('test' + IntToStr(i));
        de := 0;
      end;
    end
    else
      inc(de);
    inc(i);
  end;
end;

// Проверки на ввод
procedure TForm1.EditTimeKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['0' .. '9'];
begin
if (Key = #13) then
  ButtonStart.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

{const abc: Set of Char=['a' .. 'z', 'A' .. 'Z', 'а' .. 'я', 'А' .. 'Я', '-'];
begin
if ((Key = #13) and (length(Form1.EditName.Text) > 2)) then
  ButtonName.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;}
procedure TForm1.EditTitleKeyPress(Sender: TObject; var Key: Char);
begin
if (Key = #13) then
  ButtonStart.Click;
end;

procedure TForm1.EditMarkKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['0' .. '9'];
begin
if (Key = #13) then
  ButtonStart.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
  if (CQ = NextQuest(FQuest)) then
  begin
    if (NextQuest(CQ) <> Nil) then
    begin
      FQuest^.NextQuest := CQ^.NextQuest;
      CQ^.NextQuest^.PrevQuest := Nil;
      ButtonNext.click;
    end
    else
    MessageBox(handle, PChar('В тесте должен быть по крайней мере один вопрос.'), PChar('Ошибка удаления'),(MB_OK+MB_ICONERROR));
  end
  else if ((PrevQuest(CQ) <> Nil) and (NextQuest(CQ) <> Nil)) then
  begin
    CQ^.PrevQuest^.NextQuest := CQ^.NextQuest;
    CQ^.NextQuest^.PrevQuest := CQ^.PrevQuest;
    ButtonNext.click;
  end
  else if (NextQuest(CQ) = Nil) then
  begin
    CQ^.PrevQuest^.NextQuest := Nil;
    ButtonPrev.click;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not (IsRunning) then
  begin
    case MessageBox(Handle, 'Вы действительно хотите выйти?', 'Выход', MB_YESNO + MB_ICONQUESTION) of
    IDYES:
      begin
        CanClose:=True;
      end;
      IDNO:
      begin
        CanClose:=False;
      end;
    end;
  end
  else
  begin
    case MessageBox(Handle, 'Вы действительно хотите выйти БЕЗ СОХРАНЕНИЯ?', 'Выход', MB_YESNO + MB_ICONWARNING) of
    IDYES:
      begin
        CanClose:=True;
      end;
      IDNO:
      begin
        CanClose:=False;
      end;
    end;
  end;
end;

end.
