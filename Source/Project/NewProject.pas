unit NewProject;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  ProjectInfo, FMX.Edit;

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
    with info do
    begin
      sName := edtProjectName.Text;
      sPath := '';
    end;
    OnNewProject(info);
  end;
end;

end.
