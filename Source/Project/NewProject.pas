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
  private
    { Private declarations }
  public
    OnNewProject: TNewProjectEvent;
  end;

implementation

{$R *.fmx}

procedure TNewProjectFrame.OnNewProjectClick(Sender: TObject);
begin
  if Assigned(OnNewProject) then
  begin
    var info: TProjectInfo;

    info.sName := edtProjectName.Text;
    info.sPath := '';

    SetLength(info.SpaceObjects, 2);
    info.SpaceObjects[0] := TSpaceObject.Create('Earth');
    info.SpaceObjects[0].Mass := 100;

    info.SpaceObjects[1] := TSpaceObject.Create('Moon');
    info.SpaceObjects[1].PositionY := 10.0;
    info.SpaceObjects[1].Mass := 10;

    OnNewProject(info);
  end;
end;

end.
