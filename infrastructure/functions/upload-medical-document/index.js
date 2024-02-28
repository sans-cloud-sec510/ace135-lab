const compressImgAndUploadToS3 = require('compress-img-and-upload-to-s3-securely-pretty-please-with-sugar-on-top')

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
    return respond(200, undefined)
  } else if (method !== 'POST') {
    return respond(405, undefined)
  }

  const body = JSON.parse(event.body)
  const { content, filename } = body
  const fileBuffer = Buffer.from(content, 'binary')

  let statusCode = 200
  let responseBody

  try {
    await compressImgAndUploadToS3(filename, fileBuffer, process.env.MEDICAL_DOCUMENTS_BUCKET_NAME)

    responseBody = {
      message: 'Document uploaded successfully!'
    }
  } catch (err) {
    const errString = err.toString()
    const errText = errString.split('Error: ')[1] || errString
    statusCode = (errText.startsWith('Unsupported') || errText.startsWith('Could not find MIME for Buffer')) ? 400 : 500

    responseBody = {
      err: errText
    }
  }

  return respond(statusCode, responseBody)
}

// Export the function as the package and as a function named "handler" on the package.
module.exports.handler = module.exports
