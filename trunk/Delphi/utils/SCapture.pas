unit SCapture;
//Initial Version of this code was taken from
//  http://delphi.about.com/od/adptips2006/qt/captureactive.htm
//  Author: Zarko Gajic

// Updated to support multiple monitors.
// Author: Robert Love

interface
uses
  Windows, SysUtils, Graphics;

type
  EMonitorCaptureException = class(Exception);
  TCaptureContext = (ccActiveWindow,ccDesktopMonitor,ccActiveMonitor,
                     ccSpecificMonitor,ccAllMonitors);

function MonitorCount : Integer;

procedure CaptureScreen(aCaptureContext : TCaptureContext; destBitmap : TBitmap;aMonitorNum : Integer = 1);

implementation

uses
  MultiMon;

type
  MonIndex = record
    Idx : Integer;
    Cnt : Integer;
    MonInfo : MONITORINFO;
  end;
  PMonIndex = ^MonIndex;


// Callback function in function MonitorCount
function MonCountCB(hm: HMONITOR; dc: HDC; r: PRect; l: LPARAM): Boolean; stdcall;
begin
  inc(Integer(pointer(l)^));
  result := true;
end;

function MonitorCount : Integer;
begin
  result := 0;
  EnumDisplayMonitors(0,nil,MonCountCB, Integer(@result));
end;

// Callback function in function GetMonInfoByIdx
function MonInfoCB(hm: HMONITOR; dc: HDC; r: PRect; l: LPARAM): Boolean; stdcall;
var
 MI : PMonIndex;
begin
  MI := PMonIndex(pointer(l));
  Inc(MI.Cnt);
  if MI.Cnt = MI.Idx then
     GetMonitorInfo(hm,@(MI.MonInfo));
  result := true;
end;

function GetMonInfoByIdx(MonIdx : Integer) : MONITORINFO;
var
 MI : MonIndex;
begin
  MI.MonInfo.cbSize := SizeOf(MI.MonInfo);
  MI.Idx := MonIdx;
  MI.Cnt := 0;
  EnumDisplayMonitors(0,nil,MonInfoCB, Integer(@MI));
  result := MI.MonInfo;
end;



procedure CaptureScreen(aCaptureContext : TCaptureContext; destBitmap : TBitmap;aMonitorNum : Integer);
var
   x,y,w,h : integer;
   DC : HDC;
   hWin : Cardinal;
   r : TRect;
   Mon : HMONITOR;
   MonInfo : MONITORINFO;
begin
  // Initialization of vars to avoid warning, but not required.
  DC :=0;
  hWin := 0;
  w := 0;
  h := 0;
  // Initialization of vars that are required.
  x := 0;
  y := 0;
  case aCaptureContext of
    ccActiveWindow:
    begin
      hWin := GetForegroundWindow;
      dc := GetWindowDC(hWin);
      GetWindowRect(hWin,r);
      w := r.Right - r.Left;
      h := r.Bottom - r.Top;
    end;
    ccDesktopMonitor:
    begin
      hWin := GetDesktopWindow;
      dc := GetDC(hWin) ;
      w := GetDeviceCaps (DC, HORZRES);
      h := GetDeviceCaps (DC, VERTRES);
    end;
    ccActiveMonitor,ccSpecificMonitor:
    begin
      hWin := GetForegroundWindow;
      dc := CreateDC('DISPLAY',nil,nil,nil);
      if aCaptureContext = ccActiveMonitor then
      begin
        Mon := MonitorFromWindow(hWin,MONITOR_DEFAULTTONEAREST);
        MonInfo.cbSize := SizeOf(MonInfo);
        GetMonitorInfo(Mon,@MonInfo);
      end
      else
      begin
        if (MonitorCount < aMonitorNum) or (aMonitorNum < 1) then
           raise EMonitorCaptureException.CreateFmt('Monitor Index out of Bounds [%d]',[aMonitorNum]);
        MonInfo := GetMonInfoByIdx(aMonitorNum);
      end;
      x := MonInfo.rcMonitor.Left;
      y := MonInfo.rcMonitor.Top;
      w := MonInfo.rcMonitor.Right - MonInfo.rcMonitor.Left;
      h := MonInfo.rcMonitor.Bottom - MonInfo.rcMonitor.Top;
    end;
    ccAllMonitors:
    begin
      hWin := 0;
      dc := CreateDC('DISPLAY',nil,nil,nil);
      w := GetSystemMetrics(SM_CXVIRTUALSCREEN);
      h := GetSystemMetrics(SM_CYVIRTUALSCREEN);
    end;
  end;
  try
    destBitmap.Width := w;
    destBitmap.Height := h;
    BitBlt(destBitmap.Canvas.Handle,
           0,
           0,
           destBitmap.Width,
           destBitmap.Height,
           DC,
           x,
           y,
           SRCCOPY) ;
   finally
    ReleaseDC(hWin, DC) ;
   end;

end;


end.
