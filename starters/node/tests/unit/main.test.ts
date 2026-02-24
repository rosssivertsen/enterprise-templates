import { describe, it, expect } from 'vitest';
import { handler } from '../../src/main.js';
import { IncomingMessage, ServerResponse } from 'node:http';
import { Socket } from 'node:net';

function createMockRequest(url: string, method: string): IncomingMessage {
  const req = new IncomingMessage(new Socket());
  req.url = url;
  req.method = method;
  return req;
}

function createMockResponse(): ServerResponse & { _getData: () => string; _getStatusCode: () => number } {
  const res = new ServerResponse(new IncomingMessage(new Socket())) as any;
  let data = '';
  let statusCode = 200;
  res.writeHead = (code: number) => { statusCode = code; return res; };
  res.end = (chunk: string) => { data = chunk; };
  res._getData = () => data;
  res._getStatusCode = () => statusCode;
  return res;
}

describe('Health endpoint', () => {
  it('returns ok status', () => {
    const req = createMockRequest('/health', 'GET');
    const res = createMockResponse();
    handler(req, res);
    expect(res._getStatusCode()).toBe(200);
    expect(JSON.parse(res._getData())).toEqual({ status: 'ok' });
  });

  it('returns 404 for unknown routes', () => {
    const req = createMockRequest('/unknown', 'GET');
    const res = createMockResponse();
    handler(req, res);
    expect(res._getStatusCode()).toBe(404);
  });
});
