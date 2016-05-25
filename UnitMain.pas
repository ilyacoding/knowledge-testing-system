unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sSkinManager, sButton;

type
  TForm1 = class(TForm)
    ButtonOpenAdmin: TButton;
    ButtonOpenUser: TButton;
    sSkinManager1: TsSkinManager;
    procedure ButtonOpenAdminClick(Sender: TObject);
    procedure ButtonOpenUserClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  IsExit: boolean;
implementation

uses UnitAdmin, UnitUser;

{$R *.dfm}

procedure TForm1.ButtonOpenAdminClick(Sender: TObject);
begin
  Form1.Visible := false;
  IsExit := true;
  FormAdmin.ShowModal;
  Form1.Close;
end;

procedure TForm1.ButtonOpenUserClick(Sender: TObject);
begin
  Form1.Visible := false;
  IsExit := true;
  FormUser.ShowModal;
  Form1.Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (IsExit) then
    CanClose := True
  else
  case MessageBox(Handle, 'Вы действительно хотите выйти? ', 'Выход', MB_YESNO + MB_ICONQUESTION) of
    IDYES:
    begin
      CanClose := True;
    end;
    IDNO:
    begin
      CanClose := False;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.ButtonOpenAdmin.TabStop := false;
  IsExit := false;
  Form1.ButtonOpenUser.TabStop := false;
end;

end.
