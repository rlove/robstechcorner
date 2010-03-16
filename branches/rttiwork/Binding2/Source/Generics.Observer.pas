unit Generics.Observer;

interface
uses Sysutils, Generics.Collections;

type
  INotifier<T> = interface
    procedure AddObserver(observer : T);
    procedure RemoveObserver(observer : T);
    procedure NotifyObservers(callback : TProc<T>);
  end;

  TNotifyList<T> = class(TList<T>,INotifier<T>);


implementation

end.
