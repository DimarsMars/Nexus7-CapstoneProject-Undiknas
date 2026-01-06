import { FaCertificate } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';

import Swal from 'sweetalert2'; // Import SweetAlert untuk notifikasi

// Import komponen kustom untuk menampilkan data trip dan ulasan
import TripCard from '../components/TripCard';
import ReviewCard from '../components/ReviewCard';
import UserReviewCard from '../components/UserReviewCard';

// Import context dan service untuk manajemen autentikasi dan pemanggilan API
import { useAuth } from '../context/AuthContext';
import apiService from '../services/apiService';

const MyProfilePage = () => {
    // Inisialisasi hook untuk navigasi antar halaman
    const navigate = useNavigate();
    
    // Mengambil data user yang sedang login dan fungsi logout dari AuthContext
    const { user: authUser, logout } = useAuth();
    
    // --- STATE MANAGEMENT ---
    
    // State untuk menyimpan informasi profil pengguna (Foto, Rank, dan XP)
    const [profileImage, setProfileImage] = useState('');
    const [profileRank, setProfileRank] = useState('');
    const [userXP, setUserXP] = useState({});
    
    // State untuk menyimpan daftar konten (Rencana perjalanan, Ulasan saya, dan Ulasan orang lain)
    const [myPlans, setMyPlans] = useState([]);
    const [myReviews, setMyReviews] = useState([]);
    const [reviewsOnMyPlans, setReviewsOnMyPlans] = useState([]);

    // State untuk mengontrol tampilan semua rute
    const [showAllRoutes, setShowAllRoutes] = useState(false);

    // --- DATA FETCHING ---
    
    // useEffect untuk mengambil seluruh data dari server saat komponen dimuat atau authUser berubah
    useEffect(() => {
        const fetchAllData = async () => {
            // Validasi: Jika user tidak login atau token tidak ada, reset semua state dan berhenti
            if (!authUser || !authUser.idToken) {
                setProfileImage('');
                setProfileRank('');
                setUserXP({});
                setMyPlans([]);
                setMyReviews([]);
                setReviewsOnMyPlans([]);
                return;
            }

            try {
                // Mengambil data dari berbagai endpoint secara paralel untuk efisiensi waktu loading
                const [
                    profileResponse, 
                    xpResponse, 
                    plansResponse, 
                    myReviewsResponse, 
                    reviewsOnMyPlansResponse
                ] = await Promise.all([
                    apiService.getProfileMe(),
                    apiService.getUserXP(),
                    apiService.getAllPlanByUserLogin(),
                    apiService.getMyTripReviews(),
                    apiService.getReviewsOnMyPlans()
                ]);

                // Menyimpan data profil dasar ke dalam state
                setProfileImage(profileResponse.data.photo || '');
                setProfileRank(profileResponse.data.rank || '');
                setUserXP(xpResponse || {});

                // Menyimpan daftar rencana perjalanan (plans) milik user
                setMyPlans(plansResponse.data || []);
                
                // Logika penanganan data ulasan saya (menangani variasi struktur data dari API)
                let myReviewsData = [];
                if (Array.isArray(myReviewsResponse.data)) {
                    myReviewsData = myReviewsResponse.data;
                } else if (myReviewsResponse.data && Array.isArray(myReviewsResponse.data.data)) {
                    myReviewsData = myReviewsResponse.data.data;
                }
                setMyReviews(myReviewsData);

                // Logika penanganan data ulasan yang diterima user pada rencana perjalanannya
                let reviewsOnMyPlansData = [];
                if (Array.isArray(reviewsOnMyPlansResponse.data)) {
                    reviewsOnMyPlansData = reviewsOnMyPlansResponse.data;
                } else if (reviewsOnMyPlansResponse.data && Array.isArray(reviewsOnMyPlansResponse.data.data)) {
                    reviewsOnMyPlansData = reviewsOnMyPlansResponse.data.data;
                }
                setReviewsOnMyPlans(reviewsOnMyPlansData);

            } catch (error) {
                // Menampilkan error pada console jika proses fetching gagal
                console.error("Error fetching profile page data:", error);
            }
        };

        fetchAllData();
    }, [authUser]); // Dependensi pada authUser memastikan data diperbarui jika user berubah

    // --- HANDLERS (Fungsi Interaksi) ---
    
    // Fungsi untuk keluar dari akun dan diarahkan kembali ke halaman login
    const handleLogout = () => {
        logout();
        navigate('/login');
    };
    
    // Fungsi untuk mengarahkan user ke halaman detail rencana perjalanan tertentu
    const handleCardClick = (id) => {
        navigate(`/trip/${id}`);
    };

    // Fungsi asinkron untuk menghapus ulasan berdasarkan ID ulasan
    const handleDeleteReview = async (reviewId) => {
        // Konfirmasi keamanan sebelum menghapus data
        const result = await Swal.fire({
        title: 'Apakah Anda yakin?',
        text: "Ulasan yang dihapus tidak dapat dikembalikan!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#1e293b',
        cancelButtonColor: '#ef4444',
        confirmButtonText: 'Ya, Hapus!',
        cancelButtonText: 'Batal',
    });

    // Jika user menekan tombol "Batal", hentikan fungsi
    if (!result.isConfirmed) return;

        try {
            // Memanggil API delete dan memperbarui state secara lokal untuk sinkronisasi UI
            await apiService.deleteReviewTrips(reviewId);
            setMyReviews((prevReviews) => prevReviews.filter((review) => review.review_id !== reviewId));
            // Menampilkan Pop-up Berhasil
            Swal.fire({
                title: 'Terhapus!',
                text: 'Ulasan Anda telah berhasil dihapus.',
                icon: 'success',
                confirmButtonColor: '#1e293b',
            });
        } catch (error) {
            console.error("Gagal menghapus review:", error);
            // Menampilkan Pop-up Gagal
            Swal.fire({
                title: 'Gagal!',
                text: 'Gagal menghapus ulasan. Silakan coba lagi.',
                icon: 'error',
                confirmButtonColor: '#1e293b',
            });
        }
    };

    // --- HELPER FUNCTIONS (Fungsi Pembantu) ---
    
    // Mengonversi data string base64 menjadi format sumber gambar yang valid (data URI)
    const getImageSrc = (base64Image) => {
        if (!base64Image) return "";
        return `data:image/jpeg;base64,${base64Image}`;
    };

    // Ekstraksi angka level dari string rank (Contoh: "Traveler lvl 10" menjadi "10")
    const getRankLevel = (rankString) => {
        if (!rankString) return '?';
        const match = rankString.match(/lvl (\d+)/i);
        return match ? match[1] : '?';
    };

    // Ekstraksi nama rank dengan menghapus bagian level (Contoh: "Traveler lvl 10" menjadi "Traveler")
    const getRankName = (rankString) => {
        if (!rankString) return '';
        return rankString.replace(/ lvl \d+/i, '').trim();
    };

    // --- RENDER LOGIC (Tampilan UI) ---
    
    // Menampilkan layar loading sementara jika data user belum tersedia
    if (!authUser || !authUser.user) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <p>Loading profile...</p>
            </div>
        );
    }
    
    // Destructuring data user dan menghitung persentase progres XP untuk progress bar (skala 100)
    const { user } = authUser;
    const progressPercentage = (userXP.xp || 0) % 100;

    return (
        <div className="flex items-start justify-center min-h-screen px-5 py-10 bg-gray-100 pt-30 md:items-center">
            <div className="w-full max-w-7xl p-6 bg-white rounded-xl shadow-sm md:p-10">

                {/* Bagian Header Profil: Foto, Nama, dan Informasi Rank/XP */}
                <div className="flex flex-col items-center justify-between gap-6 md:flex-row md:gap-12 md:items-center px-30">
                    {/* Foto Profil */}
                    <div className="shrink-0">
                        <div className="overflow-hidden bg-gray-300 border-4 border-gray-200 rounded-full w-32 h-32 md:w-45 md:h-45 shadow-lg">
                            {profileImage ? (
                                <img src={getImageSrc(profileImage)} alt="Profile" className="object-cover w-full h-full" />
                            ) : (
                                <div className="flex items-center justify-center w-full h-full text-gray-400">Profile</div>
                            )}
                        </div>
                    </div>

                    {/* Detail Teks Profil (Nama & Rank Dasar) */}
                    <div className="flex flex-col justify-center gap-4 text-center md:text-left">
                        <div>
                            <h3 className="mb-0.5 text-sm font-normal text-gray-400">Name</h3>
                            <h1 className="text-xl md:text-2xl font-bold text-[#1e293b] tracking-wide capitalize">{user.username}</h1>
                        </div>
                        <div className="flex flex-col justify-center">
                            <h3 className="mb-1 text-sm font-normal text-gray-400">Rank’s</h3>
                            <div className="flex flex-row items-center justify-center gap-2 md:justify-start">
                                <div className="relative flex items-center justify-center text-white">
                                    <FaCertificate className="text-3xl text-black" />
                                    <span className="absolute text-xs font-bold">
                                        {getRankLevel(profileRank)}
                                    </span>
                                </div>
                                <h2 className="text-xl font-bold text-[#1e293b]">{getRankName(profileRank)}</h2>
                            </div>
                        </div>
                    </div>

                    {/* Bagian Visual Score/XP dan Progress Bar */}
                    <div className="flex flex-col w-full gap-10 mt-4 md:w-auto md:mt-0">
                        <div className="flex items-center gap-3">
                            <div className="relative flex items-center justify-center text-white shrink-0">
                                <FaCertificate className="text-5xl text-[#0f172a] drop-shadow-md" />
                                <span className="absolute text-md font-bold">
                                    {getRankLevel(profileRank)}
                                </span>
                            </div>
                            <div className="w-full">
                                <h4 className="font-bold text-[#1e293b] text-[18px]">Your Score’s</h4>
                                <p className="text-[14px] font-medium text-gray-500">{getRankName(userXP.rank)}</p>
                                <p className="font-bold text-[14px] text-[#1e293b] mt-0.5">{userXP.xp} XP</p>
                                
                                {/* Progress Bar Visual */}
                                <div className="w-40 h-1.5 mt-1 overflow-hidden bg-gray-200 rounded-full">
                                    <div 
                                        className="h-full bg-[#1e293b] rounded-full transition-all duration-500 ease-out" 
                                        style={{ width: `${progressPercentage}%` }}
                                    ></div>
                                </div>
                                <p className="text-[10px] text-gray-400 mt-0.5">{100 - progressPercentage} XP to next level</p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Bagian Navigasi Statis (Location & Languages) */}
                <div className="py-8">
                    <div className="border-t-2 border-[#1e293b]"></div>
                </div>

                {/* Tombol Aksi: Edit dan Logout */}
                <div className="flex flex-col gap-3">
                    <button onClick={() => navigate('/editprofile')} className="w-full py-2.5 text-sm font-semibold text-white bg-slate-900 rounded-lg tracking-wide transition shadow-sm hover:bg-slate-700">
                        Edit Profile
                    </button>
                    <button onClick={handleLogout} className="w-full py-2.5 text-sm font-semibold text-white bg-red-600 rounded-lg tracking-wide transition shadow-sm hover:bg-red-700">
                        Log Out
                    </button>
                </div>

                {/* Section: My Routes (Menampilkan maksimal 3 rencana perjalanan terbaru) */}
                <div className="pt-12">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="text-lg font-bold text-slate-900 md:text-xl text-start">My Route</h2>
                        {/* Tombol pemicu: Muncul hanya jika total rencana lebih dari 3 */}
                        {myPlans.length > 3 && (
                            <button 
                                onClick={() => setShowAllRoutes(!showAllRoutes)}
                                className="text-md font-semibold text-slate-700 hover:text-slate-900 transition"
                            >
                                {showAllRoutes ? "Tampilkan Sedikit" : `Lihat Semua (${myPlans.length})`}
                            </button>
                        )}
                    </div>

                    <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
                        {myPlans.length > 0 ? (
                            // Jika showAllRoutes true, tampilkan semua. Jika false, potong hanya 3 data pertama.
                            (showAllRoutes ? myPlans : myPlans.slice(0, 3)).map((trip, index) => (
                                <TripCard
                                    key={trip.plan_id}
                                    id={trip.plan_id}
                                    title={trip.title}
                                    author={trip.author_name || "Unknown Author"}
                                    rating={trip.rating}
                                    image={getImageSrc(trip.banner)}
                                    // Logika index === 0 agar kartu pertama selalu besar
                                    className={index === 0 ? "h-56 md:col-span-2 md:h-72" : "h-56 md:h-60"}
                                    onClick={() => handleCardClick(trip.plan_id)}
                                />
                            ))
                        ) : (
                            /* State Kosong untuk My Route */
                            <div className="flex flex-col items-center justify-center py-10 text-gray-500 md:col-span-2">
                                <p className="text-center">Anda belum membuat rute apapun. Mulai rencanakan petualangan Anda berikutnya!</p>
                                <button onClick={() => navigate('/maps')} className="px-6 py-2 mt-4 text-white bg-slate-900 rounded-lg tracking-wide transition shadow-sm hover:bg-slate-700">
                                    Buat Rute Baru
                                </button>
                            </div>
                        )}
                    </div>
                </div>

                {/* Section: Your Review (Ulasan yang diberikan oleh user ini) */}
                <div className="pt-12">
                    <h2 className="mb-4 text-lg font-bold text-left text-slate-900 md:text-xl">Your review</h2>
                    <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
                        {myReviews.length > 0 ? (
                            myReviews.map((review) => (
                                <ReviewCard
                                    key={review.review_id}
                                    image={review.plan?.banner}
                                    title={review.plan?.title}
                                    description={review.comment}
                                    location={review.plan?.description || 'Location not found'}
                                    rating={review.rating}
                                    onDelete={() => handleDeleteReview(review.review_id)}
                                />
                            ))
                        ) : (
                            /* State Kosong untuk Your Review */
                            <div className="flex flex-col items-center justify-center py-10 text-gray-500 md:col-span-2">
                                <p className="text-center">Anda belum membuat ulasan apapun.</p>
                            </div>
                        )}
                    </div>
                </div>

                {/* Section: Those who review you (Ulasan dari orang lain untuk rencana user) */}
                <div className="pt-12 text-left">
                    <h2 className="mb-4 text-lg font-bold text-slate-900 md:text-xl">Those who review you</h2>
                    <div className="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                        {reviewsOnMyPlans.length > 0 ? (
                            reviewsOnMyPlans.map((item) => (
                                <UserReviewCard
                                    key={item.review_id}
                                    userId={item.user.user_id}
                                    image={item.user.photo} 
                                    name={item.user.username}
                                    role={item.user.rank}
                                    rating={item.rating}
                                    review={item.comment}
                                />
                            ))
                        ) : (
                            /* State Kosong untuk Those who review you */
                            <div className="flex flex-col items-center justify-center py-10 text-gray-500 md:col-span-3">
                                <p className="text-center">Belum ada yang mengulas trip Anda.</p>
                            </div>
                        )}
                    </div>
                </div>

            </div>
        </div>
    );
};

export default MyProfilePage;