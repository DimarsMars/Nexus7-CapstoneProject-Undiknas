import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import TripCard from '../components/TripCard';
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import { useData } from '../context/DataContext';
import { useAuth } from '../context/AuthContext';

const ExplorePage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState("Culture");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 7;

  const { plans, fetchAllPlan, searchQuery } = useData();
  const { user } = useAuth();

  const categories = ["Culture", "Eatery", "Health", "Craft's"];

  useEffect(() => {
    setCurrentPage(1);
  }, [activeTab, searchQuery]);

  useEffect(() => {
    if (user) {
      fetchAllPlan();
    }
  }, [user]);

  // --- LOGIKA FILTERING ---
  // Kita filter dulu datanya sebelum dipotong (pagination)
  const filteredPlans = plans ? plans.filter(plan => {
      if (!searchQuery) return true;

      // Logic pencarian (Case Insensitive)
      const lowerQuery = searchQuery.toLowerCase();
      const titleMatch = plan.title && plan.title.toLowerCase().includes(lowerQuery);
      const descMatch = plan.description && plan.description.toLowerCase().includes(lowerQuery);

      return titleMatch || descMatch;
  }) : [];

  // LOGIKA PAGINATION (Berdasarkan filteredPlans)
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentTrips = filteredPlans.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredPlans.length / itemsPerPage);

  const goToNextPage = () => {
    if (currentPage < totalPages) setCurrentPage(prev => prev + 1);
  };
  const goToPrevPage = () => {
    if (currentPage > 1) setCurrentPage(prev => prev - 1);
  };

  const handleCardClick = (id) => {
    navigate(`/trip/${id}`);
  };

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 px-5">
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

        {/* Grid Trip */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5 min-h-[500px]">
          {currentTrips.length > 0 ? (
              currentTrips.map((plan, index) => {
                const isBigCard = index % 3 === 0;

                return (
                  <TripCard
                    key={plan.plan_id}
                    id={plan.plan_id}
                    title={plan.title}
                    author={plan.description}
                    rating={plan.rating || 5}
                    image={`data:image/jpeg;base64,${plan.banner}`}
                    className={
                        isBigCard 
                            ? "md:col-span-2 h-64 md:h-80" 
                            : "h-64"                       
                    }
                    onClick={() => handleCardClick(plan.plan_id)}
                  />
                );
              })
          ) : (
              // Tampilan jika hasil pencarian kosong (tanpa merusak layout)
              <div className="md:col-span-2 flex flex-col items-center justify-center text-gray-400">
                  <p className="font-bold text-lg">No trips found</p>
                  <p className="text-sm">Try searching for something else.</p>
              </div>
          )}
        </div>

        {/* Pagination Controls */}
        {filteredPlans.length > itemsPerPage && (
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