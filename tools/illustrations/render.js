// Render setiap SVG di ./svg ke PNG (skala 2x) di packages/moeslim_brand/assets/illustrations.
// Pakai: node render.js [nama ...]
let chromium;
try {
  ({ chromium } = require('playwright'));
} catch (_) {
  ({ chromium } = require('C:/Users/Zidhan/Downloads/webkita/node_modules/playwright'));
}
const fs = require('fs');
const path = require('path');
(async () => {
  const src = path.join(__dirname, 'svg');
  const out = path.join(__dirname, '../../packages/moeslim_brand/assets/illustrations');
  fs.mkdirSync(out, { recursive: true });
  const only = process.argv.slice(2);
  const chromePaths = [
    'C:/Program Files/Google/Chrome/Application/chrome.exe',
    'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  ];
  const executablePath = chromePaths.find((p) => fs.existsSync(p));
  const b = await chromium.launch(executablePath ? { executablePath } : {});
  for (const f of fs.readdirSync(src).filter((f) => f.endsWith('.svg'))) {
    const name = f.replace('.svg', '');
    if (only.length && !only.includes(name)) continue;
    const svg = fs.readFileSync(path.join(src, f), 'utf8');
    const [, w, h] = svg.match(/viewBox="0 0 (\d+) (\d+)"/);
    const p = await b.newPage({ viewport: { width: +w, height: +h }, deviceScaleFactor: 2 });
    await p.setContent(`<html><body style="margin:0;background:transparent">${svg.replace('<svg ', `<svg style="width:${w}px;height:${h}px;display:block" `)}</body></html>`);
    await p.screenshot({ path: path.join(out, `${name}.png`), omitBackground: true });
    await p.close();
  }
  await b.close();
})();
