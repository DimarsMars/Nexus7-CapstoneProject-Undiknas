import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaSearch, FaFilter } from "react-icons/fa";
import BookmarkedCard from '../components/BookmarkedCard';

const BookmarkedPage = ({ bookmarkedData }) => {
  const navigate = useNavigate();

  // 2. STATE MANAGEMENT
  const [savedItems, setSavedItems] = useState(bookmarkedData);
  const [selectedIds, setSelectedIds] = useState([]);
  const [routeItems, setRouteItems] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");


  const handleToggleSelect = (id) => {
    if (selectedIds.includes(id)) {
      setSelectedIds(selectedIds.filter(itemId => itemId !== id));
    } else {
      setSelectedIds([...selectedIds, id]);
    }
  };

  // Hapus item dari Saved
  const handleRemoveItem = (id) => {
    setSavedItems(savedItems.filter(item => item.id !== id));
    // Hapus juga dari selection jika ada
    if(selectedIds.includes(id)) {
        setSelectedIds(selectedIds.filter(itemId => itemId !== id));
    }
  };

  const handleRemoveAll = () => {
    if(window.confirm("Are you sure you want to remove all saved items?")) {
        setSavedItems([]);
        setSelectedIds([]);
    }
  };

  const handleAddToRoute = () => {
    // Ambil object data berdasarkan ID yang dipilih
    const itemsToAdd = savedItems.filter(item => selectedIds.includes(item.id));
    
    // Masukkan ke state routeItems (hindari duplikat jika perlu)
    // Disini saya buat sederhana: timpa atau gabung
    const newRoute = [...routeItems];
    itemsToAdd.forEach(item => {
        if (!newRoute.find(r => r.id === item.id)) {
            newRoute.push(item);
        }
    });
    
    setRouteItems(newRoute);
    setSelectedIds([]);
    alert(`${itemsToAdd.length} items added to route!`);
  };

  // Filter Search
  const filteredItems = savedItems.filter(item => 
    item.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
    item.category.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30">
      <div className="max-w-7xl mx-auto">
        
        {/* HEADER */}
        <div className="flex items-center gap-4 mb-8">
            <button onClick={() => navigate(-1)} className="p-2 hover:bg-gray-200 rounded-full transition">
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-xl font-bold text-black">Bookmarked</h1>
        </div>

        {/* SEARCH BAR */}
        <div className="relative mb-8">
            <input 
                type="text" 
                placeholder="Restaurant..." 
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-5 pr-12 text-gray-700 focus:outline-none focus:border-slate-500 shadow-sm"
            />
            <button className="absolute right-3 top-1/2 -translate-y-1/2 bg-[#1e293b] p-2 rounded-lg text-white">
                <FaFilter size={12} />
            </button>
        </div>

        {/* SAVED SECTION */}
        <div className="mb-8">
            <div className="flex justify-between items-center mb-4">
                <h2 className="text-md font-bold text-[#1e293b]">Saved</h2>
                {savedItems.length > 0 && (
                    <button 
                        onClick={handleRemoveAll}
                        className="bg-slate-900 text-white font-normal text-sm px-5 py-2 rounded-md hover:bg-slate-900"
                    >
                        Remove all
                    </button>
                )}
            </div>

            {/* List Saved Cards */}
            <div className="flex flex-col gap-4">
                {filteredItems.length > 0 ? (
                    filteredItems.map((item) => (
                        <BookmarkedCard 
                            key={item.id}
                            item={item}
                            isSelected={selectedIds.includes(item.id)}
                            onToggleSelect={handleToggleSelect}
                            onRemove={handleRemoveItem}
                        />
                    ))
                ) : (
                    <p className="text-center text-gray-400 py-10">No saved items found.</p>
                )}
            </div>
        </div>

        {/* ADD TO ROUTE BUTTON */}
        {savedItems.length > 0 && (
            <div className="flex justify-center mb-10">
                <button 
                    onClick={handleAddToRoute}
                    disabled={selectedIds.length === 0}
                    className={`px-5 py-2 rounded-md font-semibold text-white shadow-md transition-all
                        ${selectedIds.length > 0 
                            ? "bg-slate-900 hover:bg-slate-700" 
                            : "bg-gray-400 cursor-not-allowed"}
                    `}
                >
                    Add to route
                </button>
            </div>
        )}

        {/* ADDED TO ROUTE (Visualisasi Hasil) */}
        {routeItems.length > 0 && (
            <div className="border-t-2 border-gray-200 pt-8">
                <h2 className="text-lg font-bold text-[#1e293b] mb-4">Current Route Plan</h2>
                <div className="flex flex-col gap-4 opacity-80">
                    {routeItems.map((item) => (
                        <div key={item.id} className="pointer-events-none grayscale-[0.2]">
                             <BookmarkedCard 
                                item={item}
                                isSelected={true}
                                onToggleSelect={() => {}} 
                                onRemove={() => {}}
                            />
                        </div>
                    ))}
                </div>
            </div>
        )}

      </div>
    </div>
  );
};

export default BookmarkedPage;