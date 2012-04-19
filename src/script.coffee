$(document).ready ->
  if not Detector.webgl
    Tracking.trackEvent 'webgl', 'nodetect', nonInteraction: true
    Detector.addGetWebGLMessage()
  else
    Tracking.trackEvent 'webgl', 'available', nonInteraction: true
    game = new Game(document.body)
    game.loadAssets ->
      console.log 'assets loaded!'
      $('.loading').hide()
      game.createScene()
      game.start()
