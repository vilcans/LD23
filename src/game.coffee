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
    moneyElement,
    gameoverCallback
  }) ->
    @parentElement = parentElement
    @eventsElement = eventsElement
    @fleetListElement = fleetListElement
    @announcementListElement = announcementListElement
    @fleetHelpElement = fleetHelpElement
    @dropoffsElement = dropoffsElement;
    @moneyElement = moneyElement;
    @gameoverCallback = gameoverCallback;

    @graphics = new Graphics(parentElement, document.location.hash == '#stats')
    @keyboard = new Keyboard

    @cameraLongitude = -0.6181649663459371  # radians
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

    @money = 100
    @premium = 1  # dollars per second

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
    s1.minSpeed /= 2
    s2 = @addShip(toRadians(40.664167 - 1), toRadians(-73.938611 + 2))
    s2.bearing = Math.PI * .2
    s2.maxSpeed /= 8
    s2.minSpeed /= 8
    s3 = @addShip(0.371910271053,-2.75458528451)  # Honolulu
    s3.bearing = Math.PI * .2
    s3.maxSpeed /= 3
    s3.minSpeed /= 3

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
    @addPort 'Cape Town', -0.592107796876,0.321557522133

    @addPort 'Honolulu', 0.371910271053,-2.75458528451

    @addPort 'Los Angeles', 0.594284610304,-2.06385184048
    @addPort 'Wellington', -0.720530092865,3.05054464428
    @addPort 'Sydney', -0.590967999912,2.63913175449
    @addPort 'Anchorage', 1.06845663111 - .025,-2.61611764905
    @addPort 'Cod Bay', 0.149631246171,1.41713283676

    $(@graphics.renderer.domElement)
      .mousedown(@onMouseDown)
      .click(@onMouseClick)
    $(document.body).mouseup(@onMouseUp)

    document.addEventListener 'mozvisibilitychange', @handleVisibilityChange, false
    if document.mozVisibilityState and document.mozVisibilityState != 'visible'
      console.log 'Not starting animation because game not visible'
    else
      @startAnimation()

    $(document).keydown(@keyboard.onKeyDown).keyup(@keyboard.onKeyUp)

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

  endGame: ->
    window.setTimeout(@gameoverCallback, 2000)
    @gameover = true
    Audio.play 'gameover'

  animate: =>
    deltaTime = FRAME_LENGTH
    @totalTime += deltaTime

    if not @gameover
      @money -= deltaTime * @premium
      if @money <= 0
        @money = 0
        @announce 'Out of funding!'
        @endGame()
        for s in @ships
          @destroyShip s
      @moneyElement.innerHTML = '' + Math.ceil(@money)

    if @ships.length == 0 and not @gameover
      @announce 'You have lost your fleet!'
      @endGame()

    if @selectedShip
      oldSpeed = @selectedShip.speed
      if @keyboard.pressed.up
        newSpeed = @selectedShip.accelerate(deltaTime)
        if oldSpeed < 0 and newSpeed >= 0
          @selectedShip.speed = 0
          @keyboard.drop 'up'
      else if @keyboard.pressed.down
        newSpeed = @selectedShip.decelerate(deltaTime)
        if oldSpeed > 0 and newSpeed <= 0
          @selectedShip.speed = 0
          @keyboard.drop 'down'

      if @keyboard.pressed.left
        @selectedShip.turn 1, deltaTime
      if @keyboard.pressed.right
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
        @increasePremium 1
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
          @increasePremium 2

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

  increasePremium: (factor) ->
    @premium += factor
    if @premiumAnnounceTimer
      window.clearTimeout @premiumAnnounceTimer
    @premiumAnnounceTimer = window.setTimeout(
      =>
        @premiumAnnounceTimer = null
        if not @gameover
          perMinute = @premium * 60
          @announce "Insurance premium raised to $#{perMinute}/minute"
      2000
    )

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
    @money += 20
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
