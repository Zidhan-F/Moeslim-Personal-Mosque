<?php

namespace Tests\Feature\Api;

use App\Models\DirectoryEntry;
use App\Models\DirectoryReport;
use App\Models\Mosque;
use App\Services\Directory\DirectoryService;
use App\Services\Directory\OsmImporter;
use App\Support\Geohash;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DirectoryTest extends TestCase
{
    private function importFixture(?array $prune = null): array
    {
        $json = json_decode(file_get_contents(base_path('tests/fixtures/overpass_jakarta.json')), true);

        return app(OsmImporter::class)->import($json, $prune);
    }

    private function registerMosque(array $over = []): Mosque
    {
        Sanctum::actingAs($this->verifiedUser());
        $res = $this->postJson('/api/mosques', $over + [
            'name' => 'Masjid Istiqlal Jakarta',
            'city' => 'Jakarta Pusat',
            'latitude' => -6.17025,
            'longitude' => 106.83145,
            'timezone' => 'Asia/Jakarta',
        ])->assertCreated();

        return Mosque::findOrFail($res->json('data.id'));
    }

    public function test_geohash_encoding_and_cell_validation(): void
    {
        $this->assertSame('u4pruydqqvj', Geohash::encode(57.64911, 10.40744, 11));
        $this->assertSame('qqgu', substr(Geohash::encode(-6.1702, 106.8314), 0, 4));
        $this->assertTrue(Geohash::isValidCell('qqgu'));
        $this->assertFalse(Geohash::isValidCell('qqga')); // 'a' bukan base32 geohash
        $this->assertEqualsWithDelta(1112, Geohash::distanceMeters(0, 0, 0.01, 0), 2);
    }

    public function test_osm_import_filters_religion_detects_musala_and_is_idempotent(): void
    {
        $r = $this->importFixture();
        $this->assertSame(['imported' => 4, 'skipped' => 1, 'hidden' => 0], $r);

        $this->assertSame('musala', DirectoryEntry::where('source_ref', 'way/2002')->value('kind'));
        $this->assertSame('Masjid', DirectoryEntry::where('source_ref', 'node/1003')->value('name')); // tanpa nama
        $this->assertSame('Jl. Taman Wijaya Kusuma', DirectoryEntry::where('source_ref', 'node/1001')->value('address'));
        $this->assertSame(0, DirectoryEntry::where('name', 'Gereja Katedral')->count());

        $this->importFixture();
        $this->assertSame(4, DirectoryEntry::count());
    }

    public function test_prune_hides_removed_entries_but_keeps_locked_and_linked(): void
    {
        $this->importFixture();
        $gone = DirectoryEntry::create(['source' => 'osm', 'source_ref' => 'node/9', 'name' => 'Masjid Lama', 'latitude' => -6.18, 'longitude' => 106.83]);
        $locked = DirectoryEntry::create(['source' => 'osm', 'source_ref' => 'node/10', 'name' => 'Masjid Dikoreksi', 'latitude' => -6.181, 'longitude' => 106.831, 'locked' => true]);
        $this->travel(5)->seconds();

        $r = $this->importFixture([-6.3, 106.7, -6.1, 106.9]);

        $this->assertSame(1, $r['hidden']);
        $this->assertSame('hidden', $gone->fresh()->status);
        $this->assertSame('active', $locked->fresh()->status);
    }

    public function test_locked_entry_keeps_moderated_name_and_coordinates_on_reimport(): void
    {
        $this->importFixture();
        $e = DirectoryEntry::where('source_ref', 'node/1001')->first();
        $e->update(['name' => 'Masjid Istiqlal (koreksi)', 'latitude' => -6.1703, 'locked' => true]);

        $this->importFixture();

        $e->refresh();
        $this->assertSame('Masjid Istiqlal (koreksi)', $e->name);
        $this->assertSame(-6.1703, $e->latitude);
    }

    public function test_registered_mosque_links_to_nearby_map_entry_as_verified(): void
    {
        $this->importFixture();
        $mosque = $this->registerMosque();

        $entry = DirectoryEntry::where('source_ref', 'node/1001')->first();
        $this->assertSame($mosque->id, $entry->mosque_id);
        $this->assertTrue($entry->verified);
        $this->assertSame('Masjid Istiqlal Jakarta', $entry->name);
        $this->assertSame(0, DirectoryEntry::where('source', 'moeslim')->count()); // tidak dobel
    }

    public function test_registered_mosque_without_map_entry_gets_own_entry_and_relinks_after_import(): void
    {
        $mosque = $this->registerMosque();
        $own = DirectoryEntry::where('source', 'moeslim')->where('source_ref', $mosque->id)->first();
        $this->assertNotNull($own);
        $this->assertTrue($own->verified);

        $this->importFixture();
        $this->assertSame(1, app(DirectoryService::class)->relinkUnmatched());
        $this->assertSame(0, DirectoryEntry::where('source', 'moeslim')->count());
        $this->assertSame($mosque->id, DirectoryEntry::where('source_ref', 'node/1001')->value('mosque_id'));
    }

    public function test_different_name_far_away_is_not_linked(): void
    {
        $this->importFixture();
        $mosque = $this->registerMosque(['name' => 'Masjid Baiturrahman', 'latitude' => -6.1710, 'longitude' => 106.8314]); // ±90 m
        $this->assertNull(DirectoryEntry::where('source_ref', 'node/1001')->value('mosque_id'));
        $this->assertSame(1, DirectoryEntry::where('source', 'moeslim')->where('source_ref', $mosque->id)->count());
    }

    public function test_moving_mosque_relinks_directory(): void
    {
        $this->importFixture();
        $mosque = $this->registerMosque();
        Sanctum::actingAs($mosque->members()->first()->user);

        $this->patchJson("/api/mosques/{$mosque->id}", ['latitude' => -6.3, 'longitude' => 106.9])->assertOk();

        $this->assertNull(DirectoryEntry::where('source_ref', 'node/1001')->value('mosque_id'));
        $this->assertSame(1, DirectoryEntry::where('source', 'moeslim')->where('mosque_id', $mosque->id)->count());
    }

    public function test_cell_endpoint_returns_entries_attribution_and_supports_etag(): void
    {
        $this->importFixture();
        $mosque = $this->registerMosque();
        DirectoryEntry::where('source_ref', 'node/1003')->update(['status' => 'hidden']);

        $res = $this->getJson('/api/public/directory/cells/qqgu')->assertOk()
            ->assertJsonPath('attribution.0', '© OpenStreetMap contributors (ODbL 1.0)');
        $this->assertCount(3, $res->json('data'));
        $istiqlal = collect($res->json('data'))->firstWhere('verified', true);
        $this->assertSame($mosque->slug, $istiqlal['mosque_slug']);
        $this->assertArrayNotHasKey('locked', $istiqlal);

        $etag = $res->headers->get('ETag');
        $this->get('/api/public/directory/cells/qqgu', ['If-None-Match' => $etag])->assertStatus(304);
        $this->getJson('/api/public/directory/cells/qqga')->assertNotFound();
        $this->getJson('/api/public/directory/cells/zzzz')->assertOk()->assertJsonCount(0, 'data');
    }

    public function test_reports_validation_and_creation_without_account(): void
    {
        $this->importFixture();
        $id = DirectoryEntry::where('source_ref', 'node/1001')->value('id');

        $this->postJson('/api/public/directory/reports', ['type' => 'new_mosque'])
            ->assertUnprocessable()->assertJsonValidationErrors(['name', 'latitude', 'longitude']);
        $this->postJson('/api/public/directory/reports', ['type' => 'wrong_location'])
            ->assertUnprocessable()->assertJsonValidationErrors(['directory_id', 'latitude']);

        $this->postJson('/api/public/directory/reports', [
            'type' => 'wrong_location', 'directory_id' => $id, 'latitude' => -6.1705, 'longitude' => 106.8316,
        ])->assertCreated()->assertJsonPath('data.status', 'pending');

        $r = DirectoryReport::first();
        $this->assertSame(64, strlen($r->reporter_hash));
        $this->assertNotSame('127.0.0.1', $r->reporter_hash);
    }

    public function test_moderation_command_applies_accepted_reports(): void
    {
        $this->importFixture();
        $istiqlal = DirectoryEntry::where('source_ref', 'node/1001')->first();
        $gone = DirectoryEntry::where('source_ref', 'node/1003')->first();
        $move = DirectoryReport::create(['type' => 'wrong_location', 'directory_id' => $istiqlal->id, 'latitude' => -6.1705, 'longitude' => 106.8316]);
        $missing = DirectoryReport::create(['type' => 'not_exists', 'directory_id' => $gone->id]);
        $new = DirectoryReport::create(['type' => 'new_mosque', 'name' => 'Langgar Nurul Huda', 'latitude' => -6.19, 'longitude' => 106.84]);
        $spam = DirectoryReport::create(['type' => 'wrong_name', 'directory_id' => $istiqlal->id, 'name' => 'xxx']);

        $this->artisan('directory:reports')->assertSuccessful();
        foreach ([$move, $missing, $new] as $r) {
            $this->artisan('directory:reports', ['--accept' => $r->id])->assertSuccessful();
        }
        $this->artisan('directory:reports', ['--reject' => $spam->id])->assertSuccessful();
        $this->artisan('directory:reports', ['--accept' => $spam->id])->assertFailed();

        $istiqlal->refresh();
        $this->assertSame(-6.1705, $istiqlal->latitude);
        $this->assertTrue($istiqlal->locked);
        $this->assertNotSame('xxx', $istiqlal->name);
        $this->assertSame('hidden', $gone->fresh()->status);
        $added = DirectoryEntry::where('source', 'user')->first();
        $this->assertSame('musala', $added->kind);
        $this->assertSame($added->id, $new->fresh()->directory_id);
        $this->assertSame('rejected', $spam->fresh()->status);
    }

    public function test_csv_import_for_simas_data(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'simas');
        file_put_contents($path, "\u{FEFF}id,name,latitude,longitude,city,kind\n"
            ."01.2.3.4,Masjid Raya Bogor,-6.5950,106.8167,Bogor,\n"
            ."01.2.3.5,Mushola Al Ikhlas,-6.6000,106.8000,Bogor,\n"
            ."01.2.3.6,Tanpa Koordinat,0,0,Bogor,\n");

        $this->artisan('directory:import-csv', ['file' => $path])->assertSuccessful();

        $this->assertSame(2, DirectoryEntry::where('source', 'simas')->count());
        $this->assertSame('01.2.3.4', DirectoryEntry::where('name', 'Masjid Raya Bogor')->value('simas_id'));
        $this->assertSame('musala', DirectoryEntry::where('name', 'Mushola Al Ikhlas')->value('kind'));
        unlink($path);
    }

    public function test_import_command_fetches_overpass_tiles_with_polite_user_agent(): void
    {
        Http::fake(['*' => Http::response(json_decode(file_get_contents(base_path('tests/fixtures/overpass_jakarta.json')), true))]);

        $this->artisan('directory:import-osm', ['--bbox' => '-6.3,106.7,-6.1,106.9', '--tile' => 1, '--pause' => 0])->assertSuccessful();

        Http::assertSentCount(1);
        Http::assertSent(fn ($req) => str_contains($req['data'], '"religion"="muslim"') && str_starts_with($req->header('User-Agent')[0], 'MoeslimPM'));
        $this->assertSame(4, DirectoryEntry::where('source', 'osm')->count());
    }
}
