unit Unit1;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  ACL.UI.Forms,
  ACL.UI.Controls.BaseControls,
  ACL.UI.Controls.Buttons;

type

  { TForm1 }

  TForm1 = class(TACLForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  L: TACLContainer;
  //U: string;
begin
  //RegisterIntegerConsts(;
  L := TACLContainer.Create(Self);
  L.Parent := Self;
  L.Align := alClient;

  with TACLButton.Create(Self) do
  begin
    Caption := 'Русский текст';
    Parent := L;
  end;

  //U := 'русский';
  //Caption := IntToStr(Length(U));
  //Caption := U[1] + U[2];
//  Caption := UTF8Encode(U[1] + U[2]);
end;

end.

