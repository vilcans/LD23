class window.Ship
  constructor: ({name, mesh, listElement, latitude, longitude}) ->
    @name = name or Ship.createName()
    @alive = true
    @mesh = mesh
    @listElement = listElement
    @latitude = latitude
    @longitude = longitude
    @speed = 0 # equatorial radians per second
    @bearing = 0  # radians, where 0 is east

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

Ship.createName = ->
  i = Math.floor(Math.random() * shipNames.length)
  return "M/S #{shipNames[i]}"
