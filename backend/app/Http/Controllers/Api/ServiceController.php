<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Models\ServiceDefinition;
use App\Models\ServiceRequest;
use App\Models\ServiceRequestAttachment;
use App\Models\ServiceRequestHistory;
use App\Support\Audit;
use App\Support\Permissions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Moeslim Services (dual-side):
 * - Mosque: konfigurasi katalog layanan, form dinamis terbatas, kotak masuk permohonan, state machine + audit log.
 * - Personal: lihat katalog layanan aktif, ajukan permohonan (idempotency key), lacak status, revisi, batal, lampiran privat.
 */
class ServiceController extends Controller
{
    // ── PUBLIC & PERSONAL SIDE ──────────────────────────────────────────────

    public function publicCatalog(string $slug): JsonResponse
    {
        $mosque = Mosque::where('slug', $slug)->firstOrFail();
        $defs = ServiceDefinition::where('mosque_id', $mosque->id)
            ->where('active', true)
            ->withCount([
                'requests as active_requests_count' => fn ($q) => $q->whereNotIn('status', ['cancelled', 'rejected']),
            ])
            ->orderBy('title')
            ->get();

        return response()->json([
            'mosque' => ['id' => $mosque->id, 'slug' => $mosque->slug, 'name' => $mosque->name, 'city' => $mosque->city],
            'data' => $defs->map(fn (ServiceDefinition $d) => [
                'id' => $d->id,
                'title' => $d->title,
                'type' => $d->type,
                'description' => $d->description,
                'privacy_notice' => $d->privacy_notice,
                'fields' => $d->fields ?? [],
                'form_version' => $d->form_version,
                'capacity' => $d->capacity,
                'remaining_capacity' => $d->capacity !== null ? max(0, $d->capacity - (int) $d->active_requests_count) : null,
                'closes_at' => $d->closes_at?->toIso8601String(),
                'retention_days' => $d->retention_days,
            ])->values(),
        ]);
    }

    public function submit(Request $request, string $slug): JsonResponse
    {
        $mosque = Mosque::where('slug', $slug)->firstOrFail();
        $idempotencyKey = trim((string) ($request->header('Idempotency-Key') ?: $request->input('idempotency_key', '')));
        if ($idempotencyKey === '' || strlen($idempotencyKey) > 100) {
            throw ValidationException::withMessages(['idempotency_key' => 'Idempotency-Key wajib disertakan (maks. 100 karakter).']);
        }

        $data = $request->validate([
            'service_definition_id' => ['required', 'uuid'],
            'answers' => ['required', 'array'],
        ]);

        [$serviceRequest, $created] = DB::transaction(function () use ($request, $mosque, $data, $idempotencyKey) {
            $def = ServiceDefinition::where('id', $data['service_definition_id'])
                ->where('mosque_id', $mosque->id)
                ->lockForUpdate()
                ->first();
            abort_unless($def && $def->active, 404, 'Layanan tidak tersedia atau belum diaktifkan.');

            // Idempotency check (§8.7 SVC-AC03)
            $existing = ServiceRequest::where('user_id', $request->user()->id)
                ->where('idempotency_key', $idempotencyKey)
                ->first();
            if ($existing) {
                return [$existing->load('history', 'definition:id,mosque_id,title,type'), false];
            }

            if ($def->closes_at && $def->closes_at->isPast()) {
                throw new DomainRuleException('service_closed', 'Periode layanan ini sudah ditutup.');
            }

            if ($def->capacity !== null) {
                $used = ServiceRequest::where('service_definition_id', $def->id)
                    ->whereNotIn('status', ['cancelled', 'rejected'])
                    ->count();
                if ($used >= $def->capacity) {
                    throw new DomainRuleException('service_full', 'Kuota layanan sudah penuh.');
                }
            }

            $sanitizedAnswers = $this->validateAnswers($def, $data['answers']);
            $refNo = 'SVC-'.now()->format('ym').'-'.strtoupper(Str::random(6));

            $req = ServiceRequest::create([
                'service_definition_id' => $def->id,
                'user_id' => $request->user()->id,
                'idempotency_key' => $idempotencyKey,
                'reference_no' => $refNo,
                'form_version' => $def->form_version,
                'answers' => $sanitizedAnswers,
                'status' => 'submitted',
            ]);

            ServiceRequestHistory::create([
                'service_request_id' => $req->id,
                'actor_id' => $request->user()->id,
                'status' => 'submitted',
                'message' => 'Permohonan dikirim oleh pemohon.',
                'created_at' => now(),
            ]);

            return [$req->load('history', 'definition:id,mosque_id,title,type'), true];
        });

        return response()->json(['data' => $serviceRequest], $created ? 201 : 200);
    }

    public function myRequests(Request $request): JsonResponse
    {
        $rows = ServiceRequest::with([
            'definition:id,mosque_id,title,type,fields,privacy_notice',
            'definition.mosque:id,slug,name,city',
            'history',
            'attachments:id,service_request_id,original_name,mime_type,size_bytes,created_at',
        ])
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        return response()->json(['data' => $rows]);
    }

    public function myShow(Request $request, string $serviceRequest): JsonResponse
    {
        $req = ServiceRequest::with([
            'definition:id,mosque_id,title,type,fields,privacy_notice',
            'definition.mosque:id,slug,name,city',
            'history',
            'attachments:id,service_request_id,original_name,mime_type,size_bytes,created_at',
        ])->where('id', $serviceRequest)->where('user_id', $request->user()->id)->first();
        abort_unless($req, 404);

        return response()->json(['data' => $req]);
    }

    public function resubmit(Request $request, string $serviceRequest): JsonResponse
    {
        $data = $request->validate([
            'answers' => ['required', 'array'],
            'message' => ['nullable', 'string', 'max:500'],
        ]);

        $updated = DB::transaction(function () use ($request, $serviceRequest, $data) {
            $req = ServiceRequest::where('id', $serviceRequest)
                ->where('user_id', $request->user()->id)
                ->lockForUpdate()
                ->first();
            abort_unless($req, 404);

            if ($req->status !== 'need_revision') {
                throw new DomainRuleException('invalid_status', 'Hanya permohonan berstatus perlu revisi yang dapat dikirim ulang.');
            }
            $def = $req->definition()->firstOrFail();
            $answers = $this->validateAnswers($def, $data['answers']);

            $req->update([
                'answers' => $answers,
                'status' => 'resubmitted',
            ]);
            ServiceRequestHistory::create([
                'service_request_id' => $req->id,
                'actor_id' => $request->user()->id,
                'status' => 'resubmitted',
                'message' => $data['message'] ?? 'Perbaikan data dikirim ulang oleh pemohon.',
                'created_at' => now(),
            ]);

            return $req->fresh(['history', 'definition:id,mosque_id,title,type']);
        });

        return response()->json(['data' => $updated]);
    }

    public function cancelByApplicant(Request $request, string $serviceRequest): JsonResponse
    {
        $data = $request->validate(['reason' => ['nullable', 'string', 'max:300']]);

        $updated = DB::transaction(function () use ($request, $serviceRequest, $data) {
            $req = ServiceRequest::where('id', $serviceRequest)
                ->where('user_id', $request->user()->id)
                ->lockForUpdate()
                ->first();
            abort_unless($req, 404);

            if (! in_array($req->status, ServiceRequest::APPLICANT_CANCELLABLE, true)) {
                throw new DomainRuleException('cannot_cancel', 'Permohonan pada tahap ini tidak dapat dibatalkan sendiri.');
            }

            $req->update(['status' => 'cancelled']);
            ServiceRequestHistory::create([
                'service_request_id' => $req->id,
                'actor_id' => $request->user()->id,
                'status' => 'cancelled',
                'message' => $data['reason'] ?? 'Dibatalkan oleh pemohon.',
                'created_at' => now(),
            ]);

            return $req->fresh('history');
        });

        return response()->json(['data' => $updated]);
    }

    public function uploadAttachment(Request $request, string $serviceRequest): JsonResponse
    {
        $req = ServiceRequest::with('definition')->where('id', $serviceRequest)->where('user_id', $request->user()->id)->first();
        abort_unless($req, 404);
        if (in_array($req->status, ['rejected', 'cancelled', 'completed', 'closed'], true)) {
            throw new DomainRuleException('request_closed', 'Tidak dapat mengunggah lampiran pada permohonan yang sudah ditutup.');
        }

        $maxKb = (int) config('community.service_attachment_max_kb', 5120);
        $mimes = implode(',', (array) config('community.service_attachment_mimes', ['pdf', 'jpg', 'jpeg', 'png', 'webp']));
        $request->validate(['file' => ['required', 'file', "max:{$maxKb}", "mimes:{$mimes}"]]);

        $file = $request->file('file');
        $disk = (string) config('filesystems.attachments_disk', 'local');
        $mosqueId = $req->definition->mosque_id;
        $ext = $file->extension() ?: 'bin';
        $path = Storage::disk($disk)->putFileAs("private/services/{$mosqueId}/{$req->id}", $file, Str::ulid().'.'.$ext);

        $attachment = ServiceRequestAttachment::create([
            'service_request_id' => $req->id,
            'uploaded_by' => $request->user()->id,
            'disk' => $disk,
            'path' => $path,
            'original_name' => Str::limit($file->getClientOriginalName(), 180, ''),
            'mime_type' => (string) ($file->getClientMimeType() ?: 'application/octet-stream'),
            'size_bytes' => (int) $file->getSize(),
            'expires_at' => now()->addDays((int) $req->definition->retention_days),
        ]);

        return response()->json(['data' => $attachment], 201);
    }

    public function downloadAttachment(Request $request, string $attachmentId)
    {
        $att = ServiceRequestAttachment::with('request.definition.mosque')->find($attachmentId);
        abort_unless($att && $att->request && $att->request->definition, 404);

        $user = $request->user();
        $isOwner = $att->request->user_id === $user->id;
        $isAuthorizedStaff = false;
        if (! $isOwner) {
            $mosque = $att->request->definition->mosque;
            $member = $mosque->members()->where('user_id', $user->id)->where('status', 'active')->first();
            $isAuthorizedStaff = $member !== null && Permissions::allows($member, 'services.view', $mosque);
        }
        abort_unless($isOwner || $isAuthorizedStaff, 404);

        $disk = Storage::disk($att->disk ?: config('filesystems.attachments_disk', 'local'));
        abort_unless($disk->exists($att->path), 404);

        return $disk->response($att->path, $att->original_name);
    }

    // ── MOSQUE PENGURUS SIDE (TENANT-SCOPED) ────────────────────────────────

    public function mosqueDefinitions(Mosque $mosque): JsonResponse
    {
        $defs = ServiceDefinition::where('mosque_id', $mosque->id)
            ->withCount([
                'requests as total_requests_count',
                'requests as pending_requests_count' => fn ($q) => $q->whereIn('status', ['submitted', 'under_review', 'resubmitted']),
            ])
            ->orderByDesc('active')
            ->orderBy('title')
            ->get();

        return response()->json(['data' => $defs]);
    }

    public function storeDefinition(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $this->validateDefinition($request);
        $def = new ServiceDefinition($data);
        $def->mosque_id = $mosque->id;
        $def->form_version = 1;
        $def->save();
        Audit::log($mosque, 'service.definition_created', $def, ['title' => $def->title, 'type' => $def->type]);

        return response()->json(['data' => $def->fresh()], 201);
    }

    public function updateDefinition(Request $request, Mosque $mosque, string $definitionId): JsonResponse
    {
        $def = ServiceDefinition::where('id', $definitionId)->where('mosque_id', $mosque->id)->first();
        abort_unless($def, 404);

        $data = $this->validateDefinition($request, partial: true);
        if (array_key_exists('fields', $data) && $data['fields'] !== $def->fields) {
            $data['form_version'] = $def->form_version + 1;
        }
        $def->update($data);
        Audit::log($mosque, 'service.definition_updated', $def, array_keys($data));

        return response()->json(['data' => $def->fresh()]);
    }

    public function mosqueInbox(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate([
            'status' => ['nullable', Rule::in(ServiceRequest::STATUSES)],
            'type' => ['nullable', Rule::in(config('community.service_types', []))],
            'service_definition_id' => ['nullable', 'uuid'],
        ]);

        $defIds = ServiceDefinition::where('mosque_id', $mosque->id)
            ->when($f['type'] ?? null, fn ($q, $t) => $q->where('type', $t))
            ->when($f['service_definition_id'] ?? null, fn ($q, $id) => $q->where('id', $id))
            ->pluck('id');

        $rows = ServiceRequest::with([
            'definition:id,title,type',
            'user:id,name,email',
            'history',
            'attachments:id,service_request_id,original_name,mime_type,size_bytes,created_at',
        ])
            ->whereIn('service_definition_id', $defIds)
            ->when($f['status'] ?? null, fn ($q, $s) => $q->where('status', $s))
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        return response()->json(['data' => $rows]);
    }

    public function mosqueShowRequest(Mosque $mosque, string $serviceRequestId): JsonResponse
    {
        $req = ServiceRequest::with([
            'definition',
            'user:id,name,email',
            'history',
            'attachments:id,service_request_id,original_name,mime_type,size_bytes,created_at',
        ])
            ->where('id', $serviceRequestId)
            ->whereHas('definition', fn ($q) => $q->where('mosque_id', $mosque->id))
            ->first();
        abort_unless($req, 404);

        return response()->json(['data' => $req]);
    }

    public function updateStatus(Request $request, Mosque $mosque, string $serviceRequestId): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(ServiceRequest::STATUSES)],
            'message' => ['nullable', 'string', 'max:500'],
        ]);

        $updated = DB::transaction(function () use ($request, $mosque, $serviceRequestId, $data) {
            $req = ServiceRequest::where('id', $serviceRequestId)
                ->whereHas('definition', fn ($q) => $q->where('mosque_id', $mosque->id))
                ->lockForUpdate()
                ->first();
            abort_unless($req, 404);

            $allowed = ServiceRequest::STAFF_TRANSITIONS[$req->status] ?? [];
            if (! in_array($data['status'], $allowed, true)) {
                throw new DomainRuleException(
                    'invalid_status_transition',
                    "Status tidak dapat diubah dari {$req->status} ke {$data['status']}."
                );
            }
            if (in_array($data['status'], ['need_revision', 'rejected'], true) && trim((string) ($data['message'] ?? '')) === '') {
                throw ValidationException::withMessages(['message' => 'Catatan alasan/klarifikasi wajib diisi untuk status ini.']);
            }

            $oldStatus = $req->status;
            $req->update(['status' => $data['status']]);

            ServiceRequestHistory::create([
                'service_request_id' => $req->id,
                'actor_id' => $request->user()->id,
                'status' => $data['status'],
                'message' => $data['message'] ?? null,
                'created_at' => now(),
            ]);

            Audit::log($mosque, 'service.request_status_updated', $req, [
                'reference_no' => $req->reference_no,
                'from' => $oldStatus,
                'to' => $data['status'],
            ]);

            return $req->fresh(['definition:id,title,type', 'user:id,name,email', 'history']);
        });

        return response()->json(['data' => $updated]);
    }

    public function exportCsv(Mosque $mosque, string $definitionId): StreamedResponse
    {
        $def = ServiceDefinition::where('id', $definitionId)->where('mosque_id', $mosque->id)->first();
        abort_unless($def, 404);

        $rows = ServiceRequest::with('user:id,name,email')
            ->where('service_definition_id', $def->id)
            ->orderBy('created_at')
            ->get();

        Audit::log($mosque, 'service.requests_exported', $def, ['count' => $rows->count()]);

        return response()->streamDownload(function () use ($def, $rows) {
            $out = fopen('php://output', 'w');
            $fieldKeys = array_map(fn ($f) => (string) ($f['key'] ?? ''), (array) ($def->fields ?? []));
            fputcsv($out, array_merge(['reference_no', 'status', 'applicant_name', 'submitted_at'], $fieldKeys));
            foreach ($rows as $r) {
                $ans = (array) ($r->answers ?? []);
                $values = array_map(fn ($k) => (string) ($ans[$k] ?? ''), $fieldKeys);
                fputcsv($out, array_merge([
                    $r->reference_no ?? $r->id,
                    $r->status,
                    $r->user?->name ?? '-',
                    $r->created_at?->toIso8601String() ?? '',
                ], $values));
            }
            fclose($out);
        }, 'layanan-'.Str::slug($def->title).'.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    // ── VALIDATION HELPERS ──────────────────────────────────────────────────

    private function validateDefinition(Request $request, bool $partial = false): array
    {
        $req = $partial ? 'sometimes' : 'required';

        return $request->validate([
            'title' => [$req, 'string', 'max:150'],
            'type' => [$req, Rule::in(config('community.service_types', []))],
            'description' => [$req, 'string', 'max:2000'],
            'privacy_notice' => [$req, 'string', 'max:1000'],
            'fields' => [$req, 'array', 'max:20'],
            'fields.*.key' => ['required_with:fields', 'string', 'max:50', 'regex:/^[a-z0-9_]+$/'],
            'fields.*.label' => ['required_with:fields', 'string', 'max:100'],
            'fields.*.type' => ['required_with:fields', Rule::in(ServiceDefinition::FIELD_TYPES)],
            'fields.*.required' => ['sometimes', 'boolean'],
            'fields.*.options' => ['sometimes', 'array', 'max:20'],
            'fields.*.options.*' => ['string', 'max:100'],
            'capacity' => ['nullable', 'integer', 'between:1,10000'],
            'closes_at' => ['nullable', 'date'],
            'active' => ['sometimes', 'boolean'],
            'retention_days' => ['sometimes', 'integer', 'between:7,1825'],
        ]);
    }

    /** Validasi jawaban berdasarkan skema field definisi (tanpa kode arbitrer). */
    private function validateAnswers(ServiceDefinition $def, array $answers): array
    {
        $clean = [];
        $errors = [];
        foreach ((array) ($def->fields ?? []) as $field) {
            $key = (string) ($field['key'] ?? '');
            if ($key === '') {
                continue;
            }
            $label = (string) ($field['label'] ?? $key);
            $type = (string) ($field['type'] ?? 'text');
            $required = (bool) ($field['required'] ?? false);
            $raw = $answers[$key] ?? null;
            $str = is_scalar($raw) ? trim((string) $raw) : '';

            if ($required && $str === '') {
                $errors["answers.{$key}"] = ["Kolom {$label} wajib diisi."];
                continue;
            }
            if ($str === '') {
                continue;
            }
            if (strlen($str) > 1000) {
                $errors["answers.{$key}"] = ["Kolom {$label} maksimal 1000 karakter."];
                continue;
            }
            if ($type === 'number' && ! is_numeric($str)) {
                $errors["answers.{$key}"] = ["Kolom {$label} harus berupa angka."];
                continue;
            }
            if ($type === 'select') {
                $options = array_map('strval', (array) ($field['options'] ?? []));
                if (! empty($options) && ! in_array($str, $options, true)) {
                    $errors["answers.{$key}"] = ["Pilihan pada {$label} tidak valid."];
                    continue;
                }
            }
            $clean[$key] = $str;
        }
        if (! empty($errors)) {
            throw ValidationException::withMessages($errors);
        }

        return $clean;
    }
}
