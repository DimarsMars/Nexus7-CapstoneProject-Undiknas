// WARNING: Please replace "YOUR_FIREBASE_API_KEY" with your actual Firebase Web API Key.
// You can find this in your Firebase project settings.
const FIREBASE_API_KEY = "YOUR_FIREBASE_API_KEY";

const API_BASE_URL = "http://localhost:8080";

const FIREBASE_AUTH_URL_SIGNIN = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`;
const FIREBASE_AUTH_URL_SIGNUP = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`;

export {
    API_BASE_URL,
    FIREBASE_AUTH_URL_SIGNIN,
    FIREBASE_AUTH_URL_SIGNUP
};
