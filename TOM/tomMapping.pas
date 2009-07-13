unit tomMapping;

interface
uses
  SysUtils,
  msxml,
  Classes,
  DBXCommon,
  SqlExpr,
  tomMetaData,
  Generics.Collections,
  Generics.Defaults;

type

  TOMValidationResultType = (rtHint,rtWarning,rtError);

  TOMValidationResults = class(TObject)
  protected
    FLocation: String;
    FResultType: TOMValidationResultType;
    FError: String;
    procedure SetError(const Value: String);
    procedure SetLocation(const Value: String);
    procedure SetResultType(const Value: TOMValidationResultType);
  public
    property ResultType : TOMValidationResultType read FResultType write SetResultType;
    property Error : String read FError write SetError;
    property Location : String read FLocation write SetLocation;
  end;

  // Mapping Generator from DBX Connection
  // Really could be done in a far more robust way.  With the structure of the
  // Mapping Files as Objects and a DTD or Schema
  // But time is not permitting right now.
  // But it this works for now, and it's not 100% throw away if
  // made to be more robust, and it may never need to be done.
  // It may even be cool to dog food the Framework and have IElements that
  // Represent the mapping in the future, but I need this now as the Ielement
  // structure is not finished yet.
  TOMMapGen = class(TObject)
  private
    function ProperCaseNaming(tableName:  String): String;
  protected
    FConnection: TDBXConnection;
    FSchema: String;
    FMetaData : TOMTableListMetaData;
    FValidationResults: TObjectList<TOMValidationResults>;
    procedure SetValidationResults(
      const Value: TObjectList<TOMValidationResults>);
    procedure SetConnection(const Value: TDBXConnection);
    procedure SetSchema(const Value: String);
    procedure ExtractMetaData; virtual;
    procedure MetaDataToDOM(Dom : IXMLDomDocument); virtual;
    procedure SetDefaultMapping(Dom : IXMLDomDocument); virtual;

    function TableNameToMappedName(tableName : String) : String; virtual;
    function ColumnNameToMappedName(tableName: String): String; virtual;
    procedure SetItemType(Dom : IXMLDOMDocument; Mapping : IXMLDOMNode; dbxType : Integer; AllowNulls : Boolean);
    function GetTypeName(dbxType : Integer;AllowNulls : Boolean) : String;
  public
    function FindOrCreate(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; ElementName : String;XPath : String) : IXMLDOMNode;
    function FindOrCreateAttr(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; AttrName : String) : IXMLDOMNode;
    procedure SetAttribute(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; AttrName : String; Value : String); overload;
    procedure SetAttribute(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; AttrName : String; Value : Boolean); overload;
    procedure SetAttribute(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; AttrName : String; Value : Integer); overload;
    procedure SetAttribute(Dom : IXMLDOMDocument; Parent : IXMLDOMNode; AttrName : String; Value : Double); overload;
    function CreateRoot(Dom : IXMLDOMDocument) : IXMLDOMNode;
    function CreateTable(Dom : IXMLDOMDocument;Parent : IXMLDOMNode;TableName : String) : IXMLDOMNode;
    function CreateDepTable(Dom : IXMLDOMDocument;Parent : IXMLDOMNode;TableName : String;KeyName : String) : IXMLDOMNode;
    function CreateColumn(Dom : IXMLDOMDocument;Parent : IXMLDOMNode;ColumnName : String) : IXMLDOMNode;
    function NoMapChildFound(Parent : IXMLDomNode) : boolean; inline;
    function MappedFound(Parent : IXMLDomNode) : boolean; inline;
    function CreateMapping(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
      MappedName: String): IXMLDOMNode;
  public
    constructor Create(dbCon : TDBXConnection;aSchema : String);
    destructor Destroy; override;
    procedure SaveToDom(Dom : IXMLDomDocument);
    procedure MergeToDom(Dom : IXMLDomDocument);
    function Validate(Dom : IXMLDomDocument) : Boolean;

    property Connection : TDBXConnection read FConnection write SetConnection;
    property Schema : String read FSchema write SetSchema;
    property ValidationResults : TObjectList<TOMValidationResults> read FValidationResults write SetValidationResults;
  end;


  TOMMapNames = class
   const
      Version = '0.1';
      VersionName = 'version';
      Root = 'ObjectMap';
      Table = 'Table';
      TableName = 'name';
      Column = 'Column';
      ColumnName = 'name';
      ColumnType = 'type';
      ColumnDbxType = 'dbxType';
      ColumnPrecision = 'precision';
      ColumnScale = 'scale';
      ColumnAllowNull = 'nullable';
      // This breaks class Completion, need to report
      BooleanStr : array[Boolean] of String = ('true','false');
      DepTable = 'table';
      DepTableName = 'name';
      DepTableKeyName = 'keyname';
      DepTablePrimaryColName = 'PrimaryName';
      NoMap = 'NoMap';
      Mapped = 'Mapped';
      MappedPropName = 'name';
      MappedType = 'type';
  end;

implementation

{ TOMMapGen }

constructor TOMMapGen.Create(dbCon: TDBXConnection;aSchema : String);
begin
  FConnection := dbCon;
  FSchema := aSchema;
  FValidationResults := TObjectList<TOMValidationResults>.Create;
  FValidationResults.OwnsObjects := true;
end;

function TOMMapGen.CreateColumn(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  ColumnName: String): IXMLDOMNode;
begin
  result := FindOrCreate(Dom,Parent,ColumnName,
                         TOMMapNames.Column + '[@' + TOMMapNames.ColumnName +
                          '=''' + ColumnName + ''']');
  SetAttribute(Dom,Parent,TOMMapNames.ColumnName,ColumnName);
end;

function TOMMapGen.CreateDepTable(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  TableName, KeyName: String): IXMLDOMNode;
begin
  result := FindOrCreate(Dom,Parent,TableName,
                         TOMMapNames.DepTable + '[@' + TOMMapNames.DepTableName +
                          '=''' + TableName + '''  and @'  + TOMMapNames.DepTableKeyName +
                          '=''' + KeyName + ''']');
  SetAttribute(Dom,Parent,TOMMapNames.DepTableName,TableName);
  SetAttribute(Dom,Parent,TOMMapNames.DepTableKeyName,KeyName);
end;

function TOMMapGen.CreateRoot(Dom: IXMLDomDocument): IXMLDOMNode;
begin
  result := DOM.selectSingleNode('/' + TOMMapNames.Root);
  if Not Assigned(result) then
  begin
    result := DOM.createElement(TOMMapNames.Root);
    DOM.appendChild(result);
  end;
  SetAttribute(DOM,result,TOMMapNames.VersionName,TOMMapNames.Version);
end;

function TOMMapGen.CreateTable(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  TableName: String): IXMLDOMNode;
begin
  result := FindOrCreate(Dom,Parent,TableName,
                         TOMMapNames.Table + '[@' + TOMMapNames.TableName +
                          '=''' + TableName + '''');
  SetAttribute(Dom,Parent,TOMMapNames.TableName,TableName);
end;

destructor TOMMapGen.Destroy;
begin
  if Assigned(FMetaData) then
     FreeAndNil(FMetaData);
  FreeAndNil(FValidationResults);
  inherited;
end;

procedure TOMMapGen.ExtractMetaData;
begin
  if Assigned(FMetaData) then
     FreeAndNil(FMetaData);
  FMetaData := TOMTableListMetaData.Create(FConnection,FSchema);
end;

function TOMMapGen.FindOrCreate(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  ElementName, XPath: String): IXMLDOMNode;
begin
  result := Parent.selectSingleNode(XPath);
  if Not Assigned(result) then
  begin
    result := DOM.createElement(ElementName);
    Parent.appendChild(Result);
  end;
end;

function TOMMapGen.CreateMapping(Dom: IXMLDOMDocument; Parent: IXMLDOMNode; MappedName : String): IXMLDOMNode;
begin
  result := DOM.createElement(MappedName);
  Parent.appendChild(Result);
  SetAttribute(DOM,result,TOMMapNames.MappedPropName,MappedName);
end;



function TOMMapGen.FindOrCreateAttr(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  AttrName: String): IXMLDOMNode;
begin
  result := Parent.attributes.getNamedItem(AttrName);
  if Not Assigned(result) then
  begin
    result := Dom.createAttribute(AttrName);
    Parent.attributes.setNamedItem(result);
  end;
end;

function TOMMapGen.GetTypeName(dbxType: Integer; AllowNulls: Boolean): String;
begin
 //TODO: Finish this Method,  I think I want a type mapping file to avoid hard coding this.
 //Temporary: To get code gen working
 result := 'String';
end;

procedure TOMMapGen.MetaDataToDOM(Dom: IXMLDomDocument);
var
 Root  : IXMLDOMNode;
 Table : TOMTableMetaData;
 TableNode : IXMLDOMNode;
 ColNode : IXMLDOMNode;
 DepTable : TOMForeignKeyTableMetaData;
 DepNode : IXMLDomNode;
 DepCol  : TOMForeignKeyColumnMetaData;
begin
  Root := CreateRoot(DOM);
  for table in FMetaData.Tables do
  begin
    TableNode := CreateTable(Dom,Root,Table.TableName);
    table.Columns.First;
    while table.Columns.InBounds do
    begin
      ColNode := CreateColumn(Dom,TableNode,Table.Columns.ColumnName);
      SetAttribute(Dom,ColNode,TOMMapNames.ColumnType,Table.Columns.TypeName);
      SetAttribute(Dom,ColNode,TOMMapNames.ColumnDbxType,Table.Columns.DbxDataType);
      SetAttribute(Dom,ColNode,TOMMapNames.ColumnPrecision,Table.Columns.Precision);
      SetAttribute(Dom,ColNode,TOMMapNames.ColumnScale,Table.Columns.Scale);
      SetAttribute(Dom,ColNode,TOMMapNames.ColumnAllowNull,Table.Columns.Nullable);
      table.Columns.Next;
    end;
    for DepTable in Table.DependantTables do
    begin
      DepNode := CreateDepTable(Dom,TableNode,DepTable.TableName,DepTable.ForeignKeyName);
      for DepCol in DepTable.Columns do
      begin
        ColNode := CreateColumn(DOM,DepNode,DepCol.ColumnName);
        SetAttribute(DOM,ColNode,TOMMapNames.DepTablePrimaryColName,DepCol.PrimaryColumnName);
      end;
    end;
  end;
end;

function TOMMapGen.NoMapChildFound(Parent: IXMLDomNode): boolean;
begin
  result := Assigned(Parent.selectSingleNode(TOMMapNames.NoMap));
end;

function TOMMapGen.MappedFound(Parent: IXMLDomNode): Boolean;
begin
  result := Assigned(Parent.selectSingleNode(TOMMapNames.Mapped));
end;

procedure TOMMapGen.MergeToDom(Dom: IXMLDomDocument);
begin
  ExtractMetaData;
  MetaDataToDOM(Dom);
end;

procedure TOMMapGen.SaveToDom(Dom: IXMLDomDocument);
begin
  // Remove all Children if any, so DOM is Empty!
  while DOM.childNodes.length > 0 do
  begin
    DOM.removeChild(DOM.childNodes.item[0]);
  end;
  MergeToDom(DOM);
end;

procedure TOMMapGen.SetAttribute(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  AttrName, Value: String);
begin
  FindOrCreateAttr(Dom,Parent,AttrName).text := Value;
end;


procedure TOMMapGen.SetAttribute(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  AttrName: String; Value: Boolean);
begin
  SetAttribute(Dom,Parent,AttrName,TOMMapNames.BooleanStr[Value]);
end;

procedure TOMMapGen.SetConnection(const Value: TDBXConnection);
begin
  FConnection := Value;
end;

procedure TOMMapGen.SetDefaultMapping(Dom: IXMLDomDocument);
var
 I, J: Integer;
 TableList : IXMLDOMNodeList;
 ColumnList : IXMLDOMNodeList;
 Mapping : IXMLDOMNode;
begin
  // Look at the Dom as the source first, don't look at the FMetaData First.
  // Reason,  is that this method might be called without creating MetaData nodes automatically
  // where you just want to get the default mappings.
  TableList := DOM.selectNodes('/' + TOMMapNames.Root + '/' + TOMMapNames.Table + '/');
  for I := 0 to TableList.length -1 do
  begin
    // If not mapped then create default mapping.
    if Not MappedFound(TableList.item[I]) and Not NoMapChildFound(TableList.item[I]) then
    begin
       CreateMapping(Dom,TableList.item[I],TableNameToMappedName(TableList.item[I].text));
    end;
    ColumnList := TableList.Item[I].selectNodes(TOMMapNames.Column);
    for J := 0 to ColumnList.length -1 do
    begin
      if Not MappedFound(ColumnList.item[J]) and Not NoMapChildFound(ColumnList.item[J]) then
      begin
         Mapping := CreateMapping(Dom,ColumnList.item[J],ColumnNameToMappedName(ColumnList.item[J].text));
         SetItemType(DOM,
                     Mapping,
                     StrToInt(ColumnList.item[J].attributes.getNamedItem(TOMMapNames.ColumnDbxType).Text),
                     TOMMapNames.BooleanStr[True] = ColumnList.item[J].attributes.getNamedItem(TOMMapNames.ColumnAllowNull).text);
      end;

    end;

  end;
end;

procedure TOMMapGen.SetItemType(Dom: IXMLDOMDocument; Mapping: IXMLDOMNode;
  dbxType: Integer; AllowNulls: Boolean);
var
 TypeName : String;
begin
   TypeName := GetTypeName(dbxType,AllowNulls);
   SetAttribute(DOM,Mapping,TOMMapNames.MappedType,TypeName);
end;

procedure TOMMapGen.SetSchema(const Value: String);
begin
  FSchema := Value;
end;

procedure TOMMapGen.SetValidationResults(
  const Value: TObjectList<TOMValidationResults>);
begin
  FValidationResults := Value;
end;

function TOMMapGen.ProperCaseNaming(tableName: String): String;
var
  Len: Integer;
  I: Integer;
begin
  // ProperCase Name ITEMS becomes Items
  Result := LowerCase(tableName);
  Len := Length(Result);
  if Len > 0  then
    Result[1] := UpCase(Result[1]);
  // Remove UnderScore and ProperCase ITEM_ORDERS becomes ItemOrders
  for I := Len - 1 downto 0 do
  begin
    if Result[I] = '_' then
    begin
      Delete(Result, I, 1);
      Result[I] := UpCase(Result[I]);
    end;
  end;
end;

function TOMMapGen.ColumnNameToMappedName(tableName: String): String;
begin
  // They way I wanted it formated, made it a seperate method to make it easy
  // to modify this rule, may want to have an event later on, but this works for now.

  Result := ProperCaseNaming(tableName);
end;

function TOMMapGen.TableNameToMappedName(tableName: String): String;
begin
  // They way I wanted it formated, made it a seperate method to make it easy
  // to modify this rule, may want to have an event later on, but this works for now.

 Result := ProperCaseNaming(tableName);

end;

function TOMMapGen.Validate(Dom: IXMLDomDocument): Boolean;
begin

end;

procedure TOMMapGen.SetAttribute(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  AttrName: String; Value: Integer);
begin
  SetAttribute(Dom,Parent,AttrName,IntToStr(Value));
end;

procedure TOMMapGen.SetAttribute(Dom: IXMLDOMDocument; Parent: IXMLDOMNode;
  AttrName: String; Value: Double);
begin
  SetAttribute(Dom,Parent,AttrName,FloatToStr(Value));
end;

{ TOMValidationResults }

procedure TOMValidationResults.SetError(const Value: String);
begin
  FError := Value;
end;

procedure TOMValidationResults.SetLocation(const Value: String);
begin
  FLocation := Value;
end;

procedure TOMValidationResults.SetResultType(
  const Value: TOMValidationResultType);
begin
  FResultType := Value;
end;

end.
