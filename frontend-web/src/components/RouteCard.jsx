import { FaMapMarkerAlt } from "react-icons/fa";

const RouteCard = ({ image, title, activity, location, onClick}) => {

  return (
    <div 
      onClick={onClick}
      className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col md:flex-row gap-4 w-full shadow-sm hover:shadow-md transition-shadow"
    >
      <div className="w-full md:w-48 h-32 shrink-0 rounded-lg overflow-hidden">
        <img 
            src={image} 
            alt={title} 
            className="w-full h-full object-cover"
        />
      </div>

      <div className="flex flex-col text-start justify-center">
        <h3 className="text-xl font-bold text-[#1e293b]">{title}</h3>
        <p className="text-gray-500 text-sm mt-1">{activity}</p>
        <div className="flex items-center gap-1.5 text-gray-400 text-xs mt-2">
            <FaMapMarkerAlt />
            <span>{location}</span>
        </div>
      </div>
    </div>
  );
};

export default RouteCard;