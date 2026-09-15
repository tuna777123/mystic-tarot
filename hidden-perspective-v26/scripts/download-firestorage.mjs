import {chromium} from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';

const shareUrl = process.env.FIRESTORAGE_SHARE_URL;
if (!shareUrl) throw new Error('FIRESTORAGE_SHARE_URL is required');

const root = process.cwd();
const downloadDir = path.join(root, 'downloads');
const assetDir = path.join(root, 'public', 'assets');
const diagDir = path.join(root, 'diagnostics');
for (const d of [downloadDir, assetDir, diagDir]) fs.mkdirSync(d, {recursive: true});

const norm = (s) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();

const mappings = [
  ['abandoned 1 wav', 'score-1.wav'],
  ['abandoned 1 mp3', 'narration-1.mp3'],
  ['abandoned places english captions v19 final', 'captions.srt'],
  ['abandoned classroom with open book', 'classroom-book.png'],
  ['forgotten lessons in an abandoned classroom', 'classroom-lessons.png'],
  ['ordinary life in pripyat 1985', 'pripyat-life.png'],
  ['buses line pripyat for evacuation', 'pripyat-buses.png'],
  ['centralia mine fire four documentary views', 'centralia-grid.png'],
  ['villa epecuen salt covered ruins', 'villa.png'],
  ['maunsell sea forts in grey mist', 'maunsell-mist.png'],
  ['maunsell fort anti aircraft gun 1943', 'maunsell-gun.png'],
  ['corroded catwalk between maunsell towers', 'maunsell-catwalk.png'],
  ['maunsell pirate radio detail reconstruction', 'maunsell-radio.png'],
  ['beneath the maunsell sea forts', 'maunsell-beneath.png'],
  ['houtouwan reclaimed by nature', 'houtouwan-green.png'],
  ['houtouwan fishing village early 1980s', 'houtouwan-1980s.png'],
  ['misty ivy covered houtouwan village', 'houtouwan-misty.png'],
];

const listFiles = (dir) => {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const ent of fs.readdirSync(dir, {withFileTypes:true})) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) out.push(...listFiles(p)); else out.push(p);
  }
  return out;
};

const canonicalize = () => {
  const files = listFiles(downloadDir);
  for (const f of files) {
    if (f.toLowerCase().endsWith('.zip')) {
      const dest = path.join(downloadDir, path.basename(f, '.zip'));
      fs.mkdirSync(dest, {recursive:true});
      spawnSync('unzip', ['-o', f, '-d', dest], {stdio:'inherit'});
    }
  }
  const all = listFiles(downloadDir);
  for (const f of all) {
    const n = norm(path.basename(f));
    const match = mappings.find(([needle]) => n.includes(needle));
    if (!match) continue;
    const dest = path.join(assetDir, match[1]);
    if (!fs.existsSync(dest)) fs.copyFileSync(f, dest);
  }
};

const required = [
  'score-1.wav','narration-1.mp3','classroom-book.png','classroom-lessons.png',
  'pripyat-life.png','pripyat-buses.png','centralia-grid.png','villa.png',
  'maunsell-mist.png','maunsell-gun.png','maunsell-catwalk.png','maunsell-radio.png',
  'maunsell-beneath.png','houtouwan-green.png','houtouwan-1980s.png'
];

const browser = await chromium.launch({headless:true});
const context = await browser.newContext({acceptDownloads:true, locale:'ja-JP'});
const page = await context.newPage();
const interestingResponses = [];
page.on('response', async (r) => {
  const h = r.headers();
  const u = r.url();
  if (/download|file|object|storage|api/i.test(u) || /attachment/i.test(h['content-disposition'] || '')) {
    interestingResponses.push({status:r.status(), url:u, contentType:h['content-type'] || '', disposition:h['content-disposition'] || ''});
  }
});

await page.goto(shareUrl, {waitUntil:'domcontentloaded', timeout:60000});
await page.waitForTimeout(5000);
fs.writeFileSync(path.join(diagDir,'page.html'), await page.content());
await page.screenshot({path:path.join(diagDir,'page.png'), fullPage:true});

const anchors = await page.locator('a').evaluateAll((els) => els.map((e) => ({text:(e.innerText||'').trim(), href:e.href, download:e.getAttribute('download')})));
const buttons = await page.locator('button').evaluateAll((els) => els.map((e) => ({text:(e.innerText||'').trim(), aria:e.getAttribute('aria-label'), title:e.getAttribute('title')})));
fs.writeFileSync(path.join(diagDir,'anchors.json'), JSON.stringify(anchors,null,2));
fs.writeFileSync(path.join(diagDir,'buttons.json'), JSON.stringify(buttons,null,2));
fs.writeFileSync(path.join(diagDir,'responses.json'), JSON.stringify(interestingResponses,null,2));
console.log('ANCHORS', JSON.stringify(anchors.slice(0,120),null,2));
console.log('BUTTONS', JSON.stringify(buttons.slice(0,120),null,2));

// 1) Direct downloadable anchors first.
for (let i=0;i<anchors.length;i++) {
  const a = anchors[i];
  if (!a.href) continue;
  if (!(/download/i.test(a.href) || /\.(png|jpe?g|webp|wav|mp3|srt)(\?|$)/i.test(a.href) || a.download)) continue;
  try {
    const resp = await context.request.get(a.href, {timeout:30000});
    if (!resp.ok()) continue;
    const ct = resp.headers()['content-type'] || '';
    if (/text\/html/i.test(ct)) continue;
    let name = a.download || decodeURIComponent(new URL(a.href).pathname.split('/').pop() || `asset-${i}`);
    const disp = resp.headers()['content-disposition'] || '';
    const m = disp.match(/filename\*?=(?:UTF-8''|\")?([^\";]+)/i);
    if (m) name = decodeURIComponent(m[1].replace(/^\"|\"$/g,''));
    fs.writeFileSync(path.join(downloadDir, name), await resp.body());
  } catch (e) { console.log('direct anchor failed', a.href, String(e)); }
}
canonicalize();

// 2) Try visible download controls and capture browser downloads.
const controls = page.locator('button, a').filter({hasText:/ダウンロード|download/i});
const count = Math.min(await controls.count(), 80);
console.log('DOWNLOAD-LIKE CONTROLS', count);
for (let i=0;i<count;i++) {
  try {
    const c = controls.nth(i);
    if (!(await c.isVisible())) continue;
    const downloadPromise = page.waitForEvent('download', {timeout:7000}).catch(() => null);
    await c.click({timeout:7000}).catch(() => null);
    const dl = await downloadPromise;
    if (dl) {
      const out = path.join(downloadDir, dl.suggestedFilename());
      await dl.saveAs(out);
      console.log('downloaded', out);
    }
    await page.waitForTimeout(700);
  } catch (e) { console.log('control click failed', i, String(e)); }
}
canonicalize();

// 3) Filename-local heuristic: locate each filename and click the nearest likely action.
for (const [needle] of mappings) {
  const tokens = needle.split(' ').slice(0, Math.min(5, needle.split(' ').length)).join(' ');
  const candidate = page.getByText(new RegExp(tokens.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'),'i')).first();
  if (!(await candidate.count())) continue;
  try {
    let row = candidate.locator('xpath=ancestor::*[self::li or self::tr or self::div][.//button or .//a][1]');
    if (!(await row.count())) row = candidate.locator('xpath=..');
    const actions = row.locator('button, a');
    const ac = Math.min(await actions.count(), 8);
    for (let j=0;j<ac;j++) {
      const action = actions.nth(j);
      if (!(await action.isVisible())) continue;
      const meta = `${await action.innerText().catch(()=> '')} ${await action.getAttribute('aria-label') || ''} ${await action.getAttribute('title') || ''}`;
      if (!/download|ダウンロード|保存/i.test(meta) && j !== ac-1) continue;
      const dp = page.waitForEvent('download', {timeout:5000}).catch(() => null);
      await action.click({timeout:5000}).catch(() => null);
      const dl = await dp;
      if (dl) {
        const out = path.join(downloadDir, dl.suggestedFilename());
        await dl.saveAs(out);
        console.log('filename heuristic downloaded', out);
        break;
      }
    }
  } catch (e) { console.log('filename heuristic failed', needle, String(e)); }
}
canonicalize();

await browser.close();

const present = fs.existsSync(assetDir) ? fs.readdirSync(assetDir) : [];
console.log('CANONICAL ASSETS', present);
const missing = required.filter((f) => !present.includes(f));
if (missing.length) {
  console.error('MISSING REQUIRED ASSETS:', missing);
  process.exit(2);
}
console.log('All required V26 proof assets ready.');
