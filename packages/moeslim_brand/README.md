# Moeslim brand

Shared Flutter visual assets for Personal, Mosque and TV Display.

## Logo Brand Kit V2

The active logo comes from the user-supplied `Moeslim_PM_Logo_Brand_Kit_V2.zip`
(integrated 2026-11-24). Its original files are retained in `brand-kit-v2-src/`.
The mark is the single human figure beside the mosque under an arch.
The archive's PNG artwork is copied directly, without redrawing the logo.

- `assets/logo/horizontal.png` and `horizontal_white.png` use the light/dark
  horizontal wordmarks from `03_Logotype_Wordmark`.
- `stacked.png` and `stacked_white.png` use the matching vertical wordmarks;
  dark mode now retains the full vertical lockup.
- `symbol.png` and `symbol_white.png` use the transparent 512 px symbols.
- Both Android apps use the supplied density, round and adaptive launcher icons,
  including the monochrome layer for Android 13 themed icons.
- Mobile native splash symbols, Android TV launcher banner, backend favicon
  and web TV logo use V2. The TV banner is a proportional resize of the supplied
  dark wordmark. Web references use `v=2` to invalidate the previous image cache.

Older brand-kit source files are historical references; they are not the active
logo bundle. The UI color tokens and 3D illustration palette remain separate
from the colors embedded in the supplied logo artwork.

## Soft 3D collection

`assets/3d/` contains 66 generated renders with local 192 px thumbnails for
navigation and feature icons. Full illustrations use a maximum 768 px edge;
the TV mosque scene uses 1536 px width. WebP preserves transparency. Previous
illustration/kit files remain as source history but are no longer bundled.

Import `package:moeslim_brand/material_3d.dart` in app UI files instead of the
direct Material import. It exports the existing API with a compatible `Icon`
subclass. Feature symbols use 3D objects. Small utility controls keep their exact
glyph, state color and semantics with a shallow extruded edge. Disabled icons
retain the inherited disabled tint. Existing `BrandArt`, `FeatureTileArt`,
`BrandElementArt` and `BrandEmptyState` APIs remain available.

## Visual decisions

- ENERGY 2 / RHYTHM 2 / MOTION 1: calm worship screens, distinct feature objects,
  and no added perpetual animation.
- Sage, ivory, wood and brass connect mosque architecture, books and prayer
  objects without bright toy-like plastic surfaces.
- Matte materials and soft directional light give objects depth at small sizes.
- Mihrab relief stays at the edge of backgrounds so text remains dominant.
- Existing Inter and Quran typography preserve readable labels and shaped Arabic.
- Feature imagery follows meaning: mosque for masjid, Quran/rehal for reading,
  beads for tasbih, prayer mat for worship, compass for qibla, calendar for Hijri,
  wallet for finance, display for TV, shield for account protection.
- Uniform feature tiles support scanning the same navigation level; the greeting,
  prayer schedule, reading list and mosque selection retain different compositions.
- Utility glyph relief preserves familiar control silhouettes. No continuous 3D
  rendering engine, network asset dependency or decorative animation is added.
- The official wordmark and Quran text retain their exact content.

## Provenance and reproduction

The raster collection was generated with built-in imagegen on 2026-11-22.
These are illustrations, not photographs of an actual mosque. No downloaded
stock image is bundled. [3D Islamic by Soni Sokell](https://icon-icons.com/pack/3d-islamic/4069),
listed as CC BY 4.0, was considered as a search reference but not incorporated.

Generation briefs: `../../tools/asset_kit/optimizer/prompts.json`.
`sources.json` and `extra-sources.json` record original local PNG paths; `encoded.json` records encoded
sizes and alpha metadata. Original PNGs remain outside the app bundle. Update
source paths when re-encoding on another machine, then run from the repo root:

```powershell
npm ci --prefix tools/asset_kit/optimizer
node tools/asset_kit/optimizer/encode.cjs tools/asset_kit/optimizer/sources.json
node tools/asset_kit/optimizer/encode.cjs tools/asset_kit/optimizer/extra-sources.json
node tools/asset_kit/optimizer/encode.cjs tools/asset_kit/optimizer/extra-sources-2.json
node tools/asset_kit/optimizer/encode.cjs tools/asset_kit/optimizer/extra-sources-3.json
```

The two small SVGs in `assets/3d/` are native beveled geometry: a centered compass
needle and an ayah divider. Compass rotation and Arabic labels remain live UI.

## Validation

Run `flutter analyze` and `flutter test` in this package. From `apps/mobile`, run:

```powershell
flutter test --dart-define=WRITE_3D_PREVIEWS=true test/soft_3d_visual_test.dart
```

This regenerates real widget screenshots in `docs/brand/screenshots/soft-3d/`.
Tests exercise navigation, light/dark mode, 360 px layout, larger text, asset
availability and icon semantics.

For Windows preview files held open by an image viewer, add
`--dart-define=PREVIEW_SUBDIR=verified` to write a fresh directory.

Review evidence (2026-11-22): the 38 renders, 38 thumbnails and two SVG elements
total 2,357,893 bytes. Package tests passed (17), display tests passed (22), and
the Android debug build succeeded. Mobile UI/about regression tests passed (11).
The full mobile run passed 125 tests but encountered two compilation failures:
the new localization test calls `ScheduledAdzanAlarm.toMap(lang: ...)`, which
the current alarm API does not accept, and the compiler then interrupted another
test load. This is not a clean full-suite result.

Visual review covers the seven captured screens, including light/dark and
360 px with 1.3 text scaling. The final visual test passed; reviewed captures are
in `../../docs/brand/screenshots/soft-3d/final/`. Screenshots use deterministic test fixtures, not
live prayer times. Physical-device frame timing, GPS and audio behavior have
not been benchmarked by this asset migration.
