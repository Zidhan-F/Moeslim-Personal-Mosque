<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Mosque;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class EventController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate([
            'status' => ['nullable', Rule::in(['active', 'archived'])],
            'from' => ['nullable', 'date'], 'to' => ['nullable', 'date'],
        ]);

        return response()->json($mosque->events()
            ->where('status', $f['status'] ?? 'active')
            ->when($f['from'] ?? null, fn ($q, $v) => $q->where('starts_at', '>=', $v))
            ->when($f['to'] ?? null, fn ($q, $v) => $q->where('starts_at', '<=', $v.' 23:59:59'))
            ->orderBy('starts_at')->paginate(50));
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        // Nilai null eksplisit untuk kolom ber-default diabaikan (pakai default DB).
        $data = array_filter($request->validate($this->rules()), fn ($v, $k) => $v !== null || ! in_array($k, ['priority', 'show_on_display'], true), ARRAY_FILTER_USE_BOTH);

        $event = DB::transaction(function () use ($request, $mosque, $data) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($locked->activeContentCount() >= Mosque::MAX_ACTIVE_CONTENT) {
                throw new DomainRuleException('content_limit_reached', 'Batas 500 agenda & pengumuman aktif tercapai. Arsipkan konten yang sudah selesai.');
            }
            $event = new Event($data);
            $event->mosque_id = $mosque->id;
            $event->created_by = $request->user()->id;
            $event->save();

            return $event;
        });
        Audit::log($mosque, 'event.created', $event, ['title' => $event->title]);

        return response()->json(['data' => $event->fresh()], 201);
    }

    public function update(Request $request, Mosque $mosque, Event $event): JsonResponse
    {
        $data = $request->validate(array_map(fn ($r) => array_merge(['sometimes'], array_diff($r, ['required'])), $this->rules()));
        $event->update($data);
        Audit::log($mosque, 'event.updated', $event, array_keys($data));

        return response()->json(['data' => $event]);
    }

    public function toggleDisplay(Request $request, Mosque $mosque, Event $event): JsonResponse
    {
        $event->update($request->validate(['show_on_display' => ['required', 'boolean']]));
        Audit::log($mosque, 'event.display_toggled', $event, ['show_on_display' => $event->show_on_display]);

        return response()->json(['data' => $event]);
    }

    public function archive(Mosque $mosque, Event $event): JsonResponse
    {
        $event->update(['status' => 'archived']);
        Audit::log($mosque, 'event.archived', $event);

        return response()->json(['data' => $event]);
    }

    public function destroy(Mosque $mosque, Event $event): Response
    {
        $event->delete();
        Audit::log($mosque, 'event.deleted', null, ['id' => $event->id, 'title' => $event->title]);

        return response()->noContent();
    }

    private function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:5000'],
            'category' => ['required', Rule::in(Event::CATEGORIES)],
            'location' => ['nullable', 'string', 'max:150'],
            'speaker' => ['nullable', 'string', 'max:150'],
            'starts_at' => ['required', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'visibility' => ['required', Rule::in(['public', 'internal'])],
            'show_on_display' => ['nullable', 'boolean'],
        ];
    }
}
