unit Scene;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  SpaceObject, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.Layouts,
  FMX.Edit, Quick.Console, Quick.Logger;

type
  TSceneFrame = class(TFrame)
    lblHeading: TLabel;
    Panel: TPanel;
    Grid: TGrid;
    NameColumn: TStringColumn;
    edtName: TEdit;
    btnAddSpaceObject: TButton;

    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure btnAddSpaceObjectClick(Sender: TObject);
    procedure GridCellClick(const Column: TColumn; const Row: Integer);
  public
    procedure Init();
    procedure OnUpdate();

  private
    procedure SetSelectedSpaceObject(const ID: uint32);

  private
    FSelectedSpaceObjectID: uint32;

  public
    property SelectedSpaceObjectID: uint32 read FSelectedSpaceObjectID write SetSelectedSpaceObject;
  end;

implementation

procedure TSceneFrame.Init();
begin
  Grid.RowCount := Length(GSpaceObjects);
  FSelectedSpaceObjectID := 0;
end;

procedure TSceneFrame.OnUpdate();
begin
  Grid.RowCount := Length(GSpaceObjects);
  Grid.BeginUpdate();
  Grid.EndUpdate();
end;

procedure TSceneFrame.SetSelectedSpaceObject(const ID: uint32);
begin
  FSelectedSpaceObjectID := ID;
  var idx: int32 := SpaceObjectIndexFromID(ID);
  Grid.SelectRow(idx);

  Logger.Info('Space Object ' + GSpaceObjects[idx].Name + ' is selected');
end;

procedure TSceneFrame.btnAddSpaceObjectClick(Sender: TObject);
begin
  var SpaceObject: TSpaceObject := TSpaceObject.Create(edtName.Text);
  GSpaceObjects := GSpaceObjects + [SpaceObject];
  Grid.RowCount := Length(GSpaceObjects);
end;

procedure TSceneFrame.GridCellClick(const Column: TColumn; const Row: Integer);
begin
  var ID: uint32 := GSpaceObjects[Row].ID;
  SelectedSpaceObjectID := ID;
end;

procedure TSceneFrame.GridGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
  if ACol = 0 then
  begin
    Value := GSpaceObjects[ARow].Name;
  end;
end;


{$R *.fmx}

end.
