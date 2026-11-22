# Moeslim brand

Shared Flutter visual assets for Personal, Mosque and TV Display.

## Soft 3D collection

`assets/3d/` contains 28 generated renders with local 192 px thumbnails for
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
- The official wordmark and Quran text retain their exact content.

## Provenance and reproduction

The raster collection was generated with built-in imagegen on 2026-11-22.
These are illustrations, not photographs of an actual mosque. No downloaded
stock image is bundled. [3D Islamic by Soni Sokell](https://icon-icons.com/pack/3d-islamic/4069),
listed as CC BY 4.0, was considered as a search reference but not incorporated.

Generation briefs: `../../tools/asset_kit/optimizer/prompts.json`.
`sources.json` records original local PNG paths; `encoded.json` records encoded
sizes and alpha metadata. Original PNGs remain outside the app bundle. Update
source paths when re-encoding on another machine, then run from the repo root:

```powershell
npm ci --prefix tools/asset_kit/optimizer
node tools/asset_kit/optimizer/encode.cjs tools/asset_kit/optimizer/sources.json
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
