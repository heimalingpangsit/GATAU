import { createContext, useCallback, useContext, useEffect, useState } from 'react'
import apiClient from '../api/client'

const CartContext = createContext(null)
const SESSION_KEY = 'kebab_dzaqy_session_id' // hanya menyimpan ID sesi, bukan data cart

export function CartProvider({ children }) {
  const [sessionId, setSessionId] = useState(null)
  const [cart, setCart] = useState({ items: [], total: 0 })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function init() {
      let sid = localStorage.getItem(SESSION_KEY)
      if (!sid) {
        const res = await apiClient.post('/api/cart/new-session')
        sid = res.data.session_id
        localStorage.setItem(SESSION_KEY, sid)
      }
      setSessionId(sid)
      const res = await apiClient.get(`/api/cart/${sid}`)
      setCart(res.data)
      setLoading(false)
    }
    init()
  }, [])

  const refreshCart = useCallback(async (sid) => {
    const res = await apiClient.get(`/api/cart/${sid}`)
    setCart(res.data)
  }, [])

  const addItem = useCallback(
    async (menuId, qty = 1, notes = '') => {
      const res = await apiClient.post(`/api/cart/${sessionId}/items`, {
        menu_id: menuId,
        qty,
        notes,
      })
      setCart(res.data)
    },
    [sessionId]
  )

  const updateQty = useCallback(
    async (menuId, qty) => {
      const res = await apiClient.put(`/api/cart/${sessionId}/items/${menuId}`, null, {
        params: { qty },
      })
      setCart(res.data)
    },
    [sessionId]
  )

  const removeItem = useCallback(
    async (menuId) => {
      const res = await apiClient.delete(`/api/cart/${sessionId}/items/${menuId}`)
      setCart(res.data)
    },
    [sessionId]
  )

  const clearCart = useCallback(async () => {
    await apiClient.delete(`/api/cart/${sessionId}`)
    setCart({ items: [], total: 0 })
  }, [sessionId])

  return (
    <CartContext.Provider
      value={{ sessionId, cart, loading, addItem, updateQty, removeItem, clearCart, refreshCart }}
    >
      {children}
    </CartContext.Provider>
  )
}

export function useCart() {
  const ctx = useContext(CartContext)
  if (!ctx) throw new Error('useCart harus dipakai di dalam <CartProvider>')
  return ctx
}
