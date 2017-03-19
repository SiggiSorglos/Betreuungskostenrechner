program Betreuungskostenrechner_;

uses
  Forms,
  Betreuungskostenrechner in 'Betreuungskostenrechner.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Betreuungsrechner';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
