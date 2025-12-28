program SLC;

uses
  Vcl.Forms,
  fSymlink in 'fSymlink.pas' {main},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SymLink Creator';
  Application.CreateForm(Tmain, main);
  Application.Run;
end.
