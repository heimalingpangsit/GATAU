import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Login() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  async function submit(e) {
    e.preventDefault()
    setSubmitting(true)
    setError('')
    try {
      const role = await login(username, password)
      navigate(role === 'owner' ? '/owner' : '/kasir')
    } catch {
      setError('Username atau password salah')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="px-4 pt-16 pb-10 max-w-sm mx-auto">
      <h1 className="font-display text-2xl text-center mb-1">Masuk Akun</h1>
      <p className="text-sm text-ash text-center mb-6">Khusus Owner &amp; Kasir KEBAB DZAQY</p>
      <form onSubmit={submit} className="space-y-3">
        <input
          required
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Username"
          className="w-full border border-ink/15 rounded-lg px-3 py-2.5 text-sm"
        />
        <input
          required
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          className="w-full border border-ink/15 rounded-lg px-3 py-2.5 text-sm"
        />
        {error && <p className="text-sm text-sambal text-center">{error}</p>}
        <button
          disabled={submitting}
          className="w-full bg-ink text-paper font-semibold py-2.5 rounded-lg disabled:opacity-50"
        >
          {submitting ? 'Memproses…' : 'Masuk'}
        </button>
      </form>
    </div>
  )
}
