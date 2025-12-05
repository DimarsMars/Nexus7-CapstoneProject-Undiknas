import React, { useState, useEffect } from 'react';
import TripCard from '../components/TripCard';
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";

const ExplorePage = ({ trips }) => {
  const [activeTab, setActiveTab] = useState("Culture");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 4;

  const categories = ["Culture", "Eatery", "Health", "Craft's"];

  useEffect(() => {
    setCurrentPage(1);
  }, [activeTab]);

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  
  const currentTrips = trips ? trips.slice(indexOfFirstItem, indexOfLastItem) : [];
  const totalPages = trips ? Math.ceil(trips.length / itemsPerPage) : 0;

  const goToNextPage = () => {
    if (currentPage < totalPages) setCurrentPage(prev => prev + 1);
  };

  const goToPrevPage = () => {
    if (currentPage > 1) setCurrentPage(prev => prev - 1);
  };

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5">
      <div className="max-w-7xl mx-auto">
        
        <div className="bg-white rounded-xl shadow-sm p-2 mb-10 flex justify-between md:justify-around items-center overflow-x-auto">
            {categories.map((cat) => (
                <button
                    key={cat}
                    onClick={() => setActiveTab(cat)}
                    className={`px-6 py-3 rounded-lg text-sm md:text-base font-medium transition-all duration-300 whitespace-nowrap ${
                        activeTab === cat 
                        ? "text-black font-bold" 
                        : "text-gray-500 hover:text-gray-800"
                    }`}
                >
                    {cat}
                </button>
            ))}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5 min-h-[500px]">
          {currentTrips.map((trip, index) => {
            const isBigCard = index % 3 === 0;

            return (
              <TripCard
                key={trip.id}
                title={trip.title}
                author={trip.author}
                rating={trip.rating}
                image={trip.image}
                className={
                    isBigCard 
                        ? "md:col-span-2 h-64 md:h-80" // Kartu Besar
                        : "h-64"                       // Kartu Kecil
                }
              />
            );
          })}
        </div>

        {trips && trips.length > itemsPerPage && (
            <div className="flex justify-center items-center gap-6 mt-12">
                
                <button 
                    onClick={goToPrevPage}
                    disabled={currentPage === 1}
                    className={`p-3 rounded-full shadow-md transition flex items-center justify-center ${
                        currentPage === 1 
                        ? "bg-gray-200 text-gray-400 cursor-not-allowed" 
                        : "bg-white text-gray-800 hover:bg-blue-900 hover:text-white"
                    }`}
                >
                    <FaChevronLeft />
                </button>

                <span className="text-gray-600 font-medium">
                    Page {currentPage} of {totalPages}
                </span>

                <button 
                    onClick={goToNextPage}
                    disabled={currentPage === totalPages}
                    className={`p-3 rounded-full shadow-md transition flex items-center justify-center ${
                        currentPage === totalPages 
                        ? "bg-gray-200 text-gray-400 cursor-not-allowed" 
                        : "bg-white text-gray-800 hover:bg-blue-900 hover:text-white"
                    }`}
                >
                    <FaChevronRight />
                </button>
            </div>
        )}

      </div>
    </div>
  );
};

export default ExplorePage;