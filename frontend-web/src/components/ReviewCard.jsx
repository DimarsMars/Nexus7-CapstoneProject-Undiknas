import { FaStar, FaTrash, FaMapMarkerAlt } from "react-icons/fa";

const ReviewCard = ({ image, title, description, location, rating, onDelete }) => {
  return (
    <div className="bg-white p-3 rounded-xl shadow-sm border border-gray-100 flex gap-5 w-full transition-shadow hover:shadow-md">
      
      {/* Bagian Gambar Kiri */}
      <div className="w-32 h-28 md:w-40 md:h-36 shrink-0 rounded-lg overflow-hidden">
        <img 
            src={image} 
            alt={title} 
            className="w-full h-full object-cover"
        />
      </div>

      {/* Bagian Konten Kanan */}
      <div className="flex flex-col justify-between text-start flex-1 py-1">
        <div>
            <h3 className="text-xl font-bold text-slate-900">{title}</h3>
            <p className="text-sm text-slate-600 mt-1 leading-relaxed line-clamp-2">
                {description}
            </p>
            <div className="flex items-center gap-1 text-gray-400 text-xs mt-2 font-medium">
                <FaMapMarkerAlt className="text-gray-300" />
                <span>{location}</span>
            </div>
        </div>

        <div className="flex justify-between items-center mt-2">
            <div className="flex gap-1">
                {[...Array(5)].map((_, i) => (
                    <FaStar 
                        key={i} 
                        className={`text-lg ${i < rating ? "text-yellow-400" : "text-gray-200"}`} 
                    />
                ))}
            </div>

            <button 
                onClick={onDelete}
                className="text-slate-800 text-lg hover:text-red-600 transition p-1"
                title="Delete Review"
            >
                <FaTrash />
            </button>
        </div>

      </div>
    </div>
  );
};

export default ReviewCard;