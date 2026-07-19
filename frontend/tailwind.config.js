/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#1C1815',      // charcoal - bg gelap, teks utama
        paper: '#FBF3E7',    // warm paper - bg terang
        sambal: '#D64545',   // merah cabai - aksen utama/CTA
        turmeric: '#E3A008', // kuning kunyit - aksen promo/highlight
        herb: '#4A5D3A',     // hijau daun - aksen segar/sukses
        ash: '#8A7F72'       // abu hangat - teks sekunder
      },
      fontFamily: {
        display: ['"Archivo Black"', 'sans-serif'],
        body: ['"Plus Jakarta Sans"', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace']
      },
      clipPath: {
        ticket: 'polygon(0 0, 100% 0, 100% 100%, 0 100%)'
      }
    }
  },
  plugins: []
}
