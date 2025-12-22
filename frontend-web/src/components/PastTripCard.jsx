import { FaMapMarkerAlt } from "react-icons/fa";

const PastTripCard = ({ 
    image, 
    title, 
    description, 
    location, 
    actionIcon, 
    onAction, 
    isDanger = false
}) => {
    return (
        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-row gap-4 items-center hover:shadow-md transition-shadow duration-300">
            <div className="w-24 h-24 md:w-32 md:h-28 shrink-0 rounded-lg overflow-hidden bg-gray-200">
                <img 
                    src={image} 
                    alt={title} 
                    className="w-full h-full object-cover" 
                />
            </div>

            <div className="flex-1 flex flex-col justify-between h-full py-1">
                <div>
                    <h3 className="font-bold text-slate-900 text-lg line-clamp-1">{title}</h3>
                    <p className="text-gray-500 text-xs md:text-sm line-clamp-2 mt-1 leading-relaxed">
                        {description}
                    </p>
                </div>
                <div className="flex items-center gap-1.5 text-gray-400 text-xs mt-2">
                    <FaMapMarkerAlt />
                    <span>{location}</span>
                </div>
            </div>

            <button 
                onClick={onAction}
                className={`p-3 rounded-full transition-colors ${
                    isDanger 
                    ? "text-gray-400 hover:text-red-500 hover:bg-red-50" 
                    : "text-slate-900 hover:bg-slate-100"
                }`}
            >
                {actionIcon}
            </button>
        </div>
    );
};

export default PastTripCard;