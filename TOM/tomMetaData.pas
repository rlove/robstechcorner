unit tomMetaData;

interface
uses
  SysUtils,
  Classes,
  DB,
  SqlExpr,
  dbxCommon,
  Generics.Defaults,
  Generics.Collections,
  DBXMetaDataProvider,
  DBXTypedTableStorage,
  DBXDataExpressMetaDataProvider,
  dbxCommonTable;
type
  TOMTableMetaData = class;

  TOMTableListMetaData = class(TObject)
  private
    FProvider: TDBXDataExpressMetaDataProvider;
    FTables: TObjectList<TOMTableMetaData>;
    FSchemaName: String;
    procedure SetProvider(const Value: TDBXDataExpressMetaDataProvider);
    procedure SetTables(const Value: TObjectList<TOMTableMetaData>);
    procedure PopulateTables;
    procedure PopulateDependantTables;
    procedure SetSchemaName(const Value: String);
  public
    constructor Create(dbxConn : TDBXConnection;aSchemaName : String);
    destructor Destroy; override;
    property Provider : TDBXDataExpressMetaDataProvider read FProvider write SetProvider;
    property Tables : TObjectList<TOMTableMetaData> read FTables write SetTables;
    property SchemaName : String read FSchemaName write SetSchemaName;
  end;

  TOMForeignKeyColumnMetaData = class(TObject)
  private
    FPrimaryColumnName: UnicodeString;
    FColumnName: UnicodeString;
    procedure SetColumnName(const Value: UnicodeString);
    procedure SetPrimaryColumnName(const Value: UnicodeString);
  public
    property ColumnName: UnicodeString read FColumnName write SetColumnName;
    property PrimaryColumnName: UnicodeString read FPrimaryColumnName write SetPrimaryColumnName;
  end;

  TOMForeignKeyTableMetaData = class(TObject)
  private
    FSchemaName: UnicodeString;
    FTableName: UnicodeString;
    FForeignKeyName: UnicodeString;
    FCatalogName: UnicodeString;
    FColumns: TObjectList<TOMForeignKeyColumnMetaData>;
    procedure SetCatalogName(const Value: UnicodeString);
    procedure SetForeignKeyName(const Value: UnicodeString);
    procedure SetSchemaName(const Value: UnicodeString);
    procedure SetTableName(const Value: UnicodeString);
    procedure SetColumns(const Value: TObjectList<TOMForeignKeyColumnMetaData>);
  public
    constructor Create;
    destructor Destroy; override;
    property CatalogName: UnicodeString read FCatalogName write SetCatalogName;
    property SchemaName: UnicodeString read FSchemaName write SetSchemaName;
    property TableName: UnicodeString read FTableName write SetTableName;
    property ForeignKeyName: UnicodeString read FForeignKeyName write SetForeignKeyName;
    property Columns : TObjectList<TOMForeignKeyColumnMetaData> read FColumns write SetColumns;
  end;

  TOMTableMetaData = class(TObject)
  private
    FColumns: TDBXColumnsTableStorage;
    FForeignKeys: TDBXForeignKeyColumnsTableStorage;
    FProvider: TDBXDataExpressMetaDataProvider;
    FSchemaName: UnicodeString;
    FTableName: UnicodeString;
    FCatalogName: UnicodeString;
    FTableType: UnicodeString;
    FDependantTables: TObjectList<TOMForeignKeyTableMetaData>;
    procedure SetColumns(const Value: TDBXColumnsTableStorage);
    procedure SetForeignKeys(const Value: TDBXForeignKeyColumnsTableStorage);
    procedure GetDetails;
    procedure SetProvider(const Value: TDBXDataExpressMetaDataProvider);
    procedure SetCatalogName(const Value: UnicodeString);
    procedure SetSchemaName(const Value: UnicodeString);
    procedure SetTableName(const Value: UnicodeString);
    procedure SetTableType(const Value: UnicodeString);
    procedure SetDependantTables(
      const Value: TObjectList<TOMForeignKeyTableMetaData>);
  public
    constructor Create(aProvider : TDBXDataExpressMetaDataProvider;
                      aCatalogName,aSchemaName,aTableName,aTableType : UnicodeString);
    destructor Destroy; override;
    procedure PopulateDependantTables(aList : TObjectList<TOMTableMetaData>);
    function DependantTable(aCatalog,aSchema,aTableName : String) : TOMForeignKeyTableMetaData;
    property Provider : TDBXDataExpressMetaDataProvider read FProvider write SetProvider;
    property Columns : TDBXColumnsTableStorage read FColumns write SetColumns;
    property ForeignKeys : TDBXForeignKeyColumnsTableStorage read FForeignKeys write SetForeignKeys;
    property DependantTables : TObjectList<TOMForeignKeyTableMetaData> read FDependantTables write SetDependantTables;

    property CatalogName: UnicodeString read FCatalogName write SetCatalogName;
    property SchemaName: UnicodeString read FSchemaName write SetSchemaName;
    property TableName: UnicodeString read FTableName write SetTableName;
    property TableType: UnicodeString read FTableType write SetTableType;

  End;


implementation

{ TOMTableMetaData }


constructor TOMTableMetaData.Create(aProvider: TDBXDataExpressMetaDataProvider;
  aCatalogName, aSchemaName, aTableName, aTableType: UnicodeString);
begin
  FProvider := aProvider;
  FCatalogName := aCatalogName;
  FSchemaName := aSchemaName;
  FTableName := aTableName;
  FTableType := aTableType;
  FDependantTables := TObjectList<TOMForeignKeyTableMetaData>.Create;
  FDependantTables.OwnsObjects := true;
  GetDetails;
end;

function TOMTableMetaData.DependantTable(aCatalog, aSchema,
  aTableName: String): TOMForeignKeyTableMetaData;
var
  Table : TOMForeignKeyTableMetaData;
begin
  result := nil;
  for Table in FDependantTables do
  begin
       if (Table.CatalogName = Self.CatalogName) and
          (Table.SchemaName = Self.SchemaName) and
          (Table.TableName = Self.TableName) then
       begin
         result := Table;
         break;
       end;
  end;
end;

destructor TOMTableMetaData.Destroy;
begin
  FreeAndNil(FColumns);
  FreeAndNil(FForeignKeys);
  FreeAndNil(FDependantTables);
  inherited;
end;


procedure TOMTableMetaData.GetDetails;
var
 Coll: TDBXTable;
begin
   Coll := Provider.GetCollection(TDBXMetaDataCommands.GetColumns + ' ' + FTableName);
   Assert(Assigned(Coll));
   FColumns := Coll as TDBXColumnsTableStorage;

   Coll := Provider.GetCollection(TDBXMetaDataCommands.GetForeignKeyColumns + ' ' + TableName);
   Assert(Assigned(Coll));
   FForeignKeys := Coll as TDBXForeignKeyColumnsTableStorage;
end;



procedure TOMTableMetaData.PopulateDependantTables(
  aList: TObjectList<TOMTableMetaData>);
var
 Table : TOMTableMetaData;
 DTable : TOMForeignKeyTableMetaData;
 FKCol : TOMForeignKeyColumnMetaData;
begin
 for Table in aList do
 begin
   if Table <> self then
   begin
     Table.ForeignKeys.First;
     while Table.ForeignKeys.InBounds do
     begin
       if (Table.ForeignKeys.PrimaryCatalogName = Self.CatalogName) and
          (Table.ForeignKeys.PrimarySchemaName = Self.SchemaName) and
          (Table.ForeignKeys.PrimaryTableName = Self.TableName) then
       begin
          DTable := DependantTable(Table.ForeignKeys.PrimaryCatalogName,
                                   Table.ForeignKeys.PrimarySchemaName,
                                   Table.ForeignKeys.PrimaryTableName);
          if Not Assigned(DTable) then
          begin
            DTable := TOMForeignKeyTableMetaData.Create;
            DTable.CatalogName := Table.ForeignKeys.PrimaryCatalogName;
            DTable.SchemaName :=  Table.ForeignKeys.PrimarySchemaName;
            DTable.TableName := Table.ForeignKeys.PrimaryTableName;
            FDependantTables.Add(DTable);
          end;
          FKCol := TOMForeignKeyColumnMetaData.Create;
          FkCol.PrimaryColumnName := Table.ForeignKeys.PrimaryColumnName;
          FkCol.ColumnName := Table.ForeignKeys.ColumnName;
          DTable.Columns.Add(FKCol);

       end;
       Table.ForeignKeys.Next;
     end;

   end;
 end;

end;

procedure TOMTableMetaData.SetCatalogName(const Value: UnicodeString);
begin
  FCatalogName := Value;
end;

procedure TOMTableMetaData.SetColumns(const Value: TDBXColumnsTableStorage);
begin
  FColumns := Value;
end;

procedure TOMTableMetaData.SetDependantTables(
  const Value: TObjectList<TOMForeignKeyTableMetaData>);
begin
  FDependantTables := Value;
end;

procedure TOMTableMetaData.SetForeignKeys(
  const Value: TDBXForeignKeyColumnsTableStorage);
begin
  FForeignKeys := Value;
end;

procedure TOMTableMetaData.SetProvider(
  const Value: TDBXDataExpressMetaDataProvider);
begin
  FProvider := Value;
end;



procedure TOMTableMetaData.SetSchemaName(const Value: UnicodeString);
begin
  FSchemaName := Value;
end;

procedure TOMTableMetaData.SetTableName(const Value: UnicodeString);
begin
  FTableName := Value;
end;

procedure TOMTableMetaData.SetTableType(const Value: UnicodeString);
begin
  FTableType := Value;
end;

{ TOMTableListMetaData }

constructor TOMTableListMetaData.Create(dbxConn: TDBXConnection;aSchemaName : String );
begin
  FProvider := TDBXDataExpressMetaDataProvider.Create;
  FProvider.Connection := dbxConn;
  FProvider.Open;
  FTables := TObjectList<TOMTableMetaData>.Create;
  FTables.OwnsObjects := true;
  FSchemaName := aSchemaName;
  PopulateTables;
  PopulateDependantTables;
end;

destructor TOMTableListMetaData.Destroy;
begin
  FreeAndNil(FProvider);
  FreeAndNil(FTables);
  inherited;
end;

procedure TOMTableListMetaData.PopulateDependantTables;
var
 table : TOMTableMetaData;
begin
 for Table in FTables do
   Table.PopulateDependantTables(FTables);
end;

procedure TOMTableListMetaData.PopulateTables;
var
 Coll: TDBXTable;
 Tables : TDBXTablesTableStorage;
 Table : TOMTableMetaData;
begin
   Coll := Provider.GetCollection(TDBXMetaDataCommands.GetTables );
   Assert(Assigned(Coll));
   Tables := Coll as TDBXTablesTableStorage;
    try
      while Tables.InBounds do
      begin
        if Tables.SchemaName = FSchemaName then
        begin
          Table := TOMTableMetaData.Create(FProvider,Tables.CatalogName,Tables.SchemaName,Tables.TableName,Tables.TableType);
          FTables.Add(Table);
        end;
        Tables.Next;
      end;
    finally
      FreeAndNil(Tables);
    end;
end;

procedure TOMTableListMetaData.SetProvider(
  const Value: TDBXDataExpressMetaDataProvider);
begin
  FProvider := Value;
end;

procedure TOMTableListMetaData.SetSchemaName(const Value: String);
begin
  FSchemaName := Value;
end;

procedure TOMTableListMetaData.SetTables(
  const Value: TObjectList<TOMTableMetaData>);
begin
  FTables := Value;
end;

{ TOMForeignKeyTableMetaData }

constructor TOMForeignKeyTableMetaData.Create;
begin
 FColumns := TObjectList<TOMForeignKeyColumnMetaData>.Create;
 FColumns.OwnsObjects := true;
end;

destructor TOMForeignKeyTableMetaData.Destroy;
begin
  FreeAndNil(FColumns);
  inherited;
end;

procedure TOMForeignKeyTableMetaData.SetCatalogName(const Value: UnicodeString);
begin
  FCatalogName := Value;
end;

procedure TOMForeignKeyTableMetaData.SetColumns(
  const Value: TObjectList<TOMForeignKeyColumnMetaData>);
begin
  FColumns := Value;
end;

procedure TOMForeignKeyTableMetaData.SetForeignKeyName(
  const Value: UnicodeString);
begin
  FForeignKeyName := Value;
end;

procedure TOMForeignKeyTableMetaData.SetSchemaName(const Value: UnicodeString);
begin
  FSchemaName := Value;
end;

procedure TOMForeignKeyTableMetaData.SetTableName(const Value: UnicodeString);
begin
  FTableName := Value;
end;

{ TOMForeignKeyColumnsMetaData }

procedure TOMForeignKeyColumnMetaData.SetColumnName(
  const Value: UnicodeString);
begin
  FColumnName := Value;
end;

procedure TOMForeignKeyColumnMetaData.SetPrimaryColumnName(
  const Value: UnicodeString);
begin
  FPrimaryColumnName := Value;
end;

end.
