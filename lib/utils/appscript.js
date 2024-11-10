function doPost(request) {
  if (request === undefined) {
    return ContentService.
      createTextOutput("Error: Request is undefined.").
      setMimeType(ContentService.MimeType.TEXT);
  }
  // Open Google Sheet using ID
  var sheetId = request.parameter.sheetId;
  var worksheetname = request.parameter.worksheet;
  var action = request.parameter.action;
  if (action == 'read') {
    return readData(sheetId, worksheetname);
  } else {
    // Allow read data only through this API.
    return ContentService.
      createTextOutput(JSON.stringify({
        "status": "FAILED",
        "message": "action is not defined",
      })).
      setMimeType(ContentService.MimeType.JSON);
  }
}

function readData(sheetId, worksheetname) {
  var result = {
    "status": "NA",
    "data": [],
  };
  var spreadsheet = SpreadsheetApp.openById(sheetId);
  var worksheet = spreadsheet.getSheetByName(worksheetname);
  var sheetData = worksheet.getDataRange().getValues();
  // Get Header row and shift into data range.
  var columns = sheetData.shift();
  result["total_rows"] = sheetData.length;
  result["data"] = sheetData;
  result["columns"] = columns;
  result["status"] = "SUCCESS";

  // Return result
  return ContentService.
    createTextOutput(JSON.stringify(result)).
    setMimeType(ContentService.MimeType.JSON);
}
