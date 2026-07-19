import { useNavigate } from 'react-router-dom'
import { useCart } from '../context/CartContext'

function formatRupiah(n) {
  return 'Rp' + n.toLocaleString('id-ID')
}

export default function Cart() {
  const { cart, updateQty, removeItem, loading } = useCart()
  const navigate = useNavigate()

  if (loading) return <p className="text-center text-ash py-10">Memuat keranjang…</p>

  return (
    <div className="pb-32 px-4 pt-6">
      <h1 className="font-display text-2xl mb-4">Keranjang</h1>

      {cart.items.length === 0 ? (
        <div className="text-center py-16">
          <p className="text-4xl mb-2">🧺</p>
          <p className="text-ash text-sm">Keranjangmu masih kosong.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {cart.items.map((item) => (
            <div key={item.menu_id} className="ticket-card border border-ink/10 p-3 flex items-center gap-3">
              <div className="flex-1">
                <p className="font-semibold text-sm">{item.name}</p>
                {item.notes && <p className="text-xs text-ash italic">"{item.notes}"</p>}
                <p className="font-mono text-xs text-ash mt-1">{formatRupiah(item.price)}</p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => updateQty(item.menu_id, item.qty - 1)}
                  className="w-7 h-7 rounded-full bg-ink/5 font-bold"
                >
                  −
                </button>
                <span className="w-5 text-center text-sm">{item.qty}</span>
                <button
                  onClick={() => updateQty(item.menu_id, item.qty + 1)}
                  className="w-7 h-7 rounded-full bg-ink/5 font-bold"
                >
                  +
                </button>
              </div>
              <button onClick={() => removeItem(item.menu_id)} className="text-ash text-xs ml-1">
                ✕
              </button>
            </div>
          ))}
        </div>
      )}

      {cart.items.length > 0 && (
        <div className="fixed bottom-16 left-0 right-0 max-w-md mx-auto bg-paper border-t border-ink/10 p-4">
          <div className="flex justify-between text-sm mb-3">
            <span className="text-ash">Subtotal</span>
            <span className="font-mono font-bold">{formatRupiah(cart.total)}</span>
          </div>
          <button
            onClick={() => navigate('/checkout')}
            className="w-full bg-sambal text-white font-semibold py-3 rounded-full active:scale-[0.98] transition"
          >
            Lanjut ke Checkout
          </button>
        </div>
      )}
    </div>
  )
}
