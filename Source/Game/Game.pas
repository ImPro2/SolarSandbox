unit Game;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Quick.Logger, Quick.Console, Quick.Logger.Provider.Console, Quick.Logger.Provider.Files,
  FMX.Objects, FMX.Controls.Presentation, FMX.Menus,
  Quick.YAML, Quick.YAML.Serializer,
  ProjectInfo, ProjectSerializer, SpaceObject, Scene, Simulation, Properties;

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
    pnlControlBar: TPanel;
    pnlSimulation: TPanel;
    miViewScene: TMenuItem;
    pnlLeft: TPanel;
    pnlProperties: TPanel;
    pnlRight: TPanel;
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  public
    constructor Create(AOwner: TComponent); override;
  private
    procedure OnAddSpaceObject(SpaceObject: TSpaceObject);
    procedure OnRemoveSpaceObject(SpaceObject: TSpaceObject);

    procedure OnSpaceObjectSelected(SpaceObject: TSpaceObject);
    procedure OnSpaceObjectChanged(SpaceObject: TSpaceObject);
  private
    FProjectInfo: TProjectInfo;
    FInitialized: Boolean;
    FStart: Boolean;
    FMainForm: TForm;

    FMouseX, FMouseY: Single;

    FSceneFrame: TSceneFrame;
    FPropertiesFrame: TPropertiesFrame;
    FSimulationFrame: TSimulationFrame;
  public
    procedure Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
    procedure Update(fDeltaTime: float32); // in s

    property Initialized: Boolean read FInitialized;
  end;

implementation

constructor TGameFrame.Create(AOwner: TComponent);
begin
  inherited;
  FMainForm := TForm(AOwner);
  FInitialized := False;
  FStart := False;

  FSceneFrame := TSceneFrame.Create(Self);
  FSceneFrame.OnAddSpaceObject := Self.OnAddSpaceObject;
  FSceneFrame.OnRemoveSpaceObject := Self.OnRemoveSpaceObject;
  FSceneFrame.OnSpaceObjectSelected := Self.OnSpaceObjectSelected;
  FSceneFrame.Parent := pnlScene;
  FSceneFrame.Visible := False;

  FPropertiesFrame := TPropertiesFrame.Create(Self);
  FPropertiesFrame.OnSpaceObjectChanged := Self.OnSpaceObjectChanged;
  FPropertiesFrame.Parent := pnlProperties;
  FPropertiesFrame.Visible := False;

  FSimulationFrame := TSimulationFrame.Create(Self);
  FSimulationFrame.Parent := pnlSimulation;
  FSimulationFrame.Visible := False;
end;

procedure TGameFrame.OnAddSpaceObject(SpaceObject: TSpaceObject);
begin
  GSpaceObjects := GSpaceObjects + [SpaceObject];
  FSceneFrame.OnSpaceObjectsChange();
end;

procedure TGameFrame.OnRemoveSpaceObject(SpaceObject: TSpaceObject);
begin
  SetLength(GSpaceObjects, Length(GSpaceObjects) - 1);
  FSceneFrame.OnSpaceObjectsChange();
end;

procedure TGameFrame.OnSpaceObjectSelected(SpaceObject: TSpaceObject);
begin
  FPropertiesFrame.OnSpaceObjectSelected(SpaceObject);
end;

procedure TGameFrame.OnSpaceObjectChanged(SpaceObject: TSpaceObject);
begin
  for var i := 0 to Length(GSpaceObjects) - 1 do
  begin
    if GSpaceObjects[i].ID = SpaceObject.ID then
    begin
      GSpaceObjects[i] := SpaceObject;
    end;
  end;

  FSceneFrame.OnSpaceObjectsChange();
end;

procedure TGameFrame.FrameMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (X < pnlLeft.Width) and (Y = pnlScene.Height) then
  begin
    Logger.Trace('wee XY: ' + X.ToString() + ', ' + Y.ToString());
  end else
  begin
    Logger.Trace('XY: ' + X.ToString() + ', ' + Y.ToString());
  end;
end;

procedure TGameFrame.Init(const ProjectInfo: TProjectInfo; NewProject: Boolean);
begin
  FProjectInfo := ProjectInfo;
  FInitialized := True;

  SetLength(GSpaceObjects, 3);
  GSpaceObjects[0] := TSpaceObject.Create('Sun');
  GSpaceObjects[1] := TSpaceObject.Create('Earth');
  GSpaceObjects[2] := TSpaceObject.Create('Moon');

  FSceneFrame.Init();
  FSceneFrame.Visible := True;
  FPropertiesFrame.Visible := True;
  FSimulationFrame.Visible := True;
end;

procedure TGameFrame.Update(fDeltaTime: float32);
begin
  var sFPS: string := FloatToStrF(1.0 / (1000.0 * fDeltaTime), ffGeneral, 9, 9);
  Logger.Trace('FPS: ' + sFPS);
end;

{$R *.fmx}

end.
