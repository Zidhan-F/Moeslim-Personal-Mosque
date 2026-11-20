<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\Mosque;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class AnnouncementController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $status = $request->validate(['status' => ['nullable', Rule::in(['active', 'archived'])]])['status'] ?? 'active';

        return response()->json($mosque->announcements()->where('status', $status)
            ->orderByDesc('priority')->orderByDesc('id')->paginate(50));
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate($this->rules());
        $ann = DB::transaction(function () use ($request, $mosque, $data) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($locked->activeContentCount() >= Mosque::MAX_ACTIVE_CONTENT) {
                throw new DomainRuleException('content_limit_reached', 'Batas 500 agenda & pengumuman aktif tercapai. Arsipkan konten yang sudah selesai.');
            }
            $ann = new Announcement($data);
            $ann->mosque_id = $mosque->id;
            $ann->created_by = $request->user()->id;
            $ann->save();

            return $ann;
        });
        Audit::log($mosque, 'announcement.created', $ann, ['title' => $ann->title]);

        return response()->json(['data' => $ann->fresh()], 201);
    }

    public function update(Request $request, Mosque $mosque, Announcement $announcement): JsonResponse
    {
        $data = $request->validate(array_map(fn ($r) => array_merge(['sometimes'], array_diff($r, ['required'])), $this->rules()));
        $announcement->update($data);
        Audit::log($mosque, 'announcement.updated', $announcement, array_keys($data));

        return response()->json(['data' => $announcement]);
    }

    public function toggleDisplay(Request $request, Mosque $mosque, Announcement $announcement): JsonResponse
    {
        $announcement->update($request->validate(['show_on_display' => ['required', 'boolean']]));
        Audit::log($mosque, 'announcement.display_toggled', $announcement, ['show_on_display' => $announcement->show_on_display]);

        return response()->json(['data' => $announcement]);
    }

    public function archive(Mosque $mosque, Announcement $announcement): JsonResponse
    {
        $announcement->update(['status' => 'archived']);
        Audit::log($mosque, 'announcement.archived', $announcement);

        return response()->json(['data' => $announcement]);
    }

    public function destroy(Mosque $mosque, Announcement $announcement): Response
    {
        $announcement->delete();
        Audit::log($mosque, 'announcement.deleted', null, ['id' => $announcement->id]);

        return response()->noContent();
    }

    private function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:150'],
            'body' => ['required', 'string', 'max:3000'],
            'visibility' => ['required', Rule::in(['public', 'internal'])],
            'priority' => ['nullable', 'integer', 'between:1,5'],
            'publish_at' => ['nullable', 'date'],
            'expires_at' => ['nullable', 'date', 'after:publish_at'],
            'show_on_display' => ['nullable', 'boolean'],
        ];
    }
}
