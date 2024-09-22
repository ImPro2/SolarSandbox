unit Simulation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections, System.Generics.Defaults,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Math,
  FMX.Controls.Presentation, FMX.Objects, System.Math.Vectors, FMX.Canvas.D2D,
  Quick.Console, Quick.Logger,
  SpaceObject, WindowsFunctions;

type
  TPositionDictionary = TDictionary<uint32, TRectF>;
  TGridLines = array of TPair<TPointF, TPointF>;

  TSpaceObjectSelectedEvent = procedure(ID: uint32) of object;

  TSimulationFrame = class(TFrame)
    Image: TImage;
    //procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure FrameResize(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);

  public
    procedure Init();
    procedure OnUpdate(fDeltaTime: float32); //in s

    procedure GenerateThumbnail(Path: string);

  private
    FLastMouseX, FLastMouseY: float32;
    FMouseDeltaNDC: TVector3D;
    FSimulate: boolean;

    FViewMatrix, FProjectionMatrix, FViewInverseMatrix, FProjectionInverseMatrix: TMatrix3D;
    FViewProjectionMatrix: TMatrix3D;

    FCameraPosition: TVector3D;
    FCameraZoomLevel: float32;
    FCameraSpeed: float32;

    FAspectRatio: float32;

    FOrbitTrajectoryPathData: TPathData;

    FFocusedSpaceObjectID: uint32;
    FPlaybackSpeed: float32;

    FPositionDictionary: TPositionDictionary;
    FGridLines: TGridLines;
  public
    OnSpaceObjectSelected: TSpaceObjectSelectedEvent;

  private
    function NDCToScreenCoords(NDC: TVector3D): TPointF;
    function ScreenCoordsToNDC(ScreenX: float32; ScreenY: float32): TVector3D;
    function NDCToWorldSpace(NDC: TVector3D): TVector3D;

    procedure RecalculateViewProjectionMatrix();
    procedure RecalculateGrid();
    procedure RecalculateOrbitTrajectory(fDeltaTime: float32; SpaceObjectID: uint32; AttractorID: uint32);

    procedure UpdateCameraMovement(fDeltaTime: float32);
    procedure UpdateSpaceBodies(fDeltaTime: float32);
    procedure UpdateSpaceBodyPosition(fDeltaTime: float32; i: int32);
    procedure UpdateSpaceBodyRendering(i: int32);

    procedure PaintToCanvas(var Canvas: TCanvas);
  public
    property Simulate: boolean read FSimulate write FSimulate;
    property FocusedSpaceObjectID: uint32 read FFocusedSpaceObjectID write FFocusedSpaceObjectID;
    property PlaybackSpeed: float32 read FPlaybackSpeed write FPlaybackSpeed;
  end;

implementation

procedure TSimulationFrame.Init();
begin
  Self.OnResize      := Self.FrameResize;
  Image.OnMouseMove  := Self.FrameMouseMove;
  Image.OnMouseWheel := Self.FrameMouseWheel;
  Image.OnMouseDown  := Self.FrameMouseDown;

  FSimulate := False;

  FCameraPosition  := TVector3D.Create(0.0, 0.0, 0.0);
  FCameraSpeed     := 1.0;
  FCameraZoomLevel := 1.0;

  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();

  FFocusedSpaceObjectID := 0;
  FPlaybackSpeed := 1.0;

  FOrbitTrajectoryPathData := TPathData.Create();

  FPositionDictionary := TPositionDictionary.Create();
end;

{$Region Update functions}

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  fDeltaTime := fDeltaTime * FPlaybackSpeed;

  UpdateCameraMovement(fDeltaTime);
  UpdateSpaceBodies(fDeltaTime);

  // Temporary
  RecalculateOrbitTrajectory(fDeltaTime, GSpaceObjects[1].ID, GSpaceObjects[0].ID);

  Repaint();
end;

procedure TSimulationFrame.UpdateCameraMovement(fDeltaTime: float32);
begin
  if FPositionDictionary.ContainsKey(FFocusedSpaceObjectID) then
  begin
    var SpaceObject: TSpaceObject := SpaceObjectFromID(FFocusedSpaceObjectID);
    FCameraPosition.X := SpaceObject.PositionX;
    FCameraPosition.Y := SpaceObject.PositionY;
    RecalculateViewProjectionMatrix();
    RecalculateGrid();
  end;

  if IsRightMouseButtonDown() then
  begin
    var WorldSpaceDelta: TVector3D := NDCToWorldSpace(FMouseDeltaNDC);

    FCameraPosition.X := FCameraPosition.X - WorldSpaceDelta.X;
    FCameraPosition.Y := FCameraPosition.Y - WorldSpaceDelta.Y;

    RecalculateViewProjectionMatrix();
    RecalculateGrid();
  end;

  FMouseDeltaNDC := TVector3D.Zero;
end;

procedure TSimulationFrame.UpdateSpaceBodies(fDeltaTime: float32);
begin
  for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
  begin
    if FSimulate then
    begin
      UpdateSpaceBodyPosition(fDeltaTime, i);
    end;

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

  {var ScreenTopLeft: TPointF := TPointF.Create(
    (NDCTopLeft.X + 1.0) * 0.5 * Width,
    (1.0 - NDCTopLeft.Y) * 0.5 * Height
  );

  var ScreenBtmRight: TPointF := TPointF.Create(
    (NDCBtmRight.X + 1.0) * 0.5 * Width,
    (1.0 - NDCBtmRight.Y) * 0.5 * Height
  );}
  var ScreenTopLeft:  TPointF := NDCToScreenCoords(NDCTopLeft);
  var ScreenBtmRight: TPointF := NDCToScreenCoords(NDCBtmRight);

  FPositionDictionary[GSpaceObjects[i].ID] := TRectF.Create(
    TPointF.Create(ScreenTopLeft.X,  ScreenTopLeft.Y),
    TPointF.Create(ScreenBtmRight.X, ScreenBtmRight.Y)
  );
end;

{$EndRegion}

procedure TSimulationFrame.GenerateThumbnail(Path: string);
begin
  var Bitmap: TBitmap := TBitmap.Create(Round(Width), Round(Height));
  //PaintToCanvas(Bitmap.Canvas);

  Bitmap.SaveToFile(Path);
  Bitmap.Destroy();
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
  FViewInverseMatrix := FViewMatrix.Inverse();
  FProjectionInverseMatrix := FProjectionMatrix.Inverse();
end;

procedure TSimulationFrame.RecalculateGrid();
const CMaxHorzGridLines = 5;
begin
  SetLength(FGridLines, 0);

  var BtmLeftWorld:  TVector3D := TVector3D.Create(-1.0, -1.0, 0.0) * FProjectionInverseMatrix * FViewInverseMatrix;
  var TopRightWorld: TVector3D := TVector3D.Create( 1.0,  1.0, 0.0) * FProjectionInverseMatrix * FViewInverseMatrix;

  var WorldBounds: TRectF := TRectF.Create(
    TPointF.Create(BtmLeftWorld.X,  TopRightWorld.Y),
    TPointF.Create(TopRightWorld.X, BtmLeftWorld.Y)
  );

  var WidthRounded: int32 := Floor(WorldBounds.Width);
  var NearestPlaceholder: int32 := Floor(Power(10, Floor(Log10(WidthRounded))));

  var Increment: int32 := Ceil(NearestPlaceholder / CMaxHorzGridLines);

  var X: float32 := Increment * Floor(WorldBounds.Left   / Increment);
  var Y: float32 := Increment * Floor(WorldBounds.Bottom / Increment);

  while X <= WorldBounds.Right do
  begin
    var LineTopNDC: TVector3D := TVector3D.Create(X, WorldBounds.Top, 0.0)    * FViewProjectionMatrix;
    var LineBtmNDC: TVector3D := TVector3D.Create(X, WorldBounds.Bottom, 0.0) * FViewProjectionMatrix;

    var LineTopScreen: TPointF := NDCToScreenCoords(LineTopNDC);
    var LineBtmScreen: TPointF := NDCToScreenCoords(LineBtmNDC);

    FGridLines := FGridLines + [
      TPair<TPointF, TPointF>.Create(LineTopScreen, LineBtmScreen)
    ];

    X := X + Increment;
  end;

  while Y <= WorldBounds.Top do
  begin
    var LineLeftNDC:  TVector3D := TVector3D.Create(WorldBounds.Left,  Y, 0.0) * FViewProjectionMatrix;
    var LineRightNDC: TVector3D := TVector3D.Create(WorldBounds.Right, Y, 0.0) * FViewProjectionMatrix;

    var LineLeftScreen:  TPointF := NDCToScreenCoords(LineLeftNDC);
    var LineRightScreen: TPointF := NDCToScreenCoords(LineRightNDC);

    FGridLines := FGridLines + [
      TPair<TPointF, TPointF>.Create(LineLeftScreen, LineRightScreen)
    ];

    Y := Y + Increment;
  end;
end;

procedure TSimulationFrame.RecalculateOrbitTrajectory(fDeltaTime: float32; SpaceObjectID: uint32; AttractorID: uint32);
const StepCount = 2000;
begin
  FOrbitTrajectoryPathData.Clear();

  // TODO: Find attractor ID for every space object :(
  var SpaceObject: TSpaceObject := SpaceObjectFromID(SpaceObjectID);
  var Attractor:   TSpaceObject := SpaceObjectFromID(AttractorID);

  var G: float32 := 1.0;

  var PositionX: float32 := SpaceObject.PositionX;
  var PositionY: float32 := SpaceObject.PositionY;
  var VelocityX: float32 := SpaceObject.VelocityX;
  var VelocityY: float32 := SpaceObject.VelocityY;

  var AttractorPositionX: float32 := Attractor.PositionX;
  var AttractorPositionY: float32 := Attractor.PositionY;
  var AttractorVelocityX: float32 := Attractor.VelocityX;
  var AttractorVelocityY: float32 := Attractor.VelocityY;

  for var i: int32 := 1 to StepCount do
  begin
    // Calculate gravitational force

    var dx: float32 := AttractorPositionX - PositionX;
    var dy: float32 := AttractorPositionY - PositionY;

    var DistanceSquared := dx * dx + dy * dy;

    var Force: float32 := G * SpaceObject.Mass * Attractor.Mass / DistanceSquared;
    var Angle: float32 := ArcTan2(dy, dx);

    var ForceX: float32 := Force * Cos(Angle);
    var ForceY: float32 := Force * Sin(Angle);

    // Calculate world position

    var AccelerationX: float32 := ForceX / SpaceObject.Mass;
    var AccelerationY: float32 := ForceY / SpaceObject.Mass;

    VelocityX := VelocityX + AccelerationX * fDeltaTime;
    VelocityY := VelocityY + AccelerationY * fDeltaTime;

    PositionX := PositionX + VelocityX * fDeltaTime;
    PositionY := PositionY + VelocityY * fDeltaTime;

    var AttractorAccelerationX: float32 := -ForceX / Attractor.Mass;
    var AttractorAccelerationY: float32 := -ForceY / Attractor.Mass;

    AttractorVelocityX := AttractorVelocityX + AttractorAccelerationX * fDeltaTime;
    AttractorVelocityY := AttractorVelocityY + AttractorAccelerationY * fDeltaTime;

    AttractorPositionX := AttractorPositionX + AttractorVelocityX * fDeltaTime;
    AttractorPositionY := AttractorPositionY + AttractorVelocityY * fDeltaTime;

    // Calculate screen coords

    var NDC: TVector3D := TVector3D.Create(PositionX, PositionY, 0.0) * FViewProjectionMatrix;
    var ScreenCoords: TPointF := NDCToScreenCoords(NDC);
    FOrbitTrajectoryPathData.LineTo(ScreenCoords);
    FOrbitTrajectoryPathData.MoveTo(ScreenCoords);
  end;
  FOrbitTrajectoryPathData.ClosePath();
end;

procedure TSimulationFrame.PaintToCanvas(var Canvas: TCanvas);
begin
  if FPositionDictionary.IsEmpty then
    Exit;

  Canvas.BeginScene();

  Canvas.IntersectClipRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)));
  Canvas.ClearRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)), TAlphaColors.Black);

  // Draw grid

  var GridBrush: TStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.DimGray);
  for var GridLine: TPair<TPointF, TPointF> in FGridLines do
  begin
    Canvas.DrawLine(GridLine.Key, GridLine.Value, 1.0, GridBrush);
  end;
  GridBrush.Destroy();

  // Draw orbiral trajectory

  var OrbitTrajectoryBrush: TStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.DimGray);
  Canvas.DrawPath(FOrbitTrajectoryPathData, 1.0, OrbitTrajectoryBrush);
  OrbitTrajectoryBrush.Destroy();

  // Draw space objects

  var SpaceObjectBrush: TBrush := TBrush.Create(TBrushKind.Solid, TAlphaColors.Red);
  for var spaceObj: TSpaceObject in GSpaceObjects do
  begin
    var rectf: TRectF := FPositionDictionary[spaceObj.ID];
    Canvas.FillEllipse(rectf, 1.0, SpaceObjectBrush);
  end;
  SpaceObjectBrush.Destroy();

  Canvas.EndScene();
end;

procedure TSimulationFrame.FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  var MouseDeltaX := X - FLastMouseX;
  var MouseDeltaY := Y - FLastMouseY;

  FMouseDeltaNDC := ScreenCoordsToNDC(MouseDeltaX, MouseDeltaY);

  FLastMouseX := X;
  FLastMouseY := Y;
end;

procedure TSimulationFrame.FrameResize(Sender: TObject);
begin
  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();
  RecalculateGrid();
end;

procedure TSimulationFrame.FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  // This makes the zooming smooth somehow

  FCameraZoomLevel := FCameraZoomLevel - (float32(WheelDelta) / 120.0) * 0.25 * FCameraZoomLevel;
  FCameraZoomLevel := Max(FCameraZoomLevel, 0.25);

  RecalculateViewProjectionMatrix();
  RecalculateGrid();
end;

procedure TSimulationFrame.FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  for var Pair: TPair<uint32, TRectF> in FPositionDictionary.ToArray() do
  begin
    var ID: uint32 := Pair.Key;
    var NDCRect: TRectF := Pair.Value;

    var Radius:     float32 := 0.5 * (NDCRect.Right - NDCRect.Left);

    var dx: float32 := NDCRect.CenterPoint.X - X;
    var dy: float32 := NDCRect.CenterPoint.Y - Y;

    var DistanceSq: float32 := dx * dx + dy * dy;
    var RadiusSq:   float32 := Radius * Radius;

    if DistanceSq <= RadiusSq then
    begin
      if Assigned(OnSpaceObjectSelected) then
        OnSpaceObjectSelected(ID);
    end;
  end;
end;

function TSimulationFrame.NDCToScreenCoords(NDC: TVector3D): TPointF;
begin
  Result := TPointF.Create(
    (NDC.X + 1.0) * 0.5 * Width,
    (1.0 - NDC.Y) * 0.5 * Height
  );
end;

function TSimulationFrame.ScreenCoordsToNDC(ScreenX: float32; ScreenY: float32): TVector3D;
begin
  Result := TVector3D.Create(
     (2.0 * ScreenX) / Width  - 0.0,
    -(2.0 * ScreenY) / Height + 0.0,
    0.0
  );
end;

function TSimulationFrame.NDCToWorldSpace(NDC: TVector3D): TVector3D;
begin
  Result := NDC * FProjectionInverseMatrix;
end;

procedure TSimulationFrame.ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  PaintToCanvas(Canvas);
end;

{$R *.fmx}

end.
