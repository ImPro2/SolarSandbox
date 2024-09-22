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
    lblVelocityX: TLabel;
    nbVelocityX: TNumberBox;
    lblVelocityY: TLabel;
    nbVelocityY: TNumberBox;
    lblPositionXValue: TLabel;
    lblPositionYValue: TLabel;
    lblPositionY: TLabel;
    lblVelocityXValue: TLabel;
    lblVelocityYValue: TLabel;
    procedure edtNameChange(Sender: TObject);
    procedure spnMassChange(Sender: TObject);
    procedure nbPositionXChange(Sender: TObject);
    procedure nbPositionYChange(Sender: TObject);
    procedure nbVelocityXChange(Sender: TObject);
    procedure nbVelocityYChange(Sender: TObject);
  public
    procedure OnUpdate(SelectedSpaceObjectID: uint32);

    procedure OnGameStartOrResume();
    procedure OnGameStopOrPause();
  private
    FSpaceObjectID: uint32;
    FIsSimulating: boolean;

    procedure EnableOrDisableComponents(Enabled: boolean);
    procedure FillDataFromSpaceObject();
  end;

implementation

procedure TPropertiesFrame.OnUpdate(SelectedSpaceObjectID: uint32);
begin
  FSpaceObjectID := SelectedSpaceObjectID;

  if FSpaceObjectID = 0 then
  begin
    EnableOrDisableComponents(False);
    Exit;
  end;

  EnableOrDisableComponents(True);
  FillDataFromSpaceObject();

  if not FIsSimulating then
  begin
    nbPositionX.Repaint();
    nbPositionY.Repaint();
    nbVelocityX.Repaint();
    nbVelocityY.Repaint();
  end;
end;

procedure TPropertiesFrame.OnGameStartOrResume();
begin
  nbPositionX.Visible := False;
  nbPositionY.Visible := False;
  nbVelocityX.Visible := False;
  nbVelocityY.Visible := False;

  FIsSimulating := True;
end;

procedure TPropertiesFrame.OnGameStopOrPause();
begin
  nbPositionX.Visible := True;
  nbPositionY.Visible := True;
  nbVelocityX.Visible := True;
  nbVelocityY.Visible := True;

  FIsSimulating := False;
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

procedure TPropertiesFrame.FillDataFromSpaceObject();
begin
  var SpaceObject: TSpaceObject := SpaceObjectFromID(FSpaceObjectID);

  lblIDText.Text    := SpaceObject.ID.ToString();
  edtName.Text      := SpaceObject.Name;
  spnMass.Value     := SpaceObject.Mass;

  if not FIsSimulating then
  begin
    nbPositionX.Value := SpaceObject.PositionX;
    nbPositionY.Value := SpaceObject.PositionY;
    nbVelocityX.Value := SpaceObject.VelocityX;
    nbVelocityY.Value := SpaceObject.VelocityY;
    lblPositionXValue.Text := '';
    lblPositionYValue.Text := '';
    lblVelocityXValue.Text := '';
    lblVelocityYValue.Text := '';
  end else
  begin
    lblPositionXValue.Text := FloatToStr(SpaceObject.PositionX);
    lblPositionYValue.Text := FloatToStr(SpaceObject.PositionY);
    lblVelocityXValue.Text := FloatToStr(SpaceObject.VelocityX);
    lblVelocityYValue.Text := FloatToStr(SpaceObject.VelocityY);
  end;
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
