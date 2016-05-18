unit UnitAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UnitModel, ExtCtrls, ComCtrls, sSkinManager, Buttons,
  sGauge, sButton, sCheckBox, sPanel, acSlider, acMeter, OleCtrls, SHDocVw,
  acWebBrowser, sScrollBar;

type
  TFormAdmin = class(TForm)
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
  FormAdmin: TFormAdmin;
  FQuest, CQ: TQuest;
  TOA, testName: string;
  IsRunning: boolean;

implementation

uses UnitMain;

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
  CurrQuest: TQuest;
  CurrOpt: TOpt;
  Title, TOQ, Option: string;
  i, j, NOO, Mark, CorrectInt: integer;
begin
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
  CQ^.Title := FormAdmin.EditQuestTitle.Text;
  if ((FormAdmin.EditMark.Text = '') or (StrToInt(FormAdmin.EditMark.Text) = 0)) then
    FormAdmin.EditMark.Text := '1';

  CQ^.Mark := StrToInt(FormAdmin.EditMark.Text);
  ClearOptions(CQ);
  if (length(FormAdmin.Edit1.Text) > 0) then
    AddOption(CQ, FormAdmin.Edit1.Text, FormAdmin.CheckBox1.Checked);
  if (length(FormAdmin.Edit2.Text) > 0) then
    AddOption(CQ, FormAdmin.Edit2.Text, FormAdmin.CheckBox2.Checked);
  if (length(FormAdmin.Edit3.Text) > 0) then
    AddOption(CQ, FormAdmin.Edit3.Text, FormAdmin.CheckBox3.Checked);
  if (length(FormAdmin.Edit4.Text) > 0) then
    AddOption(CQ, FormAdmin.Edit4.Text, FormAdmin.CheckBox4.Checked);
  if (length(FormAdmin.Edit5.Text) > 0) then
    AddOption(CQ, FormAdmin.Edit5.Text, FormAdmin.CheckBox5.Checked);

  if (length(GetAnswers(CQ)) > 1) then
    CQ^.TOQ := 'checkbox'
  else
    CQ^.TOQ := 'radio';
end;

function IsFieldsTitleClean: boolean;
begin
  result := true;
  if (Trim(FormAdmin.EditQuestTitle.Text) <> '') then
    result := false
  else if (Trim(FormAdmin.EditMark.Text) <> '') then
    result := false;
end;

function IsFieldsClean: boolean;
begin
  result := true;
  if (Trim(FormAdmin.Edit1.Text) <> '') then
    result := false
  else if (Trim(FormAdmin.Edit2.Text) <> '') then
    result := false
  else if (Trim(FormAdmin.Edit3.Text) <> '') then
    result := false
  else if (Trim(FormAdmin.Edit4.Text) <> '') then
    result := false
  else if (Trim(FormAdmin.Edit5.Text) <> '') then
    result := false;
end;

function IsAnswerGiven: boolean;
begin
  result := false;
  if (FormAdmin.CheckBox1.Checked) then
    result := true
  else if (FormAdmin.CheckBox2.Checked) then
    result := true
  else if (FormAdmin.CheckBox3.Checked) then
    result := true
  else if (FormAdmin.CheckBox4.Checked) then
    result := true
  else if (FormAdmin.CheckBox5.Checked) then
    result := true;
end;

procedure LoadFields;
var
  CO: TOpt;
begin
  FormAdmin.EditQuestTitle.Text := GetTitle(CQ);
  FormAdmin.EditMark.Text := IntToStr(GetCurrMark(CQ));

  CO := CQ^.Options;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    FormAdmin.Edit1.Text := GetOptInfo(CO);
    FormAdmin.CheckBox1.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    FormAdmin.Edit2.Text := GetOptInfo(CO);
    FormAdmin.CheckBox2.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    FormAdmin.Edit3.Text := GetOptInfo(CO);
    FormAdmin.CheckBox3.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    FormAdmin.Edit4.Text := GetOptInfo(CO);
    FormAdmin.CheckBox4.Checked := GetOptAnswer(CO);
  end;

  if (CO^.NextOpt <> Nil) then
  begin
    NextOpt(CO);
    FormAdmin.Edit5.Text := GetOptInfo(CO);
    FormAdmin.CheckBox5.Checked := GetOptAnswer(CO);
  end;
end;

procedure SetFieldVisible;
begin
  FormAdmin.LabelAnswers.Visible := true;
  FormAdmin.LabelAnswersValid.Visible := true;
  FormAdmin.LabelTitle.Visible := true;
  FormAdmin.EditQuestTitle.Visible := true;
  FormAdmin.EditMark.Visible := true;
  FormAdmin.LabelMark.Visible := true;

  FormAdmin.Edit1.Visible := true;
  FormAdmin.Edit2.Visible := true;
  FormAdmin.Edit3.Visible := true;
  FormAdmin.Edit4.Visible := true;
  FormAdmin.Edit5.Visible := true;

  FormAdmin.CheckBox1.Visible := true;
  FormAdmin.CheckBox2.Visible := true;
  FormAdmin.CheckBox3.Visible := true;
  FormAdmin.CheckBox4.Visible := true;
  FormAdmin.CheckBox5.Visible := true;
end;

procedure SetFieldUnVisible;
begin
  FormAdmin.LabelAnswers.Visible := false;
  FormAdmin.LabelAnswersValid.Visible := false;
  FormAdmin.LabelTitle.Visible := false;
  FormAdmin.EditQuestTitle.Visible := false;
  FormAdmin.EditMark.Visible := false;
  FormAdmin.LabelMark.Visible := false;
  FormAdmin.ButtonSaveResult.Visible := false;
  FormAdmin.ButtonPrev.Visible := false;
  FormAdmin.ButtonNext.Visible := false;
  FormAdmin.ButtonNewQuest.Visible := false;
  FormAdmin.ButtonSaveResult.Visible := false;
  FormAdmin.ButtonDelete.Visible := false;

  FormAdmin.EditTitle.Visible := false;
  FormAdmin.EditTime.Visible := false;
  FormAdmin.LabelEditTitle.Visible := false;
  FormAdmin.LabelEditTime.Visible := false;

  FormAdmin.Edit1.Visible := false;
  FormAdmin.Edit2.Visible := false;
  FormAdmin.Edit3.Visible := false;
  FormAdmin.Edit4.Visible := false;
  FormAdmin.Edit5.Visible := false;

  FormAdmin.CheckBox1.Visible := false;
  FormAdmin.CheckBox2.Visible := false;
  FormAdmin.CheckBox3.Visible := false;
  FormAdmin.CheckBox4.Visible := false;
  FormAdmin.CheckBox5.Visible := false;
end;

procedure ClearField;
begin
  FormAdmin.EditQuestTitle.Text := '';
  FormAdmin.EditMark.Text := '';

  FormAdmin.Edit1.Text := '';
  FormAdmin.Edit2.Text := '';
  FormAdmin.Edit3.Text := '';
  FormAdmin.Edit4.Text := '';
  FormAdmin.Edit5.Text := '';

  FormAdmin.CheckBox1.Checked := false;
  FormAdmin.CheckBox2.Checked := false;
  FormAdmin.CheckBox3.Checked := false;
  FormAdmin.CheckBox4.Checked := false;
  FormAdmin.CheckBox5.Checked := false;
end;

procedure SetButtons;
begin
  if (CQ <> Nil) then
  begin
    FormAdmin.ButtonPrev.Visible := true;
    FormAdmin.ButtonNext.Visible := true;
    FormAdmin.ButtonNewQuest.Visible := false;
    FormAdmin.ButtonSaveResult.Visible := true;
    FormAdmin.ButtonDelete.Visible := true;

    FormAdmin.sGauge1.MaxValue := GetNOQ(FQuest);
    FormAdmin.sGauge1.Progress := GetQP(FQuest, CQ);

    if ((PrevQuest(CQ) = Nil) and (NextQuest(CQ) = Nil)) then
    begin
      FormAdmin.ButtonPrev.Visible := false;
      FormAdmin.ButtonNext.Visible := false;
      FormAdmin.ButtonNewQuest.Visible := true;
    end
    else if (PrevQuest(CQ) = Nil) and (NextQuest(CQ) <> Nil) then
    begin
      FormAdmin.ButtonPrev.Visible := false;
      FormAdmin.ButtonNext.Visible := true;
      FormAdmin.ButtonNewQuest.Visible := false;
    end
    else if (NextQuest(CQ) = Nil) then
    begin
      FormAdmin.ButtonPrev.Visible := true;
      FormAdmin.ButtonNext.Visible := false;
      FormAdmin.ButtonNewQuest.Visible := true;
      FormAdmin.ButtonSaveResult.Visible := true;
    end;
  end;
end;

{$R *.dfm}

procedure SetCreateEditUnVisible;
begin
  FormAdmin.ButtonCreate.Visible := false;
  FormAdmin.ButtonEdit.Visible := false;
end;

procedure SetTitleTimeVisible;
begin
  SetCreateEditUnVisible;
  FormAdmin.EditTitle.Visible := true;
  FormAdmin.EditTime.Visible := true;
  FormAdmin.LabelEditTitle.Visible := true;
  FormAdmin.LabelEditTime.Visible := true;
  FormAdmin.ButtonStart.Visible := true;
end;

procedure TFormAdmin.ButtonCreateClick(Sender: TObject);
begin
  SetTitleTimeVisible;
  TOA := 'create';
end;

procedure TFormAdmin.ButtonEditClick(Sender: TObject);
begin
  SetCreateEditUnVisible;
  TOA := 'edit';
  FormAdmin.ListBoxFileSelect.Visible := true;
  FormAdmin.LabelSelectTest.Visible := true;
end;

procedure TFormAdmin.ListBoxFileSelectDblClick(Sender: TObject);
begin
  if (length(FormAdmin.ListBoxFileSelect.Items[FormAdmin.ListBoxFileSelect.ItemIndex]) > 1) then
  begin          
    SetTitleTimeVisible;
    testName := FormAdmin.ListBoxFileSelect.Items[FormAdmin.ListBoxFileSelect.ItemIndex];
    FQuest := OpenTest(ExtractFilePath(Application.ExeName) + 'Tests/' + FormAdmin.ListBoxFileSelect.Items[FormAdmin.ListBoxFileSelect.ItemIndex] + '.txt');
    FormAdmin.EditTitle.Text := GetTitle(FQuest);
    FormAdmin.EditTime.Text := IntToStr(GetTime(FQuest));
  end;
end;

procedure TFormAdmin.ButtonStartClick(Sender: TObject);
begin
  if ((length(FormAdmin.EditTitle.Text) > 3) and (length(FormAdmin.EditTime.Text) > 1)) then
  begin

    FormAdmin.EditTitle.Readonly := true;
    FormAdmin.EditTime.Readonly := true;
    FormAdmin.EditTitle.Enabled := false;
    FormAdmin.EditTime.Enabled := false;
    FormAdmin.ButtonStart.Visible := false;
    FormAdmin.ListBoxFileSelect.Visible := false;
    FormAdmin.LabelSelectTest.Visible := false;

    if (StrToInt(FormAdmin.EditTime.Text) = 0) then
      FormAdmin.EditTime.Text := '10';

    if (TOA = 'create') then
    begin
      CreateTest(FQuest);
      FillFirstQuest(FQuest, FormAdmin.EditTitle.Text, StrToInt(FormAdmin.EditTime.Text));
      CQ := FQuest;
      // Начальные установки
      AddQuest(FQuest, '', 0, '');
      FillFirstOption(FQuest);
      CQ := NextQuest(FQuest);

    end
    else if (TOA = 'edit') then
    begin
      FQuest^.Title := FormAdmin.EditTitle.Text;
      FQuest^.Time := StrToInt(FormAdmin.EditTime.Text);
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

procedure TFormAdmin.ButtonNewQuestClick(Sender: TObject);
begin
  if (not IsFieldsClean) and IsAnswerGiven and (not IsFieldsTitleClean) and (length(FormAdmin.EditQuestTitle.Text) > 2) then
  begin
    SaveFields;
    InitCQ;
    ClearField;
    SetFieldVisible;
    SetButtons;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за тест не будет указана, то она будет равна 1 по-умолчанию. Поля должны быть заполнены. Минимум один ответ.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TFormAdmin.ButtonPrevClick(Sender: TObject);
begin
  if (IsFieldsTitleClean and IsFieldsClean) and (PrevQuest(CQ) <> Nil) then
  begin
    CQ^.PrevQuest^.NextQuest := Nil;
    CQ := PrevQuest(CQ);
    SetButtons;
    LoadFields;
  end
  else if ((length(FormAdmin.EditQuestTitle.Text) > 2) and IsAnswerGiven and (not IsFieldsClean)) then
  begin
    SaveFields;

    ClearField;
    SetFieldVisible;

    CQ := PrevQuest(CQ);
    SetButtons;

    LoadFields;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за вопрос не будет указана, то она будет равна 1 по-умолчанию. Поля должны быть заполнены. Минимум один ответ.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TFormAdmin.ButtonNextClick(Sender: TObject);
begin
  if (length(FormAdmin.EditQuestTitle.Text) > 2) and IsAnswerGiven and (not IsFieldsClean) then
  begin
    SaveFields;

    ClearField;
    SetFieldVisible;

    CQ := NextQuest(CQ);
    SetButtons;
                     
    LoadFields;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за вопрос не будет указана, то она будет равна 1 по-умолчанию. Поля должны быть заполнены. Минимум один ответ.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TFormAdmin.ButtonSaveResultClick(Sender: TObject);
begin
  if (length(FormAdmin.EditQuestTitle.Text) > 2) and IsAnswerGiven and (not IsFieldsClean) then
  begin
    SaveFields;

    ClearField;
    SetFieldUnVisible;
    if (TOA = 'create') then
    begin
      FormAdmin.LabelSavedSucc.Visible := true;
      FormAdmin.LabelSavedSucc.Caption := FormAdmin.LabelSavedSucc.Caption + ' Tests/' + SaveTest(FQuest, '');
    end
    else if (TOA = 'edit') then
    begin
      FormAdmin.LabelSavedSucc.Visible := true;
      FormAdmin.LabelSavedSucc.Caption := FormAdmin.LabelSavedSucc.Caption + ' Tests/' + SaveTest(FQuest, testname + '.txt') + ' [Обновлено]';
    end;
    FormAdmin.sGauge1.Visible := false;
    IsRunning := false;
  end
  else
    MessageBox(handle, PChar('Минимальная длина для названия - 3 символ. Если оценка за вопрос не будет указана, то она будет равна 1 по-умолчанию. Поля должны быть заполнены. Минимум один ответ.'), PChar('Ошибка ввода'),(MB_OK+MB_ICONWARNING));
end;

procedure TFormAdmin.FormCreate(Sender: TObject);
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
        FormAdmin.ListBoxFileSelect.Items.Add('test' + IntToStr(i));
        de := 0;
      end;
    end
    else
      inc(de);
    inc(i);
  end;
end;

procedure TFormAdmin.EditTimeKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['0' .. '9'];
begin
if (Key = #13) then
  ButtonStart.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

procedure TFormAdmin.EditTitleKeyPress(Sender: TObject; var Key: Char);
begin
if (Key = #13) then
  ButtonStart.Click;
end;

procedure TFormAdmin.EditMarkKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['0' .. '9'];
begin
if (Key = #13) then
  ButtonStart.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

procedure TFormAdmin.ButtonDeleteClick(Sender: TObject);
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

procedure TFormAdmin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
