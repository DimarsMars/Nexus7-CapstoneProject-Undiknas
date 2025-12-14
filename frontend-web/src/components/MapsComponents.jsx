import { useState, useEffect } from 'react';
import { FaChevronLeft } from "react-icons/fa";
import { MapContainer, TileLayer, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet-routing-machine';
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';

// --- BAGIAN ICON LEAFLET DEFAULT ---
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// --- KOMPONEN LOGIC MAP ---
const RoutingMachine = ({ points }) => {
  const map = useMap();
  useEffect(() => {
    if (!map) return;
    if (map.routingControl) map.removeControl(map.routingControl);
    
    // Fitur routing dimatikan visual panelnya agar sesuai desain bersih
    const routingControl = L.Routing.control({
      waypoints: points.map(p => L.latLng(p.lat, p.lng)),
      routeWhileDragging: true,
      show: false, // Hide instruction text
      addWaypoints: false,
      draggableWaypoints: false,
      lineOptions: { styles: [{ color: '#8B5CF6', opacity: 1, weight: 5 }] } // Warna Ungu (seperti Aloha Swing)
    }).addTo(map);

    map.routingControl = routingControl;
    return () => {
        if (map.routingControl) map.removeControl(map.routingControl);
    };
  }, [map, points]);
  return null;
};

const LocationMarker = ({ setPoints, points }) => {
  useMapEvents({
    click(e) {
      setPoints([...points, { lat: e.latlng.lat, lng: e.latlng.lng }]);
    },
  });
  return null;
};

// --- ICON SVG CUSTOM (Sesuai Gambar) ---

// Ikon melengkung di dalam Input (Route Icon)
const RouteInputIcon = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1F2937" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="opacity-80">
    <path d="M4 15s1-1 4-3.5a3.86 3.86 0 0 0 0-5.3C10 4 12 4 13 5s5 6 5 11" />
  </svg>
);


// --- MAIN PAGE ---
function MapsComponents() {
  const [waypoints, setWaypoints] = useState([]);

  return (
    // Background utama (Light Grayish Blue - mirip gambar)
    <div className="min-h-screen bg-gray-100 flex items-center justify-center py-10 px-4 pt-30 font-sans">
      <div className="w-full max-w-7xl flex flex-col gap-6">
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Forge Your Route
            </h1>
        </div>

        {/* Input Fields Section */}
        <div className="flex flex-col gap-3">
          
          {/* Title Input */}
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4 transition focus-within:ring-1 focus-within:ring-slate-800">
            <input 
              type="text" 
              placeholder="Add title" 
              className="flex-1 bg-transparent outline-none text-slate-700 placeholder-slate-400 font-medium"
            />
            <div className="ml-3 p-1.5 bg-slate-100 rounded-md">
              <RouteInputIcon />
            </div>
          </div>

          {/* Description Input */}
          <div className="bg-white rounded-lg shadow-sm border border-slate-200 h-11 flex items-center px-4 transition focus-within:ring-1 focus-within:ring-slate-800">
            <input 
              type="text" 
              placeholder="Add Description" 
              className="flex-1 bg-transparent outline-none text-slate-700 placeholder-slate-400 font-medium"
            />
            <div className="ml-3 p-1.5 bg-slate-100 rounded-md">
              <RouteInputIcon />
            </div>
          </div>
        </div>

        {/* Map Section */}
        <div className="relative w-full h-96 bg-slate-200 rounded-xl overflow-hidden shadow-sm border border-slate-300 group">
          
          <MapContainer 
            center={[-8.4436, 115.2800]}
            zoom={13} 
            className="h-full w-full"
            zoomControl={false}
          >
            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
            <LocationMarker points={waypoints} setPoints={setWaypoints} />
            <RoutingMachine points={waypoints} />
          </MapContainer>
        </div>

        {/* Actions Buttons */}
        <div className="flex justify-center gap-4 mt-4">
          <button className="bg-slate-800 text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-700 transition active:scale-95">
            Add Route
          </button>
          <button className="bg-slate-800 text-white px-8 py-3 rounded-lg text-md font-medium shadow-lg hover:bg-slate-700 transition active:scale-95">
            Bookmark's
          </button>
        </div>

      </div>
    </div>
  );
}

export default MapsComponents;