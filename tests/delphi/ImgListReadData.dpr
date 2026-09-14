program ImgListReadData;
uses Classes, ImgList;
type TImageListAccess = class(TCustomImageList);
procedure Probe(Image: TCustomImageList; Stream: TStream);
begin TImageListAccess(Image).ReadData(Stream); end;
exports Probe;
begin end.
