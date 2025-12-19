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

const getAllPlan = () => {
  return apiClient.get('/plans/');
};

const apiService = {
  updateUserProfile,
  getUserMe,
  getProfileMe,
  getCategories,
  createPlan,
  getAllPlan,
};

export default apiService;