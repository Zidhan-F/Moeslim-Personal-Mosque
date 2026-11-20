<?php

namespace App\Services;

use App\Models\Mosque;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MosqueRegistrar
{
    /** @var list<callable(Mosque): void> Hook untuk modul lain (mis. dana & akun kas default). */
    private static array $hooks = [];

    public static function afterRegistered(callable $hook): void
    {
        self::$hooks[] = $hook;
    }

    /** @return array{0: Mosque, 1: bool} masjid dan apakah dicurigai duplikat */
    public function register(User $owner, array $data): array
    {
        return DB::transaction(function () use ($owner, $data) {
            $duplicate = $this->looksDuplicate($data);

            $mosque = new Mosque($data + ['settings' => []]);
            $mosque->slug = $this->uniqueSlug($data['name']);
            $mosque->created_by = $owner->id;
            $mosque->needs_review = $duplicate;
            $mosque->save();

            $mosque->members()->create([
                'user_id' => $owner->id,
                'role' => 'admin',
                'status' => 'active',
                'is_owner' => true,
                'activated_at' => now(),
            ]);

            $mosque->subscription()->create([
                'provider' => 'manual',
                'state' => 'trialing',
                'trial_ends_at' => now()->addDays(Subscription::TRIAL_DAYS),
            ]);

            foreach (self::$hooks as $hook) {
                $hook($mosque);
            }

            return [$mosque, $duplicate];
        });
    }

    private function uniqueSlug(string $name): string
    {
        $base = Str::slug($name) ?: 'masjid';
        $slug = $base;
        for ($i = 2; Mosque::where('slug', $slug)->exists(); $i++) {
            $slug = "{$base}-{$i}";
        }

        return $slug;
    }

    public static function normalizeName(string $name): string
    {
        $n = Str::lower(Str::ascii($name));
        $n = preg_replace('/\b(masjid|mesjid|musholla|mushola|musala|langgar|surau|jami|raya|agung)\b/', ' ', $n);

        return preg_replace('/[^a-z0-9]/', '', $n);
    }

    /** Nama mirip di kota yang sama, atau koordinat dalam ~100 m. */
    private function looksDuplicate(array $data): bool
    {
        $norm = self::normalizeName($data['name']);
        $sameCity = Mosque::whereRaw('lower(city) = ?', [Str::lower($data['city'])])->get(['name']);
        foreach ($sameCity as $m) {
            $other = self::normalizeName($m->name);
            if ($norm !== '' && levenshtein($norm, $other) <= 2) {
                return true;
            }
        }
        $d = 0.001; // ~110 m
        return Mosque::whereBetween('latitude', [$data['latitude'] - $d, $data['latitude'] + $d])
            ->whereBetween('longitude', [$data['longitude'] - $d, $data['longitude'] + $d])
            ->exists();
    }
}
