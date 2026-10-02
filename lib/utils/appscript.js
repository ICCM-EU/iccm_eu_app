function doPost(request) {
  if (request === undefined) {
    return ContentService.
      createTextOutput("Error: Request is undefined.").
      setMimeType(ContentService.MimeType.TEXT);
  }
  // Open Google Sheet using ID
  var sheetId = (request && request.parameter) ? request.parameter.sheetId : null;
  var worksheetname = (request && request.parameter) ? request.parameter.worksheet : null;
  var action = (request && request.parameter) ? request.parameter.action : null;

  // Default action to 'read' if not specified (e.g. when doGet fallback is triggered)
  if (!action) {
    action = 'read';
  }

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

// fallback wrapper for redirects to google reply data cache
function doGet(e) {
  return doPost(e);
}

function readData(sheetId, worksheetname) {
  var result = {
    "status": "NA",
    "data": [],
  };

  if (!sheetId) {
    result["status"] = "FAILED";
    result["message"] = "sheetId parameter is missing";
    return ContentService.
      createTextOutput(JSON.stringify(result)).
      setMimeType(ContentService.MimeType.JSON);
  }

  var spreadsheet = SpreadsheetApp.openById(sheetId);
  if (!spreadsheet) {
    result["status"] = "FAILED";
    result["message"] = "Spreadsheet not found for ID: " + sheetId;
    return ContentService.
      createTextOutput(JSON.stringify(result)).
      setMimeType(ContentService.MimeType.JSON);
  }

  if (!worksheetname) {
    result["status"] = "FAILED";
    result["message"] = "worksheet parameter is missing";
    return ContentService.
      createTextOutput(JSON.stringify(result)).
      setMimeType(ContentService.MimeType.JSON);
  }

  var worksheet = spreadsheet.getSheetByName(worksheetname);
  if (!worksheet) {
    result["status"] = "FAILED";
    result["message"] = "Worksheet " + worksheetname + " not found";
    return ContentService.
      createTextOutput(JSON.stringify(result)).
      setMimeType(ContentService.MimeType.JSON);
  }

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
