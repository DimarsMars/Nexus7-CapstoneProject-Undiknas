import { FaCertificate } from "react-icons/fa";
import TripCard from '../components/TripCard';
import ReviewCard from '../components/ReviewCard';
import UserReviewCard from '../components/UserReviewCard';

const MyProfilePage = ({ user, trips, myReviews, othersReviews }) => {

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-28 flex justify-center items-start md:items-center">
      <div className="bg-white w-full max-w-7xl p-6 md:p-10 rounded-xl shadow-sm">
        
        {/* BAGIAN ATAS: PROFIL & STATS */}
        <div className="flex flex-col md:flex-row items-center px-30 justify-between md:items-start gap-6 md:gap-12">
            <div className="shrink-0">
                <div className="w-32 h-32 md:w-45 md:h-45 rounded-full overflow-hidden border-4 border-gray-200 shadow-lg">
                    <img src={user.image} alt="Profile" className="w-full h-full object-cover" />
                </div>
            </div>

            <div className="flex flex-col justify-center text-center md:text-left gap-4 mt-1">
                
                <div>
                    <h3 className="text-gray-400 text-sm font-normal mb-0.5">Name</h3>
                    <h1 className="text-xl md:text-2xl font-bold text-[#1e293b] tracking-wide">{user.name}</h1>
                </div>

                <div>
                    <h3 className="text-gray-400 text-sm font-normal mb-1">Rank’s</h3>
                    <div className="flex items-center justify-center md:justify-start gap-2">
                        <div className="relative flex items-center justify-center text-white">
                             <FaCertificate className="text-black text-3xl" /> 
                             <span className="absolute font-bold text-xs">{user.rankLevel}</span>
                        </div>
                        <h2 className="text-xl font-bold text-[#1e293b]">{user.rank}</h2>
                    </div>
                </div>
            </div>

            <div className="flex flex-col gap-10 w-full md:w-auto mt-4 md:mt-0">
                <div className="flex gap-3 items-center">
                    <div className="relative flex items-center justify-center text-white shrink-0">
                        <FaCertificate className="text-[#0f172a] text-5xl drop-shadow-md" />
                        <span className="absolute font-bold text-lg">{user.stats.travelScore.level}</span>
                    </div>
                    <div className="w-full">
                        <h4 className="font-bold text-[#1e293b] text-sm">Traveling Score’s</h4>
                        <p className="text-[10px] text-gray-500 font-medium">XP {user.stats.travelScore.xp}</p>
                        <p className="font-bold text-xs text-[#1e293b] mt-0.5">{user.stats.travelScore.title}</p>
                        
                        <div className="w-40 h-1.5 bg-gray-200 rounded-full mt-1 overflow-hidden">
                            <div className="h-full bg-[#1e293b] w-[60%] rounded-full"></div>
                        </div>
                    </div>
                </div>

                <div className="flex gap-3 items-center">
                    <div className="relative flex items-center justify-center text-white shrink-0">
                        <FaCertificate className="text-[#0f172a] text-5xl drop-shadow-md" />
                        <span className="absolute font-bold text-lg">{user.stats.routeScore.level}</span>
                    </div>
                    <div className="w-full">
                        <h4 className="font-bold text-[#1e293b] text-sm">Route Score</h4>
                        <p className="text-[10px] text-gray-500 font-medium">XP {user.stats.routeScore.xp}</p>
                        <p className="font-bold text-xs text-[#1e293b] mt-0.5">{user.stats.routeScore.title}</p>
                        
                        <div className="w-40 h-1.5 bg-gray-200 rounded-full mt-1 overflow-hidden">
                            <div className="h-full bg-[#1e293b] w-[60%] rounded-full"></div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        {/* BAGIAN TENGAH: GARIS & LINK */}
        <div className="mt-8 mb-8">
            <div className="border-t-2 border-[#1e293b] mb-4"></div>
            <div className="flex flex-col gap-2 items-center text-[#1e293b] text-base font-medium">
                <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Location</a>
                <a href="#" className="underline decoration-1 underline-offset-4 hover:text-gray-600">Languages</a>
            </div>
            <div className="border-t-2 border-[#1e293b] mt-4"></div>
        </div>

        {/* BAGIAN BAWAH: TOMBOL ACTION */}
        <div className="flex flex-col gap-3">
            <button className="w-full py-2.5 bg-[#1e293b] text-white text-sm font-semibold rounded-lg hover:bg-slate-700 transition shadow-sm tracking-wide">
                Edit Profile
            </button>
            <button className="w-full py-2.5 bg-[#ff0000] text-white text-sm font-semibold rounded-lg hover:bg-red-700 transition shadow-sm tracking-wide">
                Log Out
            </button>
        </div>


        {/* SECTION MY ROUTE */}
        <div className="pt-15">
            <div className="flex items-center gap-2 mb-4 cursor-pointer group">
                <h2 className="text-lg md:text-xl font-bold text-slate-900 mb-2">My Route</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {trips && trips.slice(0, 3).map((trip, index) => (
                    <TripCard
                        key={trip.id}
                        title={trip.title}
                        author={trip.author}
                        rating={trip.rating}
                        image={trip.image}
                        className={
                            index === 0
                            ? "md:col-span-2 h-56 md:h-72" // Kartu Besar
                            : "h-56 md:h-60"               // Kartu Kecil
                        }
                    />
                ))}

            </div>
        </div>

        {/* SECTION YOUR REVIEW */}
        <div className="pt-15">
            <h2 className="text-lg md:text-xl font-bold text-start text-slate-900 mb-2">
                Your review
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {myReviews.map((review) => (
                    <ReviewCard
                        key={review.id}
                        image={review.image}
                        title={review.title}
                        description={review.description}
                        location={review.location}
                        rating={review.rating}
                        onDelete={() => alert(`Delete review ${review.title}?`)}
                    />
                ))}
            </div>
        </div>

        {/* SECTION THOSE WHO REVIEW YOU */}
        <div className="pt-15 text-start">
            <div className="flex items-center gap-2 cursor-pointer group">
                <h2 className="text-lg md:text-xl font-bold text-slate-900 mb-2">Those who review you</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {othersReviews.map((item) => (
                    <UserReviewCard
                        key={item.id}
                        image={item.image}
                        name={item.name}
                        role={item.role}
                        rating={item.rating}
                        review={item.text}
                        onDelete={() => alert("Delete user review?")}
                    />
                ))}
            </div>
        </div>    

      </div>
    </div>
  );
};

export default MyProfilePage;