import { Routes, Route, useLocation } from 'react-router-dom'
import { CartProvider } from './context/CartContext'
import { AuthProvider } from './context/AuthContext'
import BottomNav from './components/BottomNav'
import ProtectedRoute from './components/ProtectedRoute'

import Home from './pages/Home'
import Cart from './pages/Cart'
import Checkout from './pages/Checkout'
import OrderStatus from './pages/OrderStatus'
import OrderHistory from './pages/OrderHistory'
import Login from './pages/Login'
import OwnerDashboard from './pages/owner/Dashboard'
import KasirDashboard from './pages/kasir/Dashboard'

function Layout({ children }) {
  const location = useLocation()
  const hideNav = location.pathname.startsWith('/owner') || location.pathname.startsWith('/kasir')
  return (
    <div className="max-w-md mx-auto min-h-screen relative">
      {children}
      {!hideNav && <BottomNav />}
    </div>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <CartProvider>
        <Layout>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/cart" element={<Cart />} />
            <Route path="/checkout" element={<Checkout />} />
            <Route path="/order/:orderNumber" element={<OrderStatus />} />
            <Route path="/riwayat" element={<OrderHistory />} />
            <Route path="/login" element={<Login />} />
            <Route
              path="/owner"
              element={
                <ProtectedRoute roles={['owner']}>
                  <OwnerDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/kasir"
              element={
                <ProtectedRoute roles={['owner', 'kasir']}>
                  <KasirDashboard />
                </ProtectedRoute>
              }
            />
          </Routes>
        </Layout>
      </CartProvider>
    </AuthProvider>
  )
}
