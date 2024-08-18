unit ProjectSerializer;

interface

uses
  Quick.YAML, Quick.YAML.Serializer,
  Quick.Console, Quick.Logger,
  ProjectInfo;

type
  TProjectSerializer = object
  public
    constructor Create(const ProjectInfo: TProjectInfo);

  public
    procedure Serialize();
    function  Deserialize(): TProjectInfo;
  private
    FProjectInfo: TProjectInfo;
  end;

implementation

constructor TProjectSerializer.Create(const ProjectInfo: TProjectInfo);
begin
  FProjectInfo := ProjectInfo;
end;

procedure TProjectSerializer.Serialize();
begin
  //var serializer: TYamlSerializer := TYamlSerializer.Create(slPublicProperty, True);
  //var text: string := serializer.ObjectToYaml(FProjectInfo);

  //Logger.Debug(text);
end;

function TProjectSerializer.Deserialize(): TProjectInfo;
begin

end;

end.
