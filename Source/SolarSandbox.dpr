program SolarSandbox;

uses
  System.StartUpCopy,
  FMX.Forms,
  Windows,
  Quick.Console,
  Quick.Logger,
  Quick.Logger.Provider.Console,
  Quick.Logger.Provider.Files,
  Main in 'Forms\Main.pas' {MainForm},
  NewProject in 'Project\NewProject.pas' {NewProjectFrame: TFrame},
  OpenProject in 'Project\OpenProject.pas' {OpenProjectFrame: TFrame},
  ProjectInfo in 'Project\ProjectInfo.pas',
  ProjectSelector in 'Project\ProjectSelector.pas' {ProjectSelectorFrame: TFrame},
  Game in 'Game\Game.pas' {GameFrame: TFrame},
  PlayBar in 'Game\PlayBar.pas' {PlayBarFrame: TFrame},
  Properties in 'Game\Properties.pas' {PropertiesFrame: TFrame},
  Scene in 'Game\Scene.pas' {SceneFrame: TFrame},
  Simulation in 'Game\Simulation.pas' {SimulationFrame: TFrame},
  SpaceObject in 'Game\SpaceObject.pas',
  Neslib.LibYaml in '..\Dependencies\Neslib.Yaml\Neslib.LibYaml.pas',
  Neslib.Yaml in '..\Dependencies\Neslib.Yaml\Neslib.Yaml.pas',
  Neslib.Collections in '..\Dependencies\Neslib.Yaml\Neslib\Neslib.Collections.pas',
  Neslib.Hash in '..\Dependencies\Neslib.Yaml\Neslib\Neslib.Hash.pas',
  Neslib.System in '..\Dependencies\Neslib.Yaml\Neslib\Neslib.System.pas',
  Neslib.SysUtils in '..\Dependencies\Neslib.Yaml\Neslib\Neslib.SysUtils.pas',
  Neslib.Utf8 in '..\Dependencies\Neslib.Yaml\Neslib\Neslib.Utf8.pas',
  ProjectTemplateItem in 'Project\ProjectTemplateItem.pas' {ProjectTemplateItemFrame: TFrame};

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
    FileName        := '.\Logs\Log.log';
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
