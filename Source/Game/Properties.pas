unit Properties;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.SpinBox,
  SpaceObject, FMX.NumberBox;

type
  TPropertiesFrame = class(TFrame)
    lblHeading: TLabel;
    Panel: TPanel;
    lblName: TLabel;
    lblMass: TLabel;
    edtName: TEdit;
    spnMass: TSpinBox;
    lblID: TLabel;
    lblIDText: TLabel;
    lblPosition: TLabel;
    lblVelocity: TLabel;
    nbPositionX: TNumberBox;
    pnlPosition: TPanel;
    pnlVelocity: TPanel;
    nbPositionY: TNumberBox;
    lblPositionX: TLabel;
    lblPositionY: TLabel;
    lblVelocityX: TLabel;
    nbVelocityX: TNumberBox;
    lblVelocityY: TLabel;
    nbVelocityY: TNumberBox;
    procedure edtNameChange(Sender: TObject);
    procedure spnMassChange(Sender: TObject);
    procedure nbPositionXChange(Sender: TObject);
    procedure nbPositionYChange(Sender: TObject);
    procedure nbVelocityXChange(Sender: TObject);
    procedure nbVelocityYChange(Sender: TObject);
  private
    FSpaceObjectID: uint32;

    procedure EnableOrDisableComponents(Enabled: boolean);
  public
    procedure OnUpdate(SelectedSpaceObjectID: uint32);
  end;

implementation

procedure TPropertiesFrame.OnUpdate(SelectedSpaceObjectID: uint32);
begin
  FSpaceObjectID := SelectedSpaceObjectID;

  if FSpaceObjectID = 0 then
  begin
    EnableOrDisableComponents(False);
  end else
  begin
    EnableOrDisableComponents(True);

    var spaceObj: TSpaceObject := SpaceObjectFromID(FSpaceObjectID);

    lblIDText.Text    := spaceObj.ID.ToString();
    edtName.Text      := spaceObj.Name;
    spnMass.Value     := spaceObj.Mass;

    nbPositionX.Value := spaceObj.PositionX;
    nbPositionY.Value := spaceObj.PositionY;

    nbVelocityX.Value := spaceObj.VelocityX;
    nbVelocityY.Value := spaceObj.VelocityY;
  end;
end;

procedure TPropertiesFrame.EnableOrDisableComponents(Enabled: boolean);
begin
  lblID.Enabled       := Enabled;
  edtName.Enabled     := Enabled;
  spnMass.Enabled     := Enabled;
  nbPositionX.Enabled := Enabled;
  nbPositionY.Enabled := Enabled;
  nbVelocityX.Enabled := Enabled;
  nbVelocityY.Enabled := Enabled;
end;

procedure TPropertiesFrame.nbPositionXChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].PositionX := nbPositionX.Value;
end;

procedure TPropertiesFrame.nbPositionYChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].PositionY := nbPositionY.Value;;
end;

procedure TPropertiesFrame.nbVelocityXChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].VelocityX := nbVelocityX.Value;
end;

procedure TPropertiesFrame.nbVelocityYChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].VelocityY := nbVelocityY.Value;
end;

procedure TPropertiesFrame.edtNameChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].Name := edtName.Text;
end;

procedure TPropertiesFrame.spnMassChange(Sender: TObject);
begin
  var idx: int32 := SpaceObjectIndexFromID(FSpaceObjectID);
  GSpaceObjects[idx].Mass := spnMass.Value;
end;

{$R *.fmx}

end.
