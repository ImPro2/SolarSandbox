program SolarSandbox;

uses
  System.StartUpCopy,
  FMX.Forms,
  Windows,
  Quick.Console,
  Quick.Logger,
  Quick.Logger.Provider.Console,
  Quick.Logger.Provider.Files,
  NewProject in 'Source\Project\NewProject.pas' {NewProjectFrame: TFrame},
  OpenProject in 'Source\Project\OpenProject.pas' {OpenProjectFrame: TFrame},
  ProjectInfo in 'Source\Project\ProjectInfo.pas',
  ProjectSelector in 'Source\Project\ProjectSelector.pas' {ProjectSelectorFrame: TFrame},
  ProjectSerializer in 'Source\Project\ProjectSerializer.pas',
  Game in 'Source\Game\Game.pas' {GameFrame: TFrame},
  Scene in 'Source\Game\Scene.pas' {SceneFrame: TFrame},
  Simulation in 'Source\Game\Simulation.pas' {SimulationFrame: TFrame},
  SpaceObject in 'Source\Game\SpaceObject.pas',
  Main in 'Source\Forms\Main.pas' {MainForm},
  Properties in 'Source\Game\Properties.pas' {PropertiesFrame: TFrame},
  PlayBar in 'Source\Game\PlayBar.pas' {PlayBarFrame: TFrame};

{$R *.res}

procedure InitializeLogging();
begin
  Logger.Providers.Add(GlobalLogConsoleProvider);
  with GlobalLogConsoleProvider do
  begin
    LogLevel                  := LOG_VERBOSE;
    ShowEventColors           := True;
    EventTypeColor[etInfo]    := ccLightGreen;
    EventTypeColor[etWarning] := ccYellow;
    EventTypeColor[etTrace]   := ccWhite;
    ShowTimeStamp             := True;
    TimePrecission            := True;
    ShowEventType             := True;
    Enabled                   := True;
    IncludedInfo              := [iiAppName];
  end;

  Logger.Providers.Add(GlobalLogFileProvider);
  with GlobalLogFileProvider do
  begin
    FileName        := '.\Log.log';
    ShowHeaderInfo  := True;
    LogLevel        := LOG_VERBOSE;
    TimePrecission  := True;
    MaxRotateFiles  := 1;
    MaxFileSizeInMB := 1024;
    ShowEventType   := True;
    Enabled         := True;
    IncludedInfo    := [iiAppName];
  end;

  Logger.RedirectOwnErrorsToProvider := GlobalLogConsoleProvider;

  Log('SolarSandbox Log File', etHeader);
end;

begin
  Application.Initialize;
  InitializeLogging();
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
