{$IFDEF CLR}
   namespace PrismTestHelper;
{$ELSE}
   unit uSampleTest;
{$ENDIF}


interface

{$IFDEF CLR}
uses
  System.Collections.Generic,
  System.Linq,
  System.Text;
{$ELSE}
 uses
   Generics.Collections,
   Classes, SysUtils;

 type
   DateTime = TDateTime;
   List<T> = class(TList<T>)
   end;
{$ENDIF}


type
  SampleSubClass = {$IFDEF CLR}public{$ENDIF} class
  private
    FValue1 : String;
    FValue2 : Integer;
  public
    property Value1 : String read FValue1 write FValue1;
    property Value2 : Integer read FValue2 write FValue2;
  end;

  ArrayOfString = Array of String;

  SampleTest = {$IFDEF CLR}public{$ENDIF} class
  private
    FValue1 : String;
    FValue2 : DateTime;
    FValue3 : Boolean;
    FValue4 : Integer;
    FValue5 : Double;
    FValue6 : TList<Integer>;
    FValue7 : ArrayOfString;
    FValue8 : SampleSubClass;
    FValue9 : List<SampleSubClass>;
  protected
  public
    property Value1 : String read FValue1 write FValue1;
    property Value2 : DateTime read FValue2 write  FValue2;
    property Value3 : Boolean read FValue3 write  FValue3;
    property Value4 : Integer read FValue4 write FValue4;
    property Value5 : Double  read FValue5 write FValue5;
    property Value6 : TList<Integer> read FValue6 write FValue6;
    property Value7 : ArrayOfString  read FValue7 write FValue7;
    property Value8 : SampleSubClass read FValue8 write FValue8;
    property Value9 : List<SampleSubClass> read FValue9 write FValue9;
  end;

implementation

end.