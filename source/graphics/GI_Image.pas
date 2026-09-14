unit GI_Image;
// Unit bracket (inferred): .text 0x0048998C..0x0048ACD0; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_GAI, GI_MessageLoop, GI_Main, GI_AImage, GI_AlphaImage, GI_GI, GI_TransImage, GI_SimpleImage, GI_GraphBuf, Classes, Types;

type
  TImageGI = class(TObjectGI) // @size 0x144
  public
    SimpleImageControl: TSimpleImageGI; // @offset 0x120
    TransImageControl: TTransImageGI; // @offset 0x124
    AlphaImageControl: TAlphaImageGI; // @offset 0x128
    GiImageControl: TgiGI; // @offset 0x12C
    AnimImageControl: TAImageGI; // @offset 0x130
    GaiImageControl: TgaiGI; // @offset 0x134
    GraphBufControl: TGraphBufGI; // @offset 0x138
    ImagePath: WideString; // @offset 0x13C
    AutoUpdateFlags: Cardinal; // @offset 0x140

    constructor Create(Owner: TObjectGI); // @addr 0x489ABC @ida "TImageGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x489B04 @ida "void __usercall $name(TImageGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x489B38
    procedure SetImagePath(Path: WideString); // @addr 0x489B4C @note "Empty paths remove the child; unknown modes raise."
    function GetImagePath: WideString; // @addr 0x48A204 @ida "void __usercall $name(TImageGI *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetContentSize: TPoint; // @addr 0x48A228 @ida "void __usercall $name(TImageGI *Self@<eax>, TPoint *Result@<edx>);"
    function GetContentOrigin: TPoint; // @addr 0x48A344 @ida "void __usercall $name(TImageGI *Self@<eax>, TPoint *Result@<edx>);" @note "Only GI children supply an origin; other kinds return (0,0)."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x48A380
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x48A470
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x48A560 @note "Only affects Simple, Trans and Anim children."
    function GetAlpha: Byte; // @addr 0x48A5CC @note "Returns GI/GAI alpha, or 255 for other kinds."
    procedure SetAlpha(Value: Byte); // @addr 0x48A620 @note "Only affects GI/GAI children."
    procedure SetSize(Size: TPoint); override; // @addr 0x48A66C @ida "void __usercall $name(TImageGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure SetOrigin(Origin: TPoint); override; // @addr 0x48A76C @ida "void __usercall $name(TImageGI *Self@<eax>, TPoint *Origin@<edx>);"
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x48A87C @ida "bool __usercall $name@<al>(TImageGI *Self@<eax>, TPoint *Point@<edx>);" @note "Returns false for kinds other than Alpha, Anim, GI and GAI."
    function GetVisualCenter: TPoint; // @addr 0x48A924 @ida "void __usercall $name(TImageGI *Self@<eax>, TPoint *Result@<edx>);" @note "Only GI and GraphBuf write the result; other kinds leave it untouched."
    procedure RestartPlayback; // @addr 0x48A970
    procedure StopPlayback; // @addr 0x48A994
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x48A9B8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x48A9EC
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x48AA14
    procedure UpdateAutoGeometry; override; // @addr 0x48ABAC @note "Auto-geometry bit 0 uses content origin; bit 1 uses content size."
    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $48ACD4 Delegates to the GAI or GI child.
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x48AC28 @note "GI and GraphBuf children are skipped."
  end;

implementation

uses SysUtils, GlobalsV, EC_Str, GR_Main;


{ @routine $489ABC TImageGI_Create }
constructor TImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $489ABC }

{ @routine $489B04 TImageGI_Destroy }
destructor TImageGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $489B04 }

{ @routine $489B38 TImageGI_Clear }
procedure TImageGI.Clear;
begin
  inherited Clear;
end;
{ @end $489B38 }

{ @routine $489B4C TImageGI_SetImagePath }
procedure TImageGI.SetImagePath(Path: WideString);
var Mode: WideString;
begin
  if ImagePath <> Path then
  begin
    if SimpleImageControl <> nil then
    begin
      FreeOwnedChild(SimpleImageControl);
      SimpleImageControl := nil;
    end;
    if TransImageControl <> nil then
    begin
      FreeOwnedChild(TransImageControl);
      TransImageControl := nil;
    end;
    if AlphaImageControl <> nil then
    begin
      FreeOwnedChild(AlphaImageControl);
      AlphaImageControl := nil;
    end;
    if GiImageControl <> nil then
    begin
      FreeOwnedChild(GiImageControl);
      GiImageControl := nil;
    end;
    if AnimImageControl <> nil then
    begin
      FreeOwnedChild(AnimImageControl);
      AnimImageControl := nil;
    end;
    if GaiImageControl <> nil then
    begin
      FreeOwnedChild(GaiImageControl);
      GaiImageControl := nil;
    end;
    if GraphBufControl <> nil then
    begin
      FreeOwnedChild(GraphBufControl);
      GraphBufControl := nil;
    end;
    if Path = '' then
    begin
      ImagePath := '';
      Invalidate;
    end
    else
    begin
      ImagePath := Path;
      Mode := ExtractNextDelimitedPartW(Path, ',');
      if Mode = 'GraphBuf' then
      begin
        GraphBufControl := TGraphBufGI.Create(Self, False);
        GraphBufControl.SetSize(ClientSize);
        GraphBufControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Path = '' then
      begin
        SimpleImageControl := TSimpleImageGI.Create(Self);
        SimpleImageControl.SetImagePath(Mode);
        SimpleImageControl.SetSize(ClientSize);
        SimpleImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'Simple' then
      begin
        SimpleImageControl := TSimpleImageGI.Create(Self);
        SimpleImageControl.SetImagePath(Path);
        SimpleImageControl.SetSize(ClientSize);
        SimpleImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'Trans' then
      begin
        TransImageControl := TTransImageGI.Create(Self);
        TransImageControl.SetImagePath(Path);
        TransImageControl.SetSize(ClientSize);
        TransImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'Alpha' then
      begin
        AlphaImageControl := TAlphaImageGI.Create(Self);
        AlphaImageControl.SetImagePath(Path);
        AlphaImageControl.SetSize(ClientSize);
        AlphaImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'GI' then
      begin
        GiImageControl := TgiGI.Create(Self);
        GiImageControl.SetImagePath(Path);
        GiImageControl.SetSize(ClientSize);
        GiImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'Anim' then
      begin
        AnimImageControl := TAImageGI.Create(Self);
        AnimImageControl.SetConfigPath(Path);
        AnimImageControl.SetSize(ClientSize);
        AnimImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
      end
      else if Mode = 'GAI' then
      begin
        GaiImageControl := TgaiGI.Create(Self);
        GaiImageControl.SetImagePath(Path);
        GaiImageControl.SetSize(ClientSize);
        GaiImageControl.SetPosition(Classes.Point(-OriginPoint.X, -OriginPoint.Y));
        if GaiImageControl.GetSequenceCount > 0 then
        begin
          GaiImageControl.SequenceIndex := 0;
          GaiImageControl.UpdateAutoGeometry;
          GaiImageControl.RestartPlayback;
        end;
      end
      else raise Exception.Create('TImageGI.SetImage. Path=' + Path);
    end;
  end;
end;
{ @end $489B4C }

{ @routine $48A204 TImageGI_GetImagePath }
function TImageGI.GetImagePath: WideString;
begin
  Result := ImagePath;
end;
{ @end $48A204 }

{ @routine $48A228 TImageGI_GetContentSize }
function TImageGI.GetContentSize: TPoint;
begin
  if SimpleImageControl <> nil then Result := SimpleImageControl.GetContentSize
  else if TransImageControl <> nil then Result := TransImageControl.GetContentSize
  else if AlphaImageControl <> nil then Result := AlphaImageControl.GetContentSize
  else if GiImageControl <> nil then Result := GiImageControl.GetContentSize
  else if AnimImageControl <> nil then Result := AnimImageControl.GetContentSize
  else if GaiImageControl <> nil then Result := GaiImageControl.GetContentSize
  else if GraphBufControl <> nil then Result := Classes.Point(GraphBufControl.GraphBuf.Width, GraphBufControl.GraphBuf.Height)
  else Result := Classes.Point(0, 0);
end;
{ @end $48A228 }

{ @routine $48A344 TImageGI_GetContentOrigin }
function TImageGI.GetContentOrigin: TPoint;
begin
  if GiImageControl <> nil then Result := GiImageControl.GetContentOrigin
  else Result := Classes.Point(0, 0);
end;
{ @end $48A344 }

{ @routine $48A380 TImageGI_SetImageKindX }
procedure TImageGI.SetImageKindX(Value: TImageKindXGI);
begin
  if SimpleImageControl <> nil then SimpleImageControl.SetImageKindX(Value)
  else if TransImageControl <> nil then TransImageControl.SetImageKindX(Value)
  else if AlphaImageControl <> nil then AlphaImageControl.SetImageKindX(Value)
  else if GiImageControl <> nil then GiImageControl.SetImageKindX(Value)
  else if AnimImageControl <> nil then AnimImageControl.SetImageKindX(Value)
  else if GaiImageControl <> nil then GaiImageControl.SetImageKindX(Value)
  else if GraphBufControl <> nil then GraphBufControl.SetImageKindX(Value);
end;
{ @end $48A380 }

{ @routine $48A470 TImageGI_SetImageKindY }
procedure TImageGI.SetImageKindY(Value: TImageKindYGI);
begin
  if SimpleImageControl <> nil then SimpleImageControl.SetImageKindY(Value)
  else if TransImageControl <> nil then TransImageControl.SetImageKindY(Value)
  else if AlphaImageControl <> nil then AlphaImageControl.SetImageKindY(Value)
  else if GiImageControl <> nil then GiImageControl.SetImageKindY(Value)
  else if AnimImageControl <> nil then AnimImageControl.SetImageKindY(Value)
  else if GaiImageControl <> nil then GaiImageControl.SetImageKindY(Value)
  else if GraphBufControl <> nil then GraphBufControl.SetImageKindY(Value);
end;
{ @end $48A470 }

{ @routine $48A560 TImageGI_SetHalfAlpha }
procedure TImageGI.SetHalfAlpha(Value: Boolean);
begin
  if SimpleImageControl <> nil then SimpleImageControl.SetHalfAlpha(Value)
  else if TransImageControl <> nil then TransImageControl.SetHalfAlpha(Value)
  else if AnimImageControl <> nil then AnimImageControl.SetHalfAlpha(Value);
end;
{ @end $48A560 }

{ @routine $48A5CC TImageGI_GetAlpha }
function TImageGI.GetAlpha: Byte;
begin
  if GiImageControl <> nil then Result := GiImageControl.Alpha
  else if GaiImageControl <> nil then Result := GaiImageControl.Alpha
  else Result := 255;
end;
{ @end $48A5CC }

{ @routine $48A620 TImageGI_SetAlpha }
procedure TImageGI.SetAlpha(Value: Byte);
begin
  if GiImageControl <> nil then GiImageControl.SetAlpha(Value)
  else if GaiImageControl <> nil then GaiImageControl.SetAlpha(Value);
end;
{ @end $48A620 }

{ @routine $48A66C TImageGI_SetSize }
procedure TImageGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if SimpleImageControl <> nil then SimpleImageControl.SetSize(Size)
  else if TransImageControl <> nil then TransImageControl.SetSize(Size)
  else if AlphaImageControl <> nil then AlphaImageControl.SetSize(Size)
  else if GiImageControl <> nil then GiImageControl.SetSize(Size)
  else if AnimImageControl <> nil then AnimImageControl.SetSize(Size)
  else if GaiImageControl <> nil then GaiImageControl.SetSize(Size)
  else if GraphBufControl <> nil then GraphBufControl.SetSize(Size);
end;
{ @end $48A66C }

{ @routine $48A76C TImageGI_SetOrigin }
procedure TImageGI.SetOrigin(Origin: TPoint);
var Position: TPoint;
begin
  inherited SetOrigin(Origin);
  Position.X := -Origin.X;
  Position.Y := -Origin.Y;
  if SimpleImageControl <> nil then SimpleImageControl.SetPosition(Position)
  else if TransImageControl <> nil then TransImageControl.SetPosition(Position)
  else if AlphaImageControl <> nil then AlphaImageControl.SetPosition(Position)
  else if GiImageControl <> nil then GiImageControl.SetPosition(Position)
  else if AnimImageControl <> nil then AnimImageControl.SetPosition(Position)
  else if GaiImageControl <> nil then GaiImageControl.SetPosition(Position)
  else if GraphBufControl <> nil then GraphBufControl.SetPosition(Position);
end;
{ @end $48A76C }

{ @routine $48A87C TImageGI_HitTestPixel }
function TImageGI.HitTestPixel(Point: TPoint): Boolean;
begin
  if AlphaImageControl <> nil then Result := AlphaImageControl.HitTestPixel(Point)
  else if AnimImageControl <> nil then Result := AnimImageControl.HitTest(Point)
  else if GiImageControl <> nil then Result := GiImageControl.HitTestPixel(Point)
  else if GaiImageControl <> nil then Result := GaiImageControl.HitTestPixel(Point)
  else Result := False;
end;
{ @end $48A87C }

{ @routine $48A924 TImageGI_GetVisualCenter }
function TImageGI.GetVisualCenter: TPoint;
begin
  if GiImageControl <> nil then Result := GiImageControl.GetVisualCenter
  else if GraphBufControl <> nil then Result := GraphBufControl.GetVisualCenter;
end;
{ @end $48A924 }

{ @routine $48A970 TImageGI_RestartPlayback }
procedure TImageGI.RestartPlayback;
begin
  if GaiImageControl <> nil then GaiImageControl.RestartPlayback;
end;
{ @end $48A970 }

{ @routine $48A994 TImageGI_StopPlayback }
procedure TImageGI.StopPlayback;
begin
  if GaiImageControl <> nil then GaiImageControl.StopAutoPlayback;
end;
{ @end $48A994 }

{ @routine $48A9B8 TImageGI_LoadFromConfigPath }
procedure TImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48A9B8 }

{ @routine $48A9EC TImageGI_LoadFromBlock }
procedure TImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $48A9EC }

{ @routine $48AA14 TImageGI_LoadImageProperties }
procedure TImageGI.LoadImageProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then SetImagePath(Block.GetParam('Image'));
  if Block.CountParams('KindX') > 0 then SetImageKindX(ParseImageKindXName(Block.GetParam('KindX')));
  if Block.CountParams('KindY') > 0 then SetImageKindY(ParseImageKindYName(Block.GetParam('KindY')));
  if Block.CountParams('HalfAlpha') > 0 then SetHalfAlpha(ParseEnabledNameGI(Block.GetParam('HalfAlpha')));
  if Block.CountParams('Auto') > 0 then AutoUpdateFlags := ParseAutoGeometryFlagsGI(Block.GetParam('Auto'));
end;
{ @end $48AA14 }

{ @routine $48ABAC TImageGI_UpdateAutoGeometry }
procedure TImageGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
  if (AutoUpdateFlags and agfPosition) = agfPosition then SetPosition(Parent.ToLocalPoint(GetContentOrigin));
  if (AutoUpdateFlags and agfSize) = agfSize then SetSize(GetContentSize);
end;
{ @end $48ABAC }

{ @routine $48AC28 TImageGI_QueueImageLoad }
procedure TImageGI.QueueImageLoad(PendingLoads: TList);
begin
  if SimpleImageControl <> nil then SimpleImageControl.QueueImageLoad(PendingLoads)
  else if TransImageControl <> nil then TransImageControl.QueueImageLoad(PendingLoads)
  else if AlphaImageControl <> nil then AlphaImageControl.QueueImageLoad(PendingLoads)
  else if AnimImageControl <> nil then AnimImageControl.QueueImageLoad(PendingLoads)
  else if GaiImageControl <> nil then GaiImageControl.QueueImageLoad(PendingLoads);
end;
{ @end $48AC28 }

{ @routine $48ACD4 TImageGI_SetHardwareMirrorHorizontal }
procedure TImageGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  if GaiImageControl <> nil then GaiImageControl.SetHardwareMirrorHorizontal(Value)
  else if GiImageControl <> nil then GiImageControl.SetHardwareMirrorHorizontal(Value);
end;
{ @end $48ACD4 }
end.
