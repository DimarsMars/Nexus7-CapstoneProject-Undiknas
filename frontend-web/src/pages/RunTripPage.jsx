import L from 'leaflet';
import 'leaflet-routing-machine';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';
import 'leaflet/dist/leaflet.css';
import { useCallback, useEffect, useRef, useState } from 'react';
import { FaChevronLeft } from "react-icons/fa";
import { MapContainer, Marker, Popup, TileLayer, useMap } from 'react-leaflet';
import { useNavigate, useParams } from 'react-router-dom';
import LocationRouteCard from '../components/LocationRouteCard';
import apiService from '../services/apiService';
import Swal from 'sweetalert2'; // Import SweetAlert untuk notifikasi

// --- LEAFLET ICON CONFIGURATION ---
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png';
import iconMarker from 'leaflet/dist/images/marker-icon.png';
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

const UserIcon = L.divIcon({
    className: 'custom-user-icon',
    html: `<div style="background-color: #3b82f6; width: 15px; height: 15px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(0,0,0,0.5);"></div>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10]
});

// --- LEAFLET ROUTING MACHINE PATCH ---
// This patch prevents errors that can occur during hot-reloads or component re-renders in React.
try {
  const originalClearLines = L.Routing.Control.prototype._clearLines;
  L.Routing.Control.prototype._clearLines = function() {
    if (this._map) { // Check if map exists
      try {
        originalClearLines.call(this);
      } catch (e) {
        // Suppress 'removeLayer' errors if the layer is already gone
      }
    }
  };

  const originalRouteDone = L.Routing.Control.prototype._routeDone;
  L.Routing.Control.prototype._routeDone = function(response, inputWaypoints, options) {
    if (!this._map) { // Check if map exists before drawing
        return; 
    }
    try {
      originalRouteDone.call(this, response, inputWaypoints, options);
    } catch (e) {
        // Suppress 'addLayer' errors
    }
  };
} catch (e) {
  console.error("Failed to apply patch to Leaflet Routing Machine:", e);
}

// --- ROUTING MACHINE COMPONENT ---
const RoutingMachine = ({ userLocation, destination, onRouteFound }) => {
  const map = useMap();
  const routingControlRef = useRef(null);

  useEffect(() => {
    if (!map || !userLocation || !destination) return;

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
    })
    .on('routingerror', (e) => { /* Suppress routing errors */ })
    .on('routesfound', (e) => {
        if (e.routes && e.routes[0]) {
            const summary = e.routes[0].summary;
            // Use setTimeout to ensure the state update doesn't conflict with the render cycle.
            setTimeout(() => {
                onRouteFound({
                    distance: (summary.totalDistance / 1000).toFixed(1) + ' km',
                    time: Math.round(summary.totalTime / 60) + ' min'
                });
            }, 0);
        }
    })
    .addTo(map);

    routingControlRef.current = control;

    return () => {
        if (map && routingControlRef.current) {
            try { map.removeControl(routingControlRef.current); } catch (error) {}
        }
    };
  }, [map, userLocation, destination, onRouteFound]);

  return null;
};

// --- MAIN PAGE COMPONENT ---
const RunTripPage = () => {
  // 1. HOOKS
  const navigate = useNavigate();
  const { id } = useParams();

  // 2. STATE MANAGEMENT
  const [tripRoute, setTripRoute] = useState([]);
  const [bookmarks, setBookmarks] = useState(new Map());
  const [tripSession, setTripSession] = useState(null);
  const [userLocation, setUserLocation] = useState(null);
  const [routeSummary, setRouteSummary] = useState({ distance: '...', time: '...' });
  
  // UI/Loading States
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isVerifying, setIsVerifying] = useState(false);
  const [isBookmarking, setIsBookmarking] = useState(false);

  // 3. DERIVED STATE
  const currentDestination = tripRoute[0];
  const allLocations = tripRoute;

  // 4. DATA FETCHING & GEOLOCATION
  useEffect(() => {
    const fetchInitialData = async () => {
        if (!id) return;

        try {
            setIsLoading(true);
            const [planRes, bookmarksRes, activeTripsRes] = await Promise.all([
                apiService.getPlanForRunTrip(id),
                apiService.getBookmarkRoute(),
                apiService.getActiveTrip()
            ]);

            // Process plan data
            if (planRes.data?.routes) {
                const completedSteps = planRes.data.completed_steps || [];
                const formattedRoutes = planRes.data.routes
                    .filter(route => !completedSteps.includes(route.step_order))
                    .map(route => ({
                        id: route.route_id,
                        title: route.title,
                        category: route.description,
                        lat: route.latitude,
                        lng: route.longitude,
                        image: route.image ? `data:image/jpeg;base64,${route.image}` : "https://via.placeholder.com/150",
                        address: route.address,
                        step_order: route.step_order,
                    }));
                setTripRoute(formattedRoutes);
            }

            // Process bookmarks data
            if (bookmarksRes.data) {
                const bookmarkList = Array.isArray(bookmarksRes.data) ? bookmarksRes.data : (bookmarksRes.data.data || []);
                const bookmarkMap = new Map();
                bookmarkList.forEach(item => bookmarkMap.set(item.route_id, item.bookmark_id));
                setBookmarks(bookmarkMap);
            }

            // Process active trip session
            if (activeTripsRes.data) {
                const session = activeTripsRes.data.find(s => s.Plan?.plan_id === parseInt(id));
                setTripSession(session || null);
            }
        } catch (err) {
            setError("Failed to fetch trip data.");
            console.error("Initial data fetch error:", err);
        } finally {
            setIsLoading(false);
        }
    };
    fetchInitialData();
  }, [id]);

  useEffect(() => {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser.");
      return;
    }

    const watchId = navigator.geolocation.watchPosition(
      (position) => {
        setUserLocation({ lat: position.coords.latitude, lng: position.coords.longitude });
      },
      (error) => {
        console.error("Error getting location:", error);
        setUserLocation({ lat: -8.6500, lng: 115.2167 }); // Default to Denpasar on error
      },
      { enableHighAccuracy: true }
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  // 5. EVENT HANDLERS
  const handleArrived = useCallback(async () => {
    if (!userLocation || !currentDestination) {
        alert("Waiting for GPS signal or destination data...");
        return;
    }

    setIsVerifying(true);
    try {
        const payload = {
            latitude: userLocation.lat,
            longitude: userLocation.lng,
            step_order: currentDestination.step_order,
        };
        const response = await apiService.postPlanVerifyLocation(id, payload);

        if (response.data?.error) {
            const distance = response.data.distance_km ? `${response.data.distance_km.toFixed(2)} km` : "-";
            alert(`${response.data.error}\nYour distance: ${distance}`);
            return;
        }
        // Success notification
        await Swal.fire({
            title: 'Selamat! Anda Sampai',
            text: `Anda telah berhasil tiba di ${currentDestination.title}!`,
            icon: 'success',
            confirmButtonColor: '#1e293b',
        });

        const updatedRoutes = tripRoute.filter(r => r.step_order !== currentDestination.step_order);

        if (updatedRoutes.length === 0) {
            await Swal.fire({
                title: '🎉 Selamat!',
                text: `Anda telah berhasil menyelesaikan trip!`,
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
            navigate("/myprofile");
        } else {
            setTripRoute(updatedRoutes);
            const nextRoute = updatedRoutes[0];
            
            // Start the session for the next route
            const res = await apiService.postTripSessionAction(id, { action: "start", route_id: nextRoute.id });
            setTripSession(res.data?.data || { route_id: nextRoute.id, status: "ongoing" });
            await Swal.fire({
                title: 'Trip Selanjutnya!',
                text: `Perjalanan ke ${nextRoute.title} telah dimulai. Ikuti peta untuk mencapai tujuan!`,
                icon: 'info',
                confirmButtonColor: '#1e293b',
            });
        }
    } catch (error) {
        const msg = error.response?.data?.error || "Failed to verify location.";
        alert(msg);
    } finally {
        setIsVerifying(false);
    }
  }, [id, userLocation, currentDestination, tripRoute, navigate]);

  const handlePause = useCallback(async () => {
    if (!currentDestination) return;

    try {
        const isSessionForCurrentRoute = tripSession?.route_id === currentDestination.id;
        
        // If no active session for this specific route, start one.
        if (!tripSession || !isSessionForCurrentRoute) {
            const res = await apiService.postTripSessionAction(id, { action: "start", route_id: currentDestination.id });
            setTripSession(res.data?.data);
            Swal.fire({
                title: 'Perjalanan Dimulai!',
                text: 'Semoga perjalanan Anda menyenangkan. Peta navigasi kini telah aktif!',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
            return;
        }

        // Otherwise, toggle pause/resume.
        const isPaused = tripSession.status === "paused";
        const action = isPaused ? "resume" : "pause";
        await apiService.postTripSessionAction(id, { action, route_id: currentDestination.id });

        setTripSession(prev => ({ ...prev, status: isPaused ? "ongoing" : "paused" }));
        Swal.fire({
            title: isPaused ? 'Navigasi Dilanjutkan' : 'Navigasi Dijeda',
            text: isPaused 
                ? 'Sesi perjalanan Anda telah aktif kembali. Silakan lanjutkan mengikuti rute.' 
                : 'Sesi perjalanan Anda dihentikan sementara. Pelacakan waktu dan rute dijeda.',
            icon: isPaused ? 'info' : 'warning',
            confirmButtonColor: '#1e293b',
        });
    } catch (error) {
        console.error("Trip session action error:", error);
        alert("Failed to perform trip action.");
    }
  }, [id, currentDestination, tripSession]);

  const handleBookmark = useCallback(async (routeId) => {
    if (isBookmarking) return;
    setIsBookmarking(true);

    const isCurrentlyBookmarked = bookmarks.has(routeId);
    const bookmarkId = bookmarks.get(routeId);

    try {
        if (isCurrentlyBookmarked && bookmarkId) {
            await apiService.deleteBookmarkRoute(bookmarkId);
            Swal.fire({
                title: 'Berhasil',
                text: 'Bookmark Berhasil Dihapus!',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
            setBookmarks(prev => {
                const newMap = new Map(prev);
                newMap.delete(routeId);
                return newMap;
            });
        } else {
            const res = await apiService.postBookmarkRoute(routeId);
            Swal.fire({
                title: 'Berhasil',
                text: 'Berhasil Ditambahkan ke Bookmark!',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
            // Refetch is safer to get the new bookmark_id
            const bookmarksRes = await apiService.getBookmarkRoute();
            if (bookmarksRes.data) {
                const bookmarkList = Array.isArray(bookmarksRes.data) ? bookmarksRes.data : (bookmarksRes.data.data || []);
                const newMap = new Map();
                bookmarkList.forEach(item => newMap.set(item.route_id, item.bookmark_id));
                setBookmarks(newMap);
            }
        }
    } catch (error) {
        console.error("Failed to update bookmark status:", error);
        const errorMessage = error.response?.data?.message || error.response?.data?.error || "An error occurred.";
        alert(`Error: ${errorMessage}`);
    } finally {
        setIsBookmarking(false);
    }
  }, [isBookmarking, bookmarks]);

  // 6. RENDER LOGIC
  if (isLoading) {
    return <div className="h-screen flex items-center justify-center">Loading Trip...</div>;
  }
  
  if (error) {
    return <div className="h-screen flex items-center justify-center">{error}</div>;
  }

  if (!userLocation) {
    return <div className="h-screen flex items-center justify-center">Looking for GPS signal...</div>;
  }
  
  if (tripRoute.length === 0 && !isLoading) { // Check isLoading to prevent flash of this screen
      return (
        <div className="h-screen flex flex-col items-center justify-center">
          <p>This trip has no routes remaining or has ended.</p>
          <button onClick={() => navigate(-1)} className="mt-4 bg-slate-800 text-white px-4 py-2 rounded-lg">
            Go Back
          </button>
      </div>
    );
  }

  return (
        <div className="min-h-screen bg-gray-100 flex items-start justify-center py-10 pt-28 px-4 font-sans">
            <div className="w-full max-w-7xl flex flex-col gap-6 relative">
                
                {/* === MAP & INFO CARD === */}
                <div className="relative">
                    <div className="absolute top-4 left-4 z-400">
                        <button onClick={() => navigate(-1)} className="bg-white p-2 rounded-full shadow-md text-slate-800 hover:bg-gray-50">
                            <FaChevronLeft />
                        </button>
                    </div>

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
                                    key={currentDestination.id} // Re-mounts component when destination changes
                                    userLocation={userLocation} 
                                    destination={currentDestination}
                                    onRouteFound={setRouteSummary}
                                />
                            )}
                        </MapContainer>
                    </div>

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

                {/* === ACTION BUTTONS === */}
                <div className="flex justify-center gap-4">
                    <button 
                        onClick={handleArrived}
                        disabled={isVerifying || !currentDestination}
                        className={`flex-1 text-white py-3 rounded-lg font-bold shadow-md transition ${
                            (isVerifying || !currentDestination)
                            ? 'bg-slate-500 cursor-not-allowed' 
                            : 'bg-slate-800 hover:bg-slate-700'
                        }`}
                    >
                        {isVerifying ? "Verifying..." : "Arrived!"}
                    </button>
                    <button 
                        onClick={handlePause}
                        disabled={!currentDestination}
                        className="flex-1 bg-white text-slate-800 border border-slate-200 py-3 rounded-lg font-bold shadow-sm hover:bg-gray-50 transition disabled:bg-slate-200 disabled:cursor-not-allowed"
                    >
                        {tripSession?.status === "paused" ? "Resume" : "Pause"}
                    </button>
                </div>

                {/* === TRIP ITINERARY === */}
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