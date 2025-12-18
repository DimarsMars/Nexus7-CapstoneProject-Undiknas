import axios from 'axios';
import {
    API_BASE_URL,
    FIREBASE_AUTH_URL_SIGNIN,
    FIREBASE_AUTH_URL_SIGNUP
} from '../../config';

const api = axios.create({
    baseURL: API_BASE_URL,
});

export const loginWithEmailAndPassword = async (email, password) => {
    const firebaseResponse = await axios.post(FIREBASE_AUTH_URL_SIGNIN, {
        email,
        password,
        returnSecureToken: true,
    });

    const idToken = firebaseResponse.data.idToken;

    localStorage.setItem('idToken', idToken); 

    const backendResponse = await api.post('/auth/login', {
        idToken,
    });

    return {
        ...backendResponse.data,
        idToken,
    };
};

export const signUpWithEmailAndPassword = async (email, password, username) => {
    const firebaseResponse = await axios.post(FIREBASE_AUTH_URL_SIGNUP, {
        email,
        password,
        returnSecureToken: true,
    });

    const idToken = firebaseResponse.data.idToken;

    localStorage.setItem('idToken', idToken);

    const backendResponse = await api.post('/auth/register', {
        idToken,
        username,
    });

    return {
        ...backendResponse.data,
        idToken,
    };
};

export const logoutUser = () => {
    localStorage.removeItem('idToken');
};