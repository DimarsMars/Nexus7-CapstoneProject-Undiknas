import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaSearch, FaMapMarkerAlt, FaTrash, FaPlus, FaChevronDown, FaTimes } from "react-icons/fa";
// 1. Tambahkan useMapEvents di sini
import { MapContainer, TileLayer, useMap, Marker, Popup, useMapEvents } from 'react-leaflet';
import LocationRouteCard from '../components/LocationRouteCard';
import apiService from '../services/apiService';
import L from 'leaflet';
import 'leaflet-routing-machine';
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';

import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// --- LOGIC MAP ---

const RoutingMachine = ({ points }) => {
  const map = useMap();
  useEffect(() => {
    if (!map) return;
    if (map.routingControl) map.removeControl(map.routingControl);
    
    if (points.length < 2) return;

    const routingControl = L.Routing.control({
      waypoints: points.map(p => L.latLng(p.lat, p.lng)),
      routeWhileDragging: false,
      show: false, 
      addWaypoints: false,
      draggableWaypoints: false,
      lineOptions: { styles: [{ color: '#8B5CF6', opacity: 1, weight: 5 }] },
      createMarker: function() { return null; }
    }).addTo(map);

    map.routingControl = routingControl;
    return () => {
        if (map.routingControl) map.removeControl(map.routingControl);
    };
  }, [map, points]);
  return null;
};

const MapUpdater = ({ center }) => {
  const map = useMap();
  useEffect(() => {
    if (center) {
      map.flyTo(center, 15, { duration: 1.5 });
    }
  }, [center, map]);
  return null;
};

// 2. Component baru untuk menangkap Klik di Peta
const MapClickHandler = ({ onMapClick }) => {
    useMapEvents({
        click: (e) => {
            onMapClick(e.latlng);
        },
    });
    return null;
};

const PreviewMarker = ({ position }) => {
    if (!position) return null;
    return <Marker position={[position.lat, position.lng]} />;
};


// --- MAIN PAGE ---
const MapsPage = () => {
  const [waypoints, setWaypoints] = useState([]); 
  const navigate = useNavigate();
  
  // State Search & Preview
  const [searchQuery, setSearchQuery] = useState("");
  const [mapCenter, setMapCenter] = useState([-8.5069, 115.2625]);
  const [previewLocation, setPreviewLocation] = useState(null); 
  const [isSearching, setIsSearching] = useState(false);
  const [whatAreYouDoing, setWhatAreYouDoing] = useState("");
  const [title, setTitle] = useState("");
  const [planDescription, setPlanDescription] = useState("");

  // --- STATE KATEGORI ---
  const [categories, setCategories] = useState([]);
  const [selectedCategories, setSelectedCategories] = useState([]); 
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // --- FETCH KATEGORI ---
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiService.getCategories();        
        if (Array.isArray(response.data)) {
            setCategories(response.data);
        } else {
            console.error("Format data kategori tidak sesuai:", response.data);
        }
      } catch (error) {
        console.error("Gagal mengambil kategori:", error);
      }
    };
    fetchCategories();
  }, []);

  // Fungsi Cari Lokasi (Search Bar)
  const handleSearch = async () => {
    if (!searchQuery) return;
    setIsSearching(true);
    
    try {
      const response = await fetch(`https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=json&singleLine=${searchQuery}&outFields=Match_addr,Addr_type`);
      const data = await response.json();
      
      if (data && data.candidates && data.candidates.length > 0) {
        const result = data.candidates[0];
        const location = result.location;
        
        const newPreview = {
            lat: location.y,
            lng: location.x,
            address: result.attributes.Match_addr,
            name: searchQuery
        };

        setPreviewLocation(newPreview);
        setMapCenter([location.y, location.x]); 
      } else {
        alert("Lokasi tidak ditemukan!");
      }
    } catch (error) {
      console.error("Error:", error);
      alert("Gagal mencari lokasi.");
    } finally {
      setIsSearching(false);
    }
  };

  // 3. Fungsi Handler saat Peta Diklik (Reverse Geocoding)
  const handleMapClick = async (latlng) => {
    const { lat, lng } = latlng;

    // Set sementara (Visual Feedback langsung muncul marker)
    setPreviewLocation({ 
        lat, 
        lng, 
        name: "Fetching address...", 
        address: "Loading..." 
    });

    try {
        // Fetch alamat dari koordinat (Reverse Geocoding ArcGIS)
        const response = await fetch(`https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=json&location=${lng},${lat}`);
        const data = await response.json();

        if (data && data.address) {
            setPreviewLocation({
                lat,
                lng,
                name: data.address.Match_addr || "Selected Location",
                address: data.address.LongLabel || data.address.Match_addr
            });
            // Update search query agar user tau apa yang diklik
            setSearchQuery(data.address.Match_addr || "");
        } else {
            // Fallback jika alamat tidak ketemu (misal klik di tengah laut)
            setPreviewLocation({
                lat,
                lng,
                name: "Selected Location",
                address: `${lat.toFixed(5)}, ${lng.toFixed(5)}`
            });
        }
    } catch (error) {
        console.error("Reverse geocode error:", error);
        setPreviewLocation({
            lat,
            lng,
            name: "Selected Location",
            address: `${lat.toFixed(5)}, ${lng.toFixed(5)}`
        });
    }
  };

  const handleAddRoute = () => {
    if (!previewLocation) {
        alert("Silakan cari atau klik lokasi di peta terlebih dahulu!");
        return;
    }

    const newRoutePoint = {
        ...previewLocation,
        description: whatAreYouDoing // Add the description here
    };

    const newWaypoints = [...waypoints, newRoutePoint];
    setWaypoints(newWaypoints);

    setPreviewLocation(null);
    setSearchQuery("");
    setWhatAreYouDoing(""); // Clear the input after adding
    
    // Log Data
    console.log("Data Route:", JSON.stringify(newWaypoints, null, 2));
    console.log("Selected Categories:", selectedCategories);
  };

  const handleDeletePoint = (index) => {
      const newPoints = waypoints.filter((_, i) => i !== index);
      setWaypoints(newPoints);
  };

  // --- HANDLER MULTI SELECT KATEGORI ---
  const handleSelectCategory = (category) => {
      if (!selectedCategories.some(c => c.category_id === category.category_id)) {
          setSelectedCategories([...selectedCategories, category]);
      }
      setIsDropdownOpen(false); 
  };

  const handleRemoveCategory = (categoryId) => {
      const updated = selectedCategories.filter(c => c.category_id !== categoryId);
      setSelectedCategories(updated);
  };

  const handleImageUpload = (index, imageBase64) => {
    const updatedWaypoints = [...waypoints];
    updatedWaypoints[index].image = imageBase64;
    setWaypoints(updatedWaypoints);
  };

  const handlePostRoute = async () => {
    // 1. Validasi
    if (!title) {
      alert("Please add a title for your plan.");
      return;
    }
    if (waypoints.length === 0) {
      alert("Please add at least one route point.");
      return;
    }

    // 2. Siapkan payload sebagai FormData
    const formData = new FormData();
    formData.append('title', title);
    formData.append('description', planDescription);
    
    // Backend mengharapkan string ID kategori yang dipisahkan koma
    const categoryIds = selectedCategories.map(c => c.category_id).join(',');
    formData.append('category_ids', categoryIds);

    // Backend mengharapkan array rute dalam format JSON string
    const routesData = waypoints.map((point, index) => {
      // Strip the base64 prefix if the image exists
      const imageBase64 = point.image ? point.image.split(',')[1] : "";

      return {
        title: point.name,
        description: point.description || "",
        address: point.address,
        latitude: point.lat,
        longitude: point.lng,
        step_order: index + 1,
        image: imageBase64,
      }
    });
    formData.append('routes', JSON.stringify(routesData));

    // Log FormData entries for debugging
    for (let [key, value] of formData.entries()) {
      console.log(`FormData: ${key}: ${value}`);
    }

    try {
      const response = await apiService.createPlan(formData);
      console.log("Plan created successfully:", response);
      alert("Your plan has been created successfully!");
      
      // Reset state
      setTitle("");
      setPlanDescription("");
      setSelectedCategories([]);
      setWaypoints([]);
    } catch (error) {
      console.error("Failed to create plan:", error.response ? error.response.data : error);
      alert(`Failed to create plan. ${error.response?.data?.error || error.message}`);
    }
  };

  const availableCategories = categories.filter(
      c => !selectedCategories.some(selected => selected.category_id === c.category_id)
  );

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center py-10 pt-30 px-4 font-sans">
      <div className="w-full max-w-7xl flex flex-col gap-6">
        
        {/* Header */}
        <div className="flex items-center gap-4 mb-2">
            <h1 className="text-xl font-bold text-black">Forge Your Route</h1>
        </div>

        {/* Input Judul & Deskripsi */}
        <div className="flex flex-col gap-3">
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input 
              type="text" 
              placeholder="Add title" 
              className="flex-1 bg-transparent outline-none text-slate-700 font-medium" 
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input 
              type="text" 
              placeholder="Add Description" 
              className="flex-1 bg-transparent outline-none text-slate-700 font-medium" 
              value={planDescription}
              onChange={(e) => setPlanDescription(e.target.value)}
            />
          </div>
        </div>

        {/* MAPS */}
        <div className="relative w-full h-96 bg-slate-200 rounded-xl overflow-hidden shadow-sm border border-slate-300 z-0">
          <MapContainer 
            center={mapCenter} 
            zoom={13} 
            className="h-full w-full" 
            zoomControl={false}
          >
            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
            
            <RoutingMachine points={waypoints} />
            
            {waypoints.map((point, idx) => (
                <Marker key={idx} position={[point.lat, point.lng]}>
                    <Popup>{point.name}</Popup>
                </Marker>
            ))}
            
            {previewLocation && (
                <Marker position={[previewLocation.lat, previewLocation.lng]} opacity={0.6}>
                      <Popup>Click 'Add Route' to confirm this location.</Popup>
                </Marker>
            )}
            
            {/* 4. Pasang Handler Klik di sini */}
            <MapClickHandler onMapClick={handleMapClick} />
            
            <MapUpdater center={mapCenter} />
          </MapContainer>
        </div>

        {/* SEARCH BAR */}
        <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-12 flex items-center px-4">
            <input 
                type="text" 
                placeholder="Cari lokasi atau klik di peta..." 
                className="flex-1 bg-transparent outline-none text-slate-700 font-medium"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
            />
            <button 
                onClick={handleSearch}
                disabled={isSearching}
                className="ml-3 p-2 bg-slate-100 hover:bg-slate-200 rounded-md text-slate-600 transition"
            >
                {isSearching ? "..." : <FaSearch />}
            </button>
        </div>

        {/* Input Deskripsi */}
        <div className="flex flex-col gap-3">
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input 
                type="text" 
                placeholder="What are you doing?" 
                className="flex-1 bg-transparent outline-none text-slate-700 font-medium" 
                value={whatAreYouDoing}
                onChange={(e) => setWhatAreYouDoing(e.target.value)}
            />
          </div>
        </div>

        {/* TOMBOL ADD ROUTE */}
        <div className="flex justify-center gap-4">
          <button 
            onClick={handleAddRoute}
            className="bg-[#1F2937] text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-800 transition active:scale-95"
          >
            Add Route
          </button>
          <button onClick={() => navigate(`/bookmarked`)} className="bg-[#1F2937] text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-800 transition active:scale-95">
            Bookmark's
          </button>
        </div>

        {/* --- MULTI SELECT CATEGORIES SECTION --- */}
        <div className="flex flex-col gap-3 relative">
          
          {/* Container Input + Tags */}
          <div 
             className="bg-white rounded-lg shadow-sm border border-slate-200 min-h-11 flex flex-wrap items-center px-4 py-1 gap-2 cursor-pointer"
             onClick={() => setIsDropdownOpen(!isDropdownOpen)} 
          >
             {/* Render Selected Categories as Tags */}
             {selectedCategories.map((item) => (
                 <div 
                    key={item.category_id} 
                    className="bg-slate-200 text-slate-800 px-2 py-1 rounded text-md font-medium flex items-center gap-1"
                    onClick={(e) => e.stopPropagation()}
                 >
                     {item.name}
                     <FaTimes 
                        className="cursor-pointer hover:text-red-500 ml-1" 
                        onClick={() => handleRemoveCategory(item.category_id)}
                     />
                 </div>
             ))}

             {/* Placeholder / Trigger */}
             <div className="flex-1 flex items-center justify-between min-w-[100px]">
                 <span className={`${selectedCategories.length === 0 ? 'text-gray-400' : 'text-slate-700'} font-medium`}>
                    {selectedCategories.length === 0 ? "Add Categories" : ""}
                 </span>
                 <FaPlus className={`text-slate-900 text-sm transition-transform ${isDropdownOpen ? 'rotate-45' : ''}`} />
             </div>
          </div>

          {/* Dropdown List Items */}
          {isDropdownOpen && (
            <div className="absolute top-full mt-1 left-0 w-full bg-white rounded-lg shadow-lg border border-slate-200 z-50 overflow-hidden">
                <div className="max-h-60 overflow-y-auto">
                    {availableCategories.map((item) => (
                        <div 
                            key={item.category_id}
                            onClick={() => handleSelectCategory(item)}
                            className="px-4 py-2.5 hover:bg-slate-100 cursor-pointer text-slate-700 font-medium text-md border-b border-slate-50 last:border-0"
                        >
                            {item.name}
                        </div>
                    ))}

                    {availableCategories.length === 0 && (
                        <div className="px-4 py-3 text-gray-400 text-sm text-center">
                            {categories.length === 0 ? "No categories loaded" : "All categories selected"}
                        </div>
                    )}
                </div>
            </div>
          )}
        </div>

        {/* LIST CARD LOKASI */}
        <div className="flex flex-col gap-4 mt-2">
            {waypoints.length === 0 && (
                <p className="text-center text-slate-400 text-sm">Belum ada lokasi yang ditambahkan.</p>
            )}

            {waypoints.map((point, index) => (
                <LocationRouteCard 
                    key={index} 
                    point={point} 
                    index={index} 
                    onDelete={handleDeletePoint}
                    onEdit={() => console.log("Edit clicked", point)}
                    onAddImage={handleImageUpload}
                    onAddPlace={() => console.log("Add Place clicked", point)}
                />
            ))}
        </div>

        {/* TOMBOL POST ROUTE */}
        <div className="flex justify-center">
          <button 
            onClick={handlePostRoute}
            className="bg-slate-800 text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-800 transition active:scale-95"
          >
            Post Route
          </button>
        </div>

      </div>
    </div>
  );
}

export default MapsPage;