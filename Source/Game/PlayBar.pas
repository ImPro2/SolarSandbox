unit PlayBar;

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

  TViewGridEvent = procedure() of object;
  THideGridevent = procedure() of object;

  TViewOrbitTrajectoryEvent = procedure() of object;
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
    btnViewOrbit: TSpeedButton;
    imgViewOrbit: TImage;
    btnViewGrid: TSpeedButton;
    procedure pnlPlayStopClick(Sender: TObject);
    procedure pnlPauseResumeClick(Sender: TObject);
    procedure nbPlaybackSpeedChange(Sender: TObject);
    procedure btnViewOrbitClick(Sender: TObject);
    procedure btnViewGridClick(Sender: TObject);
    procedure pnlPlayStopMouseEnter(Sender: TObject);
    procedure pnlPlayStopMouseLeave(Sender: TObject);
    procedure btnViewGridMouseEnter(Sender: TObject);
    procedure pnlPauseResumeMouseEnter(Sender: TObject);
    procedure pnlPauseResumeMouseLeave(Sender: TObject);
    procedure btnViewGridMouseLeave(Sender: TObject);
    procedure btnViewOrbitMouseEnter(Sender: TObject);
    procedure btnViewOrbitMouseLeave(Sender: TObject);

  public
    OnGameStart:  TGameStartEvent;
    OnGameStop:   TGameStopEvent;
    OnGamePause:  TGamePauseEvent;
    OnGameResume: TGameResumeEvent;

    OnPlaybackSpeedChange: TPlaybackSpeedChangedEvent;

    OnViewGrid: TViewGridEvent;
    OnHideGrid: THideGridEvent;

    OnViewOrbitTrajectory: TViewOrbitTrajectoryEvent;
    OnHideOrbitTrajectory: THideOrbitTrajectoryEvent;

    procedure Init();

  private
    FPlay, FPause, FViewGrid, FViewOrbit: boolean;
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
  FViewOrbit := False;

  FPopup := TPopup.Create(Self);
  FPopup.Placement := TPlacement.Center;
  FPopup.Align := TAlignLayout.Client;

  FTooltipLabel := TLabel.Create(Self);
  FTooltipLabel.Parent := FPopup;
  FTooltipLabel.TextSettings.FontColor := TAlphaColors.Gray;
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

procedure TPlayBarFrame.btnViewGridMouseEnter(Sender: TObject);
begin
  ShowTooltip('View Grid', btnViewGrid);
end;

procedure TPlayBarFrame.btnViewGridMouseLeave(Sender: TObject);
begin
  HideTooltip();
end;

procedure TPlayBarFrame.btnViewOrbitMouseEnter(Sender: TObject);
begin
  ShowTooltip('View Orbital Trajectory', btnViewOrbit);
end;

procedure TPlayBarFrame.btnViewOrbitMouseLeave(Sender: TObject);
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

procedure TPlayBarFrame.btnViewOrbitClick(Sender: TObject);
begin
  if not FViewOrbit then
  begin
    if Assigned(OnViewOrbitTrajectory) then
      OnViewOrbitTrajectory();
  end else
  begin
    if Assigned(OnHideOrbitTrajectory) then
      OnHideOrbitTrajectory();
  end;

  FViewOrbit := not FViewOrbit;
end;

{$EndRegion}

{$R *.fmx}

end.
