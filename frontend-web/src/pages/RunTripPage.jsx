import { useState, useEffect, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';
import LocationRouteCard from '../components/LocationRouteCard';
import { FaMapMarkerAlt, FaRegBookmark, FaChevronLeft } from "react-icons/fa";

// --- KONFIGURASI ICON MARKER ---
// Kita butuh icon custom agar terlihat bagus
import iconMarker from 'leaflet/dist/images/marker-icon.png';
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

const DefaultIcon = L.icon({
    iconUrl: iconMarker,
    iconRetinaUrl: iconRetina,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// Icon Khusus untuk Posisi User (Titik Biru misal)
const UserIcon = L.divIcon({
    className: 'custom-user-icon',
    html: `<div style="background-color: #3b82f6; width: 15px; height: 15px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(0,0,0,0.5);"></div>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10]
});

// --- KOMPONEN ROUTING MACHINE ---
// Ini yang bertugas menggambar garis jalan
const RoutingMachine = ({ userLocation, destination, onRouteFound }) => {
  const map = useMap();
  const routingControlRef = useRef(null);

  useEffect(() => {
    if (!map || !userLocation || !destination) return;

    // Hapus routing lama jika ada perubahan
    if (routingControlRef.current) {
      map.removeControl(routingControlRef.current);
    }

    const routingControl = L.Routing.control({
      waypoints: [
        L.latLng(userLocation.lat, userLocation.lng), // Titik Awal (User)
        L.latLng(destination.lat, destination.lng)    // Titik Tujuan
      ],
      routeWhileDragging: false,
      show: false, // Sembunyikan instruksi teks bawaan Leaflet
      addWaypoints: false,
      draggableWaypoints: false,
      fitSelectedRoutes: true,
      lineOptions: {
        styles: [{ color: '#6366f1', opacity: 0.8, weight: 6 }] // Warna Ungu seperti desain
      },
      createMarker: function() { return null; } // Jangan buat marker default, kita pakai marker sendiri
    });

    // Event Listener untuk mengambil data jarak & waktu
    routingControl.on('routesfound', function(e) {
      const routes = e.routes;
      const summary = routes[0].summary; // totalDistance & totalTime
      
      // Kirim data ke parent component
      if (onRouteFound) {
        onRouteFound({
            distance: (summary.totalDistance / 1000).toFixed(1) + ' km',
            time: Math.round(summary.totalTime / 60) + ' min'
        });
      }
    });

    routingControl.addTo(map);
    routingControlRef.current = routingControl;

    return () => {
      if (map && routingControlRef.current) {
        map.removeControl(routingControlRef.current);
      }
    };
  }, [map, userLocation, destination]);

  return null;
};

import apiClient from '../services/apiClient';

// --- KOMPONEN UTAMA ---
const RunTripPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  // 1. STATE DATA TRIP
  const [tripRoute, setTripRoute] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getPlanForRunTrip = (id) => {
      return apiClient.get(`/plans/${id}/detail`);
    }

    const fetchTripData = async () => {
        try {
            setIsLoading(true);
            const response = await getPlanForRunTrip(id);
            if (response.data && response.data.routes) {
              const formattedRoutes = response.data.routes.map(route => ({
                  id: route.route_id,
                  title: route.title,
                  category: route.description, // Menggunakan deskripsi sebagai kategori sesuai kebutuhan komponen
                  lat: route.latitude,
                  lng: route.longitude,
                  image: route.image ? `data:image/jpeg;base64,${route.image}` : "https://via.placeholder.com/150",
                  address: route.address,
              }));
              setTripRoute(formattedRoutes);
            } else {
              setTripRoute([]);
            }
        } catch (err) {
            setError("Failed to fetch trip data.");
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    if (id) {
        fetchTripData();
    }
  }, [id]);

  // 2. STATE UNTUK NAVIGASI
  const [currentStepIndex, setCurrentStepIndex] = useState(0); // Sedang menuju lokasi ke-0
  const [userLocation, setUserLocation] = useState(null);
  const [routeSummary, setRouteSummary] = useState({ distance: '...', time: '...' });
  const [isPaused, setIsPaused] = useState(false);

  // Ambil lokasi tujuan saat ini berdasarkan index
  const currentDestination = tripRoute[currentStepIndex];

  // 3. DETEKSI LOKASI USER (GEOLOCATION)
  useEffect(() => {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser");
      return;
    }

    // Watch Position: Update terus menerus jika user bergerak
    const watchId = navigator.geolocation.watchPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setUserLocation({ lat: latitude, lng: longitude });
      },
      (error) => {
        console.error("Error getting location:", error);
        // Fallback location (misal Denpasar) jika GPS error/ditolak
        setUserLocation({ lat: -8.6500, lng: 115.2167 });
      },
      { enableHighAccuracy: true }
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  // 4. HANDLER TOMBOL
  const handleArrived = () => {
    if (currentStepIndex < tripRoute.length - 1) {
        alert(`Yeay! You arrived at ${currentDestination.title}. Routing to next spot...`);
        setCurrentStepIndex(prev => prev + 1);
    } else {
        alert("Congratulations! You have completed the trip!");
        navigate('/myprofile'); // Balik ke profile atau halaman selesai
    }
  };

  const handlePause = () => {
    setIsPaused(!isPaused);
    alert(isPaused ? "Navigation Resumed" : "Navigation Paused");
  };

  const handleBookmark = async (routeId) => {
    try {
      // Ganti dengan apiClient yang benar
      await apiClient.post(`/bookmarks/route/${routeId}`);
      alert("Location added to bookmarks!");
    } catch (error) {
      console.error("Error adding bookmark:", error);
      const errorMessage = error.response?.data?.message || error.response?.data?.error || "Failed to add bookmark.";
      alert(`Error: ${errorMessage}`);
    }
  };

  if (isLoading) {
    return <div className="h-screen flex items-center justify-center">Loading Trip...</div>;
  }
  
  if (error) {
    return <div className="h-screen flex items-center justify-center">{error}</div>;
  }

  if (!userLocation) {
    return <div className="h-screen flex items-center justify-center">Looking for GPS signal...</div>;
  }
  
  if (tripRoute.length === 0) {
      return (
        <div className="h-screen flex flex-col items-center justify-center">
          <p>This trip has no routes.</p>
          <button onClick={() => navigate(-1)} className="mt-4 bg-slate-800 text-white px-4 py-2 rounded-lg">
            Go Back
          </button>
      </div>
    );
  }

  // Filter lokasi berikutnya (Next Locations list)
  // Menampilkan lokasi SETELAH lokasi tujuan saat ini
  const allLocations = tripRoute;

    return (
        <div className="min-h-screen bg-gray-100 flex items-start justify-center py-10 pt-28 px-4 font-sans">
            <div className="w-full max-w-7xl flex flex-col gap-6 relative">
                
                {/* === SECTION 1: MAP & INFO CARD === */}
                <div className="relative">
                    <div className="absolute top-4 left-4 z-400">
                        <button onClick={() => navigate(-1)} className="bg-white p-2 rounded-full shadow-md text-slate-800 hover:bg-gray-50">
                            <FaChevronLeft />
                        </button>
                    </div>

                    {/* MAP CONTAINER */}
                    <div className="h-[50vh] w-full rounded-xl shadow-md overflow-hidden z-0 border border-slate-200">
                        <MapContainer 
                            center={[userLocation.lat, userLocation.lng]} 
                            zoom={13} 
                            className="h-full w-full"
                            zoomControl={false}
                        >
                            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                            
                            <Marker position={[userLocation.lat, userLocation.lng]} icon={UserIcon} />
                            
                            {currentDestination && (
                                <Marker position={[currentDestination.lat, currentDestination.lng]}>
                                    <Popup>{currentDestination.title}</Popup>
                                </Marker>
                            )}

                            {currentDestination && (
                                <RoutingMachine 
                                    userLocation={userLocation} 
                                    destination={currentDestination}
                                    onRouteFound={setRouteSummary}
                                />
                            )}
                        </MapContainer>
                    </div>

                    {/* INFO CARD (OVERLAY) */}
                    <div className="absolute bottom-1 left-0 w-full px-4 md:px-8 z-400">
                        <div className="bg-white rounded-xl shadow-lg p-5 border border-slate-100">
                            <div className="flex flex-col gap-1">
                                <p className="text-gray-500 text-sm">
                                    Current Location - <span className="font-bold text-slate-800">My Position</span>
                                </p>
                                <p className="text-gray-500 text-sm">
                                    Going to, {currentDestination?.address?.split(',')[0]} - <span className="font-bold text-slate-800">{currentDestination?.title}</span>
                                </p>
                                <p className="text-slate-400 text-sm mt-1">
                                    est - {routeSummary.distance} left ({routeSummary.time})
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Spacer agar konten bawah tidak tertutup Card yg offset -40px */}
                <div className="h-6"></div>

                {/* === SECTION 2: ACTION BUTTONS === */}
                <div className="flex justify-center gap-4">
                    <button 
                        onClick={handleArrived}
                        className="flex-1 bg-slate-800 text-white py-3 rounded-lg font-bold shadow-md hover:bg-slate-700 transition"
                    >
                        Arrived!
                    </button>
                    <button 
                        onClick={() => setIsPaused(!isPaused)}
                        className="flex-1 bg-white text-slate-800 border border-slate-200 py-3 rounded-lg font-bold shadow-sm hover:bg-gray-50 transition"
                    >
                        {isPaused ? "Resume" : "Pause"}
                    </button>
                </div>

                {/* === SECTION 3: TRIP ITINERARY === */}
                <div>
                    <h3 className="text-slate-700 font-bold mb-3">Trip Itinerary</h3>
                    <div className="flex flex-col gap-3">
                        {allLocations.length > 0 ? (
                            allLocations.map((loc, index) => (
                                <LocationRouteCard
                                    key={loc.id} // Use loc.id for the key
                                    point={{
                                        name: loc.title,
                                        address: loc.address,
                                        lat: loc.lat,
                                        lng: loc.lng,
                                        description: loc.category, // Using category as description
                                        image: loc.image,
                                        id: loc.id // Pass the id as well, to be used for bookmarking
                                    }}
                                    index={index}
                                    onBookmark={handleBookmark} // Pass the new bookmark handler
                                />
                            ))
                        ) : (
                            <div className="p-8 text-center text-gray-400 bg-white rounded-lg border border-dashed border-gray-300">
                                This trip has no locations.
                            </div>
                        )}
                    </div>
                </div>

            </div>
        </div>
    );
};

export default RunTripPage;