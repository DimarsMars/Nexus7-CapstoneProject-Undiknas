import { FaStar } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';

const TripCard = ({ id, image, title, author, rating, className }) => {
  const navigate = useNavigate();

  return (
    <div onClick={() => navigate(`/trip/${id}`)} className={`relative rounded-xl overflow-hidden shadow-lg group cursor-pointer ${className}`}>
      
      <img 
        src={image} 
        alt={title} 
        className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110" 
      />

      <div className="absolute inset-0 bg-linear-to-t from-black/90 via-black/40 to-transparent"></div>

      <div className="absolute bottom-0 left-0 p-5 w-full">
        <h3 className="text-white text-2xl font-bold mb-1">{title}</h3>
        <p className="text-gray-300 text-sm mb-3">{author}</p>
        
        <div className="flex items-center space-x-1">
          {[...Array(5)].map((_, index) => (
            <FaStar
              key={index}
              className={`w-4 h-4 ${
                index < rating ? "text-yellow-400" : "text-gray-400"
              }`}
            />
          ))}
        </div>

      </div>
    </div>
  );
};

export default TripCard;