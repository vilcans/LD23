FPS = 60
FRAME_LENGTH = 1 / FPS

class window.Game
  constructor: ({
    parentElement,
    eventsElement,
    fleetListElement,
    announcementListElement,
    fleetHelpElement,
    dropoffsElement,
    gameoverCallback
  }) ->
    @parentElement = parentElement
    @eventsElement = eventsElement
    @fleetListElement = fleetListElement
    @announcementListElement = announcementListElement
    @fleetHelpElement = fleetHelpElement
    @dropoffsElement = dropoffsElement;
    @gameoverCallback = gameoverCallback;

    @graphics = new Graphics(parentElement)

    @cameraLongitude = 0  # radians
    @cameraLatitude = 0  # radians
    @cameraRotationSpeed = 0  # radians per second

    @ships = []
    @ports = []
    @timeToNextPickup = 1e9

    @followingSelected = false
    @keys = {}

    @animating = false

    @dropoffs = 0

    @totalTime = 0

  init: (onFinished) ->
    @graphics.loadAssets =>
      @map = new Map(@graphics.waterImage)
      onFinished()

  start: ->
    @graphics.createScene()
    @graphics.start()

    s1 = @addShip(0.2606300172003132, -0.42556363151377735)
    s1.bearing = Math.PI * .6
    s1.maxSpeed /= 2
    s2 = @addShip(toRadians(40.664167 - 1), toRadians(-73.938611 + 2))
    s2.bearing = Math.PI * .2
    s2.maxSpeed /= 3
    s3 = @addShip(0.371910271053,-2.75458528451)
    s3.bearing = Math.PI * .2
    s3.maxSpeed /= 3

    #@addDummyShips()

    @addPort('New York', toRadians(40.664167 - 1), toRadians(-73.938611 + 2))
    @addPort('Shanghai', toRadians(31.22222), toRadians(121.45806))
    @addPort('Rotterdam', toRadians(51.921667 + 1), toRadians(4.481111))
    @addPort('Goose Bay', toRadians(53.302 + 2), toRadians(-60.417 + 2))
    @addPort('Santo Domingo', toRadians(18.5 - 1), toRadians(-69.983333))
    # http://ports.com/cape-verde/port-of-vale-cavaleiros/
    @addPort('Cape Verde', 0.2606300172003132, -0.42556363151377735)
    #@addPort('Bergen', toRadians(60.41), toRadians(5.01))
    @addPort 'Hellesøya', toRadians(63.98), toRadians(9.85) #Hellesøya
    @addPort 'Rio de Janeiro', -0.401425727959,-0.768235759086
    @addPort 'Casablanca', 0.586295801985,-0.130824353854

    @addPort 'Honolulu', 0.371910271053,-2.75458528451

    $(@graphics.renderer.domElement)
      .mousedown(@onMouseDown)
      .click(@onMouseClick)
    $(document.body).mouseup(@onMouseUp)

    document.addEventListener 'mozvisibilitychange', @handleVisibilityChange, false
    if document.mozVisibilityState and document.mozVisibilityState != 'visible'
      console.log 'Not starting animation because game not visible'
    else
      @startAnimation()

    $(document).keydown(@onKeyDown).keyup(@onKeyUp)

  startAnimation: ->
    if @animating
      console.log 'animation already started!'
    else
      console.log 'starting animation'
      @animating = true
      requestAnimationFrame @animationFrame

  stopAnimation: ->
    if not @animating
      console.log 'animation not running'
    else
      @animating = false

  addShip: (latitude, longitude) ->
    mesh = @graphics.addShip()
    ship = new Ship {
      mesh: mesh, latitude: latitude, longitude: longitude
    }
    @ships.push ship
    li = document.createElement('li')
    nameElement = document.createElement('div')
    nameElement.className = 'ship'
    nameElement.innerHTML = ship.name
    destinationElement = document.createElement('div')
    nameElement.className = 'destination'
    destinationElement.innerHTML = '&nbsp;' #\u2192 Rotterdam'
    li.appendChild(nameElement)
    li.appendChild(destinationElement)
    li.addEventListener 'click', (event) =>
      if @fleetHelpElement
        @fleetHelpElement.parentNode.removeChild(@fleetHelpElement)
        @fleetHelpElement = null
        @announce 'Control ship with <strong>W A S D</strong>', 10000
        @timeToNextPickup = INITIAL_PICKUP_DELAY
      if ship.alive
        Audio.play 'select'
        @selectShip ship
    @fleetListElement.appendChild(li)
    ship.listElement = li
    ship.destinationElement = destinationElement
    return ship

  selectShip: (ship) ->
    if @selectedShip
      @deselectShip()
    @followingSelected = true
    @selectedShip = ship
    ship.listElement.className = 'selected'

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

  animationFrame: =>
    if @animating
      requestAnimationFrame @animationFrame
    @animate()

  animate: =>
    deltaTime = FRAME_LENGTH
    @totalTime += deltaTime

    if @ships.length == 0 and not @gameover
      window.setTimeout(@gameoverCallback, 2000)
      @announce 'You have lost your fleet!'
      @gameover = true
      Audio.play 'gameover'

    if @selectedShip
      if @keys.up
        @selectedShip.accelerate deltaTime
      else if @keys.down
        @selectedShip.decelerate deltaTime
      if @keys.left
        @selectedShip.turn 1, deltaTime
      if @keys.right
        @selectedShip.turn -1, deltaTime

    @animateShips(deltaTime)

    if (@timeToNextPickup -= deltaTime) <= 0 and not @gameover
      @timeToNextPickup = PICKUP_DELAY
      @createNewPickup()  # must be called after animateShips

    @collideShips()

    if @selectedShip and @followingSelected
      @cameraLongitude += wrapAngle(@selectedShip.longitude - @cameraLongitude) * CAMERA_SPEED
      @cameraLatitude += wrapAngle(@selectedShip.latitude - @cameraLatitude) * CAMERA_SPEED
      @cameraRotationSpeed = 0
    else
      @cameraLatitude += -@cameraLatitude * CAMERA_SPEED
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
      port.animate(@totalTime)
      port.mayBeDestination = true
      if port.pickup
        port.mayBePickup = false
        #port.reasons = ['already has pickup']
      else
        port.mayBePickup = true
        #port.reasons = []
    for port in @ports
      if port.pickup
        port.pickup.destination.mayBeDestination = false
        port.pickup.destination.mayBePickup = false
        #port.pickup.destination.reasons.push 'is pickup destination'

    for ship in @ships
      ship.animate(deltaTime)
      if not @map.isWater(ship.latitude, ship.longitude)
        Audio.play 'explosion'
        @announce "#{ship.htmlName} ran aground!"
        @destroyShip(ship)
        continue
      if ship.cargo
        ship.cargo.destination.mayBePickup = false
        ship.cargo.destination.mayBeDestination = false
        #ship.cargo.destination.reasons.push 'is loaded cargo destination'
      ship.updateMesh()
      for port in @ports
        d2 = distanceSquared(
          ship.latitude, ship.longitude,
          port.latitude, port.longitude)
        if d2 <= PORT_RADIUS_SQUARED
          port.mayBePickup = false
          #port.reasons.push 'has a ship'
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
          @announce "#{s1.htmlName} and #{s2.htmlName} collided!"
          Audio.play 'explosion'
          @destroyShip s1
          @destroyShip s2

  destroyShip: (ship) ->
    ship.alive = false
    if ship == @selectedShip
      @deselectShip()
    ship.listElement.className = 'destroyed'
    window.setTimeout((->
      ship.listElement.parentNode.removeChild(ship.listElement)
    ), 500)

    newArray = []
    for i in [0...@ships.length]
      if @ships[i] != ship
        newArray.push @ships[i]
    @ships = newArray
    @graphics.destroyShip ship.mesh

  deselectShip: ->
    if @selectedShip
      @selectedShip.listElement.className = ''
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
    @announce "New pickup at #{port.htmlName} to \u2192 #{destination.htmlName}"
    Audio.play 'new-request'
    return true

  shipReachedDestination: (ship) ->
    @announce "#{ship.htmlName} unloaded at \u2192 #{ship.cargo.destination.htmlName}"
    @dropoffs++
    @dropoffsElement.innerHTML = @dropoffs
    ship.destinationElement.innerHTML = '&nbsp;'
    ship.cargo = null
    ship.speed = 0
    Audio.play 'dropoff'

  pickup: (ship, port) ->
    ship.cargo = port.pickup
    port.pickup = null
    @announce "#{ship.htmlName} picked up cargo for \u2192 #{ship.cargo.destination.htmlName}"
    ship.destinationElement.innerHTML = '\u2192 ' + ship.cargo.destination.name
    Audio.play 'pickup'

  onKeyDown: (event) =>
    @setKeys event, true
    event.preventDefault()

  onKeyUp: (event) =>
    @setKeys event, false
    event.preventDefault()

  setKeys: (event, value) ->
    if event.ctrlKey or event.altKey
      return
    code = event.keyCode
    if code == 65 or code == 97
      @keys.left = value
    else if code == 68 or code == 100
      @keys.right = value
    else if code == 87 or code == 119
      @keys.up = value
    else if code == 83 or code == 115
      @keys.down = value

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
    x = event.clientX
    y = event.clientY

    if @dragging
      @followingSelected = false
      dx = x - @mouseX
      dy = y - @mouseY

      dLat = -dx / @graphics.dimensions.x * 3
      @cameraLongitude = wrapAngle(@cameraLongitude + dLat)
      @cameraRotationSpeed = dLat / FRAME_LENGTH

    @mouseX = x
    @mouseY = y

    event.preventDefault()

  announce: (html, delay=4000) ->
    li = document.createElement('li')
    li.innerHTML = html
    @announcementListElement.appendChild li
    window.setTimeout((->
      li.parentNode.removeChild(li)
    ), delay)
