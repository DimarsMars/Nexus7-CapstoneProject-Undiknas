import { useState, useEffect, useRef } from 'react'; // 1. Tambahkan useRef
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import TripCard from './TripCard';
import logoJourneys from '../assets/images/logoJourneys.png';
import apiService from '../services/apiService';

const HeroSection = ({ plans = [] }) => {
  const [activeIndex, setActiveIndex] = useState(0);
  const [categories, setCategories] = useState([]);
  const [activeTab, setActiveTab] = useState("All");

  // --- 2. SETUP VARIABLE UTK DRAG SCROLL ---
  const scrollRef = useRef(null);
  const [isDragging, setIsDragging] = useState(false);
  const [startX, setStartX] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);

  useEffect(() => {
    const fetchCategories = async () => {
        try {
            const response = await apiService.getCategories();
            if (response.data) {
                const fetchedCategories = response.data;
                const allCategory = { id: 'all', name: 'All' };
                setCategories([allCategory, ...fetchedCategories]);
            } else {
                setCategories([{ id: 'all', name: 'All' }]);
            }
        } catch (error) {
            console.error("Failed to fetch categories:", error);
            setCategories([{ id: 'all', name: 'All' }]);
        }
    };
    fetchCategories();
  }, []);

  // --- 3. LOGIKA DRAG (SAMA SEPERTI EXPLORE PAGE) ---
  const handleMouseDown = (e) => {
    setIsDragging(true);
    setStartX(e.pageX - scrollRef.current.offsetLeft);
    setScrollLeft(scrollRef.current.scrollLeft);
  };

  const handleMouseLeave = () => {
    setIsDragging(false);
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleMouseMove = (e) => {
    if (!isDragging) return;
    e.preventDefault();
    const x = e.pageX - scrollRef.current.offsetLeft;
    const walk = (x - startX) * 1; // Kecepatan geser
    scrollRef.current.scrollLeft = scrollLeft - walk;
  };

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
      style += "z-20 scale-100 opacity-100 translate-x-0 border-2 border-white/50";
    } else if (index === prevIndex) {
      style += "z-10 scale-[0.85] opacity-60 -translate-x-[50%] pointer-events-none";
    } else if (index === nextIndex) {
      style += "z-10 scale-[0.85] opacity-60 translate-x-[50%] pointer-events-none";
    } else {
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
            
            {/* 4. TEMPELKAN REF DAN EVENT HANDLER DI SINI */}
            <div
              ref={scrollRef}
              onMouseDown={handleMouseDown}
              onMouseLeave={handleMouseLeave}
              onMouseUp={handleMouseUp}
              onMouseMove={handleMouseMove}
              className={`bg-white rounded-full shadow-md p-2 w-full max-w-sm flex justify-start border-3 border-gray-200 items-center overflow-x-auto ${
                 isDragging ? 'cursor-grabbing' : 'cursor-grab'
              }`} // Tambah cursor style
              style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
            >
                {categories.map((cat) => (
                    <button
                        key={cat.id}
                        onClick={() => {
                            // Cek agar tidak kepencet saat lagi geser
                            if(!isDragging) setActiveTab(cat.name);
                        }}
                        // Tambah 'select-none' agar teks tidak ke-blok saat drag
                        className={`px-5 py-2 rounded-full text-md font-medium transition-all duration-300 whitespace-nowrap select-none ${
                            activeTab === cat.name
                            ? "bg-slate-800 text-white shadow-sm"
                            : "text-gray-500 hover:text-black"
                        }`}
                    >
                        {cat.name}
                    </button>
                ))}
            </div>
        </div>

        {/* BAGIAN KANAN (Tidak Berubah) */}
        <div 
          className="w-full md:w-6/12 relative flex items-center justify-center h-[400px]"
          style={{ perspective: '1000px' }} 
        >
            <button onClick={prevSlide} className="absolute -left-4 md:-left-10 z-30 p-3 bg-white/50 backdrop-blur-sm rounded-full text-xl hover:bg-white transition cursor-pointer shadow-sm">
                <FaChevronLeft />
            </button>
            <button onClick={nextSlide} className="absolute -right-4 md:-right-10 z-30 p-3 bg-white/50 backdrop-blur-sm rounded-full text-xl hover:bg-white transition cursor-pointer shadow-sm">
                <FaChevronRight />
            </button>

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
                            isClickable={false}
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