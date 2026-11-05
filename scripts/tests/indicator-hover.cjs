const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const configDir = path.resolve(__dirname, '../../dotfiles/omarchy/.config/omarchy');
const { bar } = JSON.parse(fs.readFileSync(path.join(configDir, 'shell.json'), 'utf8'));
assert.equal('centerAnchor' in bar, false);
assert.deepEqual(bar.layout.center.map(entry => entry.id), ['omarchy.clock']);
assert(bar.layout.centerBegin.some(entry => entry.id === 'omarchy.indicators'));
assert(bar.layout.centerEnd.some(entry => entry.id === 'ghoul.indicators'));

const source = fs.readFileSync(path.join(configDir, 'plugins/ghoul.indicators/Indicators.qml'), 'utf8');
for (const [dimension, orientation] of [['Width', 'Horizontal'], ['Height', 'Vertical']]) {
  const property = `implicit${dimension}`;
  const active = `active${orientation}Block`;
  const inactive = `inactive${orientation}Block`;
  const match = source.match(new RegExp(`${property}: (root\\.revealInactiveIndicators \\? ${inactive}\\.${property}[^\\n]*\\n\\s*: [^\\n]+)`));
  assert(match, `Missing ${orientation.toLowerCase()} collapsed-size binding`);

  for (const [activeSize, inactiveSize, hovered, expected] of [
    [0, 75, false, 30],
    [0, 75, true, 75],
    [25, 50, false, 0],
    [25, 50, true, 50],
    [75, 0, false, 0],
    [75, 0, true, 0],
    [0, 0, false, 0],
    [0, 0, true, 0],
  ]) {
    const size = vm.runInNewContext(match[1], {
      root: { revealInactiveIndicators: hovered, barSize: 30 },
      [active]: { [property]: activeSize },
      [inactive]: { [property]: inactiveSize },
    });
    assert.equal(size, expected, `${orientation}: active=${activeSize}, inactive=${inactiveSize}, hovered=${hovered}`);
  }
}
console.log('PASS: clock-centered layout and horizontal/vertical indicator hover sizing');
