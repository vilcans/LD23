FPS = 60
FRAME_LENGTH = 1 / FPS

class window.Game
  constructor: ({parentElement}) ->
    @parentElement = parentElement
    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraRotationSpeed = 0  # radians per second

  init: (onFinished) ->
    @graphics.loadAssets(onFinished)

  start: ->
    @graphics.createScene()
    @graphics.start()

    $(@parentElement)
      .mousedown(@onMouseDown)
      .mouseup(@onMouseUp)

    document.addEventListener 'mozvisibilitychange', @handleVisibilityChange, false
    if document.mozVisibilityState and document.mozVisibilityState != 'visible'
      console.log 'Not starting animation because game not visible'
    else
      @startAnimation()

  startAnimation: ->
    if @timer
      console.log 'animation already started!'
    else
      console.log 'starting animation'
      @timer = window.setInterval @animate, FRAME_LENGTH * 1000

  stopAnimation: ->
    if not @timer
      console.log 'animation not running'
    else
      console.log 'stopping animation'
      window.clearInterval @timer
      @timer = null

  handleVisibilityChange: (e) =>
    if document.mozVisibilityState != 'visible'
      @stopAnimation()
    else
      @startAnimation()

  animate: =>
    deltaTime = FRAME_LENGTH
    if not @dragging
      @cameraLongitude += @cameraRotationSpeed * deltaTime
      @cameraRotationSpeed *= Math.pow(.1, deltaTime)
      if Math.abs(@cameraRotationSpeed) < .001
        @cameraRotationSpeed = 0

    cameraAltitude = 3.0
    @graphics.setCameraPosition(
      Math.sin(@cameraLongitude) * cameraAltitude,
      0,
      Math.cos(@cameraLongitude) * cameraAltitude
    )
    @graphics.render()

  onMouseDown: (event) =>
    @dragging = true
    @mouseX = event.clientX
    @mouseY = event.clientY

    @cameraRotationSpeed = 0
    $(@parentElement).mousemove @onMouseDrag

  onMouseUp: (event) =>
    @dragging = false
    $(@parentElement).off 'mousemove', @onMouseDrag

  onMouseDrag: (event) =>
    if not @dragging
      return

    x = event.clientX
    y = event.clientY
    dx = x - @mouseX
    dy = y - @mouseY

    dLat = -dx / @graphics.dimensions.x * 3
    @cameraLongitude += dLat
    @cameraRotationSpeed = dLat / FRAME_LENGTH

    @mouseX = x
    @mouseY = y
