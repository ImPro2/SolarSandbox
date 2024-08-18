unit Simulation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects,
  SpaceObject;

type
  TCircleList = array of TCircle;

  TSimulationFrame = class(TFrame)
  private

  public
    procedure Init();

  public
    procedure OnUpdate(fDeltaTime: float32); //in s
    procedure OnSpaceObjectsChange();

  private
    FCircles: TCircleList;
    // Referring to circles with respect to the space bodies by index is not preferrable.
    // Maybe use an unordered map?
  end;

implementation

procedure TSimulationFrame.Init();
begin
  SetLength(FCircles, Length(GSpaceObjects));
  for var i := 0 to Length(FCircles) do
  begin
    FCircles[i] := TCircle.Create(Self);
    var SpaceObject := GSpaceObjects[i];

    with FCircles[i] do
    begin
      Position.X := SpaceObject.PositionX;
      Position.Y := SpaceObject.PositionY;
      Scale.X    := SpaceObject.Mass;
      Scale.Y    := SpaceObject.Mass;
    end;
  end;
end;

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  for var i := 0 to Length(FCircles) do
  begin

  end;

end;

procedure TSimulationFrame.OnSpaceObjectsChange;
begin

end;

{$R *.fmx}

end.
