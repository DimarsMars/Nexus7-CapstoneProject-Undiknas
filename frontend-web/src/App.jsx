import './App.css'
import Navbar from './components/Navbar'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import { Routes, Route } from 'react-router-dom'

function App() {

  return (
      <div className='w-full h-dvh'>
        {/* <Navbar/> */}

      <Routes>
        <Route path='/login' element={<LoginPage />} />
        <Route path='/register' element={<RegisterPage />} />
          

      </Routes>
      </div>
  )
}

export default App
