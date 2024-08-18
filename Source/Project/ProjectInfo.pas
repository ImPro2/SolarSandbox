unit ProjectInfo;

interface

type
  TProjectInfo = record
    sName: string;
    sPath: string;
  end;

  TNewProjectEvent  = procedure(Info: TProjectInfo) of object;
  TOpenProjectEvent = procedure(Info: TProjectInfo) of object;

implementation

end.
