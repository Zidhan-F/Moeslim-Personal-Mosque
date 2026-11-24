<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/svg+xml" href="/favicon.svg?v=2">
    <link rel="icon" type="image/png" href="/moeslim-icon.png?v=2">
    <link rel="shortcut icon" href="/favicon.ico?v=2">
    <title>{{ $mosque->name }} | Profil Masjid Moeslim</title>
    <style>
        :root {
            --emerald: #0A6B4F;
            --emerald-dark: #074B37;
            --gold: #C99A3B;
            --cream: #FBF9F4;
            --ink: #16231F;
            --muted: #4E5E58;
            --border: #DFDDD4;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: var(--cream);
            color: var(--ink);
            line-height: 1.55;
        }
        .hero {
            background: linear-gradient(135deg, var(--emerald-dark), var(--emerald));
            color: #fff;
            padding: 36px 20px 32px;
        }
        .wrap { max-width: 820px; margin: 0 auto; }
        .overline {
            color: var(--gold);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1.4px;
            text-transform: uppercase;
        }
        h1 { margin: 6px 0 8px; font-size: 28px; line-height: 1.2; }
        .sub { margin: 0; color: rgba(255,255,255,.9); font-size: 15px; }
        .pills { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 14px; }
        .pill {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 12.5px;
            font-weight: 600;
            background: rgba(255,255,255,.15);
            color: #fff;
            text-decoration: none;
        }
        .pill-gold { background: var(--gold); color: #16231F; }
        main { padding: 20px 16px 40px; }
        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 18px 20px;
            margin-bottom: 16px;
        }
        .card h2 {
            margin: 0 0 12px;
            font-size: 17px;
            color: var(--emerald-dark);
        }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 10px; }
        .stat {
            background: var(--cream);
            border-radius: 12px;
            padding: 12px 14px;
        }
        .stat-label { font-size: 12px; color: var(--muted); }
        .stat-val { font-size: 18px; font-weight: 800; color: var(--emerald-dark); margin-top: 2px; }
        .item { padding: 10px 0; border-top: 1px solid #EFECE3; }
        .item:first-of-type { border-top: 0; padding-top: 0; }
        .item-title { font-weight: 700; font-size: 15px; }
        .item-meta { font-size: 13px; color: var(--muted); }
        .qris-box { text-align: center; }
        .qris-box img { max-width: 220px; border-radius: 12px; border: 1px solid var(--border); padding: 8px; background: #fff; }
        footer { text-align: center; color: var(--muted); font-size: 12.5px; padding: 16px; }
    </style>
</head>
<body>
    <header class="hero">
        <div class="wrap">
            <div class="overline">Profil Resmi Masjid</div>
            <h1>{{ $mosque->name }}</h1>
            <p class="sub">
                {{ collect([$mosque->address, $mosque->city, $mosque->province])->filter()->implode(', ') }}
            </p>
            <div class="pills">
                @if($mosque->latitude && $mosque->longitude)
                    <a class="pill pill-gold" target="_blank" rel="noopener" href="https://maps.google.com/?q={{ $mosque->latitude }},{{ $mosque->longitude }}">Buka Peta Lokasi</a>
                @endif
                @foreach((array) ($mosque->facilities ?? []) as $fac)
                    <span class="pill">{{ $fac }}</span>
                @endforeach
            </div>
        </div>
    </header>

    <main class="wrap">
        @if(!empty($fridayStaff['items']))
            <section class="card">
                <h2>Petugas Jumat ({{ $fridayStaff['date'] }})</h2>
                <div class="grid">
                    @foreach($fridayStaff['items'] as $st)
                        <div class="stat">
                            <div class="stat-label">{{ ucfirst($st['duty_type']) }}</div>
                            <div class="stat-val" style="font-size:15px">{{ $st['name'] }}</div>
                        </div>
                    @endforeach
                </div>
            </section>
        @endif

        @if($publicFinance)
            <section class="card">
                <h2>Transparansi Kas Jumat ({{ $publicFinance['from'] }} s.d. {{ $publicFinance['to'] }})</h2>
                <div class="grid">
                    <div class="stat">
                        <div class="stat-label">Saldo Kas Masjid</div>
                        <div class="stat-val">Rp{{ number_format($publicFinance['closing_balance'], 0, ',', '.') }}</div>
                    </div>
                    <div class="stat">
                        <div class="stat-label">Pemasukan Pekan Ini</div>
                        <div class="stat-val">+Rp{{ number_format($publicFinance['total_in'], 0, ',', '.') }}</div>
                    </div>
                    <div class="stat">
                        <div class="stat-label">Pengeluaran Pekan Ini</div>
                        <div class="stat-val" style="color:#B3261E">-Rp{{ number_format($publicFinance['total_out'], 0, ',', '.') }}</div>
                    </div>
                </div>
            </section>
        @endif

        @if($qrisUrl)
            <section class="card qris-box">
                <h2>{{ $qrisLabel ?: 'Infaq QRIS Masjid' }}</h2>
                <img src="{{ $qrisUrl }}" alt="QRIS {{ $mosque->name }}">
                <p class="item-meta">Pindai melalui aplikasi dompet digital atau perbankan syariah Anda.</p>
            </section>
        @endif

        <section class="card">
            <h2>Agenda &amp; Kajian Terdekat</h2>
            @forelse($events as $ev)
                <div class="item">
                    <div class="item-title">{{ $ev->title }}</div>
                    <div class="item-meta">
                        {{ $ev->starts_at?->timezone($mosque->timezone)->format('d M Y, H:i') }}
                        @if($ev->location) &bull; {{ $ev->location }} @endif
                        @if($ev->speaker) &bull; {{ $ev->speaker }} @endif
                    </div>
                </div>
            @empty
                <p class="item-meta">Belum ada agenda publik terjadwal.</p>
            @endforelse
        </section>

        @if($announcements->isNotEmpty())
            <section class="card">
                <h2>Pengumuman Masjid</h2>
                @foreach($announcements as $ann)
                    <div class="item">
                        <div class="item-title">{{ $ann->title }}</div>
                        <div class="item-meta">{{ $ann->body }}</div>
                    </div>
                @endforeach
            </section>
        @endif
    </main>

    <footer>
        Halaman informasi publik resmi {{ $mosque->name }} &bull; Didukung oleh Moeslim Mosque.
    </footer>
</body>
</html>
