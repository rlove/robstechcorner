namespace PrismTestHelper;

interface

uses
  System.Xml,
  System.Text,
  System.IO,
  System.Xml.Serialization,
  System.Linq;


type
  ConsoleApp = class
  public
    class method Main;
    class method Serialize(ClassName : String; aObj : Object; FileName : String);
    class method Deserialize(ClassName : String; FileName : String) : Object;
  end;

implementation
  
class method ConsoleApp.Main;
var
  SA : Array of String; 
  Obj : Object;
begin
   SA := System.Environment.GetCommandLineArgs();
   if SA.Length <> 3 then
   begin
    Console.WriteLine('Expecting two parameters');
    Console.WriteLine(String.Concat(Path.GetFileName(SA[0]),' ClassName Filename'));
    //Console.WriteLine(TypeOf(SampleTest).Name);
    Console.ReadLine;
   end
   else
   begin
     if File.Exists(SA[2]) then
     begin
       Obj := Deserialize(SA[1],SA[2]);
       File.Delete(SA[2]);
       Serialize(SA[1],Obj,SA[2]);
     end
     else
     begin
        Console.WriteLine('File not Found');
        Console.WriteLine(SA[2]);
     end;
   end;
end;

class method ConsoleApp.Serialize(ClassName : String;aObj : Object; FileName : String);
var
  X : XmlSerializer;
  SW : StreamWriter;
begin
  X := new XmlSerializer(&Type.GetType(ClassName,True,True));
  SW := new StreamWriter(FileName);
  X.Serialize(SW,aObj);
end;

class method ConsoleApp.Deserialize(ClassName : String; FileName : String) : Object;
var
  X : XmlSerializer;
  SR : StreamReader;
begin
  X := new XmlSerializer(&Type.GetType(ClassName,True,True));
  SR := new StreamReader(FileName);
  result := X.Deserialize(SR);  
end;

end.