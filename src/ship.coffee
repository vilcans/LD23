class window.Ship
  constructor: ({name, mesh, listElement, latitude, longitude}) ->
    @name = name or Ship.createName()
    @htmlName = '<span class="ship">' + @name + '</span>'
    @alive = true
    @mesh = mesh
    @listElement = listElement
    @latitude = latitude
    @longitude = longitude
    @speed = 0 # equatorial radians per second
    @bearing = 0  # radians, where 0 is east

    @maxSpeed = .4
    @minSpeed = -.2
    # equatorial radians per second squared
    @acceleration = .3
    @deceleration = .3

    @turnSpeed = Math.PI  # radians per second

  animate: (deltaTime) ->
    cosLat = Math.cos(@latitude)
    @longitude = wrapAngle(
      @longitude + @speed * Math.cos(@bearing) / cosLat * deltaTime
    )

    @latitude += @speed * Math.sin(@bearing) * deltaTime
    if @latitude >= Math.PI / 2
      @longitude -= Math.PI
      @bearing += Math.PI
    else if @latitude <= -Math.PI / 2
      @longitude -= Math.PI
      @bearing -= Math.PI

  updateMesh: ->
    @mesh.eulerOrder = 'YXZ'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
    @mesh.rotation.z = @bearing

  brakeAtPort: (deltaTime) ->
    @speed *= Math.pow(RETARDATION_AT_PORT, deltaTime)

  collidesWith: (otherShip) ->
    d2 = distanceSquared(
      @latitude, @longitude,
      otherShip.latitude, otherShip.longitude
    )
    return d2 <= SHIP_RADIUS_SQUARED

  accelerate: (deltaTime) ->
    @speed += @acceleration * deltaTime
    if @speed > @maxSpeed
      @speed = @maxSpeed

  decelerate: (deltaTime) ->
    @speed -= @deceleration * deltaTime
    if @speed < @minSpeed
      @speed = @minSpeed

  turn: (direction, deltaTime) ->
    delta = direction * @turnSpeed * deltaTime * Math.abs(@speed / @maxSpeed)
    @bearing = wrapAngle(@bearing + delta)

nextNameIndex = 0
Ship.createName = ->
  #i = Math.floor(Math.random() * shipNames.length)
  name = "M/S #{shipNames[nextNameIndex]}"
  nextNameIndex = (nextNameIndex + 31) % shipNames.length
  return name
