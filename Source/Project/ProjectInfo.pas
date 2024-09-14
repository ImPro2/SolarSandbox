unit ProjectInfo;

interface

uses SpaceObject;

type
  TProjectInfo = record
    sName: string;
    sPath: string;
    SpaceObjects: TSpaceObjectList;
  end;

  TNewProjectEvent  = procedure(Info: TProjectInfo) of object;
  TOpenProjectEvent = procedure(Info: TProjectInfo) of object;

implementation

end.
