const tap = async (element) => {
  if (!element) throw new Error('Element is required for tap gesture');
  await element.click();
};

const doubleTap = async (driver, element) => {
  if (!driver || !element) throw new Error('Driver and element are required for double tap');
  await driver.touchAction([
    { action: 'tap', element },
    { action: 'tap', element }
  ]);
};

const longPress = async (driver, element, duration = 1000) => {
  if (!driver || !element) throw new Error('Driver and element are required for long press');
  await driver.touchAction([{ action: 'longPress', element, duration }, { action: 'release' }]);
};

const swipe = async (driver, start, end, duration = 800) => {
  await driver.touchAction([
    { action: 'press', x: start.x, y: start.y },
    { action: 'wait', ms: duration },
    { action: 'moveTo', x: end.x, y: end.y },
    'release'
  ]);
};

const scroll = async (driver, element, direction = 'down', distance = 300) => {
  const rect = await element.getRect();
  const startX = rect.x + rect.width / 2;
  const startY = rect.y + (direction === 'down' ? rect.height * 0.8 : rect.height * 0.2);
  const endY = rect.y + (direction === 'down' ? rect.height * 0.2 : rect.height * 0.8);
  await swipe(driver, { x: startX, y: startY }, { x: startX, y: endY });
};

const dragAndDrop = async (driver, source, target) => {
  const start = await source.getLocation();
  const end = await target.getLocation();
  await driver.touchAction([
    { action: 'press', x: start.x, y: start.y },
    { action: 'wait', ms: 500 },
    { action: 'moveTo', x: end.x, y: end.y },
    'release'
  ]);
};

const pinch = async (driver, element) => {
  const rect = await element.getRect();
  const centerX = rect.x + rect.width / 2;
  const centerY = rect.y + rect.height / 2;
  await driver.multiTouchPerform([
    [{ action: 'press', x: centerX - 100, y: centerY }, { action: 'moveTo', x: centerX - 20, y: centerY }, { action: 'release' }],
    [{ action: 'press', x: centerX + 100, y: centerY }, { action: 'moveTo', x: centerX + 20, y: centerY }, { action: 'release' }]
  ]);
};

const zoom = async (driver, element) => {
  const rect = await element.getRect();
  const centerX = rect.x + rect.width / 2;
  const centerY = rect.y + rect.height / 2;
  await driver.multiTouchPerform([
    [{ action: 'press', x: centerX - 20, y: centerY }, { action: 'moveTo', x: centerX - 120, y: centerY }, { action: 'release' }],
    [{ action: 'press', x: centerX + 20, y: centerY }, { action: 'moveTo', x: centerX + 120, y: centerY }, { action: 'release' }]
  ]);
};

module.exports = { tap, doubleTap, longPress, scroll, swipe, dragAndDrop, pinch, zoom };
