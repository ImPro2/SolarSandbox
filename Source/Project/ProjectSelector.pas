unit ProjectSelector;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.Controls.Presentation,
  ProjectInfo, NewProject, OpenProject;

type
  TStartGameEvent = procedure(const ProjectInfo: TProjectInfo) of object;

  TProjectSelectorFrame = class(TFrame)
    TabControl: TTabControl;
    tiOpenProject: TTabItem;
    tiNewProject: TTabItem;
  private
    frmOpenProject: TOpenProjectFrame;
    frmNewProject:  TNewProjectFrame;

    procedure OnNewProject(Info: TProjectInfo);
    procedure OnOpenProject(Info: TProjectInfo);
  public
    OnStartGame: TStartGameEvent;

    procedure Init(ProjectDirectory: string; TemplateDirectory: string);
  end;

implementation

{$R *.fmx}

procedure TProjectSelectorFrame.Init(ProjectDirectory: string; TemplateDirectory: string);
begin
  frmOpenProject := TOpenProjectFrame.Create(Self);
  frmOpenProject.Parent := tiOpenProject;
  frmOpenProject.OnOpenProject := Self.OnOpenProject;
  frmOpenProject.Init(ProjectDirectory);

  frmNewProject := TNewProjectFrame.Create(Self);
  frmNewProject.Parent := tiNewProject;
  frmNewProject.OnNewProject := Self.OnNewProject;
  frmNewProject.Init(TemplateDirectory);
end;

procedure TProjectSelectorFrame.OnNewProject(Info: TProjectInfo);
begin
  if Assigned(OnStartGame) then
    OnStartGame(Info);
end;

procedure TProjectSelectorFrame.OnOpenProject(Info: TProjectInfo);
begin
  if Assigned(OnStartGame) then
    OnStartGame(Info);
end;

end.
