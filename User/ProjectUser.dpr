program ProjectUser;

uses
  Forms,
  UnitUser in 'UnitUser.pas' {Form1},
  UnitModelUser in 'UnitModelUser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
