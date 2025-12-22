import { useNavigate } from 'react-router-dom';
import { FaArrowRight, FaTrash, FaHeart } from "react-icons/fa";
import HistoryCard from '../components/HistoryCard';
import FavoriteCard from '../components/FavoriteCard';
import { useData } from '../context/DataContext';

const HistoryPage = ({ activeTrips, pastTrips }) => {
    const navigate = useNavigate();
    const { favoriteTrips, removeFavorite } = useData();

    const handleRemoveAllFavorites = () => {
        favoriteTrips.forEach(trip => removeFavorite(trip.plan_id));
    };

    return (
        <div className="min-h-screen bg-gray-100 py-10 px-5 pt-24 md:pt-30">
            <div className="max-w-7xl mx-auto space-y-10 text-left">
                
                {/* --- SECTION 1: YOUR TRIP NOW --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Your Trip Now</h2>
                        <button className="px-4 py-1.5 bg-slate-800 text-white text-xs font-medium rounded hover:bg-slate-700 transition">
                            Cancel
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {activeTrips && activeTrips.map((trip) => (
                            <HistoryCard 
                                key={trip.id}
                                image={trip.image}
                                title={trip.title}
                                description={trip.description}
                                location={trip.location}
                                actionIcon={<FaArrowRight />} 
                                onAction={() => navigate(`/trip/${trip.id}`)}
                            />
                        ))}
                    </div>
                </div>

                {/* --- SECTION 2: FAVOURITES --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Favourites</h2>
                        <button 
                            onClick={handleRemoveAllFavorites}
                            className="px-4 py-1.5 bg-red-600 text-white text-xs font-medium rounded hover:bg-red-700 transition"
                        >
                            Remove all
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {favoriteTrips.length > 0 ? (
                            favoriteTrips.map((trip) => (
                                <FavoriteCard 
                                    key={trip.plan_id}
                                    image={`data:image/jpeg;base64,${trip.banner}`}
                                    title={trip.title}
                                    description={trip.description}
                                    location={trip.location}
                                    actionIcon={<FaHeart className="text-red-600" />}
                                    onAction={() => removeFavorite(trip.plan_id)}
                                />
                            ))
                        ) : (
                            <div className="p-4 bg-gray-50 rounded-lg text-center text-gray-400 italic">
                                You haven't favorited any trips yet.
                            </div>
                        )}
                    </div>
                </div>

                {/* --- SECTION 3: YOUR PAST TRIPS --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Your past trip's</h2>
                        <button className="px-4 py-1.5 bg-slate-800 text-white text-xs font-medium rounded hover:bg-slate-700 transition">
                            Remove all
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {pastTrips && pastTrips.map((trip) => (
                            <HistoryCard 
                                key={trip.id}
                                image={trip.image}
                                title={trip.title}
                                description={trip.description}
                                location={trip.location}
                                actionIcon={<FaTrash />} 
                                isDanger={true}
                                onAction={() => console.log("Delete history", trip.id)}
                            />
                        ))}
                    </div>
                </div>

            </div>
        </div>
    );
};

export default HistoryPage;