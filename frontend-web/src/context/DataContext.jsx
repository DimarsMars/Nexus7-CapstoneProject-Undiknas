import { createContext, useState, useContext } from 'react';
import apiService from '../services/apiService';

const DataContext = createContext();

export const DataProvider = ({ children }) => {
    const [plans, setPlans] = useState([]);
    const [loadingPlans, setLoadingPlans] = useState(false);

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

    return (
        <DataContext.Provider value={{ plans, loadingPlans, fetchAllPlan }}>
            {children}
        </DataContext.Provider>
    );
};

export const useData = () => useContext(DataContext);