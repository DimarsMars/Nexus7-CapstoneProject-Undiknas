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
  return apiClient.get('/plans/');
};

const getAllPlan = () => {
  return apiClient.get('/plans/all');
};

const getMostActiveTravellers = () => {
  return apiClient.get('/user/mostactive');
};

const getTravellersByCategory = () => {
  return apiClient.get('/user/recomendations/category');
};

const getUserXP = () => {
  return apiClient.get('/user/xp');
}

const getUserProfileById = (id) => {
  return apiClient.get(`/user/profile/${id}`);
}

const followUser = (id) => {
  return apiClient.post(`/follow/${id}`, {});
}

const unfollowUser = (id) => {
  return apiClient.delete(`/follow/${id}`);
}

const getMyTripReviews = () => {
  return apiClient.get('/reviews/trip/me');
}

const getReviewsOnMyPlans = () => {
  return apiClient.get('/reviews/trip/my-plans');
}

const getAllUsers = () => {
  return apiClient.get('/user/all');
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
  getTravellersByCategory,
  getUserXP,
  getUserProfileById,
  followUser,
  unfollowUser,
  getMyTripReviews,
  getReviewsOnMyPlans,
  getAllUsers
};

export default apiService;