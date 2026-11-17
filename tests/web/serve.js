// Builds the game for QBJS and serves it, to play by hand. docs/qbjs-plan.md, step 12.
//
//   node tests/web/serve.js [--port 8080] [--no-persist] [--qbjs <folder>]
//
// The build goes to tests/out/web/play/. Unless --no-persist is given, the page keeps the game's files
// (saves, CWS.CFG, the Hall of Fame) in the browser with QB.persistFiles, so they survive a reload.
// Open http://127.0.0.1:<port>/ . Stop with Ctrl+C.
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const { copyDependencies, copyData, serve } = require('./run_qbjs.js');

const GAME = path.resolve(__dirname, '..', '..');

function main() {
    const argv = process.argv.slice(2);
    const o = { port: 8080, persist: true, qbjs: path.join(GAME, '..', 'qbjs') };
    for (let i = 0; i < argv.length; i++) {
        if (argv[i] === '--no-persist') o.persist = false;
        else if (argv[i] === '--port') o.port = Number(argv[++i]);
        else if (argv[i] === '--qbjs') o.qbjs = path.resolve(argv[++i]);
    }
    const out = path.join(GAME, 'tests', 'out', 'web', 'play');
    fs.rmSync(out, { recursive: true, force: true });
    fs.mkdirSync(out, { recursive: true });
    const b = spawnSync('node', [path.join(o.qbjs, 'qbc.js'), path.join(GAME, 'cws.bas'), path.join(out, 'program.js'),
        '--byref', '--round-half-even'], { cwd: GAME, encoding: 'utf8' });
    process.stderr.write(b.stderr || '');
    if (b.status !== 0 || (b.stdout || '').split('\n').some(l => l.startsWith('ERROR:'))) {
        process.stdout.write(b.stdout || '');
        process.exit(2);
    }
    copyDependencies(o.qbjs, out);
    copyData(GAME, out);
    if (o.persist) {
        const page = path.join(out, 'index.html');
        const html = fs.readFileSync(page, 'utf8').replace('__qbjs_run();', 'await QB.persistFiles("cws"); __qbjs_run();')
            .replace('function startProgram()', 'async function startProgram()');
        fs.writeFileSync(page, html);
    }
    serve(out, o.port).then(server => {
        console.log('Serving ' + out + '\nOpen http://127.0.0.1:' + server.address().port + '/');
    });
}

main();
