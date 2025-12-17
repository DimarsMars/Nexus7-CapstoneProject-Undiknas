import axios from 'axios';
import {
    API_BASE_URL,
    FIREBASE_AUTH_URL_SIGNIN,
    FIREBASE_AUTH_URL_SIGNUP
} from '../../config';

const api = axios.create({
    baseURL: API_BASE_URL,
});

/**
 * Sign in with email and password through Firebase, then log into the Go backend.
 */
export const loginWithEmailAndPassword = async (email, password) => {
    // Step 1: Authenticate with Firebase to get the idToken
    const firebaseResponse = await axios.post(FIREBASE_AUTH_URL_SIGNIN, {
        email,
        password,
        returnSecureToken: true,
    });

    const idToken = firebaseResponse.data.idToken;

    // Step 2: Use the idToken to log into your Go backend
    const backendResponse = await api.post('/auth/login', {
        idToken,
    });

    // Return combined data, including the idToken for subsequent authenticated requests
    return {
        ...backendResponse.data,
        idToken,
    };
};

/**
 * Sign up a new user with Firebase, then register them in the Go backend.
 */
export const signUpWithEmailAndPassword = async (email, password, username) => {
    // Step 1: Create the user in Firebase Authentication
    const firebaseResponse = await axios.post(FIREBASE_AUTH_URL_SIGNUP, {
        email,
        password,
        returnSecureToken: true,
    });

    const idToken = firebaseResponse.data.idToken;

    // Step 2: Register the new user in your Go backend with the idToken and username
    const backendResponse = await api.post('/auth/register', {
        idToken,
        username,
    });

    // Return combined data, including the idToken for subsequent authenticated requests
    return {
        ...backendResponse.data,
        idToken,
    };
};
