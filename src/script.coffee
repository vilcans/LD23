$(document).ready ->
  if not Detector.webgl
    _gaq.push ['_trackEvent', 'webgl', 'nodetect', null, null, true]
    Detector.addGetWebGLMessage()
  else
    _gaq.push ['_trackEvent', 'webgl', 'available', null, null, true]
    new Game(document.body)
