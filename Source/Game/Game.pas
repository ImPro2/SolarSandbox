unit Game;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Quick.Logger, Quick.Console, Quick.Logger.Provider.Console, Quick.Logger.Provider.Files,
  FMX.Objects, FMX.Controls.Presentation, FMX.Menus, Windows,
  Quick.YAML, Quick.YAML.Serializer,
  ProjectInfo, SpaceObject, Scene, Simulation, Properties, PlayBar;

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
    procedure OnGameStart();
    procedure OnGameStop();
    procedure OnGamePause();
    procedure OnGameResume();

  public
    procedure Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
    procedure InitFrames();
    procedure InitSpaceObjects();
    procedure Update(fDeltaTime: float32); // in s

    procedure SaveProject();
    procedure SaveProjectAs();
    procedure OpenProject();

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
  FSceneFrame.OnUpdate();
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

{$R *.fmx}

end.
