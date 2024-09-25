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
    function RadiusFromMass(): float32;
  end;

  TSpaceObjectList = array of TSpaceObject;

  function SpaceObjectFromID(ID: uint32): TSpaceObject;
  function SpaceObjectIndexFromID(ID: uint32): int32;

var
  GSpaceObjects: TSpaceObjectList;

implementation

constructor TSpaceObject.Create(sName: string);
begin
  Name := sName;
  ID   := Random(MaxLongInt);
  Mass := 10;
end;

function TSpaceObject.RadiusFromMass(): float32;
begin
  Result := Mass * 0.1 * 0.5;
end;

function SpaceObjectFromID(ID: uint32): TSpaceObject;
begin
  var spaceObj: TSpaceObject;
  for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
  begin
    if GSpaceObjects[i].ID = ID then
    begin
      spaceObj := GSpaceObjects[i];
      break;
    end;
  end;

  Result := spaceObj;
end;

function SpaceObjectIndexFromID(ID: uint32): int32;
begin
  var idx: int32;
  for var i: int32 := 0 to Length(GSpaceObjects) - 1 do
  begin
    if GSpaceObjects[i].ID = ID then
    begin
      idx := i;
      break;
    end;
  end;

  Result := idx;
end;

end.
