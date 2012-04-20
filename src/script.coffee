$(document).ready ->
  if not Detector.webgl
    Tracking.trackEvent 'webgl', 'nodetect', nonInteraction: true
    Detector.addGetWebGLMessage()
  else
    Tracking.trackEvent 'webgl', 'available', nonInteraction: true
    game = new Game {parentElement: document.body}
    game.init ->
      console.log 'Game initialized!'
      $('.loading').hide()
      game.start()
