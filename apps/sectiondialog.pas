unit SectionDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TSectionDlg }

  TSectionDlg = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
  private

  public
    function Open(secname:String=''):String;
  end;

var
  SectionDlg: TSectionDlg;

implementation

{$R *.lfm}

{ TSectionDlg }

function TSectionDlg.Open(secname: String): String;
begin
  Edit1.Text:=secname;
  if ShowModal=mrOK then Result:=Edit1.Text
  else Result:='';
end;

end.

