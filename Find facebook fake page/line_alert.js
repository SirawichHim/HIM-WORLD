function onEdit(e) {
  const sheet = e.source.getActiveSheet();
  const sheetName = sheet.getName();
  //Select the desired column when data is added.
  const columnsToCheck = [1, 2, 3, 4]; // Columns A, B, C, D

  if (sheetName === 'Monitoring') {
    const range = e.range;
    const startRow = range.getRow();
    const numRows = range.getNumRows();
    const startColumn = range.getColumn();
    const numColumns = range.getNumColumns();

    if (startColumn === 1 && numColumns >= 4 && numRows > 0) {
      for (let i = 0; i < numRows; i++) {
        const row = startRow + i;
        const values = sheet.getRange(row, 1, 1, 4).getValues()[0];
    
        if (values.every(value => value !== "")) {
          const id = values[0];
          const pageName = values[1];
          const pageLink = values[2];
          const pageLike = values[3];
      //Message on line notification alert
          const message = `
            **Order:** ${row}
            **Page:** ${pageName}
            **Link:** ${pageLink}
            **Page Like:** ${pageLike}
          `;

          const lineNotifyToken = 'gmFhJgv6LqyWBXJgdqJjNpR6up2mWrxS9Pv7gRlmncS'; // Replace with your token
          const url = 'https://notify-api.line.me/api/notify';

          const payload = {
            'message': message
          };

          const options = {
            'method': 'post',
            'headers': {
              'Authorization': 'Bearer ' + lineNotifyToken
            },
            'payload': payload
          };

          try {
            const response = UrlFetchApp.fetch(url, options);
            Logger.log(`LINE Notify message sent successfully. Response code: ${response.getResponseCode()}`);
          } catch (error) {
            Logger.log(`Error sending LINE Notify message: ${error}`);
          }
        } else {
          Logger.log(`Skipping row ${row} as it has empty cells in relevant columns.`);
        }
      }
    }
  }
}
