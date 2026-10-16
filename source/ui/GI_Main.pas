unit GI_Main;

// Configuration helper placement in GI_Main is inferred; no explicit unit RTTI was recovered here.

interface

uses GI_MessageLoop, SysUtils, Types, EC_Struct;

const
  // ParseAutoGeometryFlagsGI maps the native configuration names pos / size.
  auto_position = $01;
  auto_size = $02;

type
  TImageKindXGI = (
    image_x_tile_left = 0,
    image_x_tile_center = 1, // Configurable, but not implemented by the native renderers.
    image_x_tile_right = 2,
    image_x_left = 3,
    image_x_center = 4,
    image_x_right = 5
  ); // @size 0x01
  TImageKindYGI = (
    image_y_tile_top = 0,
    image_y_tile_center = 1, // Configurable, but not implemented by the native renderers.
    image_y_tile_bottom = 2,
    image_y_top = 3,
    image_y_center = 4,
    image_y_bottom = 5
  ); // @size 0x01
  TTextAlignXGI = (text_x_left=0, text_x_center=1, text_x_right=2, text_x_fit_or_justify=3); // @size 0x01
  TTextAlignYGI = (text_y_top=0, text_y_center=1, text_y_font_center=2, text_y_bottom=3, text_y_fit_height=4); // @size 0x01

procedure BreakUiMessage; // @addr $4BE3AC @note "Sets the shared exception-log-copy suppression flag and raises EBreakMessageGI."

function CreateControlByName(Name: WideString; Owner: TObjectGI): TObjectGI; // @addr $4BCB40 @note "Exact type-name lookup; returns nil for unknown names."

function ParseImageKindXName(Name: WideString): TImageKindXGI; // @addr 0x004BD5F8 @note "Exact spelling required; unknown names raise."
function ParseImageKindYName(Name: WideString): TImageKindYGI; // @addr 0x004BD7A8 @note "Exact spelling required; unknown names raise."
function ParseTextAlignXName(Name: WideString): TTextAlignXGI; // @addr 0x004BD958
function ParseTextAlignYName(Name: WideString): TTextAlignYGI; // @addr 0x004BDAA4
function ParseEnabledNameGI(Name: WideString): Boolean; // @addr 0x004BDC1C @note "True only for Yes, yes, True, true, TRUE or 1."
function GetColorGI(ColorText: WideString): Cardinal; // @addr 0x004BDD10 @note "At least three comma-separated components are required; only their low bytes are used."
function GetPointGI(PointText: WideString): TPoint; // @addr 0x004BDEA0

function ParseAutoGeometryFlagsGI(Values: WideString): Integer; // @addr $4BE2C8 @note "Comma-separated pos and size names, trimmed and case-insensitive; unknown names are ignored."

function GetFloatPointGI(PointText: WideString): TPointF; // @addr $4BDFE4
function GetRectGI(RectText: WideString): TRect; // @addr $4BE10C

implementation

uses BreakMessageGIException, GR_GraphBuf, GI_XviD, GI_PolyLine, GI_SpaceImg, GI_SpaceCircle, GI_StarFieldImg, EC_CachePalBitmap, EC_CacheRotateBuf, EC_CachePlanetTempl, EC_CacheLightPal, EC_CacheTBitmap, EC_CacheBitmap, GI_StarFieldM, GI_StarField, GI_GraphBuf, GI_ShrLight, GI_Frame, GI_Circle, GI_Line, GI_Grid, GI_RadioGroup, GI_CheckBox, GI_Planet, GI_PlanetButton, GI_StatusBar, GI_CountBar, GI_ScrollBar, GI_Edit, GI_Label, GI_Zone, GI_GraphButton, GI_TextButton, GI_SimpleButton, GI_Door, GI_MultiImage, GI_GAIFile, GI_GAI, GI_GI, GI_AImage, GI_InfiniteImage, GI_Image, GI_RotateImageGAI, GI_RotateImage5, GI_RotateImage2, GI_RotateImage, GI_SBPath, GI_AlphaImage, GI_TransImage, GI_SimpleImage, GI_Window, GI_PanelScrollBar, GI_Panel, GR_Main, EC_Str, Classes;

{ @routine $4BCB40 CreateControlByName }
function CreateControlByName(Name: WideString; Owner: TObjectGI): TObjectGI;
begin
  if Name = 'Panel' then Result := TPanelGI.Create(Owner)
  else if Name = 'PanelScrollBar' then Result := TPanelScrollBarGI.Create(Owner)
  else if Name = 'Window' then Result := TWindowGI.Create(Owner)
  else if Name = 'SimpleImage' then Result := TSimpleImageGI.Create(Owner)
  else if Name = 'TransImage' then Result := TTransImageGI.Create(Owner)
  else if Name = 'AlphaImage' then Result := TAlphaImageGI.Create(Owner)
  else if Name = 'RotateImage' then Result := TRotateImageGI.Create(Owner)
  else if Name = 'RotateImage2' then Result := TRotateImage2GI.Create(Owner)
  else if Name = 'RotateImage5' then Result := TRotateImage5GI.Create(Owner)
  else if Name = 'RotateImageGAI' then Result := TRotateImageGaiGI.Create(Owner)
  else if Name = 'Image' then Result := TImageGI.Create(Owner)
  else if Name = 'InfiniteImage' then Result := TInfiniteImageGI.Create(Owner)
  else if Name = 'AImage' then Result := TAImageGI.Create(Owner)
  else if Name = 'GI' then Result := TgiGI.Create(Owner)
  else if Name = 'GAI' then Result := TgaiGI.Create(Owner)
  else if Name = 'GAIFile' then Result := TGAIFileGI.Create(Owner)
  else if Name = 'MultiImage' then Result := TMultiImageGI.Create(Owner)
  else if Name = 'Door' then Result := TDoorGI.Create(Owner)
  else if Name = 'SimpleButton' then Result := TSimpleButtonGI.Create(Owner)
  else if Name = 'TextButton' then Result := TTextButtonGI.Create(Owner)
  else if Name = 'GraphButton' then Result := TGraphButtonGI.Create(Owner)
  else if Name = 'Zone' then Result := TZoneGI.Create(Owner)
  else if Name = 'Label' then Result := TLabelGI.Create(Owner)
  else if Name = 'Edit' then Result := TEditGI.Create(Owner)
  else if Name = 'ScrollBar' then Result := TScrollBarGI.Create(Owner)
  else if Name = 'CountBar' then Result := TCountBarGI.Create(Owner)
  else if Name = 'SBPath' then Result := TSBPathGI.Create(Owner)
  else if Name = 'StatusBar' then Result := TStatusBarGI.Create(Owner)
  else if Name = 'Planet' then Result := TPlanetGI.Create(Owner)
  else if Name = 'PlanetButton' then Result := TPlanetButtonGI.Create(Owner)
  else if Name = 'CheckBox' then Result := TCheckBoxGI.Create(Owner)
  else if Name = 'RadioGroup' then Result := TRadioGroupGI.Create(Owner)
  else if Name = 'Grid' then Result := TGridGI.Create(Owner)
  else if Name = 'Line' then Result := TLineGI.Create(Owner)
  else if Name = 'Circle' then Result := TCircleGI.Create(Owner)
  else if Name = 'Frame' then Result := TFrameGI.Create(Owner)
  else if Name = 'ShrLight' then Result := TShrLightGI.Create(Owner)
  else if Name = 'GraphBuf' then Result := TGraphBufGI.Create(Owner, False)
  else if Name = 'StarField' then Result := TStarFieldGI.Create(Owner)
  else if Name = 'StarFieldM' then Result := TStarFieldMGI.Create(Owner)
  else if Name = 'StarFieldImg' then Result := TStarFieldImgGI.Create(Owner)
  else if Name = 'SpaceCircle' then Result := TSpaceCircleGI.Create(Owner)
  else if Name = 'SpaceImg' then Result := TSpaceImgGI.Create(Owner)
  else if Name = 'PolyLine' then Result := TPolyLineGI.Create(Owner)
  else if Name = 'XviD' then Result := TxvidGI.Create(Owner)
  else Result := nil;
end;
{ @end $4BCB40 }

{ @routine $4BD5F8 ParseImageKindXName }
function ParseImageKindXName(Name: WideString): TImageKindXGI;
begin
  if Name = 'LeftFill' then Result := image_x_tile_left
  else if Name = 'CenterFill' then Result := image_x_tile_center
  else if Name = 'RightFill' then Result := image_x_tile_right
  else if Name = 'Left' then Result := image_x_left
  else if Name = 'Center' then Result := image_x_center
  else if Name = 'Right' then Result := image_x_right
  else raise Exception.Create('GetITDXbyNameGI. name=' + Name);
end;
{ @end $4BD5F8 }

{ @routine $4BD7A8 ParseImageKindYName }
function ParseImageKindYName(Name: WideString): TImageKindYGI;
begin
  if Name = 'TopFill' then Result := image_y_tile_top
  else if Name = 'CenterFill' then Result := image_y_tile_center
  else if Name = 'BottomFill' then Result := image_y_tile_bottom
  else if Name = 'Top' then Result := image_y_top
  else if Name = 'Center' then Result := image_y_center
  else if Name = 'Bottom' then Result := image_y_bottom
  else raise Exception.Create('GetITDYbyNameGI. name=' + Name);
end;
{ @end $4BD7A8 }

{ @routine $4BD958 ParseTextAlignXName }
function ParseTextAlignXName(Name: WideString): TTextAlignXGI;
begin
  if Name = 'Left' then Result := text_x_left
  else if Name = 'Center' then Result := text_x_center
  else if Name = 'Right' then Result := text_x_right
  else if Name = 'Auto' then Result := text_x_fit_or_justify
  else raise Exception.Create('GetTTAXbyNameGI. name=' + Name);
end;
{ @end $4BD958 }

{ @routine $4BDAA4 ParseTextAlignYName }
function ParseTextAlignYName(Name: WideString): TTextAlignYGI;
begin
  if Name = 'Top' then Result := text_y_top
  else if Name = 'Center' then Result := text_y_center
  else if Name = 'CenterEx' then Result := text_y_font_center
  else if Name = 'Bottom' then Result := text_y_bottom
  else if Name = 'Auto' then Result := text_y_fit_height
  else raise Exception.Create('GetTTAYbyNameGI. name=' + Name);
end;
{ @end $4BDAA4 }

{ @routine $4BDC1C ParseEnabledNameGI }
function ParseEnabledNameGI(Name: WideString): Boolean;
begin
  if (Name = 'Yes') or (Name = 'yes') or (Name = 'True') or
    (Name = 'true') or (Name = 'TRUE') or (Name = '1') then
    Result := True
  else Result := False;
end;
{ @end $4BDC1C }

{ @routine $4BDD10 GetColorGI }
function GetColorGI(ColorText: WideString): Cardinal;
begin
  if CountDelimitedPartsW(ColorText, ',') < 3 then
    raise Exception.Create('GetColorGI. color=' + ColorText);
  Result := CurrentPixelFormat.PackRgbBytes(
    StrToInt(ExtractDelimitedPartW(ColorText, 0, ',')),
    StrToInt(ExtractDelimitedPartW(ColorText, 1, ',')),
    StrToInt(ExtractDelimitedPartW(ColorText, 2, ',')));
end;
{ @end $4BDD10 }

{ @routine $4BDEA0 GetPointGI }
function GetPointGI(PointText: WideString): TPoint;
begin
  if CountDelimitedPartsW(PointText, ',') < 2 then
    raise Exception.Create('GetPointGI. tstr=' + PointText);
  Result := Classes.Point(StrToInt(ExtractDelimitedPartW(PointText, 0, ',')),
    StrToInt(ExtractDelimitedPartW(PointText, 1, ',')));
end;
{ @end $4BDEA0 }

{ @routine $4BDFE4 GetFloatPointGI }
function GetFloatPointGI(PointText: WideString): TPointF;
begin
  if CountDelimitedPartsW(PointText, ',') < 2 then
    raise Exception.Create('GetFloatPointGI. tstr=' + PointText);
  Result := MakePointF(ExtractDecimalToSingleW(ExtractDelimitedPartW(PointText, 0, ',')),
    ExtractDecimalToSingleW(ExtractDelimitedPartW(PointText, 1, ',')));
end;
{ @end $4BDFE4 }

{ @routine $4BE10C GetRectGI }
function GetRectGI(RectText: WideString): TRect;
begin
  if CountDelimitedPartsW(RectText, ',') < 4 then
    raise Exception.Create('GetRectGI. tstr=' + RectText);
  Result.Left := StrToInt(ExtractDelimitedPartW(RectText, 0, ','));
  Result.Top := StrToInt(ExtractDelimitedPartW(RectText, 1, ','));
  Result.Right := StrToInt(ExtractDelimitedPartW(RectText, 2, ','));
  Result.Bottom := StrToInt(ExtractDelimitedPartW(RectText, 3, ','));
end;
{ @end $4BE10C }

{ @routine $4BE2C8 ParseAutoGeometryFlagsGI }
function ParseAutoGeometryFlagsGI(Values: WideString): Integer;
var Index, Count, Flags: Integer; Part: WideString;
begin
  Flags := 0;
  Count := CountDelimitedPartsW(Values, ',');
  for Index := 0 to Count - 1 do
  begin
    Part := LowerCaseWideString(TrimWideString(ExtractDelimitedPartW(Values, Index, ',')));
    if Part = 'pos' then Flags := Flags or auto_position
    else if Part = 'size' then Flags := Flags or auto_size;
  end;
  Result := Flags;
end;
{ @end $4BE2C8 }

{ @routine $4BE3AC BreakUiMessage }
procedure BreakUiMessage;
begin
  SuppressExceptionLogCopy := True;
  raise EBreakMessageGI.Create('No error');
end;
{ @end $4BE3AC }

end.
