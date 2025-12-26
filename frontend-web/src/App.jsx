import './App.css';
import Navbar from './components/Navbar';
import ScrollToTop from './components/ScrollToTop';
import Footer from './pages/Footer';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import HomePage from './pages/HomePage';
import ExplorePage from './pages/ExplorePage';
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import CategoriesPage from './pages/CategoriesPage';
import TravellersPage from './pages/TravellersPage';
import TravellerProfilePage from './pages/TravellerProfilePage';
import MyProfilePage from './pages/MyProfilePage';
import EditProfilePage from './pages/EditProfilePage';
import BookmarkedPage from './pages/BookmarkedPage';
import TripDetailPage from './pages/TripDetailPage';
import MyTripReviewPage from './pages/MyTripReviewPage';
import MapsPage from './pages/MapsPage';
import { useAuth } from './context/AuthContext';
import HistoryPage from './pages/HistoryPage';
import RunTripPage from './pages/RunTripPage';

const trips = [
    {
      id: 1,
      title: "Culture Trip",
      author: "Horas B.",
      rating: 5,
      image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0b/72/08/fc/bali-tour-culture-travel.jpg?w=1200&h=-1&s=1",
      description: "7 days exploring the island with my friends and we had the time of our lives. We started our adventure in Ubud, where we stayed at the beautiful Villa 'Serenity Oasis' and spent our days exploring the rice fields, temples, and local markets.",
      tags: ["Adventure", "Culture", "Nature"],
      route: [
          { title: "Yoga Session", activity: "Riding, Eating at someplace", location: "Bedugul Yoga Centre", image: "https://organium.id/wp-content/uploads/2024/10/Radiantly-Alive-Yoga-Studio-Ubud-Bali-1_11zon.webp" },
          { title: "Besakih Temple", activity: "Praying and Sightseeing", location: "Besakih, Karangasem", image: "https://kabardewata.com/uploads/image/web/pura-lempuyang.jpg" },
          { title: "Morning Walk", activity: "Walking, Staying at some Villa", location: "Watumujur Walk", image: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
    {
      id: 2, title: "Culture Trip", author: "Thomas A.", rating: 4, image: "https://saritabalitour.com/wp-content/uploads/elementor/thumbs/ismail-hamzah-2mCc2JV6oeQ-unsplash-qw9cvi8pcrwz5z3mvxglx7fstziupjvmufnzpcztkg.jpg",
      description: "Experience the authentic Balinese culture with visits to ancient temples and traditional villages. A perfect trip for history lovers.",
      tags: ["History", "Culture", "Temple"],
      route: [
          { title: "Besakih Temple", activity: "Praying and Sightseeing", location: "Besakih, Karangasem", image: "https://kabardewata.com/uploads/image/web/pura-lempuyang.jpg" },
          { title: "Penglipuran Village", activity: "Cultural Tour", location: "Bangli Regency", image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
    { id: 3, title: "Forest Trip", author: "Thomas A.", rating: 5, image: "https://balipalms.com/wp-content/uploads/2021/07/bali-jungle-villa_nearby-attractions-waterfall.jpg", description: "A refreshing journey through the lush forests of Bali. Visit hidden waterfalls and enjoy the sound of nature away from the city noise.", tags: ["Nature", "Jungle", "Waterfall"],
      route: [
          { title: "Hidden Waterfall", activity: "Swimming & Trekking", location: "Gitgit Waterfall", image: "https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?q=80&w=1000&auto=format&fit=crop" },
          { title: "Monkey Forest", activity: "Walking & Feeding", location: "Ubud Monkey Forest", image: "https://images.unsplash.com/photo-1544644181-1484b3fdfc62?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
    { id: 4,  title: "City Night", author: "Sarah C.", rating: 5, image: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=2000&auto=format&fit=crop", description: "Discover the vibrant nightlife of the city. From night markets to rooftop bars, experience the city lights like never before.", tags: ["Nightlife", "City", "Party"],
      route: [
          { title: "Night Market", activity: "Street Food Hunting", location: "Gianyar Night Market", image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1000&auto=format&fit=crop" },
          { title: "Rooftop Lounge", activity: "Dinner & Music", location: "Seminyak Area", image: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
    { id: 5, title: "Bali Temple", author: "Made W.", rating: 4, image: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000&auto=format&fit=crop", description: "A spiritual journey visiting the most iconic temples in Bali. Find peace and serenity in these sacred places.", tags: ["Spiritual", "Temple", "Peace"],
      route: [
          { title: "Ulun Danu Beratan", activity: "Sightseeing", location: "Bedugul", image: "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=1000&auto=format&fit=crop" },
          { title: "Tanah Lot", activity: "Sunset View", location: "Tabanan", image: "https://images.unsplash.com/photo-1604825966373-b26a57007722?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
    { id: 6, title: "Mountain View", author: "John D.", rating: 5, image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop", description: "Hiking adventure to the top of the mountain. Witness the breathtaking sunrise above the clouds.", tags: ["Hiking", "Mountain", "Sunrise"],
      route: [
          { title: "Mount Batur", activity: "Sunrise Trekking", location: "Kintamani", image: "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?q=80&w=1000&auto=format&fit=crop" },
          { title: "Hot Spring", activity: "Relaxing", location: "Toya Devasya", image: "https://images.unsplash.com/photo-1572331165267-854da2b00dc3?q=80&w=1000&auto=format&fit=crop" }
      ]
    },
];
const categories = [ { id: 1, title: "Fields", image: "https://www.shutterstock.com/image-photo/beautiful-morning-view-indonesia-panorama-600nw-2657185455.jpg" }, { id: 2, title: "Beach", image: "https://static.independent.co.uk/s3fs-public/thumbnails/image/2019/07/02/15/kelingking-beach.jpg" }, { id: 3, title: "Mini Resto", image: "https://awsimages.detik.net.id/community/media/visual/2020/05/23/d9f3bf54-53ef-4d8e-88ec-cbe7d8931b22.jpeg?w=1024" }, { id: 4, title: "Store's", image: "https://balidirectstore.com/wp-content/uploads/2024/09/canggublog.jpeg" },];
const travellers = [ { id: 1, name: "Jackson", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop" }, { id: 2, name: "Sally", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop" }, { id: 3, name: "Freddy", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop" }, { id: 4, name: "Bob", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop" }, { id: 5, name: "Clara", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop" },];
const allCategories = [ { id: 1, title: "Waterfall", image: "https://sita.badungkab.go.id/images/post/air-terjun-nungnung-66c4302ac7678.webp" }, { id: 2, title: "Beaches", image: "https://www.water-sport-bali.com/wp-content/uploads/2024/05/Keindahan-Pantai-Nusa-Penida-Bali.webp" }, { id: 3, title: "Temple's & Shrine's", image: "https://kabardewata.com/uploads/image/web/pura-lempuyang.jpg" }, { id: 4, title: "Mountain & Hills", image: "https://ik.imagekit.io/tvlk/blog/2020/02/shutterstock_720312688gunungagung.jpg?tr=q-70,c-at_max,w-1000,h-600" }, { id: 5, title: "Villa's", image: "https://pramanaexperience.com/wp-content/uploads/2025/01/master.jpg" }, { id: 6, title: "Hidden Cafe", image: "https://cnc-magazine.oramiland.com/parenting/images/Wyah_Art__Creative_Space.width-800.format-webp.webp" },];
const recommendationData = [ { id: 1, name: "Jackson", role: "Traveller", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop", rank: "Traveler", followers: 120, reviews: 15, totalRoutes: 3 }, { id: 2, name: "Bob", role: "Map Maker", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop", rank: "Map Maker", followers: 240, reviews: 100, totalRoutes: 28 }, { id: 3, name: "Clara", role: "Backpacker's", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop", rank: "Backpacker's", followers: 60, reviews: 5, totalRoutes: 2 }, { id: 4, name: "Freddy", role: "Traveller", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop", rank: "Traveler", followers: 87, reviews: 48, totalRoutes: 13 }, { id: 5, name: "Michael", role: "Explorer", image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop", rank: "Explorer", followers: 40, reviews: 4, totalRoutes: 1 }, { id: 6, name: "Freddy", role: "Map Maker", image: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1000&auto=format&fit=crop", rank: "Map Maker", followers: 20, reviews: 8, totalRoutes: 1 },];

const userdummy = { name: "ELALALANG", rank: "Adventurer", rankLevel: 1, image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop", birthDate: "2000-12-20", description: "Adventure, Food, Health, Bike", status: "Family (0) Child", stats: { travelScore: { xp: 60, title: "Adventurer", level: 1 }, routeScore: { xp: 60, title: "Basic Planner", level: 1 } } };
const myReviews = [ { id: 1, title: "Waterfall Trip", description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...", location: "Bedugul - Gianyar.", rating: 5, image: "https://balipalms.com/wp-content/uploads/2021/07/bali-jungle-villa_nearby-attractions-waterfall.jpg" }, { id: 2, title: "Mountain Trip", description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...", location: "Bedugul - Gianyar.", rating: 5, image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop" }, { id: 3, title: "Culture Trip", description: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...", location: "Bedugul - Gianyar.", rating: 5, image: "https://saritabalitour.com/wp-content/uploads/elementor/thumbs/ismail-hamzah-2mCc2JV6oeQ-unsplash-qw9cvi8pcrwz5z3mvxglx7fstziupjvmufnzpcztkg.jpg" }];
const othersReviews = [ { id: 1, name: "Jackson", role: "Traveller", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "The Scenery is cute, the place is comfy, the people are very friendly. I came here with my family, and we feel very nice being here." }, { id: 2, name: "Sarah M.", role: "Vlogger", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop", rating: 4, text: "Amazing hidden gem! The route was easy to follow and the view at the top was breathtaking. Definitely recommend for beginners." }, { id: 3, name: "David K.", role: "Hiker", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "One of the best trekking experiences I've had in Bali. The local guide was very helpful and the sunset was unforgettable." }, { id: 4, name: "Emily Rose", role: "Photographer", image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "Every corner of this place is so photogenic! Great lighting during the golden hour. A must-visit for content creators." }, { id: 5, name: "Michael T.", role: "Foodie", image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop", rating: 4, text: "The trip was fun, but the best part was the local food stall nearby. Authentic taste and very cheap prices!" },];
const bookmarkedData = [ { id: 1, title: "Serenity Oasis", category: "Restaurant", location: "Bedugul - Gianyar.", image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop" }, { id: 2, title: "Dirty Diana", category: "Restaurant", location: "Bedugul - Gianyar.", image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop" }, { id: 3, title: "Bali Swing", category: "Adventure", location: "Ubud - Bali.", image: "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?q=80&w=1000&auto=format&fit=crop" },];
const sliderImages = [ "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop", "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop", "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?q=80&w=1000&auto=format&fit=crop",];
const myreviewstrips = [ { id: 1, name: "Sarah C.", image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "The Scenery is cute, the place is comfy, the people are very friendly, i came here with my family, and we feel very nice being here.", moreImages: [ "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0b/72/08/fc/bali-tour-culture-travel.jpg?w=1200&h=-1&s=1", "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200&auto=format&fit=crop", ] }, { id: 2, name: "Jaenap S.", image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "The Scenery is cute, the place is comfy, the people are very friendly, i came here with my family, and we feel very nice being here.", moreImages: [ "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=200&auto=format&fit=crop", "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=200&auto=format&fit=crop", "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=200&auto=format&fit=crop", ] }, { id: 3, name: "Munaroh T.", image: "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?q=80&w=1000&auto=format&fit=crop", rating: 5, text: "The Scenery is cute, the place is comfy, the people are very friendly, i came here with my family, and we feel very nice being here.", moreImages: [ "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200&auto=format&fit=crop", "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200&auto=format&fit=crop", ] },];

//historyData
export const activeTrips = [
    { id: 1, title: "The Getaway", description: "My own schedule trip to get to somewhere full with guidance...", location: "Bedugul - Gianyar", image: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=300&q=80" },
    { id: 2, title: "Ubud Monkey Forest", description: "Visiting the sacred monkey forest sanctuary and exploring...", location: "Ubud - Gianyar", image: "https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=300&q=80" }
];
export const favouriteTrips = [
    { id: 3, title: "Kintamani Sunrise", description: "Hiking mount Batur to see the beautiful sunrise with...", location: "Kintamani - Bangli", image: "https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?auto=format&fit=crop&w=300&q=80" }
];
export const pastTrips = [
    { id: 4, title: "Tanah Lot Sunset", description: "Beautiful sunset view at the temple by the sea.", location: "Tabanan", image: "https://images.unsplash.com/photo-1539367628448-4bc5c9d171c8?auto=format&fit=crop&w=300&q=80" },
    { id: 5, title: "Ulun Danu Beratan", description: "A calm lake temple visit with cold atmosphere.", location: "Bedugul - Tabanan", image: "https://images.unsplash.com/photo-1555400038-63f5ba517a47?auto=format&fit=crop&w=300&q=80" },
    { id: 6, title: "GwK Cultural Park", description: "Seeing the gigantic statue and traditional dance performance.", location: "Jimbaran - Badung", image: "https://images.unsplash.com/photo-1576675784201-0e142b423952?auto=format&fit=crop&w=300&q=80" }
];

const MainLayout = () => {
  return (
    <div className='w-full h-dvh'>
      <Navbar />
      <ScrollToTop />
      <main>
        <Outlet />
      </main>
      <Footer />
    </div>
  );
};

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
};

const PublicRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (isAuthenticated) {
    return <Navigate to="/homepage" replace />;
  }

  return children;
};


function App() {
  return (
    <Routes>
      {/* Public routes only accessible when not logged in */}
      <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
      <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />

      {/* Protected routes only accessible when logged in */}
      <Route 
        path="/" 
        element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Navigate to="/homepage" replace />} />
        <Route path='homepage' element={<HomePage categories={categories} travellers={travellers}/>} />
        <Route path='explore' element={<ExplorePage trips={trips}/>} />
        <Route path='categories' element={<CategoriesPage allCategories={allCategories}/>} />
        <Route path='travellers' element={<TravellersPage recommendationData={recommendationData} />} />
        <Route path='profile/:id' element={<TravellerProfilePage recommendationData={recommendationData} />} />
        <Route path='myprofile' element={<MyProfilePage userdummy={userdummy} trips={trips} myReviews={myReviews} othersReviews={othersReviews}/>} />
        <Route path='editprofile' element={<EditProfilePage user={userdummy}/>} />
        <Route path='bookmarked' element={<BookmarkedPage bookmarkedData={bookmarkedData}/>} />
        <Route path='trip/:id' element={<TripDetailPage trips={trips}/>} />
        <Route path='mytripreview/:id' element={<MyTripReviewPage sliderImages={sliderImages} myreviewstrips={myreviewstrips}/>} />
        <Route path='maps' element={<MapsPage />} />
        <Route path='runtrip/:id' element={<RunTripPage />} />
        <Route path='history' element={<HistoryPage activeTrips={activeTrips} favouriteTrips={favouriteTrips} pastTrips={pastTrips} />} />
      </Route>

      {/* Fallback route */}
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  );
}

export default App;
