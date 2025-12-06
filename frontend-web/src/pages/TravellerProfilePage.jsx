import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft } from "react-icons/fa";
import TripCard from '../components/TripCard';

const TravellerProfilePage = ({ recommendationData, trips }) => {
  const { id } = useParams();
  const navigate = useNavigate();

  const person = recommendationData.find(p => p.id === parseInt(id));
  if (!person) return <div className="h-screen w-full flex items-center justify-center text-gray-400 font-bold text-md">User not found :(</div>;

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 pb-20 px-5">
      <div className="max-w-7xl mx-auto">
        
        <button 
            onClick={() => navigate(-1)} 
            className="flex items-center gap-2 mb-8 text-black font-bold hover:text-gray-600 transition"
        >
            <FaChevronLeft /> Back
        </button>

        <div className="bg-white rounded-xl p-6 md:p-15 shadow-sm flex flex-col md:flex-row items-center gap-8 md:gap-12 mb-10">
            <div className="w-32 h-32 md:w-40 md:h-40 rounded-full overflow-hidden border-4 border-gray-100 shrink-0">
                <img src={person.image} alt={person.name} className="w-full h-full object-cover" />
            </div>

            <div className="grow text-center md:text-left w-full">
                
                <div className="flex flex-col md:flex-row justify-between items-start mb-6 px-20">
                    <div>
                        <p className="text-gray-500 text-sm">Name</p>
                        <h1 className="text-2xl font-bold text-gray-900 mb-4">{person.name}</h1>
                        
                        <div className="flex items-center justify-center md:justify-start gap-2">
                            <span className="bg-black text-white text-xs px-2 py-1 rounded-full font-bold">1</span>
                            <div>
                                <p className="text-gray-500 text-xs">Rank's</p>
                                <p className="font-bold text-sm text-gray-900">{person.rank || "Traveler"}</p>
                            </div>
                        </div>
                    </div>

                    <div className="flex gap-8 md:gap-12 mt-6 md:mt-0 justify-center md:justify-end w-full md:w-auto">
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Followers</p>
                            <p className="font-bold text-lg">{person.followers || 0}</p>
                        </div>
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Reviews</p>
                            <p className="font-bold text-lg">{person.reviews || 0}</p>
                        </div>
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Route's</p>
                            <p className="font-bold text-lg">{person.totalRoutes || 0}</p>
                        </div>
                    </div>
                </div>

                <div className="flex gap-3 justify-center md:justify-end border-t pt-6 md:border-none md:pt-0 px-20">
                    <button className="bg-[#1e293b] text-white px-8 py-2 rounded-md font-medium hover:bg-slate-700 transition">
                        Follow
                    </button>
                    <button className="bg-red-600 text-white px-8 py-2 rounded-md font-medium hover:bg-red-700 transition">
                        Report
                    </button>
                </div>

            </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {trips.slice(0, 4).map((trip) => (
                <TripCard
                    key={trip.id}
                    title={trip.title}
                    author={person.name}
                    rating={trip.rating}
                    image={trip.image}
                    className="h-64"
                />
            ))}
        </div>

      </div>
    </div>
  );
};

export default TravellerProfilePage;