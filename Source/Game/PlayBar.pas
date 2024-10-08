﻿unit PlayBar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Colors, FMX.Edit, FMX.EditBox,
  FMX.NumberBox, Quick.Logger;

type
  TGameStartEvent  = procedure() of object;
  TGameStopEvent   = procedure() of object;
  TGamePauseEvent  = procedure() of object;
  TGameResumeEvent = procedure() of object;

  TPlaybackSpeedChangedEvent = procedure(PlaybackSpeed: float32) of object;
  TOrbitTrajectoryCalculationStepCountChangedEvent = procedure(StepCount: int32) of object;

  TViewGridEvent = procedure() of object;
  THideGridevent = procedure() of object;

  TViewOrbitTrajectoryEvent = procedure(Relative: boolean) of object;
  THideOrbitTrajectoryEvent = procedure() of object;

  TPlayBarFrame = class(TFrame)
    pnlLeft: TPanel;
    pnlPlayStop: TPanel;
    pnlPauseResume: TPanel;
    imgPlay: TImage;
    imgStop: TImage;
    imgPause: TImage;
    imgResume: TImage;
    pnlRight: TPanel;
    nbPlaybackSpeed: TNumberBox;
    lblPlaybackSpeed: TLabel;
    btnViewRelativeOrbit: TSpeedButton;
    imgViewOrbit: TImage;
    btnViewGrid: TSpeedButton;
    nbOrbitCalcStepCount: TNumberBox;
    lblOrbitCalcStepCount: TLabel;
    pnlOrbitCalcStep: TPanel;
    btnViewAbsoluteOrbit: TSpeedButton;
    pnlViewOrbit: TPanel;
    imgViewAbsoluteOrbit: TImage;
    procedure pnlPlayStopClick(Sender: TObject);
    procedure pnlPauseResumeClick(Sender: TObject);
    procedure nbPlaybackSpeedChange(Sender: TObject);
    procedure btnViewRelativeOrbitClick(Sender: TObject);
    procedure btnViewGridClick(Sender: TObject);
    procedure pnlPlayStopMouseEnter(Sender: TObject);
    procedure pnlPlayStopMouseLeave(Sender: TObject);
    procedure btnViewGridMouseEnter(Sender: TObject);
    procedure pnlPauseResumeMouseEnter(Sender: TObject);
    procedure pnlPauseResumeMouseLeave(Sender: TObject);
    procedure btnViewGridMouseLeave(Sender: TObject);
    procedure btnViewRelativeOrbitMouseEnter(Sender: TObject);
    procedure btnViewRelativeOrbitMouseLeave(Sender: TObject);
    procedure nbOrbitCalcStepCountChange(Sender: TObject);
    procedure pnlOrbitCalcStepMouseEnter(Sender: TObject);
    procedure pnlOrbitCalcStepMouseLeave(Sender: TObject);
    procedure btnViewAbsoluteOrbitClick(Sender: TObject);
    procedure btnViewAbsoluteOrbitMouseEnter(Sender: TObject);
    procedure btnViewAbsoluteOrbitMouseLeave(Sender: TObject);

  public
    OnGameStart:  TGameStartEvent;
    OnGameStop:   TGameStopEvent;
    OnGamePause:  TGamePauseEvent;
    OnGameResume: TGameResumeEvent;

    OnPlaybackSpeedChange: TPlaybackSpeedChangedEvent;
    OnOrbitTrajectoryCalculationStepCountChanged: TOrbitTrajectoryCalculationStepCountChangedEvent;

    OnViewGrid: TViewGridEvent;
    OnHideGrid: THideGridEvent;

    OnViewOrbitTrajectory: TViewOrbitTrajectoryEvent;
    OnHideOrbitTrajectory: THideOrbitTrajectoryEvent;

    procedure Init();

  private
    FPlay, FPause, FViewGrid, FViewRelativeOrbit, FViewAbsoluteOrbit: boolean;
    FPopup: TPopup;
    FCalloutPanel: TCalloutPanel;
    FTooltipLabel: TLabel;

    procedure ShowTooltip(Tooltip: string; Target: TControl);
    procedure HideTooltip();
  end;

implementation

{$Region Public functions}

procedure TPlayBarFrame.Init();
begin
  FPlay      := False;
  FPause     := False;
  FViewGrid  := True;

  FViewRelativeOrbit := False;
  FViewAbsoluteOrbit := False;

  FPopup := TPopup.Create(Self);
  FPopup.Placement := TPlacement.Center;
  FPopup.Align := TAlignLayout.Client;

  FTooltipLabel := TLabel.Create(Self);
  FTooltipLabel.Parent := FPopup;
  FTooltipLabel.TextSettings.FontColor := TAlphaColors.Gray;
  FTooltipLabel.Width := 80;
end;

procedure TPlayBarFrame.ShowTooltip(Tooltip: string; Target: TControl);
begin
  FTooltipLabel.Text := Tooltip;
  FPopup.PlacementTarget := Target;

  FPopup.IsOpen := True;
end;

procedure TPlayBarFrame.HideTooltip();
begin
  Fpopup.IsOpen := False;
end;

{$EndRegion}

{$Region Events}

procedure TPlayBarFrame.pnlPlayStopMouseEnter(Sender: TObject);
begin
  ShowTooltip('Play/Stop', pnlPlayStop);
end;

procedure TPlayBarFrame.pnlPlayStopMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.pnlPauseResumeMouseEnter(Sender: TObject);
begin
  ShowTooltip('Pause/Resume', pnlPauseResume);
end;

procedure TPlayBarFrame.pnlPauseResumeMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.pnlOrbitCalcStepMouseEnter(Sender: TObject);
begin
  ShowTooltip('Number of Orbit Trajectory Calculation Steps', pnlOrbitCalcStep);
end;

procedure TPlayBarFrame.pnlOrbitCalcStepMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.btnViewGridMouseEnter(Sender: TObject);
begin
  ShowTooltip('View Grid', btnViewGrid);
end;

procedure TPlayBarFrame.btnViewGridMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.btnViewRelativeOrbitMouseEnter(Sender: TObject);
begin
  ShowTooltip('View Relative Orbital Trajectory', btnViewRelativeOrbit);
end;

procedure TPlayBarFrame.btnViewRelativeOrbitMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.btnViewAbsoluteOrbitMouseEnter(Sender: TObject);
begin
  ShowTooltip('View Absolute Orbital Trajectory', btnViewAbsoluteOrbit);
end;

procedure TPlayBarFrame.btnViewAbsoluteOrbitMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.pnlPlayStopClick(Sender: TObject);
begin
  FPlay := not FPlay;

  if FPlay then
  begin
    imgPlay.Visible := False;
    imgStop.Visible := True;

    pnlPauseResume.Enabled := True;

    if Assigned(OnGameStart) then
      OnGameStart();
  end else
  begin
    imgPlay.Visible := True;
    imgStop.Visible := False;

    FPause                 := False;
    pnlPauseResume.Enabled := False;

    if Assigned(OnGameStop) then
      OnGameStop();
  end;
end;

procedure TPlayBarFrame.pnlPauseResumeClick(Sender: TObject);
begin
  FPause := not FPause;

  if FPause then
  begin
    imgPause.Visible  := False;
    imgResume.Visible := True;

    if Assigned(OnGamePause) then
      OnGamePause();
  end else
  begin
    imgPause.Visible  := True;
    imgResume.Visible := False;

    if Assigned(OnGameResume) then
      OnGameResume();
  end;
end;

procedure TPlayBarFrame.nbPlaybackSpeedChange(Sender: TObject);
begin
  if Assigned(OnPlaybackSpeedChange) then
    OnPlaybackSpeedChange(nbPlaybackSpeed.Value);
end;

procedure TPlayBarFrame.nbOrbitCalcStepCountChange(Sender: TObject);
begin
  if Assigned(OnOrbitTrajectoryCalculationStepCountChanged) then
    OnOrbitTrajectoryCalculationStepCountChanged(Round(nbOrbitCalcStepCount.Value));
end;

procedure TPlayBarFrame.btnViewGridClick(Sender: TObject);
begin
  if not FViewGrid then
  begin
    if Assigned(OnViewGrid) then
      OnViewGrid();
  end else
  begin
    if Assigned(OnHideGrid) then
      OnHideGrid();
  end;

  FViewGrid := not FViewGrid;
end;

procedure TPlayBarFrame.btnViewRelativeOrbitClick(Sender: TObject);
begin
  if not FViewRelativeOrbit then
  begin
    FViewAbsoluteOrbit := False;
    btnViewAbsoluteOrbit.IsPressed := False;

    if Assigned(OnViewOrbitTrajectory) then
      OnViewOrbitTrajectory(True);
  end else
  begin
    if Assigned(OnHideOrbitTrajectory) then
      OnHideOrbitTrajectory();
  end;

  FViewRelativeOrbit := not FViewRelativeOrbit;
end;


procedure TPlayBarFrame.btnViewAbsoluteOrbitClick(Sender: TObject);
begin
  if not FViewAbsoluteOrbit then
  begin
    FViewRelativeOrbit := False;
    btnViewRelativeOrbit.IsPressed := False;

    if Assigned(OnViewOrbitTrajectory) then
      OnViewOrbitTrajectory(False);
  end else
  begin
    if Assigned(OnHideOrbitTrajectory) then
      OnHideOrbitTrajectory();
  end;
end;

{$EndRegion}

{$R *.fmx}

end.
