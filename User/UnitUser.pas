unit UnitUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ActnList, Menus, ComCtrls, UnitModelUser, ToolWin,
  sSkinManager, sGauge, sGroupBox, sCheckBox, sLabel, acProgressBar,
  sToolBar, sPanel, acPageScroller, acAlphaHints, Mask, sMaskEdit,
  sCustomComboEdit, sComboEdit, sMemo;

type
  TForm1 = class(TForm)
    Button2: TButton;
    Button1: TButton;
    Label2: TLabel;
    Timer1: TTimer;
    Button4: TButton;
    LabelTime: TLabel;
    ButtonFinish: TButton;
    LabelResult: TLabel;
    EditName: TEdit;
    ButtonName: TButton;
    LabelName: TLabel;
    LabelSaved: TLabel;
    ListBoxFileSelect: TListBox;
    sSkinManager1: TsSkinManager;
    sGauge1: TsGauge;
    RadioGroup1: TsRadioGroup;
    GroupBoxChecked: TsGroupBox;
    CheckBox1: TsCheckBox;
    CheckBox2: TsCheckBox;
    CheckBox3: TsCheckBox;
    CheckBox4: TsCheckBox;
    CheckBox5: TsCheckBox;
    Label1: TsLabel;
    ProgressBar1: TsProgressBar;
    sMemoTitle: TsMemo;
    ListBoxResult: TsMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ButtonFinishClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonNameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxFileSelectDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TimeLeft: integer;
  FQuest, CQ: TQuest;
  CO: TOpt;
  NameOfFile: string;
  IsRunning: boolean;

implementation
{$R *.dfm}

procedure ClearField;
begin
  // Видимость
  Form1.GroupBoxChecked.Visible := false;
  Form1.CheckBox1.Visible := false;
  Form1.CheckBox2.Visible := false;
  Form1.CheckBox3.Visible := false;
  Form1.CheckBox4.Visible := false;
  Form1.CheckBox5.Visible := false;

  // Значения
  Form1.CheckBox1.Checked := false;
  Form1.CheckBox2.Checked := false;
  Form1.CheckBox3.Checked := false;
  Form1.CheckBox4.Checked := false;
  Form1.CheckBox5.Checked := false;

  // Radio
  Form1.RadioGroup1.Visible := false;
  Form1.RadioGroup1.Items.Clear;
end;

procedure SaveQuest;
begin
  if (GetTOQ(CQ) = 'checkbox') then
  begin
    CQ^.Answers := '';
    if (Form1.CheckBox1.Checked) then
      CQ^.Answers := CQ^.Answers + '1';
    if (Form1.CheckBox2.Checked) then
      CQ^.Answers := CQ^.Answers + '2';
    if (Form1.CheckBox3.Checked) then
      CQ^.Answers := CQ^.Answers + '3';
    if (Form1.CheckBox4.Checked) then
      CQ^.Answers := CQ^.Answers + '4';
    if (Form1.CheckBox5.Checked) then
      CQ^.Answers := CQ^.Answers + '5';
  end
  else if (GetTOQ(CQ) = 'radio') then
  begin
    CQ^.Answers := IntToStr(Form1.RadioGroup1.ItemIndex + 1);
  end;
end;

procedure SetButtons;
begin
  if (CQ <> Nil) then
  begin
    Form1.Button1.Visible := true;
    Form1.Button2.Visible := true;
    if (GetQuestID(CQ) = 0) then
    begin
      Form1.Button1.Visible := false;
      Form1.Button2.Visible := false;
      Form1.ButtonFinish.Visible := false;
    end
    else if (PrevQuest(CQ) = Nil) then
    begin
      Form1.Button1.Visible := false;
      Form1.Button2.Visible := true;
      Form1.ButtonFinish.Visible := false;
    end
    else if (NextQuest(CQ) = Nil) then
    begin
      Form1.Button1.Visible := true;
      Form1.Button2.Visible := false;
      Form1.ButtonFinish.Visible := true;
    end;
  end;
end;

procedure SetGroupChecked(i: integer; CO: TOpt; Checked: boolean);
begin
  case i of
    1: begin
      Form1.CheckBox1.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      Form1.CheckBox1.Visible := true;
      Form1.CheckBox1.Checked := Checked;
    end;
    2: begin
      Form1.CheckBox2.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      Form1.CheckBox2.Visible := true;
      Form1.CheckBox2.Checked := Checked;
    end;
    3: begin
      Form1.CheckBox3.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      Form1.CheckBox3.Visible := true;
      Form1.CheckBox3.Checked := Checked;
    end;
    4: begin
      Form1.CheckBox4.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      Form1.CheckBox4.Visible := true;
      Form1.CheckBox4.Checked := Checked;
    end;
    5: begin
      Form1.CheckBox5.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      Form1.CheckBox5.Visible := true;
      Form1.CheckBox5.Checked := Checked;
    end;
  end;
end;

procedure DrawQuest;
var
  i, k: integer;
  CO: TOpt;
  is_checked: boolean;
  answers: string;
begin
  Form1.sMemoTitle.Visible := true;
  Form1.sMemoTitle.Lines.Text := IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ);
    CO := CQ^.Options;
  if (GetTOQ(CQ) = 'checkbox') then
  begin
    Form1.GroupBoxChecked.Visible := true;
    for i := 1 to GetNOO(CQ) do
    begin
      NextOpt(CO);

      is_checked := false;
      answers := GetUserAnswers(CQ);
      for k := 1 to length(answers) do
        if (answers[k] = IntToStr(i)) then
          is_checked := true;

      if (is_checked) then
        SetGroupChecked(i, CO, true)
      else
        SetGroupChecked(i, CO, false);
    end;
  end
  else if (GetTOQ(CQ) = 'radio') then
  begin
    Form1.RadioGroup1.Visible := true;
    for i := 1 to GetNOO(CQ) do
    begin
      NextOpt(CO);
      Form1.RadioGroup1.Items.Add(IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO));
    end;
    if (StrToInt(GetUserAnswers(CQ)) > 0) then
      Form1.RadioGroup1.ItemIndex := (StrToInt(GetUserAnswers(CQ)) - 1);

  end;
  SetButtons;
  Form1.sGauge1.Progress := GetQuestID(CQ);
end;

procedure Test(testFile: string);
var
  test, answer: string;
  time: integer;

begin
  if (IsTestValid(testFile)) then
  begin
    Form1.Label2.Visible := false;
    FQuest := OpenTest(testFile);
    NameOfFile := testFile;

    Form1.Label1.Caption := GetTitle(FQuest);
    Form1.LabelTime.Caption := 'Времени: ' + IntToStr(GetTime(FQuest)) + ' сек.';
    Form1.LabelTime.Visible := true;
    CQ := FQuest;

    TimeLeft := GetTime(FQuest);
    Form1.ProgressBar1.Max := TimeLeft;

    Form1.sGauge1.MaxValue := GetNOQ(FQuest);

    SetButtons;

    Form1.Button4.Visible := true;
  end
  else
  begin
    Form1.Label2.Caption := 'Неверный формат теста.';
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  CQ := NextQuest(CQ);
  DrawQuest;

  Form1.Button4.Visible := false;
  Form1.ListBoxFileSelect.Visible := false;
  Form1.ProgressBar1.Visible := true;

  Form1.sGauge1.Visible := true;
  Form1.sGauge1.Progress := GetQuestID(CQ);

  Form1.LabelTime.Font.Size := 8;
  Form1.Timer1.Enabled := true;
  IsRunning := true;
end;

procedure EndTest;
begin
  // Прячем остатки от теста
  Form1.Button1.Visible := false;
  Form1.Button2.Visible := false;
  Form1.ButtonFinish.Visible := false;
  Form1.sMemoTitle.Visible := false;
  Form1.LabelTime.Visible := false;
  Form1.ProgressBar1.Visible := false;
  Form1.sGauge1.Visible := false;

  // Вводим фамилию
  Form1.ButtonName.Visible := true;
  Form1.LabelName.Visible := true;
  Form1.EditName.Visible := true;
end;

procedure PrintResults;
var
  HashCalc, i: integer;
begin
  // Подсчитаем результаты
  CQ := NextQuest(FQuest);
  while (CQ <> Nil) do
  begin
    CheckQuest(CQ);
    CQ := NextQuest(CQ);
  end;
  IsRunning := false;
  Form1.LabelResult.Visible := true;
  Form1.LabelResult.Caption := 'Вы набрали ' + IntToStr(GetMark(FQuest)) + ' из ' + IntToStr(GetMaxMark(FQuest)) + ' баллов.';

  // Вывод правильных неправильных ответов
  Form1.ListBoxResult.Visible := true;
  CQ := NextQuest(FQuest);
  Form1.ListBoxResult.Lines.Add('Название: ' + GetTitle(FQuest));
  Form1.ListBoxResult.Lines.Add('Время на тест: ' + IntToStr(GetTime(FQuest)) + ' секунд');
  Form1.ListBoxResult.Lines.Add(' ');
  Form1.ListBoxResult.Lines.Add('Ваша фамилия: ' + Form1.EditName.Text);
  Form1.ListBoxResult.Lines.Add('Закончен за: ' + IntToStr(GetTime(FQuest) - TimeLeft) + ' секунд');
  Form1.ListBoxResult.Lines.Add('Результат: ' + IntToStr(GetMark(FQuest)) + ' из ' + IntToStr(GetMaxMark(FQuest)) + ' баллов');
  Form1.ListBoxResult.Lines.Add(' ');
  Form1.ListBoxResult.Lines.Add('Вопросы: [баллы]');
  while (CQ <> Nil) do
  begin
    if (IsSolved(CQ)) then
      Form1.ListBoxResult.Lines.Add(IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ) + ' [' + IntToStr(GetCurrMark(CQ)) + '] ')
    else
      Form1.ListBoxResult.Lines.Add(IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ) + ' [' + IntToStr(GetCurrMark(CQ)) + '] ' + '; - НЕВЕРНО');
    CQ := NextQuest(CQ);
  end;

  //Считаем хэш
  HashCalc := 0;
  HashCalc := GetHash(NameOfFile);
  for i := 0 to Form1.ListBoxResult.Lines.Count-1 do
    HashCalc := (HashCalc + GetHash(Form1.ListBoxResult.Lines[i])*(i*i+1)) mod 100000000;
  HashCalc := HashCalc * GetSalt;

  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'results') then
    CreateDir(ExtractFilePath(Application.ExeName) + 'results');
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'results/' + Form1.EditName.Text) then
    CreateDir(ExtractFilePath(Application.ExeName) + 'results/' + Form1.EditName.Text);

  Form1.ListBoxResult.Lines.SaveToFile(ExtractFilePath(Application.ExeName) + 'results/' + Form1.EditName.Text + '/result_' + Form1.EditName.Text + '_' + IntToStr(HashCalc) + '.txt');
  Form1.LabelSaved.Caption := 'Сохранено в файл /results/' + Form1.EditName.Text + '/' + 'result_' + IntToStr(HashCalc) + '.txt';
end;

procedure TForm1.ListBoxFileSelectDblClick(Sender: TObject);
begin
  if (length(Form1.ListBoxFileSelect.Items[Form1.ListBoxFileSelect.ItemIndex]) > 1) then
  begin
    Test(ExtractFilePath(Application.ExeName) + 'Tests/' + Form1.ListBoxFileSelect.Items[Form1.ListBoxFileSelect.ItemIndex] + '.txt');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (TimeLeft >= 0) then
  begin
    Form1.ProgressBar1.Position := Form1.ProgressBar1.Position + 1;
    Form1.LabelTime.Caption := 'Времени осталось: ' + IntToStr(TimeLeft) + ' сек.';
    Dec(TimeLeft);
    Form1.Timer1.Enabled := true;
  end
  else
  begin
    Form1.Timer1.Enabled := false;
    ClearField;
    EndTest;
  end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  SaveQuest;
  ClearField;
  CQ := NextQuest(CQ);
  DrawQuest;
  SetButtons;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SaveQuest;
  ClearField;
  CQ := PrevQuest(CQ);
  DrawQuest;
  SetButtons;
end;

procedure TForm1.ButtonFinishClick(Sender: TObject);
begin
  Form1.Timer1.Enabled := false;
  SaveQuest;
  ClearField;
  EndTest;
end;

procedure TForm1.EditNameKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['a' .. 'z', 'A' .. 'Z', 'а' .. 'я', 'А' .. 'Я', '-'];
begin
if ((Key = #13) and (length(Form1.EditName.Text) > 2)) then
  ButtonName.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

procedure TForm1.ButtonNameClick(Sender: TObject);
begin
  if (length(Form1.EditName.Text) > 2) then
  begin
    // Фамилия
    Form1.ButtonName.Visible := false;
    Form1.LabelName.Visible := false;
    Form1.EditName.Visible := false;
    PrintResults;
  end
  else
    MessageBox(Handle, 'Минимальная длина фамилии должна быть 3 символа и больше!', 'Ввод: Фамилия', MB_OK + MB_ICONERROR);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, de: integer;
  fileName, testName: string;
begin
  i := 1;
  de := 0;
  IsRunning := false;
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

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not (IsRunning) then
  begin
    case MessageBox(Handle, 'Вы действительно хотите выйти?', 'Завершение', MB_YESNO + MB_ICONQUESTION) of
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
    MessageBox(Handle, 'Выход из теста во время проведения тестирования запрещен!', 'Выход из программы', MB_OK + MB_ICONERROR);
    CanClose:=False;
  end;
end;

end.
