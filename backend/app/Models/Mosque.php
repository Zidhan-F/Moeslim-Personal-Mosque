<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Mosque extends Model
{
    use HasUlids;

    /** Batas penggunaan wajar (FUP) paket tunggal. */
    public const MAX_ACTIVE_MEMBERS = 5;
    public const STORAGE_QUOTA_BYTES = 1024 * 1024 * 1024;
    public const MAX_DISPLAYS = 5;
    public const MONTHLY_TRANSACTION_SOFT_LIMIT = 10000;
    public const MAX_ACTIVE_CONTENT = 500;
    public const MAX_INVENTORY_ITEMS = 5000;

    public const DEFAULT_SETTINGS = [
        'pengurus_can_view_finance' => false,
        'display_show_finance' => false,
        'iqamah_minutes' => ['fajr' => 10, 'dhuhr' => 10, 'asr' => 10, 'maghrib' => 5, 'isha' => 10],
        'prayer_adjustments' => ['fajr' => 0, 'dhuhr' => 0, 'asr' => 0, 'maghrib' => 0, 'isha' => 0],
        'hijri_offset_days' => 0,
    ];

    protected $guarded = ['id', 'storage_used_bytes', 'needs_review', 'created_by'];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
            'needs_review' => 'boolean',
            'latitude' => 'float',
            'longitude' => 'float',
            'storage_used_bytes' => 'integer',
        ];
    }

    public function setting(string $key): mixed
    {
        return data_get(array_replace_recursive(self::DEFAULT_SETTINGS, $this->settings ?? []), $key);
    }

    public function members(): HasMany
    {
        return $this->hasMany(MosqueMember::class);
    }

    public function activeMembers(): HasMany
    {
        return $this->members()->where('status', 'active');
    }

    public function funds(): HasMany
    {
        return $this->hasMany(Fund::class)->orderBy('sort')->orderBy('id');
    }

    public function cashAccounts(): HasMany
    {
        return $this->hasMany(CashAccount::class)->orderBy('id');
    }

    public function financeCategories(): HasMany
    {
        return $this->hasMany(FinanceCategory::class)->orderBy('id');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(FinanceTransaction::class);
    }

    /** Lampiran transaksi (nama relasi dipakai oleh scoped route binding {attachment}). */
    public function attachments(): HasMany
    {
        return $this->hasMany(FinanceAttachment::class);
    }

    public function invitations(): HasMany
    {
        return $this->hasMany(MosqueInvitation::class);
    }

    public function events(): HasMany
    {
        return $this->hasMany(Event::class);
    }

    public function announcements(): HasMany
    {
        return $this->hasMany(Announcement::class);
    }

    public function staffAssignments(): HasMany
    {
        return $this->hasMany(StaffAssignment::class);
    }

    public function inventoryItems(): HasMany
    {
        return $this->hasMany(InventoryItem::class);
    }

    public function activeContentCount(): int
    {
        return $this->events()->where('status', 'active')->count()
            + $this->announcements()->where('status', 'active')->count();
    }

    public function displayDevices(): HasMany
    {
        return $this->hasMany(DisplayDevice::class);
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(Subscription::class);
    }
}
