import axios from 'axios'
import { toast, ToastContainer } from 'react-toastify'
import 'react-toastify/dist/ReactToastify.css'
import './App.css';

const functionUrl = 'https://2yz5idbwnpya475oi2np5xt2li0qznjq.lambda-url.us-east-1.on.aws'

export const uploadDocument = function(e) {
  const document = e.target.files[0]

  const reader = new FileReader()
  reader.readAsBinaryString(document)

  reader.addEventListener('load', async () => {
    try {
      const res = await axios.post(functionUrl, {
        content: reader.result,
        filename: document.name
      })

      toast.success(res.data.message, {
        autoClose: false,
        draggable: false
      })
    } catch (err) {
      toast.error(err.toString(), { autoClose: 10000 })
    }

    e.target.files = new DataTransfer().files
  }, false)
}

function App() {
  return (
    <div className="App">
      <ToastContainer />

      <header className="App-header">
        <label for="medical_document">Upload a medical document:</label>

        <input type="file" id="medical_document" accept="image/*" onChange={uploadDocument} />

        <br />TODO: Make this app look better after we win the race. There's no time to waste!
      </header>
    </div>
  );
}

export default App;
