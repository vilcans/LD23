FPS = 60
FRAME_LENGTH = 1 / FPS

toRadians = (degrees) -> degrees / 360 * 2 * Math.PI
toDegrees = (radians) -> radians / 2 / Math.PI * 360

class window.Game
  constructor: ({parentElement}) ->
    @parentElement = parentElement
    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraRotationSpeed = 0  # radians per second

    @ships = []

  init: (onFinished) ->
    @graphics.loadAssets(onFinished)

  start: ->
    @graphics.createScene()
    @graphics.start()

    @addShip(toRadians(59.329444), toRadians(18.068611))
    @addShip(toRadians(50.329444), toRadians(18.068611))
    @addShip(toRadians(40.329444), toRadians(18.068611))
    @addShip(toRadians(40.329444), toRadians(8.068611))
    @addShip(toRadians(30.329444), toRadians(8.068611))

    @addShip(toRadians(40.329444), toRadians(0))
    @addShip(toRadians(30.329444), toRadians(0))

    for lat in [-9..9]
      @addShip(toRadians(lat * 10), 0)

    @selectedShip = @addShip(0, 0)

    $(@parentElement)
      .mousedown(@onMouseDown)
      .mouseup(@onMouseUp)

    document.addEventListener 'mozvisibilitychange', @handleVisibilityChange, false
    if document.mozVisibilityState and document.mozVisibilityState != 'visible'
      console.log 'Not starting animation because game not visible'
    else
      @startAnimation()

    document.addEventListener 'keypress', @onKeypress

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

  addShip: (latitude, longitude) ->
    mesh = @graphics.addShip()
    ship = new Ship(mesh, latitude, longitude)
    @ships.push ship
    return ship

  handleVisibilityChange: (e) =>
    if document.mozVisibilityState != 'visible'
      @stopAnimation()
    else
      @startAnimation()

  animate: =>
    deltaTime = FRAME_LENGTH
    if @selectedShip
      @cameraLongitude = @selectedShip.longitude
    else if not @dragging
      @cameraLongitude += @cameraRotationSpeed * deltaTime
      @cameraRotationSpeed *= Math.pow(.1, deltaTime)
      if Math.abs(@cameraRotationSpeed) < .01
        @cameraRotationSpeed = 0

    document.getElementById('camera-longitude').innerHTML = toDegrees(@cameraLongitude) + '\u00b0'
    for ship in @ships
      ship.animate(deltaTime)
      ship.updateMesh()

    cameraAltitude = 3.4
    @graphics.setCameraPosition(
      Math.sin(@cameraLongitude) * cameraAltitude,
      0,
      Math.cos(@cameraLongitude) * cameraAltitude
    )
    @graphics.render()

  onKeypress: (event) =>
    console.log 'keypress', event
    if event.charCode == 65 or event.charCode == 97
      @selectedShip.bearing += Math.PI * 2 / 36
    else if event.charCode == 68 or event.charCode == 100
      @selectedShip.bearing -= Math.PI * 2 / 36
    else if event.charCode == 87 or event.charCode = 119
      @selectedShip.speed += .1
    else if event.charCode == 83 or event.charCode = 115
      @selectedShip.speed -= .1

    console.log 'bearing', @selectedShip.bearing

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
