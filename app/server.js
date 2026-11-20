const http = require('http');

const VERSION = '1.0.0';
const APP_NAME = 'supply-chain-security-lab';

const server = http.createServer((req, res) => {
  const response = {
    name: APP_NAME,
    version: VERSION,
    timestamp: new Date().toISOString()
  };

  if (req.url === '/healthz' || req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    response.status = 'healthy';
    response.message = 'Supply Chain Security Lab is healthy';
  } else if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    response.path = req.url;
    response.endpoints = ['/healthz', '/'];
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    response.path = req.url;
    response.error = 'Not found';
  }

  res.end(JSON.stringify(response, null, 2));
});

const PORT = process.env.PORT || 8080;

server.listen(PORT, () => {
  console.log(`${APP_NAME} v${VERSION} listening on port ${PORT}`);
});
