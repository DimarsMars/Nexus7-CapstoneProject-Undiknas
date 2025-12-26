import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
// 1. IMPORT FaRegBookmark (Outline)
import { FaChevronLeft, FaStar, FaBookmark, FaRegBookmark, FaTimes, FaCamera } from "react-icons/fa";
import apiService from '../services/apiService';

const MyTripReviewPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  const [routeDetail, setRouteDetail] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentImage, setCurrentImage] = useState(0);
  
  // 2. STATE UNTUK STATUS BOOKMARK
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [isBookmarking, setIsBookmarking] = useState(false);
  const [bookmarkId, setBookmarkId] = useState(null);

  // Modal States
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [userRating, setUserRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewComment, setReviewComment] = useState("");
  const [reviewImage, setReviewImage] = useState(null);
  const [previewImage, setPreviewImage] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // FETCH DATA (ROUTE, REVIEWS, & CHECK BOOKMARK STATUS)
  const fetchData = async () => {
    try {
      const [routeRes, reviewsRes, bookmarksRes] = await Promise.all([
        apiService.getRouteData(id),
        apiService.getReviewPlace(id),
        apiService.getBookmarkRoute(),
      ]);

      if (routeRes.data) {
        setRouteDetail(routeRes.data);
      }

      if (reviewsRes.data && Array.isArray(reviewsRes.data)) {
        setReviews(reviewsRes.data);
      } else if (reviewsRes.data && reviewsRes.data.data) {
        setReviews(reviewsRes.data.data);
      } else {
        setReviews([]);
      }

      if (bookmarksRes.data) {
        const bookmarkList = Array.isArray(bookmarksRes.data) ? bookmarksRes.data : (bookmarksRes.data.data || []);
        const foundBookmark = bookmarkList.find(item => item.route_id === parseInt(id));

        if (foundBookmark) {
          setIsBookmarked(true);
          setBookmarkId(foundBookmark.bookmark_id);
        } else {
          setIsBookmarked(false);
          setBookmarkId(null);
        }
      }
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) {
      setLoading(true);
      fetchData();
    }
    // eslint-disable-next-line
  }, [id]);

  // HANDLERS
  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setReviewImage(file);
      setPreviewImage(URL.createObjectURL(file));
    }
  };

  const handleSubmitReview = async () => {
    if (userRating === 0) {
      alert("Please provide a star rating.");
      return;
    }

    setIsSubmitting(true);

    try {
      const formData = new FormData();
      formData.append('route_id', parseInt(id));
      formData.append('rating', userRating);
      formData.append('comment', reviewComment);
      
      if (reviewImage) {
        formData.append('image', reviewImage);
      }

      const response = await apiService.postReviewPlace(formData);

      if (response.message) {
        alert(response.message);
      } else {
        alert("Review submitted successfully!");
      }

      setIsModalOpen(false);
      setUserRating(0);
      setReviewComment("");
      setReviewImage(null);
      setPreviewImage(null);

      fetchData();

    } catch (error) {
      console.error("Error submitting review:", error);
      alert("Failed to submit review. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  // 4. UPDATE LOGIKA HANDLE BOOKMARK
  const handleBookmark = async () => {
    if (isBookmarking) {
      return;
    }
    setIsBookmarking(true);

    try {
      if (isBookmarked && bookmarkId) {
        // --- UNBOOKMARK ---
        await apiService.deleteBookmarkRoute(bookmarkId);
        alert("Bookmark removed successfully!");
        setIsBookmarked(false);
        setBookmarkId(null);
      } else {
        // --- BOOKMARK ---
        await apiService.postBookmarkRoute(id); // 'id' is routeId from useParams
        alert("Added to bookmarks!");
        // Re-fetch all data to get the new bookmarkId and ensure state is perfectly synced
        await fetchData();
      }
    } catch (error) {
      console.error("Failed to update bookmark status:", error);
      const errorMessage = error.response?.data?.message || error.response?.data?.error || "An error occurred.";
      alert(`Error: ${errorMessage}`);
    } finally {
      setIsBookmarking(false);
    }
  };

  // HANDLING LOADING & ERROR
  if (loading) {
      return (
        <div className="min-h-screen bg-gray-100 flex items-center justify-center">
            <div className="text-gray-500 font-bold">Loading details...</div>
        </div>
      );
  }

  if (!routeDetail) {
      return (
        <div className="min-h-screen bg-gray-100 flex items-center justify-center">
            <div className="text-red-500 font-bold">Location Not Found</div>
        </div>
      );
  }

  const getImageSrc = (img) => {
      if (!img) return null;
      return img.startsWith('data:image') || img.startsWith('http') 
        ? img 
        : `data:image/jpeg;base64,${img}`;
  };

  let sliderImages = [];
  if (routeDetail.image) {
      sliderImages = [routeDetail.image];
  }

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
      <div className="w-full max-w-7xl">
        
        {/* HEADER */}
        <div className="flex justify-between items-center mb-6">
            <button 
                onClick={() => navigate(-1)}
                className="flex items-center gap-2 text-black font-bold text-xl hover:text-gray-600 transition"
            >
                <FaChevronLeft /> 
                <span>{routeDetail.title}</span> 
            </button>

            <div className="flex text-yellow-400 text-2xl gap-1">
                {[...Array(5)].map((_, i) => <FaStar key={i} />)}
            </div>
        </div>

        {/* IMAGE SLIDER */}
        <div className="bg-white p-2 rounded-2xl shadow-sm mb-6">
            <div className="relative w-full h-64 md:h-[400px] rounded-xl overflow-hidden group">
                {sliderImages.length > 0 ? (
                    <img 
                        src={getImageSrc(sliderImages[currentImage])} 
                        alt={routeDetail.title} 
                        className="w-full h-full object-cover transition-all duration-500"
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center bg-gray-200 text-gray-400">
                        No Image Available
                    </div>
                )}
            </div>
        </div>

        {/* ACTION BAR */}
        <div className="flex justify-end items-center gap-4 mb-8">
            
            {/* 5. IMPLEMENTASI UI TOGGLE ICON */}
            <div onClick={handleBookmark} className="cursor-pointer transition hover:scale-110" title={isBookmarked ? "Saved" : "Save this place"}>
                {isBookmarked ? (
                    // TAMPILAN JIKA SUDAH DI-BOOKMARK (FILLED & WARNA)
                    <FaBookmark className="text-3xl text-[#1e293b]" />
                ) : (
                    // TAMPILAN JIKA BELUM (OUTLINE)
                    <FaRegBookmark className="text-3xl text-[#1e293b] hover:text-gray-600" />
                )}
            </div>

            <button 
                onClick={() => setIsModalOpen(true)}
                className="bg-[#1e293b] text-white px-8 py-2 rounded-lg font-medium text-sm hover:bg-slate-700 transition"
            >
                Add review
            </button>
        </div>

        {/* REVIEW SECTION */}
        <h2 className="text-xl font-bold text-[#1e293b] mb-6">Review from the people’s</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {reviews && reviews.length > 0 ? (
                reviews.map((item) => (
                    <div key={item.review_id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
                        <div className="flex gap-4 mb-4">
                            <div className="w-24 h-20 shrink-0 rounded-lg overflow-hidden">
                                {item.image ? (
                                    <img src={getImageSrc(item.image)} alt="Review" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full bg-gray-200 flex items-center justify-center text-xs text-gray-400">No Img</div>
                                )}
                            </div>

                            <div className='text-left'>
                                <div className="flex text-yellow-400 text-xs mb-1">
                                    {[...Array(item.rating || 0)].map((_, i) => <FaStar key={i} />)}
                                </div>
                                <h3 className="font-bold text-[#1e293b] mb-1">Traveler</h3>
                                <p className="text-gray-500 text-[10px] leading-tight line-clamp-3">
                                    {item.comment}
                                </p>
                            </div>
                        </div>

                        <div className="mt-auto">
                            <p className="text-[10px] text-gray-500 mb-2">More picture from the reviews</p>
                            <div className="flex items-center gap-2 h-10">
                                <span className="text-[10px] text-gray-300 italic">No extra photos</span>
                                <button className="text-[10px] text-gray-500 underline hover:text-black ml-auto whitespace-nowrap">
                                    See More Picture
                                </button>
                            </div>
                        </div>
                    </div>
                ))
            ) : (
                <div className="col-span-3 text-center text-gray-400 py-10">
                    No reviews yet for this location.
                </div>
            )}
        </div>

      </div>

      {/* --- ADD REVIEW MODAL --- */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50 p-4" onClick={() => setIsModalOpen(false)}>
            <div 
                className="bg-white w-full max-w-lg rounded-2xl p-6 shadow-2xl transform transition-all relative" 
                onClick={(e) => e.stopPropagation()}
            >
                <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-bold text-[#1e293b]">Add Review</h3>
                    <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                        <FaTimes />
                    </button>
                </div>

                <div className="flex justify-center gap-2 mb-6">
                    {[...Array(5)].map((_, index) => {
                        const starValue = index + 1;
                        return (
                            <FaStar 
                                key={index}
                                className={`text-3xl cursor-pointer transition-colors ${
                                    starValue <= (hoverRating || userRating) ? "text-yellow-400" : "text-gray-200"
                                }`}
                                onMouseEnter={() => setHoverRating(starValue)}
                                onMouseLeave={() => setHoverRating(0)}
                                onClick={() => setUserRating(starValue)}
                            />
                        );
                    })}
                </div>

                <div className="mb-4">
                    <textarea 
                        className="w-full border border-slate-300 rounded-lg p-4 text-gray-700 focus:outline-none focus:border-slate-800 resize-none h-32 placeholder-gray-400"
                        placeholder="Share your experience..."
                        value={reviewComment}
                        onChange={(e) => setReviewComment(e.target.value)}
                    ></textarea>
                </div>

                <div className="mb-6">
                    <label className="block text-sm font-medium text-gray-700 mb-2">Add Photo</label>
                    <div className="flex items-center gap-4">
                        <label className="cursor-pointer bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 flex items-center gap-2 hover:bg-gray-100 transition">
                            <FaCamera className="text-gray-500" />
                            <span className="text-sm text-gray-600">Choose Image</span>
                            <input 
                                type="file" 
                                accept="image/*" 
                                className="hidden" 
                                onChange={handleImageChange}
                            />
                        </label>
                        {previewImage && (
                            <div className="w-16 h-16 rounded-md overflow-hidden border border-gray-200">
                                <img src={previewImage} alt="Preview" className="w-full h-full object-cover" />
                            </div>
                        )}
                    </div>
                </div>

                <button 
                    onClick={handleSubmitReview}
                    disabled={isSubmitting}
                    className={`w-full py-3 rounded-lg text-white font-bold transition ${
                        isSubmitting ? 'bg-slate-500 cursor-not-allowed' : 'bg-[#1e293b] hover:bg-slate-700'
                    }`}
                >
                    {isSubmitting ? 'Submitting...' : 'Post Review'}
                </button>
            </div>
        </div>
      )}

    </div>
  );
};

export default MyTripReviewPage;