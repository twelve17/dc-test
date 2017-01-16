import http from "http";
import { version } from "my-npm";

const port = process.env.PORT || 4000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader("Content-Type", "text/plain");
  res.end("Hello World! my-npm version is: " + version + " \n");
});

server.listen(port, () => {
  console.log(`Server running at port ${port}.`);
});
