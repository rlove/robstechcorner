unit ObjectDataSet;

interface

// Special Thanks to Marco Cantu for his: Master Delphi 7 Book it a good
// place to start to learn how to build Custom TDataSets
uses SysUtils, Classes, Generics.Collections, Rtti, DB;

Type
  EBindingDataSetError = class(Exception)
  end;

  TRecInfo = record
    Bookmark: Integer;
    BookmarkFlag: TBookmarkFlag;
  end;

  PRecInfo = ^TRecInfo;

const
  RecInfoSize = sizeOf(TRecInfo);

type
  TCustomBindingDataSet = class;

  IBindingDataProvider = interface
    ['{D463C3CB-B94C-41FB-A5AE-788E6FF71DAE}']
    // Optional Hooks don't really have to do anything here
    // They are called at begin and end of the "InternalXXXX" Methods
    procedure BeforeOpen(DataSet: TCustomBindingDataSet);
    procedure BeforeClose(DataSet: TCustomBindingDataSet);
    procedure AfterOpen(DataSet: TCustomBindingDataSet);
    procedure AfterClose(DataSet: TCustomBindingDataSet);
    procedure BeforePost(DataSet: TCustomBindingDataSet);
    procedure AfterPost(DataSet: TCustomBindingDataSet);

    //Optional Hooks, since Base TDataset does nothing here,
    // and TCustomBindingDataSet also does nothing no point in having before/after
    procedure InternalEdit(DataSet: TCustomBindingDataSet);
    procedure InternalInsert(DataSet: TCustomBindingDataSet);
    procedure InternalCancel(DataSet: TCustomBindingDataSet);
    // Required to make Dataset work.
    procedure InternalInitFieldDefs(DataSet: TCustomBindingDataSet);
    procedure SetCurrentRecord(RecNo: Integer); // RecNo needs to be Zero Based!
    function GetCurrentRecord: Integer; // Return -1 if RowCount =0
    function GetRowCount: Integer;
    // Support for Nulls
    function GetRecordMemberIsNull(Index : Integer;MemberName : String) : Boolean;
    procedure SetRecordMemberNull(Index : Integer;MemberName : String);
    // Must return the Native type (i.e. if Nullable<Integer> return Integer in TValue
    function GetRecordMemberValue(Index: Integer; MemberName: String): TValue;
    procedure SetRecordMemberValue(Index: Integer; MemberName: String; Value: TValue);
  end;

  TCustomBindingDataSet = class(TDataSet)
  private
    FBindingDataProvider: IBindingDataProvider;
    procedure SetBindingDataProvider(const Value: IBindingDataProvider);
    // procedure SetBoundValue(const Value: TValue);
    // FBoundValue: TValue;
    // procedure SetBoundValue(const Value: TValue);
  protected
    // FCtx: TRttiContext;
    FIsOpen: Boolean;
    // FCurrentRecord: Integer;
    // FCanInsert: Boolean;
    // FCanUpdate: Boolean;
    // FCanDelete: Boolean;
    // FListType: TRttiType;
    // FListTypeStr: String;
    // FItemType: TRttiType;
    // FItemTypeStr: String;
    // procedure SetListType(const Value: String);
    // procedure SetItemType(const Value: String);
    procedure SetupFieldDef(FieldDef: TFieldDef; aMember: TRttiMember); virtual;
    procedure InternalLoadCurrentRecord(Buffer: TRecordBuffer);
  protected
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    procedure InternalCancel; virtual;
    procedure InternalEdit; virtual;
    procedure InternalInsert; virtual;

    function IsCursorOpen: Boolean; override;
    procedure InternalPost; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    procedure SetRecNo(Value: Integer); override;
    function GetRecNo: Integer; override;
    function GetRecordCount: Integer; override;

    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
  public
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BindingDataProvider: IBindingDataProvider read FBindingDataProvider write SetBindingDataProvider;
    // property ListType: String read FListTypeStr write SetListType;
    // property ItemType: String read FItemTypeStr write SetItemType;
    // property BoundValue: TValue read FBoundValue write SetBoundValue;

  end;

implementation

uses RttiUtils, TypInfo;

{ TBindingDataSet }

function TCustomBindingDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  GetMem(result, RecInfoSize);
end;

constructor TCustomBindingDataSet.Create(AOwner: TComponent);
begin
  inherited;
  // FBoundValue := TValue.Empty;
  // FCtx := TRttiContext.Create;
  // FCtx.GetType(TypeInfo(Integer)); // Insure Pool token created
end;

destructor TCustomBindingDataSet.Destroy;
begin

  inherited;
end;

procedure TCustomBindingDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer, RecInfoSize);
end;

procedure TCustomBindingDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  PInteger(Data)^ := PRecInfo(Buffer).Bookmark;
end;

function TCustomBindingDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  result := PRecInfo(Buffer).BookmarkFlag;
end;

function TCustomBindingDataSet.GetFieldData(Field: TField;
  Buffer: Pointer): Boolean;
var
 Value : TValue;
begin
  if Field.IsNull then
     FBindingDataProvider.SetRecordMemberNull(PRecInfo(Buffer)^.Bookmark,Field.Name)
  else


  Value := FBindingDataProvider.GetRecordMemberValue(PRecInfo(Buffer)^.Bookmark,Field.Name);



  result := true;
end;

function TCustomBindingDataSet.GetRecNo: Integer;
var
  lCurrentRecord: Integer;
begin
  UpdateCursorPos;
  lCurrentRecord := FBindingDataProvider.GetCurrentRecord;
  if lCurrentRecord < 0 then
    result := 1
  else
    result := lCurrentRecord + 1;
end;

function TCustomBindingDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  result := grOK;
  case GetMode of
    gmCurrent: begin
        if FBindingDataProvider.GetCurrentRecord >= FBindingDataProvider.GetRowCount - 1 then
          result := grError;
      end;
    gmNext: begin
        if FBindingDataProvider.GetCurrentRecord < FBindingDataProvider.GetRowCount - 1 then
          FBindingDataProvider.SetCurrentRecord(FBindingDataProvider.GetCurrentRecord + 1)
        else
          result := grEOF;
      end;
    gmPrior: begin
        if FBindingDataProvider.GetCurrentRecord > 0 then
          FBindingDataProvider.SetCurrentRecord(FBindingDataProvider.GetCurrentRecord + 1)
        else
          result := grBOF;
      end;
  end;
  if (result = grOK) then
    InternalLoadCurrentRecord(Buffer)
  else if (result = grError) and DoCheck then
    raise EBindingDataSetError.Create('Invalid Record');

end;

function TCustomBindingDataSet.GetRecordCount: Integer;
begin
  CheckActive;
  result := FBindingDataProvider.GetCurrentRecord + 1;
end;

procedure TCustomBindingDataSet.InternalCancel;
begin
  FBindingDataProvider.InternalCancel(Self);
end;

procedure TCustomBindingDataSet.InternalClose;
begin
  BindFields(False);
  if DefaultFields then
    DestroyFields;

  FIsOpen := False;
end;

procedure TCustomBindingDataSet.InternalEdit;
begin
  FBindingDataProvider.InternalEdit(Self);
end;

procedure TCustomBindingDataSet.InternalHandleException;
begin
  inherited;

end;

procedure TCustomBindingDataSet.InternalInitFieldDefs;
// var
// lField: TRttiField;
// lProp: TRttiProperty;
// lFieldDef: TFieldDef;
begin
  FBindingDataProvider.InternalInitFieldDefs(Self);
  // FieldDefs.Clear;
  // if Assigned(FItemType) then
  // begin
  // for lProp in FItemType.GetProperties do
  // begin
  // if lProp.Visibility in [mvPublic, mvPublished] then
  // begin
  // lFieldDef := FieldDefs.AddFieldDef;
  // SetupFieldDef(lFieldDef, lProp);
  // // If Unknow we don't want it as a field def
  // if lFieldDef.DataType = ftUnknown then
  // FieldDefs.Delete(FieldDefs.IndexOf(lFieldDef.Name));
  // end;
  // end;
  //
  // for lField in FItemType.GetFields do
  // begin
  // if lField.Visibility in [mvPublic, mvPublished] then
  // begin
  // lFieldDef := FieldDefs.AddFieldDef;
  // SetupFieldDef(lFieldDef, lField);
  // // If Unknow we don't want it as a field def
  // if lFieldDef.DataType = ftUnknown then
  // FieldDefs.Delete(FieldDefs.IndexOf(lFieldDef.Name));
  // end;
  // end;
  //
  // end;
end;

procedure TCustomBindingDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillChar(Buffer, RecInfoSize, 0);
end;

procedure TCustomBindingDataSet.InternalInsert;
begin
  FBindingDataProvider.InternalInsert(Self);
end;

procedure TCustomBindingDataSet.InternalLoadCurrentRecord(Buffer: TRecordBuffer);
begin
  PRecInfo(Buffer)^.BookmarkFlag := bfCurrent;
  PRecInfo(Buffer)^.Bookmark := FBindingDataProvider.GetCurrentRecord
end;

procedure TCustomBindingDataSet.InternalOpen;
begin
  FBindingDataProvider.BeforeOpen(Self);

  // Setup and Create fields
  InternalInitFieldDefs;
  if DefaultFields then
    CreateFields;
  BindFields(True);
  FIsOpen := True;

  FBindingDataProvider.AfterOpen(Self);
end;

procedure TCustomBindingDataSet.InternalPost;
begin
  FBindingDataProvider.BeforePost(Self);
  inherited InternalPost;
  FBindingDataProvider.AfterPost(Self);
end;

function TCustomBindingDataSet.IsCursorOpen: Boolean;
begin
  result := FIsOpen;
end;

procedure TCustomBindingDataSet.SetBindingDataProvider(const Value: IBindingDataProvider);
begin
  FBindingDataProvider := Value;
end;

procedure TCustomBindingDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  PRecInfo(Buffer).Bookmark := PInteger(Data)^;
end;

procedure TCustomBindingDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer).BookmarkFlag := Value;
end;

procedure TCustomBindingDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
 Value : TValue;
begin

  FBindingDataProvider.SetRecordMemberValue(PRecInfo(Buffer)^.Bookmark,Field.Name,Value);
end;

// procedure TCustomBindingDataSet.SetBoundValue(const Value: TValue);
// begin
// FBoundValue := Value;
// end;
//
// procedure TCustomBindingDataSet.SetItemType(const Value: String);
// begin
// FItemTypeStr := Value;
// FItemType := FCtx.FindType(Value);
// end;
//
// procedure TCustomBindingDataSet.SetListType(const Value: String);
// begin
// FListTypeStr := Value;
// FListType := FCtx.FindType(Value);
// end;

procedure TCustomBindingDataSet.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value > 1) and (Value <= FBindingDataProvider.GetRowCount) then
  begin
    FBindingDataProvider.SetCurrentRecord(Value - 1);
    Resync([]);
  end;
end;

procedure TCustomBindingDataSet.SetupFieldDef(FieldDef: TFieldDef; aMember: TRttiMember);
var
  lMemberType: TRttiType;
begin
  // Decendants can use Attributes to further define how the field defs are defined.
  FieldDef.Name := aMember.Name;
  case aMember.MemberType.TypeKind of
    tkInteger, tkEnumeration, tkSet, tkInt64: FieldDef.DataType := ftInteger;
    tkChar: FieldDef.DataType := ftFixedChar;
    tkWChar: FieldDef.DataType := ftFixedWideChar;
    tkFloat: begin
        if aMember.MemberType.QualifiedName = 'System.TDateTime' then
          FieldDef.DataType := ftDateTime
        else if aMember.MemberType.QualifiedName = 'System.TDate' then
          FieldDef.DataType := ftDate
        else if aMember.MemberType.QualifiedName = 'System.TTime' then
          FieldDef.DataType := ftTime
        else
          FieldDef.DataType := ftFloat;
      end;
    tkString, tkLString, tkUString, tkWString: FieldDef.DataType := ftString;
    tkVariant: FieldDef.DataType := ftVariant;
  else
    {
      tkArray, tkRecord, tkInterface, tkClass, tkMethod,
      tkDynArray, tkClassRef, tkPointer, tkProcedure : }
    FieldDef.DataType := ftUnknown;
  end; { Case }
end;

end.
