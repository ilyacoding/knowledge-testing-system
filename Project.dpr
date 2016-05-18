program Project;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {Form1},
  UnitAdmin in 'UnitAdmin.pas' {FormAdmin},
  UnitUser in 'UnitUser.pas' {FormUser};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormAdmin, FormAdmin);
  Application.CreateForm(TFormUser, FormUser);
  Application.Run;
end.
