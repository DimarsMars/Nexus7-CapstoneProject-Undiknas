import { FaMapMarkerAlt, FaTrash } from "react-icons/fa";
import { useRef } from 'react';

const LocationRouteCard = ({ point, index, onDelete, onEdit, onAddImage }) => {
  const fileInputRef = useRef(null);

  const handleAddImageClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        // The result includes the base64 prefix, e.g., "data:image/jpeg;base64,"
        onAddImage(index, e.target.result); 
      };
      reader.readAsDataURL(file);
    }
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border border-slate-200 flex items-start gap-5 transition hover:shadow-md">
      
      {/* Hidden file input */}
      <input 
        type="file" 
        ref={fileInputRef} 
        onChange={handleFileChange}
        className="hidden"
        accept="image/*"
      />

      {/* Gambar Placeholder */}
      <div className="w-40 h-26 bg-slate-100 rounded-md flex items-center justify-center shrink-0">
        {point.image ? (
            <img src={point.image} alt={point.name} className="w-full h-full object-cover rounded-md" />
        ) : (
            <FaMapMarkerAlt className="text-slate-400 text-2xl" />
        )}
      </div>

      {/* Konten Teks */}
      <div className="flex-1 text-left">
        <h4 className="font-bold text-slate-800 text-md mb-1">
          Lokasi {index + 1} : {point.name}
        </h4>
        <p className="text-slate-500 px-3 text-xs leading-relaxed line-clamp-2">
          {point.address}
        </p>
        <p className="text-slate-700  text-sm leading-relaxed line-clamp-2">
          {point.description}
        </p>
        
        {/* Tombol Aksi */}
        <div className="flex flex-wrap gap-2 mt-3">
          <button 
            onClick={() => onEdit && onEdit(point)}
            className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
          >
            Edit Route
          </button>
          <button 
            onClick={handleAddImageClick}
            className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
          >
            Add Image
          </button>

          <button 
            onClick={() => onDelete(index)}
            className="text-[10px] bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 flex items-center gap-1"
          >
            <FaTrash size={8} /> Delete
          </button>
        </div>
      </div>
    </div>
  );
};

export default LocationRouteCard;