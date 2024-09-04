unit SpaceObject;

interface

type

  TSpaceObject = record
    PositionX, PositionY: float32;
    VelocityX, VelocityY: float32;
    Mass: float32;
    Name: string;
    ID: uint64;
    Notes: string;

    constructor Create(sName: string);
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
