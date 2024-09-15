unit WindowsFunctions;

interface

uses Windows;

function IsRightMouseButtonDown(): boolean;

implementation

function IsRightMouseButtonDown(): boolean;
begin
  Result := ((GetKeyState(VK_RBUTTON) and $80) <> 0);
end;

end.
