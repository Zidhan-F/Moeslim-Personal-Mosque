<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QurbanAnimal extends Model
{
    public const SPECIES = ['sapi', 'kambing', 'domba', 'kerbau', 'unta'];

    public const SLAUGHTER_STATUSES = ['registered', 'slaughtered', 'skinned', 'packaged', 'distributed'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'hijri_year' => 'integer',
            'capacity' => 'integer',
            'weight_kg' => 'float',
            'price_idr' => 'integer',
            'meat_packs_count' => 'integer',
            'slaughtered_at' => 'datetime',
        ];
    }

    public static function defaultCapacity(string $species): int
    {
        return in_array($species, ['sapi', 'kerbau', 'unta'], true) ? 7 : 1;
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function participants(): HasMany
    {
        return $this->hasMany(QurbanParticipant::class, 'animal_id')->orderBy('id');
    }
}
