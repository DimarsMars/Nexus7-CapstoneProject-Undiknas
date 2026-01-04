import { createContext, useState, useContext, useEffect } from 'react';
import apiService from '../services/apiService';
import { useAuth } from './AuthContext';

const DataContext = createContext();

export const DataProvider = ({ children }) => {
    const { user } = useAuth();
    const [plans, setPlans] = useState([]);
    const [loadingPlans, setLoadingPlans] = useState(false);
    
    const [favoriteTrips, setFavoriteTrips] = useState([]);
    const [searchQuery, setSearchQuery] = useState("");

    // GET FAVORITES
    const fetchFavorites = async () => {
        try {
            const response = await apiService.getFavorite();
            if (response.data) {
                setFavoriteTrips(response.data);
            }
        } catch (error) {
            console.error("Error fetching favorites:", error);
        }
    };

    // Load favorites saat aplikasi pertama kali dibuka
    useEffect(() => {
        if (user) {
            fetchFavorites();
        }
    }, [user]);

    // ADD FAVORITE (POST)
    const addFavorite = async (planId) => {
        try {
            const response = await apiService.postFavorite(planId);
            await fetchFavorites();
        } catch (error) {
            console.error("Error adding favorite:", error);
            alert("Gagal menambahkan ke favorite");
        }
    };

    // REMOVE FAVORITE (DELETE)
    const removeFavorite = async (favoriteId) => {
        try {
            await apiService.deleteFavorite(favoriteId);
            await fetchFavorites();
        } catch (error) {
            console.error("Error removing favorite:", error);
            alert("Gagal menghapus favorite");
        }
    };

    const fetchAllPlan = async (forceRefresh = false) => {
        if (!forceRefresh && plans.length > 0) {
            return; 
        }
        setLoadingPlans(true);
        try {
            const response = await apiService.getAllPlan();
            
            let receivedData = [];
            if (response.data && Array.isArray(response.data)) {
                receivedData = response.data;
            } 

            setPlans(receivedData);
        } catch (error) {
            console.error("Error fetching plans in Context:", error);
        } finally {
            setLoadingPlans(false);
        }
    };
    
    const fetchAllPlanByUserLogin = async () => {
        if (plans.length > 0) {
            return; 
        }
        setLoadingPlans(true);
        try {
            const response = await apiService.getAllPlanByUserLogin();
            
            let receivedData = [];
            if (response.data && Array.isArray(response.data)) {
                receivedData = response.data;
            } 

            setPlans(receivedData);
        } catch (error) {
            console.error("Error fetching plans in Context:", error);
        } finally {
            setLoadingPlans(false);
        }
    };

    // --- Route Creation State ---
    const [currentRouteWaypoints, setCurrentRouteWaypoints] = useState([]);

    const setWaypoints = (newWaypoints) => {
        setCurrentRouteWaypoints(newWaypoints);
    }

    const addWaypoint = (waypoint) => {
        setCurrentRouteWaypoints((prev) => {
            const isDuplicate = prev.some(item => item.lat === waypoint.lat && item.lng === waypoint.lng);
            return isDuplicate ? prev : [...prev, waypoint];
        });
    };

    const addWaypoints = (waypoints) => {
        setCurrentRouteWaypoints((prev) => {
            const newWaypoints = waypoints.filter(newWp => 
                !prev.some(prevWp => prevWp.lat === newWp.lat && prevWp.lng === newWp.lng)
            );
            return [...prev, ...newWaypoints];
        });
    };

    const deleteWaypoint = (index) => {
        setCurrentRouteWaypoints((prev) => prev.filter((_, i) => i !== index));
    };

    const editWaypoint = (index, updatedData) => {
        setCurrentRouteWaypoints((prev) => {
            const newWaypoints = [...prev];
            newWaypoints[index] = { ...newWaypoints[index], ...updatedData };
            return newWaypoints;
        });
    };

    const uploadWaypointImage = (index, imageBase64) => {
        setCurrentRouteWaypoints((prev) => {
            const newWaypoints = [...prev];
            newWaypoints[index].image = imageBase64;
            return newWaypoints;
        });
    };
    
    const clearRouteWaypoints = () => {
        setCurrentRouteWaypoints([]);
    };

    const value = {
        plans,
        loadingPlans,
        fetchAllPlan,
        fetchAllPlanByUserLogin,
        favoriteTrips,
        addFavorite,
        removeFavorite,
        fetchFavorites,
        searchQuery, 
        setSearchQuery,
        // Waypoint management
        currentRouteWaypoints,
        setWaypoints,
        addWaypoint,
        addWaypoints,
        deleteWaypoint,
        editWaypoint,
        uploadWaypointImage,
        clearRouteWaypoints,
    };

    return (
        <DataContext.Provider value={value}>
            {children}
        </DataContext.Provider>
    );
};

export const useData = () => useContext(DataContext);