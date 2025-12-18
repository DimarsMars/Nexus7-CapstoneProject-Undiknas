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

const apiService = {
  updateUserProfile,
  getUserMe,
  getProfileMe,
  getCategories,
};

export default apiService;