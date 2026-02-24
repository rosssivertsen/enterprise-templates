import { describe, it, expect } from 'vitest';

const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:3000';

describe('E2E: Health endpoint', () => {
  it('returns ok from running server', async () => {
    const response = await fetch(`${BASE_URL}/health`);
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data).toEqual({ status: 'ok' });
  });
});
