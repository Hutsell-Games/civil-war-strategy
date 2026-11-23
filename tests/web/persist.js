// Checks QB.persistFiles (qbjs branch feature/persist-files): files a program writes are still there
// when the page is loaded again. docs/qbjs-plan.md, step 11.
//
//   node tests/web/persist.js
//
// Loads the page of persist_keep.bas three times in one browser. The program reads keep.txt if it is
// there, writes it, makes a folder and a binary file, and deletes a third file. Screenshots of each load
// go to tests/out/web/persist/. The first one prints NEW, the next ones FOUND:saved, and gone.txt is never
// there. Exit code 0 when the later loads find the file and the first does not.
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const puppeteer = require('puppeteer-core');
const { findChrome, copyDependencies, serve } = require('./run_qbjs.js');

const GAME = path.resolve(__dirname, '..', '..');
const qbjs = path.resolve(GAME, '..', 'qbjs');
const out = path.join(GAME, 'tests', 'out', 'web', 'persist');

async function main() {
    fs.rmSync(out, { recursive: true, force: true });
    fs.mkdirSync(out, { recursive: true });
    const b = spawnSync('node', [path.join(qbjs, 'qbc.js'), path.join(__dirname, 'persist_keep.bas'),
        path.join(out, 'program.js')], { encoding: 'utf8' });
    if (b.status !== 0 || (b.stdout || '').includes('ERROR:')) { console.log(b.stdout, b.stderr); process.exit(2); }
    copyDependencies(qbjs, out);
    const server = await serve(out);
    const browser = await puppeteer.launch({ executablePath: findChrome(), headless: true });
    let failed = false;
    for (let round = 1; round <= 3; round++) {
        const page = await browser.newPage();
        page.on('pageerror', e => { failed = true; console.log('[page error]', e.message); });
        await page.evaluateOnNewDocument(() => {
            window.addEventListener('DOMContentLoaded', () => {
                const run = window.__qbjs_run;
                window.__qbjs_run = async () => { window.__persist = await QB.persistFiles('persist-check'); return run(); };
            });
        });
        await page.goto('http://127.0.0.1:' + server.address().port + '/index.html');
        await new Promise(r => setTimeout(r, 1500));
        const files = await page.evaluate(() => {
            const vfs = GX.vfs();
            const names = [];
            const walk = n => { for (const c of vfs.getChildren(n)) { names.push(vfs.fullPath(c)); if (c.type == vfs.DIRECTORY) walk(c); } };
            walk(vfs.rootDirectory());
            const keep = vfs.getNode('keep.txt', vfs.rootDirectory());
            return { persist: window.__persist, names, text: keep ? vfs.readText(keep) : null };
        });
        await page.screenshot({ path: path.join(out, 'load' + round + '.png') });
        console.log('load ' + round + ': persist=' + files.persist + ' files=' + files.names.join(' '));
        if (!files.persist || files.names.includes('/gone.txt') || !files.names.includes('/sub/b.bin')) failed = true;
        await page.close();
    }
    await browser.close();
    server.close();
    console.log(failed ? 'FAIL (read tests/out/web/persist/load*.png: load 1 NEW, 2 and 3 FOUND)' : 'files kept; compare load1.png (NEW) with load2.png (FOUND:saved)');
    process.exit(failed ? 1 : 0);
}

main().catch(e => { console.error(e); process.exit(2); });
