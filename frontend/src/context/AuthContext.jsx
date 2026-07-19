import { createContext, useContext, useEffect, useState } from 'react'
import apiClient from '../api/client'

const AuthContext = createContext(null)
const TOKEN_KEY = 'kebab_dzaqy_token'

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null) // { username, role }
  const [ready, setReady] = useState(false)

  useEffect(() => {
    async function loadMe() {
      const token = localStorage.getItem(TOKEN_KEY)
      if (!token) {
        setReady(true)
        return
      }
      try {
        const res = await apiClient.get('/api/auth/me')
        setUser(res.data)
      } catch {
        localStorage.removeItem(TOKEN_KEY)
      } finally {
        setReady(true)
      }
    }
    loadMe()
  }, [])

  async function login(username, password) {
    const res = await apiClient.post('/api/auth/login', { username, password })
    localStorage.setItem(TOKEN_KEY, res.data.access_token)
    setUser({ username: res.data.username, role: res.data.role })
    return res.data.role
  }

  function logout() {
    localStorage.removeItem(TOKEN_KEY)
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ user, ready, login, logout }}>{children}</AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth harus dipakai di dalam <AuthProvider>')
  return ctx
}
