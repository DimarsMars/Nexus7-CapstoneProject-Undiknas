import { useNavigate } from 'react-router-dom';
import { FaArrowRight, FaTrash, FaHeart } from "react-icons/fa";
import { useData } from '../context/DataContext';
import FavoriteCard from '../components/FavoriteCard';
import TripNowCard from '../components/TripNowCard';
import PastTripCard from '../components/PastTripCard';

const HistoryPage = ({ activeTrips, pastTrips }) => {
    const navigate = useNavigate();
    // Gunakan fungsi dari Context yang sudah diupdate
    const { favoriteTrips, removeFavorite } = useData();

    // Fungsi remove all (Looping delete)
    const handleRemoveAllFavorites = async () => {
        // Karena delete bersifat async, kita lakukan Promise.all agar paralel
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
                                // Perhatikan mapping data di sini berdasarkan response GET
                                <FavoriteCard 
                                    key={item.favorite_id} 
                                    // Akses ke dalam object 'plan'
                                    image={item.plan.banner ? `data:image/jpeg;base64,${item.plan.banner}` : 'placeholder_url'}
                                    title={item.plan.title}
                                    description={item.plan.description}
                                    // Response GET favorite belum menyertakan lokasi spesifik, 
                                    // kita bisa pakai default atau kosongkan dulu.
                                    location="Saved Location" 
                                    actionIcon={<FaHeart className="text-red-600" />}
                                    // Panggil removeFavorite dengan favorite_id
                                    onAction={() => removeFavorite(item.favorite_id)}
                                    // Tambahkan onClick card agar bisa navigate ke detail (opsional)
                                    onClick={() => navigate(`/trip/${item.plan_id}`)}
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
                            <PastTripCard 
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