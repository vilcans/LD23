class window.Ship
  constructor: (mesh, latitude, longitude) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude
    @speed = Math.PI * .1 # equatorial radians per second
    @bearing = 0  # radians, where 0 is east

  animate: (deltaTime) ->
    @longitude += @speed * Math.cos(@bearing) / Math.cos(@latitude) * deltaTime
    #@latitude += deltaTime * @speed.y
    #@longitude += deltaTime * @speed.x

  updateMesh: ->
    @mesh.eulerOrder = 'ZYX'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
