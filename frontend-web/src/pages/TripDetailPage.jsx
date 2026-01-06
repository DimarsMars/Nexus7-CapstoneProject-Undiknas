import { useCallback, useEffect, useState } from 'react';
import { FaChevronLeft, FaHeart, FaRegHeart, FaStar } from "react-icons/fa";
import { useNavigate, useParams } from 'react-router-dom';
import RouteCard from '../components/RouteCard';
import { useData } from '../context/DataContext';
import apiService from '../services/apiService';
import Swal from 'sweetalert2';
import placeholderImage from '../assets/images/placeholderTrip.png';

// --- 1. Custom Hook for Data Fetching ---
const useTripDetail = (id) => {
  const [tripData, setTripData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!id) {
      setIsLoading(false);
      setError("No trip ID provided.");
      return;
    }

    const fetchTripDetail = async () => {
      try {
        setIsLoading(true);
        const response = await apiService.getPlanForRunTrip(id);
        setTripData(response.data);
      } catch (err) {
        setError("Failed to fetch trip details. Please try again.");
        console.error("Error fetching trip details:", err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchTripDetail();
  }, [id]);

  return { tripData, isLoading, error };
};

// --- 2. Self-Contained Review Modal Component ---
const ReviewModal = ({ isOpen, onClose, planId, onSubmit }) => {
  const [rating, setRating] = useState(0);
  const [hover, setHover] = useState(0);
  const [comment, setComment] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async () => {
    if (rating === 0) {
      Swal.fire({
        title: 'Rating Diperlukan',
        text: 'Silakan berikan penilaian bintang sebelum mengirimkan ulasan Anda.',
        icon: 'warning',
        confirmButtonColor: '#1e293b',
      });
      return;
    }
    setIsSubmitting(true);
    try {
      await onSubmit({ plan_id: planId, rating, comment });
      handleClose();
    } catch (error) {
      const errorMessage = error.response?.data?.error || "Failed to submit review.";
      alert(errorMessage);
      console.error("Error submitting review:", error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleClose = () => {
    setRating(0);
    setHover(0);
    setComment("");
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-500 p-4" onClick={handleClose}>
      <div className="bg-white w-full max-w-lg rounded-2xl p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
        <textarea
          className="w-full border border-slate-300 rounded-lg p-4 text-gray-700 focus:outline-none focus:border-slate-800 resize-none h-40 placeholder-gray-400"
          placeholder="Share your experience about this trip..."
          value={comment}
          onChange={(e) => setComment(e.target.value)}
        />
        <div className="flex items-center justify-between mt-4">
          <div className="flex gap-1">
            {[...Array(5)].map((_, index) => {
              const starValue = index + 1;
              return (
                <FaStar
                  key={index}
                  className={`text-2xl cursor-pointer transition-colors ${starValue <= (hover || rating) ? "text-yellow-400" : "text-gray-200"}`}
                  onMouseEnter={() => setHover(starValue)}
                  onMouseLeave={() => setHover(0)}
                  onClick={() => setRating(starValue)}
                />
              );
            })}
          </div>
          <button
            onClick={handleSubmit}
            disabled={isSubmitting}
            className="bg-slate-800 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-slate-700 transition disabled:bg-slate-500"
          >
            {isSubmitting ? "Submitting..." : "Add Review"}
          </button>
        </div>
      </div>
    </div>
  );
};


// --- 3. Main Page Component ---
const TripDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { favoriteTrips, addFavorite, removeFavorite } = useData();
  const { tripData, isLoading, error } = useTripDetail(id);

  const [isReviewModalOpen, setIsReviewModalOpen] = useState(false);
  const [showReportPopup, setShowReportPopup] = useState(false); // State for report modal

  const favoriteRecord = tripData ? favoriteTrips.find(fav => fav.plan_id === tripData.plan.plan_id) : null;
  const isLiked = !!favoriteRecord;

  const handleLike = useCallback(async () => {
    if (!tripData) return;
    isLiked ? await removeFavorite(favoriteRecord.favorite_id) : await addFavorite(tripData.plan.plan_id);
  }, [isLiked, tripData, favoriteRecord, addFavorite, removeFavorite]);

  const handleSetTrip = useCallback(async () => {
    if (!tripData?.routes?.length) {
      Swal.fire({
        title: 'Rute Tidak Tersedia',
        text: 'Maaf, perjalanan ini tidak memiliki titik tujuan (routes) sehingga tidak dapat dimulai. Silakan periksa kembali data perjalanan Anda.',
        icon: 'warning',
        confirmButtonColor: '#1e293b',
      });
      return;
    }
    try {
      const firstRoute = tripData.routes[0];
      await apiService.postTripSessionStart(tripData.plan.plan_id, firstRoute.route_id);
      navigate(`/runtrip/${tripData.plan.plan_id}`);
    } catch (err) {
      const msg = err?.response?.data?.error || "Failed to start the trip. Please try again.";
      alert(msg);
      console.error("Failed to start trip:", err);
    }
  }, [navigate, tripData]);

  const handleSubmitReview = useCallback(async (reviewData) => {
    const response = await apiService.postReviewTrip(reviewData);
    await Swal.fire({
      title: 'Success',
      text: response.message || "Ulasan Anda telah berhasil dikirim",
      icon: 'success',
      confirmButtonColor: '#1e293b',
    });
    // Optional: could add logic here to refetch trip data to show new average rating
  }, []);

  const handleReport = () => {
    setShowReportPopup(true);
  };

  const handleClosePopup = () => {
    setShowReportPopup(false);
  };

  if (isLoading) {
    return <div className="min-h-screen flex items-center justify-center font-bold text-gray-500">Loading trip details...</div>;
  }
  if (error) {
    return <div className="min-h-screen flex items-center justify-center font-bold text-red-500">{error}</div>;
  }
  if (!tripData) {
    return <div className="min-h-screen flex items-center justify-center font-bold text-gray-500">Trip not found.</div>;
  }

  const { plan, routes, rating } = tripData;
  const tripImage = plan.banner ? `data:image/jpeg;base64,${plan.banner}` : placeholderImage;

  return (
    <>
      <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
        <div className="w-full max-w-7xl">
          <div className="flex items-center gap-4 mb-5">
            <button onClick={() => navigate(-1)} className="p-2 hover:bg-gray-200 rounded-full transition">
              <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-xl font-bold text-black">Back</h1>
          </div>

          <div className="bg-white w-full p-6 md:p-8 rounded-xl shadow-sm border border-gray-100">
            <div className="w-full h-64 md:h-96 rounded-xl overflow-hidden mb-6 shadow-sm">
              <img src={tripImage} alt={plan.title} className="w-full h-full object-cover" />
            </div>

            <div className="mb-4">
              <div className="flex justify-between items-start">
                <h1 className="text-3xl font-bold text-slate-800 capitalize">{plan.title}</h1>
                <button onClick={() => setIsReviewModalOpen(true)} className="hidden md:block bg-slate-600 text-white px-4 py-1 rounded text-sm font-medium cursor-pointer hover:bg-slate-700">Rate trip</button>
              </div>
              <div className="flex gap-1 mt-2 text-yellow-400 text-xl">
                {[...Array(5)].map((_, i) => <FaStar key={i} className={i < rating ? "text-yellow-400" : "text-gray-200"} />)}
              </div>
            </div>

            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-2 pb-4">
              <div className="flex gap-3">
                <button onClick={handleSetTrip} className="bg-slate-800 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-slate-700 transition shadow-sm">Start</button>
                <button onClick={handleReport} className="bg-red-600 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-red-700 transition shadow-sm">Report</button>
              </div>
              <button onClick={handleLike} aria-label={isLiked ? "Unsave Trip" : "Save Trip"}>
                {isLiked ? <FaHeart className="text-2xl text-red-600 cursor-pointer transition transform active:scale-90" /> : <FaRegHeart className="text-2xl text-slate-800 cursor-pointer transition transform active:scale-90" />}
              </button>
            </div>

            {plan.categories?.length > 0 && (
              <div className="flex flex-wrap gap-2 pb-3 mb-3 border-b border-gray-200">
                {plan.categories.map((cat, index) => <span key={index} className="text-slate-600 bg-slate-100 px-3 py-1 rounded-full text-sm font-medium">#{cat.name || cat}</span>)}
              </div>
            )}

            <div className="mb-8">
              <p className="text-gray-600 text-base leading-relaxed text-justify">{plan.description || "No description available for this trip."}</p>
            </div>

            <div>
              <h3 className="text-xl font-bold text-slate-800 mb-4">Trip Route</h3>
              <div className="flex flex-col gap-4">
                {routes?.length > 0 ? (
                  routes.map((item, index) => (
                    <RouteCard
                      key={item.route_id || index}
                      image={item.image ? `data:image/jpeg;base64,${item.image}` : placeholderImage}
                      title={item.title}
                      activity={item.description}
                      location={item.address}
                      onClick={() => navigate(`/mytripreview/${item.route_id}`)}
                    />
                  ))
                ) : (
                  <div className="p-4 bg-gray-50 rounded-lg text-center text-gray-400 italic">No specific route details available for this trip yet.</div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Report Success Modal */}
      {showReportPopup && (
        <div className="fixed inset-0 z-500 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm" onClick={handleClosePopup}>
          <div className="bg-white w-full max-w-md rounded-2xl p-6 shadow-2xl text-center" onClick={(e) => e.stopPropagation()}>
            <h3 className="mb-4 text-xl font-bold text-slate-800">Report Submitted</h3>
            <p className="mb-6 text-gray-600">
              Thank you. This trip has been reported and our team will review the case.
            </p>
            <button
              onClick={handleClosePopup}
              className="w-full py-2 font-bold text-white transition rounded-lg bg-red-600 hover:bg-red-700"
            >
              Close
            </button>
          </div>
        </div>
      )}

      <ReviewModal
        isOpen={isReviewModalOpen}
        onClose={() => setIsReviewModalOpen(false)}
        planId={parseInt(id, 10)}
        onSubmit={handleSubmitReview}
      />
    </>
  );
};

export default TripDetailPage;