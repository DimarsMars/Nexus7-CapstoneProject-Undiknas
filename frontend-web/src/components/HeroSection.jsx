import React from 'react';
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import TripCard from './TripCard';
// Pastikan kamu punya logo versi hitam/gelap sesuai gambar
// Jika belum ada, ganti path ini dengan logo yang sesuai
import logoJourneys from '../assets/images/logoJourneys.png'; 

const HeroSection = ({trips}) => {
  return (
    <section className="bg-gray-100 py-10 px-5 mb-15">
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-10">
        
        {/* === BAGIAN KIRI: Logo & Menu Kategori === */}
        <div className="w-full md:w-5/12 flex flex-col items-center md:items-start space-y-10">
            
            {/* Logo */}
            {/* Jika gambar tidak muncul, pastikan path import logo benar */}
            <img src={logoJourneys} alt="Journeys Logo" className="w-64 md:w-80" />
            
            {/* Menu Kapsul (Pill Menu) */}
            <div className="bg-white rounded-full shadow-md px-8 py-3 flex space-x-6 text-md font-medium text-gray-700">
                <button className="hover:text-black transition">Culture</button>
                <button className="hover:text-black transition">Eatery</button>
                <button className="hover:text-black transition">Health</button>
                <button className="hover:text-black transition">Craft's</button>
            </div>
        </div>

        {/* === BAGIAN KANAN: Carousel / Slider Look === */}
        <div className="w-full md:w-6/12 relative flex items-center justify-center h-[400px]">
            
            {/* Tombol Panah Kiri */}
            <button className="absolute -left-3 z-20 p-2 bg-transparent text-2xl font-bold hover:scale-110 transition">
                <FaChevronLeft />
            </button>

            {/* Kartu Belakang (Kiri) - Efek Tertutup */}
            <div className="absolute left-4 top-10 scale-90 opacity-80 z-0 w-64 h-80 pointer-events-none">
                 <TripCard 
                    title={trips[0].title}
                    author={trips[0].author}
                    rating={trips[0].rating}
                    image={trips[0].image}
                    className="h-full"
                 />
            </div>

            {/* Kartu Belakang (Kanan) - Efek Tertutup */}
            <div className="absolute right-4 top-10 scale-90 opacity-80 z-0 w-64 h-80 pointer-events-none">
                 <TripCard 
                    title={trips[2].title}
                    author={trips[2].author}
                    rating={trips[2].rating}
                    image={trips[2].image}
                    className="h-full"
                 />
            </div>

            {/* Kartu UTAMA (Tengah) - Paling Depan & Jelas */}
            <div className="relative z-10 w-72 h-96 shadow-2xl transform hover:scale-105 transition duration-300">
                 <TripCard 
                    title={trips[1].title}
                    author={trips[1].author}
                    rating={trips[1].rating}
                    image={trips[1].image}
                    className="h-full border-2 border-white" 
                 />
            </div>

             {/* Tombol Panah Kanan */}
             <button className="absolute -right-3 z-20 p-2 bg-transparent text-2xl font-bold hover:scale-110 transition">
                <FaChevronRight />
            </button>

        </div>

      </div>
    </section>
  );
};

export default HeroSection;