// Builds a BASIC program with QBJS and runs it in a headless Chrome. docs/qbjs-plan.md, step 1.
//
//   node tests/web/run_qbjs.js <program.bas> [options]
//
//   --qbjs <folder>   QBJS's folder (default ../qbjs, beside the game's repo)
//   --out <folder>    where the page is built (default tests/out/web/<program name>)
//   --wait <seconds>  how long to let the program run (default 5)
//   --until <js>      stop as soon as this JavaScript expression is true in the page
//   --eval <js>       write the value of this expression after the run
//   --shot <file>     save a PNG of the page after the run
//   --env NAME=VALUE  make ENVIRON$("NAME") return VALUE (QBJS's own ENVIRON$ always gives "")
//   --keys <list>     press keys during the run: "3:Enter,1:ArrowDown" (seconds to wait, then the key)
//   --chrome <exe>    the browser (default: Chrome or Edge in their usual places)
//
// What it prints: QBJS's warnings and errors from the build, the page's console output and errors,
// and the --eval value. Its exit code is 0 when the build had no ERROR line and the page threw no
// error. The program's data files are copied from the program's folder (everything but sources,
// executables and the tests folders).

const fs = require('fs');
const http = require('http');
const path = require('path');
const { spawnSync } = require('child_process');
const puppeteer = require('puppeteer-core');

function options(argv) {
    const o = { env: {}, wait: 5 };
    const rest = [];
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--env') {
            const [k, ...v] = argv[++i].split('=');
            o.env[k] = v.join('=');
        } else if (a.startsWith('--')) {
            o[a.slice(2)] = argv[++i];
        } else {
            rest.push(a);
        }
    }
    o.program = rest[0];
    return o;
}

function findChrome(given) {
    const places = [given,
        'C:/Program Files/Google/Chrome/Application/chrome.exe',
        'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
        '/usr/bin/google-chrome', '/usr/bin/chromium', '/usr/bin/chromium-browser'];
    return places.find(p => p && fs.existsSync(p));
}

function copyDependencies(qbjs, out) {
    // export/dependencies.txt lines are: "<path in QBJS>", "<path in the build>"
    const list = fs.readFileSync(path.join(qbjs, 'export', 'dependencies.txt'), 'utf8').split(/\r?\n/);
    for (const line of list) {
        const m = line.match(/^"([^"]+)",\s*"([^"]+)"/);
        if (!m) continue;
        const to = path.join(out, m[2]);
        fs.mkdirSync(path.dirname(to), { recursive: true });
        fs.copyFileSync(path.join(qbjs, m[1]), to);
    }
    fs.copyFileSync(path.join(qbjs, 'export', 'auto.html'), path.join(out, 'index.html'));
}

function copyData(from, out) {
    const skip = new Set(['tests', 'tools', 'docs', '.git', 'node_modules']);
    const walk = (dir, rel) => {
        for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
            if (skip.has(e.name) && rel === '') continue;
            const src = path.join(dir, e.name);
            const r = path.join(rel, e.name);
            if (e.isDirectory()) {
                walk(src, r);
            } else if (!/\.(bas|bi|bm|exe|md|py)$/i.test(e.name)) {
                const to = path.join(out, r);
                fs.mkdirSync(path.dirname(to), { recursive: true });
                fs.copyFileSync(src, to);
            }
        }
    };
    walk(from, '');
}

function serve(root) {
    const types = { '.html': 'text/html', '.js': 'text/javascript', '.png': 'image/png', '.css': 'text/css' };
    const server = http.createServer((req, res) => {
        const file = path.join(root, decodeURIComponent(req.url.split('?')[0]).replace(/^\//, '') || 'index.html');
        if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
            res.writeHead(404);
            res.end();
            return;
        }
        res.writeHead(200, { 'Content-Type': types[path.extname(file).toLowerCase()] || 'application/octet-stream' });
        fs.createReadStream(file).pipe(res);
    });
    return new Promise(resolve => server.listen(0, '127.0.0.1', () => resolve(server)));
}

async function main() {
    const o = options(process.argv.slice(2));
    if (!o.program) {
        console.error('usage: node run_qbjs.js <program.bas> [options]; see the top of this file');
        process.exit(2);
    }
    const program = path.resolve(o.program);
    const qbjs = path.resolve(o.qbjs || path.join(__dirname, '..', '..', '..', 'qbjs'));
    const name = path.basename(program, path.extname(program));
    const out = path.resolve(o.out || path.join(__dirname, '..', 'out', 'web', name));
    fs.rmSync(out, { recursive: true, force: true });
    fs.mkdirSync(out, { recursive: true });

    // Build: QBJS's command-line compiler writes program.js and prints its warnings.
    const build = spawnSync('node', [path.join(qbjs, 'qbc.js'), program, path.join(out, 'program.js')],
        { cwd: path.dirname(program), encoding: 'utf8' });
    process.stdout.write(build.stdout || '');
    process.stderr.write(build.stderr || '');
    const buildErrors = (build.stdout || '').split('\n').filter(l => l.startsWith('ERROR:')).length;
    copyDependencies(qbjs, out);
    copyData(path.dirname(program), out);

    const server = await serve(out);
    const browser = await puppeteer.launch({ executablePath: findChrome(o.chrome), headless: true });
    let failed = buildErrors > 0 || build.status !== 0;
    try {
        const page = await browser.newPage();
        await page.setViewport({ width: 1280, height: 960 });
        page.on('console', m => console.log('[page]', m.text()));
        page.on('pageerror', e => { failed = true; console.log('[page error]', e.message); });
        page.on('response', r => { if (r.status() === 404) console.log('[404]', new URL(r.url()).pathname); });
        // QBJS's ENVIRON$ returns "" always; the harness replaces it before the program starts.
        await page.evaluateOnNewDocument(env => {
            window.__qbjsEnv = env;
            window.addEventListener('DOMContentLoaded', () => {
                QB.func_Environ = name => (window.__qbjsEnv[name] !== undefined ? window.__qbjsEnv[name] : '');
            });
        }, o.env);
        await page.goto('http://127.0.0.1:' + server.address().port + '/index.html');
        // --keys "3:Enter,1:ArrowDown,1:Enter": after each delay (seconds) press the key (puppeteer's key names)
        const pressKeys = async () => {
            for (const item of (o.keys || '').split(',').filter(Boolean)) {
                const [secs, key] = item.split(':');
                await new Promise(r => setTimeout(r, Number(secs) * 1000));
                await page.keyboard.press(key);
            }
        };
        pressKeys().catch(e => console.log('[keys]', e.message));
        const deadline = Date.now() + Number(o.wait) * 1000;
        while (Date.now() < deadline) {
            if (o.until && await page.evaluate(o.until).catch(() => false)) break;
            await new Promise(r => setTimeout(r, 100));
        }
        if (o.eval) console.log('[eval]', JSON.stringify(await page.evaluate(o.eval)));
        if (o.shot) await page.screenshot({ path: path.resolve(o.shot) });
    } finally {
        await browser.close();
        server.close();
    }
    process.exit(failed ? 1 : 0);
}

main().catch(e => { console.error(e); process.exit(2); });
