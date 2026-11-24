<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/svg+xml" href="/favicon.svg?v=2">
    <link rel="icon" type="image/png" href="/moeslim-icon.png?v=2">
    <link rel="shortcut icon" href="/favicon.ico?v=2">
    <title>Verifikasi Kuitansi {{ $receipt['receipt_no'] }} - {{ $receipt['mosque_name'] }}</title>
    <style>
        body { margin: 0; font-family: system-ui, -apple-system, sans-serif; background: #F7F7F1; color: #07372F; padding: 24px 16px; }
        .card { max-width: 520px; margin: 0 auto; background: #fff; border-radius: 20px; border: 1px solid rgba(217,171,54,.45); overflow: hidden; box-shadow: 0 8px 24px rgba(7,55,47,.06); }
        .header { background: linear-gradient(135deg, #087E65, #07372F); color: #fff; padding: 24px; text-align: center; }
        .badge { display: inline-block; padding: 6px 14px; border-radius: 999px; font-weight: 700; font-size: 13px; margin-bottom: 10px; }
        .badge-valid { background: #D9AB36; color: #07372F; }
        .badge-reversed { background: #B3261E; color: #fff; }
        .body { padding: 24px; }
        .amount { font-size: 30px; font-weight: 800; color: #087E65; margin: 6px 0 18px; }
        .row { display: flex; justify-content: space-between; gap: 12px; padding: 10px 0; border-bottom: 1px solid #eef1ef; font-size: 14px; }
        .label { color: #4B5B57; }
        .val { font-weight: 600; text-align: right; }
        .footer { padding: 16px 24px; background: #F7F7F1; font-size: 12px; color: #4B5B57; text-align: center; }
    </style>
</head>
<body>
<div class="card">
    <div class="header">
        @if($receipt['status'] === 'valid')
            <div class="badge badge-valid">Kuitansi Terverifikasi</div>
        @else
            <div class="badge badge-reversed">Transaksi Dibatalkan</div>
        @endif
        <h1 style="margin:0;font-size:22px;">{{ $receipt['mosque_name'] }}</h1>
        <div style="opacity:.85;font-size:13px;margin-top:4px;">{{ $receipt['mosque_city'] }}</div>
    </div>
    <div class="body">
        <div class="label">Nominal Donasi</div>
        <div class="amount">Rp{{ number_format($receipt['amount'], 0, ',', '.') }}</div>
        <div class="row"><span class="label">Nomor Kuitansi</span><span class="val">{{ $receipt['receipt_no'] }}</span></div>
        <div class="row"><span class="label">Donatur</span><span class="val">{{ $receipt['donor_name'] }}</span></div>
        <div class="row"><span class="label">Pos Dana</span><span class="val">{{ $receipt['fund_name'] ?? '-' }}</span></div>
        <div class="row"><span class="label">Tanggal</span><span class="val">{{ $receipt['date'] }}</span></div>
        <div class="row"><span class="label">Keterangan</span><span class="val">{{ $receipt['description'] }}</span></div>
        @if($receipt['status'] === 'reversed')
            <div class="row"><span class="label">Ref. Pembatalan</span><span class="val">{{ $receipt['reversed_reference'] }}</span></div>
        @endif
    </div>
    <div class="footer">
        Diverifikasi secara resmi melalui ledger Moeslim Mosque.
    </div>
</div>
</body>
</html>
