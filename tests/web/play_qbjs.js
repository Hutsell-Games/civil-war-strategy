// Plays the scripts of tests/scripts in the game's QBJS build, as tests/play.py plays them in the native
// builds. docs/qbjs-plan.md, step 12.
//
//   node tests/web/play_qbjs.js [script ...] [--jobs 1] [--native] [--qbc "<flags>"] [--qbjs <folder>]
//                               [--prompt-seconds 120] [--chrome <exe>] [--hook <file.js>] [--keep-site]
//
// All the scripts are a large run, which goes in QB64Rust's suites VM (QB64Rust's tools\winvm\README.md, "A game
// port's run"). From QB64Rust's folder, in PowerShell:
//
//   tools\winvm\game.ps1 -Game ..\civil-war-strategy -With qbjs -Include tests/web/node_modules
//       -Outputs tests/out/web/scripts -Command node,tests/web/play_qbjs.js,--native,--jobs,4
//
// The VM has Edge, not Chrome; --chrome is not needed, since the default looks for both.
//
// --keep-site keeps each script's served folder (tests/out/web/scripts/<script>/site), which is otherwise
// removed after its run.
//
// --hook runs the JavaScript of a file in the page before QBJS starts, and prints the page's console
// output: a way to trace what the program does, as by wrapping a QB.sub_ function.
//
// With no script named it plays them all. Each script gets the run's folder that play.py would give it
// (tests/web/play_setup.py prepare), served to a headless Chrome. The keys file's steps are carried out as
// QB64Rust's screen-state check carries them out (QB64Rust's tools/screen/README.md, "The keys file"):
// the game announces each wait for a key by POKEing &H4F0 to &H4F2 (io/script.bm), and `prompt`,
// `rule` and `play until` answer those waits in the same way.
//
// What is compared with the native recording (<script>.screen):
// - The run must carry out every step: each `prompt` and `play until` must meet the wait it expects,
//   with no wait that no rule answers. So the same keys reach the same menus in the same order.
// - The program must end by itself (SYSTEM) after the last step, with no page error.
// - Each file of the script's "#! files" must have the hash recorded natively. A copy of each, as QBJS left
//   it, goes to tests/out/web/scripts/<script>/files/. A file that is not in QBJS's file system is hashed
//   as the run's folder holds it, so a file the game deleted would count as there; no recording expects a
//   missing file today.
// The `digest` lines are not compared: QBJS draws text and circles its own way. Instead each `digest`
// and `state` step, and the end, saves a screenshot to tests/out/web/scripts/<script>/qbjs-<n>.png.
// With --native the script also runs in the QB64Rust build with full states (play_setup.py native),
// its screens go beside them as native-<n>.png, and report.html shows each pair with the share of
// pixels that differ.
//
// Exit code: 0 when every script passed, 1 when one failed, 2 when the build or a set-up failed.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { spawnSync, spawn } = require('child_process');
const puppeteer = require('puppeteer-core');
const { findChrome, copyDependencies, serve } = require('./run_qbjs.js');

const GAME = path.resolve(__dirname, '..', '..');
const SCRIPTS = path.join(GAME, 'tests', 'scripts');
const OUT = path.join(GAME, 'tests', 'out', 'web', 'scripts');

// The key names of a keys file, as puppeteer names them.
const KEY_NAMES = {
    enter: 'Enter', esc: 'Escape', tab: 'Tab', backspace: 'Backspace', space: 'Space',
    up: 'ArrowUp', down: 'ArrowDown', left: 'ArrowLeft', right: 'ArrowRight', home: 'Home', end: 'End',
    pageup: 'PageUp', pagedown: 'PageDown', insert: 'Insert', delete: 'Delete',
};
for (let i = 1; i <= 12; i++) KEY_NAMES['f' + i] = 'F' + i;

// The characters typed with Shift down on a US keyboard. QBJS's INKEY$ takes the character from the
// key's code and the Shift state, not from the key's name.
const SHIFTED = '~!@#$%^&*()_+{}|:"<>?ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// A key of a step: { name } for a named key, { char } for a character.
function textKeys(s, where) {
    const keys = [];
    for (const c of s) {
        if (c < ' ' || c > '~') throw new Error(where + ': not a printable character');
        keys.push({ char: c });
    }
    return keys;
}

function namedKey(name, where) {
    if (!KEY_NAMES[name]) throw new Error(where + ': unknown key ' + name);
    return { name };
}

// The keys of a rule: "key <name>" parts, then at most one "text <characters>" part.
function ruleKeys(s, where) {
    const keys = [];
    while (s) {
        if (s.startsWith('text ') && s.length > 5) return keys.concat(textKeys(s.slice(5), where));
        if (!s.startsWith('key ')) throw new Error(where + ': not a rule');
        s = s.slice(4);
        const sp = s.indexOf(' ');
        keys.push(namedKey(sp < 0 ? s : s.slice(0, sp), where));
        s = sp < 0 ? '' : s.slice(sp + 1);
    }
    if (!keys.length) throw new Error(where + ': a rule with no keys');
    return keys;
}

// "<n>" or "<n>:<letter>"; letter -1 is any letter.
function place(s, where) {
    const m = s.match(/^(\d{1,3})(?::([\x21-\x7e]))?$/);
    if (!m || Number(m[1]) > 255) throw new Error(where + ': not a place');
    return { place: Number(m[1]), letter: m[2] ? m[2].charCodeAt(0) : -1 };
}

// The steps of a keys file, with `repeat <n>` blocks unrolled. The mouse and hold steps are not
// here: no script of the game uses them.
function readSteps(file) {
    const lines = fs.readFileSync(file, 'utf8').split('\n');
    const steps = [];
    const blocks = [];
    let repeats = false;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].replace(/\r$/, '');
        const n = i + 1;
        const where = path.basename(file) + ' line ' + n;
        if (!line || line[0] === '#') continue;
        if (repeats) throw new Error(where + ': a step after the last `repeat <key>`');
        const sp = line.indexOf(' ');
        const verb = sp < 0 ? line : line.slice(0, sp);
        const arg = sp < 0 ? '' : line.slice(sp + 1);
        if (verb === 'text' && arg) {
            for (const k of textKeys(arg, where)) steps.push({ kind: 'press', key: k });
        } else if (verb === 'repeat' && /^\d+$/.test(arg)) {
            blocks.push({ times: Number(arg), first: steps.length });
        } else if (line === 'end') {
            const b = blocks.pop();
            if (!b) throw new Error(where + ': `end` with no `repeat`');
            const body = steps.slice(b.first);
            for (let k = 1; k < b.times; k++) steps.push(...body);
        } else if (verb === 'key') {
            steps.push({ kind: 'press', key: namedKey(arg, where) });
        } else if (verb === 'repeat') {
            if (blocks.length) throw new Error(where + ': `repeat <key>` inside a block');
            steps.push({ kind: 'repeat', key: namedKey(arg, where) });
            repeats = true;
        } else if (verb === 'rule') {
            const sp2 = arg.indexOf(' ');
            if (sp2 < 0) throw new Error(where + ': not a rule');
            steps.push({ kind: 'rule', ...place(arg.slice(0, sp2), where), keys: ruleKeys(arg.slice(sp2 + 1), where) });
        } else if (verb === 'play' && arg.startsWith('until ')) {
            steps.push({ kind: 'play', ...place(arg.slice(6), where), line: n });
        } else if (line === 'prompt') {
            steps.push({ kind: 'prompt', line: n });
        } else if (line === 'digest' || line === 'state') {
            steps.push({ kind: 'shot', line: n });
        } else if (verb === 'wait' && /^\d+$/.test(arg)) {
            steps.push({ kind: 'wait', ms: Number(arg) });
        } else {
            throw new Error(where + ': not a step this player knows');
        }
    }
    if (blocks.length) throw new Error(path.basename(file) + ': a `repeat` block is never closed');
    return steps;
}

function placeName(p, letter) {
    return String(p) + (letter > 0x20 && letter < 0x7f ? ':' + String.fromCharCode(letter) : letter > 0 ? ':' + letter : '');
}

class Stop extends Error {}

const sleep = ms => new Promise(r => setTimeout(r, ms));

// Installed in the page before QBJS starts: ENVIRON$, the announced waits, and what the program reads.
function pageHooks(env) {
    window.__env = env;
    window.__h = { waits: 0, place: 0, letter: 0, given: 0, taken: 0, reads: 0, input: false };
    window.addEventListener('DOMContentLoaded', () => {
        const h = window.__h;
        QB.func_Environ = name => (window.__env[name] !== undefined ? window.__env[name] : '');
        // io/script.bm: &H4F1 holds the place and &H4F2 the letter; &H4F0 counts the waits and is POKEd last.
        const poke = QB.sub_Poke;
        let p = 0, l = 0;
        QB.sub_Poke = function (address, value) {
            if (address === 0x4F1) p = value;
            else if (address === 0x4F2) l = value;
            else if (address === 0x4F0) { h.place = p; h.letter = l; h.waits++; }
            return poke.apply(this, arguments);
        };
        // A key goes in only when the program has taken the one before (the keys file's rule), and only
        // once it reads: INPUT does not read QBJS's INKEY$ buffer, so a key given before it starts is lost.
        const inkey = QB.func_InKey;
        QB.func_InKey = function () {
            h.reads++;
            const k = inkey.apply(this, arguments);
            if (k !== '') h.taken++;
            return k;
        };
        const clear = QB.sub__KeyClear;
        QB.sub__KeyClear = function () { h.taken = h.given; return clear.apply(this, arguments); };
        const input = QB.sub_Input;
        QB.sub_Input = async function () {
            h.input = true;
            h.reads++;
            try { return await input.apply(this, arguments); } finally { h.input = false; }
        };
    });
}

async function shot(page, file) {
    // A frame first, so what the program drew is on the canvas.
    const url = await page.evaluate(() => new Promise(r => requestAnimationFrame(() => r(GX.canvas().toDataURL('image/png')))));
    fs.writeFileSync(file, Buffer.from(url.split(',')[1], 'base64'));
}

// Carries out the steps in the page. Each screenshot taken goes into shots, with its keys file line, so that
// those before a failure are kept.
async function playSteps(page, steps, o, errors, folder, keysName, shots) {
    const limit = o.promptSeconds * 1000;
    const h = () => page.evaluate(() => window.__h);
    let prompts = 0;
    let lastReads = 0;
    const rules = [];
    let pending = [];

    const check = () => { if (errors.length) throw new Stop('page error: ' + errors[0]); };

    const waitFor = async (expected, line) => {
        const until = Date.now() + limit;
        for (;;) {
            check();
            const s = await h();
            if (s.waits === expected) return s;
            if (s.waits > expected) throw new Stop(keysName + ' line ' + line + ': the program announced more waits than the keys file has prompts');
            if (Date.now() > until) throw new Stop(keysName + ' line ' + line + ': no prompt in ' + o.promptSeconds + ' s');
            await sleep(5);
        }
    };

    const press = async (key) => {
        const until = Date.now() + limit;
        let s;
        for (;;) {
            check();
            s = await h();
            if (s.input || (s.given === s.taken && s.reads !== lastReads)) break;
            if (Date.now() > until) throw new Stop('the program did not read the key ' + JSON.stringify(key) + ' in ' + o.promptSeconds + ' s');
            await sleep(5);
        }
        if (s.input) {
            // QBJS's INPUT looks at the last key every 5 ms, so keys must come slower than that.
            await page.keyboard.press(key.name ? KEY_NAMES[key.name] : key.char);
            await sleep(40);
            lastReads = (await h()).reads;
            return;
        }
        await page.evaluate(() => { window.__h.given++; });
        lastReads = s.reads;
        if (key.name) {
            await page.keyboard.press(KEY_NAMES[key.name]);
        } else if (SHIFTED.includes(key.char)) {
            await page.keyboard.down('Shift');
            await page.keyboard.press(key.char);
            await page.keyboard.up('Shift');
        } else {
            await page.keyboard.press(key.char === ' ' ? 'Space' : key.char);
        }
    };

    for (const st of steps) {
        if (st.kind === 'press') {
            await press(st.key);
        } else if (st.kind === 'wait') {
            await sleep(st.ms);
        } else if (st.kind === 'prompt') {
            await waitFor(++prompts, st.line);
        } else if (st.kind === 'shot') {
            const file = path.join(folder, 'qbjs-' + (shots.length + 1) + '.png');
            await shot(page, file);
            shots.push({ line: st.line, file });
        } else if (st.kind === 'rule') {
            for (let i = rules.length - 1; i >= 0; i--) {
                if (rules[i].place === st.place && rules[i].letter === st.letter) rules.splice(i, 1);
            }
            rules.push(st);
        } else if (st.kind === 'play') {
            for (;;) {
                const s = await waitFor(++prompts, st.line);
                if (pending.length) {
                    await press(pending.shift());
                    continue;
                }
                if (s.place === st.place && (st.letter < 0 || st.letter === s.letter)) break;
                let rule = null;
                for (let i = rules.length - 1; i >= 0 && !rule; i--) {
                    if (rules[i].place === s.place && rules[i].letter === s.letter) rule = rules[i];
                }
                for (let i = rules.length - 1; i >= 0 && !rule; i--) {
                    if (rules[i].place === s.place && rules[i].letter < 0) rule = rules[i];
                }
                if (!rule) throw new Stop(keysName + ' line ' + st.line + ': no rule for the wait at place ' + placeName(s.place, s.letter));
                pending = rule.keys.slice(1);
                await press(rule.keys[0]);
            }
        } else if (st.kind === 'repeat') {
            const until = Date.now() + limit;
            while (!(await page.evaluate(() => QB.halted()))) {
                check();
                if (Date.now() > until) throw new Stop('the program did not end in ' + o.promptSeconds + ' s');
                await page.keyboard.press(KEY_NAMES[st.key.name]);
                await sleep(100);
            }
        }
    }
}

// The bytes of a file of QBJS's file system, the name's parts matched whatever their case, as on
// Windows; null when it is not there.
async function vfsFile(page, name) {
    const b64 = await page.evaluate((name) => {
        const vfs = GX.vfs();
        let node = GX.vfsCwd();
        for (const part of name.split('/')) {
            const found = vfs.getChildren(node).find(c => c.name && c.name.toLowerCase() === part.toLowerCase());
            if (!found) return null;
            node = found;
        }
        if (node.type !== vfs.FILE) return null;
        const bytes = new Uint8Array(node.data);
        let s = '';
        for (let i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
        return btoa(s);
    }, name);
    return b64 === null ? null : Buffer.from(b64, 'base64');
}

function diskFile(folder, name) {
    let p = folder;
    for (const part of name.split('/')) {
        if (!fs.existsSync(p) || !fs.statSync(p).isDirectory()) return null;
        const found = fs.readdirSync(p).find(e => e.toLowerCase() === part.toLowerCase());
        if (!found) return null;
        p = path.join(p, found);
    }
    return fs.statSync(p).isFile() ? fs.readFileSync(p) : null;
}

// play.py's file_entries: the SHA-256 of the file with CRLF taken as LF, its first 16 hex digits.
function fileLine(name, bytes) {
    if (!bytes) return 'file ' + name + ' missing';
    const lf = Buffer.from(bytes.toString('latin1').replace(/\r\n/g, '\n'), 'latin1');
    return 'file ' + name + ' ' + crypto.createHash('sha256').update(lf).digest('hex').slice(0, 16).toUpperCase();
}

function runPython(args) {
    return new Promise(resolve => {
        const p = spawn('python', ['-I', path.join(__dirname, 'play_setup.py'), ...args], { cwd: GAME });
        let out = '', err = '';
        p.stdout.on('data', d => { out += d; });
        p.stderr.on('data', d => { err += d; });
        p.on('close', code => {
            const last = out.trim().split('\n').pop() || '';
            let json = null;
            try { json = JSON.parse(last); } catch (e) { /* reported below */ }
            resolve({ code, json, out, err });
        });
    });
}

async function playScript(browser, build, name, o) {
    const folder = path.join(OUT, name);
    const site = path.join(folder, 'site');
    fs.rmSync(folder, { recursive: true, force: true });
    fs.mkdirSync(site, { recursive: true });
    for (const e of fs.readdirSync(build, { withFileTypes: true })) {
        fs.cpSync(path.join(build, e.name), path.join(site, e.name), { recursive: true });
    }
    const setup = await runPython(['prepare', name, site]);
    if (!setup.json || setup.json.error) {
        return { name, setupError: (setup.json && setup.json.error) || (setup.err || setup.out).trim() };
    }
    const script = setup.json;
    const steps = readSteps(script.keys);
    const keysName = 'tests/scripts/' + path.basename(script.keys);

    const server = await serve(site);
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    const env = { CWS_SEED: String(script.seed) };
    if (script.dice) env.CWS_DICE = script.dice;
    await page.evaluateOnNewDocument(pageHooks, env);
    if (o.hook) {
        await page.evaluateOnNewDocument(fs.readFileSync(path.resolve(o.hook), 'utf8'));
        page.on('console', m => console.log('[' + name + '] ' + m.text()));
    }
    const t0 = Date.now();
    let problem = null;
    const shots = [];
    const files = [];
    try {
        // Two minutes, not puppeteer's 30 s: in the suites VM a load beside other pages took longer.
        await page.goto('http://127.0.0.1:' + server.address().port + '/index.html', { timeout: 120000 })
            .catch(e => { throw new Stop('the page did not load: ' + e.message); });
        await playSteps(page, steps, o, errors, folder, keysName, shots);
        // After the last step the program ends by itself, as the native run's exit code 0 says.
        const until = Date.now() + o.promptSeconds * 1000;
        while (!(await page.evaluate(() => QB.halted()))) {
            if (errors.length) throw new Stop('page error: ' + errors[0]);
            if (Date.now() > until) throw new Stop('the program did not end after the last step');
            await sleep(20);
        }
        if (errors.length) throw new Stop('page error: ' + errors[0]);
    } catch (e) {
        if (!(e instanceof Stop)) throw e;
        problem = e.message;
    }
    try {
        const file = path.join(folder, 'qbjs-' + (shots.length + 1) + '.png');
        await shot(page, file);
        shots.push({ line: 'exit', file });
    } catch (e) { /* the page may be gone */ }
    if (!problem) {
        for (const f of script.files) {
            const bytes = (await vfsFile(page, f)) || diskFile(site, f);
            files.push(fileLine(f, bytes));
            // The file as QBJS left it, to compare with the native run's (tests/out/run/<script>-rust-web/game/).
            if (bytes) {
                const kept = path.join(folder, 'files', f);
                fs.mkdirSync(path.dirname(kept), { recursive: true });
                fs.writeFileSync(kept, bytes);
            }
        }
    }
    await page.close();
    server.close();
    const seconds = (Date.now() - t0) / 1000;

    const want = script.recorded.filter(l => l.startsWith('file '));
    const differing = [];
    files.forEach((l, i) => { if (l !== want[i]) differing.push({ now: l, recorded: want[i] }); });
    const result = { name, problem, seconds, shots, checkpoints: script.checkpoints.length, files, want, differing };
    if (o.native) result.native = await nativeShots(name, folder);
    if (!o.keepSite) fs.rmSync(site, { recursive: true, force: true });
    return result;
}

// The native runs go one at a time, also with --jobs: play.py's build of the game is not safe to run twice at once.
let nativeQueue = Promise.resolve();

function nativeShots(name, folder) {
    const run = nativeQueue.then(() => nativeShot(name, folder));
    nativeQueue = run.catch(() => {});
    return run;
}

async function nativeShot(name, folder) {
    const r = await runPython(['native', name, folder]);
    if (!r.json) return { problem: (r.err || r.out).trim().split('\n').slice(-3).join(' / ') };
    return { problem: r.json.problem, pngs: r.json.pngs };
}

// The share of pixels that differ between two PNGs, worked out in the browser (no image package).
async function pixelDiff(page, a, b) {
    const toUrl = f => 'data:image/png;base64,' + fs.readFileSync(f).toString('base64');
    return page.evaluate(async (ua, ub) => {
        const load = u => new Promise((ok, bad) => { const i = new Image(); i.onload = () => ok(i); i.onerror = bad; i.src = u; });
        const [ia, ib] = await Promise.all([load(ua), load(ub)]);
        const w = Math.min(ia.width, ib.width), hgt = Math.min(ia.height, ib.height);
        const px = img => {
            const c = document.createElement('canvas');
            c.width = w; c.height = hgt;
            const x = c.getContext('2d');
            x.drawImage(img, 0, 0, w, hgt);
            return x.getImageData(0, 0, w, hgt).data;
        };
        const da = px(ia), db = px(ib);
        let n = 0;
        for (let i = 0; i < da.length; i += 4) {
            if (Math.abs(da[i] - db[i]) > 48 || Math.abs(da[i + 1] - db[i + 1]) > 48 || Math.abs(da[i + 2] - db[i + 2]) > 48) n++;
        }
        return { share: n / (w * hgt), size: [ia.width, ia.height, ib.width, ib.height] };
    }, toUrl(a), toUrl(b));
}

async function writeReport(browser, r) {
    if (!r.native || !r.native.pngs) return;
    const page = await browser.newPage();
    const rows = [];
    try {
        for (let i = 0; i < r.shots.length; i++) {
            const native = path.join(OUT, r.name, 'native-' + (i + 1) + '.png');
            const s = r.shots[i];
            let d = null;
            if (fs.existsSync(native)) d = await pixelDiff(page, s.file, native);
            s.diff = d ? d.share : null;
            rows.push('<tr><td>' + (i + 1) + '</td><td>' + s.line + '</td><td>' +
                (d ? (100 * d.share).toFixed(1) + ' %' : 'no native screen') + '</td>' +
                '<td><img src="' + path.basename(s.file) + '"></td><td>' +
                (fs.existsSync(native) ? '<img src="native-' + (i + 1) + '.png">' : '') + '</td></tr>');
        }
    } finally {
        await page.close();
    }
    const html = '<!doctype html><meta charset="utf-8"><title>' + r.name + '</title>' +
        '<style>img{width:640px;image-rendering:pixelated}td{vertical-align:top;padding:4px}</style>' +
        '<h1>' + r.name + '</h1><p>QBJS on the left, the QB64Rust build on the right. "Differ" is the share of ' +
        'pixels whose color differs.</p><table><tr><th>#</th><th>keys line</th><th>differ</th><th>QBJS</th><th>native</th></tr>' +
        rows.join('\n') + '</table>';
    fs.writeFileSync(path.join(OUT, r.name, 'report.html'), html);
}

function options(argv) {
    const o = { jobs: 1, promptSeconds: 120, qbc: '--byref --round-half-even --qb-booleans --qb-lines', scripts: [] };
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--native') o.native = true;
        else if (a === '--keep-site') o.keepSite = true;
        else if (a === '--jobs') o.jobs = Number(argv[++i]);
        else if (a === '--prompt-seconds') o.promptSeconds = Number(argv[++i]);
        else if (a.startsWith('--')) o[a.slice(2)] = argv[++i];
        else o.scripts.push(a);
    }
    if (!o.scripts.length) {
        o.scripts = fs.readdirSync(SCRIPTS).filter(f => f.endsWith('.keys')).map(f => f.slice(0, -5)).sort();
    }
    return o;
}

function report(r) {
    if (r.setupError) {
        console.log('SETUP ' + r.name + ': ' + r.setupError);
        return false;
    }
    const ok = !r.problem && !r.differing.length && r.files.length === r.want.length;
    const shots = r.shots.filter(s => s.line !== 'exit').length;
    let line = (ok ? 'ok    ' : 'FAIL  ') + r.name + ': ' + shots + ' of ' + r.checkpoints + ' checkpoints, ' +
        r.files.length + ' files' + (r.differing.length ? ' (' + r.differing.length + ' differ)' : '') +
        ', ' + r.seconds.toFixed(0) + ' s';
    if (r.problem) line += '\n    ' + r.problem;
    for (const d of r.differing) line += '\n    recorded: ' + d.recorded + '\n    now:      ' + d.now;
    if (r.native) {
        if (r.native.problem) line += '\n    native run: ' + r.native.problem;
        const diffs = r.shots.filter(s => s.diff !== undefined && s.diff !== null);
        if (diffs.length) {
            const worst = diffs.reduce((a, b) => (b.diff > a.diff ? b : a));
            line += '\n    screens: the most different is ' + (100 * worst.diff).toFixed(1) + ' % at keys line ' + worst.line +
                '; report: ' + path.relative(GAME, path.join(OUT, r.name, 'report.html')).replace(/\\/g, '/');
        }
    }
    console.log(line);
    return ok;
}

async function main() {
    const o = options(process.argv.slice(2));
    const qbjs = path.resolve(o.qbjs || path.join(GAME, '..', 'qbjs'));
    const build = path.join(OUT, '_build');
    fs.rmSync(build, { recursive: true, force: true });
    fs.mkdirSync(build, { recursive: true });
    const b = spawnSync('node', [path.join(qbjs, 'qbc.js'), path.join(GAME, 'cws.bas'), path.join(build, 'program.js'),
        ...o.qbc.split(' ').filter(Boolean)], { cwd: GAME, encoding: 'utf8' });
    process.stderr.write(b.stderr || '');
    if (b.status !== 0 || (b.stdout || '').split('\n').some(l => l.startsWith('ERROR:'))) {
        process.stdout.write(b.stdout || '');
        process.exit(2);
    }
    copyDependencies(qbjs, build);

    const browser = await puppeteer.launch({ executablePath: findChrome(o.chrome), headless: true });
    const results = [];
    try {
        const queue = o.scripts.slice();
        const worker = async () => {
            while (queue.length) {
                const name = queue.shift();
                const r = await playScript(browser, build, name, o);
                if (!r.setupError) await writeReport(browser, r);
                results.push(r);
                report(r);
            }
        };
        await Promise.all(Array.from({ length: Math.max(1, o.jobs) }, worker));
    } finally {
        await browser.close();
    }
    const setup = results.filter(r => r.setupError).length;
    const failed = results.filter(r => !r.setupError && (r.problem || r.differing.length || r.files.length !== r.want.length)).length;
    console.log((results.length - failed - setup) + ' passed, ' + failed + ' failed' + (setup ? ', ' + setup + ' not set up' : ''));
    process.exit(setup ? 2 : failed ? 1 : 0);
}

main().catch(e => { console.error(e); process.exit(2); });
