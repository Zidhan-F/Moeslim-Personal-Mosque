<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="theme-color" content="#07372F">
    <link rel="icon" type="image/png" href="/moeslim-icon.png?v=1">
    <link rel="shortcut icon" href="/favicon.ico?v=1">
    <link rel="apple-touch-icon" href="/moeslim-icon.png?v=1">
    <link rel="manifest" href="/tv/manifest.json">
    <title>Moeslim Mosque TV Display</title>
    <style>
        :root {
            --bg: #041F1A;
            --surface: #0A2E27;
            --surface-2: #0F3B33;
            --border: #1A564A;
            --text: #F7F7F1;
            --muted: #B6CCC6;
            --emerald: #0E9377;
            --emerald-deep: #07372F;
            --gold: #D9AB36;
            --gold-ink: #041F1A;
            --danger: #D94C42;
            --tile-active-bg: #087E65;
            --tile-active-text: #FFFFFF;
            --shadow: 0 18px 48px rgba(0, 0, 0, .35);
        }

        /* Tema tambahan dari Desain Tampilan TV di aplikasi pengurus. */
        [data-theme="navy"] {
            --bg: #061A30;
            --surface: #0F2A4A;
            --surface-2: #123A63;
            --border: #1F4E79;
            --tile-active-bg: #123A63;
        }

        [data-theme="maroon"] {
            --bg: #2E0B12;
            --surface: #4A1520;
            --surface-2: #6B1F2A;
            --border: #7E2E3A;
            --tile-active-bg: #6B1F2A;
        }

        [data-theme="light"] {
            --bg: #F7F7F1;
            --surface: #FFFFFF;
            --surface-2: #EEF2EC;
            --border: #D2DCD7;
            --text: #07372F;
            --muted: #3F5550;
            --emerald: #087E65;
            --emerald-deep: #07372F;
            --gold: #8A6A14;
            --gold-ink: #FFFFFF;
            --danger: #B3261E;
            --tile-active-bg: #087E65;
            --tile-active-text: #FFFFFF;
            --shadow: 0 12px 30px rgba(7, 55, 47, .09);
        }

        * { box-sizing: border-box; }
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            background: var(--bg);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        button, input {
            font: inherit;
            color: inherit;
        }
        button:focus-visible, input:focus-visible {
            outline: 3px solid var(--gold);
            outline-offset: 2px;
        }

        .hidden { display: none !important; }

        /* ── PAIRING SCREEN ─────────────────────────────────────────── */
        .pair-shell {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(0, 1.15fr) minmax(300px, 0.85fr);
            gap: clamp(24px, 4vw, 56px);
            align-items: center;
            padding: clamp(24px, 4vw, 56px);
            max-width: 1320px;
            margin: 0 auto;
        }
        .brand-mark {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 14px;
        }
        .brand-logo {
            width: 28px;
            height: 28px;
            border-radius: 7px;
            display: block;
        }
        .pair-title {
            margin: 0 0 12px;
            font-size: clamp(28px, 3.6vw, 48px);
            line-height: 1.12;
            font-weight: 800;
            letter-spacing: -0.02em;
        }
        .pair-lead {
            margin: 0 0 28px;
            font-size: clamp(15px, 1.5vw, 19px);
            color: var(--muted);
            line-height: 1.55;
            max-width: 58ch;
        }
        .steps {
            list-style: none;
            padding: 0;
            margin: 0 0 28px;
            display: grid;
            gap: 14px;
        }
        .steps li {
            display: grid;
            grid-template-columns: 34px 1fr;
            gap: 14px;
            align-items: start;
            font-size: clamp(15px, 1.35vw, 18px);
            line-height: 1.45;
        }
        .step-num {
            width: 34px;
            height: 34px;
            border-radius: 10px;
            background: var(--surface-2);
            border: 1px solid var(--border);
            color: var(--gold);
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 15px;
        }
        .pair-status-row {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }
        .status-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 10px;
            background: var(--surface);
            border: 1px solid var(--border);
            font-size: 14px;
            font-weight: 600;
        }
        .status-chip.error {
            border-color: var(--danger);
            color: #FFD9D6;
            background: rgba(217, 76, 66, .18);
        }
        .btn-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .btn {
            cursor: pointer;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--text);
            padding: 11px 18px;
            min-height: 44px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
            transition: background .15s ease, border-color .15s ease;
        }
        .btn:hover { background: var(--surface-2); border-color: var(--gold); }
        .btn-primary {
            background: var(--emerald);
            border-color: var(--emerald);
            color: #FFFFFF;
        }
        .btn-primary:hover { background: #0A7B62; border-color: #0A7B62; }
        .btn-gold {
            background: var(--gold);
            border-color: var(--gold);
            color: var(--gold-ink);
        }
        .btn-danger {
            background: var(--danger);
            border-color: var(--danger);
            color: #FFFFFF;
        }

        .qr-panel {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 22px;
            padding: clamp(20px, 2.5vw, 32px);
            text-align: center;
            box-shadow: var(--shadow);
        }
        .qr-box {
            width: min(320px, 72vw);
            aspect-ratio: 1;
            margin: 0 auto 18px;
            background: #FFFFFF;
            border-radius: 16px;
            padding: 16px;
            display: grid;
            place-items: center;
        }
        .qr-box svg {
            width: 100%;
            height: 100%;
            display: block;
            shape-rendering: crispEdges;
        }
        .qr-loading {
            color: #07372F;
            font-weight: 700;
            font-size: 15px;
        }
        .code-caption {
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 6px;
        }
        .pair-code {
            font-size: clamp(28px, 3vw, 40px);
            font-weight: 900;
            letter-spacing: 0.22em;
            font-variant-numeric: tabular-nums;
            color: var(--gold);
            margin-bottom: 8px;
        }
        .pair-expiry {
            font-size: 13px;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
        }

        .manual-box {
            margin-top: 18px;
            padding: 16px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            text-align: left;
        }
        .manual-box label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .manual-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .manual-input {
            flex: 1 1 160px;
            min-height: 44px;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: var(--bg);
            color: var(--text);
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 0.2em;
            font-variant-numeric: tabular-nums;
        }
        .manual-error {
            margin-top: 8px;
            color: #FFB4AE;
            font-size: 13px;
            font-weight: 600;
        }

        /* ── LIVE DISPLAY SCREEN ────────────────────────────────────── */
        .tv-shell {
            width: 100vw;
            height: 100vh;
            display: grid;
            grid-template-rows: auto 1fr auto;
            gap: clamp(12px, 1.8vh, 22px);
            padding: clamp(16px, 2.2vh, 28px) clamp(20px, 2.8vw, 40px);
            overflow: hidden;
        }
        .tv-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding-bottom: clamp(10px, 1.2vh, 16px);
            border-bottom: 1px solid var(--border);
        }
        .mosque-identity h1 {
            margin: 0;
            font-size: clamp(22px, 2.5vw, 38px);
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -0.015em;
        }
        .mosque-identity p {
            margin: 4px 0 0;
            font-size: clamp(13px, 1.25vw, 17px);
            color: var(--muted);
        }
        .date-cluster {
            text-align: right;
            flex-shrink: 0;
        }
        .date-hijri {
            font-size: clamp(16px, 1.6vw, 24px);
            font-weight: 800;
            color: var(--gold);
        }
        .date-greg {
            font-size: clamp(13px, 1.2vw, 17px);
            color: var(--muted);
            margin-top: 2px;
        }
        .sync-badge {
            display: inline-block;
            margin-top: 4px;
            padding: 3px 9px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            background: rgba(217, 76, 66, .22);
            color: #FFD9D6;
        }
        [data-theme="light"] .sync-badge {
            background: #FDECEB;
            color: #8E1E16;
        }

        .tv-main {
            display: grid;
            grid-template-columns: minmax(0, 1.05fr) minmax(0, 1.15fr);
            gap: clamp(18px, 2.4vw, 34px);
            min-height: 0;
        }
        .clock-stage {
            display: flex;
            flex-direction: column;
            justify-content: center;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 22px;
            padding: clamp(20px, 3vh, 36px) clamp(22px, 2.8vw, 38px);
            box-shadow: var(--shadow);
        }
        .clock-time {
            font-size: clamp(56px, 8.6vw, 136px);
            font-weight: 900;
            line-height: 1;
            letter-spacing: -0.03em;
            font-variant-numeric: tabular-nums;
        }
        .clock-sec {
            font-size: 0.42em;
            font-weight: 700;
            color: var(--gold);
            margin-left: 4px;
            vertical-align: top;
        }
        .phase-card {
            margin-top: clamp(16px, 2.5vh, 28px);
            padding: clamp(14px, 2vh, 22px) clamp(16px, 2vw, 24px);
            border-radius: 16px;
            background: var(--surface-2);
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }
        .phase-card.iqamah {
            background: var(--gold);
            border-color: var(--gold);
            color: var(--gold-ink);
        }
        .phase-label {
            font-size: clamp(14px, 1.4vw, 20px);
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .phase-sub {
            font-size: clamp(12px, 1.1vw, 15px);
            opacity: 0.88;
            margin-top: 3px;
        }
        .phase-countdown {
            font-size: clamp(30px, 3.6vw, 54px);
            font-weight: 900;
            font-variant-numeric: tabular-nums;
            line-height: 1;
        }

        .info-stage {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 22px;
            padding: clamp(20px, 2.6vh, 32px) clamp(22px, 2.5vw, 34px);
            display: flex;
            flex-direction: column;
            min-height: 0;
            box-shadow: var(--shadow);
        }
        .slide-kicker {
            font-size: clamp(12px, 1.1vw, 15px);
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--gold);
            margin-bottom: 8px;
        }
        .slide-title {
            margin: 0 0 14px;
            font-size: clamp(20px, 2.1vw, 32px);
            font-weight: 800;
            line-height: 1.2;
        }
        .slide-body {
            flex: 1;
            min-height: 0;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 12px;
        }
        .info-list {
            display: grid;
            gap: 12px;
        }
        .info-item {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 14px 16px;
        }
        .info-item-title {
            font-size: clamp(16px, 1.55vw, 22px);
            font-weight: 800;
            margin-bottom: 4px;
        }
        .info-item-meta {
            font-size: clamp(13px, 1.2vw, 17px);
            color: var(--muted);
            line-height: 1.45;
        }
        .staff-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }
        .stat-box {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 14px 16px;
        }
        .stat-label {
            font-size: clamp(12px, 1.05vw, 14px);
            color: var(--muted);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .stat-val {
            font-size: clamp(18px, 1.9vw, 28px);
            font-weight: 900;
            margin-top: 4px;
            font-variant-numeric: tabular-nums;
        }
        .qris-slide {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 24px;
            align-items: center;
        }
        .qris-frame {
            background: #FFFFFF;
            padding: 12px;
            border-radius: 16px;
            width: clamp(180px, 24vh, 260px);
            aspect-ratio: 1;
            display: grid;
            place-items: center;
        }
        .qris-frame img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .slide-dots {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 14px;
        }
        .slide-dot {
            width: 8px;
            height: 8px;
            border-radius: 99px;
            background: var(--border);
            transition: width .2s ease, background .2s ease;
        }
        .slide-dot.active {
            width: 24px;
            background: var(--gold);
        }

        /* ── PRAYER STRIP ───────────────────────────────────────────── */
        .prayer-bar {
            display: grid;
            grid-template-columns: repeat(6, minmax(0, 1fr));
            gap: clamp(8px, 1vw, 14px);
        }
        .prayer-tile {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: clamp(10px, 1.4vh, 18px) 12px;
            text-align: center;
        }
        .prayer-tile.active {
            background: var(--tile-active-bg);
            border-color: var(--gold);
            color: var(--tile-active-text);
            box-shadow: 0 0 0 2px var(--gold);
        }
        .prayer-name {
            font-size: clamp(12px, 1.15vw, 16px);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--muted);
        }
        .prayer-tile.active .prayer-name {
            color: #F7F7F1;
        }
        .prayer-time {
            font-size: clamp(22px, 2.5vw, 38px);
            font-weight: 900;
            font-variant-numeric: tabular-nums;
            margin-top: 4px;
            line-height: 1.05;
        }

        /* ── FULLSCREEN OVERLAYS (OVERRIDE / SILENT PRAYER) ─────────── */
        .overlay {
            position: fixed;
            inset: 0;
            z-index: 40;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: clamp(28px, 5vw, 72px);
        }
        .overlay-silent {
            background: #020E0B;
            color: #DCE7E3;
        }
        .overlay-duka {
            background: #06251F;
            color: #F7F7F1;
        }
        .overlay-darurat {
            background: #6B1410;
            color: #FFFFFF;
        }
        .overlay-badge {
            font-size: clamp(14px, 1.4vw, 20px);
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: #D9AB36;
            margin-bottom: 16px;
        }
        .overlay-title {
            margin: 0 0 18px;
            font-size: clamp(32px, 4.6vw, 68px);
            font-weight: 900;
            line-height: 1.12;
            max-width: 24ch;
        }
        .overlay-body {
            margin: 0;
            font-size: clamp(18px, 2.2vw, 34px);
            line-height: 1.45;
            max-width: 44ch;
            opacity: 0.94;
        }
        .overlay-foot {
            position: fixed;
            bottom: 24px;
            right: 32px;
            font-size: clamp(16px, 1.5vw, 22px);
            font-weight: 700;
            font-variant-numeric: tabular-nums;
            opacity: 0.72;
        }

        /* ── FLOATING CONTROLS ──────────────────────────────────────── */
        .tv-toolbar {
            position: fixed;
            top: 14px;
            right: 16px;
            z-index: 60;
            display: flex;
            gap: 8px;
            opacity: 0.16;
            transition: opacity .2s ease;
        }
        .tv-toolbar:hover, .tv-toolbar:focus-within, .tv-toolbar.visible {
            opacity: 1;
        }
        .tool-btn {
            cursor: pointer;
            min-height: 44px;
            padding: 8px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: rgba(7, 55, 47, .92);
            color: #F7F7F1;
            font-size: 13px;
            font-weight: 700;
        }
        .tool-btn:hover { border-color: #D9AB36; }

        /* ── MODAL ──────────────────────────────────────────────────── */
        .modal-backdrop {
            position: fixed;
            inset: 0;
            z-index: 80;
            background: rgba(0, 0, 0, .65);
            display: grid;
            place-items: center;
            padding: 20px;
        }
        .modal-card {
            width: min(460px, 100%);
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 24px;
            box-shadow: var(--shadow);
        }
        .modal-card h2 { margin: 0 0 8px; font-size: 20px; }
        .modal-card p { margin: 0 0 20px; color: var(--muted); line-height: 1.5; }

        @media (max-width: 960px) {
            .pair-shell { grid-template-columns: 1fr; padding: 20px; }
            .tv-shell { height: auto; min-height: 100vh; overflow: auto; }
            .tv-main { grid-template-columns: 1fr; }
            .prayer-bar { grid-template-columns: repeat(3, minmax(0, 1fr)); }
            .qris-slide { grid-template-columns: 1fr; justify-items: center; text-align: center; }
        }
    </style>
</head>
<body data-theme="dark">
    <!-- PAIRING VIEW (Zero mosque data before paired) -->
    <main id="pairing-view" class="pair-shell">
        <section>
            <div class="brand-mark"><img src="/moeslim-icon.png" alt="Moeslim" class="brand-logo"> Moeslim Mosque TV</div>
            <h1 class="pair-title">Hubungkan Layar TV ke Masjid Anda</h1>
            <p class="pair-lead">
                Tampilkan jam digital, jadwal salat otomatis, countdown iqamah, layar hening salat, papan petugas Jumat, dan QRIS infaq masjid langsung dari browser TV tanpa install aplikasi tambahan.
            </p>
            <ol class="steps">
                <li>
                    <span class="step-num">1</span>
                    <span>Buka aplikasi <strong>Moeslim</strong> di HP pengurus masjid lalu pilih menu <strong>TV Display</strong>.</span>
                </li>
                <li>
                    <span class="step-num">2</span>
                    <span>Ketuk <strong>Scan QR TV</strong> dan arahkan kamera HP ke kode QR di samping.</span>
                </li>
                <li>
                    <span class="step-num">3</span>
                    <span>Layar ini otomatis terhubung khusus ke masjid Anda dan langsung menampilkan jadwal salat.</span>
                </li>
            </ol>
            <div class="pair-status-row">
                <div id="pair-status" class="status-chip" role="status" aria-live="polite">Menyiapkan sesi QR...</div>
            </div>
            <div class="btn-row">
                <button id="btn-refresh-qr" type="button" class="btn">Perbarui QR</button>
                <button id="btn-pair-fullscreen" type="button" class="btn btn-primary">Layar Penuh</button>
                <button id="btn-toggle-manual" type="button" class="btn">Masukkan Kode dari HP</button>
            </div>
            <form id="manual-pair-form" class="manual-box hidden" novalidate>
                <label for="manual-code-input">Kode 6 digit yang dibuat di menu TV Display HP pengurus</label>
                <div class="manual-row">
                    <input id="manual-code-input" class="manual-input" inputmode="numeric" maxlength="6" autocomplete="one-time-code" placeholder="000000">
                    <button id="btn-manual-submit" type="submit" class="btn btn-gold">Hubungkan</button>
                </div>
                <div id="manual-error" class="manual-error hidden" role="alert"></div>
            </form>
        </section>

        <aside class="qr-panel" aria-label="Kode QR Pairing TV">
            <div id="qr-box" class="qr-box">
                <div class="qr-loading">Membuat kode QR...</div>
            </div>
            <div class="code-caption">Atau masukkan 6 digit kode sesi ini di HP pengurus</div>
            <div id="pair-code" class="pair-code">--- ---</div>
            <div id="pair-expiry" class="pair-expiry">Menghubungkan ke server...</div>
        </aside>
    </main>

    <!-- LIVE TV DISPLAY PRO VIEW -->
    <div id="display-view" class="tv-shell hidden">
        <header class="tv-header">
            <div class="mosque-identity">
                <h1 id="tv-mosque-name">Memuat masjid...</h1>
                <p id="tv-mosque-address"></p>
            </div>
            <div class="date-cluster">
                <div id="tv-date-hijri" class="date-hijri"></div>
                <div id="tv-date-greg" class="date-greg"></div>
                <div id="tv-offline-badge" class="sync-badge hidden">Offline: menggunakan jadwal tersimpan</div>
            </div>
        </header>

        <section class="tv-main">
            <div class="clock-stage">
                <div class="clock-time">
                    <span id="tv-clock-hm">--:--</span><span id="tv-clock-sec" class="clock-sec">--</span>
                </div>
                <div id="tv-phase-card" class="phase-card">
                    <div>
                        <div id="tv-phase-label" class="phase-label">Menuju Waktu Salat</div>
                        <div id="tv-phase-sub" class="phase-sub">Jadwal otomatis sesuai lokasi masjid</div>
                    </div>
                    <div id="tv-phase-countdown" class="phase-countdown">--:--</div>
                </div>
            </div>

            <div class="info-stage">
                <div id="tv-slide-kicker" class="slide-kicker">Informasi Masjid</div>
                <h2 id="tv-slide-title" class="slide-title">Memuat konten...</h2>
                <div id="tv-slide-body" class="slide-body"></div>
                <div id="tv-slide-dots" class="slide-dots" aria-hidden="true"></div>
            </div>
        </section>

        <footer id="tv-prayer-bar" class="prayer-bar" aria-label="Jadwal Salat Hari Ini"></footer>
    </div>

    <!-- OVERLAY: OVERRIDE BERITA DUKA / DARURAT OR SILENT PRAYER SCREEN -->
    <div id="tv-overlay" class="overlay hidden" role="region" aria-live="polite">
        <div id="overlay-badge" class="overlay-badge"></div>
        <h2 id="overlay-title" class="overlay-title"></h2>
        <p id="overlay-body" class="overlay-body"></p>
        <div id="overlay-foot" class="overlay-foot"></div>
    </div>

    <!-- FLOATING TOOLBAR -->
    <div id="tv-toolbar" class="tv-toolbar hidden">
        <button id="btn-fullscreen" type="button" class="tool-btn">Layar Penuh</button>
        <button id="btn-sync" type="button" class="tool-btn">Sinkronkan</button>
        <button id="btn-unpair" type="button" class="tool-btn">Putuskan TV</button>
    </div>

    <!-- UNPAIR CONFIRM MODAL -->
    <div id="unpair-modal" class="modal-backdrop hidden" role="dialog" aria-modal="true" aria-labelledby="unpair-title">
        <div class="modal-card">
            <h2 id="unpair-title">Putuskan Hubungan TV Ini?</h2>
            <p>Layar ini akan kembali ke tampilan QR pairing dan data masjid di browser ini akan dibersihkan.</p>
            <div class="btn-row">
                <button id="btn-unpair-cancel" type="button" class="btn">Batal</button>
                <button id="btn-unpair-confirm" type="button" class="btn btn-danger">Ya, Putuskan</button>
            </div>
        </div>
    </div>

    <script>
    (() => {
        'use strict';

        // ── 1. ISO/IEC 18004 QR CODE ENCODER (BYTE MODE, LEVEL M, V1..V4) ──
        const QR = (() => {
            const EXP = new Uint8Array(512);
            const LOG = new Uint8Array(256);
            let x = 1;
            for (let i = 0; i < 255; i++) {
                EXP[i] = x;
                LOG[x] = i;
                x = (x << 1) ^ (x & 128 ? 0x11d : 0);
            }
            for (let i = 255; i < 512; i++) EXP[i] = EXP[i - 255];

            const gfMul = (a, b) => (a === 0 || b === 0) ? 0 : EXP[LOG[a] + LOG[b]];

            const rsGen = (deg) => {
                let g = [1];
                for (let i = 0; i < deg; i++) {
                    const next = new Array(g.length + 1).fill(0);
                    for (let j = 0; j < g.length; j++) {
                        next[j] ^= g[j];
                        next[j + 1] ^= gfMul(g[j], EXP[i]);
                    }
                    g = next;
                }
                return g;
            };

            const rsEncode = (data, ecLen) => {
                const gen = rsGen(ecLen);
                const rem = new Uint8Array(ecLen);
                for (let i = 0; i < data.length; i++) {
                    const factor = data[i] ^ rem[0];
                    rem.copyWithin(0, 1);
                    rem[ecLen - 1] = 0;
                    if (factor !== 0) {
                        for (let j = 0; j < ecLen; j++) {
                            rem[j] ^= gfMul(gen[j + 1], factor);
                        }
                    }
                }
                return rem;
            };

            // Version specs for ECC Level M: [version, size, totalData, blocks, ecPerBlock, alignCenters]
            const SPECS = [
                { v: 1, size: 21, data: 16, blocks: 1, ec: 10, align: [] },
                { v: 2, size: 25, data: 28, blocks: 1, ec: 16, align: [6, 18] },
                { v: 3, size: 29, data: 44, blocks: 1, ec: 26, align: [6, 22] },
                { v: 4, size: 33, data: 64, blocks: 2, ec: 18, align: [6, 26] },
            ];

            const maskFn = [
                (r, c) => (r + c) % 2 === 0,
                (r, c) => r % 2 === 0,
                (r, c) => c % 3 === 0,
                (r, c) => (r + c) % 3 === 0,
                (r, c) => (Math.floor(r / 2) + Math.floor(c / 3)) % 2 === 0,
                (r, c) => ((r * c) % 2) + ((r * c) % 3) === 0,
                (r, c) => (((r * c) % 2) + ((r * c) % 3)) % 2 === 0,
                (r, c) => (((r + c) % 2) + ((r * c) % 3)) % 2 === 0,
            ];

            function buildMatrix(text) {
                const bytes = new TextEncoder().encode(text);
                const spec = SPECS.find((s) => bytes.length <= s.data - 2);
                if (!spec) throw new Error('QR payload too long');

                // Build bit buffer (Byte mode = 0100, 8-bit length)
                const bits = [];
                const pushBits = (val, len) => {
                    for (let i = len - 1; i >= 0; i--) bits.push((val >> i) & 1);
                };
                pushBits(0b0100, 4);
                pushBits(bytes.length, 8);
                for (const b of bytes) pushBits(b, 8);

                const capBits = spec.data * 8;
                const termLen = Math.min(4, capBits - bits.length);
                for (let i = 0; i < termLen; i++) bits.push(0);
                while (bits.length % 8 !== 0) bits.push(0);

                const dataCw = [];
                for (let i = 0; i < bits.length; i += 8) {
                    let v = 0;
                    for (let j = 0; j < 8; j++) v = (v << 1) | bits[i + j];
                    dataCw.push(v);
                }
                const pads = [0xec, 0x11];
                let padIdx = 0;
                while (dataCw.length < spec.data) dataCw.push(pads[padIdx++ & 1]);

                // Split into blocks & compute Reed-Solomon EC
                const perBlock = spec.data / spec.blocks;
                const dBlocks = [];
                const eBlocks = [];
                for (let b = 0; b < spec.blocks; b++) {
                    const chunk = dataCw.slice(b * perBlock, (b + 1) * perBlock);
                    dBlocks.push(chunk);
                    eBlocks.push(rsEncode(chunk, spec.ec));
                }

                const codewords = [];
                for (let i = 0; i < perBlock; i++) {
                    for (let b = 0; b < spec.blocks; b++) codewords.push(dBlocks[b][i]);
                }
                for (let i = 0; i < spec.ec; i++) {
                    for (let b = 0; b < spec.blocks; b++) codewords.push(eBlocks[b][i]);
                }

                const n = spec.size;
                const mat = Array.from({ length: n }, () => new Int8Array(n)); // 0=light, 1=dark
                const res = Array.from({ length: n }, () => new Uint8Array(n)); // 1=function pattern

                const setFunc = (r, c, dark) => {
                    if (r >= 0 && r < n && c >= 0 && c < n) {
                        mat[r][c] = dark ? 1 : 0;
                        res[r][c] = 1;
                    }
                };

                // Finder patterns + separators
                const drawFinder = (r0, c0) => {
                    for (let dr = -1; dr <= 7; dr++) {
                        for (let dc = -1; dc <= 7; dc++) {
                            const r = r0 + dr, c = c0 + dc;
                            if (r < 0 || r >= n || c < 0 || c >= n) continue;
                            const inBorder = dr >= 0 && dr <= 6 && dc >= 0 && dc <= 6;
                            const dark = inBorder && (
                                dr === 0 || dr === 6 || dc === 0 || dc === 6 ||
                                (dr >= 2 && dr <= 4 && dc >= 2 && dc <= 4)
                            );
                            setFunc(r, c, dark);
                        }
                    }
                };
                drawFinder(0, 0);
                drawFinder(0, n - 7);
                drawFinder(n - 7, 0);

                // Alignment patterns
                for (const ar of spec.align) {
                    for (const ac of spec.align) {
                        if (res[ar][ac]) continue;
                        for (let dr = -2; dr <= 2; dr++) {
                            for (let dc = -2; dc <= 2; dc++) {
                                const dark = Math.max(Math.abs(dr), Math.abs(dc)) !== 1;
                                setFunc(ar + dr, ac + dc, dark);
                            }
                        }
                    }
                }

                // Timing patterns
                for (let i = 8; i < n - 8; i++) {
                    if (!res[6][i]) setFunc(6, i, i % 2 === 0);
                    if (!res[i][6]) setFunc(i, 6, i % 2 === 0);
                }

                // Dark module & reserve format info areas
                setFunc(n - 8, 8, true);
                for (let i = 0; i <= 8; i++) {
                    if (i !== 6) { res[8][i] = 1; res[i][8] = 1; }
                }
                for (let i = 0; i < 8; i++) {
                    res[8][n - 1 - i] = 1;
                    if (i < 7) res[n - 1 - i][8] = 1;
                }

                // Place data bits in 2-col zigzag
                const bitStream = [];
                for (const cw of codewords) {
                    for (let i = 7; i >= 0; i--) bitStream.push((cw >> i) & 1);
                }
                let bitIdx = 0;
                let up = true;
                for (let col = n - 1; col >= 1; col -= 2) {
                    if (col === 6) col = 5;
                    for (let step = 0; step < n; step++) {
                        const row = up ? (n - 1 - step) : step;
                        for (let dx = 0; dx < 2; dx++) {
                            const c = col - dx;
                            if (!res[row][c]) {
                                mat[row][c] = bitIdx < bitStream.length ? bitStream[bitIdx++] : 0;
                            }
                        }
                    }
                    up = !up;
                }

                const writeFormat = (m, maskId) => {
                    const data5 = (0b00 << 3) | maskId; // Level M = 00
                    let rem = data5 << 10;
                    for (let i = 14; i >= 10; i--) {
                        if ((rem >> i) & 1) rem ^= (0x537 << (i - 10));
                    }
                    const fmt = ((data5 << 10) | rem) ^ 0x5412;
                    const bit = (i) => (fmt >> i) & 1;

                    // Copy 1: top-left
                    const coords1 = [
                        [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 7], [8, 8],
                        [7, 8], [5, 8], [4, 8], [3, 8], [2, 8], [1, 8], [0, 8],
                    ];
                    for (let k = 0; k < 15; k++) {
                        const [r, c] = coords1[k];
                        m[r][c] = bit(14 - k);
                    }
                    // Copy 2: bottom-left & top-right
                    for (let k = 0; k < 7; k++) m[n - 1 - k][8] = bit(14 - k);
                    for (let k = 0; k < 8; k++) m[8][n - 8 + k] = bit(7 - k);
                };

                const penalty = (m) => {
                    let score = 0;
                    for (let r = 0; r < n; r++) {
                        let run = 1;
                        for (let c = 1; c < n; c++) {
                            if (m[r][c] === m[r][c - 1]) {
                                run++;
                                if (run === 5) score += 3;
                                else if (run > 5) score += 1;
                            } else run = 1;
                        }
                    }
                    for (let c = 0; c < n; c++) {
                        let run = 1;
                        for (let r = 1; r < n; r++) {
                            if (m[r][c] === m[r - 1][c]) {
                                run++;
                                if (run === 5) score += 3;
                                else if (run > 5) score += 1;
                            } else run = 1;
                        }
                    }
                    for (let r = 0; r < n - 1; r++) {
                        for (let c = 0; c < n - 1; c++) {
                            const v = m[r][c];
                            if (v === m[r][c + 1] && v === m[r + 1][c] && v === m[r + 1][c + 1]) score += 3;
                        }
                    }
                    return score;
                };

                let best = null;
                let bestScore = Infinity;
                for (let maskId = 0; maskId < 8; maskId++) {
                    const cand = mat.map((row, r) => {
                        const copy = new Int8Array(row);
                        for (let c = 0; c < n; c++) {
                            if (!res[r][c] && maskFn[maskId](r, c)) copy[c] ^= 1;
                        }
                        return copy;
                    });
                    writeFormat(cand, maskId);
                    const sc = penalty(cand);
                    if (sc < bestScore) { bestScore = sc; best = cand; }
                }
                return best;
            }

            function toSvg(text) {
                const m = buildMatrix(text);
                const n = m.length;
                const quiet = 4;
                const total = n + quiet * 2;
                let rects = '';
                for (let r = 0; r < n; r++) {
                    for (let c = 0; c < n; c++) {
                        if (m[r][c]) {
                            rects += `<rect x="${c + quiet}" y="${r + quiet}" width="1" height="1"/>`;
                        }
                    }
                }
                return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${total} ${total}" role="img" aria-label="QR Code pairing TV"><rect width="${total}" height="${total}" fill="#FFFFFF"/><g fill="#07372F">${rects}</g></svg>`;
            }

            return { buildMatrix, toSvg };
        })();

        // ── 2. ASTRONOMICAL PRAYER TIMES & HIJRI CALENDAR (matches shared_prayer) ──
        const PrayerEngine = (() => {
            const dtr = (d) => d * Math.PI / 180;
            const rtd = (r) => r * 180 / Math.PI;
            const fixAngle = (a) => a - 360 * Math.floor(a / 360);
            const fixHour = (a) => a - 24 * Math.floor(a / 24);
            const acot = (v) => Math.atan(1 / v);

            const METHODS = {
                kemenag: { fajr: 20, isha: 18, ishaMin: null, ih: 2 },
                muslimWorldLeague: { fajr: 18, isha: 17, ishaMin: null, ih: 0 },
                ummAlQura: { fajr: 18.5, isha: null, ishaMin: 90, ih: 0 },
                isna: { fajr: 15, isha: 15, ishaMin: null, ih: 0 },
                egypt: { fajr: 19.5, isha: 17.5, ishaMin: null, ih: 0 },
                jakim: { fajr: 20, isha: 18, ishaMin: null, ih: 1 },
            };

            function utcOffsetFor(tz) {
                if (tz === 'Asia/Jakarta' || tz === 'Asia/Pontianak') return 7;
                if (tz === 'Asia/Makassar') return 8;
                if (tz === 'Asia/Jayapura') return 9;
                return -new Date().getTimezoneOffset() / 60;
            }

            function julianDay(y, m, d) {
                if (m <= 2) { y -= 1; m += 12; }
                const a = Math.floor(y / 100);
                const b = 2 - a + Math.floor(a / 4);
                return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + d + b - 1524.5;
            }

            function sunPos(jd) {
                const d = jd - 2451545.0;
                const g = fixAngle(357.529 + 0.98560028 * d);
                const q = fixAngle(280.459 + 0.98564736 * d);
                const l = fixAngle(q + 1.915 * Math.sin(dtr(g)) + 0.020 * Math.sin(dtr(2 * g)));
                const e = 23.439 - 0.00000036 * d;
                const ra = rtd(Math.atan2(Math.cos(dtr(e)) * Math.sin(dtr(l)), Math.cos(dtr(l)))) / 15.0;
                let eqt = q / 15.0 - fixHour(ra);
                if (eqt > 12) eqt -= 24;
                if (eqt < -12) eqt += 24;
                const decl = rtd(Math.asin(Math.sin(dtr(e)) * Math.sin(dtr(l))));
                return { decl, eqt };
            }

            function midDay(jd, hour) {
                return fixHour(12 - sunPos(jd + hour / 24).eqt);
            }

            function computeDay(y, m, d, lat, lng, utcOffset, methodKey, adjustments) {
                const method = METHODS[methodKey] || METHODS.kemenag;
                const jd = julianDay(y, m, d) - lng / (15 * 24);
                let t = { fajr: 5, sunrise: 6, dhuhr: 12, asr: 13, maghrib: 18, isha: 18 };

                for (let i = 0; i < 2; i++) {
                    const sun = (hour, angle, ccw) => {
                        const p = sunPos(jd + hour / 24);
                        const noon = midDay(jd, hour);
                        const x = (-Math.sin(dtr(angle)) - Math.sin(dtr(p.decl)) * Math.sin(dtr(lat))) /
                            (Math.cos(dtr(p.decl)) * Math.cos(dtr(lat)));
                        const clamped = Math.max(-1, Math.min(1, x));
                        const v = rtd(Math.acos(clamped)) / 15.0;
                        return noon + (ccw ? -v : v);
                    };
                    const asrTime = (hour) => {
                        const p = sunPos(jd + hour / 24);
                        const angle = -rtd(acot(1 + Math.tan(dtr(Math.abs(lat - p.decl)))));
                        return sun(hour, angle, false);
                    };
                    t = {
                        fajr: sun(t.fajr, method.fajr, true),
                        sunrise: sun(t.sunrise, 0.833, true),
                        dhuhr: midDay(jd, t.dhuhr),
                        asr: asrTime(t.asr),
                        maghrib: sun(t.maghrib, 0.833, false),
                        isha: method.isha != null ? sun(t.isha, method.isha, false) : t.isha,
                    };
                }
                if (method.ishaMin != null) {
                    t.isha = t.maghrib + method.ishaMin / 60.0;
                }

                const shift = utcOffset - lng / 15.0;
                const ih = method.ih;
                const adj = (k) => Number((adjustments && adjustments[k]) || 0);
                const toMin = (h, extra, ceil = true) => {
                    const secs = (h + shift) * 3600 + extra * 60;
                    return ceil ? Math.ceil(secs / 60) : Math.floor(secs / 60);
                };

                return {
                    fajr: toMin(t.fajr, ih + adj('fajr'), true),
                    sunrise: toMin(t.sunrise, -ih, false),
                    dhuhr: toMin(t.dhuhr, ih + adj('dhuhr'), true),
                    asr: toMin(t.asr, ih + adj('asr'), true),
                    maghrib: toMin(t.maghrib, ih + adj('maghrib'), true),
                    isha: toMin(t.isha, ih + adj('isha'), true),
                };
            }

            const HIJRI_ID = ['Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir', 'Jumadil Awal', 'Jumadil Akhir', 'Rajab', "Sya'ban", 'Ramadan', 'Syawal', "Dzulqa'dah", 'Dzulhijjah'];
            const HIJRI_EN = ['Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Ula', 'Jumada al-Akhirah', 'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qa'dah", 'Dhu al-Hijjah'];
            const HIJRI_EPOCH = 1948439.5;
            const hijriToJd = (y, m, d) => d + Math.ceil(29.5 * (m - 1)) + (y - 1) * 354 + Math.floor((3 + 11 * y) / 30) + HIJRI_EPOCH - 1;

            function formatHijri(y, m, d, offsetDays, lang) {
                const utcMs = Date.UTC(y, m - 1, d) + (offsetDays || 0) * 86400000;
                const jd = utcMs / 86400000 + 2440587.5;
                const hy = Math.floor((30 * (jd - HIJRI_EPOCH) + 10646) / 10631);
                let hm = Math.ceil((jd - (29 + hijriToJd(hy, 1, 1))) / 29.5) + 1;
                hm = Math.max(1, Math.min(12, hm));
                const hd = Math.max(1, Math.min(30, Math.round(jd - hijriToJd(hy, hm, 1)) + 1));
                const names = lang === 'en' ? HIJRI_EN : HIJRI_ID;
                return lang === 'en' ? `${hd} ${names[hm - 1]} ${hy} AH` : `${hd} ${names[hm - 1]} ${hy} H`;
            }

            return { utcOffsetFor, computeDay, formatHijri };
        })();

        // ── 3. APP STATE & PERSISTENCE ──
        const STORAGE = {
            token: 'moeslim.tv.token',
            content: 'moeslim.tv.content',
            etag: 'moeslim.tv.etag',
            skew: 'moeslim.tv.skewMs',
        };

        const state = {
            token: localStorage.getItem(STORAGE.token),
            content: (() => {
                try { return JSON.parse(localStorage.getItem(STORAGE.content) || 'null'); }
                catch { return null; }
            })(),
            etag: localStorage.getItem(STORAGE.etag),
            skewMs: Number(localStorage.getItem(STORAGE.skew) || 0),
            offline: false,
            session: null,
            pollTimer: null,
            syncTimer: null,
            tickTimer: null,
            qrisBlobUrl: null,
            qrisLoadedFor: null,
            slideIdx: 0,
            lastSlideAt: Date.now(),
            lastBeepKey: null,
            wakeLock: null,
        };

        const $ = (id) => document.getElementById(id);
        const pad2 = (n) => String(Math.floor(Math.max(0, n))).padStart(2, '0');
        const fmtMin = (m) => `${pad2(Math.floor(m / 60) % 24)}:${pad2(m % 60)}`;
        const fmtSec = (s) => {
            const total = Math.max(0, Math.floor(s));
            const h = Math.floor(total / 3600);
            const m = Math.floor((total % 3600) / 60);
            const sc = total % 60;
            return h > 0 ? `${pad2(h)}:${pad2(m)}:${pad2(sc)}` : `${pad2(m)}:${pad2(sc)}`;
        };
        const fmtRp = (n) => 'Rp' + Math.round(Number(n || 0)).toLocaleString('id-ID');
        const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

        // Subtle Web Audio chime for Iqamah (if browser audio policy allows after interaction)
        function playIqamahBeep() {
            try {
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                const ctx = new AudioCtx();
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.value = 880;
                gain.gain.setValueAtTime(0.16, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.45);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.46);
            } catch (_) {}
        }

        async function acquireWakeLock() {
            try {
                if ('wakeLock' in navigator && !state.wakeLock) {
                    state.wakeLock = await navigator.wakeLock.request('screen');
                    state.wakeLock.addEventListener('release', () => { state.wakeLock = null; });
                }
            } catch (_) {}
        }

        function toggleFullscreen() {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen?.().catch(() => {});
            } else {
                document.exitFullscreen?.().catch(() => {});
            }
        }

        // ── 4. REVERSE QR PAIRING FLOW ──
        async function startPairingSession() {
            clearInterval(state.pollTimer);
            state.session = null;
            $('pair-status').className = 'status-chip';
            $('pair-status').textContent = 'Menyiapkan kode QR baru...';
            $('qr-box').innerHTML = '<div class="qr-loading">Membuat kode QR...</div>';
            $('pair-code').textContent = '--- ---';
            $('pair-expiry').textContent = 'Menghubungkan ke server...';

            try {
                const res = await fetch('/api/display/sessions', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json' },
                });
                if (!res.ok) throw new Error('HTTP ' + res.status);
                const data = await res.json();
                state.session = {
                    sessionId: data.session_id,
                    pollSecret: data.poll_secret,
                    code: data.code,
                    qrPayload: data.qr_payload,
                    expiresAt: new Date(data.expires_at).getTime(),
                };
                $('qr-box').innerHTML = QR.toSvg(data.qr_payload);
                $('pair-code').textContent = `${data.code.slice(0, 3)} ${data.code.slice(3)}`;
                $('pair-status').textContent = 'Siap dipindai dari aplikasi Moeslim di HP pengurus';
                updateSessionExpiryLabel();
                state.pollTimer = setInterval(pollPairingSession, 3000);
            } catch (_) {
                $('pair-status').className = 'status-chip error';
                $('pair-status').textContent = 'Gagal terhubung ke server. Periksa internet TV lalu klik Perbarui QR.';
                $('qr-box').innerHTML = '<div class="qr-loading">Tidak dapat memuat QR</div>';
                $('pair-expiry').textContent = 'Koneksi terputus';
            }
        }

        function updateSessionExpiryLabel() {
            if (!state.session) return;
            const leftSec = Math.floor((state.session.expiresAt - Date.now()) / 1000);
            if (leftSec <= 0) {
                $('pair-expiry').textContent = 'QR kedaluwarsa, memperbarui otomatis...';
                startPairingSession();
                return;
            }
            $('pair-expiry').textContent = `Kode QR berlaku ${fmtSec(leftSec)} lagi`;
        }

        async function pollPairingSession() {
            if (!state.session || state.token) return;
            updateSessionExpiryLabel();
            try {
                const res = await fetch(`/api/display/sessions/${encodeURIComponent(state.session.sessionId)}/poll`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify({ poll_secret: state.session.pollSecret }),
                });
                if (!res.ok) return;
                const data = await res.json();
                if (data.status === 'paired' && data.token) {
                    completePairing(data.token);
                } else if (data.status === 'expired') {
                    startPairingSession();
                }
            } catch (_) {
                $('pair-status').className = 'status-chip error';
                $('pair-status').textContent = 'Koneksi internet sempat terputus, mencoba menyambung kembali...';
            }
        }

        async function submitManualPair(e) {
            e.preventDefault();
            const code = $('manual-code-input').value.replace(/\D/g, '').slice(0, 6);
            const errEl = $('manual-error');
            errEl.classList.add('hidden');
            if (code.length !== 6) {
                errEl.textContent = 'Masukkan 6 digit kode pairing dari HP pengurus.';
                errEl.classList.remove('hidden');
                return;
            }
            $('btn-manual-submit').disabled = true;
            try {
                const res = await fetch('/api/display/pair', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify({ code, device_name: 'TV Display Web' }),
                });
                const body = await res.json().catch(() => ({}));
                if (!res.ok || !body.token) {
                    errEl.textContent = body.message || 'Kode pairing tidak valid atau kedaluwarsa.';
                    errEl.classList.remove('hidden');
                    return;
                }
                completePairing(body.token);
            } catch (_) {
                errEl.textContent = 'Tidak dapat terhubung ke server. Periksa internet TV.';
                errEl.classList.remove('hidden');
            } finally {
                $('btn-manual-submit').disabled = false;
            }
        }

        function completePairing(token) {
            clearInterval(state.pollTimer);
            state.session = null;
            state.token = token;
            state.content = null;
            state.etag = null;
            localStorage.setItem(STORAGE.token, token);
            localStorage.removeItem(STORAGE.content);
            localStorage.removeItem(STORAGE.etag);
            enterDisplayMode();
        }

        function unpairDisplay() {
            clearInterval(state.syncTimer);
            clearInterval(state.tickTimer);
            if (state.qrisBlobUrl) {
                URL.revokeObjectURL(state.qrisBlobUrl);
                state.qrisBlobUrl = null;
                state.qrisLoadedFor = null;
            }
            state.token = null;
            state.content = null;
            state.etag = null;
            state.offline = false;
            Object.values(STORAGE).forEach((k) => localStorage.removeItem(k));
            $('unpair-modal').classList.add('hidden');
            $('tv-overlay').classList.add('hidden');
            $('display-view').classList.add('hidden');
            $('tv-toolbar').classList.add('hidden');
            $('pairing-view').classList.remove('hidden');
            document.body.dataset.theme = 'dark';
            startPairingSession();
        }

        // ── 5. LIVE TV SYNC & RENDERING ──
        async function syncContent(force = false) {
            if (!state.token) return;
            try {
                const headers = {
                    'Authorization': `Bearer ${state.token}`,
                    'Accept': 'application/json',
                };
                if (!force && state.etag) headers['If-None-Match'] = state.etag;

                const res = await fetch('/api/display/content', { headers });
                if (res.status === 401) {
                    unpairDisplay();
                    return;
                }
                const serverHeader = res.headers.get('X-Server-Time');
                if (serverHeader) {
                    const serverMs = Date.parse(serverHeader);
                    if (!Number.isNaN(serverMs)) {
                        state.skewMs = serverMs - Date.now();
                        localStorage.setItem(STORAGE.skew, String(state.skewMs));
                    }
                }
                const newEtag = res.headers.get('ETag');
                if (newEtag) {
                    state.etag = newEtag;
                    localStorage.setItem(STORAGE.etag, newEtag);
                }
                if (res.status === 200) {
                    const data = await res.json();
                    state.content = data;
                    localStorage.setItem(STORAGE.content, JSON.stringify(data));
                    if (data.qris && data.qris.enabled) {
                        loadQrisBlob();
                    } else if (state.qrisBlobUrl) {
                        URL.revokeObjectURL(state.qrisBlobUrl);
                        state.qrisBlobUrl = null;
                        state.qrisLoadedFor = null;
                    }
                }
                state.offline = false;
                renderTick();
            } catch (_) {
                state.offline = true;
                renderTick();
            }
        }

        async function loadQrisBlob() {
            const cacheKey = `${state.token}:${state.etag || 'init'}`;
            if (!state.token || state.qrisLoadedFor === cacheKey) return;
            try {
                const res = await fetch('/api/display/qris', {
                    headers: { 'Authorization': `Bearer ${state.token}` },
                });
                if (!res.ok) return;
                const blob = await res.blob();
                if (state.qrisBlobUrl) URL.revokeObjectURL(state.qrisBlobUrl);
                state.qrisBlobUrl = URL.createObjectURL(blob);
                state.qrisLoadedFor = cacheKey;
                renderTick();
            } catch (_) {}
        }

        function getWallClock(tz) {
            const offsetHrs = PrayerEngine.utcOffsetFor(tz || 'Asia/Jakarta');
            const nowUtcMs = Date.now() + state.skewMs;
            const shifted = new Date(nowUtcMs + offsetHrs * 3600000);
            return {
                y: shifted.getUTCFullYear(),
                m: shifted.getUTCMonth() + 1,
                d: shifted.getUTCDate(),
                dow: shifted.getUTCDay(), // 0=Sun .. 5=Fri
                h: shifted.getUTCHours(),
                min: shifted.getUTCMinutes(),
                sec: shifted.getUTCSeconds(),
                totalSec: shifted.getUTCHours() * 3600 + shifted.getUTCMinutes() * 60 + shifted.getUTCSeconds(),
                offsetHrs,
                utcMs: nowUtcMs,
            };
        }

        const DAYS_ID = ['Ahad', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
        const MONTHS_ID = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        const DAYS_EN = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const MONTHS_EN = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        const PRAYER_NAMES = {
            id: { fajr: 'Subuh', sunrise: 'Syuruq', dhuhr: 'Dzuhur', jumuah: 'Jumat', asr: 'Ashar', maghrib: 'Maghrib', isha: 'Isya' },
            en: { fajr: 'Fajr', sunrise: 'Sunrise', dhuhr: 'Dhuhr', jumuah: 'Jumuah', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha' },
        };

        function buildSlides(content, lang) {
            const slides = [];
            const cfg = (content.device && content.device.config) || {};
            const isEn = lang === 'en';

            if (content.friday_staff && content.friday_staff.items && content.friday_staff.items.length) {
                slides.push({
                    kicker: isEn ? 'Friday Duty Roster' : 'Papan Petugas Jumat',
                    title: isEn ? `Friday, ${content.friday_staff.date}` : `Salat Jumat (${content.friday_staff.date})`,
                    html: `<div class="staff-grid">${content.friday_staff.items.map((st) => `
                        <div class="stat-box">
                            <div class="stat-label">${esc(st.duty_type)}</div>
                            <div class="stat-val" style="font-size:clamp(16px,1.5vw,23px)">${esc(st.name)}</div>
                        </div>`).join('')}</div>`,
                });
            }

            if (cfg.show_staff !== false && content.staff_today && content.staff_today.length) {
                slides.push({
                    kicker: isEn ? "Today's Roster" : 'Petugas Hari Ini',
                    title: isEn ? 'Imam & Muadzin Schedule' : 'Jadwal Imam & Muadzin',
                    html: `<div class="staff-grid">${content.staff_today.slice(0, 6).map((st) => `
                        <div class="stat-box">
                            <div class="stat-label">${esc(st.duty_type)} ${st.prayer ? '• ' + esc(st.prayer) : ''}</div>
                            <div class="stat-val" style="font-size:clamp(16px,1.45vw,22px)">${esc(st.name)}</div>
                        </div>`).join('')}</div>`,
                });
            }

            if (content.events && content.events.length) {
                slides.push({
                    kicker: isEn ? 'Mosque Events' : 'Agenda & Kajian Masjid',
                    title: isEn ? 'Upcoming Schedule' : 'Jadwal Kegiatan Mendatang',
                    html: `<div class="info-list">${content.events.slice(0, 3).map((ev) => {
                        const meta = [ev.speaker, ev.location].filter(Boolean).join(' • ');
                        return `<div class="info-item">
                            <div class="info-item-title">${esc(ev.title)}</div>
                            <div class="info-item-meta">${esc(meta || ev.category || '')}</div>
                        </div>`;
                    }).join('')}</div>`,
                });
            }

            if (content.announcements && content.announcements.length) {
                slides.push({
                    kicker: isEn ? 'Announcements' : 'Pengumuman Jamaah',
                    title: esc(content.announcements[0].title),
                    html: `<div class="info-list">${content.announcements.slice(0, 2).map((a) => `
                        <div class="info-item">
                            <div class="info-item-title">${esc(a.title)}</div>
                            <div class="info-item-meta">${esc(a.body)}</div>
                        </div>`).join('')}</div>`,
                });
            }

            if (content.finance) {
                const f = content.finance;
                slides.push({
                    kicker: isEn ? 'Friday Cash Report' : 'Rekap Kas Jumat',
                    title: isEn ? 'Mosque Cash Transparency' : 'Transparansi Keuangan Masjid',
                    html: `<div class="staff-grid">
                        <div class="stat-box" style="grid-column:span 2">
                            <div class="stat-label">${isEn ? 'Current Cash Balance' : 'Saldo Kas Saat Ini'}</div>
                            <div class="stat-val" style="color:var(--gold)">${esc(fmtRp(f.balance))}</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-label">${isEn ? 'Weekly Income' : 'Pemasukan 7 Hari'}</div>
                            <div class="stat-val">${esc(fmtRp(f.week_in))}</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-label">${isEn ? 'Weekly Expense' : 'Pengeluaran 7 Hari'}</div>
                            <div class="stat-val">${esc(fmtRp(f.week_out))}</div>
                        </div>
                    </div>`,
                });
            }

            if (content.qris && content.qris.enabled && state.qrisBlobUrl) {
                slides.push({
                    kicker: isEn ? 'Mosque Donation' : 'Infaq & Sedekah Digital',
                    title: esc(content.qris.label || (isEn ? 'Mosque Donation QRIS' : 'QRIS Infaq Masjid')),
                    html: `<div class="qris-slide">
                        <div class="qris-frame"><img src="${state.qrisBlobUrl}" alt="QRIS Infaq Masjid"></div>
                        <div>
                            <div class="info-item-title">${isEn ? 'Scan QRIS with any e-wallet or mobile banking app' : 'Pindai QRIS lewat e-wallet atau mobile banking'}</div>
                            <div class="info-item-meta" style="margin-top:8px">${isEn ? 'Every donation directly supports mosque operations and congregation programs.' : 'Infaq Anda tercatat langsung oleh takmir untuk operasional dan kegiatan jamaah.'}</div>
                        </div>
                    </div>`,
                });
            }

            if (!slides.length) {
                slides.push({
                    kicker: isEn ? 'Congregation Reminder' : 'Informasi Jamaah',
                    title: isEn ? `Welcome to ${content.mosque.name}` : `Selamat Datang di ${content.mosque.name}`,
                    html: `<div class="info-item">
                        <div class="info-item-title">${isEn ? 'Straighten and tighten the prayer rows' : 'Luruskan dan rapatkan shaf salat berjamaah'}</div>
                        <div class="info-item-meta">${isEn ? 'Please keep your mobile phone silent inside the prayer hall.' : 'Mohon menonaktifkan atau menyenyapkan nada dering ponsel selama di dalam masjid.'}</div>
                    </div>`,
                });
            }

            return slides;
        }

        function hexLuminance(hex) {
            const m = /^#?([0-9a-f]{6})$/i.exec(hex || '');
            if (!m) return 0;
            const n = parseInt(m[1], 16);
            const ch = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); };
            return 0.2126 * ch((n >> 16) & 255) + 0.7152 * ch((n >> 8) & 255) + 0.0722 * ch(n & 255);
        }

        function applyCustomTheme(cfg) {
            const st = document.body.style;
            const valid = (h) => /^#[0-9a-f]{6}$/i.test(h || '');
            if (!cfg || !valid(cfg.custom_background)) {
                ['--bg', '--surface', '--surface-2', '--tile-active-bg'].forEach((k) => st.removeProperty(k));
                return;
            }
            st.setProperty('--bg', valid(cfg.custom_background_2) ? cfg.custom_background_2 : cfg.custom_background);
            st.setProperty('--surface', cfg.custom_background);
            st.setProperty('--surface-2', cfg.custom_background);
            st.setProperty('--tile-active-bg', cfg.custom_background);
        }

        function renderTick() {
            if (!state.token || !state.content) return;
            const c = state.content;
            const m = c.mosque || {};
            const ms = m.settings || {};
            const cfg = (c.device && c.device.config) || {};
            const lang = cfg.language === 'en' ? 'en' : 'id';
            const names = PRAYER_NAMES[lang];

            const clock = getWallClock(m.timezone);
            const lat = Number(m.latitude ?? -6.2088);
            const lng = Number(m.longitude ?? 106.8456);
            const times = PrayerEngine.computeDay(
                clock.y, clock.m, clock.d, lat, lng, clock.offsetHrs,
                m.prayer_method || 'kemenag', ms.prayer_adjustments
            );

            // Tema: auto (ikut siang/malam) / light / dark / navy / maroon / custom (warna pilihan pengurus).
            const themePref = cfg.theme || 'auto';
            const isDay = clock.totalSec >= times.sunrise * 60 && clock.totalSec < times.maghrib * 60;
            applyCustomTheme(themePref === 'custom' ? cfg : null);
            document.body.dataset.theme = themePref === 'auto'
                ? (isDay ? 'light' : 'dark')
                : themePref === 'custom'
                    ? (hexLuminance(cfg.custom_background) > 0.4 ? 'light' : 'dark')
                    : (['light', 'dark', 'navy', 'maroon'].includes(themePref) ? themePref : 'dark');
            $('tv-date-hijri').style.display = cfg.show_hijri === false ? 'none' : '';
            $('tv-clock-sec').style.display = cfg.show_seconds === false ? 'none' : '';

            // Header identity & dates
            $('tv-mosque-name').textContent = m.name || 'Masjid';
            $('tv-mosque-address').textContent = [m.address, m.city].filter(Boolean).join(' • ');
            $('tv-date-hijri').textContent = PrayerEngine.formatHijri(clock.y, clock.m, clock.d, ms.hijri_offset_days || 0, lang);
            const dayName = (lang === 'en' ? DAYS_EN : DAYS_ID)[clock.dow];
            const monthName = (lang === 'en' ? MONTHS_EN : MONTHS_ID)[clock.m - 1];
            $('tv-date-greg').textContent = `${dayName}, ${clock.d} ${monthName} ${clock.y}`;
            $('tv-offline-badge').classList.toggle('hidden', !state.offline);

            // Digital clock
            $('tv-clock-hm').textContent = `${pad2(clock.h)}:${pad2(clock.min)}`;
            $('tv-clock-sec').textContent = pad2(clock.sec);

            // Schedule phase evaluation (beforeAdhan / beforeIqamah / praying)
            const order = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
            const iqMap = ms.iqamah_minutes || {};
            const prMap = ms.praying_minutes || {};
            const isFriday = clock.dow === 5;

            let phase = 'beforeAdhan';
            let activePrayer = 'fajr';
            let isJumuah = false;
            let remainingSec = 0;
            let found = false;

            for (const key of order) {
                const adhanSec = times[key] * 60;
                const jum = isFriday && key === 'dhuhr';
                const iqMin = Number(iqMap[key] ?? (key === 'maghrib' ? 5 : 10));
                const iqSec = adhanSec + iqMin * 60;
                const prayMin = jum ? Number(prMap.jumuah ?? 45) : Number(prMap[key] ?? 15);
                const prayEndSec = iqSec + prayMin * 60;

                if (clock.totalSec < adhanSec) {
                    phase = 'beforeAdhan'; activePrayer = key; isJumuah = jum;
                    remainingSec = adhanSec - clock.totalSec; found = true; break;
                }
                if (clock.totalSec < iqSec) {
                    phase = 'beforeIqamah'; activePrayer = key; isJumuah = jum;
                    remainingSec = iqSec - clock.totalSec; found = true; break;
                }
                if (clock.totalSec < prayEndSec) {
                    phase = 'praying'; activePrayer = key; isJumuah = jum;
                    remainingSec = prayEndSec - clock.totalSec; found = true; break;
                }
            }
            if (!found) {
                // Next day Fajr
                const tomorrow = new Date(Date.UTC(clock.y, clock.m - 1, clock.d + 1));
                const nextTimes = PrayerEngine.computeDay(
                    tomorrow.getUTCFullYear(), tomorrow.getUTCMonth() + 1, tomorrow.getUTCDate(),
                    lat, lng, clock.offsetHrs, m.prayer_method || 'kemenag', ms.prayer_adjustments
                );
                phase = 'beforeAdhan';
                activePrayer = 'fajr';
                remainingSec = (86400 - clock.totalSec) + nextTimes.fajr * 60;
            }

            // Iqamah beep on entering last 3 seconds of iqamah countdown
            if (phase === 'beforeIqamah' && ms.iqamah_beep !== false && remainingSec <= 3 && remainingSec >= 1) {
                const beepKey = `${clock.y}-${clock.m}-${clock.d}-${activePrayer}-${remainingSec}`;
                if (state.lastBeepKey !== beepKey) {
                    state.lastBeepKey = beepKey;
                    playIqamahBeep();
                }
            }

            const pLabel = isJumuah ? names.jumuah : names[activePrayer];
            const phaseCard = $('tv-phase-card');
            phaseCard.classList.toggle('iqamah', phase === 'beforeIqamah');
            if (phase === 'beforeIqamah') {
                $('tv-phase-label').textContent = lang === 'en' ? `IQAMAH • ${pLabel}` : `MENUNGGU IQAMAH ${pLabel}`;
                $('tv-phase-sub').textContent = lang === 'en' ? 'Prepare rows for congregational prayer' : 'Luruskan dan rapatkan shaf salat';
            } else {
                $('tv-phase-label').textContent = lang === 'en' ? `Next Prayer: ${pLabel}` : `Menuju ${pLabel}`;
                $('tv-phase-sub').textContent = lang === 'en'
                    ? `Adhan at ${fmtMin(times[activePrayer])}`
                    : `Waktu adzan pukul ${fmtMin(times[activePrayer])}`;
            }
            $('tv-phase-countdown').textContent = fmtSec(remainingSec);

            // Prayer tiles strip
            const tiles = [
                { key: 'fajr', label: names.fajr, val: fmtMin(times.fajr) },
                { key: 'sunrise', label: names.sunrise, val: fmtMin(times.sunrise) },
                { key: 'dhuhr', label: isFriday ? names.jumuah : names.dhuhr, val: fmtMin(times.dhuhr) },
                { key: 'asr', label: names.asr, val: fmtMin(times.asr) },
                { key: 'maghrib', label: names.maghrib, val: fmtMin(times.maghrib) },
                { key: 'isha', label: names.isha, val: fmtMin(times.isha) },
            ];
            $('tv-prayer-bar').innerHTML = tiles.map((t) => `
                <div class="prayer-tile ${t.key === activePrayer ? 'active' : ''}">
                    <div class="prayer-name">${esc(t.label)}</div>
                    <div class="prayer-time">${esc(t.val)}</div>
                </div>`).join('');

            // Info slide rotation
            const slides = buildSlides(c, lang);
            const rotMs = Math.max(5, Number(cfg.rotation_seconds || 15)) * 1000;
            if (Date.now() - state.lastSlideAt >= rotMs) {
                state.slideIdx = (state.slideIdx + 1) % slides.length;
                state.lastSlideAt = Date.now();
            }
            if (state.slideIdx >= slides.length) state.slideIdx = 0;
            const cur = slides[state.slideIdx];
            $('tv-slide-kicker').textContent = cur.kicker;
            $('tv-slide-title').textContent = cur.title;
            $('tv-slide-body').innerHTML = cur.html;
            $('tv-slide-dots').innerHTML = slides.length > 1
                ? slides.map((_, idx) => `<span class="slide-dot ${idx === state.slideIdx ? 'active' : ''}"></span>`).join('')
                : '';

            // Priority Full-Screen Overlays: (1) Emergency/Duka Override, (2) Silent Prayer Screen
            const ov = c.override;
            const ovActive = ov && ov.expires_at && Date.parse(ov.expires_at) > clock.utcMs;
            const overlayEl = $('tv-overlay');

            if (ovActive) {
                overlayEl.className = `overlay ${ov.type === 'darurat' ? 'overlay-darurat' : 'overlay-duka'}`;
                $('overlay-badge').textContent = ov.type === 'darurat'
                    ? (lang === 'en' ? 'URGENT MOSQUE ANNOUNCEMENT' : 'PENGUMUMAN DARURAT MASJID')
                    : (lang === 'en' ? 'CONDOLENCE ANNOUNCEMENT' : 'INNALILLAHI WA INNA ILAIHI RAJIUN');
                $('overlay-title').textContent = ov.title || '';
                $('overlay-body').textContent = ov.body || '';
                $('overlay-foot').textContent = `${m.name || ''} • ${pad2(clock.h)}:${pad2(clock.min)}`;
            } else if (phase === 'praying' && ms.silent_prayer_screen !== false) {
                overlayEl.className = 'overlay overlay-silent';
                $('overlay-badge').textContent = isJumuah
                    ? (lang === 'en' ? 'FRIDAY SERMON & PRAYER' : 'KHUTBAH & SALAT JUMAT')
                    : (lang === 'en' ? 'PRAYER IN PROGRESS' : 'SALAT BERJAMAAH SEDANG BERLANGSUNG');
                $('overlay-title').textContent = isJumuah
                    ? (lang === 'en' ? 'Please Listen Quietly' : 'Harap Tenang Selama Khutbah & Salat')
                    : (lang === 'en' ? `${pLabel} Prayer` : `Salat ${pLabel}`);
                $('overlay-body').textContent = ms.silent_prayer_message || 'Luruskan & Rapatkan Shaf • Harap Tenangkan Ponsel';
                $('overlay-foot').textContent = `${pad2(clock.h)}:${pad2(clock.min)} • ${fmtSec(remainingSec)}`;
            } else {
                overlayEl.className = 'overlay hidden';
            }
        }

        function enterDisplayMode() {
            $('pairing-view').classList.add('hidden');
            $('display-view').classList.remove('hidden');
            $('tv-toolbar').classList.remove('hidden');
            acquireWakeLock();
            renderTick();
            syncContent(true);
            clearInterval(state.syncTimer);
            clearInterval(state.tickTimer);
            state.syncTimer = setInterval(() => syncContent(false), 60000);
            state.tickTimer = setInterval(renderTick, 1000);
        }

        // ── 6. EVENT WIRING & PWA REGISTRATION ──
        $('btn-refresh-qr').addEventListener('click', startPairingSession);
        $('btn-pair-fullscreen').addEventListener('click', toggleFullscreen);
        $('btn-fullscreen').addEventListener('click', toggleFullscreen);
        $('btn-sync').addEventListener('click', () => syncContent(true));
        $('btn-toggle-manual').addEventListener('click', () => {
            const form = $('manual-pair-form');
            form.classList.toggle('hidden');
            if (!form.classList.contains('hidden')) $('manual-code-input').focus();
        });
        $('manual-pair-form').addEventListener('submit', submitManualPair);

        $('btn-unpair').addEventListener('click', () => {
            $('unpair-modal').classList.remove('hidden');
            $('btn-unpair-cancel').focus();
        });
        $('btn-unpair-cancel').addEventListener('click', () => $('unpair-modal').classList.add('hidden'));
        $('btn-unpair-confirm').addEventListener('click', unpairDisplay);
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && !$('unpair-modal').classList.contains('hidden')) {
                $('unpair-modal').classList.add('hidden');
            }
        });
        document.addEventListener('visibilitychange', () => {
            if (document.visibilityState === 'visible' && state.token) acquireWakeLock();
        });

        // Show toolbar briefly on mouse/touch movement
        let hideBarTimer = null;
        const bumpToolbar = () => {
            if (!state.token) return;
            $('tv-toolbar').classList.add('visible');
            clearTimeout(hideBarTimer);
            hideBarTimer = setTimeout(() => $('tv-toolbar').classList.remove('visible'), 4000);
        };
        window.addEventListener('mousemove', bumpToolbar, { passive: true });
        window.addEventListener('touchstart', bumpToolbar, { passive: true });

        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/tv/sw.js', { scope: '/tv' }).catch(() => {});
        }

        // Boot
        if (state.token) {
            enterDisplayMode();
        } else {
            startPairingSession();
            setInterval(updateSessionExpiryLabel, 1000);
        }
    })();
    </script>
</body>
</html>
