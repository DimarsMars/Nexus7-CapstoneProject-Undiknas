import { FaChevronLeft } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import TravellerCard from '../components/TravellerCard';
import { useEffect, useState } from "react";
import apiService from "../services/apiService";

const TravellersPage = ({ recommendationData }) => {
  const navigate = useNavigate();
  const [mostActive, setMostActive] = useState([]);
  const [travellersByCategory, setTravellersByCategory] = useState([]);

  useEffect(() => {
    const fetchMostActive = async () => {
      try {
        const response = await apiService.getMostActiveTravellers();
        setMostActive(response.data);
      } catch (error) {
        console.error("Error fetching most active travellers:", error);
      }
    };

    fetchMostActive();
  }, []);

useEffect(() => {
    const fetchTravellersByCategory = async () => {
      try {
        const response = await apiService.getTravellersByCategory();
      
        if (response.data && Array.isArray(response.data.data)) {
            setTravellersByCategory(response.data.data);
        } else if (Array.isArray(response.data)) {
            setTravellersByCategory(response.data);
        }

      } catch (error) {
        console.error("Error fetching travellers:", error);
      }
    };

    fetchTravellersByCategory();
}, []);

  return (
    <div className="min-h-screen bg-gray-100 py-10 pt-30 px-5">
      <div className="max-w-7xl mx-auto">
        
        <div className="flex items-center gap-4 mb-5">
            <button 
                onClick={() => navigate(-1)} 
                className="p-2 hover:bg-gray-200 rounded-full transition"
            >
                <FaChevronLeft className="text-lg text-black" />
            </button>
            <h1 className="text-2xl md:text-xl font-bold text-black">
                Recommendation
            </h1>
        </div>

        <div className="mb-12">
            <h2 className="text-lg md:text-xl font-bold text-gray-800 mb-6">
                You may like
            </h2>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-5">
                {travellersByCategory?.map((item, index) => {
                    const person = item.user; 

                    return (
                        <TravellerCard 
                            key={person.user_id || index} 
                            id={person.user_id}
                            image={person.photo} 
                            name={person.username}
                            role={person.role}
                        />
                    );
                })}
            </div>
        </div>

        <div className="mb-12">
            <h2 className="text-lg md:text-xl font-bold text-gray-800 mb-6">
                Most Active Traveller
            </h2>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-5">
                {mostActive?.map((person) => (
                    <TravellerCard 
                        key={person.user_id}
                        id={person.user_id}
                        image={person.photo}
                        name={person.username}
                        role={person.role}
                    />
                ))}
            </div>
        </div>

      </div>
    </div>
  );
};

export default TravellersPage;