<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\Mosque;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

/**
 * Ramadan Local & Kelas Masjid (Learning Path):
 * - Publikasi & kuota dikelola Mosque (`events` dengan `publication_status`, `hijri_year`, `learning_path`, `capacity`).
 * - Pendaftaran jamaah memakai kunci atomik `lockForUpdate()` untuk mencegah double-booking (RAM-AC04).
 */
class EventRegistrationController extends Controller
{
    public function publicRamadan(Request $request, string $slug): JsonResponse
    {
        $mosque = Mosque::where('slug', $slug)->firstOrFail();
        $f = $request->validate(['hijri_year' => ['nullable', 'integer', 'between:1400,1600']]);

        $rows = $mosque->events()
            ->where('status', 'active')
            ->where('visibility', 'public')
            ->where('category', 'ramadan')
            ->where('publication_status', '!=', 'draft')
            ->when($f['hijri_year'] ?? null, fn ($q, $y) => $q->where('hijri_year', $y))
            ->withCount([
                'registrations as confirmed_count' => fn ($q) => $q->where('status', 'confirmed'),
                'registrations as waitlisted_count' => fn ($q) => $q->where('status', 'waitlisted'),
            ])
            ->orderBy('starts_at')
            ->limit(100)
            ->get();

        return response()->json([
            'mosque' => ['id' => $mosque->id, 'slug' => $mosque->slug, 'name' => $mosque->name, 'timezone' => $mosque->timezone],
            'synced_at' => now()->toIso8601String(),
            'data' => $rows->map(fn (Event $e) => $this->serializePublicEvent($e))->values(),
        ]);
    }

    public function publicClasses(Request $request, string $slug): JsonResponse
    {
        $mosque = Mosque::where('slug', $slug)->firstOrFail();
        $f = $request->validate(['learning_path' => ['nullable', 'string', 'max:80']]);

        $rows = $mosque->events()
            ->where('status', 'active')
            ->where('visibility', 'public')
            ->where('publication_status', '!=', 'draft')
            ->where(function ($q) {
                $q->where('category', 'pendidikan')->orWhereNotNull('learning_path');
            })
            ->when($f['learning_path'] ?? null, fn ($q, $p) => $q->where('learning_path', $p))
            ->withCount([
                'registrations as confirmed_count' => fn ($q) => $q->where('status', 'confirmed'),
                'registrations as waitlisted_count' => fn ($q) => $q->where('status', 'waitlisted'),
            ])
            ->orderBy('starts_at')
            ->limit(100)
            ->get();

        return response()->json([
            'mosque' => ['id' => $mosque->id, 'slug' => $mosque->slug, 'name' => $mosque->name, 'timezone' => $mosque->timezone],
            'synced_at' => now()->toIso8601String(),
            'data' => $rows->map(fn (Event $e) => $this->serializePublicEvent($e))->values(),
        ]);
    }

    public function register(Request $request, Event $event): JsonResponse
    {
        $data = $request->validate([
            'participant_name' => ['nullable', 'string', 'max:120'],
            'contact_phone' => ['nullable', 'string', 'max:40'],
            'notes' => ['nullable', 'string', 'max:300'],
        ]);

        $reg = DB::transaction(function () use ($request, $event, $data) {
            $locked = Event::whereKey($event->id)->lockForUpdate()->firstOrFail();
            abort_unless(
                $locked->status === 'active'
                    && $locked->visibility === 'public'
                    && in_array($locked->publication_status, ['published', 'updated'], true),
                404,
                'Kegiatan tidak tersedia untuk pendaftaran.'
            );
            if (! $locked->registration_enabled) {
                throw new DomainRuleException('registration_disabled', 'Pendaftaran tidak dibuka untuk kegiatan ini.');
            }
            if ($locked->registration_closes_at && $locked->registration_closes_at->isPast()) {
                throw new DomainRuleException('registration_closed', 'Batas waktu pendaftaran telah berakhir.');
            }

            $existing = EventRegistration::where('event_id', $locked->id)
                ->where('user_id', $request->user()->id)
                ->lockForUpdate()
                ->first();
            if ($existing && $existing->status !== 'cancelled') {
                return $existing;
            }

            $confirmedCount = EventRegistration::where('event_id', $locked->id)
                ->where('status', 'confirmed')
                ->count();

            $targetStatus = 'confirmed';
            if ($locked->capacity !== null && $confirmedCount >= $locked->capacity) {
                if ($locked->waitlist_enabled) {
                    $targetStatus = 'waitlisted';
                } else {
                    throw new DomainRuleException('event_full', 'Kuota kegiatan sudah penuh.');
                }
            }

            if ($existing) {
                $existing->update([
                    'status' => $targetStatus,
                    'participant_name' => $data['participant_name'] ?? $request->user()->name,
                    'contact_phone' => $data['contact_phone'] ?? null,
                    'notes' => $data['notes'] ?? null,
                ]);

                return $existing->fresh();
            }

            return EventRegistration::create([
                'event_id' => $locked->id,
                'user_id' => $request->user()->id,
                'status' => $targetStatus,
                'participant_name' => $data['participant_name'] ?? $request->user()->name,
                'contact_phone' => $data['contact_phone'] ?? null,
                'notes' => $data['notes'] ?? null,
            ]);
        });

        return response()->json(['data' => $reg], 201);
    }

    public function cancel(Request $request, Event $event): JsonResponse
    {
        $reg = DB::transaction(function () use ($request, $event) {
            Event::whereKey($event->id)->lockForUpdate()->firstOrFail();
            $existing = EventRegistration::where('event_id', $event->id)
                ->where('user_id', $request->user()->id)
                ->lockForUpdate()
                ->first();
            abort_unless($existing, 404);

            $wasConfirmed = $existing->status === 'confirmed';
            $existing->update(['status' => 'cancelled']);

            if ($wasConfirmed) {
                $nextWaitlisted = EventRegistration::where('event_id', $event->id)
                    ->where('status', 'waitlisted')
                    ->orderBy('created_at')
                    ->lockForUpdate()
                    ->first();
                if ($nextWaitlisted) {
                    $nextWaitlisted->update(['status' => 'confirmed']);
                }
            }

            return $existing->fresh();
        });

        return response()->json(['data' => $reg]);
    }

    public function myRegistrations(Request $request): JsonResponse
    {
        $rows = EventRegistration::with(['event:id,mosque_id,title,category,location,speaker,starts_at,ends_at,publication_status,hijri_year,learning_path', 'event.mosque:id,slug,name,city'])
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        return response()->json(['data' => $rows]);
    }

    public function mosqueIndex(Mosque $mosque, Event $event): JsonResponse
    {
        $rows = $event->registrations()
            ->with('user:id,name,email')
            ->orderBy('created_at')
            ->get();

        return response()->json([
            'event' => $this->serializePublicEvent($event->loadCount([
                'registrations as confirmed_count' => fn ($q) => $q->where('status', 'confirmed'),
                'registrations as waitlisted_count' => fn ($q) => $q->where('status', 'waitlisted'),
            ])),
            'data' => $rows,
        ]);
    }

    public function mosqueUpdateStatus(Request $request, Mosque $mosque, Event $event, EventRegistration $registration): JsonResponse
    {
        abort_unless($registration->event_id === $event->id, 404);
        $data = $request->validate([
            'status' => ['required', Rule::in(EventRegistration::STATUSES)],
        ]);
        $registration->update(['status' => $data['status']]);
        Audit::log($mosque, 'event.registration_updated', $event, [
            'registration_id' => $registration->id,
            'status' => $data['status'],
        ]);

        return response()->json(['data' => $registration->fresh()]);
    }

    private function serializePublicEvent(Event $e): array
    {
        $confirmed = (int) ($e->confirmed_count ?? 0);
        $waitlisted = (int) ($e->waitlisted_count ?? 0);

        return [
            'id' => $e->id,
            'title' => $e->title,
            'description' => $e->description,
            'category' => $e->category,
            'location' => $e->location,
            'speaker' => $e->speaker,
            'starts_at' => $e->starts_at?->toIso8601String(),
            'ends_at' => $e->ends_at?->toIso8601String(),
            'publication_status' => $e->publication_status ?? 'published',
            'hijri_year' => $e->hijri_year,
            'learning_path' => $e->learning_path,
            'registration_enabled' => (bool) $e->registration_enabled,
            'waitlist_enabled' => (bool) $e->waitlist_enabled,
            'capacity' => $e->capacity,
            'confirmed_count' => $confirmed,
            'waitlisted_count' => $waitlisted,
            'remaining_seats' => $e->capacity !== null ? max(0, $e->capacity - $confirmed) : null,
            'registration_closes_at' => $e->registration_closes_at?->toIso8601String(),
            'version' => (int) ($e->version ?? 1),
            'updated_at' => $e->updated_at?->toIso8601String(),
        ];
    }
}
