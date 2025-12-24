import { Link } from 'react-router-dom';
import { useEffect, useState } from "react";
import apiService from "../services/apiService";

const TravellerSection = () => {
  const [travellers, setTravellers] = useState([]);

  useEffect(() => {
    const fetchTravellers = async () => {
      try {
        const response = await apiService.getAllUsers();
  
        if (response.data && Array.isArray(response.data)) {
             setTravellers(response.data);
        } else if (response.data && response.data.data && Array.isArray(response.data.data)) {
             setTravellers(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching travellers:", error);
      }
    };

    fetchTravellers();
  }, []);

  return (
    <section className="px-5 my-16">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-800 mb-10">
            Follow These Traveller
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8 md:gap-2 justify-items-center">
            
            {travellers?.map((person) => (
                <div key={person.user_id} className="flex flex-col items-center group cursor-pointer">
                    <div className="w-32 h-32 md:w-40 md:h-40 rounded-full overflow-hidden shadow-lg border-4 border-transparent group-hover:border-white transition-all duration-300 transform group-hover:scale-105">
                        <img 
                            src={person.photo} 
                            alt={person.username} 
                            className="w-full h-full object-cover"
                        />
                    </div>
                    <h3 className="mt-4 text-md font-medium text-gray-900 group-hover:text-slate-800 transition-colors">
                        {person.username}
                    </h3>
                </div>
            ))}

        </div>

        <div className="text-right mt-5">
             <Link to="/travellers" className="text-gray-600 text-sm font-semibold hover:text-gray-600 transition hover:underline">
                See More
             </Link>
        </div>

      </div>
    </section>
  );
};

export default TravellerSection;