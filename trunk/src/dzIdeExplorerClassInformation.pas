unit dzIdeExplorerClassInformation;

{$INCLUDE 'jedi.inc'}

interface

uses
  SysUtils,
{$IFDEF SUPPORTS_GENERICS}
  Generics.Defaults,
  Generics.Collections;
{$ELSE SUPPORTS_GENERICS}
  Classes,
  dzIdeExplorerBinarySearch;
{$ENDIF SUPPORTS_GENERICS}

type
  TClassInformation = class
  private
    FName: string;
    FClassPtr: TClass;
    FIsVisible: Boolean;
  public
    constructor Create(const _Name: string; _ClassPtr: TClass; _IsVisible: Boolean);
    property Name: string read FName write FName;
    property ClassPtr: TClass read FClassPtr write FClassPtr;
    property IsVisible: Boolean read FIsVisible write FIsVisible;
  end;

type
  TClassInfoList = class
  private
{$IFDEF SUPPORTS_GENERICS}
    FList: TList<TClassInformation>;
{$ELSE SUPPORTS_GENERICS}
    FList: TList;
    function CompareTo(_Key: Pointer; _Idx: Integer): Integer;
{$ENDIF SUPPORTS_GENERICS}
    function CompareNames(const _Item1, _Item2: TClassInformation): Integer;
    function GetItems(_Idx: Integer): TClassInformation;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(_Item: TClassInformation): Integer;
    function Find(const _Name: string; out _Item: TClassInformation): Boolean;
    function Count: Integer;
    property Items[_Idx: Integer]: TClassInformation read GetItems; default;
  end;

implementation

{ TClassInformation }

constructor TClassInformation.Create(const _Name: string; _ClassPtr: TClass; _IsVisible: Boolean);
begin
  inherited Create;
  FName := _Name;
  FClassPtr := _ClassPtr;
  FIsVisible := _IsVisible;
end;

{ TClassInfoList }

constructor TClassInfoList.Create;
begin
  inherited Create;
{$IFDEF SUPPORTS_GENERICS}
  FList := TList<TClassInformation > .Create;
{$ELSE SUPPORTS_GENERICS}
  FList := TList.Create;
{$ENDIF SUPPORTS_GENERICS}
end;

destructor TClassInfoList.Destroy;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    Items[i].Free;
  FList.Free;
  inherited;
end;

{$IFNDEF SUPPORTS_GENERICS}

function TClassInfoList.CompareTo(_Key: Pointer; _Idx: Integer): Integer;
begin
  Result := CompareNames(TClassInformation(_Key), TClassInformation(FList[_Idx]));
end;
{$ENDIF ~SUPPORTS_GENERICS}

function TClassInfoList.Find(const _Name: string; out _Item: TClassInformation): Boolean;
var
  idx: Integer;
  TempItem: TClassInformation;
begin
  TempItem := TClassInformation.Create(_Name, nil, False);
  try
{$IFDEF SUPPORTS_GENERICS}
    Result := FList.BinarySearch(TempItem, idx, TComparer<TClassInformation > .Construct(CompareNames));
{$ELSE SUPPORTS_GENERICS}
    Result := BinarySearch(0, FList.Count - 1, idx, TempItem, CompareTo);
{$ENDIF SUPPORTS_GENERICS}
    if Result then
      _Item := Items[idx];
  finally
    FreeAndNil(TempItem);
  end;
end;

function TClassInfoList.GetItems(_Idx: Integer): TClassInformation;
begin
{$IFDEF SUPPORTS_GENERICS}
  Result := FList[_Idx];
{$ELSE SUPPORTS_GENERICS}
  Result := TObject(FList[_Idx]) as TClassInformation;
{$ENDIF SUPPORTS_GENERICS}
end;

function TClassInfoList.CompareNames(const _Item1, _Item2: TClassInformation): Integer;
begin
  Result := CompareText(_Item1.Name, _Item2.Name);
end;

function TClassInfoList.Count: Integer;
begin
  Result := FList.Count;
end;

function TClassInfoList.Add(_Item: TClassInformation): Integer;
var
  idx: Integer;
  Found: Boolean;
begin
{$IFDEF SUPPORTS_GENERICS}
  Found := FList.BinarySearch(_Item, idx, TComparer<TClassInformation > .Construct(CompareNames));
    // we don't raise an exception for duplicates but just ignore them, this might create a memory leak
{$ELSE SUPPORTS_GENERICS}
  Found := BinarySearch(0, FList.Count - 1, idx, _Item, CompareTo);
{$ENDIF SUPPORTS_GENERICS}
  if Found then begin
    Result := -1;
  end else begin
    Result := idx;
    FList.Insert(idx, _Item);
  end;
end;

end.
