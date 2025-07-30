// app/dashboard/page.js
'use client';
import { useState, useEffect } from 'react';
import { collection, getDocs, onSnapshot, doc, deleteDoc } from 'firebase/firestore';
import { auth, db } from '../../lib/firebase';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { useRouter } from 'next/navigation';
import { FiUsers, FiFileText, FiTrash2 } from 'react-icons/fi'; // Import icons

export default function Dashboard() {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const router = useRouter();

  // Protect route
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (!user || user.email !== 'admin@example.com') {
        router.push('/login');
      } else {
        setLoading(false);
      }
    });
    return () => unsubscribe();
  }, [router]);

  // Fetch users
  useEffect(() => {
    const fetchUsers = async () => {
      const usersSnapshot = await getDocs(collection(db, 'users'));
      setUsers(usersSnapshot.docs.map(d => ({ id: d.id, ...d.data() })));
    };
    if (!loading) fetchUsers();
  }, [loading]);

  // Listener for selected user's todos
  useEffect(() => {
    if (!selectedUser) return;
    const todosRef = collection(db, 'users', selectedUser.id, 'todos');
    const unsubscribe = onSnapshot(todosRef, (snapshot) => {
      setTodos(snapshot.docs.map(d => ({ id: d.id, ...d.data() })));
    });
    return () => unsubscribe();
  }, [selectedUser]);

  const handleLogout = async () => await signOut(auth);

  // NEW: Delete a specific to-do item
  const handleDeleteTodo = async (todoId) => {
    if (!selectedUser || !window.confirm("Are you sure you want to delete this task?")) return;
    const todoDocRef = doc(db, 'users', selectedUser.id, 'todos', todoId);
    await deleteDoc(todoDocRef);
  };
  
  // NEW: Filter users based on search term
  const filteredUsers = users.filter(user => 
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) return <div className="container"><h1>Loading...</h1></div>;

  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <h1>Admin Dashboard</h1>
        <button onClick={handleLogout} className="logout-button">Logout</button>
      </header>

      {/* NEW: Stat Cards */}
      <div className="stat-cards-container">
        <div className="stat-card">
          <FiUsers size={24} />
          <div>
            <span>Total Users</span>
            <strong>{users.length}</strong>
          </div>
        </div>
        <div className="stat-card">
          <FiFileText size={24} />
          <div>
            <span>Tasks (Selected User)</span>
            <strong>{todos.length}</strong>
          </div>
        </div>
      </div>
      
      <main className="dashboard-main">
        <aside className="sidebar">
          <h2>Users ({filteredUsers.length})</h2>
          {/* NEW: Search Bar */}
          <input 
            type="text" 
            placeholder="Search users..." 
            className="search-bar"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <ul className="user-list">
            {filteredUsers.map(user => (
              <li 
                key={user.id} 
                onClick={() => setSelectedUser(user)}
                className={selectedUser?.id === user.id ? 'active' : ''}
              >
                {user.email}
              </li>
            ))}
          </ul>
        </aside>
        
        <section className="content">
          <h2>
            {selectedUser ? `Tasks for ${selectedUser.email}` : 'Select a user to see their tasks'}
          </h2>
          {selectedUser ? (
            <ul className="todo-list">
              {todos.length > 0 ? (
                todos.map(todo => (
                  <li key={todo.id}>
                    <span className={todo.isDone ? 'done' : ''}>{todo.title}</span>
                    {/* NEW: Delete Button */}
                    <button onClick={() => handleDeleteTodo(todo.id)} className="delete-todo-button">
                      <FiTrash2 />
                    </button>
                  </li>
                ))
              ) : (<p>No tasks found for this user.</p>)}
            </ul>
          ) : null}
        </section>
      </main>
    </div>
  );
}