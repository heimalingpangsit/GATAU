# ---- Frontend: KEBAB DZAQY React (Vite) ----
# Dockerfile ini opsional — dipakai HANYA jika Anda deploy frontend ke
# platform berbasis Docker (Render/Railway/VPS), BUKAN ke Netlify.
# Untuk Netlify, cukup pakai netlify.toml (build otomatis, tanpa Docker).

FROM node:20-slim AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
# VITE_API_URL di-inject saat build karena Vite meng-embed env ke bundle statis
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
