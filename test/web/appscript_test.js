const { test, describe } = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const vm = require('node:vm');
const fs = require('node:fs');

describe('appscript.js Tests', () => {
  function createEnvironment() {
    const context = {
      ContentService: {
        MimeType: { TEXT: 'TEXT', JSON: 'JSON' },
        createTextOutput: function (content) {
          return {
            _content: content,
            _mimeType: null,
            setMimeType: function (type) {
              this._mimeType = type;
              return this;
            }
          };
        }
      },
      SpreadsheetApp: {
        openById: function (id) {
          if (id === 'valid_sheet_id') {
            return {
              getSheetByName: function (name) {
                if (name === 'Venue') {
                  return {
                    getDataRange: function () {
                      return {
                        getValues: function () {
                          return [
                            ['Name', 'Description'],
                            ['Auditorium A', 'Main hall']
                          ];
                        }
                      };
                    }
                  };
                }
                return null;
              }
            };
          }
          return null;
        }
      }
    };

    const filePath = path.join(__dirname, '../../lib/utils/appscript.js');
    const code = fs.readFileSync(filePath, 'utf8');
    vm.createContext(context);
    vm.runInContext(code, context);
    return context;
  }

  test('doPost handles undefined request', () => {
    const env = createEnvironment();
    const output = env.doPost(undefined);
    assert.strictEqual(output._content, 'Error: Request is undefined.');
  });

  test('doPost returns status FAILED when action is not read', () => {
    const env = createEnvironment();
    const output = env.doPost({ parameter: { action: 'delete' } });
    const json = JSON.parse(output._content);
    assert.strictEqual(json.status, 'FAILED');
  });

  test('readData returns FAILED when sheetId parameter is missing', () => {
    const env = createEnvironment();
    const output = env.readData(null, 'Venue');
    const json = JSON.parse(output._content);
    assert.strictEqual(json.status, 'FAILED');
    assert.ok(json.message.includes('sheetId'));
  });

  test('readData returns FAILED when worksheet parameter is missing', () => {
    const env = createEnvironment();
    const output = env.readData('valid_sheet_id', null);
    const json = JSON.parse(output._content);
    assert.strictEqual(json.status, 'FAILED');
    assert.ok(json.message.includes('worksheet'));
  });

  test('readData returns SUCCESS with sheet data for valid parameters', () => {
    const env = createEnvironment();
    const output = env.readData('valid_sheet_id', 'Venue');
    const json = JSON.parse(output._content);
    assert.strictEqual(json.status, 'SUCCESS');
    assert.deepStrictEqual(json.columns, ['Name', 'Description']);
    assert.strictEqual(json.total_rows, 1);
  });
});
