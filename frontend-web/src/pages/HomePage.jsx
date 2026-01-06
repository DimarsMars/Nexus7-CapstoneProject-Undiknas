import { useCallback, useEffect, useMemo, useState } from "react"; // Added useCallback
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useData } from "../context/DataContext";
import apiService from "../services/apiService";
import CreatePlanSection from "../components/CreatePlanSection";
import HeroSection from "../components/HeroSection";
import PlanCategorySection from "../components/PlanCategorySection"; // Renamed import
import TravellerSection from "../components/TravellerSection";
import TripCard from "../components/TripCard";
import placeholderImage from '../assets/images/placeholderTrip.png';

const HomePage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const { plans, fetchAllPlan } = useData();
  const [recommendedPlans, setRecommendedPlans] = useState([]);

  useEffect(() => {
    if (user) {
      fetchAllPlan();
      
      const fetchRecommended = async () => {
        try {
          const response = await apiService.getRecommendedPlans();
          if (response.data && Array.isArray(response.data)) {
            setRecommendedPlans(response.data);
          } else {
            setRecommendedPlans([]);
          }
        } catch (error) {
          console.error("Error fetching recommended plans:", error);
          setRecommendedPlans([]);
        }
      };
      fetchRecommended();
    }
  }, [user, fetchAllPlan]);

  const newestPlans = useMemo(() => {
    if (plans && plans.length > 0) {
      return [...plans].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    }
    return [];
  }, [plans]);

  const handleCardClick = useCallback((id) => { // Wrapped in useCallback
    navigate(`/trip/${id}`);
  }, [navigate]); // Added navigate to dependency array

    return (
        <div className="min-h-screen bg-gray-100 py-10 pt-28 px-5">
            <HeroSection plans={plans} />
            <div className="max-w-7xl mx-auto pb-15">
              <h2 className="text-3xl font-bold text-center text-black mb-10">Newest Plans</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {newestPlans.slice(0, 3).map((plan, index) => (
                    <TripCard
                    key={plan.plan_id}
                    id={plan.plan_id}
                    title={plan.title}
                    author={plan.author_name || "Unknown Author"}
                    rating={plan.rating} 
                    image={plan.banner ? `data:image/jpeg;base64,${plan.banner}` : placeholderImage}
                    className={
                        index === 0
                        ? "md:col-span-2 h-64 md:h-80" 
                        : "h-64"                       
                    }
                    onClick={() => handleCardClick(plan.plan_id)}
                    />
                ))}
                </div>

                <div className="text-right mt-4">
                    <a href="/explore" className="text-gray-600 text-sm font-semibold hover:underline">See More</a>
                </div>
            </div>

            <div className="max-w-7xl mx-auto pb-25">
              <h2 className="text-3xl font-bold text-center text-black mb-10">Plans by your Personalisation</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {recommendedPlans.slice(0, 3).map((plan, index) => (
                    <TripCard
                    key={plan.plan_id}
                    id={plan.plan_id}
                    title={plan.title}
                    author={plan.author_name || "Unknown Author"}
                    rating={plan.rating} 
                    image={plan.banner ? `data:image/jpeg;base64,${plan.banner}` : placeholderImage}
                    className={
                        index === 0
                        ? "md:col-span-2 h-64 md:h-80" 
                        : "h-64"                       
                    }
                    onClick={() => handleCardClick(plan.plan_id)}
                    />
                ))}
                </div>

                <div className="text-right mt-4">
                    <a href="/explore" className="text-gray-600 text-sm font-semibold hover:underline">See More</a>
                </div>
            </div>

            <CreatePlanSection />
            <PlanCategorySection /> {/* Updated component name */}
            <TravellerSection />

        </div>
    );
};

export default HomePage;