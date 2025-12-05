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

const categories = [
    { id: 1, title: "Fields", image: "https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000&auto=format&fit=crop" },
    { id: 2, title: "Beach", image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1000&auto=format&fit=crop" },
    { id: 3, title: "Mini Resto", image: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=1000&auto=format&fit=crop" },
    { id: 4, title: "Store's", image: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000&auto=format&fit=crop" },
];

function App() {

  return (
      <div className='w-full h-dvh'>
        <Navbar/>

        <Routes>
          <Route path='/login' element={<LoginPage />} />
          <Route path='/register' element={<RegisterPage />} />

          <Route path='/homepage' element={<HomePage trips={trips} categories={categories}/>} />

        </Routes>

        <Footer />
      </div>
  )
}

export default App
