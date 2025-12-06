import { FaChevronLeft } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import TravellerCard from '../components/TravellerCard';

const TravellersPage = ({ recommendationData, mostActiveData }) => {
  const navigate = useNavigate();

  const renderSection = (title, data) => (
    <div className="mb-12">
        <h2 className="text-lg md:text-xl font-bold text-gray-800 mb-6">
            {title}
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-6 gap-5">
            {data?.map((person) => (
                <TravellerCard 
                    key={person.id}
                    id={person.id}
                    image={person.image}
                    name={person.name}
                    role={person.role}
                />
            ))}
        </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 px-5">
      <div className="max-w-7xl mx-auto">
        
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)} 
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-lg text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Recommendation
            </h1>
        </div>

        {renderSection("You may like", recommendationData)}
        {renderSection("Most Active Traveller", mostActiveData)}
        {renderSection("Route Maker", mostActiveData)}

      </div>
    </div>
  );
};

export default TravellersPage;