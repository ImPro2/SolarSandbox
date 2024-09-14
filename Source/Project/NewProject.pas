unit NewProject;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  SpaceObject, ProjectInfo, FMX.Edit;

type
  TNewProjectFrame = class(TFrame)
    lblNewProject: TLabel;
    btnNewProject: TButton;
    edtProjectName: TEdit;
    btnPathSelector: TButton;
    lblName: TLabel;
    lblPath: TLabel;
    procedure OnNewProjectClick(Sender: TObject);
    procedure btnPathSelectorClick(Sender: TObject);
  private
    FSavePath: string;
  public
    OnNewProject: TNewProjectEvent;
  end;

implementation

{$R *.fmx}

procedure TNewProjectFrame.btnPathSelectorClick(Sender: TObject);
begin
  var SaveDialog: TSaveDialog := TSaveDialog.Create(Self);
  SaveDialog.InitialDir := 'C:\';

  if SaveDialog.Execute() then
    FSavePath := SaveDialog.FileName;
end;

procedure TNewProjectFrame.OnNewProjectClick(Sender: TObject);
begin
  if Assigned(OnNewProject) then
  begin
    var info: TProjectInfo;

    info.sName := edtProjectName.Text;
    info.sPath := FSavePath;

    OnNewProject(info);
  end;
end;

end.
