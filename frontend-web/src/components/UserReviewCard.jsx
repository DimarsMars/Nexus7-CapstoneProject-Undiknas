import { FaStar, FaTrash } from "react-icons/fa";

const UserReviewCard = ({ image, name, role, review, rating, onDelete }) => {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row gap-6 w-full transition-shadow hover:shadow-md">
      
      {/* BAGIAN KIRI: PROFIL PEREVIEW */}
      <div className="flex flex-col items-center shrink-0 w-full md:w-32">
        <div className="w-24 h-24 mb-3 rounded-3xl overflow-hidden shadow-sm">
          <img 
            src={image} 
            alt={name} 
            className="w-full h-full object-cover"
          />
        </div>

        <h3 className="text-gray-900 font-bold text-lg leading-tight">{name}</h3>
        <p className="text-gray-900 font-bold text-sm mb-3">{role}</p>

        <button className="bg-[#1e293b] text-white text-sm font-medium px-6 py-1.5 rounded-lg hover:bg-slate-700 transition-colors w-full md:w-auto">
          Follow
        </button>
      </div>

      {/* BAGIAN KANAN: ISI REVIEW */}
      <div className="flex flex-col grow relative">
        <div className="flex justify-between items-start mb-3">
            <div className="flex gap-1">
                {[...Array(5)].map((_, i) => (
                    <FaStar 
                        key={i} 
                        className={`text-xl ${i < rating ? "text-yellow-400" : "text-gray-200"}`} 
                    />
                ))}
            </div>

            <button 
                onClick={onDelete}
                className="text-slate-800 text-lg hover:text-red-600 transition p-1"
                title="Delete Review"
            >
                <FaTrash />
            </button>
        </div>

        <p className="text-gray-800 text-base leading-relaxed">
            {review}
        </p>

      </div>
    </div>
  );
};

export default UserReviewCard;