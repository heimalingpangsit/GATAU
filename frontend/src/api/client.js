import axios from 'axios'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000',
})

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('kebab_dzaqy_token')
  // NOTE: token JWT boleh disimpan di localStorage (bukan "database" aplikasi,
  // hanya credential sisi client, ini praktik umum SPA). Data aplikasi TIDAK
  // pernah disimpan di localStorage — semua lewat GitHub API via backend.
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

export default apiClient
