const glob = require("glob");
const globrex = require('globrex');

const result = globrex("node_modules/**", { globstar: true });
console.log(result.regex.test("node_modules/lol/xd.js"), result);

// async function test() {
// 	const files = await glob.glob(".**/*.luau");
// 	console.log(files);
// }

// test();
