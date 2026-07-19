import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function OrderHistory() {
  const [orderNumber, setOrderNumber] = useState('')
  const navigate = useNavigate()

  function search(e) {
    e.preventDefault()
    if (orderNumber.trim()) navigate(`/order/${orderNumber.trim().toUpperCase()}`)
  }

  return (
    <div className="px-4 pt-6 pb-10 text-center">
      <h1 className="font-display text-2xl mb-2">Cek Pesanan</h1>
      <p className="text-sm text-ash mb-6">
        Karena kamu belanja tanpa akun, masukkan nomor pesanan (dikirim setelah checkout) untuk melihat status.
      </p>
      <form onSubmit={search} className="flex gap-2 max-w-sm mx-auto">
        <input
          value={orderNumber}
          onChange={(e) => setOrderNumber(e.target.value)}
          placeholder="KDZ-260720-1234"
          className="flex-1 border border-ink/15 rounded-lg px-3 py-2 text-sm font-mono"
        />
        <button className="px-4 rounded-lg bg-sambal text-white text-sm font-semibold">Cek</button>
      </form>
    </div>
  )
}
