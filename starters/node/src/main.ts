import { createServer, IncomingMessage, ServerResponse } from 'node:http';

const PORT = parseInt(process.env.PORT || '3000', 10);

const handler = (req: IncomingMessage, res: ServerResponse): void => {
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not Found' }));
};

const server = createServer(handler);

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export { handler };
