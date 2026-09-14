program ProgramStartup;
{$APPTYPE GUI}{$O-}{$I-}
uses SysUtils;
var
  ProgramFile: TextFile; // @addr $3000
  ProgramLine: AnsiString; // @addr $3200
{ @routine $2000 start }
begin
  AssignFile(ProgramFile, 'Lang.txt');
  Reset(ProgramFile);
  while not Eof(ProgramFile) do Readln(ProgramFile, ProgramLine);
  CloseFile(ProgramFile);
end.
{ @end $2000 }
