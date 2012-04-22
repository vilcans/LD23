FPS = 60
FRAME_LENGTH = 1 / FPS

class window.Game
  constructor: ({parentElement, eventsElement, fleetListElement}) ->
    @parentElement = parentElement
    @eventsElement = eventsElement
    @fleetListElement = fleetListElement

    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraLatitude = 0  # radians
    @cameraRotationSpeed = 0  # radians per second

    @ships = []
    @ports = []
    @timeToNextPickup = INITIAL_PICKUP_DELAY

  init: (onFinished) ->
    @graphics.loadAssets(onFinished)

  start: ->
    @graphics.createScene()
    @graphics.start()

    @addShip(0, 0)

    @addDummyShips()

    @addPort('Stockholm', toRadians(59.329444), toRadians(18.068611))
    @addPort('New York', toRadians(40.664167), toRadians(-73.938611))
    @addPort('Shanghai', toRadians(31.22222), toRadians(121.45806))
    @addPort('Rotterdam', toRadians(51.921667), toRadians(4.481111))
    @addPort('Goose Bay', toRadians(53.302), toRadians(-60.417))
    #@addPort('Santo Domingo', toRadians())
    # http://ports.com/cape-verde/port-of-vale-cavaleiros/
    @addPort('Cape Verde', 0.2606300172003132, -0.42556363151377735)

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
    ship = new Ship {
      mesh: mesh, latitude: latitude, longitude: longitude
    }
    @ships.push ship
    li = document.createElement('li')
    a = document.createElement('a')
    a.href = '#'
    a.innerHTML = ship.name
    li.addEventListener 'click', (event) =>
      if ship.alive
        @selectShip ship
    li.appendChild(a)
    @fleetListElement.appendChild(li)
    ship.listElement = li
    return ship

  selectShip: (ship) ->
    if @selectedShip
      @deselectShip()
    @selectedShip = ship
    $(ship.listElement).addClass('selected')

  addPort: (name, latitude, longitude) ->
    mesh = @graphics.addPort()
    port = new Port(mesh, latitude, longitude, name)
    @ports.push port
    return port

  handleVisibilityChange: (e) =>
    if document.mozVisibilityState != 'visible'
      @stopAnimation()
    else
      @startAnimation()

  animate: =>
    deltaTime = FRAME_LENGTH

    @animateShips(deltaTime)

    if (@timeToNextPickup -= deltaTime) <= 0
      @timeToNextPickup = PICKUP_DELAY
      @createNewPickup()  # must be called after animateShips

    @collideShips()

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

    @graphics.setCamera @cameraLatitude, @cameraLongitude, CAMERA_ALTITUDE
    @graphics.render()

  addDummyShips: ->
    for lat in [-8..8]
      ship = @addShip toRadians(lat * 10), THREE.Math.randFloatSpread(Math.PI / 2)
      ship.bearing = THREE.Math.randFloatSpread(Math.PI)
      ship.speed = .1

  # Animates all ships and also sets the
  # mayBeDestination and mayBePickup on the ports.
  animateShips: (deltaTime) ->
    for port in @ports
      port.mayBeDestination = true
      if port.pickup
        port.mayBePickup = false
        port.reasons = ['already has pickup']
      else
        port.mayBePickup = true
        port.reasons = []
    for port in @ports
      if port.pickup
        port.pickup.destination.mayBeDestination = false
        port.pickup.destination.mayBePickup = false
        port.pickup.destination.reasons.push 'is pickup destination'

    for ship in @ships
      ship.animate(deltaTime)
      if ship.cargo
        ship.cargo.destination.mayBePickup = false
        ship.cargo.destination.mayBeDestination = false
        ship.cargo.destination.reasons.push 'is loaded cargo destination'
      ship.updateMesh()
      for port in @ports
        d2 = distanceSquared(
          ship.latitude, ship.longitude,
          port.latitude, port.longitude)
        if d2 <= PORT_RADIUS_SQUARED
          port.mayBePickup = false
          port.reasons.push 'has a ship'
          shipAtDestination = (ship.cargo and ship.cargo.destination == port)
          shipCanPickUp = (not ship.cargo and port.pickup)
          if shipAtDestination or shipCanPickUp
            ship.brakeAtPort(deltaTime)
            if Math.abs(ship.speed) <= MAX_SPEED_AT_PORT
              if shipAtDestination
                @shipReachedDestination ship
              else
                @pickup ship, port

  collideShips: ->
    for s1 in @ships
      for s2 in @ships
        if s1 == s2
          continue
        if s1.collidesWith(s2)
          console.log 'Ships collided!'
          @destroyShip s1
          @destroyShip s2

  destroyShip: (ship) ->
    ship.alive = false
    $element = $(ship.listElement)
    $element.slideUp 500, ->
      $element.remove()
    if ship == @selectedShip
      @deselectShip()
    newArray = []
    for i in [0...@ships.length]
      if @ships[i] != ship
        newArray.push @ships[i]
    @ships = newArray
    @graphics.destroyShip ship.mesh

  deselectShip: ->
    if @selectedShip
      $(@selectedShip.listElement).removeClass 'selected'
      @selectedShip = null

  createNewPickup: ->
    port = @ports[Math.floor(Math.random() * @ports.length)]
    destination = @ports[Math.floor(Math.random() * @ports.length)]
    if port == destination
      return false
    if not port.mayBePickup
      #console.log "Not allowed to use #{port.name} as pickup point"
      return false
    if not destination.mayBeDestination
      #console.log "Not allowed to use #{destination.name} as destination"
      return false

    port.pickup = new Cargo destination: destination
    console.log "New pickup at #{port.name} to #{destination.name}"
    Audio.play 'new-request'
    return true

  shipReachedDestination: (ship) ->
    console.log "ship reached destination"
    ship.cargo = null
    ship.speed = 0
    Audio.play 'dropoff'

  pickup: (ship, port) ->
    ship.cargo = port.pickup
    port.pickup = null
    console.log "Picked up cargo at #{port.name} with destination #{ship.cargo.destination.name}"
    Audio.play 'pickup'

  onKeypress: (event) =>
    if event.ctrlKey or event.altKey
      return

    if @selectedShip
      if event.charCode == 65 or event.charCode == 97
        @selectedShip.bearing = wrapAngle(@selectedShip.bearing + Math.PI * 2 / 36)
      else if event.charCode == 68 or event.charCode == 100
        @selectedShip.bearing = wrapAngle(@selectedShip.bearing - Math.PI * 2 / 36)
      else if event.charCode == 87 or event.charCode == 119
        @selectedShip.speed += .1
      else if event.charCode == 83 or event.charCode == 115
        @selectedShip.speed -= .1

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
