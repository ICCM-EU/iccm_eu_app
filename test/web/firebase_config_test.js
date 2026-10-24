const { test, describe } = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const vm = require('node:vm');
const fs = require('node:fs');

describe('firebase-config.js Tests', () => {
  test('populates self.firebaseConfig and window.firebaseConfig with expected keys', () => {
    const filePath = path.join(__dirname, '../../web/firebase-config.js');
    const code = fs.readFileSync(filePath, 'utf8');

    const context = {
      self: {},
      window: {}
    };

    vm.createContext(context);
    vm.runInContext(code, context);

    assert.ok(context.self.firebaseConfig, 'self.firebaseConfig should be defined');
    assert.ok(context.window.firebaseConfig, 'window.firebaseConfig should be defined');

    const config = context.window.firebaseConfig;
    assert.strictEqual(config.projectId, 'iccmeu-app');
    assert.ok(config.apiKey);
    assert.ok(config.messagingSenderId);
    assert.ok(config.vapidKey);
  });
});
