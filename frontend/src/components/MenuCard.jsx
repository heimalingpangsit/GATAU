import { useCart } from '../context/CartContext'

function formatRupiah(n) {
  return 'Rp' + n.toLocaleString('id-ID')
}

export default function MenuCard({ item }) {
  const { addItem } = useCart()

  return (
    <div className="ticket-card overflow-hidden border border-ink/10">
      <div className="flex gap-3 p-3">
        <div className="w-20 h-20 rounded shrink-0 bg-ink/5 overflow-hidden flex items-center justify-center">
          {item.image_url ? (
            <img src={item.image_url} alt={item.name} className="w-full h-full object-cover" />
          ) : (
            <span className="text-2xl">🥙</span>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <h3 className="font-semibold text-sm leading-tight">{item.name}</h3>
            {item.is_promo && (
              <span className="shrink-0 bg-turmeric/15 text-turmeric text-[10px] font-bold px-1.5 py-0.5 rounded">
                PROMO
              </span>
            )}
          </div>
          <p className="text-xs text-ash mt-0.5 line-clamp-2">{item.description}</p>
          <div className="flex items-center justify-between mt-2">
            <span className="font-mono font-bold text-sm text-ink">{formatRupiah(item.price)}</span>
            <button
              disabled={!item.is_available}
              onClick={() => addItem(item.id, 1)}
              className="text-xs font-semibold px-3 py-1.5 rounded-full bg-sambal text-white disabled:bg-ash/40 active:scale-95 transition"
            >
              {item.is_available ? '+ Tambah' : 'Habis'}
            </button>
          </div>
        </div>
      </div>
      <div className="ticket-perforation" />
    </div>
  )
}
