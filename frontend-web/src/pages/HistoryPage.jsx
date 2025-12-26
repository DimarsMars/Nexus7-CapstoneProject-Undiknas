import { useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import apiService from '../services/apiService';
import { FaArrowRight, FaTrash, FaHeart } from "react-icons/fa";
import { useData } from '../context/DataContext';
import FavoriteCard from '../components/FavoriteCard';
import TripNowCard from '../components/TripNowCard';
import PastTripCard from '../components/PastTripCard';

const HistoryPage = ({ activeTrips }) => {
    const navigate = useNavigate();
    const { favoriteTrips, removeFavorite } = useData();
    const [pastTrips, setPastTrips] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(true);

    useEffect(() => {
        const fetchHistoryData = async () => {
            try {
                setLoadingHistory(true);
                const response = await apiService.getPasTripCard();

                if (response.data) {
                    setPastTrips(response.data);
                }
            } catch (error) {
                console.error("Gagal mengambil data history:", error);
            } finally {
                setLoadingHistory(false);
            }
        };

        fetchHistoryData();
    }, []);

    const handleRemoveAllFavorites = async () => {
        const deletePromises = favoriteTrips.map(trip => removeFavorite(trip.favorite_id));
        await Promise.all(deletePromises);
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
                            <TripNowCard 
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

                {/* --- SECTION 2: FAVOURITES (UPDATED INTEGRATION) --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Favourites</h2>
                        <button 
                            onClick={handleRemoveAllFavorites}
                            className="px-4 py-1.5 bg-slate-800 text-white text-xs font-medium rounded hover:bg-slate-700 transition"
                        >
                            Remove all
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {favoriteTrips && favoriteTrips.length > 0 ? (
                            favoriteTrips.map((item) => (
                                <FavoriteCard 
                                    key={item.favorite_id} 
                                    image={`data:image/jpeg;base64,${item.plan.banner}`}
                                    title={item.plan.title}
                                    description={item.plan.description}
                                    location={item.address || "Location Dummy"}
                                    actionIcon={<FaHeart className="text-red-600" />}
                                    onAction={() => removeFavorite(item.favorite_id)}
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
                    {loadingHistory ? (
                             <div className="p-4 text-center text-gray-400">Loading history...</div>
                        ) : pastTrips && pastTrips.length > 0 ? (
                            pastTrips.map((trip) => (
                                <PastTripCard 
                                    key={trip.plan_id}
                                    image={trip.banner}
                                    title={trip.title}
                                    description={trip.description}
                                    location={trip.address || "Location Dummy"}
                                    actionIcon={<FaTrash />} 
                                    isDanger={true}
                                    onAction={() => console.log("Delete history logic", trip.plan_id)}
                                />
                            ))
                        ) : (
                            <div className="p-4 bg-gray-50 rounded-lg text-center text-gray-400 italic">
                                No travel history found.
                            </div>
                        )}      
                    </div>
                </div>

            </div>
        </div>
    );
};

export default HistoryPage;