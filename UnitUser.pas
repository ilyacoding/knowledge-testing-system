unit UnitUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ActnList, Menus, ComCtrls, UnitModel, ToolWin,
  sSkinManager, sGauge, sGroupBox, sCheckBox, sLabel, acProgressBar,
  sToolBar, sPanel, acPageScroller, acAlphaHints, Mask, sMaskEdit,
  sCustomComboEdit, sComboEdit, sMemo;

type
  TFormUser = class(TForm)
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
  FormUser: TFormUser;
  TimeLeft: integer;
  FQuest, CQ: TQuest;
  CO: TOpt;
  NameOfFile: string;
  IsRunning: boolean;

implementation

{$R *.dfm}

procedure ClearField;
begin
  FormUser.GroupBoxChecked.Visible := false;
  FormUser.CheckBox1.Visible := false;
  FormUser.CheckBox2.Visible := false;
  FormUser.CheckBox3.Visible := false;
  FormUser.CheckBox4.Visible := false;
  FormUser.CheckBox5.Visible := false;

  FormUser.CheckBox1.Checked := false;
  FormUser.CheckBox2.Checked := false;
  FormUser.CheckBox3.Checked := false;
  FormUser.CheckBox4.Checked := false;
  FormUser.CheckBox5.Checked := false;

  FormUser.RadioGroup1.Visible := false;
  FormUser.RadioGroup1.Items.Clear;
end;

procedure SaveQuest;
begin
  if (GetTOQ(CQ) = 'checkbox') then
  begin
    CQ^.Answers := '';
    if (FormUser.CheckBox1.Checked) then
      CQ^.Answers := CQ^.Answers + '1';
    if (FormUser.CheckBox2.Checked) then
      CQ^.Answers := CQ^.Answers + '2';
    if (FormUser.CheckBox3.Checked) then
      CQ^.Answers := CQ^.Answers + '3';
    if (FormUser.CheckBox4.Checked) then
      CQ^.Answers := CQ^.Answers + '4';
    if (FormUser.CheckBox5.Checked) then
      CQ^.Answers := CQ^.Answers + '5';
  end
  else if (GetTOQ(CQ) = 'radio') then
  begin
    CQ^.Answers := IntToStr(FormUser.RadioGroup1.ItemIndex + 1);
  end;
end;

procedure SetButtons;
begin
  if (CQ <> Nil) then
  begin
    FormUser.Button1.Visible := true;
    FormUser.Button2.Visible := true;
    if (GetQuestID(CQ) = 0) then
    begin
      FormUser.Button1.Visible := false;
      FormUser.Button2.Visible := false;
      FormUser.ButtonFinish.Visible := false;
    end
    else if (PrevQuest(CQ) = Nil) and (NextQuest(CQ) = Nil) then
    begin
      FormUser.Button1.Visible := false;
      FormUser.Button2.Visible := false;
      FormUser.ButtonFinish.Visible := true;
    end
    else if (PrevQuest(CQ) = Nil) then
    begin
      FormUser.Button1.Visible := false;
      FormUser.Button2.Visible := true;
      FormUser.ButtonFinish.Visible := false;
    end
    else if (NextQuest(CQ) = Nil) then
    begin
      FormUser.Button1.Visible := true;
      FormUser.Button2.Visible := false;
      FormUser.ButtonFinish.Visible := true;
    end;
  end;
end;

procedure SetGroupChecked(i: integer; CO: TOpt; Checked: boolean);
begin
  case i of
    1: begin
      FormUser.CheckBox1.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      FormUser.CheckBox1.Visible := true;
      FormUser.CheckBox1.Checked := Checked;
    end;
    2: begin
      FormUser.CheckBox2.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      FormUser.CheckBox2.Visible := true;
      FormUser.CheckBox2.Checked := Checked;
    end;
    3: begin
      FormUser.CheckBox3.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      FormUser.CheckBox3.Visible := true;
      FormUser.CheckBox3.Checked := Checked;
    end;
    4: begin
      FormUser.CheckBox4.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      FormUser.CheckBox4.Visible := true;
      FormUser.CheckBox4.Checked := Checked;
    end;
    5: begin
      FormUser.CheckBox5.Caption := IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO);
      FormUser.CheckBox5.Visible := true;
      FormUser.CheckBox5.Checked := Checked;
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
  FormUser.sMemoTitle.Visible := true;
  FormUser.sMemoTitle.Lines.Text := IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ);
    CO := CQ^.Options;
  if (GetTOQ(CQ) = 'checkbox') then
  begin
    FormUser.GroupBoxChecked.Visible := true;
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
    FormUser.RadioGroup1.Visible := true;
    for i := 1 to GetNOO(CQ) do
    begin
      NextOpt(CO);
      FormUser.RadioGroup1.Items.Add(IntToStr(GetOptID(CO)) + ') ' + GetOptInfo(CO));
    end;
    if (StrToInt(GetUserAnswers(CQ)) > 0) then
      FormUser.RadioGroup1.ItemIndex := (StrToInt(GetUserAnswers(CQ)) - 1);
  end;
  SetButtons;
  FormUser.sGauge1.Progress := GetQuestID(CQ);
end;

procedure Test(testFile: string);
begin
  if (IsTestValid(testFile)) then
  begin
    FormUser.Label2.Visible := false;
    FQuest := OpenTest(testFile);
    NameOfFile := testFile;

    FormUser.Label1.Caption := GetTitle(FQuest);
    FormUser.LabelTime.Caption := 'Времени: ' + IntToStr(GetTime(FQuest)) + ' сек.';
    FormUser.LabelTime.Visible := true;
    CQ := FQuest;

    TimeLeft := GetTime(FQuest);
    FormUser.ProgressBar1.Max := TimeLeft;

    FormUser.sGauge1.MaxValue := GetNOQ(FQuest);

    SetButtons;

    FormUser.Button4.Visible := true;
  end;
end;

procedure TFormUser.Button4Click(Sender: TObject);
begin
  CQ := NextQuest(CQ);
  DrawQuest;

  FormUser.Button4.Visible := false;
  FormUser.ListBoxFileSelect.Visible := false;
  FormUser.ProgressBar1.Visible := true;

  FormUser.sGauge1.Visible := true;
  FormUser.sGauge1.Progress := GetQuestID(CQ);

  FormUser.LabelTime.Font.Size := 8;
  FormUser.Timer1.Enabled := true;
  IsRunning := true;
end;

procedure EndTest;
begin
  FormUser.Button1.Visible := false;
  FormUser.Button2.Visible := false;
  FormUser.ButtonFinish.Visible := false;
  FormUser.sMemoTitle.Visible := false;
  FormUser.LabelTime.Visible := false;
  FormUser.ProgressBar1.Visible := false;
  FormUser.sGauge1.Visible := false;

  FormUser.ButtonName.Visible := true;
  FormUser.LabelName.Visible := true;
  FormUser.EditName.Visible := true;
end;

procedure PrintResults;
var
  HashCalc, i: integer;
begin
  CQ := NextQuest(FQuest);
  while (CQ <> Nil) do
  begin
    CheckQuest(CQ);
    CQ := NextQuest(CQ);
  end;
  IsRunning := false;
  FormUser.LabelResult.Visible := true;
  FormUser.LabelResult.Caption := 'Вы набрали ' + IntToStr(GetMark(FQuest)) + ' из ' + IntToStr(GetMaxMark(FQuest)) + ' баллов.';

  FormUser.ListBoxResult.Visible := true;
  CQ := NextQuest(FQuest);
  FormUser.ListBoxResult.Lines.Add('Название: ' + GetTitle(FQuest));
  FormUser.ListBoxResult.Lines.Add('Время на тест: ' + IntToStr(GetTime(FQuest)) + ' секунд');
  FormUser.ListBoxResult.Lines.Add(' ');
  FormUser.ListBoxResult.Lines.Add('Ваша фамилия: ' + FormUser.EditName.Text);
  FormUser.ListBoxResult.Lines.Add('Закончен за: ' + IntToStr(GetTime(FQuest) - TimeLeft) + ' секунд');
  FormUser.ListBoxResult.Lines.Add('Результат: ' + IntToStr(GetMark(FQuest)) + ' из ' + IntToStr(GetMaxMark(FQuest)) + ' баллов');
  FormUser.ListBoxResult.Lines.Add(' ');
  FormUser.ListBoxResult.Lines.Add('Вопросы: [баллы]');
  while (CQ <> Nil) do
  begin
    if (IsSolved(CQ)) then
      FormUser.ListBoxResult.Lines.Add(IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ) + ' [' + IntToStr(GetCurrMark(CQ)) + '] ')
    else
      FormUser.ListBoxResult.Lines.Add(IntToStr(GetQuestID(CQ)) + ') ' + GetTitle(CQ) + ' [' + IntToStr(GetCurrMark(CQ)) + '] ' + '; - НЕВЕРНО');
    CQ := NextQuest(CQ);
  end;

  HashCalc := GetHash(NameOfFile);
  for i := 0 to FormUser.ListBoxResult.Lines.Count-1 do
    HashCalc := (HashCalc + GetHash(FormUser.ListBoxResult.Lines[i])*(i*i+1)) mod 100000000;
  HashCalc := HashCalc * GetSalt;

  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'results') then
    CreateDir(ExtractFilePath(Application.ExeName) + 'results');
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'results/' + FormUser.EditName.Text) then
    CreateDir(ExtractFilePath(Application.ExeName) + 'results/' + FormUser.EditName.Text);

  FormUser.ListBoxResult.Lines.SaveToFile(ExtractFilePath(Application.ExeName) + 'results/' + FormUser.EditName.Text + '/result_' + FormUser.EditName.Text + '_' + IntToStr(HashCalc) + '.txt');
  FormUser.LabelSaved.Caption := 'Сохранено в файл /results/' + FormUser.EditName.Text + '/' + 'result_' + IntToStr(HashCalc) + '.txt';
end;

procedure TFormUser.ListBoxFileSelectDblClick(Sender: TObject);
begin
  if (length(FormUser.ListBoxFileSelect.Items[FormUser.ListBoxFileSelect.ItemIndex]) > 1) then
  begin
    Test(ExtractFilePath(Application.ExeName) + 'Tests/' + FormUser.ListBoxFileSelect.Items[FormUser.ListBoxFileSelect.ItemIndex] + '.txt');
  end;
end;

procedure TFormUser.Timer1Timer(Sender: TObject);
begin
  if (TimeLeft >= 0) then
  begin
    FormUser.ProgressBar1.Position := FormUser.ProgressBar1.Position + 1;
    FormUser.LabelTime.Caption := 'Времени осталось: ' + IntToStr(TimeLeft) + ' сек.';
    Dec(TimeLeft);
    FormUser.Timer1.Enabled := true;
  end
  else
  begin
    FormUser.Timer1.Enabled := false;
    ClearField;
    EndTest;
  end;
end;

procedure TFormUser.Button2Click(Sender: TObject);
begin
  SaveQuest;
  ClearField;
  CQ := NextQuest(CQ);
  DrawQuest;
  SetButtons;
end;

procedure TFormUser.Button1Click(Sender: TObject);
begin
  SaveQuest;
  ClearField;
  CQ := PrevQuest(CQ);
  DrawQuest;
  SetButtons;
end;

procedure TFormUser.ButtonFinishClick(Sender: TObject);
begin
  FormUser.Timer1.Enabled := false;
  SaveQuest;
  ClearField;
  EndTest;
end;

procedure TFormUser.EditNameKeyPress(Sender: TObject; var Key: Char);
const abc: Set of Char=['a' .. 'z', 'A' .. 'Z', 'а' .. 'я', 'А' .. 'Я', '-'];
begin
if ((Key = #13) and (length(FormUser.EditName.Text) > 2)) then
  ButtonName.Click;

if ((not (Key in abc)) and (not (Key = #08))) then
  Key:=#0;
end;

procedure TFormUser.ButtonNameClick(Sender: TObject);
begin
  if (length(FormUser.EditName.Text) > 2) then
  begin
    FormUser.ButtonName.Visible := false;
    FormUser.LabelName.Visible := false;
    FormUser.EditName.Visible := false;
    PrintResults;
  end
  else
    MessageBox(Handle, 'Минимальная длина фамилии должна быть 3 символа и больше!', 'Ввод: Фамилия', MB_OK + MB_ICONERROR);
end;

procedure TFormUser.FormCreate(Sender: TObject);
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
        FormUser.ListBoxFileSelect.Items.Add('test' + IntToStr(i));
        de := 0;
      end;
    end
    else
      inc(de);
    inc(i);
  end;
end;

procedure TFormUser.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
