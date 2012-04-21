class window.Game
  constructor: ({parentElement}) ->
    @parentElement = parentElement
    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraRotationSpeed = Math.PI * 2 / 2  # radians per second

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
      @timer = window.setInterval @animate, 1000 / 60

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
    deltaTime = 1 / 60
    @cameraLongitude += @cameraRotationSpeed * deltaTime
    console.log 'camera longitude', @cameraLongitude
    cameraAltitude = 3.0
    @graphics.setCameraPosition(
      Math.sin(@cameraLongitude) * cameraAltitude,
      0,
      Math.cos(@cameraLongitude) * cameraAltitude
    )
    @graphics.render()

  onMouseDown: (event) =>
    @mouseX = event.clientX
    @mouseY = event.clientY

    $(@parentElement).mousemove @onMouseDrag

  onMouseUp: (event) =>
    $(@parentElement).off 'mousemove', @onMouseDrag

  onMouseDrag: (event) =>
    x = event.clientX
    y = event.clientY
    dx = x - @mouseX
    dy = y - @mouseY
    @graphics.camera.translateX dx * -.01
    @graphics.camera.translateY dy * .01
    @graphics.camera.updateMatrix()
    @mouseX = x
    @mouseY = y
