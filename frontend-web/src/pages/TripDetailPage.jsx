import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FaStar, FaBookmark, FaChevronLeft } from "react-icons/fa";
import RouteCard from '../components/RouteCard';

const TripDetailPage = ({ trips }) => {
  const { id } = useParams();
  const navigate = useNavigate();

  const trip = trips.find(t => t.id === parseInt(id));

  if (!trip) return <div className="min-h-screen text-gray-400 flex items-center justify-center text-md font-bold">Trip not found</div>;

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30 flex justify-center">
      <div className="w-full max-w-7xl">
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)} // Kembali ke halaman sebelumnya
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
                <img src={trip.image} alt={trip.title} className="w-full h-full object-cover" />
            </div>

            <div className="mb-4">
                <div className="flex justify-between items-start">
                    <h1 className="text-3xl font-bold text-[#1e293b]">{trip.title}</h1>
                    <div className="hidden md:block bg-[#5e6c7c] text-white px-4 py-1 rounded text-sm font-medium cursor-pointer hover:bg-[#4a5568]">Rate trip</div>
                </div>
                
                <div className="flex gap-1 mt-2 text-yellow-400 text-xl">
                    {[...Array(5)].map((_, i) => (
                        <FaStar key={i} className={i < trip.rating ? "text-yellow-400" : "text-gray-200"} />
                    ))}
                </div>
            </div>

            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 border-b border-gray-100 pb-6">
                <div className="flex gap-3">
                    <button className="bg-[#1e293b] text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-slate-700 transition shadow-sm">
                        Set Trip
                    </button>
                    <button className="bg-red-600 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-red-700 transition shadow-sm">
                        Report
                    </button>
                </div>
                
                <div className="flex gap-2 items-center w-full md:w-auto justify-between md:justify-end">
                    <div className="flex flex-wrap gap-2">
                        {trip.tags?.map((tag, idx) => (
                            <span key={idx} className="bg-gray-200 text-gray-600 text-xs px-3 py-1 rounded-full font-medium">
                                #{tag}
                            </span>
                        ))}
                    </div>
                    <FaBookmark className="text-2xl text-[#1e293b] cursor-pointer ml-4 hover:text-blue-600 transition" title="Save Trip" />
                </div>
            </div>

            <div className="mb-8">
                <p className="text-gray-600 text-base leading-relaxed text-justify">
                    {trip.description || "No description available for this trip."}
                </p>
            </div>

            <div className="flex flex-col gap-4">
                <h3 className="text-xl font-bold text-[#1e293b] mb-2">Trip Route</h3>
                {trip.route && trip.route.length > 0 ? (
                    trip.route.map((item, index) => (
                        <RouteCard 
                            key={index}
                            image={item.image}
                            title={item.title}
                            activity={item.activity || "Sightseeing"}
                            location={item.location}
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
    </div>
  );
};

export default TripDetailPage;