import { useEffect, useState, useContext } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaCertificate } from "react-icons/fa";
import TripCard from '../components/TripCard';
import apiService from '../services/apiService';
import { useAuth } from '../context/AuthContext';

const TravellerProfilePage = () => {
  const { id: idParam } = useParams();
  const navigate = useNavigate();
  const { user: currentUser } = useAuth(); 

  // State
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // State Social
  const [isFollowing, setIsFollowing] = useState(false);
  const [followerCount, setFollowerCount] = useState(0);

  // 1. FETCH PROFILE & FOLLOW STATUS
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
        // Fetch user profile
        const profileResponse = await apiService.getUserProfileById(id);
        const userData = profileResponse.data?.data || profileResponse.data;

        if (userData && userData.user_id) {
          setProfile(userData);

          // Fetch follower data
          const followersResponse = await apiService.getFollower(id);
          const followers = followersResponse.data || [];
          
          setFollowerCount(followers.length);

          // Check if the current user is in the followers list
          if (currentUser && followers.some(follower => follower.user_id === currentUser.user_id)) {
            setIsFollowing(true);
          } else {
            setIsFollowing(false);
          }

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

  const getRankLevel = (rankString) => {
    if (!rankString) return '?';
    const match = rankString.match(/lvl (\d+)/i);
    return match ? match[1] : '?';
  };

  // 3. ACTION HANDLERS
  const handleFollow = async () => {
    const id = parseInt(idParam, 10);
    if (!profile || isNaN(id) || !currentUser) return;
    
    // Prevent following self
    if (profile.user_id === currentUser.user_id) {
        alert("You cannot follow yourself.");
        return;
    }

    const previousState = isFollowing;
    const previousCount = followerCount;

    // Optimistic UI update
    setIsFollowing(!previousState);
    setFollowerCount(previousState ? previousCount - 1 : previousCount + 1);

    try {
      if (previousState) {
        await apiService.unfollowUser(id);
      } else {
        await apiService.followUser(id);
      }
    } catch (error) {
      console.error("Failed to toggle follow:", error);
      // Rollback on error
      setIsFollowing(previousState);
      setFollowerCount(previousCount);
      alert("Failed to update follow status.");
    }
  };

  if (loading) return <div className="h-screen w-full flex items-center justify-center">Loading profile...</div>;
  if (error || !profile) return <div className="h-screen w-full flex items-center justify-center text-gray-400 font-bold text-md">{error}</div>;

  const handleCardClick = (id) => {
    navigate(`/trip/${id}`);
  };

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
                {profile.photo ? (
                    <img src={profile.photo} alt={profile.username} className="w-full h-full object-cover" />
                ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400">
                        Profile
                    </div>
                )}
            </div>

            <div className="grow text-center md:text-left w-full">
                
                <div className="flex flex-col md:flex-row justify-between items-start mb-6 px-20">
                    <div>
                        <p className="text-gray-500 text-sm">Name</p>
                        <h1 className="text-2xl font-bold text-gray-900 mb-4">{profile.username}</h1>
                        
                        <div className="flex items-center justify-center md:justify-start gap-2">
                            <div className="relative flex items-center justify-center text-white">
                                <FaCertificate className="text-black text-3xl" />
                                <span className="absolute font-bold text-xs">
                                    {getRankLevel(profile.rank)}
                                </span>
                            </div>
                            <div>
                                <p className="text-gray-500 text-xs">Rank's</p>
                                <p className="font-bold text-sm text-gray-900">{profile.rank || "Traveler"}</p>
                            </div>
                        </div>
                    </div>

                    <div className="flex gap-8 md:gap-12 mt-6 md:mt-0 justify-center md:justify-end w-full md:w-auto">
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Followers</p>
                            <p className="font-bold text-lg">{followerCount}</p>
                        </div>
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Reviews</p>
                            <p className="font-bold text-lg">{profile.stats.reviews || 0}</p>
                        </div>
                        <div className="text-center">
                            <p className="text-gray-500 text-sm mb-1">Route's</p>
                            <p className="font-bold text-lg">{profile.stats.routes || 0}</p>
                        </div>
                    </div>
                </div>

                <div className="flex gap-3 justify-center md:justify-end border-t pt-6 md:border-none md:pt-0 px-20">
                    {currentUser && currentUser.user_id !== profile.user_id && (
                         <button
                            onClick={handleFollow}
                            className={`px-8 py-2 rounded-md font-medium transition ${
                                isFollowing
                                ? 'bg-gray-200 text-gray-800 border border-gray-300'
                                : 'bg-[#1e293b] text-white hover:bg-slate-700'
                            }`}
                        >
                            {isFollowing ? 'Unfollow' : 'Follow'}
                        </button>
                    )}
                    <button className="bg-red-600 text-white px-8 py-2 rounded-md font-medium hover:bg-red-700 transition">
                        Report
                    </button>
                </div>

            </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
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
                              ? "md:col-span-2 h-64 md:h-80"
                              : "h-64"
                            }
                            onClick={() => handleCardClick(trip.plan_id)}
                        />

                ))
            ) : (
                <div className="md:col-span-2 text-center py-10 text-gray-400">
                    Pengguna ini belum memiliki trip.
                </div>
            )}
        </div>

      </div>
    </div>
  );
};

export default TravellerProfilePage;