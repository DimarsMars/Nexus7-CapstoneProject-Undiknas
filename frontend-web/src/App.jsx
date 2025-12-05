import './App.css'
import Navbar from './components/Navbar'
import Footer from './pages/Footer'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import HomePage from './pages/HomePage'
import { Routes, Route } from 'react-router-dom'

// Data dummy untuk TripCard
const trips = [
    {
      id: 1,
      title: "Culture Trip",
      author: "Horas B.",
      rating: 4,
      image: "https://lp-cms-production.imgix.net/2024-08/shutterstockRF787893667.jpg?auto=format,compress&q=72&w=1440&h=810&fit=crop", // Gambar Street/Building
      layout: "big",
    },
    {
      id: 2,
      title: "Culture Trip",
      author: "Thomas A.",
      rating: 5,
      image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/79/5a/66/caption.jpg?w=1200&h=-1&s=1", // Gambar Sign/Store
      layout: "small",
    },
    {
      id: 3,
      title: "Forest Trip",
      author: "Thomas A.",
      rating: 5,
      image: "https://imageio.forbes.com/specials-images/imageserve//62bdd4a21a6dc599d18bca9b/0x0.jpg?format=jpg&height=900&width=1600&fit=bounds", // Gambar Hutan
      layout: "small",
    },
  ];

function App() {

  return (
      <div className='w-full h-dvh'>
        <Navbar/>

        <Routes>
          <Route path='/login' element={<LoginPage />} />
          <Route path='/register' element={<RegisterPage />} />

          <Route path='/homepage' element={<HomePage trips={trips}/>} />

        </Routes>

        <Footer />
      </div>
  )
}

export default App
