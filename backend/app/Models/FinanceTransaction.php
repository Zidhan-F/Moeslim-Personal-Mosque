<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use LogicException;

/** Transaksi keuangan immutable. Koreksi dilakukan dengan entri pembalik. */
class FinanceTransaction extends Model
{
    public const FLOWS = ['in', 'out', 'transfer'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['amount' => 'integer', 'date' => 'date:Y-m-d'];
    }

    protected static function booted(): void
    {
        static::updating(fn () => throw new LogicException('Transaksi keuangan tidak dapat diubah.'));
        static::deleting(fn () => throw new LogicException('Transaksi keuangan tidak dapat dihapus.'));
    }

    public function fund(): BelongsTo
    {
        return $this->belongsTo(Fund::class);
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(CashAccount::class, 'cash_account_id');
    }

    public function toAccount(): BelongsTo
    {
        return $this->belongsTo(CashAccount::class, 'to_cash_account_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(FinanceCategory::class);
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(FinanceAttachment::class, 'transaction_id');
    }

    public function reversedBy(): HasOne
    {
        return $this->hasOne(self::class, 'reversal_of_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
