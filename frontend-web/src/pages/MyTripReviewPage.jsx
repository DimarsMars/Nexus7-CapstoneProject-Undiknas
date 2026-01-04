import { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaStar, FaBookmark, FaRegBookmark, FaTimes, FaCamera } from "react-icons/fa";
import apiService from '../services/apiService';

// Helper function to safely get an image source
const getImageSrc = (img) => {
    if (!img) return null;
    
    // If the image data is an array, take the first element.
    const imageString = Array.isArray(img) ? img[0] : img;

    if (typeof imageString !== 'string' || imageString.trim() === '') return null;

    // Return the string if it's already a data URL or a web URL.
    if (imageString.startsWith('data:image') || imageString.startsWith('http')) {
        return imageString;
    }
    
    // Otherwise, assume it's a Base64 string and format it.
    return `data:image/jpeg;base64,${imageString}`;
};


// --- Sub-component for the Review Modal ---
const AddReviewModal = ({ isOpen, onClose, routeId, onSubmitSuccess }) => {
    if (!isOpen) return null;

    const [rating, setRating] = useState(0);
    const [hoverRating, setHoverRating] = useState(0);
    const [comment, setComment] = useState("");
    const [images, setImages] = useState([]);
    const [previewImageUrls, setPreviewImageUrls] = useState([]);
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleImageChange = (e) => {
        const files = Array.from(e.target.files);
        if (files.length > 0) {
            setImages(prev => [...prev, ...files]);
            const newPreviews = files.map(file => URL.createObjectURL(file));
            setPreviewImageUrls(prev => [...prev, ...newPreviews]);
        }
    };

    const removeImage = (index) => {
        setImages(prev => prev.filter((_, i) => i !== index));
        setPreviewImageUrls(prev => prev.filter((_, i) => i !== index));
    };

    const handleSubmit = async () => {
        if (rating === 0) {
            alert("Please provide a star rating.");
            return;
        }

        setIsSubmitting(true);
        try {
            const formData = new FormData();
            formData.append('route_id', routeId);
            formData.append('rating', rating);
            formData.append('comment', comment);
            images.forEach(file => formData.append('image', file));

            await apiService.postReviewPlace(formData);
            alert("Review submitted successfully!");
            onSubmitSuccess();
        } catch (error) {
            console.error("Error submitting review:", error);
            alert("Failed to submit review. Please try again.");
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-500 p-4" onClick={onClose}>
            <div className="bg-white w-full max-w-lg rounded-2xl p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
                <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-bold text-[#1e293b]">Add Review</h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-600"><FaTimes /></button>
                </div>

                <div className="flex justify-center gap-2 mb-6">
                    {[...Array(5)].map((_, index) => {
                        const starValue = index + 1;
                        return (
                            <FaStar 
                                key={index}
                                className={`text-3xl cursor-pointer transition-colors ${starValue <= (hoverRating || rating) ? "text-yellow-400" : "text-gray-200"}`}
                                onMouseEnter={() => setHoverRating(starValue)}
                                onMouseLeave={() => setHoverRating(0)}
                                onClick={() => setRating(starValue)}
                            />
                        );
                    })}
                </div>

                <textarea 
                    className="w-full border border-slate-300 rounded-lg p-4 mb-4 text-gray-700 focus:outline-none focus:border-slate-800 resize-none h-32"
                    placeholder="Share your experience..."
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                />

                <div className="mb-6">
                    <label className="block text-sm font-medium text-gray-700 mb-2">Add Photo (Max 5)</label>
                    <div className="flex flex-col gap-3">
                        <label className="cursor-pointer bg-gray-50 border-dashed border-gray-300 rounded-lg px-4 py-2 flex items-center justify-center gap-2 hover:bg-gray-100">
                            <FaCamera className="text-gray-500" />
                            <span className="text-sm text-gray-600">Choose Images</span>
                            <input type="file" accept="image/*" multiple className="hidden" onChange={handleImageChange} />
                        </label>

                        {previewImageUrls.length > 0 && (
                            <div className="flex gap-2 overflow-x-auto py-2">
                                {previewImageUrls.map((src, idx) => (
                                    <div key={idx} className="relative w-16 h-16 shrink-0 group">
                                        <img src={src} alt={`Preview ${idx}`} className="w-full h-full object-cover rounded-md border" />
                                        <button onClick={() => removeImage(idx)} className="absolute -top-1 -right-1 bg-red-500 text-white rounded-full p-0.5 text-[10px] opacity-0 group-hover:opacity-100">
                                            <FaTimes />
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>

                <button 
                    onClick={handleSubmit}
                    disabled={isSubmitting}
                    className={`w-full py-3 rounded-lg text-white font-bold transition ${isSubmitting ? 'bg-slate-500' : 'bg-[#1e293b] hover:bg-slate-700'}`}
                >
                    {isSubmitting ? 'Submitting...' : 'Post Review'}
                </button>
            </div>
        </div>
    );
};

// --- Sub-component for an individual Review Card ---
const ReviewCard = ({ review }) => {
    const images = Array.isArray(review.image) ? review.image : (review.image ? [review.image] : []);
    const mainImage = images[0] || null;
    const extraImages = images.slice(1, 4);

    return (
        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
            <div className="flex gap-4 mb-4">
                <div className="w-32 h-20 shrink-0 rounded-lg overflow-hidden border">
                    {mainImage ? (
                        <img src={getImageSrc(mainImage)} alt="Review" className="w-full h-full object-cover" />
                    ) : (
                        <div className="w-full h-full bg-gray-200 flex items-center justify-center text-xs text-gray-400">No Img</div>
                    )}
                </div>
                <div className='text-left'>
                    <div className="flex text-yellow-400 text-xs mb-1">
                        {[...Array(review.rating || 0)].map((_, i) => <FaStar key={i} />)}
                    </div>
                    <h3 className="font-bold text-[#1e293b] mb-1">Traveler</h3>
                    <p className="text-gray-500 text-[10px] leading-tight line-clamp-3">{review.comment}</p>
                </div>
            </div>
            <div className="mt-auto">
                <p className="text-[10px] text-gray-500 mb-2">More picture from the reviews</p>
                <div className="flex items-center gap-2 h-10">
                    {extraImages.length > 0 ? (
                        extraImages.map((img, idx) => (
                            <div key={idx} className="w-15 h-10 rounded-md overflow-hidden border shrink-0">
                                <img src={getImageSrc(img)} alt={`Extra ${idx}`} className="w-full h-full object-cover" />
                            </div>
                        ))
                    ) : (
                        <span className="text-[10px] text-gray-300 italic">No extra photos</span>
                    )}
                    {images.length > 4 && (
                        <button className="text-[10px] text-gray-500 underline hover:text-black ml-auto whitespace-nowrap">
                            +{images.length - 4} More
                        </button>
                    )}
                    {images.length > 0 && images.length <= 4 && (
                         <button className="text-[10px] text-gray-500 underline hover:text-black ml-auto whitespace-nowrap">
                            See Detail
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};


// --- Main Page Component ---
const MyTripReviewPage = () => {
    const navigate = useNavigate();
    const { id } = useParams();

    const [routeDetail, setRouteDetail] = useState(null);
    const [reviews, setReviews] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isBookmarked, setIsBookmarked] = useState(false);
    const [isBookmarking, setIsBookmarking] = useState(false);
    const [bookmarkId, setBookmarkId] = useState(null);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [currentImage, setCurrentImage] = useState(0); // State for image slider

    const fetchData = useCallback(async () => {
        try {
            const [routeRes, reviewsRes, bookmarksRes] = await Promise.all([
                apiService.getRouteData(id),
                apiService.getReviewPlace(id),
                apiService.getBookmarkRoute(),
            ]);

            setRouteDetail(routeRes.data || null);

            const reviewsData = reviewsRes.data;
            setReviews(Array.isArray(reviewsData) ? reviewsData : (reviewsData?.data || []));

            const bookmarksData = bookmarksRes.data;
            const bookmarkList = Array.isArray(bookmarksData) ? bookmarksData : (bookmarksData?.data || []);
            const foundBookmark = bookmarkList.find(item => item.route_id === parseInt(id));

            setIsBookmarked(!!foundBookmark);
            setBookmarkId(foundBookmark?.bookmark_id || null);

        } catch (error) {
            console.error("Error fetching data:", error);
        } finally {
            setLoading(false);
        }
    }, [id]);

    useEffect(() => {
        if (id) {
            setLoading(true);
            fetchData();
        }
    }, [id, fetchData]);

    const handleBookmark = useCallback(async () => {
        if (isBookmarking) return;
        
        setIsBookmarking(true);
        try {
            if (isBookmarked && bookmarkId) {
                await apiService.deleteBookmarkRoute(bookmarkId);
                alert("Bookmark removed successfully!");
                setIsBookmarked(false);
                setBookmarkId(null);
            } else {
                const response = await apiService.postBookmarkRoute(id);
                alert("Added to bookmarks!");
                setIsBookmarked(true);
                // The new bookmark ID might be in the response, let's try to get it without a full refetch.
                if (response.data?.bookmark_id) {
                    setBookmarkId(response.data.bookmark_id);
                } else {
                    await fetchData(); // Fallback to refetch if ID not in response
                }
            }
        } catch (error) {
            console.error("Failed to update bookmark status:", error);
            const errorMessage = error.response?.data?.message || "An error occurred.";
            alert(`Error: ${errorMessage}`);
        } finally {
            setIsBookmarking(false);
        }
    }, [isBookmarking, isBookmarked, bookmarkId, id, fetchData]);
    
    const handleReviewSubmissionSuccess = () => {
        setIsModalOpen(false);
        fetchData();
    };

    if (loading) {
        return <div className="min-h-screen flex items-center justify-center"><div className="text-gray-500 font-bold">Loading details...</div></div>;
    }

    if (!routeDetail) {
        return <div className="min-h-screen flex items-center justify-center"><div className="text-red-500 font-bold">Location Not Found</div></div>;
    }

    const sliderImages = routeDetail.image ? [routeDetail.image] : [];

    return (
        <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
            <div className="w-full max-w-7xl">
                <div className="flex justify-between items-center mb-6">
                    <button onClick={() => navigate(-1)} className="flex items-center gap-2 text-black font-bold text-xl hover:text-gray-600">
                        <FaChevronLeft /> 
                        <span>{routeDetail.title}</span> 
                    </button>
                    <div className="flex text-yellow-400 text-2xl gap-1">
                        {[...Array(5)].map((_, i) => <FaStar key={i} />)}
                    </div>
                </div>

                <div className="bg-white p-2 rounded-2xl shadow-sm mb-6">
                    <div className="relative w-full h-64 md:h-[400px] rounded-xl overflow-hidden">
                        {sliderImages.length > 0 ? (
                            <img 
                                src={getImageSrc(sliderImages[currentImage])} 
                                alt={routeDetail.title} 
                                className="w-full h-full object-cover"
                            />
                        ) : (
                            <div className="w-full h-full flex items-center justify-center bg-gray-200 text-gray-400">
                                No Image Available
                            </div>
                        )}
                    </div>
                </div>

                <div className="flex justify-end items-center gap-4 mb-8">
                    <div onClick={handleBookmark} className="cursor-pointer transition hover:scale-110" title={isBookmarked ? "Saved" : "Save this place"}>
                        {isBookmarked ? (
                            <FaBookmark className="text-3xl text-[#1e293b]" />
                        ) : (
                            <FaRegBookmark className="text-3xl text-[#1e293b] hover:text-gray-600" />
                        )}
                    </div>
                    <button onClick={() => setIsModalOpen(true)} className="bg-[#1e293b] text-white px-8 py-2 rounded-lg font-medium text-sm hover:bg-slate-700">
                        Add review
                    </button>
                </div>

                <h2 className="text-xl font-bold text-[#1e293b] mb-6">Review from the people’s</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {reviews.length > 0 ? (
                        reviews.map((item) => <ReviewCard key={item.review_id} review={item} />)
                    ) : (
                        <div className="col-span-3 text-center text-gray-400 py-10">
                            No reviews yet for this location.
                        </div>
                    )}
                </div>
            </div>

            <AddReviewModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                routeId={parseInt(id)}
                onSubmitSuccess={handleReviewSubmissionSuccess}
            />
        </div>
    );
};

export default MyTripReviewPage;