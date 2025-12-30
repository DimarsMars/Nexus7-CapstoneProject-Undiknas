import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import TripCard from '../components/TripCard';
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import { useData } from '../context/DataContext';
import { useAuth } from '../context/AuthContext';
import apiService from '../services/apiService';

const ExplorePage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState("");
  const [categories, setCategories] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 7;

  const { plans, fetchAllPlan, searchQuery } = useData();
  const { user } = useAuth();

  useEffect(() => {
    const fetchCategories = async () => {
        try {
            const response = await apiService.getCategories();
            if (response.data) {
                setCategories(response.data);
                if (response.data.length > 0) {
                    setActiveTab(response.data[0].name);
                }
            }
        } catch (error) {
            console.error("Failed to fetch categories:", error);
        }
    };
    if (user) {
        fetchCategories();
    }
  }, [user]);

  useEffect(() => {
    setCurrentPage(1);
  }, [activeTab, searchQuery]);

  useEffect(() => {
    if (user) {
      fetchAllPlan();
    }
  }, [user]);

  // --- LOGIKA FILTERING ---
  // filter dulu datanya sebelum dipotong (pagination)
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

  const scrollRef = useRef(null); 
  const [isDragging, setIsDragging] = useState(false);
  const [startX, setStartX] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);

  const goToNextPage = () => {
    if (currentPage < totalPages) setCurrentPage(prev => prev + 1);
  };
  const goToPrevPage = () => {
    if (currentPage > 1) setCurrentPage(prev => prev - 1);
  };

  const handleCardClick = (id) => {
    navigate(`/trip/${id}`);
  };

  // 3. FUNGSI LOGIKA DRAG (GESER PAKAI MOUSE)
  const handleMouseDown = (e) => {
    setIsDragging(true);
    setStartX(e.pageX - scrollRef.current.offsetLeft);
    setScrollLeft(scrollRef.current.scrollLeft);
  };

  const handleMouseLeave = () => {
    setIsDragging(false);
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleMouseMove = (e) => {
    if (!isDragging) return;
    e.preventDefault();
    const x = e.pageX - scrollRef.current.offsetLeft;
    const walk = (x - startX) * 1;
    scrollRef.current.scrollLeft = scrollLeft - walk;
  };

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 px-5">
      <div className="max-w-7xl mx-auto">
        
        <div
          ref={scrollRef}
          onMouseDown={handleMouseDown}
          onMouseLeave={handleMouseLeave}
          onMouseUp={handleMouseUp}
          onMouseMove={handleMouseMove}
          className={`bg-white rounded-xl shadow-sm p-2 mb-10 flex justify-start items-center overflow-x-auto space-x-2 no-scrollbar ${
                isDragging ? 'cursor-grabbing' : 'cursor-grab'
            }`}>
            {categories.map((cat) => (
                <button
                    key={cat.id}
                    className={`px-6 py-3 rounded-lg text-sm md:text-base font-medium transition-all duration-300 whitespace-nowrap select-none ${
                        activeTab === cat.name 
                        ? "text-black font-bold" 
                        : "text-gray-500 hover:text-gray-800"
                    }`}
                    onClick={() => {
                        if(!isDragging) setActiveTab(cat.name)
                    }}
                >
                    {cat.name}
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
                    author={plan.author_name || "Unknown Author"}
                    rating={plan.rating}
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