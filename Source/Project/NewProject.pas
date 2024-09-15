unit NewProject;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  SpaceObject, ProjectInfo, FMX.Edit, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, FMX.Layouts,
  Quick.Logger, ProjectTemplateItem;

type
  TNewProjectFrame = class(TFrame)
    btnNewProject: TButton;
    lblTemplate: TLabel;
    TemplatesGridPanel: TGridPanelLayout;
    pnlBottom: TPanel;
    lblTemplateInfo: TLabel;
    lblInfo: TLabel;
    procedure OnNewProjectClick(Sender: TObject);
    procedure btnPathSelectorClick(Sender: TObject);
  public
    OnNewProject: TNewProjectEvent;

    procedure Init(TemplateDirectory: string);
  private
    FSavePath: string;
    FTemplatesDirectory: string;
    FSelectedTemplate: TProjectInfo;

    const
      CColumnCount = 3;
      CRowCount    = 3;

    procedure InitializeTemplatesGridPanel(Templates: TProjectInfoList);
    procedure OnTemplateSelected(ProjectInfo: TProjectInfo);
    procedure OnTemplateOpened(ProjectInfo: TProjectInfo);
  end;

implementation

{$R *.fmx}

procedure TNewProjectFrame.Init(TemplateDirectory: string);
begin
  var Templates: TProjectInfoList := LoadProjectsFromDirectory(TemplateDirectory);

  InitializeTemplatesGridPanel(Templates);
end;

procedure TNewProjectFrame.InitializeTemplatesGridPanel(Templates: TProjectInfoList);
begin
  TemplatesGridPanel.RowCollection.BeginUpdate();
  TemplatesGridPanel.ColumnCollection.BeginUpdate();

  TemplatesGridPanel.RowCollection.Clear();
  TemplatesGridPanel.ColumnCollection.Clear();

  for var i := 1 to CRowCount do
  begin
    var RowItem       := TemplatesGridPanel.RowCollection.Add();
    RowItem.SizeStyle := TGridPanelLayout.TSizeStyle.Percent;
    RowItem.Value     := 100 / CRowCount;
  end;

  for var i := 1 to CColumnCount do
  begin
    var ColumnItem       := TemplatesGridPanel.ColumnCollection.Add();
    ColumnItem.SizeStyle := TGridPanelLayout.TSizeStyle.Percent;
    ColumnItem.Value     := 100 / CColumnCount;
  end;

  for var i := 0 to CRowCount * CColumnCount - 1 do
  begin
    if i > Length(Templates) - 1 then
      continue;

    var TemplateItemFrame: TProjectTemplateItemFrame := TProjectTemplateItemFrame.Create(Self);

    TemplateItemFrame.Name          := 'TemplateItem' + i.ToString();
    TemplateItemFrame.Parent        := TemplatesGridPanel;
    TemplateItemFrame.Visible       := True;
    TemplateItemFrame.Align         := TAlignLayout.Client;
    TemplateItemFrame.SelectedEvent := Self.OnTemplateSelected;
    TemplateItemFrame.OpenedEvent   := Self.OnTemplateOpened;
    TemplateItemFrame.Init(Templates[i]);

    if Templates[i].sName = 'Blank' then
    begin
      TemplateItemFrame.Button.Pressed := True;
      FSelectedTemplate := Templates[i];
    end;
  end;

  TemplatesGridPanel.RowCollection.EndUpdate();
  TemplatesGridPanel.ColumnCollection.EndUpdate();
end;

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
    FSelectedTemplate.sPath := '';
    FSelectedTemplate.sName := '';
    OnNewProject(FSelectedTemplate);
  end;
end;

procedure TNewProjectFrame.OnTemplateSelected(ProjectInfo: TProjectInfo);
begin
  FSelectedTemplate := ProjectInfo;
  lblTemplateInfo.Text := ProjectInfo.Notes;
end;

procedure TNewProjectFrame.OnTemplateOpened(ProjectInfo: TProjectInfo);
begin
  if Assigned(OnNewProject) then
    OnNewProject(ProjectInfo);
end;

end.
