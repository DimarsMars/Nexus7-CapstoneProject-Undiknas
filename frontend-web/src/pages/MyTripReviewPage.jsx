import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaStar, FaBookmark, FaRegBookmark, FaTimes, FaCamera } from "react-icons/fa";
import apiService from '../services/apiService';

const MyTripReviewPage = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  const [routeDetail, setRouteDetail] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentImage, setCurrentImage] = useState(0);
  
  // STATE UNTUK STATUS BOOKMARK
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [isBookmarking, setIsBookmarking] = useState(false);
  const [bookmarkId, setBookmarkId] = useState(null);

  // Modal States
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [userRating, setUserRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewComment, setReviewComment] = useState("");
  
  // --- Ubah state image jadi Array [] ---
  const [reviewImages, setReviewImages] = useState([]); 
  const [previewImages, setPreviewImages] = useState([]); 
  
  const [isSubmitting, setIsSubmitting] = useState(false);

  // FETCH DATA
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
  }, [id]);

  // --- Handle Multiple Images ---
  const handleImageChange = (e) => {
    const files = Array.from(e.target.files); // Ambil semua file yang dipilih
    if (files.length > 0) {
      // Simpan File object untuk dikirim ke API
      setReviewImages(prev => [...prev, ...files]);

      // Buat URL preview untuk ditampilkan di UI
      const newPreviews = files.map(file => URL.createObjectURL(file));
      setPreviewImages(prev => [...prev, ...newPreviews]);
    }
  };

  // Fungsi untuk menghapus gambar yang salah pilih
  const removeImage = (index) => {
    setReviewImages(prev => prev.filter((_, i) => i !== index));
    setPreviewImages(prev => prev.filter((_, i) => i !== index));
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
      
      // --- Append Multiple Images ---
   
      reviewImages.forEach((file) => {
          formData.append('image', file);
      });

      const response = await apiService.postReviewPlace(formData);

      if (response.message) {
        alert(response.message);
      } else {
        alert("Review submitted successfully!");
      }

      setIsModalOpen(false);
      
      // Reset State
      setUserRating(0);
      setReviewComment("");
      setReviewImages([]); // Reset array
      setPreviewImages([]); // Reset preview array

      fetchData();

    } catch (error) {
      console.error("Error submitting review:", error);
      alert("Failed to submit review. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleBookmark = async () => {
    if (isBookmarking) {
      return;
    }
    setIsBookmarking(true);

    try {
      if (isBookmarked && bookmarkId) {
        await apiService.deleteBookmarkRoute(bookmarkId);
        alert("Bookmark removed successfully!");
        setIsBookmarked(false);
        setBookmarkId(null);
      } else {
        await apiService.postBookmarkRoute(id);
        alert("Added to bookmarks!");
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
      
      let imageString = img;
      if (Array.isArray(img)) {
          if (img.length === 0) return null;
          imageString = img[0]; 
      }

      if (typeof imageString !== 'string') return null;

      return imageString.startsWith('data:image') || imageString.startsWith('http') 
        ? imageString 
        : `data:image/jpeg;base64,${imageString}`;
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
            <div onClick={handleBookmark} className="cursor-pointer transition hover:scale-110" title={isBookmarked ? "Saved" : "Save this place"}>
                {isBookmarked ? (
                    <FaBookmark className="text-3xl text-[#1e293b]" />
                ) : (
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
                reviews.map((item) => {

                    const images = Array.isArray(item.image) 
                        ? item.image 
                        : (item.image ? [item.image] : []);
                    
                    const mainImage = images.length > 0 ? images[0] : null;
                    const extraImages = images.slice(1, 4);

                    return (
                        <div key={item.review_id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
                            <div className="flex gap-4 mb-4">
                                {/* FOTO UTAMA (KIRI) */}
                                <div className="w-32 h-20 shrink-0 rounded-lg overflow-hidden border border-gray-100">
                                    {mainImage ? (
                                        <img src={getImageSrc(mainImage)} alt="Review" className="w-full h-full object-cover" />
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

                            {/* EXTRA PHOTOS */}
                            <div className="mt-auto">
                                <p className="text-[10px] text-gray-500 mb-2">More picture from the reviews</p>
                                <div className="flex items-center gap-2 h-10">
                                    {extraImages.length > 0 ? (
                                        extraImages.map((img, idx) => (
                                            <div key={idx} className="w-15 h-10 rounded-md overflow-hidden border border-gray-200 shrink-0">
                                                <img src={getImageSrc(img)} alt={`Extra ${idx}`} className="w-full h-full object-cover" />
                                            </div>
                                        ))
                                    ) : (
                                        <span className="text-[10px] text-gray-300 italic">No extra photos</span>
                                    )}

                                    {/* Tombol See More */}
                                    {images.length > 4 && (
                                        <button className="text-[10px] text-gray-500 underline hover:text-black ml-auto whitespace-nowrap">
                                            +{images.length - 4} More
                                        </button>
                                    )}
                                    
                                    {images.length <= 4 && (
                                         <button className="text-[10px] text-gray-500 underline hover:text-black ml-auto whitespace-nowrap">
                                            See Detail
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    );
                })
            ) : (
                <div className="col-span-3 text-center text-gray-400 py-10">
                    No reviews yet for this location.
                </div>
            )}
        </div>

      </div>

      {/* ADD REVIEW MODAL */}
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
                    <label className="block text-sm font-medium text-gray-700 mb-2">Add Photo (Max 5)</label>
                    <div className="flex flex-col gap-3">
                        {/* INPUT FILE MULTIPLE */}
                        <label className="cursor-pointer bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 flex items-center justify-center gap-2 hover:bg-gray-100 transition border-dashed">
                            <FaCamera className="text-gray-500" />
                            <span className="text-sm text-gray-600">Choose Images</span>
                            <input 
                                type="file" 
                                accept="image/*" 
                                multiple
                                className="hidden" 
                                onChange={handleImageChange}
                            />
                        </label>

                        {/* PREVIEW IMAGE LIST */}
                        {previewImages.length > 0 && (
                            <div className="flex gap-2 overflow-x-auto py-2">
                                {previewImages.map((src, idx) => (
                                    <div key={idx} className="relative w-16 h-16 shrink-0 group">
                                        <img src={src} alt={`Preview ${idx}`} className="w-full h-full object-cover rounded-md border border-gray-200" />
                                        {/* Optional: Tombol hapus kecil jika hover */}
                                        <button 
                                            onClick={() => removeImage(idx)}
                                            className="absolute -top-1 -right-1 bg-red-500 text-white rounded-full p-0.5 text-[10px] opacity-0 group-hover:opacity-100 transition"
                                        >
                                            <FaTimes />
                                        </button>
                                    </div>
                                ))}
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