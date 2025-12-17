import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080'; // Sesuaikan dengan base URL API Anda

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const updateUserProfile = async (idToken, payload) => {
  try {
    const response = await api.put('/profile/update', payload, {
      headers: {
        'Authorization': `Bearer ${idToken}`
      }
    });
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const getUserMe = async (idToken) => {
  try {
    const response = await api.get('/user/me', {
      headers: {
        'Authorization': `Bearer ${idToken}`
      }
    });
    return response.data;
  } catch (error) {
    throw error;
  }
};
