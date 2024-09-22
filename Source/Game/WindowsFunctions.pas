unit WindowsFunctions;

interface

uses Windows;

function IsLeftMouseButtonDown(): boolean;
function IsMiddleMouseButtonDown(): boolean;
function IsRightMouseButtonDown(): boolean;

function IsKeyDown(KeyCode: int32): boolean;
function IsKeyPressed(KeyCode: int32): boolean;

implementation

function IsLeftMouseButtonDown(): boolean;
begin
  Result := ((GetKeyState(VK_LBUTTON) and $80) <> 0);
end;

function IsMiddleMouseButtonDown(): boolean;
begin
  Result := ((GetKeyState(VK_MBUTTON) and $80) <> 0);
end;

function IsRightMouseButtonDown(): boolean;
begin
  Result := ((GetKeyState(VK_RBUTTON) and $80) <> 0);
end;

function IsKeyDown(KeyCode: int32): boolean;
begin
  Result := ((GetKeyState(KeyCode) and $80) <> 0);
end;

function IsKeyPressed(KeyCode: int32): boolean;
begin
  Result := (GetKeyState(KeyCode)) <> 0;
end;

end.
