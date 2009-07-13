unit tomContext;

interface
uses
  SysUtils,
  Classes,
  Generics.Defaults,
  Generics.Collections,
  Generics.InterfaceList,
  tomClasses,
  tomIntf,
  TypInfo;

type

  TBaseSource = class(TObject)
  public
    function Load(Params : Array Of String;Values : Array of Variant;aEntityList :TInterfaceList<ITOMEntity> ) : ITOMEntity;
    procedure Save(aEntityRoot : ITOMEntity;aEntityList :TInterfaceList<ITOMEntity>);
  end;

  TBaseContext = class(TInterfacedObject,ItomContext)
  protected
    FEntityList : TInterfaceList<ITOMEntity>;
    FSources : TObjectList<TBaseSource>; // Needed ?
  public
    constructor Create;
    destructor Destroy; override;
    function Load(aSource : TBaseSource;Params : Array Of String;Values : Array of Variant) : ITOMEntity;
    procedure Save(aSource : TBaseSource;aEntityRoot : ITOMEntity);
    procedure SaveAllChanges;
  end;


  TBaseComponentContext = class(TComponent) // Will be in a different unit in the end, when Prism Support is added
  private
    FContext: ITOMContext;
  public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     property Context : ITOMContext read FContext write FContext;
  end;


implementation

{ TComponentContext }

constructor TBaseComponentContext.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TBaseComponentContext.Destroy;
begin
  FContext := nil;
  inherited;
end;

{ TBaseContext }

constructor TBaseContext.Create;
begin
  FEntityList := TInterfaceList<ITOMEntity>.Create;
end;

destructor TBaseContext.Destroy;
begin
  FEntityList := nil;
  inherited;
end;

function TBaseContext.Load(aSource: TBaseSource; Params: array of String;
  Values: array of Variant): ITOMEntity;
begin
  result :=  aSource.Load(Params,Values,FEntityList);
end;

procedure TBaseContext.Save(aSource: TBaseSource; aEntityRoot: ITOMEntity);
begin
  aSource.Save(aEntityRoot,FEntityList);
end;

procedure TBaseContext.SaveAllChanges;
begin
  //TODO: Build a tree of IEntity objects to determine root entities, so they are saved first.
  //However needs to be aware of recursive entities.

end;


{ TBaseSource }

{ TBaseSource }

function TBaseSource.Load(Params: array of String; Values: array of Variant;
  aEntityList: TInterfaceList<ITOMEntity>): ITOMEntity;
begin

end;

procedure TBaseSource.Save(aEntityRoot: ITOMEntity;
  aEntityList: TInterfaceList<ITOMEntity>);
begin

end;

end.
