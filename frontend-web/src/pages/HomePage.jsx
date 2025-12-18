import CreatePlanSection from "../components/CreatePlanSection";
import HeroSection from "../components/HeroSection";
import PlansCategory from "../components/PlanCategorySection";
import TravellerSection from "../components/TravellerSection";
import TripCard from "../components/TripCard"

const HomePage = ({trips, travellers}) => {
    return (
        <div className="min-h-screen bg-gray-100 py-10 pt-28 px-5">

            <HeroSection trips={trips} />

            <div className="max-w-7xl mx-auto pb-25">
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                
                {trips && trips.slice(0, 3).map((trip, index) => (
                    <TripCard
                    key={trip.id}
                    id={trip.id}
                    title={trip.title}
                    author={trip.author}
                    rating={trip.rating}
                    image={trip.image}
                    className={
                        index === 0
                        ? "md:col-span-2 h-64 md:h-80" // Kartu Besar
                        : "h-64"                       // Kartu Kecil
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