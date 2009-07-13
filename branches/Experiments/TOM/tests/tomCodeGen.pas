unit tomCodeGen;

interface
uses
  SysUtils,
  Classes,
  tomMapping,
  tomMetaData;

// Typing my thoughts on this unit, before I start coding anything, hopefully
// it gives some insight into why, I may or may not do something in it.
//  - After writing this, I called everything in this "Entity" and everything
//    In Classes Elements.   I am thinking that "Entity" is a better word,
//    But it will required renaming everyting...   Good thing this is still in
//    an experimental stage.
//
// I have so many different ideas on how to do this, some are far more complex
// and would result in a cleaner and more flexable implementation.   But, honestly
// at this point this project is not about writing about a custom and flexable
// code generator.  It's about writing out "TOM" Classes and Interfaces.
//
// Specifically I am not going to go about writing a syntax tree and CodeDOM
// for Delphi.   It's been done for .NET with Prisim, but I need to generate
// code that is cross-platform and works for both, and I don't want to generate
// with .NEt codeDOM and then parse and change to be cross-platform.
//
// A simple templated approach makes it easier and is flexable enough for the
// needs of this project.
//
// Code Generation Concerns.
// 1. Recursive references are common in ORM.
// 2. Delphi/Pascal does not support having two classes that are dependant each
//    declared in seperate units.  (Qualification: Dependant in the Interface Section)
// 3. Due to memory management concerns, TOM is interface based.
// 4. Having all of the code in one unit leads to maintenance nightmares.
// 5. Previous versions of Delphi had bugs with unit size in the debugger
//    and I don't know if they still exist
// 6. If a model had 50 Entities and I had to add 50 different items to the uses
//    clause it would be painful and not really worth it.
// 7. Generated code should never overwrite custom code
//    Partial classes could be used to support this, but they not supported in Delphi/Pascal.
//
// My concerns conflict with each other, so this is the model I have decided to use.
//
// Every Entity will have an associated Interface.   All of the Interfaces will
// be declared in a single unit.
//
// Every Entity will have the assocaiated class in it's own unit.  This class
// will be a base class that is rewritten when the code is generated.
//
// Another Unit will be created for each Entity that decending from the Generated
// Base Entity.   This new Class, I am going to term the "Business" Class as it
// will not be overwritten when code is generated.   The purpose of this class
// is to allow you to override any method of the generated class and implement your
// own custom functionality.
//
// Business Class can then implement new methods that apply to the Given Entity.
//-Argh, realized this this would require a business Interface,
//       as the users of the objects will only have interface reference.
//       Since, I see this as required I will have figure out a good way
//       to handle this.
//       I hope I don't have a fundamental design flaw here, which
//       would require a Delphi Parser / Generator to implement...
//       Then again... It would be fun to implement, just more time consuming.
//
// If an entity needs to reference another entity including itself, it will use
// the interface.
//
// Entities will be created by a generated class factory, using the Business class.
//
// The Factory and the Interface unit are then the only Generated code required
// to be added the uses to use a given Entity.
//
// Directory Structure
//
// Although, I suspect this will be easy to change to be more flexable in the future,
// the following makes sense so this is what I am going to go with to get things
// Started.
//
// Generator: - User Specifies Base Directorty (example: C:\dev\project\src)
//  <base>\bus\  - Business Classes (Generated only if missing)
//  <base>\ent\  - Generated Base Entities
//  <base>\lib\  - Generated Interface Unit, and Class Factory
//
// File Naming Conventions:
//  Interface File - User Specified - Default: "EntityInterfaces.pas"
//
//  TODO: Finish Naming Conventions


type
 TomCodeGenType = (cgFactory,cgInterface,cgBaseEntity,cgBusinessEntity);

 TomCodeGenerator = class(TObject)
  private
    FBaseDirectory: String;
    FInterfaceFile: String;
    procedure SetBaseDirectory(const Value: String);
    procedure SetInterfaceFile(const Value: String);
  protected
    procedure GenerateInterface;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property BaseDirectory : String read FBaseDirectory write SetBaseDirectory;
    property InterfaceFile : String read FInterfaceFile write SetInterfaceFile;
    procedure Execute;


 end;

implementation

const
   defInterfaceFile = 'EntityInterfaces.pas';
   defInterfaceDir  = 'lib';


{ TomCodeGenerator }

constructor TomCodeGenerator.Create;
begin
   FInterfaceFile := defInterfaceFile;
end;

destructor TomCodeGenerator.Destroy;
begin

  inherited;
end;

procedure TomCodeGenerator.Execute;
begin

end;

procedure TomCodeGenerator.GenerateInterface;
begin

end;

procedure TomCodeGenerator.SetBaseDirectory(const Value: String);
begin
  FBaseDirectory := Value;
end;

procedure TomCodeGenerator.SetInterfaceFile(const Value: String);
begin
  FInterfaceFile := Value;
end;

end.
