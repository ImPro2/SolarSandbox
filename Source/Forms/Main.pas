unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Windows,
  Quick.Logger, Quick.Console, Quick.Logger.Provider.Console, Quick.Logger.Provider.Files,
  ProjectInfo, ProjectSelector, Game;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FLastTime: int64;
    FSecondsPerCount: float32;
    frmProjectSelector: TProjectSelectorFrame;
    frmGame: TGameFrame;

    procedure OnStartGame(const ProjectInfo: TProjectInfo);
    procedure OnUpdate(fDeltaTime: float32); // in s
    procedure OnAppIdle(Sender: TObject; var Done: Boolean);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
var
  iCountPerSecond: int64;
begin
  QueryPerformanceFrequency(iCountPerSecond);
  FSecondsPerCount := 1.0 / float32(iCountPerSecond);
  QueryPerformanceCounter(FLastTime);

  Application.OnIdle := Self.OnAppIdle;

  frmProjectSelector := TProjectSelectorFrame.Create(Self);
  frmProjectSelector.Parent := Self;
  frmProjectSelector.OnStartGame := Self.OnStartGame;
  frmProjectSelector.Init;

  frmGame := TGameFrame.Create(Self);
  frmGame.Parent := Self;
  frmGame.Visible := False;

  Logger.Info('Successfully initialized application.');
end;

procedure TMainForm.OnStartGame(const ProjectInfo: TProjectInfo);
begin
  //Self.WindowState := TWindowState.wsMaximized;
  frmProjectSelector.Visible := False;
  frmGame.Visible := True;
  frmGame.Init(ProjectInfo, False);
end;

procedure TMainForm.OnUpdate(fDeltaTime: float32);
begin
  if frmGame.Initialized then
  begin
    frmGame.Update(fDeltaTime);
  end;
end;

procedure TMainForm.OnAppIdle(Sender: TObject; var Done: Boolean);
var
  iCurrentTime, iElapsedTime: int64;
  fDeltaTime: float64;
begin
  Done := False;

  QueryPerformanceCounter(iCurrentTime);
  fDeltaTime := float64(iCurrentTime - FLastTime) * FSecondsPerCount;

  Self.OnUpdate(fDeltaTime);

  FLastTime := iCurrentTime;
end;

end.
