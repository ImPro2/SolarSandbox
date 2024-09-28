unit WindowsFunctions;

interface

uses Windows;

function IsLeftMouseButtonDown(): boolean;
function IsMiddleMouseButtonDown(): boolean;
function IsRightMouseButtonDown(): boolean;

function IsKeyDown(KeyCode: int32): boolean;
function IsKeyPressed(KeyCode: int32): boolean;

function GetSecondsPerCount(): float32;
function GetCurrentTime(): int64;

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

function GetSecondsPerCount(): float32;
begin
  var CountsPerSecond: int64;
  QueryPerformanceFrequency(CountsPerSecond);
  Result := 1.0 / float32(CountsPerSecond);
end;

function GetCurrentTime(): int64;
begin
  var CurrentTime: int64;
  QueryPerformanceCounter(CurrentTime);
  Result := CurrentTime;
end;

end.
