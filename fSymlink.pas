unit fSymlink;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.IOUtils, System.Win.ComObj, Vcl.FileCtrl;

type
  TLang = (lgRU, lgEN);

  Tmain = class(TForm)
    btnDoIt: TButton;
    targ: TLabel;
    Link: TLabel;
    s: TEdit;
    t: TEdit;
    btnPthLink: TButton;
    btnPthSource: TButton;
    rbEN: TRadioButton;
    rbRU: TRadioButton;
    procedure btnDoItClick(Sender: TObject);
    procedure btnPthSourceClick(Sender: TObject);
    procedure btnPthLinkClick(Sender: TObject);
    procedure rbRUClick(Sender: TObject);
    procedure rbENClick(Sender: TObject);
  private
    FCurrentLang: TLang;
    procedure UpdateUI;
    function Lng(const RU, EN: string): string;
  public
  end;

const
  SYMLINK_FLAG_DIRECTORY = $1;

var
  main: Tmain;

implementation

{$R *.dfm}

type
  TTaskDialogAccess = class(TTaskDialog);

function Tmain.Lng(const RU, EN: string): string;
begin
  if FCurrentLang = lgRU then Result := RU else Result := EN;
end;

function GetStr(ID: string; Lang: TLang): string;
begin
  if Lang = lgRU then
  begin
    if ID = 'CAPTION' then Result := 'Выбор объекта';
    if ID = 'TITLE' then Result := 'Что вы хотите выбрать?';
    if ID = 'FILE' then Result := 'Файл';
    if ID = 'FOLDER' then Result := 'Папка / Диск';
    if ID = 'ERR_EMPTY' then Result := 'Пути не могут быть пустыми';
    if ID = 'SUCCESS' then Result := 'Успешно создано!';
    if ID = 'LBL_TARGET' then Result := 'Цель (существующая папка/файл):';
    if ID = 'LBL_LINK' then Result := 'Путь к новой ссылке (где создать и имя):';
    if ID = 'DLG_SAVE_TITLE' then Result := 'Где создать ссылку?';
    if ID = 'DLG_OPEN_TITLE' then Result := 'Выберите исходный файл';
    if ID = 'ERR_NOT_FOUND' then Result := 'Целевой объект не найден: ';
    if ID = 'ERR_OCCUPIED' then Result := 'Путь занят реальным объектом (не ссылкой)';
    if ID = 'ERR_PRIVILEGE' then Result := 'Нужны права администратора или "Режим разработчика" Windows';
    if ID = 'ERR_WIN32' then Result := 'Ошибка Win32. Код: ';
  end
  else
  begin
    if ID = 'CAPTION' then Result := 'Object Selection';
    if ID = 'TITLE' then Result := 'What do you want to select?';
    if ID = 'FILE' then Result := 'File';
    if ID = 'FOLDER' then Result := 'Folder / Drive';
    if ID = 'ERR_EMPTY' then Result := 'Paths cannot be empty';
    if ID = 'SUCCESS' then Result := 'Successfully created!';
    if ID = 'LBL_TARGET' then Result := 'Target (existing folder/file):';
    if ID = 'LBL_LINK' then Result := 'Path for new symlink (location and name):';
    if ID = 'DLG_SAVE_TITLE' then Result := 'Where to create the link?';
    if ID = 'DLG_OPEN_TITLE' then Result := 'Select source file';
    if ID = 'ERR_NOT_FOUND' then Result := 'Target object not found: ';
    if ID = 'ERR_OCCUPIED' then Result := 'Path is occupied by a real object (not a link)';
    if ID = 'ERR_PRIVILEGE' then Result := 'Admin rights or Windows Developer Mode required';
    if ID = 'ERR_WIN32' then Result := 'Win32 Error. Code: ';
  end;
end;

procedure Tmain.UpdateUI;
begin
  targ.Caption := GetStr('LBL_TARGET', FCurrentLang);
  Link.Caption := GetStr('LBL_LINK', FCurrentLang);
  btnDoIt.Caption := Lng('Создать символическую ссылку', 'Create SymLink');
  btnPthLink.Caption := Lng('Обзор...', 'Browse...');
  btnPthSource.Caption := Lng('Обзор...', 'Browse...');
  Self.Caption := Lng('Мастер создания сим-линк от ///LisEd', 'SymLink Creator Master by ///LisEd');
end;

function CustomSelectPath(var SelectedPath: string; Lang: TLang): Boolean;
var
  TaskDlg: TTaskDialog;
  OpenDlg: TOpenDialog;
  Dir: string;
begin
  Result := False;
  TaskDlg := TTaskDialog.Create(nil);
  try
    TaskDlg.Caption := GetStr('CAPTION', Lang);
    TaskDlg.Title := GetStr('TITLE', Lang);
    with TaskDlg.RadioButtons.Add do Caption := GetStr('FILE', Lang);
    with TaskDlg.RadioButtons.Add do Caption := GetStr('FOLDER', Lang);
    TaskDlg.CommonButtons := [tcbOk, tcbCancel];
    if TaskDlg.Execute and (TaskDlg.ModalResult = mrOk) then
    begin
      if TaskDlg.RadioButton.Index = 0 then
      begin
        OpenDlg := TOpenDialog.Create(nil);
        try
          OpenDlg.Title := GetStr('DLG_OPEN_TITLE', Lang);
          if OpenDlg.Execute then begin SelectedPath := OpenDlg.FileName; Result := True; end;
        finally OpenDlg.Free; end;
      end
      else
        if SelectDirectory(GetStr('FOLDER', Lang), '', Dir) then begin SelectedPath := Dir; Result := True; end;
    end;
  finally TaskDlg.Free; end;
end;

function CreateSymbolicLinkW(lpSymlinkFileName, lpTargetFileName: PWideChar; dwFlags: DWORD): BOOL; stdcall;
  external 'kernel32.dll' name 'CreateSymbolicLinkW';

function IsReparsePoint(const Path: string): Boolean;
var Attr: DWORD;
begin
  Attr := GetFileAttributesW(PWideChar(Path));
  Result := (Attr <> INVALID_FILE_ATTRIBUTES) and (Attr and FILE_ATTRIBUTE_REPARSE_POINT <> 0);
end;

procedure CreateSymlink(const SymlinkPath, TargetPath: string; Lang: TLang);
var
  Flags: DWORD;
  LastError: DWORD;
  IsDirectory: Boolean;
begin
  if System.IOUtils.TDirectory.Exists(TargetPath) then IsDirectory := True
  else if System.IOUtils.TFile.Exists(TargetPath) then IsDirectory := False
  else raise Exception.Create(GetStr('ERR_NOT_FOUND', Lang) + TargetPath);

  if System.IOUtils.TFile.Exists(SymlinkPath) or System.IOUtils.TDirectory.Exists(SymlinkPath) then
  begin
    if IsReparsePoint(SymlinkPath) then
    begin
      {$WARN SYMBOL_PLATFORM OFF}
      if System.SysUtils.DirectoryExists(SymlinkPath) then Win32Check(RemoveDir(SymlinkPath))
      else Win32Check(DeleteFile(PWideChar(SymlinkPath)));
      {$WARN SYMBOL_PLATFORM ON}
    end
    else raise Exception.Create(GetStr('ERR_OCCUPIED', Lang));
  end;

  if IsDirectory then Flags := SYMLINK_FLAG_DIRECTORY else Flags := 0;

  if not CreateSymbolicLinkW(PWideChar(SymlinkPath), PWideChar(TargetPath), Flags) then
  begin
    LastError := GetLastError;
    if LastError = ERROR_PRIVILEGE_NOT_HELD then raise Exception.Create(GetStr('ERR_PRIVILEGE', Lang))
    else raise Exception.Create(GetStr('ERR_WIN32', Lang) + IntToStr(LastError));
  end;
end;

procedure Tmain.btnDoItClick(Sender: TObject);
begin
  try
    if (s.Text = '') or (t.Text = '') then raise Exception.Create(GetStr('ERR_EMPTY', FCurrentLang));
    CreateSymlink(s.Text, t.Text, FCurrentLang);
    ShowMessage(GetStr('SUCCESS', FCurrentLang));
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure Tmain.btnPthSourceClick(Sender: TObject);
var Path: string;
begin
  if CustomSelectPath(Path, FCurrentLang) then t.Text := Path;
end;

procedure Tmain.btnPthLinkClick(Sender: TObject);
var SaveDlg: TSaveDialog;
begin
  SaveDlg := TSaveDialog.Create(nil);
  try
    SaveDlg.Title := GetStr('DLG_SAVE_TITLE', FCurrentLang);
    if SaveDlg.Execute then s.Text := SaveDlg.FileName;
  finally SaveDlg.Free; end;
end;

procedure Tmain.rbENClick(Sender: TObject);
begin
  if rbEN.Checked then FCurrentLang := lgEn;
  UpdateUI;
end;

procedure Tmain.rbRUClick(Sender: TObject);
begin
  if rbRU.Checked then FCurrentLang := lgRU;
  UpdateUI;
end;

end.

