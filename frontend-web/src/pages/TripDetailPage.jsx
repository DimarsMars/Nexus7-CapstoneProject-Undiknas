import { useParams, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { FaStar, FaHeart, FaRegHeart, FaChevronLeft } from "react-icons/fa";
import RouteCard from '../components/RouteCard';
import apiClient from '../services/apiClient';
import { useData } from '../context/DataContext';

const TripDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { favoriteTrips, addFavorite, removeFavorite } = useData();
  
  const [tripData, setTripData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  // isLiked is now derived from the global context
  const isLiked = tripData ? favoriteTrips.some(trip => trip.plan_id === tripData.plan.plan_id) : false;

  // STATE REVIEW MODAL
  const [isReviewModalOpen, setIsReviewModalOpen] = useState(false);
  const [userRating, setUserRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewText, setReviewText] = useState("");

  useEffect(() => {
    const fetchTripDetail = async () => {
      try {
        setIsLoading(true);
        const response = await apiClient.get(`/plans/${id}/detail`);
        setTripData(response.data);
      } catch (err) {
        setError("Failed to fetch trip details. Please try again.");
        console.error("Error fetching trip details:", err);
      } finally {
        setIsLoading(false);
      }
    };

    if (id) {
      fetchTripDetail();
    }
  }, [id]);

  const handleLike = () => {
    if (!tripData) return;

    if (isLiked) {
        removeFavorite(tripData.plan.plan_id);
    } else {
        const favoriteData = {
            plan_id: tripData.plan.plan_id,
            title: tripData.plan.title,
            description: tripData.plan.description,
            banner: tripData.plan.banner,
            location: tripData.routes?.[0]?.address || 'Multiple locations'
        };
        addFavorite(favoriteData);
    }
  };

const handleSubmitReview = async () => {
      if (userRating === 0) {
          alert("Please provide a star rating before submitting.");
          return;
      }

      try {
          const reviewData = {
              plan_id: parseInt(id, 10), // Ensure plan_id is a number
              rating: userRating,
              comment: reviewText
          };

          const response = await apiClient.post('/reviews/trip', reviewData);
          
          alert(response.message || "Review submitted successfully!");

          // Reset and close the modal
          setIsReviewModalOpen(false);
          setUserRating(0);
          setHoverRating(0);
          setReviewText("");

      } catch (error) {
          console.error("Error submitting review:", error);
          alert("Failed to submit review. Please try again.");
      }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-400 text-md font-bold">Loading trip details...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-red-500 text-md font-bold">{error}</div>
      </div>
    );
  }

  if (!tripData) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-400 text-md font-bold">Trip not found</div>
      </div>
    );
  }

  const { plan, routes } = tripData;
  const tripImage = plan.banner ? `data:image/jpeg;base64,${plan.banner}` : 'placeholder-image-url';

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
      <div className="w-full max-w-7xl">
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Back
            </h1>
        </div>

        <div className="bg-white w-full p-6 md:p-8 rounded-xl shadow-sm border border-gray-100">
            <div className="w-full h-64 md:h-96 rounded-xl overflow-hidden mb-6 shadow-sm">
                <img src={tripImage} alt={plan.title} className="w-full h-full object-cover" />
            </div>

            <div className="mb-4">
                <div className="flex justify-between items-start">
                    <h1 className="text-3xl font-bold text-[#1e293b]">{plan.title}</h1>
                    <div onClick={() => setIsReviewModalOpen(true)} className="hidden md:block bg-[#5e6c7c] text-white px-4 py-1 rounded text-sm font-medium cursor-pointer hover:bg-[#4a5568]">Rate trip</div>
                </div>
                
                <div className="flex gap-1 mt-2 text-yellow-400 text-xl">
                    {[...Array(5)].map((_, i) => (
                        <FaStar key={i} className={i < (plan.rating || 5) ? "text-yellow-400" : "text-gray-200"} />
                    ))}
                </div>
            </div>

            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 border-b border-gray-100">
                <div className="flex gap-3">
                    <button  onClick={() => navigate('/maps')} className="bg-slate-800 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-slate-700 transition shadow-sm">
                        Set Trip
                    </button>
                    <button className="bg-red-600 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-red-700 transition shadow-sm">
                        Report
                    </button>
                </div>
                
                <div className="flex gap-2 items-center w-full md:w-auto justify-between md:justify-end">
                    {isLiked ? (
                        <FaHeart 
                            onClick={handleLike}
                            className="text-2xl text-red-600 cursor-pointer ml-4 transition transform active:scale-90" 
                            title="Unsave Trip"
                        />
                    ) : (
                        <FaRegHeart 
                            onClick={handleLike}
                            className="text-2xl text-slate-800 cursor-pointer ml-4 transition transform active:scale-90" 
                            title="Save Trip"
                        />
                    )}
                </div>
            </div>

            <div className="mb-5">
                <p className="text-gray-600 text-base leading-relaxed text-justify">
                    {plan.description || "No description available for this trip."}
                </p>
            </div>

            <div className="flex flex-col gap-4">
                <h3 className="text-xl font-bold text-[#1e293b] mb-2">Trip Route</h3>
                {routes && routes.length > 0 ? (
                    routes.map((item, index) => (
                        <RouteCard 
                            key={item.route_id || index}
                            image={item.image ? `data:image/jpeg;base64,${item.image}` : 'placeholder-route-image-url'}
                            title={item.title}
                            activity={item.description || "Sightseeing"}
                            location={item.address}
                        />
                    ))
                ) : (
                    <div className="p-4 bg-gray-50 rounded-lg text-center text-gray-400 italic">
                        No specific route details available for this trip yet.
                    </div>
                )}
            </div>

        </div>
      </div>
      
      {/* --- REVIEW MODAL (POPUP) --- */}
      {isReviewModalOpen && (
        <div 
            className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50 p-4"
            onClick={() => setIsReviewModalOpen(false)}
        >
            <div 
                className="bg-white w-full max-w-lg rounded-2xl p-6 shadow-2xl transform transition-all"
                onClick={(e) => e.stopPropagation()}
            >
                {/* Text Area */}
                <div className="mb-4">
                    <textarea 
                        className="w-full border border-slate-300 rounded-lg p-4 text-gray-700 focus:outline-none focus:border-slate-800 resize-none h-40 placeholder-gray-400"
                        placeholder="Write a Review..."
                        value={reviewText}
                        onChange={(e) => setReviewText(e.target.value)}
                    ></textarea>
                </div>

                {/* Footer: Stars & Button */}
                <div className="flex items-center justify-between">
                    <div className="flex gap-1">
                        {[...Array(5)].map((_, index) => {
                            const starValue = index + 1;
                            return (
                                <FaStar 
                                    key={index}
                                    className={`text-2xl cursor-pointer transition-colors ${
                                        starValue <= (hoverRating || userRating) 
                                        ? "text-yellow-400" 
                                        : "text-gray-200"
                                    }`}
                                    onMouseEnter={() => setHoverRating(starValue)}
                                    onMouseLeave={() => setHoverRating(0)}
                                    onClick={() => setUserRating(starValue)}
                                />
                            );
                        })}
                    </div>

                    <button 
                        onClick={handleSubmitReview}
                        className="bg-[#1e293b] text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-slate-700 transition"
                    >
                        Add review
                    </button>
                </div>
            </div>
        </div>
      )}
    </div>
  );
};

export default TripDetailPage;