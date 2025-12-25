import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useData } from "../context/DataContext";
import CreatePlanSection from "../components/CreatePlanSection";
import HeroSection from "../components/HeroSection";
import PlansCategory from "../components/PlanCategorySection";
import TravellerSection from "../components/TravellerSection";
import TripCard from "../components/TripCard";

const HomePage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const { plans, fetchAllPlan } = useData();

  useEffect(() => {
    if (user) {
      fetchAllPlan();
    }
  }, [user]);

  const handleCardClick = (id) => {
    navigate(`/trip/${id}`);
  };

    return (
        <div className="min-h-screen bg-gray-100 py-10 pt-28 px-5">
            <HeroSection plans={plans} />
            <div className="max-w-7xl mx-auto pb-25">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {plans && plans.slice(0, 3).map((plan, index) => (
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
                    onClick={() => handleCardClick(plan.plan_id)}
                    />
                ))}
                </div>

                <div className="text-right mt-4">
                    <a href="/explore" className="text-gray-600 text-sm font-semibold hover:underline">See More</a>
                </div>
            </div>

            <CreatePlanSection />
            <PlansCategory />
            <TravellerSection />

        </div>
    );
};

export default HomePage;