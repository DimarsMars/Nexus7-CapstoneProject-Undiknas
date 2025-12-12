import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaStar, FaBookmark } from "react-icons/fa";

const MyTripReviewPage = ({ trips, myreviewstrips }) => {
  const navigate = useNavigate();
  const { id } = useParams();

  const trip = trips ? trips.find(t => t.id === parseInt(id)) : null;
  const [currentImage, setCurrentImage] = useState(0);

  if (!trip) {
      return <div className="min-h-screen flex items-center justify-center">Trip Not Found</div>;
  }

  let sliderImages = trip.route?.map(item => item.image) || [];

  if (sliderImages.length === 0) {
      sliderImages = [trip.image];
  }

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
      <div className="w-full max-w-7xl">
        
        {/* HEADER: JUDUL & TOMBOL BACK */}
        <div className="flex justify-between items-center mb-6">
            <button 
                onClick={() => navigate('/myprofile')}
                className="flex items-center gap-2 text-black font-bold text-xl hover:text-gray-600 transition"
            >
                <FaChevronLeft /> 
                <span>{trip.title}</span> 
            </button>

            <div className="flex text-yellow-400 text-2xl gap-1">
                {[...Array(5)].map((_, i) => <FaStar key={i} />)}
            </div>
        </div>

        {/* IMAGE SLIDER */}
        <div className="bg-white p-2 rounded-2xl shadow-sm mb-6">
            <div className="relative w-full h-64 md:h-[400px] rounded-xl overflow-hidden group">
                <img 
                    src={sliderImages[currentImage]} 
                    alt="Slider" 
                    className="w-full h-full object-cover transition-all duration-500"
                />
                
                <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-3">
                    {sliderImages.map((_, idx) => (
                        <button 
                            key={idx}
                            onClick={() => setCurrentImage(idx)}
                            className={`w-3 h-3 rounded-full transition-all ${
                                currentImage === idx ? "bg-[#1e293b] scale-125" : "bg-gray-300/80 hover:bg-white"
                            }`}
                        />
                    ))}
                </div>
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
            {myreviewstrips.map((item) => (
                <div key={item.id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col h-full">
                    <div className="flex gap-4 mb-4">
                        <div className="w-24 h-20 shrink-0 rounded-lg overflow-hidden">
                            <img src={item.image} alt="Review" className="w-full h-full object-cover" />
                        </div>

                        <div className='text-left'>
                            <div className="flex text-yellow-400 text-xs mb-1">
                                {[...Array(item.rating)].map((_, i) => <FaStar key={i} />)}
                            </div>
                            <h3 className="font-bold text-[#1e293b] mb-1">Review</h3>
                            <p className="text-gray-500 text-[10px] leading-tight line-clamp-3">
                                {item.text}
                            </p>
                        </div>
                    </div>

                    <div className="mt-auto">
                        <p className="text-[10px] text-gray-500 mb-2">More picture from the reviews</p>
                        <div className="flex items-center gap-2">
                            {item.moreImages.map((img, idx) => (
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
            ))}
        </div>

      </div>
    </div>
  );
};

export default MyTripReviewPage;