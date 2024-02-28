// Reference: https://ourcodeworld.com/articles/read/607/how-to-obfuscate-javascript-code-with-node-js
const fs = require('fs')
const JavaScriptObfuscator = require('javascript-obfuscator')

const data = fs.readFileSync('./malware.js', 'UTF-8')

const obfuscationResult = JavaScriptObfuscator.obfuscate(data, {
  log: true
})

fs.writeFileSync('./innocuous.js', obfuscationResult.getObfuscatedCode())
