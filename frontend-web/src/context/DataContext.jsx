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

    const fetchAllPlan = async () => {
        if (plans.length > 0) {
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
        setSearchQuery
    };

    return (
        <DataContext.Provider value={value}>
            {children}
        </DataContext.Provider>
    );
};

export const useData = () => useContext(DataContext);