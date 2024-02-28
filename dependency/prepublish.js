// Reference: https://ourcodeworld.com/articles/read/607/how-to-obfuscate-javascript-code-with-node-js
const fs = require('fs')
const JavaScriptObfuscator = require('javascript-obfuscator')

const data = fs.readFileSync('./malware.js', 'UTF-8')

const obfuscationResult = JavaScriptObfuscator.obfuscate(data,     {
  compact: true,
  controlFlowFlattening: false,
  deadCodeInjection: true,
  deadCodeInjectionThreshold: 1,
  debugProtection: false,
  disableConsoleOutput: false,
  identifierNamesGenerator: 'hexadecimal',
  log: true,
  renameGlobals: false,
  rotateStringArray: true,
  selfDefending: true,
  shuffleStringArray: true,
  splitStrings: true,
  splitStringsChunkLength: 5,
  stringArray: false,
  transformObjectKeys: true,
  unicodeEscapeSequence: false
})

fs.writeFileSync('./innocuous.js', obfuscationResult.getObfuscatedCode())
