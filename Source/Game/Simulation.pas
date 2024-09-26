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
  TOrbitTrajectoryData = array of TPair<TPointF, TPointF>;

  TSpaceObjectSelectedEvent = procedure(ID: uint32) of object;

  TSimulationFrame = class(TFrame)
    Image: TImage;
    procedure FrameResize(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FrameKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);

  public
    procedure Init();
    procedure OnUpdate(fDeltaTime: float32); //in s

    procedure GenerateThumbnail(Path: string);

  private
    FLastMouseX, FLastMouseY: float32;
    FMouseDeltaNDC: TVector3D;
    FSimulate: boolean;

    FViewGrid: boolean;
    FViewAbsoluteOrbitTrajectory, FViewRelativeOrbitTrajectory: boolean;

    FOrbitTrajectoryCalculationStepCount: int32;

    FViewMatrix, FProjectionMatrix, FViewInverseMatrix, FProjectionInverseMatrix: TMatrix3D;
    FViewProjectionMatrix: TMatrix3D;

    FCameraPosition: TVector3D;
    FCameraFocusPanOffset: TVector3D;
    FCameraZoomLevel: float32;
    FCameraSpeed: float32;

    FAspectRatio: float32;

    FSelectedSpaceObjectID: uint32;
    FFocused: boolean;

    FPlaybackSpeed: float32;

    FPositionDictionary: TPositionDictionary;
    FGridLines: TGridLines;
    FOrbitTrajectoryData: TOrbitTrajectoryData;
  public
    OnSpaceObjectSelected: TSpaceObjectSelectedEvent;

  private
    // Update functions
    procedure UpdateCameraMovement(fDeltaTime: float32);
    procedure UpdateSpaceBodies(fDeltaTime: float32);
    function  CalculateGravitationalForce(const [ref] SpaceObject: TSpaceObject; const [ref] SpaceObjectList: TSpaceObjectList): TPointF;
    procedure ApplyForceToSpaceBody(var SpaceObject: TSpaceObject; ForceX, ForceY: float32; fDeltaTime: float32);
    procedure CalculateCollision(var SpaceObject1, SpaceObject2: TSpaceObject; fDeltaTime: float32);

    // Rendering and Rendering Calculations
    procedure PaintToCanvas(var Canvas: TCanvas);
    procedure RecalculateSpaceBodyRendering(const [ref] SpaceObject: TSpaceObject);
    function  IsColliding(SpaceBody1, SpaceBody2: TSpaceObject): boolean;
    procedure RecalculateViewProjectionMatrix();
    procedure RecalculateGrid();
    procedure RecalculateAbsoluteOrbitTrajectory(fDeltaTime: float32; SpaceObjectID: uint32);

    // Conversions
    function NDCToScreenCoords(NDC: TVector3D): TPointF;
    function ScreenCoordsToNDC(ScreenX: float32; ScreenY: float32): TVector3D;
    function NDCToWorldSpace(NDC: TVector3D): TVector3D;

  public
    property Simulate: boolean read FSimulate write FSimulate;
    property SelectedSpaceObjectID: uint32 read FSelectedSpaceObjectID write FSelectedSpaceObjectID;
    property Focused: boolean read FFocused write FFocused;
    property PlaybackSpeed: float32 read FPlaybackSpeed write FPlaybackSpeed;
    property ViewGrid: boolean read FViewGrid write FViewGrid;
    property ViewRelativeOrbitTrajectory: boolean read FViewRelativeOrbitTrajectory write FViewRelativeOrbitTrajectory;
    property ViewAbsoluteOrbitTrajectory: boolean read FViewAbsoluteOrbitTrajectory write FViewAbsoluteOrbitTrajectory;
    property OrbitTrajectoryCalculationStepCount: int32 read FOrbitTrajectoryCalculationStepCount write FOrbitTrajectoryCalculationStepCount;
  end;

implementation

procedure TSimulationFrame.Init();
begin
  FSimulate := False;

  FViewAbsoluteOrbitTrajectory := False;
  FViewRelativeOrbitTrajectory := False;
  FViewGrid := True;

  FOrbitTrajectoryCalculationStepCount := 5000;

  FCameraPosition  := TVector3D.Create(0.0, 0.0, 0.0);
  FCameraFocusPanOffset := TVector3D.Create(0.0, 0.0, 0.0);
  FCameraSpeed     := 1.0;
  FCameraZoomLevel := 1.0;

  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();

  FSelectedSpaceObjectID := 0;
  FFocused := False;

  FPlaybackSpeed := 1.0;

  SetLength(FOrbitTrajectoryData, 0);

  FPositionDictionary := TPositionDictionary.Create();
end;

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  var DeltaTimeWithPlaybackSpeed: float32 := fDeltaTime * FPlaybackSpeed;

  UpdateCameraMovement(DeltaTimeWithPlaybackSpeed);
  UpdateSpaceBodies(DeltaTimeWithPlaybackSpeed);

  // Temporary
  RecalculateAbsoluteOrbitTrajectory(fDeltaTime, FSelectedSpaceObjectID);

  Repaint();
end;

{$Region Update functions}

procedure TSimulationFrame.UpdateCameraMovement(fDeltaTime: float32);
begin
  var Pan:   boolean := IsMiddleMouseButtonDown();
  var Focus: boolean := FPositionDictionary.ContainsKey(FSelectedSpaceObjectID) and FFocused;

  var WorldSpaceDelta: TVector3D := TVector3D.Zero;

  if Pan then
    WorldSpaceDelta := NDCToWorldSpace(FMouseDeltaNDC);

  if Focus then
  begin
    var SpaceObject: TSpaceObject := SpaceObjectFromID(FSelectedSpaceObjectID);

    FCameraFocusPanOffset.X := FCameraFocusPanOffset.X + WorldSpaceDelta.X;
    FCameraFocusPanOffset.Y := FCameraFocusPanOffset.Y + WorldSpaceDelta.Y;

    FCameraPosition.X := SpaceObject.PositionX - FCameraFocusPanOffset.X;
    FCameraPosition.Y := SpaceObject.PositionY - FCameraFocusPanOffset.Y;
  end else
  begin
    FCameraFocusPanOffset := TVector3D.Zero;
    FCameraPosition.X := FCameraPosition.X - WorldSpaceDelta.X;
    FCameraPosition.Y := FCameraPosition.Y - WorldSpaceDelta.Y;
  end;

  if Pan or Focus then
  begin
    RecalculateViewProjectionMatrix();
    RecalculateGrid();
  end;

  FMouseDeltaNDC := TVector3D.Zero;
end;

procedure TSimulationFrame.UpdateSpaceBodies(fDeltaTime: float32);
begin
  if FSimulate then
  begin
    // Movement

    for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
    begin
      var SpaceObject: TSpaceObject := GSpaceObjects[i];

      var Force: TPointF := CalculateGravitationalForce(SpaceObject, GSpaceObjects);
      ApplyForceToSpaceBody(SpaceObject, Force.X, Force.Y, fDeltaTime);

      GSpaceObjects[i] := SpaceObject;
    end;

    // Collision

    for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
    begin
      for var j: int32 := i to Length(GSpaceObjects) - 1 do
      begin
        var SpaceObject1: TSpaceObject := GSpaceObjects[i];
        var SpaceObject2: TSpaceObject := GSpaceObjects[j];

        if SpaceObject1.ID = SpaceObject2.ID then continue;

        if IsColliding(SpaceObject1, SpaceObject2) then
        begin
          CalculateCollision(SpaceObject1, SpaceObject2, fDeltaTime);
        end;

        GSpaceObjects[i] := SpaceObject1;
        GSpaceObjects[j] := SpaceObject2;
      end;
    end;
  end;

  // Rendering

  for var SpaceObject: TSpaceObject in GSpaceObjects do
  begin
    RecalculateSpaceBodyRendering(SpaceObject);
  end;
end;

function TSimulationFrame.CalculateGravitationalForce(const [ref] SpaceObject: TSpaceObject; const [ref] SpaceObjectList: TSpaceObjectList): TPointF;
const G = 1.0;
begin
  // Newton's Law of Gravitation
  // F = G * m1 * m2 / r^2

  var ForceX: float32 := 0;
  var ForceY: float32 := 0;

  for var OtherSpaceObject in SpaceObjectList do
  begin
    if SpaceObject.ID = OtherSpaceobject.ID then continue;

    var dx: float32 := OtherSpaceObject.PositionX - SpaceObject.PositionX;
    var dy: float32 := OtherSpaceObject.PositionY - SpaceObject.PositionY;

    var DistanceSquared := dx * dx + dy * dy;

    var Force: float32 := G * OtherSpaceObject.Mass * SpaceObject.Mass / DistanceSquared;
    var Angle: float32 := ArcTan2(dy, dx);

    ForceX := ForceX + Force * Cos(Angle);
    ForceY := ForceY + Force * Sin(Angle);
  end;

  Result := TPointF.Create(ForceX, ForceY);
end;

procedure TSimulationFrame.ApplyForceToSpaceBody(var SpaceObject: TSpaceObject; ForceX, ForceY: float32; fDeltaTime: float32);
begin
  var AccelerationX: float32 := ForceX / SpaceObject.Mass;
  var AccelerationY: float32 := ForceY / SpaceObject.Mass;

  SpaceObject.VelocityX := SpaceObject.VelocityX + AccelerationX * fDeltaTime;
  SpaceObject.VelocityY := SpaceObject.VelocityY + AccelerationY * fDeltaTime;

  SpaceObject.PositionX := SpaceObject.PositionX + SpaceObject.VelocityX * fDeltaTime;
  SpaceObject.PositionY := SpaceObject.PositionY + SpaceObject.VelocityY * fDeltaTime;
end;

procedure TSimulationFrame.CalculateCollision(var SpaceObject1, SpaceObject2: TSpaceObject; fDeltaTime: float32);
begin
  var m1:  float32 := SpaceObject1.Mass;
  var m2:  float32 := SpaceObject2.Mass;
  var v1x: float32 := SpaceObject1.VelocityX;
  var v1y: float32 := SpaceObject1.VelocityY;
  var v2x: float32 := SpaceObject2.VelocityX;
  var v2y: float32 := SpaceObject2.VelocityY;

  SpaceObject1.VelocityX := v1x * (m1 - m2) / (m1 + m2) + v2x * (2 * m2) / (m1 + m2);
  SpaceObject1.VelocityY := v1y * (m1 - m2) / (m1 + m2) + v2y * (2 * m2) / (m1 + m2);

  SpaceObject2.VelocityX := v1x * (2 * m1) / (m1 + m2) + v2x * (m2 - m1) / (m1 + m2);
  SpaceObject2.VelocityY := v1y * (2 * m1) / (m1 + m2) + v2y * (m2 - m1) / (m1 + m2);

  SpaceObject1.PositionX := SpaceObject1.PositionX + SpaceObject1.VelocityX * fDeltaTime;
  SpaceObject1.PositionY := SpaceObject1.PositionY + SpaceObject1.VelocityY * fDeltaTime;
  SpaceObject2.PositionX := SpaceObject2.PositionX + SpaceObject2.VelocityX * fDeltaTime;
  SpaceObject2.PositionY := SpaceObject2.PositionY + SpaceObject2.VelocityY * fDeltaTime;
end;

{$EndRegion}

{$Region Rendering and Rendering Calculations}

procedure TSimulationFrame.PaintToCanvas(var Canvas: TCanvas);
begin
  if FPositionDictionary.IsEmpty then
    Exit;

  Canvas.BeginScene();

  Canvas.IntersectClipRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)));
  Canvas.ClearRect(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)), TAlphaColors.Black);

  // Draw grid

  if FViewGrid then
  begin
    var GridBrush: TStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.DimGray);
    for var GridLine: TPair<TPointF, TPointF> in FGridLines do
    begin
      Canvas.DrawLine(GridLine.Key, GridLine.Value, 1.0, GridBrush);
    end;
    GridBrush.Destroy();
  end;

  // Draw orbiral trajectory

  if FViewAbsoluteOrbitTrajectory or FViewRelativeOrbitTrajectory then
  begin
    var OrbitTrajectoryBrush: TStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.White);
    OrbitTrajectoryBrush.Thickness := 0.5;
    var Count: int32 := Length(FOrbitTrajectoryData);
    for var i: int32 := 0 to Count - 1 do
    begin
      var Opacity: float32 := float32(Count - i + 1) / Count;

      var LinePair: TPair<TPointF, TPointF> := FOrbitTrajectoryData[i];
      Canvas.DrawLine(LinePair.Key, LinePair.Value, Opacity, OrbitTrajectoryBrush);
    end;
    OrbitTrajectoryBrush.Destroy();
  end;

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

procedure TSimulationFrame.GenerateThumbnail(Path: string);
begin
  var Bitmap: TBitmap := TBitmap.Create(Round(Width), Round(Height));
  //PaintToCanvas(Bitmap.Canvas);

  Bitmap.SaveToFile(Path);
  Bitmap.Destroy();
end;

procedure TSimulationFrame.RecalculateSpaceBodyRendering(const [ref] SpaceObject: TSpaceObject);
begin
  // Ensure space object exists in local registry

  if not FPositionDictionary.ContainsKey(SpaceObject.ID) then
    FPositionDictionary.Add(SpaceObject.ID, TRectF.Create(TPointF.Zero));

  // stuff

  var LocalTopLeft:  TVector3D := TVector3D.Create(-0.5,  0.5, 0.0);
  var LocalBtmRight: TVector3D := TVector3D.Create( 0.5, -0.5, 0.0);

  var Position: TVector3D := TVector3D.Create(
    SpaceObject.PositionX,
    SpaceObject.PositionY,
    0.0
  );

  var Scale: TPoint3D := TPoint3D.Create(
    SpaceObject.RadiusFromMass() * 2,
    SpaceObject.RadiusFromMass() * 2,
    0.0
  );

  // Convert to Local Space

  var TransformMatrix: TMatrix3D := TMatrix3D.CreateScaling(Scale) * TMatrix3D.CreateTranslation(Position);

  // Convert to to World Space and then Normalized Device Coordinates

  var NDCTopLeft:  TVector3D := (localtopleft  * TransformMatrix) * FViewProjectionMatrix;
  var NDCBtmRight: TVector3D := (LocalBtmRight * TransformMatrix) * FViewProjectionMatrix;

  // Convert to Screen Space Coordinates

  var ScreenTopLeft:  TPointF := NDCToScreenCoords(NDCTopLeft);
  var ScreenBtmRight: TPointF := NDCToScreenCoords(NDCBtmRight);

  FPositionDictionary[SpaceObject.ID] := TRectF.Create(
    TPointF.Create(ScreenTopLeft.X,  ScreenTopLeft.Y),
    TPointF.Create(ScreenBtmRight.X, ScreenBtmRight.Y)
  );
end;

function TSimulationFrame.IsColliding(SpaceBody1: TSpaceObject; SpaceBody2: TSpaceObject): boolean;
begin
  var dx: float32 := SpaceBody1.PositionX - SpaceBody2.PositionX;
  var dy: float32 := SpaceBody1.PositionY - SpaceBody2.PositionY;
  var DistSq: float32 := dx * dx + dy * dy;
  var Radius1: float32 := SpaceBody1.RadiusFromMass();
  var Radius2: float32 := SpaceBody2.RadiusFromMass();

  if DistSq <= (Radius1 + Radius2) * (Radius1 + Radius2) then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;
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
  if not FViewGrid then Exit;

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

procedure TSimulationFrame.RecalculateAbsoluteOrbitTrajectory(fDeltaTime: float32; SpaceObjectID: uint32);
begin
  if not (FViewAbsoluteOrbitTrajectory or FViewRelativeOrbitTrajectory) then Exit;

  Delete(FOrbitTrajectoryData, 0, Length(FOrbitTrajectoryData));

  var SpaceObject: TSpaceObject := SpaceObjectFromID(SpaceObjectID);

  var SpaceObjectsCopy: TSpaceObjectList := Copy(GSpaceObjects, 0, Length(GSpaceObjects));

  var G: float32 := 1.0;

  var LastPoint: TPointF := NDCToScreenCoords(TVector3D.Create(SpaceObject.PositionX, SpaceObject.PositionY, 0.0) * FViewProjectionMatrix);

  for var i: int32 := 0 to FOrbitTrajectoryCalculationStepCount - 1 do
  begin
    // Calculate gravitational force
    if FViewAbsoluteOrbitTrajectory then
    begin
      for var j := 0 to Length(SpaceObjectsCopy) - 1 do
      begin
        {var OtherSpaceObject: TSpaceObject := SpaceObjectsCopy[j];

        if OtherSpaceObject.ID = SpaceObject.ID then continue;

        var dx: float32 := OtherSpaceObject.PositionX - SpaceObject.PositionX;
        var dy: float32 := OtherSpaceObject.PositionY - SpaceObject.PositionY;

        var DistanceSquared := dx * dx + dy * dy;

        var Force: float32 := G * SpaceObject.Mass * OtherSpaceObject.Mass / DistanceSquared;
        var Angle: float32 := ArcTan2(dy, dx);

        var ForceX: float32 := Force * Cos(Angle);
        var ForceY: float32 := Force * Sin(Angle);}
        var SpaceObjectIter: TSpaceObject := SpaceObjectsCopy[j];

        var Force: TPointF := CalculateGravitationalForce(SpaceObjectIter, SpaceObjectsCopy);

        ApplyForceToSpaceBody(SpaceObjectIter, Force.X, Force.Y, fDeltaTime);
        //ApplyForceToSpaceBody(OtherSpaceObject, -ForceX, -ForceY, fDeltaTime);

        if SpaceObjectIter.ID = SpaceObject.ID then
        begin
          SpaceObject := SpaceObjectIter;
        end else
        begin
          if IsColliding(SpaceObject, SpaceObjectIter) then
            Exit;
        end;

        SpaceObjectsCopy[j] := SpaceObjectIter;

      end;
    end else if FViewRelativeOrbitTrajectory then
    begin
      {var SpaceObjectForce: TPointF := CalculateGravitationalForce(SpaceObject);
      var AttractorForce:   TPointF := CalculateGravitationalForce(Attractor);

      // Calculate world position

      ApplyForceToSpaceBody(SpaceObject, SpaceObjectForce.X, SpaceObjectForce.Y, fDeltaTime);
      ApplyForceToSpaceBody(Attractor, AttractorForce.X, AttractorForce.Y, fDeltaTime);}
    end;

    // Calculate screen coords

    var SpaceObjectVector:  TVector3D := TVector3D.Create(SpaceObject.PositionX, SpaceObject.PositionY, 0.0);

    var NDC: TVector3D := SpaceObjectVector * FViewProjectionMatrix;
    var ScreenCoords: TPointF := NDCToScreenCoords(NDC);

    FOrbitTrajectoryData := FOrbitTrajectoryData + [TPair<TPointF, TPointF>.Create(LastPoint, ScreenCoords)];
    LastPoint := ScreenCoords;
  end;
end;

{$EndRegion}

{$Region Conversions}

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

{$EndRegion}

{$Region Events}

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

procedure TSimulationFrame.FrameKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  Logger.Trace(KeyChar);

end;

procedure TSimulationFrame.ImagePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  PaintToCanvas(Canvas);
end;

{$EndRegion}

{$R *.fmx}

end.
