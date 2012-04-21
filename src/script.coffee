$(document).ready ->
  if not Detector.webgl
    Tracking.trackEvent 'webgl', 'nodetect', nonInteraction: true
    $('.loading').hide()
    $('#game').hide()
    Detector.addGetWebGLMessage
      parent: document.getElementById('errors')
  else
    Tracking.trackEvent 'webgl', 'available', nonInteraction: true
    element = document.getElementById('game')
    game = new Game {parentElement: element}
    game.init ->
      console.log 'Game initialized!'
      $('.loading').hide()
      game.start()
