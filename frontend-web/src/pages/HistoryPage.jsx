import { useCallback, useEffect, useState } from 'react'; // Added useCallback
import { FaArrowRight, FaHeart, FaTrash } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import FavoriteCard from '../components/FavoriteCard';
import PastTripCard from '../components/PastTripCard';
import TripNowCard from '../components/TripNowCard';
import { useData } from '../context/DataContext';
import apiService from '../services/apiService';

const HistoryPage = () => {
    const navigate = useNavigate();
    const { favoriteTrips, removeFavorite } = useData();
    const [pastTrips, setPastTrips] = useState([]);
    const [activeTrips, setActiveTrips] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(true);
    const [loadingActiveTrips, setLoadingActiveTrips] = useState(true);

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

        const fetchActiveTrips = async () => {
            try {
                setLoadingActiveTrips(true);
                const response = await apiService.getActiveTrip();
                if (response.data) {
                    setActiveTrips(response.data);
                }
            } catch (error) {
                console.error("Gagal mengambil trip aktif:", error);
            } finally {
                setLoadingActiveTrips(false);
            }
        };

        fetchHistoryData();
        fetchActiveTrips();
    }, []);

    const handleDeleteHistory = useCallback(async (progressId) => {
        const isConfirmed = window.confirm("Apakah Anda yakin ingin menghapus riwayat perjalanan ini?");
        if (!isConfirmed) return;

        try {
            await apiService.deletePastTripPlan(progressId);
            setPastTrips((prev) => prev.filter((trip) => trip.progress_id !== progressId));
            alert("Riwayat perjalanan berhasil dihapus.");
        } catch (error) {
            console.error("Gagal menghapus history:", error);
            alert("Gagal menghapus data. Silakan coba lagi.");
        }
    }, []);

    const handleRemoveAllFavorites = useCallback(async () => {
        const isConfirmed = window.confirm("Apakah Anda yakin ingin menghapus SEMUA favorit Anda?");
        if (!isConfirmed) return;
        try {
            const deletePromises = favoriteTrips.map(trip => removeFavorite(trip.favorite_id));
            await Promise.all(deletePromises);
            alert("Semua favorit berhasil dihapus.");
        } catch (error) {
            console.error("Gagal menghapus semua favorit:", error);
        }
    }, [favoriteTrips, removeFavorite]);

    const handleCancelTripNow = useCallback(async () => {
        if (activeTrips.length === 0) {
            alert("Tidak ada trip aktif.");
            return;
        }
        const isConfirmed = window.confirm("Yakin ingin membatalkan semua trip yang sedang berjalan?");
        if (!isConfirmed) return;

        try {
            await Promise.all(
                activeTrips.map(trip => apiService.cancelTripSessions(trip.Plan.plan_id))
            );
            alert("Semua trip berhasil dibatalkan.");
            setActiveTrips([]);
        } catch (error) {
            console.error("Gagal cancel trip:", error);
            alert("Gagal membatalkan trip.");
        }
    }, [activeTrips]);


    return (
        <div className="min-h-screen bg-gray-100 py-10 px-5 pt-24 md:pt-30">
            <div className="max-w-7xl mx-auto space-y-10 text-left">
                
                {/* --- SECTION 1: YOUR TRIP NOW --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Your Trip Now</h2>
                        <button 
                            onClick={handleCancelTripNow}
                            className="px-4 py-1.5 bg-slate-800 text-white text-xs font-medium rounded hover:bg-slate-700 transition"
                        >
                            Cancel All
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {loadingActiveTrips ? (
                            <div className="p-4 text-center text-gray-400">Loading active trips...</div>
                        ) : activeTrips.length > 0 ? (
                            activeTrips.map((session) => (
                                <TripNowCard 
                                    key={session.session_id}
                                    image={`data:image/jpeg;base64,${session.Plan.banner}`}
                                    title={session.Plan.title}
                                    description={session.Plan.description}
                                    location={session.Plan.routes[0]?.address || "Unknown"}
                                    actionIcon={<FaArrowRight />} 
                                    onAction={() => navigate(`/runtrip/${session.Plan.plan_id}`)}
                                />
                            ))
                        ) : (
                            <div className="p-4 bg-gray-50 rounded-lg text-center text-gray-400 italic">
                                You have no active trips right now.
                            </div>
                        )}
                    </div>
                </div>

                {/* --- SECTION 2: FAVOURITES --- */}
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
                                    location={item.plan.routes[0].address}
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
                        <h2 className="text-xl font-bold text-slate-900">Your Past Trips</h2> {/* Typo fixed */}
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
                                    location={trip.routes[0].address}
                                    actionIcon={<FaTrash />} 
                                    isDanger={true}
                                    onAction={() => handleDeleteHistory(trip.progress_id)}
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