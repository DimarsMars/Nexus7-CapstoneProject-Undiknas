import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaStar, FaBookmark } from "react-icons/fa";
import apiClient from '../services/apiClient'; // Pastikan path import ini benar sesuai struktur folder Anda

const MyTripReviewPage = ({ myreviewstrips }) => {
  const navigate = useNavigate();
  const { id } = useParams(); // Mengambil ID dari URL (misal: 3)

  const [routeDetail, setRouteDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentImage, setCurrentImage] = useState(0);

  // --- 1. FETCH DATA DARI API ---
  useEffect(() => {
    const fetchRouteData = async () => {
        try {
            setLoading(true);
            // Memanggil endpoint sesuai data yang Anda berikan
            // URL: /plans/plans/{id}/route
            const response = await apiClient.get(`/plans/plans/${id}/route`);
            
            // Cek apakah ada data di dalam array response.data
            // Struktur response Anda: { data: [ { title: "...", ... } ] }
            if (response.data && Array.isArray(response.data) && response.data.length > 0) {
                setRouteDetail(response.data[0]); // Ambil item pertama
            } else if (response.data && response.data.data && Array.isArray(response.data.data)) {
                 // Jaga-jaga jika strukturnya { data: { data: [...] } }
                 setRouteDetail(response.data.data[0]);
            } else {
                 console.warn("Data route kosong atau format berbeda", response);
            }

        } catch (error) {
            console.error("Error fetching route detail:", error);
        } finally {
            setLoading(false);
        }
    };

    if (id) {
        fetchRouteData();
    }
  }, [id]);

  // --- 2. HANDLING LOADING & ERROR ---
  if (loading) {
      return (
        <div className="min-h-screen bg-gray-100 flex items-center justify-center">
            <div className="text-gray-500 font-bold">Loading route details...</div>
        </div>
      );
  }

  if (!routeDetail) {
      return (
        <div className="min-h-screen bg-gray-100 flex items-center justify-center">
            <div className="text-red-500 font-bold">Trip Not Found (No Data)</div>
        </div>
      );
  }

  // --- 3. HELPER GAMBAR ---
  const getImageSrc = (img) => {
      if (!img) return null;
      // Jika string base64 belum punya prefix data:image, tambahkan
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
        
        {/* HEADER: JUDUL & TOMBOL BACK */}
        <div className="flex justify-between items-center mb-6">
            <button 
                onClick={() => navigate(-1)} // Balik ke halaman sebelumnya
                className="flex items-center gap-2 text-black font-bold text-xl hover:text-gray-600 transition"
            >
                <FaChevronLeft /> 
                {/* Tampilkan Title dari API */}
                <span>{routeDetail.title || "Unknown Location"}</span> 
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
                        alt="Location" 
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
            <FaBookmark className="text-3xl text-[#1e293b] cursor-pointer hover:text-gray-600 transition" title="Save this place" />
            <button className="bg-[#1e293b] text-white px-8 py-2 rounded-lg font-medium text-sm hover:bg-slate-700 transition">
                Add review
            </button>
        </div>

        {/* REVIEW SECTION */}
        <h2 className="text-xl font-bold text-[#1e293b] mb-6">Review from the people’s</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {myreviewstrips && myreviewstrips.length > 0 ? (
                myreviewstrips.map((item) => (
                    <div key={item.id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
                        <div className="flex gap-4 mb-4">
                            <div className="w-24 h-20 shrink-0 rounded-lg overflow-hidden">
                                <img src={item.image} alt="Review" className="w-full h-full object-cover" />
                            </div>

                            <div className='text-left'>
                                <div className="flex text-yellow-400 text-xs mb-1">
                                    {[...Array(item.rating)].map((_, i) => <FaStar key={i} />)}
                                </div>
                                <h3 className="font-bold text-[#1e293b] mb-1">{item.name}</h3>
                                <p className="text-gray-500 text-[10px] leading-tight line-clamp-3">
                                    {item.text}
                                </p>
                            </div>
                        </div>

                        <div className="mt-auto">
                            <p className="text-[10px] text-gray-500 mb-2">More picture from the reviews</p>
                            <div className="flex items-center gap-2">
                                {item.moreImages && item.moreImages.map((img, idx) => (
                                    <div key={idx} className="w-12 h-10 rounded-md overflow-hidden shrink-0">
                                        <img src={img} alt="More" className="w-full h-full object-cover" />
                                    </div>
                                ))}
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
    </div>
  );
};

export default MyTripReviewPage;