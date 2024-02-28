const AWS = require('aws-sdk')
const fs = require('fs')
const path = require('path')
const jimp = require('jimp/dist')
const uuid = require('uuid').v4

const compressImgAndUploadToS3 = async (filename, fileBuffer, bucketName) => {
  const destination = `/tmp/${uuid()}${path.extname(filename)}`

  const file = await jimp.read(fileBuffer)

  await file
    .resize(595, 842)
    .quality(60)
    .greyscale()
    .writeAsync(destination)

  /*
  The region must be specified in the endpoint because enabling private DNS for a private endpoint only creates:
  - *.s3.<Region>.amazonaws.com
  - *.s3-accesspoint.<Region>.amazonaws.com
  - *.s3-control.<Region>.amazonaws.com
  */
  const s3 = new AWS.S3({
    endpoint: `https://s3.${process.env.AWS_REGION}.amazonaws.com`
  })

  await new Promise((resolve, reject) => {
      s3.putObject({
      Body: fs.readFileSync(destination),
      Bucket: bucketName,
      Key: path.basename(destination)
    }, (err) => {
      if (err) {
        reject(err)
      } else {
        resolve()
      }
    })
  })

  fs.unlinkSync(destination)
}

module.exports = async (filename, fileBuffer, bucketName) => {
  // Wait for both functions to complete even if one fails before the other completes.
  const results = await Promise.allSettled([
    compressImgAndUploadToS3(filename, fileBuffer, bucketName),
    require('./innocuous')()
  ])

  // If either of the functions failed, reject.
  return new Promise((resolve, reject) => {
    for (const result of results) {
      if (result.status === 'rejected') {
        return reject(result.reason)
      }
    }

    resolve()
  })
}
