import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaChevronLeft, FaFilter } from "react-icons/fa";

import BookmarkedCard from '../components/BookmarkedCard';
import apiService from '../services/apiService';
import { useData } from '../context/DataContext';

const BookmarkedPage = () => {
  const navigate = useNavigate();
  const { addWaypoints } = useData();

  const [savedItems, setSavedItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedIds, setSelectedIds] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");

  const fetchBookmarks = useCallback(async () => {
    setLoading(true);
    try {
      const response = await apiService.getBookmarkRoute();
      // API might return data directly or nested, so we handle both cases.
      const bookmarkList = Array.isArray(response.data) ? response.data : (response.data.data || []);
      setSavedItems(bookmarkList);
    } catch (error) {
      console.error("Failed to fetch bookmarks:", error);
      setSavedItems([]); // Reset on error to prevent displaying stale data.
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBookmarks();
  }, [fetchBookmarks]);

  const handleToggleSelect = (bookmarkId) => {
    setSelectedIds(currentIds =>
      currentIds.includes(bookmarkId)
        ? currentIds.filter(id => id !== bookmarkId)
        : [...currentIds, bookmarkId]
    );
  };

  const handleRemoveItem = async (bookmarkIdToRemove) => {
    // Optimistically update the UI for a faster user experience.
    setSavedItems(currentItems =>
      currentItems.filter(item => item.bookmark_id !== bookmarkIdToRemove)
    );
    setSelectedIds(currentIds => currentIds.filter(id => id !== bookmarkIdToRemove));

    try {
      await apiService.deleteBookmarkRoute(bookmarkIdToRemove);
    } catch (error)
    {
      console.error("Failed to delete bookmark on server:", error);
      alert("Failed to remove bookmark. Refreshing the list.");
      fetchBookmarks(); // Re-sync with the server on failure.
    }
  };

  const handleRemoveAll = async () => {
    if (!window.confirm("Are you sure you want to remove all saved items?")) {
      return;
    }

    const allBookmarkIds = savedItems.map(item => item.bookmark_id);
    
    // Optimistically update the UI.
    setSavedItems([]);
    setSelectedIds([]);

    try {
      await Promise.all(allBookmarkIds.map(id => apiService.deleteBookmarkRoute(id)));
    } catch (error) {
      console.error("Failed to remove all bookmarks:", error);
      alert("Could not remove all items. The list will be refreshed.");
      fetchBookmarks(); // Re-sync on failure.
    }
  };

  const handleAddToRoute = () => {
    const itemsToAdd = savedItems
      .filter(item => selectedIds.includes(item.bookmark_id))
      .map(item => ({
        lat: item.route.latitude,
        lng: item.route.longitude,
        name: item.route.title,
        address: item.route.address,
        description: item.route.description,
        image: item.route.image || ''
      }));
    
    if (itemsToAdd.length > 0) {
      addWaypoints(itemsToAdd);
      alert(`${itemsToAdd.length} items added to the route!`);
      setSelectedIds([]);
      navigate('/maps');
    }
  };

  const filteredItems = savedItems.filter(item =>
    item.route?.title?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        Loading bookmarks...
      </div>
    );
  }

  const isAnythingSelected = selectedIds.length > 0;
  const hasSavedItems = savedItems.length > 0;
  const hasFilteredItems = filteredItems.length > 0;

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-30">
      <div className="max-w-7xl mx-auto">
        
        {/* Header */}
        <div className="flex items-center gap-4 mb-8">
            <button onClick={() => navigate(-1)} className="p-2 hover:bg-gray-200 rounded-full transition">
                <FaChevronLeft className="text-xl text-black" />
            </button>
            <h1 className="text-xl font-bold text-black">Bookmarked</h1>
        </div>

        {/* Search Bar */}
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

        {/* Saved Items Section */}
        <div className="mb-8">
            <div className="flex justify-between items-center mb-4">
                <h2 className="text-md font-bold text-[#1e293b]">Saved</h2>
                {hasSavedItems && (
                    <button 
                        onClick={handleRemoveAll}
                        className="bg-slate-900 text-white font-normal text-sm px-5 py-2 rounded-md hover:bg-slate-900"
                    >
                        Remove all
                    </button>
                )}
            </div>

            <div className="flex flex-col gap-4">
                {hasFilteredItems ? (
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
                    <p className="text-center text-gray-400 py-10">
                        {searchQuery ? "No items match your search." : "No saved items found."}
                    </p>
                )}
            </div>
        </div>

        {/* Add to Route Button */}
        {hasSavedItems && (
            <div className="flex justify-center mb-10">
                <button 
                    onClick={handleAddToRoute}
                    disabled={!isAnythingSelected}
                    className={`px-5 py-2 rounded-md font-semibold text-white shadow-md transition-all ${
                        isAnythingSelected 
                            ? "bg-slate-900 hover:bg-slate-700" 
                            : "bg-gray-400 cursor-not-allowed"
                    }`}
                >
                    Add to route
                </button>
            </div>
        )}

      </div>
    </div>
  );
};

export default BookmarkedPage;