unit Simulation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects,
  SpaceObject;

type
  TCircleDictionary = TDictionary<uint32, TCircle>;

  TSimulationFrame = class(TFrame)
    PaintBox: TPaintBox;
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);

  public
    procedure Init();
    procedure OnUpdate(fDeltaTime: float32); //in s
    procedure OnGamePause();
    procedure OnGameResume();

  private
    FPlay: boolean;
  end;

implementation

procedure TSimulationFrame.Init();
begin
  FPlay := True;
end;

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  if FPlay then
  begin
    for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
    begin
      GSpaceObjects[i].PositionX := GSpaceObjects[i].PositionX + GSpaceObjects[i].VelocityX * fDeltaTime;
      GSpaceObjects[i].PositionY := GSpaceObjects[i].PositionY + GSpaceObjects[i].VelocityY * fDeltaTime;
    end;
  end;

  Repaint();
end;

procedure TSimulationFrame.OnGamePause();
begin
  FPlay := False;
end;

procedure TSimulationFrame.OnGameResume();
begin
  FPlay := True;
end;

procedure TSimulationFrame.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
begin
  Canvas.BeginScene();

  for var spaceObj: TSpaceObject in GSpaceObjects do
  begin
    var centerPoint: TPointF := TPointF.Create(spaceObj.PositionX, spaceObj.PositionY);
    var rect: TRectF := TRectF.Create(centerPoint, spaceObj.Mass, spaceObj.Mass);

    Canvas.FillEllipse(rect, 1.0, TBrush.Create(TBrushKind.Solid, TAlphaColors.Red));

  end;

  Canvas.EndScene();
end;

{$R *.fmx}

end.
