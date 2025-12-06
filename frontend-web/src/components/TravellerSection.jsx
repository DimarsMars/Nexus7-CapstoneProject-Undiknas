const TravellerSection = ({ travellers }) => {
  return (
    <section className="px-5 my-16">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-800 mb-10">
            Follow These Traveller
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8 md:gap-2 justify-items-center">
            
            {travellers?.map((person) => (
                <div key={person.id} className="flex flex-col items-center group cursor-pointer">
                    <div className="w-32 h-32 md:w-40 md:h-40 rounded-full overflow-hidden shadow-lg border-4 border-transparent group-hover:border-white transition-all duration-300 transform group-hover:scale-105">
                        <img 
                            src={person.image} 
                            alt={person.name} 
                            className="w-full h-full object-cover"
                        />
                    </div>
                    <h3 className="mt-4 text-md font-medium text-gray-900 group-hover:text-slate-800 transition-colors">
                        {person.name}
                    </h3>
                </div>
            ))}

        </div>

        {/* Tombol See More */}
        <div className="text-right mt-5">
             <a href="#" className="text-gray-600 text-sm font-semibold hover:text-gray-600 transition hover:underline">
                See More
             </a>
        </div>

      </div>
    </section>
  );
};

export default TravellerSection;