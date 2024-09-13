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
    PaintBox: TPaintBox;
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure FrameResize(Sender: TObject);
    procedure PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);

  public
    procedure Init();
    procedure OnUpdate(fDeltaTime: float32); //in s
    procedure OnGamePause();
    procedure OnGameResume();

  private
    FLastMouseX, FLastMouseY: float32;
    FMouseDeltaNDC: TVector3D;
    FPlay: boolean;

    FViewMatrix, FProjectionMatrix, FProjectionInverseMatrix: TMatrix3D;
    FViewProjectionMatrix: TMatrix3D;

    FCameraPosition: TVector3D;
    FCameraZoomLevel: float32;
    FCameraSpeed: float32;

    FAspectRatio: float32;

    FPositionDictionary: TPositionDictionary;
  private
    procedure RecalculateViewProjectionMatrix();
    procedure CameraMovement(fDeltaTime: float32);
  end;

implementation

procedure TSimulationFrame.Init();
begin
  Self.OnResize        := Self.FrameResize;
  PaintBox.OnMouseMove := Self.FrameMouseMove;

  FPlay := True;

  FCameraPosition  := TVector3D.Create(0.0, 0.0, 0.0);
  FCameraSpeed     := 1.0;
  FCameraZoomLevel := 1.0;

  FAspectRatio := float32(Width) / float32(Height);

  RecalculateViewProjectionMatrix();

  FPositionDictionary := TPositionDictionary.Create();
  FPositionDictionary.Add(GSpaceObjects[0].ID, TRectF.Create(TPointF.Zero));
end;

procedure TSimulationFrame.OnUpdate(fDeltaTime: float32);
begin
  if FPlay then
  begin
    CameraMovement(fDeltaTime);

    for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
    begin
      GSpaceObjects[i].PositionX := GSpaceObjects[i].PositionX + GSpaceObjects[i].VelocityX * fDeltaTime;
      GSpaceObjects[i].PositionY := GSpaceObjects[i].PositionY + GSpaceObjects[i].VelocityY * fDeltaTime;

      {
      var TransformMatrix: TMatrix3D :=
        TMatrix3D.CreateScaling(TPoint3D.Create(GSpaceObjects[i].Mass, GSpaceObjects[i].Mass, 1.0)) *
        TMatrix3D.CreateTranslation(TVector3D.Create(GSpaceObjects[i].PositionX, GSpaceObjects[i].PositionY, 0.0));

      var ndctopleft:  TVector3D := TVector3D.Create(-0.5,  0.5, 0.0);
      var ndcbtmright: TVector3D := TVector3D.Create( 0.5, -0.5, 0.0);

      var topleft:  TVector3D := ndctopleft  * TransformMatrix * FViewProjectionMatrix;
      var btmright: TVector3D := ndcbtmright * TransformMatrix * FViewProjectionMatrix;

      {FPositionDictionary[GSpaceObjects[i].ID] := TRectF.Create(
        TPointF.Create(topLeft.X,  topLeft.Y),
        TPointF.Create(btmright.X, btmright.Y)
      );

      }
    end;

    var LocalTopLeft:  TVector3D := TVector3D.Create(-0.5,  0.5, 0.0);
    var LocalBtmRight: TVector3D := TVector3D.Create( 0.5, -0.5, 0.0);

    var Position: TVector3D := TVector3D.Create(
      GSpaceObjects[0].PositionX,
      GSpaceObjects[0].PositionY,
      0.0
    );

    var Scale: TPoint3D := TPoint3D.Create(
      GSpaceObjects[0].Mass,
      GSpaceObjects[0].Mass,
      0.0
    );

    var TransformMatrix: TMatrix3D := TMatrix3D.CreateScaling(Scale) * TMatrix3D.CreateTranslation(Position);

    var NDCTopLeft:  TVector3D := (localtopleft  * TransformMatrix) * FViewProjectionMatrix;
    var NDCBtmRight: TVector3D := (LocalBtmRight * TransformMatrix) * FViewProjectionMatrix;

    var screentopleft: TPointF := TPointF.Create(
      (NDCTopLeft.X + 1.0) * 0.5 * Width,
      (1.0 - NDCTopLeft.Y) * 0.5 * Height
    );

    var screenbtmright: TPointF := TPointF.Create(
      (NDCBtmRight.X + 1.0) * 0.5 * Width,
      (1.0 - NDCBtmRight.Y) * 0.5 * Height
    );

    FPositionDictionary[GSpaceObjects[0].ID] := TRectF.Create(
      TPointF.Create(screentopLeft.X,  screentopLeft.Y),
      TPointF.Create(screenbtmright.X, screenbtmright.Y)
    );

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

procedure TSimulationFrame.CameraMovement(fDeltaTime: float32);
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

procedure TSimulationFrame.PaintBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  FCameraZoomLevel := FCameraZoomLevel - (float32(WheelDelta) / 120.0) * 0.25 * FCameraZoomLevel;
  FCameraZoomLevel := Max(FCameraZoomLevel, 0.25);
  RecalculateViewProjectionMatrix();
end;

procedure TSimulationFrame.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
begin
  Canvas.BeginScene();

  for var spaceObj: TSpaceObject in GSpaceObjects do
  begin
    var rectf: TRectF := FPositionDictionary[spaceObj.ID];
    //Canvas.SetMatrix()

    Canvas.FillEllipse(rectf, 1.0, TBrush.Create(TBrushKind.Solid, TAlphaColors.Red));
    //Canvas.DrawEllipse(TRectF.Create(TPointF.Zero, TPointF.Create(Width, Height)), 1.0, TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Red));
  end;

  Canvas.EndScene();
end;

{$R *.fmx}

end.
