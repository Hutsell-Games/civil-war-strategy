// Plays Civil War Strategy in QBJS with the computer playing both sides and prints the line that
// the game writes to autoplay.txt. docs/qbjs-plan.md, step 9.
//
//   node tests/web/autoplay.js [--seeds 1-3] [--timeout 600] [--qbc "<flags>"] [--qbjs <folder>] [--native]
//                              [--history] [--dump <names>] [--out <folder name>] [--jobs <n>]
//                              [--expect <native results>]
//
// --jobs plays that many seeds at once. --expect compares each seed with a file of native results that
// tests/autoplay.py run wrote (as tests/out/web/native-1-100.json), prints the seeds that differ, and
// fails when one does. Seeds 1 to 100 are a large run, for QB64Rust's suites VM (tools\winvm\game.ps1).
//
// --out names the folder under tests/out/web/ where the page is built (default autoplay), so that
// several runs of different seeds can go side by side.
//
// --history turns the game's History setting on, and --dump a.txt,b.txt names other files of QBJS's
// file system. At the end of a seed they are saved as tests/out/web/autoplay/seed<seed>-<name>, to find
// where two runs part.
//
// For each seed it starts the page with CWS_SEED=<seed> and CWS_AUTOPLAY=1, and with the CWS.CFG that
// tests/autoplay.py gives a two-player game (the player's side is the Union). The game announces each
// wait for a key by POKEing bytes &H4F0 to &H4F2 (io/script.bm). This script catches those POKEs and
// answers with the keys of tests/autoplay.py's keys file. When autoplay.txt exists in QBJS's file
// system it reads it. With --native it also runs tests/autoplay.py for the same seeds, and prints
// the native build's line beside the QBJS one.
//
// A line is: the side end_game names, the rule that ended the game, the month and year, each side's
// victory points, each side's cities. Exit code: 0 when every seed gave a line (and with --native,
// the same one), else 1.

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const puppeteer = require('puppeteer-core');
const { findChrome, copyDependencies, copyData, serve } = require('./run_qbjs.js');

const GAME = path.resolve(__dirname, '..', '..');
const PROGRAM = path.join(GAME, 'cws.bas');

// The keys of tests/autoplay.py: [place, letter] -> key. Place 1 is a pause any key ends; place 2 is a
// menu named by its first letter.
function keyFor(place, letter) {
    if (place === 1) return 'Space';
    if (place === 2) {
        if (letter === 'E') return 'y';   // End Turn / End Game: Yes
        if (letter === 'R') return 'Enter'; // a retreat: the first city
        if (letter === 'O') return 'q';   // Quit this Game
        if (letter === 'C') return 's';   // the title menu: Start NEW Game
        if (letter === 'S') return 's';   // the map: standard
    }
    return null;
}

// The CWS.CFG of tests/autoplay.py's two-player game, in tests/play.py's field order.
function cfgFor(seed, history) {
    const f = [1, 3, 0, 3, 2, 1, 5, 600, 300, 1, seed % 2, 36, 134, 3992, 5041, history ? 1 : 0, seed % 6];
    return f.join(',') + '\n';
}

function options(argv) {
    const o = { seeds: '1', timeout: 600, qbc: '--byref --round-half-even --qb-booleans' };
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--native') o.native = true;
        else if (a === '--history') o.history = true;
        else if (a.startsWith('--')) o[a.slice(2)] = argv[++i];
    }
    const [first, last] = String(o.seeds).split('-');
    o.list = [];
    for (let s = Number(first); s <= Number(last || first); s++) o.list.push(s);
    return o;
}

async function playSeed(browser, port, seed, timeoutSeconds, dumpPrefix, dumpNames) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    await page.evaluateOnNewDocument((seed) => {
        window.__env = { CWS_SEED: String(seed), CWS_AUTOPLAY: '1' };
        window.__waits = 0;
        window.__last = [0, 0];
        window.addEventListener('DOMContentLoaded', () => {
            QB.func_Environ = name => (window.__env[name] !== undefined ? window.__env[name] : '');
            // io/script.bm: byte &H4F1 holds the place, &H4F2 the letter, and &H4F0 counts the waits,
            // which it POKEs last.
            const poke = QB.sub_Poke;
            let place = 0, letter = 0;
            QB.sub_Poke = function (address, value) {
                if (address === 0x4F1) place = value;
                else if (address === 0x4F2) letter = value;
                else if (address === 0x4F0) { window.__last = [place, letter]; window.__waits++; }
                return poke.apply(this, arguments);
            };
        });
    }, seed);
    // Two minutes, not puppeteer's 30 s: in the suites VM, with six pages at once, a load took longer.
    await page.goto('http://127.0.0.1:' + port + '/index.html', { timeout: 120000 });
    const deadline = Date.now() + timeoutSeconds * 1000;
    let answered = 0;
    let line = null;
    while (Date.now() < deadline) {
        const state = await page.evaluate((names) => {
            const vfs = GX.vfs();
            const file = vfs.getNode('autoplay.txt', GX.vfsCwd());
            const done = file && file.type == vfs.FILE;
            const dumped = {};
            if (done) {
                for (const name of names) {
                    const f = vfs.getNode(name, GX.vfsCwd());
                    if (f && f.type == vfs.FILE) dumped[name] = vfs.readText(f);
                }
            }
            return { waits: window.__waits, last: window.__last,
                     result: done ? vfs.readText(file) : null, dumped };
        }, dumpNames).catch(() => null);
        if (state && state.result) {
            line = state.result.trim();
            for (const name of Object.keys(state.dumped)) {
                fs.writeFileSync(dumpPrefix + name, state.dumped[name]);
            }
            break;
        }
        if (errors.length) break;
        if (state && state.waits !== answered) {
            answered = state.waits;
            const key = keyFor(state.last[0], String.fromCharCode(state.last[1]));
            if (key) await page.keyboard.press(key);
        }
        await new Promise(r => setTimeout(r, 20));
    }
    await page.close();
    return { line, error: errors[0] || (line ? null : 'no autoplay.txt in ' + timeoutSeconds + ' seconds') };
}

function nativeLines(seeds) {
    const out = path.join(GAME, 'tests', 'out', 'web', 'autoplay-native.json');
    const first = seeds[0], last = seeds[seeds.length - 1];
    const r = spawnSync('python', [path.join(GAME, 'tests', 'autoplay.py'), 'run', out, '--seeds', first + '-' + last,
        '--mode', 'two'], { cwd: GAME, encoding: 'utf8' });
    process.stdout.write(r.stdout || '');
    if (r.status !== 0) { process.stderr.write(r.stderr || ''); return null; }
    return JSON.parse(fs.readFileSync(out, 'utf8'));
}

async function main() {
    const o = options(process.argv.slice(2));
    const qbjs = path.resolve(o.qbjs || path.join(GAME, '..', 'qbjs'));
    const out = path.join(GAME, 'tests', 'out', 'web', o.out || 'autoplay');
    fs.rmSync(out, { recursive: true, force: true });
    fs.mkdirSync(out, { recursive: true });
    const build = spawnSync('node', [path.join(qbjs, 'qbc.js'), PROGRAM, path.join(out, 'program.js'), ...o.qbc.split(' ')],
        { cwd: GAME, encoding: 'utf8' });
    process.stderr.write(build.stderr || '');
    if (build.status !== 0 || (build.stdout || '').split('\n').some(l => l.startsWith('ERROR:'))) {
        process.stdout.write(build.stdout || '');
        process.exit(2);
    }
    copyDependencies(qbjs, out);
    copyData(GAME, out);

    const browser = await puppeteer.launch({ executablePath: findChrome(o.chrome), headless: true });
    const lines = {};
    const servers = [];
    try {
        // --jobs: each worker plays its seeds from a folder and a server of its own, since a seed's
        // CWS.CFG is written into the folder the page is served from.
        const queue = o.list.slice();
        const worker = async (k) => {
            const folder = k === 0 ? out : out + '-' + k;
            if (k > 0) {
                fs.rmSync(folder, { recursive: true, force: true });
                fs.cpSync(out, folder, { recursive: true });
            }
            const server = await serve(folder);
            servers.push(server);
            while (queue.length) {
                const seed = queue.shift();
                fs.writeFileSync(path.join(folder, 'CWS.CFG'), cfgFor(seed, o.history));
                const t0 = Date.now();
                const dumpNames = (o.history ? ['cws.his'] : []).concat(o.dump ? o.dump.split(',') : []);
                // An error of one seed (a page that did not load) is that seed's result, not the run's end.
                const r = await playSeed(browser, server.address().port, seed, Number(o.timeout),
                    path.join(out, 'seed' + seed + '-'), dumpNames).catch(e => ({ line: null, error: e.message }));
                lines[seed] = r;
                console.log('seed ' + seed + ' qbjs  : ' + (r.line || ('ERROR ' + r.error)) +
                    '  (' + ((Date.now() - t0) / 1000).toFixed(1) + ' s)');
            }
        };
        await Promise.all(Array.from({ length: Math.max(1, Number(o.jobs) || 1) }, (_, k) => worker(k)));
    } finally {
        await browser.close();
        servers.forEach(s => s.close());
    }
    let bad = o.list.filter(s => !lines[s].line).length;
    if (o.expect) {
        // The native results of tests/autoplay.py run, as tests/out/web/native-1-100.json
        const data = JSON.parse(fs.readFileSync(path.resolve(o.expect), 'utf8'));
        const games = data.games || data;
        let same = 0, differ = 0;
        for (const seed of o.list) {
            const g = games.find(x => x && x.seed === seed);
            const mine = lines[seed];
            if (!g) { console.log('seed ' + seed + ' NO NATIVE RESULT'); differ++; continue; }
            if (mine && mine.line && sameFields(mine.line, g)) { same++; continue; }
            differ++;
            console.log('seed ' + seed + ' DIFFERENT: native ' +
                [g.winner, g.rule, g.month, g.year, ...(g.points || []), ...(g.cities || [])].join(','));
        }
        console.log(same + ' of ' + o.list.length + ' seeds match the native results, ' + differ + ' differ');
        if (differ) bad++;
    }
    if (o.native) {
        const native = nativeLines(o.list);
        if (!native) process.exit(2);
        // tests/autoplay.py's results are objects (winner, rule, month, year, points, cities); compare
        // the numbers of the line the game wrote with the same fields.
        for (const g of native.games || native) {
            if (!g || g.seed === undefined) continue;
            const mine = lines[g.seed];
            const expected = [g.winner, g.rule, g.month, g.year, ...(g.points || []), ...(g.cities || [])].join(',');
            console.log('seed ' + g.seed + ' native: ' + expected);
            console.log('seed ' + g.seed + (mine && mine.line && sameFields(mine.line, g) ? ' MATCH' : ' DIFFERENT'));
        }
    }
    process.exit(bad ? 1 : 0);
}

// The line holds the named side, the rule number, month, year, points and cities. autoplay.py keeps
// the winner (the Rebels for a time limit) and the rule's name, so compare month, year, points, cities.
function sameFields(line, g) {
    const f = line.split(',').map(x => Math.round(Number(x)));
    const want = [g.month, g.year, ...(g.points || []), ...(g.cities || [])];
    return want.every((v, i) => f[i + 2] === v);
}

main().catch(e => { console.error(e); process.exit(2); });
