unit tomIntf;

interface
uses
  TypInfo,
  SysUtils,
  Classes,
  Generics.Collections,
  Generics.Defaults,
  Generics.InterfaceList;


type
  ITOMEntity = interface; //forward
  ITOMAttributes = interface; // forward


  ITOMSource = interface
    ['{4EA06104-FEC6-4089-915E-3B0742F89A2B}']
  end;


  TOMPropertyState = (psUnSet,psLoading,psLoaded);

  ITOMPropertyBase = interface
    ['{D756262A-74C8-4417-96C1-270B2FE71C3F}']
    function GetChanged: Boolean;
    procedure SetState(const Value: TOMPropertyState);
    procedure SetEntity(const Entity : ITOMEntity);
    function GetEntity: ITOMEntity;
    function GetState: TOMPropertyState;
    function GetPropType : PTypeInfo;
    function GetPropName : String;
    function GetAttributes : ITOMAttributes;


    property Changed : Boolean read GetChanged;
    property State : TOMPropertyState read GetState write SetState;
    property Entity : ITOMEntity read GetEntity write SetEntity;
    property PropType : PTypeInfo read GetPropType;
    property PropName : String read GetPropName;
    property Attributes : ITOMAttributes read GetAttributes;
  end;

  ITOMProperty<T> = interface(ITOMPropertyBase)
    ['{E592D7C0-3176-4637-9E18-A9EA1AFB89E3}']
    procedure SetOriginalValue(const Value: T);
    procedure SetValue(const Value: T);
    procedure SetComparer(const Value : IComparer<T>);
    function GetComparer: IComparer<T>;
    function GetOriginalValue: T;
    function GetValue: T;

    property Value : T read GetValue write SetValue;
    property OriginalValue :  T read GetOriginalValue write SetOriginalValue;
    property Comparer: IComparer<T> read GetComparer write SetComparer;
  end;
  /// <summary>
  ///   TEntityState
  ///      esPrep - UnInitialized - Default State, No Properties can be
  ///               set during this state.
  ///      esLoading - Occurs when Loading data from source
  ///                  Any Property can be set during this time but no changes
  ///                  are recorded.
  ///      esInsert - Occurs when new instance of object has been created by
  ///                 not persisted, allow editing of data
  ///      esLoaded - Occurs after loading, allows editing of loaded data.
  ///      esStoring - Occurs during the streaming of data to source.
  ///                  when finished state will be esLoaded
  /// </summary>
  TEntityState = (esPrep, esLoading, esInsert, esLoaded, esStoring);
  ITOMEntity = interface
    ['{457CB7D7-1E8F-4C35-81CE-B99EC0E310D7}']
//   Thinking that we need to publish a State instead and make loading,saving and inserting
//    a functionality of ISource
//     procedure Insert;
//     procedure Save;
//     procedure Load;
     // I want to Reserve the load overload for TValue and I think it may be ambugious
     // So hence LoadEx instead of overload
//     procedure LoadEx(PropNames : Array of String;PropValues : Array of Variant);
//   Since every property get an entity it would be nice to dynamically get the values.
//   But you really can't refer to a generic Class this way.
//     function GetProperty(Name : String) : ITOMProperty<T>; overload;
//     function GetProperty(Index : Integer) : ITOMProperty<T>; overload;
//   Might have to wait until Weaver (and TValue Support) but don't know if that
//   will work since I have only seen it at DelphiLive.
//   In the mean time I think it can at least do this.
//     Then we might be able to use some RTTI hacks to get the value
     function EntityPropertyCount : Integer;
     function GetProperty(Name : String) : ITOMPropertyBase; overload;
     function GetProperty(Index : Integer) : ITOMPropertyBase; overload;
     function GetEntityState : TEntityState;
     procedure SetEntityState(const Value : TEntityState);
     property State : TEntityState read GetEntityState write SetEntityState;

// A thought for future version, need to to think about possibly supporting
// nested transactions before implementing it.
//     procedure StartTransaction;
//     procedure CommitTransaction;
//     procedure RollbackTransaction;
  end;
  ITOMAttributes = interface
    ['{2E189549-B3F6-45D3-B28B-5CF5BC015594}']
    procedure SetAssignedBySource(const Value: Boolean);
    procedure SetLazyLoad(const Value: Boolean);
    procedure SetRequired(const Value: Boolean);
    procedure SetSourceName(const Value: String);
    procedure SetValues(const Value: TDictionary<String,String>);
    function GetAssignedBySource: Boolean;
    function GetLazyLoad: Boolean;
    function GetRequired: Boolean;
    function GetSourceName: String;
    function GetValues: TDictionary<String,String>;
    property SourceName : String read GetSourceName write SetSourceName;
    property AssignedBySource : Boolean read GetAssignedBySource write SetAssignedBySource;
    property Required : Boolean read GetRequired write SetRequired;
    property LazyLoad : Boolean read GetLazyLoad write SetLazyLoad;
    property Values : TDictionary<String,String> read GetValues write SetValues;
  end;

  ITOMPropertyList = interface(IInterfaceList<ITOMPropertyBase>)
      function GetItemByName(Name : String) : ITOMPropertyBase;
  end;



implementation

end.
