import { useState, useEffect } from 'react';
import { FaStar } from "react-icons/fa";
import apiService from '../services/apiService';
import { useAuth } from '../context/AuthContext';

const UserReviewCard = ({ userId, image, name, role, review, rating }) => {
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

  const handleFollow = async () => {
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
    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row gap-6 w-full transition-shadow hover:shadow-md">
      
      {/* BAGIAN KIRI: PROFIL PEREVIEW */}
      <div className="flex flex-col items-center shrink-0 w-full md:w-32">
        <div className="w-24 h-24 mb-3 rounded-full overflow-hidden shadow-sm">
          <img 
            src={image && image.trim() !== '' ? image : 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs='} 
            alt={name} 
            className="w-full h-full object-cover"
          />
        </div>

        <h3 className="text-gray-900 font-bold text-lg leading-tight capitalize">{name}</h3>
        <p className="text-gray-900 font-normal text-sm mb-3">{role}</p>

        {currentUser && currentUser.user_id !== userId && (
            <button 
                onClick={handleFollow}
                disabled={loading}
                className={`text-sm font-medium px-2 py-1.5 rounded-lg transition-colors w-full md:w-24 ${
                    isFollowing
                    ? 'bg-gray-200 text-gray-800 hover:bg-gray-300'
                    : 'bg-[#1e293b] text-white hover:bg-slate-700'
                }`}
            >
                {loading ? '...' : (isFollowing ? 'Unfollow' : 'Follow')}
            </button>
        )}
      </div>

      {/* BAGIAN KANAN: ISI REVIEW */}
      <div className="flex flex-col grow relative">
        <div className="flex justify-between items-start mb-3">
            <div className="flex gap-1">
                {[...Array(5)].map((_, i) => (
                    <FaStar 
                        key={i} 
                        className={`text-xl ${i < rating ? "text-yellow-400" : "text-gray-200"}`} 
                    />
                ))}
            </div>

        </div>

        <p className="text-gray-800 text-base leading-relaxed">
            {review}
        </p>

      </div>
    </div>
  );
};

export default UserReviewCard;