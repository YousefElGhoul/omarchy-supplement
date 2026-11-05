const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const source = fs.readFileSync(path.resolve(__dirname, '../../overrides/omarchy/patch-nightlight.sh'), 'utf8');
const tempDir = fs.mkdtempSync('/tmp/opencode/patch-nightlight-');
const toggle = path.join(tempDir, 'toggle');
const service = path.join(tempDir, 'Service.qml');
// Redirect the installed paths into fixtures so the real script runs without sudo.
const script = source
  .replace('/usr/bin/omarchy-toggle-nightlight', toggle)
  .replace('/usr/share/omarchy/shell/plugins/services/nightlight/Service.qml', service);

try {
  for (const [toggleTemp, serviceTemp, expectedStatus] of [
    [4000, 4000, 0],
    [1000, 4000, 0],
    [4000, 1000, 0],
    [1000, 1000, 0],
    [null, 4000, 1],
    [4000, null, 1],
    [3000, 4000, 1],
    [4000, 3000, 1],
  ]) {
    fs.rmSync(toggle, { force: true });
    fs.rmSync(service, { force: true });
    if (toggleTemp !== null) fs.writeFileSync(toggle, `ON_TEMP=${toggleTemp}\nOFF_TEMP=6500\n`);
    if (serviceTemp !== null) fs.writeFileSync(service, `  readonly property int nightTemperature: ${serviceTemp}\n  readonly property int dayTemperature: 6500\n`);

    const result = spawnSync('bash', ['-s'], { input: script, encoding: 'utf8' });
    assert.equal(result.status, expectedStatus, result.stdout + result.stderr);
    for (const [file, temp, expected] of [
      [toggle, toggleTemp, `ON_TEMP=${toggleTemp === 4000 ? 1000 : toggleTemp}\nOFF_TEMP=6500\n`],
      [service, serviceTemp, `  readonly property int nightTemperature: ${serviceTemp === 4000 ? 1000 : serviceTemp}\n  readonly property int dayTemperature: 6500\n`],
    ]) {
      if (temp === null) assert.equal(fs.existsSync(file), false);
      else assert.equal(fs.readFileSync(file, 'utf8'), expected);
    }
    if (expectedStatus === 1) assert.match(result.stderr, /not found|Unexpected/);
    else if (toggleTemp === 1000 && serviceTemp === 1000) assert.match(result.stdout, /already set to 1000K/);
  }
  console.log('PASS: nightlight CLI/bar patching, reruns, missing files, and unexpected temperatures');
} finally {
  fs.rmSync(tempDir, { recursive: true, force: true });
}
