unit ProjectTemplateItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects,
  ProjectInfo;

type
  TProjectTemplateItemSelectedEvent = procedure(ProjectInfo: TProjectInfo) of object;
  TProjectTemplateItemOpenedEvent   = procedure(ProjectInfo: TProjectInfo) of object;

  TProjectTemplateItemFrame = class(TFrame)
    imgThumbnail: TImage;
    lblCaption: TLabel;
    Button: TButton;
    procedure ButtonDblClick(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
  public
    SelectedEvent: TProjectTemplateItemSelectedEvent;
    OpenedEvent:   TProjectTemplateItemOpenedEvent;

    procedure Init(ProjectInfo: TProjectInfo);
  private
    FProjectInfo: TProjectInfo;
  end;

implementation

procedure TProjectTemplateItemFrame.Init(ProjectInfo: TProjectInfo);
begin
  FProjectInfo := ProjectInfo;
  lblCaption.Text := ProjectInfo.sName;
  imgThumbnail.Bitmap := TBitmap.CreateFromFile(ProjectInfo.ThumbnailPath);
end;

procedure TProjectTemplateItemFrame.ButtonClick(Sender: TObject);
begin
  if Assigned(SelectedEvent) then
    SelectedEvent(FProjectInfo);
end;

procedure TProjectTemplateItemFrame.ButtonDblClick(Sender: TObject);
begin
  if Assigned(OpenedEvent) then
    OpenedEvent(FProjectInfo);
end;

{$R *.fmx}

end.
