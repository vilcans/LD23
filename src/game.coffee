FPS = 60
FRAME_LENGTH = 1 / FPS

class window.Game
  constructor: ({parentElement, eventsElement}) ->
    @parentElement = parentElement
    @eventsElement = eventsElement
    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraLatitude = 0  # radians
    @cameraRotationSpeed = 0  # radians per second

    @ships = []
    @ports = []

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

    for lat in [-8..8]
      @addShip(toRadians(lat * 10), 0)

    @selectedShip = @addShip(0, 0)

    @addPort('Stockholm', toRadians(59.329444), toRadians(18.068611))
    @addPort('Atlantic', 0, 0)

    $(@eventsElement)
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

  addPort: (name, latitude, longitude) ->
    mesh = @graphics.addPort()
    port = new Port(mesh, latitude, longitude)
    @ports.push port
    return port

  handleVisibilityChange: (e) =>
    if document.mozVisibilityState != 'visible'
      @stopAnimation()
    else
      @startAnimation()

  animate: =>
    deltaTime = FRAME_LENGTH
    if @selectedShip
      @cameraLongitude = @selectedShip.longitude
      @cameraLatitude = @selectedShip.latitude
    else
      @cameraLatitude = 0
      if not @dragging
        @cameraLongitude += @cameraRotationSpeed * deltaTime
        @cameraRotationSpeed *= Math.pow(.1, deltaTime)
        if Math.abs(@cameraRotationSpeed) < .01
          @cameraRotationSpeed = 0

    document.getElementById('camera-longitude').innerHTML = toDegrees(@cameraLongitude) + '\u00b0'
    for ship in @ships
      ship.animate(deltaTime)
      ship.updateMesh()

    @graphics.setCamera @cameraLatitude, @cameraLongitude, 2.4
    @graphics.render()

  onKeypress: (event) =>
    console.log 'keypress', event
    if event.ctrlKey or event.altKey
      return

    handled = true
    if @selectedShip
      if event.charCode == 65 or event.charCode == 97
        @selectedShip.bearing = wrapAngle(@selectedShip.bearing + Math.PI * 2 / 36)
      else if event.charCode == 68 or event.charCode == 100
        @selectedShip.bearing = wrapAngle(@selectedShip.bearing - Math.PI * 2 / 36)
      else if event.charCode == 87 or event.charCode == 119
        @selectedShip.speed += .1
      else if event.charCode == 83 or event.charCode == 115
        @selectedShip.speed -= .1
      else
        handled = false
      if handled
        console.log 'bearing', @selectedShip.bearing, 'speed', @selectedShip.speed

    event.preventDefault()

  onMouseDown: (event) =>
    @dragging = true
    @mouseX = event.clientX
    @mouseY = event.clientY

    @cameraRotationSpeed = 0
    $(@eventsElement).mousemove @onMouseDrag
    event.preventDefault()

  onMouseUp: (event) =>
    @dragging = false
    $(@eventsElement).off 'mousemove', @onMouseDrag

  onMouseDrag: (event) =>
    if not @dragging
      return

    x = event.clientX
    y = event.clientY
    dx = x - @mouseX
    dy = y - @mouseY

    dLat = -dx / @graphics.dimensions.x * 3
    @cameraLongitude = wrapAngle(@cameraLongitude + dLat)
    @cameraRotationSpeed = dLat / FRAME_LENGTH

    @mouseX = x
    @mouseY = y

    event.preventDefault()
