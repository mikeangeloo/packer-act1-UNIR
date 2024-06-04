var http = require("http");
var port = 3000;
var now = new Date();
http
  .createServer(function (req, res) {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.write("Hola mundo desde node.js\n");
    res.write("Alumno: Miguel Angel Ramirez Lopez, UNIR-DevOps\n");
    res.write("Fecha de lanzamiento: " + now.toGMTString());
    res.end("\nAdios!");
  })
  .listen(port, "");
console.log("Servidor corriendo en puerto: " + port);