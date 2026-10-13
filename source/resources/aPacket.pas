unit aPacket;

interface

function InitializePackageCollection: Boolean; // @addr $4829D4 @note "Creates the loose-file package and returns true regardless of OpenAllPackages' result."
function LoadConfiguredPackages: Boolean; // @addr $482A44 @note "Appends packages in language-mod, language, mod, then base order; existing entries are retained."
procedure FinalizePackageCollection; // @addr $482D04 @note "Requires an initialized package collection."

implementation

uses Classes, SyncObjs, EC_HsFile, EC_BlockPar, GR_Main;

{ @routine $4829D4 InitializePackageCollection }
function InitializePackageCollection: Boolean;
var Pack: TPackFileEC;
begin
  PackageFileLock := TCriticalSection.Create;
  Result := True;
  PackageCollection := nil;
  PackageCollection := TPackCollectionEC.Create;
  Pack := TPackFileEC.Create;
  Pack.UseLooseFiles := True;
  Pack.SetPackagePath('');
  PackageCollection.AddPackToFront(Pack);
  PackageCollection.OpenAllPackages;
end;
{ @end $4829D4 }

{ @routine $482A44 LoadConfiguredPackages }
function LoadConfiguredPackages: Boolean;
var Pack: TPackFileEC; Block: TBlockParEC; ParamIndex, ModIndex: Integer;
begin
  PackageCollection.CloseAllPackages;
  for ModIndex := 0 to ModLanguageInstallConfigs.Count - 1 do
  begin
    Block := ModLanguageInstallConfigs[ModIndex];
    Block := Block.GetBlock('Packages');
    for ParamIndex := 0 to Block.GetParamCount - 1 do
    begin
      Pack := TPackFileEC.Create;
      Pack.SetPackagePath(AnsiString(Block.GetParamValue(ParamIndex)));
      PackageCollection.AddPackToBack(Pack);
    end;
  end;
  Block := LanguageInstallConfig.GetBlock('Packages');
  for ParamIndex := 0 to Block.GetParamCount - 1 do
  begin
    Pack := TPackFileEC.Create;
    Pack.SetPackagePath(AnsiString(Block.GetParamValue(ParamIndex)));
    PackageCollection.AddPackToBack(Pack);
  end;
  for ModIndex := 0 to ModInstallConfigs.Count - 1 do
  begin
    Block := ModInstallConfigs[ModIndex];
    Block := Block.GetBlock('Packages');
    for ParamIndex := 0 to Block.GetParamCount - 1 do
    begin
      Pack := TPackFileEC.Create;
      Pack.SetPackagePath(AnsiString(Block.GetParamValue(ParamIndex)));
      PackageCollection.AddPackToBack(Pack);
    end;
  end;
  Block := InstallConfig.GetBlock('Packages');
  for ParamIndex := 0 to Block.GetParamCount - 1 do
  begin
    Pack := TPackFileEC.Create;
    Pack.SetPackagePath(AnsiString(Block.GetParamValue(ParamIndex)));
    PackageCollection.AddPackToBack(Pack);
  end;
  Result := PackageCollection.OpenAllPackages;
end;
{ @end $482A44 }

{ @routine $482D04 FinalizePackageCollection }
procedure FinalizePackageCollection;
begin
  PackageCollection.CloseAllPackages;
  PackageCollection.Clear(True);
  PackageCollection.Free;
  PackageCollection := nil;
  if PackageFileLock <> nil then
  begin
    PackageFileLock.Free;
    PackageFileLock := nil;
  end;
end;
{ @end $482D04 }

end.
