import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import apiClient from '../api/client'

const STATUS_LABEL = {
  pending_payment: { label: 'Menunggu Pembayaran', color: 'text-turmeric' },
  paid: { label: 'Pembayaran Diterima', color: 'text-herb' },
  processing: { label: 'Sedang Diproses', color: 'text-herb' },
  ready: { label: 'Siap Diambil / Diantar', color: 'text-herb' },
  completed: { label: 'Selesai', color: 'text-herb' },
  cancelled: { label: 'Dibatalkan', color: 'text-sambal' },
  expired: { label: 'Kadaluarsa', color: 'text-sambal' },
}

function formatRupiah(n) {
  return 'Rp' + n.toLocaleString('id-ID')
}

export default function OrderStatus() {
  const { orderNumber } = useParams()
  const [order, setOrder] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    let interval
    async function fetchOrder() {
      try {
        const res = await apiClient.get(`/api/orders/by-number/${orderNumber}`)
        setOrder(res.data)
        if (res.data.status !== 'pending_payment' && interval) clearInterval(interval)
      } catch {
        setError('Order tidak ditemukan')
      }
    }
    fetchOrder()
    interval = setInterval(fetchOrder, 5000)
    return () => clearInterval(interval)
  }, [orderNumber])

  if (error) return <p className="text-center text-sambal py-16">{error}</p>
  if (!order) return <p className="text-center text-ash py-16">Memuat pesanan…</p>

  const statusInfo = STATUS_LABEL[order.status] || { label: order.status, color: 'text-ash' }

  return (
    <div className="px-4 pt-6 pb-10 max-w-md mx-auto">
      <div className="ticket-card border border-ink/10 p-5 text-center">
        <p className="text-xs text-ash">No. Pesanan</p>
        <p className="font-mono font-bold text-lg">{order.order_number}</p>
        <p className={`text-sm font-semibold mt-2 ${statusInfo.color}`}>{statusInfo.label}</p>

        {order.status === 'pending_payment' && order.qris_url && (
          <div className="mt-4">
            <img src={order.qris_url} alt="QRIS" className="w-56 h-56 mx-auto rounded-lg border border-ink/10" />
            <p className="text-xs text-ash mt-2">Scan dengan aplikasi e-wallet / m-banking apa pun yang mendukung QRIS.</p>
          </div>
        )}

        <div className="ticket-perforation my-4" />

        <div className="text-left space-y-1 text-sm">
          {order.items.map((it) => (
            <div key={it.menu_id} className="flex justify-between">
              <span>
                {it.qty}× {it.name}
              </span>
              <span className="font-mono">{formatRupiah(it.subtotal)}</span>
            </div>
          ))}
        </div>

        <div className="ticket-perforation my-4" />

        <div className="flex justify-between font-bold text-sm">
          <span>Total</span>
          <span className="font-mono">{formatRupiah(order.total)}</span>
        </div>
      </div>

      <p className="text-center text-xs text-ash mt-4">
        Status akan otomatis diperbarui setelah pembayaran diterima.
      </p>
    </div>
  )
}
