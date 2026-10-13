unit Registry;

interface

type
  TRegistry = class(TObject) // @size 0x1C
  public
    constructor Create; // @addr $41D6AC @note "No-argument overload: HKCU, KEY_ALL_ACCESS and lazy writes."
    property RootKey: Cardinal write SetRootKey;
    function KeyExists(const Key: AnsiString): Boolean; // @addr $41DB7C
    function GetKey(const Key: AnsiString): Cardinal; // @addr $41DAE4 @note "Private SDK helper used by KeyExists; preserves the current key."
    function GetBaseKey(Relative: Boolean): Cardinal; // @addr $41D79C
    procedure CloseKey;
    procedure SetRootKey(Value: Cardinal);
    procedure ChangeKey(Value: Cardinal; const Path: AnsiString);
    function OpenKeyReadOnly(const Key: AnsiString): Boolean;
    function GetDataInfo(const ValueName: AnsiString; var Value: TRegDataInfo): Boolean;
    function GetDataSize(const ValueName: AnsiString): Integer;
    function ReadString(const Name: AnsiString): AnsiString;
    function GetData(const Name: AnsiString; Buffer: Pointer; BufSize: Integer; var RegData: TRegDataType): Integer;
  end;

  TRegDataInfo = record;

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary); // @size 0x1

function IsRelative(const Value: AnsiString): Boolean;

implementation
end.
