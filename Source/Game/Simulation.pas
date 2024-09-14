unit Simulation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Math,
  FMX.Controls.Presentation, FMX.Objects, System.Math.Vectors, Windows, FMX.Canvas.D2D,
  Quick.Console, Quick.Logger,
  SpaceObject;

type
  TPositionDictionary = TDictionary<uint32, TRectF>;

  TSimulationFrame = class(TFrame)
    Image: TImage;
    //procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure FrameResize(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);

  public
    procedure Init();
    procedure OnUpdate(fDeltaTime: float32); //in s

  private
    FLastMouseX, FLastMouseY: float32;
    FMouseDeltaNDC: TVector3D;
    FSimulate: boolean;

    FViewMatrix, FProjectionMatrix, FProjectionInverseMatrix: TMatrix3D;
    FViewProjectionMatrix: TMatrix3D;

    FCameraPosition: TVector3D;
    FCameraZoomLevel: float32;
    FCameraSpeed: float32;

    FAspectRatio: float32;

    FPositionDictionary: TPositionDictionary;

  public
    property Simulate: boolean read FSimulate write FSimulate;

  private
    procedure RecalculateViewProjectionMatrix();
    procedure UpdateCameraMovement(fDeltaTime: float32);
    procedure UpdateSpaceBodies(fDeltaTime: float32);
    procedure UpdateSpaceBodyPosition(fDeltaTime: float32; i: int32);
    procedure UpdateSpaceBodyRendering(i: int32);
  end;

implementation

procedure TSimulationFrame.Init();
begin
  Self.OnResize      := Self.FrameResize;
  Image.OnMouseMove  := Self.FrameMouseMove;
  Image.OnMouseWheel := Self.FrameMouseWheel;

  FSimulate := False;

  FCameraPosition  := TVector3D.Create(0.0, 0.0, 0.0);
  FCameraSpeed     := 1.0;
  FCameraZoomLevel := 1.0;

  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();

  FPositionDictionary := TPositionDictionary.Create();
end;

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  UpdateCameraMovement(fDeltaTime);
  UpdateSpaceBodies(fDeltaTime);

  Repaint();
end;

procedure TSimulationFrame.UpdateSpaceBodies(fDeltaTime: float32);
begin
  for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
  begin
    if FSimulate then
      UpdateSpaceBodyPosition(fDeltaTime, i);

    UpdateSpaceBodyRendering(i);
  end;
end;

procedure TSimulationFrame.UpdateSpaceBodyPosition(fDeltaTime: float32; i: int32);
const
  G = 1;
begin
  // Newton's Law of Gravitation
  // F = G * m1 * m2 / r^2

  var ForceX: float32 := 0;
  var ForceY: float32 := 0;

  for var spaceObj in GSpaceObjects do
  begin
    if spaceObj.ID = GSpaceObjects[i].ID then
      continue;

    var dx: float32 := spaceObj.PositionX - GSpaceObjects[i].PositionX;
    var dy: float32 := spaceObj.PositionY - GSpaceObjects[i].PositionY;

    var DistanceSquared := dx * dx + dy * dy;

    var Force: float32 := G * GSpaceObjects[i].Mass * spaceObj.Mass / DistanceSquared;
    var Angle: float32 := ArcTan2(dy, dx);

    ForceX := ForceX + Force * Cos(Angle);
    ForceY := ForceY + Force * Sin(Angle);
  end;

  var AccelerationX: float32 := ForceX / GSpaceObjects[i].Mass;
  var AccelerationY: float32 := ForceY / GSpaceObjects[i].Mass;

  GSpaceObjects[i].VelocityX := GSpaceObjects[i].VelocityX + AccelerationX * fDeltaTime;
  GSpaceObjects[i].VelocityY := GSpaceObjects[i].VelocityY + AccelerationY * fDeltaTime;

  GSpaceObjects[i].PositionX := GSpaceObjects[i].PositionX + GSpaceObjects[i].VelocityX * fDeltaTime;
  GSpaceObjects[i].PositionY := GSpaceObjects[i].PositionY + GSpaceObjects[i].VelocityY * fDeltaTime;
end;

procedure TSimulationFrame.UpdateSpaceBodyRendering(i: int32);
begin
  // Ensure space object exists in local registry

  if not FPositionDictionary.ContainsKey(GSpaceObjects[i].ID) then
    FPositionDictionary.Add(GSpaceObjects[i].ID, TRectF.Create(TPointF.Zero));

  // stuff

  var LocalTopLeft:  TVector3D := TVector3D.Create(-0.5,  0.5, 0.0);
  var LocalBtmRight: TVector3D := TVector3D.Create( 0.5, -0.5, 0.0);

  var Position: TVector3D := TVector3D.Create(
    GSpaceObjects[i].PositionX,
    GSpaceObjects[i].PositionY,
    0.0
  );

  var Scale: TPoint3D := TPoint3D.Create(
    GSpaceObjects[i].Mass * 0.1,
    GSpaceObjects[i].Mass * 0.1,
    0.0
  );

  // Convert to Local Space

  var TransformMatrix: TMatrix3D := TMatrix3D.CreateScaling(Scale) * TMatrix3D.CreateTranslation(Position);

  // Convert to to World Space and then Normalized Device Coordinates

  var NDCTopLeft:  TVector3D := (localtopleft  * TransformMatrix) * FViewProjectionMatrix;
  var NDCBtmRight: TVector3D := (LocalBtmRight * TransformMatrix) * FViewProjectionMatrix;

  // Convert to Screen Space Coordinates

  var ScreenTopLeft: TPointF := TPointF.Create(
    (NDCTopLeft.X + 1.0) * 0.5 * Width,
    (1.0 - NDCTopLeft.Y) * 0.5 * Height
  );

  var ScreenBtmRight: TPointF := TPointF.Create(
    (NDCBtmRight.X + 1.0) * 0.5 * Width,
    (1.0 - NDCBtmRight.Y) * 0.5 * Height
  );

  FPositionDictionary[GSpaceObjects[i].ID] := TRectF.Create(
    TPointF.Create(ScreenTopLeft.X,  ScreenTopLeft.Y),
    TPointF.Create(ScreenBtmRight.X, ScreenBtmRight.Y)
  );
end;

procedure TSimulationFrame.RecalculateViewProjectionMatrix();
var
  Left, Right, Top, Bottom: float32;
begin
  Left   := -FAspectRatio * FCameraZoomLevel;
  Right  :=  FAspectRatio * FCameraZoomLevel;
  Top    :=  FCameraZoomLevel;
  Bottom := -FCameraZoomLevel;

  FProjectionMatrix := TMatrix3D.CreateOrthoOffCenterLH(Left, Top, Right, Bottom, 0.1, 100.0);
  FViewMatrix       := TMatrix3D.CreateTranslation(FCameraPosition).Inverse();

  FViewProjectionMatrix := FViewMatrix * FProjectionMatrix;
  FProjectionInverseMatrix := FProjectionMatrix.Inverse();
end;

procedure TSimulationFrame.UpdateCameraMovement(fDeltaTime: float32);
begin
  var bRightMouseButton: boolean := ((GetKeyState(VK_RBUTTON) and $80) <> 0);

  if (bRightMouseButton) then
  begin
    var WorldSpaceDelta: TVector3D := FMouseDeltaNDC * FProjectionInverseMatrix;

    FCameraPosition.X := FCameraPosition.X - WorldSpaceDelta.X;
    FCameraPosition.Y := FCameraPosition.Y - WorldSpaceDelta.Y;

    RecalculateViewProjectionMatrix();
  end;

  FMouseDeltaNDC := TVector3D.Zero;
end;

procedure TSimulationFrame.FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  var MouseDeltaX := X - FLastMouseX;
  var MouseDeltaY := Y - FLastMouseY;

  FMouseDeltaNDC := TVector3D.Create(
     (2.0 * MouseDeltaX) / Width  - 0.0,
    -(2.0 * MouseDeltaY) / Height + 0.0,
    0.0
  );

  FLastMouseX := X;
  FLastMouseY := Y;
end;

procedure TSimulationFrame.FrameResize(Sender: TObject);
begin
  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();
end;

procedure TSimulationFrame.FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  // This makes the zooming smooth somehow

  FCameraZoomLevel := FCameraZoomLevel - (float32(WheelDelta) / 120.0) * 0.25 * FCameraZoomLevel;
  FCameraZoomLevel := Max(FCameraZoomLevel, 0.25);

  RecalculateViewProjectionMatrix();
end;

procedure TSimulationFrame.ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  if FPositionDictionary.IsEmpty then
    Exit;

  Canvas.BeginScene();

  Canvas.IntersectClipRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)));
  Canvas.ClearRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)), TAlphaColors.Black);

  // Draw space objects

  for var spaceObj: TSpaceObject in GSpaceObjects do
  begin
    var rectf: TRectF := FPositionDictionary[spaceObj.ID];
    Canvas.FillEllipse(rectf, 1.0, TBrush.Create(TBrushKind.Solid, TAlphaColors.Red));
  end;

  Canvas.EndScene();
end;

{$R *.fmx}

end.
