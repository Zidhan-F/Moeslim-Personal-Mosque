<?php

/*
| Matriks izin awal (Blueprint §08). Admin memiliki semua izin.
| `finance.view` & `finance.export` untuk pengurus hanya aktif bila
| settings.pengurus_can_view_finance = true (lihat App\Support\Permissions).
*/

return [
    'admin' => ['*'],
    'bendahara' => [
        'dashboard.view', 'members.view',
        'finance.view', 'finance.write', 'finance.export',
        'events.view', 'staff.view', 'inventory.view',
        'audit.view',
    ],
    'pengurus' => [
        'dashboard.view', 'members.view',
        'events.view', 'events.write',
        'staff.view', 'staff.write',
        'inventory.view', 'inventory.write',
        'display.view',
        'audit.view',
    ],
    'operator' => [
        'dashboard.view', 'members.view',
        'events.view', 'events.display',
        'staff.view',
        'display.view', 'display.manage',
    ],

    // Prefix aksi audit yang boleh dilihat role non-admin ("Terbatas").
    'audit_scopes' => [
        'bendahara' => ['finance.'],
        'pengurus' => ['event.', 'announcement.', 'staff.', 'inventory.'],
    ],
];
