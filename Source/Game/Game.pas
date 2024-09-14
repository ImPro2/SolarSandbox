unit Game;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Quick.Logger, Quick.Console, Quick.Logger.Provider.Console, Quick.Logger.Provider.Files,
  FMX.Objects, FMX.Controls.Presentation, FMX.Menus,
  Quick.YAML, Quick.YAML.Serializer,
  ProjectInfo, ProjectSerializer, SpaceObject, Scene, Simulation, Properties, PlayBar;

type
  TGameFrame = class(TFrame)
    MenuBar: TMenuBar;
    miFile: TMenuItem;
    miEdit: TMenuItem;
    miView: TMenuItem;
    miHelp: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    miFileOpen: TMenuItem;
    miFileClose: TMenuItem;
    miEditOptions: TMenuItem;
    miViewSimulation: TMenuItem;
    miViewControlBar: TMenuItem;
    miViewProperties: TMenuItem;
    miHelpAbout: TMenuItem;
    pnlScene: TPanel;
    pnlPlayBar: TPanel;
    pnlSimulation: TPanel;
    miViewScene: TMenuItem;
    pnlLeft: TPanel;
    pnlProperties: TPanel;
    pnlRight: TPanel;
  public
    constructor Create(AOwner: TComponent); override;

  private
    FProjectInfo: TProjectInfo;
    FInitialized: Boolean;
    FStart: Boolean;
    FMainForm: TForm;

    FMouseX, FMouseY: Single;

    FSceneFrame:      TSceneFrame;
    FPropertiesFrame: TPropertiesFrame;
    FPlayBarFrame:    TPlayBarFrame;
    FSimulationFrame: TSimulationFrame;

  private
    procedure OnGameStart();
    procedure OnGameStop();
    procedure OnGamePause();
    procedure OnGameResume();

  public
    procedure Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
    procedure InitFrames();
    procedure InitSpaceObjects();
    procedure Update(fDeltaTime: float32); // in s

    property Initialized: Boolean read FInitialized;
  end;

implementation

constructor TGameFrame.Create(AOwner: TComponent);
begin
  inherited;
  FMainForm                  := TForm(AOwner);
  FInitialized               := False;
  FStart                     := False;

  FSceneFrame                := TSceneFrame.Create(Self);
  FSceneFrame.Parent         := pnlScene;
  FSceneFrame.Visible        := False;

  FPropertiesFrame           := TPropertiesFrame.Create(Self);
  FPropertiesFrame.Parent    := pnlProperties;
  FPropertiesFrame.Visible   := False;

  FPlayBarFrame              := TPlayBarFrame.Create(Self);
  FPlayBarFrame.Parent       := pnlPlayBar;
  FPlayBarFrame.OnGameStart  := Self.OnGameStart;
  FPlayBarFrame.OnGameStop   := Self.OnGameStop;
  FPlayBarFrame.OnGamePause  := Self.OnGamePause;
  FPlayBarFrame.OnGameResume := Self.OnGameResume;
  FPlayBarFrame.Visible      := False;

  FSimulationFrame           := TSimulationFrame.Create(Self);
  FSimulationFrame.Parent    := pnlSimulation;
  FSimulationFrame.Visible   := False;
end;

procedure TGameFrame.Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
begin
  FProjectInfo := ProjectInfo;
  FInitialized := True;

  InitSpaceObjects();
  InitFrames();
end;

procedure TGameFrame.InitSpaceObjects();
begin
  GSpaceObjects := Copy(FProjectInfo.SpaceObjects, 0, Length(FProjectInfo.SpaceObjects));
end;

procedure TGameFrame.InitFrames();
begin
  FSceneFrame.Init();
  FSceneFrame.Visible := True;

  FPropertiesFrame.Visible := True;

  FPlayBarFrame.Init();
  FPlayBarFrame.Visible := True;

  FSimulationFrame.Init();
  FSimulationFrame.Visible := True;
end;

procedure TGameFrame.Update(fDeltaTime: float32);
begin
  FPropertiesFrame.OnUpdate(FSceneFrame.SelectedSpaceObjectID);
  FSimulationFrame.OnUpdate(fDeltaTime);
end;

procedure TGameFrame.OnGameStart();
begin
  Logger.Info('Game Start');
  FSimulationFrame.Simulate := True;
  FProjectInfo.SpaceObjects := Copy(GSpaceObjects, 0, Length(GSpaceObjects));
end;

procedure TGameFrame.OnGameStop();
begin
  Logger.Info('Game Stop');
  GSpaceObjects := Copy(FProjectInfo.SpaceObjects, 0, Length(FProjectInfo.SpaceObjects));
  FSimulationFrame.Simulate := False;
end;

procedure TGameFrame.OnGamePause();
begin
  Logger.Info('Game Pause');
  FSimulationFrame.Simulate := False;
end;

procedure TGameFrame.OnGameResume();
begin
  Logger.Info('Game Resume');
  FSimulationFrame.Simulate := True;
end;

{$R *.fmx}

end.
