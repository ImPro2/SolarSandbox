unit PlayBar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Colors;

type
  TGameStartEvent  = procedure() of object;
  TGameStopEvent   = procedure() of object;
  TGamePauseEvent  = procedure() of object;
  TGameResumeEvent = procedure() of object;

  TPlayBarFrame = class(TFrame)
    pnlLeft: TPanel;
    pnlPlayStop: TPanel;
    pnlPauseResume: TPanel;
    imgPlay: TImage;
    imgStop: TImage;
    imgPause: TImage;
    imgResume: TImage;
    pnlRight: TPanel;
    procedure pnlPlayStopClick(Sender: TObject);
    procedure pnlPauseResumeClick(Sender: TObject);

  public
    OnGameStart:  TGameStartEvent;
    OnGameStop:   TGameStopEvent;
    OnGamePause:  TGamePauseEvent;
    OnGameResume: TGameResumeEvent;

    procedure Init();

  private
    FPlay, FPause: boolean;
  end;

implementation

procedure TPlayBarFrame.Init();
begin
  FPlay  := False;
  FPause := False;


end;

{$R *.fmx}

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

end.
