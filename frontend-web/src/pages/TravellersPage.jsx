import { FaChevronLeft } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import TravellerCard from '../components/TravellerCard';
import { useEffect, useState } from "react";
import apiService from "../services/apiService";

const TravellersPage = () => {
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
        
        let rawData = [];
        if (response.data && Array.isArray(response.data.data)) {
            rawData = response.data.data;
        } else if (Array.isArray(response.data)) {
            rawData = response.data;
        }

        // --- SOLUSI DEDUPLIKASI & PENGGABUNGAN KATEGORI ---
        // Gunakan Map untuk menyimpan user unik berdasarkan user_id.
        // Jika user sudah ada, tambahkan kategori barunya ke daftar kategori user tersebut.
        const userMap = new Map();

        rawData.forEach((item) => {
            const userId = item.user.user_id;
            // Ambil kategori dari item saat ini (bersihkan spasi)
            const currentCategory = item.category ? item.category.trim() : "";

            if (userMap.has(userId)) {
                // Jika user sudah ada, tambahkan kategori baru jika belum ada
                const existingUser = userMap.get(userId);
                if (currentCategory && !existingUser.displayCategories.includes(currentCategory)) {
                    existingUser.displayCategories.push(currentCategory);
                }
            } else {
                // Jika user belum ada, buat entri baru
                userMap.set(userId, {
                    ...item, // Salin semua data item
                    displayCategories: currentCategory ? [currentCategory] : [] // Buat array kategori
                });
            }
        });

        // Konversi Map kembali ke Array
        const uniqueTravellers = Array.from(userMap.values());
        setTravellersByCategory(uniqueTravellers);

      } catch (error) {
        console.error("Error fetching travellers:", error);
      }
    };

    fetchTravellersByCategory();
}, []);

  const handleCardClick = (user_Id) => {
        navigate(`/profile/${user_Id}`);
    };

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
                {travellersByCategory.map((person) => (
                  <div 
                        key={person.user.user_id} 
                        onClick={() => handleCardClick(person.user.user_id)}
                        className="cursor-pointer"
                    >
                    <TravellerCard 
                        id={person.user.user_id}
                        image={person.user.photo} 
                        name={person.user.username}
                        role={person.user.role}
                        categories={person.displayCategories.join(", ")}
                    />
                  </div>
                ))}
            </div>
        </div>

        <div className="mb-12">
            <h2 className="text-lg md:text-xl font-bold text-gray-800 mb-6">
                Most Active Traveller
            </h2>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-5">
                {mostActive.map((person) => (
                  <div 
                        key={person.user_id} 
                        onClick={() => handleCardClick(person.user_id)}
                        className="cursor-pointer"
                    >
                      <TravellerCard 
                          key={person.user_id}
                          id={person.user_id}
                          image={person.photo}
                          name={person.username}
                          role={person.role}
                      />
                    </div>
                ))}
            </div>
        </div>

      </div>
    </div>
  );
};

export default TravellersPage;