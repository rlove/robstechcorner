unit SubmitReportDlg;
// MIT License
//
// Copyright (c) 2009 - Robert Love
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
interface
uses SysUtils,Classes, Controls, SubmitReportForm;

type
  ESubmitDialogError = class(Exception);
  TSubmitReportDlg = class(TComponent)
  private
    FForm : TfrmSubmitReport;
    FTechnicalDetails: TStrings;
    FTitle: String;
    FAllowAttachments: boolean;
    FReportQuestion: String;
    FReportComment: TStrings;
    procedure SetTechnicalDetails(const Value: TStrings);
    procedure SetAllowAttachments(const Value: boolean);
    procedure SetReportComment(const Value: TStrings);
    procedure SetReportQuestion(const Value: String);
    procedure SetTitle(const Value: String);
    procedure CreateFormIfNeeded;
    function GetAttachment(Index: Integer): String;
    function GetAttachmentCount: Integer;
    function GetAttachmentDescription(Index: Integer): String;
  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;

    function Execute: Boolean;  virtual;
    procedure CaptureImages;
    property TechnicalDetails : TStrings read FTechnicalDetails write SetTechnicalDetails;
    property ReportComment : TStrings read FReportComment write SetReportComment;
    property Title : String read FTitle write SetTitle;
    property ReportQuestion : String read FReportQuestion write SetReportQuestion;
    property AllowAttachments : boolean read FAllowAttachments write SetAllowAttachments;
    property AttachmentCount : Integer read GetAttachmentCount;
    property Attachment[Index : Integer] : String read GetAttachment;
    property AttachmentDescription[Index : Integer] : String read GetAttachmentDescription;


  published
  end;

implementation
uses ComCtrls,RtlConsts;

{ TSubmitReportDlg }

procedure TSubmitReportDlg.CaptureImages;
begin
  CreateFormIfNeeded;
  FForm.CaptureImages;
end;

constructor TSubmitReportDlg.Create(aOwner: TComponent);
begin
  inherited;
  FTechnicalDetails := TStringList.Create;
  FReportComment := TStringList.Create;
  FTitle := icTitle;
  FReportQuestion := icReportQuestion;
end;

procedure TSubmitReportDlg.CreateFormIfNeeded;
begin
 if Not Assigned(FForm) then
    FForm := TfrmSubmitReport.Create(nil);
end;

destructor TSubmitReportDlg.Destroy;
begin
  FreeAndNil(FTechnicalDetails);
  FreeAndNil(FReportComment);
  if Assigned(FForm) then
     FreeAndNil(FForm);
  inherited;
end;

function TSubmitReportDlg.Execute: Boolean;
begin
  CreateFormIfNeeded;
  FForm.Caption := FTitle;
  FForm.lblReport.Caption := FReportQuestion;
  FForm.memTechDetails.Lines.Assign(FTechnicalDetails);
  result := (FForm.ShowModal = mrOk);
  if result then
  begin
    FReportComment.Assign(FForm.memUserComment.Lines);
  end;
end;

function TSubmitReportDlg.GetAttachment(Index: Integer): String;
begin
  if Assigned(FForm) then
    result := FForm.lvAttachedFiles.Items.Item[Index].Caption
  else
    raise ESubmitDialogError.Create('Unable to Get Attachments, must call execute first.');
end;

function TSubmitReportDlg.GetAttachmentCount: Integer;
begin
 if Assigned(FForm) then
   result := FForm.lvAttachedFiles.Items.Count
 else
   result := 0;
end;

function TSubmitReportDlg.GetAttachmentDescription(Index: Integer): String;
var
 li : TListItem;
begin
  if Assigned(FForm) then
  begin
    li := FForm.lvAttachedFiles.Items.Item[Index];
    if li.SubItems.Count > 0 then
       result := li.SubItems.Strings[0]
    else
       result := '';
  end
  else
    raise ESubmitDialogError.Create('Unable to Get Attachments, must call execute first.');
end;

procedure TSubmitReportDlg.SetAllowAttachments(const Value: boolean);
begin
  FAllowAttachments := Value;
end;

procedure TSubmitReportDlg.SetReportComment(const Value: TStrings);
begin
  FReportComment := Value;
end;

procedure TSubmitReportDlg.SetReportQuestion(const Value: String);
begin
  FReportQuestion := Value;
end;

procedure TSubmitReportDlg.SetTechnicalDetails(const Value: TStrings);
begin                            
  FTechnicalDetails.Assign(Value);
end;

procedure TSubmitReportDlg.SetTitle(const Value: String);
begin
  FTitle := Value;
end;

end.
