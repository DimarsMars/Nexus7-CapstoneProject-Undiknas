import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaStar, FaBookmark, FaTimes, FaCamera } from "react-icons/fa";
import apiService from '../services/apiService';

const MyTripReviewPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  const [routeDetail, setRouteDetail] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentImage, setCurrentImage] = useState(0);
  const [isBookmarking, setIsBookmarking] = useState(false);

  // Modal States
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [userRating, setUserRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewComment, setReviewComment] = useState("");
  const [reviewImage, setReviewImage] = useState(null);
  const [previewImage, setPreviewImage] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // FETCH DATA (ROUTE & REVIEWS)
  const fetchData = async () => {
    try {
        // Jangan set loading true jika hanya refresh data setelah submit
        // (opsional: bisa diatur sesuai kebutuhan UI)
        // if (!routeDetail) setLoading(true); 

        const [routeRes, reviewsRes] = await Promise.all([
            apiService.getRouteData(id),
            apiService.getReviewPlace(id)
        ]);

        if (routeRes.data) {
            setRouteDetail(routeRes.data);
            setReviews(reviewsRes.data);
        }

    } catch (error) {
        console.error("Error fetching data:", error);
    } finally {
        setLoading(false);
    }
  };

  // --- 2. PANGGIL FETCH DATA DI USE EFFECT ---
  useEffect(() => {
    if (id) {
        setLoading(true); // Set loading awal disini
        fetchData();
    }
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
      // Create FormData for file upload
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

      // Reset Form & Close Modal
      setIsModalOpen(false);
      setUserRating(0);
      setReviewComment("");
      setReviewImage(null);
      setPreviewImage(null);

      // Refresh reviews list
      fetchData();

    } catch (error) {
      console.error("Error submitting review:", error);
      alert("Failed to submit review. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleBookmark = async () => {
    setIsBookmarking(true);
    try {
        // Panggil API POST /bookmarks/{route-id}
        const response = await apiService.postBookmarkRoute(id);
        
        // Tampilkan notifikasi sukses
        alert(response.data.message || "Berhasil ditambahkan ke Bookmark!");
        
        // Opsional: Anda bisa navigate ke halaman bookmark langsung
        // navigate('/bookmarked'); 
    } catch (error) {
        console.error("Gagal bookmark:", error);
        alert("Gagal menambahkan bookmark. Coba lagi.");
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

  // HELPER GAMBAR
  const getImageSrc = (img) => {
      if (!img) return null;
      return img.startsWith('data:image') || img.startsWith('http') 
        ? img 
        : `data:image/jpeg;base64,${img}`;
  };

  // Slider image logic
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
            <FaBookmark 
                onClick={handleBookmark}
                className={`text-3xl cursor-pointer transition ${
                    isBookmarking ? 'text-gray-300' : 'text-[#1e293b] hover:text-gray-600'
                }`} 
                title="Save this place" 
            />
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
            {reviews.length > 0 ? (
                reviews.map((item) => (
                    <div key={item.review_id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
                        <div className="flex gap-4 mb-4">
                            {/* Gambar User/Review */}
                            <div className="w-24 h-20 shrink-0 rounded-lg overflow-hidden">
                                {item.image ? (
                                    <img src={getImageSrc(item.image)} alt="Review" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full bg-gray-200 flex items-center justify-center text-xs text-gray-400">No Img</div>
                                )}
                            </div>

                            <div className='text-left'>
                                {/* Bintang Rating */}
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
                {/* Header Modal */}
                <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-bold text-[#1e293b]">Add Review</h3>
                    <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                        <FaTimes />
                    </button>
                </div>

                {/* Rating Input */}
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

                {/* Comment Input */}
                <div className="mb-4">
                    <textarea 
                        className="w-full border border-slate-300 rounded-lg p-4 text-gray-700 focus:outline-none focus:border-slate-800 resize-none h-32 placeholder-gray-400"
                        placeholder="Share your experience..."
                        value={reviewComment}
                        onChange={(e) => setReviewComment(e.target.value)}
                    ></textarea>
                </div>

                {/* Image Upload Input */}
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

                {/* Submit Button */}
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