import { FaBookmark, FaMapMarkerAlt } from "react-icons/fa";

const BookmarkedCard = ({ item, isSelected, onToggleSelect, onRemove }) => {
  if (!item) {
    return null;
  }

  return (
    <div className="bg-white p-3 rounded-xl shadow-sm border border-gray-100 flex gap-4 w-full transition-all hover:shadow-md">
      
      {/* Gambar Kiri */}
      <div className="w-28 h-24 md:w-36 md:h-28 shrink-0 rounded-lg overflow-hidden">
        <img 
            src={`data:image/jpeg;base64,${item.image}`}
            alt={item.title} 
            className="w-full h-full object-cover"
        />
      </div>

      {/* Konten Tengah */}
      <div className="flex flex-col text-start justify-center flex-1">
        <h3 className="text-lg font-bold text-slate-900 mb-1">{item.title}</h3>
        <p className="text-xs font-normal text-slate-700">{item.description}</p>
        <div className="flex items-center gap-1 text-gray-400 text-xs mt-2">
            <FaMapMarkerAlt className="text-gray-400" />
            <span>{item.address}</span>
        </div>
      </div>

      {/* Action Buttons Kanan */}
      <div className="flex items-center gap-3 md:gap-4 pr-2">
        <button 
            onClick={onRemove}
            className="text-[#0f172a] text-2xl hover:text-red-500 transition"
            title="Remove from bookmarks"
        >
            <FaBookmark />
        </button>

        {/* Kotak Checklist */}
        <button 
            onClick={onToggleSelect}
            className={`w-8 h-8 rounded-lg border-2 transition-all flex items-center justify-center
                ${isSelected 
                    ? "bg-[#0f172a] border-[#0f172a] text-white"
                    : "bg-transparent border-dashed border-gray-400 hover:border-gray-600"
                }
            `}
        >
            {isSelected && (
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
            )}
        </button>

      </div>
    </div>
  );
};

export default BookmarkedCard;