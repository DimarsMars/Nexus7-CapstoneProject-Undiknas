import { FaMapMarkerAlt, FaTrash } from "react-icons/fa";

const LocationRouteCard = ({ point, index, onDelete, onEdit, onAddImage, onAddPlace }) => {
  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border border-slate-200 flex items-start gap-4 transition hover:shadow-md">
      
      {/* Gambar Placeholder */}
      <div className="w-20 h-20 bg-slate-100 rounded-md flex items-center justify-center shrink-0">
        {/* Jika nanti ada image di point, bisa dipasang logika di sini */}
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
        <p className="text-slate-500 text-sm leading-relaxed line-clamp-2">
          {point.address}
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
            onClick={() => onAddImage && onAddImage(point)}
            className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
          >
            Add Image
          </button>
          <button 
             onClick={() => onAddPlace && onAddPlace(point)}
             className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
          >
            Add Specific Place
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