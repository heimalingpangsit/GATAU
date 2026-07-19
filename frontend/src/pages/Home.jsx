import { useEffect, useState } from 'react'
import apiClient from '../api/client'
import MenuCard from '../components/MenuCard'

const CATEGORIES = ['semua', 'kebab', 'minuman', 'snack']

export default function Home() {
  const [banners, setBanners] = useState([])
  const [menu, setMenu] = useState([])
  const [category, setCategory] = useState('semua')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function load() {
      const [bRes, mRes] = await Promise.all([
        apiClient.get('/api/banners'),
        apiClient.get('/api/menu', { params: { only_available: false } }),
      ])
      setBanners(bRes.data)
      setMenu(mRes.data)
      setLoading(false)
    }
    load()
  }, [])

  const filtered = category === 'semua' ? menu : menu.filter((m) => m.category === category)

  return (
    <div className="pb-24">
      <header className="bg-ink text-paper px-4 pt-6 pb-8 zigzag-bottom">
        <p className="font-mono text-[11px] text-turmeric tracking-widest uppercase">
          Buka setiap hari · 10.00–22.00
        </p>
        <h1 className="font-display text-3xl leading-none mt-1">KEBAB DZAQY</h1>
        <p className="text-sm text-paper/70 mt-2">Kebab hangat, diantar cepat ke depan pintumu.</p>
      </header>

      {banners.length > 0 && (
        <div className="flex gap-3 overflow-x-auto px-4 -mt-4 pb-1 snap-x">
          {banners.map((b) => (
            <a
              key={b.id}
              href={b.link_url || '#'}
              className="shrink-0 w-64 h-32 rounded-lg overflow-hidden shadow-lg snap-start border-2 border-paper"
            >
              <img src={b.image_url} alt={b.title} className="w-full h-full object-cover" />
            </a>
          ))}
        </div>
      )}

      <div className="flex gap-2 px-4 mt-5 overflow-x-auto">
        {CATEGORIES.map((c) => (
          <button
            key={c}
            onClick={() => setCategory(c)}
            className={`px-4 py-1.5 rounded-full text-xs font-semibold capitalize shrink-0 ${
              category === c ? 'bg-sambal text-white' : 'bg-ink/5 text-ink'
            }`}
          >
            {c}
          </button>
        ))}
      </div>

      <div className="px-4 mt-4 space-y-3">
        {loading && <p className="text-center text-ash py-8">Memuat menu…</p>}
        {!loading && filtered.length === 0 && (
          <p className="text-center text-ash py-8">Belum ada menu di kategori ini.</p>
        )}
        {filtered.map((item) => (
          <MenuCard key={item.id} item={item} />
        ))}
      </div>
    </div>
  )
}
