unit Game;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Quick.Logger, Quick.Console, Quick.Logger.Provider.Console, Quick.Logger.Provider.Files,
  FMX.Objects, FMX.Controls.Presentation, FMX.Menus, Windows,
  Quick.YAML, Quick.YAML.Serializer,
  ProjectInfo, SpaceObject, Scene, Simulation, Properties, PlayBar, WindowsFunctions;

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
    procedure miFileSaveClick(Sender: TObject);
    procedure miFileSaveAsClick(Sender: TObject);
    procedure miFileOpenClick(Sender: TObject);
    procedure miFileCloseClick(Sender: TObject);
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
    // Game events
    procedure OnGameStart();
    procedure OnGameStop();
    procedure OnGamePause();
    procedure OnGameResume();
    procedure OnPlaybackSpeedChange(PlaybackSpeed: float32);
    procedure OnViewGrid();
    procedure OnHideGrid();
    procedure OnViewOrbitTrajectory();
    procedure OnHideOrbitTrajectory();
    procedure OnSimulationSpaceObjectSelected(ID: uint32);

  public
    // Init and update
    procedure Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
    procedure Update(fDeltaTime: float32); // in s
    procedure OnKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

  private
    procedure InitFrames();
    procedure InitSpaceObjects();

    // Menubar impl
    procedure SaveProject();
    procedure SaveProjectAs();
    procedure OpenProject();

  public
    property Initialized: Boolean read FInitialized;
  end;

implementation

{$Region Initialization and Update}

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
  FPlayBarFrame.OnPlaybackSpeedChange := Self.OnPlaybackSpeedChange;
  FPlayBarFrame.OnViewGrid := Self.OnViewGrid;
  FPlayBarFrame.OnHideGrid := Self.OnHideGrid;
  FPlayBarFrame.OnViewOrbitTrajectory := Self.OnViewOrbitTrajectory;
  FPlayBarFrame.OnHideOrbitTrajectory := Self.OnHideOrbitTrajectory;
  FPlayBarFrame.Visible      := False;

  FSimulationFrame           := TSimulationFrame.Create(Self);
  FSimulationFrame.Parent    := pnlSimulation;
  FSimulationFrame.Visible   := False;
  FSimulationFrame.OnSpaceObjectSelected := Self.OnSimulationSpaceObjectSelected;
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
  FSceneFrame.OnUpdate();
  FPropertiesFrame.OnUpdate(FSceneFrame.SelectedSpaceObjectID);
  FSimulationFrame.OnUpdate(fDeltaTime);
end;

procedure TGameFrame.OnKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case KeyChar of
    'f': FSimulationFrame.Focused := not FSimulationFrame.Focused;
  end;
end;

{$EndRegion}

{$Region Game Events}

procedure TGameFrame.OnGameStart();
begin
  FPropertiesFrame.OnGameStartOrResume();
  FSimulationFrame.Simulate := True;
  FProjectInfo.SpaceObjects := Copy(GSpaceObjects, 0, Length(GSpaceObjects));
end;

procedure TGameFrame.OnGameStop();
begin
  FPropertiesFrame.OnGameStopOrPause();
  GSpaceObjects := Copy(FProjectInfo.SpaceObjects, 0, Length(FProjectInfo.SpaceObjects));
  FSimulationFrame.Simulate := False;
end;

procedure TGameFrame.OnGamePause();
begin
  FPropertiesFrame.OnGameStopOrPause();
  FSimulationFrame.Simulate := False;
end;

procedure TGameFrame.OnGameResume();
begin
  FPropertiesFrame.OnGameStartOrResume();
  FSimulationFrame.Simulate := True;
end;

procedure TGameFrame.OnPlaybackSpeedChange(PlaybackSpeed: float32);
begin
  FSimulationFrame.PlaybackSpeed := PlaybackSpeed;
end;

procedure TGameFrame.OnViewGrid();
begin
  FSimulationFrame.ViewGrid := True;
end;

procedure TGameFrame.OnHideGrid();
begin
  FSimulationFrame.ViewGrid := False;
end;

procedure TGameFrame.OnViewOrbitTrajectory();
begin
  FSimulationFrame.ViewOrbitTrajectory := True;
end;

procedure TGameFrame.OnHideOrbitTrajectory();
begin
  FSimulationFrame.ViewOrbitTrajectory := False;
end;

procedure TGameFrame.OnSimulationSpaceObjectSelected(ID: uint32);
begin
  FSceneFrame.SelectedSpaceObjectID := ID;
  FSimulationFrame.SelectedSpaceObjectID := ID;
end;

{$EndRegion Game Events}

{$Region Menubar Functions}

procedure TGameFrame.SaveProject();
begin
  FProjectInfo.SpaceObjects := Copy(GSpaceObjects, 0, Length(GSpaceObjects));
  FSimulationFrame.GenerateThumbnail(FProjectInfo.ThumbnailPath);

  SerializeProject(FProjectInfo);
end;

procedure TGameFrame.SaveProjectAs();
begin
  var SaveDialog: TSaveDialog := TSaveDialog.Create(Self);

  SaveDialog.InitialDir := '.';

  if SaveDialog.Execute() then
  begin
    FProjectInfo.sPath := System.IOUtils.TPath.GetFullPath(SaveDialog.FileName);

    var FileName: string := System.IOUtils.TPath.GetFileNameWithoutExtension(SaveDialog.FileName);
    FProjectInfo.ThumbnailPath := FileName + '.bmp';

    SaveProject();
  end;
end;

procedure TGameFrame.OpenProject();
begin
  var OpenDialog: TOpenDialog := TOpenDialog.Create(Self);

  OpenDialog.Options := [TOpenOption.ofPathMustExist];

  if OpenDialog.Execute() then
    FProjectInfo.sPath := OpenDialog.FileName;

  SetLength(FProjectInfo.SpaceObjects, 0);
  DeserializeProject(FProjectInfo);

  GSpaceObjects := Copy(FProjectInfo.SpaceObjects, 0, Length(FProjectInfo.SpaceObjects));
end;

{$EndRegion}

{$Region Events}

procedure TGameFrame.miFileCloseClick(Sender: TObject);
begin
  FMainForm.Close();
end;

procedure TGameFrame.miFileOpenClick(Sender: TObject);
begin
  OpenProject();
end;

procedure TGameFrame.miFileSaveAsClick(Sender: TObject);
begin
  SaveProjectAs();
end;

procedure TGameFrame.miFileSaveClick(Sender: TObject);
begin
  SaveProject();
end;

{$EndRegion}

{$R *.fmx}

end.
