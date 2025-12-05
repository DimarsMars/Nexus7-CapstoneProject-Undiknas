const CreatePlanSection = () => {
  return (
    <section className="px-5 pb-10">
      <div className="max-w-7xl mx-auto">
        
        <div className="relative w-full h-32 md:h-40 rounded-2xl overflow-hidden cursor-pointer group shadow-lg">
          <img
            src="https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=2000&auto=format&fit=crop" 
            alt="Nature Background"
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-black/20 group-hover:bg-black/30 transition-colors duration-300"></div>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
             <h2 className="text-white text-2xl md:text-3xl font-bold tracking-wide drop-shadow-md text-center">
                Create your own plan
             </h2>
             <div className="mt-1 h-[3px] w-32 bg-white rounded-full transition-all duration-300 group-hover:w-48 shadow-sm"></div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default CreatePlanSection;