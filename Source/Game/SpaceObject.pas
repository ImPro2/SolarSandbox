unit SpaceObject;

interface

type

  TSpaceObject = record
    PositionX, PositionY: float32;
    VelocityX, VelocityY: float32;
    Mass: float32;
    Name: string;
    ID: uint64;

    constructor Create(sName: string);
  end;

  TSpaceObjectList = array of TSpaceObject;

  TAddSpaceObjectEvent    = procedure(SpaceObject: TSpaceObject) of object;
  TRemoveSpaceObjectEvent = procedure(SpaceObject: TSpaceObject) of object;

  TSpaceObjectSelectedEvent = procedure(SpaceObject: TSpaceObject) of object;

var
  GSpaceObjects: TSpaceObjectList;

implementation

constructor TSpaceObject.Create(sName: string);
begin
  Name := sName;
  ID := Random(MaxLongInt);
end;

end.
