import { createContext, useState, useContext, useEffect } from 'react';
import apiService from '../services/apiService';

const DataContext = createContext();

export const DataProvider = ({ children }) => {
    const [plans, setPlans] = useState([]);
    const [loadingPlans, setLoadingPlans] = useState(false);
    
    const [favoriteTrips, setFavoriteTrips] = useState(() => {
        const savedFavorites = localStorage.getItem('favoriteTrips');
        return savedFavorites ? JSON.parse(savedFavorites) : [];
    });

    useEffect(() => {
        localStorage.setItem('favoriteTrips', JSON.stringify(favoriteTrips));
    }, [favoriteTrips]);

    const addFavorite = (tripToAdd) => {
        setFavoriteTrips((prevFavorites) => {
            const isAlreadyFavorited = prevFavorites.some(trip => trip.plan_id === tripToAdd.plan_id);
            if (!isAlreadyFavorited) {
                return [...prevFavorites, tripToAdd];
            }
            return prevFavorites;
        });
    };

    const removeFavorite = (tripId) => {
        setFavoriteTrips((prevFavorites) => prevFavorites.filter(trip => trip.plan_id !== tripId));
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
        removeFavorite
    };

    return (
        <DataContext.Provider value={value}>
            {children}
        </DataContext.Provider>
    );
};

export const useData = () => useContext(DataContext);