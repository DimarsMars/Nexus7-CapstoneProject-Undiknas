import { useEffect, useState } from 'react';
import { FaCertificate, FaChevronLeft } from "react-icons/fa";
import { useNavigate, useParams } from 'react-router-dom';

import TripCard from '../components/TripCard';
import { useAuth } from '../context/AuthContext';
import apiService from '../services/apiService';

const TravellerProfilePage = () => {
  const { id: idParam } = useParams();
  const navigate = useNavigate();
  const { user: currentUser } = useAuth(); 

  // State for profile data
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // State for social interactions
  const [isFollowing, setIsFollowing] = useState(false);
  const [followerCount, setFollowerCount] = useState(0);
  const [showReportPopup, setShowReportPopup] = useState(false); // State for report pop-up

  // --- DATA FETCHING ---
  useEffect(() => {
    const fetchProfileData = async () => {
      const id = parseInt(idParam, 10);
      if (isNaN(id)) {
        setLoading(false);
        setError('Invalid User ID');
        return;
      }

      setLoading(true);
      try {
        const profileResponse = await apiService.getUserProfileById(id);
        const userData = profileResponse.data?.data || profileResponse.data;

        if (userData && userData.user_id) {
          setProfile(userData);

          const [socialResponse, followStatusRes] = await Promise.all([
            apiService.getUserSocials(id),
            apiService.checkIsFollowing(id)
          ]);

          setFollowerCount(socialResponse?.followers_count ?? 0);
          setIsFollowing(followStatusRes?.is_following === true);

        } else {
          setError('User not found.');
        }

      } catch (err) {
        console.error("Error fetching traveller profile:", err);
        setError('Failed to fetch user profile.');
      } finally {
        setLoading(false);
      }
    };

    fetchProfileData();
  }, [idParam, currentUser]);

  // --- HELPER FUNCTIONS ---
  const getRankLevel = (rankString) => {
    if (!rankString) return '?';
    const match = rankString.match(/lvl (\d+)/i);
    return match ? match[1] : '?';
  };

  const getRankName = (rankString) => {
      if (!rankString) return '';
      return rankString.replace(/ lvl \d+/i, '').trim();
  };

  // --- HANDLERS ---
  const handleFollow = async () => {
    const id = parseInt(idParam, 10);
    if (!profile || isNaN(id) || !currentUser) return;
    if (profile.user_id === currentUser.user_id) {
      alert("You cannot follow yourself.");
      return;
    }

    const previousState = isFollowing;

    // Optimistically update state
    setIsFollowing(!previousState);
    setFollowerCount((prev) => previousState ? prev - 1 : prev + 1);

    try {
      if (previousState) {
        await apiService.unfollowUser(id);
      } else {
        await apiService.followUser(id);
      }

    } catch (error) {
      console.error("Failed to toggle follow:", error);
      setIsFollowing(previousState);
      setFollowerCount((prev) => previousState ? prev + 1 : prev - 1);
      alert("Failed to update follow status.");
    }
  };

  const handleReport = () => {
    setShowReportPopup(true);
    setTimeout(() => {
      setShowReportPopup(false);
    }, 3000); // Hide pop-up after 3 seconds
  };

  const handleCardClick = (id) => {
    navigate(`/trip/${id}`);
  };

  // --- RENDER LOGIC ---
  if (loading) {
    return (
      <div className="flex items-center justify-center w-full h-screen">
        Loading profile...
      </div>
    );
  }
  
  if (error || !profile) {
    return (
      <div className="flex items-center justify-center w-full h-screen text-base font-bold text-gray-400">
        {error}
      </div>
    );
  }

  return (
    <div className="min-h-screen px-5 py-10 bg-gray-100 pt-30 pb-20">
      <div className="max-w-7xl mx-auto">
        
        <button 
            onClick={() => navigate(-1)} 
            className="flex items-center gap-2 mb-8 font-bold text-black transition hover:text-gray-600"
        >
            <FaChevronLeft /> Back
        </button>

        <div className="flex flex-col items-center p-6 mb-10 bg-white shadow-sm rounded-xl md:flex-row md:p-15 gap-8 md:gap-12">
            <div className="shrink-0 w-32 h-32 overflow-hidden border-4 border-gray-100 rounded-full md:w-40 md:h-40">
                {profile.photo ? (
                    // Note: Assuming profile.photo is a direct URL. If it's base64, it needs conversion like in MyProfilePage.jsx
                    <img src={profile.photo} alt={profile.username} className="object-cover w-full h-full" />
                ) : (
                    <div className="flex items-center justify-center w-full h-full text-gray-400">
                        Profile
                    </div>
                )}
            </div>

            <div className="w-full text-center grow md:text-left">
                <div className="flex flex-col items-start justify-between px-20 mb-6 md:flex-row">
                    <div>
                        <p className="text-sm text-gray-500">Name</p>
                        <h1 className="mb-4 text-2xl font-bold text-gray-900 capitalize">{profile.username}</h1>
                        
                        <div className="flex items-center justify-center gap-2 md:justify-start">
                            <div className="relative flex items-center justify-center text-white">
                                <FaCertificate className="text-3xl text-black" />
                                <span className="absolute text-xs font-bold">
                                    {getRankLevel(profile.rank)}
                                </span>
                            </div>
                            <div>
                                <p className="text-xs text-gray-500">Rank's</p>
                                <p className="text-sm font-bold text-gray-900">{getRankName(profile.rank) || "Unknown"}</p>
                            </div>
                        </div>
                    </div>

                    <div className="flex justify-center w-full gap-8 mt-6 md:justify-end md:w-auto md:gap-12 md:mt-0">
                        <div className="text-center">
                            <p className="mb-1 text-sm text-gray-500">Followers</p>
                            <p className="text-lg font-bold">{followerCount}</p>
                        </div>
                        <div className="text-center">
                            <p className="mb-1 text-sm text-gray-500">Reviews</p>
                            <p className="text-lg font-bold">{profile.stats.reviews || 0}</p>
                        </div>
                        <div className="text-center">
                            <p className="mb-1 text-sm text-gray-500">Route's</p>
                            <p className="text-lg font-bold">{profile.stats.routes || 0}</p>
                        </div>
                    </div>
                </div>

                <div className="flex justify-center gap-3 px-20 pt-6 border-t md:justify-end md:border-none md:pt-0">
                    {currentUser && currentUser.user_id !== profile.user_id && (
                         <button
                            onClick={handleFollow}
                            className={`px-8 py-2 font-medium transition rounded-md ${
                                isFollowing
                                ? 'border border-gray-300 bg-gray-200 text-gray-800'
                                : 'bg-[#1e293b] text-white hover:bg-slate-700'
                            }`}
                        >
                            {isFollowing === true ? 'Unfollow' : 'Follow'}
                        </button>
                    )}
                    <button 
                        onClick={handleReport} // Call handleReport on click
                        className="px-8 py-2 font-medium text-white transition bg-red-600 rounded-md hover:bg-red-700"
                    >
                        Report
                    </button>
                </div>
            </div>
        </div>

        {/* Report Success Pop-up */}
        {showReportPopup && (
          <div className="fixed bottom-4 right-4 p-4 bg-green-500 text-white rounded-lg shadow-lg">
            User has been reported successfully!
          </div>
        )}

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            {profile.plans && profile.plans.length > 0 ? (
                profile.plans.slice(0, 3).map((trip, index) => (
                    <TripCard
                        key={trip.plan_id}
                        id={trip.plan_id}
                        title={trip.title}
                        author={trip.description}
                        rating={trip.rating || 5}
                        image={`data:image/jpeg;base64,${trip.banner}`}
                        className={
                          index === 0
                          ? "h-64 md:col-span-2 md:h-80"
                          : "h-64"
                        }
                        onClick={() => handleCardClick(trip.plan_id)}
                    />
                ))
            ) : (
                <div className="py-10 text-center text-gray-400 md:col-span-2">
                    Pengguna ini belum memiliki trip.
                </div>
            )}
        </div>
      </div>
    </div>
  );
};

export default TravellerProfilePage;