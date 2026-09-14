unit aModsInfo;
// Unit bracket (inferred): .text 0x005307A0..0x00532C2D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TModInfo RTTI and module-manager accesses establish the class layout.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_Image;

type
  TModInfo = class(TObjectEx) // @size $48
  public
    Folder: WideString; // @offset $04 Relative path beneath Mods.
    SwitchImage: TImageGI; // @offset $08 Borrowed module-manager control.
    IndexText: WideString; // @offset $0C Decimal index in ModInfos.
    Name: WideString; // @offset $10 Metadata ID; duplicates are permitted.
    Section: WideString; // @offset $14
    SmallDescription: WideString; // @offset $18
    FullDescription: WideString; // @offset $1C
    Author: WideString; // @offset $20
    DependencyNames: WideString; // @offset $24 Comma-separated IDs.
    DependencyCount: Integer; // @offset $28
    Dependencies: array of TModInfo; // @offset $2C Borrowed references.
    ConflictNames: WideString; // @offset $30 Comma-separated IDs.
    ConflictCount: Integer; // @offset $34
    Conflicts: array of TModInfo; // @offset $38 Borrowed references.
    Priority: Cardinal; // @offset $3C
    UnsupportedLanguage: Boolean; // @offset $40
    MissingFolder: Boolean; // @offset $41
    MissingDependency: Boolean; // @offset $42
    Misplaced: Boolean; // @offset $43 Reported as ProblemsInfoMisplaced by the module manager.
    DuplicateName: Boolean; // @offset $44
    ReferencedAsConflict: Boolean; // @offset $45
    ReferencedAsDependency: Boolean; // @offset $46
    Selected: Boolean; // @offset $47
    constructor Create; // @addr $5308C0 @ida "TModInfo *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $5309E8 @ida "void __usercall $name(TModInfo *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetDisplayName: WideString; // @addr $530A50 @ida "void __usercall $name(TModInfo *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetConflict(Index, VariantIndex: Integer): TModInfo; // @addr $530AAC
    function GetDependency(Index, VariantIndex: Integer): TModInfo; // @addr $530BB0
  end;

function FindOrInsertModFolder(Folder: WideString): Integer; // @addr $530CB4
function LoadModInfo(Folder: WideString; Info: TModInfo): Boolean; // @addr $53125C
procedure ScanModFolders(Folder, Prefix: WideString); // @addr $531F6C
procedure InitializeModInfos; // @addr $5321A8

var
  ModInfos: TList = nil; // @addr $87AA0C @note "Owns the TModInfo objects."
  SelectedModInfos: TList = nil; // @addr $87AA10 @note "Non-owning references into ModInfos."
  ModIdCounts: TBlockParEC = nil; // @addr $87AA14
  ModConflictIndex: TBlockParEC = nil; // @addr $87AA18 @note "Maps declared conflict IDs to matching mod indices."
  ModDependencyIndex: TBlockParEC = nil; // @addr $87AA1C @note "Maps required mod IDs to matching mod indices."
  ModInfosInitialized: Boolean = False; // @addr $87AA20

procedure ClearModInfoState; // @addr $532B8C @note "Frees mod objects and clears the existing containers, retaining their allocation for reload."

implementation

uses Windows, SysUtils, EC_Str, EC_Expression, GR_Main;


{ @routine $5308C0 TModInfo_Create }
constructor TModInfo.Create;
begin
  inherited Create;
  Folder := '';
  SwitchImage := nil;
  Name := '';
  Section := '';
  SmallDescription := '';
  FullDescription := '';
  Author := '';
  DependencyNames := '';
  DependencyCount := 0;
  SetLength(Dependencies, 0);
  ConflictNames := '';
  ConflictCount := 0;
  SetLength(Conflicts, 0);
  Priority := 0;
  UnsupportedLanguage := False;
  MissingFolder := False;
  MissingDependency := False;
  Misplaced := False;
  DuplicateName := False;
  ReferencedAsConflict := False;
  ReferencedAsDependency := False;
  Selected := False;
end;
{ @end $5308C0 }

{ @routine $5309E8 TModInfo_Destroy }
destructor TModInfo.Destroy;
begin
  SetLength(Dependencies, 0);
  SetLength(Conflicts, 0);
  inherited Destroy;
end;
{ @end $5309E8 }

{ @routine $530A50 TModInfo_GetDisplayName }
function TModInfo.GetDisplayName: WideString;
begin
  if Name <> '' then Result := Name
  else Result := '[' + Folder + ']';
end;
{ @end $530A50 }

{ @routine $530AAC TModInfo_GetConflict }
function TModInfo.GetConflict(Index, VariantIndex: Integer): TModInfo;
var
  Info: TModInfo;
  Indices: WideString;
  Count: Integer;
begin
  Result := nil;
  if (Index < 0) or (Index >= ConflictCount) then Exit;
  if VariantIndex = 0 then
  begin
    Result := Conflicts[Index];
    Exit;
  end;
  Info := Conflicts[Index];
  if not Info.DuplicateName then Exit;
  Indices := ModConflictIndex.GetParam(Info.Name);
  Count := CountDelimitedPartsW(Indices, ',');
  if (VariantIndex < 0) or (VariantIndex >= Count) then Exit;
  Result := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, VariantIndex, ','))]);
end;
{ @end $530AAC }

{ @routine $530BB0 TModInfo_GetDependency }
function TModInfo.GetDependency(Index, VariantIndex: Integer): TModInfo;
var
  Info: TModInfo;
  Indices: WideString;
  Count: Integer;
begin
  Result := nil;
  if (Index < 0) or (Index >= DependencyCount) then Exit;
  if VariantIndex = 0 then
  begin
    Result := Dependencies[Index];
    Exit;
  end;
  Info := Dependencies[Index];
  if not Info.DuplicateName then Exit;
  Indices := ModDependencyIndex.GetParam(Info.Name);
  Count := CountDelimitedPartsW(Indices, ',');
  if (VariantIndex < 0) or (VariantIndex >= Count) then Exit;
  Result := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, VariantIndex, ','))]);
end;
{ @end $530BB0 }

{ @routine $530CB4 FindOrInsertModFolder }
function FindOrInsertModFolder(Folder: WideString): Integer;
var
  Left, Right, Middle, Comparison: Integer;
  Info: TModInfo;
begin
  if ModInfos.Count < 1 then
  begin
    ModInfos.Add(nil);
    Result := 0;
    Exit;
  end;
  Left := 0;
  Info := TModInfo(ModInfos[0]);
  Comparison := CompareScriptNames(PWideChar(Folder), PWideChar(Info.Folder));
  if Comparison = 0 then
  begin
    Result := 0;
    Exit;
  end;
  if Comparison < 0 then
  begin
    ModInfos.Insert(0, nil);
    Result := 0;
    Exit;
  end;
  Right := ModInfos.Count - 1;
  Info := TModInfo(ModInfos[Right]);
  Comparison := CompareScriptNames(PWideChar(Folder), PWideChar(Info.Folder));
  if Comparison = 0 then
  begin
    Result := Right;
    Exit;
  end;
  if Comparison > 0 then
  begin
    ModInfos.Add(nil);
    Result := Right + 1;
    Exit;
  end;
  while True do
  begin
    if Right - Left < 2 then
    begin
      ModInfos.Insert(Right, nil);
      Result := Right;
      Exit;
    end;
    Middle := (Left + Right) div 2;
    Info := TModInfo(ModInfos[Middle]);
    Comparison := CompareScriptNames(PWideChar(Folder), PWideChar(Info.Folder));
    if Comparison = 0 then
    begin
      Result := Middle;
      Exit;
    end;
    if Comparison < 0 then Right := Middle else Left := Middle;
  end;
end;
{ @end $530CB4 }

{ @routine $53125C LoadModInfo }
function LoadModInfo(Folder: WideString; Info: TModInfo): Boolean;
var
  SavedDir: AnsiString;
  HasCommonResources, HasForeignResources, HasLanguageResources: Boolean;
  Block: TBlockParEC;
  Language, Languages: WideString;
  I, Count: Integer;

  // @nested $530E70 HasOtherLanguageResources
  function HasOtherLanguageResources: Boolean; // @addr $530E70 @ida "bool __usercall $name@<al>(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x53137E,0x5313C9,0x531A71,0x531B9A"
  var
    FileName: WideString;
    Handle: THandle;
    FindData: TWin32FindDataA;
  begin
    Result := False;
    FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
    Handle := Windows.FindFirstFile('*.txt', FindData);
    if Handle <> INVALID_HANDLE_VALUE then
    begin
      repeat
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
        begin
          FileName := WideString(FindData.cFileName);
          FileName := LowerCaseWideString(FileName);
          if (FileName <> LowerCaseWideString('install_' + SelectedLanguage + '.txt')) and
             (Length(FileName) > 12) and
             (FindTextOffsetW(FileName, 'install_') = 0) then
          begin
            Result := True;
            Windows.FindClose(Handle);
            Exit;
          end;
        end;
      until not Windows.FindNextFile(Handle, FindData);
      Windows.FindClose(Handle);
    end;
    if DirectoryExists(AnsiString(Folder + '\CFG')) then
    begin
      try
        SetCurrentDir(AnsiString(Folder + '\CFG'));
        FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
        Handle := Windows.FindFirstFile('*.*', FindData);
        if Handle <> INVALID_HANDLE_VALUE then
        begin
          repeat
            if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
            begin
              FileName := WideString(FindData.cFileName);
              if (FileName <> '.') and (FileName <> '..') and
                 (LowerCaseWideString(FileName) <> LowerCaseWideString(LanguageInstallConfig.GetParam('Lang'))) and
                 SysUtils.FileExists(AnsiString(FileName + '\Lang.dat')) then
              begin
                Result := True;
                Windows.FindClose(Handle);
                Exit;
              end;
            end;
          until not Windows.FindNextFile(Handle, FindData);
          Windows.FindClose(Handle);
        end;
      finally
        SetCurrentDir(AnsiString(Folder));
      end;
    end;
  end;

begin
  HasForeignResources := False;
  HasLanguageResources := False;
  HasCommonResources := False;
  Block := nil;
  SavedDir := GetCurrentDir;
  try
    SetCurrentDir(AnsiString(Folder));
    if SysUtils.FileExists('install.txt') or
       SysUtils.FileExists('CFG\Main.dat') or
       SysUtils.FileExists('CFG\CacheData.dat') then HasCommonResources := True;
    Language := LanguageInstallConfig.GetParam('Lang');
    if SysUtils.FileExists(AnsiString('install_' + SelectedLanguage + '.txt')) or
       SysUtils.FileExists(AnsiString('CFG\' + Language + '\Lang.dat')) then HasLanguageResources := True;
    if not HasCommonResources and not HasLanguageResources then HasForeignResources := HasOtherLanguageResources;
    Result := (HasCommonResources or HasLanguageResources) or HasForeignResources;
    if not SysUtils.FileExists('ModuleInfo.txt') then
    begin
      if not Result then Exit;
      if not HasLanguageResources then
      begin
        if not HasForeignResources then HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end;
      Exit;
    end;
    Block := TBlockParEC.Create;
    try
      Block.LoadFromTextFileWithEncodingProbe('ModuleInfo.txt', False);
      if not Result then
      begin
        if Block.CountParams('NoNormalResources') <= 0 then
        begin
          Block.Free;
          Block := nil;
          Exit;
        end;
        Result := True;
      end;
      if Block.CountParams('Name') > 0 then Info.Name := TrimWideString(Block.GetParam('Name'));
      if Block.CountParams('Section' + Language) > 0 then
        Info.Section := TrimWideString(Block.GetParam('Section' + Language))
      else if Block.CountParams('Section') > 0 then
        Info.Section := TrimWideString(Block.GetParam('Section'));
      if Block.CountParams('SmallDescription' + Language) > 0 then
      begin
        Count := Block.CountParams('SmallDescription' + Language);
        Info.SmallDescription := Block.GetParamByPath('SmallDescription' + Language + ':0');
        for I := 1 to Count - 1 do
          Info.SmallDescription := Info.SmallDescription + #13#10 + Block.GetParamByPath('SmallDescription' + Language + ':' + IntToWideString(I));
      end
      else if Block.CountParams('SmallDescription') > 0 then
      begin
        Count := Block.CountParams('SmallDescription');
        Info.SmallDescription := Block.GetParamByPath('SmallDescription:0');
        for I := 1 to Count - 1 do
          Info.SmallDescription := Info.SmallDescription + #13#10 + Block.GetParamByPath('SmallDescription:' + IntToWideString(I));
      end;
      if Block.CountParams('FullDescription' + Language) > 0 then
      begin
        Count := Block.CountParams('FullDescription' + Language);
        Info.FullDescription := Block.GetParamByPath('FullDescription' + Language + ':0');
        for I := 1 to Count - 1 do
          Info.FullDescription := Info.FullDescription + #13#10 + Block.GetParamByPath('FullDescription' + Language + ':' + IntToWideString(I));
      end
      else if Block.CountParams('FullDescription') > 0 then
      begin
        Count := Block.CountParams('FullDescription');
        Info.FullDescription := Block.GetParamByPath('FullDescription:0');
        for I := 1 to Count - 1 do
          Info.FullDescription := Info.FullDescription + #13#10 + Block.GetParamByPath('FullDescription:' + IntToWideString(I));
      end;
      if Block.CountParams('Author' + Language) > 0 then
        Info.Author := TrimWideString(Block.GetParam('Author' + Language))
      else if Block.CountParams('Author') > 0 then
        Info.Author := TrimWideString(Block.GetParam('Author'));
      if Block.CountParams('Languages') > 0 then
      begin
        Info.UnsupportedLanguage := True;
        Language := WideString(LowerCase(AnsiString(Language)));
        Languages := TrimWideString(Block.GetParam('Languages'));
        Count := CountDelimitedPartsW(Languages, ',');
        if Languages <> '' then
          for I := 0 to Count - 1 do
            if WideString(LowerCase(AnsiString(TrimWideString(ExtractDelimitedPartW(Languages, I, ','))))) = Language then
            begin
              Info.UnsupportedLanguage := False;
              Break;
            end;
      end
      else if not HasLanguageResources then
      begin
        if not HasForeignResources then HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end;
      if Block.CountParams('Dependence') > 0 then Info.DependencyNames := TrimWideString(Block.GetParam('Dependence'));
      if Block.CountParams('Conflict') > 0 then Info.ConflictNames := TrimWideString(Block.GetParam('Conflict'));
      if Block.CountParams('Priority') > 0 then Info.Priority := ExtractDigitsToIntW(Block.GetParam('Priority'));
    except
      Info.Name := '';
      Info.Section := '';
      Info.SmallDescription := '';
      Info.FullDescription := '';
      Info.Author := '';
      if not HasLanguageResources then
      begin
        if not HasForeignResources then HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end
      else Info.UnsupportedLanguage := True;
      Info.DependencyNames := '';
      Info.ConflictNames := '';
      Info.Priority := 0;
    end;
  finally
    SetCurrentDir(SavedDir);
    if Block <> nil then Block.Free;
  end;
end;
{ @end $53125C }

{ @routine $531F6C ScanModFolders }
procedure ScanModFolders(Folder, Prefix: WideString);
var
  FileName: WideString;
  Path, ChildPrefix: WideString;
  Handle: THandle;
  Info: TModInfo;
  Index: Integer;
  FindData: TWin32FindDataA;
begin
  Info := TModInfo.Create;
  SetCurrentDir(AnsiString(Folder));
  FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
  Handle := Windows.FindFirstFile('*.*', FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      begin
        FileName := WideString(FindData.cFileName);
        if (FileName <> '.') and (FileName <> '..') then
        begin
          Path := Folder + '\' + FileName;
          if LoadModInfo(Path, Info) then
          begin
            Info.Folder := Prefix + FileName;
            Index := FindOrInsertModFolder(Info.Folder);
            ModInfos[Index] := Info;
            if Info.Name <> '' then
            begin
              if ModIdCounts.CountParams(Info.Name) <= 0 then ModIdCounts.AddParam(Info.Name, '1')
              else ModIdCounts.SetOrAddParam(Info.Name, '0');
            end;
            Info := TModInfo.Create;
          end
          else
          begin
            ChildPrefix := Prefix + FileName + '\';
            ScanModFolders(Path, ChildPrefix);
          end;
        end;
      end;
    until not Windows.FindNextFile(Handle, FindData);
    Windows.FindClose(Handle);
  end;
  Info.Free;
end;
{ @end $531F6C }

{ @routine $5321A8 InitializeModInfos }
procedure InitializeModInfos;
var
  SavedDir: AnsiString;
  Folder, Name, Names, Indices: WideString;
  I, J, Index, Count: Integer;
  Info: TModInfo;
begin
  if ModInfosInitialized then Exit;
  if ModInfos = nil then ModInfos := TList.Create;
  if SelectedModInfos = nil then SelectedModInfos := TList.Create;
  if ModIdCounts = nil then ModIdCounts := TBlockParEC.Create;
  if ModConflictIndex = nil then ModConflictIndex := TBlockParEC.Create;
  if ModDependencyIndex = nil then ModDependencyIndex := TBlockParEC.Create;
  SavedDir := GetCurrentDir;
  Folder := WideString(SavedDir);
  Folder := Folder + '\Mods';
  ScanModFolders(Folder, '');
  SetCurrentDir(SavedDir);
  if SelectedMods <> '' then
  begin
    Names := SelectedMods;
    Names := ReplaceAllWideString(Names, '/', '\');
    Count := CountDelimitedPartsW(Names, ',');
    for I := 0 to Count - 1 do
    begin
      Name := TrimWideString(ExtractDelimitedPartW(Names, I, ','));
      if Name <> '' then
      begin
        Index := FindOrInsertModFolder(Name);
        if ModInfos[Index] <> nil then
        begin
          Info := TModInfo(ModInfos[Index]);
          SelectedModInfos.Add(Info);
          Info.Selected := True;
        end
        else
        begin
          Info := TModInfo.Create;
          ModInfos[Index] := Info;
          SelectedModInfos.Add(Info);
          if DirectoryExists(AnsiString(Folder + '\' + Name)) and LoadModInfo(Folder + '\' + Name, Info) then
          begin
            Info.Folder := Name;
            if Info.Name <> '' then
            begin
              if ModIdCounts.CountParams(Info.Name) <= 0 then ModIdCounts.AddParam(Info.Name, '1')
              else ModIdCounts.SetOrAddParam(Info.Name, '0');
            end;
          end
          else
          begin
            Info.Folder := Name;
            Info.MissingFolder := True;
            Info.Selected := True;
          end;
        end;
      end;
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    Info.IndexText := IntToWideString(I);
    if Info.Name <> '' then Info.DuplicateName := ModIdCounts.GetParam(Info.Name) <> '1';
    if Info.ConflictNames <> '' then
    begin
      Count := CountDelimitedPartsW(Info.ConflictNames, ',');
      for J := 0 to Count - 1 do
      begin
        Indices := TrimWideString(ExtractDelimitedPartW(Info.ConflictNames, J, ','));
        if ModConflictIndex.CountParams(Indices) <= 0 then ModConflictIndex.AddParam(Indices, '');
      end;
    end;
    if Info.DependencyNames <> '' then
    begin
      Count := CountDelimitedPartsW(Info.DependencyNames, ',');
      for J := 0 to Count - 1 do
      begin
        Indices := TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, J, ','));
        if ModDependencyIndex.CountParams(Indices) <= 0 then ModDependencyIndex.AddParam(Indices, '');
      end;
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.Name = '' then Continue;
    if ModConflictIndex.CountParams(Info.Name) > 0 then
    begin
      Indices := ModConflictIndex.GetParam(Info.Name);
      if Indices = '' then ModConflictIndex.SetParam(Info.Name, IntToWideString(I))
      else ModConflictIndex.SetParam(Info.Name, Indices + ',' + IntToWideString(I));
    end;
    if ModDependencyIndex.CountParams(Info.Name) > 0 then
    begin
      Indices := ModDependencyIndex.GetParam(Info.Name);
      if Indices = '' then ModDependencyIndex.SetParam(Info.Name, IntToWideString(I))
      else ModDependencyIndex.SetParam(Info.Name, Indices + ',' + IntToWideString(I));
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.DependencyNames = '' then Continue;
    Info.DependencyCount := CountDelimitedPartsW(Info.DependencyNames, ',');
    SetLength(Info.Dependencies, Info.DependencyCount);
    for J := 0 to Info.DependencyCount - 1 do
    begin
      Indices := TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, J, ','));
      Indices := ModDependencyIndex.GetParam(Indices);
      if Indices = '' then
      begin
        Info.MissingDependency := True;
        Info.Dependencies[J] := nil;
      end
      else Info.Dependencies[J] := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, 0, ','))]);
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.ConflictNames = '' then Continue;
    Info.ConflictCount := CountDelimitedPartsW(Info.ConflictNames, ',');
    SetLength(Info.Conflicts, Info.ConflictCount);
    for J := 0 to Info.ConflictCount - 1 do
    begin
      Indices := TrimWideString(ExtractDelimitedPartW(Info.ConflictNames, J, ','));
      Indices := ModConflictIndex.GetParam(Indices);
      if Indices = '' then
      begin
        Info.Conflicts[J] := nil;
      end
      else Info.Conflicts[J] := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, 0, ','))]);
    end;
  end;
  for I := 0 to ModConflictIndex.GetParamCount - 1 do
  begin
    Indices := ModConflictIndex.GetParamValue(I);
    Count := CountDelimitedPartsW(Indices, ',');
    for J := 0 to Count - 1 do
    begin
      Index := ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, J, ','));
      TModInfo(ModInfos[Index]).ReferencedAsConflict := True;
    end;
  end;
  for I := 0 to ModDependencyIndex.GetParamCount - 1 do
  begin
    Indices := ModDependencyIndex.GetParamValue(I);
    Count := CountDelimitedPartsW(Indices, ',');
    for J := 0 to Count - 1 do
    begin
      Index := ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, J, ','));
      TModInfo(ModInfos[Index]).ReferencedAsDependency := True;
    end;
  end;
  ModInfosInitialized := True;
end;
{ @end $5321A8 }

{ @routine $532B8C ClearModInfoState }
procedure ClearModInfoState;
var Index: Integer;
begin
  ModInfosInitialized := False;
  if ModInfos <> nil then
  begin
    for Index := 0 to ModInfos.Count - 1 do TObject(ModInfos[Index]).Free;
    ModInfos.Clear;
  end;
  if SelectedModInfos <> nil then SelectedModInfos.Clear;
  if ModIdCounts <> nil then ModIdCounts.Clear;
  if ModConflictIndex <> nil then ModConflictIndex.Clear;
  if ModDependencyIndex <> nil then ModDependencyIndex.Clear;
end;
{ @end $532B8C }

end.
