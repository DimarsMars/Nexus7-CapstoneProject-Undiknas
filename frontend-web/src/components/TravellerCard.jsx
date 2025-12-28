import { useState, useEffect } from 'react';
import apiService from '../services/apiService';
import { useAuth } from '../context/AuthContext';

const TravellerCard = ({ userId, image, name, role, categories }) => {
  const { user: currentUser } = useAuth();
  const [isFollowing, setIsFollowing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!currentUser || !userId || currentUser.user_id === userId) {
      setLoading(false);
      return;
    }

    const checkStatus = async () => {
      try {
        setLoading(true);
        const followStatusRes = await apiService.checkIsFollowing(userId);
        setIsFollowing(followStatusRes?.is_following === true);
      } catch (error) {
        console.error(`Failed to check follow status for user ${userId}:`, error);
      } finally {
        setLoading(false);
      }
    };

    checkStatus();
  }, [currentUser, userId]);

  const handleFollow = async (e) => {
    e.stopPropagation(); 

    if (!currentUser || !userId || loading) return;
    if (currentUser.user_id === userId) {
      alert("You cannot follow yourself.");
      return;
    }

    const previousState = isFollowing;
    setIsFollowing(!previousState);

    try {
      if (previousState) {
        await apiService.unfollowUser(userId);
      } else {
        await apiService.followUser(userId);
      }
    } catch (error) {
      console.error(`Failed to toggle follow for user ${userId}:`, error);
      setIsFollowing(previousState);
      alert("Failed to update follow status.");
    }
  };

  return (
    <div 
        className="bg-white p-4 rounded-2xl shadow-sm hover:shadow-md transition-shadow flex flex-col items-center text-center border border-gray-100">
            <div className="w-24 h-24 mb-3 rounded-full overflow-hidden">
                <img 
                    src={image || "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg"} 
                    alt={name} 
                    className="w-full h-full object-cover"
                />
            </div>

      <h3 className="text-gray-900 font-bold text-lg capitalize">{name}</h3>
      <p className="text-gray-500 text-sm font-normal mb-1 capitalize">{role}</p>
      <p className="text-gray-600 text-sm font-semibold mb-4">{categories}</p>

      {currentUser && currentUser.user_id !== userId && (
        <button 
          onClick={handleFollow}
          disabled={loading}
          className={`text-sm font-medium px-2 py-1.5 rounded-lg transition-colors w-24 ${
            isFollowing
            ? 'bg-gray-200 text-gray-800 hover:bg-gray-300'
            : 'bg-slate-900 text-white hover:bg-gray-700'
          }`}
        >
          {loading ? '...' : (isFollowing ? 'Unfollow' : 'Follow')}
        </button>
      )}
    </div>
  );
};

export default TravellerCard;