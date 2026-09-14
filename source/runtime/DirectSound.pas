unit DirectSound;
// Unit bracket (inferred): .text 0x00472C18..0x00472C90; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

const
  DS_OK = 0;
  DS_NO_VIRTUALIZATION = 142082058;
  DS_INCOMPLETE = 142082068;
  DSERR_ALLOCATED = -2005401590;
  DSERR_CONTROLUNAVAIL = -2005401570;
  DSERR_INVALIDPARAM = -2147024809;
  DSERR_INVALIDCALL = -2005401550;
  DSERR_GENERIC = -2147467259;
  DSERR_PRIOLEVELNEEDED = -2005401530;
  DSERR_OUTOFMEMORY = -2147024882;
  DSERR_BADFORMAT = -2005401500;
  DSERR_UNSUPPORTED = -2147467263;
  DSERR_NODRIVER = -2005401480;
  DSERR_ALREADYINITIALIZED = -2005401470;
  DSERR_NOAGGREGATION = -2147221232;
  DSERR_BUFFERLOST = -2005401450;
  DSERR_OTHERAPPHASPRIO = -2005401440;
  DSERR_UNINITIALIZED = -2005401430;
  DSERR_NOINTERFACE = -2147467262;
  DSERR_ACCESSDENIED = -2147024891;
  DSERR_BUFFERTOOSMALL = -2005401420;
  DSERR_DS8_REQUIRED = -2005401410;
  DSERR_SENDLOOP = -2005401400;
  DSERR_BADSENDBUFFERGUID = -2005401390;
  DSERR_OBJECTNOTFOUND = -2005397151;
  DSERR_FXUNAVAILABLE = -2005401380;

  DSBCAPS_PRIMARYBUFFER = $00000001;
  DSBCAPS_STATIC = $00000002;
  DSBCAPS_LOCSOFTWARE = $00000008;
  DSBCAPS_CTRLPAN = $00000040;
  DSBCAPS_CTRLVOLUME = $00000080;
  DSBCAPS_CTRLPOSITIONNOTIFY = $00000100;
  DSBCAPS_GETCURRENTPOSITION2 = $00010000;
  DSBPLAY_LOOPING = 1;
  DSBLOCK_ENTIREBUFFER = 2;
  DSBSTATUS_PLAYING = 1;
  DSSCL_PRIORITY = 2;
  DSBVOLUME_MIN = -10000;
  DSBPAN_LEFT = -10000;
  DSBPAN_RIGHT = 10000;

type
  // The engine copies 20 bytes, including the aligned wave-format tail.
  TSoundWaveFormat = record // @size 0x14
    FormatTag: Word; // @offset 0
    Channels: Word; // @offset 2
    SamplesPerSecond: Cardinal; // @offset 4
    AverageBytesPerSecond: Cardinal; // @offset 8
    BlockAlign: Word; // @offset 12
    BitsPerSample: Word; // @offset 14
    ExtraSize: Word; // @offset 16
  end;

  TDSBufferDesc = record // @size 0x24
    Size: Cardinal; // @offset 0
    Flags: Cardinal; // @offset 4
    BufferBytes: Cardinal; // @offset 8
    Reserved: Cardinal; // @offset 12
    WaveFormat: Pointer; // @offset 16
    Algorithm: TGUID; // @offset 20
  end;
  PDSPositionNotify = ^TDSPositionNotify;
  TDSPositionNotify = record // @size 8
    Offset: Cardinal; // @offset 0
    EventHandle: Cardinal; // @offset 4
  end;

  IDirectSoundBuffer = interface;
  IDirectSound = interface(IInterface)
    ['{279AFA83-4981-11CE-A521-0020AF0BE560}']
    function CreateSoundBuffer(const Desc: TDSBufferDesc; out Buffer: IDirectSoundBuffer; Outer: IInterface): LongInt; stdcall; // @ida "int __stdcall $name(IDirectSound *Self, const TDSBufferDesc *Desc, IDirectSoundBuffer **Buffer, IInterface *Outer);"
    function GetCaps(Caps: Pointer): LongInt; stdcall;
    function DuplicateSoundBuffer(Original: IDirectSoundBuffer; out Duplicate: IDirectSoundBuffer): LongInt; stdcall;
    function SetCooperativeLevel(Window: Cardinal; Level: Cardinal): LongInt; stdcall;
    function Compact: LongInt; stdcall;
    function GetSpeakerConfig(out Configuration: Cardinal): LongInt; stdcall;
    function SetSpeakerConfig(Configuration: Cardinal): LongInt; stdcall;
    function Initialize(Guid: Pointer): LongInt; stdcall;
  end;

  IDirectSoundBuffer = interface(IInterface)
    ['{279AFA85-4981-11CE-A521-0020AF0BE560}']
    function GetCaps(Caps: Pointer): LongInt; stdcall;
    function GetCurrentPosition(PlayCursor, WriteCursor: PCardinal): LongInt; stdcall;
    function GetFormat(Format: Pointer; Size: Cardinal; Written: PCardinal): LongInt; stdcall;
    function GetVolume(out Volume: Integer): LongInt; stdcall;
    function GetPan(out Pan: Integer): LongInt; stdcall;
    function GetFrequency(out Frequency: Cardinal): LongInt; stdcall;
    function GetStatus(out Status: Cardinal): LongInt; stdcall;
    function Initialize(DirectSound: Pointer; const Desc: TDSBufferDesc): LongInt; stdcall; // @ida "int __stdcall $name(IDirectSoundBuffer *Self, void *DirectSound, const TDSBufferDesc *Desc);"
    function Lock(Offset, Bytes: Cardinal; Audio1: PPointer; Bytes1: PCardinal; Audio2: PPointer; Bytes2: PCardinal; Flags: Cardinal): LongInt; stdcall;
    function Play(Reserved1, Reserved2, Flags: Cardinal): LongInt; stdcall;
    function SetCurrentPosition(Position: Cardinal): LongInt; stdcall;
    function SetFormat(Format: Pointer): LongInt; stdcall;
    function SetVolume(Volume: Integer): LongInt; stdcall;
    function SetPan(Pan: Integer): LongInt; stdcall;
    function SetFrequency(Frequency: Cardinal): LongInt; stdcall;
    function Stop: LongInt; stdcall;
    function Unlock(Audio1: Pointer; Bytes1: Cardinal; Audio2: Pointer; Bytes2: Cardinal): LongInt; stdcall;
    function Restore: LongInt; stdcall;
  end;

  IDirectSoundNotify = interface(IInterface)
    ['{B0210783-89CD-11D0-AF08-00A0C925CD16}']
    function SetNotificationPositions(Count: Cardinal; Positions: PDSPositionNotify): LongInt; stdcall;
  end;

type
  TDirectSoundCreate = function(Guid: Pointer; out DirectSound: IDirectSound; Outer: IInterface): LongInt; stdcall;
  TDSEnumCallback = function(Guid: Pointer; Description, Module: PAnsiChar; Context: Pointer): LongBool; stdcall;

function DirectSoundEnumerateA(Callback: TDSEnumCallback; Context: Pointer): LongInt; stdcall;
  external 'dsound.dll' name 'DirectSoundEnumerateA'; // @addr $472CCC

type
  TDirectSoundEnumerate = function(Callback: TDSEnumCallback; Context: Pointer): LongInt; stdcall;
var
  DirectSoundCreate: TDirectSoundCreate; // @addr $888E10
  DirectSoundEnumerate: TDirectSoundEnumerate; // @addr $888E14

implementation
end.
