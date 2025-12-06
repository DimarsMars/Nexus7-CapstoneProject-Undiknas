import { Link } from 'react-router-dom';

const PlansCategory = ({categories}) => {
  return (
    <section className="px-5 my-16">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl font-bold text-center text-black mb-10">Plan’s Category</h2>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-6">
          {categories.map((item) => (
            <div key={item.id} className="flex flex-col items-center group cursor-pointer">
              <div className="w-full h-32 md:h-40 rounded-lg overflow-hidden shadow-sm mb-2">
                <img 
                    src={item.image} 
                    alt={item.title} 
                    className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
                />
              </div>

              <p className="text-md font-medium text-gray-800 group-hover:text-black">{item.title}</p>
            </div>
          ))}
        </div>

        <div className="text-right mt-5">
             <Link to="/categories" className="text-gray-600 text-sm font-semibold hover:text-gray-600 transition hover:underline">
                See More
             </Link>
        </div>

      </div>
    </section>
  );
};

export default PlansCategory;