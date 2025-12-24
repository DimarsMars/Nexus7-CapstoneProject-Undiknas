import { useNavigate } from 'react-router-dom';

const TravellerCard = ({ id, image, name, role }) => {
    const navigate = useNavigate();

  return (
    <div 
        onClick={() => navigate(`/profile/${id}`)}
        className="bg-white p-4 rounded-2xl shadow-sm hover:shadow-md transition-shadow flex flex-col items-center text-center border border-gray-100">
            <div className="w-24 h-24 mb-3 rounded-full overflow-hidden">
                <img 
                    src={image || "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg"} 
                    alt={name} 
                    className="w-full h-full object-cover"
                />
            </div>

      <h3 className="text-gray-900 font-bold text-lg">{name}</h3>
      <p className="text-gray-500 text-sm font-normal mb-4">{role}</p>

      <button className="bg-slate-900 text-white text-sm font-medium px-6 py-1.5 rounded-lg hover:bg-gray-700 transition-colors">
        Follow
      </button>

    </div>
  );
};

export default TravellerCard;