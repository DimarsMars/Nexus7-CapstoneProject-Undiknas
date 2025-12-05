import './App.css'
import Navbar from './components/Navbar'
import Footer from './pages/Footer'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import HomePage from './pages/HomePage'
import ExplorePage from './pages/ExplorePage'
import { Routes, Route } from 'react-router-dom'

// Data dummy untuk TripCard
const trips = [
    {
      id: 1,
      title: "Culture Trip",
      author: "Horas B.",
      rating: 5,
      image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0b/72/08/fc/bali-tour-culture-travel.jpg?w=1200&h=-1&s=1",
    },
    {
      id: 2,
      title: "Culture Trip",
      author: "Thomas A.",
      rating: 4,
      image: "https://saritabalitour.com/wp-content/uploads/elementor/thumbs/ismail-hamzah-2mCc2JV6oeQ-unsplash-qw9cvi8pcrwz5z3mvxglx7fstziupjvmufnzpcztkg.jpg",
    },
    {
      id: 3,
      title: "Forest Trip",
      author: "Thomas A.",
      rating: 5,
      image: "https://balipalms.com/wp-content/uploads/2021/07/bali-jungle-villa_nearby-attractions-waterfall.jpg",
    },
    { id: 4, title: "City Night", author: "Sarah C.", rating: 5, image: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=2000&auto=format&fit=crop" },
    { id: 5, title: "Bali Temple", author: "Made W.", rating: 4, image: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000&auto=format&fit=crop" },
    { id: 6, title: "Mountain View", author: "John D.", rating: 5, image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop" },
  ];

const categories = [
    { id: 1, title: "Fields", image: "https://www.shutterstock.com/image-photo/beautiful-morning-view-indonesia-panorama-600nw-2657185455.jpg" },
    { id: 2, title: "Beach", image: "https://static.independent.co.uk/s3fs-public/thumbnails/image/2019/07/02/15/kelingking-beach.jpg" },
    { id: 3, title: "Mini Resto", image: "https://awsimages.detik.net.id/community/media/visual/2020/05/23/d9f3bf54-53ef-4d8e-88ec-cbe7d8931b22.jpeg?w=1024" },
    { id: 4, title: "Store's", image: "https://balidirectstore.com/wp-content/uploads/2024/09/canggublog.jpeg" },
];

const travellers = [
    { id: 1, name: "Jackson", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop" },
    { id: 2, name: "Sally", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop" },
    { id: 3, name: "Freddy", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop" },
    { id: 4, name: "Bob", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop" },
    { id: 5, name: "Clara", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop" },
];

const exploreTrips = [
  { id: 1, title: "Grand Culture Trip", author: "Horas B.", rating: 4, image: "https://images.unsplash.com/photo-1517260739337-6799d2ff04fe?q=80&w=2000&auto=format&fit=crop" },
  { id: 2, title: "Old Store", author: "Thomas A.", rating: 5, image: "https://images.unsplash.com/photo-1520939817895-060bdaf4de1e?q=80&w=1000&auto=format&fit=crop" },
  { id: 3, title: "Forest Mist", author: "Thomas A.", rating: 5, image: "https://images.unsplash.com/photo-1448375240586-dfd8f3793371?q=80&w=1000&auto=format&fit=crop" },
];

function App() {

  return (
      <div className='w-full h-dvh'>
        <Navbar/>

        <Routes>
          <Route path='/login' element={<LoginPage />} />
          <Route path='/register' element={<RegisterPage />} />

          <Route path='/homepage' element={<HomePage trips={trips} categories={categories} travellers={travellers}/>} />
          <Route path='/explore' element={<ExplorePage trips={trips}/>} />

        </Routes>

        <Footer />
      </div>
  )
}

export default App
