unit OpenProject;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  ProjectInfo, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, FMX.Edit;

type
  TOpenProjectFrame = class(TFrame)
    RecentProjectsGrid: TGrid;
    lblRecent: TLabel;
    edtSearch: TEdit;
    btnSearch: TButton;
    colProjectNames: TStringColumn;
    colProjectPaths: TStringColumn;
    btnOpenProject: TButton;
    colThumbnails: TImageColumn;
    procedure btnOpenProjectClick(Sender: TObject);
    procedure RecentProjectsGridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure RecentProjectsGridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure RecentProjectsGridResize(Sender: TObject);
  public
    OnOpenProject: TOpenProjectEvent;

    procedure Init(ProjectDirectory: string);
  private
    FProjectList: TProjectInfoList;
  end;

implementation

{$R *.fmx}

procedure TOpenProjectFrame.Init(ProjectDirectory: string);
begin
  FProjectList := LoadProjectsFromDirectory(ProjectDirectory);
  RecentProjectsGrid.RowCount := Length(FProjectList);
end;

procedure TOpenProjectFrame.btnOpenProjectClick(Sender: TObject);
begin
  var OpenDialog: TOpenDialog := TOpenDialog.Create(Self);
  OpenDialog.InitialDir	:= '.';

  if OpenDialog.Execute() then
  begin
    var ProjectInfo: TProjectInfo;
    ProjectInfo.sPath := OpenDialog.FileName;

    DeserializeProject(ProjectInfo);

    if Assigned(OnOpenProject) then
        OnOpenProject(ProjectInfo);
  end;
end;

procedure TOpenProjectFrame.RecentProjectsGridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  if ARow > (Length(FProjectList) - 1) then
  begin
    Value := '';
    Exit;
  end;

  case ACol of
    0: Value := TBitmap.CreateFromFile(FProjectList[ARow].ThumbnailPath);
    1: Value := FProjectList[ARow].sName;
    2: Value := TPath.GetFullPath(FProjectList[ARow].sPath);
  end;
end;

procedure TOpenProjectFrame.RecentProjectsGridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  if Row > (Length(FProjectList) - 1) then
    Exit;

  if Assigned(OnOpenProject) then
    OnOpenProject(FProjectList[Row]);
end;

procedure TOpenProjectFrame.RecentProjectsGridResize(Sender: TObject);
begin
  colProjectPaths.Width := RecentProjectsGrid.Width - colThumbnails.Width - colProjectNames.Width - 6;
end;

end.
