$(document).ready ->
  if not Detector.webgl
    Tracking.trackEvent 'webgl', 'nodetect', nonInteraction: true
    Detector.addGetWebGLMessage()
  else
    Tracking.trackEvent 'webgl', 'available', nonInteraction: true
    new Game(document.body)
