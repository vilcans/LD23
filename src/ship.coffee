class window.Ship
  constructor: (mesh, latitude, longitude) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude
    @speed = Math.PI * .1 # equatorial radians per second
    @bearing = 0  # radians, where 0 is east

  animate: (deltaTime) ->
    @longitude += @speed * Math.cos(@bearing) / Math.cos(@latitude) * deltaTime
    @latitude += @speed * Math.sin(@bearing) * deltaTime
    # if @latitude >= Math.PI / 2
    #   @latitude -= Math.PI

  updateMesh: ->
    @mesh.eulerOrder = 'YXZ'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
    @mesh.rotation.z = @bearing
