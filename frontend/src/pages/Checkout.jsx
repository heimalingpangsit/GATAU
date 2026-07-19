import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import apiClient from '../api/client'
import { useCart } from '../context/CartContext'

function formatRupiah(n) {
  return 'Rp' + n.toLocaleString('id-ID')
}

export default function Checkout() {
  const { cart, sessionId } = useCart()
  const navigate = useNavigate()

  const [form, setForm] = useState({
    customer_name: '',
    customer_whatsapp: '',
    order_type: 'delivery',
    address: '',
    voucher_code: '',
  })
  const [voucherInfo, setVoucherInfo] = useState(null)
  const [voucherError, setVoucherError] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')

  const discount = voucherInfo?.discount || 0
  const total = Math.max(cart.total - discount, 0)

  async function applyVoucher() {
    setVoucherError('')
    if (!form.voucher_code) return
    try {
      const res = await apiClient.post('/api/vouchers/validate', null, {
        params: { code: form.voucher_code, subtotal: cart.total },
      })
      setVoucherInfo(res.data)
    } catch (err) {
      setVoucherInfo(null)
      setVoucherError(err.response?.data?.detail || 'Voucher tidak valid')
    }
  }

  async function submit(e) {
    e.preventDefault()
    setSubmitting(true)
    setError('')
    try {
      const res = await apiClient.post('/api/checkout', {
        session_id: sessionId,
        ...form,
        voucher_code: voucherInfo ? form.voucher_code : null,
      })
      navigate(`/order/${res.data.order_number}`)
    } catch (err) {
      setError(err.response?.data?.detail || 'Checkout gagal, coba lagi.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="pb-10 px-4 pt-6">
      <h1 className="font-display text-2xl mb-4">Checkout</h1>

      <form onSubmit={submit} className="space-y-4">
        <div>
          <label className="text-xs font-semibold text-ash">Nama Penerima</label>
          <input
            required
            value={form.customer_name}
            onChange={(e) => setForm({ ...form, customer_name: e.target.value })}
            className="w-full mt-1 border border-ink/15 rounded-lg px-3 py-2 text-sm"
            placeholder="Nama kamu"
          />
        </div>
        <div>
          <label className="text-xs font-semibold text-ash">No. WhatsApp</label>
          <input
            required
            value={form.customer_whatsapp}
            onChange={(e) => setForm({ ...form, customer_whatsapp: e.target.value })}
            className="w-full mt-1 border border-ink/15 rounded-lg px-3 py-2 text-sm"
            placeholder="08xxxxxxxxxx"
          />
        </div>

        <div className="flex gap-2">
          {['delivery', 'pickup'].map((t) => (
            <button
              type="button"
              key={t}
              onClick={() => setForm({ ...form, order_type: t })}
              className={`flex-1 py-2 rounded-lg text-sm font-semibold capitalize border ${
                form.order_type === t ? 'bg-ink text-paper border-ink' : 'border-ink/15 text-ash'
              }`}
            >
              {t === 'delivery' ? 'Diantar' : 'Ambil Sendiri'}
            </button>
          ))}
        </div>

        {form.order_type === 'delivery' && (
          <div>
            <label className="text-xs font-semibold text-ash">Alamat Pengantaran</label>
            <textarea
              required
              value={form.address}
              onChange={(e) => setForm({ ...form, address: e.target.value })}
              className="w-full mt-1 border border-ink/15 rounded-lg px-3 py-2 text-sm"
              rows={2}
              placeholder="Jalan, nomor rumah, patokan…"
            />
          </div>
        )}

        <div>
          <label className="text-xs font-semibold text-ash">Kode Voucher (opsional)</label>
          <div className="flex gap-2 mt-1">
            <input
              value={form.voucher_code}
              onChange={(e) => setForm({ ...form, voucher_code: e.target.value.toUpperCase() })}
              className="flex-1 border border-ink/15 rounded-lg px-3 py-2 text-sm font-mono"
              placeholder="KODEVOUCHER"
            />
            <button
              type="button"
              onClick={applyVoucher}
              className="px-4 rounded-lg bg-ink text-paper text-sm font-semibold"
            >
              Pakai
            </button>
          </div>
          {voucherError && <p className="text-xs text-sambal mt-1">{voucherError}</p>}
          {voucherInfo && (
            <p className="text-xs text-herb mt-1">
              Voucher berhasil! Hemat {formatRupiah(voucherInfo.discount)}
            </p>
          )}
        </div>

        <div className="ticket-card border border-ink/10 p-4 space-y-1 text-sm">
          <div className="flex justify-between">
            <span className="text-ash">Subtotal</span>
            <span className="font-mono">{formatRupiah(cart.total)}</span>
          </div>
          {discount > 0 && (
            <div className="flex justify-between text-herb">
              <span>Diskon</span>
              <span className="font-mono">-{formatRupiah(discount)}</span>
            </div>
          )}
          <div className="ticket-perforation my-2" />
          <div className="flex justify-between font-bold">
            <span>Total Bayar</span>
            <span className="font-mono">{formatRupiah(total)}</span>
          </div>
        </div>

        {error && <p className="text-sm text-sambal text-center">{error}</p>}

        <button
          type="submit"
          disabled={submitting || cart.items.length === 0}
          className="w-full bg-sambal text-white font-semibold py-3 rounded-full disabled:opacity-50"
        >
          {submitting ? 'Memproses…' : `Bayar dengan QRIS · ${formatRupiah(total)}`}
        </button>
      </form>
    </div>
  )
}
