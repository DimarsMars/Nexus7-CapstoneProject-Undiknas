import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaSearch, FaPlus, FaTimes } from "react-icons/fa";
// Import komponen inti dari React Leaflet untuk integrasi peta
import { MapContainer, TileLayer, useMap, Marker, Popup, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet-routing-machine';

// --- Local Components ---
import LocationRouteCard from '../components/LocationRouteCard';

// --- Services & Context ---
import apiService from '../services/apiService';
import { useData } from '../context/DataContext'; 

// --- Leaflet Styles & Assets ---
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

// --- LEAFLET CONFIG & HELPER COMPONENTS ---

// --- Konfigurasi Ikon Default Leaflet agar marker muncul dengan benar di UI ---
let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// --- Komponen untuk menangani pembuatan garis rute (Polyline) di peta menggunakan Leaflet Routing Machine ---
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
      createMarker: () => null
    }).addTo(map);

    map.routingControl = routingControl;
    return () => { if (map.routingControl) map.removeControl(map.routingControl); };
  }, [map, points]);
  return null;
};

// --- Komponen untuk melakukan transisi perpindahan pandangan peta (FlyTo) secara halus ---
const MapUpdater = ({ center }) => {
  const map = useMap();
  useEffect(() => {
    if (center) map.flyTo(center, 15, { duration: 1.5 });
  }, [center, map]);
  return null;
};

// --- Komponen untuk menangkap event klik pada peta agar bisa mendapatkan koordinat lat/lng ---
const MapClickHandler = ({ onMapClick }) => {
    useMapEvents({ click: (e) => onMapClick(e.latlng) });
    return null;
};

// MAIN MAPS PAGE COMPONENT

const MapsPage = () => {
  // --- Hooks untuk navigasi dan akses data global dari Context ---
  const navigate = useNavigate();
  const { 
    fetchAllPlan, 
    currentRouteWaypoints, 
    clearRouteWaypoints,
    addWaypoint,
    deleteWaypoint,
    editWaypoint,
    uploadWaypointImage
  } = useData(); 
  
  // --- State Management: Form Detail Rencana Perjalanan ---
  const [title, setTitle] = useState("");
  const [planDescription, setPlanDescription] = useState("");
  const [status, setStatus] = useState("");

  // --- State Management: Interaksi Peta dan Lokasi Preview ---
  const [mapCenter, setMapCenter] = useState([-8.5069, 115.2625]);
  const [previewLocation, setPreviewLocation] = useState(null); 
  const [whatAreYouDoing, setWhatAreYouDoing] = useState("");
  
  // --- State Management: Pencarian Lokasi ---
  const [searchQuery, setSearchQuery] = useState("");
  const [isSearching, setIsSearching] = useState(false);

  // --- State Management: Daftar Kategori dari Database ---
  const [categories, setCategories] = useState([]);
  const [selectedCategories, setSelectedCategories] = useState([]); 
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // --- Effect untuk mengambil daftar kategori saat pertama kali halaman dimuat ---
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiService.getCategories();        
        setCategories(Array.isArray(response.data) ? response.data : []);
      } catch (error) {
        console.error("Gagal mengambil kategori:", error);
      }
    };
    fetchCategories();
  }, []);

  // --- EVENT HANDLERS ---

  // --- Fungsi untuk mencari koordinat berdasarkan teks input menggunakan ArcGIS Geocoding ---
  const handleSearch = async () => {
    if (!searchQuery) return;
    setIsSearching(true);
    try {
      const response = await fetch(`https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=json&singleLine=${searchQuery}&outFields=Match_addr,Addr_type`);
      const data = await response.json();
      
      if (data?.candidates?.length > 0) {
        const { location, attributes } = data.candidates[0];
        const newPreview = {
            lat: location.y,
            lng: location.x,
            address: attributes.Match_addr,
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

  // --- Fungsi untuk menangani klik pada peta dan melakukan Reverse Geocoding (Lat/Lng -> Alamat) ---
  const handleMapClick = async (latlng) => {
    const { lat, lng } = latlng;
    setPreviewLocation({ lat, lng, name: "Fetching address...", address: "Loading..." });

    try {
        const response = await fetch(`https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=json&location=${lng},${lat}`);
        const data = await response.json();
        const address = data?.address;
        const newName = address?.Match_addr || "Selected Location";
        const newAddress = address?.LongLabel || address?.Match_addr || `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
        
        setPreviewLocation({ lat, lng, name: newName, address: newAddress });
        setSearchQuery(newName);
    } catch (error) {
        console.error("Reverse geocode error:", error);
        setPreviewLocation({ lat, lng, name: "Selected Location", address: `${lat.toFixed(5)}, ${lng.toFixed(5)}` });
    }
  };

  // --- Fungsi untuk menambahkan lokasi terpilih ke dalam daftar waypoint rute ---
  const handleAddRoute = () => {
    if (!previewLocation) {
        alert("Silakan cari atau klik lokasi di peta terlebih dahulu!");
        return;
    }
    addWaypoint({ ...previewLocation, description: whatAreYouDoing });
    setPreviewLocation(null);
    setSearchQuery("");
    setWhatAreYouDoing("");
  };

  // --- Fungsi untuk menangani pemilihan kategori dari dropdown ---
  const handleSelectCategory = (category) => {
      if (!selectedCategories.some(c => c.category_id === category.category_id)) {
          setSelectedCategories([...selectedCategories, category]);
      }
      setIsDropdownOpen(false); 
  };

  // --- Fungsi untuk menghapus kategori yang telah dipilih ---
  const handleRemoveCategory = (categoryId) => {
      setSelectedCategories(selectedCategories.filter(c => c.category_id !== categoryId));
  };

  // --- Fungsi untuk mengirimkan seluruh data rute (Plan) ke server via API ---
  const handlePostRoute = async () => {
    if (!title) return alert("Please add a title for your plan.");
    if (currentRouteWaypoints.length === 0) return alert("Please add at least one route point.");

    const formData = new FormData();
    formData.append('title', title);
    formData.append('description', planDescription);
    formData.append('category_ids', selectedCategories.map(c => c.category_id).join(','));

    // Menyiapkan data rute dalam format JSON untuk dikirim ke backend
    const routesData = currentRouteWaypoints.map((point, index) => {
      let imageBase64 = "";
      if (point.image) {
        imageBase64 = point.image.includes(',') ? point.image.split(',')[1] : point.image;
      }
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

    try {
      await apiService.createPlan(formData);
      alert("Your plan has been created successfully!");
      await fetchAllPlan(true);

      // Reset state form setelah berhasil post data
      setTitle("");
      setPlanDescription("");
      setSelectedCategories([]);
      clearRouteWaypoints();
    } catch (error) {
      console.error("Failed to create plan:", error.response?.data || error);
      alert(`Failed to create plan. ${error.response?.data?.error || error.message}`);
    }
  };

  // --- RENDER LOGIC ---

  // Filter kategori agar tidak menampilkan yang sudah dipilih di dalam list dropdown
  const availableCategories = categories.filter(
      c => !selectedCategories.some(selected => selected.category_id === c.category_id)
  );

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center py-10 pt-30 px-4 font-sans">
      <div className="w-full max-w-7xl flex flex-col gap-6">
        
        {/* --- Bagian Header --- */}
        <div className="flex items-center gap-4 mb-2">
            <h1 className="text-xl font-bold text-black">Forge Your Route</h1>
        </div>

        {/* --- Formulir Detail Rencana (Judul, Deskripsi, Status) --- */}
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
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center">
            <select 
              name="status"
              className="w-full bg-transparent outline-none text-slate-700 font-medium appearance-none cursor-pointer px-4"
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option value="" disabled>Select Status</option>
              <option value="Married">Married</option>
              <option value="Single">Single</option>
              <option value="In Relationship">In Relationship</option>
              <option value="Adult">Adult</option>
              <option value="Family Friendly">Family Friendly</option>
            </select>
          </div>
        </div>

        {/* --- Tampilan Peta Interaktif menggunakan Leaflet --- */}
        <div className="relative w-full h-96 bg-slate-200 rounded-xl overflow-hidden shadow-sm border border-slate-300 z-0">
          <MapContainer center={mapCenter} zoom={13} className="h-full w-full" zoomControl={false}>
            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
            {/* Menampilkan rute antar waypoint jika tersedia */}
            <RoutingMachine points={currentRouteWaypoints} />
            
            {/* Menampilkan marker permanen untuk setiap waypoint yang sudah ditambahkan */}
            {currentRouteWaypoints.map((point, idx) => (
                <Marker key={idx} position={[point.lat, point.lng]}><Popup>{point.name}</Popup></Marker>
            ))}
            
            {/* Menampilkan marker preview sementara saat mencari/klik peta */}
            {previewLocation && (
                <Marker position={[previewLocation.lat, previewLocation.lng]} opacity={0.6}>
                    <Popup>Click 'Add Route' to confirm this location.</Popup>
                </Marker>
            )}
            
            <MapClickHandler onMapClick={handleMapClick} />
            <MapUpdater center={mapCenter} />
          </MapContainer>
        </div>

        {/* --- Input Pencarian Lokasi dan Deskripsi Aktivitas --- */}
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
        <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input 
                type="text" 
                placeholder="What are you doing? (optional description)" 
                className="flex-1 bg-transparent outline-none text-slate-700 font-medium" 
                value={whatAreYouDoing}
                onChange={(e) => setWhatAreYouDoing(e.target.value)}
            />
        </div>

        {/* --- Tombol Aksi untuk Manajemen Rute dan Bookmark --- */}
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

        {/* --- Sistem Pemilihan Kategori Tag --- */}
        <div className="relative">
          <div 
             className="bg-white rounded-lg shadow-sm border border-slate-200 min-h-11 flex flex-wrap items-center px-4 py-1 gap-2 cursor-pointer"
             onClick={() => setIsDropdownOpen(!isDropdownOpen)} 
          >
             {/* Render tag kategori yang sudah terpilih */}
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

             <div className="flex-1 flex items-center justify-between min-w-[100px]">
                 <span className={`${selectedCategories.length === 0 ? 'text-gray-400' : 'text-slate-700'} font-medium`}>
                    {selectedCategories.length === 0 ? "Add Categories" : ""}
                 </span>
                 <FaPlus className={`text-slate-900 text-sm transition-transform ${isDropdownOpen ? 'rotate-45' : ''}`} />
             </div>
          </div>

          {/* Render List Dropdown Kategori */}
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

        {/* --- Daftar Lokasi (Waypoint) yang telah ditambahkan ke rute --- */}
        <div className="flex flex-col gap-4 mt-2">
            {currentRouteWaypoints.length === 0 ? (
                <p className="text-center text-slate-400 text-sm">Belum ada lokasi yang ditambahkan.</p>
            ) : (
                currentRouteWaypoints.map((point, index) => (
                    <LocationRouteCard 
                        key={index} 
                        point={point} 
                        index={index} 
                        onDelete={deleteWaypoint}
                        onEdit={editWaypoint}
                        onAddImage={uploadWaypointImage}
                    />
                ))
            )}
        </div>

        {/* --- Tombol Final untuk mempublikasikan Rute ke server --- */}
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