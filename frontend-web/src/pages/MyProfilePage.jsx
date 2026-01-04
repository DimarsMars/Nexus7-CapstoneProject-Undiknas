import { FaCertificate } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';

import TripCard from '../components/TripCard';
import ReviewCard from '../components/ReviewCard';
import UserReviewCard from '../components/UserReviewCard';
import { useAuth } from '../context/AuthContext';
import apiService from '../services/apiService';

const MyProfilePage = () => {
    const navigate = useNavigate();
    const { user: authUser, logout } = useAuth();
    
    // State for user data
    const [profileImage, setProfileImage] = useState('');
    const [profileRank, setProfileRank] = useState('');
    const [userXP, setUserXP] = useState({});
    
    // State for content
    const [myPlans, setMyPlans] = useState([]);
    const [myReviews, setMyReviews] = useState([]);
    const [reviewsOnMyPlans, setReviewsOnMyPlans] = useState([]);

    // --- DATA FETCHING ---
    useEffect(() => {
        const fetchAllData = async () => {
            if (!authUser || !authUser.idToken) {
                // Clear all data if user is not authenticated
                setProfileImage('');
                setProfileRank('');
                setUserXP({});
                setMyPlans([]);
                setMyReviews([]);
                setReviewsOnMyPlans([]);
                return;
            }

            try {
                // Fetch all data in parallel
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

                // Set Profile Data
                setProfileImage(profileResponse.data.photo || '');
                setProfileRank(profileResponse.data.rank || '');
                setUserXP(xpResponse || {});

                // Set Plans Data
                setMyPlans(plansResponse.data || []);
                
                // Set My Reviews Data
                let myReviewsData = [];
                if (Array.isArray(myReviewsResponse.data)) {
                    myReviewsData = myReviewsResponse.data;
                } else if (myReviewsResponse.data && Array.isArray(myReviewsResponse.data.data)) {
                    myReviewsData = myReviewsResponse.data.data;
                }
                setMyReviews(myReviewsData);

                // Set Reviews on My Plans Data
                let reviewsOnMyPlansData = [];
                if (Array.isArray(reviewsOnMyPlansResponse.data)) {
                    reviewsOnMyPlansData = reviewsOnMyPlansResponse.data;
                } else if (reviewsOnMyPlansResponse.data && Array.isArray(reviewsOnMyPlansResponse.data.data)) {
                    reviewsOnMyPlansData = reviewsOnMyPlansResponse.data.data;
                }
                setReviewsOnMyPlans(reviewsOnMyPlansData);

            } catch (error) {
                console.error("Error fetching profile page data:", error);
            }
        };

        fetchAllData();
    }, [authUser]);

    // --- HANDLERS ---
    const handleLogout = () => {
        logout();
        navigate('/login');
    };
    
    const handleCardClick = (id) => {
        navigate(`/trip/${id}`);
    };

    const handleDeleteReview = async (reviewId) => {
        if (!window.confirm("Apakah Anda yakin ingin menghapus ulasan ini?")) return;

        try {
            await apiService.deleteReviewTrips(reviewId);
            setMyReviews((prevReviews) => prevReviews.filter((review) => review.review_id !== reviewId));
            alert("Ulasan berhasil dihapus.");
        } catch (error) {
            console.error("Gagal menghapus review:", error);
            alert("Gagal menghapus ulasan. Silakan coba lagi.");
        }
    };

    // --- HELPER FUNCTIONS ---
    const getImageSrc = (base64Image) => {
        if (!base64Image) return "";
        return `data:image/jpeg;base64,${base64Image}`;
    };

    const getRankLevel = (rankString) => {
        if (!rankString) return '?';
        const match = rankString.match(/lvl (\d+)/i);
        return match ? match[1] : '?';
    };

    const getRankName = (rankString) => {
        if (!rankString) return '';
        return rankString.replace(/ lvl \d+/i, '').trim();
    };

    // --- RENDER LOGIC ---
    if (!authUser || !authUser.user) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <p>Loading profile...</p>
            </div>
        );
    }
    
    const { user } = authUser;
    const progressPercentage = (userXP.xp || 0) % 100;

    return (
        <div className="flex items-start justify-center min-h-screen px-5 py-10 bg-gray-100 pt-30 md:items-center">
            <div className="w-full max-w-7xl p-6 bg-white rounded-xl shadow-sm md:p-10">

                {/* Profile Header */}
                <div className="flex flex-col items-center justify-between gap-6 md:flex-row md:gap-12 md:items-center px-30">
                    <div className="shrink-0">
                        <div className="overflow-hidden bg-gray-300 border-4 border-gray-200 rounded-full w-32 h-32 md:w-45 md:h-45 shadow-lg">
                            {profileImage ? (
                                <img src={getImageSrc(profileImage)} alt="Profile" className="object-cover w-full h-full" />
                            ) : (
                                <div className="flex items-center justify-center w-full h-full text-gray-400">Profile</div>
                            )}
                        </div>
                    </div>

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

                {/* Divider & Links */}
                <div className="my-8">
                    <div className="border-t-2 border-[#1e293b]"></div>
                    <div className="flex flex-col items-center gap-2 my-4 text-base font-medium text-[#1e293b]">
                        <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Location</a>
                        <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Languages</a>
                    </div>
                    <div className="border-t-2 border-[#1e293b]"></div>
                </div>

                {/* Action Buttons */}
                <div className="flex flex-col gap-3">
                    <button onClick={() => navigate('/editprofile')} className="w-full py-2.5 text-sm font-semibold text-white bg-slate-900 rounded-lg tracking-wide transition shadow-sm hover:bg-slate-700">
                        Edit Profile
                    </button>
                    <button onClick={handleLogout} className="w-full py-2.5 text-sm font-semibold text-white bg-red-600 rounded-lg tracking-wide transition shadow-sm hover:bg-red-700">
                        Log Out
                    </button>
                </div>

                {/* My Routes Section */}
                <div className="pt-12">
                    <h2 className="mb-4 text-lg font-bold text-slate-900 md:text-xl text-start">My Route</h2>
                    <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
                        {myPlans.length > 0 ? (
                            myPlans.slice(0, 3).map((trip, index) => (
                                <TripCard
                                    key={trip.plan_id}
                                    id={trip.plan_id}
                                    title={trip.title}
                                    author={trip.description}
                                    rating={trip.rating || 5}
                                    image={getImageSrc(trip.banner)}
                                    className={index === 0 ? "h-56 md:col-span-2 md:h-72" : "h-56 md:h-60"}
                                    onClick={() => handleCardClick(trip.plan_id)}
                                />
                            ))
                        ) : (
                            <div className="flex flex-col items-center justify-center py-10 text-gray-500 md:col-span-2">
                                <p className="text-center">Anda belum membuat rute apapun. Mulai rencanakan petualangan Anda berikutnya!</p>
                                <button onClick={() => navigate('/maps')} className="px-6 py-2 mt-4 text-white bg-slate-900 rounded-lg tracking-wide transition shadow-sm hover:bg-slate-700">
                                    Buat Rute Baru
                                </button>
                            </div>
                        )}
                    </div>
                </div>

                {/* Your Reviews Section */}
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
                            <div className="flex flex-col items-center justify-center py-10 text-gray-500 md:col-span-2">
                                <p className="text-center">Anda belum membuat ulasan apapun.</p>
                            </div>
                        )}
                    </div>
                </div>

                {/* Reviews on Your Plans Section */}
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