unit EC_Data;
// Unit bracket (inferred): .text 0x007EC35C..0x007F2818; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876A68..0x00876A7B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_Buf, EC_File, EC_Struct, SyncObjs;

type
  TDataEntryKind = (dekFile = 1, dekSubtree = 2); // @size 0x04
  TDataEC = class;

  TDataFileEC = class(TObjectEx) // @size 0x10
  public
    Prev: TDataFileEC; // @offset 0x04
    Next: TDataFileEC; // @offset 0x08
    FileRef: TFileEC; // @offset 0x0C

    constructor Create; // @addr 0x7F1438 @ida "TDataFileEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F148C @ida "void __usercall $name(TDataFileEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x7F14D0 @note "Empty in this binary."
  end;
  PDataFileEC = ^TDataFileEC;

  TDataElEC = class(TObjectEx) // @size 0x24
  public
    Prev: TDataElEC; // @offset 0x04
    Next: TDataElEC; // @offset 0x08
    Name: WideString; // @offset 0x0C
    Kind: TDataEntryKind; // @offset 0x10
    ChildData: TDataEC; // @offset 0x14
    SharedFileRef: TDataFileEC; // @offset 0x18
    FileOffset: Cardinal; // @offset 0x1C
    ByteCount: Integer; // @offset 0x20

    constructor Create; // @addr 0x7F14DC @ida "TDataElEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F1520 @ida "void __usercall $name(TDataElEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearChildData; // @addr 0x7F155C
  end;
  PDataElEC = ^TDataElEC;

  TDataEC = class(TObjectEx) // @size 0x2C
  public
    FileLock: TCriticalSection; // @offset 0x04
    SharesInternedFileList: Boolean; // @offset 0x08
    InternedFileListHeadRef: PDataFileEC; // @offset 0x0C
    InternedFileListTailRef: PDataFileEC; // @offset 0x10
    OwnedInternedFileListHead: TDataFileEC; // @offset 0x14
    OwnedInternedFileListTail: TDataFileEC; // @offset 0x18
    FirstEntry: TDataElEC; // @offset 0x1C
    LastEntry: TDataElEC; // @offset 0x20
    // Delphi dynamic array sorted by case-sensitive, zero-terminated names.
    IndexedEntries: array of TDataElEC; // @offset 0x24
    IndexedEntryCount: Integer; // @offset 0x28

    constructor Create; // @addr 0x7F1584 @ida "TDataEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7F15F0 @ida "void __usercall $name(TDataEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function IsEmpty: Boolean; // @addr 0x7F1634
    procedure Clear; // @addr 0x7F1650 @note "Frees owned files; linked-list head/tail fields remain unchanged."
    function AddEntry(EntryKind: TDataEntryKind): TDataElEC; // @addr 0x7F16F8 @note "Caller must update the index. Child subtrees share the interned-file list."
    function FindIndexedEntry(const Name: WideString): TDataElEC; // @addr 0x7F17B0 @note "Returns nil when absent."
    function FindInsertionIndex(Entry: TDataElEC): Integer; // @addr 0x7F1858
    procedure InsertIntoIndex(Entry: TDataElEC); // @addr 0x7F1910
    procedure RebuildIndex; // @addr 0x7F19B8
    function InternFileName(const FileName: WideString): TDataFileEC; // @addr 0x7F1A14
    function FindEntry(const Name: WideString): TDataElEC; // @addr 0x7F1B10
    function FindEntryByPath(const Path: WideString): TDataElEC; // @addr 0x7F1BC8 @note "Accepts dot, slash and backslash separators; returns nil when absent or an intermediate entry is not a subtree."
    procedure ReadEntryBuffer(Entry: TDataElEC; Dest: TBufEC); // @addr 0x7F1C7C @note "Requires a file entry. Negative ByteCount uses file size minus FileOffset; zero FileOffset skips seeking."
    function GetData(const Name: WideString): TDataEC; // @addr 0x7F1D50 @note "Raises when Name is absent or is not a subtree."
    procedure ReadBufferByPath(const Path: WideString; Dest: TBufEC); // @addr 0x7F1E28 @note "Raises when Path is absent or is not a file entry."
    function FileExistsByPath(const Path: WideString): Boolean; // @addr 0x7F1F0C
    procedure AddMissingFromBlock(Block: TBlockParEC); // @addr 0x7F1F88 @note "Adds only absent names; existing subtrees are not merged recursively."
    procedure WriteToBlock(Block: TBlockParEC); // @addr 0x7F2104
    procedure MergeFrom(Source: TDataEC); // @addr 0x7F21BC @note "Different-kind name matches are skipped."
    procedure LoadFromDecodedBuffer(Buf: TBufEC); // @addr 0x7F22A8 @note "Replaces existing contents; trusts index order from the stream."
    procedure LoadFromEncryptedDatFile(const FileName: WideString); // @addr 0x7F23D8 @note "An inner checksum mismatch leaves the tree unchanged."
  end;

type
  // Native record RTTI at $7EC4C8.
  tclist = record // @size $0C
    NameCrc: Cardinal; // @offset $00
    FileCrc: Cardinal; // @offset $04
    EncodedName: WideString; // @offset $08
  end;
  TResourceChecksumTable = array[0..1023] of tclist;

procedure VerifyResourceFileChecksum(const FileName: WideString); // @addr 0x7F2614 @note "Checks only names present in the built-in checksum table; folds ASCII uppercase for lookup."

const

  // Open addressing by CRC of the ASCII-folded UTF-16 filename. Each
  // stored filename character is shifted by three; zero hashes end probes.
  ResourceChecksums: TResourceChecksumTable = (
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DDC6E004; FileCrc: $F42ED0E3; EncodedName: 'gdwd_txhvw_jhu_orjlfbjhu1tpp'), // Decoded: 'data\quest\ger\logic_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9352F406; FileCrc: $48E9EDB1; EncodedName: 'gdwd_txhvw_hqj_pd}hbhqj1tpp'), // Decoded: 'data\quest\eng\maze_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $0ED79C08; FileCrc: $B37F8A3C; EncodedName: 'gdwd_txhvw_uxv_erpehu1tpp'), // Decoded: 'data\quest\rus\bomber.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $8848D40A; FileCrc: $FB928404; EncodedName: 'gdwd_txhvw_hqj_hohfwlrqbhqj1tpp'), // Decoded: 'data\quest\eng\election_eng.qmm'
    (NameCrc: $23A3B80B; FileCrc: $A9E77C9D; EncodedName: 'gdwd_txhvw_uxv_skrwrurerw1tpp'), // Decoded: 'data\quest\rus\photorobot.qmm'
    (NameCrc: $02C3F00A; FileCrc: $4A72D033; EncodedName: 'gdwd_txhvw_hqj_frgher{bhqj1tpp'), // Decoded: 'data\quest\eng\codebox_eng.qmm'
    (NameCrc: $5A840C0D; FileCrc: $657F5078; EncodedName: 'gdwd_txhvw_hqj_sludwhvqhvwbhqj1tpp'), // Decoded: 'data\quest\eng\piratesnest_eng.qmm'
    (NameCrc: $73BAB40E; FileCrc: $B572CB2D; EncodedName: 'gdwd_depds_pdsb61rsw'), // Decoded: 'data\abmap\map_3.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EBD7F013; FileCrc: $276A4098; EncodedName: 'gdwd_vfulsw_whvw1vfu'), // Decoded: 'data\script\test.scr'
    (NameCrc: $0F7D0C13; FileCrc: $254F56BC; EncodedName: 'gdwd_depds_pdsbervv1rsw'), // Decoded: 'data\abmap\map_boss.opt'
    (NameCrc: $ADE23013; FileCrc: $2E4CE921; EncodedName: 'gdwd_txhvw_hqj_vleroxvrywbhqj1tpp'), // Decoded: 'data\quest\eng\sibolusovt_eng.qmm'
    (NameCrc: $B70A2816; FileCrc: $EC577BDF; EncodedName: 'gdwd_vfulsw_sfbsod4<1vfu'), // Decoded: 'data\script\pc_pla19.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $67406819; FileCrc: $8A69FDBE; EncodedName: 'gdwd_txhvw_uxv_vwtbdwdpdq51tpp'), // Decoded: 'data\quest\rus\stq_ataman2.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $59C49824; FileCrc: $C4EDDDE1; EncodedName: 'gdwd_txhvw_vsd_hylghqfhbvsd1tpp'), // Decoded: 'data\quest\spa\evidence_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9D88F430; FileCrc: $134B39DA; EncodedName: 'gdwd_txhvw_vsd_plqlvwu|bvsd1tpp'), // Decoded: 'data\quest\spa\ministry_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $774F6433; FileCrc: $5E6D10D0; EncodedName: 'gdwd_depds_pdsb41rsw'), // Decoded: 'data\abmap\map_1.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $73977035; FileCrc: $7410AF29; EncodedName: 'gdwd_txhvw_hqj_urerwvbhqj1tpp'), // Decoded: 'data\quest\eng\robots_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $2ABE6439; FileCrc: $C7C09903; EncodedName: 'gdwd_depds_pdowd1pds'), // Decoded: 'data\abmap\malta.map'
    (NameCrc: $C447703A; FileCrc: $D1FE9395; EncodedName: 'gdwd_txhvw_jhu_sod|hubjhu1tpp'), // Decoded: 'data\quest\ger\player_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $20BBE83E; FileCrc: $CE83BCB7; EncodedName: 'gdwd_txhvw_jhu_vnlbjhu1tpp'), // Decoded: 'data\quest\ger\ski_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $7EA4C449; FileCrc: $AF3A1AB8; EncodedName: 'gdwd_depds_pdsb81rsw'), // Decoded: 'data\abmap\map_5.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $AB80D84B; FileCrc: $17ECE7FA; EncodedName: 'gdwd_txhvw_hqj_vwtbedurq6bhqj1tpp'), // Decoded: 'data\quest\eng\stq_baron3_eng.qmm'
    (NameCrc: $6BCC704C; FileCrc: $BCA64246; EncodedName: 'gdwd_txhvw_hqj_ghswkbhqj1tpp'), // Decoded: 'data\quest\eng\depth_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4E62584F; FileCrc: $6AFC55F4; EncodedName: 'gdwd_txhvw_uxv_wd{lvw1tpp'), // Decoded: 'data\quest\rus\taxist.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $3ED66055; FileCrc: $3154B766; EncodedName: 'gdwd_txhvw_vsd_vwtbedurq5bvsd1tpp'), // Decoded: 'data\quest\spa\stq_baron2_spa.qmm'
    (NameCrc: $45ADA456; FileCrc: $3063358F; EncodedName: 'gdwd_depds_nuxjdgd1pds'), // Decoded: 'data\abmap\krugada.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $91FCB058; FileCrc: $3DC7FF75; EncodedName: 'gdwd_txhvw_jhu_glvnbjhu1tpp'), // Decoded: 'data\quest\ger\disk_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F890185B; FileCrc: $734C1CEA; EncodedName: 'gdwd_txhvw_hqj_eru}xnkdqbhqj1tpp'), // Decoded: 'data\quest\eng\borzukhan_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $6CF6CC5F; FileCrc: $0CD45DA7; EncodedName: 'gdwd_txhvw_hqj_vkdvknlbhqj1tpp'), // Decoded: 'data\quest\eng\shashki_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EA23C865; FileCrc: $4DAFE272; EncodedName: 'gdwd_txhvw_jhu_hohfwlrqbjhu1tpp'), // Decoded: 'data\quest\ger\election_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DCE02C6E; FileCrc: $C4B43DA9; EncodedName: 'olerjj031goo'), // Decoded: 'libogg-0.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $CB3E5475; FileCrc: $64F3921B; EncodedName: 'gdwd_txhvw_uxv_jdlgqhw1tpp'), // Decoded: 'data\quest\rus\gaidnet.qmm'
    (NameCrc: $AB572875; FileCrc: $049AE4A1; EncodedName: 'gdwd_txhvw_uxv_vnl1tpp'), // Decoded: 'data\quest\rus\ski.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $2CAF6479; FileCrc: $1AD50E18; EncodedName: 'gdwd_vfulsw_sfbsod3<1vfu'), // Decoded: 'data\script\pc_pla09.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $CE87847F; FileCrc: $BC972677; EncodedName: 'gdwd_txhvw_vsd_sdfkydudvkbvsd1tpp'), // Decoded: 'data\quest\spa\pachvarash_spa.qmm'
    (NameCrc: $34656080; FileCrc: $62E9D3C4; EncodedName: 'gdwd_txhvw_jhu_vwtbdwdpdq5bjhu1tpp'), // Decoded: 'data\quest\ger\stq_ataman2_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $E5898086; FileCrc: $04D2B6BE; EncodedName: 'gdwd_txhvw_uxv_ilvklqjfxs1tpp'), // Decoded: 'data\quest\rus\fishingcup.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $40F1488A; FileCrc: $42739E94; EncodedName: 'gdwd_txhvw_uxv_sod|hu1tpp'), // Decoded: 'data\quest\rus\player.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $3F78248D; FileCrc: $EBC64C53; EncodedName: 'gdwd_vfulsw_sfbsod341vfu'), // Decoded: 'data\script\pc_pla01.scr'
    (NameCrc: $4EC1688D; FileCrc: $F3B7FD4D; EncodedName: 'gdwd_txhvw_hqj_ghdgrudolyhbhqj1tpp'), // Decoded: 'data\quest\eng\deadoralive_eng.qmm'
    (NameCrc: $CC77DC8F; FileCrc: $AF57F1E2; EncodedName: 'gdwd_txhvw_vsd_vwtbkhdgkxqwhubvsd1tpp'), // Decoded: 'data\quest\spa\stq_headhunter_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4117D492; FileCrc: $341252B1; EncodedName: 'gdwd_txhvw_jhu_vwtbkhdgkxqwhubjhu1tpp'), // Decoded: 'data\quest\ger\stq_headhunter_ger.qmm'
    (NameCrc: $DC90F893; FileCrc: $47882624; EncodedName: 'gdwd_txhvw_jhu_urerwvbjhu1tpp'), // Decoded: 'data\quest\ger\robots_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $FD58E895; FileCrc: $39D1B40F; EncodedName: 'gdwd_vfulsw_sfbsduw91vfu'), // Decoded: 'data\script\pc_part6.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $AD36C898; FileCrc: $D0C851A6; EncodedName: 'gdwd_vfulsw_sfbsod481vfu'), // Decoded: 'data\script\pc_pla15.scr'
    (NameCrc: $2A124C99; FileCrc: $9ED87CC1; EncodedName: 'gdwd_txhvw_hqj_orvwkhurbhqj1tpp'), // Decoded: 'data\quest\eng\losthero_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $2C4D8C9B; FileCrc: $C660870B; EncodedName: 'gdwd_txhvw_uxv_vwtbedurq61tpp'), // Decoded: 'data\quest\rus\stq_baron3.qmm'
    (NameCrc: $6B40F89C; FileCrc: $D1D71A15; EncodedName: 'gdwd_txhvw_hqj_sod|hubhqj1tpp'), // Decoded: 'data\quest\eng\player_eng.qmm'
    (NameCrc: $C56CC09C; FileCrc: $F66BB6A2; EncodedName: 'gdwd_txhvw_hqj_pdildbhqj1tpp'), // Decoded: 'data\quest\eng\mafia_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $623300A0; FileCrc: $0E22B93C; EncodedName: 'gdwd_txhvw_jhu_px}rqbjhu1tpp'), // Decoded: 'data\quest\ger\muzon_ger.qmm'
    (NameCrc: $11FD84A1; FileCrc: $C54C33BE; EncodedName: 'gdwd_txhvw_jhu_vwtbedurq4bjhu1tpp'), // Decoded: 'data\quest\ger\stq_baron1_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $84ACF0A3; FileCrc: $642E1DB5; EncodedName: 'gdwd_depds_nuxjdgd1rsw'), // Decoded: 'data\abmap\krugada.opt'
    (NameCrc: $A99244A3; FileCrc: $17E2BF48; EncodedName: 'gdwd_txhvw_jhu_sl}}dbjhu1tpp'), // Decoded: 'data\quest\ger\pizza_ger.qmm'
    (NameCrc: $A9C318A5; FileCrc: $60B52C86; EncodedName: 'gdwd_vfulsw_sfbsod4:1vfu'), // Decoded: 'data\script\pc_pla17.scr'
    (NameCrc: $E0A74CA3; FileCrc: $CE293522; EncodedName: 'gdwd_txhvw_hqj_{hqrsdunbhqj1tpp'), // Decoded: 'data\quest\eng\xenopark_eng.qmm'
    (NameCrc: $6D1D9CA3; FileCrc: $F1D129E1; EncodedName: 'gdwd_txhvw_hqj_sursurorjbhqj1tpp'), // Decoded: 'data\quest\eng\proprolog_eng.qmm'
    (NameCrc: $F9AD38A8; FileCrc: $DF29620C; EncodedName: 'gdwd_vfulsw_sfbsduw71vfu'), // Decoded: 'data\script\pc_part4.scr'
    (NameCrc: $35BF04A5; FileCrc: $4F4F964D; EncodedName: 'gdwd_txhvw_hqj_vwtbdwdpdq5bhqj1tpp'), // Decoded: 'data\quest\eng\stq_ataman2_eng.qmm'
    (NameCrc: $28B85CA6; FileCrc: $7671239F; EncodedName: 'gdwd_txhvw_uxv_vwtbedurq41tpp'), // Decoded: 'data\quest\rus\stq_baron1.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $8A1C70AC; FileCrc: $E9C82059; EncodedName: 'gdwd_txhvw_hqj_nlehuud}xpbhqj1tpp'), // Decoded: 'data\quest\eng\kiberrazum_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $13AC04AE; FileCrc: $2FCCD46E; EncodedName: 'gdwd_txhvw_uxv_vwtbkhdgkxqwhu1tpp'), // Decoded: 'data\quest\rus\stq_headhunter.qmm'
    (NameCrc: $207168AF; FileCrc: $2EE7314E; EncodedName: 'gdwd_txhvw_uxv_ro|psldgd1tpp'), // Decoded: 'data\quest\rus\olympiada.qmm'
    (NameCrc: $3B8DF4B0; FileCrc: $5EB08EF0; EncodedName: 'gdwd_vfulsw_sfbsod361vfu'), // Decoded: 'data\script\pc_pla03.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DA7D58B3; FileCrc: $DBB44F8C; EncodedName: 'gdwd_txhvw_hqj_iruxpbhqj1tpp'), // Decoded: 'data\quest\eng\forum_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $29F1FCB8; FileCrc: $A52A3C50; EncodedName: 'gdwd_txhvw_vsd_ro|psldgdbvsd1tpp'), // Decoded: 'data\quest\spa\olympiada_spa.qmm'
    (NameCrc: $B7FFC4B9; FileCrc: $50737E80; EncodedName: 'gdwd_txhvw_vsd_vkdvknlbvsd1tpp'), // Decoded: 'data\quest\spa\shashki_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $BFA590BC; FileCrc: $027C08E8; EncodedName: 'gdwd_depds_pdsb81pds'), // Decoded: 'data\abmap\map_5.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $B64E30C6; FileCrc: $30E53515; EncodedName: 'gdwd_depds_pdsb41pds'), // Decoded: 'data\abmap\map_1.map'
    (NameCrc: $52E188C6; FileCrc: $738D6016; EncodedName: 'gdwd_txhvw_hqj_sdunbhqj1tpp'), // Decoded: 'data\quest\eng\park_eng.qmm'
    (NameCrc: $9AF320C7; FileCrc: $D0673E6B; EncodedName: 'gdwd_txhvw_uxv_hdv|zrun1tpp'), // Decoded: 'data\quest\rus\easywork.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $326654CA; FileCrc: $5E65B093; EncodedName: 'gdwd_vfulsw_sfbsod3:1vfu'), // Decoded: 'data\script\pc_pla07.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EBBF30CC; FileCrc: $58C47D40; EncodedName: 'gdwd_depds_pdowd1rsw'), // Decoded: 'data\abmap\malta.opt'
    (NameCrc: $82CC50CC; FileCrc: $3B2591D6; EncodedName: 'gdwd_txhvw_jhu_{hqrsdunbjhu1tpp'), // Decoded: 'data\quest\ger\xenopark_ger.qmm'
    (NameCrc: $E5E240CD; FileCrc: $56D5ADE7; EncodedName: 'gdwd_txhvw_hqj_ilvklqjfxsbhqj1tpp'), // Decoded: 'data\quest\eng\fishingcup_eng.qmm'
    (NameCrc: $B7A4ACCD; FileCrc: $36F53283; EncodedName: 'gdwd_txhvw_hqj_yxondqbhqj1tpp'), // Decoded: 'data\quest\eng\vulkan_eng.qmm'
    (NameCrc: $30AADCD0; FileCrc: $1C993B62; EncodedName: 'gdwd_txhvw_vsd_vwtbedurq7bvsd1tpp'), // Decoded: 'data\quest\spa\stq_baron4_spa.qmm'
    (NameCrc: $118D78D1; FileCrc: $430F19F3; EncodedName: 'gdwd_txhvw_hqj_hdv|zrunbhqj1tpp'), // Decoded: 'data\quest\eng\easywork_eng.qmm'
    (NameCrc: $F04698D2; FileCrc: $7E751FA7; EncodedName: 'gdwd_vfulsw_sfbsduw31vfu'), // Decoded: 'data\script\pc_part0.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $763200D8; FileCrc: $1E16EE0D; EncodedName: 'gdwd_txhvw_hqj_skrwrurerwbhqj1tpp'), // Decoded: 'data\quest\eng\photorobot_eng.qmm'
    (NameCrc: $F3A874D8; FileCrc: $5ED68278; EncodedName: 'gdwd_txhvw_uxv_grrplqr1tpp'), // Decoded: 'data\quest\rus\doomino.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C0C60CDD; FileCrc: $8B6D6BAC; EncodedName: 'gdwd_txhvw_vsd_vwtbdwdpdq5bvsd1tpp'), // Decoded: 'data\quest\spa\stq_ataman2_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $A028B8DF; FileCrc: $1501DE7D; EncodedName: 'gdwd_vfulsw_sfbsod461vfu'), // Decoded: 'data\script\pc_pla13.scr'
    (NameCrc: $4A4634DF; FileCrc: $C1F569C9; EncodedName: 'gdwd_txhvw_vsd_slorwbvsd1tpp'), // Decoded: 'data\quest\spa\pilot_spa.qmm'
    (NameCrc: $61AB80DF; FileCrc: $08809345; EncodedName: 'gdwd_txhvw_hqj_vnlbhqj1tpp'), // Decoded: 'data\quest\eng\ski_eng.qmm'
    (NameCrc: $A4DD68E2; FileCrc: $9C108F1A; EncodedName: 'gdwd_vfulsw_sfbsod441vfu'), // Decoded: 'data\script\pc_pla11.scr'
    (NameCrc: $35BE98E1; FileCrc: $4A329FE9; EncodedName: 'gdwd_txhvw_jhu_vsdfholqhvbjhu1tpp'), // Decoded: 'data\quest\ger\spacelines_ger.qmm'
    (NameCrc: $98A874E2; FileCrc: $64314C0B; EncodedName: 'gdwd_txhvw_hqj_glvnbhqj1tpp'), // Decoded: 'data\quest\eng\disk_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $CE7C58E6; FileCrc: $3C2F0B87; EncodedName: 'gdwd_depds_pdsbervv1pds'), // Decoded: 'data\abmap\map_boss.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $658CC0EA; FileCrc: $3DB816A4; EncodedName: 'gdwd_txhvw_vsd_mxpshubvsd1tpp'), // Decoded: 'data\quest\spa\jumper_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D9CAF8EC; FileCrc: $928F2BF0; EncodedName: 'gdwd_txhvw_vsd_frgher{bvsd1tpp'), // Decoded: 'data\quest\spa\codebox_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F4B348EF; FileCrc: $2B514452; EncodedName: 'gdwd_vfulsw_sfbsduw51vfu'), // Decoded: 'data\script\pc_part2.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $12838CF2; FileCrc: $8686AC11; EncodedName: 'gdwd_txhvw_hqj_hylojhqlxvbhqj1tpp'), // Decoded: 'data\quest\eng\evilgenius_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $67BF00F5; FileCrc: $440752CA; EncodedName: 'gdwd_txhvw_hqj_udoo|bhqj1tpp'), // Decoded: 'data\quest\eng\rally_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $369384F7; FileCrc: $BA6ECB35; EncodedName: 'gdwd_vfulsw_sfbsod381vfu'), // Decoded: 'data\script\pc_pla05.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $B5E364F9; FileCrc: $A01B4653; EncodedName: 'gdwd_txhvw_uxv_hghozhlvv1tpp'), // Decoded: 'data\quest\rus\edelweiss.qmm'
    (NameCrc: $026708FA; FileCrc: $1D319109; EncodedName: 'gdwd_txhvw_hqj_wrxulvwvbhqj1tpp'), // Decoded: 'data\quest\eng\tourists_eng.qmm'
    (NameCrc: $B2BBE0FB; FileCrc: $9F8476E9; EncodedName: 'gdwd_depds_pdsb61pds'), // Decoded: 'data\abmap\map_3.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $FCFAF505; FileCrc: $0E7931A1; EncodedName: 'gdwd_txhvw_hqj_slorwbhqj1tpp'), // Decoded: 'data\quest\eng\pilot_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $78F94D07; FileCrc: $AE9D1EA8; EncodedName: 'gdwd_txhvw_jhu_plqlvwu|bjhu1tpp'), // Decoded: 'data\quest\ger\ministry_ger.qmm'
    (NameCrc: $974B3108; FileCrc: $80A7790A; EncodedName: 'gdwd_txhvw_vsd_edqnhwbvsd1tpp'), // Decoded: 'data\quest\spa\banket_spa.qmm'
    (NameCrc: $12D0A109; FileCrc: $747714AB; EncodedName: 'gdwd_depds_odelulqwblll1pds'), // Decoded: 'data\abmap\labirint_iii.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $BCB52113; FileCrc: $F7C13800; EncodedName: 'gdwd_txhvw_jhu_hylghqfhbjhu1tpp'), // Decoded: 'data\quest\ger\evidence_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $14A5E11D; FileCrc: $B40F490A; EncodedName: 'gdwd_txhvw_jhu_frgher{bjhu1tpp'), // Decoded: 'data\quest\ger\codebox_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DB54F122; FileCrc: $9DAE1B4E; EncodedName: 'gdwd_txhvw_vsd_sludwhfodqsulvrqbvsd1tpp'), // Decoded: 'data\quest\spa\pirateclanprison_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $0C5DAD24; FileCrc: $EB0DE892; EncodedName: 'gdwd_txhvw_uxv_irqfhuv1tpp'), // Decoded: 'data\quest\rus\foncers.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1EF2512B; FileCrc: $151F72F0; EncodedName: 'gdwd_depds_pdsbvn|1rsw'), // Decoded: 'data\abmap\map_sky.opt'
    (NameCrc: $3C81D12C; FileCrc: $309FD439; EncodedName: 'gdwd_vfulsw_sfbsod531vfu'), // Decoded: 'data\script\pc_pla20.scr'
    (NameCrc: $1D5A312C; FileCrc: $8322B884; EncodedName: 'gdwd_txhvw_uxv_sdfkydudvk1tpp'), // Decoded: 'data\quest\rus\pachvarash.qmm'
    (NameCrc: $A01AF52C; FileCrc: $C99AFCEB; EncodedName: 'gdwd_txhvw_uxv_uyn1tpp'), // Decoded: 'data\quest\rus\rvk.qmm'
    (NameCrc: $A270712B; FileCrc: $C0111A70; EncodedName: 'gdwd_txhvw_uxv_yxondq1tpp'), // Decoded: 'data\quest\rus\vulkan.qmm'
    (NameCrc: $4C8B0D2E; FileCrc: $9B513043; EncodedName: 'gdwd_txhvw_uxv_frpsoh{1tpp'), // Decoded: 'data\quest\rus\complex.qmm'
    (NameCrc: $D103C12F; FileCrc: $16ED62DE; EncodedName: 'gdwd_txhvw_vsd_udoo|bvsd1tpp'), // Decoded: 'data\quest\spa\rally_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D450BD37; FileCrc: $C8D850D6; EncodedName: 'gdwd_txhvw_vsd_vwtbedurq4bvsd1tpp'), // Decoded: 'data\quest\spa\stq_baron1_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5769D13A; FileCrc: $BABC8E68; EncodedName: 'gdwd_txhvw_uxv_plqlvwu|1tpp'), // Decoded: 'data\quest\rus\ministry.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D1647940; FileCrc: $D37C460B; EncodedName: 'gdwd_txhvw_uxv_skdudrq1tpp'), // Decoded: 'data\quest\rus\pharaon.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $CBB74943; FileCrc: $2ED7AF28; EncodedName: 'gdwd_vfulsw_pvbve51vfu'), // Decoded: 'data\script\ms_sb2.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F507E546; FileCrc: $8B1F22E8; EncodedName: 'gdwd_txhvw_jhu_vwtbedurq7bjhu1tpp'), // Decoded: 'data\quest\ger\stq_baron4_ger.qmm'
    (NameCrc: $4D035D47; FileCrc: $9AA44FFC; EncodedName: 'gdwd_txhvw_hqj_prlbhqj1tpp'), // Decoded: 'data\quest\eng\moi_eng.qmm'
    (NameCrc: $7A90DD48; FileCrc: $730166D1; EncodedName: 'gdwd_txhvw_jhu_vkdvknlbjhu1tpp'), // Decoded: 'data\quest\ger\shashki_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $FDA1FD4B; FileCrc: $70D7B8F2; EncodedName: 'gdwd_txhvw_vsd_edggd|bvsd1tpp'), // Decoded: 'data\quest\spa\badday_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D5565D52; FileCrc: $361BC30A; EncodedName: 'gdwd_txhvw_hqj_dpqhvldbhqj1tpp'), // Decoded: 'data\quest\eng\amnesia_eng.qmm'
    (NameCrc: $0F527152; FileCrc: $43CB21FA; EncodedName: 'gdwd_txhvw_vsd_hohfwlrqbvsd1tpp'), // Decoded: 'data\quest\spa\election_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C2D02555; FileCrc: $21506EBA; EncodedName: 'gdwd_txhvw_vsd_vnlbvsd1tpp'), // Decoded: 'data\quest\spa\ski_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $B10FC15D; FileCrc: $D9F4810F; EncodedName: 'gdwd_txhvw_hqj_suryrgdbhqj1tpp'), // Decoded: 'data\quest\eng\provoda_eng.qmm'
    (NameCrc: $7285FD5E; FileCrc: $532DD25A; EncodedName: 'gdwd_txhvw_uxv_iruxp1tpp'), // Decoded: 'data\quest\rus\forum.qmm'
    (NameCrc: $24B38D5D; FileCrc: $AE54851F; EncodedName: 'gdwd_txhvw_jhu_sulvrqbjhu1tpp'), // Decoded: 'data\quest\ger\prison_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $0C0B5D61; FileCrc: $14C8806D; EncodedName: 'oleyruelv031goo'), // Decoded: 'libvorbis-0.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5E76C564; FileCrc: $CB0EB7C0; EncodedName: 'gdwd_txhvw_uxv_sludwhvqhvw1tpp'), // Decoded: 'data\quest\rus\piratesnest.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $102F6568; FileCrc: $E0501010; EncodedName: 'gdwd_depds_nhoohubvslulwb351pds'), // Decoded: 'data\abmap\keller_spirit_02.map'
    (NameCrc: $F8CBE168; FileCrc: $DC5292C6; EncodedName: 'gdwd_depds_sludwhvbiodj1pds'), // Decoded: 'data\abmap\pirates_flag.map'
    (NameCrc: $1A925168; FileCrc: $6F8AA0C7; EncodedName: 'gdwd_txhvw_hqj_plqlvwu|bhqj1tpp'), // Decoded: 'data\quest\eng\ministry_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D057D16E; FileCrc: $A35F5387; EncodedName: 'gdwd_depds_5vwduv1pds'), // Decoded: 'data\abmap\2stars.map'
    (NameCrc: $13E45D6E; FileCrc: $519D4F88; EncodedName: 'gdwd_txhvw_hqj_erpehubhqj1tpp'), // Decoded: 'data\quest\eng\bomber_eng.qmm'
    (NameCrc: $875DA96E; FileCrc: $D7A4A6A0; EncodedName: 'gdwd_txhvw_uxv_wrxulvwv1tpp'), // Decoded: 'data\quest\rus\tourists.qmm'
    (NameCrc: $42D3E970; FileCrc: $C78F0F33; EncodedName: 'gdwd_txhvw_uxv_orvwkhur1tpp'), // Decoded: 'data\quest\rus\losthero.qmm'
    (NameCrc: $3579C572; FileCrc: $2CBA2313; EncodedName: 'gdwd_txhvw_uxv_phjdwhvw1tpp'), // Decoded: 'data\quest\rus\megatest.qmm'
    (NameCrc: $ADABBD73; FileCrc: $387BC314; EncodedName: 'gdwd_txhvw_vsd_eru}xnkdqbvsd1tpp'), // Decoded: 'data\quest\spa\borzukhan_spa.qmm'
    (NameCrc: $9D7AB574; FileCrc: $6F07D188; EncodedName: 'gdwd_txhvw_uxv_edqnhw1tpp'), // Decoded: 'data\quest\rus\banket.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F013A177; FileCrc: $B6D6E4B5; EncodedName: 'gdwd_txhvw_vsd_vsdfholqhvbvsd1tpp'), // Decoded: 'data\quest\spa\spacelines_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DEDE3D7C; FileCrc: $ACFFB3DA; EncodedName: 'gdwd_txhvw_hqj_hylghqfhbhqj1tpp'), // Decoded: 'data\quest\eng\evidence_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D940F17E; FileCrc: $BC920906; EncodedName: 'gdwd_depds_dwrp1rsw'), // Decoded: 'data\abmap\atom.opt'
    (NameCrc: $E6814D7E; FileCrc: $4E207124; EncodedName: 'gdwd_txhvw_jhu_hoxvbjhu1tpp'), // Decoded: 'data\quest\ger\elus_ger.qmm'
    (NameCrc: $E847C180; FileCrc: $BC8FD416; EncodedName: 'gdwd_txhvw_uxv_hylojhqlxv1tpp'), // Decoded: 'data\quest\rus\evilgenius.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1841A58B; FileCrc: $04A1794F; EncodedName: 'gdwd_depds_dwrp1pds'), // Decoded: 'data\abmap\atom.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $7CCA5990; FileCrc: $309801D6; EncodedName: 'gdwd_txhvw_hqj_ro|psldgdbhqj1tpp'), // Decoded: 'data\quest\eng\olympiada_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DD70B196; FileCrc: $DD65462C; EncodedName: 'gdwd_txhvw_vsd_ghswkbvsd1tpp'), // Decoded: 'data\quest\spa\depth_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1156859B; FileCrc: $2694D1F7; EncodedName: 'gdwd_depds_5vwduv1rsw'), // Decoded: 'data\abmap\2stars.opt'
    (NameCrc: $34C9199C; FileCrc: $4E0EE23B; EncodedName: 'gdwd_vfulsw_pvbehjlq1vfu'), // Decoded: 'data\script\ms_begin.scr'
    (NameCrc: $D12E319D; FileCrc: $EF95650A; EncodedName: 'gdwd_depds_nhoohubvslulwb351rsw'), // Decoded: 'data\abmap\keller_spirit_02.opt'
    (NameCrc: $39CAB59D; FileCrc: $327072BA; EncodedName: 'gdwd_depds_sludwhvbiodj1rsw'), // Decoded: 'data\abmap\pirates_flag.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DFE7B5A4; FileCrc: $85B082F4; EncodedName: 'rnji1goo'), // Decoded: 'okgf.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9A5731AC; FileCrc: $32E13284; EncodedName: 'gdwd_txhvw_jhu_hghozhlvvbjhu1tpp'), // Decoded: 'data\quest\ger\edelweiss_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $055AD9B3; FileCrc: $2257B552; EncodedName: 'gdwd_txhvw_jhu_sludwhfodqsulvrqbjhu1tpp'), // Decoded: 'data\quest\ger\pirateclanprison_ger.qmm'
    (NameCrc: $507B15B4; FileCrc: $ABA7B7C2; EncodedName: 'gdwd_txhvw_uxv_vydurnrn1tpp'), // Decoded: 'data\quest\rus\svarokok.qmm'
    (NameCrc: $AEAB99B5; FileCrc: $E09C4195; EncodedName: 'gdwd_txhvw_vsd_gulyhubvsd1tpp'), // Decoded: 'data\quest\spa\driver_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $6A6961BE; FileCrc: $6F3E8572; EncodedName: 'gdwd_txhvw_uxv_glvn1tpp'), // Decoded: 'data\quest\rus\disk.qmm'
    (NameCrc: $2A40D1BF; FileCrc: $AE314337; EncodedName: 'gdwd_txhvw_vsd_vwtbdwdpdq4bvsd1tpp'), // Decoded: 'data\quest\spa\stq_ataman1_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $FB7B59C3; FileCrc: $C278B686; EncodedName: 'gdwd_txhvw_jhu_vwtbedurq5bjhu1tpp'), // Decoded: 'data\quest\ger\stq_baron2_ger.qmm'
    (NameCrc: $EFD589C4; FileCrc: $C33CAEE2; EncodedName: 'gdwd_txhvw_hqj_hoxvbhqj1tpp'), // Decoded: 'data\quest\eng\elus_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $E737D9C7; FileCrc: $396B4215; EncodedName: 'gdwd_txhvw_uxv_ohrqdugr1tpp'), // Decoded: 'data\quest\rus\leonardo.qmm'
    (NameCrc: $DF39D9C7; FileCrc: $CE76A7BC; EncodedName: 'gdwd_txhvw_hqj_vwtbdwdpdq4bhqj1tpp'), // Decoded: 'data\quest\eng\stq_ataman1_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $789605D0; FileCrc: $CFC8F987; EncodedName: 'gdwd_txhvw_hqj_whvwlqjbhqj1tpp'), // Decoded: 'data\quest\eng\testing_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $273E7DD2; FileCrc: $517DA116; EncodedName: 'gdwd_txhvw_uxv_frorql}dwlrq1tpp'), // Decoded: 'data\quest\rus\colonization.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $14111DD4; FileCrc: $21918AAA; EncodedName: 'gdwd_vfulsw_pvbwhuurq1vfu'), // Decoded: 'data\script\ms_terron.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1BB181D9; FileCrc: $42F24A83; EncodedName: 'gdwd_txhvw_hqj_glyhubhqj1tpp'), // Decoded: 'data\quest\eng\diver_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $86FFADDB; FileCrc: $3659B625; EncodedName: '{ylgfruh1goo'), // Decoded: 'xvidcore.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C5D2CDDD; FileCrc: $C9916113; EncodedName: 'gdwd_txhvw_uxv_eru}xnkdq1tpp'), // Decoded: 'data\quest\rus\borzukhan.qmm'
    (NameCrc: $DFF305DE; FileCrc: $112F1AF6; EncodedName: 'gdwd_depds_pdsbvn|1pds'), // Decoded: 'data\abmap\map_sky.map'
    (NameCrc: $FCD36DDE; FileCrc: $69ADE472; EncodedName: 'gdwd_txhvw_uxv_gulyhu1tpp'), // Decoded: 'data\quest\rus\driver.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DEE3BDE2; FileCrc: $56CD7493; EncodedName: 'gdwd_txhvw_jhu_vwtbdwdpdq4bjhu1tpp'), // Decoded: 'data\quest\ger\stq_ataman1_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $0B2ABDE9; FileCrc: $D0F2FE05; EncodedName: 'gdwd_txhvw_jhu_sdfkydudvkbjhu1tpp'), // Decoded: 'data\quest\ger\pachvarash_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5A3A15EE; FileCrc: $6E7A206B; EncodedName: 'gdwd_txhvw_uxv_sl}}d1tpp'), // Decoded: 'data\quest\rus\pizza.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $67BDE9FB; FileCrc: $B7AED871; EncodedName: 'gdwd_txhvw_vsd_{hqrsdunbvsd1tpp'), // Decoded: 'data\quest\spa\xenopark_spa.qmm'
    (NameCrc: $D3D1F5FC; FileCrc: $092E8091; EncodedName: 'gdwd_depds_odelulqwblll1rsw'), // Decoded: 'data\abmap\labirint_iii.opt'
    (NameCrc: $8BB405FB; FileCrc: $BB1B6DA2; EncodedName: 'gdwd_txhvw_hqj_sulvrqbhqj1tpp'), // Decoded: 'data\quest\eng\prison_eng.qmm'
    (NameCrc: $F08341FE; FileCrc: $24FD2B48; EncodedName: 'gdwd_txhvw_uxv_sdun1tpp'), // Decoded: 'data\quest\rus\park.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F2315E08; FileCrc: $824F98AD; EncodedName: 'gdwd_txhvw_hqj_joxnlbhqj1tpp'), // Decoded: 'data\quest\eng\gluki_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $3461EE0E; FileCrc: $0C67C0AE; EncodedName: 'gdwd_vfulsw_pvbnhoohu1vfu'), // Decoded: 'data\script\ms_keller.scr'
    (NameCrc: $811AFA0E; FileCrc: $5C2B78E7; EncodedName: 'gdwd_txhvw_hqj_edqnhwbhqj1tpp'), // Decoded: 'data\quest\eng\banket_eng.qmm'
    (NameCrc: $E7815A10; FileCrc: $8470C206; EncodedName: 'gdwd_txhvw_jhu_irqfhuvbjhu1tpp'), // Decoded: 'data\quest\ger\foncers_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D343BA12; FileCrc: $3D73B021; EncodedName: 'gdwd_vfulsw_sfbsod541vfu'), // Decoded: 'data\script\pc_pla21.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $25C02214; FileCrc: $35E8A9A4; EncodedName: 'gdwd_txhvw_hqj_uynbhqj1tpp'), // Decoded: 'data\quest\eng\rvk_eng.qmm'
    (NameCrc: $17FDDA15; FileCrc: $A1E32968; EncodedName: 'gdwd_txhvw_jhu_gulyhubjhu1tpp'), // Decoded: 'data\quest\ger\driver_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EBB7FE18; FileCrc: $7F7D8209; EncodedName: 'gdwd_txhvw_vsd_vruwlurynd4bvsd1tpp'), // Decoded: 'data\quest\spa\sortirovka1_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DFBFDA1A; FileCrc: $CD8C1561; EncodedName: 'gdwd_txhvw_hqj_vwhdowkbhqj1tpp'), // Decoded: 'data\quest\eng\stealth_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $95CAFA1E; FileCrc: $DAE217CC; EncodedName: 'gdwd_txhvw_uxv_orjlf1tpp'), // Decoded: 'data\quest\rus\logic.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $A387AA2A; FileCrc: $A0DDAAAE; EncodedName: 'gdwd_txhvw_uxv_px}rq1tpp'), // Decoded: 'data\quest\rus\muzon.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4AAED22F; FileCrc: $80E2522B; EncodedName: 'gdwd_txhvw_hqj_vwtbedurq7bhqj1tpp'), // Decoded: 'data\quest\eng\stq_baron4_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9FE64E32; FileCrc: $4F42A7A2; EncodedName: 'gdwd_txhvw_vsd_ilvklqjfxsbvsd1tpp'), // Decoded: 'data\quest\spa\fishingcup_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DA5D9A35; FileCrc: $A8369349; EncodedName: 'gdwd_txhvw_uxv_grprfodq1tpp'), // Decoded: 'data\quest\rus\domoclan.qmm'
    (NameCrc: $7E9D5236; FileCrc: $603CD386; EncodedName: 'gdwd_txhvw_vsd_glvnbvsd1tpp'), // Decoded: 'data\quest\spa\disk_spa.qmm'
    (NameCrc: $C8F36E35; FileCrc: $89EDD932; EncodedName: 'gdwd_txhvw_hqj_vwtbkhdgkxqwhubhqj1tpp'), // Decoded: 'data\quest\eng\stq_headhunter_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D7DA523C; FileCrc: $B690E013; EncodedName: 'gdwd_txhvw_hqj_jodyuhgbhqj1tpp'), // Decoded: 'data\quest\eng\glavred_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $2080F240; FileCrc: $A72EE38C; EncodedName: 'gdwd_vfulsw_pvbve41vfu'), // Decoded: 'data\script\ms_sb1.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1F149245; FileCrc: $6AA4252E; EncodedName: 'gdwd_txhvw_jhu_vruwlurynd4bjhu1tpp'), // Decoded: 'data\quest\ger\sortirovka1_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $D8C5564A; FileCrc: $3BD4D698; EncodedName: 'gdwd_txhvw_uxv_vwhdowk1tpp'), // Decoded: 'data\quest\rus\stealth.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EBF0364D; FileCrc: $46388F17; EncodedName: 'gdwd_txhvw_hqj_edggd|bhqj1tpp'), // Decoded: 'data\quest\eng\badday_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $E0A98656; FileCrc: $10F06353; EncodedName: 'gdwd_txhvw_uxv_suryrgd1tpp'), // Decoded: 'data\quest\rus\provoda.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $935F165B; FileCrc: $1E4472F6; EncodedName: 'gdwd_txhvw_hqj_phjdwhvwbhqj1tpp'), // Decoded: 'data\quest\eng\megatest_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EC4ADA5F; FileCrc: $A3D1D615; EncodedName: 'gdwd_txhvw_vsd_ohrqdugrbvsd1tpp'), // Decoded: 'data\quest\spa\leonardo_spa.qmm'
    (NameCrc: $1ECEF660; FileCrc: $A115786B; EncodedName: 'gdwd_txhvw_hqj_vruwlurynd4bhqj1tpp'), // Decoded: 'data\quest\eng\sortirovka1_eng.qmm'
    (NameCrc: $F22D065F; FileCrc: $E56A0D73; EncodedName: 'gdwd_txhvw_hqj_guxjvbhqj1tpp'), // Decoded: 'data\quest\eng\drugs_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $04DFAE67; FileCrc: $E11A3420; EncodedName: 'gdwd_depds_xudqy461rsw'), // Decoded: 'data\abmap\uranv13.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4CD88E6A; FileCrc: $2F300933; EncodedName: 'gdwd_txhvw_hqj_jdlgqhwbhqj1tpp'), // Decoded: 'data\quest\eng\gaidnet_eng.qmm'
    (NameCrc: $D85EB66B; FileCrc: $44D2547D; EncodedName: 'gdwd_vfulsw_sfbilqdo1vfu'), // Decoded: 'data\script\pc_final.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $956E8672; FileCrc: $9CC85E3A; EncodedName: 'gdwd_txhvw_uxv_hohfwlrq1tpp'), // Decoded: 'data\quest\rus\election.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9176B274; FileCrc: $1B55F497; EncodedName: 'gdwd_txhvw_uxv_slorw1tpp'), // Decoded: 'data\quest\rus\pilot.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $610C3679; FileCrc: $4F0F1048; EncodedName: 'gdwd_txhvw_uxv_vsdfholqhv1tpp'), // Decoded: 'data\quest\rus\spacelines.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $E401C67C; FileCrc: $D8AC4E3D; EncodedName: 'gdwd_txhvw_vsd_orjlfbvsd1tpp'), // Decoded: 'data\quest\spa\logic_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $B4838A80; FileCrc: $38378814; EncodedName: 'gdwd_txhvw_hqj_sdfkydudvkbhqj1tpp'), // Decoded: 'data\quest\eng\pachvarash_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $26D99284; FileCrc: $E86A4C4E; EncodedName: 'gdwd_txhvw_uxv_vruwlurynd41tpp'), // Decoded: 'data\quest\rus\sortirovka1.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9AE4F686; FileCrc: $C364BDBC; EncodedName: 'gdwd_txhvw_uxv_ghdgrudolyh1tpp'), // Decoded: 'data\quest\rus\deadoralive.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $616BD68D; FileCrc: $335FB4C7; EncodedName: 'gdwd_txhvw_hqj_hghozhlvvbhqj1tpp'), // Decoded: 'data\quest\eng\edelweiss_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C5DEFA92; FileCrc: $7857100A; EncodedName: 'gdwd_depds_xudqy461pds'), // Decoded: 'data\abmap\uranv13.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $A3E42E94; FileCrc: $2BA7B9BC; EncodedName: 'gdwd_vfulsw_pvbeod}hu1vfu'), // Decoded: 'data\script\ms_blazer.scr'
    (NameCrc: $5F3CB695; FileCrc: $74BE3F82; EncodedName: 'gdwd_txhvw_hqj_sludwhfodqsulvrqbhqj1tpp'), // Decoded: 'data\quest\eng\pirateclanprison_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $984F0298; FileCrc: $5E6CC392; EncodedName: 'gdwd_txhvw_hqj_vydurnrnbhqj1tpp'), // Decoded: 'data\quest\eng\svarokok_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $738112A7; FileCrc: $3D089361; EncodedName: 'gdwd_txhvw_jhu_slorwbjhu1tpp'), // Decoded: 'data\quest\ger\pilot_ger.qmm'
    (NameCrc: $2E1D72A8; FileCrc: $7BB56B7D; EncodedName: 'gdwd_txhvw_jhu_edqnhwbjhu1tpp'), // Decoded: 'data\quest\ger\banket_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $44D26EAA; FileCrc: $F93742D0; EncodedName: 'gdwd_txhvw_hqj_vwtbedurq5bhqj1tpp'), // Decoded: 'data\quest\eng\stq_baron2_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $87F6BEB1; FileCrc: $E53F3FB4; EncodedName: 'gdwd_txhvw_jhu_ro|psldgdbjhu1tpp'), // Decoded: 'data\quest\ger\olympiada_ger.qmm'
    (NameCrc: $FC4B12B2; FileCrc: $0C1CADB6; EncodedName: 'gdwd_txhvw_uxv_vleroxvryw1tpp'), // Decoded: 'data\quest\rus\sibolusovt.qmm'
    (NameCrc: $B8FA52B3; FileCrc: $BBEAA04A; EncodedName: 'gdwd_txhvw_hqj_gulyhubhqj1tpp'), // Decoded: 'data\quest\eng\driver_eng.qmm'
    (NameCrc: $D184D6B4; FileCrc: $D6FECEAB; EncodedName: 'gdwd_txhvw_vsd_vwtbedurq6bvsd1tpp'), // Decoded: 'data\quest\spa\stq_baron3_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9BE6FABE; FileCrc: $5E8AC0AF; EncodedName: 'gdwd_txhvw_uxv_hoxv1tpp'), // Decoded: 'data\quest\rus\elus.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $01FECAC8; FileCrc: $266B3FAC; EncodedName: 'gdwd_txhvw_uxv_sulvrq1tpp'), // Decoded: 'data\quest\rus\prison.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $8C8BDAD3; FileCrc: $26112504; EncodedName: 'gdwd_txhvw_uxv_{hqrorj1tpp'), // Decoded: 'data\quest\rus\xenolog.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $09F89AD7; FileCrc: $DA56D2A1; EncodedName: 'gdwd_txhvw_uxv_vkdvknl1tpp'), // Decoded: 'data\quest\rus\shashki.qmm'
    (NameCrc: $B6318AD8; FileCrc: $CDF5B20D; EncodedName: 'gdwd_txhvw_hqj_iduxnbhqj1tpp'), // Decoded: 'data\quest\eng\faruk_eng.qmm'
    (NameCrc: $5BF426D8; FileCrc: $0B5A3EAC; EncodedName: 'gdwd_txhvw_vsd_px}rqbvsd1tpp'), // Decoded: 'data\quest\spa\muzon_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $905562DB; FileCrc: $BBF28BCB; EncodedName: 'gdwd_txhvw_vsd_sl}}dbvsd1tpp'), // Decoded: 'data\quest\spa\pizza_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $BDECCEDD; FileCrc: $622A027E; EncodedName: 'gdwd_txhvw_hqj_ihlsv|fkrbhqj1tpp'), // Decoded: 'data\quest\eng\feipsycho_eng.qmm'
    (NameCrc: $BC228EDE; FileCrc: $49C72061; EncodedName: 'vwhdpbdsl1goo'), // Decoded: 'steam_api.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $AF7EEAE1; FileCrc: $EA8E3FDE; EncodedName: 'gdwd_txhvw_uxv_urerwv1tpp'), // Decoded: 'data\quest\rus\robots.qmm'
    (NameCrc: $24B582E2; FileCrc: $CED8AE1E; EncodedName: 'gdwd_txhvw_uxv_guxjv1tpp'), // Decoded: 'data\quest\rus\drugs.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $05787AE6; FileCrc: $A4C2FBCC; EncodedName: 'gdwd_txhvw_uxv_prl1tpp'), // Decoded: 'data\quest\rus\moi.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $44F7BEEB; FileCrc: $9956B9B4; EncodedName: 'gdwd_txhvw_jhu_edggd|bjhu1tpp'), // Decoded: 'data\quest\ger\badday_ger.qmm'
    (NameCrc: $2866DAEC; FileCrc: $75C69DB4; EncodedName: 'vwhdpbdfk1goo'), // Decoded: 'steam_ach.dll'
    (NameCrc: $D7E63EEC; FileCrc: $791BB1E4; EncodedName: 'gdwd_txhvw_vsd_vleroxvrywbvsd1tpp'), // Decoded: 'data\quest\spa\sibolusovt_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $FA241EF7; FileCrc: $1A741279; EncodedName: 'gdwd_txhvw_jhu_vydurnrnbjhu1tpp'), // Decoded: 'data\quest\ger\svarokok_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $04B6D2FC; FileCrc: $B4290543; EncodedName: 'gdwd_txhvw_vsd_vwhdowkbvsd1tpp'), // Decoded: 'data\quest\spa\stealth_spa.qmm'
    (NameCrc: $9DE5CEFD; FileCrc: $6056D39A; EncodedName: 'gdwd_txhvw_vsd_sulvrqbvsd1tpp'), // Decoded: 'data\quest\spa\prison_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $26E9A301; FileCrc: $6EAD54C1; EncodedName: 'gdwd_txhvw_hqj_sl}}dbhqj1tpp'), // Decoded: 'data\quest\eng\pizza_eng.qmm'
    (NameCrc: $ED48E702; FileCrc: $0A40D434; EncodedName: 'gdwd_txhvw_hqj_px}rqbhqj1tpp'), // Decoded: 'data\quest\eng\muzon_eng.qmm'
    (NameCrc: $179BCB01; FileCrc: $35E540DD; EncodedName: 'gdwd_txhvw_uxv_whvwlqj1tpp'), // Decoded: 'data\quest\rus\testing.qmm'
    (NameCrc: $4A0B1F02; FileCrc: $4D76164D; EncodedName: 'gdwd_txhvw_uxv_nlehuud}xp1tpp'), // Decoded: 'data\quest\rus\kiberrazum.qmm'
    (NameCrc: $52903F04; FileCrc: $AC34AFC9; EncodedName: 'gdwd_txhvw_hqj_iloldobhqj1tpp'), // Decoded: 'data\quest\eng\filial_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $F1E74B07; FileCrc: $18FED95D; EncodedName: 'gdwd_txhvw_hqj_irqfhuvbhqj1tpp'), // Decoded: 'data\quest\eng\foncers_eng.qmm'
    (NameCrc: $6B507F07; FileCrc: $12114320; EncodedName: 'gdwd_txhvw_hqj_ohrqdugrbhqj1tpp'), // Decoded: 'data\quest\eng\leonardo_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C9D9CB0D; FileCrc: $8884639E; EncodedName: 'gdwd_txhvw_jhu_vwhdowkbjhu1tpp'), // Decoded: 'data\quest\ger\stealth_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EC871B0F; FileCrc: $5A79C590; EncodedName: 'pdwul{jdph1goo'), // Decoded: 'matrixgame.dll'
    (NameCrc: $09E0AF10; FileCrc: $E81CC99D; EncodedName: 'gdwd_txhvw_vsd_hoxvbvsd1tpp'), // Decoded: 'data\quest\spa\elus_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $3D10CB15; FileCrc: $B5D3A37D; EncodedName: 'gdwd_txhvw_uxv_joxnl1tpp'), // Decoded: 'data\quest\rus\gluki.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $87B3AF19; FileCrc: $C9C832CE; EncodedName: 'gdwd_txhvw_uxv_flwdghov1tpp'), // Decoded: 'data\quest\rus\citadels.qmm'
    (NameCrc: $8C77D31A; FileCrc: $D334A70C; EncodedName: 'gdwd_txhvw_uxv_vwtbdwdpdq41tpp'), // Decoded: 'data\quest\rus\stq_ataman1.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C3E08B1F; FileCrc: $57E43927; EncodedName: 'gdwd_txhvw_uxv_pdild1tpp'), // Decoded: 'data\quest\rus\mafia.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1429EF22; FileCrc: $8F7514C0; EncodedName: 'gdwd_txhvw_jhu_vwtbedurq6bjhu1tpp'), // Decoded: 'data\quest\ger\stq_baron3_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C5755727; FileCrc: $82CC6DAA; EncodedName: 'gdwd_vfulsw_sfbghvwur|hu1vfu'), // Decoded: 'data\script\pc_destroyer.scr'
    (NameCrc: $58C84328; FileCrc: $63CDE2C8; EncodedName: 'gdwd_vfulsw_sfbsod4;1vfu'), // Decoded: 'data\script\pc_pla18.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9C78DF30; FileCrc: $E41CA7DD; EncodedName: 'gdwd_depds_pdsb51rsw'), // Decoded: 'data\abmap\map_2.opt'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DF817333; FileCrc: $06639A8F; EncodedName: 'gdwd_depds_dpxohw1rsw'), // Decoded: 'data\abmap\amulet.opt'
    (NameCrc: $65C6BB33; FileCrc: $028814BF; EncodedName: 'gdwd_txhvw_vsd_urerwvbvsd1tpp'), // Decoded: 'data\quest\spa\robots_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C9A0FB43; FileCrc: $230269A2; EncodedName: 'gdwd_depds_eurqg5wkhuhyhqjhy441pds'), // Decoded: 'data\abmap\brond2therevengev11.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C36D0F47; FileCrc: $EAE1E7F4; EncodedName: 'gdwd_vfulsw_sfbsod3;1vfu'), // Decoded: 'data\script\pc_pla08.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DCDA834A; FileCrc: $1347CBAC; EncodedName: 'gdwd_txhvw_jhu_mxpshubjhu1tpp'), // Decoded: 'data\quest\ger\jumper_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5807F751; FileCrc: $60D9EE56; EncodedName: 'gdwd_txhvw_hqj_{hqrorjbhqj1tpp'), // Decoded: 'data\quest\eng\xenolog_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $E8C4E757; FileCrc: $D79DE9BB; EncodedName: 'gdwd_txhvw_jhu_udoo|bjhu1tpp'), // Decoded: 'data\quest\ger\rally_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DDC9E75F; FileCrc: $B1E8C689; EncodedName: 'oleyruelviloh1goo'), // Decoded: 'libvorbisfile.dll'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C9A50B61; FileCrc: $A54694FA; EncodedName: 'gdwd_txhvw_uxv_edggd|1tpp'), // Decoded: 'data\quest\rus\badday.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $093B6368; FileCrc: $C94AEFBC; EncodedName: 'gdwd_txhvw_jhu_ohrqdugrbjhu1tpp'), // Decoded: 'data\quest\ger\leonardo_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $072B7B74; FileCrc: $9CDA6630; EncodedName: 'gdwd_txhvw_uxv_pd}h1tpp'), // Decoded: 'data\quest\rus\maze.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9166AF77; FileCrc: $45077906; EncodedName: 'gdwd_depds_pdsb71rsw'), // Decoded: 'data\abmap\map_4.opt'
    (NameCrc: $1F006F77; FileCrc: $17F145FD; EncodedName: 'gdwd_txhvw_uxv_ghswk1tpp'), // Decoded: 'data\quest\rus\depth.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $03ACFF7A; FileCrc: $FE90485C; EncodedName: 'gdwd_txhvw_jhu_eru}xnkdqbjhu1tpp'), // Decoded: 'data\quest\ger\borzukhan_ger.qmm'
    (NameCrc: $124B077A; FileCrc: $806F5E34; EncodedName: 'gdwd_txhvw_jhu_vleroxvrywbjhu1tpp'), // Decoded: 'data\quest\ger\sibolusovt_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $59F53B7E; FileCrc: $C4D2E00E; EncodedName: 'gdwd_txhvw_hqj_frorql}dwlrqbhqj1tpp'), // Decoded: 'data\quest\eng\colonization_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $6050CB80; FileCrc: $2ECD8611; EncodedName: 'gdwd_txhvw_uxv_jodyuhg1tpp'), // Decoded: 'data\quest\rus\glavred.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5067FB82; FileCrc: $504EDE55; EncodedName: 'gdwd_depds_pdsb71pds'), // Decoded: 'data\abmap\map_4.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $49FAA785; FileCrc: $FA7495F2; EncodedName: 'gdwd_txhvw_uxv_hylghqfh1tpp'), // Decoded: 'data\quest\rus\evidence.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $C68E8F88; FileCrc: $1EB0C429; EncodedName: '}ole1goo'), // Decoded: 'zlib.dll'
    (NameCrc: $8A17AF88; FileCrc: $518832B6; EncodedName: 'gdwd_txhvw_hqj_vsdfholqhvbhqj1tpp'), // Decoded: 'data\quest\eng\spacelines_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $9577EB8C; FileCrc: $126CFCF8; EncodedName: 'gdwd_txhvw_uxv_iloldo1tpp'), // Decoded: 'data\quest\rus\filial.qmm'
    (NameCrc: $1A1AF78D; FileCrc: $1EAA8FC9; EncodedName: 'gdwd_txhvw_hqj_wd{lvwbhqj1tpp'), // Decoded: 'data\quest\eng\taxist_eng.qmm'
    (NameCrc: $D44F9F8E; FileCrc: $9EEFE202; EncodedName: 'gdwd_vfulsw_sfbsod351vfu'), // Decoded: 'data\script\pc_pla02.scr'
    (NameCrc: $A6D5A38F; FileCrc: $2BBC5E4D; EncodedName: 'gdwd_vfulsw_pvbse1vfu'), // Decoded: 'data\script\ms_pb.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $166F5396; FileCrc: $5D0FF6B0; EncodedName: 'gdwd_vfulsw_sfbsduw81vfu'), // Decoded: 'data\script\pc_part5.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $04825799; FileCrc: $E2082079; EncodedName: 'gdwd_txhvw_uxv_sludwhfodqsulvrq1tpp'), // Decoded: 'data\quest\rus\pirateclanprison.qmm'
    (NameCrc: $7D11339A; FileCrc: $315A71F2; EncodedName: 'gdwd_txhvw_vsd_sod|hubvsd1tpp'), // Decoded: 'data\quest\spa\player_spa.qmm'
    (NameCrc: $4601739B; FileCrc: $D8ADF2E0; EncodedName: 'gdwd_vfulsw_sfbsod491vfu'), // Decoded: 'data\script\pc_pla16.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $A8DA2F9D; FileCrc: $C790A1A0; EncodedName: 'gdwd_txhvw_hqj_skdudrqbhqj1tpp'), // Decoded: 'data\quest\eng\pharaon_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $0A306FA2; FileCrc: $798EF5B6; EncodedName: 'gdwd_txhvw_uxv_sursurorj1tpp'), // Decoded: 'data\quest\rus\proprolog.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5A4B77A4; FileCrc: $393AA51F; EncodedName: 'gdwd_txhvw_jhu_ilvklqjfxsbjhu1tpp'), // Decoded: 'data\quest\ger\fishingcup_ger.qmm'
    (NameCrc: $345073A5; FileCrc: $979BAFA0; EncodedName: 'gdwd_txhvw_vsd_hghozhlvvbvsd1tpp'), // Decoded: 'data\quest\spa\edelweiss_spa.qmm'
    (NameCrc: $42F4A3A6; FileCrc: $7774BFF4; EncodedName: 'gdwd_vfulsw_sfbsod471vfu'), // Decoded: 'data\script\pc_pla14.scr'
    (NameCrc: $52BD07A6; FileCrc: $EB0B57F9; EncodedName: 'gdwd_txhvw_hqj_orjlfbhqj1tpp'), // Decoded: 'data\quest\eng\logic_eng.qmm'
    (NameCrc: $C38FE7A5; FileCrc: $C33088FF; EncodedName: 'gdwd_txhvw_uxv_vwtbedurq51tpp'), // Decoded: 'data\quest\rus\stq_baron2.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $095A4BAA; FileCrc: $0665C841; EncodedName: 'gdwd_txhvw_uxv_frgher{1tpp'), // Decoded: 'data\quest\rus\codebox.qmm'
    (NameCrc: $129A83AB; FileCrc: $D2A23C21; EncodedName: 'gdwd_vfulsw_sfbsduw:1vfu'), // Decoded: 'data\script\pc_part7.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $B77AE7AF; FileCrc: $9E80035C; EncodedName: 'gdwd_txhvw_hqj_nlgqdsshgbhqj1tpp'), // Decoded: 'data\quest\eng\kidnapped_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5F197BB2; FileCrc: $6747A1F6; EncodedName: 'gdwd_txhvw_uxv_iduxn1tpp'), // Decoded: 'data\quest\rus\faruk.qmm'
    (NameCrc: $E84343B2; FileCrc: $0E8615D4; EncodedName: 'gdwd_txhvw_hqj_grrplqrbhqj1tpp'), // Decoded: 'data\quest\eng\doomino_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $08A1AFB6; FileCrc: $19212459; EncodedName: 'gdwd_depds_eurqg5wkhuhyhqjhy441rsw'), // Decoded: 'data\abmap\brond2therevengev11.opt'
    (NameCrc: $C80107B7; FileCrc: $C099D269; EncodedName: 'gdwd_txhvw_uxv_ihlsv|fkr1tpp'), // Decoded: 'data\quest\rus\feipsycho.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $EB6CDFBB; FileCrc: $1D795F8A; EncodedName: 'gdwd_txhvw_hqj_flwdghovbhqj1tpp'), // Decoded: 'data\quest\eng\citadels_eng.qmm'
    (NameCrc: $E7D147BB; FileCrc: $7FAE8555; EncodedName: 'gdwd_txhvw_uxv_glyhu1tpp'), // Decoded: 'data\quest\rus\diver.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1F55A7C0; FileCrc: $A901F0D5; EncodedName: 'gdwd_txhvw_vsd_vydurnrnbvsd1tpp'), // Decoded: 'data\quest\spa\svarokok_spa.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $5D798BC5; FileCrc: $16691B23; EncodedName: 'gdwd_depds_pdsb51pds'), // Decoded: 'data\abmap\map_2.map'
    (NameCrc: $1E8027C6; FileCrc: $2E845170; EncodedName: 'gdwd_depds_dpxohw1pds'), // Decoded: 'data\abmap\amulet.map'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $AE54B3C8; FileCrc: $5954DFB8; EncodedName: 'gdwd_txhvw_hqj_vwtbedurq4bhqj1tpp'), // Decoded: 'data\quest\eng\stq_baron1_eng.qmm'
    (NameCrc: $D951EFC9; FileCrc: $4646E623; EncodedName: 'gdwd_vfulsw_sfbsod371vfu'), // Decoded: 'data\script\pc_pla04.scr'
    (NameCrc: $6ACE53CA; FileCrc: $DBEB1E0E; EncodedName: 'gdwd_txhvw_uxv_nlgqdsshg1tpp'), // Decoded: 'data\quest\rus\kidnapped.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1B7123D1; FileCrc: $F3EE6AE7; EncodedName: 'gdwd_vfulsw_sfbsduw61vfu'), // Decoded: 'data\script\pc_part3.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $BB1823DA; FileCrc: $9CAB9713; EncodedName: 'gdwd_txhvw_hqj_frpsoh{bhqj1tpp'), // Decoded: 'data\quest\eng\complex_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4B1F03DC; FileCrc: $07EF48B5; EncodedName: 'gdwd_vfulsw_sfbsod431vfu'), // Decoded: 'data\script\pc_pla10.scr'
    (NameCrc: $C33DEBDC; FileCrc: $AD28D94A; EncodedName: 'gdwd_txhvw_uxv_{hqrsdun1tpp'), // Decoded: 'data\quest\rus\xenopark.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $532353DF; FileCrc: $4D5446C2; EncodedName: 'gdwd_txhvw_hqj_grprfodqbhqj1tpp'), // Decoded: 'data\quest\eng\domoclan_eng.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $4FEAD3E1; FileCrc: $121C260A; EncodedName: 'gdwd_vfulsw_sfbsod451vfu'), // Decoded: 'data\script\pc_pla12.scr'
    (NameCrc: $2AEE43E1; FileCrc: $0CD0F997; EncodedName: 'gdwd_txhvw_vsd_irqfhuvbvsd1tpp'), // Decoded: 'data\quest\spa\foncers_spa.qmm'
    (NameCrc: $CE9197E2; FileCrc: $CEEA6BEF; EncodedName: 'gdwd_txhvw_uxv_vwtbedurq71tpp'), // Decoded: 'data\quest\rus\stq_baron4.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $1F84F3EC; FileCrc: $60B2D128; EncodedName: 'gdwd_vfulsw_sfbsduw41vfu'), // Decoded: 'data\script\pc_part1.scr'
    (NameCrc: $28F62BEC; FileCrc: $30DB11C5; EncodedName: 'gdwd_txhvw_uxv_mxpshu1tpp'), // Decoded: 'data\quest\rus\jumper.qmm'
    (NameCrc: $73DD0BEC; FileCrc: $578630B1; EncodedName: 'gdwd_txhvw_hqj_mxpshubhqj1tpp'), // Decoded: 'data\quest\eng\jumper_eng.qmm'
    (NameCrc: $E4B797EE; FileCrc: $CAA7D4BB; EncodedName: 'gdwd_txhvw_jhu_ghswkbjhu1tpp'), // Decoded: 'data\quest\ger\depth_ger.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $307AE3F1; FileCrc: $3F3B7D43; EncodedName: 'gdwd_txhvw_uxv_dpqhvld1tpp'), // Decoded: 'data\quest\rus\amnesia.qmm'
    (NameCrc: $263033F2; FileCrc: $1CAB4526; EncodedName: 'gdwd_vfulsw_sfbihpbudqjhuv1vfu'), // Decoded: 'data\script\pc_fem_rangers.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $DDA43FF4; FileCrc: $C20289FA; EncodedName: 'gdwd_vfulsw_sfbsod391vfu'), // Decoded: 'data\script\pc_pla06.scr'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $65D11FF8; FileCrc: $BECA3724; EncodedName: 'gdwd_txhvw_uxv_udoo|1tpp'), // Decoded: 'data\quest\rus\rally.qmm'
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: ''),
    (NameCrc: $00000000; FileCrc: $00000000; EncodedName: '')
  ); // @addr $87EC14
const
  ResourceDatSeedKey: Cardinal = $EA8F3F37; // @addr $881C14
  ResourceDatCrcKey1: Cardinal = $7DB6C99D; // @addr $881C18
  ResourceDatCrcKey2: Cardinal = $C83FCBF3; // @addr $881C1C

implementation

// @unit-initialization $876A68
// @unit-finalization $7F27D4

uses EC_Str, Windows, SysUtils, GlobalsV, CrcUnit, GR_Main;

{ @routine $7F1438 TDataFileEC_Create }
constructor TDataFileEC.Create;
begin
  inherited Create;
  FileRef := TFileEC.Create;
end;
{ @end $7F1438 }

{ @routine $7F148C TDataFileEC_Destroy }
destructor TDataFileEC.Destroy;
begin
  Clear;
  FileRef.Free;
  inherited Destroy;
end;
{ @end $7F148C }

{ @routine $7F14D0 TDataFileEC_Clear }
procedure TDataFileEC.Clear;
begin
end;
{ @end $7F14D0 }

{ @routine $7F14DC TDataElEC_Create }
constructor TDataElEC.Create;
begin
  inherited Create;
end;
{ @end $7F14DC }

{ @routine $7F1520 TDataElEC_Destroy }
destructor TDataElEC.Destroy;
begin
  ClearChildData;
  inherited Destroy;
end;
{ @end $7F1520 }

{ @routine $7F155C TDataElEC_ClearChildData }
procedure TDataElEC.ClearChildData;
begin
  if ChildData <> nil then
  begin
    ChildData.Free;
    ChildData := nil;
  end;
end;
{ @end $7F155C }

{ @routine $7F1584 TDataEC_Create }
constructor TDataEC.Create;
begin
  inherited Create;
  FileLock := TCriticalSection.Create;
  InternedFileListHeadRef := @OwnedInternedFileListHead;
  InternedFileListTailRef := @OwnedInternedFileListTail;
end;
{ @end $7F1584 }

{ @routine $7F15F0 TDataEC_Destroy }
destructor TDataEC.Destroy;
begin
  Clear;
  FileLock.Free;
  inherited Destroy;
end;
{ @end $7F15F0 }

{ @routine $7F1634 TDataEC_IsEmpty }
function TDataEC.IsEmpty: Boolean;
begin
  Result := FirstEntry = nil;
end;
{ @end $7F1634 }

{ @routine $7F1650 TDataEC_Clear }
procedure TDataEC.Clear;
var FileEntry, RemovedFile: TDataFileEC;
    Entry, RemovedEntry: TDataElEC;
begin
  if not SharesInternedFileList then
  begin
    FileEntry := InternedFileListHeadRef^;
    while FileEntry <> nil do
    begin
      RemovedFile := FileEntry;
      FileEntry := FileEntry.Next;
      RemovedFile.Free;
    end;
  end;
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    RemovedEntry := Entry;
    Entry := Entry.Next;
    RemovedEntry.Free;
  end;
  SharesInternedFileList := False;
  InternedFileListHeadRef := @OwnedInternedFileListHead;
  InternedFileListTailRef := @OwnedInternedFileListTail;
  IndexedEntries := nil;
  IndexedEntryCount := 0;
end;
{ @end $7F1650 }

{ @routine $7F16F8 TDataEC_AddEntry }
function TDataEC.AddEntry(EntryKind: TDataEntryKind): TDataElEC;
var Entry: TDataElEC;
begin
  Entry := TDataElEC.Create;
  if LastEntry <> nil then LastEntry.Next := Entry;
  Entry.Prev := LastEntry;
  Entry.Next := nil;
  LastEntry := Entry;
  if FirstEntry = nil then FirstEntry := Entry;
  Entry.Kind := EntryKind;
  if EntryKind <> dekFile then
  begin
    Entry.ChildData := TDataEC.Create;
    Entry.ChildData.SharesInternedFileList := True;
    Entry.ChildData.InternedFileListHeadRef := InternedFileListHeadRef;
    Entry.ChildData.InternedFileListTailRef := InternedFileListTailRef;
  end;
  Result := Entry;
end;
{ @end $7F16F8 }

{ @routine $7F17B0 TDataEC_FindIndexedEntry }
function TDataEC.FindIndexedEntry(const Name: WideString): TDataElEC;
var Lo, Hi, Mid, Order: Integer;
    Entry: TDataElEC;
begin
  if IndexedEntryCount < 1 then
  begin Result := nil; Exit end;
  Lo := 0;
  Hi := IndexedEntryCount - 1;
  repeat
    Mid := (Hi - Lo) div 2 + Lo;
    Entry := IndexedEntries[Mid];
    Order := CompareWideChars(PWideChar(Name), PWideChar(Entry.Name));
    if Order = 0 then
    begin Result := Entry; Exit end;
    if Order < 0 then Hi := Mid - 1 else Lo := Mid + 1;
  until Hi < Lo;
  Result := nil;
end;
{ @end $7F17B0 }

{ @routine $7F1858 TDataEC_FindInsertionIndex }
function TDataEC.FindInsertionIndex(Entry: TDataElEC): Integer;
var Lo, Hi, Mid, Order: Integer;
    Existing: TDataElEC;
begin
  if IndexedEntryCount <= 0 then
  begin Result := 0; Exit end;
  Lo := 0;
  Hi := IndexedEntryCount - 1;
  repeat
    Mid := ((Hi - Lo) shr 1) + Lo;
    Existing := IndexedEntries[Mid];
    Order := CompareWideChars(PWideChar(Entry.Name), PWideChar(Existing.Name));
    if Order = 0 then
    begin Result := Mid; Exit end;
    if Order < 0 then Hi := Mid - 1 else Lo := Mid + 1;
  until Hi < Lo;
  if Order < 0 then Result := Mid else Result := Mid + 1;
end;
{ @end $7F1858 }

{ @routine $7F1910 TDataEC_InsertIntoIndex }
procedure TDataEC.InsertIntoIndex(Entry: TDataElEC);
var Index: Integer;
begin
  SetLength(IndexedEntries, IndexedEntryCount + 1);
  Index := FindInsertionIndex(Entry);
  if Index >= IndexedEntryCount then
  begin
    IndexedEntries[IndexedEntryCount] := Entry;
    Inc(IndexedEntryCount);
  end
  else
  begin
    Windows.MoveMemory(@IndexedEntries[Index + 1], @IndexedEntries[Index], (IndexedEntryCount - Index) * SizeOf(IndexedEntries[0]));
    IndexedEntries[Index] := Entry;
    Inc(IndexedEntryCount);
  end;
end;
{ @end $7F1910 }

{ @routine $7F19B8 TDataEC_RebuildIndex }
procedure TDataEC.RebuildIndex;
var Entry: TDataElEC;
begin
  SetLength(IndexedEntries, 0);
  IndexedEntryCount := 0;
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    InsertIntoIndex(Entry);
    Entry := Entry.Next;
  end;
end;
{ @end $7F19B8 }

{ @routine $7F1A14 TDataEC_InternFileName }
function TDataEC.InternFileName(const FileName: WideString): TDataFileEC;
var Entry: TDataFileEC;
begin
  Entry := InternedFileListHeadRef^;
  while Entry <> nil do
  begin
    if Entry.FileRef.GetFileName = FileName then
    begin Result := Entry; Exit end;
    Entry := Entry.Next;
  end;
  Entry := TDataFileEC.Create;
  if InternedFileListTailRef^ <> nil then InternedFileListTailRef^.Next := Entry;
  Entry.Prev := InternedFileListTailRef^;
  Entry.Next := nil;
  InternedFileListTailRef^ := Entry;
  if InternedFileListHeadRef^ = nil then InternedFileListHeadRef^ := Entry;
  Entry.FileRef.SetFileName(FileName);
  Result := Entry;
end;
{ @end $7F1A14 }

{ @routine $7F1B10 TDataEC_FindEntry }
function TDataEC.FindEntry(const Name: WideString): TDataElEC;
begin
  Result := FindIndexedEntry(Name);
end;
{ @end $7F1B10 }

{ @routine $7F1BC8 TDataEC_FindEntryByPath }
function TDataEC.FindEntryByPath(const Path: WideString): TDataElEC;
var Position, PathLength, PartStart, PartLength: Integer;
    Entry: TDataElEC;
    Data: TDataEC;
  // @nested $7F1B34 NextDataPathComponent
  function NextDataPathComponent: Boolean; // @addr 0x7F1B34 @ida "bool __cdecl $name(void *ParentFrame);" @note "Nested helper of TDataEC.FindEntryByPath; requires its parent stack frame."
  var Ch: WideChar;
      i: Integer;
  begin
    if Position >= PathLength then
    begin Result := False; Exit end;
    PartStart := Position;
    i := PartStart;
    while PathLength > i do
    begin
      Ch := Path[i + 1];
      if (Ch = '.') or (Ch = '/') or (Ch = '\') then Break;
      Inc(i);
    end;
    PartLength := i - PartStart;
    Position := i + 1;
    Result := True;
  end;
begin
  PathLength := Length(Path);
  Position := 0;
  Data := Self;
  while NextDataPathComponent do
  begin
    Entry := Data.FindEntry(Copy(Path, PartStart + 1, PartLength));
    if Entry = nil then Break;
    if Position >= PathLength then
    begin Result := Entry; Exit end;
    if Entry.Kind <> dekSubtree then Break;
    Data := Entry.ChildData;
  end;
  Result := nil;
end;
{ @end $7F1BC8 }

{ @routine $7F1C7C TDataEC_ReadEntryBuffer }
procedure TDataEC.ReadEntryBuffer(Entry: TDataElEC; Dest: TBufEC);
var Size: Integer;
begin
  VerifyResourceFileChecksum(Entry.SharedFileRef.FileRef.FileName);
  FileLock.Enter;
  Entry.SharedFileRef.FileRef.AcquireReadWriteHandle;
  try
    if Entry.FileOffset <> 0 then Entry.SharedFileRef.FileRef.SetPointer(Entry.FileOffset, FILE_BEGIN);
    Size := Entry.ByteCount;
    if Size < 0 then Size := Entry.SharedFileRef.FileRef.GetSize - Entry.FileOffset;
    Dest.LoadFromFileChunk(Entry.SharedFileRef.FileRef, Size);
  finally
    Entry.SharedFileRef.FileRef.ReleaseHandle;
    FileLock.Leave;
  end;
end;
{ @end $7F1C7C }

{ @routine $7F1D50 TDataEC_GetData }
function TDataEC.GetData(const Name: WideString): TDataEC;
var Entry: TDataElEC;
begin
  Entry := FindEntry(Name);
  if (Entry = nil) or (Entry.Kind <> dekSubtree) then
    raise Exception.Create('TDataEC.GetData. name=' + Name);
  Result := Entry.ChildData;
end;
{ @end $7F1D50 }

{ @routine $7F1E28 TDataEC_ReadBufferByPath }
procedure TDataEC.ReadBufferByPath(const Path: WideString; Dest: TBufEC);
var Entry: TDataElEC;
begin
  Entry := FindEntryByPath(Path);
  if (Entry = nil) or (Entry.Kind <> dekFile) then
    raise Exception.Create('TDataEC.PathGetBuf. path=' + Path);
  ReadEntryBuffer(Entry, Dest);
end;
{ @end $7F1E28 }

{ @routine $7F1F0C TDataEC_FileExistsByPath }
function TDataEC.FileExistsByPath(const Path: WideString): Boolean;
var Entry: TDataElEC;
begin
  Entry := FindEntryByPath(Path);
  if (Entry = nil) or (Entry.Kind <> dekFile) then
  begin Result := False; Exit end;
  if (Entry.SharedFileRef <> nil) and (Entry.SharedFileRef.FileRef <> nil) and
     Entry.SharedFileRef.FileRef.TryAcquireReadHandle(False) then
    Entry.SharedFileRef.FileRef.ReleaseHandle
  else
  begin Result := False; Exit end;
  Result := True;
end;
{ @end $7F1F0C }

{ @routine $7F1F88 TDataEC_AddMissingFromBlock }
procedure TDataEC.AddMissingFromBlock(Block: TBlockParEC);
var Count, i: Integer;
    Kind: TBlockParKind;
    Entry: TDataElEC;
begin
  Count := Block.GetEntryCount;
  for i := 0 to Count - 1 do
  begin
    Kind := Block.GetEntryKindByIndex(i);
    if (Kind = bpkString) or (Kind = bpkBlock) then
      if FindEntry(Block.GetEntryNameByIndex(i)) <> nil then Continue;
    if Kind = bpkString then
    begin
      Entry := AddEntry(dekFile);
      Entry.Name := Block.GetEntryNameByIndex(i);
      Entry.SharedFileRef := InternFileName(Block.GetEntryStringByIndex(i));
      Entry.FileOffset := 0;
      Entry.ByteCount := -1;
      InsertIntoIndex(Entry);
    end
    else if Kind = bpkBlock then
    begin
      Entry := AddEntry(dekSubtree);
      Entry.Name := Block.GetEntryNameByIndex(i);
      InsertIntoIndex(Entry);
      Entry.ChildData.AddMissingFromBlock(Block.GetEntryBlockByIndex(i));
    end;
  end;
end;
{ @end $7F1F88 }

{ @routine $7F2104 TDataEC_WriteToBlock }
procedure TDataEC.WriteToBlock(Block: TBlockParEC);
var i: Integer;
    Entry: TDataElEC;
begin
  for i := 0 to IndexedEntryCount - 1 do
  begin
    Entry := IndexedEntries[i];
    if Entry.Kind = dekFile then
      Block.AddParam(Entry.Name, Entry.SharedFileRef.FileRef.GetFileName)
    else Entry.ChildData.WriteToBlock(Block.AddChildBlock(Entry.Name));
  end;
end;
{ @end $7F2104 }

{ @routine $7F21BC TDataEC_MergeFrom }
procedure TDataEC.MergeFrom(Source: TDataEC);
var Entry, Existing: TDataElEC;
begin
  Entry := Source.FirstEntry;
  while Entry <> nil do
  begin
    Existing := FindIndexedEntry(Entry.Name);
    if Existing = nil then
    begin
      Existing := AddEntry(Entry.Kind);
      Existing.Name := Entry.Name;
    end
    else if Entry.Kind <> Existing.Kind then
    begin
      Entry := Entry.Next;
      Continue;
    end;
    if Integer(Entry.Kind) <> 0 then
      if Entry.Kind = dekFile then
      begin
        Existing.FileOffset := 0;
        Existing.ByteCount := -1;
        Existing.SharedFileRef := InternFileName(Entry.SharedFileRef.FileRef.FileName);
      end
      else if Entry.Kind = dekSubtree then Existing.ChildData.MergeFrom(Entry.ChildData);
    Entry := Entry.Next;
  end;
  RebuildIndex;
end;
{ @end $7F21BC }

{ @routine $7F22A8 TDataEC_LoadFromDecodedBuffer }
procedure TDataEC.LoadFromDecodedBuffer(Buf: TBufEC);
var Entry: TDataElEC;
    i: Integer;
    Kind: TDataEntryKind;
begin
  Clear;
  IndexedEntryCount := Buf.GetInt32;
  SetLength(IndexedEntries, IndexedEntryCount);
  for i := 0 to IndexedEntryCount - 1 do
  begin
    Kind := TDataEntryKind(Buf.GetByte);
    Entry := AddEntry(Kind);
    Entry.Name := Buf.ReadWideString;
    Entry.FileOffset := 0;
    Entry.ByteCount := -1;
    if Kind = dekFile then Entry.SharedFileRef := InternFileName(Buf.ReadWideString)
    else Entry.ChildData.LoadFromDecodedBuffer(Buf);
    IndexedEntries[i] := Entry;
  end;
end;
{ @end $7F22A8 }

{ @routine $7F23D8 TDataEC_LoadFromEncryptedDatFile }
procedure TDataEC.LoadFromEncryptedDatFile(const FileName: WideString);
var
  Buf: TBufEC;
  FileObj: TFileEC;
  Crc: Cardinal;
  Seed: Integer;
  ByteCount: Integer;
  ExpectedOuter, Position: Cardinal;
begin
  FileObj := TFileEC.Create;
  FileObj.SetFileName(WideString(PWideChar(FileName)));
  FileObj.AcquireReadHandle(False);
  Position := FileObj.GetPointer;
  FileObj.ReadBuffer(@ByteCount, SizeOf(ByteCount));
  FileObj.ReadBuffer(@ExpectedOuter, SizeOf(ExpectedOuter));
  ByteCount := ByteCount xor (ResourceDatCrcKey1 xor ResourceDatCrcKey2);
  if FileObj.GetSize - FileObj.GetPointer = Cardinal(ByteCount) then
  begin
    Buf := TBufEC.Create;
    Buf.SetSize(ByteCount + SizeOf(Crc));
    Position := FileObj.GetPointer;
    FileObj.ReadBuffer(Pointer(PAnsiChar(Buf.Data) + SizeOf(Crc)), Buf.DataSize - SizeOf(Crc));
    Crc := Buf.ComputeCrc32Range(SizeOf(Crc), Buf.DataSize) xor ResourceDatCrcKey1;
    PCardinal(Buf.Data)^ := Crc;
    Crc := Buf.ComputeCrc32 xor ResourceDatCrcKey2;
    Buf.Free;
    if Crc <> ExpectedOuter then GR_Main.CCInterface.SetResourceChecksumFailed(True);
  end
  else GR_Main.CCInterface.SetResourceChecksumFailed(True);
  FileObj.SetPointer(Position, FILE_BEGIN);
  ByteCount := FileObj.GetSize - FileObj.GetPointer;
  FileObj.ReadBuffer(@Crc, SizeOf(Crc));
  FileObj.ReadBuffer(@Seed, SizeOf(Seed));
  Seed := Seed xor ResourceDatSeedKey;
  Buf := TBufEC.Create;
  Buf.SetSize(ByteCount - SizeOf(Crc) - SizeOf(Seed));
  FileObj.ReadBuffer(Buf.Data, Buf.DataSize);
  Buf.ApplyDatXorCipher(Seed);
  if Buf.ComputeCrc32 = Crc then
  begin
    Buf.ExpandZlibPayloadInPlace;
    Buf.SetPosition(0);
    LoadFromDecodedBuffer(Buf);
  end;
  Buf.Free;
  FileObj.Free;
end;
{ @end $7F23D8 }

{ @routine $7F2614 VerifyResourceFileChecksum }
procedure VerifyResourceFileChecksum(const FileName: WideString);
var LowerName: WideString;
    CharacterIndex, Index, NameLength, TableSize: Integer;
    NameCrc: Cardinal;
    Ch: WideChar;
    Buf: TBufEC;
begin
  NameLength := Length(FileName);
  SetLength(LowerName, NameLength);
  for Index := 0 to NameLength - 1 do
  begin
    Ch := FileName[Index + 1];
    if (Ch >= 'A') and (Ch <= 'Z') then Ch := WideChar(Ord(Ch) - Ord('A') + Ord('a'));
    LowerName[Index + 1] := Ch;
  end;
  NameCrc := ComputeCrc32(PWideChar(LowerName), NameLength * SizeOf(WideChar));
  TableSize := Length(ResourceChecksums);
  Index := (TableSize - 1) and NameCrc;
  while ResourceChecksums[Index].NameCrc <> 0 do
  begin
    if (ResourceChecksums[Index].NameCrc = NameCrc) and
       (Length(ResourceChecksums[Index].EncodedName) = NameLength) then
    begin
      CharacterIndex := 0;
      while CharacterIndex < NameLength do
      begin
        if ResourceChecksums[Index].EncodedName[CharacterIndex + 1] <>
           WideChar(Ord(LowerName[CharacterIndex + 1]) + 3) then Break;
        Inc(CharacterIndex);
      end;
      if CharacterIndex >= NameLength then
      begin
        Buf := TBufEC.Create;
        Buf.LoadFromWideFilePath(PWideChar(FileName));
        if Buf.ComputeCrc32 <> ResourceChecksums[Index].FileCrc then
          GR_Main.CCInterface.SetResourceChecksumFailed(True);
        Buf.Free;
        Break;
      end;
    end;
    Inc(Index);
    if Index >= TableSize then Index := 0;
  end;
end;
{ @end $7F2614 }

end.
