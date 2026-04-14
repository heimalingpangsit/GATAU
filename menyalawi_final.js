export default {
  async fetch(request) {
    const userAgent = request.headers.get("User-Agent") || "";

    const isBrowser =
      userAgent.includes("Mozilla") ||
      userAgent.includes("Chrome") ||
      userAgent.includes("Safari") ||
      userAgent.includes("Firefox") ||
      userAgent.includes("Edge") ||
      userAgent.includes("Opera");

    if (isBrowser) {
      const html = `<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>POKAYCORE</title>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--red:#ff1a1a;--red2:#ff6b6b;--yellow:#ffd600;--dark:#0a0000;--white:#fff0f0}
html,body{height:100%;background:var(--dark);color:var(--white);font-family:'Space Mono',monospace;overflow:hidden;cursor:crosshair}
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,0,0,0.18) 2px,rgba(0,0,0,0.18) 4px);pointer-events:none;z-index:99}
body::after{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at center,transparent 40%,rgba(0,0,0,0.85) 100%);pointer-events:none;z-index:98}
@keyframes flicker{0%,100%{opacity:1}92%{opacity:1}93%{opacity:.4}94%{opacity:1}96%{opacity:.6}97%{opacity:1}}
@keyframes glitch-1{0%,100%{clip-path:inset(0 0 98% 0);transform:translateX(-4px)}20%{clip-path:inset(30% 0 60% 0);transform:translateX(4px)}40%{clip-path:inset(70% 0 10% 0);transform:translateX(-2px)}60%{clip-path:inset(15% 0 80% 0);transform:translateX(3px)}80%{clip-path:inset(55% 0 35% 0);transform:translateX(-3px)}}
@keyframes glitch-2{0%,100%{clip-path:inset(50% 0 30% 0);transform:translateX(3px)}25%{clip-path:inset(10% 0 85% 0);transform:translateX(-4px)}50%{clip-path:inset(80% 0 5% 0);transform:translateX(2px)}75%{clip-path:inset(40% 0 50% 0);transform:translateX(-2px)}}
@keyframes pulse-red{0%,100%{box-shadow:0 0 20px rgba(255,26,26,0.4),0 0 60px rgba(255,26,26,0.1)}50%{box-shadow:0 0 40px rgba(255,26,26,0.8),0 0 120px rgba(255,26,26,0.3)}}
@keyframes shake{0%,100%{transform:translateX(0)}10%{transform:translateX(-6px) rotate(-1deg)}20%{transform:translateX(6px) rotate(1deg)}30%{transform:translateX(-4px)}40%{transform:translateX(4px)}50%{transform:translateX(-2px)}60%{transform:translateX(2px)}}
@keyframes blink-text{0%,49%{opacity:1}50%,100%{opacity:0}}
@keyframes slideUp{from{transform:translateY(30px);opacity:0}to{transform:translateY(0);opacity:1}}
@keyframes spin-slow{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
@keyframes stripe-move{from{background-position:0 0}to{background-position:60px 0}}
.container{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;animation:flicker 4s infinite;padding:20px}
.stripe-top,.stripe-bottom{position:fixed;left:0;right:0;height:28px;background:repeating-linear-gradient(90deg,var(--yellow) 0px,var(--yellow) 20px,#111 20px,#111 40px);background-size:60px 100%;animation:stripe-move 1s linear infinite;z-index:50}
.stripe-top{top:0}.stripe-bottom{bottom:0}
.alert-box{border:3px solid var(--red);border-radius:4px;padding:40px 50px;max-width:700px;width:100%;text-align:center;position:relative;background:rgba(20,0,0,0.92);animation:pulse-red 2s ease-in-out infinite,slideUp 0.5s ease both}
.bracket{position:absolute;width:20px;height:20px;border-color:var(--yellow);border-style:solid}
.bracket.tl{top:-3px;left:-3px;border-width:3px 0 0 3px}
.bracket.tr{top:-3px;right:-3px;border-width:3px 3px 0 0}
.bracket.bl{bottom:-3px;left:-3px;border-width:0 0 3px 3px}
.bracket.br{bottom:-3px;right:-3px;border-width:0 3px 3px 0}
.skull{font-size:64px;line-height:1;margin-bottom:8px;animation:shake 0.8s ease-in-out infinite;display:block}
.warn-label{font-family:'Bebas Neue',cursive;font-size:clamp(13px,3vw,18px);letter-spacing:6px;color:var(--yellow);margin-bottom:14px;display:flex;align-items:center;justify-content:center;gap:10px}
.warn-label::before,.warn-label::after{content:'⚠';font-size:14px}
.main-text-wrap{position:relative;margin-bottom:18px;line-height:1}
.main-text{font-family:'Bebas Neue',cursive;font-size:clamp(32px,9vw,72px);color:var(--red);text-shadow:0 0 30px rgba(255,26,26,0.6),3px 3px 0 #500,-3px -3px 0 #300;position:relative;letter-spacing:2px;display:block}
.main-text::before{content:attr(data-text);position:absolute;inset:0;color:var(--red2);animation:glitch-1 2.5s steps(1) infinite;opacity:0.7}
.main-text::after{content:attr(data-text);position:absolute;inset:0;color:var(--yellow);animation:glitch-2 2.5s steps(1) infinite;opacity:0.5}
.brand{font-family:'Bebas Neue',cursive;font-size:clamp(28px,8vw,58px);letter-spacing:8px;color:var(--white);text-shadow:0 0 20px rgba(255,255,255,0.3);margin-bottom:20px;display:block}
.brand span{color:var(--yellow);text-shadow:0 0 20px rgba(255,214,0,0.6)}
.divider{width:100%;height:1px;background:linear-gradient(90deg,transparent,var(--red),transparent);margin:16px 0}
.sys-text{font-size:11px;color:rgba(255,107,107,0.55);letter-spacing:2px;text-transform:uppercase;line-height:1.8;margin-bottom:20px}
.sys-text .blink{animation:blink-text 1s step-end infinite;color:var(--red)}
.ring-wrap{margin-bottom:20px;position:relative;width:60px;height:60px}
.ring{position:absolute;inset:0;border:2px solid transparent;border-top-color:var(--red);border-radius:50%;animation:spin-slow 1s linear infinite}
.ring2{position:absolute;inset:6px;border:2px solid transparent;border-bottom-color:var(--yellow);border-radius:50%;animation:spin-slow 1.5s linear infinite reverse}
.ring-inner{position:absolute;inset:14px;background:var(--red);border-radius:50%;animation:pulse-red 1s ease-in-out infinite}
.btn-wrap{display:flex;gap:12px;flex-wrap:wrap;justify-content:center}
.btn{font-family:'Space Mono',monospace;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:10px 22px;border-radius:3px;border:none;cursor:pointer;transition:all 0.15s;text-decoration:none;display:inline-flex;align-items:center;gap:7px}
.btn-ghost{background:transparent;color:rgba(255,255,255,0.35);border:1px solid rgba(255,255,255,0.1)}
.btn-ghost:hover{color:rgba(255,255,255,0.6);border-color:rgba(255,255,255,0.25)}
.bottom-bar{margin-top:18px;font-size:9px;letter-spacing:3px;color:rgba(255,26,26,0.3);text-transform:uppercase}
@media(max-width:480px){.alert-box{padding:28px 22px}}
</style>
</head>
<body>
<div class="stripe-top"></div>
<div class="stripe-bottom"></div>
<div class="container">
  <div class="alert-box">
    <div class="bracket tl"></div><div class="bracket tr"></div>
    <div class="bracket bl"></div><div class="bracket br"></div>
    <span class="skull">💀</span>
    <div class="warn-label">PERINGATAN SISTEM AKTIF</div>
    <div class="main-text-wrap">
      <span class="main-text" data-text="CIE HAYO MAU NGAPAIN">CIE HAYO MAU NGAPAIN</span>
    </div>
    <span class="brand">POKAY<span>CORE</span></span>
    <div class="divider"></div>
    <div class="sys-text">
      AKSES TERDETEKSI — IP KAMU SUDAH DICATAT 🕵️<br>
      STATUS: <span class="blink">■ MENCURIGAKAN</span><br>
      LOKASI: LANGIT KE-7 (MAYBE)
    </div>
    <div class="ring-wrap">
      <div class="ring"></div><div class="ring2"></div><div class="ring-inner"></div>
    </div>
    <div class="btn-wrap">
      <a class="btn btn-ghost" href="javascript:history.back()">✕ KABUR</a>
    </div>
    <div class="bottom-bar">POKAYCORE © 2025 — DETECTED • LOGGED • JUDGED</div>
  </div>
</div>
<script>
  const box = document.querySelector('.alert-box');
  setInterval(() => {
    if (Math.random() < 0.15) {
      box.style.transform = 'translateX(' + ((Math.random()-0.5)*8) + 'px)';
      setTimeout(() => box.style.transform = '', 80);
    }
  }, 300);
  setInterval(() => {
    if (Math.random() < 0.05) {
      document.body.style.filter = 'brightness(1.4)';
      setTimeout(() => document.body.style.filter = '', 60);
    }
  }, 500);
</script>
</body>
</html>`;

      return new Response(html, {
        headers: { "Content-Type": "text/html;charset=UTF-8" },
      });
    }

    // Bukan browser (executor Roblox) → fetch script dari GitHub
    const SCRIPT_URL = "https://raw.githubusercontent.com/heimalingpangsit/GATAU/refs/heads/main/pokayfinalbos.lua";

    try {
      const resp = await fetch(SCRIPT_URL);
      if (!resp.ok) {
        return new Response("-- Script tidak tersedia", { headers: { "Content-Type": "text/plain" }, status: 503 });
      }
      const scriptContent = await resp.text();
      return new Response(scriptContent, {
        headers: {
          "Content-Type": "text/plain; charset=utf-8",
          "Access-Control-Allow-Origin": "*",
        },
      });
    } catch (err) {
      return new Response("-- Script tidak tersedia saat ini", {
        headers: { "Content-Type": "text/plain" },
        status: 503,
      });
    }
  },
};
