unit GI_Image;

interface

uses EC_BlockPar, GI_GAI, GI_MessageLoop, GI_Main, GI_AImage, GI_AlphaImage, GI_GI, GI_TransImage, GI_SimpleImage, GI_GraphBuf, Classes, Types;

type
  TImageGI = class(TObjectGI) // @size 0x144 @methodorder source
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

    constructor Create(Owner: TObjectGI); // @addr 0x00498FAC
    destructor Destroy; override; // @addr 0x00498FE4
    procedure Clear; override; // @addr 0x0049900C
    procedure SetImagePath(Path: WideString); // @addr 0x00499014 @note "Empty paths remove the child; unknown modes raise."
    property ImageSourcePath: WideString write SetImagePath;
    function GetImagePath: WideString; // @addr 0x0049959C
    function GetContentSize: TPoint; // @addr 0x004995B4
    function GetContentOrigin: TPoint; // @addr 0x00499678 @note "Only GI children supply an origin; other kinds return (0,0)."
    procedure SetImageKindX(Value: TImageKindXGI); // @addr 0x004996A4
    property KindX: TImageKindXGI write SetImageKindX;
    procedure SetImageKindY(Value: TImageKindYGI); // @addr 0x00499728
    property KindY: TImageKindYGI write SetImageKindY;
    procedure SetHalfAlpha(Value: Boolean); // @addr 0x004997AC @note "Only affects Simple, Trans and Anim children."
    property HalfAlpha: Boolean write SetHalfAlpha;
    function GetAlpha: Byte; // @addr 0x004997E4 @note "Returns GI/GAI alpha, or 255 for other kinds."
    procedure SetAlpha(Value: Byte); // @addr 0x0049980C @note "Only affects GI/GAI children."
    procedure SetSize(Size: TPoint); override; // @addr 0x00499830
    procedure SetOrigin(Origin: TPoint); override; // @addr 0x004998E0
    function HitTestPixel(Point: TPoint): Boolean; // @addr 0x004999A4 @note "Returns false for kinds other than Alpha, Anim, GI and GAI."
    function GetVisualCenter: TPoint; // @addr 0x00499A0C @note "Only GI and GraphBuf write the result; other kinds leave it untouched."
    procedure RestartPlayback; // @addr 0x00499A40
    procedure StopPlayback; // @addr 0x00499A54
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00499A68
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00499A94
    procedure LoadImageProperties(Block: TBlockParEC); // @addr 0x00499AB0
    procedure UpdateAutoGeometry; override; // @addr 0x00499C34 @note "Auto-geometry bit 0 uses content origin; bit 1 uses content size."
    procedure SetHardwareMirrorHorizontal(Value: Boolean); // @addr $499CFC Delegates to the GAI or GI child.
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr 0x00499C9C @note "GI and GraphBuf children are skipped."
  end;

implementation

uses SysUtils, GlobalsV, EC_Str, GR_Main;


{ @routine $498FAC TImageGI_Create }
constructor TImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;
{ @end $498FAC }

{ @routine $498FE4 TImageGI_Destroy }
destructor TImageGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $498FE4 }

{ @routine $49900C TImageGI_Clear }
procedure TImageGI.Clear;
begin
  inherited Clear;
end;
{ @end $49900C }

{ @routine $499014 TImageGI_SetImagePath }
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
{ @end $499014 }

{ @routine $49959C TImageGI_GetImagePath }
function TImageGI.GetImagePath: WideString;
begin
  Result := ImagePath;
end;
{ @end $49959C }

{ @routine $4995B4 TImageGI_GetContentSize }
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
{ @end $4995B4 }

{ @routine $499678 TImageGI_GetContentOrigin }
function TImageGI.GetContentOrigin: TPoint;
begin
  if GiImageControl <> nil then Result := GiImageControl.GetContentOrigin
  else Result := Classes.Point(0, 0);
end;
{ @end $499678 }

{ @routine $4996A4 TImageGI_SetImageKindX }
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
{ @end $4996A4 }

{ @routine $499728 TImageGI_SetImageKindY }
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
{ @end $499728 }

{ @routine $4997AC TImageGI_SetHalfAlpha }
procedure TImageGI.SetHalfAlpha(Value: Boolean);
begin
  if SimpleImageControl <> nil then SimpleImageControl.SetHalfAlpha(Value)
  else if TransImageControl <> nil then TransImageControl.SetHalfAlpha(Value)
  else if AnimImageControl <> nil then AnimImageControl.SetHalfAlpha(Value);
end;
{ @end $4997AC }

{ @routine $4997E4 TImageGI_GetAlpha }
function TImageGI.GetAlpha: Byte;
begin
  if GiImageControl <> nil then Result := GiImageControl.Alpha
  else if GaiImageControl <> nil then Result := GaiImageControl.Alpha
  else Result := 255;
end;
{ @end $4997E4 }

{ @routine $49980C TImageGI_SetAlpha }
procedure TImageGI.SetAlpha(Value: Byte);
begin
  if GiImageControl <> nil then GiImageControl.SetAlpha(Value)
  else if GaiImageControl <> nil then GaiImageControl.SetAlpha(Value);
end;
{ @end $49980C }

{ @routine $499830 TImageGI_SetSize }
procedure TImageGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if SimpleImageControl <> nil then SimpleImageControl.ObjectSize := Size
  else if TransImageControl <> nil then TransImageControl.ObjectSize := Size
  else if AlphaImageControl <> nil then AlphaImageControl.ObjectSize := Size
  else if GiImageControl <> nil then GiImageControl.ObjectSize := Size
  else if AnimImageControl <> nil then AnimImageControl.ObjectSize := Size
  else if GaiImageControl <> nil then GaiImageControl.ObjectSize := Size
  else if GraphBufControl <> nil then GraphBufControl.SetSize(Size);
end;
{ @end $499830 }

{ @routine $4998E0 TImageGI_SetOrigin }
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
{ @end $4998E0 }

{ @routine $4999A4 TImageGI_HitTestPixel }
function TImageGI.HitTestPixel(Point: TPoint): Boolean;
begin
  if AlphaImageControl <> nil then Result := AlphaImageControl.HitTestPixel(Point)
  else if AnimImageControl <> nil then Result := AnimImageControl.HitTest(Point)
  else if GiImageControl <> nil then Result := GiImageControl.HitTestPixel(Point)
  else if GaiImageControl <> nil then Result := GaiImageControl.HitTestPixel(Point)
  else Result := False;
end;
{ @end $4999A4 }

{ @routine $499A0C TImageGI_GetVisualCenter }
function TImageGI.GetVisualCenter: TPoint;
begin
  if GiImageControl <> nil then Result := GiImageControl.GetVisualCenter
  else if GraphBufControl <> nil then Result := GraphBufControl.GetVisualCenter;
end;
{ @end $499A0C }

{ @routine $499A40 TImageGI_RestartPlayback }
procedure TImageGI.RestartPlayback;
begin
  if GaiImageControl <> nil then GaiImageControl.RestartPlayback;
end;
{ @end $499A40 }

{ @routine $499A54 TImageGI_StopPlayback }
procedure TImageGI.StopPlayback;
begin
  if GaiImageControl <> nil then GaiImageControl.StopAutoPlayback;
end;
{ @end $499A54 }

{ @routine $499A68 TImageGI_LoadFromConfigPath }
procedure TImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $499A68 }

{ @routine $499A94 TImageGI_LoadFromBlock }
procedure TImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $499A94 }

{ @routine $499AB0 TImageGI_LoadImageProperties }
procedure TImageGI.LoadImageProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Image') > 0 then ImageSourcePath := Block.GetParam('Image');
  if Block.CountParams('KindX') > 0 then KindX := ParseImageKindXName(Block.GetParam('KindX'));
  if Block.CountParams('KindY') > 0 then KindY := ParseImageKindYName(Block.GetParam('KindY'));
  if Block.CountParams('HalfAlpha') > 0 then HalfAlpha := ParseEnabledNameGI(Block.GetParam('HalfAlpha'));
  if Block.CountParams('Auto') > 0 then AutoUpdateFlags := ParseAutoGeometryFlagsGI(Block.GetParam('Auto'));
end;
{ @end $499AB0 }

{ @routine $499C34 TImageGI_UpdateAutoGeometry }
procedure TImageGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
  if (AutoUpdateFlags and auto_position) = auto_position then SetPosition(Parent.ToLocalPoint(GetContentOrigin));
  if (AutoUpdateFlags and auto_size) = auto_size then SetSize(GetContentSize);
end;
{ @end $499C34 }

{ @routine $499C9C TImageGI_QueueImageLoad }
procedure TImageGI.QueueImageLoad(PendingLoads: TList);
begin
  if SimpleImageControl <> nil then SimpleImageControl.QueueImageLoad(PendingLoads)
  else if TransImageControl <> nil then TransImageControl.QueueImageLoad(PendingLoads)
  else if AlphaImageControl <> nil then AlphaImageControl.QueueImageLoad(PendingLoads)
  else if AnimImageControl <> nil then AnimImageControl.QueueImageLoad(PendingLoads)
  else if GaiImageControl <> nil then GaiImageControl.QueueImageLoad(PendingLoads);
end;
{ @end $499C9C }

{ @routine $499CFC TImageGI_SetHardwareMirrorHorizontal }
procedure TImageGI.SetHardwareMirrorHorizontal(Value: Boolean);
begin
  if GaiImageControl <> nil then GaiImageControl.SetHardwareMirrorHorizontal(Value)
  else if GiImageControl <> nil then GiImageControl.SetHardwareMirrorHorizontal(Value);
end;
{ @end $499CFC }
end.
