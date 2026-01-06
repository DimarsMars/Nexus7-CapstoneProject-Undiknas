import { useCallback, useEffect, useState } from 'react'; // Mengimpor hooks inti React
import { FaArrowRight, FaHeart, FaTrash } from "react-icons/fa"; // Mengimpor ikon dari font-awesome
import { useNavigate } from 'react-router-dom'; // Mengimpor hook untuk navigasi antar halaman

import Swal from 'sweetalert2'; // Mengimpor SweetAlert2 untuk notifikasi pop-up

// Mengimpor komponen kartu kustom untuk berbagai kategori trip
import FavoriteCard from '../components/FavoriteCard';
import PastTripCard from '../components/PastTripCard';
import TripNowCard from '../components/TripNowCard';

// Mengimpor data global dari context dan layanan API
import { useData } from '../context/DataContext';
import apiService from '../services/apiService';

const HistoryPage = () => {
    // Inisialisasi hook navigasi
    const navigate = useNavigate();

    // Mengambil data favorit dan fungsi penghapusan dari DataContext
    const { favoriteTrips, removeFavorite } = useData();

    // State untuk menyimpan daftar perjalanan (past trip dan active trip) serta status loading
    const [pastTrips, setPastTrips] = useState([]);
    const [activeTrips, setActiveTrips] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(true);
    const [loadingActiveTrips, setLoadingActiveTrips] = useState(true);

    // Effect hook untuk memicu pengambilan data saat komponen pertama kali dimuat
    useEffect(() => {
        // Fungsi asinkron untuk mengambil data riwayat perjalanan masa lalu dari API
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

        // Fungsi asinkron untuk mengambil data perjalanan yang sedang aktif dari API
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

        // Menjalankan proses fetching data
        fetchHistoryData();
        fetchActiveTrips();
    }, []);

    // Fungsi untuk menghapus satu item riwayat perjalanan berdasarkan progressId
    const handleDeleteHistory = useCallback(async (progressId) => {
        const result = await Swal.fire({
            title: 'Hapus Riwayat?',
            text: "Data perjalanan ini akan dihapus permanen dari riwayat Anda.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#1e293b',
            cancelButtonColor: '#ef4444',
            confirmButtonText: 'Ya, Hapus!',
            cancelButtonText: 'Batal',
        });
        // Jika user menekan tombol "Batal", hentikan proses
        if (!result.isConfirmed) return;

        try {
            await apiService.deletePastTripPlan(progressId);
            // Memperbarui state secara lokal untuk menghapus item dari tampilan
            setPastTrips((prev) => prev.filter((trip) => trip.progress_id !== progressId));
            // Menampilkan Pop-up Sukses
            Swal.fire({
                title: 'Terhapus!',
                text: 'Riwayat perjalanan berhasil dihapus.',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
        } catch (error) {
            console.error("Gagal menghapus history:", error);
            // Menampilkan Pop-up Gagal
            Swal.fire({
                title: 'Gagal!',
                text: 'Terjadi kesalahan. Silakan coba beberapa saat lagi.',
                icon: 'error',
                confirmButtonColor: '#1e293b',
            });
        }
    }, []);

    // Fungsi untuk menghapus seluruh daftar favorit secara massal menggunakan Promise.all
    const handleRemoveAllFavorites = useCallback(async () => {
        // Munculkan Pop-up Konfirmasi
        const result = await Swal.fire({
            title: 'Hapus Semua Favorit?',
            text: "Seluruh daftar perjalanan favorit Anda akan dikosongkan!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#1e293b',
            cancelButtonColor: '#ef4444',
            confirmButtonText: 'Ya, Hapus Semua!',
            cancelButtonText: 'Batal',
        });
        // Jika user membatalkan, berhenti di sini
        if (!result.isConfirmed) return;

        try {
            // Memetakan semua item favorit ke dalam array promise untuk dihapus sekaligus
            const deletePromises = favoriteTrips.map(trip => removeFavorite(trip.favorite_id));
            await Promise.all(deletePromises);
            // Menampilkan Feedback Sukses
            Swal.fire({
                title: 'Berhasil!',
                text: 'Daftar favorit Anda telah dikosongkan.',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
        } catch (error) {
            console.error("Gagal menghapus semua favorit:", error);

            // Menampilkan Feedback Gagal
            Swal.fire({
                title: 'Gagal!',
                text: 'Terjadi kesalahan saat menghapus data.',
                icon: 'error',
                confirmButtonColor: '#1e293b',
            });
        }
    }, [favoriteTrips, removeFavorite]);

    // Fungsi untuk menghapus seluruh riwayat perjalanan
    const handleRemoveAllHistory = useCallback(async () => {
        if (pastTrips.length === 0) {
            Swal.fire({
                title: 'Info',
                text: 'Tidak ada riwayat perjalanan yang bisa dihapus.',
                icon: 'info',
                confirmButtonColor: '#1e293b',
            });
            return;
        }

        const result = await Swal.fire({
            title: 'Hapus Semua Riwayat?',
            text: "Seluruh riwayat perjalanan Anda akan dihapus permanen!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#1e293b',
            cancelButtonColor: '#ef4444',
            confirmButtonText: 'Ya, Hapus Semua!',
            cancelButtonText: 'Batal',
        });

        if (!result.isConfirmed) return;

        try {
            const deletePromises = pastTrips.map(trip => apiService.deletePastTripPlan(trip.progress_id));
            await Promise.all(deletePromises);
            
            setPastTrips([]);

            Swal.fire({
                title: 'Berhasil!',
                text: 'Semua riwayat perjalanan Anda telah dihapus.',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
        } catch (error) {
            console.error("Gagal menghapus semua riwayat:", error);
            Swal.fire({
                title: 'Gagal!',
                text: 'Terjadi kesalahan saat menghapus riwayat.',
                icon: 'error',
                confirmButtonColor: '#1e293b',
            });
        }
    }, [pastTrips]);

    // Fungsi untuk membatalkan semua perjalanan yang sedang aktif secara massal
    const handleCancelTripNow = useCallback(async () => {
        if (activeTrips.length === 0) {
            Swal.fire({
                title: 'Info',
                text: 'Tidak ada perjalanan aktif yang bisa dibatalkan.',
                icon: 'info',
                confirmButtonColor: '#1e293b',
            });
            return;
        }
        // Konfirmasi Pembatalan
        const result = await Swal.fire({
            title: 'Batalkan Semua Trip?',
            text: "Seluruh perjalanan yang sedang berjalan akan dihentikan paksa!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#1e293b',
            cancelButtonColor: '#ef4444',
            confirmButtonText: 'Ya, Batalkan Semua!',
            cancelButtonText: 'Batal',
        });
        // Jika user menekan "Batal", berhenti di sini
        if (!result.isConfirmed) return;

        try {
            // Mengirim request pembatalan ke API untuk setiap session trip aktif
            await Promise.all(
                activeTrips.map(trip => apiService.cancelTripSessions(trip.Plan.plan_id))
            );

            setActiveTrips([]); // Mengosongkan state trip aktif
            // Feedback Sukses
            Swal.fire({
                title: 'Berhasil Dibatalkan',
                text: 'Semua sesi perjalanan Anda telah dihentikan.',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
        } catch (error) {
            console.error("Gagal cancel trip:", error);
            // Feedback Gagal
            Swal.fire({
                title: 'Gagal Membatalkan',
                text: 'Terjadi kesalahan sistem. Silakan coba lagi.',
                icon: 'error',
                confirmButtonColor: '#1e293b',
            });
        }
    }, [activeTrips]);


    return (
        <div className="min-h-screen bg-gray-100 py-10 px-5 pt-24 md:pt-30">
            <div className="max-w-7xl mx-auto space-y-10 text-left">
                
                {/* --- SEKSI 1: PERJALANAN AKTIF SAAT INI --- */}
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
                            // Melakukan iterasi untuk menampilkan daftar trip aktif
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

                {/* --- SEKSI 2: DAFTAR FAVORIT --- */}
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
                            // Melakukan iterasi untuk menampilkan daftar trip yang difavoritkan
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

                {/* --- SEKSI 3: RIWAYAT PERJALANAN MASA LALU --- */}
                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-bold text-slate-900">Your Past Trips</h2> 
                        <button 
                            onClick={handleRemoveAllHistory}
                            className="px-4 py-1.5 bg-slate-800 text-white text-xs font-medium rounded hover:bg-slate-700 transition"
                        >
                            Remove all
                        </button>
                    </div>
                    <div className="flex flex-col gap-4">
                        {loadingHistory ? (
                             <div className="p-4 text-center text-gray-400">Loading history...</div>
                        ) : pastTrips && pastTrips.length > 0 ? (
                            // Melakukan iterasi untuk menampilkan daftar riwayat perjalanan
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