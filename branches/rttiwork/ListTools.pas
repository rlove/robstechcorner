unit ListTools;

interface
uses Generics.Collections;
type
 TListTools = class(TObject)
 public
    // Convert TList<T> to TArray<T>
    class function ToArray<T>(AList: TList<T>): TArray<T>;
    // Append Array elements in AValues to AList
    class procedure AppendList<T>(AList : TList<T>;AValues : TArray<T>);
    // Clear List and Append Values to aList
    class procedure ToList<T>(AList : TList<T>;AValues : TArray<T>);
 end;

implementation

{ TListTools }

class procedure TListTools.AppendList<T>(AList: TList<T>; AValues: TArray<T>);
var
  Element : T;
begin
  for Element in AValues do
  begin
     AList.Add(Element);
  end;
end;

class function TListTools.ToArray<T>(AList: TList<T>): TArray<T>;
// taken from rtti.pas
var
  i : Integer;
begin
  SetLength(Result, AList.Count);
  for i := 0 to AList.Count - 1 do
    Result[i] := AList[i];
end;

class procedure TListTools.ToList<T>(AList: TList<T>; AValues: TArray<T>);
begin
   AList.Clear;
   AppendList<T>(AList,AValues);
end;

end.
