unit Properties;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.SpinBox,
  SpaceObject;

type
  TPropertiesFrame = class(TFrame)
    lblHeading: TLabel;
    Panel: TPanel;
    lblName: TLabel;
    lblMass: TLabel;
    edtName: TEdit;
    spnMass: TSpinBox;
    procedure edtNameChange(Sender: TObject);
    procedure spnMassChange(Sender: TObject);
  private
    FSpaceObject: TSpaceObject;
  public
    OnSpaceObjectChanged: TSpaceObjectChangedEvent;
    procedure OnSpaceObjectSelected(SpaceObject: TSpaceObject);
  end;

implementation

procedure TPropertiesFrame.OnSpaceObjectSelected(SpaceObject: TSpaceObject);
begin
  FSpaceObject := SpaceObject;
  edtName.Text := SpaceObject.Name;
  spnMass.Value := SpaceObject.Mass;
end;

{$R *.fmx}

procedure TPropertiesFrame.edtNameChange(Sender: TObject);
begin
  FSpaceObject.Name := edtName.Text;
  OnSpaceObjectChanged(FSpaceObject);
end;

procedure TPropertiesFrame.spnMassChange(Sender: TObject);
begin
  FSpaceObject.Mass := spnMass.Value;
  OnSpaceObjectChanged(FSpaceObject);
end;

end.
