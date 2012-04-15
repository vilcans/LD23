$(document).ready ->
  if not Detector.webgl
    Detector.addGetWebGLMessage()
  else
    new Game(document.body)
