import './globals.css';

export const metadata = {
  title: 'Todo App Admin',
  description: 'Admin panel for the To-Do app',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}