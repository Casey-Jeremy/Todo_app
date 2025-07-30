import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDLOiMV21SJIUYLm0nA_qGqHcjDg4feCew",
  authDomain: "dev-challenge-app.firebaseapp.com",
  projectId: "dev-challenge-app",
  storageBucket: "dev-challenge-app.firebasestorage.app",
  messagingSenderId: "383277827031",
  appId: "1:383277827031:web:413bf9b613197851a78192",
  measurementId: "G-VXT0BNJEE6"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);