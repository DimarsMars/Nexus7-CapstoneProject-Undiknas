// Your web app's Firebase configuration
// This configuration is for client-side Firebase SDKs.
const firebaseConfig = {
  apiKey: "AIzaSyAKowFpPDUTTgHrW0mIlUvFPKYbxtf0d3k",
  authDomain: "journeys-e31cb.firebaseapp.com",
  projectId: "journeys-e31cb",
  storageBucket: "journeys-e31cb.firebasestorage.app",
  messagingSenderId: "655822390436",
  appId: "1:655822390436:web:5f42d13bf8f75c88bd5231",
  measurementId: "G-N7CLE0K9K7"
};

const FIREBASE_API_KEY = firebaseConfig.apiKey;

const API_BASE_URL = "http://localhost:8080";

const FIREBASE_AUTH_URL_SIGNIN = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`;
const FIREBASE_AUTH_URL_SIGNUP = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`;

export {
    API_BASE_URL,
    FIREBASE_AUTH_URL_SIGNIN,
    FIREBASE_AUTH_URL_SIGNUP,
    firebaseConfig // Export the full config in case other Firebase services are needed later
};
