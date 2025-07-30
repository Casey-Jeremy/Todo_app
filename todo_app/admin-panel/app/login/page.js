// app/login/page.js
'use client';
import { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../../lib/firebase';
import { useRouter } from 'next/navigation';
import styles from './login.module.css'; // Import the CSS module

export default function Login() {
  const [email, setEmail] = useState('admin@example.com');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const router = useRouter();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(null);
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      if (userCredential.user.email === 'admin@example.com') {
        router.push('/dashboard');
      } else {
        await auth.signOut();
        setError('Error: Not an authorized admin account.');
      }
    } catch (error) {
      setError(`Error: ${error.message}`);
    }
  };

  return (
    // Use the styles object for class names
    <div className={styles.loginPage}>
      <div className={styles.loginContainer}>

        <div className={styles.loginInfo}>
          <div className={styles.logo}>
            <div className={styles.logoIcon}></div>
            <span>Admin Panel</span>
          </div>
          <h1>Login into your account</h1>
          <p>Manage all your user&#39;s to-do lists.</p>
        </div>

        <div className={styles.loginFormContainer}>
          <form className={styles.loginForm} onSubmit={handleLogin}>
            <div className={styles.formGroup}>
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@example.com"
                required
              />
            </div>
            <div className={styles.formGroup}>
              <label htmlFor="password">Password</label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Your password"
                required
              />
            </div>
            <div className={styles.formActions}>
              <span className={styles.signupLink}>
                Need help?
              </span>
              <button type="submit" className={styles.loginButton}>Login</button>
            </div>
            {error && <p style={{ color: 'red', textAlign: 'center' }}>{error}</p>}
          </form>
        </div>
        
      </div>
      <footer className={styles.footer}>
        © 2025 To-Do App. All Rights Reserved.
      </footer>
    </div>
  );
}