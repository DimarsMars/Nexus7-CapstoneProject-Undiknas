import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaFilter } from "react-icons/fa";
import BookmarkedCard from '../components/BookmarkedCard';
import apiService from '../services/apiService';

const BookmarkedPage = () => {
  const navigate = useNavigate();

  const [savedItems, setSavedItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedIds, setSelectedIds] = useState([]);
  const [routeItems, setRouteItems] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");

  const fetchBookmarks = async () => {
    try {
      setLoading(true);
      const response = await apiService.getBookmarkRoute();
      
      if (response.data) {
        const bookmarkList = Array.isArray(response.data) ? response.data : (response.data.data || []);
        setSavedItems(bookmarkList);
      } else {
        setSavedItems([]);
      }
    } catch (error) {
      console.error("Gagal mengambil data bookmark:", error);
      setSavedItems([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookmarks();
  }, []);

  const handleToggleSelect = (bookmarkId) => {
    if (selectedIds.includes(bookmarkId)) {
      setSelectedIds(selectedIds.filter(id => id !== bookmarkId));
    } else {
      setSelectedIds([...selectedIds, bookmarkId]);
    }
  };

  const handleRemoveItem = async (bookmarkIdToRemove) => {
    setSavedItems(currentItems =>
      currentItems.filter(item => item.bookmark_id !== bookmarkIdToRemove)
    );
    if (selectedIds.includes(bookmarkIdToRemove)) {
      setSelectedIds(currentIds => currentIds.filter(id => id !== bookmarkIdToRemove));
    }

    try {
      await apiService.deleteBookmarkRoute(bookmarkIdToRemove);
    } catch (error) {
      console.error("Gagal menghapus bookmark di server:", error);
      alert("Failed to remove bookmark. Refreshing list.");
      fetchBookmarks(); // Re-sync with server on failure
    }
  };

  const handleRemoveAll = async () => {
    if (window.confirm("Are you sure you want to remove all saved items?")) {
      const allBookmarkIds = savedItems.map(item => item.bookmark_id);
      
      setSavedItems([]);
      setSelectedIds([]);

      try {
        await Promise.all(allBookmarkIds.map(id => apiService.deleteBookmarkRoute(id)));
      } catch (error) {
        console.error("Failed to remove all bookmarks:", error);
        alert("Could not remove all items. Please refresh.");
        fetchBookmarks();
      }
    }
  };

  const handleAddToRoute = () => {
    const itemsToAdd = savedItems
      .filter(item => selectedIds.includes(item.bookmark_id))
      .map(item => item.route);
    
    const newRoute = [...routeItems];
    itemsToAdd.forEach(item => {
      if (!newRoute.find(r => r.route_id === item.route_id)) {
        newRoute.push(item);
      }
    });
    
    setRouteItems(newRoute);
    setSelectedIds([]);
    alert(`${itemsToAdd.length} items added to route!`);
  };

  const filteredItems = savedItems.filter(item =>
    item.route && item.route.title && item.route.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading bookmarks...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30">
      <div className="max-w-7xl mx-auto">
        
        <div className="flex items-center gap-4 mb-8">
            <button onClick={() => navigate(-1)} className="p-2 hover:bg-gray-200 rounded-full transition">
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-xl font-bold text-black">Bookmarked</h1>
        </div>

        <div className="relative mb-8">
            <input 
                type="text" 
                placeholder="Search places..." 
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-5 pr-12 text-gray-700 focus:outline-none focus:border-slate-500 shadow-sm"
            />
            <button className="absolute right-3 top-1/2 -translate-y-1/2 bg-[#1e293b] p-2 rounded-lg text-white">
                <FaFilter size={12} />
            </button>
        </div>

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

            <div className="flex flex-col gap-4">
                {filteredItems.length > 0 ? (
                    filteredItems.map((item) => (
                        <BookmarkedCard 
                            key={item.bookmark_id}
                            item={item.route}
                            isSelected={selectedIds.includes(item.bookmark_id)}
                            onToggleSelect={() => handleToggleSelect(item.bookmark_id)}
                            onRemove={() => handleRemoveItem(item.bookmark_id)}
                        />
                    ))
                ) : (
                    <p className="text-center text-gray-400 py-10">No saved items found.</p>
                )}
            </div>
        </div>

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

        {routeItems.length > 0 && (
            <div className="border-t-2 border-gray-200 pt-8">
                <h2 className="text-lg font-bold text-[#1e293b] mb-4">Current Route Plan</h2>
                <div className="flex flex-col gap-4 opacity-80">
                    {routeItems.map((item) => (
                        <div key={`route-${item.route_id}`} className="pointer-events-none grayscale-[0.2]">
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