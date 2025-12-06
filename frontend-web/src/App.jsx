import './App.css'
import Navbar from './components/Navbar'
import ScrollToTop from './components/ScrollToTop'
import Footer from './pages/Footer'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import HomePage from './pages/HomePage'
import ExplorePage from './pages/ExplorePage'
import { Routes, Route } from 'react-router-dom'
import CategoriesPage from './pages/CategoriesPage'
import TravellersPage from './pages/TravellersPage'
import TravellerProfilePage from './pages/TravellerProfilePage'
import MyProfilePage from './pages/MyProfilePage'
import EditProfilePage from './pages/EditProfilePage'

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

const allCategories = [
    { id: 1, title: "Waterfall", image: "https://sita.badungkab.go.id/images/post/air-terjun-nungnung-66c4302ac7678.webp" },
    { id: 2, title: "Beaches", image: "https://www.water-sport-bali.com/wp-content/uploads/2024/05/Keindahan-Pantai-Nusa-Penida-Bali.webp" },
    { id: 3, title: "Temple's & Shrine's", image: "https://kabardewata.com/uploads/image/web/pura-lempuyang.jpg" },
    { id: 4, title: "Mountain & Hills", image: "https://ik.imagekit.io/tvlk/blog/2020/02/shutterstock_720312688gunungagung.jpg?tr=q-70,c-at_max,w-1000,h-600" },
    { id: 5, title: "Villa's", image: "https://pramanaexperience.com/wp-content/uploads/2025/01/master.jpg" },
    { id: 6, title: "Hidden Cafe", image: "https://cnc-magazine.oramiland.com/parenting/images/Wyah_Art__Creative_Space.width-800.format-webp.webp" },
];

const recommendationData = [
    { id: 1, name: "Jackson", role: "Traveller", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop", rank: "Traveler", followers: 120, reviews: 15, totalRoutes: 3 },
    { id: 2, name: "Bob", role: "Map Maker", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop", rank: "Map Maker", followers: 240, reviews: 100, totalRoutes: 28 },
    { id: 3, name: "Clara", role: "Backpacker's", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop", rank: "Backpacker's", followers: 60, reviews: 5, totalRoutes: 2 },
    { id: 4, name: "Freddy", role: "Traveller", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop", rank: "Traveler", followers: 87, reviews: 48, totalRoutes: 13 },
    { id: 5, name: "Michael", role: "Explorer", image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop", rank: "Explorer", followers: 40, reviews: 4, totalRoutes: 1 },
    { id: 6, name: "Freddy", role: "Map Maker", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop", rank: "Map Maker", followers: 20, reviews: 8, totalRoutes: 1 },
];

const mostActiveData = [
    { id: 7, name: "Thomas", role: "Photographer", image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1000&auto=format&fit=crop" },
    { id: 8, name: "Sarah", role: "Traveller", image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000&auto=format&fit=crop" },
    { id: 9, name: "James", role: "Hiker", image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop" },
    { id: 10, name: "Lily", role: "Map Maker", image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1000&auto=format&fit=crop" },
    { id: 11, name: "David", role: "Guide", image: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop" },
    { id: 12, name: "Sophia", role: "Influencer", image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1000&auto=format&fit=crop" },
];

// Data Dummy User
const user = {
name: "ELALALANG",
    rank: "Adventurer",
    rankLevel: 1,
    image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop",
    birthDate: "2000-12-20", 
    description: "Adventure, Food, Health, Bike",
    status: "Family (0) Child",
    stats: {
        travelScore: { xp: 60, title: "Adventurer", level: 1 },
        routeScore: { xp: 60, title: "Basic Planner", level: 1 }
    }
};

const myReviews = [
  {
    id: 1,
    title: "Waterfall Trip",
    description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...",
    location: "Bedugul - Gianyar.",
    rating: 5,
    image: "https://balipalms.com/wp-content/uploads/2021/07/bali-jungle-villa_nearby-attractions-waterfall.jpg"
  },
  {
    id: 2,
    title: "Mountain Trip",
    description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...",
    location: "Bedugul - Gianyar.",
    rating: 5,
    image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop"
  },
  {
    id: 3,
    title: "Culture Trip",
    description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...",
    location: "Bedugul - Gianyar.",
    rating: 5,
    image: "https://saritabalitour.com/wp-content/uploads/elementor/thumbs/ismail-hamzah-2mCc2JV6oeQ-unsplash-qw9cvi8pcrwz5z3mvxglx7fstziupjvmufnzpcztkg.jpg"
  }
];

const othersReviews = [
  {
      id: 1,
      name: "Jackson",
      role: "Traveller",
      image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop",
      rating: 5,
      text: "The Scenery is cute, the place is comfy, the people are very friendly. I came here with my family, and we feel very nice being here."
  },
  {
      id: 2,
      name: "Sarah M.",
      role: "Vlogger",
      image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop",
      rating: 4,
      text: "Amazing hidden gem! The route was easy to follow and the view at the top was breathtaking. Definitely recommend for beginners."
  },
  {
      id: 3,
      name: "David K.",
      role: "Hiker",
      image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop",
      rating: 5,
      text: "One of the best trekking experiences I've had in Bali. The local guide was very helpful and the sunset was unforgettable."
  },
  {
      id: 4,
      name: "Emily Rose",
      role: "Photographer",
      image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1000&auto=format&fit=crop",
      rating: 5,
      text: "Every corner of this place is so photogenic! Great lighting during the golden hour. A must-visit for content creators."
  },
  {
      id: 5,
      name: "Michael T.",
      role: "Foodie",
      image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop",
      rating: 4,
      text: "The trip was fun, but the best part was the local food stall nearby. Authentic taste and very cheap prices!"
  },
];

function App() {

  return (
      <div className='w-full h-dvh'>
        <Navbar/>
        <ScrollToTop />
        <Routes>
          <Route path='/login' element={<LoginPage />} />
          <Route path='/register' element={<RegisterPage />} />

          <Route path='/homepage' element={<HomePage trips={trips} categories={categories} travellers={travellers}/>} />
          <Route path='/explore' element={<ExplorePage trips={trips}/>} />
          <Route path='/categories' element={<CategoriesPage allCategories={allCategories}/>} />
          <Route path='/travellers' element={<TravellersPage recommendationData={recommendationData} mostActiveData={mostActiveData}/>} />
          <Route path='/profile/:id' element={<TravellerProfilePage recommendationData={recommendationData} trips={trips} />} />
          <Route path='/myprofile' element={<MyProfilePage user={user} trips={trips} myReviews={myReviews} othersReviews={othersReviews}/>} />
          <Route path='/editprofile' element={<EditProfilePage user={user}/>} />

        </Routes>

        <Footer />
      </div>
  )
}

export default App
