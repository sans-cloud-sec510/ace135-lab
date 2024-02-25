const dependency = require('./dependency')

const respond = (statusCode, responseBody) => {
  return {
    statusCode,
    body: JSON.stringify(responseBody),
    headers: {
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,POST'
    }
  }
}

module.exports = async event => {
  const method = event.requestContext.http.method

  if (method === 'OPTIONS') {
    return respond(200, undefined, ...args)
  } else if (method !== 'POST') {
    return respond(405, undefined, ...args)
  }

  let statusCode = 200

  const responseBody = {
    message: await dependency() // TODO: Don't expose the output once we have a solid exfiltration path.
  }

  return respond(statusCode, responseBody)
}

// Export the function as the package and as a function named "handler" on the package.
module.exports.handler = module.exports
