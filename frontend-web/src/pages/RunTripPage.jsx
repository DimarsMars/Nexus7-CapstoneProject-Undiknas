import { useState, useEffect, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';
import LocationRouteCard from '../components/LocationRouteCard';
import { FaChevronLeft } from "react-icons/fa";
import apiService from '../services/apiService';

// --- KONFIGURASI ICON MARKER ---
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

// --- PATCH UNTUK LEAFLET ROUTING MACHINE ---
try {
  // 1. PATCH CLEANUP (Mencegah error 'removeLayer')
  const originalClearLines = L.Routing.Control.prototype._clearLines;
  L.Routing.Control.prototype._clearLines = function() {
    try {
      originalClearLines.call(this);
    } catch (e) {
      // Diamkan error jika gagal hapus garis
    }
  };

  // 2. PATCH DRAWING (Mencegah error 'addLayer')
  const originalRouteDone = L.Routing.Control.prototype._routeDone;
  L.Routing.Control.prototype._routeDone = function(response, inputWaypoints, options) {
    if (!this._map) {
        return; 
    }

    try {
      originalRouteDone.call(this, response, inputWaypoints, options);
    } catch (e) {
    }
  };

} catch (e) {
  console.error("Gagal menerapkan patch pada Leaflet Routing Machine");
}


// --- KOMPONEN ROUTING MACHINE ---
const RoutingMachine = ({ userLocation, destination, onRouteFound }) => {
  const map = useMap();
  const routingControlRef = useRef(null);

  useEffect(() => {
    if (!map) return;

    if (routingControlRef.current) {
        try { map.removeControl(routingControlRef.current); } catch(e) {}
    }

    const control = L.Routing.control({
      waypoints: [
        L.latLng(userLocation.lat, userLocation.lng),
        L.latLng(destination.lat, destination.lng)
      ],
      routeWhileDragging: false,
      show: false,
      addWaypoints: false,
      draggableWaypoints: false,
      fitSelectedRoutes: true,
      lineOptions: {
        styles: [{ color: '#6366f1', opacity: 0.8, weight: 6 }]
      },
      createMarker: () => null,
      router: L.Routing.osrmv1({
         serviceUrl: 'https://router.project-osrm.org/route/v1'
      })
    });

    control.on('routingerror', function(e) {
       // Suppress routing errors
    });

    control.addTo(map);
    routingControlRef.current = control;

    const handleRoutesFound = (e) => {
        const summary = e.routes[0].summary;
        if (onRouteFound) {
            setTimeout(() => {
                onRouteFound({
                    distance: (summary.totalDistance / 1000).toFixed(1) + ' km',
                    time: Math.round(summary.totalTime / 60) + ' min'
                });
            }, 0);
        }
    };

    control.on('routesfound', handleRoutesFound);

    return () => {
        if (map && routingControlRef.current) {
            try {
                map.removeControl(routingControlRef.current);
            } catch (error) {}
            routingControlRef.current = null;
        }
    };
  }, [map, userLocation.lat, userLocation.lng, destination.lat, destination.lng]);

  return null;
};

// --- KOMPONEN UTAMA ---
const RunTripPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  // 1. STATE DATA TRIP & BOOKMARKS
  const [tripRoute, setTripRoute] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [bookmarks, setBookmarks] = useState(new Map()); 
  const [isBookmarking, setIsBookmarking] = useState(false);
  
  // State baru untuk loading tombol Verify
  const [isVerifying, setIsVerifying] = useState(false);

  // Fetch plan and bookmarks in parallel
  useEffect(() => {
    const fetchInitialData = async () => {
        try {
            setIsLoading(true);
            const [planRes, bookmarksRes] = await Promise.all([
                apiService.getPlanForRunTrip(id),
                apiService.getBookmarkRoute()
            ]);

            if (planRes.data && planRes.data.routes) {
              const formattedRoutes = planRes.data.routes.map(route => ({
                  id: route.route_id,
                  title: route.title,
                  category: route.description,
                  lat: route.latitude,
                  lng: route.longitude,
                  image: route.image ? `data:image/jpeg;base64,${route.image}` : "https://via.placeholder.com/150",
                  address: route.address,
              }));
              setTripRoute(formattedRoutes);
            }

            if (bookmarksRes.data) {
                const bookmarkList = Array.isArray(bookmarksRes.data) ? bookmarksRes.data : (bookmarksRes.data.data || []);
                const bookmarkMap = new Map();
                bookmarkList.forEach(item => {
                    bookmarkMap.set(item.route_id, item.bookmark_id);
                });
                setBookmarks(bookmarkMap);
            }
        } catch (err) {
            setError("Failed to fetch trip data.");
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    if (id) {
        fetchInitialData();
    }
  }, [id]);

  // 2. STATE UNTUK NAVIGASI
  const [currentStepIndex, setCurrentStepIndex] = useState(0); 
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

    const watchId = navigator.geolocation.watchPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setUserLocation({ lat: latitude, lng: longitude });
      },
      (error) => {
        console.error("Error getting location:", error);
        // Lokasi default (Denpasar) jika error agar tidak crash
        setUserLocation({ lat: -8.6500, lng: 115.2167 });
      },
      { enableHighAccuracy: true }
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  // 4. HANDLER TOMBOL (UPDATED: VERIFIKASI LOKASI)
  const handleArrived = async () => {
    // Cek apakah lokasi GPS tersedia
    if (!userLocation) {
        alert("Menunggu sinyal GPS...");
        return;
    }

    setIsVerifying(true);

    try {
        const stepOrder = currentStepIndex + 1;

        const payload = {
            latitude: userLocation.lat,
            longitude: userLocation.lng,
            step_order: stepOrder
        };

        // Panggil Endpoint Verify
        const response = await apiService.postPlanVerifyLocation(id, payload);

        // Cek response body
        // Skenario 1: Backend mengembalikan status 200 OK tapi dengan pesan error (Soft Error)
        if (response.data && response.data.error) {
             const jarak = response.data.distance_km ? `${response.data.distance_km.toFixed(2)} km` : '-';
             alert(`${response.data.error}\nJarak Anda: ${jarak}`);
             // Jangan update step index karena belum sampai
        } 
        // Skenario 2: Berhasil
        else {
             alert(`Berhasil sampai di ${currentDestination.title}! Melanjutkan ke tujuan berikutnya...`);
             
             // Pindah ke step berikutnya
             if (currentStepIndex < tripRoute.length - 1) {
                setCurrentStepIndex(prev => prev + 1);
             } else {
                alert("Selamat! Anda telah menyelesaikan seluruh perjalanan!");
                navigate('/myprofile');
             }
        }

    } catch (error) {
        // Skenario 3: Backend mengembalikan status 400/500 (Hard Error)
        console.error("Verifikasi Gagal:", error);
        
        const errorData = error.response?.data;
        const errorMessage = errorData?.error || "Gagal memverifikasi lokasi.";
        const jarak = errorData?.distance_km ? `${errorData.distance_km.toFixed(2)} km` : null;

        if (jarak) {
            alert(`${errorMessage}\nJarak Anda: ${jarak}`);
        } else {
            alert(errorMessage);
        }
    } finally {
        setIsVerifying(false);
    }
  };

  const handlePause = () => {
    setIsPaused(!isPaused);
    alert(isPaused ? "Navigation Resumed" : "Navigation Paused");
  };

  const handleBookmark = async (routeId) => {
    if (isBookmarking) return;
    setIsBookmarking(true);

    const isCurrentlyBookmarked = bookmarks.has(routeId);
    const bookmarkId = bookmarks.get(routeId);

    try {
        if (isCurrentlyBookmarked && bookmarkId) {
            await apiService.deleteBookmarkRoute(bookmarkId);
            alert("Bookmark removed successfully!");
            setBookmarks(prev => {
                const newMap = new Map(prev);
                newMap.delete(routeId);
                return newMap;
            });
        } else {
            await apiService.postBookmarkRoute(routeId);
            alert("Added to bookmarks!");
            const bookmarksRes = await apiService.getBookmarkRoute();
            if (bookmarksRes.data) {
                const bookmarkList = Array.isArray(bookmarksRes.data) ? bookmarksRes.data : (bookmarksRes.data.data || []);
                const bookmarkMap = new Map();
                bookmarkList.forEach(item => {
                    bookmarkMap.set(item.route_id, item.bookmark_id);
                });
                setBookmarks(bookmarkMap);
            }
        }
    } catch (error) {
        console.error("Failed to update bookmark status:", error);
        const errorMessage = error.response?.data?.message || error.response?.data?.error || "An error occurred.";
        alert(`Error: ${errorMessage}`);
    } finally {
        setIsBookmarking(false);
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

                <div className="h-6"></div>

                {/* === SECTION 2: ACTION BUTTONS === */}
                <div className="flex justify-center gap-4">
                    <button 
                        onClick={handleArrived}
                        disabled={isVerifying}
                        className={`flex-1 text-white py-3 rounded-lg font-bold shadow-md transition ${
                            isVerifying 
                            ? 'bg-slate-500 cursor-not-allowed' 
                            : 'bg-slate-800 hover:bg-slate-700'
                        }`}
                    >
                        {isVerifying ? "Verifying..." : "Arrived!"}
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
                                    key={loc.id}
                                    point={{
                                        name: loc.title,
                                        address: loc.address,
                                        lat: loc.lat,
                                        lng: loc.lng,
                                        description: loc.category,
                                        image: loc.image,
                                        id: loc.id
                                    }}
                                    isBookmarked={bookmarks.has(loc.id)}
                                    onBookmark={handleBookmark}
                                    index={index}
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