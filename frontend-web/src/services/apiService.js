import apiClient from "./apiClient";

const updateUserProfile = (payload) => {
  return apiClient.put('/profile/update', payload);
};

const getUserMe = () => {
  return apiClient.get('/user/me');
};

const getProfileMe = () => {
  return apiClient.get('/profile/me');
};

const getCategories = () => {
  return apiClient.get('/category/');
};

const createPlan = (planData) => {
  return apiClient.post('/plans/', planData);
};

const getAllPlanByUserLogin = () => {
  return get('/plans/');
};

const getAllPlan = () => {
  return apiClient.get('/plans/all');
};

const getMostActiveTravellers = () => {
  return apiClient.get('/user/mostactive');
};

const getTravellersByCategory = () => {
  return apiClient.get('/user/recomendations/category');
}

const apiService = {
  updateUserProfile,
  getUserMe,
  getProfileMe,
  getCategories,
  createPlan,
  getAllPlan,
  getAllPlanByUserLogin,
  getMostActiveTravellers,
  getTravellersByCategory
};

export default apiService;