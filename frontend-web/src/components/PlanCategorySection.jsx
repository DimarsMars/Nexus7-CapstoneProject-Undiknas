import { Link } from 'react-router-dom';
import { useEffect, useState } from 'react';
import apiService from '../services/apiService';
import { useAuth } from '../context/AuthContext';

const PlansCategory = () => {
  const [categories, setCategories] = useState([]);
  const { user } = useAuth();

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiService.getCategories();
        setCategories(response.data || []);
      } catch (error) {
        console.error("Error fetching categories:", error);
      }
    };

    if (user) {
      fetchCategories();
    }
  }, [user]);

  return (
    <section className="px-5 my-16">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl font-bold text-center text-black mb-10">Plan’s Category</h2>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-6">
          {categories.slice(0, 4).map((item) => (
            <div key={item.category_id} className="flex flex-col items-center group cursor-pointer">
              <div className="w-full h-32 md:h-40 rounded-lg overflow-hidden shadow-sm mb-2">
                <img 
                    src={`data:image/jpeg;base64,${item.image}`} 
                    alt={item.name} 
                    className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
                />
              </div>

              <p className="text-md font-medium text-gray-800 group-hover:text-black">{item.name}</p>
            </div>
          ))}
        </div>

        <div className="text-right mt-5">
             <Link to="/categories" className="text-gray-600 text-sm font-semibold hover:text-gray-600 transition hover:underline">
                See More
             </Link>
        </div>

      </div>
    </section>
  );
};

export default PlansCategory;