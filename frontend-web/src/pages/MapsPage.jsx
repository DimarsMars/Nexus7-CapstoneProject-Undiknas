import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaSearch, FaMapMarkerAlt, FaTrash, FaPlus, FaChevronDown } from "react-icons/fa";
import { MapContainer, TileLayer, useMap, Marker, Popup } from 'react-leaflet';
import LocationRouteCard from '../components/LocationRouteCard';
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

// Routing Machine (Hanya menggambar rute dari waypoints yang SUDAH DI-ADD)
const RoutingMachine = ({ points }) => {
  const map = useMap();
  useEffect(() => {
    if (!map) return;
    if (map.routingControl) map.removeControl(map.routingControl);
    
    // Hanya gambar rute jika ada minimal 2 titik
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

// Map Updater (Animasi Pindah Kamera)
const MapUpdater = ({ center }) => {
  const map = useMap();
  useEffect(() => {
    if (center) {
      map.flyTo(center, 15, { duration: 1.5 });
    }
  }, [center, map]);
  return null;
};

// Temporary Marker (Marker Merah untuk lokasi yang baru di-search tapi BELUM di-add)
const PreviewMarker = ({ position }) => {
    if (!position) return null;
    return <Marker position={[position.lat, position.lng]} />;
};


// --- MAIN PAGE ---
const MapsPage = () => {
  const [waypoints, setWaypoints] = useState([]); // Data rute fix (Array of Objects)
  const navigate = useNavigate();
  
  // State Search & Preview
  const [searchQuery, setSearchQuery] = useState("");
  const [mapCenter, setMapCenter] = useState([-8.5069, 115.2625]);
  const [previewLocation, setPreviewLocation] = useState(null); // Lokasi yang sedang dilihat tapi belum di-add
  const [isSearching, setIsSearching] = useState(false);

  // Fungsi Cari Lokasi (Hanya Preview)
  const handleSearch = async () => {
    if (!searchQuery) return;
    setIsSearching(true);
    
    try {
      // API ArcGIS untuk alamat lengkap
      const response = await fetch(`https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=json&singleLine=${searchQuery}&outFields=Match_addr,Addr_type`);
      const data = await response.json();
      
      if (data && data.candidates && data.candidates.length > 0) {
        const result = data.candidates[0];
        const location = result.location;
        
        // Simpan data calon lokasi ke state 'previewLocation'
        const newPreview = {
            lat: location.y,
            lng: location.x,
            address: result.attributes.Match_addr,
            name: searchQuery
        };

        setPreviewLocation(newPreview);
        setMapCenter([location.y, location.x]); // Pindah kamera map
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

  // Fungsi Add Route (Konfirmasi Lokasi)
  const handleAddRoute = () => {
    if (!previewLocation) {
        alert("Silakan cari lokasi terlebih dahulu!");
        return;
    }

    // Masukkan lokasi preview ke daftar waypoints permanen
    const newWaypoints = [...waypoints, previewLocation];
    setWaypoints(newWaypoints);

    // Reset preview
    setPreviewLocation(null);
    setSearchQuery("");
    
    // Log Data untuk Backend
    console.log("Data siap kirim ke Backend:", JSON.stringify(newWaypoints, null, 2));
  };

  // Fungsi Hapus Titik
  const handleDeletePoint = (index) => {
      const newPoints = waypoints.filter((_, i) => i !== index);
      setWaypoints(newPoints);
  };

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
            <input type="text" placeholder="Add title" className="flex-1 bg-transparent outline-none text-slate-700 font-medium" />
          </div>
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input type="text" placeholder="Add Description" className="flex-1 bg-transparent outline-none text-slate-700 font-medium" />
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
            
            {/* Gambar Rute Fix */}
            <RoutingMachine points={waypoints} />
            
            {/* Gambar Marker untuk Titik yang sudah Fix */}
            {waypoints.map((point, idx) => (
                <Marker key={idx} position={[point.lat, point.lng]}>
                    <Popup>{point.name}</Popup>
                </Marker>
            ))}

            {/* Gambar Marker untuk PREVIEW */}
            {previewLocation && (
                <Marker position={[previewLocation.lat, previewLocation.lng]} opacity={0.6}>
                      <Popup>Click 'Add Route' to confirm this location.</Popup>
                </Marker>
            )}

            <MapUpdater center={mapCenter} />
          </MapContainer>
        </div>

        {/* SEARCH BAR */}
        <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-12 flex items-center px-4">
            <input 
                type="text" 
                placeholder="Cari lokasi (Misal: Aloha Ubud Swing)..." 
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

        {/* Input Tags dan Keterangan*/}
        <div className="flex flex-col gap-3">
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input type="text" placeholder="What are you doing?" className="flex-1 bg-transparent outline-none text-slate-700 font-medium" />
          </div>
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
            <input type="text" placeholder="#Tags" className="flex-1 bg-transparent outline-none text-slate-700 font-medium" />
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

        {/* --- NEW CATEGORIES SECTION --- */}
        <div className="flex flex-col gap-3">
          {/* Select Categories Dropdown */}
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center relative">
            <select className="w-full bg-transparent outline-none text-slate-700 font-medium appearance-none cursor-pointer px-4 z-10">
              <option value="" disabled selected>Select Categories</option>
              <option value="nature">Nature</option>
              <option value="adventure">Adventure</option>
              <option value="culture">Culture</option>
              <option value="culinary">Culinary</option>
            </select>
            <FaChevronDown className="absolute right-4 text-slate-900 text-sm pointer-events-none" />
          </div>

          {/* Add more Categories Input */}
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4">
             <input type="text" placeholder="Add more Categories" className="flex-1 bg-transparent outline-none text-slate-700 font-medium" />
             <FaPlus className="text-slate-900 cursor-pointer" />
          </div>
        </div>

        {/* LIST CARD LOKASI (Hasil Add Route) */}
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
                    // Kamu bisa menambahkan handler lain nanti:
                    onEdit={() => console.log("Edit clicked", point)}
                    onAddImage={() => console.log("Add Image clicked", point)}
                    onAddPlace={() => console.log("Add Place clicked", point)}
                />
            ))}
        </div>

        {/* TOMBOL POST ROUTE */}
        <div className="flex justify-center">
          <button className="bg-slate-800 text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-800 transition active:scale-95">
            Post Route
          </button>
        </div>

      </div>
    </div>
  );
}

export default MapsPage;