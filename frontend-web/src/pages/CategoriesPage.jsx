import { useEffect, useState } from 'react';
import { FaChevronLeft } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import apiService from '../services/apiService';

const CategoriesPage = () => {
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiService.getCategories();
        setCategories(response.data || []);
      } catch (error) {
        console.error("Error fetching categories:", error);
      }
    };

    fetchCategories();
  }, []);

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 pb-20 px-5">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)} // Kembali ke halaman sebelumnya
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Categories
            </h1>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-8 md:gap-8">   
            {categories.map((cat) => (
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
            ))}

        </div>

      </div>
    </div>
  );
};

export default CategoriesPage;