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
          resolve({ status: res.statusCode, body: json, headers: res.headers });
        });
      });
      req.on('error', reject);
      req.write(dataStr);
      req.end();
    });
  }

  test('Security headers X-Content-Type-Options and X-Frame-Options are present', async () => {
    const res = await makePost('/', { token: 'valid_token' });
    assert.strictEqual(res.headers['x-content-type-options'], 'nosniff');
    assert.strictEqual(res.headers['x-frame-options'], 'DENY');
  });

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

  test('POST /subscribe rejects invalid topic with spaces or special characters', async () => {
    const res = await makePost('/subscribe', { token: 'token_1', topic: 'invalid topic name!' });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.error, 'Missing or invalid topic in request body');
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

  test('POST /send rejects unauthorized or partially matching secret using timing safe comparison', async () => {
    const resWrongSecret = await makePost('/send', {
      topic: 'announcements',
      secret: 'test_secret_12',
      messageText: 'Hello',
      author: 'Admin'
    });
    assert.strictEqual(resWrongSecret.status, 403);

    const resEmptySecret = await makePost('/send', {
      topic: 'announcements',
      secret: '',
      messageText: 'Hello',
      author: 'Admin'
    });
    assert.strictEqual(resEmptySecret.status, 403);
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
