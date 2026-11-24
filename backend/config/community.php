<?php

return [
    // Batas teknis Family Cloud (gratis bagi Personal, anti-abuse VPS).
    'family_member_limit' => (int) env('FAMILY_MEMBER_LIMIT', 8),
    'family_owner_limit' => (int) env('FAMILY_OWNER_LIMIT', 5),
    'family_invite_ttl_hours' => (int) env('FAMILY_INVITE_TTL_HOURS', 48),

    // Jenis layanan resmi Moeslim Services (R1 & R2 + integrasi Ramadan).
    'service_types' => [
        'tpq',
        'kegiatan',
        'aspirasi',
        'fasilitas',
        'konsultasi',
        'sosial',
        'ramadan',
    ],

    // Batas unggahan lampiran privat Services.
    'service_attachment_max_kb' => (int) env('SERVICE_ATTACHMENT_MAX_KB', 5120),
    'service_attachment_mimes' => ['pdf', 'jpg', 'jpeg', 'png', 'webp'],

    // Feature flags rollout bertahap (§12.3).
    'features' => [
        'family' => (bool) env('FEATURE_FAMILY', true),
        'ramadan_local' => (bool) env('FEATURE_RAMADAN_LOCAL', true),
        'learning_classes' => (bool) env('FEATURE_LEARNING_CLASSES', true),
        'services' => (bool) env('FEATURE_SERVICES', true),
    ],
];
