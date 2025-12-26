import React, { createContext, useState, useContext, useEffect } from 'react';
import apiService from '../services/apiService';

const TripContext = createContext();

export const useTrip = () => useContext(TripContext);

export const TripProvider = ({ children }) => {
  const [activeTrip, setActiveTrip] = useState(null);
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isLoading, setIsLoading] = useState(true); // Loading state for fetching the trip

  // On initial load, check localStorage for an active trip ID and fetch its data
  useEffect(() => {
    const activeTripId = localStorage.getItem('activeTripId');
    const savedStepIndex = localStorage.getItem('currentStepIndex');

    if (activeTripId) {
      apiService.getPlanForRunTrip(activeTripId)
        .then(response => {
          setActiveTrip(response.data);
          if (savedStepIndex) {
            setCurrentStepIndex(parseInt(savedStepIndex, 10));
          }
        })
        .catch(error => {
          console.error("Failed to load saved trip", error);
          // Clear invalid saved data if fetch fails
          localStorage.removeItem('activeTripId');
          localStorage.removeItem('currentStepIndex');
        })
        .finally(() => {
          setIsLoading(false);
        });
    } else {
      setIsLoading(false); // No saved trip, so not loading
    }
  }, []);

  const startTrip = (tripData) => {
    setActiveTrip(tripData);
    setCurrentStepIndex(0);
    setIsPaused(false);
    // Store ONLY the ID and progress in localStorage
    localStorage.setItem('activeTripId', tripData.plan.plan_id);
    localStorage.setItem('currentStepIndex', '0');
  };

  const endTrip = () => {
    setActiveTrip(null);
    setCurrentStepIndex(0);
    localStorage.removeItem('activeTripId');
    localStorage.removeItem('currentStepIndex');
  };

  const nextStep = () => {
    if (activeTrip && currentStepIndex < activeTrip.routes.length - 1) {
      const newStepIndex = currentStepIndex + 1;
      setCurrentStepIndex(newStepIndex);
      localStorage.setItem('currentStepIndex', newStepIndex.toString());
    } else {
      alert("Congratulations! You have completed the trip!");
      endTrip();
    }
  };

  const pauseToggle = () => {
    setIsPaused(prev => !prev);
  };

  const value = {
    activeTrip,
    currentStepIndex,
    isPaused,
    isLoading, // Expose loading state
    isTripActive: activeTrip !== null,
    currentDestination: activeTrip ? activeTrip.routes[currentStepIndex] : null,
    startTrip,
    endTrip,
    nextStep,
    pauseToggle,
  };

  return (
    <TripContext.Provider value={value}>
      {children}
    </TripContext.Provider>
  );
};
