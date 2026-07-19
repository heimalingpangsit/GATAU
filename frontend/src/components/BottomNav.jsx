import { NavLink } from 'react-router-dom'
import { useCart } from '../context/CartContext'

export default function BottomNav() {
  const { cart } = useCart()
  const itemCount = cart.items.reduce((sum, i) => sum + i.qty, 0)

  const linkClass = ({ isActive }) =>
    `flex flex-col items-center justify-center gap-0.5 text-[11px] font-medium ${
      isActive ? 'text-sambal' : 'text-ash'
    }`

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 border-t border-ink/10 bg-paper/95 backdrop-blur px-2 py-2 flex justify-around max-w-md mx-auto">
      <NavLink to="/" className={linkClass}>
        <span className="text-lg">🥙</span>
        Menu
      </NavLink>
      <NavLink to="/cart" className={linkClass}>
        <span className="relative text-lg">
          🧺
          {itemCount > 0 && (
            <span className="absolute -top-1.5 -right-2 bg-sambal text-white text-[9px] rounded-full w-4 h-4 flex items-center justify-center">
              {itemCount}
            </span>
          )}
        </span>
        Keranjang
      </NavLink>
      <NavLink to="/riwayat" className={linkClass}>
        <span className="text-lg">🧾</span>
        Riwayat
      </NavLink>
      <NavLink to="/login" className={linkClass}>
        <span className="text-lg">👤</span>
        Akun
      </NavLink>
    </nav>
  )
}
