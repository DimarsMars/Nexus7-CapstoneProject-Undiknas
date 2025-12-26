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
  return apiClient.post(`/follow/${id}`);
}

const getFollower = (id) => {
  return apiClient.get(`/follow/${id}/followers`);
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

const getRouteData = (id) => {
  return apiClient.get(`/plans/route/${id}`);
}

const getReviewPlace = (id) => {
  return apiClient.get(`/reviews/place/${id}`);
}

const postReviewPlace = (data) => {
  return apiClient.post(`/reviews/place`, data);
}

const postBookmarkRoute = (routeId) => {
  return apiClient.post(`/bookmarks/${routeId}`);
}

const getBookmarkRoute = () => {
  return apiClient.get(`/bookmarks/`);
}

const deleteBookmarkRoute = (bookmarkId) => {
  return apiClient.delete(`/bookmarks/${bookmarkId}`);
}

const getPlanForRunTrip = (id) => {
  return apiClient.get(`/plans/${id}/detail`);
}

const postPlanVerifyLocation = (id, data) => {
  return apiClient.post(`/plans/${id}/verify-location`, data);
}

const postFavorite = (id) => {
  return apiClient.post(`/favorites/${id}`, {});
}

const getFavorite = () => {
  return apiClient.get(`/favorites/`);
}

const deleteFavorite = (id) => {
  return apiClient.delete(`/favorites/${id}`);
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
  getFollower,
  unfollowUser,
  getMyTripReviews,
  getReviewsOnMyPlans,
  getAllUsers,
  getRouteData,
  getReviewPlace,
  postReviewPlace,
  postBookmarkRoute,
  getBookmarkRoute,
  deleteBookmarkRoute,
  getPlanForRunTrip,
  postPlanVerifyLocation,
  postFavorite,
  getFavorite,
  deleteFavorite
};

export default apiService;