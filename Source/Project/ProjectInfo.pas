unit ProjectInfo;

interface

uses SpaceObject, Neslib.Yaml, System.SysUtils;

type
  TProjectInfo = record
    sName: string;
    sPath: string;
    SpaceObjects: TSpaceObjectList;
  end;

  TNewProjectEvent  = procedure(Info: TProjectInfo) of object;
  TOpenProjectEvent = procedure(Info: TProjectInfo) of object;

  procedure SerializeProject(ProjectInfo: TProjectInfo);
  procedure DeserializeProject(var ProjectInfo: TProjectInfo);

implementation

procedure SerializeProject(ProjectInfo: TProjectInfo);
begin
  var Doc: IYamlDocument := TYamlDocument.CreateMapping();

  Doc.Root.AddOrSetValue('Name', ProjectInfo.sName);

  var SpaceObjectSequence: TYamlNode := Doc.Root.AddOrSetSequence('Space Objects');
  for var SpaceObject in ProjectInfo.SpaceObjects do
  begin
    var SpaceObjectMapping: TYamlNode := SpaceObjectSequence.AddMapping();

    SpaceObjectMapping.AddOrSetValue('Name', SpaceObject.Name);
    SpaceObjectMapping.AddOrSetValue('ID', SpaceObject.ID);
    SpaceObjectMapping.AddOrSetValue('Mass', FloatToStr(SpaceObject.Mass));
    SpaceObjectMapping.AddOrSetValue('PositionX', FloatToStr(SpaceObject.PositionX));
    SpaceObjectMapping.AddOrSetValue('PositionY', FloatToStr(SpaceObject.PositionY));
    SpaceObjectMapping.AddOrSetValue('VelocityX', FloatToStr(SpaceObject.VelocityX));
    SpaceObjectMapping.AddOrSetValue('VelocityY', FloatToStr(SpaceObject.VelocityY));
  end;

  Doc.Save(ProjectInfo.sPath);
end;

procedure DeserializeProject(var ProjectInfo: TProjectInfo);
begin
  var Doc: IYamlDocument := TYamlDocument.Load(ProjectInfo.sPath);

  ProjectInfo.sName := Doc.Root.Values['Name'];

  var SpaceObjectsMapping: TYamlNode := Doc.Root.Values['Space Objects'];

  SetLength(ProjectInfo.SpaceObjects, SpaceObjectsMapping.Count);

  for var i: int32 := 0 to Length(ProjectInfo.SpaceObjects) - 1 do
  begin
    var SpaceObject: TSpaceObject;
    var SpaceObjectNode: TYamlNode := SpaceObjectsMapping.Nodes[i];

    SpaceObject.Name      := SpaceObjectNode.Values['Name'];
    SpaceObject.ID        := SpaceObjectNode.Values['ID'];
    SpaceObject.Mass      := SpaceObjectNode.Values['Mass'];
    SpaceObject.PositionX := SpaceObjectNode.Values['PositionX'];
    SpaceObject.PositionY := SpaceObjectNode.Values['PositionY'];
    SpaceObject.VelocityX := SpaceObjectNode.Values['VelocityX'];
    SpaceObject.VelocityY := SpaceObjectNode.Values['VelocityY'];

    ProjectInfo.SpaceObjects[i] := SpaceObject;
  end;
end;

end.
