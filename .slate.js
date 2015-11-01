slate.configAll({
  defaultToCurrentScreen: true,
  resizePercentOf: 'screenSize',
  windowHintsIgnoreHiddenWindows: false,
  windowHintsSpread: false,
  windowHintsShowIcons: false,
  windowHintsDuration: 3,
  windowHintsOrder: 'leftToRight'
});

var rightStage = 0;
var leftStage = 0;

var superCombo = 'ctrl;alt;cmd';
var hyperKey = 'ctrl;alt;cmd;shift';

var fullscreen = slate.operation('move', {x: 'screenOriginX', y: 'screenOriginY', width: 'screenSizeX', height: 'screenSizeY'});

slate.bind('f:' + hyperKey, fullscreen);

slate.bind('1:' + hyperKey, slate.operation('throw', {screen: 'left', height: 'screenSizeY'}));
slate.bind('2:' + hyperKey, slate.operation('throw', {screen: 'right', height: 'screenSizeY'}));

slate.bind('r:' + hyperKey, slate.operation('relaunch'));
slate.bind('g:' + hyperKey, slate.operation('grid'));
slate.bind('u:' + hyperKey, slate.operation('undo'));
slate.bind('0:' + hyperKey, slate.operation('snapshot', {name: 'default', save: true}));
slate.bind('/:' + hyperKey, slate.operation('activate-snapshot', {name: 'default'}));

slate.bind('esc:' + hyperKey, slate.operation('hint'));
slate.bind('h:' + hyperKey, slate.operation('focus', {direction: 'left'}));
slate.bind('l:' + hyperKey, slate.operation('focus', {direction: 'right'}));
slate.bind('left:' + hyperKey, slate.operation('focus', {direction: 'left'}));
slate.bind('right:' + hyperKey, slate.operation('focus', {direction: 'right'}));

slate.bind('a:' + hyperKey, slate.operation('focus', {app: 'Atom'}));
slate.bind('j:' + hyperKey, slate.operation('focus', {app: 'IntelliJ IDEA'}));
slate.bind('c:' + hyperKey, slate.operation('focus', {app: 'Google Chrome'}));
slate.bind('i:' + hyperKey, slate.operation('focus', {app: 'iTerm'}));
slate.bind('s:' + hyperKey, slate.operation('focus', {app: 'Slack'}));
slate.bind('m:' + hyperKey, slate.operation('focus', {app: 'Spotify'}));

slate.bind('f11', slate.operation('focus', {app: 'Google Chrome'}));
slate.bind('f12', slate.operation('focus', {app: 'iTerm'}));
slate.bind('f13', slate.operation('focus', {app: 'Atom'}));
