import CreatePlanSection from "../components/CreatePlanSection";
import HeroSection from "../components/HeroSection";
import PlansCategory from "../components/PlanCategorySection";
import TravellerSection from "../components/TravellerSection";
import TripCard from "../components/TripCard"
import { useEffect, useState } from "react";
import apiService from "../services/apiService";
import { useAuth } from "../context/AuthContext";

const HomePage = ({ trips, travellers }) => {
  const [plan, setPlan] = useState([]);
  const { user } = useAuth();

  useEffect(() => {
    const fetchAllPlan = async () => {
      try {
        const response = await apiService.getAllPlan();
        setPlan(response.data || []);
      } catch (error) {
        console.error("Error fetching categories:", error);
      }
    };

    if (user) {
      fetchAllPlan();
    }
  }, [user]);

    return (
        <div className="min-h-screen bg-gray-100 py-10 pt-28 px-5">
            <HeroSection trips={trips} />
            <div className="max-w-7xl mx-auto pb-25">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {plan && plan.slice(0, 3).map((plan, index) => (
                    <TripCard
                    key={plan.plan_id}
                    id={plan.plan_id}
                    title={plan.title}
                    author={plan.description}
                    rating={plan.rating || 5} 
                    image={`data:image/jpeg;base64,${plan.banner}`}
                    className={
                        index === 0
                        ? "md:col-span-2 h-64 md:h-80" 
                        : "h-64"                       
                    }
                    />
                ))}
                </div>

                <div className="text-right mt-4">
                    <a href="/explore" className="text-gray-600 text-sm font-semibold hover:underline">See More</a>
                </div>
            </div>

            <CreatePlanSection />
            <PlansCategory />
            <TravellerSection travellers={travellers}/>

        </div>
    );
};

export default HomePage;