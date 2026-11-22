const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');

async function main() {
  const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
  const target = path.resolve(__dirname, '../../../packages/moeslim_brand/assets/3d');
  fs.mkdirSync(path.join(target, 'thumbs'), { recursive: true });
  const report = [];
  for (const [name, source] of Object.entries(manifest)) {
    const width = name === 'scene' ? 1536 : 768;
    const input = sharp(source);
    const metadata = await input.metadata();
    const output = path.join(target, `${name}.webp`);
    await input.resize({ width, height: name === 'scene' ? undefined : 768, fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 84, alphaQuality: 100, effort: 6 }).toFile(output);
    await sharp(source).resize({ width: 192, height: 192, fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 86, alphaQuality: 100, effort: 6 }).toFile(path.join(target, 'thumbs', `${name}.webp`));
    report.push({ name, source: path.basename(source), alpha: metadata.hasAlpha, bytes: fs.statSync(output).size });
  }
  fs.writeFileSync(path.join(__dirname, 'encoded.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
}
main().catch(error => { console.error(error); process.exitCode = 1; });
