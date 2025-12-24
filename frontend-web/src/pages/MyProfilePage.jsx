import { FaCertificate } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import TripCard from '../components/TripCard';
import ReviewCard from '../components/ReviewCard';
import UserReviewCard from '../components/UserReviewCard';
import { useAuth } from '../context/AuthContext';
import apiService from '../services/apiService';

const MyProfilePage = ({ othersReviews }) => {
    const navigate = useNavigate();
    const { user: authUser, logout } = useAuth();
    const [myPlans, setMyPlans] = useState([]);
    const [myReviews, setMyReviews] = useState([]);

    const [profileImage, setProfileImage] = useState('');
    const [profileRank, setProfileRank] = useState('');
    const [userXP, setUserXP] = useState({});

    useEffect(() => {
        const fetchProfileData = async () => {
            if (authUser && authUser.idToken) {
                try {
                    const profileResponse = await apiService.getProfileMe();
                    const xpResponse = await apiService.getUserXP();
                    setProfileImage(profileResponse.data.photo || '');
                    setProfileRank(profileResponse.data.rank || '');
                    setUserXP(xpResponse || {});
                } catch (error) {
                    console.error("Error fetching profile data:", error);
                }
            }
        };
        fetchProfileData();
    }, [authUser]);

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    if (!authUser || !authUser.user) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <p>Loading profile...</p>
            </div>
        );
    }

    // FIX FOTO 
    const getImageSrc = () => {
      if (!profileImage) return "";

      // Base64 dari backend
      return `data:image/jpeg;base64,${profileImage}`;
    };

    const { user } = authUser;

    useEffect(() => {
    const fetchPlanByUserLogin = async () => {
      if (!authUser) {
        setMyPlans([]); // Clear plans if user logs out
        return;
      }
      try {
        const response = await apiService.getAllPlanByUserLogin();
        setMyPlans(response.data);
      } catch (error) {
        console.error("Error fetching my plans:", error);
      }
    };

    fetchPlanByUserLogin();
  }, [authUser]);

    useEffect(() => {
        const fetchMyReviews = async () => {
            if (!authUser) {
                setMyReviews([]);
                return;
            }
            try {
                const response = await apiService.getMyTripReviews();
                if (response.data && Array.isArray(response.data.data)) {
                    setMyReviews(response.data.data);
                } else {
                    setMyReviews([]);
                }
            } catch (error) {
                console.error("Error fetching my reviews:", error);
                setMyReviews([]);
            }
        };

        fetchMyReviews();
    }, [authUser]);

    return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center items-start md:items-center">
      <div className="bg-white w-full max-w-7xl p-6 md:p-10 rounded-xl shadow-sm">

        {/* BAGIAN ATAS: PROFIL & STATS */}
        <div className="flex flex-col md:flex-row items-center px-30 py-5 justify-between md:items-center gap-6 md:gap-12">
            <div className="shrink-0">
                <div className="w-32 h-32 md:w-45 md:h-45 rounded-full overflow-hidden border-4 border-gray-200 shadow-lg bg-gray-300">
                    {profileImage ? (
                        <img src={getImageSrc()} alt="Profile" className="w-full h-full object-cover" />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center text-gray-400">
                            Profile
                        </div>
                    )}
                </div>
            </div>

            <div className="flex flex-col justify-center text-center md:text-left gap-4">
                <div>
                    <h3 className="text-gray-400 text-sm font-normal mb-0.5">Name</h3>
                    <h1 className="text-xl md:text-2xl font-bold text-[#1e293b] tracking-wide">{user.username}</h1>
                </div>

                <div className="flex flex-col justify-center">
                    <h3 className="text-gray-400 text-sm font-normal mb-1">Rank’s</h3>
                    <div className="flex flex-row items-center justify-center md:justify-start gap-2">
                        <div className="relative flex items-center justify-center text-white">
                             <FaCertificate className="text-black text-3xl" /> 
                             <span className="absolute font-bold text-xs"></span>
                        </div>
                        <h2 className="text-xl font-bold text-[#1e293b]">{profileRank}</h2>
                    </div>
                </div>
            </div>

            <div className="flex flex-col gap-10 w-full md:w-auto mt-4 md:mt-0">
                <div className="flex gap-3 items-center">
                    <div className="relative flex items-center justify-center text-white shrink-0">
                        <FaCertificate className="text-[#0f172a] text-5xl drop-shadow-md" />
                        <span className="absolute font-bold text-lg"></span>
                    </div>
                    <div className="w-full">
                        <h4 className="font-bold text-[#1e293b] text-[18px]">Your Score’s</h4>
                        <p className="text-[14px] text-gray-500 font-medium">{userXP.rank}</p>
                        <p className="font-bold text-[14px] text-[#1e293b] mt-0.5">{userXP.xp}</p>
                        
                        <div className="w-40 h-1.5 bg-gray-200 rounded-full mt-1 overflow-hidden">
                            <div className="h-full bg-[#1e293b] w-[60%] rounded-full"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {/* BAGIAN TENGAH: GARIS & LINK */}
        <div className="mt-8 mb-8">
            <div className="border-t-2 border-[#1e293b] mb-4"></div>
            <div className="flex flex-col gap-2 items-center text-[#1e293b] text-base font-medium">
                <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Location</a>
                <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Languages</a>
            </div>
            <div className="border-t-2 border-[#1e293b] mt-4"></div>
        </div>

        {/* BAGIAN BAWAH: TOMBOL ACTION */}
        <div className="flex flex-col gap-3">
            <button onClick={() => navigate('/editprofile')} className="w-full py-2.5 bg-slate-900 text-white text-sm font-semibold rounded-lg hover:bg-slate-700 transition shadow-sm tracking-wide">
                Edit Profile
            </button>
            <button onClick={handleLogout} className="w-full py-2.5 bg-red-600 text-white text-sm font-semibold rounded-lg hover:bg-red-700 transition shadow-sm tracking-wide">
                Log Out
            </button>
        </div>


        {/* SECTION MY ROUTE */}
        <div className="pt-15">
            <div className="flex items-center gap-2 mb-4 cursor-pointer group">
                <h2 className="text-lg md:text-xl font-bold text-slate-900 mb-2">My Route</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {myPlans && myPlans.length > 0 ? (
                    myPlans.slice(0, 3).map((trip, index) => (
                        <div key={trip.plan_id} 
                            onClick={() => navigate(`/mytripreview/${trip.plan_id}`)}
                            className={index === 0 ? "md:col-span-2 cursor-pointer" : "cursor-pointer"}
                        >
                            <TripCard
                                key={trip.plan_id}
                                title={trip.title}
                                author={trip.description}
                                rating={trip.rating || 5}
                                image={`data:image/jpeg;base64,${trip.banner}`}
                                className={
                                    index === 0
                                    ? "md:col-span-2 h-56 md:h-72"
                                    : "h-56 md:h-60"               
                                }
                            />
                        </div>
                    ))
                ) : (
                    <div className="md:col-span-2 flex flex-col items-center justify-center py-10 text-gray-500">
                        <p className="text-center">Anda belum membuat rute apapun. Mulai rencanakan petualangan Anda berikutnya!</p>
                        <button
                            onClick={() => navigate('/maps')} 
                            className="mt-4 px-6 py-2 bg-slate-900 text-white rounded-lg hover:bg-slate-700 transition shadow-sm tracking-wide"
                        >
                            Buat Rute Baru
                        </button>
                    </div>
                )}
            </div>
        </div>

        {/* SECTION YOUR REVIEW */}
        <div className="pt-15">
            <h2 className="text-lg md:text-xl font-bold text-start text-slate-900 mb-2">
                Your review
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {myReviews.map((review) => {
                    const plan = myPlans.find(p => p.plan_id === review.plan_id);
                    return (
                        <ReviewCard
                            key={review.review_id}
                            image={plan ? `data:image/jpeg;base64,${plan.banner}` : ''}
                            title={plan ? plan.title : 'Trip not found'}
                            description={review.comment}
                            location={plan ? plan.description : 'Location not found'}
                            rating={review.rating}
                            onDelete={() => alert(`Delete review for plan ${plan ? plan.title : review.plan_id}?`)}
                        />
                    );
                })}
            </div>
        </div>

        {/* SECTION THOSE WHO REVIEW YOU */}
        <div className="pt-15 text-start">
            <div className="flex items-center gap-2 cursor-pointer group">
                <h2 className="text-lg md:text-xl font-bold text-slate-900 mb-2">Those who review you</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {othersReviews.map((item) => (
                    <UserReviewCard
                        key={item.id}
                        image={item.image}
                        name={item.name}
                        role={item.role}
                        rating={item.rating}
                        review={item.text}
                        onDelete={() => alert("Delete user review?")}
                    />
                ))}
            </div>
        </div>    

      </div>
    </div>
  );
};

export default MyProfilePage;