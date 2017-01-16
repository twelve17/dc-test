var fs = require("fs");

const packageJson = JSON.parse(fs.readFileSync(__dirname + "/package.json"));

exports.version = packageJson.version;

exports.someChange = "foo";

