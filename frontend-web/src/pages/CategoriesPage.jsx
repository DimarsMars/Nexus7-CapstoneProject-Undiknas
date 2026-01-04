import { useEffect, useState, useCallback } from 'react'; // Added useCallback
import { FaChevronLeft } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import apiService from '../services/apiService';

const CategoriesPage = () => {
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);

  // Memoize the fetchCategories function
  const fetchCategories = useCallback(async () => {
    try {
      const response = await apiService.getCategories();
      setCategories(response.data || []);
    } catch (error) {
      console.error("Error fetching categories:", error);
      setCategories([]); // Ensure categories is an empty array on error
    }
  }, []); // Empty dependency array as it doesn't depend on any props or state

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]); // Add fetchCategories to useEffect dependencies

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 pb-20 px-5">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)} // Navigate back to the previous page
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Categories
            </h1>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-8 md:gap-8">   
            {categories.length > 0 ? ( // Conditional rendering for categories
                categories.map((cat) => (
                    <div key={cat.category_id} className="group cursor-pointer flex flex-col items-center mb-4">
                        <div className="w-full h-48 md:h-64 rounded-lg overflow-hidden shadow-sm mb-2 relative">
                            <img 
                                src={`data:image/jpeg;base64,${cat.image}`} 
                                alt={cat.name} 
                                className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                            />
                            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors duration-300"></div>
                        </div>

                        <p className="text-md md:text-md font-medium text-gray-800 group-hover:text-black text-center">
                            {cat.name}
                        </p>
                    </div>
                ))
            ) : (
                <div className="col-span-full text-center text-gray-500 py-10">
                    No categories found.
                </div>
            )}
        </div>
      </div>
    </div>
  );
};

export default CategoriesPage;