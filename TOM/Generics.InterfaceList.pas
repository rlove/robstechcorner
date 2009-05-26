unit Generics.InterfaceList;

interface
uses SysUtils, Classes, Generics.Defaults, Generics.Collections, SyncObjs;

type

  TThreadList<T> = class
  private
    FList: TList<T>;
    FLock: TCriticalSection;
  public
    constructor Create; overload;
    constructor Create(aComparer : IComparer<T>); overload;
    destructor Destroy; override;
    procedure Add(Item: T);
    procedure Clear;
    function  LockList: TList<T>;
    procedure Remove(Item: T);
    procedure UnlockList;
  end;

  TInterfaceListEnumerator<T:  IInterface> = class;
  TInterfaceList<T : IInterface> = class;

  IInterfaceList<T : IInterface> = interface
     ['{285DEA8A-B865-11D1-AAA7-00C04FB17A72}']
    function Get(Index: Integer): T;
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; const Item: T);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);

    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function First: IInterface;
    function IndexOf(const Item: T): Integer;
    function Add(const Item: T): Integer;
    procedure Insert(Index: Integer; const Item: T);
    function Last: IInterface;
    function Remove(const Item: T): Integer;
    procedure Lock;
    procedure Unlock;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: T read Get write Put; default;
    function GetEnumerator: TInterfaceListEnumerator<T>;
  end;

  TInterfaceListEnumerator<T : IInterface> = class
  private
    FIndex: Integer;
    FInterfaceList: TInterfaceList<T>;
  public
    constructor Create(AInterfaceList: TInterfaceList<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    property Current: T read GetCurrent;
  end;

  TInterfaceList<T : IInterface> = class(TInterfacedObject, IInterfaceList<T>)
  private
    FList: TThreadList<T>;
  protected
    { IInterfaceList }
    function Get(Index: Integer): T;
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; const Item: T);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    constructor Create; overload;
    constructor Create(aComparer : IComparer<T>); overload;

    destructor Destroy; override;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function First: IInterface;
    function IndexOf(const Item: T): Integer;
    function Add(const Item: T): Integer;
    procedure Insert(Index: Integer; const Item: T);
    function Last: IInterface;
    function Remove(const Item: T): Integer;
    procedure Lock;
    procedure Unlock;
    function GetEnumerator: TInterfaceListEnumerator<T>;

    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: T read Get write Put; default;
  end;

implementation

uses
  RTLConsts;

{ TInterfaceListEnumerator<T> }

constructor TInterfaceListEnumerator<T>.Create(
  AInterfaceList: TInterfaceList<T>);
begin
  inherited Create;
  FIndex := -1;
  FInterfaceList := AInterfaceList;
end;

function TInterfaceListEnumerator<T>.GetCurrent: T;
begin
  Result := FInterfaceList[FIndex];
end;

function TInterfaceListEnumerator<T>.MoveNext: Boolean;
begin
  Result := FIndex < FInterfaceList.Count - 1;
  if Result then
     Inc(FIndex);
end;

{ TInterfaceList<T> }

{ TInterfaceList }

constructor TInterfaceList<T>.Create;
begin
  inherited Create;
  FList := TThreadList<T>.Create;
end;

constructor TInterfaceList<T>.Create(aComparer: IComparer<T>);
begin
  inherited Create;
  FList := TThreadList<T>.Create(aComparer);
end;


destructor TInterfaceList<T>.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TInterfaceList<T>.Clear;
var
  I: Integer;
  lList : TList<T>;
begin
  if FList <> nil then
  begin
    lList := FList.LockList;
    try
      for I := 0 to Count - 1 do
      begin
         lList.Items[I] := default(t); //i.e. Nil
      end;
      lList.Clear;
    finally
      FList.UnlockList;
    end;
  end;
end;


procedure TInterfaceList<T>.Delete(Index: Integer);
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Self.Put(Index, Default(T));
    lList.Delete(Index);
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.First: IInterface;
begin
  Result := Get(0);
end;

function TInterfaceList<T>.Get(Index: Integer): T;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    if (Index < 0) or (Index >= lList.Count) then
       raise EListError.CreateFmt(SListIndexError, [Index]);
    Result := lList[Index];
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.GetCapacity: Integer;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Result := lList.Capacity;
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.GetCount: Integer;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Result := lList.Count;
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.GetEnumerator: TInterfaceListEnumerator<T>;
begin
  Result := TInterfaceListEnumerator<T>.Create(Self);
end;

function TInterfaceList<T>.IndexOf(const Item: T): Integer;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
     Result := lList.IndexOf(Item);
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.Add(const Item: T): Integer;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Result := lList.Add(Item);
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.Insert(Index: Integer; const Item: T);
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    lList.Insert(Index, Item);
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.Last: IInterface;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Result := Self.Get(lList.Count - 1);
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.Put(Index: Integer; const Item: T);
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    if (Index < 0) or (Index >= lList.Count) then
      raise EListError.CreateFmt(SListIndexError, [Index]);
    lList[Index] := Item;
  finally
    Self.FList.UnlockList;
  end;
end;

function TInterfaceList<T>.Remove(const Item: T): Integer;
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    Result := lList.IndexOf(Item);
    if Result > -1 then
    begin
      lList[Result] := Default(T);
      lList.Delete(Result);
    end;
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.SetCapacity(NewCapacity: Integer);
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    lList.Capacity := NewCapacity;
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.SetCount(NewCount: Integer);
var
 lList : TList<T>;
begin
  lList := FList.LockList;
  try
    lList.Count := NewCount;
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.Exchange(Index1, Index2: Integer);
var
 lList : TList<T>;
 Item1 : T;
 Item2 : T;
begin
  lList := FList.LockList;
  try
    Item1 := lList[Index1];
    Item2 := lList[Index2];
    lList[Index1] := Item2;
    lList[Index2] := Item1;
  finally
    Self.FList.UnlockList;
  end;
end;

procedure TInterfaceList<T>.Lock;
begin
  FList.LockList;
end;

procedure TInterfaceList<T>.Unlock;
begin
  FList.UnlockList;
end;

{ TThreadList<T> }

procedure TThreadList<T>.Add(Item: T);
begin
  LockList;
  try
    FList.Add(Item)
  finally
    UnlockList;
  end;
end;

procedure TThreadList<T>.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
    UnlockList;
  end;
end;

constructor TThreadList<T>.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FList := TList<T>.Create;
end;

constructor TThreadList<T>.Create(aComparer: IComparer<T>);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FList := TList<T>.Create(aComparer);
end;

destructor TThreadList<T>.Destroy;
begin
  LockList;
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    FreeAndNil(FLock);
  end;
end;

function TThreadList<T>.LockList: TList<T>;
begin
  FLock.Enter;
  Result := FList;
end;

procedure TThreadList<T>.Remove(Item: T);
begin
  LockList;
  try
    FList.Remove(Item);
  finally
    UnlockList;
  end;
end;


procedure TThreadList<T>.UnlockList;
begin
  FLock.Leave;
end;

end.
