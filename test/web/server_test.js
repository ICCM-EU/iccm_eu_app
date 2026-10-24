const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const http = require('node:http');

process.env.NODE_ENV = 'test';
process.env.ADMIN_SECRET = 'test_secret_123';

const app = require('../../web/backend/server.js');

describe('Node.js Express Server (server.js) Tests', () => {
  let server;
  let port;

  before(async () => {
    server = http.createServer(app);
    await new Promise((resolve) => {
      server.listen(0, '127.0.0.1', () => {
        port = server.address().port;
        resolve();
      });
    });
  });

  after(async () => {
    await new Promise((resolve) => {
      server.close(resolve);
    });
  });

  function makePost(reqPath, body) {
    return new Promise((resolve, reject) => {
      const dataStr = JSON.stringify(body);
      const req = http.request({
        host: '127.0.0.1',
        port: port,
        path: reqPath,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(dataStr)
        }
      }, (res) => {
        let raw = '';
        res.on('data', chunk => raw += chunk);
        res.on('end', () => {
          let json;
          try { json = JSON.parse(raw); } catch (e) { json = raw; }
          resolve({ status: res.statusCode, body: json });
        });
      });
      req.on('error', reject);
      req.write(dataStr);
      req.end();
    });
  }

  test('POST / returns 400 when token is missing', async () => {
    const res = await makePost('/', {});
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.error, 'Missing token in request body');
  });

  test('POST / returns 200 when token is provided', async () => {
    const res = await makePost('/', { token: 'valid_token_123' });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
  });

  test('POST //subscribe normalizes URL double slashes and handles request', async () => {
    const res = await makePost('//subscribe', { token: 'token_1', topic: 'announcements' });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
  });

  test('POST /subscribe returns 400 when token or topic is missing', async () => {
    const resNoToken = await makePost('/subscribe', { topic: 'announcements' });
    assert.strictEqual(resNoToken.status, 400);

    const resNoTopic = await makePost('/subscribe', { token: 'token_1' });
    assert.strictEqual(resNoTopic.status, 400);
  });

  test('POST /unsubscribe returns 400 when token or topic is missing', async () => {
    const res = await makePost('/unsubscribe', { token: 'token_1' });
    assert.strictEqual(res.status, 400);
  });

  test('POST /unsubscribe returns 200 when token and topic are provided', async () => {
    const res = await makePost('/unsubscribe', { token: 'token_1', topic: 'announcements' });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
  });

  test('POST /send returns 403 when secret is incorrect', async () => {
    const res = await makePost('/send', {
      topic: 'announcements',
      secret: 'wrong_secret',
      messageText: 'Hello',
      author: 'Admin'
    });
    assert.strictEqual(res.status, 403);
  });

  test('POST /send returns 200 when valid parameters and secret are provided', async () => {
    const res = await makePost('/send', {
      topic: 'announcements',
      secret: 'test_secret_123',
      title: 'Update',
      messageText: 'Hello World',
      author: 'Admin'
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
  });
});
