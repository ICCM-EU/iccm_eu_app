const { test, describe } = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const vm = require('node:vm');
const fs = require('node:fs');

describe('firebase-messaging-sw.js Tests', () => {
  test('registers push, onBackgroundMessage, and notificationclick handlers', () => {
    const eventListeners = {};
    let backgroundMessageHandler = null;
    let shownNotification = null;

    const context = {
      console: console,
      importScripts: function () {},
      self: {
        firebaseConfig: {
          projectId: 'iccmeu-app'
        },
        addEventListener: function (type, handler) {
          eventListeners[type] = handler;
        },
        registration: {
          showNotification: function (title, options) {
            shownNotification = { title, options };
            return Promise.resolve();
          }
        },
        clients: {
          matchAll: function () {
            return Promise.resolve([]);
          },
          openWindow: function (url) {
            return Promise.resolve({ url });
          }
        }
      },
      firebase: {
        initializeApp: function () {},
        messaging: function () {
          return {
            onBackgroundMessage: function (handler) {
              backgroundMessageHandler = handler;
            }
          };
        }
      }
    };

    const filePath = path.join(__dirname, '../../web/firebase-messaging-sw.js');
    const code = fs.readFileSync(filePath, 'utf8');
    vm.createContext(context);
    vm.runInContext(code, context);

    assert.ok(eventListeners['push'], 'push listener should be added');
    assert.ok(eventListeners['notificationclick'], 'notificationclick listener should be added');
    assert.ok(backgroundMessageHandler, 'onBackgroundMessage handler should be set');

    // Test data-only payload in background message handler
    const dataPayload = {
      data: {
        title: 'Background Title',
        messageText: 'Background Body',
        click_action: '/'
      }
    };

    backgroundMessageHandler(dataPayload);
    assert.ok(shownNotification, 'showNotification should be called for data-only payload');
    assert.strictEqual(shownNotification.title, 'Background Title');
    assert.strictEqual(shownNotification.options.body, 'Background Body');
  });
});
