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
    constructor Create(AOwner: TComponent); override;

    procedure Init();

  public
    OnAddSpaceObject: TAddSpaceObjectEvent;
    OnRemoveSpaceObject: TRemoveSpaceObjectEvent;
    OnSpaceObjectSelected: TSpaceObjectSelectedEvent;

    procedure OnSpaceObjectsChange();

  private
    procedure SetSelectedSpaceObject(const Index: int32);

  private
    FGameFrame: TFrame;
    FSelectedSpaceObject: int32;

  public
    property SelectedSpaceObject: int32 read FSelectedSpaceObject write SetSelectedSpaceObject;
  end;

implementation

constructor TSceneFrame.Create(AOwner: TComponent);
begin
  inherited;
  FGameFrame := TFrame(AOwner);
end;

procedure TSceneFrame.Init();
begin
  Grid.RowCount := Length(GSpaceObjects);
end;

procedure TSceneFrame.OnSpaceObjectsChange();
begin
  Grid.RowCount := Length(GSpaceObjects);
end;

procedure TSceneFrame.SetSelectedSpaceObject(const Index: int32);
begin
  FSelectedSpaceObject := Index;
  Grid.SelectRow(Index);

  Logger.Info('Space Object ' + GSpaceObjects[FSelectedSpaceObject].Name + ' is selected');
end;

procedure TSceneFrame.btnAddSpaceObjectClick(Sender: TObject);
begin
  if Assigned(OnAddSpaceObject) then
  begin
    var SpaceObject: TSpaceObject := TSpaceObject.Create(edtName.Text);

    OnAddSpaceObject(SpaceObject);
  end;

end;

procedure TSceneFrame.GridCellClick(const Column: TColumn; const Row: Integer);
begin
  SelectedSpaceObject := Row;
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
