import { useState, useEffect } from 'react';
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import TripCard from './TripCard';
import logoJourneys from '../assets/images/logoJourneys.png';

const HeroSection = ({ plans = [] }) => {
  const [activeIndex, setActiveIndex] = useState(0);

  // Helper untuk membatasi Karakter
  const truncateText = (text, maxLength) => {
    if (!text) return "";
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + "...";
  };

  const nextSlide = () => {
    setActiveIndex((current) => (current === plans.length - 1 ? 0 : current + 1));
  };
  const prevSlide = () => {
    setActiveIndex((current) => (current === 0 ? plans.length - 1 : current - 1));
  };

  useEffect(() => {
    const interval = setInterval(() => {
      nextSlide();
    }, 4000); 
    return () => clearInterval(interval);
  }, [activeIndex, plans.length]);

  // --- FUNGSI GAYA (STYLE) KARTU ---
  const getCardStyle = (index) => {
    const len = plans.length;
    const prevIndex = (activeIndex - 1 + len) % len;
    const nextIndex = (activeIndex + 1) % len;

    let style = "absolute top-0 w-72 h-96 transition-all duration-1000 ease-in-out shadow-xl rounded-2xl ";

    if (index === activeIndex) {
      // KARTU TENGAH (AKTIF)
      style += "z-20 scale-100 opacity-100 translate-x-0 border-2 border-white/50";
    } else if (index === prevIndex) {

      // KARTU KIRI
      style += "z-10 scale-[0.85] opacity-60 -translate-x-[50%] pointer-events-none";
    } else if (index === nextIndex) {
      
      // KARTU KANAN
      style += "z-10 scale-[0.85] opacity-60 translate-x-[50%] pointer-events-none";
    } else {

      // KARTU LAINNYA (YANG TIDAK TERLIHAT)
      style += "z-0 scale-50 opacity-0 translate-x-0 pointer-events-none";
    }
    return style;
  };

  if (!plans || plans.length === 0) {
      return <div className="text-center py-20">Loading Hero Section...</div>;
  }

  return (
    <section className="bg-gray-100 py-20 px-5 mb-15 overflow-hidden">
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-10">
        
        {/* BAGIAN KIRI */}
        <div className="w-full md:w-5/12 flex flex-col items-center md:items-center space-y-10 z-30 relative">
            <img src={logoJourneys} alt="Journeys Logo" className="w-64 md:w-80" />
            <div className="bg-white rounded-full shadow-md px-8 py-3 flex space-x-6 text-md font-medium text-gray-700">
                <button className="hover:text-black transition">Culture</button>
                <button className="hover:text-black transition">Eatery</button>
                <button className="hover:text-black transition">Health</button>
                <button className="hover:text-black transition">Craft's</button>
            </div>
        </div>

        {/* BAGIAN KANAN */}
        <div 
          className="w-full md:w-6/12 relative flex items-center justify-center h-[400px]"
          style={{ perspective: '1000px' }} 
        >
            {/* TOMBOL NAVIGASI */}
            <button onClick={prevSlide} className="absolute -left-4 md:-left-10 z-30 p-3 bg-white/50 backdrop-blur-sm rounded-full text-xl hover:bg-white transition cursor-pointer shadow-sm">
                <FaChevronLeft />
            </button>
            <button onClick={nextSlide} className="absolute -right-4 md:-right-10 z-30 p-3 bg-white/50 backdrop-blur-sm rounded-full text-xl hover:bg-white transition cursor-pointer shadow-sm">
                <FaChevronRight />
            </button>

            {/* MAPPING SEMUA KARTU */}
            <div className="relative w-full h-full flex items-center justify-center">
              {plans.map((item, index) => (
                  <div 
                    key={item.plan_id}
                    className={getCardStyle(index)}
                  >
                     <div className="w-full h-full rounded-2xl overflow-hidden">
                        <TripCard 
                            title={item.title}
                            author={truncateText(item.description, 50)}
                            rating={item.rating || 5}
                            image={`data:image/jpeg;base64,${item.banner}`}
                            className="h-full shadow-none rounded-none" 
                        />
                     </div>
                  </div>
              ))}
            </div>

        </div>
      </div>
    </section>
  );
};

export default HeroSection;